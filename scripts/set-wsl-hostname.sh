#!/bin/bash
# set-wsl-hostname.sh -- give this WSL distro its own hostname.
#
# By default every WSL distro on the same Windows machine reports the
# Windows PC's own computer name (they also share one IP -- see Module 2's
# "Why They Share the Same IP"). This script sets a distro-specific
# hostname via /etc/wsl.conf, so `hostname` distinguishes it from any
# other distro running on the same machine.
#
# Usage:
#   sudo ./set-wsl-hostname.sh my-distro-name
#
# Run this INSIDE the distro you want to rename (not on the Windows side).
# The change takes effect after this distro is restarted:
#   (from PowerShell) wsl --terminate <distro-name-in-wsl--list>

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Run this with sudo: sudo $0 <hostname>" >&2
  exit 1
fi

if [ $# -ne 1 ] || [ -z "$1" ]; then
  echo "Usage: sudo $0 <hostname>" >&2
  echo "Example: sudo $0 kali-attack" >&2
  exit 1
fi

new_hostname="$1"
conf_file="/etc/wsl.conf"

if [ -f "$conf_file" ] && grep -q '^\[network\]' "$conf_file"; then
  # [network] section already exists -- update hostname in place, add it
  # if the section exists but has no hostname line yet.
  if grep -q '^\s*hostname\s*=' "$conf_file"; then
    sed -i "s/^\s*hostname\s*=.*/hostname = ${new_hostname}/" "$conf_file"
  else
    sed -i "/^\[network\]/a hostname = ${new_hostname}" "$conf_file"
  fi
else
  {
    echo ""
    echo "[network]"
    echo "hostname = ${new_hostname}"
    echo "generateHosts = false"
  } >> "$conf_file"
fi

echo "Set hostname = ${new_hostname} in ${conf_file}."
echo ""
echo "This distro's hostname stays the old one until it restarts. From"
echo "PowerShell on the Windows side, run:"
echo "  wsl --terminate <this-distro-name>"
echo "Then reopen it and check with: hostname"
