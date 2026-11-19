#!/bin/bash
set -e

echo "=== Team 4: Applying Per-Persona RBAC on /srv/clinical-data ==="

# 0. Ensure all 4 persona accounts have active shells & no expiration for SSH/Team 5 gateway tests
for u in guest1 nurse1 physician1 patient1; do
  sudo usermod -s /bin/bash -e "" "$u" 2>/dev/null || true
done

# 1. Create a shared 'clinical' traversal group for staff + patient1 (excludes guest1!)
sudo groupadd -f clinical
sudo gpasswd -M nurse1,physician1,patient1 clinical >/dev/null

# 2. Lock down /srv/clinical-data directory:
#    - Owned by root:clinical with setgid (2750) so guest1 is completely blocked at the directory gate
sudo chown root:clinical /srv/clinical-data
sudo chmod 2750 /srv/clinical-data

# 3. Set Access & Default ACLs on /srv/clinical-data so even if simulate.sh runs 'sed -i',
#    newly recreated files automatically grant physicians=rw, nurses=r, patients=---, guests=---!
sudo setfacl -b /srv/clinical-data
sudo setfacl -m g:clinical:rx,g:physicians:rwx,g:nurses:rx,g:patients:rx,g:guests:---,o::--- /srv/clinical-data
sudo setfacl -d -m u::rw,g::---,g:physicians:rw,g:nurses:r,g:patients:---,g:guests:---,o::--- /srv/clinical-data

# 4. Configure /srv/clinical-data/patients.csv:
#    - physicians: rw- (Read + Write)
#    - nurses:     r-- (Read-Only)
#    - patients:   --- (Denied from reading all other patients' master CSV)
#    - guests:     --- (Denied)
sudo chown root:physicians /srv/clinical-data/patients.csv
sudo chmod 660 /srv/clinical-data/patients.csv
sudo setfacl -b /srv/clinical-data/patients.csv
sudo setfacl -m g:physicians:rw,g:nurses:r,g:patients:---,g:guests:---,o::--- /srv/clinical-data/patients.csv

# 5. Create patient1's own individual record (ER-1001) so patient1 can read ONLY their own chart
head -n 2 /srv/clinical-data/patients.csv | sudo tee /srv/clinical-data/patient1-chart.csv >/dev/null
sudo chown root:physicians /srv/clinical-data/patient1-chart.csv
sudo chmod 640 /srv/clinical-data/patient1-chart.csv
sudo setfacl -b /srv/clinical-data/patient1-chart.csv
sudo setfacl -m g:physicians:rw,g:nurses:r,u:patient1:r,g:patients:---,g:guests:---,o::--- /srv/clinical-data/patient1-chart.csv

# 6. Configure /srv/clinical-data/README.md (readable by physicians, nurses, patients; blocked for guests)
sudo chown root:clinical /srv/clinical-data/README.md
sudo chmod 640 /srv/clinical-data/README.md

# 7. Remediate Trap #1: Lock hidden .patients.csv.bak to root-only (600) so attackers cannot exfiltrate it
if [ -f /srv/clinical-data/.patients.csv.bak ]; then
  sudo chown root:root /srv/clinical-data/.patients.csv.bak
  sudo chmod 600 /srv/clinical-data/.patients.csv.bak
  sudo setfacl -b /srv/clinical-data/.patients.csv.bak
fi

# 8. Remediate Trap #2: Scrub leaked password from /opt/hospital-vm/legacy-notify.sh and lock to 700 root:root
sudo tee /opt/hospital-vm/legacy-notify.sh >/dev/null <<'LEGACY'
#!/bin/bash
# Retired legacy notification script (credentials scrubbed by Team 4)
echo "legacy notify: disabled"
LEGACY
sudo chown -R root:root /opt/hospital-vm
sudo chmod 700 /opt/hospital-vm /opt/hospital-vm/legacy-notify.sh

echo "=== RBAC Enforcement Complete ==="
