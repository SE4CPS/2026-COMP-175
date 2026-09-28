#!/usr/bin/env bash
# COMP-175 Project Part 1 -- reverses setup.sh. Run as a sudo-capable user:
#   sudo bash cleanup.sh
set -euo pipefail

echo "== Removing Project Part 1 scenario from hospital-records =="

systemctl disable --now hospital-sync.timer >/dev/null 2>&1 || true
rm -f /etc/systemd/system/hospital-sync.service /etc/systemd/system/hospital-sync.timer
systemctl daemon-reload

rm -f /etc/sudoers.d/hospital-backup
rm -f /etc/ssh/sshd_config.d/00-project-part1.conf
rm -rf /opt/hospital
rm -rf /var/backups/hospital
rm -rf /srv/hospital-records
rm -f /var/log/hospital-sync.log
rm -f /root/bounty-flag.txt

if id contractor >/dev/null 2>&1; then
  userdel -r contractor >/dev/null 2>&1 || true
fi
if id intern >/dev/null 2>&1; then
  userdel -r intern >/dev/null 2>&1 || true
fi
getent group svc-backup >/dev/null && groupdel svc-backup || true
getent group hospital >/dev/null && groupdel hospital || true

systemctl reload ssh 2>/dev/null || service ssh reload 2>/dev/null || true

echo "== Cleanup done =="
