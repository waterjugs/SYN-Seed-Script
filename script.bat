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
REM Download updates from GitHub
SET PSScript=%temp%\~tmpDlFile.ps1
IF EXIST "%PSScript%" DEL /Q /F "%PSScript%"
ECHO [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls">>"%PSScript%"
ECHO Invoke-WebRequest "https://github.com/waterjugs/SYN-Seed-Script/archive/refs/heads/main.zip" -OutFile "main.zip">>"%PSScript%"

Powershell -ExecutionPolicy Bypass -Command "& '%PSScript%'"

tar -xf main.zip

REM Copy all files including script.bat from GitHub download
if exist "%SEED_DIRECTORY%\SYN-Seed-Script-main" (
    xcopy /s /e /y "%SEED_DIRECTORY%\SYN-Seed-Script-main\*" "%SEED_DIRECTORY%\" >nul 2>&1
)
echo.
echo Directory copied (including script.bat from GitHub).

@echo off
for /f "delims=" %%x in (%scriptdir%config.txt) do (set "%%x")

echo Checking to see if HLL is running...
set "APPLICATION=HLL-Win64-Shipping.exe"

REM Wait for HLL to start before proceeding
call :WaitForHLL

REM Function to wait for HLL window
:WaitForHLL
tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
if errorlevel 1 (
    echo Waiting for HLL to start...
    timeout /t 5 >nul
    goto WaitForHLL
)
echo HLL process detected. Waiting for window to be ready...
REM Wait additional time for window to be fully ready
timeout /t 10 >nul
REM Use PowerShell to verify window actually exists
powershell -Command "$proc = Get-Process '%APPLICATION%' -ErrorAction SilentlyContinue; if ($proc) { $hwnd = $proc.MainWindowHandle; if ($hwnd -ne 0) { exit 0 } else { exit 1 } } else { exit 1 }" >nul 2>&1
if errorlevel 1 (
    echo Window not ready yet, waiting more...
    timeout /t 5 >nul
    goto WaitForHLL
)
echo HLL window is ready.
exit /b

echo Launching "Ctrl Alt Defeat[Hellfire" Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountCTRL=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountCTRL=%%i

IF NOT DEFINED axiscountCTRL goto ServerDownCTRLSEED
IF DEFINED axiscountCTRL goto ServerUpCTRLSEED
:ServerDownCTRLSEED
echo The "Ctrl Alt Defeat[Hellfire" Server is Down. Skipping to the next server.
goto EXILEDSEED
:ServerUpCTRLSEED
echo.Allied Faction has %alliedcountCTRL% players
echo.Axis Faction has %axiscountCTRL% players
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count") do set countCTRL=%%i
echo.Player Count %countCTRL%
If %countCTRL% gtr %SEEDED_THRESHOLD% (
goto EXILEDSEED
)

REM Wait for HLL window to be available before calling Seeder.exe
echo Waiting for HLL window to be ready...
set "HLL_READY=0"
for /L %%w in (1,1,60) do (
    tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
    if not errorlevel 1 (
        REM Process found, now verify window exists
        powershell -Command "$proc = Get-Process '%APPLICATION%' -ErrorAction SilentlyContinue; if ($proc) { $hwnd = $proc.MainWindowHandle; if ($hwnd -ne 0) { exit 0 } else { exit 1 } } else { exit 1 }" >nul 2>&1
        if not errorlevel 1 (
            timeout /t 10 >nul
            set "HLL_READY=1"
            goto HLLReadyCTRLSEED
        )
    )
    timeout /t 2 >nul
)
:HLLReadyCTRLSEED
if "%HLL_READY%"=="0" (
    echo WARNING: HLL window not found after 2 minutes. Seeder.exe may fail.
)

if %alliedcountCTRL% leq %axiscountCTRL% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul
goto CTRLloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "Ctrl Alt Defeat[Hellfire" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul

goto CTRLloop
)



:CTRLloop

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count") do set countCTRL=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.time_remaining") do set timeCTRL=%%i
for /f "tokens=1,2 delims=." %%a  in ("%timeCTRL%") do (set timeCTRL=%%a)
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountCTRL=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountCTRL=%%i

if %countCTRL% gtr %SEEDED_THRESHOLD% (
    echo "Ctrl Alt Defeat[Hellfire" Player count is greater than %SEEDED_THRESHOLD%.
    goto EXILEDSEED
) else (
    echo "Ctrl Alt Defeat[Hellfire" Player count is %countCTRL%. Waiting 30 seconds...
	echo Timeleft: %timeCTRL%
	if %timeCTRL% geq 5280 (
	echo New Map.
		REM Wait for HLL window before respawning
		tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
		if not errorlevel 1 (
			if %alliedcountCTRL% leq %axiscountCTRL% (
			echo Spawning
			Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			) else (
			echo Spawning
			Seeder.exe Axis "Ctrl Alt Defeat[Hellfire" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			)
		) else (
			echo HLL window not found. Skipping respawn.
		)
	timeout /t 120 >nul
	goto CTRLloop
	) else (
    timeout /t 30 >nul
	tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
	if not errorlevel 1 (
		Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% AFK
		if errorlevel 1 (
			echo WARNING: Seeder.exe returned an error. Continuing anyway...
		)
	) else (
		echo HLL window not found. Skipping AFK command.
	)
    goto CTRLloop
)
)

:endCTRL
tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
if not errorlevel 1 (
    Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% AltF4
    if errorlevel 1 (
        echo WARNING: Seeder.exe returned an error. Attempting to close HLL anyway...
        taskkill /F /IM %APPLICATION% >nul 2>&1
    )
) else (
    echo HLL is not running. Skipping close command.
)
echo Waiting for HLL to Close.
timeout /t 60 >nul
echo The "Ctrl Alt Defeat[Hellfire" Server is seeded. Onto the "Exiled" server

:EXILEDSEED
echo Launching "Exiled" Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLEXILED% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountEXILED=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLEXILED% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountEXILED=%%i

IF NOT DEFINED axiscountEXILED goto ServerDownEXILEDSEED
IF DEFINED axiscountEXILED goto ServerUpEXILEDSEED
:ServerDownEXILEDSEED
echo The "Exiled" Server is Down. Skipping to the next server.
goto ROTNSEED
:ServerUpEXILEDSEED
echo.Allied Faction has %alliedcountEXILED% players
echo.Axis Faction has %axiscountEXILED% players
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLEXILED% ^| %JQ_PATH% -r ".result.player_count") do set countEXILED=%%i
echo.Player Count %countEXILED%
If %countEXILED% gtr %SEEDED_THRESHOLD% (
goto ROTNSEED
)

REM Wait for HLL window to be available before calling Seeder.exe
echo Waiting for HLL window to be ready...
set "HLL_READY=0"
for /L %%w in (1,1,60) do (
    tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
    if not errorlevel 1 (
        REM Process found, now verify window exists
        powershell -Command "$proc = Get-Process '%APPLICATION%' -ErrorAction SilentlyContinue; if ($proc) { $hwnd = $proc.MainWindowHandle; if ($hwnd -ne 0) { exit 0 } else { exit 1 } } else { exit 1 }" >nul 2>&1
        if not errorlevel 1 (
            timeout /t 10 >nul
            set "HLL_READY=1"
            goto HLLReadyEXILEDSEED
        )
    )
    timeout /t 2 >nul
)
:HLLReadyEXILEDSEED
if "%HLL_READY%"=="0" (
    echo WARNING: HLL window not found after 2 minutes. Seeder.exe may fail.
)

if %alliedcountEXILED% leq %axiscountEXILED% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "Exiled" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul
goto EXILEDloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "Exiled" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul

goto EXILEDloop
)



:EXILEDloop

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLEXILED% ^| %JQ_PATH% -r ".result.player_count") do set countEXILED=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLEXILED% ^| %JQ_PATH% -r ".result.time_remaining") do set timeEXILED=%%i
for /f "tokens=1,2 delims=." %%a  in ("%timeEXILED%") do (set timeEXILED=%%a)
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLEXILED% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountEXILED=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLEXILED% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountEXILED=%%i

if %countEXILED% gtr %SEEDED_THRESHOLD% (
    echo "Exiled" Player count is greater than %SEEDED_THRESHOLD%.
    goto ROTNSEED
) else (
    echo "Exiled" Player count is %countEXILED%. Waiting 30 seconds...
	echo Timeleft: %timeEXILED%
	if %timeEXILED% geq 5280 (
	echo New Map.
		REM Wait for HLL window before respawning
		tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
		if not errorlevel 1 (
			if %alliedcountEXILED% leq %axiscountEXILED% (
			echo Spawning
			Seeder.exe Allied "Exiled" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			) else (
			echo Spawning
			Seeder.exe Axis "Exiled" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			)
		) else (
			echo HLL window not found. Skipping respawn.
		)
	timeout /t 120 >nul
	goto EXILEDloop
	) else (
    timeout /t 30 >nul
	tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
	if not errorlevel 1 (
		Seeder.exe Allied "Exiled" %LAUNCHER% AFK
		if errorlevel 1 (
			echo WARNING: Seeder.exe returned an error. Continuing anyway...
		)
	) else (
		echo HLL window not found. Skipping AFK command.
	)
    goto EXILEDloop
)
)

:endEXILED
tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
if not errorlevel 1 (
    Seeder.exe Allied "Exiled" %LAUNCHER% AltF4
    if errorlevel 1 (
        echo WARNING: Seeder.exe returned an error. Attempting to close HLL anyway...
        taskkill /F /IM %APPLICATION% >nul 2>&1
    )
) else (
    echo HLL is not running. Skipping close command.
)
echo Waiting for HLL to Close.
timeout /t 60 >nul
echo The "Exiled" Server is seeded. Onto the "=ROTN= OnlyToes" server

:ROTNSEED
echo Launching "=ROTN= OnlyToes" Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLROTN% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountROTN=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLROTN% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountROTN=%%i

IF NOT DEFINED axiscountROTN goto ServerDownROTNSEED
IF DEFINED axiscountROTN goto ServerUpROTNSEED
:ServerDownROTNSEED
echo The "=ROTN= OnlyToes" Server is Down. Skipping to the next server.
goto SYNSEED
:ServerUpROTNSEED
echo.Allied Faction has %alliedcountROTN% players
echo.Axis Faction has %axiscountROTN% players
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLROTN% ^| %JQ_PATH% -r ".result.player_count") do set countROTN=%%i
echo.Player Count %countROTN%
If %countROTN% gtr %SEEDED_THRESHOLD% (
goto SYNSEED
)

REM Wait for HLL window to be available before calling Seeder.exe
echo Waiting for HLL window to be ready...
set "HLL_READY=0"
for /L %%w in (1,1,60) do (
    tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
    if not errorlevel 1 (
        REM Process found, now verify window exists
        powershell -Command "$proc = Get-Process '%APPLICATION%' -ErrorAction SilentlyContinue; if ($proc) { $hwnd = $proc.MainWindowHandle; if ($hwnd -ne 0) { exit 0 } else { exit 1 } } else { exit 1 }" >nul 2>&1
        if not errorlevel 1 (
            timeout /t 10 >nul
            set "HLL_READY=1"
            goto HLLReadyROTNSEED
        )
    )
    timeout /t 2 >nul
)
:HLLReadyROTNSEED
if "%HLL_READY%"=="0" (
    echo WARNING: HLL window not found after 2 minutes. Seeder.exe may fail.
)

if %alliedcountROTN% leq %axiscountROTN% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "=ROTN= OnlyToes" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul
goto ROTNloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "=ROTN= OnlyToes" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul

goto ROTNloop
)



:ROTNloop

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLROTN% ^| %JQ_PATH% -r ".result.player_count") do set countROTN=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLROTN% ^| %JQ_PATH% -r ".result.time_remaining") do set timeROTN=%%i
for /f "tokens=1,2 delims=." %%a  in ("%timeROTN%") do (set timeROTN=%%a)
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLROTN% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountROTN=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLROTN% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountROTN=%%i

if %countROTN% gtr %SEEDED_THRESHOLD% (
    echo "=ROTN= OnlyToes" Player count is greater than %SEEDED_THRESHOLD%.
    goto SYNSEED
) else (
    echo "=ROTN= OnlyToes" Player count is %countROTN%. Waiting 30 seconds...
	echo Timeleft: %timeROTN%
	if %timeROTN% geq 10680 (
	echo New Map.
		REM Wait for HLL window before respawning
		tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
		if not errorlevel 1 (
			if %alliedcountROTN% leq %axiscountROTN% (
			echo Spawning
			Seeder.exe Allied "=ROTN= OnlyToes" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			) else (
			echo Spawning
			Seeder.exe Axis "=ROTN= OnlyToes" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			)
		) else (
			echo HLL window not found. Skipping respawn.
		)
	timeout /t 120 >nul
	goto ROTNloop
	) else (
    timeout /t 30 >nul
	tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
	if not errorlevel 1 (
		Seeder.exe Allied "=ROTN= OnlyToes" %LAUNCHER% AFK
		if errorlevel 1 (
			echo WARNING: Seeder.exe returned an error. Continuing anyway...
		)
	) else (
		echo HLL window not found. Skipping AFK command.
	)
    goto ROTNloop
)
)

:endROTN
tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
if not errorlevel 1 (
    Seeder.exe Allied "=ROTN= OnlyToes" %LAUNCHER% AltF4
    if errorlevel 1 (
        echo WARNING: Seeder.exe returned an error. Attempting to close HLL anyway...
        taskkill /F /IM %APPLICATION% >nul 2>&1
    )
) else (
    echo HLL is not running. Skipping close command.
)
echo Waiting for HLL to Close.
timeout /t 60 >nul
echo The "=ROTN= OnlyToes" Server is seeded. Onto the "Syndicate | US East" server

:SYNSEED
echo Launching "Syndicate | US East" Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountSYN=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountSYN=%%i

IF NOT DEFINED axiscountSYN goto ServerDownSYNSEED
IF DEFINED axiscountSYN goto ServerUpSYNSEED
:ServerDownSYNSEED
echo The "Syndicate | US East" Server is Down. Skipping to end of seeding.
goto endFINAL
:ServerUpSYNSEED
echo.Allied Faction has %alliedcountSYN% players
echo.Axis Faction has %axiscountSYN% players
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count") do set countSYN=%%i
echo.Player Count %countSYN%
If %countSYN% gtr %SEEDED_THRESHOLD% (
goto endFINAL
)

REM Wait for HLL window to be available before calling Seeder.exe
echo Waiting for HLL window to be ready...
set "HLL_READY=0"
for /L %%w in (1,1,60) do (
    tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
    if not errorlevel 1 (
        REM Process found, now verify window exists
        powershell -Command "$proc = Get-Process '%APPLICATION%' -ErrorAction SilentlyContinue; if ($proc) { $hwnd = $proc.MainWindowHandle; if ($hwnd -ne 0) { exit 0 } else { exit 1 } } else { exit 1 }" >nul 2>&1
        if not errorlevel 1 (
            timeout /t 10 >nul
            set "HLL_READY=1"
            goto HLLReadySYNSEED
        )
    )
    timeout /t 2 >nul
)
:HLLReadySYNSEED
if "%HLL_READY%"=="0" (
    echo WARNING: HLL window not found after 2 minutes. Seeder.exe may fail.
)

if %alliedcountSYN% leq %axiscountSYN% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "Syndicate | US East" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul
goto SYNloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "Syndicate | US East" %LAUNCHER% SpawnSL
if errorlevel 1 (
    echo WARNING: Seeder.exe returned an error. Continuing anyway...
)
timeout /t 10 >nul

goto SYNloop
)



:SYNloop

for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count") do set countSYN=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.time_remaining") do set timeSYN=%%i
for /f "tokens=1,2 delims=." %%a  in ("%timeSYN%") do (set timeSYN=%%a)
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.allied") do set alliedcountSYN=%%i
for /f "usebackq delims=," %%i in (curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.axis") do set axiscountSYN=%%i

if %countSYN% gtr %SEEDED_THRESHOLD% (
    echo "Syndicate | US East" Player count is greater than %SEEDED_THRESHOLD%.
    goto endFINAL
) else (
    echo "Syndicate | US East" Player count is %countSYN%. Waiting 30 seconds...
	echo Timeleft: %timeSYN%
	if %timeSYN% geq 5280 (
	echo New Map.
		REM Wait for HLL window before respawning
		tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
		if not errorlevel 1 (
			if %alliedcountSYN% leq %axiscountSYN% (
			echo Spawning
			Seeder.exe Allied "Syndicate | US East" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			) else (
			echo Spawning
			Seeder.exe Axis "Syndicate | US East" %LAUNCHER% ReSpawnSL
			if errorlevel 1 (
				echo WARNING: Seeder.exe returned an error. Continuing anyway...
			)
			)
		) else (
			echo HLL window not found. Skipping respawn.
		)
	timeout /t 120 >nul
	goto SYNloop
	) else (
    timeout /t 30 >nul
	tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
	if not errorlevel 1 (
		Seeder.exe Allied "Syndicate | US East" %LAUNCHER% AFK
		if errorlevel 1 (
			echo WARNING: Seeder.exe returned an error. Continuing anyway...
		)
	) else (
		echo HLL window not found. Skipping AFK command.
	)
    goto SYNloop
)
)

:endSYN
tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
if not errorlevel 1 (
    Seeder.exe Allied "Syndicate | US East" %LAUNCHER% AltF4
    if errorlevel 1 (
        echo WARNING: Seeder.exe returned an error. Attempting to close HLL anyway...
        taskkill /F /IM %APPLICATION% >nul 2>&1
    )
) else (
    echo HLL is not running. Skipping close command.
)
echo Waiting for HLL to Close.
timeout /t 60 >nul

:endFINAL
echo All servers have been seeded! Thank you for contributing.
timeout /t 30 >nul
tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I /N "%APPLICATION%">NUL
if not errorlevel 1 (
    Seeder.exe Allied "Exiled" %LAUNCHER% AltF4
    if errorlevel 1 (
        echo WARNING: Seeder.exe returned an error. Attempting to close HLL anyway...
        taskkill /F /IM %APPLICATION% >nul 2>&1
    )
) else (
    echo HLL is not running. Skipping close command.
)
echo Waiting for HLL to Close.
timeout /t 60 >nul

echo Putting the PC to sleep...
REM powercfg -h off
REM rundll32.exe powrprof.dll,SetSuspendState 0,1,0
REM powercfg -h on

echo PC is now asleep.
:exit

