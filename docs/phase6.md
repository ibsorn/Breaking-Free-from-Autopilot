---
description: Phase 6 - Block Autopilot enrollment servers via hosts file. Add Microsoft enrollment domains to hosts file and set Windows Defender exclusions to prevent Autopilot detection.
keywords: hosts file, domain blocking, Autopilot servers, ztd.desktop.microsoft.com, cs.dds.microsoft.com, Windows Defender
---

# Phase 6: Server Blocking in the Hosts File

## Overview

Even with all your defenses active, Windows would still contact Autopilot and enrollment servers if given the chance. In this phase, we'll **block these servers at the operating system level** by editing the `hosts` file.

The `hosts` file is a local DNS override – it tells your computer "when you try to reach this internet address, send the request to 0.0.0.0 (nowhere)." This is an elegant, OS-level firewall that doesn't require external software or network configuration.

We'll then protect the hosts file from being reset by:
- Adding it to Windows Defender exclusions
- Making it read-only

**Time required:** 5-10 minutes  
**Special consideration:** We're still offline, and staying that way until Phase 9

!!! note "Why 0.0.0.0?"
    The special address `0.0.0.0` is a non-routable address that means "send this nowhere." It's used specifically for blocking domains without needing to know the "fake" IP address.

---

## Automated Alternative: Use a PowerShell Script

If you prefer to **automate all of Phase 6**, you can use a PowerShell script that will:
- Automatically add blocking entries to the hosts file
- Protect the hosts file with read-only flag
- Add it to Windows Defender exclusions

[📥 Download phase6-block-servers.ps1](assets/downloads/phase6-block-servers.ps1){: .md-button }

**To use the script:**

1. Download the file above
2. Right-click on it and select **Properties**
3. Check the **"Unblock"** checkbox at the bottom and click **OK**
4. Right-click on the script file and select **Run with PowerShell**
5. Click **"Yes"** when Windows asks for Administrator permission (UAC dialog)
6. The script will automatically modify your hosts file and apply protections

!!! tip "Script Benefits"
    - Automatically adds blocking entries
    - Sets read-only protection in one go
    - Adds to Windows Defender exclusions automatically
    - Less chance of manual error

If you prefer to do it manually, follow the instructions below.

---

### Step 1: Open Notepad as Administrator

1. Click **Start menu**
2. Search for **Notepad** (just type "notepad")
3. **Right-click** on **Notepad** in the results
4. Select **Run as administrator**
5. Click **Yes** when asked to allow changes

A blank Notepad window will open.

!!! warning "Must Be Administrator"
    Without admin privileges, you won't be able to save changes to the hosts file. If Notepad doesn't open with admin rights, Notepad will fail when you try to save.

### Step 2: Open the Hosts File

1. In Notepad, go to **File > Open** (or press **Ctrl + O**)
2. Navigate to: `C:\Windows\System32\drivers\etc`
3. You might see "No files" – that's because by default, Notepad looks for `.txt` files
4. At the bottom right, change the file type from **"Text Documents (*.txt)"** to **"All Files (.)"**
5. Now you should see a file called **`hosts`** (no extension)
6. **Click on it** and click **Open**

The hosts file will now be open in Notepad. It's a plain text file with some default comments.

!!! note "What Does This File Contain?"
    - The hosts file starts with comments (lines beginning with `#`)
    - At the bottom, you might see `127.0.0.1    localhost` or similar
    - We'll add nine new lines to block Autopilot/Enrollment domains

### Step 3: Add the Blocking Entries

1. Click at the **very end of the file** (after the last line)
2. Press **Enter** twice to create a blank line
3. **Type exactly** these lines (one per line):

```
0.0.0.0 ztd.desktop.microsoft.com
0.0.0.0 cs.dds.microsoft.com
0.0.0.0 enterpriseregistration.windows.net
0.0.0.0 enrollment.manage.microsoft.com
0.0.0.0 api.intune.microsoft.com
0.0.0.0 portal.manage.microsoft.com
0.0.0.0 dsirnpus.microsoft.com
0.0.0.0 dc.services.visualstudio.com
0.0.0.0 management.azure.com
```

!!! warning "Format Matters"
    - Use `0.0.0.0` (zero dot zero dot zero dot zero)
    - Use a **TAB** or multiple **SPACES** between the address and the domain name (not a mix)
    - Do NOT add extra lines or trailing spaces
    - The domain names must be exactly as shown (lowercase is typical, but Windows doesn't care about case here)

**What each domain does:**
- **ztd.desktop.microsoft.com** – Zero Touch Deployment (Autopilot) server
- **cs.dds.microsoft.com** – Device Enrollment Service
- **enterpriseregistration.windows.net** – Enterprise device registration
- **enrollment.manage.microsoft.com** – Intune enrollment service
- **api.intune.microsoft.com** – Intune API (mobile device management)
- **portal.manage.microsoft.com** – Intune admin portal (device operations)
- **dsirnpus.microsoft.com** – Device state and policy reporting
- **dc.services.visualstudio.com** – Diagnostic/telemetry collection
- **management.azure.com** – Azure management API

### Step 4: Save the File

1. Press **Ctrl + S** to save (or go to **File > Save**)
2. The file should save immediately – no dialog should appear
3. If a dialog appears asking about the file format, click **Save** or **Yes**
4. Close Notepad when done

!!! success "Hosts File Updated"
    Your computer will now redirect any requests to these Microsoft enrollment servers to 0.0.0.0 (nowhere). Autopilot can't reach its servers, so it can't enroll your device.

---

### Step 5: Add the Hosts File to Windows Defender Exclusions

Windows Defender might try to "repair" the hosts file, thinking it's infected or misconfigured. Let's tell Defender to leave it alone:

1. Click **Start menu**
2. Search for and open **Windows Security**
3. Click **Virus & threat protection**
4. Scroll down and click **Manage settings** (under "Virus & threat protection settings")
5. Scroll down further to **"Exclusions"**
6. Click **Add or remove exclusions**
7. Click **Add an exclusion**
8. Select **File**
9. Navigate to `C:\Windows\System32\drivers\etc` and select the `hosts` file
10. Windows will add it – you should see it listed under Exclusions

!!! tip "Verify the Exclusion"
    After adding it, you should see something like `c:\windows\system32\drivers\etc\hosts` listed under exclusions. If you don't, try adding it again.

---

### Step 6: Make the Hosts File Read-Only

This prevents any program (including malware or system updates) from modifying the file:

1. Open **File Explorer**
2. Navigate to `C:\Windows\System32\drivers\etc`
3. **Right-click on the `hosts` file**
4. Select **Properties**
5. At the bottom of the "General" tab, check the **Read-only** checkbox
6. Click **Apply** and then **OK**

!!! warning "Read-Only = Protected"
    Once a file is read-only, even admin programs can't modify it without first removing the read-only flag. This is good for protecting it, but it also means you'll need to uncheck read-only if you ever want to edit the hosts file again.

---

## Verification: Test Connectivity Block

You can verify that the hosts file is working correctly:

1. Press **Windows + R**
2. Type `cmd` and press Enter
3. Type: `ping ztd.desktop.microsoft.com`
4. The important part is the address the name resolves to. You should see it resolve to `0.0.0.0`:
   ```
   Pinging ztd.desktop.microsoft.com [0.0.0.0] with 32 bytes of data:
   ```
   The ping itself will then **fail** (for example "General failure", "Destination host unreachable", or "Request timed out"). That failure is expected and correct — `0.0.0.0` goes nowhere.

This confirms the domain is being redirected to `0.0.0.0` instead of Microsoft's real servers.

!!! note "What Matters Is the Resolved Address"
    If the name resolves to `[0.0.0.0]`, the hosts file is correctly blocking the server — even though the ping replies fail. If it resolves to a real Microsoft IP address instead, the hosts entry isn't being applied; re-check Steps 3–4.

---

## What You've Accomplished

By editing the hosts file, you've created a **local, OS-level firewall** that:
- Blocks Autopilot enrollment servers
- Blocks device enrollment services
- Survives reboots and updates
- Doesn't require special firewall knowledge

The domains are now permanently unreachable from your device.

!!! success "Phase 6 Complete"
    The servers that could re-enroll your device are now blocked at the OS level. Even if corporate certificates somehow remained, they can't contact the enrollment servers to activate. Your device is now truly free from Autopilot. Just one phase left – secure your personal account!
