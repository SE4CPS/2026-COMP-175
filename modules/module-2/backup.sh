#!/bin/bash
# backup.sh - back up the library catalog to a dated copy in archive/
#
# Not executable yet -- that's the point of the Module 2 permissions
# practice ("Lock Down backup.sh"): run `chmod 700 backup.sh` first.

set -e

DEST="archive/catalog-$(date +%Y%m%d).txt"
cp catalog.txt "$DEST"
echo "Backed up catalog.txt to $DEST"
