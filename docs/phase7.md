---
description: Phase 7 - Application-level Firewall blocking. Block MDM executables at the firewall level to prevent outbound connections from device enrollment processes, adding an additional security layer of defense-in-depth.
keywords: firewall, application blocking, deviceenroller.exe, omadmclient.exe, dsregcmd, MDM process blocking, defense-in-depth
---

# Phase 7: Application-Level Firewall Blocking

## Overview

You've already blocked the **destinations** (domains in the hosts file). Now we'll block the **messengers** – the internal Windows executables that Autopilot and Intune use to communicate with Microsoft servers.

Think of it as two-layered defense:

**Layer 1 (Previous):** Hosts file blocks the DNS names of Microsoft servers  
**Layer 2 (Now):** Firewall blocks the Windows executables that try to reach ANY server

Even if Microsoft changes their server IPs, embeds new addresses directly in code, or finds a way around your hosts file, the Windows Firewall will **prevent the application itself from reaching the internet**.

**Time required:** 5 minutes  
**Status:** Device is still offline – connection to internet happens in Phase 9

!!! warning "Why Two Layers?"
    This is **defense-in-depth** thinking. A single layer can be bypassed. Two independent layers, working at different levels (DNS + Application), are exponentially harder to circumvent. If the firewall rules are removed, the hosts file still protects you. If the hosts file is deleted, the firewall still stops outbound connections.

---

## The Four "Double Agents" You're Blocking

These are the Windows System32 executables that handle device enrollment, policy management, and Azure/Entra ID binding:

| Executable | Purpose | What It Does |
|------------|---------|-------------|
| **deviceenroller.exe** | Device Enrollment Client | Attempts to enroll the device in MDM (Intune) |
| **omadmclient.exe** | OMA DM (Open Mobile Alliance Device Management) Client | Downloads and applies MDM policies from Intune |
| **dsregcmd.exe** | Device Registration Command Tool | Joins/leaves the device from Azure AD / Entra ID |
| **ProvTool.exe** | Provisioning Package Tool | Installs corporate provisioning packages and policies |

By blocking these processes at the firewall, you ensure they **cannot transmit data to any external server**, regardless of the address.

!!! note "These Are System Files"
    You're not deleting these files. They'll remain in `C:\Windows\System32`. But Windows Firewall will intercept any outbound connection attempts from these processes and block them silently.

---

## Automated Firewall Blocking Script

The easiest way to implement this is with a PowerShell script that creates the firewall rules automatically.

[📥 Download phase7-firewall-block.ps1](assets/downloads/phase7-firewall-block.ps1){: .md-button }

**To use the script:**

1. Download the file above
2. Right-click on it and select **Properties**
3. Check the **"Unblock"** checkbox at the bottom and click **OK**
4. Right-click on the script file and select **Run with PowerShell**
5. Click **"Yes"** when Windows asks for Administrator permission (UAC dialog)
6. The script will create firewall rules for all four MDM processes

!!! tip "Script Benefits"
    - Automatically creates all four firewall rules
    - Checks if rules already exist (won't duplicate)
    - Shows clear status for each process
    - Skips any executables that don't exist on your system
    - Provides immediate feedback on success/failure

---

## Manual Method: Block via Windows Defender Firewall GUI

If you prefer to do this manually, you can create the rules through the Windows GUI:

### Step 1: Open Windows Defender Firewall with Advanced Security

1. Press **Windows + R**
2. Type `wf.msc` and press **Enter**
3. Click **Yes** when asked for Administrator permission

The Windows Defender Firewall advanced management window will open.

### Step 2: Create Outbound Rule for deviceenroller.exe

1. In the left panel, click **Outbound Rules**
2. In the right panel, click **New Rule...**
3. Choose **Program** and click **Next**
4. Select **This program path:**
5. Click **Browse** and navigate to: `C:\Windows\System32\deviceenroller.exe`
6. Click **Next**
7. Choose **Block** and click **Next**
8. Select **All** (Domain, Private, Public) and click **Next**
9. Name it: `Block-Autopilot-Process-deviceenroller.exe`
10. Description: `Blocks device enrollment agent communication`
11. Click **Finish**

### Step 3: Create Outbound Rule for omadmclient.exe

Repeat Steps 1-2 but use the path: `C:\Windows\System32\omadmclient.exe`

Name it: `Block-Autopilot-Process-omadmclient.exe`

Description: `Blocks MDM policy download and management`

### Step 4: Create Outbound Rule for dsregcmd.exe

Repeat Steps 1-2 but use the path: `C:\Windows\System32\dsregcmd.exe`

Name it: `Block-Autopilot-Process-dsregcmd.exe`

Description: `Blocks Azure AD / Entra ID binding`

### Step 5: Create Outbound Rule for ProvTool.exe

Repeat Steps 1-2 but use the path: `C:\Windows\System32\ProvTool.exe`

Name it: `Block-Autopilot-Process-ProvTool.exe`

Description: `Blocks provisioning package installation`

!!! success "All Four Rules Created"
    Once all four rules are in place, your device is protected at the application level. Even if a future Windows update tries to re-enroll your device, these firewall rules will silently block it.

---

## How This Protects You

### Scenario 1: Windows Update Includes New Enrollment Logic
- **Old defense:** Hosts file blocks the new domain
- **This defense:** Even if the domain isn't blocked, the firewall blocks `omadmclient.exe` before it can query DNS

### Scenario 2: Malicious Corporate Network
- **Old defense:** Hosts file works only for named domains
- **This defense:** Even if the network redirects IP addresses, the Firewall blocks the exact process trying to connect

### Scenario 3: Cached Corporate Credentials
- **Old defense:** Registry keys prevent auto-enrollment
- **This defense:** Even if auto-enrollment somehow triggers, `dsregcmd.exe` is blocked from reaching any server

---

## How to Verify the Rules Were Created

### Via PowerShell (PowerShell as Administrator):

```powershell
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Block-Autopilot*"}
```

You should see **four rules** listed with status `True`.

### Via Windows Firewall GUI:

1. Press **Windows + R**
2. Type `wf.msc` and press **Enter**
3. Click **Outbound Rules** in the left panel
4. Look for the four rules starting with `Block-Autopilot-Process-*`
5. All four should show **Enabled** in the **Enabled** column

---

## Important: These Rules Don't Break Normal Functions

The four executables these rules target have **very specific purposes**:

- **deviceenroller.exe** – Only communicates with Intune servers (blocked)
- **omadmclient.exe** – Only communicates with Intune servers (blocked)
- **dsregcmd.exe** – Only communicates with Azure AD servers (blocked)
- **ProvTool.exe** – Only applies provisioning packages downloaded by admins (not a concern)

These processes are **never used for normal Windows operation**. Blocking them will not:
- Break Windows Update
- Break normal internet connectivity
- Prevent you from installing software
- Stop Windows from working properly
- Break Microsoft Office or other applications

Normal Windows processes use different executables (`svchost.exe`, `WinInet`, etc.) that remain unblocked.

---

## What These Rules Actually Do in the Background

Every time Windows (or malicious software) tries to run one of the four blocked executables and it attempts an outbound connection:

1. The Firewall sees the process attempting to connect
2. It checks the firewall rules
3. It finds the **Block** rule you created
4. It silently drops the connection (no error, no prompt)
5. The process fails silently

This happens **instantly and invisibly**. The user never sees a notification, but the malicious enrollment is prevented.

---

## After Phase 7

Your device now has **three independent layers of protection**:

1. **DNS Level (Phase 6):** Hosts file blocks domain names
2. **Service Level (Phase 5):** Disabled MDM and telemetry services
3. **Application Level (Phase 7):** Firewall blocks the executables themselves

Even if one layer fails or is bypassed:
- The other two layers still protect you
- It would require an attacker to bypass **all three simultaneously**
- This is enterprise-grade defense-in-depth security

!!! success "Phase 7 Complete"
    Your device is now hardened at the application level. Corporate enrollment is not just blocked – it's physically prevented from communicating with any server. The device is "air-gapped" from the enrollment infrastructure at multiple levels, making re-enrollment virtually impossible without physically reinstalling Windows.

---

## Troubleshooting: If You Need to Remove These Rules

If in the future you need to remove these firewall rules (unlikely, but just in case):

### Via PowerShell (Admin):
```powershell
Remove-NetFirewallRule -DisplayName "Block-Autopilot-Process-*" -Confirm:$false
```

### Via GUI:
1. Open **Windows Defender Firewall with Advanced Security** (`wf.msc`)
2. Click **Outbound Rules**
3. Right-click on each `Block-Autopilot-Process-*` rule
4. Select **Delete**

But remember: These rules protect you from involuntary corporate re-enrollment. Keep them in place for as long as you own the device.

---

## Next: Phase 8 (Optional) - Automatic Hosts File Protection

You've now implemented application-level firewall blocking. If you want to add one final layer of **automatic protection** that restores your hosts file if Windows ever modifies it during updates, proceed to:

[Phase 8 - Hosts File Watchdog (Optional but Recommended)](phase8.md)

Phase 8 installs a scheduled task that automatically monitors your hosts file and restores any blocking entries that Windows removes during updates. It's the final insurance policy for complete protection.

!!! note "Phase 8 is Optional"
    Your device is already fully hardened by Phase 7. Phase 8 is extra insurance. Most users will find Phase 7 sufficient, but we recommend Phase 8 if you want to literally never think about hosts file restoration again.
