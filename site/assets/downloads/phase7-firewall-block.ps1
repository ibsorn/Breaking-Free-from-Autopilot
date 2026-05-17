# Phase 8: Automated MDM Process Firewall Blocking Script
# This script creates outbound firewall rules to block MDM and enrollment executables
# Includes automatic UAC elevation

# Auto-elevate to Administrator
if (-NOT ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544")) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Phase 8: Firewall-Based MDM Process Blocking" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# List of Windows System32 executables responsible for Autopilot/Intune/Entra ID enrollment
$mdmProcesses = @(
    @{
        Path = "$env:windir\System32\deviceenroller.exe"
        Description = "Blocks device enrollment agent communication"
    },
    @{
        Path = "$env:windir\System32\omadmclient.exe"
        Description = "Blocks MDM policy download and management"
    },
    @{
        Path = "$env:windir\System32\dsregcmd.exe"
        Description = "Blocks Azure AD / Entra ID binding"
    },
    @{
        Path = "$env:windir\System32\ProvTool.exe"
        Description = "Blocks provisioning package installation"
    }
)

Write-Host "Creating outbound firewall rules for MDM processes..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$skippedCount = 0

foreach ($process in $mdmProcesses) {
    # Extract only the filename for the rule label
    $fileName = Split-Path $process.Path -Leaf
    $ruleName = "Block-Autopilot-Process-$fileName"
    
    # Verify if the executable exists on this system
    if (Test-Path $process.Path) {
        # Check if the rule already exists
        $existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        
        if (-not $existing) {
            try {
                New-NetFirewallRule `
                    -DisplayName $ruleName `
                    -Description $process.Description `
                    -Direction Outbound `
                    -Action Block `
                    -Program $process.Path `
                    -Enabled True `
                    -Profile Any | Out-Null
                Write-Host "✓ Rule created and blocking: $fileName" -ForegroundColor Green
                $successCount++
            } catch {
                Write-Host "✗ Failed to create rule for $fileName : $_" -ForegroundColor Red
            }
        } else {
            Write-Host "⚠ Rule already exists for: $fileName" -ForegroundColor Yellow
            $successCount++
        }
    } else {
        Write-Host "ℹ Process not found (already removed or not applicable): $fileName" -ForegroundColor DarkGray
        $skippedCount++
    }
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Phase 8 Complete!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Green
Write-Host "  ✓ Firewall rules created/verified: $successCount" -ForegroundColor Green
Write-Host "  ℹ Processes skipped (not found): $skippedCount" -ForegroundColor DarkGray
Write-Host ""
Write-Host "MDM engines have been isolated at the firewall level." -ForegroundColor Cyan
Write-Host "Even if enrollment executables try to connect, they will be blocked." -ForegroundColor Cyan
Write-Host ""

# Optional: Verify and display the created rules
Write-Host "Verification - Current firewall rules:" -ForegroundColor Yellow
Write-Host ""
$rules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Block-Autopilot-Process*"}
if ($rules) {
    $rules | Select-Object DisplayName, Enabled, Direction, Action | Format-Table -AutoSize
} else {
    Write-Host "No rules found. This may indicate the script didn't complete successfully." -ForegroundColor Orange
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
