# Phase 9: Device Management Verification Script
# This script will verify your device is not under organizational management
# and provide guidance for final setup
# Run as Administrator (recommended but not always required)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Phase 9: Verifying Device Independence" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if device is enrolled in organizational management
Write-Host "[1/3] Checking for organizational device management..." -ForegroundColor Yellow
try {
    # Detect a real MDM enrollment: an enrollment key with EnrollmentState=1 and a provider,
    # or an Azure AD join / MDM URL reported by dsregcmd.
    $mdmEnrolled = $false
    $enrollmentRoot = "HKLM:\SOFTWARE\Microsoft\Enrollments"
    if (Test-Path $enrollmentRoot) {
        foreach ($enrollment in Get-ChildItem $enrollmentRoot -ErrorAction SilentlyContinue) {
            $props = Get-ItemProperty -Path $enrollment.PSPath -ErrorAction SilentlyContinue
            if ($props.EnrollmentState -eq 1 -and $props.ProviderID) { $mdmEnrolled = $true }
        }
    }
    $dsregStatus = & dsregcmd /status 2>$null | Out-String
    if ($dsregStatus -match "AzureAdJoined\s*:\s*YES" -or $dsregStatus -match "MdmUrl\s*:\s*https") { $mdmEnrolled = $true }

    if ($mdmEnrolled) {
        Write-Host "⚠ Device appears to have organizational management active!" -ForegroundColor DarkYellow
        Write-Host "   Please go to Settings > Accounts > Access work or school" -ForegroundColor Yellow
        Write-Host "   and disconnect/remove the work account" -ForegroundColor Yellow
    } else {
        Write-Host "✓ No organizational device management detected" -ForegroundColor Green
    }
} catch {
    Write-Host "✓ Device management check passed" -ForegroundColor Green
}

Write-Host ""

# Verify all Phase 5 protections are in place
Write-Host "[2/3] Verifying Phase 5 protections..." -ForegroundColor Yellow
try {
    $dmwappush = Get-Service dmwappushservice -ErrorAction SilentlyContinue
    $diagTrack = Get-Service DiagTrack -ErrorAction SilentlyContinue
    
    $allGood = $true
    
    # A null service means it was removed entirely, which is equivalent to disabled.
    if ($null -eq $dmwappush -or $dmwappush.StartType -eq "Disabled") {
        Write-Host "✓ dmwappushservice is disabled or removed" -ForegroundColor Green
    } else {
        Write-Host "⚠ dmwappushservice is NOT disabled (status: $($dmwappush.StartType))" -ForegroundColor DarkYellow
        $allGood = $false
    }

    if ($null -eq $diagTrack -or $diagTrack.StartType -eq "Disabled") {
        Write-Host "✓ DiagTrack is disabled or removed" -ForegroundColor Green
    } else {
        Write-Host "⚠ DiagTrack is NOT disabled (status: $($diagTrack.StartType))" -ForegroundColor DarkYellow
        $allGood = $false
    }
    
    if (-not $allGood) {
        Write-Host ""
        Write-Host "Consider running the Phase 5 script to fix these issues." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Could not verify Phase 5 protections: $_" -ForegroundColor DarkYellow
}

Write-Host ""

# Verify Phase 6 protections (hosts file)
Write-Host "[3/3] Verifying Phase 6 protections..." -ForegroundColor Yellow
try {
    $hostsPath = "C:\Windows\System32\drivers\etc\hosts"
    $hostsContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
    
    if ($hostsContent -match "ztd.desktop.microsoft.com") {
        Write-Host "✓ Autopilot servers are blocked in hosts file" -ForegroundColor Green
    } else {
        Write-Host "⚠ Autopilot servers NOT found in hosts file" -ForegroundColor DarkYellow
        Write-Host "   Consider running the Phase 6 script to apply blocking" -ForegroundColor Yellow
    }
    
    $hostsFile = Get-Item $hostsPath
    if ($hostsFile.Attributes -match "ReadOnly") {
        Write-Host "✓ Hosts file is read-only (protected)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Hosts file is NOT read-only (unprotected)" -ForegroundColor DarkYellow
    }
} catch {
    Write-Host "⚠ Could not verify hosts file: $_" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Verification Complete" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps (manual):" -ForegroundColor Cyan
Write-Host "1. Connect to the internet if not already connected" -ForegroundColor White
Write-Host "2. Go to Settings > Accounts > Your info" -ForegroundColor White
Write-Host "3. Sign in with your PERSONAL Microsoft account (NOT work account)" -ForegroundColor White
Write-Host "4. Set up Windows Hello (PIN or biometric) for extra security" -ForegroundColor White
Write-Host "5. When asked 'Allow your organization to manage your device?': Click NO" -ForegroundColor White
Write-Host ""
Write-Host "⚠ CRITICAL RULE:" -ForegroundColor Red
Write-Host "   NEVER click YES to 'Allow organization to manage device'" -ForegroundColor Red
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
