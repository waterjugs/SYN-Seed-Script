@echo off
for /f "delims=" %%x in (config.txt) do (set "%%x")
echo Checking to see if HLL is running...
set "APPLICATION=HLL-Win64-Shipping.exe"
echo Launching "[GER] Oktogon | OKT" Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLOKT% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountOKT=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLOKT% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountOKT=%%i

IF NOT DEFINED axiscountOKT goto ServerDownOKT
IF DEFINED axiscountOKT goto ServerUpOKT
:ServerDownOKT
echo The "[GER] Oktogon | OKT" Server is Down. Skipping to the "Ctrl Alt Defeat[Hellfire" server.
goto CTRLSEED
:ServerUpOKT
echo.Allied Faction has %alliedcountOKT% players
echo.Axis Faction has %axiscountOKT% players
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLOKT% ^| %JQ_PATH% -r ".result.player_count"`) do set countOKT=%%i
echo.Player Count %countOKT%
If %countOKT% gtr %SEEDED_THRESHOLD% (
goto CTRLSEED
)

if %alliedcountOKT% leq %axiscountOKT% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "[GER] Oktogon | OKT" %LAUNCHER% SpawnSL
timeout /t 10 >nul
goto OKTloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "[GER] Oktogon | OKT" %LAUNCHER% SpawnSL
timeout /t 10 >nul

goto OKTloop
)



:OKTloop

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLOKT% ^| %JQ_PATH% -r ".result.player_count"`) do set countOKT=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLOKT% ^| %JQ_PATH% -r ".result.time_remaining"`) do set timeOKT=%%i
for /f "tokens=1,2 delims=." %%a  in ("%timeOKT%") do (set timeOKT=%%a)
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLOKT% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountOKT=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLOKT% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountOKT=%%i

if %countOKT% gtr %SEEDED_THRESHOLD% (
    echo Player count is greater than %SEEDED_THRESHOLD%.
    goto endloop
) else (
    echo Player count is %countOKT%. Waiting 30 seconds...
	echo Timeleft: %timeOKT%
	if %timeOKT% geq 5280 (
	echo New Map.
		if %alliedcountOKT% leq %axiscountOKT% (
		echo Spawning
		Seeder.exe Allied "[GER] Oktogon | OKT" %LAUNCHER% ReSpawnSL
		) else (
		echo Spawning
		Seeder.exe Axis "[GER] Oktogon | OKT" %LAUNCHER% ReSpawnSL
		)
	timeout /t 120 >nul
	goto OKTloop
	) else (
    timeout /t 60 >nul
    goto OKTloop
)
)

:endloop
Seeder.exe Allied "[GER] Oktogon | OKT" %LAUNCHER% AltF4
echo Waiting for HLL to Close.
timeout /t 60 >nul
:CTRLSEED
echo The "[GER] Oktogon | OKT"Server is seeded. Onto the "Ctrl Alt Defeat[Hellfire" server.
echo Launching Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountCTRL=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLCTRL% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountCTRL=%%i

IF NOT DEFINED axiscountCTRL goto ServerDownCTRL
IF DEFINED axiscountCTRL goto ServerUpCTRL
:ServerDownCTRL
echo Server is Down. Skipping to next server.
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
    echo Player count is greater than %SEEDED_THRESHOLD%.
    goto endloop
) else (
    echo Player count is %countCTRL%. Waiting 30 seconds...
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
    goto CTRLloop
)
)

:endloop
Seeder.exe Allied "Ctrl Alt Defeat[Hellfire" %LAUNCHER% AltF4
echo Waiting for HLL to Close.
timeout /t 60 >nul
:SYNSEED
echo The "Ctrl Alt Defeat[Hellfire" Server is seeded. Onto the "Syndicate | US East" server
echo Launching Seed...
echo.
echo Checking Player counts ..

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.allied"`) do set alliedcountSYN=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count_by_team.axis"`) do set axiscountSYN=%%i

IF NOT DEFINED axiscountSYN goto ServerDownSYN
IF DEFINED axiscountSYN goto ServerUpSYN
:ServerDownSYN
echo The "Syndicate | US East" Server is Down. Skipping to end of seeding.
goto endloop
:ServerUpSYN
echo.Allied Faction has %alliedcountSYN% players
echo.Axis Faction has %axiscountSYN% players
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URLSYN% ^| %JQ_PATH% -r ".result.player_count"`) do set countSYN=%%i
echo.Player Count %countSYN%
If %countSYN% gtr %SEEDED_THRESHOLD% (
goto CTRLSEED
)

if %alliedcountSYN% leq %axiscountSYN% (
echo Launching as Allies. Time to Launch 4.5 Minutes.
Seeder.exe Allied "Syndicate | US East" %LAUNCHER% SpawnSL
timeout /t 10 >nul
goto SYNloop
) else (
echo Launching as Axis. Time to Launch 4.5 Minutes.
Seeder.exe Axis "Syndicate | US East" %LAUNCHER% SpawnSL
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
    echo Player count is greater than %SEEDED_THRESHOLD%.
    goto endloop
) else (
    echo Player count is %countSYN%. Waiting 30 seconds...
	echo Timeleft: %timeSYN%
	if %timeSYN% geq 5280 (
	echo New Map.
		if %alliedcountSYN% leq %axiscountSYN% (
		echo Spawning
		Seeder.exe Allied "Syndicate | US East" %LAUNCHER% ReSpawnSL
		) else (
		echo Spawning
		Seeder.exe Axis "Syndicate | US East" %LAUNCHER% ReSpawnSL
		)
	timeout /t 120 >nul
	goto SYNloop
	) else (
    timeout /t 30 >nul
    goto SYNloop
)
)

:endloop
Seeder.exe Allied "Syndicate | US East" %LAUNCHER% AltF4
echo Waiting for HLL to Close.
timeout /t 60 >nul

echo Putting the PC to sleep...
REM powercfg -h off
REM rundll32.exe powrprof.dll,SetSuspendState 0,1,0
REM powercfg -h on

echo PC is now asleep.
