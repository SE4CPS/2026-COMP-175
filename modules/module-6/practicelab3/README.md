# Module 6, Practice Lab 3: Scheduling with cron

Scenario: your Ubuntu VM plays the role of a medical unit's scheduling
server. Four routine jobs need to run on a schedule -- reminders, an
equipment check, a shift handoff report, and a nightly backup -- using
`crontab -e` from this module's own lesson, not systemd timers.

## Files

- `appointment-reminders.sh` -- logs that reminders were sent. No real
  patient names or appointment details, just a placeholder line.
- `equipment-check.sh` -- logs a routine equipment status check
  (imaging machines, monitors, etc.), weekdays only.
- `shift-handoff-report.sh` -- logs an end-of-shift summary for the
  outgoing team.
- `nightly-backup.sh` -- backs up `/tmp/records` to
  `/tmp/records-backup` (both placeholder folders under /tmp, never
  real patient records).
- `crontab.sample` -- the four crontab lines, using a `SCRIPTDIR` token
  in place of the real path. cron needs an absolute path (see this
  module's own "Cron runs with a tiny PATH" warning), so this is
  substituted with the folder's real location at install time, not
  left as a relative path that would only work from one directory.

Nothing here writes outside `/tmp`. Safe to install and remove.

## Get it on the medical-unit server

```
git clone https://github.com/SE4CPS/2026-COMP-175
cd 2026-COMP-175/modules/module-6/practicelab3
chmod +x *.sh
(crontab -l 2>/dev/null; sed "s|SCRIPTDIR|$(pwd)|" crontab.sample) | crontab -
crontab -l
```

## Verify

```
crontab -l
```

should show all four jobs with a real absolute path (no `SCRIPTDIR`
left in). To see a job run without waiting for its real time, run any
script directly, e.g. `bash appointment-reminders.sh`, then check its
log under `/tmp`.

## Remove

```
crontab -l | grep -v practicelab3 | crontab -
```
