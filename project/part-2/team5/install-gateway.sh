#!/usr/bin/env bash
# Run on your own Ubuntu VM or, with Team 4, on their clinical-data VM.
set -euo pipefail
if [[ $# -ne 1 ]]; then echo 'Usage: ./install-gateway.sh /path/to/four-public-keys-directory' >&2; exit 2; fi
base=$(cd -- "$(dirname -- "$0")" && pwd)
sudo install -o root -g root -m 0755 "$base/gateway.py" /usr/local/bin/team5-gateway
for persona in guest1 nurse1 physician1 patient1; do
  pubkey=$(cat -- "$1/${persona}_ed25519.pub")
  case "$pubkey" in ssh-ed25519\ *) ;; *) echo "Expected an ed25519 public key for $persona" >&2; exit 2;; esac
  getent passwd "$persona" >/dev/null
  homedir=$(getent passwd "$persona" | cut -d: -f6)
  sudo install -d -o "$persona" -g "$persona" -m 0700 "$homedir/.ssh"
  line="restrict,command=\"/usr/local/bin/team5-gateway\" $pubkey"
  if ! sudo test -e "$homedir/.ssh/authorized_keys" || ! sudo grep -Fqx -- "$line" "$homedir/.ssh/authorized_keys"; then
    printf '%s\n' "$line" | sudo tee -a "$homedir/.ssh/authorized_keys" >/dev/null
  fi
  sudo chown "$persona:$persona" "$homedir/.ssh/authorized_keys"
  sudo chmod 0600 "$homedir/.ssh/authorized_keys"
done
echo 'Gateway installed for four personas. Test from Kali before using the app.'
