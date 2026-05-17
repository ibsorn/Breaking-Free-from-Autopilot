---
description: Phase 1 of bypassing Autopilot - BIOS/UEFI hardware cleanup. Clear TPM module, disable Computrace/Lojack, and remove corporate hardware fingerprints.
keywords: BIOS, UEFI, TPM, Computrace, hardware hash, Lojack, hardware cleanup
---

# Phase 1: Deep Hardware Cleanup (BIOS/UEFI)

## Overview

Before you even install Windows, you need to erase the corporate "fingerprints" stored in your hardware. Microsoft's Autopilot system relies on a hardware identifier called the **Hardware Hash** – a unique number burned into your device. The TPM (Trusted Platform Module) chip and BIOS store corporate certificates and enrollment records that prevent device unbinding.

In this phase, we'll:
- Clear the TPM module (which holds corporate certificates)
- Disable tracking modules like Computrace/Lojack (if present)

**Time required:** 5–10 minutes  
**Risk level:** Low (you haven't touched Windows yet)

!!! warning "Critical Step"
    Do NOT skip the TPM reset. Without it, Windows will try to re-enroll the device in the corporate domain. Clearing the TPM is essential regardless of which Windows edition you choose. This is the most important step in Phase 1.

---

## Step-by-Step Instructions

### Step 1: Enter BIOS/UEFI

<ol class="steps-list">
  <li><strong>Power on the device</strong> and immediately start pressing the BIOS entry key repeatedly.</li>
  <li>The key varies by manufacturer:
    <ul>
      <li><strong>Dell:</strong> F2 or F12</li>
      <li><strong>HP:</strong> F10 or Esc, then F10</li>
      <li><strong>Lenovo:</strong> F2 or Fn + F2</li>
      <li><strong>ASUS:</strong> Del or F2</li>
      <li><strong>Generic/Other:</strong> F2, F10, F12, Del, or Esc</li>
    </ul>
  </li>
</ol>

!!! tip "Timing Matters"
    You must press the key *immediately* after power-on, during the manufacturer logo. If you miss it, restart and try again. Don't wait for Windows to load.

### Step 2: Clear the TPM Module

This is where the corporate control data lives. Here's what to do:

<ol class="steps-list">
  <li><strong>Navigate to the Security tab</strong> (look for tabs like Security, System Security, or Integrated Peripherals)</li>
  <li><strong>Find the TPM option.</strong> It might be called:
    <ul>
      <li>"TPM Security Chip"</li>
      <li>"TPM Device"</li>
      <li>"Trusted Platform Module"</li>
      <li>"Intel PTT" (Intel devices)</li>
      <li>"AMD fTPM" (AMD devices)</li>
    </ul>
  </li>
  <li><strong>Select "Clear TPM"</strong> or <strong>"Reset TPM"</strong> or <strong>"Clear Security Chip"</strong></li>
  <li><strong>Confirm the action</strong> – this will delete all stored certificates and keys</li>
</ol>

!!! note "What This Does"
    The TPM chip can store corporate certificates that persist even after a Windows format. Clearing it ensures those certificates are permanently gone and cannot be recovered.

### Step 3: Disable Computrace (if present)

Some corporate devices have an agent called **Computrace** (also branded as "LoJack for Laptops" or "Absolute Persistent Agent"). This is remote access software that locks devices even without Autopilot.

<ol class="steps-list">
  <li><strong>Look for options related to:</strong>
    <ul>
      <li>"Computrace"</li>
      <li>"Absolute Persistence"</li>
      <li>"Lojack"</li>
      <li>"Embedded Security"</li>
    </ul>
  </li>
  <li><strong>If found, change the setting to:</strong>
    <ul>
      <li>"Permanently Disable"</li>
      <li>"Permanently Deactivated"</li>
      <li>Or set to "Disabled" (not just "Disabled – can be enabled by software")</li>
    </ul>
  </li>
</ol>

!!! warning "Computrace is Rare but Dangerous"
    If your device has Computrace and you don't disable it here, you won't be able to disable it later in Windows. It runs at a level below the OS. That's why we do it now.

### Step 4: Save and Exit

<ol class="steps-list">
  <li>Press <strong>F10</strong> (or the save/exit key for your BIOS) to save changes</li>
  <li>Confirm "Yes" when asked to save</li>
  <li>The device will restart</li>
</ol>

!!! success "Phase 1 Complete"
    You've successfully erased the hardware-level locks. The device is now "blank" at the BIOS level, though Windows still thinks it's enrolled in Autopilot. We'll fix that in Phase 3.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't find TPM option | Some laptops let you enter BIOS but have limited settings. Try "Security Chip," "Integrated Peripherals," or contact your device manufacturer for the exact path. |
| BIOS is password protected | You'll need the BIOS password. If you don't have it, this device may require manufacturer intervention. |
| Settings appear grayed out | Some corporate devices lock certain BIOS options. Try resetting to factory defaults (often under "System Defaults" or "Reset to Setup Defaults"). |