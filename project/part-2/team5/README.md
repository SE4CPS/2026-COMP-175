# Team 5 — Clinical Web Interface

Members: Gionni, Hernan, Gabriel, Elvin.

This Kali-hosted Flask dashboard serves four synthetic hospital personas and one Team 5 operator. Five buttons run real subprocess commands and display their actual output or error. Record reads cross SSH to Ubuntu. Each SSH key is restricted by `authorized_keys` to a root-owned, read-only gateway that runs as that persona. Linux permissions on `/srv/clinical-data` decide whether listing or reading succeeds. The application has no record-write operation. Personas can only use the three read-only buttons; only the operator can deploy or restart this app on Kali.

## Component setup

1. On **Ubuntu**, run `project/part-2/Hospital-VM/setup.sh` from the course repository. Confirm `SETUP OK`. This is a deliberately permissive starting point; Team 4's RBAC changes should be applied before the final access-control demo.
2. On **Kali**, in this directory, create a virtual environment and install Flask:

   ```sh
   python3 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   .venv/bin/python configure.py
   mkdir -p keys
   chmod 700 keys
   for p in guest1 nurse1 physician1 patient1; do ssh-keygen -q -t ed25519 -N '' -f "keys/${p}_ed25519"; done
   ssh-keyscan -H UBUNTU_IP > known_hosts
   ```

   `configure.py` saves five generated web-login passwords to `demo-passwords-private.txt` with mode 0600. Keep that file private. `persona-hashes.json`, `session-secret.txt`, `keys/`, and `known_hosts` are local and excluded from Git. Confirm the scanned SSH host fingerprint through a trusted channel before use.
3. Copy only the four `.pub` files and `gateway.py` and `install-gateway.sh` to **your own Ubuntu** VM for component testing. Run `bash install-gateway.sh /path/to/public-keys-directory` there. Team 4 must approve and perform the corresponding install on their Ubuntu VM for cross-team integration. Do not change Team 4's records or groups from Team 5.
4. On Kali, set the environment and run the app:

   ```sh
   export TEAM5_SESSION_SECRET="$(cat session-secret.txt)"
   export TEAM5_PASSWORD_HASHES="$PWD/persona-hashes.json"
   export TEAM5_UBUNTU_HOST=UBUNTU_IP
   export TEAM5_KEY_DIR="$PWD/keys"
   export TEAM5_KNOWN_HOSTS="$PWD/known_hosts"
   export TEAM5_BIND=0.0.0.0
   .venv/bin/python app.py
   ```

   Open `http://KALI_IP:5000/` from the isolated lab network. On our current component VM, this is `http://192.168.56.11:5000/`. Bookmark the home address. Opening a saved `/action` result URL returns to the dashboard; only authenticated POST button clicks can execute commands. Use a persona or the operator with its generated web password. Keep this demonstration network isolated because it uses HTTP with synthetic, temporary demo credentials. The app's own login passwords are separate from Ubuntu account passwords.

## Five buttons

| Button | Real command | Expected evidence |
|---|---|---|
| Verify identity | `ssh persona@Ubuntu identity` | Ubuntu UID/account or real SSH error |
| List records | `ssh persona@Ubuntu list` | Ubuntu list or `PermissionError` |
| Read record | `ssh persona@Ubuntu 'read patients.csv'` | Real file content or denied read |
| Deploy app (operator only) | `git pull --ff-only` then Python syntax check | Git output or real error; restart separately |
| Restart app (operator only) | `systemd-run --user --on-active=3s` schedules `systemctl --user restart team5-web.service` | Real systemd scheduling result or real error |

The deploy and restart buttons are intended for the optional user systemd service. Copy `team5-web.service` to `~/.config/systemd/user/`, make a private `~/.config/team5-web.env` with the five `TEAM5_*` settings above, then run `systemctl --user daemon-reload` and `systemctl --user enable --now team5-web.service`. Adjust the service paths if the repository has a different location. A failed service action is shown as a failure in the interface.

## Verification and coordination

Run `.venv/bin/python -m unittest discover -s tests -v` on Kali. Capture a permitted persona read and a denied persona read **after Team 4 applies RBAC**. Capture one real command failure, such as a temporarily unreachable Ubuntu VM, and confirm that the page shows the failure. For the weekly update, report which of those checks passed and what remains blocked by Team 4 or the shared network.

Team 1 supplies the shared IP scheme and reachability check. Team 4 owns Ubuntu's RBAC and must agree on the gateway installation. Team 5 owns this app, its dashboard buttons, screenshots, write-up, slides, and poster section. Do not push private keys, passwords, or real data. AI assistance: Codex helped draft and test this code; document any additional AI use in the final submission.
