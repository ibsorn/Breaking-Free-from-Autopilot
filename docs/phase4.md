---
description: Phase 4 - Lock Windows 11 to Home edition. Remove preinstalled retail keys, purge license keys, and set registry policies to prevent edition upgrade or MDM re-enrollment.
keywords: license key, Home edition, registry policy, preinstalled retail key, upgrade block, PRK
---

# Phase 4: Key Purging and Version Lock

!!! info "⚡ MASTER SCRIPT AVAILABLE - Automate Phases 4–9"
    If you prefer **complete automation** instead of manual steps, use the **Master Script** that handles everything from Phase 4 through Phase 9:
    
    [📥 Download breaking-free-complete.ps1](https://github.com/ibsorn/Breaking-Free-from-Autopilot/releases/download/v0.1.0-alpha/breaking-free-complete.ps1){: .md-button }
    
    **What it automates:**
    - ✅ Phase 4: Edition locking & license purging
    - ✅ Phase 5: MDM & telemetry services disabling
    - ✅ Phase 6: Hosts file DNS blocking
    - ✅ Phase 7: Firewall application blocking
    - ✅ Phase 8: Watchdog scheduled task installation
    - ✅ Phase 9: Pre-flight verification
    
    **How to use:** Right-click the script > **Run as Administrator**. Takes ~10-15 minutes. Zero manual steps.
    
    **Prefer step-by-step control?** Scroll down to use individual phase scripts or follow manual instructions below.

---

## Overview

Your device's motherboard contains a **Preinstalled Retail Key (PRK)** – a Pro license engraved in the firmware. If Windows ever connects to Microsoft servers, it will automatically detect this key.

### Why This Phase Matters

The goal of Phase 4 is to **prevent Windows from using the corporate PRK (Preinstalled Retail Key) embedded in your device's firmware**. This prevents:
- Automatic re-activation with the corporate license
- Forced edition upgrades (especially back to Pro if you're on Home)
- Policy-based re-enrollment triggered by license detection

**If you installed Home Edition:**
- Installing a generic Home key prevents Windows from detecting and upgrading to Pro
- Blocks any attempt to apply the corporate Pro license from the motherboard

**If you installed Pro Edition:**
- Installing a generic Pro key replaces the corporate license
- Prevents Windows from using the corporate key even if it detects it
- Blocks policy-based forced upgrades or re-enrollment based on the corporate license

### What You'll Do

In this phase, you'll:
1. **Delete the corporate PRK** from Windows registry
2. **Remove any preloaded enterprise keys** that might trigger automatic upgrades
3. **Install a generic key** (Home key if you installed Home, or skip if you installed Pro with your own key)
4. **Block Windows from attempting OS upgrades** at the registry level

**Time required:** 5 minutes  
**Important:** Stay offline during this entire phase

!!! warning "Still Offline"
    Do NOT connect to the internet yet. You're still "immunizing" the device against corporate control. We'll connect in Phase 9 once defenses are fully in place.

!!! info "About Preinstalled Retail Keys (PRKs)"
    Corporate manufacturers embed Pro/Enterprise licenses directly in the motherboard's BIOS/UEFI. These are called **Preinstalled Retail Keys (PRKs)**. They're designed to automatically "activate" the correct Windows edition when Windows detects them. By purging them from the OS registry, we prevent Windows from ever using them.

---

## Automated Alternative: Use a PowerShell Script

If you prefer to **automate all of Phase 4**, you can use a PowerShell script that will execute all the recommended commands:


[📥 Download phase4-lock-edition.ps1](assets/downloads/phase4-lock-edition.ps1){: .md-button }

**To use the script (Home Edition users):**

1. Download the file above
2. Right-click on it and select **Properties**
3. Check the **"Unblock"** checkbox at the bottom and click **OK**
4. Right-click on the script file and select **Run with PowerShell**
5. Click **"Yes"** when Windows asks for Administrator permission (UAC dialog)
6. The script will automatically execute all Phase 4 commands with delays between them

!!! tip "Why Use the Script?"
    - **Automatic delays** – Each command gets time to process before the next one runs
    - **No typing required** – No risk of typos in license keys
    - **Clear visual feedback** – Colorized output shows exactly what's happening
    - **Handles registry creation** – Automatically creates registry paths if they don't exist
    - **Faster than manual** – All four steps run automatically

If you prefer to do it manually, or if you installed Pro edition, follow the instructions below.

---

## Step-by-Step Instructions

### Step 1: Open Command Prompt as Administrator

1. Click the **Start menu**
2. Type `cmd` (just type it, don't press Enter immediately)
3. You'll see **"Command Prompt"** in the results
4. **Right-click on it** and select **"Run as administrator"**
5. Click **"Yes"** when asked if you want to allow this app to make changes

You should now see a black Command Prompt window with `C:\Windows\System32>` or similar.

!!! note "Command Prompt vs PowerShell"
    We're using Command Prompt (cmd), not PowerShell. Make sure you opened the right one.

### Step 2: Delete the Motherboard License Key

This removes the record of the Pro license burned into the motherboard:

1. **Type exactly:**
   ```
   slmgr.vbs /cpky
   ```

2. **Press Enter**
3. A dialog box will appear saying **"Licensing data has been cleared."**
4. Click **OK**

!!! tip "What This Does"
    The `/cpky` command purges the certificate from the registry. The motherboard still has Pro license info in firmware, but Windows no longer has a copy of it in the OS.

### Step 3: Uninstall the Pre-Installed Key

Some corporate devices have pre-installation keys for Pro edition. Let's remove it:

1. **Type exactly:**
   ```
   slmgr.vbs /upk
   ```

2. **Press Enter**
3. A message will appear saying **"Uninstall SUCCEEDED"** (or similar)
4. Click **OK**

!!! note "Even If No Key Was Found"
    This command is safe to run even if there's no pre-installed key. It will simply report that there was nothing to uninstall.

### Step 4: Install a Generic Key

Now install an official Microsoft generic key for your edition:

**If you installed Home Edition:**

1. **Type exactly:**
   ```
   slmgr.vbs /ipk YTMG3-N6DKC-DKB77-7M9GH-8HVX7
   ```

2. **Press Enter**
3. A dialog box will say **"The product key was successfully installed."** or **"Installed a product key."**
4. Click **OK**

**If you installed Pro Edition:**

1. **Type exactly:**
   ```
   slmgr.vbs /ipk VK7JG-NPHTM-C97JM-9MPGT-3V66T
   ```

2. **Press Enter**
3. A dialog box will say **"The product key was successfully installed."** or **"Installed a product key."**
4. Click **OK**

!!! note "About This Generic Key"
    This generic key is **not a permanent activation key** – it's temporary and will expire. After completing all 9 phases, you'll need to purchase a genuine Windows 11 key for permanent activation, but for now it replaces the corporate license and prevents Windows from using the embedded PRK.

### Step 5: Block Forced OS Upgrades (Two Registry Locations)

Finally, we'll disable Windows' ability to force upgrade to Pro. **Microsoft uses two separate mechanisms for edition upgrades**, so we'll block both:

**Location 1: Windows Update Path**

1. **Close Command Prompt** (type `exit` and press Enter, or just close the window)
2. Press **Windows + R** to open the Run dialog
3. Type `regedit` and press **Enter**
4. Click **"Yes"** if asked to allow Registry Editor

The Registry Editor window will open.

!!! warning "Registry Editor is Powerful"
    The Registry Editor lets you change Windows at a deep level. Don't change anything except what's described below. One wrong edit could break Windows.

5. In the **left panel**, navigate to:
   ```
   HKEY_LOCAL_MACHINE > SOFTWARE > Policies > Microsoft
   ```

   - If `Policies` doesn't exist, right-click on `SOFTWARE` > **New > Key**, name it `Policies`
   - If `Policies > Microsoft` doesn't exist, right-click on `Policies` > **New > Key**, name it `Microsoft`

6. **Right-click inside the `Microsoft` folder** (in the left panel) and select **New > Key**
7. Name it **`Windows`** (if it doesn't already exist)
8. **Right-click on `Windows`** and select **New > Key**
9. Name it **`WindowsUpdate`**
10. **Right-click inside the `WindowsUpdate` folder** (left panel) > **New > DWORD (32-bit) Value**
11. Name it **`DisableOSUpgrade`**
12. **Double-click it** and set the value to **`1`**
13. Click **OK**

!!! success "First Block Installed"
    The WindowsUpdate path now blocks OS version upgrades (e.g., Windows 10 → Windows 11). But Microsoft also uses the **Windows Store component** to silently upgrade editions (Home → Pro). We'll block that too.

**Location 2: Windows Store Path (Defense in Depth)**

14. In the left panel, go back to:
    ```
    HKEY_LOCAL_MACHINE > SOFTWARE > Policies > Microsoft
    ```

15. **Right-click inside the `Microsoft` folder** and select **New > Key**
16. Name it **`WindowsStore`** (create it if it doesn't exist)
17. **Right-click inside the `WindowsStore` folder** > **New > DWORD (32-bit) Value**
18. Name it **`DisableOSUpgrade`**
19. **Double-click it** and set the value to **`1`**
20. Click **OK**

!!! success "Upgrade Completely Blocked"
    You've now blocked Windows from upgrading your edition through **both** the Windows Update path AND the Windows Store path. This is "defense in depth" — even if Microsoft updates one mechanism, the other will still protect you.

### Step 6: Close Registry Editor and Restart

1. Close the Registry Editor
2. You can restart now, or proceed to Phase 5

!!! success "Phase 4 Complete"
    Your device is now locked down and corporate PRK keys are removed. Whether you chose Home or Pro, Windows cannot use the corporate license keys and cannot be forced into corporate enrollment. You're one step closer to freedom.

---

## About License Keys

The generic keys used in Step 4 are **Microsoft-provided temporary keys** that are freely distributed. They serve one purpose: **prevent Windows from detecting and using the corporate PRK**. After completing all 9 phases and verifying your system works correctly, you should purchase a genuine Windows 11 license key for permanent activation.

---

## Registry Path Quick Reference

If you need to find these settings again later, they're at:

**Location 1 (Windows Update):**
```
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
DWORD: DisableOSUpgrade = 1
```

**Location 2 (Windows Store - blocks edition upgrades):**
```
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore
DWORD: DisableOSUpgrade = 1
```

Both are required for complete, defense-in-depth protection against edition upgrades.
