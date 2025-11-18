@echo off
REM Batch file wrapper for PowerShell uninstaller

echo ========================================
echo SYN Seed Script Uninstaller
echo ========================================
echo.
echo This will run the PowerShell uninstaller...
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell is not available.
    echo Please run uninstall.ps1 manually.
    pause
    exit /b 1
)

REM Run PowerShell uninstaller
powershell.exe -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Uninstallation failed. Press any key to exit...
    pause >nul
    exit /b 1
)

exit /b 0
