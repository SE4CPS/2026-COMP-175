#!/bin/bash
# Starts 4 long-running background processes on the medical-unit server.
# Safe to inspect and kill -- nothing here touches real files outside /tmp.
DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$DIR"/*.sh

nohup "$DIR/vitals-logger.sh"  < /dev/null > /dev/null 2>&1 & disown
nohup "$DIR/labsync.sh"        < /dev/null > /dev/null 2>&1 & disown
nohup "$DIR/stuck-job.sh"      < /dev/null > /dev/null 2>&1 & disown
nohup "$DIR/backup-nightly.sh" < /dev/null > /dev/null 2>&1 & disown

echo "Started 4 background processes."
echo "Check them with: ps aux | grep -E 'vitals-logger|labsync|stuck-job|backup-nightly'"
