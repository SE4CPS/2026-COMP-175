# set-static-ip.ps1
# Sets a static IPv4 address on one network adapter -- used for the direct
# Ethernet link between two lab partners' laptops.
# Usage: .\set-static-ip.ps1 -Adapter "Ethernet" -IP "192.168.77.1" -Prefix 24

param(
    [Parameter(Mandatory=$true)][string]$Adapter,
    [Parameter(Mandatory=$true)][string]$IP,
    [int]$Prefix = 24
)

Write-Host "Available adapters:"
Get-NetAdapter | Select-Object Name, Status

$existing = Get-NetIPAddress -InterfaceAlias $Adapter -AddressFamily IPv4 -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Remove-NetIPAddress -Confirm:$false
}

New-NetIPAddress -InterfaceAlias $Adapter -IPAddress $IP -PrefixLength $Prefix -ErrorAction Stop
Write-Host "Set $Adapter to $IP/$Prefix"
Get-NetIPAddress -InterfaceAlias $Adapter -AddressFamily IPv4
