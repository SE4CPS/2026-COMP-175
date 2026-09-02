# Scripts

Ready-to-run scripts so students configure their environment by running a
script instead of hand-editing config files in an editor.

| Script | What it does |
|--------|---------------|
| `set-wsl-hostname.sh` | Sets this WSL distro's own hostname via `/etc/wsl.conf`, so it stops reporting the Windows PC's shared hostname. See Module 2's "Give a Distro Its Own Name". |

## Running a script

```
cd ~/2026-COMP-175
git pull
sudo bash scripts/set-wsl-hostname.sh your-distro-name
```
