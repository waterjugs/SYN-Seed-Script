@echo off
REM Batch file wrapper for PowerShell installer
REM This allows users to double-click to install without needing to run PowerShell manually

echo ========================================
echo SYN Seed Script Installer
echo ========================================
echo.
echo This will run the PowerShell installer...
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell is not found on this system.
    echo Please install PowerShell or run install.ps1 manually.
    pause
    exit /b 1
)

REM Run PowerShell installer
powershell.exe -ExecutionPolicy Bypass -File "%~dp0install.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Installation failed. Press any key to exit...
    pause >nul
    exit /b 1
)

exit /b 0
