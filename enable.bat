@echo off
for /f "delims=" %%x in (config.txt) do (set "%%x")

setlocal enabledelayedexpansion

set SEED_DIRECTORY=%USERPROFILE%\%INSTALL_DIR%
if "%CD%"=="%SEED_DIRECTORY%" (
    echo Script is running from %SEED_DIRECTORY%
) else (
    if not exist "%SEED_DIRECTORY%" (
        echo Creating Folder: %SEED_DIRECTORY%
        mkdir "%SEED_DIRECTORY%"  
    ) else (
        echo Folder already exists.
		echo.
		echo Deleting old files.
		rmdir /S /Q "%SEED_DIRECTORY%"
		echo.
		mkdir "%SEED_DIRECTORY%"
    )
    echo Copying Files...
    copy /y "enable.bat" "%SEED_DIRECTORY%\"
    copy /y "disable.bat" "%SEED_DIRECTORY%\"
    copy /y "script.bat" "%SEED_DIRECTORY%\"
    copy /y "task.xml" "%SEED_DIRECTORY%\"
    copy /y "config.txt" "%SEED_DIRECTORY%\"
    copy /y "Seeder.exe" "%SEED_DIRECTORY%\"
)

echo.

echo Installing jq
set JQ_DIRECTORY=%USERPROFILE%\%INSTALL_DIR%\jq
if not exist %JQ_DIRECTORY% mkdir %JQ_DIRECTORY%

curl -L %JQ_URL% -o %JQ_DIRECTORY%\jq.exe

echo Installed jq to %JQ_DIRECTORY%

echo.

echo Legacy: removing old tasks if exists
schtasks /delete /tn "GOF Seed" /f >nul2>nul

echo Removing old tasks if exists
schtasks /delete /tn "SYN Seed" /f >nul2>nul


echo.
echo Installing new task
schtasks /create /xml task.xml /tn "SYN Seed" /IT
echo Scheduled task created.

echo.
echo Installation has finished this window will close in 15 seconds...
timeout /t 15 >nul
