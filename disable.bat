@echo off

echo Removing old tasks if exists
schtasks /delete /tn "SYN Seed" /f >nul2>nul

echo Uninstall has finished this window will close in 15 seconds...
timeout /t 15 >nul
