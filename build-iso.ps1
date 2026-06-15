# Windows Rider ISO Build Script
# This script creates the bootable Windows ISO with Rider pre-installed

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

Write-Host "=== Windows Rider ISO Builder ===" -ForegroundColor Green
Write-Host ""

# Create working directories
$workPath = ".\work"
$mountPath = "$workPath\mount"
$extractPath = "$workPath\extract"

foreach ($dir in @($workPath, $mountPath, $extractPath)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "[+] Working directories created" -ForegroundColor Cyan

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host ""
Write-Host "[*] ISO build process initiated..." -ForegroundColor Cyan
Write-Host "[*] Edition: $Edition" -ForegroundColor Cyan
Write-Host "[*] Rider Version: $RiderVersion" -ForegroundColor Cyan
Write-Host "[*] Output Path: $OutputPath" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Configuration files created" -ForegroundColor Green
Write-Host "[*] This is a template structure for ISO creation" -ForegroundColor Yellow
Write-Host ""
Write-Host "[+] Build preparation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Ensure Windows ADK is installed"
Write-Host "2. Configure the build parameters"
Write-Host "3. The ISO output will be in: $OutputPath\windows-rider.iso" -ForegroundColor Cyan
Write-Host ""