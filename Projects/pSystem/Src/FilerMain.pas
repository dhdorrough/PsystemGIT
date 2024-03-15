
{$Undef FastMM}
// WARNING: transfer to pSystem does not copy if file already exists
unit FilerMain;

interface

uses
  Windows, Messages, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, PsysUnit, StdCtrls, InterpII, InterpIV, pSys_Decl, PSysWindow,
  SearchForString,
  Search_Decl,
  ShellAPI,
  DirectoryListing, pSysVolumes, Interp_Decl, Interp_Common, WindowsList, DiskFormatUtils,
  CrtUnit, Interp_Const,
  LoadVersion, SyscomEditor, MyMessages;

const
  DEFAULT_BOOT_VOLUME = 4;

type

  TOnKeyDown  = procedure {OnKeyDown}(Sender: TObject; var Key: Word; Shift: TShiftState) of object;
  TOnKeyPress = procedure {OnKeyPress}(Sender: TObject; var Key: Char) of object;
  TOnKeyUp    = procedure {OnKeyUp}(Sender: TObject; var Key: Word; Shift: TShiftState) of object;

  TMountResult = (mrUnknown, mrMounted, mrAlreadyMounted, mrFailed);

  TSearchResult = (sr_Unknown, sr_EOF, sr_Found, sr_NotInBuffer);

  TDirectoryOutput = (doMemo, doStringGrid);

  TfrmFiler = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Memo1: TMemo;
    N1: TMenuItem;
    Exit1: TMenuItem;
    CopySingleFile1: TMenuItem;
    SetDOSPath1: TMenuItem;
    CopyAllFiles1: TMenuItem;
    CopyTextFileasBinary1: TMenuItem;
    CopyAllFilesinBinary1: TMenuItem;
    OpenDialog1: TOpenDialog;
    CopyAllTextFiles1: TMenuItem;
    pSystem1: TMenuItem;
    Boot1: TMenuItem;
    CopyfrompSys1: TMenuItem;
    CopytopSys1: TMenuItem;
    CopyTextfilefromDOS1: TMenuItem;
    N2: TMenuItem;
    lblStatus: TLabel;
    DeleteFile1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    RenamepSysFile1: TMenuItem;
    CopyBinaryfilefromDOS1: TMenuItem;
    SearchManyVolumes1: TMenuItem;
    Utilities1: TMenuItem;
    SetCurrentUnit1: TMenuItem;
    ScanRawVolume1: TMenuItem;
    CopyDataRange1: TMenuItem;
    miTextFile1: TMenuItem;
    miTextFile2: TMenuItem;
    SaveDialog1: TSaveDialog;
    Edit1: TMenuItem;
    Find1: TMenuItem;
    N6: TMenuItem;
    ClearWindow1: TMenuItem;
    N7: TMenuItem;
    SaveDialog2: TSaveDialog;
    OpenDialog2: TOpenDialog;
    FindStringinWindow1: TMenuItem;
    FindDialog1: TFindDialog;
    FindAgain1: TMenuItem;
    VolumeConversions1: TMenuItem;
    SaveDialog3: TSaveDialog;
    ScanRawFile1: TMenuItem;
    ExtractRawFile1: TMenuItem;
    Volumes1: TMenuItem;
    MountedVolumes1: TMenuItem;
    NewVolume1: TMenuItem;
    ResizeVolume1: TMenuItem;
    Directories1: TMenuItem;
    Directory0: TMenuItem;
    BriefDirectory1: TMenuItem;
    ListDirectory1: TMenuItem;
    MountVolume1: TMenuItem;
    MountVolSubsidiaryVolume1: TMenuItem;
    MountSubVolonCurrent1: TMenuItem;
    DirectorytoGrid1: TMenuItem;
    AlphaSort2: TMenuItem;
    DateSort1: TMenuItem;
    FileSize1: TMenuItem;
    Unsorted1: TMenuItem;
    RecentVolumes1: TMenuItem;
    REMountCurrentUnit1: TMenuItem;
    SelectedVolumes1: TMenuItem;
    SelectedVolumes2: TMenuItem;
    UnmountAll1: TMenuItem;
    SaveListofMountedVolumes1: TMenuItem;
    MountVolumesfromSavedList1: TMenuItem;
    SetFilter1: TMenuItem;
    SelectedVolume1: TMenuItem;
    SearchVolumes1: TMenuItem;
    miSearchMountedVolumes: TMenuItem;
    ZeroVolume1: TMenuItem;
    ClosepSystemWindow1: TMenuItem;
    CopyallCODEfiles1: TMenuItem;
    Settings1: TMenuItem;
    N8: TMenuItem;
    btnAbort: TButton;
    MountNonStandardVolume1: TMenuItem;
    CopyfrompSystopSys1: TMenuItem;
    ExtractFilefromRawVolume1: TMenuItem;
    GuessTermType: TMenuItem;
    Debug1: TMenuItem;
    Miscellaneous1: TMenuItem;
    GuessVolumeFormat1: TMenuItem;
    CleanVolumeforprevers41: TMenuItem;
    SegmentMapSEGMAP1: TMenuItem;
    CompareVolumes1: TMenuItem;
    EnableExternalPool1: TMenuItem;
    Dumpopcodesfile1: TMenuItem;
    N9: TMenuItem;
    EditpSystemTextFile1: TMenuItem;
    ChangeSyscom1: TMenuItem;
    ConfigureCodePoolInfo1: TMenuItem;
    ChangeScreenSize1: TMenuItem;
    DebuggerSettings1: TMenuItem;
    N10: TMenuItem;
    BoorParameters: TMenuItem;
    MaintainBootParameters1: TMenuItem;
    PrintBootParameters1: TMenuItem;
    N5: TMenuItem;
    RebootLastSystem1: TMenuItem;
    ChangeFileTypeforFile1: TMenuItem;
    procedure MountVolume1Click(Sender: TObject);
    procedure Directory0Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure BriefDirectory1Click(Sender: TObject);
    procedure ListDirectory1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure CopySingleFile1Click(Sender: TObject);
    procedure SetDOSPath1Click(Sender: TObject);
    procedure CopyAllFiles1Click(Sender: TObject);
    procedure CopyTextFileasBinary1Click(Sender: TObject);
    procedure CopyAllFilesinBinary1Click(Sender: TObject);
    procedure SetFilter1Click(Sender: TObject);
    procedure CopyAllTextFiles1Click(Sender: TObject);
    procedure pSystem1Click(Sender: TObject);
    procedure MountedVolumes1Click(Sender: TObject);
    procedure CopyTextfilefromDOS1Click(Sender: TObject);
    procedure UnmountVolume1Click(Sender: TObject);
    procedure DeleteFile1Click(Sender: TObject);
    procedure RenamepSysFile1Click(Sender: TObject);
    procedure CopyBinaryfilefromDOS1Click(Sender: TObject);
    procedure SearchManyVolumes1Click(Sender: TObject);
    procedure NewVolume1Click(Sender: TObject);
    procedure ResizeVolume1Click(Sender: TObject);
    procedure Dumpopcodesfile1Click(Sender: TObject);
    procedure SetCurrentUnit1Click(Sender: TObject);
    procedure ScanRawVolume1Click(Sender: TObject);
    procedure EditpSystemTextFile1Click(Sender: TObject);
    procedure RefreshCurrentUnit1Click(Sender: TObject);
    procedure UnitRead1Click(Sender: TObject);
    procedure miTextFile1Click(Sender: TObject);
    procedure miTextFile2Click(Sender: TObject);
    procedure MountSubsidiaryVolume1ClickMountSubsidiaryVolume1Click(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure ClearWindow1Click(Sender: TObject);
    procedure SaveListofMountedVolumes1Click(Sender: TObject);
    procedure MountVolumesfromSavedList1Click(Sender: TObject);
    procedure FindStringinWindow1Click(Sender: TObject);
    procedure FindAgain1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure VolumeConversionClick(Sender: TObject);
    procedure ScanRawFile1Click(Sender: TObject);
    procedure ExtractRawFile1Click(Sender: TObject);
    procedure MountSubVolonCurrent1Click(Sender: TObject);
    procedure AlphaSort2Click(Sender: TObject);
    procedure DateSort1Click(Sender: TObject);
    procedure FileSize1Click(Sender: TObject);
    procedure Unsorted1Click(Sender: TObject);
    procedure UnmountAll1Click(Sender: TObject);
    procedure SelectedVolume1Click(Sender: TObject);
    procedure miSearchMountedVolumesClick(Sender: TObject);
    procedure ZeroVolume1Click(Sender: TObject);
    procedure ClosepSystemWindow1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CopyallCODEfiles1Click(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure btnAbortClick(Sender: TObject);
    procedure MountNonStandardVolume1Click(Sender: TObject);
    procedure CopyfrompSystopSys1Click(Sender: TObject);
    procedure ExtractFilefromRawVolume1Click(Sender: TObject);
    procedure CleanVolumeforprevers41Click(Sender: TObject);
    procedure GuessVolumeFormat1Click(Sender: TObject);
    procedure ReportSYSTEMMISCINFOcontents1Click(Sender: TObject);
    procedure ReportSYSTEMMISCINFOKEYcontents1Click(Sender: TObject);
    procedure MaintainBootFilesList1Click(Sender: TObject);
    procedure DebuggerSettings1Click(Sender: TObject);
    procedure SegmentMapSEGMAP1Click(Sender: TObject);
    procedure PrintBootFilesList1Click(Sender: TObject);
    procedure GuessTermTypeClick(Sender: TObject);
    procedure CompareVolumes1Click(Sender: TObject);
    procedure ConfigureCodePoolInfo1Click(Sender: TObject);
    procedure ChangeScreenSize1Click(Sender: TObject);
    procedure RebootLastSystem1Click(Sender: TObject);
    procedure ChangeFileTypeforFile1Click(Sender: TObject);
  private
    fCurrentBootParams: TBootParams;
    fCurrentUnit  : integer;
    fFileName     : string;
    fAltFileName  : string;
    fFilePath     : string;
    fInputFolder  : string;
    fInterpreter  : TCustomPsystemInterpreter;
    fLastFindText : string;
    fFindStart    : pchar;
    fListOfVolumesToMountCSV: string;
    fMemoBuf      : string;
    fOutputFile   : TextFile;
    fAltOutputFile: TextFile;
    fOutputFolder : string;
    fSearchInfo   : TSearchInfo;
    fOnKeyDown    : TOnKeyDown;
    fOnKeyPress   : TOnKeyPress;
    fOnKeyUp      : TOnKeyUp;
    fSysRunning   : boolean;
    fThePSysWindow: TfrmPSysWindow;
    fVersionNr    : TVersionNr;
    fVolumesList  : TVolumesList;

    procedure Write(const s: string); overload;
    procedure WriteLn(const s: string); overload;
    procedure Write(const s: string; len: integer); overload;
    procedure WriteLn; overload;
    procedure Write(n, wid: integer); overload;
    procedure Spaces(wid: integer);
    procedure DisplayDirectory( UnitNumber: integer;
                         OutputFileName: string;
                         DETAIL:BOOLEAN = true;
                         DirectoryOutput: TDirectoryOutput = doMemo;
                         DirectorySort: TDirectorySort = dsUnsorted);
    procedure Log_Status( const Msg: string;
                          DoLog: boolean = true;
                          DoStatus: boolean = true;
                          Color: TColor = clBtnFace);
    procedure Log_StatusFmt(const Msg: string; Args: array of const);
    procedure BadFileNumber(const FileNumberStrings: string);
    function  MountVolume(const VolumeFileName: string; var TheUnitNumber: integer; AskForParams: boolean = false): TMountResult;
    function LoadFromUnit(BootParams: TBootParams): TCustomPsystemInterpreter;
    function MountedCount: integer;
    procedure ShowMountStatus;
    function GetCurrentVolume: TVolume;
    procedure NoCurrentVolume;
    procedure OpenRecentVolume(Sender: TObject);
    function VolumeIsMounted(const VolumeFileName: string; var UnitNumber: integer): boolean; overload;
    function VolumeIsMounted(Volume: TVolume; var UnitNumber: integer): boolean; overload;
    procedure DisplayBlock(Volume: TVolume; BlockNr: word; Buffer: pchar);
    function InRecentVolumes(aVolume: TVolume; var IdxNr: integer): boolean;
    procedure CopyBlockRangeToFile(FileKind: integer);
    function MountOuterVolume(aCaption: string; AskForParams: boolean = false): integer;
    function FindFreeUnitNumber: integer;
    procedure UnmountVolume(VolumeNumber: integer; ShowMounted: boolean = true);
    procedure ShowMountedVolumes;
    procedure VolumeBeingFreed(const Volume: TVolume);
    procedure ClearVolumeListInfo(idx: integer);
    procedure AddDivider;
    procedure UpdateStatus( const Msg: string;
                            DoLog: boolean = true;
                            DoStatus: boolean = true;
                            Color: TColor = clBtnFace);
    procedure MountListOfVolumes(const FileName: string);
    procedure MountVolumes(List: TStringList);
    function ExtractFileFromRawFile(InFileName, OutFileName: string;
      StartingBlock, NrBlocks: LongInt): boolean;
    procedure SaveListOfMountedVolumes(const FileName: string);
    function AnyVolumesMounted: boolean;
    procedure MountSubsidiaryVolume(TheParentUnitNumber: integer);
    function UnitNumberFromVolumeName(const aVolumeName: string): integer;
    function GetThePSyswindow: TfrmPSysWindow;
    procedure EnableMenus(NewState: boolean; BootParams: TBootParams);
    procedure CopyAllFiles(FileKind: integer);
    procedure LogMatchingLine(const FilePath, FileName, Line: string;
      LastAccessTime: TDateTime; const DOSFilePath: string = '');
    function UnpackName(     PathName: string;
                         var UnitNr: integer;
                         var VolName: string;
                         var FileName: string): boolean;
    function GetInteger(const Prompt: string; Default: Longint): longint;
    procedure SaveCrtSettings(Sender: TObject);
    procedure SearchManyVolumes(TheSearchMode: TSearchMode);
    function OpenOutputFile(SearchMode: TSearchMode): string;
    procedure CloseOutputFile(SearchInfo: TSearchInfo);
    function GetBootParams(MenuItem: TMenuItem; var SaveOnly: boolean): TBootParams;
    procedure BootInterpreter(BootParams: TBootParams);
{$IfDef Debugging}
    procedure DebugInterpreter(BootParams: TBootParams);
    procedure DebugClick(Sender: TObject);
    procedure DebugFromUnitClick(Sender: TObject);
{$endIf}
    procedure NavigateClick(ClickType: TNavigatePush);
    procedure BootClick(Sender: TObject);
    procedure SetVersionNr(const Value: TVersionNr);
    procedure ChangeSyscom(SyscomWhat: TSyscomWhat);
    procedure UnMountAllVolumes;
    function FindFirstMountedUnitNumber: integer;
    procedure BootFromUnitClick(Sender: TObject);
//  procedure SetDefaultVersionNumber(Sender: TObject);
  private
    { Private declarations }
    property ThePSysWindow: TfrmPSysWindow
             read GetThePSyswindow;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure WMMountVolumes(var Message: TMessage); message MSG_MOUNT_VOLUMES;
    procedure WMUnMountAllVolumes(var Message: TMessage); message MSG_UNMOUNT_ALL_VOLUMES;
    procedure WMCreateCSVFileFromMountedVolumes(var message: TMessage); message MSG_CREATE_CSV_FILE_FROM_MOUNTED_VOLUMES;
    procedure GetDefaultBootParams(UnitNr: Integer; var BootParams: TBootParams);
  public
    fLastError    : string;
    { Public declarations }

    constructor Create(aOwner: TComponent); override;
    Destructor Destroy; override;
    function FILER_LEGAL_UNITS: TUnitsRange;
    procedure SetLastError(const Msg: string);

    property CurrentVolume : TVolume
             read GetCurrentVolume;
    property OnKeyDown: TOnKeyDown
             read fOnKeyDown
             write fOnKeyDown;
    property OnKeyUp: TOnKeyUp
             read fOnKeyUp
             write fOnKeyUp;
    property OnKeyPress: TOnKeyPress
             read fOnKeyPress
             write fOnKeyPress;
    property VersionNr: TVersionNr
             read fVersionNr
             write SetVersionNr;
  end;

var
  frmFiler: TfrmFiler;

implementation

uses
  MyUtils, uGetString, RenameFile, FilerSettingsUnit, Misc,
  UCSDGlob,
  GetBlockParams,
  MyDelimitedParser,
{$IfDef Debugging}
  DecodeWindow,
  pCodeDebugger,
  Debug_Decl,
  pCodeDebugger_Decl,
  DebuggerSettingsUnit,
  DebuggerSettingsForm,
{$EndIf Debugging}
  VolConverter, StrUtils, RawFileParams,
  pSysDatesAndTimes, SysUtils, pSysExceptions, FilerSettingsForm,
  pSysVolumesNonStandard, VolumeParams, pSys_Const, SysCommon,
  DBCtrls, InterpC, SegMap, SelectVersion, ProcedureMapping, GuessOptions,
  MiscinfoUnit, CompareVolumes, FileNames, CSVStuff;

{$R *.dfm}

const
  BLOCKSPERREAD = 1;
  REPORT_INTERVAL = 100000;

procedure TfrmFiler.Log_Status( const Msg: string;
                                DoLog: boolean = true;
                                DoStatus: boolean = true;
                                Color: TColor = clBtnFace);
begin
  if DoLog then
    WriteLn(Msg);
  if DoStatus then
    begin
      lblStatus.Caption := Msg;
      lblStatus.Color   := Color;
      Application.ProcessMessages;
    end;
end;

function TfrmFiler.FindFreeUnitNumber: integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to MAX_FILER_UNITNR do
    with fVolumesList[i] do
      if (i in FILER_LEGAL_UNITS) and not Assigned(TheVolume) then
        begin
          result := i;
          exit;
        end;
end;

function TfrmFiler.FindFirstMountedUnitNumber: integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to MAX_FILER_UNITNR do
    with fVolumesList[i] do
      if (i in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        begin
          result := i;
          exit;
        end;
end;

function TfrmFiler.VolumeIsMounted(Volume: TVolume; var UnitNumber: integer): boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to MAX_FILER_UNITNR do
    if (i in FILER_LEGAL_UNITS) AND (fVolumesList[i].TheVolume = Volume) THEN
      begin
        UnitNumber := i;
        result := true;
        exit;
      end;
end;

function TfrmFiler.VolumeIsMounted(const VolumeFileName: string; var UnitNumber: integer): boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to MAX_FILER_UNITNR do
    if (i in FILER_LEGAL_UNITS) AND (Sametext(fVolumesList[i].VolumeName, VolumeFileName)) THEN
      begin
        UnitNumber := i;
        result := true;
        exit;
      end;
end;

//  TMountResult = (mrUnknown, mrMounted, mrAlreadyMounted);
function TfrmFiler.MountVolume(const VolumeFileName: string; var TheUnitNumber: integer; AskForParams: boolean): TMountResult;
var
  aDiskFormat: TDiskFormat;
  IsStandard: boolean;
  Ext: string;
  df: TDiskFormats;
begin
  if not VolumeIsMounted(VolumeFileName, TheUnitNumber) then
    begin
      if TheUnitNumber <= 0 then
        TheUnitNumber := FindFreeUnitNumber;

      if TheUnitNumber > 0 then
        begin
          with fVolumesList[TheUnitNumber] do
            begin
              UnitNumber := TheUnitNumber;

              Ext        := ExtractFileExt(VolumeFileName);
              IsStandard := StandardVolumeFormat(Ext);
              if IsStandard then
                TheVolume := CreateVolume(self, VolumeFileName, VersionNr, 0)
              else
                begin
                  if not AskForParams then
                    begin
                      df := DiskFormatFromExt(Ext);
                      aDiskFormat := DiskFormatInfo[df];
                    end
                  else
                    if not GetNonStandardParams(VolumeFileName, aDiskFormat) then
                      SysUtils.Abort;

                  case aDiskFormat.Alg of
                    alStandard:
                      TheVolume  := TNonStandardVolume.Create(self, VolumeFileName);
                    alApple2:
                      TheVolume  := TMiscVolume.Create(self, VolumeFileName)
                    else
                      SysUtils.Abort;
                  end;

                  with TheVolume as TNonStandardVolume do
                    DiskFormatUtil.DiskFormat := aDiskFormat;
                end;

              TheVolume.OnStatusProc      := Log_Status;
              TheVolume.OnSearchFoundProc := LogMatchingLine;
              TheVolume.OnSVOLFree        := VolumeBeingFreed;
              TheVolume.LoadVolumeInfo(DIRECTORY_BLOCKNR); // would be nice to delay loading until needed
              fVolumesList[TheUnitNumber].VolumeName := TheVolume.VolumeName;
              inc(RefCount);
            end;

          ChDir(ExtractFilePath(VolumeFileName));
          fCurrentUnit := TheUnitNumber;
          result := mrMounted;
        end
      else
        begin
          Log_Status(Format('Volume "%s" could not be mounted',
                            [VolumeFileName]));
          result := mrFailed;
        end;
    end
  else
    begin
      Log_Status(Format('Volume "%s" is already mounted on unit %d',
                        [VolumeFileName, TheUnitNumber]));
      result := mrAlreadyMounted;
    end;
end;

function TfrmFiler.MountOuterVolume(aCaption: string; AskForParams: boolean = false): integer;
var
  mr: TMountResult;
begin
  result := -1;
  with OpenDialog1 do
    begin
      Title      := aCaption;
      DefaultExt := VOL_EXT;
      FileName   := Format('*.%s', [VOL_EXT]);
      InitialDir := fFilePath;
      Filter     := VOLUMEFILTERLIST;
      if AskForParams then
        begin
          DefaultExt := '*';
          FileName   := '*.*';
        end;
      if Execute then
        begin
          mr := MountVolume(FileName, result, AskForParams);
          if mr = mrMounted then
            DisplayDirectory(fCurrentUnit, '', true);
          fFilePath := ExtractFilePath(FileName);
        end;
    end;
  ShowMountStatus;
end;


procedure TfrmFiler.MountVolume1Click(Sender: TObject);
var
  UnitNumber: integer;
begin
  UnitNumber := MountOuterVolume('Volume File');
  if UnitNumber > 0 then
    with fVolumesList[UnitNumber] do
      WriteLn(Format('Volume %s: mounted onto Unit# %d. %d files',
                      [VolumeName, UnitNumber, TheVolume.NumFiles]));
end;

  procedure TfrmFiler.WriteLn(const s: string);
  begin
    if fFileName = '' then
      begin
        Write(s);
        Memo1.Lines.Add(s);
        Application.ProcessMessages;
      end
    else
      system.WriteLn(fOutputFile, s);

    fMemoBuf := '';
  end;

  procedure TfrmFiler.Write(const s: string);
  begin
    fMemoBuf := fMemoBuf + s;
  end;

  procedure TfrmFiler.Write(const s: string; Len: integer);
  begin
    fMemoBuf := fMemoBuf + PadR(s, len);
  end;

  procedure TfrmFiler.Write(n: integer; wid: integer);
  var
    temp: string;
  begin
    temp := IntToStr(n);
    Write(Padl(temp, wid));
  end;

  procedure TfrmFiler.Spaces(wid: integer);
  begin
    Write(Padr('', wid));
  end;

procedure TfrmFiler.WriteLn;
begin
  if fFileName = '' then
    Memo1.Lines.Add(fMemoBuf)
  else
    system.WriteLn(fOutputFile, fMemoBuf);

  fMemoBuf := '';
end;

procedure TfrmFiler.AddDivider;
begin
  WriteLn;
  WriteLn('----------------------------------------------------------------------');
end;

PROCEDURE TfrmFiler.DisplayDirectory( UnitNumber: integer;
                               OutputFileName: string;
                               DETAIL:BOOLEAN = true;
                               DirectoryOutput: TDirectoryOutput = doMemo;
                               DirectorySort: TDirectorySort = dsUnsorted);
const
  NRWIDTH   = 3;
  DATEWIDTH = 11;
  TIMEWIDTH = 7;
  USEDWIDTH = 4;
  BLOCKWIDTH = 7;
  TYPEWIDTH = 10;

VAR LASTI, LARGEST,FREEBLKS,USEDAREA,USEDBLKS: INTEGER;
    TimeStr: STRING;
    TheVolume: TVolume;
    temp: string;
    HH, MM, SS, MSEC: word;

  procedure WriteToMemo;
  var
    I: integer;
    LastBootStr: string;

  PROCEDURE FREECHECK(FIRSTOPEN,NEXTUSED: INTEGER);
  VAR FREEAREA: INTEGER;
  BEGIN
    FREEAREA := NEXTUSED-FIRSTOPEN;
    IF FREEAREA > LARGEST THEN
      LARGEST := FREEAREA;
    IF FREEAREA > 0 THEN
      BEGIN
        FREEBLKS := FREEBLKS+FREEAREA;
        IF DETAIL THEN
          BEGIN
            Write('', NRWIDTH); Spaces(2);
            Write('< UNUSED >', TIDLENG + 1);
            Write(FREEAREA, USEDWIDTH);
            SPACES(2);
            SPACES(DATEWIDTH);
            SPACES(TIMEWIDTH);
            Write(FIRSTOPEN, BLOCKWIDTH);
            WriteLn;
          END
      END;
  END {FREECHECK} ;

  begin { WriteToMemo }
    fFileName := OutputFileName;
    if OutputFileName <> '' then
      begin
        AssignFile(fOutputFile, OutputFileName);
        ReWrite(fOutputFile);
      end;
    try
      AddDivider;
      TheVolume := fVolumesList[UnitNumber].TheVolume;
      if Assigned(TheVolume) then
        begin
          with TheVolume do
            begin
              with DirecTory[0] do
                if LastBoot <> BAD_DATE then
                  LastBootStr := DateToStr(LastBoot)
                else
                  LastBootStr := 'Not set';

              WriteLn('VOLUME: ' + VolumeName + ', DOSFILENAME: ' + DOSFILENAME +
                      ', LastBoot=' + LastBootStr);
              if HasDupDir then
                WriteLn('--- HAS DUPLICATE DIRECTORY ---');
            end;
          Write('#', NRWIDTH); Write('  ');
          Write('DTID', TIDLENG + 1);
          Write('Used', USEDWIDTH);
          Spaces(2);
          Write('MM/DD/YY', DATEWIDTH);
          Write('HH:MM', TIMEWIDTH);
          if detail then
            begin
              Write(' 1stBlk', BLOCKWIDTH);
              Write('  Bytes', BLOCKWIDTH);
              Spaces(2);
              Write('File Type', TYPEWIDTH);
            end;
          WriteLn;

          LASTI := 1;  // Range check unless used
          with TheVolume do
            begin
              FOR I := 1 TO TheVolume.NumFiles DO
                WITH TheVolume, Directory[i] DO
                 if Wild_Match(@FileName[1], pchar(TheVolume.Filter), '*', '?', false) then
                  BEGIN
                    LASTI := I;
                    FREECHECK(TheVolume.Directory[I-1].LastBlk, FirstBlk);
                    USEDAREA := LastBlk-FirstBlk;
                    USEDBLKS := USEDBLKS+USEDAREA;
            //      IF DACCESS.YEAR IN [1..99] THEN
                    BEGIN
                      Write(I, NRWIDTH); Write(': ');
                      Write(FileName, TIDLENG+1);
                      Write(USEDAREA, USEDWIDTH);
                      Spaces(2);
                      IF DateAccessed <> BAD_DATE then
                        begin
                          temp := DateToPSysStr(DateAccessed);
                          Write(temp, DATEWIDTH);
                          DecodeTime(DateAccessed, HH, MM, SS, MSEC);
                          if (HH > 0) then
                            begin
                              TimeStr := Format('%2s:%2s', [RZero(HH,2), RZero(MM,2)]);
                              Write(TimeStr, TIMEWIDTH);
                            end
                          else
                            Write('', TIMEWIDTH);
                        end
                      ELSE
                        begin
                          Spaces(DATEWIDTH);
                          Spaces(TIMEWIDTH);
                        end;

                      IF DETAIL THEN
                        BEGIN
                          Write(FirstBlk, BLOCKWIDTH);
                          Write(LastByte, BLOCKWIDTH);
                          SPACES(2);
                          Write(PSysFileType(xDFKIND), TYPEWIDTH)
                        END;
                      WriteLn;
                    END;
                  END;
              FREECHECK(DI.RECTORY[LASTI-1].DLASTBLK,DI.RECTORY[0].DEOVBLK);
              Write(DI.RECTORY[0].DNUMFILES,0);
              Write(' files, ');
              Write(USEDBLKS,0);
              Write(' blocks used, ');
              Write(FREEBLKS,0);
              Write(' unused');
              IF DETAIL THEN BEGIN
                 Write(', ');
                 Write(LARGEST,0);
                 Write(' in largest area.');
                 WriteLn;
              END;
            end;
        end
      else
        SysUtils.Beep;
    finally
      if OutputFileName <> '' then
        begin
          CloseFile(fOutputFile);
          fFileName := '';
        end;
    end;
  end;  { WriteToMemo }

  procedure WriteToStringGrid;
  var
    RowNr: integer;

    PROCEDURE FREECHECK(FIRSTOPEN,NEXTUSED: INTEGER);
    VAR FREEAREA: INTEGER;
    BEGIN
      FREEAREA := NEXTUSED-FIRSTOPEN;
      IF FREEAREA > LARGEST THEN
        LARGEST := FREEAREA;
      IF FREEAREA > 0 THEN
        FREEBLKS := FREEBLKS+FREEAREA;
    END {FREECHECK} ;

  begin { WriteToStringGrid }
    fFileName := OutputFileName;
    if not Assigned(frmDirectoryListing) then
      frmDirectoryListing := TfrmDirectoryListing.Create(self);

    with frmDirectoryListing, sgDirectory do
    try
      if Detail then
        ColCount := 8
      else
        ColCount := 5;

      TheVolume := fVolumesList[UnitNumber].TheVolume;
      with TheVolume do
        begin
          lblVolumeName.Caption   := VolumeName;
          lblDOSFiileName.Caption := DOSFILENAME;
          lblLastWrite.Caption    := DateToStr(Directory[0].LastBoot);
        end;

      RowCount := TheVolume.NumFiles + 1;
      if RowCount > 1 then
        FixedRows := 1;

      Cells[COL_NR, 0] := '#';
      Cells[COL_DTID, 0] := 'DTID';
      Cells[COL_USED, 0] := 'Used';
      Cells[COL_DATE, 0] := 'Date';
      Cells[COL_TIME, 0] := 'Time';
      if detail then
        begin
          Cells[COL_1STBLK, 0] := '1stBlk';
          Cells[COL_BYTES, 0] := 'Bytes';
          Cells[COL_FILETYPE, 0] := 'File Type';
        end;

      LASTI := 1;  // Range check unless used
      FOR RowNr := 1 TO TheVolume.NumFiles DO
        WITH TheVolume, Directory[RowNr] DO
         if Wild_Match(@FileName[1], pchar(TheVolume.Filter), '*', '?', false) then
          BEGIN
            LASTI := RowNr;
            FREECHECK(TheVolume.Directory[RowNr-1].LastBlk, FirstBlk);
            USEDAREA := LastBlk-FirstBlk;
            USEDBLKS := USEDBLKS+USEDAREA;

            Cells[COL_NR, RowNr]   := IntToStr(RowNr);
            Cells[COL_DTID, RowNr] := FileName;
            Cells[COL_USED, RowNr] := IntToStr(UsedArea);
            IF DateAccessed <> BAD_DATE then
              begin
//              if DirectorySort = dsDateSort then
//                temp := YYYYMMDD(DateAccessed)
//              else
//                temp := DateToPSysStr(DateAccessed);
                temp := YYYYMMDD(DateAccessed); // always use this format to permit re-sorts to work proprly

                Cells[COL_DATE, RowNr] := temp;
                DecodeTime(DateAccessed, HH, MM, SS, MSEC);
                if (HH > 0) then
                  begin
                    TimeStr := Format('%2s:%2s', [RZero(HH,2), RZero(MM,2)]);
                    Cells[COL_TIME, RowNr] := TimeStr;
                  end;
              end;

            IF DETAIL THEN
              BEGIN
                Cells[COL_1STBLK, RowNr] := IntToStr(FirstBlk);
                Cells[COL_BYTES, RowNr]  := IntToStr(LastByte);
                Cells[COL_FILETYPE, RowNr] := PSysFileType(xDFKIND);
              END;
          END;

          with TheVolume do
            begin
              FREECHECK(DI.RECTORY[LASTI-1].DLASTBLK,DI.RECTORY[0].DEOVBLK);
              leNrFiles.text    := IntToStr(DI.RECTORY[0].DNUMFILES);
            end;

        leBlocksUsed.text := IntToStr(USEDBLKS);
        leUnused.Text     := IntToStr(FREEBLKS);
        leInLargestArea.Text := IntToStr(LARGEST);
        frmDirectoryListing.Show{Modal};
    finally
      AdjustColumnWidths(sgDirectory);
      case DirectorySort of
        dsUnsorted:
          begin
            Unsorted1.Checked := true;
            SortGridNumeric(sgDirectory, COL_NR);
          end;

        dsAlphaSort:
          begin
            Alpha1.Checked := true;
            Sortgrid(sgDirectory, COL_DTID);
          end;

        dsDateSort:
          begin
            Date1.Checked := true;
            SortGridNumeric(sgDirectory, COL_DATE);
          end;

        dsFileSize:
          begin
            Size1.Checked := true;
            SortGridNumeric(sgDirectory, COL_USED);
          end;
      end;
    end;
  end;  { WriteToStringGrid }

BEGIN { DisplayDirectory }
  FREEBLKS := 0; USEDBLKS := 0;
  LARGEST := 0;

  if UnitNumber <> 0 then
    begin
      case DirectoryOutput of
        doMemo:
          WriteToMemo;
        doStringGrid:
          WriteToStringGrid;
      end;
    end
  else
    Error('No current unit number');

END; { DisplayDirectory }

procedure TfrmFiler.Directory0Click(Sender: TObject);
begin
  DisplayDirectory(fCurrentUnit, '', true);
end;

procedure TfrmFiler.OpenRecentVolume(Sender: TObject);
var
  idx: integer;
  mr: TMountResult;
  UnitNumber: integer;
begin                         
{$IfNDef FastMM}    // 4/15/2021: Why?
  with Sender as TMenuItem do
    begin
      idx := RecentVolumes1.IndexOf(Sender as TMenuItem);
      if idx >= 0 then
        begin
          mr := MountVolume(FilerSettings.RecentVolumes[idx], UnitNumber);
          if mr = mrMounted then
            begin
              with fVolumesList[UnitNumber] do
                WriteLn(Format('Volume %s: mounted onto Unit# %d. %d files',
                                [VolumeName, UnitNumber, TheVolume.NumFiles]));
              DisplayDirectory(UnitNumber, '', true);
            end;
        end;
    end;
{$endIf}
end;

procedure TfrmFiler.MountVolumes(List: TStringList);
var
  i: integer;
  Lfn, Ext: string;
  mr: TMountResult;
  UnitNumber: integer;
begin
  for i := 0 to List.Count-1 do
    begin
      Lfn := List[i];
      Ext := Copy(Lfn, Length(Lfn)-2, 3);

      if Sametext(Ext, CSV_EXT) then
        fListOfVolumesToMountCSV := Lfn;   // remember the name even if the file does not exist

      if FileExists(Lfn) then
        begin
          if SameText(Ext, VOL_EXT) or
             SameText(Ext, 'svol') then
            begin
              mr := MountVolume(Lfn, UnitNumber);
              if mr = mrMounted then
                begin
                  ShowMountStatus;
                  DisplayDirectory(UnitNumber, '', true);
                end
              else
                AlertFmt('Failed to mount "%s"', [Lfn])
            end else
          if Sametext(Ext, CSV_EXT) then
            try
              MountListOfVolumes(Lfn)
            except
              on e:Exception do
                Log_StatusFmt('Not all volumes could be mounted [%s]', [e.message]);
            end
          else
            Log_StatusFmt('File "%s" is not a volume (.vol) or a Volume List (.csv) file', [Lfn]);
        end
      else
        Log_StatusFmt('File "%s" does not exist', [Lfn]);
    end;
end;


constructor TfrmFiler.Create(aOwner: TComponent);
var
  i: integer;
  MenuItem: TMenuItem;
  List: TStringList;
//vn: TVersionNr;
begin
  inherited;

{$IfNDef FastMM}  {I don't remember why I did this...}
  FilerSettings := TFilerSettings.Create(self);

  with FilerSettings do
    if FileExists(FilerSettingsFileName) and (FileSize32(FilerSettingsFileName) > 0) then
      begin
        LoadFromFile(FilerSettingsFileName);
        for i := 0 to RecentVolumes.Count - 1 do
          begin
            MenuItem := TMenuItem.Create(RecentVolumes1);
            MenuItem.Caption := ExtractFileBase(RecentVolumes[i]);
            MenuItem.OnClick := OpenRecentVolume;
            RecentVolumes1.Add(MenuItem);
          end;
        fFilePath := VolumesFolder;
        VersionNr := DefaultPSystemVersion;
      end;
{$EndIf}

  List      := TStringList.Create;
  try
    for i := 1 to ParamCount do
      List.Add(ParamStr(i));
    MountVolumes(List);
  finally
    List.Free;
  end;

(*
  // create the "default" version number menu
  for vn := vn_VersionI_4 to HIGH(TVersionNr) do // vn_VersionIV_12 does not work
   if not (vn in BADVERSIONS) then
    begin
      MenuItem := TMenuItem.Create(DefaultVersion1);
      MenuItem.Caption   := VersionNrStrings[vn].Name;
      MenuItem.Tag       := ord(vn);
      MenuItem.OnClick   := SetDefaultVersionNumber;
      MenuItem.RadioItem := true;
      DefaultVersion1.Add(MenuItem);
    end;
*)

  VersionNr := FilerSettings.DefaultPSystemVersion;

  if VersionNr >= vn_VersionIV then
    begin
      EnableExternalPool1.Visible := true;
      EnableExternalPool1.Checked := true;
    end
  else
    EnableExternalPool1.Visible := false;
end;

(*
procedure TfrmFiler.SetDefaultVersionNumber(Sender: TObject);
begin
  with Sender as TMenuItem do
    begin
      VersionNr := TVersionNr(Tag);
      Checked   := true;
    end;
end;
*)


function TfrmFiler.InRecentVolumes(aVolume: TVolume; var IdxNr: integer): boolean;
var
  i: integer;
begin
  result := false;
{$IfNDef FastMM}
  IdxNr  := -1;
  with FilerSettings do
    for i := 0 to RecentVolumes.Count-1 do
      if SameText(aVolume.DOSFileName, RecentVolumes[i]) then
        begin
          result := true;
          IdxNr  := i;
          Exit;
        end;
{$endIf}
end;

procedure TfrmFiler.ClearVolumeListInfo(idx: integer);
begin
  with fVolumesList[idx] do
    begin
      VolumeName := '';
      TheVolume  := nil;
      UnitNumber := 0;
      RefCount   := 0;
    end;
end;

procedure TfrmFiler.VolumeBeingFreed(const Volume: TVolume);
var
  i: integer;
begin
  for i := 0 to MAX_FILER_UNITNR do
    if fVolumesList[i].TheVolume = Volume then
      begin
        ClearVolumeListInfo(i);
        break;
      end;
end;

destructor TfrmFiler.Destroy;
const
  MAXRECENT = 10;
var
  i, j, NrFound, IdxNr: integer;
  TempVolInfo: TVolumeInfo;
  WasFound: boolean;
  SavedFileName: string;
begin
  FreeAndNil(fInterpreter);

  FreeAndNil(fThePsysWindow);
{$IfDef Debugging}
  FreeAndNil(frmPCodeDebugger);
{$endIf}

{$IfNDef FastMM}     // 4/15/2021: Why?

  with FilerSettings do
    begin
//    VolumesFolder         := fFilePath;
      DefaultPSystemVersion := VersionNr;

      // Sort Recent list by RefCount

      for i := 0 to MAX_FILER_UNITNR-1 do
        for j := i + 1 to MAX_FILER_UNITNR do
          if Assigned(fVolumesList[i].TheVolume) and Assigned(fVolumesList[j].TheVolume) then
            if fVolumesList[i].RefCount <= fVolumesList[j].RefCount then
              begin
                TempVolInfo     := fVolumesList[i];
                fVolumesList[i] := fVolumesList[j];
                fVolumesList[j] := TempVolInfo;
              end;

      NrFound := 0;
      for i := 0 to MAX_FILER_UNITNR do
        if Assigned(fVolumesList[i].TheVolume) then
          if NrFound <= MAXRECENT then
            begin
              WasFound := InRecentVolumes(fVolumesList[i].TheVolume, IdxNr);
              if (IdxNr > i) or (not WasFound) then
                begin
                  if IdxNr >= 0 then
                    RecentVolumes.Delete(IdxNr);
                  RecentVolumes.Insert(NrFound, fVolumesList[i].TheVolume.DOSFileName);
                end;
              NrFound := NrFound + 1;
            end;

      for i := RecentVolumes.Count - 1 downto MAXRECENT do
        RecentVolumes.Delete(i);

      FilerSettings.WindowsList.AddWindow(self, WindowsType[wtFiler], 0);
      FilerSettings.RecentBootsList.CleanUpList;

//    SavedFileName := UniqueFileName(FilerSettingsFileName);
      SavedFileName := FileNameByDate(FilerSettingsFileName);
      SysUtils.RenameFile(FilerSettingsFileName, SavedFileName);       // Save the current settings to a backup file "FILER (nnn).INI"
      SaveToFile(FilerSettingsFileName);                      // and save the current settings to the default name "FILER.INI"
    end;
{$endIf}

  SaveListOfMountedVolumes(fListOfVolumesToMountCSV);
  
  for i := 0 to MAX_FILER_UNITNR do
    if Assigned(fVolumesList[i].TheVolume) then
      begin
        Log_Status(Format('Free vol #%d', [i]));
        FreeAndNil(fVolumesList[i].TheVolume);
        ClearVolumeListInfo(i);
      end;

  FreeAndNil(FilerSettings);
  inherited;
end;

procedure TfrmFiler.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmFiler.BriefDirectory1Click(Sender: TObject);
begin
  DisplayDirectory(fCurrentUnit, '', false);
end;

procedure TfrmFiler.ListDirectory1Click(Sender: TObject);
var
  TheVolume: TVolume;
  OpenDialog: TSaveDialog;
begin
  OpenDialog := TSaveDialog.Create(self);
  try
    TheVolume := CurrentVolume;
    if Assigned(TheVolume) then
      with OpenDialog do
        begin
          FileName   := ExtractFilePath(ParamStr(0)) + 'Index of ' + TheVolume.VolumeName + '.txt';
          Filter     := 'Text File (*.txt)|*.txt';
          DefaultExt := TXT_EXT;
          Options    := [ofOverwritePrompt, ofNoValidate, ofExtensionDifferent,
                         ofPathMustExist, ofCreatePrompt, ofNoReadOnlyReturn,
                         ofNoTestFileCreate, ofNoNetworkButton, ofNoLongNames,
                         ofEnableIncludeNotify, ofEnableSizing, ofDontAddToRecent];
          if Execute then
            begin
              DisplayDirectory(fCurrentUnit, FileName, true);
              if not ExecAndWait(FilerSettings.EditorFilePath, FileName, true) then
                AlertFmt('Could not edit "%s"', [FileName]);
            end;
        end
    else
      NoCurrentVolume;
  finally
    FreeAndNil(OpenDialog);
  end;
end;

function TfrmFiler.AnyVolumesMounted(): boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to MAX_FILER_UNITNR do
    with fVolumesList[i] do
      if (i in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        begin
          result := true;
          Exit;
        end;
end;


procedure TfrmFiler.File1Click(Sender: TObject);
var
  OK: boolean;
begin
  OK                      := Assigned(CurrentVolume);
  SelectedVolumes2.Enabled  := AnyVolumesMounted;
  Directory0.Enabled      := OK;
  BriefDirectory1.Enabled := OK;
  ListDirectory1.Enabled  := OK;
  CopySingleFile1.Enabled := OK;
  SetDOSPath1.Enabled     := OK;
  CopyAllFiles1.Enabled   := OK;
  CopyAllFilesinBinary1.Enabled := OK;
  CopyTextFileasBinary1.Enabled := OK;
  Directories1.Enabled    := OK;
//Boot1.Enabled           := false;

  if OK then
    if CurrentVolume.Filter <> DEFAULT_FILTER then
      begin
        CopyAllFiles1.Caption         := 'Copy Selected Files';
        CopyAllFilesinBinary1.Caption := 'Copy Selected Files as Binary';
      end
    else
      begin
        CopyAllFiles1.Caption         := 'Copy All Files';
        CopyAllFilesinBinary1.Caption := 'Copy All Files as Binary';
      end;
end;

procedure TfrmFiler.BadFileNumber(const FileNumberStrings: string);
begin { BadFileNumber }
   AlertFmt('Invalid file number: %s', [FileNumberStrings]);
end;  { BadFileNumber }

procedure TfrmFiler.CopySingleFile1Click(Sender: TObject);
var
  DirIdx: integer;
  aFileName: string;
  FileNumberString: string;
  Prompt, FilePath: string;
  TheVolume: TVolume;
  IsText: boolean;
begin { TfrmFiler.CopySingleFile1Click }
  TheVolume  := CurrentVolume;
  if Assigned(TheVolume) then
    begin
      if GetString('Select pSys file to copy to DOS', Prompt, FileNumberString, 15) then
        begin
          DirIdx := TheVolume.DirIdxFromString(FileNumberString);
          if (DirIdx > 0) and (DirIdx <= TheVolume.NumFiles) then
            begin
              aFileName    := TheVolume.Directory[DirIdx].FileName;
              IsText       := TheVolume.Directory[DirIdx].xDFKIND = kTEXTFILE;
              if IsText then
                aFileName  := TheVolume.FixTextName(aFileName);
              FilePath    := fOutputFolder + aFileName;
              with SaveDialog1 do
                begin
                  FileName   := FilePath;
                  Options    := [];
                  if IsText then
                    begin
                      DefaultExt := TXT_EXT;
                      FilterIndex := 0;
                      Filter      := 'Text File (*.txt)|*.txt';
                    end
                  else
                    begin
                      DefaultExt := '';;
                      FilterIndex := 1;
                      Filter      := 'Data File (*.*)|*.*';
                    end;
                  if Execute then
                    TheVolume.CopySingleFile(DirIdx, FileName);
                end;
            end
          else
            Log_StatusFmt('File %s not found', [FileNumberString]);
        end
    end
  else
    NoCurrentVolume;
end;  { TfrmFiler.CopySingleFile1Click }

procedure TfrmFiler.NoCurrentVolume;
begin
  Alert('No current volume');
end;


procedure TfrmFiler.SetDOSPath1Click(Sender: TObject);
var
  FolderName: string;
  TheVolume: TVolume;
begin
  TheVolume  := CurrentVolume;
  if Assigned(TheVolume) then
    begin
      FolderName := ExtractFilePath(ParamStr(0));
      if BrowseForFolder('DOS folder', FolderName) then
        TheVolume.OutputRootFolder := FolderName;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.CopyAllFiles1Click(Sender: TObject);
var
  OKToOverWrite: boolean;
  Temp: string;
  TheVolume: TVolume;
begin
  TheVolume := CurrentVolume;
  if Assigned(TheVolume) then
    begin
      Temp := fOutputFolder + TheVolume.VolumeName;
      if BrowseForFolder('Output Folder', fOutputFolder) then
        begin
          OKToOverWrite := YesFmt('Overwrite existing files in "%s"?', [Temp]);
          TheVolume.CopyAllFilesToDOS(fOutputFolder, OKToOverWrite, kANYFILE);
        end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.CopyTextFileasBinary1Click(Sender: TObject);
var
  FileNumber: integer;
  FileNumberString: string;
  Prompt, FolderName: string;
  TheVolume: TVolume;
begin
  TheVolume := CurrentVolume;
  if Assigned(TheVolume) then
    begin
      Prompt     := Format('File Number (1..%d)', [TheVolume.NumFiles]);
      FolderName := fOutputFolder;
      if BrowseForFolder('DOS folder', FolderName) then
        begin
          fOutputFolder := FolderName;
          TheVolume.OutputRootFolder := FolderName;
          if GetString('Select file to copy to DOS', Prompt, FileNumberString, 3) then
            begin
              try
                FileNumber := StrToInt(FileNumberString);
                TheVolume.OutputRootFolder := FolderName;
                if (FileNumber >= 1) and (FileNumber <= TheVolume.NumFiles) then
                  TheVolume.CopySingleDataFile(FileNumber)
                else
                  BadFileNumber(FileNumberString);
              except
                on e:Exception do
                  BadFileNumber(FileNumberString);
              end;
            end;
        end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.CopyAllFilesinBinary1Click(Sender: TObject);
var
  OKToOverWrite: boolean;
  TheVolume: TVolume;
begin
  TheVolume := CurrentVolume;
  if Assigned(TheVolume) then
    begin
      fOutputFolder := TheVolume.DOSFolderName;
      if BrowseForFolder('Output Folder', fOutputFolder) then
        begin
          OKToOverWrite := YesFmt('Overwrite existing files in "%s"?', [fOutputFolder + TheVolume.VolumeName]);
          TheVolume.CopyAllFilesToDOSInBinary(fOutputFolder, OKToOverWrite);
        end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.SetFilter1Click(Sender: TObject);
var
  aFilter: string;
  TheVolume: TVolume;
begin
  TheVolume := CurrentVolume;
  if Assigned(TheVolume) then
    begin
      aFilter := TheVolume.Filter;
      if GetString('Set Directory Filter', 'Filter', aFilter, TIDLENG) then
        begin
          if Empty(aFilter) then
            aFilter := '*.*';
          if Assigned(TheVolume) then
            begin
              TheVolume.Filter := aFilter;
              DisplayDirectory(fCurrentUnit, '', true);
            end;
        end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.CopyAllFiles(FileKind: integer);
var
  Temp: string;
  OKToOverWrite: boolean;
  TheVolume: TVolume;
begin
  TheVolume := CurrentVolume;
  if Assigned(TheVolume) then
    begin
      Temp := fOutputFolder + TheVolume.VolumeName;
      if BrowseForFolder('Output Folder', Temp) then
        begin
          OKToOverWrite := YesFmt('Overwrite existing files in "%s"?', [Temp]);

          fOutputFolder := Temp;
          TheVolume.CopyAllFilesToDos(fOutputFolder, OKToOverWrite, FileKind);
        end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.CopyAllTextFiles1Click(Sender: TObject);
begin
  CopyAllFiles(kTEXTFILE)
end;

procedure TfrmFiler.CopyallCODEfiles1Click(Sender: TObject);
begin
  CopyAllFiles(kCODEFILE)
end;


(*
procedure TfrmFiler.ConvertIMNDFile1Click(Sender: TObject);
var
  InFilePath, OutFilePath: string;
  InBuf: pchar;
  OutBuf: pchar;
//ip,
  op: pchar;
  FileLen, BytesRead, OutLen, BytesWritten: longint;
  InFile, OutFile: file;
  i, j: longint;
  len : integer;
begin
  if BrowseForFile('Source IMD file', InFilePath, 'IMD') then
    begin
      OutFilePath := ForceExtension(InFilePath, EXTENSION_TXT);
      if BrowseForFile('Output file name', OutFilePath, EXTENSION_TXT) then
        begin
          FileLen := FileSize32(InFilePath);
          GetMem(InBuf, FileLen);
          GetMem(OutBuf, FileLen);
          AssignFile(InFile, InFilePath);
          Reset(InFile, 1);
          try
            try
              BlockRead(InFile, InBuf^, FileLen, BytesRead);
              if BytesRead = FileLen then
                begin
//                ip := InBuf;
                  op := OutBuf;
                  outlen := 0;
                  i      := 0;
                  while i < FileLen do
                    begin
                      if (InBuf+i) = DLE then
                        begin
                          Len := Ord((InBuf+i+1)^) - ord(' ');
                          for j := 1 to len do
                            begin
                              op^ := ' ';
                              Inc(op);
                              Inc(OutLen);
                            end;
                          inc(i);  // skip past the DLE,cnt
                        end else
                      if not ((InBuf+i)^ in [#0,#$F6]) then
                        begin
                          op^ := (InBuf+i)^;
                          inc(op);
                          inc(outLen);
                        end;
                      Inc(i);
                    end;
                  AssignFile(OutFile, OutFilePath);
                  Rewrite(OutFile, 1);
                  try
                    BlockWrite(OutFile, OutBuf^, OutLen, BytesWritten);
                    if OutLen = BytesWritten then
                      MessageFmt('Complete. %d bytes written to %s', [BytesWritten, OutFilePath])
                    else
                      AlertFmt('Failed. %d/%d bytes written to %s', [BytesWritten, OutLen, OutFilePath]);
                  finally
                    CloseFile(OutFile);
                  end;
                end;
            except
              on e:Exception do
                AlertFmt('Error = %s', [e.Message]);
            end;
          finally
            CloseFile(InFile);
          end;
        end;
    end;
end;
*)

function TfrmFiler.LoadFromUnit(BootParams: TBootParams): TCustomPsystemInterpreter;
var
  i: integer;
  mr: TMountResult;
  MountedUnitNr: integer;
begin

  VersionNr := BootParams.VersionNr;

  if FileExists(BootParams.VolumesToMount) then
    begin
      // dismount ALL volumes
      for i := 0 to MAX_FILER_UNITNR do
        with fVolumesList[i] do
          if (i in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
            UnmountVolume(i);

      // Mount the requested volumes, if possible
      MountListOfVolumes(BootParams.VolumesToMount);
    end;

  // If the volume specified in BootParams to be the boot volume is not mounted, then mount it now.
  if not Assigned(fVolumesList[BootParams.UnitNumber].TheVolume) then
    begin
      MountedUnitNr := BootParams.UnitNumber; // this is where we want it mounted
      mr := MountVolume(BootParams.VolumeFileName, MountedUnitNr);
      if (mr <> mrMounted) or (BootParams.UnitNumber <> MountedUnitNr) then
        raise ESystemError.CreateFmt('Volume %s did not mounted properly', [fVolumesList[BootParams.UnitNumber].VolumeName]);
    end;
    
  if Assigned(fVolumesList[BootParams.UnitNumber].TheVolume) then  // should always be true
    begin
      BootParams.RefCount := BootParams.RefCount + 1;
(* *)
      inc(fVolumesList[BootParams.UnitNumber].RefCount);
      case VersionNr of
        vn_VersionI_4,
        vn_VersionI_5,
        vn_VersionII:
          begin
            if BootParams.UseCInterp then
              fInterpreter := TCPsystemInterpreter.Create(self, fVolumesList, ThePSysWindow, Memo1, VersionNr, BootParams)
            else
              fInterpreter := TIIPsystemInterpreter.Create(self, fVolumesList, ThePSysWindow, Memo1, VersionNr, BootParams);
          end;
        vn_VersionIV{, vn_VersionIV_12}:
          begin
            fInterpreter := TIVPsystemInterpreter.Create(self, fVolumesList, ThePSysWindow, Memo1, VersionNr, BootParams);
            with (fInterpreter as TIVPsystemInterpreter) do
//                EnableExternalPool := BootParams.EnableExternalPool; // This is going to be overwritten by SYSTEM.MISCINFO
              EnableExternalPool := EnableExternalPool1.Checked;
          end
        else
          raise EUnknownVersion.Create('Unknown VersionNr');
      end;
(* *)
      result := fInterpreter;
    end
  else
    raise Exception.CreateFmt('Volume %d is not mounted', [BootParams.UnitNumber]);
end;

procedure TfrmFiler.NavigateClick(ClickType: TNavigatePush);
var
  PrevOk, NextOk: boolean;
  aBootParams: TBootParams;
begin
  with frmLoadVersion do
    begin
      PrevOk := RecNo > 0;
      NextOk := Recno < Pred(FilerSettings.RecentBootsList.Count);

      case ClickType of
        nbPrior:
          if PrevOk then
            begin
              (FilerSettings.RecentBootsList.Items[RecNo] as TBootParams).Assign(RecentBootParams); // save the changed values
              Dec(RecNo);
              RecentBootParams := FilerSettings.RecentBootsList.Items[RecNo] as TBootParams;
            end;
            
        nbNext:
          if NextOk then
            begin
              (FilerSettings.RecentBootsList.Items[RecNo] as TBootParams).Assign(RecentBootParams); // save the changed values
              Inc(RecNo);
              RecentBootParams := FilerSettings.RecentBootsList.Items[RecNo] as TBootParams;
            end;

        nbInsert:
          begin
            try
              aBootParams := TBootParams.Create(FilerSettings.RecentBootsList);
              with aBootParams do
                if Assigned(fVolumesList[fCurrentUnit].TheVolume) then
                  begin
                    VolumeName   := '';
                    SettingsFileToUse := '';
                    UnitNumber   := fCurrentUnit;
                    UseCInterp   := false;
//                  EnableExternalPool := false; // This is going to be overwritten by SYSTEM.MISCINFO
                    LastBootedDateTime := now;
                    RecentBootParams := aBootParams;
                  end
                else
                  Alert('Current unit is not assigned');
            finally
//            FilerSettings.RecentBootsList.Add;
            end;
          end;

        nbDelete:
          if FilerSettings.RecentBootsList.Count > 0 then
            begin
              FilerSettings.RecentBootsList.Delete(RecNo);
              if RecNo > 0 then
                Dec(RecNo);
              if (RecNo >= 0) and (Recno < Pred(FilerSettings.RecentBootsList.Count)) then
                RecentBootParams := FilerSettings.RecentBootsList.Items[RecNo] as TBootParams
              else
                RecentBootParams := nil;
            end;
      end;

      Enable_Buttons;
      btnPrev.Enabled   := RecNo > 0;
      btnNext.Enabled   := Recno < Pred(FilerSettings.RecentBootsList.Count);
      btnDelete.Enabled := FilerSettings.RecentBootsList.Count > 0;
    end;
end;

function TfrmFiler.GetBootParams(MenuItem: TMenuItem; var SaveOnly: boolean): TBootParams;
var
  mr:  TModalResult;
  mtr: TMountResult;
  ItemNr, UnitNr: integer;
  TempBootParam: TBootParams;
  JustCreated: boolean;
begin
  result := nil;
  JustCreated := false;

  ItemNr := MenuItem.Tag;
  if ItemNr < 0 then                                                        // not in the list
    begin
      TempBootParam := FilerSettings.RecentBootsList.Add as TBootParams;    // so add a new item to the list
      JustCreated   := true;

      UnitNr        := FindFirstMountedUnitNumber;

      // and set a bunch of defaults
      if UnitNr >= 4 then
        begin
          TempBootParam.UnitNumber     := UnitNr;
          TempBootParam.VersionNr      := self.VersionNr;
          TempBootParam.VolumeName     := fVolumesList[UnitNr].VolumeName;
          TempBootParam.VolumeFileName := fVolumesList[UnitNr].TheVolume.DOSFileName;
          TempBootParam.VolumesToMount := '';   // WAS: fListOfVolumesToMountCSV;
          {use the version number}
{$IfDef debugging}
          TempBootParam.SettingsFileToUse := DEBUGGERSettingsFileName(self.VersionNr);
{$EndIf}
        end
      else
        with TempBootParam do
          begin
            TempBootParam.UnitNumber     := 0;
            TempBootParam.VersionNr      := vn_Unknown;
            TempBootParam.VolumeName     := '';
            TempBootParam.VolumeFileName := '';
            TempBootParam.VolumesToMount := '';
            TempBootParam.SettingsFileToUse := '';
          end;

      MenuItem.Tag := FilerSettings.RecentBootsList.Count - 1;              // remember the new index
    end else
  if ItemNr < FilerSettings.RecentBootsList.Count then                      // otherwise select this item from the list
    TempBootParam := FilerSettings.RecentBootsList.Items[ItemNr] as TBootParams;

  FreeAndNil(frmLoadVersion);     // start fresh
  frmLoadVersion := TfrmLoadVersion.Create(self, fVolumesList);
  with frmLoadVersion do
    begin
      RecNo := 0;
      frmLoadVersion.RecentBootParams := TempBootParam;
      mr  := frmLoadVersion.ShowModal;
      if mr in [mrOK, mrSave] then
        begin
          TempBootParam := frmLoadVersion.RecentBootParams;
          UnitNr        := TempBootParam.UnitNumber;

          if Assigned(fVolumesList[UnitNr].TheVolume) then
            begin
              if fVolumesList[UnitNr].TheVolume.VolumeName <> TempBootParam.VolumeName then
                begin
                  if YesFmt('Volume name mismatch #%d: %s <> %s. Do you want to mount %s?',
                             [UnitNr,
                              fVolumesList[UnitNr].TheVolume.VolumeName,
                              TempBootParam.VolumeName, TempBootParam.VolumeName]) then
                    begin
                      UnmountVolume(UnitNr);
                      MountVolume(TempBootParam.VolumeFileName, UnitNr);
                      ShowMountedVolumes;
                    end
                  else
                    exit;
                end;
              result := TempBootParam;
            end
          else
            begin
              if FileExists(TempBootParam.VolumeFileName) then
                begin
                  mtr := MountVolume(TempBootParam.VolumeFileName, UnitNr);
                  if mtr = mrMounted then
                    begin
                      ShowMountedVolumes;
                      result := TempBootParam;
                    end
                  else
                    with TempBootParam do
                      begin
                        AlertFmt('Boot volume #%d:%s cannot not be mounted', [UnitNumber, VolumeFileName]);
                        result := nil;
                      end;
                end;
            end;
          if (not Empty(TempBootParam.VolumesToMount)) and (not FileExists(TempBootParam.VolumesToMount)) then
            AlertFmt('CSV file "%s" does not exist', [TempBootParam.VolumesToMount]);
        end
      else
        if JustCreated and (mr = mrCancel) then
          begin
            FreeAndNil(TempBootParam);  // so delete just added but unused Boot item
            result := nil;
          end;
    end;
end;

procedure TfrmFiler.BootInterpreter(BootParams: TBootParams);
begin
  with BootParams do
    begin
      BootParams.IsDebugging := false;
      fInterpreter := LoadFromUnit(BootParams);
      if Assigned(fInterpreter) then
        with fInterpreter as TCustomPsystemInterpreter do
          begin
            Load_PSystem(BootParams.UnitNumber);
            try
              EnableMenus(false, BootParams);
              Run_PSystem;
            finally
              EnableMenus(true, BootParams);
              FreeAndNil(fInterpreter);  // 1/10/2023- Deleted because I was getting memory errors:
                                         //            "Attempting to call virtual proc on released object"
                                         // 12/27/2023- reinstated to correct memory leak of fInterpreter when trying to execute
                                         //             an interpreter more than once. (See Diary for 12/27/2023)
            end;
          end;
    end;
end;

{$IfDef Debugging}
procedure TfrmFiler.DebugInterpreter(BootParams: TBootParams);
begin
  with BootParams do
    begin
      BootParams.IsDebugging := true;
      fInterpreter := LoadFromUnit(BootParams);
      if Assigned(fInterpreter) then
        begin
          if Assigned(frmPCodeDebugger) then
            FreeAndNil(frmPCodeDebugger);

          case VersionNr of
            vn_VersionI_4,
            vn_VersionI_5,
            vn_VersionII:
              if BootParams.UseCInterp then
                frmPCodeDebugger := TfrmPCodeDebuggerC.Create(self, fInterpreter, fVolumesList, UpdateStatus,
                                                              BootParams)
              else
                frmPCodeDebugger := TfrmPCodeDebuggerII.Create(self, fInterpreter, fVolumesList, UpdateStatus,
                                                               BootParams);

            vn_VersionIV:
              frmPCodeDebugger := TfrmPCodeDebugger.Create(self, fInterpreter, fVolumesList, UpdateStatus,
                                                           BootParams);
            vn_VersionIV_12:
              raise EUnknownVersion.Create('Unimplemented versionNr');  // i.e., it does not work
          end;

          if Assigned(frmPCodeDebugger) then
            with frmPCodeDebugger do
              begin
                FreeNotification(self);
                OnStatusUpdate := UpdateStatus;
                EnableMenus(false, BootParams);
                DebuggerLoadFromUnit(VersionNr, BootParams.UnitNumber);
                Show;
              end;
        end;
    end;
end;
{$EndIf}

procedure TfrmFiler.BootClick(Sender: TObject);
var
  BootParams: TBootParams;
  SaveOnly: boolean;
begin
  BootParams := GetBootParams(Sender as TMenuItem, SaveOnly);
  if Assigned(BootParams) and (not SaveOnly) then
    BootInterpreter(BootParams);
end;

procedure TfrmFiler.GetDefaultBootParams(UnitNr: Integer; var BootParams: TBootParams);
begin
  BootParams := TBootParams.Create(FilerSettings.RecentBootsList);
  // This could be a duplicate -- should it be deleted if so?
  with BootParams do
    begin
      VolumeName         := fVolumesList[UnitNr].VolumeName;
      VolumeFileName     := fVolumesList[UnitNr].TheVolume.DOSFileName;
      UnitNumber         := UnitNr;
//    UseCInterp         := UseCInterpParm;
      VersionNr          := self.VersionNr;
      if VersionNr in [vn_VersionI_4, vn_VersionI_5] then // could use a Peter Miller Interpreter
        UseCInterp := Yes('Use the Peter Miller interpreter?');
      LastBootedDateTime := now;
      RefCount           := 1;
      SettingsFileToUse  := ''; // Is this actually used ?
      VolumesToMount     := ''; // don't change the currently mounted volumes
    end;
end;

{$IfDef Debugging}
procedure TfrmFiler.DebugClick(Sender: TObject);
var
  BootParams: TBootParams;
  SaveOnly: boolean;
begin
  BootParams := GetBootParams(Sender as TMenuItem, SaveOnly);
  if Assigned(BootParams) and (not SaveOnly) then
    DebugInterpreter(BootParams);
end;


procedure TfrmFiler.DebugFromUnitClick(Sender: TObject);
var
  UnitNr: integer;
  BootParams: TBootParams;
begin
  with Sender as TMenuItem do
    begin
      UnitNr         := Tag;

      GetDefaultBootParams(UnitNr, BootParams);
      DebugInterpreter(BootParams);
    end;
end;

{$EndIf}

procedure TfrmFiler.BootFromUnitClick(Sender: TObject);
var
  UnitNr: integer;
  BootParams: TBootParams;
begin
  with Sender as TMenuItem do
    begin
      UnitNr         := Tag;
      GetDefaultBootParams(UnitNr, BootParams);
      BootInterpreter(BootParams);
    end;
end;


procedure TfrmFiler.pSystem1Click(Sender: TObject);
var
  BootParams: TBootParams;

  function CheckUnit(UnitNr: integer{; MenuItem: TMenuItem}): boolean;
  begin
    if UnitNr in FILER_LEGAL_UNITS then
      result := Assigned(fVolumesList[UnitNr].TheVolume)
    else
      result := false;
  end;

  procedure BuildBootSubmenu(MenuItem: TMenuItem; DoOnClick, DoOnBootFromUnitNrClick: TNotifyEvent);
  var
    SubMenuItem, SubSubMenuItem: TmenuItem;
    i, UnitNr: integer;
    RecentBootParams: TBootParams;
    Which: string;
  begin { BuildBootSubmenu }
    MenuItem.Clear;        // start with a clean slate

    // Boot straight to a volume
    SubMenuItem := TMenuItem.Create(MenuItem);
    SubMenuItem.Caption := 'Boot from Volume';
    MenuItem.Add(SubMenuItem);

    for UnitNr := 4 to MAX_FILER_UNITNR do
      with fVolumesList[UnitNr] do
        if (UnitNr in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
          begin
            SubSubMenuItem := TMenuItem.Create(SubMenuItem);
            SubSubMenuItem.Caption := Format('#%d:%s', [UnitNr, VolumeName]);
            SubSubMenuItem.Tag     := UnitNr;
            SubSubMenuItem.OnClick := DoOnBootFromUnitNrClick;
            SubMenuItem.Add(SubSubMenuItem);
          end;

    // add a divider
    SubMenuItem := TMenuItem.Create(MenuItem);
    SubMenuItem.Caption := '-';
    MenuItem.Add(SubMenuItem);

    // now show the recently booted items
    for i := 0 to FilerSettings.RecentBootsList.Count-1 do
      begin
        RecentBootParams := FilerSettings.RecentBootsList.Items[i] as TBootParams;
        with RecentBootParams do
          if RecentBootParams.IsClean then
            begin
              SubMenuItem := TMenuItem.Create(MenuItem);
              with SubMenuItem do
                begin
                  OnClick := DoOnClick;
                  case UseCInterp of
                    true:
                      Which := 'Peter Miller';
                    false:
                      Which := 'Laurence Boshell';
                  end;

                  Caption := Format('#%2d: (Vers %s) %9s: [%s] {%s}',
                                      [UnitNumber, VersionNrToAbbrev(VersionNr), VolumeName, VolumeFileName,
                                       Which{, ExtPoolStr}]);
                  Tag := i;   // remember what was selected
                end;
              MenuItem.Add(SubMenuItem);
            end;
      end;

    // add a divider
    SubMenuItem := TMenuItem.Create(MenuItem);
    SubMenuItem.Caption := '-';
    MenuItem.Add(SubMenuItem);

    // And the ability to specify
    SubMenuItem := TMenuItem.Create(MenuItem);
    with SubMenuItem do
      begin
        Caption := 'Specify...';
        OnClick := DoOnClick;
        Tag     := -1;
      end;
    MenuItem.Add(SubMenuItem);
  end;  { BuildBootSubmenu }

begin { pSystem1Click }
  with Boot1 do
    begin
      if not fSysRunning then
        begin
          BootParams := FilerSettings.RecentBootsList.FindLatestBootItem;
          RebootLastSystem1.Caption := Format('Reboot last system: %s V%s %s',
                                              [IIF(BootParams.UseCInterp, 'PM', 'LB'),
                                               VersionNrStrings[BootParams.VersionNr].NumStr,
                                               ExtractFileName(BootParams.VolumeFileName)]);
          BuildBootSubmenu(Boot1,  BootClick,  BootFromUnitClick);
{$IfDef Debugging}
          BuildBootSubMenu(Debug1, DebugClick, DebugFromUnitClick);
{$Else}
          Debug1.Visible := false;
{$EndIf}
        end
    end;
end;  { pSystem1Click }

procedure TfrmFiler.ShowMountedVolumes;
const
  C1 = 3;
  C2 = 3;
  C3 = 2;
  C4 = 2;
  C5 = 15;
  C6 = 7;
  C7 = 2;
  C8_ = 64;
  C9 = 6;
  C10 = 15;
var
  i: integer;
  C8: integer;
  ThereAreSubsidiary: boolean;
begin { TfrmFiler.ShowMountedVolumes }
  // Are there any sibsidiary volumes?
  ThereAreSubsidiary := false;
  for i := 0 to MAX_FILER_UNITNR do
    with fVolumesList[i] do
      if (i in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        with TheVolume do
          if ParentUnitNumber > 0 then
            ThereAreSubsidiary := true;

  AddDivider;
  WriteLn('Vols on-line:');

  Write('   ', C1);
  Write(' # ', C2);
  Write('', C3);
  Write('', C4);
  Write('VolumeName', C5);
  Write('DeovBlk', C6);
  Write('', C7);
  C8 := 100; // if there is enough room display more of the DOS path
  if ThereAreSubsidiary then
    begin
      Write('Par #', C9);
      Write('', 2);
      Write('Parent Name', C10);
      C8 := C8_;
    end;
  Write('DOSPath', C8);
  WriteLn;

  for i := 0 to MAX_FILER_UNITNR do
    with fVolumesList[i] do
      if (i in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        with TheVolume do
          begin
            if i = fCurrentUnit then
              Write('-->', C1)
            else
              Write('   ', C1);
            Write(' # ', C2);
            Write(i, C3);
            Write(': ', C4);
            Write(VolumeName + ':', C5);
            Write('[');
            Write(DeovBlk, C6-2);
            Write('] ');
            Write('', C7);
            if ThereAreSubsidiary then
              if ParentUnitNumber <> 0 then
                begin
                  Write(ParentUnitNumber, C9);
                  Write('', 2);
                  Write(fVolumesList[ParentUnitNumber].VolumeName+':', C10);
                end
              else
                begin
                  Write('', C9);
                  Write('', 2);
                  Write('', C10);
                end;
            Write(DOSFileName, C8);
            WriteLn;
          end;
end;  { TfrmFiler.ShowMountedVolumes }


procedure TfrmFiler.MountedVolumes1Click(Sender: TObject);
begin
  ShowMountedVolumes;
end;

procedure TfrmFiler.CopyTextfilefromDOS1Click(Sender: TObject);
var
  FilePath, PSysFileName: string;
  TheVolume: TVolume;
  ErrorMessage: string;
  OpenDialog: TOpenDialog;
  i: integer;
begin
  FilePath  := fInputFolder + '*.*';
  if Assigned(CurrentVolume) then
    begin
      TheVolume := CurrentVolume; 
      OpenDialog := TOpenDialog.Create(self);
      try
        with OpenDialog do
          begin
            Options    := [ofFileMustExist, ofAllowMultiSelect];
            DefaultExt := TXT_EXT;
            FileName   := FilePath;
            Filter     := 'Text files (*.txt,*.text,*.pas)|*.TXT;*.TEXT;*.PAS';    // |Pascal files (*.pas)|*.PAS
            InitialDir := ExtractFilePath(FilePath);
            Title      := 'Select txt file to copy to pSys';
            if Execute then
              begin
                for i := 0 to Files.Count-1 do
                  begin
                    PSysFileName := TheVolume.PSysNameFromDosName(Files[i], 'TEXT');
                    if TheVolume.CopyDosTxtToPSysText(Files[i], PSysFileName, ErrorMessage,
                                                      False) then
                    else
                      Alert(ErrorMessage);
                  end;
                DisplayDirectory(fCurrentUnit, '', true);
                fInputFolder := ExtractFilePath(FileName);
              end;
          end;
      finally
        FreeAndNil(OpenDialog);
      end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.UpdateStatus( const Msg: string;
                                  DoLog: boolean = true;
                                  DoStatus: boolean = true;
                                  Color: TColor = clBtnFace);
begin
  if DoStatus then
    begin
      lblStatus.Caption := Msg;
      lblStatus.Color   := Color;
      Application.ProcessMessages;
    end;

  if DoLog then
    WriteLn(Msg);
end;


procedure TfrmFiler.ShowMountStatus;
var
  TheVolume: TVolume;
  Msg: string;
begin
  TheVolume := CurrentVolume;
  if Assigned(TheVolume) then
    Msg := Format('%d volumes mounted. Current volume is #%d: [%s]',
                                [MountedCount, fCurrentUnit, TheVolume.VolumeName])
  else
    Msg := Format('%d volumes mounted. There is no current volume.',
                                [MountedCount, fCurrentUnit]);
  lblStatus.Caption := Msg;
  WriteLn(Msg);
end;

procedure TfrmFiler.UnmountVolume(VolumeNumber: integer; ShowMounted: boolean = true);
var
  TheVolume, svol: TVolume;
  VolNr: integer;
begin
  if VolumeNumber in FILER_LEGAL_UNITS then
    begin
      TheVolume := fVolumesList[VolumeNumber].TheVolume;
      if Assigned(TheVolume) then
        begin
          // if there is a subsidiary volume mounted, unmount it first
          svol := fVolumesList[VolumeNumber].TheVolume.CurrentSVOL;
          if Assigned(svol) and VolumeIsMounted(svol, VolNr) then
            begin
              UnmountVolume(Volnr);
              TheVolume.CurrentSVOL := nil;
            end;

          FreeAndNil(TheVolume);
          with fVolumesList[VolumeNumber] do
            begin
              if ParentUnitNumber <> 0 then
                fVolumesList[ParentUnitNumber].TheVolume.CurrentSVOL := nil;

              TheVolume  := nil;
              VolumeName := '';
              UnitNumber := 0;
              RefCount   := 0;
              ParentUnitNumber := 0;
            end;
          Log_Status(Format('Dismounted volume #%d:', [VolumeNumber]));
          if ShowMounted then
            ShowMountStatus;
        end
      else
        AlertFmt('Volume #%d: is not currently mounted', [VolumeNumber]);
    end
  else
    AlertFmt('%d is not a legal volume number', [VolumeNumber]);
end;

function TfrmFiler.MountedCount: integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to MAX_FILER_UNITNR do
    if i in FILER_LEGAL_UNITS then
      if Assigned(fVolumesList[i].TheVolume) then
        Inc(result);
end;


procedure TfrmFiler.DeleteFile1Click(Sender: TObject);
var
  FileIDString: string;
  TheVolume: TVolume;
begin
  TheVolume := CurrentVolume;
  if not Assigned(TheVolume) then
    NoCurrentVolume
  else
    if GetString('Select pSystem file name (or number) to delete from current volume',
                 'File ID', FileIDString, TIDLENG) then
      begin
        if TheVolume.DeletePSystemFile(FileIDString) then
          DisplayDirectory(fCurrentUnit, '', true);
      end;
end;

function TfrmFiler.GetCurrentVolume: TVolume;
begin
  if fCurrentUnit in FILER_LEGAL_UNITS then
    result := fVolumesList[fCurrentUnit].TheVolume
  else
    result := nil;
end;

procedure TfrmFiler.RenamepSysFile1Click(Sender: TObject);
var
  mr: integer;
  NewName: string;
begin
  if not Assigned(frmRenameFile) then
    frmRenameFile := TfrmRenameFile.Create(self);
  with frmRenameFile do
    begin
      mr := ShowModal;
      if (mr = mrOK) and (not Empty(leOldFileName.Text)) and (not empty(leNewFileName.Text))then
        begin
          NewName := leNewFileName.Text;
          if CurrentVolume.RenamePSystemFile(leOldFileName.Text, NewName) then
            AlertFmt('Renamed "%s" to "%s"', [leOldFileName.Text, NewName])
          else
            AlertFmt('Rename FAILED ("%s" to "%s")', [leOldFileName.Text, NewName]);
          DisplayDirectory(UnitNumberFromVolumeName(CurrentVolume.VolumeName), '', true);
        end
    end;
end;

procedure TfrmFiler.EnableMenus(NewState: boolean; BootParams: TBootParams);
const
  C = ', ';
{$IfDef debugging}
  Compiled = 'FILER_DEBUGGER.EXE';
{$else}
  Compiled = 'FILER.EXE';
{$endIf}
var
  LogRunsFile: TextFile;
  Action: string;
begin
  EditpSystemTextFile1.Enabled  := NewState;
  FindStringinWindow1.Enabled   := NewState;
  Find1.Enabled                 := Newstate;
  fSysRunning                   := not NewState;
  Boot1.Enabled                 := not fSysRunning;
  Debug1.Enabled                := not fSysRunning;
  RebootLastSystem1.Enabled     := not fSysRunning;
  
  
{$IfDef LogRuns}
  if fSysRunning then  // starting a run
    begin
      fCurrentBootParams := BootParams;
      fLastError         := '';
    end
  else                 // finishing a run
    BootParams := fCurrentBootParams;

  if Assigned(BootParams) then
    with BootParams do
      begin
        AssignFile(LogRunsFile, FilerSettings.LogRunsFileName);
        try
          if FileExists(FilerSettings.LogRunsFileName) then
            try
              Append(LogRunsFile)
            except
              on e:Exception do
                AlertFmt('Cannot open %s [%s]', [FilerSettings.LogRunsFileName, e.Message])
            end
          else
            begin
              ReWrite(LogRunsFile);
              system.writeLn(LogRunsFile,
                      'DateTime', C,
                      'Action', C,
                      'UnitNumber', C,
                      'VolumeName:', C,
                      'VolumeFileName', C,
                      'VersionNr', C,
                      'Derivation', C,
                      'COMPILED for', c,
                      'LastError');
            end;

          Action := IIF(fSysRunning, 'Booting',
                                     'Halted ');
          system.WriteLn(LogRunsFile, DateTimeToStr(Now), C,
                                      Action, C,
                                      UnitNumber, C,
                                      VolumeName+':', C,
                                      VolumeFileName, C,
                                      VersionNrStrings[VersionNr].Abbrev, C,
                                      IIF(UseCInterp, 'Peter Miller', 'Laurence Boshell'), C,
                                      COMPILED, C,
                                      fLastError);
            if not fSysRunning then  // halted
              system.WriteLn(LogRunsFile);
        finally
          CloseFile(LogRunsFile);
        end;
      end
  else
    raise Exception.Create('System error. LogRuns. BootParams not assigned');
{$endIf LogRuns}
end;

procedure TfrmFiler.CopyBinaryfilefromDOS1Click(Sender: TObject);
var
  i: integer;
  FilePath, PSysFileName: string;
  TheVolume: TVolume;
  ErrorMessage: string;
begin
  FilePath  := fOutputFolder + '*.*';
  if Assigned(CurrentVolume) then
    begin
      TheVolume := CurrentVolume;
      with OpenDialog1 do
        begin
          Options    := [ofFileMustExist, ofAllowMultiSelect];
          DefaultExt := 'svol';
          FileName   := FilePath;
          Filter     := 'p-System Volumes (*.vol,*.svol)|*.vol;*.svol|Any File (*.*)|*.*';
          InitialDir := ExtractFilePath(FilePath);
          Title      := 'Select DOS binary file to copy to pSys';
          if Execute then
            begin
              for i := 0 to Files.Count-1 do
                begin
                  FilePath     := Files[i];
                  PSysFileName := ExtractFileName(FilePath);
                  if TheVolume.CopyDosToPSys(FilePath, PSysFileName, ErrorMessage) then
                  else
                    Alert(ErrorMessage);
                end;
              DisplayDirectory(fCurrentUnit, '', true)
            end;
        end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.LogMatchingLine( const FilePath, FileName, Line: string;
                                     LastAccessTime: TDateTime;
                                     const DOSFilePath: string = '');
var
  Msg: string;
begin
  Msg := Format('=====>  %-10s  FileName: %-20s [%s] %s',
                [DateToStr(lastAccessTime), FileName, FilePath, DOSFilePath]);
  Log_Status(Msg);
  if Line <> '' then
    Log_Status('        ' + Line);
  Log_Status('');
  inc(fSearchInfo.MatchesFound);
  if fSearchInfo.Abort then
    raise Exception.Create('Operator abort');
end;

procedure TfrmFiler.CloseOutputFile(SearchInfo: TSearchInfo);
var
  Msg: string;
  cf: TCRTFuncs;
begin
  with SearchInfo do
    case SearchMode of
      smCRTInfo, smKEYInfo:
        begin
          system.WriteLn(fAltOutputFile);
          system.WriteLn(fAltOutputFile, ',* indicates prefixed by lead-in char');
          system.WriteLn(fAltOutputFile, ',Term Type is just a guess');

          if SearchMode = smCRTInfo then
            for cf := cf_LeadInToScreen to cf_MoveCursorHome do
              with FuncNames[cf] do
                system.writeln(fAltOutputFile, ',', Abbrev, ' = ', SN);

          CloseFile(fAltOutputFile);
          ExecAndWait(fAltFileName, '', false);

          Msg := Format('%d %s files scanned. Results written to %s',
                        [MatchesFound, CSYSTEM_MISCINFO, fAltFileName]);
          Log_Status(Msg);
        end;
{$IfDef SegInfo}
      smSegments:
        begin
          CloseFile(fAltOutputFile);
          if YesFmt('Do you want to open the output file "%s"', [fAltFileName]) then
            ExecAndWait(fAltFileName, '', false);
          Msg := Format('%d files scanned. Results written to %s',
                        [MatchesFound, fAltFileName]);
          Log_Status(Msg);
        end;
{$EndIf SegInfo}
{$IfDef ProcInfo}
      smProcedures:
        begin
          CloseFile(fAltOutputFile);
          if YesFmt('Do you want to open the output file "%s"', [fAltFileName]) then
            ExecAndWait(fAltFileName, '', false);
          Msg := Format('%d files scanned. Results written to %s',
                        [MatchesFound, fAltFileName]);
          Log_Status(Msg);
        end;
{$EndIf}
{$IfDef PoolInfo}
      smPoolInfo:
        begin
          if NumberOfErrors > 0 then
            system.WriteLn(fAltOutputFile, ',,,,,,,,,Records with invalid PoolInfo were not reported');
          CloseFile(fAltOutputFile);
          if YesFmt('Do you want to open the output file "%s"', [fAltFileName]) then
            ExecAndWait(fAltFileName, '', false);

          Msg := Format('%d %s files scanned. Results written to %s',
                        [MatchesFound, CSYSTEM_MISCINFO, fAltFileName]);
          Log_Status(Msg);
        end;
{$endIf}
    end;
end;

function TfrmFiler.OpenOutputFile(SearchMode: TSearchMode): string;
var
  Line: string;
  BaseName: string;

  procedure InitProcedureMapping(const OutputFile: TextFile);
  begin { InitProcedureMapping }
    SetLength(Fields,     ord(High(TFieldNumbers))+1);
    SetLength(FieldNames, ord(High(TFieldNumbers))+1);

    // Initializing it this way makes it easy to re-order the fields, add or delete fields
    FieldNames[ord(FLD_SEG_NR)]            := 'SegNr';
    FieldNames[ord(FLD_Flag)]              := 'Flag';
    FieldNames[ord(FLD_Version)]           := 'Version';
    FieldNames[ord(FLD_Origin)]            := 'Origin';
    FieldNames[ord(FLD_DOS_Volume_Name)]   := 'DOS Volume Name';
    FieldNames[ord(FLD_pSys_Volume_Name)]  := 'Volume';
    FieldNames[ord(FLD_pSys_FileName)]     := 'pSys FileName';
    FieldNames[ord(FLD_Volume_Date)]       := 'Volume Date';
    FieldNames[ord(FLD_File_Date)]         := 'File Date';
    FieldNames[ord(FLD_Segment_Name)]      := 'Segment Name';
    FieldNames[ord(FLD_CodeFirstBlock)]    := 'Code Block';
    FieldNames[ord(FLD_CodeLeng)]          := 'Code Leng';
    FieldNames[ord(FLD_NrProcs)]           := 'Nr Procs';
    FieldNames[ord(FLD_SegKind)]           := 'Kind';
    FieldNames[ord(FLD_Info)]              := 'Info';
    FieldNames[ord(FLD_Error_Number)]      := 'Err #';
    FieldNames[ord(FLD_ItIsFlipped)]       := 'Flipped';

    Delimited_Info.Field_Seperator := ',';
    Delimited_Info.QuoteChar       := '''';
  end;  { InitProcedureMapping }

begin { TfrmFiler.OpenOutputFile }
  case SearchMode of
    smCrtInfo:
      BaseName := 'CrtInfo';
    smKeyInfo:
      BaseName := 'KeyInfo';
{$IfDef SegInfo}
    smSegments:
      BaseName := 'Segments';
{$EndIf SegInfo}
{$IfDef ProcInfo}
    smProcedures:
      BaseName := 'Procedures';
{$EndIf ProcInfo}
{$IfDef PoolInfo}
    smPoolInfo:
      BaseName := 'PoolInfo';
{$endIf}
  end;

  result := Format('%s%s.%s', [FilerSettings.ReportsPath, BaseName, CSV_EXT]);

  result := FileNameByDate(result);

  if BrowseForFile('Output .CSV file', result, CSV_EXT) then
    begin
      AssignFile(fAltOutputFile, result);
      try
        Rewrite(fAltOutputFile);
        case SearchMode of
          smCRTInfo:
            Line := TCrtInfo.CRTHeaderLine(LOW_CRT_FUNC, HIGH_CRT_FUNC);
          smKeyInfo:
            Line := TCrtInfo.CRTHeaderLine(LOW_KEY_FUNC, HIGH_KEY_FUNC);
{$IfDef SegInfo}
          smSegments:
            begin
              InitProcedureMapping(fAltOutputFile);
              Line := Contruct_Delimited_Line(FieldNames, Delimited_Info);
            end;
{$EndIf SegInfo}
{$IfDef ProcInfo}
         smProcedures:
           begin
             Line := 'Procedure Listing report';
           end;
{$endIf ProcInfo}
{$IfDef PoolInfo}
          smPoolInfo:
            begin
              Line := 'PoolOutside,'+'PoolSize,'+'PoolBaseAddr,'+'PoolBase[0],'+'Poolbase[1],'+'Resolution,'+
                      'p-Sys File Name,'+'Last Access,'+'DOS Volume Name,'+ 'Warning';
            end;
{$endIf PoolInfo}
        end;
        System.WriteLn(fAltOutputFile, Line);  // write the field names
      except
        on e:Exception do
          AlertFmt('Exception (%s) when opening %s. Make sure that it is not already open.', [e.Message, result]);
      end;
    end
  else
    raise Exception.Create('Cancelled by operator');
end;  { TfrmFiler.OpenOutputFile }


procedure TfrmFiler.SearchManyVolumes(TheSearchMode: TSearchMode);
var
  RootFolder: string;
  aFileName, Ext, Msg: string;
  mr, i: integer;
  LowDateStr, HighDateStr: string;

  procedure ProcessVolume(const VolumeName: string);
  var
    Volume: TVolume;
  begin
    Log_Status('Processing Volume: ' + VolumeName, false);
    if LineContainsTarget(fSearchInfo, aFileName) then
      begin
        WriteLn(Format('VolumeName %s matches string', [VolumeName]));
        Inc(fSearchInfo.MatchesFound);
      end;

    Volume := CreateVolume(self, VolumeName); // 6/16/2023 moved out of TRY..FINALLY - leaky memory problem
    try
      Volume.OnSVOLFree        := VolumeBeingFreed;
      Volume.OnStatusProc      := Log_Status;
      Volume.OnSearchFoundProc := LogMatchingLine;
      Volume.VolumeName        := ExtractFileBase(VolumeName);  // this may be overwritten in LoadVolumeInfo
      try
        Volume.LoadVolumeInfo(DIRECTORY_BLOCKNR);
        case fSearchInfo.SearchMode of
          smASCII:
            Volume.ScanVolumeForString(@fSearchInfo);
          SMHEX:
            Volume.ScanVolumeForHexString(@fSearchInfo);
          smVersionNumber:
            Volume.ScanVolumeForVersionNumber(@fSearchInfo);
          smCrtInfo, smKeyInfo:
            Volume.ScanVolumeForMiscinfo(@fSearchInfo, fAltOutputFile);
{$IfDef SegInfo}
          smSegments:
            Volume.ScanVolumeForSegmentInfo(@fSearchInfo, fAltOutputFile);
{$endIf SegInfo}
{$IfDef ProcInfo}
          smProcedures:
            Volume.ScanVolumeForProcedureInfo(@fSearchInfo, fAltOutputFile);
{$endIf ProcInfo}
{$IfDef PoolInfo}
          smPoolInfo:
            Volume.ScanVolumeForPoolInfo(@fSearchInfo, fAltOutputFile);
{$endIf PoolInfo}
        end;
      except
        on e:Exception do
          Log_Status(e.Message, fSearchInfo.LogMountingErrors)
      end;
    finally
      Inc(fSearchInfo.VolumesSearched);
      FreeAndNil(Volume);
    end;
  end;

  procedure ProcessDOSTextFile(aFileName: string);
  var
    InFile: TextFile;
    Line, FName, FPath: string;
    creationTime, lastAccessTime, lastModificationTime: TDateTime;
  begin { ProcessDOSTextFile }
    AssignFile(InFile, aFileName);
    Reset(InFile);
    try
      if GetFileTimes(aFileName, creationTime, lastAccessTime,
                       lastModificationTime) then
       while (not Eof(InFile)) and (not fSearchInfo.Abort) do
        begin
          ReadLn(InFile, Line);
          Line := UpperCase(Line);
          if LineContainsTarget(fSearchInfo, Line) then
            begin
              FName := ExtractFileName(aFileName);
              FPath := ExtractFilePath(aFileName);
              LogMatchingLine(FPath, FName, Line, lastModificationTime);
            end;
        end;
    finally
      CloseFile(InFile);
      inc(fSearchInfo.DOSTextFilesSearched);
    end;
  end;  { ProcessDOSTextFile }

  procedure ProcessDOSDataFile(aFileName: string);
  const
    MAXBLOCKCOUNT = 500;
    MAXBLOCKSIZE = MAXBLOCKCOUNT * BLOCKSIZE;
  type
    TBigChunk  = array[0..MAXBLOCKSIZE-1] of byte;
  var
    Infile: file;
    Buffer: ^TBigChunk;
    FileSize: system.integer;

    function MatchesSearch(indx: system.integer): boolean;
    var
      i: integer;
    begin { MatchesSearch }
      for i := 0 to fSearchInfo.NrHexBytes-1 do
        begin
          if Buffer^[indx+i] <> fSearchInfo.HexBytes[i] then
            begin
              result := false;
              exit;
            end;
        end;
      result := true;
    end;  { MatchesSearch }

    procedure FindMatchingBytes;
    var
      indx: system.integer;
    begin { FindMatching Bytes }
      try
        for indx := 0 to FileSize-fSearchInfo.NrHexBytes-1 do
          begin
            if indx >= MAXBLOCKSIZE then
              break;
            if MatchesSearch(indx) then
              begin
                inc(fSearchInfo.MatchesFound);
                Log_Status(Format('=====>  Hex string found offset @ %s in %s',
                                       [BothWays(indx), aFileName]));
              end;
          end;
      except
        on e:Exception do
          AlertFmt('%s (while processing %s)', [e.Message, aFileName]);
      end;
    end;  { FindMatchingBytes }

  begin { ProcessDOSDataFile }
    FileSize := FileSize32(aFileName);
    if FileSize > 0 then
      begin
        if FileSize > MAXBLOCKSIZE then
          begin
            Log_Status(fORMAT('Only the 1st %d bytes of %s will be searched', [MAXBLOCKSIZE, aFileName]));
            FileSize := MAXBLOCKSIZE;
          end;
        AssignFile(Infile, aFileName);
        Reset(Infile, FileSize);
        GetMem(Buffer, FileSize);

        try
          BlockRead(InFile, Buffer^, 1);
          FindMatchingBytes;
        finally
          CloseFile(InFile);
          FreeMem(Buffer);
        end;
      end;
  end;  { ProcessDOSDataFile }

  procedure ProcessFolder(CurrentFolder: string; var OutputFile: TextFile);
  var
    DOSErr: integer;
    FileName, Temp, CurrentFileName: string;
    SearchRec: TSearchRec;
  begin { ProcessFolder }
    Log_Status('Processing Folder: ' + CurrentFolder, false);
    DOSErr := FindFirst(CurrentFolder + '*.*', faAnyFile, SearchRec);
    try
      while DOSErr = 0 do
        begin
          try
            if not ((SearchRec.Name = '.') or (SearchRec.Name = '..')) then
              if ((SearchRec.Attr and faDirectory) <> 0) then
                begin
                  Temp := CurrentFolder + SearchRec.Name + '\';
                  ProcessFolder(Temp, OutputFile)
                end
              else
                begin
                  if fSearchInfo.Case_Sensitive then
                    FileName := SearchRec.Name
                  else
                    FileName := UpperCase(SearchRec.Name);

                  Ext      := ExtractFileExt(FileName);
                  with fSearchInfo do
                    begin
//                    if OKFileDateTime(SearchRec.Time, LowDate, HighDate) then  // Commented out because even though
                                                                                 // the volume may not be in acceptable data range,
                                                                                 // individual files might be.
                        begin
                          if OKFileDateTime(SearchRec.Time, LowDate, HighDate) and
                             LineContainsTarget(fSearchInfo, FileName) then
                            LogMatchingLine(CurrentFolder, FileName,
                                            FileName,
                                            FileDateToDateTime(FileAge(CurrentFolder + FileName)));
                          CurrentFileName := CurrentFolder + FileName;
                          case SearchMode of
                            smASCII:
                              begin
                                if LegalPSysVolumeExt(Ext) then
                                  ProcessVolume(CurrentFileName) else
                                if not fSearchInfo.OnlySearchFileNames then
                                  begin
                                    if (SameText(Ext, CTXT)           // .txt
                                        or SameText(Ext, CPAS)        // .pas
                                        or SameText(Ext, CLIS)        // .lis
                                        or SameText(Ext, CEXT)        // .c
                                        or SameText(Ext, HEXT)) then  // .h
                                      if OKFileDateTime(SearchRec.Time, LowDate, HighDate) then
                                        ProcessDOSTextFile(CurrentFileName);
                                  end
                              end;

                            smHEX:
                              begin
                                if LegalPSysVolumeExt(Ext) then
                                  ProcessVolume(CurrentFileName)
                                else
                                  if OKFileDateTime(SearchRec.Time, LowDate, HighDate) then
                                    ProcessDOSDataFile(CurrentFileName);
                              end;

                            smVersionNumber, smCrtInfo, smKeyInfo:
                              begin
                                if LegalPSysVolumeExt(Ext) then
                                  ProcessVolume(CurrentFileName);
                              end;
{$IfDef SegInfo}
                            smSegments:
                              begin
                                if LegalPSysVolumeExt(Ext) then
                                  ProcessVolume(currentFileName);
                              end;
{$endIf SegInfo}
{$IfDef ProcInfo}
                            smProcedures:
                              begin
                                if LegalPSysVolumeExt(Ext) then
                                  ProcessVolume(currentFileName);
                              end;
{$endIf ProcInfo}
{$IfDef PoolInfo}
                            smPoolInfo:
                              if LegalPSysVolumeExt(Ext) then
                                ProcessVolume(CurrentFileName);
{$EndIf PoolInfo}
                        end;
                    end;
                  end;
              end;
          except
            on e:Exception do
              Log_Status(Format('%s while processing %s', [e.Message, SearchRec.Name]));
          end;
          DOSErr   := FindNext(SearchRec);
          if fSearchInfo.Abort then
            Break;
        end;
    finally
      Inc(fSearchInfo.FoldersSearched);
      FindClose(SearchRec);
    end;
  end;  { ProcessFolder }

begin { SearchManyVolumes }
  if not Assigned(frmSearchForString) then
    frmSearchForString := TfrmSearchForString.Create(self);
  with frmSearchForString do
    begin
      if TheSearchMode in [smCRTInfo, smKeyInfo
{$IfDef PoolInfo}
                           ,smPoolInfo
{$endIf PoolInfo}
                           ] then
        begin
          SearchMode := TheSearchMode;
          SearchFor  := '*.MISCINFO';
        end
      else if TheSearchMode in [smUnknown] then
        begin
          SearchMode := smAscii;
          SearchFor  := fSearchInfo.SearchString;
        end;

      HexBytes          := fSearchInfo.HexBytes;
      NrHexBytes        := fSearchInfo.NrHexBytes;
      KeyWordSearch     := fSearchInfo.KeyWordSearch;
      CaseSensitive     := fSearchInfo.Case_Sensitive;
      IgnoreUnderScores := fSearchInfo.IgnoreUnderScores;
      OnlySearchFileNames := fSearchInfo.OnlySearchFileNames;
      LogMountingErrors := fSearchInfo.LogMountingErrors;
      AllKeyWords       := fSearchInfo.AllKeyWords;
      WildMatch         := fSearchInfo.WildCardSearch;
      AnyKeyWords       := fSearchInfo.AnyKeyWords;

      mr := ShowModal;
      if mr = mrOk then
        begin
          AddDivider;
          fSearchInfo.SearchMode          := SearchMode;
          fSearchInfo.KeyWordSearch       := KeyWordSearch;
          fSearchInfo.Case_Sensitive      := CaseSensitive;
          fSearchInfo.LogMountingErrors   := LogMountingErrors;
          fSearchInfo.IgnoreUnderScores   := IgnoreUnderScores;
          fSearchInfo.OnlySearchFileNames := OnlySearchFileNames;
          fSearchInfo.AllKeyWords         := AllKeyWords;
          fSearchInfo.AnyKeyWords         := AnyKeyWords;
          fSearchInfo.NumberOfErrors      := 0;
          fSearchInfo.WildCardSearch    := WildMatch;
          case SearchMode of
            smASCII:
              begin
                if fSearchInfo.Case_Sensitive then
                  fSearchInfo.SearchString := SearchFor
                else
                  fSearchInfo.SearchString := UpperCase(SearchFor);

                if fSearchInfo.IgnoreUnderScores then
                  begin
                    i    := Length(fSearchInfo.SearchString);
                    while i > 0 do
                      begin
                        if fSearchInfo.SearchString[i] = '_' then
                          Delete(fSearchInfo.SearchString, i, 1);
                        i := i - 1;
                      end;
                  end;

                Log_Status(Format('Searching for ASCII string: %s', [SearchFor]));
              end;
            smHex:
              begin
                fSearchInfo.HexBytes     := HexBytes;
                fSearchInfo.NrHexBytes   := NrHexBytes;
                Log_Status(Format('Searching for HEX   string: %s', [SearchFor]));
              end;
            smVersionNumber:
              fSearchInfo.SearchString := UpperCase(SearchFor);
            smCRTInfo, smKeyInfo
{$IfDef PoolInfo}
              , smPoolInfo
{$EndIf PoolInfo}
              :
              begin
                fSearchInfo.SearchString        := UpperCase(SearchFor);
                fSearchInfo.Case_Sensitive      := false;
                fSearchInfo.LogMountingErrors   := LogMountingErrors;
                fSearchInfo.IgnoreUnderScores   := false;
                fSearchInfo.OnlySearchFileNames := false;
                fSearchInfo.AllKeyWords         := false;
                fSearchInfo.AnyKeyWords         := false;

                fAltFileName := OpenOutputFile(fSearchInfo.SearchMode);
              end;
{$IfDef SegInfo}
            smSegments:
              begin
                fSearchInfo.SearchString        := UpperCase(SearchFor);
                fSearchInfo.LogMountingErrors   := LogMountingErrors;

                fAltFileName := OpenOutputFile(fSearchInfo.SearchMode);
              end;
{$endIf SegInfo}
{$IfDef ProcInfo}
           smProcedures:
             begin
                fSearchInfo.SearchString        := UpperCase(SearchFor);
                fSearchInfo.LogMountingErrors   := LogMountingErrors;

                fAltFileName := OpenOutputFile(fSearchInfo.SearchMode);
             end;
{$endIf ProcInfo}
          end;

          fSearchInfo.LowDate      := LowDate;
          fSearchInfo.HighDate     := HighDate;
          fSearchInfo.MatchesFound := 0;
          fSearchInfo.DOSTextFilesSearched := 0;
          fSearchInfo.pSystemTextFilesSearched := 0;
          fSearchInfo.FoldersSearched := 0;
          fSearchInfo.VolumesSearched := 0;
          fSearchInfo.Abort           := false;

          RootFolder    := FilerSettings.SearchFolder;
          if BrowseForFolder('SEARCH Root Folder', RootFolder) then
            begin
              with fSearchInfo do
                begin
                  if LowDate <> BAD_DATE then
                    LowDateStr := DateToStr(LowDate)
                  else
                    LowDateStr := '*';

                  if HighDate <> BAD_DATE then
                    HighDateStr := DateToStr(HighDate)
                  else
                    HighDateStr := '*';

                  Log_StatusFmt('Search mode: %s, Dates: %s->%s, %s %s %s %s',
                               [SearchModeNames[SearchMode],
                                LowDateStr,
                                HighDateStr,
                                IIF(KeyWordSearch,       'Key Word Search, ', ''),
                                IIF(Case_Sensitive,      'Case Sensitive, ', ''),
                                IIF(IgnoreUnderScores,   'Ignore Underscores, ', ''),
                                IIF(OnlySearchFileNames, 'File Names Only ', '')
                               ]);
                  Log_StatusFmt('Root folder for search: %s', [RootFolder]);
                  Log_Status('');
                end;

              btnAbort.Caption  := 'Abort';
              btnAbort.Visible  := true;
              FilerSettings.SearchFolder := RootFolder;
              with fSearchInfo do
                begin
                  FoldersSearched        := 0;
                  VolumesSearched        := 0;
                  MatchesFound           := 0;
                  DOSTextFilesSearched   := 0;
                end;
              ProcessFolder(RootFolder, fAltOutputFile);
              with fSearchInfo do
                begin
                  Msg := Format('%d matches were found. %d folders were searched. %d volumes were searched, %d errors occurred',
                                [MatchesFound, FoldersSearched, VolumesSearched, NumberOfErrors]);
                  Log_Status(Msg);
                  CloseOutputFile(fSearchInfo);
                end;
              btnAbort.Visible := false;
            end;
        end;
    end;
end;

procedure TfrmFiler.SearchManyVolumes1Click(Sender: TObject);
begin { SearchManyVolumes1Click }
  SearchManyVolumes(smUnknown);
end;  { SearchManyVolumes1Click }

procedure TfrmFiler.NewVolume1Click(Sender: TObject);
var
  aVolume: TVolume;
  NrBlocksStr, aFileName: string;
  NrBlocks: integer;
  UnitNumber: integer;
  mr: TMountResult;
begin
  with SaveDialog3 do
    begin
      DefaultExt := CVOL;
      InitialDir := fFilePath;
      if Execute then
        begin
          aFileName := ForceExtension(FileName, VOL_EXT);
          if GetString('Create Volume', 'Number of blocks', NrBlocksStr, 5) then
            begin
              try
                NrBlocks := StrToInt(NrBlocksStr);
                aVolume := TVolume.Create(self, aFileName);
                aVolume.OnSVOLFree   := VolumeBeingFreed;
                try
                  aVolume.CreateVolume(aFileName, NrBlocks);
                  mr := MountVolume(aFileName, UnitNumber);
                  if mr = mrMounted then
                    begin
                      with fVolumesList[UnitNumber] do
                        WriteLn(Format('Volume %s: mounted onto Unit# %d. %d files',
                                        [VolumeName, UnitNumber, TheVolume.NumFiles]));
                      DisplayDirectory(fCurrentUnit, '', true);
                      fFilePath := ExtractFilePath(FileName);
                    end;
                finally
                  aVolume.Free;
                end;
              except
                AlertFmt('Invalid number of blocks: %s', [NrBlocksStr]);
              end;
            end;
        end;
    end;
  ShowMountStatus;
end;

procedure TfrmFiler.ResizeVolume1Click(Sender: TObject);
var
  NrBlocksStr, Msg: string;
  NewNrBlocks: integer;
begin
  if Assigned(CurrentVolume) then
    begin
      Msg := Format('Resize Volume [currently %d blocks]', [CurrentVolume.DeovBlk]);
      if GetString(Msg, 'New Number of Blocks', NrBlocksStr, 5) then
        begin
          try
            NewNrBlocks := StrToInt(NrBlocksStr);
            CurrentVolume.ResizeVolume(NewNrBlocks);
            DisplayDirectory(fCurrentUnit, '', true);
          except
            on e:Exception do
              AlertFmt('Unable to resize %s [%s]', [CurrentVolume.VolumeName, e.message]);
          end;
        end;
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.Dumpopcodesfile1Click(Sender: TObject);
const
  TAB = #9;
type
  TOpName = packed array[0..7] of char;
  TOpcodeRec = record
                 Name: TOpName; // packed array[0..7] of char;
                 Unknown: packed array[0..1] of word;
               end;
var
  InFile: File of TOpcodeRec;
  OutFile: TextFile;
  anOpcode: TOpCodeRec;
  InPath, OutPath: string;
  NoName: TOpName;
  j, Cnt: integer;

  function Printable(aName: TOpName): boolean;
  var
    i: integer;
  begin
    result := true;   // assume OK
    for i := 0 to 7 do
      if aName[i] < #20 then
        begin
          result := false;
          exit;
        end;
  end;

begin
  FillChar(NoName[0], 8, #0);
  Cnt := 0;
  InPath := '8086.OpCodes';
  if BrowseForFile('Dump Opcodes File', InPath, 'opcodes') then
    begin
      AssignFile(InFile, InPath);
      Reset(InFile);
      OutPath := 'C:\D7\Projects\pSystem\Temp\8086OpCodes.CSV';
      if BrowseForFile('Output File', OutPath, CSV_EXT) then
        begin
          try
            AssignFile(OutFile, OutPath);
            ReWrite(OutFile);
            try
              while not Eof(InFile) do
                begin
                  Read(InFile, anOpcode);
                  if (anOpcode.Name <> NoName) and Printable(anOpcode.Name) then
                    begin
                      system.Write(OutFile, anOpCode.Name);
                      system.Write(OutFile, TAB);
                      for j := 0 to 1 do
                        begin
                          system.Write(OutFile, anOpCode.Unknown[j], TAB);
                          system.Write(OutFile, '"', HexWord(anOpCode.Unknown[j]), '"', TAB);
                        end;
                      system.WriteLn(OutFile);
                      inc(Cnt);
                    end;
                end;
              MessageFmt('%d opcodes written to output file', [Cnt]);
            finally
              CloseFile(OutFile);
            end;
          finally
            CloseFile(InFile);
          end;
        end;
    end;

end;

procedure TfrmFiler.SetCurrentUnit1Click(Sender: TObject);
var
  aResult: string;
  UnitNumber: integer;
  done: boolean;
  TheVolume: TVolume;

  procedure DisplayIt;
  begin
    fCurrentUnit := UnitNumber;
    TheVolume    := fVolumesList[UnitNumber].TheVolume;
    TheVolume.LoadVolumeInfo(DIRECTORY_BLOCKNR); // re-load the info
    ShowMountedVolumes;
    DisplayDirectory(fCurrentUnit, '', true);
    ShowMountStatus;
    inc(fVolumesList[UnitNumber].RefCount);
  end;

begin
  done := false;
  repeat
    if GetString('Select Unit', 'Unit# or VolumeName', aResult, 10, ecUpperCase) then
      if (aResult <> '') {and (IsAllNumeric(aResult))} then
        begin
          if aResult[Length(aResult)] = ':' then
            Delete(aResult, Length(aResult), 1);
          if aResult[1] = '#' then
            Delete(aResult, 1, 1);
          if IsAllNumeric(aResult) then
            begin
              UnitNumber := StrToInt(aResult);
              if (UnitNumber in FILER_LEGAL_UNITS) and
                  Assigned(fVolumesList[UnitNumber].TheVolume) then
                begin
                  DisplayIt;
                  Done := true;
                end
              else
                AlertFmt('%d is not a legal unit number', [UnitNumber]);
            end
          else
            begin
              UnitNumber := UnitNumberFromVolumeName(aResult);
              if UnitNumber in FILER_LEGAL_UNITS then
                begin
                  DisplayIt;
                  Done := true;
                end
              else
                AlertFmt('Unknown VolumeName/Unit # [%s]', [aResult]);
            end
        end
      else
        begin
          if Assigned(fVolumesList[fCurrentUnit].TheVolume) then
            begin
              UnitNumber := fCurrentUnit;
              DisplayIt;
              Done := true;
            end;
        end
    else
      done := true;
  until done;
end;

procedure TfrmFiler.DisplayBlock(Volume: TVolume; BlockNr: word; Buffer: pchar);
var
  CrunchBuf: TBlockBuffer;
  i, j: integer;

  function GetFileName(BlockNr: word): string;
  var
    i: integer;
  begin
    with Volume do
      for i := 1 to NumFiles do
        with Directory[i] do
          if (BlockNr >= FirstBlk) and
             (BlockNr < LASTBLK) then
            begin
              result := Format('%s @ %d', [FileNAME, Blocknr-FirstBlk]);
              exit;
            end;
    result := '(UNUSED SPACE)';
  end;

begin { TfrmFiler.DisplayBlock }
  j := 0;
  for i := 0 to BLOCKSIZE - 1 do
    if ((Buffer[i] >= ' ') and (Buffer[i] <= #127))
      {or (Buffer[i] in [#13,#10])} then
      begin
        CrunchBuf[j] := Buffer[i];
        j := j + 1;
      end;
  WriteLn(Format('Block #%4d (%s)', [BlockNr, GetFileName(BlockNr)]));
  Write(CrunchBuf, j); WriteLn; WriteLn;
end;  { TfrmFiler.DisplayBlock }


procedure TfrmFiler.ScanRawVolume1Click(Sender: TObject);
const
  MAXBLOCKS = 1;
  BUFSIZE   = MAXBLOCKS * BLOCKSIZE;
var
  aResult: string;
  BlockNr: integer;
  Bufp, p: pchar;
  Buffer: array[0..MAXBLOCKS-1] of TBlock;
  VolumeSize: longint;
  NrBlocks  : integer;
  NrFound: integer;
  VolumeString: string;
  VolumeNumber: integer;
  TheVolume: TVolume;
begin
  if GetString('Select volume number', 'Volume Number', VolumeString, 2) then
    begin
      if IsPureNumeric(VolumeString) then
        begin
          VolumeNumber := StrToInt(VolumeString);
          if VolumeNumber in FILER_LEGAL_UNITS THEN
            begin
              TheVolume := fVolumesList[VolumeNumber].TheVolume;
              if Assigned(TheVolume) then
                begin
                  if GetString('Scan Raw Volume', 'Search for', aResult) then
                    begin
                      VolumeSize := FileSize32(TheVolume.DOSFileName);
                      NrBlocks   := (VolumeSize + BLOCKSIZE - 1) DIV BLOCKSIZE; // Calculate number of blocks
                      BlockNr    := 0;
                      NrFound    := 0;
                      repeat
                        TheVolume.SeekInVolumeFile(BlockNr); // start at the begining
                        TheVolume.BlockRead(Buffer, MAXBLOCKS);
                        Bufp := @Buffer;
                        repeat
                          p := MyStrPos(Bufp, pchar(aResult), BufSize, true);
                          if p <> nil then
                            begin
                              DisplayBlock(TheVolume, BlockNr, Bufp);
                              Bufp    := p + Length(aResult);  // skip over the found string and continue searching
                              Inc(NrFound);
                            end;
                        until p = nil;
                        BlockNr := BlockNr + MAXBLOCKS;
                      until BlockNr >= NrBlocks;
                      WriteLn(Format('%d occurrences found if volume "%s"', [NrFound, TheVolume.DOSFileName]));
                    end;
                end
              else
                NoCurrentVolume;
            end;
        end;
    end;
end;

procedure TfrmFiler.EditpSystemTextFile1Click(Sender: TObject);
var
  DOSFileName, pSysFileName: string;
  FileIDString, BaseName, ErrorMessage: string;
  DirIdx: integer;
  OK: boolean;
begin
  if not Assigned(CurrentVolume) then
    NoCurrentVolume
  else
    if GetString('Select pSystem file number/name to view on current volume',
                 'File ID', FileIDString, TIDLENG) then
      begin
        DirIdx      := CurrentVolume.DirIdxFromString(FileIDString);
        if DirIdx > 0 then
          begin
            pSysFileName := CurrentVolume.Directory[DirIdx].FileNAME;
            if CurrentVolume.Directory[DirIdx].xDFKind = kTEXTFILE then
              begin
                BaseName    := ForceExtension(pSysFileName, '.TXT', TRUE);
                DOSFileName := TempPath + BaseName;
              end
            else
              DOSFileName := TempPath + pSysFileName;

            CurrentVolume.CopySingleFile(DirIdx, DOSFileName); // To DOS

            if not ExecAndWait(FilerSettings.EditorFilePath, DOSFileName, true) then
              AlertFmt('Could not edit "%s"', [DOSFileName])
            else
              begin
                Message('Close this window when editing is complete');
                OK := CurrentVolume.CopyDosTxtToPSysText(DOSFileName, PSysFileName, ErrorMessage, true);
//              if not OK then
//                Error(ErrorMessage);
                if OK or YesFmt('Delete the temporary file "%s"?', [DosFileName]) then
                  DeleteFile(DosFileName);
              end;
          end
        else
          AlertFmt('File %s could not be located', [FileIdString]);
      end;
end;

procedure TfrmFiler.RefreshCurrentUnit1Click(Sender: TObject);
var
  TheVolume: TVolume;
  FileName: string;
begin
  TheVolume := fVolumesList[fCurrentUnit].TheVolume;
  if Assigned(TheVolume) then
    begin
      FileName := TheVolume.DOSFileName;
      TheVolume.Free;
      TheVolume := TVolume.Create(self, FileName);
      TheVolume.OnStatusProc      := Log_Status;
      TheVolume.OnSearchFoundProc := LogMatchingLine;
      TheVolume.OnSVOLFree        := VolumeBeingFreed;
      TheVolume.LoadVolumeInfo(DIRECTORY_BLOCKNR);
      fVolumesList[fCurrentUnit].TheVolume := TheVolume;
      inc(fVolumesList[fCurrentUnit].RefCount);
      DisplayDirectory(fCurrentUnit, '', true);
      with fVolumesList[fCurrentUnit] do
        WriteLn(Format('Volume %s: RE-mounted onto Unit# %d. %d files',
                        [TheVolume.VolumeName, UnitNumber, TheVolume.NumFiles]));
    end;

end;

procedure TfrmFiler.UnitRead1Click(Sender: TObject);
var
  TheVolume: TVolume;
  miscinfo: TmiscInfo;
  buffer: packed array[0..BLOCKSIZE-1] of char;
begin
  TheVolume := fVolumesList[fCurrentUnit].TheVolume;
  FillChar(MiscInfo, SizeOf(TMiscInfo), 0);
  FillChar(Buffer,   SizeOf(Buffer), 0);
  TheVolume.UnitRead(Miscinfo, SizeOf(TMiscInfo), 129, 0);
end;

procedure TfrmFiler.CopyBlockRangeToFile(FileKind: integer);
var
  DirIdx: integer;
  NumberOfBlocks: integer;
  StartingBlock: integer;
  DOSFileName: string;
  Found1: boolean;
begin
  if not Assigned(frmBlockParams) then
    frmBlockParams := TfrmBlockParams.Create(self);
  with frmBlockParams do
    begin
      DOSFolderName := CurrentVolume.DOSFolderName;
      if ShowModal = mrOk then
        begin
          try
            NumberOfBlocks := StrToInt(leNumberOfBlocks.text);
            StartingBlock  := StrToInt(leStartingBlock.text);
            DOSFileName    := leDOSFilePathName.Text;
            with CurrentVolume do
              begin
                DirIdx := FindEmptySpace(NumberOfBlocks+2);
                Found1 := DirIdx >= 0;
                if Found1 then
                  begin
                    with Directory[DirIdx] do
                      begin
                        FirstBlk     := StartingBlock;
                        LASTBLK      := StartingBlock + NumberOfBlocks;
                        xDFKIND      := FixDFKind(FileKind); //;
                        FileName     := UpperCase(ExtractFileBase(ExtractFileName(DOSFileName))) + '.TEXT';
                        LastByte     := BLOCKSIZE;
                        DateAccessed := Now;
                      end;
                    CopySingleFile(DirIdx, DOSFileName);
                  end;
              end;
          except
            on e:Exception do
              Alert(e.message);
          end;
        end;
    end;
end;


procedure TfrmFiler.miTextFile1Click(Sender: TObject);
begin
  CopyBlockRangeToFile(kTEXTFILE);
end;

procedure TfrmFiler.miTextFile2Click(Sender: TObject);
begin
  CopyBlockRangeToFile(kDATAFILE);
end;

procedure TfrmFiler.MountSubsidiaryVolume(TheParentUnitNumber: integer);
var
  FileIDString: string;
  SVOLUnitNr: integer;
  ParentVolume: TVolume;
  DirIdx: integer;
begin
  if (TheParentUnitNumber >= 0) and (TheParentUnitNumber <= MAX_FILER_UNITNR) then
    begin
      if GetString('Select pSystem file name (or number) to mount onto current volume',
                   'File ID', FileIDString, TIDLENG, ecUpperCase) then
        begin
          ParentVolume := fVolumesList[TheParentUnitNumber].TheVolume;
          DirIdx       := ParentVolume.DirIdxFromString(FileIDString);
          if (DirIdx > 0) and (DirIdx <= MAXDIR) then
            begin
              ParentVolume.MountSVOL(DirIdx);
              SVOLUnitNr   := FindFreeUnitNumber;
              with fVolumesList[SVOLUnitNr] do
                begin
                  TheVolume              := ParentVolume.CurrentSVOL;
                  TheVolume.OnSVOLFree   := VolumeBeingFreed;
                  VolumeName             := TheVolume.VolumeName;
                  ParentUnitNumber       := TheParentUnitNumber;
                  UnitNumber             := SVOLUnitNr;
                  RefCount               := 0;
                end;
              fCurrentUnit := SVOLUnitNr;
              ShowMountedVolumes;
              DisplayDirectory(fCurrentUnit, '', true);
            end
          else
            AlertFmt('%s could not be found', [FileIdString]);
        end;
    end;
end;


procedure TfrmFiler.MountSubsidiaryVolume1ClickMountSubsidiaryVolume1Click(Sender: TObject);
var
  TheParentUnitNumber: integer;
begin
  TheParentUnitNumber := MountOuterVolume('Volume containing the .svol file');
  MountSubsidiaryVolume(TheParentUnitNumber);
end;

procedure TfrmFiler.Find1Click(Sender: TObject);
var
  SearchFor: string;
  NrLines, LineNr, NrFound: integer;
begin
  if GetString('String to search for', 'String', SearchFor, 0) then
    begin
      SearchFor := UpperCase(SearchFor);
      NrLines   := Memo1.Lines.Count;
      LineNr    := 1; NrFound := 0;
      WriteLn;
      WriteLn('Searching for ' + SearchFor);
      repeat
        if Pos(SearchFor, UpperCase(Memo1.Lines[LineNr])) > 0 then
          begin
            WriteLn(Format('%3d. %s', [LineNr, UpperCase(Memo1.Lines[LineNr])]));
            inc(NrFound);
          end;
        LineNr := LineNr + 1;
      until LineNr > NrLines;
      WriteLn(Format('%d occurrences of "%s" were found in %d lines', [NrFound, SearchFor, NrLines]));
      Writeln;
    end;
end;

procedure TfrmFiler.ClearWindow1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TfrmFiler.SaveListOfMountedVolumes(const FileName: string);
var
  i: integer;
  CSVFile: TextFile;
  Line: string;
begin { SaveListOfMountedVolumes }
  if FileName <> '' then
    begin
      AssignFile(CSVFile, FileName);
      try
        ReWrite(CSVFile);
        System.Writeln(CSVFile, 'UnitNumber,VolumeName,DOSPathName,ParentUnitNumber,VolStartBlockInParent,NonStandardFormat');
        try
          for i := 0 to MAX_FILER_UNITNR do
            with fVolumesList[i] do
              if (i in FILER_LEGAL_UNITS) and Assigned(TheVolume) and (ParentUnitNumber = 0) then
                with fVolumesList[i] do
                  begin
                    Line := Format('%d,"%s","%s",%d,%d',
                                   [UnitNumber, TheVolume.VolumeName,
                                    TheVolume.DOSFileName, ParentUnitNumber,
                                    TheVolume.VolStartBlockInParent]);
                    if TheVolume is TNonStandardVolume then
                      with (TheVolume as TNonStandardVolume).DiskFormatUtil.DiskFormat do
                        Line := Line + ',' + Desc;
                    System.Writeln( CSVFile, Line);
                  end;
        finally
          CloseFile(CSVFile);
//        Log_Status(Format('%d lines written to file "%s"', [NrLines, FileName])); // would never be seen
        end;
      except
        SysUtils.Beep;
      end;
    end;
end;  { SaveListOfMountedVolumes }


procedure TfrmFiler.SaveListofMountedVolumes1Click(Sender: TObject);
begin
  with SaveDialog2 do
    if Execute then
      SaveListOfMountedVolumes(FileName);
end;

procedure TfrmFiler.MountListOfVolumes(const FileName: string);
var
  aUnitNumber, TheParentUnitNumber, NrLines: integer;
  Count: system.integer;
  CSVFile: TextFile;
  Line, VolumeFileName, DiskFormatDesc: string;
  Fields: TFieldArray;
  aVolStartBlockInParent: integer;
  CSVInfo: TDelimited_Info;
begin
  WriteLn;
  VolumeFileName := Format('Mounting volumes from %s', [FileName]);
  WriteLn(VolumeFileName);
  CSVInfo.Field_Seperator := ',';
  CSVInfo.QuoteChar       := '"';
  AssignFile(CSVFile, FileName);
  Reset(CSVFile);
  try
    NrLines := 0;
    if not eof(CSVFile) then
      begin
        while not eof(CSVFile) do
          begin
            ReadLn(CSVFile, Line);
            if NrLines = 0 then // first line
              begin
                Parse_Delimited_Line( Line, Fields, count, CSVInfo);  // ignore the header line
                if Fields[FN_UNITNUMBER] = 'UnitNumber' then
                  ReadLn(CSVFile, Line);  // skip the 1st line
              end;

            Parse_Delimited_Line( Line, Fields, count, CSVInfo);

            aUnitNumber         := StrToInt(Fields[FN_UNITNUMBER]);
            TheParentUnitNumber := StrToIntSafe(Fields[FN_PARENTUNITNUMBER]);
            VolumeFileName      := Fields[FN_DOSFILEPATH];
            aVolStartBlockInParent := StrToIntSafe(Fields[FN_VOLSTARTBLOCKINPARENT]);
            with fVolumesList[aUnitNumber] do
              begin
                if not Assigned(TheVolume) then
                  begin
                    try
                      VolumeName     := Fields[FN_VOLUMENAME];
                      DiskFormatDesc := Fields[FN_NONSTANDARDVOLUME];
                      if DiskFormatDesc = '' then  { standard .VOL volume }
                        TheVolume  := TVolume.Create(self, VolumeFileName, VersionNr, aVolStartBlockInParent)
                      else
                        TheVolume := CreateVolume(self, VolumeFileName, VersionNr, aVolStartBlockInParent);

                      UnitNumber                  := aUnitNumber;
                      ParentUnitNumber            := TheParentUnitNumber;
                      TheVolume.OnStatusProc      := Log_Status;
                      TheVolume.OnSearchFoundProc := LogMatchingLine;
                      TheVolume.OnSVOLFree        := VolumeBeingFreed;
                      TheVolume.LoadVolumeInfo(DIRECTORY_BLOCKNR);
                    except
                      on e:exception do
                        begin
                          FreeAndNil(TheVolume);
                          AlertFmt('Volume "%s" could not be mounted (%s)', [Fields[FN_VOLUMENAME], e.Message]);
                        end;
                    end;
                  end
                else
                  raise EAlreadyExists.CreateFmt('Unit # %d is already assigned to Volume %s',
                                                 [aUnitNumber, VolumeName]);
              end;
            Inc(NrLines);
          end;

        ShowMountedVolumes;
      end;
  finally
    CloseFile(CSVFile);
  end;
end;

procedure TfrmFiler.UnMountAllVolumes();
var
  aUnitNumber: integer;
begin
  for aUnitNumber := 0 to MAX_FILER_UNITNR do
    with fVolumesList[aUnitNumber] do
      if (aUnitNumber in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        with fVolumesList[aUnitNumber] do
          begin
            UnmountVolume(aUnitNumber);
            // do I need to reset fVolumesList[i] ?
          end;
end;

procedure TfrmFiler.MountVolumesfromSavedList1Click(Sender: TObject);
begin
  with OpenDialog2 do
    begin
      if Execute then
        begin
          if Yes('Unmount currently mounted volumes?') then
            UnMountAllVolumes;
            
          try
            MountListOfVolumes(FileName);
          except
            on e:Exception do
              AlertFmt('Not all volumes could be mounted [%s]', [e.message]);
          end;
        end;
    end;
end;

procedure TfrmFiler.FindStringinWindow1Click(Sender: TObject);
begin
  with FindDialog1 do
    begin
      FindText := fLastFindText;
      Execute;
    end;
end;

procedure TfrmFiler.FindAgain1Click(Sender: TObject);
begin
  FindDialog1Find(nil);
end;

procedure TfrmFiler.Edit1Click(Sender: TObject);
begin
  FindAgain1.Enabled := not Empty(fLastFindText);
end;

procedure TfrmFiler.FindDialog1Find(Sender: TObject);
var
  p, buf: pchar;
begin
  fLastFindText := UpperCase(FindDialog1.FindText);
  Buf           := pchar(Memo1.Text);

  fFindStart    := Buf + Memo1.SelStart + Memo1.SelLength;
  if fFindStart >= (Buf+Length(Memo1.Text)) then
    fFindStart := pchar(Memo1.text);

  p   := MyStrPos(fFindStart, pchar(fLastFindText), Length(Memo1.Text), true);
  if Assigned(p) then
    begin
      Memo1.SelStart  := p - Buf;
      Memo1.SelLength := Length(fLastFindText);
//    Memo1.SetFocus;
    end
  else
    lblStatus.Caption := Format('String "%s" could not be found', [fLastFindText]);
end;

procedure TfrmFiler.VolumeConversionClick(Sender: TObject);
var
  VolumeConverter: TfrmVolConverter;
begin
  VolumeConverter := TfrmVolConverter.Create(self);
  try
    with VolumeConverter do
      begin
        DiskFormat          := dfRaw;
        ConversionDirection := cdVolToOther;
        InputFileName       := FilerSettings.VolumesFolder + '15SYS1.VOL';
        OutputFileName      := FilerSettings.VolumesFolder + '15SYS1.RAW';

        if ShowModal = mrOk then
          Log_Status(Format('%s --> %s', [InputFileName, OutputFileName]), true, true)
        else
          Message('Conversion failed');
      end;
  finally
    FreeAndNil(VolumeConverter);
  end;
end;

(*
procedure TfrmFiler.FindTextBlocksinFile1Click(Sender: TObject);
var
  SrcFilePath, DstFilePath: string;
  NrFound: integer;
  VolumeConverter: TfrmVolumeConverter;
begin
  SrcFilePath := '\\hplaptop\HPLaptop-C\HeathKit\UCSDPascal\Startup_Bootable.h8d';
  if BrowseForFile('Source File', SrcFilePath, '*') then
    begin
      DstFilePath     := ForceExtension(SrcFilePath, EXTENSION_TXT);
      VolumeConverter := TfrmVolumeConverter.Create(self);
      try
        NrFound := VolumeConverter.FindTextBlocksInFile(SrcFilePath, DstFilePath);
        if NrFound > 0 then
          begin
            WriteLn(Format('%d sectors containing ASCII data were found', [NrFound]));
            WriteLn(Format(' in the file %s', [SrcFilePath]));
            ExecAndWait(FilerSettings.EditorFilePath, DstFilePath, true);
          end
        else
          Alert('No text blocks were found');
      finally
        FreeAndNil(VolumeConverter);
      end;
    end;
end;
*)

procedure TfrmFiler.SaveCrtSettings(Sender: TObject);
begin
  if Sender is TfrmPSysWindow then
    with Sender as TfrmPSysWindow do
      FilerSettings.TermType := CrtInfo.TermType;
end;


procedure TfrmFiler.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) then
    begin
{$IfDef Debugging}
      if aComponent = frmPCodeDebugger then
        begin
          frmPCodeDebugger := nil;
          FreeAndNil(fInterpreter);
          SaveCrtSettings(self);
          FreeAndNil(fThePSysWindow);
          EnableMenus(true, nil);
        end else
{$endIf}
      if aComponent = fThePSysWindow then
        begin
          fThePsysWindow := nil;
          EnableMenus(true, nil);
        end;
    end;
end;

{$UnDef UseSeek}

procedure TfrmFiler.ScanRawFile1Click(Sender: TObject);
var
  Buffer: TBlock;
  BlockNr: LONGINT;
{$IfNDef USESEEK}
  BlkNr: LONGINT;
{$EndIf}  
  Offset, NrFound: integer;
  InFile: File of TBlock;
  Done: boolean;
  BlocksRead: longint;
  sr: TSearchResult;

  function ScanRawFile(InFileName: string; const SearchFor: string; StartingBlockNr: longint): TSearchResult;
  var
    FileSizeInBlocks: longint;

    function RawStringSearch(SearchFor: string; var StartingBlockNr: LONGINT; var Offset: integer): TSearchResult;
    var
      p: pchar;
    begin
      while BlockNr < FileSizeInBlocks do
        begin
          if (BlockNr mod REPORT_INTERVAL) = 0 then
            UpdateStatus(Format('Processed block # %0.n/%0.n (%6.2n%%)',
                                [ BlockNr*1.0,
                                  FileSizeInBlocks*1.0,
                                  BlockNr/FileSizeInBlocks*100.0]));
          BlockRead(InFile, Buffer, BLOCKSPERREAD, BlocksRead);
          if BlocksRead < BLOCKSPERREAD then
            Break;
          p := MyStrPos(Buffer.a, pchar(SearchFor), BLOCKSIZE, true);
          if p <> nil then
            begin
              Offset := p - @Buffer;
              result := sr_Found;
              Exit;
            end;
          BlockNr := BlockNr + 1;
        end;
      result := sr_EOF;  // EOF
    end;

    function CharStringFromBuffer(Offset: integer): string;
    const
      MAXLEN = 80;
    var
      i, Len: integer;
      ch: char;
      Temp: string[MAXLEN];
    begin
      SetLength(Temp, MAXLEN);
      Len := 0;
      for i := Offset to Min(Offset+MAXLEN-1, BLOCKSIZE-1) do
        begin
          if Buffer.a[i] in IDENT_CHARS then
            ch := Buffer.a[i]
          else
            ch := '.';

          if Len < MAXLEN then
            begin
              Len := Len + 1;
              Temp[Len] := ch;
            end
          else
            break;
        end;
      SetLength(Temp, Len);
      result := Temp;
    end;

  begin { ScanRawFile }
    FileSizeInBlocks := FileSize64(InFileName) div BLOCKSIZE;
    WriteLn('Searching for: '); WriteLn(SearchFor);
    AssignFile(InFile, InFileName);
    Reset(InFile);
    BlockNr := StartingBlockNr;  NrFound := 0;
    try
      done := false;
      if BlockNr <> 0 then
        begin
{$IfDef USESEEK}
          Seek(InFile, BlockNr);  // does not work ?
{$Else}
          BlkNr := 0;
          while BlkNr < BlockNr do
            begin
              BlockRead(InFile, Buffer, BLOCKSPERREAD, BlocksRead);
              if (BlkNr mod REPORT_INTERVAL) = 0 then
                UpdateStatus(Format('Skipping block # %0.n', [BlkNr*1.0]));
              Inc(BlkNr);
            end;
{$EndIf}
        end;

      repeat
        result := RawStringSearch(SearchFor, BlockNr, Offset);
        if result = sr_Found then
          begin
            Inc(NrFound);
            WriteLn(Format('%4d: Block #%8d, Offset %3d: %s',
                           [NrFound, BlockNr, Offset, CharStringFromBuffer(Offset)]));
          end else
        if result = sr_EOF then
          done := true
      until done;
      UpdateStatus('Scan is complete');
    finally
      CloseFile(InFile);
    end;
  end;  { ScanRawFile }

begin { TfrmFiler.ScanRawFile1Click }
  if not Assigned(frmRawParameters) then
    frmRawParameters := TfrmRawParameters.Create(self);

  with frmRawParameters do
    begin
      leRawOutputFileName.Visible := false;
      StartingBlockNr := 27837337;
      InFileName      := '\\SurfacePro\Virtual Machines\Windows XP\Windows XP Hard Disk (15x).vhd';
      SearchFor       := 'TESTING';

      if ShowModal = mrOk then
        begin
          NrFound := 0;
          sr := ScanRawFile(InFileName, SearchFor, StartingBlockNr);
          if sr = sr_Found then
            MessageFmt('The string "%s" was found %d times in file "%s"', [NrFound, InFileName])
        end;
    end;
end; { TfrmFiler.ScanRawFile1Click }


function TfrmFiler.ExtractFileFromRawFile(InFileName, OutFileName: string;
                                           StartingBlock, NrBlocks: longint): boolean;
const
//BLOCKSIZE = 512;
  BLOCKSPERREAD = 1;
  REPORT_INTERVAL = 100000;
type
  TBlock = packed Array[0..BLOCKSIZE-1] of char;
  TSearchResult = (sr_Unknown, sr_EOF, sr_Found, sr_NotInBuffer);
var
  Buffer: TBlock;
{$IfNDef USESEEK}
  BlkNr: LONGINT;
{$EndIf}
  BlocksWritten: longint;
  InFile, OutFile: File of TBlock;
begin
  try
    AssignFile(InFile, InFileName);
    Reset(InFile);
    AssignFile(OutFile, OutFileName);
    Rewrite(OutFile);
    Writeln(Format('Skipping %0.n blocks in file "%s"', [StartingBlock*1.0, InFileName]));
    try
    // Skip to the starting block
      BlkNr := 0;
      while BlkNr < StartingBlock do
        begin
          BlockRead(InFile, Buffer, BLOCKSPERREAD, BlocksWritten);
          if (BlkNr mod REPORT_INTERVAL) = 0 then
            UpdateStatus(Format('Skipping block # %0.n', [BlkNr*1.0]));
          Inc(BlkNr);
        end;

      // Extract the specified region to the output file
      Writeln(Format('Copying %0.n blocks from file "%s" to "%s"', [NrBlocks*1.0, InFileName, OutFileName]));
      BlkNr := 0;
      repeat
        BlockWrite(OutFile, Buffer, BLOCKSPERREAD, BlocksWritten);
        BlockRead(InFile, Buffer, BLOCKSPERREAD, BlocksWritten);
        Inc(BlkNr);
      until BlkNr > NrBlocks;
      Writeln(Format('Copied %0.n blocks from file "%s" to "%s"', [NrBlocks*1.0, InFileName, OutFileName]));
      result := true
    finally
      CloseFile(OutFile);
      CloseFile(InFile);
    end;
  except
    on e:Exception do
      begin
        ErrorFmt('Extraction failed: %s', [e.message]);
        result := false;
      end;
  end;
end;


procedure TfrmFiler.ExtractRawFile1Click(Sender: TObject);
var
  OK: boolean;
begin
  if not Assigned(frmRawParameters) then
    frmRawParameters := TfrmRawParameters.Create(self);

  with frmRawParameters do
    begin
      StartingBlockNr := 27837338;
      InFileName  := '\\SurfacePro\Virtual Machines\Windows XP\Windows XP Hard Disk (15x).vhd';
      OutFileName := 'c:\temp\TESTED.VOL';
      NrBlocks    := 10000;
      leStringToSearchFor.Visible := false;
      if ShowModal = mrOk then
        begin
          Ok := not FileExists(OutFileName);
          if not Ok then
            Ok := YesFmt('File%s already exists. Overwrite it?', [OutFileName]);
          if OK then
            if ExtractFileFromRawFile(InFileName, OutFileName, StartingBlockNr, NrBlocks) then
              MessageFmt('Extracted %d blocks from "%s" to "%s"', [NrBlocks, InFileName, OutFileName])
            else
              Message('Extraction failed');
        end;
    end;
end;

procedure TfrmFiler.MountSubVolonCurrent1Click(Sender: TObject);
begin
  MountSubsidiaryVolume(fCurrentUnit);
end;

procedure TfrmFiler.AlphaSort2Click(Sender: TObject);
begin
  DisplayDirectory(fCurrentUnit, '', true, doStringGrid, dsAlphaSort);
end;

procedure TfrmFiler.DateSort1Click(Sender: TObject);
begin
  DisplayDirectory(fCurrentUnit, '', true, doStringGrid, dsDateSort);
end;

procedure TfrmFiler.FileSize1Click(Sender: TObject);
begin
  DisplayDirectory(fCurrentUnit, '', true, doStringGrid, dsFileSize);
end;

procedure TfrmFiler.Unsorted1Click(Sender: TObject);
begin
  DisplayDirectory(fCurrentUnit, '', true, doStringGrid, dsUnsorted);
end;

procedure TfrmFiler.UnmountAll1Click(Sender: TObject);
var
  VolumeNumber: integer;
  SaveFileName: string;
begin
  SaveFileName := FileNameByDate(fListOfVolumesToMountCSV);
  if FileExists(fListOfVolumesToMountCSV) then
    Sysutils.RenameFile(fListOfVolumesToMountCSV, SaveFileName);

  for VolumeNumber := 0 to MAX_FILER_UNITNR do
    with fVolumesList[VolumeNumber] do
      if (VolumeNumber in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        UnmountVolume(VolumeNumber);

  Log_Status(Format('Previous Volumes to Mount List saved to "%s"', [SaveFileName]), true, true);
end;

procedure TfrmFiler.UnmountVolume1Click(Sender: TObject);
var
  VolumeNumber: integer;
begin
  for VolumeNumber := 0 to MAX_FILER_UNITNR do
    with fVolumesList[VolumeNumber] do
      if (VolumeNumber in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        if YesFmt('Unmount #%d [%s]?', [VolumeNumber, TheVolume.VolumeName]) then
          UnmountVolume(VolumeNumber);
  ShowMountedVolumes;
end;

procedure TfrmFiler.SelectedVolume1Click(Sender: TObject);
var
  VolumeNumber: integer;
  VolNrStr: string;
begin
  if GetString('Select Unit #', 'Unit #', VolNrStr, 10) then
    begin
      if IsPureNumeric(VolNrStr) then
        VolumeNumber := StrToInt(VolNrStr)
      else
        begin
          VolumeNumber := UnitNumberFromVolumeName(VolNrStr);
          if VolumeNumber < 0 then
            begin
              AlertFmt('Illegal unit # or volume name: %s', [VolNrStr]);
              exit;
            end;
        end;

      if (VolumeNumber in FILER_LEGAL_UNITS) and Assigned(fVolumesList[VolumeNumber].TheVolume) then
        if YesFmt('Unmount #%d [%s]?', [VolumeNumber, fVolumesList[VolumeNumber].VolumeName]) then
          UnmountVolume(VolumeNumber);
    end;
  ShowMountedVolumes;
end;

procedure TfrmFiler.miSearchMountedVolumesClick(Sender: TObject);
var
  Msg: string;
  mr, i: integer;
  VolumeNumber: integer;

  procedure ProcessVolume(VolumeNumber: integer);
  var
    Volume: TVolume;
  begin
    with fVolumesList[VolumeNumber] do
      if (VolumeNumber in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        begin
          try
            Volume := TheVolume;
            Volume.OnStatusProc      := Log_Status;
            Volume.OnSearchFoundProc := LogMatchingLine;
            Volume.VolumeName        := ExtractFileBase(VolumeName);  // this may be overwritten in LoadVolumeInfo
            try
              Volume.LoadVolumeInfo(DIRECTORY_BLOCKNR);
              Log_Status('Processing Volume: ' + Volume.VolumeName, false);
              case fSearchInfo.SearchMode of
                smASCII:
                  Volume.ScanVolumeForString(@fSearchInfo);

                smHEX:
                  Volume.ScanVolumeForHexString(@fSearchInfo);

                smVersionNumber:
                  Volume.ScanVolumeForVersionNumber(@fSearchInfo);

                smCrtInfo, smKeyInfo:
                  Volume.ScanVolumeForMiscinfo(@fSearchInfo, fAltOutputFile);
{$IfDef PoolInfo}
                smPoolInfo:
                  Volume.ScanVolumeForPoolInfo(@fSearchInfo, fAltOutputFile);
{$endIf PoolInfo}
{$IfDef SegInfo}
                smSegments:
                  Volume.ScanVolumeForSegmentInfo(@fSearchInfo, fAltOutputFile);
{$endIf SegInfo}
{$IfDef ProcInfo}
                smProcedures:
                  Volume.ScanVolumeForProcedureInfo(@fSearchInfo, fAltOutputFile);
{$endIf ProcInfo}
              end;
            except
              on e:Exception do
                Log_Status(e.Message, fSearchInfo.LogMountingErrors)
            end;
          finally
            Inc(fSearchInfo.VolumesSearched);
          end;
        end;
  end;

begin { TfrmFiler.miSearchMountedVolumesClick }
  if not Assigned(frmSearchForString) then
    frmSearchForString := TfrmSearchForString.Create(self);
  with frmSearchForString do
    begin
      SearchFor         := fSearchInfo.SearchString;
      HexBytes          := fSearchInfo.HexBytes;
      NrHexBytes        := fSearchInfo.NrHexBytes;
      KeyWordSearch     := fSearchInfo.KeyWordSearch;
      CaseSensitive     := fSearchInfo.Case_Sensitive;
      IgnoreUnderScores := fSearchInfo.IgnoreUnderScores;
      OnlySearchFileNames := fSearchInfo.OnlySearchFileNames;
      LogMountingErrors := fSearchInfo.LogMountingErrors;
      AnyKeyWords       := fSearchInfo.AnyKeyWords;
      AllKeyWords       := fSearchInfo.AllKeyWords;
      SearchMode        := smAscii;
      WildMatch         := false;

      mr := ShowModal;
      if mr = mrOk then
        begin
          AddDivider;
          fSearchInfo.SearchMode        := SearchMode;
          fSearchInfo.KeyWordSearch     := KeyWordSearch;
          fSearchInfo.Case_Sensitive    := CaseSensitive;
          fSearchInfo.LogMountingErrors := LogMountingErrors;
          fSearchInfo.IgnoreUnderScores := IgnoreUnderScores;
          fSearchInfo.OnlySearchFileNames := OnlySearchFileNames;
          fSearchInfo.AllKeyWords       := AllKeyWords;
          fSearchInfo.AnyKeyWords       := AnyKeyWords;
          fSearchInfo.WildCardSearch    := WildMatch;
          case SearchMode of
            smASCII:
              begin
                if fSearchInfo.Case_Sensitive then
                  fSearchInfo.SearchString := SearchFor
                else
                  fSearchInfo.SearchString := UpperCase(SearchFor);

                if fSearchInfo.IgnoreUnderScores then
                  begin
                    i    := Length(fSearchInfo.SearchString);
                    while i > 0 do
                      begin
                        if fSearchInfo.SearchString[i] = '_' then
                          Delete(fSearchInfo.SearchString, i, 1);
                        i := i - 1;
                      end;
                  end;

                Log_Status(Format('Searching for ASCII string %s', [SearchFor]));
              end;

            smHex:
              begin
                fSearchInfo.HexBytes     := HexBytes;
                fSearchInfo.NrHexBytes   := NrHexBytes;
                Log_Status(Format('Searching for HEX   string "%s"', [SearchFor]));
              end;

            smVersionNumber:
              fSearchInfo.SearchString := UpperCase(SearchFor);

            smCrtInfo, smKeyInfo
{$IfDef PoolInfo}
               , smPoolInfo
{$endIf PoolInfo}
            :
              begin
                fSearchInfo.SearchString := UpperCase(searchFor);
                fAltFileName := OpenOutputFile(fSearchInfo.SearchMode);
              end;

{$IfDef SegInfo}
            smSegments:
              begin
                fSearchInfo.SearchString := UpperCase(searchFor);
                fAltFileName := OpenOutputFile(fSearchInfo.SearchMode);
              end;
{$endIf SegInfo}
{$IfDef ProcInfo}
            smProcedures:
              begin
                fSearchInfo.SearchString := UpperCase(searchFor);
                fAltFileName := OpenOutputFile(fSearchInfo.SearchMode);
              end;
{$endIf ProcInfo}
          end;


          fSearchInfo.LowDate      := LowDate;
          fSearchInfo.HighDate     := HighDate;
          fSearchInfo.MatchesFound := 0;
          fSearchInfo.DOSTextFilesSearched := 0;
          fSearchInfo.pSystemTextFilesSearched := 0;
          fSearchInfo.FoldersSearched := 0;
          fSearchInfo.VolumesSearched := 0;
          fSearchInfo.NumberOfErrors  := 0;
          fSearchInfo.Abort           := false;
          btnAbort.Caption            := 'Abort';
          btnAbort.Visible            := true;

          for VolumeNumber := 0 to MAX_FILER_UNITNR do
            with fVolumesList[VolumeNumber] do
              if (VolumeNumber in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
                ProcessVolume(VolumeNumber);

          with fSearchInfo do
            Msg := Format('%d matches were found. %d volumes were searched',
                     [MatchesFound, VolumesSearched]);
          Log_Status(Msg);
          CloseOutputFile(fSearchInfo);
          btnAbort.Visible := false;
      end;
    end;
end;  { TfrmFiler.miSearchMountedVolumesClick }

function TfrmFiler.UnitNumberFromVolumeName(
  const aVolumeName: string): integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to MAX_FILER_UNITNR do
    with fVolumesList[i] do
      if (i in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
        if SameText(aVolumeName, TheVolume.VolumeName) then
          begin
            result := i;
            Exit;
          end;
end;

procedure TfrmFiler.ZeroVolume1Click(Sender: TObject);
var
  VolNrStr, VolName: string;
  UnitNumber: integer;
begin
  if GetString('Select Unit #', 'Unit #', VolNrStr, 10) then
    begin
      UnitNumber := StrToInt(VolNrStr);
      if (UnitNumber in FILER_LEGAL_UNITS) and          Assigned(fVolumesList[UnitNumber].TheVolume) then
        with fVolumesList[UnitNumber].TheVolume do
          begin
            if GetString('New Volume Name', 'Vol Name', VolName, VIDLENG, ecUpperCase) then
              begin
                ZeroDirectory(VolName);
                ShowMountedVolumes;
                LoadVolumeInfo(DIRECTORY_BLOCKNR);
                DisplayDirectory(UnitNumber, '', true);
                fCurrentUnit := UnitNumber;
              end;
          end
    end;
end;

function TfrmFiler.GetThePSyswindow: TfrmPSysWindow;
var
  WindowInfo: TWindowInfo;
  dummy: integer;
begin
  if not Assigned(fThePsysWindow) then
    begin
      WindowInfo := FilerSettings.WindowsList.FindNamedWindow(cPSYSTEM_WINDOW_NAME);
      if Assigned(WindowInfo) then
        begin
          fThePSysWindow  := TfrmPSysWindow.Create(self, cPSYSTEM_WINDOW_NAME, WindowInfo.Top, WindowInfo.Left, fVersionNr);
          FilerSettings.WindowsList.LoadWindowInfo(fThePSysWindow, cPSYSTEM_WINDOW_NAME, dummy);
        end
      else
        if Screen.MonitorCount > 1 then
          fThePSysWindow  := TfrmPSysWindow.Create(nil, cPSYSTEM_WINDOW_NAME, 150, -3840)
        else
          fThePSysWindow  := TfrmPSysWindow.Create(nil, cPSYSTEM_WINDOW_NAME, 378, 28);

      fThePSysWindow.OnSaveSettings := SaveCrtSettings;
      fThePSysWindow.FreeNotification(self);
    end;
  result := fThePsysWindow;
end;

procedure TfrmFiler.ClosepSystemWindow1Click(Sender: TObject);
begin
  FreeAndNil(fThePSysWindow);
end;

procedure TfrmFiler.FormShow(Sender: TObject);
var
  Dummy: integer;
begin
  with FilerSettings.WindowsList do
    LoadWindowInfo(self, WindowsType[wtFiler], dummy);
end;

procedure TfrmFiler.Log_StatusFmt(const Msg: string; Args: array of const);
begin
  Log_Status(Format(Msg, Args), true, true);
end;

procedure TfrmFiler.Settings1Click(Sender: TObject);
begin
  if not Assigned(frmFilerSettings) then
    frmFilerSettings := TfrmFilerSettings.Create(self);
  if frmFilerSettings.ShowModal = mrOK then
    begin
      try
        with FilerSettings do
          SaveToFile(FilerSettingsFileName);
        Log_Status(Format('Settings saved to "%s"', [FilerSettingsFileName]), false, true);
      except
        on e:Exception do
          Alertfmt('Could not save settings file "%s" [%s]', [FilerSettingsFileName, e.message]);
      end;
    end;
end;

procedure TfrmFiler.btnAbortClick(Sender: TObject);
begin
  fSearchInfo.Abort := true;
  btnAbort.Caption  := 'Aborting';
end;

procedure TfrmFiler.MountNonStandardVolume1Click(Sender: TObject);
var
  UnitNumber: integer;
begin
  UnitNumber := MountOuterVolume('Volume File', true);
  if UnitNumber > 0 then
    with fVolumesList[UnitNumber] do
      WriteLn(Format('Non-standard Volume %s: mounted onto Unit# %d. %d files',
                      [VolumeName, UnitNumber, TheVolume.NumFiles]));
end;

function TfrmFiler.UnpackName(        PathName: string;
                                var   UnitNr: integer;
                                var   VolName: string;
                                var   FileName: string): boolean;
var
  cp, Len: integer;

  function GetUnitNrFromVolName(var VolName: string): integer;
  var
    Temp: string;
    U: integer;
  begin { GetUnitNrFromVolName }
    result := -1;
    if Length(VolName) > 0 then
      if VolName[1] = '#' then
        begin
          Temp := Copy(VolName, 2, MAXINT);
          if IsAllNumeric(temp) then
            begin
              result  := StrToInt(Temp);
              if result in FILER_LEGAL_UNITS then
                VolName := fVolumesList[result].VolumeName;
            end
        end
      else
        begin
          for U := 1 to MAX_FILER_UNITNR-1 do
            with fVolumesList[U] do
              if (U in FILER_LEGAL_UNITS) and Assigned(TheVolume) then
                if SameText(VolName, VolumeName) then
                  begin
                    result := U;
                    break;
                  end;
        end;
  end;  { GetUnitNrFromVolName }

begin { UnpackName }
  cp := Pos(':', PathName);
  if cp > 0 then
    begin
      VolName    := UCSDName(Copy(PathName, 1, cp-1));
      Len        := Length(VolName);
      if Len > 0 then
        if VolName[Len] = ':' then
          Delete(VolName, Len, 1);

      FileName   := Copy(PathName, cp+1, MAXINT);
      UnitNr     := GetUnitNrFromVolName(VolName);
      result     := UNITNR in FILER_LEGAL_UNITS;
    end
  else // cp = 0
    begin
      FileName := PathName;
      cp := Pos('#', PathName);
      if cp > 0 then
        UnitNr     := GetUnitNrFromVolName(PathName);
      if not ((UnitNr in FILER_LEGAL_UNITS) and Assigned(fVolumesList[UnitNr].TheVolume)) then
        UnitNr := fCurrentUnit;  // Use the default unit
      VolName  := ExtractFileBase(fVolumesList[UnitNr].VolumeName);
      result   := true;
    end;
  if not result then
    raise Exception.CreateFmt('Unknown Unit #: %s', [FileName]);
end;  { UnpackName }

procedure TfrmFiler.CopyfrompSystopSys1Click(Sender: TObject);
var
  SourcePathName, DestPathName, SourceFileName, DestFileName, SrcVol, DestVol: string;
  SrcUnit, DestUnit: integer;
  DestVolume: TVolume;  ErrorMessage: string;
begin
  if GetString('Source', 'File Name', SourcePathName, 15, ecUpperCase) then
    if GetString('Dest', 'Volume:File Name', DestPathName, 15, ecUpperCase) then
      begin
        if not UnpackName(SourcePathName, SrcUnit,  SrcVol, SourceFileName) then
          begin
            ErrorFmt('Invalid source Volume:FileName = %s', [SourcePathName]);
            Exit;
          end;
        if (SrcUnit <> fCurrentUnit) {or (SrcVol <> CurrentVolume.VolumeName)} then
          raise Exception.CreateFmt('Source must be on currently selected unit (%d:%s)',
                                   [fCurrentUnit, CurrentVolume.VolumeName]);
//      SrcUnit := fCurrentUnit;  // Source unit must be the current unit

        DestUnit := fCurrentUnit;
        if not UnpackName(DestPathName,   DestUnit, DestVol, DestFileName) then
          begin
            ErrorFmt('Invalid destination Volume:FileName = %s', [DestPathName]);
            Exit;
          end;

        if (DestFileName = '') or (DestFileName = '$') then
          DestFileName := SourceFileName;

        DestVolume := fVolumesList[DestUnit].TheVolume;
        fVolumesList[SrcUnit].TheVolume.CopyToVolume(SourceFileName, DestFileName, DestVolume, ErrorMessage);
        if ErrorMessage = '' then
          UpdateStatus(Format('Copied #%d:%s --> #%d:%s', [SrcUnit, SourceFileName, DestUnit, DestFileName]))
        else
          Error(ErrorMessage);
      end;
end;

function TfrmFiler.GetInteger(const Prompt: string; Default: longint): longint;
var
  DefaultStr: string;
begin
  result     := Default;
  DefaultStr := IntToStr(Default);
  if GetString(Prompt, Prompt, DefaultStr) then
    begin
      if IsPureNumeric(DefaultStr) then
        result := StrToInt(DefaultStr)
      else
        raise Exception.CreateFmt('Invalid number: %s', [DefaultStr]);
    end;
end;

procedure TfrmFiler.ExtractFilefromRawVolume1Click(Sender: TObject);
var
  OutputFilePath: string;
  VolumeNumber, NrRead, IO: integer;
  BlockNr, Volumesize, NrBlocks: longint;
  TheVolume: TVolume;
  OutputFile: file;
  Buffer: packed array[0..BLOCKSIZE] of char;

begin
  VolumeNumber := GetInteger('Volume Number', fCurrentUnit);

  if VolumeNumber in FILER_LEGAL_UNITS THEN
    begin
      TheVolume := fVolumesList[VolumeNumber].TheVolume;
      if Assigned(TheVolume) then
        begin
          VolumeSize := FileSize32(TheVolume.DOSFileName);

          BlockNr    := GetInteger('Starting Input Block Number', 0);

          NrBlocks   := ((VolumeSize + BLOCKSIZE - 1) DIV BLOCKSIZE) - BlockNr; // Calculate number of blocks

          NrBlocks   := GetInteger('Number of blocks to copy', NrBlocks);

          NrRead     := 0;

          OutputFilePath := FilerSettings.VolumesFolder + 'Extracted.dat';
          if BrowseForFile('Output file name', OutputFilePath, 'DAT') then
            begin
              AssignFile(OutputFile, OutputFilePath);
              Rewrite(OutputFile, BLOCKSIZE);
              try
{$I-}
                repeat
                  TheVolume.SeekInVolumeFile(BlockNr); // start at the begining
                  TheVolume.BlockRead(Buffer, 1);
                  IO := IOResult;
                  if IO = 0 then
                    begin
                      BlockWrite(OutputFile, Buffer, 1);

                      BlockNr := BlockNr + 1;
                      Inc(NrRead);
                    end;

                until (IO <> 0) or (NrRead >= NrBlocks);
                WriteLn(Format('%d blocks written from volume %s to file %s', [NrRead, TheVolume.DOSFileName, OutputFilePath]));
              finally
                CloseFile(OutputFile);
              end;
            end;
        end
      else
        NoCurrentVolume;
    end;
end;

procedure TfrmFiler.CleanVolumeforPrevers41Click(Sender: TObject);
var
  VolumeNumber: integer;
  TheVolume : TVolume;
begin
  VolumeNumber := GetInteger('Volume Number', fCurrentUnit);

  if VolumeNumber in FILER_LEGAL_UNITS THEN
    begin
      TheVolume := fVolumesList[VolumeNumber].TheVolume;
      if Assigned(TheVolume) then
        with TheVolume do
          begin
            if CleanUpDirectory then
              begin
                DisplayDirectory(VolumeNumber, '', true);
                MessageFmt('Volume %s directory cleaned for pre Version IV', [VolumeName]);
              end;
          end;
    end;
end;

procedure TfrmFiler.GuessVolumeFormat1Click(Sender: TObject);
begin
  if not Assigned(frmGuessOptions) then
    frmGuessOptions := TfrmGuessOptions.Create(self, Log_Status);
  frmGuessOptions.ShowModal;
end;

function TfrmFiler.FILER_LEGAL_UNITS: TUnitsRange;
begin
  case VersionNr of
    vn_VersionI_4,
    vn_VersionI_5,
    vn_VersionII:
      result := TIIPsystemInterpreter.GetLEGAL_UNITS;

    vn_VersionIV{, vn_VersionIV_12}:
      result := TIVPsystemInterpreter.GetLEGAL_UNITS;
    else
      raise EUnknownVersion.Create('Unimplemented version');
  end;
end;

procedure TfrmFiler.ReportSYSTEMMISCINFOcontents1Click(Sender: TObject);
begin
  SearchManyVolumes(smCRTInfo);
end;

procedure TfrmFiler.ReportSYSTEMMISCINFOKEYcontents1Click(Sender: TObject);
begin
  SearchManyVolumes(smKeyInfo);
end;

procedure TfrmFiler.MaintainBootFilesList1Click(Sender: TObject);
var
  mr: integer;
begin
  if not Assigned(frmLoadVersion) then
    begin
      frmLoadVersion := TfrmLoadVersion.Create(self, fVolumesList);
      frmLoadVersion.RecNo := 0;
    end;

  frmLoadVersion.OnNavigateClick := NavigateClick;
  with frmLoadVersion do
    begin
      InitDropDowns;

      if FilerSettings.RecentBootsList.Count > 0 then
        RecentBootParams := FilerSettings.RecentBootsList.Items[RecNo] as TBootParams
      else
        RecentBootParams := nil;

      mr := frmLoadVersion.ShowModal;
      if mr = mrSAVE then
        FilerSettings.SaveToFile(FilerSettingsFileName);
    end;
end;

// This should update the VersionNr menu
procedure TfrmFiler.SetVersionNr(const Value: TVersionNr);
var
  i: integer;
  MenuItem: TMenuItem;
begin
  fVersionNr := Value;
  with RebootLastSystem1 do
    begin
      for i := 0 to Count-1 do
        if TVersionNr(Items[i].Tag) = Value then
          begin
            MenuItem := Items[i];
            MenuITem.Checked := true;
            exit;
          end;
    end;
end;

{$IfDef debugging}
// 12/15/2023- dhd: This is useful whe you cannot even get into the debugger
procedure TfrmFiler.DebuggerSettings1Click(Sender: TObject);
var
  TheDebuggerSettingsFileName: string;
  frmDebuggerSettings: TfrmDebuggerSettings;
  DebuggerSettings: TDEBUGGERSettings;
begin
  DebuggerSettings            := TDEBUGGERSettings.Create(self);
  TheDebuggerSettingsFileName := DebuggerSettingsFileName(VersionNr);
  DebuggerSettings.LoadFromFile(TheDebuggerSettingsFileName);
  frmDebuggerSettings         := TfrmDebuggerSettings.Create(self, DebuggerSettings);
  try
    if frmDebuggerSettings.ShowModal = mrOK then
      begin
        try
          with DebuggerSettings do
            SaveToFile(TheDebuggerSettingsFileName);
          Log_StatusFmt('Settings saved to "%s"', [TheDebuggerSettingsFileName]);
        except
          on e:Exception do
            Alertfmt('Could not save settings file "%s" [%s]', [TheDebuggerSettingsFileName, e.message]);
        end;
      end;
  finally
    FreeAndNil(frmDebuggerSettings);
    FreeAndNil(DebuggerSettings);
  end;
end;
{$else}
procedure TfrmFiler.DebuggerSettings1Click(Sender: TObject);
begin
end;
{$EndIf}

procedure TfrmFiler.SegmentMapSEGMAP1Click(Sender: TObject);
const
  C = ',';
var
  pSysFileName: string;
  pSysVolumeName: string;
  FileIDString: string;
  DirIdx, SegNr: integer;
  sfi: TSegmentFileInfo;
  OutFile: TextFile;
  OutFileName, Msg: string;
  LineCount: integer;
  MachTypesKludge: TMachTypesKludge;
  MachType: string;
  vname: string;
  StatusMsg: string;
  NrSegsFound: integer;
begin
  if not Assigned(CurrentVolume) then
    begin
      Alert('No current volume');
      Exit;
    end;
  if GetString('Select pSystem file number/name to map on current volume',
               'File ID', FileIDString, TIDLENG) then
    begin
      DirIdx      := CurrentVolume.DirIdxFromString(FileIDString);
      if DirIdx > 0 then
        begin
          pSysFileName := CurrentVolume.Directory[DirIdx].FileNAME;
          pSysVolumeName := CurrentVolume.VolumeName;
          OutFileName := UniqueFileName(Format('%sSEGMAP-%s-%s.%s',
                                               [FilerSettings.ReportsPath, pSysVolumeName, pSysFileName, CSV_EXT]));
          if BrowseForFile('Output file', OutFileName, CSV_EXT) then
            begin
              if FileExists(OutFileName) then
                if not YesFmt('File %s exists. Overwrite it?', [OutFileName]) then
                  Exit;
              AssignFile(OutFile, OutFileName);
              Rewrite(OutFile);

              LineCount := 0;
              if (CurrentVolume.IsCodeFile(DirIdx)) then
                begin
                  try
                    with CurrentVolume, Directory[DirIdx] do
                      if LoadSegmentFile(FirstBlk, VolStartBlockInParent, CurrentVolume, sfi,
                                         FileNAME, Log_StatusFmt) then
                        begin
                          SegNr := 0; NrSegsFound := 0;
                          with sfi do
                           begin
                            if SegNr = 0 then
                              system.WriteLn(OutFile, '#', C,
                                                       'SegName', C,
                                                       'Code_Addr', C,
                                                       IIF(VersionSplit = vsSoftech,
                                                           'Code_Leng (words)',
                                                           'Code_Leng (bytes)'), C,   // this is bytes for version 1.4, 1.5, words for version 2.0, 4.0 ?
                                                       'Major_Version', C,
                                                       'MachineType', C,
                                                       'OldSegType', C,
                                                       'Seg_Text', C,
                                                       'Text_Size (words)', C,
                                                       'Flipped', C,
                                                       'NewSegType', C,
                                                       'HasLinkInfo', C,
                                                       'Relocatable', C,
                                                       'Seg_Ref_Words (# segs in comp unit)', C,
                                                       'Data_Size', C,
                                                       'max_seg_num', C,
                                                       'host_name');
//                          for SegNr := 0 to NrSegsInFile do
                            while (NrSegsFound < NrSegsInFile) and (SegNr < 16) do
                              with SegDictInfo[SegNr] do
                                begin
                                  SegName := TrimTrailing(SegName, [#0, ' ']);
                                  if SegName <> '' then
                                    begin
                                      NrSegsFound := NrSegsFound + 1;
                                      if MajorVersion < iv then
                                        begin
                                          MachTypesKludge := ConvertMType(Word(MachineType), true);
                                          MachType := MachTypesK[MachTypesKludge];
                                        end
                                      else
                                        begin
//                                        MachTypesKludge := ConvertMType(Word(MachineType), );
                                          MachType := 'Unknown';
                                        end;

                                      if Major_Version in [ii..iv] then
                                        vname := VersionNames[Major_Version]
                                      else
                                        vname := 'Unknown';

                                      system.WriteLn(OutFile,
                                                       SegNr, C,
                                                       SegName, C,
                                                       Code_Addr, C,
                                                       Code_Leng, C,
                                                       vName, C,
                                                       MachType, C,
                                                       OldSegTypeNames[OldSegType], C,
                                                       Seg_Text, C,
                                                       Text_Size, C,
                                                       TF(Flipped), C,
                                                       SegTypeNames[NewSegType], C,
                                                       TF(HasLinkInfo), C,
                                                       TF(Relocatable), C,
                                                       Seg_Ref_Words, C,
                                                       Data_Size, C,
                                                       max_seg_num, C,
                                                       host_name);
                                      inc(LineCount);
                                    end;
                                  SegNr := SegNr + 1;
                                end;
                           end;
                        end;
//                  system.WriteLn(OutFile);
                    Log_Status('NOTE: Code_Leng is BYTES for V1.4 1.5, 2.0? BUT is WORDS for version 4.0');
                    Log_Status('DOS volume:  ' + CurrentVolume.DOSFileName);
                    Log_Status('UCSD volume: ' + CurrentVolume.VolumeName + ':');
                    Log_Status('UCSD file:   ' + pSysFileName);
                    CloseFile(OutFile);
                    Msg := Format('%d lines written to %s', [LineCount, OutFileName]);
                    Log_Status(Msg, true, true);
                    ExecAndWait(OutFileName, '', false);
                  except
                    on e:Exception do
                      begin
                        with CurrentVolume do
                          StatusMsg := Format('%s %s:%s', [e.Message, VolumeName, pSysFileName]);
                        Log_Status(StatusMsg, true, true);
                        CloseFile(OutFile);
                      end;
                  end;
                end;
            end;
        end;
    end;
end;

procedure TfrmFiler.PrintBootFilesList1Click(Sender: TObject);
const
  IW = 10;
var
  RecNo: integer;
  BootParams: TBootParams;
  FileName: string;
  OutFile: TextFile;
begin
  FileName := FileNameByDate(FilerSettings.ReportsPath + 'BootParams.'+TXT_EXT);
  AssignFile(OutFile, FileName);
  Rewrite(OutFile);
  System.WriteLn(OutFile,
          'UnitNr', ',',
          'VolumeName', ',',
          'Volume FileName', ',',
          'VersionNr', ',',
          'Derivation');
  System.Writeln(OutFile,
          '':IW, 'LastBoot', ',',
          'RefCount', ',',
          'SettingsFile', ',',
          'Comment');
  System.Writeln(OutFile);
  try
    for Recno := 0 to FilerSettings.RecentBootsList.Count-1 do
      begin
        BootParams := FilerSettings.RecentBootsList.Items[RecNo] as TBootParams;
        with BootParams do
          begin
            System.WriteLn(OutFile,
                    UnitNumber, ',',
                    VolumeName, ',',
                    VolumeFileName, ',',
                    VersionNrToAbbrev(VersionNr), ',',
                    IIF(UseCInterp, 'Peter Miller', 'Laurence Boshell'));
            System.Writeln(OutFile,
                    '':IW, DateTimeToStr(LastBootedDateTime), ',',
                    RefCount, ',',
                    SettingsFileToUse,',',
                    Comment);
            System.Writeln(OutFile);

          end;
      end;
  finally
    CloseFile(OutFile);
    ExecAndWait(FileName, '', false);
  end;
end;

procedure TfrmFiler.GuessTermTypeClick(Sender: TObject);
var
  Inbuf: TInbuf;
  InBufPtr: TInBufPtr;
  TheCrtInfo: TCrtInfo;
begin
  if Assigned(CurrentVolume) then
    begin
      if Assigned(fThePSysWindow) then
        with fThePSysWindow do
          begin
            LoadMiscInfo(CurrentVolume, CSYSTEM_MISCINFO, InBuf);
            InBufPtr := @InBuf;
            LoadCrtKeyInfo(InBufPtr, TheCrtInfo, KeyInfo, VersionNr);
            if InBuf.sysII.CRTTYPE = 0 then
              begin
                CrtInfo.TermType := TheCrtInfo.GuessTerminalType;
                if TheCrtInfo.TermType <> tt_Unknown then
                  begin
                    MessageFmt('Best guess is that the terminal expected is a %s',
                       [TermTypes[TheCrtInfo.TermType].Name]);
                    fThePSysWindow.CRTInfoChanged(TheCrtInfo);
                    fThePSysWindow.ClrScreen;
                  end
                else
                  Message('Unable to guess terminal type');
              end;
          end
      else
        Alert('Terminal window is not open')
    end
  else
    NoCurrentVolume;
end;

procedure TfrmFiler.CompareVolumes1Click(Sender: TObject);
begin
  frmCompareVolumes := TfrmCompareVolumes.Create(self, fVolumesList);
  try
    frmCompareVolumes.ShowModal;
  finally
    FreeAndNil(frmCompareVolumes);
  end;
end;

procedure TfrmFiler.ChangeSyscom(SyscomWhat: TSyscomWhat);
var
  DirIdx: integer;
  FileNumberString: string;
begin
  if Assigned(CurrentVolume) then
    begin
      FileNumberString := CSYSTEM_MISCINFO;
      if GetString('Select SYSTEM.MISCINFO file to process', 'File', FileNumberString, 15) then
        with CurrentVolume do
          begin
            DirIdx := DirIdxFromString(FileNumberString);
            if (DirIdx > 0) and (DirIdx <= NumFiles) then
              with Directory[DirIdx] do
                begin
                  frmSyscomSettings := TfrmSyscomSettings.Create(self, SyscomWhat, CurrentVolume, DirIdx);
                  try
                    frmSyscomSettings.ShowModal;
                  finally
                    FreeAndNil(frmSyscomSettings);
                  end;
                end;
          end;
    end
  else
    NoCurrentVolume
end;


procedure TfrmFiler.ConfigureCodePoolInfo1Click(Sender: TObject);
begin
  ChangeSyscom(sw_CodePool);
end;

procedure TfrmFiler.ChangeScreenSize1Click(Sender: TObject);
begin
  ChangeSyscom(sw_CrtSize);
end;

procedure TfrmFiler.SetLastError(const Msg: string);
begin
  fLastError := fLastError + ', ' + Msg;
end;

procedure TfrmFiler.WMMountVolumes(var Message: TMessage);

begin
  MountListOfVolumes(MessageBuffer);
end;

procedure TfrmFiler.WMUnMountAllVolumes(var Message: TMessage);
begin
  UnMountAllVolumes;
end;

procedure TfrmFiler.WMCreateCSVFileFromMountedVolumes(
  var message: TMessage);
var
  Msg: string;
begin
  SaveListOfMountedVolumes(MessageBuffer);
  Msg := Format('List of mounted volumes written to file: %s', [MessageBuffer]);
  WriteLn(Msg);
end;

procedure TfrmFiler.RebootLastSystem1Click(Sender: TObject);
var
  BootParams: TBootparams;
begin
  BootParams := FilerSettings.RecentBootsList.FindLatestBootItem;
{$IfDef Debugging}
  if BootParams.IsDebugging then
    DebugInterpreter(BootParams)
  else
{$EndIf Debugging}
    BootInterpreter(BootParams);
end;

procedure TfrmFiler.ChangeFileTypeforFile1Click(Sender: TObject);
var
  FileNumberString, aFileName, CodeStr: string;
  TheVolume: TVolume;
  DirIdx: integer;
begin
  if Assigned(CurrentVolume) then
    begin
      TheVolume  := CurrentVolume;
      if GetString('Select pSys file', 'File name/number', FileNumberString, 15) then
        begin
          DirIdx := TheVolume.DirIdxFromString(FileNumberString);
          if (DirIdx > 0) and (DirIdx <= TheVolume.NumFiles) then
            begin
              aFileName    := TheVolume.Directory[DirIdx].FileName;
              if GetString(aFileName, 'New Code (0:UNTYPED, 1:XDSK, 2:CODE, 3:TEXT, 4:INFO, 5:DATA, 6:GRAF, 7:FOTO, 8:SECURE)', CodeStr, 2) then
                begin
                  if (Length(CodeStr) = 1) and (CodeStr[1] in ['0'..'8']) then
                    with TheVolume do
                      begin
                        DI.RECTORY[DirIdx].DFKind := StrToInt(CodeStr);
                        DirectoryChanged('Change file type');
                        WriteDirectoryToDisk(false);
                        CloseVolumeFile;
                        LoadVolumeInfo(DIRECTORY_BLOCKNR);         // reload the updated volume info
                        DisplayDirectory(fCurrentUnit, '', true);
                      end
                  else
                    AlertFmt('Invalid code value %s', [CodeStr]);
                end;
            end;
        end;
    end
  else
    NoCurrentVolume;
end;

end.
