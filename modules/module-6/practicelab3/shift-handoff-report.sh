#!/bin/bash
# End-of-shift summary for the outgoing team. Logs a placeholder line,
# no patient-specific content.
echo "$(date -Iseconds) Shift handoff report generated" >> /tmp/shift-handoff-report.log
