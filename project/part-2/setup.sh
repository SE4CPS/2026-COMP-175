#!/bin/bash
# Project Part 2: ER Hospital System -- shared clinical-data seed.
# Run on each team's Ubuntu VM so every VM starts identical.
# Synthetic data only. No real PHI. Safe to re-run.
set -e

echo "Seeding ER Hospital clinical data..."

for g in guests nurses physicians patients; do
  sudo groupadd -f "$g"
done

for u in guest1 nurse1 physician1 patient1; do
  sudo useradd -m -s /bin/bash "$u" 2>/dev/null || true
done
sudo usermod -aG guests guest1
sudo usermod -aG nurses nurse1
sudo usermod -aG physicians physician1
sudo usermod -aG patients patient1

sudo mkdir -p /srv/clinical-data
sudo cp -r "$(dirname "$0")/sample-data/." /srv/clinical-data/
sudo chown -R root:root /srv/clinical-data
sudo chmod 755 /srv/clinical-data
sudo chmod 644 /srv/clinical-data/*

echo "SETUP OK"
echo "Groups:   guests nurses physicians patients"
echo "Accounts: guest1 nurse1 physician1 patient1"
echo "Data:     /srv/clinical-data (world-readable baseline, not secure yet)"
echo ""
echo "This is a shared starting point, not the final RBAC config."
echo "Clinical Data & Access Control narrows real per-persona rules"
echo "on top of this baseline: it starts world-readable on purpose,"
echo "that is the real problem this team has to fix."
