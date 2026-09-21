#!/usr/bin/env bash
# COMP-175 Lab 3 cleanup: removes everything setup.sh (and the lab) created,
# so you can start over or leave the VM tidy.   sudo bash cleanup.sh
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "run with sudo:  sudo bash $0" >&2; exit 1; }

pkill -u mreyes 2>/dev/null
pkill -u jokafor 2>/dev/null
pkill -u tnguyen 2>/dev/null
pkill -f 'inotifywait.*/srv/registrar' 2>/dev/null
pkill -f 'http.server 8000' 2>/dev/null

for u in mreyes jokafor tnguyen; do
  id "$u" >/dev/null 2>&1 && userdel -r "$u" 2>/dev/null
done
for g in registrars auditors; do
  getent group "$g" >/dev/null && groupdel "$g"
done

rm -rf /srv/registrar /opt/registrar /var/backups/registrar
rm -f /usr/local/bin/backup-grades.sh /etc/sudoers.d/90-registrar-backup
rm -f /etc/ssh/sshd_config.d/10-lab.conf /tmp/registrar-watch.log
systemctl reload ssh 2>/dev/null

echo "Lab 3 cleaned up. Run setup.sh again to start over."
