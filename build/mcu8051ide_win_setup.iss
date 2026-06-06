; ============================================================
; MCU 8051 IDE - Inno Setup 6 Installer Script
; Adapted from the original mcu8051ide_win_setup.iss for the
; Windows freewrap build layout.
;
; This file is stored in the source tree and copied to build/
; during the installer build process.
; ============================================================

#define MyAppName "MCU 8051 IDE"
#define MyAppVersion "1.4.9"
#define MyAppPublisher "Martin Osmera"
#define MyAppURL "http://mcu8051ide.sf.net/"
#define MyAppExeName "mcu8051ide.exe"

[Setup]
; Unique app ID - keep consistent across versions for upgrade detection
AppId={{E0D2EFF2-AF92-403C-88F6-6188F369D6BB}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; Install directory
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes

; License
LicenseFile=data\license.txt

; Output - goes to build/ directory
OutputDir=.
OutputBaseFilename=mcu8051ide-{#MyAppVersion}-setup

; Compression - LZMA2 is the best available in Inno Setup 6
Compression=lzma2/ultra64
SolidCompression=yes

; Modern wizard style (Inno Setup 6 feature)
WizardStyle=modern

; Use mcu8051ide.ico for the installer icon (Inno Setup requires .ico format)
; Generated from mcu8051ide.png during build_exe.bat
SetupIconFile=mcu8051ide.ico

; Use mcu8051ide.png for the small wizard sidebar image (IS6 supports PNG)
WizardSmallImageFile=mcu8051ide.png

; Use the original setup_image.bmp for the large wizard banner
WizardImageFile=..\src\pkgs\Windows\setup_image.bmp

; Architecture - the freewrap exe is 32-bit, runs on both x86 and x64
ArchitecturesAllowed=x86compatible
ArchitecturesInstallIn64BitMode=x86compatible

; Privileges - admin needed for file association registry entries
PrivilegesRequired=admin

; Uninstall
UninstallDisplayName={#MyAppName}

[Registry]
; Register .mcu8051ide file extension
Root: HKCR; Subkey: ".mcu8051ide"; ValueType: string; ValueName: ""; ValueData: "MCU8051IDEProject"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "MCU8051IDEProject"; ValueType: string; ValueName: ""; ValueData: "MCU 8051 IDE project file"; Flags: uninsdeletekey
Root: HKCR; Subkey: "MCU8051IDEProject\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\mcu8051ide.ico"; Flags: uninsdeletekey
Root: HKCR; Subkey: "MCU8051IDEProject\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\mcu8051ide.exe"" ""%1"""; Flags: uninsdeletekey

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; ---- Main executable (freewrap-packaged, contains all .tcl/data/icons in VFS) ----
Source: "mcu8051ide.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "external_command.exe"; DestDir: "{app}"; Flags: ignoreversion

; ---- Icon files ----
Source: "mcu8051ide.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "mcu8051ide.png"; DestDir: "{app}"; Flags: ignoreversion

; ---- Data files (MCU definitions, tips, project DTD) ----
Source: "data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- Demo project files ----
Source: "demo\*"; DestDir: "{app}\demo"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- Translations ----
Source: "translations\*"; DestDir: "{app}\translations"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- Hardware plugins ----
Source: "hwplugins\*"; DestDir: "{app}\hwplugins"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- UI Icons ----
Source: "icons\*"; DestDir: "{app}\icons"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- Libraries (Tcl packages needed at runtime alongside the exe) ----
Source: "libraries\*"; DestDir: "{app}\libraries"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- Tcl source (lib directory - main app modules) ----
Source: "lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs

; ---- Batch scripts for external tools (ASEM-51, SDCC) ----
Source: "..\src\pkgs\Windows\startasem.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\src\pkgs\Windows\startsdcc.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\src\pkgs\Windows\external_command.bat"; DestDir: "{app}"; Flags: ignoreversion

; ---- Readme ----
Source: "..\src\pkgs\Windows\readme.txt"; DestDir: "{app}"; Flags: ignoreversion

; ---- Entry script (for reference/debugging) ----
Source: "mcu8051ide_entry.tcl"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\mcu8051ide.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\mcu8051ide.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: shellexec postinstall skipifsilent
Filename: "{app}\readme.txt"; Description: "View the README file"; Flags: postinstall shellexec skipifsilent unchecked

[UninstallDelete]
Type: filesandordirs; Name: "{app}"