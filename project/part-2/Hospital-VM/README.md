# Hospital-VM: Shared Clinical Data Baseline

For all teams and all users: run this on your own Ubuntu VM so every
VM in the class starts from the exact same starting point.

## Setup

```
sudo apt install -y git
git clone https://github.com/SE4CPS/2026-COMP-175.git
cd 2026-COMP-175/project/part-2/Hospital-VM
chmod +x setup.sh
./setup.sh
```

Seeds `/srv/clinical-data` with synthetic clinical records and creates
4 persona accounts (`guest1`, `nurse1`, `physician1`, `patient1`).
Prints `SETUP OK` when done. Safe to re-run if you need to reset back
to the starting state.

**Clinical Data & Access Control** then configures the real
per-persona RBAC (narrower read/write rules for nurses vs. physicians
vs. patients) on top of this shared baseline.

## Activity simulator (optional, run after setup.sh)

```
chmod +x simulate.sh
nohup ./simulate.sh > /dev/null 2>&1 < /dev/null &
disown
```

Runs in the background and generates ongoing persona activity
(reads, occasional record updates) logged to
`/var/log/clinical-activity.log`, so Monitor Read has something real
to watch and Monitor Write has something real to back up and verify a
restore against. Stop it with `pkill -f simulate.sh`.

All seed data is entirely synthetic: fake names, fake record numbers,
no real patient information. Same convention as this repo's Module 4
medical-records lab.
