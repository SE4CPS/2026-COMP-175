#!/usr/bin/env bash
# Simulated end-of-term report: burns one CPU core for at most 10 minutes,
# then exits on its own. Lab 3 Q8 finds it, lowers its priority and stops it.
end=$((SECONDS + 600))
echo "report-job started, pid $$"
while [ "$SECONDS" -lt "$end" ]; do :; done
echo "report-job finished"
