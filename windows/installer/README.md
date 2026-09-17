# Building the Windows installer

One-time setup: install [Inno Setup](https://jrsoftware.org/isinfo.php) (free). This adds `ISCC.exe` — depending on install options, either at `C:\Program Files (x86)\Inno Setup 6\ISCC.exe` (machine-wide) or `%LocalAppData%\Programs\Inno Setup 6\ISCC.exe` (per-user).

Then, from the `mis_desktop` project folder, for every release:

```
flutter build windows --release
"%LocalAppData%\Programs\Inno Setup 6\ISCC.exe" windows\installer\mis_desktop.iss
```

Before compiling the installer, download the official Microsoft Visual C++
2015-2022 Redistributable for x64 and place it at
`windows/installer/prerequisites/vc_redist.x64.exe`. The Windows application
uses native plugins and requires this runtime. The installer checks whether the
runtime is already installed and installs it silently when needed.

This produces `windows\installer\Output\ARMSS_Gateway_Setup.exe`.

## What the installer does

- Installs per-user to `%LocalAppData%\Programs\ARMSS Gateway` — no admin/UAC prompt required.
- Adds a Start Menu entry, and a desktop shortcut only if the user ticks "Create a desktop icon" during setup.
- Registers a normal uninstaller under Settings → Apps for the current user.
- Does **not** touch the app's database (`%APPDATA%\...\mis_desktop\mis_desktop.sqlite`), which lives outside the install folder — uninstalling and reinstalling keeps existing data intact.

Since the installer and app aren't code-signed, Windows SmartScreen may show a "Windows protected your PC" warning on first run — click "More info" → "Run anyway". This is expected for any unsigned app from outside the Microsoft Store.

## OTP install gate

Before copying any files, Setup shows a page asking for a one-time code. It requests an OTP from the Trust Management backend (`trustapi.arminfo.in`), which emails it to the configured admin address — the person running Setup has to contact the admin by phone/chat to get the code. Wrong or expired codes block the install.

This needs two things set up ahead of time:
- The backend (`trustManagement/backend`) needs `SMTP_HOST`/`SMTP_PORT`/`SMTP_USERNAME`/`SMTP_PASSWORD` (the `noreply@arminfo.in` GoDaddy mailbox), `INSTALLER_ADMIN_EMAIL`, and `INSTALLER_API_SECRET` set — see `.env.example` there.
- `mis_desktop.iss`'s `InstallerApiSecret` `#define` must be set to that same `INSTALLER_API_SECRET` value before compiling (it ships as a placeholder in source).
