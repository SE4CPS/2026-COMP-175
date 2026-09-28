#!/usr/bin/env bash
# COMP-175 Project Part 1 -- hospital-records (Ubuntu) setup script.
# Run this ON the hospital-records VM, as a sudo-capable user:
#   sudo bash setup.sh
#
# Re-running resets the scenario back to its "as delivered" state.
set -euo pipefail

echo "== COMP-175 Project Part 1: setting up hospital-records =="

# ---- packages ----
apt-get update -y -qq
apt-get install -y -qq acl inotify-tools openssh-server >/dev/null

# ---- group + service account ----
getent group hospital >/dev/null || groupadd hospital
getent group svc-backup >/dev/null || groupadd svc-backup

if ! id contractor >/dev/null 2>&1; then
  useradd -m -s /bin/bash -G svc-backup contractor
fi
passwd -l contractor >/dev/null   # no password login -- key auth only

mkdir -p /home/contractor/.ssh
cat > /home/contractor/.ssh/authorized_keys <<'PUBKEY'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAPMedcmpXLtA6dsupdvf1ha/jQtktoE6vy+4rxBq7W contractor@hospital-records (COMP-175 Project Part 1 -- intentionally leaked lab key, do not reuse)
PUBKEY
chown -R contractor:contractor /home/contractor/.ssh
chmod 700 /home/contractor/.ssh
chmod 600 /home/contractor/.ssh/authorized_keys

# ---- records directory ----
mkdir -p /srv/hospital-records
cat > /srv/hospital-records/patients.csv <<'CSV'
record_id,room,admit_date,status
H-1001,204,2026-09-02,active
H-1002,211,2026-09-05,active
H-1003,118,2026-09-10,discharged
H-1004,305,2026-09-14,active
H-1005,102,2026-09-16,active
CSV
cat > /srv/hospital-records/billing.log <<'LOG'
2026-09-02 09:14 record=H-1001 amount=340.00 status=posted
2026-09-05 11:02 record=H-1002 amount=190.50 status=posted
2026-09-10 14:47 record=H-1003 amount=725.00 status=posted
2026-09-14 08:30 record=H-1004 amount=110.00 status=pending
2026-09-16 16:05 record=H-1005 amount=95.00 status=pending
LOG
chown -R root:hospital /srv/hospital-records
chmod 750 /srv/hospital-records
chmod 640 /srv/hospital-records/patients.csv /srv/hospital-records/billing.log

# ---- backup script (left over from the contractor's hurried setup) ----
mkdir -p /opt/hospital /var/backups/hospital
cat > /opt/hospital/backup.sh <<'SCRIPT'
#!/usr/bin/env bash
# Nightly backup of the records directory. Run via sudo/cron.
tar -czf /var/backups/hospital/records-$(date +%Y%m%d-%H%M%S).tar.gz \
  -C /srv hospital-records
echo "Backup complete."
SCRIPT
chown root:svc-backup /opt/hospital/backup.sh
chmod 775 /opt/hospital/backup.sh

# ---- sudoers entry the contractor set up for the backup job ----
cat > /etc/sudoers.d/hospital-backup <<'SUDOERS'
contractor ALL=(root) NOPASSWD: /opt/hospital/backup.sh
SUDOERS
chmod 440 /etc/sudoers.d/hospital-backup
visudo -cf /etc/sudoers.d/hospital-backup >/dev/null

# ---- the bounty flag ----
cat > /root/bounty-flag.txt <<'FLAG'
Congratulations -- you escalated to root on hospital-records.

Flag: HOSP-BOUNTY-D91E77EBFFF8AC67

Include this exact line in your Part 3 PDF report for bonus credit.
FLAG
chown root:root /root/bounty-flag.txt
chmod 600 /root/bounty-flag.txt

echo "== SETUP OK =="
echo "Server IP:"
hostname -I
echo
echo "Reminder: snapshot this VM now, BEFORE you do any of your own"
echo "hardening in Sections 4-5 of the assignment. Name the snapshot"
echo "'post-clone-vulnerable' -- you will need it for Section 6."
