# Module 7: Mirrored Networking Lab

Scenario: by default, each Windows host's WSL2 instance sits behind its
own private, host-local NAT -- two students' WSL instances on two
different laptops can't reach each other. This lab turns on WSL2's
"mirrored" networking mode, which makes WSL share the host's own real
network identity, then proves it works by connecting two laptops
directly with an Ethernet cable and pinging from one partner's WSL
instance to the other's.

## Files

- `enable-mirrored.ps1` -- edits (or creates) `%USERPROFILE%\.wslconfig`
  to set `networkingMode=mirrored` under `[wsl2]`, then runs
  `wsl --shutdown` to apply it. Safe to re-run; it updates the existing
  setting in place rather than duplicating it. Run from a normal
  PowerShell window -- Administrator rights are not required.
- `set-static-ip.ps1` -- assigns a static IPv4 address to one network
  adapter (the one plugged into the direct Ethernet cable). Takes the
  adapter name/alias and the IP as parameters, e.g.:
  ```
  .\set-static-ip.ps1 -Adapter "Ethernet" -IP "192.168.77.1" -Prefix 24
  ```
  Run `Get-NetAdapter` first (the script also prints this list) to find
  the real adapter name on your machine -- "Ethernet" is only a
  placeholder.

Both scripts run entirely on the Windows host, in PowerShell, not
inside WSL.

## Get it on your laptop

```
git clone https://github.com/SE4CPS/2026-COMP-175
cd 2026-COMP-175\modules\module-7\mirrored-networking
.\enable-mirrored.ps1
```

`git` must be installed on Windows for the clone step (not just inside
WSL) -- install it from [git-scm.com](https://git-scm.com/) first if
`git` isn't recognized as a command.
