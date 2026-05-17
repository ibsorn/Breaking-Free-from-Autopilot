---
description: Phase 2 - Prepare Windows 11 installation media to force Home edition. Modify ei.cfg file to bypass Pro requirement and prevent future Autopilot re-enrollment.
keywords: Windows 11 Home, installation media, ei.cfg, ISO modification, edition lock
---

# Phase 2: Windows 11 Edition Selection (Recommended: Home)

## Overview

In this phase, you'll prepare your installation media. You have a choice of Windows editions:

- **Windows 11 Home (Recommended)** – The safest path because it has no built-in Autopilot, Azure AD join, or MDM capabilities. If you choose Home, use the `ei.cfg` method below to force it during installation.

- **Windows 11 Pro (Also Works)** – If you prefer or already have Pro, that's fine. The remaining phases (Phases 3–9) are specifically designed to completely disable all Autopilot, MDM, and Azure AD features on Pro edition. Many users successfully use Pro with this guide, but i highly suggest going for the Home edition.

Both paths work. Home is simpler because the unwanted features don't exist on that edition. Pro requires more steps to disable them, but all those steps are in this guide.

### Edition Comparison

| Aspect | Home | Pro |
|--------|------|-----|
| **Autopilot Support** | None | Yes (can be disabled) |
| **Azure AD Join** | None | Yes (can be disabled) |
| **MDM Enrollment** | Limited | Yes (can be disabled) |
| **Complexity** | Lower – features don't exist | Higher – features must be disabled |

!!! info "Alternative: Other Windows 11 Versions"
    
    - **Windows 11 Enterprise LTSC** – Has Autopilot components that can be theoretically disabled post-install, though this approach is **not tested or guaranteed** to work. Obtaining LTSC legally is also more difficult for most users.
    
    - **Windows 11 with Autopilot components removed** – Some community-modified versions exist, though these are less official, require finding reliable sources, and are **not tested or guaranteed** to work as intended.

    However, **forcing Home edition remains the simplest, most straightforward, and most reliably tested approach** and is recommended for most users.

This phase shows how to **prepare installation media and optionally force Home edition**. If you're choosing Home, you'll use the `ei.cfg` file method. If you're choosing Pro, skip the `ei.cfg` section and proceed directly to Phase 3.

**Time required:** 5 minutes  
**What you need:** 
- Windows 11 installation media (USB drive with Windows 11 image)
- A computer to prepare it on
- Administrator rights on that computer

!!! note "Why Home + ei.cfg?"
    If you're using Home edition, the `ei.cfg` file ensures the installer defaults to Home instead of Pro. This prevents Windows from auto-upgrading to the Pro license stored in your BIOS.
    
    If you're using Pro edition, you don't need this step – skip to Phase 3 and proceed with the Pro installation.

---

## Step-by-Step Instructions

### Step 1: Create or Obtain Windows 11 USB Media

If you don't already have a Windows 11 USB:

<ol class="steps-list">
  <li>Go to <a href="https://www.microsoft.com/software-download/windows11">Microsoft's Windows 11 download page</a></li>
  <li>Use the <strong>"Create installation media"</strong> tool</li>
  <li>Follow the wizard to download Windows 11 onto a USB drive (minimum 8 GB)</li>
  <li>Plug the USB into the locked corporate device</li>
</ol>

If you already have a Windows 11 USB, proceed to Step 2.

!!! tip "USB Preparation"
    Make sure the USB is truly blank or you're okay erasing it – the next steps will modify files on it. If you're reusing an old installation USB, that's fine.

### Step 2: Open the USB and Navigate to the `sources` Folder

<ol class="steps-list">
  <li><strong>Safely eject any USB drives</strong> from your computer</li>
  <li><strong>Plug in the Windows 11 USB</strong> you just created</li>
  <li><strong>Open File Explorer</strong> and find the USB drive (usually <code>D:</code> or <code>E:</code>, labeled as something like "WININSTALL")</li>
  <li>Look for the folder called <code>sources</code> – go inside it</li>
</ol>

!!! note "Cannot Find sources Folder?"
    If you don't see a `sources` folder, try changing the view to show all file types, or the USB may not have been created correctly.

---

## Step 3: Create the `ei.cfg` File (Home Edition Only)

**Skip this section if you're using Pro edition. Proceed to Phase 3.**

If you're installing Home edition, this step is required.

This special file tells the Windows installer: "Install Home edition, not Pro."

**Option A: Manual Creation**

<ol class="steps-list">
  <li><strong>Right-click in an empty area</strong> of the <code>sources</code> folder</li>
  <li>Choose <strong>New > Text Document</strong></li>
  <li>A file called <code>New Text Document.txt</code> will appear – open it</li>
  <li><strong>Delete everything</strong> and copy-paste <strong>exactly</strong> these lines:</li>
</ol>

```
[EditionID]
Core
[Channel]
Retail
[VL]
0
```

!!! warning "Exact Formatting Required"
    - Do NOT add extra spaces or blank lines
    - The section names must be `[EditionID]`, `[Channel]`, and `[VL]` in square brackets
    - Each value must be on its own line
    - Save as UTF-8 or ANSI (not UTF-8 with BOM)

**Option B: Download Pre-Made File**

If you prefer not to create the file manually, you can download a ready-made `ei.cfg` file:

[📥 Download ei.cfg](assets/downloads/ei.cfg){: .md-button }

Simply:
1. Download the file above
2. Copy it to the `sources` folder on your USB
3. Skip to Step 4 below

!!! note "Pro Edition Users"
    If you're installing Pro edition, you don't need this file. You can delete any `ei.cfg` file that might already be on the USB, and proceed directly to Phase 3.

### Step 4: Save or Move the File as `ei.cfg`

If you created it manually (Option A):

<ol class="steps-list">
  <li>Press <strong>Ctrl + S</strong> or go to <strong>File > Save As</strong></li>
  <li>At the bottom, change the file type from <strong>"Text Documents (*.txt)"</strong> to <strong>"All Files (.*)"</strong></li>
  <li>Change the filename from <code>New Text Document.txt</code> to <strong><code>ei.cfg</code></strong> (no <code>.txt</code> extension)</li>
  <li>Click <strong>Save</strong></li>
</ol>

If you downloaded it (Option B):

<ol class="steps-list">
  <li>Move the downloaded <code>ei.cfg</code> file into the <code>sources</code> folder on your USB</li>
  <li>That's it – it's already in the correct format</li>
</ol>

!!! success "File in Place"
    You should now see a file called `ei.cfg` in the `sources` folder. If you see `ei.cfg.txt`, you saved it wrong – delete it and try again, making sure the file type is set to "All Files (.)".

### Step 5: Verify the File

<ol class="steps-list">
  <li>Right-click on <code>ei.cfg</code> and select <strong>Properties</strong></li>
  <li>Confirm:
    <ul>
      <li>Filename is exactly: <code>ei.cfg</code></li>
      <li>Type is: "Configuration Settings" or just "File"</li>
      <li>NOT a text file with a <code>.txt</code> extension</li>
    </ul>
  </li>
  <li>Close Properties</li>
  <li><strong>Safely eject the USB</strong> (right-click in File Explorer > Eject)</li>
</ol>

!!! tip "Keep This USB Safe"
    This USB is now customized for your device. Keep it somewhere safe – you'll use it in Phase 3 to install Windows.

**If you created an `ei.cfg` file (Home edition path):**
- The Windows installer will detect the `ei.cfg` file
- It will automatically select Home edition (instead of asking which version to install)
- Windows 11 Home will install without auto-upgrading to Pro

**If you didn't create `ei.cfg` (Pro edition path):**
- The Windows installer will proceed normally
- You'll choose Pro edition when prompted
- Continue to Phase 3

!!! note "Why This Matters"
    Whether you use Home or Pro, the key is a clean installation done offline. The `ei.cfg` technique simply saves Home users from the risk of Windows auto-upgrading to Pro during installation. All subsequent phases (4–7) work regardless of which edition you choose.

This is the key that prevents Autopilot from re-enrolling your device automatically.

!!! note "Why ei.cfg Works"
    The `ei.cfg` file is a legitimate part of Windows deployment. Microsoft's own enterprise deployment teams use it. By using it, we're telling Windows: "This is a retail (consumer) install, with Home edition only."
