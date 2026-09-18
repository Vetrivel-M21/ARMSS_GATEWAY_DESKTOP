# ARMSS Gateway Desktop (Windows)

ARMSS Gateway Desktop provides financial ledger management, multi-portal application switching, centralized online authentication, hardware token access control, and seamless in-app auto-updating for Windows 10/11 (x64).

---

## 1. Prerequisites

Before building the Windows desktop application and installer, verify that your development environment has:

1. **Flutter SDK** (v3.13.1 or higher):
   ```powershell
   flutter doctor
   ```
2. **Visual Studio 2022** (Community, Professional, or Enterprise):
   - Workload installed: **Desktop development with C++**
   - Components installed: MSVC v143 toolset, Windows 10/11 SDK, C++ CMake tools for Windows.
3. **Inno Setup 6** (Free open-source Windows installer compiler):
   - Installed to: `%LocalAppData%\Programs\Inno Setup 6\ISCC.exe` or `C:\Program Files (x86)\Inno Setup 6\ISCC.exe`.
4. **Visual C++ Redistributable Runtime**:
   - `vc_redist.x64.exe` must exist at `windows\installer\prerequisites\vc_redist.x64.exe` (bundled automatically by the installer).

---

## 2. Step-by-Step Release & Installer Build Guide

### Step 1: Install Dependencies
Open a PowerShell terminal in the `mis_desktop` root folder:
```powershell
flutter pub get
```

### Step 2: Compile the Windows Release Binary
Compile the native 64-bit Windows executable:
```powershell
flutter build windows --release
```
- **Release Output Directory**: `build\windows\x64\runner\Release\`
- **Generated Executable**: `armss_gateway.exe`

### Step 3: Compile the Windows Installer (`.exe`)
Run the Inno Setup command-line compiler:
```powershell
& "$env:LocalAppData\Programs\Inno Setup 6\ISCC.exe" windows\installer\mis_desktop.iss
```
*(If Inno Setup was installed system-wide, use `& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\installer\mis_desktop.iss`)*

- **Final Installer Path**: `windows\installer\Output\ARMSS_Gateway_Setup.exe`
- **Output File Size**: ~35.7 MB (includes Flutter runtime, native DLLs, assets, and Visual C++ Redistributable)

---

## 3. Generating the SHA-256 Checksum

To prevent download corruption or tampering, every desktop release requires an exact SHA-256 hash.

Run this PowerShell command inside `mis_desktop`:
```powershell
Get-FileHash "windows\installer\Output\ARMSS_Gateway_Setup.exe" -Algorithm SHA256
```

**Example Output:**
```
Algorithm       Hash                                                             Path
---------       ----                                                             ----
SHA256          4E2D36F18A34B88232684BD09EDA70FC66C4ACEF6C44FC2AB2A4CA793A9A631D   ...\ARMSS_Gateway_Setup.exe
```

Copy the 64-character hash string.

---

## 4. Configuring Backend Auto-Update Server (`armss_gateway_backend`)

To deliver this update automatically to installed desktop clients:

1. Copy `ARMSS_Gateway_Setup.exe` to your server file storage (e.g. `/opt/armss/ARMSS_Gateway_Setup.exe`).
2. Open `.env` in `armss_gateway_backend` and update the desktop update parameters:

```env
# Desktop auto-update metadata
APP_UPDATE_VERSION=1.1.2
APP_UPDATE_URL=https://armssgateway.arminfo.in/api/v1/app/download
APP_UPDATE_SHA256=<PASTE_THE_SHA256_HASH_HERE>
APP_UPDATE_FILE=/opt/armss/ARMSS_Gateway_Setup.exe
```

3. Restart the backend service:
```bash
sudo systemctl restart armss-gateway-backend
```

---

## 5. How Desktop In-App Auto-Update Works

1. **Manifest Query**: On launch, the desktop app calls `GET /api/v1/app/update`.
2. **Version Comparison**: Compares the server's version against the installed app version.
3. **Integrity Validation**: When a newer version is found, it downloads the installer to `%TEMP%`, calculates the SHA-256 hash, and verifies it against `APP_UPDATE_SHA256`.
4. **Seamless Upgrade**: The app executes the installer with the `/UPDATE` flag:
   ```powershell
   ARMSS_Gateway_Setup_1.1.2.exe /UPDATE
   ```
   The installer replaces outdated files in `%LocalAppData%\Programs\ARMSS Gateway` and restarts the application without touching the user's local database or settings.

---

## 6. Installer Security & OTP Gate

When installing for the first time, Setup enforces a two-factor security gate:
1. Setup requests an OTP from the gateway backend (`POST /api/v1/installer/request-otp`).
2. The backend emails an OTP to the administrator (`INSTALLER_ADMIN_EMAIL`).
3. The person installing the app must obtain the code from the administrator to proceed.
4. **Secret Key Alignment**: The `#define InstallerApiSecret` in [windows/installer/mis_desktop.iss](file:///c:/Users/ARMSS%20GROUPS/Documents/MIS/mis_desktop/windows/installer/mis_desktop.iss) must match `INSTALLER_API_SECRET` in the backend's `.env`.
