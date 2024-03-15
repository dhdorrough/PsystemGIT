program Filer;

{%File 'Src\BiosConst.inc'}
{%File '..\FastMM\FastMM4Options.inc'}
{%File 'Listings\V4.0\PME-debug.txt'}
{%File 'FileName'}

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  Forms,
  FilerMain in 'Src\FilerMain.pas' {frmFiler},
  PsysUnit in 'Src\PsysUnit.pas',
  MyUtils in '..\MyUtils\MyUtils.pas',
  UCSDGlob in 'Src\UCSDGlob.pas',
  CrtWindow in 'Src\CrtWindow.pas' {frmCrtWindow},
  pSys_Decl in 'Src\pSys_Decl.pas',
  RenameFile in 'Src\RenameFile.pas' {frmRenameFile},
  ShowConfig in 'Src\ShowConfig.pas',
  SettingsFiles in '..\MyUtils\SettingsFiles.pas',
  GetBlockParams in 'Src\GetBlockParams.pas' {frmBlockParams},
  MyDelimitedParser in '..\MyUtils\MyDelimitedParser.pas',
  SearchForString in 'Src\SearchForString.pas' {frmSearchForString},
  Search_Decl in '..\MyUtils\Search_Decl.pas',
  Misc in 'Src\Misc.pas',
  BitOps in '..\MyUtils\BitOps.pas',
  MyTables_Decl in '..\MyUtils\MyTables_Decl.pas',
  MyTables in '..\MyUtils\MyTables.pas',
  uGetString in '..\MyUtils\uGetString.pas' {frmGetString},
  OpsTables in 'Src\OpsTables.pas',
  Interp_Decl in 'Src\Interp_Decl.pas',
  InterpIV in 'Src\InterpIV.pas',
  DirectoryListing in 'Src\DirectoryListing.pas' {frmDirectoryListing},
  DbDbUtils in 'Debugger\DbDbUtils.pas',
  pSysExceptions in 'Src\pSysExceptions.pas',
  SegMap in 'Src\segmap.pas',
  VolumeParams in 'Src\VolumeParams.pas' {frmVolumeParams},
  FilerSettingsUnit in 'Src\FilerSettingsUnit.pas',
  InterpC in 'Src\InterpC.pas',
  ProcedureMapping in 'Debugger\ProcedureMapping.pas',
  InterpII in 'Src\InterpII.pas',
  LoadVersion in 'Src\LoadVersion.pas' {frmLoadVersion},
  pSysVolumes in 'Src\pSysVolumes.pas',
  CRTUnit in 'Src\CRTUnit.pas',
  MiscinfoUnit in 'Src\MiscinfoUnit.pas',
  pSysWindow in 'Src\pSysWindow.pas' {frmPSysWindow},
  KeyShortCuts in 'Src\KeyShortCuts.pas' {frmKeyShortCuts},
  WindowsList in 'Src\WindowsList.pas',
  Interp_Common in 'Src\Interp_Common.pas',
  CRT_Decl in '..\MyUtils\CRT_Decl.pas',
  FileNames in 'Src\FileNames.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmFiler, frmFiler);
  Application.Run;
end.
