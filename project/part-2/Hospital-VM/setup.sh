#!/bin/bash
# Project Part 2: ER Hospital System -- shared Hospital-VM baseline.
# Run on EVERY team's Ubuntu VM so every VM starts identical.
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
echo "patient1:Patient123!" | sudo chpasswd

sudo mkdir -p /srv/clinical-data
sudo cp -r "$(dirname "$0")/sample-data/." /srv/clinical-data/
sudo chown -R root:root /srv/clinical-data
sudo chmod 755 /srv/clinical-data
sudo chmod 644 /srv/clinical-data/*
sudo cp /srv/clinical-data/patients.csv /srv/clinical-data/.patients.csv.bak
sudo chmod 644 /srv/clinical-data/.patients.csv.bak

sudo mkdir -p /opt/hospital-vm
sudo tee /opt/hospital-vm/legacy-notify.sh > /dev/null <<'EOF'
#!/bin/bash
# TODO: retire, replaced by new notification pipeline
# patient1 / Patient123!
echo "legacy notify: disabled"
EOF
sudo chmod 644 /opt/hospital-vm/legacy-notify.sh

echo "SETUP OK"
echo "Groups:   guests nurses physicians patients"
echo "Accounts: guest1 nurse1 physician1 patient1"
echo "Data:     /srv/clinical-data (starting baseline, not secured yet)"
echo ""
echo "This is a shared starting point, not the final RBAC config."
echo "Clinical Data & Access Control narrows real per-persona rules"
echo "on top of this baseline: it starts world-readable on purpose,"
echo "that is the real problem this team has to fix."
