#!/bin/bash
# Scheduled for nighttime only -- running now is the second thing to catch.
while true; do
  dd if=/dev/zero of=/dev/null bs=1M count=50 2>/dev/null
  sleep 2
done
