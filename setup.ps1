# Windows Rider ISO Setup Script
# This script sets up the environment for creating a Windows Rider ISO

param(
    [string]$Edition = "Community",
    [string]$RiderVersion = "latest",
    [string]$OutputPath = ".\output"
)

# Requires admin privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

Write-Host "=== Windows Rider ISO Builder Setup ===" -ForegroundColor Green
Write-Host ""

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
    Write-Host "[+] Created output directory: $OutputPath" -ForegroundColor Green
}

# Check for required tools
Write-Host "[*] Checking for required tools..." -ForegroundColor Yellow

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion.Major
if ($psVersion -lt 5) {
    Write-Host "[-] PowerShell 5.0 or higher required (current: $psVersion)" -ForegroundColor Red
    exit 1
}
Write-Host "[+] PowerShell version: $psVersion" -ForegroundColor Green

# Check for Windows ADK
$adkPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit"
if (-not (Test-Path $adkPath)) {
    Write-Host "[-] Windows ADK not found at $adkPath" -ForegroundColor Red
    Write-Host "    Please install Windows ADK from: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install" -ForegroundColor Yellow
} else {
    Write-Host "[+] Windows ADK found" -ForegroundColor Green
}

# Check disk space
$drive = Get-PSDrive C
$freeSpace = $drive.Free / 1GB
if ($freeSpace -lt 20) {
    Write-Host "[-] Insufficient disk space: ${freeSpace}GB free (need 20GB)" -ForegroundColor Red
    exit 1
}
Write-Host "[+] Disk space available: ${freeSpace}GB" -ForegroundColor Green

# Create configuration files
Write-Host ""
Write-Host "[*] Creating configuration files..." -ForegroundColor Yellow

# Create config directory
if (-not (Test-Path ".\config")) {
    New-Item -ItemType Directory -Path ".\config" | Out-Null
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review configuration in ./config/"
Write-Host "2. Run: .\build-iso.ps1"
Write-Host ""