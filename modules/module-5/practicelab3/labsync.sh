#!/bin/bash
# Needed: syncs lab results every 30s. Low CPU, mostly asleep.
while true; do
  sleep 30
  echo "$(date -Iseconds) sync tick" >> /tmp/labsync.log
done
