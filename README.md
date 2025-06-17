# Before Installing

This seed script supports the **_Steam_** and **_Epic Games_** versions of Hell Let Loose.

Verify that you have one of these supported monitor resolutions listed below for the script to work:
  - 1920 x 1080
  - 2560 x 1440
  - 3840 x 2160
  - 2560 x 1080
  - 3440 x 1440
  - 5120 x 2160

If you do not have one of these supported resolutions, this error box will apear and the script will not work correctly.
  
![first](https://github.com/waterjugs/SYN-Seed-Script/blob/screenshots/Game%20Resolution%20Error.png)

## Step One: Delete All Intro Movies From Your Respective Game Folder.

This must be done to ensure the timings for the script work correctly.

-If you are using the _Steam_ version of Hell Let Loose
> Steam Intro Movies Location: "*YourSteamInstallPath*\\steamapps\common\Hell Let Loose\HLL\Content\Movies"

-If you are using the _Epic Games_ version of Hell Let Loose
> Epic Games Intro Movies Location: "Program Files\Epic Games\HellLetLooseG0WU4\HLL\Content\Movies"
 
## Step Two: Download The Latest Release
Download the latest seed script from the [releases](https://github.com/waterjugs/SYN-Seed-Script/releases) page.

-Extract the zip file

-Double click on `enable.bat` to run

-Click the `More info` button on the Windows Defender pop up highlighted in red.

> Why are you seeing this pop up? Because I am not paying microsoft for a certificate to run this script. If you have concerns about the code, you can check all of the code in the seeder.exe files in notepad++. The seeder.exe file has the instructions it executes at the bottom of the file.<br>

![second](https://github.com/waterjugs/SYN-Seed-Script/blob/screenshots/Windows%20Security%2001.png)

-Click `Run anyway` highlighted in red.

![third](https://github.com/waterjugs/SYN-Seed-Script/blob/screenshots/Windows%20Security%2002.png)

-Go to "C:\users\\*youruserprofile*\hll-seq-seed"

**Repeat these same steps above for the `script.bat` file**

At this point you should be able to open up your Windows Task Scheduler and see the newly created task `SYN seed`

You can find your Windows Task Scheduler by hitting the windows key and typing "Task" then clicking on the "Task Schduler"

![task](https://github.com/waterjugs/SYN-Seed-Script/blob/screenshots/Syn%20Task.png)
  
Even if you start late you will still be helping out! The task skips over already seeded servers so dont be afraid to start it manualy whenever you can if thats what you want to do.

You can manually launch the bot by going to the install directory "C:\users\\*youruserprofile*\hll-seq-seed" and launching script.bat

## Step Three: Using The Correct Config.txt Option

This seeding script work for both the Steam and Epic Games versions of Hell Let Loose. 

**By default** this script it set to run for the _Steam_ version of Hell Let Loose.

If you are intending on using the _Epic Games_ version of Hell Let Loose, follow these steps below:

-Go to "C:\users\\*youruserprofile*\hll-seq-seed"

-Open `config.txt`

-Change the option "LAUNCHER=" from `steam` to `epic`

-Save the file, it should now look like this:

![epic](https://github.com/waterjugs/SYN-Seed-Script/blob/screenshots/Config%20File%20Epic.png)

## Optional - Put Your Computer to Sleep After Seeding

-Go to the install directory should be "C:\users\\*youruserprofile*\hll-seq-seed"

-Find the script.bat file.

-Right Click the file and select "edit in Notepad"

-Go to the end of the file

-Delete the letters "REM" and the space.

It should now read like this:

> echo Putting the PC to sleep... <br>
> powercfg -h off <br>
> rundll32.exe powrprof.dll,SetSuspendState 0,1,0 <br>
> powercfg -h on <br>

It should put your computer to sleep after seeding now.

## Optional - If You Want Your Computer to Wake From Sleep

The task is already setup to wake up your computer from sleep, but you must be logged into your computer with your user account running the bot when you put it to sleep.

There is unfortunately no way to make the task login after a restart. This is a security decision made by Microsoft.

If you computer is not waking from sleep after you are logged in and put it to sleep make sure the Windows settings below are set.

-You need to go to "Control Panel" then "Hardware and Sound" then "Power Options" then "Edit Power Plan".

-On the power plan page click "Change advanced power settings".

-Make sure that the setting under "Sleep", "Allow wake timers" is set to "Enable" on all plans from the drop down shown as "Balanced [Active]" in the screenshot. 

![Power Plan](https://github.com/waterjugs/SYN-Seed-Script/blob/screenshots/Power%20Plan%20Settings.png) <br>

-Next Open "Settings"

-Go to "Accounts" on the left window.

-In the main right window go to "Sign-In options" with the key icon

-Scroll to "Additional Settings" Make sure "If you've been away, when should Windows require you to sign in again?" Is set to "Never" as shown below.<br>

![Account Settings](https://github.com/waterjugs/SYN-Seed-Script/blob/screenshots/Account%20Setting.png)
