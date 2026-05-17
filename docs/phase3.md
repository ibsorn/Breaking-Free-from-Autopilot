---
description: Phase 3 - Clean Windows 11 installation offline. Skip Microsoft account setup using BypassNRO command and disconnect from network to prevent Autopilot/Entra ID enrollment.
keywords: Windows installation, offline installation, BypassNRO, clean install, skip device setup
---

# Phase 3: Clean Installation and Network Bypass (BypassNRO)

## Overview

Now it's time to perform a **completely clean Windows 11 installation**. This erases all existing Windows, all corporate tracking, and all enrollment data. You'll install your chosen Windows edition (Home or Pro) while completely bypassing Microsoft account creation and online enrollment checks.

The key technique is the **BypassNRO** command, which removes network requirements from Windows setup.

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

### Step 5: Bypass Network Requirements with BypassNRO

When installation finishes, you'll see a setup screen:
**"Is this the correct country or region?"** or similar.

<ol class="steps-list">
  <li><strong>Press Shift + F10</strong> (or <strong>Shift + Fn + F10</strong> on some laptops) to open <strong>Command Prompt</strong></li>
  <li>Type <strong>exactly:</strong> <code>oobe\bypassnro</code></li>
  <li><strong>Press Enter</strong></li>
</ol>

!!! warning "Exact Syntax Required"
    The command must be exactly `oobe\bypassnro` (backslash, not forward slash). If it doesn't work, you're not in the right place – BypassNRO only works during OOBE (Out of Box Experience).

The device will restart automatically.

### Step 6: Complete Setup with No Account

After restart, Windows will show setup screens again:

<ol class="steps-list">
  <li><strong>Select country and keyboard layout</strong> again</li>
  <li><strong>When you reach the "Let's connect you to a network" screen,</strong> look for <strong>"I have no internet"</strong> at the bottom</li>
  <li><strong>Click it</strong></li>
</ol>

!!! tip "If BypassNRO Worked"
    The "I have no internet" option will appear. If it doesn't, BypassNRO might not have run successfully – restart and try command prompt again in the OOBE phase.

<ol class="steps-list" start="4">
  <li>Click <strong>Continue with limited setup</strong></li>
  <li>Create a <strong>local user account</strong> (give it any name you like, e.g., <code>Admin</code> or <code>LocalUser</code>)</li>
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
| BypassNRO command doesn't work | Make sure you typed it exactly: `oobe\bypassnro` (with backslash). Case doesn't matter, but the spelling must be exact. |
| Device keeps trying to connect to WiFi | Go back to Step 1 and physically disable WiFi or unplug Ethernet. |
| "I have no internet" option doesn't appear | BypassNRO didn't run successfully. Restart and try the Shift+F10 command again. |
