#!/bin/bash
# oil-check.sh -- simulated daily oil-level check, meant to run from cron
level=$(( RANDOM % 100 ))
echo "$(date '+%Y-%m-%d %H:%M:%S') oil_level=${level}%" >> /tmp/oil-check.log
if [ "$level" -lt 20 ]; then
  echo "WARNING: oil level low ($level%)"
fi
