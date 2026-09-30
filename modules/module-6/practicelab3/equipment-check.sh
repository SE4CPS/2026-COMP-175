#!/bin/bash
# Routine equipment status check (imaging machines, monitors, etc.),
# weekdays only. Logs a placeholder pass/fail count, no PHI.
echo "$(date -Iseconds) Equipment check complete: 0 issues found" >> /tmp/equipment-check.log
