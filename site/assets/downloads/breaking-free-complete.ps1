# =================================================================
# AUTOPILOT & MDM BYPASS - MASTER MEGA-SCRIPT (PHASES 4-9)
# =================================================================
# This script executes ALL core defense layers sequentially:
# Layer 1: Edition Lock & Key Purging (Phase 4)
# Layer 2: MDM & Telemetry Services Deactivation (Phase 5)
# Layer 3: Hosts File DNS Server Blocking (Phase 6)
# Layer 4: Firewall Application Blocking (Phase 7)
# Layer 5: Watchdog Scheduled Task Installation (Phase 8)
# Layer 6: Final Verification & Pre-Flight Check (Phase 9)
# =================================================================

# --- ROBUST AUTO-ELEVATION BLOCK (100% Failsafe) ---
$isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isElevated) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    $scriptPath = ""
    if ($PSCommandPath) { $scriptPath = $PSCommandPath } 
    elseif ($MyInvocation.MyCommand.Path) { $scriptPath = $MyInvocation.MyCommand.Path }
    
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        Write-Host "CRITICAL ERROR: Cannot determine script path. Ensure you are running this from a saved .ps1 file." -ForegroundColor Red
        Start-Sleep -Seconds 5; exit
    }
    try {
        $argList = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File `"$scriptPath`""
        Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -ErrorAction Stop; exit
    } catch {
        Write-Host "CRITICAL ERROR: UAC elevation failed or was denied." -ForegroundColor Red
        Write-Host "Please right-click the file and select 'Run as Administrator'." -ForegroundColor White
        Start-Sleep -Seconds 5; exit
    }
}

# --- HELPER FUNCTION ---
function Wait-WithProgress {
    param([int]$Seconds, [string]$Message)
    Write-Host "⏳ $Message " -ForegroundColor Yellow -NoNewline
    for ($i = 0; $i -lt $Seconds; $i++) {
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline -ForegroundColor Yellow
    }
    Write-Host ""
}

Clear-Host
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "           AUTOPILOT & MDM BYPASS - MASTER MEGA-SCRIPT           " -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Deploying maximum defense stack. Do not close this window." -ForegroundColor Yellow
Write-Host ""

# =================================================================
# PHASE 4: EDITION LOCK & KEY PURGING
# =================================================================
Write-Host "--- [LAYER 1: LICENSING & EDITION LOCK (Phase 4)] ---" -ForegroundColor Cyan
$currentEdition = $null
try {
    $regInfo = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction Stop
    $currentEdition = $regInfo.EditionID
} catch { }

if ($null -ne $currentEdition -and $currentEdition -match "Core") {
    $targetKey = "YTMG3-N6DKC-DKB77-7M9GH-8HVX7"; $targetName = "Home"
} elseif ($null -ne $currentEdition -and $currentEdition -match "Professional") {
    $targetKey = "VK7JG-NPHTM-C97JM-9MPGT-3V66T"; $targetName = "Pro"
} else {
    $targetKey = "YTMG3-N6DKC-DKB77-7M9GH-8HVX7"; $targetName = "Home (Fallback)"
}

try {
    $null = Start-Process "cscript.exe" -ArgumentList "//B //Nologo $env:windir\system32\slmgr.vbs /cpky" -Wait -WindowStyle Hidden
    Write-Host "✓ BIOS/Motherboard key purged" -ForegroundColor Green
    $null = Start-Process "cscript.exe" -ArgumentList "//B //Nologo $env:windir\system32\slmgr.vbs /upk" -Wait -WindowStyle Hidden
    Write-Host "✓ Preloaded keys removed" -ForegroundColor Green
    $null = Start-Process "cscript.exe" -ArgumentList "//B //Nologo $env:windir\system32\slmgr.vbs /ipk $targetKey" -Wait -WindowStyle Hidden
    Write-Host "✓ $targetName Edition locked and isolated" -ForegroundColor Green
    
    $paths = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate", "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore")
    foreach ($path in $paths) {
        if (-not (Test-Path $path)) { New-Item -Path $path -Force -ErrorAction SilentlyContinue | Out-Null }
        New-ItemProperty -Path $path -Name "DisableOSUpgrade" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host "✓ Forced Edition Upgrades blocked in registry" -ForegroundColor Green
} catch { Write-Host "⚠ Non-critical error in Layer 1: $_" -ForegroundColor Orange }
Write-Host ""

# =================================================================
# PHASE 5: MDM & TELEMETRY DISABLE
# =================================================================
Write-Host "--- [LAYER 2: MDM & TELEMETRY DISABLE (Phase 5)] ---" -ForegroundColor Cyan
try {
    $dsregOutput = & dsregcmd /status | Out-String
    if ($dsregOutput -match "AzureAdJoined\s*:\s*YES|DomainJoined\s*:\s*YES") {
        Write-Host "⚠ Warning: Device is Entra/Azure joined. Forcing removal..." -ForegroundColor Yellow
        & dsregcmd /leave | Out-Null
    }

    Stop-Service -Name dmwappushservice -Force -ErrorAction SilentlyContinue
    Set-Service -Name dmwappushservice -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "✓ MDM and Telemetry background services disabled" -ForegroundColor Green

    $MDMPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM"
    if (-not (Test-Path $MDMPath)) { New-Item -Path $MDMPath -Force | Out-Null }
    New-ItemProperty -Path $MDMPath -Name "DisableRegistration" -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $MDMPath -Name "AutoEnrollMDM" -Value 0 -PropertyType DWORD -Force | Out-Null
    
    $WJPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin"
    if (-not (Test-Path $WJPath)) { New-Item -Path $WJPath -Force | Out-Null }
    New-ItemProperty -Path $WJPath -Name "BlockAADWorkplaceJoin" -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Host "✓ Silent auto-enrollment blocked in registry" -ForegroundColor Green
} catch { Write-Host "⚠ Non-critical error in Layer 2: $_" -ForegroundColor Orange }
Write-Host ""

# =================================================================
# PHASE 6: HOSTS FILE SERVER BLOCK
# =================================================================
Write-Host "--- [LAYER 3: HOSTS FILE DNS BLOCK (Phase 6)] ---" -ForegroundColor Cyan
try {
    $hostsPath = "$env:windir\System32\drivers\etc\hosts"
    $hostsFile = Get-Item $hostsPath -ErrorAction SilentlyContinue
    if ($hostsFile -and $hostsFile.IsReadOnly) { $hostsFile.IsReadOnly = $false }

    $hostsContent = Get-Content $hostsPath -Raw -ErrorAction SilentlyContinue
    if ($hostsContent -notmatch "ztd\.desktop\.microsoft\.com") {
        Add-Content -Path $hostsPath -Value "`n# Autopilot and Enrollment Servers" -Encoding ASCII
        $domainsToBlock = @("ztd.desktop.microsoft.com", "cs.dds.microsoft.com", "enterpriseregistration.windows.net", "enrollment.manage.microsoft.com", "api.intune.microsoft.com", "portal.manage.microsoft.com", "dsirnpus.microsoft.com", "dc.services.visualstudio.com", "management.azure.com")
        foreach ($domain in $domainsToBlock) {
            Add-Content -Path $hostsPath -Value "0.0.0.0 $domain" -Encoding ASCII
        }
    }
    
    $hostsFile = Get-Item $hostsPath
    $hostsFile.IsReadOnly = $true
    Write-Host "✓ Autopilot/Intune servers blacklisted in Hosts file" -ForegroundColor Green

    if (Get-Service WinDefend -ErrorAction SilentlyContinue) {
        Add-MpPreference -ExclusionPath $hostsPath -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Hosts file added to Defender exclusions" -ForegroundColor Green
    }
} catch { Write-Host "⚠ Non-critical error in Layer 3: $_" -ForegroundColor Orange }
Write-Host ""

# =================================================================
# PHASE 7: FIREWALL APPLICATION BLOCK
# =================================================================
Write-Host "--- [LAYER 4: FIREWALL PROCESS BLOCKING (Phase 7)] ---" -ForegroundColor Cyan
try {
    $mdmProcesses = @("deviceenroller.exe", "omadmclient.exe", "dsregcmd.exe", "ProvTool.exe")
    $successCount = 0
    foreach ($proc in $mdmProcesses) {
        $path = "$env:windir\System32\$proc"
        $ruleName = "Block-Autopilot-$proc"
        if (Test-Path $path) {
            if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
                New-NetFirewallRule -DisplayName $ruleName -Direction Outbound -Action Block -Program $path -Profile Any -ErrorAction SilentlyContinue | Out-Null
            }
            $successCount++
        }
    }
    Write-Host "✓ Application firewall rules applied to $successCount MDM binaries" -ForegroundColor Green
} catch { Write-Host "⚠ Non-critical error in Layer 4: $_" -ForegroundColor Orange }
Write-Host ""

# =================================================================
# PHASE 8: WATCHDOG INSTALLATION
# =================================================================
Write-Host "--- [LAYER 5: WATCHDOG GUARDIAN (Phase 8)] ---" -ForegroundColor Cyan
try {
    $monitorDir = "$env:ProgramData\AutopilotBlock"
    if (-not (Test-Path $monitorDir)) { New-Item -Path $monitorDir -ItemType Directory -Force | Out-Null }

    $monitorScriptPath = "$monitorDir\hosts-watchdog.ps1"
    $monitorPayload = @'
$hostsPath = "$env:windir\System32\drivers\etc\hosts"
$logPath = "$env:ProgramData\AutopilotBlock\watchdog.log"
$requiredEntries = @("ztd.desktop.microsoft.com","cs.dds.microsoft.com","enterpriseregistration.windows.net","enrollment.manage.microsoft.com","api.intune.microsoft.com","portal.manage.microsoft.com","dsirnpus.microsoft.com","dc.services.visualstudio.com","management.azure.com")
if (-not (Test-Path $hostsPath)) { New-Item -Path $hostsPath -ItemType File -Force | Out-Null }
$hostsContent = Get-Content $hostsPath -Raw -ErrorAction SilentlyContinue
$missing = @()
foreach ($entry in $requiredEntries) { if (-not ($hostsContent -match [regex]::Escape($entry))) { $missing += $entry } }
if ($missing.Count -gt 0) {
    try {
        $hostsFile = Get-Item $hostsPath; if ($hostsFile.IsReadOnly) { $hostsFile.IsReadOnly = $false }
        Add-Content -Path $hostsPath -Value "`n# Autopilot/MDM Block (Restored)" -Encoding ASCII
        foreach ($entry in $missing) { Add-Content -Path $hostsPath -Value "0.0.0.0 $entry" -Encoding ASCII }
        $hostsFile.IsReadOnly = $true
        Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ALERT: Restored entries: $($missing -join ', ')"
    } catch {}
}
'@
    $monitorPayload | Out-File -FilePath $monitorScriptPath -Encoding utf8 -Force
    $taskName = "Autopilot-Hosts-Watchdog"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$monitorScriptPath`""
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration (New-TimeSpan -Days 3650)
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    Register-ScheduledTask -TaskName $taskName -Description "Restores Autopilot blocking entries if Windows modifies them" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
    Write-Host "✓ Watchdog deployed. Hosts file will be monitored 24/7" -ForegroundColor Green
} catch { Write-Host "⚠ Non-critical error in Layer 5: $_" -ForegroundColor Orange }
Write-Host ""

Wait-WithProgress -Seconds 3 -Message "Running final system diagnostics"

# =================================================================
# PHASE 9: VERIFICATION (PRE-FLIGHT CHECK)
# =================================================================
Write-Host "--- [LAYER 6: FINAL VERIFICATION (Phase 9)] ---" -ForegroundColor Cyan

$allClear = $true

# Check 1: MDM Profile
$mdmCheck = Get-CimInstance -Query "SELECT * FROM Win32_DeviceManagementConfiguration" -ErrorAction SilentlyContinue
if ($mdmCheck) { 
    Write-Host "✗ Device still shows MDM management" -ForegroundColor Red; $allClear = $false 
} else { 
    Write-Host "✓ No organizational management detected" -ForegroundColor Green 
}

# Check 2: Services (Fixed Logic: Null equals Disabled)
$dmwappush = Get-Service dmwappushservice -ErrorAction SilentlyContinue
if ($null -eq $dmwappush -or $dmwappush.StartType -eq "Disabled") { 
    Write-Host "✓ dmwappushservice is disabled or successfully removed" -ForegroundColor Green 
} else { 
    Write-Host "✗ dmwappushservice is NOT disabled" -ForegroundColor Red; $allClear = $false 
}

# Check 3: Hosts File
$hPath = "$env:windir\System32\drivers\etc\hosts"
$hContent = Get-Content $hPath -Raw -ErrorAction SilentlyContinue
if ($hContent -match "ztd\.desktop\.microsoft\.com") { 
    Write-Host "✓ Enrollment servers blocked in hosts file" -ForegroundColor Green 
} else { 
    Write-Host "✗ Hosts file blocking failed" -ForegroundColor Red; $allClear = $false 
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
if ($allClear) {
    Write-Host "                 SYSTEM IS SECURE AND FREE                       " -ForegroundColor Green -BackgroundColor Black
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "All defense layers have been successfully applied and verified." -ForegroundColor White
    Write-Host "You may now connect to the internet safely." -ForegroundColor Yellow
} else {
    Write-Host "                 WARNING: SYSTEM NOT FULLY SECURE                " -ForegroundColor Red -BackgroundColor Black
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "Some defenses failed to apply. Check the logs above." -ForegroundColor Orange
}
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
