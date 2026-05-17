---
description: Phase 9 - Final connection to internet and safe account setup. After 8 layers of hardware, licensing, and network protection, connect to internet, create personal Microsoft account, and configure Windows Hello as the final step.
keywords: internet connection, account setup, Windows Hello, verification, security checks, final configuration, safe use
---

# Phase 9: Final Connection to Internet and Safe Account Setup

## Overview

You've made it! Your device is now:
- ✅ Free from BIOS-level tracking
- ✅ OS edition locked down (Home or Pro)
- ✅ Enrollment services disabled
- ✅ Enrollment servers blocked

Now it's time to:
1. **Connect to the internet** (finally!)
2. **Set up your personal Microsoft account**
3. **Learn the ONE critical rule** to prevent corporate takeover
4. **Configure Windows Hello** for security

**Time required:** 5-10 minutes

!!! success "All 8 Layers of Defense Are Active"
    From this point on, it's safe to connect to the internet. Your device has 8 independent defensive layers protecting it from Autopilot and MDM enrollment. Only after these defenses are in place should you connect to the network.

---

## Pre-Flight Check (Optional but Recommended)

Before connecting to the internet, you can optionally verify that all your defenses are properly in place. A verification script is available that checks:

- ✅ Hosts file blocking entries are present
- ✅ Registry policies are correctly set (`DisableOSUpgrade`)
- ✅ Firewall rules are active
- ✅ MDM services are disabled

[📥 Download phase9-verify-protection.ps1](assets/downloads/phase9-verify-protection.ps1){: .md-button }

**To run the verification:**

1. Download the script above
2. Right-click on it and select **Properties**
3. Check the **"Unblock"** checkbox at the bottom and click **OK**
4. Right-click on the script file and select **Run with PowerShell**
5. Click **"Yes"** when Windows asks for Administrator permission

The script will display a report showing which defenses are active and which (if any) need attention. If all checks pass, you're ready to connect safely.

!!! note "Verification is Optional"
    If you're confident in your setup, you can skip this step and proceed directly to connecting to the internet. This script is just extra insurance.

---

## Step-by-Step Instructions

### Step 1: Connect to the Internet (NOW Safe)

Now that all your defenses are in place – and ONLY when all 8 previous phases are complete:

1. **Plug in the Ethernet cable**, OR
2. **Re-enable WiFi:**
   - If you use a WiFi kill switch, toggle it back on
   - Or go to **Settings > Network > WiFi** and turn it on
   - Or restart the WiFi router if you disabled it earlier

Your device will now connect to the internet. Windows might check for updates and show notifications – this is normal.

!!! note "Updates Are Safe Now"
    Windows will try to download updates. This is fine – your device can't be re-enrolled in Autopilot anymore. Updates will make your device more secure, not less.

### Step 2: Sign In with Your Personal Microsoft Account

This is when you claim the device as your own:

1. Click **Start menu**
2. Go to **Settings > Accounts > Your info**
3. Look for **"Sign in with a Microsoft account instead"** (or similar)
4. Click it
5. Enter your **personal Microsoft account** (your Outlook, Hotmail, Xbox, or any Microsoft email address)
6. If you don't have one, click **"Create a new account"** to make one
7. Follow the setup steps

!!! tip "Personal Account, Not Work Account"
    Use your personal Microsoft account (like your Gmail-forwarded-to-Outlook, or your personal Outlook address). Do NOT use any work email address, even if you have a personal Microsoft account created with a work email. That can trigger the "Allow my organization to manage this device" dialog.

### Step 3: Set Up Windows Hello Security

Windows Hello (biometric or PIN login) adds an extra layer of security:

1. Still in **Settings > Accounts > Your info**, find **"Sign-in options"** in the left sidebar
2. Under Windows Hello, you'll see options for:
   - **Face Recognition** (if your device has a camera)
   - **Fingerprint** (if your device has a fingerprint reader)
   - **PIN**

3. Click on one (even just a PIN is good) and set it up
4. This creates a second layer of authentication that even Windows doesn't fully control

!!! success "Two Factors is Better"
    Setting up Windows Hello PIN or biometric makes your device even more secure. You own the biometric or PIN – not Microsoft, not the corporation.

---

## The CRITICAL Rule: Never Allow Device Management

### What to Watch For

At some point, you might see a dialog like:

**"Allow your organization to manage your device?"**

Or:

**"Your organization is asking to manage your device"**

Or:

**"Allow IT admin to manage this device"**

!!! danger "CRITICAL - READ THIS"
    **NEVER click "Yes" or "Agree."**
    
    Even if the dialog seems official or important, even if it claims your organization "requires" it, **ALWAYS:**
    1. **UNCHECK the box** if there is one
    2. **Click "No" or "Don't allow"**
    3. Click **"No, sign in only to this app"** if that option appears

### When Does This Happen?

This dialog appears when you try to sign into:
- **Microsoft Teams** (work version)
- **Office 365** or **Microsoft 365**
- **Outlook** (work version)
- **SharePoint** or **OneDrive** (corporate)

!!! warning "You Can Still Use These Apps"
    You CAN still use Teams, Office, Outlook, etc. with your work account. Just refuse device management, and you get the apps without the device enrollment. Your organization gets your productivity tools, but not control of your device.

### Example Scenario

```
You open Microsoft Teams to chat with coworkers.
A dialog appears: "Allow your organization to manage your device?"

WRONG: Click "Yes" ❌
RIGHT: Uncheck the box and click "No, sign in only to this app" ✅

Result: Teams works, but your device stays yours.
```

!!! success "Using Work Apps Without Giving Up Your Device"
    This is the balance: you can be productive with corporate tools, but your device remains under your control, not corporate control.

---

## Your Device is Now Ready

After completing the setup:

- ✅ All corporate tracking is disabled
- ✅ All corporate enrollment is blocked
- ✅ Your personal account is in control
- ✅ Windows Hello adds extra security
- ✅ You can use work apps without giving up device control

---

## Long-Term Security Tips

### Keep These Practices

1. **Regularly update Windows** – this keeps your device secure against new exploits
2. **Use your Windows Hello PIN/biometric** – always sign in securely
3. **Keep backups** – if something goes wrong, you can restore
4. **Monitor device management** – go to **Settings > Accounts** and verify no organization is managing your device
5. **Never accept "device management" requests** – the one critical rule

### What If?

**"I accidentally clicked Yes to device management"**
- Go to **Settings > Accounts > Access work or school**
- If your work account is listed, click on it and select **Disconnect**
- Your device is free again

**"Windows is trying to upgrade me to Pro"**
- Your Registry key from Phase 4 should prevent this
- If it's happening, go back to Phase 4 and verify `DisableOSUpgrade` is set to `1`

**"I see an Autopilot enrollment screen"**
- This shouldn't happen if you followed all phases
- Check that your hosts file is protected and read-only (Phase 6)
- Verify that `dmwappushservice` is stopped and disabled (Phase 5)

!!! success "Phase 9 Complete – You're Done!"
    Your device is now a consumer computer under your control, even though it was legally owned by a corporation. You can use work apps and be productive, but no one can remotely manage, lock, or control your device. **Congratulations – your device is free!**

---

## Congratulations: You've Reached Phase 9!

You've successfully completed all 9 phases. Your device is now protected by:
- **Phases 1-2:** BIOS and installation enforcements
- **Phases 3-4:** Clean OS installation and license locking
- **Phases 5-6:** Service and DNS-level blocking
- **Phase 7:** Firewall application-level blocking
- **Phase 8:** (Optional) Automatic hosts file watchdog

Only now is it safe to connect to the internet.

---

## Summary of All Defenses

| Phase | Defense | Level |
|-------|---------|-------|
| 1 | TPM cleared, Computrace disabled | BIOS/Hardware |
| 2 | Edition selection with optional Home forcing | Installation Media |
| 3 | Clean Windows install, offline setup | OS Installation |
| 4 | Corporate license keys purged, edition locked, upgrades blocked | Registry/Licensing |
| 5 | MDM services killed, Azure AD blocked | OS Services |
| 6 | Enrollment servers blocked | Network/Hosts File |
| 7 | MDM executables blocked at firewall | Application/Firewall |
| 8 | Hosts file monitored and auto-restored (optional) | Continuous Restoration |
| 9 | Personal account, Windows Hello, internet connection | Final Safe Account Setup |

**These nine layers create an enterprise-grade defense stack (with Phase 8 being optional).** Even if an attacker understands and tries to bypass one or two layers, the remaining independent layers will continue to protect your device.
