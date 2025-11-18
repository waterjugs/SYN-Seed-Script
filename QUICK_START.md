# Quick Start Guide - Installer Setup

This guide will help you quickly set up an installer for distributing the SYN Seed Script to different users and computers.

## Option 1: PowerShell Installer (Easiest - Recommended for Most Users)

### For Distributors:

1. **Package all files:**
   - Include all original files (config.txt, script.bat, task.xml, Seeder.exe, etc.)
   - Include `install.ps1` and `install.bat`
   - Include `uninstall.ps1` and `uninstall.bat`
   - Include `INSTALLER_README.md` and `QUICK_START.md`

2. **Create a zip file** with all these files

3. **Distribute** the zip file to users

### For End Users:

1. **Extract the zip file**

2. **Run the installer:**
   - **Easy way:** Double-click `install.bat`
   - **Alternative:** Right-click `install.ps1` → "Run with PowerShell"

3. **Follow the prompts:**
   - Choose whether to perform a clean installation (if directory exists)
   - Wait for installation to complete
   - jq utility will be downloaded automatically
   - Scheduled task will be created automatically

4. **Configure if needed:**
   - Edit `%USERPROFILE%\hll-seq-seed\config.txt` if using Epic Games launcher
   - Change `LAUNCHER=Steam` to `LAUNCHER=epic`

---

## Option 2: Inno Setup Installer (Professional Windows Installer)

### For Distributors:

**Prerequisites:**
- Download and install Inno Setup from: https://jrsoftware.org/isdl.php

**Steps:**

1. **Open Inno Setup Compiler**

2. **Open `installer.iss`** in Inno Setup Compiler

3. **Build the installer:**
   - Click "Build" → "Compile" (or press F9)
   - The installer will be created in the `dist` folder
   - Filename: `SYN-Seed-Script-Setup-v4.0.0.exe`

4. **Distribute:**
   - Share only the `.exe` file with users
   - Users don't need any other files

### For End Users:

1. **Download** `SYN-Seed-Script-Setup-v4.0.0.exe`

2. **Run the installer:**
   - Double-click the `.exe` file
   - Follow the installation wizard
   - Installation happens automatically

3. **Configure if needed:**
   - Same as Option 1 (edit config.txt if using Epic Games)

---

## Silent Installation (For System Administrators)

### PowerShell Installer:
```cmd
powershell.exe -ExecutionPolicy Bypass -File "install.ps1" -Silent
```

### Inno Setup Installer:
```cmd
SYN-Seed-Script-Setup-v4.0.0.exe /SILENT /SUPPRESSMSGBOXES
```

---

## Uninstallation

### PowerShell Method:
- Double-click `uninstall.bat`
- Or run: `powershell.exe -ExecutionPolicy Bypass -File "uninstall.ps1"`

### Inno Setup Method:
- Go to Windows Settings → Apps
- Find "SYN Seed Script"
- Click "Uninstall"

---

## Files Included in Installer Package

### Required Files (Must be in installer package):
- `config.txt` - Configuration file
- `script.bat` - Main seeding script
- `task.xml` - Task Scheduler configuration
- `Seeder.exe` - Seeder executable
- `enable.bat` - Enable script (original)
- `disable.bat` - Disable script (original)
- `README.md` - User documentation

### Installer Files:
- `install.ps1` - PowerShell installer script
- `install.bat` - Batch wrapper for installer
- `uninstall.ps1` - PowerShell uninstaller script
- `uninstall.bat` - Batch wrapper for uninstaller
- `installer.iss` - Inno Setup script (for professional installer)
- `post-install.ps1` - Post-installation script (for Inno Setup)

### Documentation:
- `INSTALLER_README.md` - Detailed installer documentation
- `QUICK_START.md` - This file

---

## Testing the Installer

### Before Distribution:

1. **Test on clean system:**
   - Install on a test computer
   - Verify all files are copied correctly
   - Verify jq is downloaded and installed
   - Verify Task Scheduler task is created

2. **Test uninstall:**
   - Run uninstaller
   - Verify tasks are removed
   - Verify directory can be removed

3. **Test configuration:**
   - Edit config.txt for Epic Games
   - Verify script still works

---

## Troubleshooting

### PowerShell Execution Policy Error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Task Scheduler Creation Failed:
- Run installer as Administrator
- Or manually create task after installation

### jq Download Failed:
- Check internet connection
- Manually download jq.exe to `%USERPROFILE%\hll-seq-seed\jq\jq.exe`

---

## Recommendation

- **For most users:** Use PowerShell installer (Option 1)
  - Easiest to set up
  - No additional tools required
  - Works on all Windows systems with PowerShell

- **For professional distribution:** Use Inno Setup (Option 2)
  - Professional appearance
  - Single executable file
  - Standard Windows installer experience
  - Requires Inno Setup to compile (free)

---

## Next Steps

1. Choose your installer method
2. Test the installer
3. Package for distribution
4. Share with users
5. Provide support as needed

For detailed information, see `INSTALLER_README.md`.
