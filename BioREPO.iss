[Setup]
AppName=BioREPO
AppVersion=1.0
DefaultDirName={autopf}\BioREPO
DefaultGroupName=BioREPO
OutputDir=Output
OutputBaseFilename=BioREPO_Installer
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\BioREPO"; Filename: "{app}\BioREPO.exe"
Name: "{commondesktop}\BioREPO"; Filename: "{app}\BioREPO.exe"

[Run]
Filename: "{app}\BioREPO.exe"; Description: "Ejecutar BioREPO"; Flags: nowait postinstall skipifsilent