#!/bin/bash
echo "=== 1. Directory & File Permissions (ls -la /srv/clinical-data) ==="
ls -la /srv/clinical-data
echo ""
echo "=== 2. POSIX ACLs (getfacl /srv/clinical-data/patients.csv & patient1-chart.csv) ==="
getfacl -pc /srv/clinical-data/patients.csv /srv/clinical-data/patient1-chart.csv
echo ""
echo "=== 3. Live Per-Persona RBAC Verification Matrix ==="
for u in physician1 nurse1 patient1 guest1; do
  r_all=$(sudo -u "$u" head -n 1 /srv/clinical-data/patients.csv >/dev/null 2>&1 && echo "ALLOW" || echo "DENY ")
  w_all=$(sudo -u "$u" bash -c "test -w /srv/clinical-data/patients.csv" >/dev/null 2>&1 && echo "ALLOW" || echo "DENY ")
  r_own=$(sudo -u "$u" head -n 1 /srv/clinical-data/patient1-chart.csv >/dev/null 2>&1 && echo "ALLOW" || echo "DENY ")
  printf "Persona: %-10s | Master CSV Read: %s | Master CSV Write: %s | Own Chart Read: %s\n" "$u" "$r_all" "$w_all" "$r_own"
done
