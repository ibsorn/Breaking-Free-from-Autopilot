# Breaking Free from Autopilot

So you've got a Windows laptop that *technically* belongs to you, but Microsoft and your former employer disagree. You can't install software, can't change settings, can't even use it with your own account. Welcome to the hell that is corporate device locks.

This guide walks you through **exactly how to remove them**—no BS, no "you need a new device," just proven technical steps that actually work.

## ⚡ Quick Start: Master Script (Phases 4–9 Automated)

If you want to skip all the manual steps after Phase 3, use the **Master Script** to automate everything:

[📥 Download breaking-free-complete.ps1](https://github.com/ibsorn/Breaking-Free-from-Autopilot/releases/download/v0.1.0-alpha/breaking-free-complete.ps1)

Just right-click > **Run as Administrator**. It handles phases 4–9 automatically (~10-15 minutes).

---

## Read the Full Guide

Everything you need is documented online at:

**→ [ibsorn.github.io/Breaking-Free-from-Autopilot/](https://ibsorn.github.io/Breaking-Free-from-Autopilot/)**

Code examples, PowerShell scripts, troubleshooting, everything is there.

## What's Actually Happening Here

When a company sets up a device with Autopilot, they plant three separate locks:

1. **BIOS-level hardware lock** — Your motherboard has a unique identifier that Microsoft knows about
2. **MDM (Mobile Device Management)** — Background services constantly phone home to corporate servers
3. **Azure/Entra ID tenant lock** — Your device is bound to their organization's directory

Even if you wipe the drive and reinstall Windows, these locks persist. The new Windows installation sees the locked hardware, sees the MDM services, and immediately re-enrolls itself. It's basically uninstall-proof.

This guide breaks all three locks in sequence. By the end, you have a genuinely free device.

## What You'll Accomplish

- **Phase 1:** Erase the hardware ID from your BIOS (TPM wipe, Computrace removal, etc.)
- **Phase 2:** Choose your Windows edition (Home recommended, Pro also works) and prepare installation media
- **Phase 3:** Do a completely offline clean install with your chosen edition
- **Phase 4:** Remove corporate license keys and lock down the OS to prevent upgrades or corporate re-enrollment
- **Phase 5:** Disable all the MDM background services
- **Phase 6:** Block the Microsoft servers that handle enrollment (at the OS level)
- **Phase 7:** Block MDM executables at the Windows Firewall level
- **Phase 8:** (Optional) Set up automatic watchdog to restore hosts file if Windows tampers with it
- **Phase 9:** Connect to internet and set up your personal account safely

Total time: roughly 1-2 hours depending on how familiar you are with BIOS menus.

Everything includes both manual steps and downloadable PowerShell scripts (so you're not typing 50 commands by hand).

## How This Repo Works

The documentation is built with **MkDocs** and automatically published to GitHub Pages. Every time you push changes, the site rebuilds automatically.

### Run Locally

```powershell
pip install -r requirements.txt
mkdocs serve
```

Visit `http://localhost:8000` to preview.

### Project Structure

```
docs/
  ├── index.md           # Start here
  ├── phase1.md–phase9.md
  └── assets/downloads/  # Scripts & config files
mkdocs.yml
overrides/              # Custom HTML templates (SEO, OpenGraph)
```

## Fair Warning

This works. People do it all the time. But understand what you're doing: you're disabling security features that employers use to protect corporate data. Make sure the device actually belongs to you before you do this, because corporate security teams don't appreciate surprises. Laws vary by country—do your homework.

## Links

- **Website:** [ibsorn.github.io/Breaking-Free-from-Autopilot/](https://ibsorn.github.io/Breaking-Free-from-Autopilot/)
- **GitHub:** [github.com/ibsorn/breaking-free-from-autopilot](https://github.com/ibsorn/breaking-free-from-autopilot)

