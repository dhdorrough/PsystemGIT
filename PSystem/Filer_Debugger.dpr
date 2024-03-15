program Filer_Debugger;

{%File '..\FastMM\FastMM4Options.inc'}
{%File 'Listings\PME-debug.txt'}
{%File 'Debugger\PDefines.inc'}
{%File 'VisDiffStable.bat'}

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  Forms,
  FilerMain in 'Src\FilerMain.pas' {frmFiler},
  PsysUnit in 'Src\PsysUnit.pas',
  MyUtils in '..\MyUtils\MyUtils.pas',
  UCSDGlob in 'Src\UCSDGlob.pas',
  PSysWindow in 'Src\PSysWindow.pas' {frmPSysWindow},
  pSys_Decl in 'Src\pSys_Decl.pas',
  RenameFile in 'Src\RenameFile.pas' {frmRenameFile},
  ShowConfig in 'Src\ShowConfig.pas',
  SettingsFiles in '..\MyUtils\SettingsFiles.pas',
  FilerSettingsUnit in 'Src\FilerSettingsUnit.pas',
  GetBlockParams in 'Src\GetBlockParams.pas' {frmBlockParams},
  MyDelimitedParser in '..\MyUtils\MyDelimitedParser.pas',
  Search_Decl in '..\MyUtils\Search_Decl.pas',
  Misc in 'Src\Misc.pas',
  VolumeConverter in 'Src\VolumeConverter.pas',
  BitOps in '..\MyUtils\BitOps.pas',
  FilerTables in 'Src\FilerTables.pas',
  MyTables_Decl in '..\MyUtils\MyTables_Decl.pas',
  MyTables in '..\MyUtils\MyTables.pas',
  uGetString in '..\MyUtils\uGetString.pas' {frmGetString},
  OpsTables in 'Src\OpsTables.pas',
  Interp_Decl in 'Src\Interp_Decl.pas',
  LocalVariables in 'Debugger\LocalVariables.pas' {frmLocalVariables},
  uWatchInfo in 'Debugger\uWatchInfo.pas' {frmWatchInfo},
  Watch in 'Debugger\Watch.pas' {frmWatch},
  Debug_Decl in 'Debugger\Debug_Decl.pas',
  Inspector in 'Debugger\Inspector.pas' {frmInspect},
  BreakPointInfo in 'Debugger\BreakPointInfo.pas' {frmBreakPointInfo},
  pCodeDebugger in 'Debugger\pCodeDebugger.pas' {frmPCodeDebugger},
  InterpIV in 'Src\InterpIV.pas',
  SegmentProcname in 'Src\SegmentProcname.pas' {frmSegmentProcName},
  ListingUtils in 'Debugger\ListingUtils.pas',
  Watch_Decl in 'Debugger\Watch_Decl.pas',
  RawFileParams in '..\MyUtils\RawFileParams.pas' {frmRawParameters},
  pSysDatesAndTimes in 'Src\pSysDatesAndTimes.pas',
  DumpAddr in 'Src\DumpAddr.pas' {frmDumpAddr},
  SearchForString in 'Src\SearchForString.pas' {frmSearchForString},
  InterpII in 'Src\InterpII.pas',
  pSysVolumes in 'Src\pSysVolumes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmFiler, frmFiler);
  Application.CreateForm(TfrmSearchForString, frmSearchForString);
  Application.Run;
end.
