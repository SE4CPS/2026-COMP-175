#!/bin/bash
# Nightly backup of the unit's own scheduling records (never real
# patient records) to a local backup folder, both placeholders under /tmp.
SRC=/tmp/records
DST=/tmp/records-backup
mkdir -p "$SRC" "$DST"
tar czf "$DST/records-$(date +%Y%m%d).tar.gz" -C "$SRC" . 2>/dev/null
echo "$(date -Iseconds) Nightly backup complete" >> /tmp/nightly-backup.log
