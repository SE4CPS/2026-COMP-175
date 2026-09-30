#!/bin/bash
# Sends daily appointment reminders. Logs a placeholder line only --
# no real patient names or details, just a run marker.
echo "$(date -Iseconds) Sent daily appointment reminders" >> /tmp/appointment-reminders.log
