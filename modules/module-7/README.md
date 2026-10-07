# Module 7: Network Configuration

Covers Linux network configuration and diagnosis (`ip`, `netplan`,
`resolvectl`, `ss`, `traceroute`, ...) plus WSL2 networking specifics.

## mirrored-networking/

Scripts for the "Lab: Mirrored Network" practice lab: switching WSL2
from its default per-host NAT networking into mirrored mode, so two
students' WSL instances on two different laptops can reach each other
over a direct Ethernet link. See
[`mirrored-networking/README.md`](mirrored-networking/README.md).
