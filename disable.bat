@echo off

echo Removing old  Syn Seed schedule tasks tasks if exists
schtasks /delete /tn "SYN Seed" /f >NUL 2>&1

echo Removing old  Syn Seed schedule tasks tasks if exists
schtasks /delete /tn "Syndicate\SYN Seed" /f >NUL 2>&1

echo Uninstall has finished this window will close in 15 seconds...
timeout /t 15 >nul
