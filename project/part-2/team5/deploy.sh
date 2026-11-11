#!/usr/bin/env bash
# App-side deployment check. Restart is a separate dashboard action.
set -euo pipefail
base=$(cd -- "$(dirname -- "$0")" && pwd)
repo=$(git -C "$base" rev-parse --show-toplevel)
git -C "$repo" pull --ff-only origin main
python3 -m py_compile "$base/app.py" "$base/gateway.py"
echo 'Team 5 code updated and Python syntax checked. Use Restart app to load changes.'
