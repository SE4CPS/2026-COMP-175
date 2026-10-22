# Project Part 2: ER Hospital System

## Shared clinical-data seed

Run `setup.sh` on your **Ubuntu** VM so every Ubuntu VM starts from
the same identical baseline: the same synthetic clinical data, the
same 4 persona accounts (`guest1`, `nurse1`, `physician1`,
`patient1`). No team should start from a different copy or a blank
box.

```
sudo apt install -y git
git clone https://github.com/SE4CPS/2026-COMP-175.git
cd 2026-COMP-175/project/part-2
chmod +x setup.sh
./setup.sh
```

Seeds `/srv/clinical-data` from `sample-data/` and prints `SETUP OK`
when done. Safe to re-run if you need to reset back to the starting
state. The data starts world-readable on purpose: Team 4 tightens
the real permissions on top of this shared baseline.

**Clinical Data & Access Control** is the team that then actually
configures the real per-persona RBAC on top of that shared baseline
(narrower read/write rules for nurses vs. physicians vs. patients).

All seed data will be entirely synthetic: fake names, fake record
numbers, no real patient information. Same convention as this
repo's Module 4 medical-records lab.

## Team folders

Each team pushes its own Kali-side dashboard code and role scripts
to its own folder:

- `team1/`: Monitor Read (Joshua, Eivan, Darrel)
- `team2/`: Monitor Write (Anh, Andy, Andrew)
- `team3/`: Attacker (Charlie, Angadpaul, Joe)
- `team4/`: Clinical Data & Access Control (Toan, Kaung, Shomario)
- `team5/`: Clinical Web Interface (Gionni, Hernan, Gabriel, Elvin)

## Discord

Join the class server: https://discord.gg/2wuVZu6Fm

Use your own team's channel for day-to-day coordination:
questions, blockers, status-update drafts.

See the Project Part 2 description (shared separately) for the full
assignment brief.
