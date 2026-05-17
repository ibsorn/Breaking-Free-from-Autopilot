# Phase 9: Hosts File Watchdog Installation Script
# Automatically monitors and restores hosts file blocking entries if Windows modifies them
# Includes automatic UAC elevation

# Auto-elevate to Administrator
if (-NOT ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544")) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Installing Hosts File Watchdog Guardian" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Create hidden directory in ProgramData
$monitorDir = "$env:ProgramData\AutopilotBlock"
if (-not (Test-Path $monitorDir)) {
    New-Item -Path $monitorDir -ItemType Directory -Force | Out-Null
    Write-Host "✓ Created watchdog directory: $monitorDir" -ForegroundColor Green
}

# 2. The watchdog script payload (will be written to disk as-is)
$monitorScriptPath = "$monitorDir\hosts-watchdog.ps1"

# NOTE: Using @' (single quote syntax) so PowerShell doesn't evaluate variables now,
# but instead writes them literally to the target file where they'll be evaluated at runtime.
$monitorPayload = @'
$hostsPath = "$env:windir\System32\drivers\etc\hosts"
$logPath = "$env:ProgramData\AutopilotBlock\watchdog.log"

$requiredEntries = @(
    "ztd.desktop.microsoft.com", "cs.dds.microsoft.com",
    "enterpriseregistration.windows.net", "enrollment.manage.microsoft.com",
    "api.intune.microsoft.com", "portal.manage.microsoft.com",
    "dsirnpus.microsoft.com", "dc.services.visualstudio.com",
    "management.azure.com"
)

# FAILURE SCENARIO 1: If Windows or antivirus has completely deleted the hosts file, recreate it
if (-not (Test-Path $hostsPath)) {
    New-Item -Path $hostsPath -ItemType File -Force | Out-Null
}

# Read file content (SilentlyContinue prevents crash if file is empty or unreadable)
$hostsContent = Get-Content $hostsPath -Raw -ErrorAction SilentlyContinue
$missing = @()

# Check each required entry using regex escape to handle dots literally (not as wildcards)
foreach ($entry in $requiredEntries) {
    if (-not ($hostsContent -match [regex]::Escape($entry))) {
        $missing += $entry
    }
}

# If any entries are missing, restore them immediately
if ($missing.Count -gt 0) {
    try {
        # Temporarily remove read-only flag to allow modification
        $hostsFile = Get-Item $hostsPath
        if ($hostsFile.IsReadOnly) { 
            $hostsFile.IsReadOnly = $false 
        }

        # Restore missing entries (ASCII is the official network standard for hosts file)
        Add-Content -Path $hostsPath -Value "`n# Autopilot/MDM Block (Restored by Watchdog)" -Encoding ASCII
        foreach ($entry in $missing) {
            Add-Content -Path $hostsPath -Value "0.0.0.0 $entry" -Encoding ASCII
        }
        
        # Re-apply read-only protection
        $hostsFile.IsReadOnly = $true

        # Log the restoration event
        Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ALERT: Hosts file modified. Restored entries: $($missing -join ', ')"
    } catch {
        # Log any errors for troubleshooting
        Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - CRITICAL ERROR: $_"
    }
}
'@

# Write the watchdog script to disk (UTF8 is safe for PowerShell scripts)
$monitorPayload | Out-File -FilePath $monitorScriptPath -Encoding utf8 -Force
Write-Host "✓ Watchdog script created: $monitorScriptPath" -ForegroundColor Green
Write-Host ""

# 3. Create the Scheduled Task
Write-Host "[1/2] Registering Scheduled Task..." -ForegroundColor Yellow
$taskName = "Autopilot-Hosts-Watchdog"

# Remove existing task if it exists
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# Task action: Run PowerShell script silently
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$monitorScriptPath`""

# Task trigger: Run every hour, indefinitely
# FAILURE SCENARIO 2: Using RepetitionDuration to prevent Windows from automatically expiring the task
$trigger = New-ScheduledTaskTrigger `
    -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Hours 1) `
    -RepetitionDuration (New-TimeSpan -Days 3650)  # Active for 10 years without expiration

# NT AUTHORITY\SYSTEM is universal and language-independent (works in Spanish, English, etc.)
$principal = New-ScheduledTaskPrincipal `
    -UserId "NT AUTHORITY\SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

# Register the task
try {
    Register-ScheduledTask `
        -TaskName $taskName `
        -Description "Monitors and automatically restores Autopilot/MDM blocking entries in the hosts file if Windows modifies them." `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Force | Out-Null
    Write-Host "✓ Scheduled task registered successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to register scheduled task: $_" -ForegroundColor Red
    exit
}

Write-Host ""

# 4. Verify the task was created
Write-Host "[2/2] Verifying task installation..." -ForegroundColor Yellow
try {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "✓ Task verified: $($task.TaskName)" -ForegroundColor Green
        Write-Host "  Status: $($task.State)" -ForegroundColor Green
        Write-Host "  Run frequency: Every 1 hour" -ForegroundColor Green
        Write-Host "  Privilege level: SYSTEM (Highest)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Task verification failed" -ForegroundColor Orange
    }
} catch {
    Write-Host "⚠ Could not verify task: $_" -ForegroundColor Orange
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Phase 9 Installation Complete!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Watchdog Details:" -ForegroundColor Green
Write-Host "  ✓ Script location: $monitorScriptPath" -ForegroundColor Green
Write-Host "  ✓ Log location: $monitorDir\watchdog.log" -ForegroundColor Green
Write-Host "  ✓ Check interval: Every 1 hour" -ForegroundColor Green
Write-Host "  ✓ Restoration time: Within 60 minutes of Windows tampering" -ForegroundColor Green
Write-Host ""
Write-Host "The watchdog will now silently monitor and protect your hosts file." -ForegroundColor Cyan
Write-Host "You will never see it running - it works invisibly in the background." -ForegroundColor Cyan
Write-Host "To verify it's working, check: $monitorDir\watchdog.log" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
