# Phase 5: Automated MDM Disabling Script
# This script will automatically disable MDM services and block Azure AD enrollment
# Includes automatic UAC elevation

# Auto-elevate to Administrator
if (-NOT ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544")) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Phase 5: Disabling MDM and Telemetry Services" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Pre-check: Verify device is not domain/Azure joined
Write-Host "[Pre-Check] Verifying device enrollment status..." -ForegroundColor Yellow
try {
    $dsregStatus = & dsregcmd /status
    $dsregOutput = $dsregStatus | Out-String
    
    if ($dsregOutput -match "AzureAdJoined\s*:\s*YES|DomainJoined\s*:\s*YES|WorkplaceJoined\s*:\s*YES") {
        Write-Host ""
        Write-Host "⚠  WARNING: Device is currently joined to enterprise (Azure/Domain/MDM)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Attempting to remove enrollment with: dsregcmd /leave" -ForegroundColor Yellow
        & dsregcmd /leave
        Write-Host ""
        Write-Host "✓ Device removed from enterprise enrollment" -ForegroundColor Green
        Write-Host "⚠  A restart is recommended to complete the removal" -ForegroundColor Yellow
        Write-Host ""
        pause
    } else {
        Write-Host "✓ Device is not domain/Azure/workplace joined - proceeding" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Could not verify enrollment status: $_" -ForegroundColor Orange
}

Write-Host ""

# Step 1: Disable dmwappushservice (MDM Enrollment Service)
Write-Host "[1/4] Stopping and disabling dmwappushservice..." -ForegroundColor Yellow
try {
    Stop-Service -Name dmwappushservice -Force -ErrorAction SilentlyContinue
    Set-Service -Name dmwappushservice -StartupType Disabled
    Write-Host "✓ dmwappushservice disabled" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not disable dmwappushservice: $_" -ForegroundColor Orange
}

Write-Host ""

# Step 2: Disable DiagTrack (Windows Telemetry)
Write-Host "[2/4] Stopping and disabling DiagTrack..." -ForegroundColor Yellow
try {
    Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service -Name DiagTrack -StartupType Disabled
    Write-Host "✓ DiagTrack disabled" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not disable DiagTrack: $_" -ForegroundColor Orange
}

Write-Host ""

# Step 3: Block MDM Registration via Registry
Write-Host "[3/4] Blocking MDM registration via Registry..." -ForegroundColor Yellow
try {
    $MDMPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM"
    if (-not (Test-Path $MDMPath)) {
        New-Item -Path $MDMPath -Force | Out-Null
    }
    
    # Bloqueo 1: Evita el registro directo/manual
    New-ItemProperty -Path $MDMPath -Name "DisableRegistration" -Value 1 -PropertyType DWORD -Force | Out-Null
    
    # Bloqueo 2 (NUEVO): Evita el auto-enrolamiento silencioso con credenciales (AutoEnrollMDM)
    New-ItemProperty -Path $MDMPath -Name "AutoEnrollMDM" -Value 0 -PropertyType DWORD -Force | Out-Null
    
    Write-Host "✓ MDM registration and Auto-Enrollment blocked" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not block MDM registration: $_" -ForegroundColor Orange
}

Write-Host ""

# Step 4: Block Azure AD Workplace Join
Write-Host "[4/4] Blocking Azure AD Workplace Join..." -ForegroundColor Yellow
try {
    $WorkplaceJoinPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin"
    if (-not (Test-Path $WorkplaceJoinPath)) {
        New-Item -Path $WorkplaceJoinPath -Force | Out-Null
    }
    New-ItemProperty -Path $WorkplaceJoinPath -Name "BlockAADWorkplaceJoin" -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Host "✓ Azure AD Workplace Join blocked" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not block Azure AD Workplace Join: $_" -ForegroundColor Orange
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Phase 5 Complete!" -ForegroundColor Cyan
Write-Host "All MDM and telemetry services have been disabled." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
