#!/bin/bash
# engine-scan.sh -- simulates a short engine sensor scan
echo "Starting engine scan (PID $$)..."
for i in 1 2 3 4 5; do
  rpm=$(( (RANDOM % 2000) + 800 ))
  temp=$(( (RANDOM % 40) + 180 ))
  echo "RPM: $rpm  Coolant Temp: ${temp}F"
  sleep 2
done
echo "Scan complete."
