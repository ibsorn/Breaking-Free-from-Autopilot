---
description: Complete 9-phase technical guide to bypass Microsoft Autopilot, MDM, and Azure enrollment on Windows 11. Remove corporate device locks with step-by-step instructions and automated PowerShell scripts, including optional hosts file watchdog protection.
keywords: autopilot, MDM, Azure, Windows 11, device unlock, corporate lock removal, Microsoft enrollment bypass, Windows Home edition, firewall blocking, hosts watchdog
---

# Complete Guide to Blocking Autopilot, MDM, and Azure Enrollment on Windows

Learn how to **completely remove Microsoft Autopilot, MDM (Mobile Device Management), and Azure/Entra ID locks** from Windows 11 devices. This comprehensive 9-phase technical guide provides step-by-step instructions to **regain full control** of corporate-locked computers, with both manual procedures and downloadable automation scripts.

## Why You Need This Guide

Microsoft's Autopilot and Device Management systems create powerful restrictions on Windows devices:

- **Autopilot Lock:** Prevents you from bypassing initial device setup and account configuration
- **MDM Enrollment:** Continuously monitors device activity, enforces policies, and can remotely wipe data
- **Azure/Entra ID Tenant Lock:** Permanently binds the device to a corporate organization, blocking account changes
- **Preinstalled Retail Keys (PRKs):** Automatically upgrade Windows editions and re-enable Autopilot enrollment

If you've purchased a used corporate laptop or inherited a company device, these locks prevent you from:
- Creating local administrator accounts
- Installing software without approval
- Connecting to any Wi-Fi network
- Using the device for personal purposes
- Selling or repurposing the hardware

**This guide solves all of these problems** by providing proven technical procedures to completely remove all layers of corporate control.

!!! warning "⚡ Quick Alternative: Master Script"
    After completing **Phases 1–3** (BIOS, edition selection, and clean installation), you can use the **Master Script** to automate the remaining **Phases 4–9** (early testing stage, may fail):
    
    [📥 Download breaking-free-complete.ps1](https://github.com/ibsorn/Breaking-Free-from-Autopilot/releases/download/v0.1.0-alpha/breaking-free-complete.ps1){: .md-button }
    
    **One click to automate:** Edition locking, MDM disabling, hosts blocking, firewall rules, watchdog setup, and pre-flight verification. Takes ~10-15 minutes. No manual steps needed.
    
    Prefer step-by-step control? Follow the individual phases below.

!!! warning "Important Prerequisites"
    - You will need administrator access or the ability to enter BIOS
    - A bootable Windows 11 USB drive
    - A backup of any important data (this process will wipe the drive)
    - Patience – work through each phase in order without skipping steps
    - Internet connectivity will be restored only after phase completion

## How This Guide Works

The process is divided into **nine phases**, each building on the previous one. Phases 1-7 are mandatory and comprehensive. Phase 8 adds optional automated protection. Phase 9 is the final connection and account setup step. Start with Phase 1 and proceed in order. **Internet connection is restored only in Phase 9**, after all defensive layers are active.

### Quick Overview

<div class="phase-grid">
  <a href="phase1/" class="phase-card">
    <div class="phase-card__number">1</div>
    <div class="phase-card__title">Deep Hardware Cleanup</div>
    <div class="phase-card__description">Clear BIOS tracking, TPM reset, disable Computrace/Lojack</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5–10 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase2/" class="phase-card">
    <div class="phase-card__number">2</div>
    <div class="phase-card__title">Edition Selection</div>
    <div class="phase-card__description">Choose Windows 11 edition (Home recommended) using ei.cfg</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase3/" class="phase-card">
    <div class="phase-card__number">3</div>
    <div class="phase-card__title">Clean Installation</div>
    <div class="phase-card__description">Fresh Windows install completely offline, no network</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">20–30 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase4/" class="phase-card">
    <div class="phase-card__number">4</div>
    <div class="phase-card__title">Key Purging</div>
    <div class="phase-card__description">Remove corporate licenses, lock edition with rearm</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase5/" class="phase-card">
    <div class="phase-card__number">5</div>
    <div class="phase-card__title">Telemetry & MDM Kill</div>
    <div class="phase-card__description">Disable DiagTrack, dmwappushservice, and Azure AD join</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase6/" class="phase-card">
    <div class="phase-card__number">6</div>
    <div class="phase-card__title">Hosts File Block</div>
    <div class="phase-card__description">Block Microsoft domains at system level via hosts file</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase7/" class="phase-card">
    <div class="phase-card__number">7</div>
    <div class="phase-card__title">Firewall Blocking</div>
    <div class="phase-card__description">Block MDM processes at firewall level with specific rules</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase8/" class="phase-card">
    <div class="phase-card__number">8</div>
    <div class="phase-card__title">Hosts Watchdog</div>
    <div class="phase-card__description">Auto-restore hosts file if modified by Windows updates</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5 min</span>
      <span class="phase-card__badge phase-card__badge--optional">Optional</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>

  <a href="phase9/" class="phase-card">
    <div class="phase-card__number">9</div>
    <div class="phase-card__title">Final Connection</div>
    <div class="phase-card__description">Safe internet connection after all defenses are active</div>
    <div class="phase-card__meta">
      <span class="phase-card__time">5–10 min</span>
      <span class="phase-card__badge">Required</span>
    </div>
    <span class="phase-card__arrow">→</span>
  </a>
</div>

**Total time: ~1–2 hours** (including 30 min for Windows installation)

!!! warning "Critical: Internet Until Phase 9"
    All phases 1-8 must be completed **while disconnected from the internet**. Only after all 8 protective layers are active is it safe to connect the network cable and proceed to Phase 9. This principle applies regardless of which Windows edition you chose in Phase 2.
