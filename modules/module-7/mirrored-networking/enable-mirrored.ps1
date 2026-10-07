# enable-mirrored.ps1
# Turns on WSL2 mirrored networking mode so WSL shares the Windows host's
# real network identity (needed for cross-host VM-to-VM reachability).
# Run this from a normal PowerShell window (Administrator not required).

$wslConfigPath = "$env:USERPROFILE\.wslconfig"

if (Test-Path $wslConfigPath) {
    $content = Get-Content $wslConfigPath -Raw
} else {
    $content = ""
}

if ($content -match "(?ms)^\[wsl2\]") {
    if ($content -match "(?m)^\s*networkingMode\s*=") {
        $content = $content -replace "(?m)^\s*networkingMode\s*=.*", "networkingMode=mirrored"
    } else {
        $content = $content -replace "(?ms)^\[wsl2\]", "[wsl2]`nnetworkingMode=mirrored"
    }
} else {
    if ($content.Trim().Length -gt 0) { $content += "`n`n" }
    $content += "[wsl2]`nnetworkingMode=mirrored`n"
}

Set-Content -Path $wslConfigPath -Value $content -Encoding ascii -NoNewline
Write-Host "Updated $wslConfigPath :"
Get-Content $wslConfigPath
Write-Host ""
Write-Host "Restarting WSL now (wsl --shutdown). Reopen your Kali/Ubuntu terminal after this finishes."
wsl --shutdown
