#!/usr/bin/env bash
# COMP-175 Project Part 1 -- reverses setup.sh. Run as a sudo-capable user:
#   sudo bash cleanup.sh
set -euo pipefail

echo "== Removing Project Part 1 scenario from hospital-records =="

rm -f /etc/sudoers.d/hospital-backup
rm -rf /opt/hospital
rm -rf /var/backups/hospital
rm -rf /srv/hospital-records
rm -f /root/bounty-flag.txt

if id contractor >/dev/null 2>&1; then
  userdel -r contractor >/dev/null 2>&1 || true
fi
getent group svc-backup >/dev/null && groupdel svc-backup || true
getent group hospital >/dev/null && groupdel hospital || true

echo "== Cleanup done =="
