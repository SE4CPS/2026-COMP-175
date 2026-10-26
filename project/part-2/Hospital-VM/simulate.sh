#!/bin/bash
# Project Part 2: ER Hospital System -- Hospital-VM activity simulator.
# Run on your own Ubuntu VM after setup.sh. Generates ongoing persona
# activity so Monitor Read has something to watch, Monitor Write has
# something to back up and restore, and the records don't just sit
# static the whole project. Logs every action it takes.
set -e
LOG=/var/log/clinical-activity.log
PERSONAS=(guest1 nurse1 physician1 patient1)

sudo touch "$LOG"
sudo chmod 644 "$LOG"

while true; do
  persona=${PERSONAS[$RANDOM % 4]}
  if sudo -u "$persona" cat /srv/clinical-data/patients.csv >/dev/null 2>&1; then
    result="allowed"
  else
    result="denied"
  fi
  echo "$(date '+%F %T') persona=$persona action=read result=$result" | sudo tee -a "$LOG" >/dev/null

  if (( RANDOM % 4 == 0 )); then
    sudo sed -i "2s/.*/ER-1001,Jordan Ellis,1990-03-14,ER-A,$(date '+%F %H:%M')/" /srv/clinical-data/patients.csv
    echo "$(date '+%F %T') action=vitals-update row=ER-1001" | sudo tee -a "$LOG" >/dev/null
  fi

  if (( RANDOM % 20 == 0 )); then
    sudo sed -i "3s/.*/CORRUPTED/" /srv/clinical-data/patients.csv
    echo "$(date '+%F %T') action=data-corruption row=3" | sudo tee -a "$LOG" >/dev/null
  fi

  sleep 30
done
