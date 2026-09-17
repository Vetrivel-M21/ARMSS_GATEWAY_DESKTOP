; Inno Setup script for ARMSS Gateway.
; Build & compile with:
;   flutter build windows --release
;   ISCC.exe windows\installer\mis_desktop.iss
; See README.md in this folder for the full process.

#define MyAppName "ARMSS Gateway"
#define MyAppVersion "1.1.2"
#define MyAppExeName "armss_gateway.exe"
#define MyReleaseDir "..\..\build\windows\x64\runner\Release"
#define VCRedistInstaller "prerequisites\vc_redist.x64.exe"

; OTP install gate: an OTP is emailed to the admin (see armss_gateway_backend's
; INSTALLER_ADMIN_EMAIL) and the installing user must enter it before Setup will
; proceed. InstallerApiSecret must match that backend's INSTALLER_API_SECRET —
; see windows/installer/README.md.
#define InstallerApiBaseUrl "https://armssgateway.arminfo.in/api/v1"
#define InstallerApiSecret "f46b48cc8a2999302ca05101385eb9219a72878f274b2cd0"

[Setup]
AppId={{7B6C9C2E-6E7B-4E9E-9E3B-6E6C6E5A5F1E}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
DisableDirPage=no
; Per-user install: no admin/UAC prompt, installs/registers under the
; current user only (HKCU), not machine-wide.
PrivilegesRequired=lowest
SetupIconFile=..\runner\resources\app_icon.ico
OutputDir=Output
OutputBaseFilename=ARMSS_Gateway_Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyReleaseDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#VCRedistInstaller}"; DestDir: "{tmp}"; Flags: deleteafterinstall noencryption

[Icons]
Name: "{userprograms}\{#MyAppName}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{userprograms}\{#MyAppName}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ Runtime..."; Verb: runas; Flags: waituntilterminated shellexec; Check: NeedVCRedist
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[Code]
var
IdentityPage: TInputQueryWizardPage;
OtpPage: TInputQueryWizardPage;
PasswordPage: TInputQueryWizardPage;
OtpRequestID: String;
OtpRequested: Boolean;
InstallerUsername: String;
InstallerDepartment: String;
InstallerBranch: String;
VerifiedUserID: String;
DeviceID: String;
DeviceToken: String;
HttpLastStatus: String;
UpdateMode: Boolean;

function NeedVCRedist: Boolean;
var
Installed: Cardinal;
begin
Result := not RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) or (Installed <> 1);
end;

function IsUpdateMode: Boolean;
var
Index: Integer;
begin
Result := False;
for Index := 1 to ParamCount do
begin
if CompareText(ParamStr(Index), '/UPDATE') = 0 then
begin
Result := True;
Exit;
end;
end;
end;

// Plain HTTPS/HTTP POST via the WinHTTP COM object built into every Windows
// machine — Inno Setup's Pascal scripting has no HTTP client of its own,
// and this avoids depending on SMTP/CDO components that may not be present
// on the installing machine.
function HttpPost(const Url, Body: String; var ResponseText: String): Boolean;
var
WinHttpReq: Variant;
begin
Result := False;
ResponseText := '';
HttpLastStatus := '';
try
WinHttpReq := CreateOleObject('WinHttp.WinHttpRequest.5.1');
WinHttpReq.Open('POST', Url, False);
// Ignore SSL certificate errors for local testing if https is used (0x3300 = SslErrorFlag_Ignore_All)
try
WinHttpReq.Option[4] := $3300;
except
end;
try
// Enable TLS 1.2 for broad compatibility with Windows WinHTTP.
WinHttpReq.Option[9] := $0800;
except
end;
WinHttpReq.SetRequestHeader('Content-Type', 'application/json');
WinHttpReq.SetRequestHeader('X-Installer-Secret', '{#InstallerApiSecret}');
WinHttpReq.Send(Body);
HttpLastStatus := IntToStr(WinHttpReq.Status);
ResponseText := WinHttpReq.ResponseText;
Result := (WinHttpReq.Status >= 200) and (WinHttpReq.Status < 300);
except
HttpLastStatus := 'transport error';
Result := False;
end;
end;

// The backend's responses are small and predictable (e.g. {"success":true,
// "data":{"request_id":"..."}}), so plain substring search is enough —
// no need to pull in a JSON library for one field at a time.
function ExtractJsonStringField(const Json, FieldName: String): String;
var
SearchKey: String;
StartPos, EndPos: Integer;
begin
Result := '';
SearchKey := '"' + FieldName + '":"';
StartPos := Pos(SearchKey, Json);
if StartPos = 0 then Exit;
StartPos := StartPos + Length(SearchKey);
EndPos := Pos('"', Copy(Json, StartPos, Length(Json) - StartPos + 1));
if EndPos = 0 then Exit;
Result := Copy(Json, StartPos, EndPos - 1);
end;

function ExtractJsonIntField(const Json, FieldName: String): String;
var
SearchKey: String;
StartPos, EndPos: Integer;
begin
Result := '';
SearchKey := '"' + FieldName + '":';
StartPos := Pos(SearchKey, Json);
if StartPos = 0 then Exit;
StartPos := StartPos + Length(SearchKey);
EndPos := StartPos;
while (EndPos <= Length(Json)) and (Json[EndPos] >= '0') and (Json[EndPos] <= '9') do
EndPos := EndPos + 1;
Result := Copy(Json, StartPos, EndPos - StartPos);
end;

function ExtractJsonBoolField(const Json, FieldName: String): Boolean;
begin
Result := Pos('"' + FieldName + '":true', Json) > 0;
end;

function JsonEscape(const Value: String): String;
begin
Result := Value;
StringChangeEx(Result, '\', '\\', True);
StringChangeEx(Result, '"', '\"', True);
end;

function GenerateDeviceId: String;
var
DT: String;
begin
DT := GetDateTimeString('yyyymmddhhnnss', #0, #0);
Result := 'dev_' + DT + '_' + IntToStr(Random(1000000)) + IntToStr(Random(1000000));
end;

procedure SaveDeviceCredentials(const DevID, DevToken: String);
var
ConfigDir, ConfigFile, JsonContent: String;
begin
ConfigDir := ExpandConstant('{localappdata}\ARMSS Gateway');
ForceDirectories(ConfigDir);
ConfigFile := ConfigDir + '\device_auth.json';
JsonContent := '{"device_id":"' + DevID + '","device_token":"' + DevToken + '"}';
SaveStringToFile(ConfigFile, JsonContent, False);
end;

procedure InitializeWizard;
begin
UpdateMode := IsUpdateMode;
IdentityPage := CreateInputQueryPage(wpWelcome,
'Installation Details', 'Identify the person and installation',
'Enter these details before requesting the OTP. They will be included in the administrator notification.');
IdentityPage.Add('Username:', False);
IdentityPage.Add('Department:', False);
IdentityPage.Add('Branch:', False);

OtpPage := CreateInputQueryPage(IdentityPage.ID,
'Verify Installation', 'Enter the OTP provided by your administrator',
'An OTP has been emailed to the administrator with the username, department, and branch entered on the previous page.');
OtpPage.Add('OTP:', False);

PasswordPage := CreateInputQueryPage(OtpPage.ID,
'Verify Password', 'Enter the installation password',
'Enter the central installation password to authorize and register this device.');
PasswordPage.Add('Installation Password:', True);
end;

procedure CurPageChanged(CurPageID: Integer);
var
ResponseText: String;
begin
if CurPageID = IdentityPage.ID then
begin
OtpRequested := False;
OtpRequestID := '';
end
else if (CurPageID = OtpPage.ID) and (not OtpRequested) then
begin
InstallerUsername := Trim(IdentityPage.Values[0]);
InstallerDepartment := Trim(IdentityPage.Values[1]);
InstallerBranch := Trim(IdentityPage.Values[2]);
if HttpPost('{#InstallerApiBaseUrl}/installer/request-otp',
'{"username":"' + JsonEscape(InstallerUsername) + '","department":"' + JsonEscape(InstallerDepartment) + '","branch":"' + JsonEscape(InstallerBranch) + '"}', ResponseText) then
OtpRequestID := ExtractJsonStringField(ResponseText, 'request_id');
if OtpRequestID <> '' then
OtpRequested := True
else
MsgBox('Could not request an OTP from the verification server (HTTP ' + HttpLastStatus + '). Check your internet connection and try again.', mbError, MB_OK);
end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
ResponseText, Otp, Password, Body: String;
begin
Result := True;

if CurPageID = IdentityPage.ID then
begin
InstallerUsername := Trim(IdentityPage.Values[0]);
InstallerDepartment := Trim(IdentityPage.Values[1]);
InstallerBranch := Trim(IdentityPage.Values[2]);
if (InstallerUsername = '') or (InstallerDepartment = '') or (InstallerBranch = '') then
begin
MsgBox('Username, department, and branch are required before requesting the OTP.', mbError, MB_OK);
Result := False;
end;
end
else if CurPageID = OtpPage.ID then
begin
Otp := Trim(OtpPage.Values[0]);
if (OtpRequestID = '') or (Otp = '') then
begin
MsgBox('Please enter the OTP sent to your administrator.', mbError, MB_OK);
Result := False;
Exit;
end;
Body := '{"request_id":"' + OtpRequestID + '","otp":"' + Otp + '"}';
Result := HttpPost('{#InstallerApiBaseUrl}/installer/verify-otp', Body, ResponseText) and ExtractJsonBoolField(ResponseText, 'valid');
if not Result then
MsgBox('That OTP is incorrect or has expired. Check with your administrator and try again.', mbError, MB_OK);
end
else if CurPageID = PasswordPage.ID then
begin
Password := PasswordPage.Values[0];
if Password = '' then
begin
MsgBox('Please enter the installation password.', mbError, MB_OK);
Result := False;
Exit;
end;

Body := '{"password":"' + Password + '"}';
if HttpPost('{#InstallerApiBaseUrl}/installer/verify-password', Body, ResponseText) and ExtractJsonBoolField(ResponseText, 'valid') then
begin
VerifiedUserID := ExtractJsonIntField(ResponseText, 'user_id');
if VerifiedUserID = '' then
VerifiedUserID := ExtractJsonStringField(ResponseText, 'user_id');
if VerifiedUserID = '' then
VerifiedUserID := '1';

// Generate unique device id and register device
DeviceID := GenerateDeviceId;
Body := '{"user_id":' + VerifiedUserID + ',"device_id":"' + DeviceID + '","machine_fingerprint":"' + GetComputerNameString + '"}';
if HttpPost('{#InstallerApiBaseUrl}/devices/register', Body, ResponseText) then
begin
DeviceToken := ExtractJsonStringField(ResponseText, 'token');
if DeviceToken <> '' then
begin
SaveDeviceCredentials(DeviceID, DeviceToken);
Result := True;
end
else
begin
MsgBox('Registration succeeded but no device token was received from the server. Please contact your administrator.', mbError, MB_OK);
Result := False;
end;
end
else
begin
MsgBox('Could not register device with the server. Check your network connection and try again.', mbError, MB_OK);
Result := False;
end;
end
else
begin
MsgBox('Invalid installation password. Please check your password and try again.', mbError, MB_OK);
Result := False;
end;
end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
Result := UpdateMode and ((PageID = IdentityPage.ID) or (PageID = OtpPage.ID) or (PageID = PasswordPage.ID));
end;