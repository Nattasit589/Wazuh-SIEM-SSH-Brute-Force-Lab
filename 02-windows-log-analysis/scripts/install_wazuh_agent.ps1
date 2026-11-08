# =====================================================================
# Script: install_wazuh_agent.ps1
# Description: Installs and registers Wazuh Agent on Windows
# Note: Run this script with Administrator privileges in PowerShell
# =====================================================================

param (
    [string]$WazuhManager = "192.168.117.132",
    [string]$AgentName = "windows_endpoint_agt",
    [string]$WazuhVersion = "4.14.0-1"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Wazuh Agent Installation for Windows" -ForegroundColor Cyan
Write-Host " Manager: $WazuhManager | Agent Name: $AgentName" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Check Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as Administrator."
}

$MsiFileName = "wazuh-agent-$WazuhVersion.msi"
$DownloadUrl = "https://packages.wazuh.com/4.x/windows/$MsiFileName"
$TempPath = [System.IO.Path]::Combine($env:TEMP, $MsiFileName)

Write-Host "[+] Downloading Wazuh Agent installer..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempPath

Write-Host "[+] Installing and enrolling agent with Manager: $WazuhManager..." -ForegroundColor Yellow
$InstallArgs = "/i `"$TempPath`" /q WAZUH_MANAGER=`"$WazuhManager`" WAZUH_AGENT_NAME=`"$AgentName`""
$Process = Start-Process -FilePath "msiexec.exe" -ArgumentList $InstallArgs -Wait -PassThru

if ($Process.ExitCode -ne 0) {
    Write-Error "Installation failed with exit code: $($Process.ExitCode)"
}

Write-Host "[+] Starting Wazuh Service (WazuhSvc)..." -ForegroundColor Yellow
Start-Service -Name "WazuhSvc" -ErrorAction SilentlyContinue
Get-Service -Name "WazuhSvc"

Write-Host "[✓] Wazuh Agent successfully installed and service started!" -ForegroundColor Green
Write-Host "Verify agent status on the Wazuh Dashboard." -ForegroundColor Green

