# Windows Rider IDE Installation ISO

An automated solution to create a bootable Windows ISO with JetBrains Rider IDE pre-installed.

## Overview

This project provides scripts and configuration files to build a custom Windows installation ISO that includes JetBrains Rider IDE, eliminating the need for manual installation.

## Features

- Automated ISO creation
- Unattended Windows installation
- Pre-configured Rider IDE installation
- Support for both Professional and Community editions
- Customizable installation options

## Prerequisites

- Windows 10/11 with administrator privileges
- Windows Assessment and Deployment Kit (ADK)
- PowerShell 5.0 or higher
- At least 20GB free disk space
- Internet connection for downloading components

## Quick Start

1. Clone this repository
2. Run the setup script: `./setup.ps1`
3. Follow the on-screen prompts
4. The ISO will be created in the `output/` directory

## File Structure

```
windows-rider-iso/
├── README.md
├── setup.ps1
├── build-iso.ps1
├── autounattend.xml
├── rider-install.ps1
├── config/
│   ├── rider-config.json
│   └── windows-settings.json
└── output/
    └── (ISO files will be generated here)
```

## Configuration

Edit `config/rider-config.json` to customize:
- Rider version (default: latest)
- Edition (Professional or Community)
- Plugins to install
- IDE settings

## Building the ISO

### Method 1: Automated (Recommended)

```powershell
./setup.ps1
```

### Method 2: Manual

```powershell
# Download Windows PE/ADK
# Configure unattended setup
./build-iso.ps1 -Edition Community -RiderVersion latest
```

## Troubleshooting

- **ADK not found**: Download from [Microsoft ADK](https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install)
- **Insufficient disk space**: Free up at least 20GB
- **Permission denied**: Run PowerShell as Administrator

## Support

For issues or questions, open an issue on GitHub.

## License

MIT License - See LICENSE file for details