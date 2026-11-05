# ARMSS Gateway v1.1.16 Setup & Installation Instructions

**Installer File Location:**
`windows\installer\Output\ARMSS_Gateway_Setup.exe`
**Version:** `1.1.16` (Build `14`)
**SHA-256 Hash:** `1A6055323724D2FD4131D14D349FF101C93E6E91F4652F0C7AD2380BA1F136BE`

---

## What's New in Version 1.1.16
1. **Logo Zoom & Expand Feature in Web Portals:**
   - Each web portal card now includes an **Expand** icon (top-left).
   - Clicking opens the portal logo in a full-screen high-resolution dialog.
   - Features mouse-wheel zooming, click-and-drag panning, double-tap zoom toggle, reset view, and an **"Open in Browser"** quick action button.
2. **Gateway Stability & Network Timeout:**
   - Gateway authentication timeout increased for reliable OTP and token verifications across all 10 platform domains without intermittent 403 blocks.
3. **Optimized Per-User Installation:**
   - No Administrator / UAC prompt required during installation.

---

## Installation Steps (User / Admin)

### Step 1: Run Setup
1. Double-click `ARMSS_Gateway_Setup.exe`.
2. *Note for Windows SmartScreen:* If Windows displays a blue prompt ("Windows protected your PC"), click **"More info"** and then click **"Run anyway"** (normal for internal/non-Store enterprise apps).

### Step 2: OTP Verification Gate
1. The installer displays the ARMSS Gateway Security Verification dialog.
2. An automatic 6-digit verification code (OTP) is sent to the registered administrator email (`noreply@arminfo.in` / admin mailbox).
3. Enter the 6-digit OTP code into Setup and click **Verify & Continue**.

### Step 3: Complete Installation
1. Setup installs files to `%LocalAppData%\Programs\ARMSS Gateway`.
2. If Microsoft Visual C++ 2015–2022 Redistributable is missing, it installs it silently.
3. Choose whether to create a Desktop shortcut and Start Menu shortcut.
4. Click **Finish** to automatically launch ARMSS Gateway.

---

## Server Deployment (For In-App Auto Updates)
To make this new installer available for automatic client updates via the background service:
1. Copy `windows\installer\Output\ARMSS_Gateway_Setup.exe` to the server:
   `/opt/armss_gateway_api/ARMSS_Gateway_Setup.exe`
2. Ensure the backend `.env` has:
   ```env
   APP_UPDATE_FILE=/opt/armss_gateway_api/ARMSS_Gateway_Setup.exe
   ```
3. Existing desktop apps will automatically download and prompt users to upgrade to `v1.1.16`.

