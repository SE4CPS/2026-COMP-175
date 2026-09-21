# Lab 3: Registrar Server

Ten practical tasks across Modules 3, 4 and 5. Each one ends with a screenshot as evidence.
You work on two VirtualBox VMs: **Ubuntu** is the registrar server, **Kali** is your admin workstation.

The questions and what each screenshot must show are in the course slides (Assignment, Lab 3).
This folder only builds the scenario so every student starts from the same server.

## Set up (Ubuntu VM, once)

```bash
git clone https://github.com/SE4CPS/2026-COMP-175.git ~/2026-COMP-175   # or: git -C ~/2026-COMP-175 pull
sudo bash ~/2026-COMP-175/modules/module-5/lab3/setup.sh
```

The script asks for one lab password (8+ characters) that it gives to the three accounts.
It prints `SETUP OK` and the server's IP address when it is done. You need that IP from Kali.

Re-running `setup.sh` resets the lab files. `sudo bash cleanup.sh` removes everything (accounts, folders,
scripts, the sudoers file and SSH drop-in you create in Q6 and Q9) so you can start over.

## What setup creates

| Item | Detail |
|---|---|
| Accounts | `mreyes` and `jokafor` (group `registrars`), `tnguyen` (group `auditors`) |
| `/srv/registrar/grades.csv` | owner `jokafor`, group `registrars`, mode 640 |
| `/srv/registrar/archive/` | six files, three of them older than 180 days (one in `2024/`) |
| `/srv/registrar/reports/` | `mreyes`'s folder, with `summary.txt` |
| `/srv/registrar/shared/`, `dropbox/` | plain modes on purpose; Q4 hardens them |
| `/srv/registrar/public/index.html` | the page you reach through a tunnel in Q10 |
| `/usr/local/bin/backup-grades.sh` | needs root; Q6 lets one group run it with sudo |
| `/opt/registrar/report-job.sh` | burns one CPU core for at most 10 minutes; Q8 |
| Packages | `acl`, `inotify-tools`, `openssh-server` |

## Notes

- The three accounts are lab-only. Run this on the VM, never on a machine you care about.
- Kali needs nothing installed: `ssh`, `ssh-keygen` and `curl` are already there.
- If you turned on `ufw` in Module 2, port 22 must be allowed (`sudo ufw allow 22/tcp`) or Kali cannot connect.
