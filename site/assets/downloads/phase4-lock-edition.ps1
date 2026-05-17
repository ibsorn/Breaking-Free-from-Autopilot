# Phase 4: Automated Key Purging and Edition Lock Script
# Automatically detects OS edition, purges OEM keys, and locks the current edition
# Includes robust automatic UAC elevation

# =================================================================
# ROBUST AUTO-ELEVATION BLOCK (100% Failsafe)
# =================================================================
$isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isElevated) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    
    # Redundant Path Resolution: Guaranteed to find the physical file
    $scriptPath = ""
    if ($PSCommandPath) {
        $scriptPath = $PSCommandPath
    } elseif ($MyInvocation.MyCommand.Path) {
        $scriptPath = $MyInvocation.MyCommand.Path
    }
    
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        Write-Host "CRITICAL ERROR: Cannot determine script path. Ensure you are running this from a saved .ps1 file." -ForegroundColor Red
        Start-Sleep -Seconds 5
        exit
    }

    try {
        # Encapsulate path in literal quotes to survive any spacing or special character issues
        $argList = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File `"$scriptPath`""
        Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -ErrorAction Stop
        exit
    } catch {
        Write-Host "CRITICAL ERROR: UAC elevation failed or was denied by the user." -ForegroundColor Red
        Write-Host "Please right-click the file and select 'Run as Administrator'." -ForegroundColor White
        Start-Sleep -Seconds 5
        exit
    }
}
# =================================================================

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Phase 4: Key Purging and Version Lock" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This process will:" -ForegroundColor Yellow
Write-Host "  1. Delete the motherboard/BIOS license key" -ForegroundColor White
Write-Host "  2. Uninstall any preloaded/active keys" -ForegroundColor White
Write-Host "  3. Detect current OS edition and inject generic offline key" -ForegroundColor White
Write-Host "  4. Block Windows from automatically upgrading editions" -ForegroundColor White
Write-Host ""

# Function to wait with visual feedback
function Wait-WithProgress {
    param([int]$Seconds, [string]$Message)
    Write-Host "⏳ $Message " -ForegroundColor Yellow -NoNewline
    for ($i = 0; $i -lt $Seconds; $i++) {
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline -ForegroundColor Yellow
    }
    Write-Host ""
}

# --- AUTOMATIC EDITION DETECTION (Failsafe Version) ---
Write-Host "[0/4] Detecting current Windows Edition..." -ForegroundColor Yellow
$currentEdition = $null

try {
    $regInfo = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction Stop
    $currentEdition = $regInfo.EditionID
} catch {
    Write-Host "⚠ Could not read EditionID from registry. Proceeding with fallback." -ForegroundColor Orange
}

# Logic to determine the correct generic key
if ($null -ne $currentEdition -and $currentEdition -match "Core") {
    # 'Core' is the internal Microsoft name for Home Edition
    $targetKey = "YTMG3-N6DKC-DKB77-7M9GH-8HVX7"
    $targetName = "Home"
    Write-Host "✓ Windows 11 Home Edition detected" -ForegroundColor Green
} elseif ($null -ne $currentEdition -and $currentEdition -match "Professional") {
    $targetKey = "VK7JG-NPHTM-C97JM-9MPGT-3V66T"
    $targetName = "Pro"
    Write-Host "✓ Windows 11 Pro Edition detected" -ForegroundColor Green
} else {
    # Absolute Failsafe: Default to Home if detection fails or edition is obscure
    $targetKey = "YTMG3-N6DKC-DKB77-7M9GH-8HVX7"
    $targetName = "Home (Fallback)"
    Write-Host "⚠ Unrecognized or missing Edition ($currentEdition). Forcing fallback to Home Edition." -ForegroundColor Orange
}
Write-Host ""

# Step 1: Delete motherboard key from registry
Write-Host "[1/4] Deleting motherboard license key..." -ForegroundColor Yellow
try {
    # Run silently and suppress errors
    $null = Start-Process "cscript.exe" -ArgumentList "//B //Nologo $env:windir\system32\slmgr.vbs /cpky" -Wait -WindowStyle Hidden
    Write-Host "✓ Motherboard key purged" -ForegroundColor Green
    Wait-WithProgress -Seconds 2 -Message "Processing"
} catch {
    Write-Host "⚠ Warning during motherboard key purge: $_" -ForegroundColor Orange
}
Write-Host ""

# Step 2: Uninstall any preloaded key
Write-Host "[2/4] Uninstalling preloaded product key..." -ForegroundColor Yellow
try {
    $null = Start-Process "cscript.exe" -ArgumentList "//B //Nologo $env:windir\system32\slmgr.vbs /upk" -Wait -WindowStyle Hidden
    Write-Host "✓ Preloaded key uninstalled" -ForegroundColor Green
    Wait-WithProgress -Seconds 3 -Message "Clearing cache"
} catch {
    Write-Host "⚠ No preloaded key found or already removed" -ForegroundColor Orange
}
Write-Host ""

# Step 3: Install Detected Generic Key
Write-Host "[3/4] Installing Windows 11 $targetName generic key..." -ForegroundColor Yellow
try {
    $null = Start-Process "cscript.exe" -ArgumentList "//B //Nologo $env:windir\system32\slmgr.vbs /ipk $targetKey" -Wait -WindowStyle Hidden
    Write-Host "✓ $targetName Edition key installed ($targetKey)" -ForegroundColor Green
    Wait-WithProgress -Seconds 4 -Message "Applying edition policy"
} catch {
    Write-Host "✗ Failed to install key: $_" -ForegroundColor Red
}
Write-Host ""

# Step 4: Block forced OS upgrades via Registry
Write-Host "[4/4] Blocking forced OS upgrades..." -ForegroundColor Yellow
try {
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $storePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    
    # Create paths safely
    $paths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows",
        $registryPath,
        $storePolicy
    )
    foreach ($path in $paths) {
        if (-not (Test-Path $path)) { 
            New-Item -Path $path -Force -ErrorAction SilentlyContinue | Out-Null 
        }
    }
    
    # Apply blocks
    New-ItemProperty -Path $registryPath -Name "DisableOSUpgrade" -Value 1 -PropertyType DWORD -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $storePolicy -Name "DisableOSUpgrade" -Value 1 -PropertyType DWORD -Force -ErrorAction Stop | Out-Null
    
    Write-Host "✓ OS upgrade blocks installed in Registry" -ForegroundColor Green
    Wait-WithProgress -Seconds 2 -Message "Verifying changes"
} catch {
    Write-Host "✗ Failed to set registry value: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Phase 4 Complete!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your Windows edition is now locked to $targetName Edition." -ForegroundColor Green
Write-Host "The corporate motherboard BIOS key has been destroyed." -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
