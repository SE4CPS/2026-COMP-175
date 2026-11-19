# Team 4 -- Clinical Data & Access Control

**Members:** Toan, Kaung, Shomario

## What's Here (`project/part-2/team4/`)

- `app.py` -- Live 5-button Python Flask web dashboard hosted on Kali (`http://0.0.0.0:5000`). Uses `subprocess.run()` over SSH to execute real administration and verification commands on the Ubuntu `Hospital-VM` (`10.0.0.40` / `clindata-ubuntu`).
- `enforce-rbac.sh` -- Configures real per-persona Linux RBAC (`groups`, `chmod`, `chgrp`, `setgid`, and `setfacl` default/access ACLs) on top of the shared `Hospital-VM/setup.sh` baseline (`/srv/clinical-data`) and scrubs planted legacy credentials.
- `check-rbac.sh` -- Audits directory permissions, POSIX ACLs (`getfacl`), and runs live `sudo -u` read/write verification tests across all 4 personas (`physician1`, `nurse1`, `patient1`, `guest1`).
- `rbac-progress/` -- Dated evidence trail and screenshots (`progress-log.md`) of initial RBAC prototyping and UFW/ACL tests.

## Per-Persona RBAC Design (`/srv/clinical-data`)

| Persona | Group | Master `patients.csv` | Individual `patient1-chart.csv` | `README.md` | Hidden `.patients.csv.bak` |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **`physician1`** | `physicians` | `ALLOW (rw-)` | `ALLOW (rw-)` | `ALLOW (r--)` | `DENY (root 600)` |
| **`nurse1`** | `nurses` | `ALLOW (r--)` | `ALLOW (r--)` | `ALLOW (r--)` | `DENY (root 600)` |
| **`patient1`** | `patients` | `DENY (---)` | `ALLOW (r--)` | `ALLOW (r--)` | `DENY (root 600)` |
| **`guest1`** | `guests` | `DENY (---)` | `DENY (---)` | `DENY (---)` | `DENY (root 600)` |

## Short Write-Up

### 1. What Our Role Did
As **Team 4 (Clinical Data & Access Control)**, we hardened `/srv/clinical-data` on the Ubuntu `Hospital-VM` (`10.0.0.40`) on top of the shared `Hospital-VM/setup.sh` baseline and built a 5-button Python Flask dashboard on Kali (`10.0.0.41`, `app.py`) that executes real Linux commands over SSH via `subprocess.run()`. We created a `clinical` group, set `/srv/clinical-data` to `chmod 2750` (`root:clinical`) to block `guest1` at the directory gate, and used POSIX ACLs (`setfacl`) so `physician1` has read/write (`rw-`), `nurse1` has read-only (`r--`), and `patient1` is blocked from the master `patients.csv` (`---`) while having read-only access to their own `patient1-chart.csv`. We also locked down two planted vulnerabilities from `setup.sh`: `.patients.csv.bak` (`600 root:root`) and the hardcoded password in `/opt/hospital-vm/legacy-notify.sh` (`700 root:root`).

### 2. One Real Problem We Hit & How We Fixed It
- **Problem:** Whenever `simulate.sh` ran `sudo sed -i` to update vitals in `/srv/clinical-data/patients.csv`, `sed -i` created a temporary file (`sedXXXXXX`) as `root:root` and renamed it over `patients.csv`, wiping out our custom file permissions and ACLs.
- **How We Fixed It:** We applied `setgid` (`chmod 2750`) and **Default POSIX ACLs** (`setfacl -d -m u::rw,g::---,g:physicians:rw,g:nurses:r,g:patients:---,g:guests:---,o::--- /srv/clinical-data`) on the parent directory so any new file created inside `/srv/clinical-data` automatically inherits our per-persona ACL rules.

### 3. AI Usage Statement
We used AI assistance to help design the Flask HTML/CSS template and structure the `setfacl` default ACL syntax for `sed -i` persistence. All VM setup, SSH key configuration, script execution, permission verification, and live testing across Ubuntu and Kali were performed and verified manually on our VMs.

## Running the Kali Dashboard

```bash
sudo apt-get install -y python3-flask
HOSPITAL_HOST=$(hostname -I | awk '{print $1}') python3 app.py
# Open http://localhost:5000 (or http://10.0.0.41:5000 on the shared switch)
