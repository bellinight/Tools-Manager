; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Tools Manager"
#define MyAppVersion "1.4"
#define MyAppPublisher "SPARK IMPULSOS"
#define MyAppURL "http://www.sparkjf.com/"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{7D6AF9D1-6397-4687-9FDA-539D3ED83813}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultGroupName={#MyAppName}
OutputDir=C:\Users\leonardo.belini\Documents\Projetos\Tools Manager\exe
OutputBaseFilename=ToolsManager[V{#MyAppVersion}]
Compression=lzma
SolidCompression=yes
UninstallFilesDir={userappdata}
UninstallDisplayName=TOOLS MANAGER
AppModifyPath={userappdata}\Processa\ToolsManager
CreateAppDir=False
UninstallDisplayIcon={uninstallexe}
SetupIconFile=userdocs:Projetos\Tools Manager\ico\pguard-logo-color.ico
SetupLogging=True

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Files]
Source: "..\Scripts\install_task.bat"; DestDir: "{userappdata}\Processa\ToolsManager"; Flags: ignoreversion
Source: "..\Scripts\ver_rem_toolkit.bat"; DestDir: "{userappdata}\Processa\ToolsManager"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "..\Scripts\remove-tools.bat"; DestDir: "{userappdata}\Processa\Scripts"
Source: "..\Scripts\ver_log.bat"; DestDir: "{userappdata}\Processa\ToolsManager"
Source: "..\Scripts\exec_verif_guard.bat"; DestDir: "{userappdata}\Processa\ToolsManager"; Flags: ignoreversion
Source: "..\Scripts\guard_alert\datasense.config"; DestDir: "{userappdata}\Processa\ToolsManager\guard_alert"; Flags: ignoreversion
Source: "..\Scripts\guard_alert\email-servico-off.ps1"; DestDir: "{userappdata}\Processa\ToolsManager\guard_alert"; Flags: ignoreversion
Source: "..\Scripts\guard_alert\email.bat"; DestDir: "{userappdata}\Processa\ToolsManager\guard_alert"; Flags: ignoreversion
Source: "..\ico\pguard-logo-color.ico"; DestDir: "{userappdata}\Processa\ToolsManager\ico"; Flags: ignoreversion
Source: "..\ico\pguard-logo-green.ico"; DestDir: "{userappdata}\Processa\ToolsManager\ico"; Flags: ignoreversion
Source: "..\ico\pguard-logo-red.ico"; DestDir: "{userappdata}\Processa\ToolsManager\ico"; Flags: ignoreversion
Source: "..\ico\pguard-logo-yellow.ico"; DestDir: "{userappdata}\Processa\ToolsManager\ico"; Flags: ignoreversion

[Icons]
Name: "{group}\Executa ProcessaGuard"; Filename: "{userappdata}\Processa\ToolsManager\exec_verif_guard.bat"; WorkingDir: "{autoappdata}"; IconFilename: "{userappdata}\Processa\ToolsManager\ico\pguard-logo-green.ico"; IconIndex: 0; Check: IsWin64; AfterInstall: SetElevationBit('{group}\Executa ProcessaGuard.lnk')
Name: "{group}\Verificar ProcessaGuard"; Filename: "{userappdata}\Processa\ToolsManager\ver_log.bat"; WorkingDir: "{autoappdata}"; IconFilename: "{userappdata}\Processa\ToolsManager\ico\pguard-logo-color.ico"; IconIndex: 0; Check: IsWin64; AfterInstall: SetElevationBit('{group}\Verificar ProcessaGuard.lnk')
Name: "{group}\Recuperar ProcessaGuard"; Filename: "{userappdata}\Processa\ToolsManager\install_task.bat"; WorkingDir: "{userappdata}"; IconFilename: "{userappdata}\Processa\ToolsManager\ico\pguard-logo-yellow.ico"; IconIndex: 0; AfterInstall: SetElevationBit('{group}\Recuperar ProcessaGuard.lnk')
;Name: "{group}\Remover ToolsManager"; Filename: "{uninstallexe}"; WorkingDir: "{userappdata}"; IconFilename: "{userappdata}\Processa\ToolsManager\ico\pguard-logo-red.ico"; IconIndex: 0

[Run]
Filename: "{userappdata}\Processa\ToolsManager\install_task.bat"; WorkingDir: "{app}"; Flags: shellexec runhidden; Description: "Instala Agendamento para Verificação"; StatusMsg: "Instalando Agenda"; Languages: brazilianportuguese

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\Processa\ToolsManager"

[UninstallRun]
Filename: "{userappdata}\Processa\Scripts\remove-tools.bat"

[Dirs]
Name: "{userappdata}\Processa\ToolsManager\log"
Name: "C:\Mercadologic\log"

[Code]
// Rodar como administrador
procedure SetElevationBit(Filename: string);
var
  Buffer: string;
  Stream: TStream;
begin
  Filename := ExpandConstant(Filename);
  Log('Setting elevation bit for ' + Filename);

  Stream := TFileStream.Create(FileName, fmOpenReadWrite);
  try
    Stream.Seek(21, soFromBeginning);
    SetLength(Buffer, 1);
    Stream.ReadBuffer(Buffer, 1);
    Buffer[1] := Chr(Ord(Buffer[1]) or $20);
    Stream.Seek(-1, soFromCurrent);
    Stream.WriteBuffer(Buffer, 1);
  finally
    Stream.Free;
  end;
end;
