#!/bin/bash
# dyno-monitor.sh -- simulated always-on sensor watch, meant to run as
# a systemd service (dyno-monitor.service). Prints one line every 10s.
while true; do
  echo "$(date '+%H:%M:%S') sensor OK"
  sleep 10
done
