; SYN Seed Script Installer
; Inno Setup Script
; Version: 4.0.0

#define MyAppName "SYN Seed Script"
#define MyAppVersion "4.0.0"
#define MyAppPublisher "Syndicate"
#define MyAppURL "https://github.com/waterjugs/SYN-Seed-Script"
#define MyAppInstallDir "{userprofile}\hll-seq-seed"

[Setup]
AppId={{3F8E9A2B-7C4D-4E1F-9A6B-2D5C8E7F1A3B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={#MyAppInstallDir}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=
OutputDir=dist
OutputBaseFilename=SYN-Seed-Script-Setup-v{#MyAppVersion}
SetupIconFile=
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: "config.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "script.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "task.xml"; DestDir: "{app}"; Flags: ignoreversion
Source: "Seeder.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "enable.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "disable.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "post-install.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\README.md"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\README.md"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\README.md"; Tasks: quicklaunchicon

[Code]
procedure InitializeWizard;
begin
  // Add custom initialization code here if needed
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    // Run post-install script after files are copied
    Exec('powershell.exe', '-ExecutionPolicy Bypass -File """' + ExpandConstant('{app}\post-install.ps1') + '"""', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

[UninstallRun]
Filename: "schtasks.exe"; Parameters: "/Delete /TN ""Syndicate\SYN Seed"" /F"; Flags: runhidden; RunOnceId: "DelTask1"
Filename: "schtasks.exe"; Parameters: "/Delete /TN ""SYN Seed"" /F"; Flags: runhidden; RunOnceId: "DelTask2"

