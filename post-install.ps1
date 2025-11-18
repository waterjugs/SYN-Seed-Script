# Post-installation script for Inno Setup installer
# This script runs after files are copied to handle jq installation and task scheduling

$ErrorActionPreference = "Stop"

$INSTALL_PATH = Join-Path $env:USERPROFILE "hll-seq-seed"
$jqDir = Join-Path $INSTALL_PATH "jq"
$jqPath = Join-Path $jqDir "jq.exe"

# Create jq directory
if (-not (Test-Path $jqDir)) {
    New-Item -ItemType Directory -Path $jqDir -Force | Out-Null
}

# Install jq
if (-not (Test-Path $jqPath)) {
    $jqUrl = "https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe"
    
    # Try to read from config.txt
    $configPath = Join-Path $INSTALL_PATH "config.txt"
    if (Test-Path $configPath) {
        $configContent = Get-Content $configPath
        foreach ($line in $configContent) {
            if ($line -match "JQ_URL=(.+)") {
                $jqUrl = $matches[1]
                break
            }
        }
    }
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls
        Invoke-WebRequest -Uri $jqUrl -OutFile $jqPath -UseBasicParsing
    } catch {
        # Silent failure - user can manually download if needed
    }
}

# Remove old tasks
$oldTaskNames = @("SYN Seed", "Syndicate\SYN Seed")
foreach ($oldTaskName in $oldTaskNames) {
    try {
        schtasks /Delete /TN $oldTaskName /F 2>$null | Out-Null
    } catch {
        # Ignore errors
    }
}

# Create new scheduled task
$taskXmlPath = Join-Path $INSTALL_PATH "task.xml"
$taskName = "Syndicate\SYN Seed"

if (Test-Path $taskXmlPath) {
    $xmlContent = Get-Content -Path $taskXmlPath -Raw -Encoding UTF8
    try {
        # schtasks requires UTF-16LE encoding with BOM
        $tempXmlPath = Join-Path $env:TEMP "task_scheduler_temp.xml"
        
        # Save with UTF-16LE encoding (which schtasks requires)
        $utf16Encoding = New-Object System.Text.UnicodeEncoding $false, $true
        [System.IO.File]::WriteAllText($tempXmlPath, $xmlContent, $utf16Encoding)
        
        # Create the task using the properly encoded file
        schtasks /Create /XML $tempXmlPath /TN $taskName /F 2>$null | Out-Null
        
        # Clean up temp file
        if (Test-Path $tempXmlPath) {
            Remove-Item -Path $tempXmlPath -Force -ErrorAction SilentlyContinue
        }
    } catch {
        # Try PowerShell method as fallback
        try {
            $xml = [xml]$xmlContent
            $taskPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
            
            # Map XML settings to PowerShell settings
            $taskSettings = New-ScheduledTaskSettingsSet `
                -AllowStartIfOnBatteries `
                -StopIfGoingOnBatteries `
                -StartWhenAvailable:$false `
                -WakeToRun `
                -MultipleInstances Parallel `
                -ExecutionTimeLimit ([TimeSpan]::Zero) `
                -Priority 7
            
            $startBoundary = $xml.Task.Triggers.CalendarTrigger.StartBoundary
            $trigger = New-ScheduledTaskTrigger -Daily -At $startBoundary
            
            $command = $xml.Task.Actions.Exec.Command -replace '%USERPROFILE%', $env:USERPROFILE
            $workingDir = $xml.Task.Actions.Exec.WorkingDirectory -replace '%USERPROFILE%', $env:USERPROFILE
            
            # For batch files, use cmd.exe to execute
            if ($command -match '\.bat$') {
                $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$command`"" -WorkingDirectory $workingDir
            } else {
                $action = New-ScheduledTaskAction -Execute $command -WorkingDirectory $workingDir
            }
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $taskSettings -Principal $taskPrincipal -Force | Out-Null
        } catch {
            # Silent failure
        }
    }
}
