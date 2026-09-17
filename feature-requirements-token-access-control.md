# Feature Requirements: Token-Based Access Control for Desktop App & Company Products

## 1. Overview

We have a desktop application that gives users access to our company's digital products and services (internal websites/tools). Currently, install-time verification uses OTP only. We need to add:

1. Password verification during install (in addition to existing OTP).
2. Per-user/per-device token issuance at install/registration time.
3. Token-based gating: the desktop app only allows users to access company websites/URLs if their token is valid.
4. Centralized admin control: admin can revoke or rotate a specific user's/device's token at any time.
5. When a user's token is revoked/invalid, they cannot access sites and must submit an **activation request**. Only after admin approval does their desktop app receive a new valid token.
6. Full audit trail of all token/activation/revocation events.

This is a **per-user/per-device** token model — NOT a single shared token for all users. Revoking or rotating one user's/device's token must not affect any other user.

---

## 2. Existing System (context for implementation)

- Desktop app already exists.
- Desktop app backend already exists in **Go**, centrally hosted at:
  `https://armssgateway.arminfo.in/api/v1/...`
  (confirmed NOT local/localhost — it's a shared central server all desktop app instances connect to).
- Existing REST structure follows `/api/v1/...` versioning.
- Install process is built with **Inno Setup** (Pascal Script), and currently performs **OTP verification** during install via a helper mechanism (helper exe/DLL calling the backend).
- Need to add a **password verification step** into the same Inno Setup install flow, immediately after OTP.

Antigravity should inspect the existing codebase structure, existing handler/router patterns, existing migration tooling, and existing OTP verification implementation in Inno Setup before writing new code, and match those conventions rather than introducing new patterns.

---

## 3. Functional Requirements

### 3.1 Install-Time Verification (Inno Setup)

- [x] Add a new custom wizard page for **password verification**, appearing immediately after the existing OTP verification page.
- [x] Password is verified via a backend API call (reuse the same helper exe/DLL mechanism currently used for OTP verification — same pattern, different endpoint/flag).
- [x] Block "Next" button and show an error message if password verification fails.
- [x] After BOTH OTP and password succeed:
  - Generate/collect a unique `device_id` for this installation (hardware fingerprint or generated UUID persisted locally).
  - Call backend to **register the device** (`/api/v1/devices/register`) linked to the verified `user_id`.
  - Backend issues the **first token** for this `user_id + device_id` pair.
  - Store the returned token securely on the local machine (OS-native secure storage — Windows Credential Manager/DPAPI preferred over plain config file).
- [x] Do not hardcode API URLs/secrets directly in the Inno Setup script; keep them in the helper exe's config.

### 3.2 Token Model (Per-User/Per-Device)

- [x] Each token is uniquely tied to a specific `user_id` + `device_id` pair — NOT a single global/shared token.
- [x] Each token has a `token_version` / status (`active`, `revoked`, `pending`).
- [x] Revoking or rotating one user's/device's token must have **zero effect** on any other user's/device's token.
- [x] A user with multiple installs (multiple devices) has a separate token/row per device — admin can revoke one device without affecting the user's other devices.
- [x] Tokens should be signed/verifiable (JWT) or opaque random tokens with server-side hash storage — raw tokens must never be stored in plaintext in the database.

### 3.3 Site/URL Access Gating (Desktop App)

- [x] Before opening any company website/product URL, the desktop app must call `/api/v1/auth/validate-token` with its stored token.
- [x] Validation must always happen **server-side** on every check — the app must never locally decide a token is valid based only on local data (e.g., a locally stored expiry date). Local caching of "last known good" state is allowed only as a fallback UX for brief network loss, not as a substitute for the real check.
- [x] If validation succeeds: allow navigation to the requested URL.
- [x] If validation fails (revoked / expired / wrong version): block navigation and show an "Access Revoked" screen with a **"Request Activation"** action.
- [x] Determine whether URLs open in an **embedded webview** (within the desktop app) or the **user's system browser**, since this affects how the token is passed to the destination site:
  - Embedded webview → token can be passed via custom header or cookie set before navigation.
  - System browser → token must be passed via a **short-lived, single-use signed URL parameter** (expires quickly, e.g. 60 seconds) since URLs can be logged/cached/shared/bookmarked.

### 3.4 Activation Request Flow

- [x] When token validation fails, the desktop app shows a **"Request Activation"** button.
- [x] Clicking it calls `/api/v1/auth/request-activation` with `user_id`, `device_id`, and the domain/URL that was blocked. This creates a pending record in `activation_requests`.
- [x] Desktop app then shows a **"Check Activation Status"** (a.k.a. "Activate") button — a manual, user-triggered pull rather than push/WebSocket.
- [x] Clicking "Check Activation Status" calls `/api/v1/auth/check-activation`:
  - If still pending → show "Waiting for admin approval."
  - If approved → backend returns the new token; app stores it securely and retries the previously blocked site access.
  - If rejected → show rejection reason if provided.
- [ ] Optional (nice-to-have, not blocking for v1): silently re-check activation status automatically on app launch/focus, so users don't have to remember to click if they forget.
- [x] Pending activation requests should auto-expire after a configurable time period (e.g. 7 days) so stale requests don't linger indefinitely in the admin queue.

### 3.5 Admin Capabilities

- [x] Admin can view a list of all users/devices and their current token status.
- [x] Admin can **revoke** a specific user's/device's token individually (bumps that row's `token_version`/status only — no global effect).
- [x] Admin can view a queue of **pending activation requests** (user, device, domain requested, timestamp).
- [x] Admin can **approve** or **reject** a specific pending activation request.
- [x] On approval, a new active token is generated for that specific `user_id + device_id` and made available for the app to pull via `check-activation`.
- [x] (If not already existing) Admin actions must be protected by existing admin-role authentication/authorization used elsewhere in the backend.

### 3.6 Audit Trail

- [x] Every state-changing action must be logged with timestamp, actor, and target:
  - Device registered (install time)
  - Token issued / rotated
  - Token revoked (by which admin)
  - Activation requested (by which user/device, for which domain)
  - Activation approved/rejected (by which admin)
- [x] Logs should be queryable by `user_id` and/or `device_id` for support/compliance purposes.

### 3.7 Multi-Product Enforcement (Other Company Web Products)

- [ ] For real security (not just app-level convenience gating), each company web product (PHP, React+backend, Python, etc.) that is reachable independent of the desktop app should also validate the token server-side before serving protected pages, by calling the same central `/api/v1/auth/validate-token` endpoint over plain HTTP(S).
- [ ] No language-specific SDK is required — a plain HTTP call to the central Go service is sufficient for all stacks (PHP, Python, React's backend, etc.). Optional thin convenience wrapper packages per language may be added later purely to reduce boilerplate; this is NOT required for v1.
- [ ] For React (client-side/SPA) products: validation must happen on whatever backend/API serves that product, never purely client-side in the browser, since browser-side checks can be bypassed.
- [ ] This requirement (3.7) is out of scope for the initial build phase and should be scheduled after the desktop app + central backend + admin flow (3.1–3.6) are complete and tested. Flag clearly in implementation as "Phase 2."

---

## 4. Data Model (Go Backend)

Extend the existing central Go backend/database with the following new tables (match existing migration tooling/style already used in the repo):

```
users                        (existing — link new tables to it via user_id FK)
 ├─ user_id (PK)
 ├─ ...existing fields...

devices
 ├─ device_id (PK)
 ├─ user_id (FK -> users)
 ├─ machine_fingerprint
 ├─ created_at

tokens
 ├─ token_id (PK)
 ├─ user_id (FK -> users)
 ├─ device_id (FK -> devices)
 ├─ token_version (int)
 ├─ status (active | revoked | pending)
 ├─ token_hash (never store raw token)
 ├─ issued_at
 ├─ expires_at (nullable, optional TTL)

activation_requests
 ├─ request_id (PK)
 ├─ user_id (FK -> users)
 ├─ device_id (FK -> devices)
 ├─ domain_requested
 ├─ requested_at
 ├─ status (pending | approved | rejected)
 ├─ approved_by (admin user_id, nullable)
 ├─ approved_at (nullable)

audit_log
 ├─ log_id (PK)
 ├─ event_type (device_registered | token_issued | token_revoked | activation_requested | activation_approved | activation_rejected)
 ├─ user_id (FK, nullable)
 ├─ device_id (FK, nullable)
 ├─ actor (system | admin_id)
 ├─ metadata (JSON — free-form details)
 ├─ created_at
```

---

## 5. API Endpoints (Go Backend — `https://armssgateway.arminfo.in/api/v1/...`)

| Method | Endpoint | Purpose | Auth |
|---|---|---|---|
| POST | `/auth/verify-otp` | (existing) verify OTP during install | none/temp session |
| POST | `/auth/verify-password` | new — verify password during install | none/temp session |
| POST | `/devices/register` | new — register device + issue first token after OTP+password success | verified install session |
| POST | `/auth/validate-token` | new — check if a user/device token is currently active | token in request |
| POST | `/auth/request-activation` | new — user requests activation after being blocked | token or user/device id |
| GET | `/auth/check-activation` | new — poll/pull for activation approval status + new token | user/device id |
| GET | `/admin/devices` | new — list all users/devices + token status | admin auth |
| POST | `/admin/devices/{device_id}/revoke` | new — revoke a specific device's token | admin auth |
| GET | `/admin/requests` | new — list pending activation requests | admin auth |
| POST | `/admin/requests/{request_id}/approve` | new — approve a pending request, issue new token | admin auth |
| POST | `/admin/requests/{request_id}/reject` | new — reject a pending request | admin auth |

Exact request/response JSON shapes to be finalized during implementation — should follow the same conventions as existing endpoints in the backend (error format, response envelope, etc.).

---

## 6. Desktop App Changes

- [x] Secure local token storage (OS-native: Credential Manager/DPAPI on Windows, Keychain on macOS, libsecret on Linux — match whatever the desktop app's platform/framework is).
- [x] Token validation call before opening any gated site/URL.
- [x] "Access Revoked" screen with "Request Activation" button when validation fails.
- [x] "Check Activation Status" button that pulls new token on approval.
- [x] Store and replace token locally after successful activation.
- [ ] (Optional, phase 2) Silent activation-status check on app launch/focus.

---

## 7. Security Notes (do not skip)

- Raw tokens must never be logged or stored in plaintext server-side — store a hash, compare hashes.
- All admin endpoints must require existing admin-role authentication.
- Token validation must always be a live server-side check, never a purely local/offline decision.
- If URLs open in the system browser, use short-lived, single-use signed tokens in the URL rather than long-lived tokens, to reduce exposure via browser history/logs.
- Bind tokens to `device_id`/machine fingerprint where possible, so a copied token can't simply be reused on a different machine.
- Auth/crypto/signing code (token generation, JWT signing, password/OTP verification) should get a manual human code review — do not rely solely on AI-generated code for these paths.

---

## 8. Monthly OTP Re-Verification

In addition to install-time OTP + password verification, every device must be periodically re-verified via OTP on a recurring (monthly, 30-day) cycle. This is separate from the admin revoke/activation flow — it is a routine, fully self-service check, not an admin-approval gate.

### 8.1 How the cycle is tracked

- [x] Add `last_otp_verified_at` (timestamp) to the `devices` table.
- [x] Set `last_otp_verified_at` = install completion time when the device is first registered (Section 3.1).
- [x] No cron/scheduled job is required — the check happens live, on demand.

### 8.2 How expiry is detected

- [x] On every `POST /api/v1/auth/validate-token` call (the same call the desktop app already makes before opening any product URL), the backend must also check `last_otp_verified_at` against the current time.
- [x] If `now - last_otp_verified_at > 30 days`, the backend responds:
  ```json
  { "valid": false, "reason": "otp_reverification_required" }
  ```
  This is a distinct reason code from `"revoked_by_admin"` or `"expired_token"`, so the desktop app can show the correct screen for each case.
- [x] This check is fully live/server-side — no separate background job needed, since it piggybacks on the validate-token call that already happens before every site access.

### 8.3 Unlock flow (Option A — self-service, no admin approval needed)

- [x] When the app receives `reason: "otp_reverification_required"`, it shows a **"Monthly Verification Required"** screen (visually distinct from the "Access Revoked / Request Activation" screen used for admin revocations).
- [x] User clicks **"Send OTP"** → app calls backend to send an OTP to the user's registered email/phone, reusing the same OTP-send mechanism already built for install-time verification.
- [x] User enters the OTP in-app → app calls a verify endpoint (reuse existing OTP verification logic, or add a thin wrapper: `POST /api/v1/auth/monthly-reverify`).
- [x] On successful verification:
  - Backend updates `devices.last_otp_verified_at` = now.
  - Backend responds success; app automatically retries the originally blocked site access.
- [x] No admin action or approval queue is involved in this flow — it is fully automatic/self-service, distinct from the activation-request flow used for revocations.
- [x] Failed OTP attempts should follow the same retry/lockout rules already in place for install-time OTP (e.g. max attempts, resend cooldown) — reuse existing logic rather than building new rules.

### 8.4 Admin visibility (monitoring only)

- [x] Admin dashboard should display each device's `last_otp_verified_at` and current lock state (for support/monitoring purposes), but does **not** need to take any action for this flow — it's informational only.

### 8.5 Data model addition

```
devices
 ├─ device_id (PK)
 ├─ user_id (FK -> users)
 ├─ machine_fingerprint
 ├─ created_at
 ├─ last_otp_verified_at   -- NEW: set at install, updated on each successful monthly re-verification
```

### 8.6 Endpoint addition

| Method | Endpoint | Purpose | Auth |
|---|---|---|---|
| POST | `/auth/monthly-reverify` | new (or reuse existing OTP verify endpoint) — verify OTP and refresh `last_otp_verified_at` | device/user id |

### 8.7 Audit trail addition

- [x] Log `otp_reverification_success` and `otp_reverification_failed` events in `audit_log`, same as other events (Section 4).

---

## 9. Build Order / Milestones (for Antigravity, one feature per session)

1. Database migrations: `devices`, `tokens`, `activation_requests`, `audit_log` tables.
2. Backend: `/devices/register` + `/auth/verify-password` (extends existing OTP verification pattern).
3. Backend: `/auth/validate-token`.
4. Backend: `/auth/request-activation` + `/auth/check-activation`.
5. Backend: Admin endpoints (`/admin/devices`, `/admin/devices/{id}/revoke`, `/admin/requests`, `/admin/requests/{id}/approve`, `/admin/requests/{id}/reject`).
6. Desktop app: secure token storage + validate-before-open logic.
7. Desktop app: "Access Revoked" + "Request Activation" + "Check Activation Status" UI/flow.
8. Inno Setup: add password verification page after OTP page; wire up device registration + first token issuance at end of install.
9. Admin dashboard: list devices/token status, list pending requests, approve/reject/revoke actions.
10. Backend: add `last_otp_verified_at` field + check inside `validate-token` + `monthly-reverify` endpoint (Section 8).
11. Desktop app: "Monthly Verification Required" screen + Send OTP / Enter OTP / Verify flow.
12. (Phase 2, later) Add token validation calls into other company web products (PHP/React/Python) reachable independently of the desktop app.

---

## 10. Out of Scope for V1

- Push notifications / WebSocket-based instant token delivery (deliberately using manual pull + button instead).
- Per-language SDKs/packages for other products (plain HTTP call is sufficient for now).
- Enforcement inside other company web products (Phase 2, scheduled after core system is stable).
