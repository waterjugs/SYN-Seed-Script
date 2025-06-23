REM version 20250622a 

@echo off

REM SafeGuard incase config.txt file doesn't include the variable 
SET "INSTALL_DIR=hll-seq-seed" 

REM Set the absolute path in the event the enable.bat file is not executed with the install file folder.
SET "scriptdir=%~dp0"

 if not exist "%scriptdir%config.txt" (
 echo config.txt file not found at path location %scriptdir%
goto :exit
) ELSE (
 echo config.txt file exists at path location %scriptdir% 
)
 

for /f "delims=" %%x in (%scriptdir%config.txt) do (set "%%x")

setlocal enabledelayedexpansion 

set SEED_DIRECTORY=%USERPROFILE%\%INSTALL_DIR%





if "%CD%"=="%SEED_DIRECTORY%" (
    echo Script is running from %SEED_DIRECTORY%
) else (
    if not exist "%SEED_DIRECTORY%" (
        echo Creating Folder: %SEED_DIRECTORY%
        mkdir "%SEED_DIRECTORY%"  
    ) else (
        echo %SEED_DIRECTORY% Folder already exists.
		echo.
		echo Deleting old files.
echo.
echo.
echo The Syndicate Seeder folder will be wiped for a cleaninstall of the Seeding bot.
echo.		
CHOICE /C YN /M " Do you want to continue with Deleting all files and subdirectories in folder %SEED_DIRECTORY%? (Y/N)"
IF ERRORLEVEL 2 GOTO :NoConfirmation
IF ERRORLEVEL 1 GOTO :ContinueScript

:ContinueScript
echo.
echo.
echo User confirmed. Continuing with the script...
		
		
		rmdir /s /q  "%SEED_DIRECTORY%"
		echo.
		mkdir "%SEED_DIRECTORY%"
    )
	echo.
	echo.
    echo Copying Files...
    copy /y "%scriptdir%enable.bat" "%SEED_DIRECTORY%\"
    copy /y "%scriptdir%disable.bat" "%SEED_DIRECTORY%\"
    copy /y "%scriptdir%script.bat" "%SEED_DIRECTORY%\"
    copy /y "%scriptdir%task.xml" "%SEED_DIRECTORY%\"
    copy /y "%scriptdir%config.txt" "%SEED_DIRECTORY%\"
    copy /y "%scriptdir%Seeder.exe" "%SEED_DIRECTORY%\"
	copy /y "%scriptdir%README.md" "%SEED_DIRECTORY%\"
)

echo.

echo Installing jq
set JQ_DIRECTORY=%USERPROFILE%\%INSTALL_DIR%\jq
if not exist %JQ_DIRECTORY% mkdir %JQ_DIRECTORY%

curl -L %JQ_URL% -o %JQ_DIRECTORY%\jq.exe

echo Installed jq to %JQ_DIRECTORY%

echo.


echo Removing old  Syn Seed schedule tasks tasks if exists
schtasks /delete /tn "SYN Seed" /f >NUL 2>&1

echo Removing old  Syn Seed schedule tasks tasks if exists
schtasks /delete /tn "Syndicate\SYN Seed" /f >NUL 2>&1

echo.

echo Installing new scheduled task
schtasks /create /xml %scriptdir%task.xml /tn "Syndicate\SYN Seed" /IT
echo Scheduled task created.


echo.
echo Installation has finished this window will close in 15 seconds...
timeout /t 15 >nul
exit /b
:exit
echo Installation cancelled config.txt file not found
exit /b 
:NoConfirmation
echo User did not confirm. Exiting...
exit /b







