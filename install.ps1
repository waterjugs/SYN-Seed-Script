# SYN Seed Script Installer
# Version: 4.0.0
# PowerShell-based installer for SYN Seed Script

param(
    [switch]$Silent,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# Configuration
$INSTALL_DIR = "hll-seq-seed"
$INSTALL_PATH = Join-Path $env:USERPROFILE $INSTALL_DIR
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Display message (respects silent mode)
function Write-Message {
    param([string]$Message, [string]$Color = "White")
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Main installation function
function Install-SYNSeedScript {
    Write-Message "========================================" "Cyan"
    Write-Message "SYN Seed Script Installer v4.0.0" "Cyan"
    Write-Message "========================================" "Cyan"
    Write-Message ""

    # Check if running from correct location
    $requiredFiles = @("config.txt", "script.bat", "task.xml", "Seeder.exe", "enable.bat", "disable.bat", "README.md")
    $missingFiles = @()
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $SCRIPT_DIR $file
        if (-not (Test-Path $filePath)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Message "ERROR: Missing required files:" "Red"
        foreach ($file in $missingFiles) {
            Write-Message "  - $file" "Red"
        }
        Write-Message ""
        Write-Message "Please run this installer from the directory containing all files." "Yellow"
        if (-not $Silent) {
            Read-Host "Press Enter to exit"
        }
        exit 1
    }

    Write-Message "Installation directory: $INSTALL_PATH" "Green"
    Write-Message ""

    # Check if installation directory exists
    $cleanInstall = $false
    if (Test-Path $INSTALL_PATH) {
        if (-not $Silent) {
            Write-Message "The installation directory already exists." "Yellow"
            $response = Read-Host "Do you want to perform a clean installation? This will delete all files in the directory. (Y/N)"
            if ($response -eq "Y" -or $response -eq "y") {
                Write-Message "Removing existing installation..." "Yellow"
                Remove-Item -Path $INSTALL_PATH -Recurse -Force -ErrorAction SilentlyContinue
                $cleanInstall = $true
            } else {
                Write-Message "Continuing with existing installation..." "Yellow"
            }
        } else {
            # Silent mode: clean install
            Write-Message "Performing clean installation (silent mode)..." "Yellow"
            Remove-Item -Path $INSTALL_PATH -Recurse -Force -ErrorAction SilentlyContinue
            $cleanInstall = $true
        }
    } else {
        $cleanInstall = $true
    }

    # Create installation directory
    if ($cleanInstall) {
        Write-Message "Creating installation directory..." "Green"
        New-Item -ItemType Directory -Path $INSTALL_PATH -Force | Out-Null
    }

    # Copy files
    Write-Message "Copying files..." "Green"
    $filesToCopy = @(
        "enable.bat",
        "disable.bat",
        "script.bat",
        "task.xml",
        "config.txt",
        "Seeder.exe",
        "README.md"
    )

    foreach ($file in $filesToCopy) {
        $sourcePath = Join-Path $SCRIPT_DIR $file
        $destPath = Join-Path $INSTALL_PATH $file
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Message "  Copied: $file" "Gray"
    }

    # Install jq
    Write-Message ""
    Write-Message "Installing jq utility..." "Green"
    $jqDir = Join-Path $INSTALL_PATH "jq"
    if (-not (Test-Path $jqDir)) {
        New-Item -ItemType Directory -Path $jqDir -Force | Out-Null
    }

    $jqUrl = "https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe"
    $jqPath = Join-Path $jqDir "jq.exe"

    try {
        # Read config to get JQ_URL if available
        $configPath = Join-Path $SCRIPT_DIR "config.txt"
        if (Test-Path $configPath) {
            $configContent = Get-Content $configPath
            foreach ($line in $configContent) {
                if ($line -match "JQ_URL=(.+)") {
                    $jqUrl = $matches[1]
                    break
                }
            }
        }

        Write-Message "  Downloading jq from: $jqUrl" "Gray"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls
        Invoke-WebRequest -Uri $jqUrl -OutFile $jqPath -UseBasicParsing
        Write-Message "  jq installed successfully" "Gray"
    } catch {
        Write-Message "  WARNING: Failed to download jq: $_" "Yellow"
        Write-Message "  You may need to manually download jq.exe to: $jqPath" "Yellow"
    }

    # Create/Update Windows Task Scheduler task
    Write-Message ""
    Write-Message "Configuring Windows Task Scheduler..." "Green"
    
    $taskName = "Syndicate\SYN Seed"
    $taskXmlPath = Join-Path $SCRIPT_DIR "task.xml"

    # Remove old tasks if they exist
    $oldTaskNames = @("SYN Seed", "Syndicate\SYN Seed")
    foreach ($oldTaskName in $oldTaskNames) {
        try {
            $existingTask = schtasks /Query /TN $oldTaskName 2>$null
            if ($existingTask) {
                Write-Message "  Removing old task: $oldTaskName" "Gray"
                schtasks /Delete /TN $oldTaskName /F | Out-Null
            }
        } catch {
            # Task doesn't exist, ignore
        }
    }

    # Create new task
    try {
        Write-Message "  Creating scheduled task: $taskName" "Gray"
        
        # schtasks requires UTF-16LE encoding with BOM
        # Read the XML and convert it to the correct encoding
        $xmlContent = Get-Content -Path $taskXmlPath -Raw -Encoding UTF8
        $tempXmlPath = Join-Path $env:TEMP "task_scheduler_temp.xml"
        
        # Save with UTF-16LE encoding (which schtasks requires)
        $utf16Encoding = New-Object System.Text.UnicodeEncoding $false, $true
        [System.IO.File]::WriteAllText($tempXmlPath, $xmlContent, $utf16Encoding)
        
        # Create the task using the properly encoded file
        $result = schtasks /Create /XML $tempXmlPath /TN $taskName /F 2>&1
        $exitCode = $LASTEXITCODE
        
        # Clean up temp file
        Remove-Item -Path $tempXmlPath -Force -ErrorAction SilentlyContinue
        
        if ($exitCode -ne 0) {
            # If schtasks fails, try PowerShell method
            Write-Message "  schtasks failed, trying PowerShell method..." "Yellow"
            
            $action = New-ScheduledTaskAction -Execute (Join-Path $INSTALL_PATH "script.bat") -WorkingDirectory $INSTALL_PATH
            $trigger = New-ScheduledTaskTrigger -Daily -At "12:00AM"
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
            
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
            Write-Message "  Task created successfully (PowerShell method)" "Gray"
        } else {
            Write-Message "  Task created successfully" "Gray"
        }
    } catch {
        Write-Message "  ERROR: Failed to create scheduled task: $_" "Red"
        Write-Message "  You may need to manually create the task in Task Scheduler" "Yellow"
    }

    Write-Message ""
    Write-Message "========================================" "Cyan"
    Write-Message "Installation Complete!" "Cyan"
    Write-Message "========================================" "Cyan"
    Write-Message ""
    Write-Message "Installation location: $INSTALL_PATH" "Green"
    Write-Message ""
    Write-Message "Next steps:" "Yellow"
    Write-Message "1. Edit config.txt if you're using Epic Games launcher (change LAUNCHER=Steam to LAUNCHER=epic)" "White"
    Write-Message "2. Verify the scheduled task 'Syndicate\SYN Seed' in Task Scheduler" "White"
    Write-Message "3. The script will run automatically according to the schedule" "White"
    
    if (-not $Silent) {
        Read-Host "Press Enter to exit"
    }
}

# Uninstall function
function Uninstall-SYNSeedScript {
    Write-Message "========================================" "Cyan"
    Write-Message "SYN Seed Script Uninstaller" "Cyan"
    Write-Message "========================================" "Cyan"
    Write-Message ""

    # Remove scheduled tasks
    Write-Message "Removing scheduled tasks..." "Green"
    $taskNames = @("SYN Seed", "Syndicate\SYN Seed")
    foreach ($taskName in $taskNames) {
        try {
            $existingTask = schtasks /Query /TN $taskName 2>$null
            if ($existingTask) {
                Write-Message "  Removing task: $taskName" "Gray"
                schtasks /Delete /TN $taskName /F | Out-Null
                Write-Message "  Task removed successfully" "Gray"
            }
        } catch {
            # Task doesn't exist, ignore
        }
    }

    # Remove installation directory
    if (Test-Path $INSTALL_PATH) {
        if (-not $Silent) {
            $response = Read-Host "Do you want to remove the installation directory '$INSTALL_PATH'? (Y/N)"
            if ($response -eq "Y" -or $response -eq "y") {
                Write-Message "Removing installation directory..." "Green"
                Remove-Item -Path $INSTALL_PATH -Recurse -Force
                Write-Message "Installation directory removed" "Green"
            } else {
                Write-Message "Installation directory kept" "Yellow"
            }
        } else {
            Write-Message "Removing installation directory..." "Green"
            Remove-Item -Path $INSTALL_PATH -Recurse -Force -ErrorAction SilentlyContinue
            Write-Message "Installation directory removed" "Green"
        }
    } else {
        Write-Message "Installation directory not found" "Yellow"
    }

    Write-Message ""
    Write-Message "========================================" "Cyan"
    Write-Message "Uninstallation Complete!" "Green"
    Write-Message "========================================" "Cyan"
    Write-Message ""
    
    if (-not $Silent) {
        Read-Host "Press any key to exit"
    }
}

# Main execution
try {
    if ($Uninstall) {
        Uninstall-SYNSeedScript
    } else {
        Install-SYNSeedScript
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if (-not $Silent) {
        Read-Host "Press Enter to exit"
    }
    exit 1
}
