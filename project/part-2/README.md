# Project Part 2: ER Hospital System

## Shared clinical-data seed (coming soon)

This folder will hold a setup script every team pulls onto their
**Ubuntu** VM, so every Ubuntu VM starts from the same identical
baseline: the same synthetic clinical data, the same 4 persona
accounts (`guest1`, `nurse1`, `physician1`, `patient1`). No team
should start from a different copy or a blank box.

**Clinical Data & Access Control** is the team that then actually
configures the real per-persona RBAC on top of that shared baseline
(narrower read/write rules for nurses vs. physicians vs. patients).

All seed data will be entirely synthetic — fake names, fake record
numbers, no real patient information. Same convention as this
repo's Module 4 medical-records lab.

## Team folders

Each team pushes its own Kali-side dashboard code and role scripts
to its own folder:

- `team1/` — Monitor Read
- `team2/` — Monitor Write
- `team3/` — Attacker
- `team4/` — Clinical Data & Access Control
- `team5/` — Clinical Web Interface

See the Project Part 2 description (shared separately) for the full
assignment brief.
