# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a modular PowerShell configuration system with the following structure:

- **Microsoft.PowerShell_profile.ps1**: Main profile that orchestrates module loading with Japanese comments
- **functions/**: Modular PowerShell scripts organized by functionality
- **Modules/**: Third-party PowerShell modules (posh-git, PSFzf, PSEverything, ZLocation)
- **packages.json**: WinGet package manifest for development environment setup
- **powershell.config.json**: PowerShell execution policy configuration

### Core Modules

The profile loads modules in this order:
1. **Logging.ps1**: Logging infrastructure with `Write-ProfileLog` function
2. **Utility.ps1**: General utilities (Unity helpers, file operations, touch command)
3. **PackageManagement.ps1**: WinGet and PowerShell module installation automation
4. **Helper.ps1**: Additional helper functions
5. **ArgumentCompleters.ps1**: Tab completion enhancements
6. **Environment.ps1**: Environment variables and execution policy setup
7. **OhMyPosh.ps1**: Oh My Posh shell prompt configuration with performance optimization
8. **PSReadLine.ps1**: Enhanced command line editing
9. **Aliases.ps1**: Command aliases and shortcuts

### Key Features

- **Performance-optimized**: Uses flag files to skip package checks after initial setup
- **Comprehensive logging**: All operations logged to `~/.pwsh-profile.log`
- **Debug mode**: Enable with `$env:PWSH_DEBUG = "true"`
- **Auto-dependency management**: Automatically installs missing packages and modules

## Common Commands

### Profile Management
```powershell
# View profile logs
Show-ProfileLog          # Last 50 lines
Show-ProfileLog -All     # All logs
Show-ProfileLog -Last 100  # Last 100 lines

# Clear profile logs
Clear-ProfileLog

# Force dependency update
Update-OhMyPoshDependencies
```

### Development Environment
```powershell
# Package management (uses WinGet)
Install-PackageIfMissing "PackageName"

# Module management
Install-ModuleIfMissing "ModuleName"

# Unity development
unity-version           # Get Unity version from ProjectSettings
uadb                   # Unity Android Debug Bridge shortcut
```

### Aliases and Shortcuts
```powershell
v         # nvim
open      # explorer
ll        # CustomListChildItems (enhanced ls with timestamps)
cd        # pushd (maintains directory stack)
search    # Search-Everything
sudo      # CustomSudo
p         # GetCurrentPath
```

### File Operations
```powershell
touch filename         # Create empty file (Linux-style)
ls-empty-dirs         # Find empty directories
```

## Debug Mode

Enable detailed logging and console output:
```powershell
$env:PWSH_DEBUG = "true"
```

In debug mode, the profile will show:
- Module loading progress
- Package installation status
- Performance timing information
- Available commands on startup

## Dependencies

Required packages (auto-installed via WinGet):
- JanDeDobbeleer.OhMyPosh

Required PowerShell modules (auto-installed):
- posh-git (Git integration)
- PSFzf (Fuzzy finder)
- PSEverything (Everything search)
- ZLocation (Smart directory jumping)

## Performance Notes

- Initial setup performs package checks (~2800ms)
- Subsequent startups skip checks using flag file `~/.omp_installed`
- Oh My Posh loading time is tracked and logged
- Use `Update-OhMyPoshDependencies` to force re-check dependencies