# SYN Seed Script Uninstaller
# PowerShell-based uninstaller

param(
    [switch]$Silent
)

$ErrorActionPreference = "Continue"

$INSTALL_DIR = "hll-seq-seed"
$INSTALL_PATH = Join-Path $env:USERPROFILE $INSTALL_DIR

function Write-Message {
    param([string]$Message, [string]$Color = "White")
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Remove-InstallationDirectory {
    param(
        [string]$Path,
        [switch]$Silent
    )
    
    $maxRetries = 3
    $retryDelay = 2
    
    # First, try to close any handles to files in the directory using handle.exe if available
    # or use PowerShell to find processes
    Write-Message "  Checking for processes using files..." "Gray"
    
    # Try to find processes that might have files open
    $lockedFiles = @()
    try {
        $items = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            try {
                # Try to open the file exclusively to see if it's locked
                $fileStream = [System.IO.File]::Open($item.FullName, 'Open', 'ReadWrite', 'None')
                $fileStream.Close()
            } catch {
                $lockedFiles += $item
            }
        }
    } catch {
        # Ignore errors during check
    }
    
    if ($lockedFiles.Count -gt 0) {
        Write-Message "  Found $($lockedFiles.Count) file(s) that may be locked" "Yellow"
        Write-Message "  Waiting a moment for Windows Defender or other processes to release files..." "Yellow"
        Start-Sleep -Seconds 3
    }
    
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            # Try to stop any processes that might be using files in the directory
            if ($attempt -gt 1) {
                Write-Message "  Attempt $attempt of $maxRetries - Checking for locked files..." "Yellow"
                
                # Try to find and stop processes using files in the directory
                $processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
                    try {
                        $_.Path -like "$Path*"
                    } catch {
                        $false
                    }
                }
                
                if ($processes) {
                    Write-Message "  Stopping processes that may be using files..." "Yellow"
                    $processes | Stop-Process -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                }
            }
            
            # Try to remove the directory
            $null = Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Message "Installation directory removed successfully" "Green"
            return
        } catch {
            $errorMessage = $_.Exception.Message
            
            if ($attempt -lt $maxRetries) {
                Write-Message "  Some files may be in use. Retrying in $retryDelay seconds..." "Yellow"
                Start-Sleep -Seconds $retryDelay
            } else {
                # Final attempt failed - try to remove files individually
                Write-Message "  Standard removal failed. Attempting individual file removal..." "Yellow"
                
                try {
                    # Get all items in the directory
                    $items = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
                    
                    # Remove files first (reverse order to handle dependencies)
                    $files = $items | Where-Object { -not $_.PSIsContainer } | Sort-Object FullName -Descending
                    foreach ($file in $files) {
                        try {
                            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                        } catch {
                            Write-Message "  Could not remove: $($file.Name)" "Yellow"
                            Write-Message "    This file may be locked by Windows Defender or another process." "Yellow"
                            Write-Message "    You may need to manually delete it or restart your computer." "Yellow"
                        }
                    }
                    
                    # Remove directories
                    $dirs = $items | Where-Object { $_.PSIsContainer } | Sort-Object FullName -Descending
                    foreach ($dir in $dirs) {
                        try {
                            Remove-Item -Path $dir.FullName -Force -ErrorAction Stop
                        } catch {
                            # Directory might not be empty, ignore
                        }
                    }
                    
                    # Try to remove the root directory
                    try {
                        Remove-Item -Path $Path -Force -ErrorAction Stop
                        Write-Message "Installation directory removed (some files may have been skipped)" "Green"
                    } catch {
                        Write-Message "  WARNING: Could not fully remove installation directory" "Yellow"
                        Write-Message "  Remaining files may need to be removed manually" "Yellow"
                        Write-Message "  Location: $Path" "Yellow"
                        
                        if (-not $Silent) {
                            Write-Message ""
                            Write-Message "Common causes:" "Yellow"
                            Write-Message "  - Windows Defender is scanning the file" "White"
                            Write-Message "  - Another process has the file open" "White"
                            Write-Message "  - File permissions issue" "White"
                            Write-Message ""
                            Write-Message "You can try:" "Yellow"
                            Write-Message "  1. Restart your computer and delete the folder manually" "White"
                            Write-Message "  2. Temporarily disable Windows Defender real-time protection" "White"
                            Write-Message "  3. Use 'Take Ownership' and delete manually" "White"
                        }
                    }
                } catch {
                    Write-Message "  ERROR: Failed to remove installation directory: $errorMessage" "Red"
                    Write-Message "  You may need to manually delete: $Path" "Yellow"
                }
            }
        }
    }
}

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

# Remove Task Scheduler folder if it exists and is empty
Write-Message ""
Write-Message "Removing Task Scheduler folder..." "Green"
try {
    # Use COM object to access Task Scheduler
    $service = New-Object -ComObject Schedule.Service
    $service.Connect()
    $rootFolder = $service.GetFolder("\")
    
    try {
        $folder = $rootFolder.GetFolder("Syndicate")
        $tasks = $folder.GetTasks(0)
        
        if ($tasks.Count -eq 0) {
            Write-Message "  Removing empty folder: Syndicate" "Gray"
            $rootFolder.DeleteFolder("Syndicate", $null)
            Write-Message "  Folder removed successfully" "Gray"
        } else {
            Write-Message "  Folder contains $($tasks.Count) other task(s), keeping it" "Gray"
        }
    } catch {
        # Folder doesn't exist or already removed
        Write-Message "  Task Scheduler folder 'Syndicate' not found or already removed" "Gray"
    }
} catch {
    # Fallback: Try using PowerShell cmdlets
    try {
        $tasksInFolder = Get-ScheduledTask -TaskPath "\Syndicate\" -ErrorAction SilentlyContinue
        if ($tasksInFolder -and $tasksInFolder.Count -eq 0) {
            Write-Message "  Folder is empty but cannot be removed automatically" "Yellow"
            Write-Message "  You can manually remove it from Task Scheduler if desired" "Yellow"
        } elseif ($tasksInFolder -and $tasksInFolder.Count -gt 0) {
            Write-Message "  Folder contains other tasks, keeping it" "Gray"
        } else {
            Write-Message "  Task Scheduler folder 'Syndicate' not found or already removed" "Gray"
        }
    } catch {
        Write-Message "  Could not access Task Scheduler to remove folder (this is okay)" "Yellow"
    }
}

    # Remove installation directory
    if (Test-Path $INSTALL_PATH) {
        if (-not $Silent) {
            $response = Read-Host "Do you want to remove the installation directory '$INSTALL_PATH'? (Y/N)"
            if ($response -eq "Y" -or $response -eq "y") {
                Write-Message "Removing installation directory..." "Green"
                Remove-InstallationDirectory -Path $INSTALL_PATH
            } else {
                Write-Message "Installation directory kept" "Yellow"
            }
        } else {
            Write-Message "Removing installation directory..." "Green"
            Remove-InstallationDirectory -Path $INSTALL_PATH -Silent
        }
    } else {
        Write-Message "Installation directory not found" "Yellow"
    }

Write-Message ""
Write-Message "========================================" "Cyan"

# Check if installation directory still exists
if (Test-Path $INSTALL_PATH) {
    Write-Message "Uninstallation completed with warnings" "Yellow"
    Write-Message "Some files could not be removed (see messages above)" "Yellow"
} else {
    Write-Message "Uninstallation Complete!" "Green"
}

Write-Message "========================================" "Cyan"
Write-Message ""

if (-not $Silent) {
    Read-Host "Press Enter to exit"
}
