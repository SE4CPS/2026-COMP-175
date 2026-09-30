#!/bin/bash
# telemetry-logger.sh -- appends a simulated telemetry reading every
# few seconds, forever. Meant to be run in the background.
while true; do
  echo "$(date '+%H:%M:%S') speed=$(( RANDOM % 80 ))mph fuel=$(( RANDOM % 100 ))%" >> ~/telemetry.log
  sleep 5
done
