# =====================================================================
# Script: attack_simulation.ps1
# Description: Simulates failed logon attempts to generate Windows Event ID 4625
# =====================================================================

param (
    [string]$TargetIP = "127.0.0.1",
    [string]$Username = "Administrator",
    [int]$DelayMs = 500
)

$Wordlist = @(
    "123456",
    "password",
    "12345678",
    "qwerty",
    "123456789",
    "12345",
    "Admin2024!",
    "WrongPassword123",
    "TestPassword!",
    "Summer2024!"
)

Write-Host "==========================================================" -ForegroundColor Red
Write-Host " Windows Logon Failure Simulation" -ForegroundColor Red
Write-Host " Target: $TargetIP | Account: $Username" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Red

$Counter = 1
foreach ($Password in $Wordlist) {
    Write-Host "[$Counter/$($Wordlist.Count)] Attempting authentication with candidate: '$Password'..." -NoNewline
    
    # Trigger authentication failure using net use over SMB (triggers Event ID 4625)
    $null = net use "\\$TargetIP\IPC$" /user:$Username "$Password" 2>&1
    
    Write-Host " [FAILED as expected]" -ForegroundColor Yellow
    $Counter++
    Start-Sleep -Milliseconds $DelayMs
}

Write-Host ""
Write-Host "[✓] Simulation completed." -ForegroundColor Green
Write-Host "[*] Check Event Viewer -> Windows Logs -> Security for Event ID 4625." -ForegroundColor Cyan
Write-Host "[*] Check Wazuh Dashboard for Rules 60122 (Level 5) and 60115 (Level 10)." -ForegroundColor Cyan

