---
description: Phase 3 - Clean Windows 11 installation offline. Skip the Microsoft account / network requirement with the ms-cxh:localonly command (Windows 11 24H2+) or the legacy oobe\bypassnro, and stay disconnected to prevent Autopilot/Entra ID enrollment.
keywords: Windows installation, offline installation, ms-cxh:localonly, BypassNRO, Windows 11 24H2, local account, clean install, skip device setup
---

# Phase 3: Clean Installation and Offline Local Account

## Overview

Now it's time to perform a **completely clean Windows 11 installation**. This erases all existing Windows, all corporate tracking, and all enrollment data. You'll install your chosen Windows edition (Home or Pro) while completely bypassing Microsoft account creation and online enrollment checks.

The key technique is skipping the forced Microsoft-account/network step during setup. On current Windows 11 (**24H2 and newer**) this is done with the `start ms-cxh:localonly` command; on older builds the classic `oobe\bypassnro` command does the same thing.

**Time required:** 20–30 minutes  
**What you need:**
- The customized Windows 11 USB from Phase 2
- No internet connection (critical!)
- The device you're unlocking

!!! danger "Keep the Device Offline During This Phase"
    If your device connects to the internet during setup, it will attempt to re-enroll in Autopilot. Keep WiFi and Ethernet both disconnected until Phase 9. This is critical.

---

## Step-by-Step Instructions

### Step 1: Disconnect from the Internet

Before you do anything else:

<ol class="steps-list">
  <li><strong>Unplug any Ethernet cable</strong> from the device</li>
  <li><strong>Disable WiFi:</strong>
    <ul>
      <li>If you have a WiFi kill switch on the keyboard, toggle it off</li>
      <li>Or go to <strong>Settings > Network > WiFi</strong> and toggle it off</li>
    </ul>
  </li>
  <li><strong>Optional but recommended:</strong> Temporarily turn off your WiFi router so even accidental connection is harder</li>
</ol>

!!! warning "No Internet Means No Internet"
    The Windows installer is extremely persistent about checking Microsoft servers. If you're on WiFi, it WILL try to connect. Just turning off the WiFi toggle isn't always enough – physically disable it or disconnect from the network.

### Step 2: Boot from the USB

<ol class="steps-list">
  <li><strong>Insert the Windows 11 USB</strong> you prepared in Phase 2</li>
  <li><strong>Turn on the device</strong> and immediately enter the <strong>boot menu</strong> (usually F12, F2, Del, or Esc during startup – varies by manufacturer)</li>
  <li><strong>Select the USB drive</strong> as the boot device (look for something like "UEFI: USB" or the drive name)</li>
  <li><strong>Press Enter</strong> and let the Windows installer load</li>
</ol>

!!! tip "Can't Find Boot Menu?"
    If you miss the boot menu timing, let Windows start normally, then restart and try again. Timing can be tricky – be patient and try multiple times if needed.

### Step 3: Start the Installation

<ol class="steps-list">
  <li>Windows Setup will load (this takes 1–2 minutes)</li>
  <li>Select your <strong>Language</strong>, <strong>Time and Currency Format</strong>, and <strong>Keyboard/Input Method</strong></li>
  <li>Click <strong>Next</strong></li>
  <li>Click <strong>Install now</strong></li>
</ol>

!!! note "Offline Indicator"
    You'll see a message like "Your internet isn't secure" or no internet connectivity indicators. This is normal and expected.

### Step 4: Erase the Disk

<ol class="steps-list">
  <li>You'll see a screen: <strong>"Where do you want to install Windows?"</strong></li>
  <li><strong>Select each partition one by one</strong> and click <strong>Delete</strong></li>
  <li>Repeat until you see only <strong>"Unallocated Space"</strong></li>
  <li><strong>Click on the Unallocated Space</strong> and click <strong>Next</strong></li>
</ol>

Windows will now begin installing. This takes 10–20 minutes.

!!! success "Installation in Progress"
    Windows is being installed on a completely clean disk. No corporate data, no Autopilot records, no tracking software. Just vanilla Windows 11 (Home or Pro, depending on your choice).

### Step 5: Skip the Microsoft Account / Network Requirement

When installation finishes, you'll see a setup screen:
**"Is this the correct country or region?"** or similar.

Press **Shift + F10** (or **Shift + Fn + F10** on some laptops) to open **Command Prompt**. Then use the method that matches your Windows 11 version.

!!! warning "Windows 11 24H2 removed the old `bypassnro` command"
    On **Windows 11 24H2 and newer** (build 26100+), Microsoft **deleted** the classic `oobe\bypassnro` script, so it no longer works on recent ISOs. Use **Method A** below. On older ISOs (23H2 and earlier), `oobe\bypassnro` still works (**Method B**).

**Method A — `ms-cxh:localonly` (recommended, works on 24H2+):**

<ol class="steps-list">
  <li>In the Command Prompt, type <strong>exactly:</strong> <code>start ms-cxh:localonly</code></li>
  <li><strong>Press Enter</strong></li>
</ol>

A local-account creation screen opens **immediately** – no restart needed. Continue with Step 6 (you'll go straight to creating the local user).

**Method B — `oobe\bypassnro` (older ISOs, 23H2 and earlier):**

<ol class="steps-list">
  <li>In the Command Prompt, type <strong>exactly:</strong> <code>oobe\bypassnro</code> (backslash, not forward slash)</li>
  <li><strong>Press Enter</strong> – the device restarts automatically</li>
  <li>After the restart, continue with Step 6 (you'll get an <strong>"I don't have internet"</strong> option on the network screen)</li>
</ol>

!!! tip "Method C — Registry fallback (if neither works)"
    Some in-between builds have neither option. In that case, re-enable the bypass flag manually from the Command Prompt and reboot:
    ```
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f
    shutdown /r /t 0
    ```
    After the restart, the **"I don't have internet"** option returns on the network screen – continue with Step 6.

### Step 6: Complete Setup with No Account

**If you used Method A (`start ms-cxh:localonly`):** a local-account screen ("Who's going to use this device?") opens right away – go straight to creating the local user below. There is no restart and no "Continue with limited setup" button.

**If you used Method B or C (`bypassnro` / registry):** after the automatic restart, Windows shows the setup screens again. Select country and keyboard, and when you reach **"Let's connect you to a network"**, click **"I don't have internet"** at the bottom, then **Continue with limited setup**.

!!! tip "If the offline option doesn't appear (Method B/C)"
    The "I don't have internet" / "Continue with limited setup" option should be there. If it isn't, the bypass didn't run – reopen Command Prompt with Shift+F10 and use `start ms-cxh:localonly` (Method A) instead.

Then, for **all methods**:

<ol class="steps-list">
  <li>Create a <strong>local user account</strong> (give it any name you like, e.g., <code>Admin</code> or <code>LocalUser</code>) and set a password if you want</li>
  <li><strong>Press Next</strong> and proceed through any remaining setup screens</li>
  <li><strong>Skip Microsoft account sign-in</strong> – you'll add your personal account later in Phase 9</li>
  <li>Configure privacy settings (you can turn everything off if you want)</li>
  <li>Click <strong>Finish</strong> when you reach the desktop</li>
</ol>

!!! success "Phase 3 Complete"
    You now have a completely clean Windows 11 installation (Home or Pro) on a fresh, completely offline system. No accounts are signed in, no enrollment data exists, and corporate fingerprints are gone. Your device now thinks it's a brand-new personal computer.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Command Prompt not found" when pressing Shift+F10 | You're not in OOBE (setup phase). Only Shift+F10 works during setup, not in the main Windows environment. |
| `oobe\bypassnro` command doesn't work / "not recognized" | On Windows 11 24H2+ this command was **removed**. Use Method A instead: `start ms-cxh:localonly`. On older ISOs, type `oobe\bypassnro` exactly (backslash, not slash). |
| `ms-cxh:localonly` does nothing | It only works during OOBE (setup). Make sure you're at the setup screens, not the desktop. On very old ISOs it may not exist – use `oobe\bypassnro` (Method B) instead. |
| Device keeps trying to connect to WiFi | Go back to Step 1 and physically disable WiFi or unplug Ethernet. |
| "I don't have internet" option doesn't appear | The bypass didn't run. Reopen Command Prompt with Shift+F10 and try `start ms-cxh:localonly` (Method A). |
