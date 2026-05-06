[Setup]
AppName=FTP VPN Client
AppVersion={#AppVersion}
AppPublisher=FTPVPN
AppPublisherURL=https://ftpvpn.lol
AppSupportURL=https://ftpvpn.lol
AppUpdatesURL=https://github.com/dlyaplatmrkt/ftp-client/releases
DefaultDirName={autopf}\FTP VPN Client
DefaultGroupName=FTP VPN Client
AllowNoIcons=yes
OutputBaseFilename=FTPVPNClient-Setup-v{#AppVersion}
SetupIconFile=
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\FTP VPN Client"; Filename: "{app}\ftp_client.exe"
Name: "{group}\{cm:UninstallProgram,FTP VPN Client}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\FTP VPN Client"; Filename: "{app}\ftp_client.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\ftp_client.exe"; Description: "{cm:LaunchProgram,FTP VPN Client}"; Flags: nowait postinstall skipifsilent
