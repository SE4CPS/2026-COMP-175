# Module 5, Practice Lab Part 3: Process Triage

Scenario: your Ubuntu VM plays the role of a medical unit's server.
You connect to it from Kali over SSH using key-based login, then use
`spawn.sh` to start 4 background processes and practice figuring out
which ones actually belong running right now.

## Files

- `spawn.sh` -- starts all 4 processes with `nohup ... & disown` so they
  survive you logging out. Run it once per session (`bash spawn.sh`).
- `vitals-logger.sh` -- a needed background job. Appends a heartbeat
  line to `/tmp/vitals.log` every 5 seconds. Low CPU.
- `labsync.sh` -- a needed background job. Appends a line to
  `/tmp/labsync.log` every 30 seconds. Low CPU, mostly asleep.
- `stuck-job.sh` -- **not needed.** A runaway process stuck in a tight
  loop with no sleep at all. Pins a full CPU core.
- `backup-nightly.sh` -- **not needed right now.** Meant to run only
  overnight; if it's running during the day, that's the second thing
  to catch. Moderate, bursty CPU.

Nothing here writes outside `/tmp`. Safe to `kill` any of the 4 once
you've decided it shouldn't be running.

## Get it on the medical-unit server

```
git clone https://github.com/SE4CPS/2026-COMP-175
cd 2026-COMP-175/modules/module-5/practicelab3
bash spawn.sh
```
