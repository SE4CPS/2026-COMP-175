#!/bin/bash
# Needed: a light heartbeat logger. Low CPU, checks in every 5s.
while true; do
  echo "$(date -Iseconds) heartbeat OK" >> /tmp/vitals.log
  sleep 5
done
