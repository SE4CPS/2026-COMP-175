# Module 4, Lab 2: Clinic Records Access Control

Synthetic sample data for the "Practice Lab Part 2" access-control exercises
(comp-175, Module 4). No real patient data (PHI) of any kind — every file is
a short, generic placeholder used only to exercise Linux permission/ACL
mechanics (ownership, group membership, ACLs, file-watching).

## Using this data

```
git clone https://github.com/SE4CPS/2026-COMP-175.git
cd 2026-COMP-175/modules/module-4/lab2
sudo cp -r sample-data/* /srv/patient-records/
sudo chown -R $(whoami) /srv/patient-records
```

## Contents

- `sample-data/record.txt` — a generic top-level record placeholder
- `sample-data/today/invoice.txt` — a generic billing placeholder
- `sample-data/today/notes.txt` — a generic front-desk notes placeholder
