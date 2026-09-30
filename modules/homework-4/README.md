# Homework 4 -- Sample Scripts (Modules 5 & 6, Automotive Domain)

Synthetic automotive shop scripts and sample telemetry data for
Homework 4's practical questions (Module 5: Process Mgmt & Remote
Access, Module 6: Service Management). No real vehicle or shop data --
all numbers are randomly generated or hand-written samples.

- `engine-scan.sh` -- a short, one-shot sensor scan (foreground/kill practice)
- `telemetry-logger.sh` -- a long-running background logger (jobs/nice practice)
- `dyno-test.sh` -- a long `sleep`-based job to practice `kill`
- `dyno-monitor.sh` -- an always-on watcher, meant to run as a systemd service
- `oil-check.sh` -- a quick check meant to run from cron
- `engine-samples.csv` -- a handful of sample telemetry rows

## Pulling it onto your VM

```
git clone https://github.com/SE4CPS/2026-COMP-175
cd 2026-COMP-175/modules/homework-4
chmod +x *.sh
```
