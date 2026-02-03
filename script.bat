REM Version: 3.0.4
@ECHO ON


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



:PowerShell
SET PSScript=%temp%\~tmpDlFile.ps1
IF EXIST "%PSScript%" DEL /Q /F "%PSScript%"
ECHO [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls">>"%PSScript%"
ECHO Invoke-WebRequest "https://github.com/waterjugs/SYN-Seed-Script/archive/refs/heads/main.zip" -OutFile "main.zip">>"%PSScript%"

Powershell -ExecutionPolicy Bypass -Command "& '%PSScript%'"

tar -xf main.zip

xcopy /s /e /y "%SEED_DIRECTORY%\SYN-Seed-Script-main" "%SEED_DIRECTORY%\"
echo.
echo Directory copied.
@echo off
for /f "delims=" %%x in (config.txt) do (set "%%x")
echo Checking to see if HLL is running...
set "APPLICATION=HLL-Win64-Shipping.exe"
echo Launching CTRL Alt Defeat Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountCTRL=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountCTRL=%%i

IF NOT DEFINED axiscountCTRL goto ServerDownCTRL
IF DEFINED axiscountCTRL goto ServerUpCTRL
:ServerDownCTRL
echo The "Ctrl Alt Defeat[Hellfire" Server is Down. Skipping to the "SWEATS AND SYNNERS | Syndicate" server.
goto SYNSEED
:ServerUpCTRL
echo.Allied Faction has %alliedcountCTRL% players
echo.Axis Faction has %axiscountCTRL% players
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count"`) do set countCTRL=%%i
echo.Player Count %countCTRL%
If %countCTRL% gtr %SEEDED_THRESHOLD% (
goto SYNSEED
)

if %alliedcountCTRL% leq %axiscountCTRL% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% SpawnSL
timeout /t 10 >nul
goto CTRLloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "Ctrl Alt Defeat[Hellfire" %LAUNCHER% SpawnSL
timeout /t 10 >nul

goto CTRLloop
)

:CTRLloop

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count"`) do set countCTRL=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.time_remaining"`) do set timeCTRL=%%i
for /f "tokens=1,2 delims=." %%a  in ("%timeCTRL%") do (set timeCTRL=%%a)
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountCTRL=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountCTRL=%%i

if %countCTRL% gtr %SEEDED_THRESHOLD% (
    echo "Ctrl Alt Defeat[Hellfire" Player count is greater than %SEEDED_THRESHOLD%.
    goto endCTRL
) else (
    echo "Ctrl Alt Defeat[Hellfire" Player count is %countCTRL%. Waiting 30 seconds...
	echo Timeleft: %timeCTRL%
	if %timeCTRL% geq 5280 (
	echo New Map.
		if %alliedcountCTRL% leq %axiscountCTRL% (
		echo Spawning
		Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% ReSpawnSL
		) else (
		echo Spawning
		Seeder.exe Axis "Ctrl Alt Defeat[Hellfire" %LAUNCHER% ReSpawnSL
		)
	timeout /t 120 >nul
	goto CTRLloop
	) else (
    timeout /t 30 >nul
	Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% AFK
    goto CTRLloop
)
)

:endCTRL
Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% AltF4
echo Waiting for HLL to Close.
timeout /t 60 >nul


:SYNSEED
echo The "Ctrl Alt Defeat[Hellfire" Server is seeded. Onto the "SWEATS AND SYNNERS | Syndicate" server
echo Launching "SWEATS AND SYNNERS | Syndicate" Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountSYN=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountSYN=%%i

IF NOT DEFINED axiscountSYN goto ServerDownSYN
IF DEFINED axiscountSYN goto ServerUpSYN
:ServerDownSYN
echo The "SWEATS AND SYNNERS | Syndicate" Server is Down. Skipping to end of seeding.
goto endFINAL
:ServerUpSYN
echo.Allied Faction has %alliedcountSYN% players
echo.Axis Faction has %axiscountSYN% players
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count"`) do set countSYN=%%i
echo.Player Count %countSYN%
If %countSYN% gtr %SEEDED_THRESHOLD% (
goto endFINAL
)

if %alliedcountSYN% leq %axiscountSYN% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "SWEATS AND SYNNERS | Syndicate" %LAUNCHER% SpawnSL
timeout /t 10 >nul
goto SYNloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "SWEATS AND SYNNERS | Syndicate" %LAUNCHER% SpawnSL
timeout /t 10 >nul

goto SYNloop
)
:SYNloop
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count"`) do set countSYN=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.time_remaining"`) do set timeSYN=%%i
for /f "tokens=1,2 delims=." %%a  in ("%timeSYN%") do (set timeSYN=%%a)
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountSYN=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountSYN=%%i

if %countSYN% gtr %SEEDED_THRESHOLD% (
    echo "SWEATS AND SYNNERS | Syndicate" Player count is greater than %SEEDED_THRESHOLD%.
    goto endFINAL
) else (
    echo "SWEATS AND SYNNERS | Syndicate" Player count is %countSYN%. Waiting 30 seconds...
	echo Timeleft: %timeSYN%
	if %timeSYN% geq 5280 (
	echo New Map.
		if %alliedcountSYN% leq %axiscountSYN% (
		echo Spawning
		Seeder.exe Allied "SWEATS AND SYNNERS | Syndicate" %LAUNCHER% ReSpawnSL
		) else (
		echo Spawning
		Seeder.exe Axis "SWEATS AND SYNNERS | Syndicate" %LAUNCHER% ReSpawnSL
		)
	timeout /t 120 >nul
	goto SYNloop
	) else (
    timeout /t 30 >nul
	Seeder.exe Allied "SWEATS AND SYNNERS | Syndicate" %LAUNCHER% AFK
    goto SYNloop
)
)

:endFINAL
echo All servers have been seeded! Thank you for contributing.
timeout /t 30 >nul
Seeder.exe Allied "SWEATS AND SYNNERS | Syndicate" %LAUNCHER% AltF4
echo Waiting for HLL to Close.
timeout /t 60 >nul

echo Putting the PC to sleep...
REM powercfg -h off
REM rundll32.exe powrprof.dll,SetSuspendState 0,1,0
REM powercfg -h on

echo PC is now asleep.

