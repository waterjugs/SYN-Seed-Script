# Installer Documentation

This project includes multiple installer options for distributing the SYN Seed Script to different users and computers.

## Available Installers

### 1. PowerShell Installer (Recommended for Quick Distribution)

**File:** `install.ps1`

This is a native Windows PowerShell installer that doesn't require any additional tools to compile or run.

#### Features:
- ✅ No additional software required (uses built-in PowerShell)
- ✅ Interactive and silent installation modes
- ✅ Automatic jq utility download and installation
- ✅ Windows Task Scheduler configuration
- ✅ Clean installation option
- ✅ Error handling and validation

#### Usage:

**Interactive Installation:**
```powershell
.\install.ps1
```

**Silent Installation (for automated deployments):**
```powershell
.\install.ps1 -Silent
```

**Uninstall:**
```powershell
.\uninstall.ps1
```
or
```powershell
.\install.ps1 -Uninstall
```

#### Requirements:
- Windows PowerShell 3.0 or later
- Internet connection (for downloading jq)
- Administrator privileges (optional, but may be required for Task Scheduler)

---

### 2. Inno Setup Installer (Professional Windows Installer)

**File:** `installer.iss`

This creates a professional Windows installer (.exe) with a graphical wizard interface.

#### Features:
- ✅ Professional Windows installer UI
- ✅ Desktop and quick launch icons
- ✅ Standard Windows uninstaller integration
- ✅ Automatic jq download and task scheduling
- ✅ Proper versioning and metadata

#### Creating the Installer:

1. **Download Inno Setup:**
   - Visit: https://jrsoftware.org/isdl.php
   - Download and install Inno Setup Compiler (free)

2. **Compile the Installer:**
   - Open `installer.iss` in Inno Setup Compiler
   - Click "Build" → "Compile" (or press F9)
   - The installer will be created in the `dist` folder

3. **Distribute:**
   - Share the generated `SYN-Seed-Script-Setup-v4.0.0.exe` file
   - Users can double-click to install

#### Requirements for Compilation:
- Inno Setup 6.0 or later
- All project files in the same directory

---

## Installation Process

Both installers perform the following steps:

1. **File Installation:**
   - Copies all required files to `%USERPROFILE%\hll-seq-seed`
   - Files: `config.txt`, `script.bat`, `task.xml`, `Seeder.exe`, `enable.bat`, `disable.bat`, `README.md`

2. **jq Utility Installation:**
   - Creates `jq` subdirectory
   - Downloads `jq-win64.exe` from GitHub releases
   - Saves as `jq.exe` in the installation directory

3. **Task Scheduler Configuration:**
   - Removes any existing "SYN Seed" tasks
   - Creates new scheduled task "Syndicate\SYN Seed" using `task.xml`
   - Task runs daily at the configured time

4. **Clean Installation:**
   - If installation directory exists, user is prompted for clean install
   - Silent mode automatically performs clean installation

---

## Distribution Methods

### For End Users (Recommended):

**Option 1: PowerShell Installer**
- Distribute the entire project folder (zipped)
- Include `INSTALLER_README.md`
- Users run `install.ps1` with PowerShell

**Option 2: Inno Setup Installer**
- Compile `installer.iss` to create `.exe` installer
- Distribute the single `.exe` file
- Users double-click to install

### For System Administrators:

**Silent Installation (PowerShell):**
```powershell
# Deploy via Group Policy, SCCM, or manual script
powershell.exe -ExecutionPolicy Bypass -File "\\network\share\install.ps1" -Silent
```

**Silent Installation (Inno Setup):**
```cmd
SYN-Seed-Script-Setup-v4.0.0.exe /SILENT /SUPPRESSMSGBOXES
```

---

## Uninstallation

### PowerShell Uninstaller:
```powershell
.\uninstall.ps1
```
or
```powershell
.\install.ps1 -Uninstall
```

### Inno Setup Uninstaller:
- Use Windows "Add or Remove Programs" (Settings → Apps)
- Or run `unins000.exe` from installation directory

Both methods:
- Remove scheduled tasks
- Optionally remove installation directory (user prompt)

---

## Customization

### Changing Installation Directory:

**PowerShell Installer (`install.ps1`):**
- Edit line: `$INSTALL_DIR = "hll-seq-seed"`

**Inno Setup (`installer.iss`):**
- Edit line: `#define MyAppInstallDir "{userprofile}\hll-seq-seed"`

### Changing Task Schedule:

Edit `task.xml` before installation:
- Modify `<StartBoundary>` for start time
- Modify `<DaysInterval>` for frequency

---

## Troubleshooting

### PowerShell Execution Policy Error:

If you see "execution of scripts is disabled":
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Task Scheduler Creation Failed:

- Run installer as Administrator
- Or manually create task after installation:
```cmd
schtasks /Create /XML "%USERPROFILE%\hll-seq-seed\task.xml" /TN "Syndicate\SYN Seed"
```

### jq Download Failed:

- Manually download from: https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
- Save to: `%USERPROFILE%\hll-seq-seed\jq\jq.exe`

---

## Best Practices

1. **For Distribution:**
   - Use Inno Setup for professional appearance
   - Include version number in installer filename
   - Test installer on clean Windows installation

2. **For Automated Deployment:**
   - Use PowerShell installer with `-Silent` flag
   - Pre-download jq.exe if internet access is restricted
   - Document any custom configurations needed

3. **For Users:**
   - Provide clear installation instructions
   - Mention Windows Defender warnings (unsigned executable)
   - Include link to README.md for configuration

---

## File Structure After Installation

```
%USERPROFILE%\hll-seq-seed\
├── config.txt
├── script.bat
├── task.xml
├── Seeder.exe
├── enable.bat
├── disable.bat
├── README.md
└── jq\
    └── jq.exe
```

---

## Version History

- **v4.0.0** - Initial installer release
  - PowerShell installer with GUI and silent modes
  - Inno Setup installer script
  - Uninstaller support
  - Automatic jq download and task scheduling

---

## Support

For issues or questions about the installer:
- Check this README for common solutions
- Review the main project README.md
- Verify all required files are present before installation
