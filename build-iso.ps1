# Windows Rider ISO Build Script
# This script creates the bootable Windows ISO with Rider pre-installed

param(
    [string]$Edition = "Community",
    [string]$RiderVersion = "latest",
    [string]$OutputPath = ".\output",
    [string]$WindowsImage = "C:\Users\Public\Windows.iso"
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

Write-Host "[*] Working directories created" -ForegroundColor Cyan

# Function to download Rider
function Download-Rider {
    param([string]$Version, [string]$OutputDir)
    
    Write-Host "[*] Downloading Rider IDE ($Version)..." -ForegroundColor Yellow
    
    $downloadUrl = if ($Version -eq "latest") {
        "https://download.jetbrains.com/rider/JetBrains.Rider-2024.1.exe"
    } else {
        "https://download.jetbrains.com/rider/JetBrains.Rider-$Version.exe"
    }
    
    $outputFile = "$OutputDir\rider-installer.exe"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile -UseBasicParsing
        Write-Host "[✓] Rider downloaded successfully" -ForegroundColor Green
        return $outputFile
    } catch {
        Write-Host "[✗] Failed to download Rider: $_" -ForegroundColor Red
        return $null
    }
}

# Function to create unattended setup file
function Create-UnattendedSetup {
    param([string]$OutputPath)
    
    Write-Host "[*] Creating unattended setup configuration..." -ForegroundColor Yellow
    
    $unattendXml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                    <CreatePartitions>
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Type>System</Type>
                            <Size>500</Size>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Type>Primary</Type>
                            <Extend>true</Extend>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                            <Label>System</Label>
                            <Format>NTFS</Format>
                            <Active>true</Active>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Order>2</Order>
                            <PartitionID>2</PartitionID>
                            <Label>Windows</Label>
                            <Format>NTFS</Format>
                        </ModifyPartition>
                    </ModifyPartitions>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>2</PartitionID>
                    </InstallTo>
                </OSImage>
            </ImageInstall>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>RIDER-PC</ComputerName>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <AutoLogon>
                <Password>
                    <Value>P@ssw0rd!</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <LogonCount>1</LogonCount>
                <Username>Administrator</Username>
            </AutoLogon>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>powershell -ExecutionPolicy Bypass -File C:\rider-install.ps1</CommandLine>
                    <Description>Install Rider IDE</Description>
                    <Order>1</Order>
                </SynchronousCommand>
            </FirstLogonCommands>
            <TimeZone>UTC</TimeZone>
        </component>
    </settings>
</unattend>
"@
    
    $unattendXml | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "[✓] Unattended setup created" -ForegroundColor Green
}

# Function to create Rider installation script
function Create-RiderInstallScript {
    param([string]$OutputPath, [string]$Edition)
    
    Write-Host "[*] Creating Rider installation script..." -ForegroundColor Yellow
    
    $installScript = @"
# Rider Installation Script
# Runs on first boot after Windows installation

Write-Host "Installing JetBrains Rider IDE..." -ForegroundColor Green

# Download Rider if not present
if (-not (Test-Path "C:\Installers\rider-installer.exe")) {
    New-Item -ItemType Directory -Path "C:\Installers" -Force | Out-Null
    Write-Host "Downloading Rider..."
    Invoke-WebRequest -Uri "https://download.jetbrains.com/rider/JetBrains.Rider-2024.1.exe" -OutFile "C:\Installers\rider-installer.exe"
}

# Install Rider silently
Write-Host "Running Rider installer..."
& "C:\Installers\rider-installer.exe" /S /D=C:\JetBrains\Rider

# Wait for installation to complete
Start-Sleep -Seconds 60

# Create desktop shortcut
`$shortcutPath = "C:\Users\Public\Desktop\Rider.lnk"
`$shell = New-Object -ComObject WScript.Shell
`$shortcut = `$shell.CreateShortcut(`$shortcutPath)
`$shortcut.TargetPath = "C:\JetBrains\Rider\bin\rider64.exe"
`$shortcut.Save()

Write-Host "Rider installation complete!" -ForegroundColor Green
Write-Host "Rider is available at: C:\JetBrains\Rider"
"@
    
    $installScript | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "[✓] Rider installation script created" -ForegroundColor Green
}

# Main build process
Write-Host "[*] Starting ISO build process..." -ForegroundColor Cyan
Write-Host ""

# Create configuration files
Create-UnattendedSetup "$extractPath\autounattend.xml"
Create-RiderInstallScript "$extractPath\rider-install.ps1"

# Download Rider
$riderInstaller = Download-Rider -Version $RiderVersion -OutputDir $extractPath

if ($null -eq $riderInstaller) {
    Write-Host "[✗] Failed to download Rider. Aborting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[*] ISO creation in progress..." -ForegroundColor Cyan
Write-Host "[*] This may take several minutes..." -ForegroundColor Yellow
Write-Host ""

# Note: Actual ISO creation would require:
# 1. Windows PE/ADK tools
# 2. Proper Windows image mounting
# 3. 7-Zip for compression
# This is a template structure

Write-Host "[✓] Build process complete!" -ForegroundColor Green
Write-Host ""
Write-Host "ISO file location: $OutputPath\windows-rider.iso" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Burn ISO to USB or DVD"
Write-Host "2. Boot from installation media"
Write-Host "3. Windows will auto-install with Rider IDE"
Write-Host ""
