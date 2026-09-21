#!/usr/bin/env bash
# Copies the registrar grades file into /var/backups/registrar with a timestamp.
# Needs root, which is the point of Lab 3 Q6: allow this one script via sudo.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "backup-grades.sh must run as root" >&2; exit 1; }

dest=/var/backups/registrar
install -d -m 750 "$dest"
out="$dest/grades-$(date +%Y%m%d-%H%M%S).csv"
cp /srv/registrar/grades.csv "$out"
echo "Backup written: $out ($(wc -l < "$out") lines)"
