{$undef temporary}
unit pCodeDebugger_Decl;

interface

uses
  Forms, Debug_Decl, Interp_Decl, pSys_Decl, Graphics,
  FilerTables, Classes, pSysVolumes, DebuggerSettingsUnit, Interp_Const, LoadVersion;

type
  TAltNameRec = record
                  xSegNameIdx: TSegNameIdx;
                  xErecp: word;
                  xSegName: string;
                end;

  THistoryList = array of THistoryItem;

  TFormsList = class(TList)
  private
  protected
  public
    procedure RefreshAll; virtual; abstract;
    procedure SaveAll; virtual; abstract;
    procedure DeleteAll; virtual;
    procedure DeleteOne(Idx: integer); virtual;
    Destructor Destroy; override;
  end;

  TDashBoardsList = class(TFormsList)
                      public
                        procedure DeleteAll; override;
                        procedure RefreshAll; override;
                        procedure SaveAll; override;
                    end;

  TInspectorList = class(TFormsList)
                   public
                     procedure RefreshAll; override;
                     procedure SaveAll; override;
                   end;

  TfrmPCodeDebuggerCustom = class;

  TVarsList = class(TFormsList)
                   private
                     pCodeDebugger : TfrmPCodeDebuggerCustom;
                   public
                     procedure RefreshAll; override;
                     procedure SaveAll; override;
                     Constructor Create(aForm: TForm); reintroduce; virtual;
                   end;

  TfrmPCodeDebuggerCustom = class(TForm)
  private
    fLoaded          : integer;
    fNrErrors        : integer;
    fProcessed       : integer;
    function CallingAProc(anOpcode: word): boolean;
    procedure ErrorLine(const Msg: string);
    procedure ErrorLineFmt(const Msg: string; Args: array of const);
    procedure LoadSegmentName(Table: TpCodesProcTable);
    procedure ScanSegmentProcNames(DBName: string; ProcCall: TScanSegNameProcCall);
    procedure SetVersionNr(const Value: TVersionNr);
    function DbgCnt: longint;
    function GetVersionNr: TVersionNr;
    procedure DoAfterDEBUGGERSettingsLoaded(Sender: TObject);
  protected
    fCurrentProcName  : string;
    fDatabaseSettings: TDATABASESettings;
    fDatabaseSettingsFileName: string;
{$IfDef DashBoard}
    fDashBoardWindowsList: TDashBoardsList;
{$EndIf DashBoard}    
    XfDEBUGGERSettings: TDEBUGGERSettings;
    fDEBUGGERSettingsFileName: string;
    fHistory         : THistoryList;
    fHistIdx         : integer;
    fLastAccDbFileNumber: integer;
    fLogFile         : TextFile;
    fErrorLogFile    : TextFile;   // **
    fLogFileName     : string;
    fOnStatusUpdate  : TStatusProc;
    fSeenProcs       : array of TSeenProc; // better: array[TSegNameIdx] of array of integer;
    fStepping        : boolean;
    fUseCInterp      : boolean;
    fMAXHIST         : integer;
    fVersionNr       : TVersionNr;
    fVolumesList     : TVolumesList;
    fpCodesProcTableS: TStringList;
    fpCodesProcTableName: string;
    fpCodesProcTable : TpCodesProcTable;  // The currently active procs table

    procedure CloseLogFile;
    procedure DumpHistory(HowMany: word);
    function  GetCallHistoryOnly: boolean; virtual; abstract;
    function  IdentifierValue(IC: TIdentCode): longword; virtual; abstract;
    function  InAltSegNames(anErecp: word; var aSegNameIdx: TSegNameIdx; var aSegName: string): boolean;
    procedure InitProcNames; virtual;
    procedure LoadProcedureNames; virtual;
    procedure LoadSegmentProcName(Table: TpCodesProcTable);
    procedure PrintSegmentProcNames(OutFileName: string);
    procedure SetCallHistoryOnly(const Value: boolean); virtual; abstract;
    procedure VerifySegnamesProcNames;
    procedure VerifySegmentProcName(Table: TpCodesProcTable);
    property  VersionNr: TVersionNr
              read GetVersionNr
              write SetVersionNr;
  public
    fExceptionMessage: string;
    fInterpreter     : TObject;
    fLastProcNr      : integer;
    fLastSegmentIdx  : TSegNameIdx;
    AltSegNames      : array of TAltNameRec;
    procedure AddAltSegName(aErecp: word; aSegNameIdx: TSegNameIdx; aSegName: string);
    procedure AddHist(aProcNr: byte; aRelIPC: integer; anOpcode: word;
      aName: string; aSegNameIdx: TSegNameIdx; ProcCallsOnly: boolean);
    procedure AddMessage( WatchIndex:integer;
                          SegNameIdx: TSegNameIdx;
                          ProcNum: word;
                          anIPC: word;
                          const Value: string = ''); virtual; abstract;
    procedure AddSeenProc(aSegNameIdx: TSegNameIdx; aProcNr: integer);
    procedure CloseDebugUnit;
    procedure DebuggerLoadFromUnit(aVersionNr: TVersionNr; Boot_Unit: integer);
    function  DashboardWindowsList: TDashBoardsList;
    function  DATABASESettings: TDATABASESettings;
    function  DEBUGGERSettings: TDEBUGGERSettings;
    procedure Enable_Run(value: boolean); virtual; abstract;
    function  IdentCode(const aWord: string): TIdentCode;
    procedure IncProfile(SegNameIdx: TSegNameIdx; ProcNum: integer);
    procedure InitDebugUnit(aInterpreter: TObject); virtual;
    function  IsUnSeenProc(aSegNameIdx: TSegNameIdx; aProcNr: word): boolean;
    procedure LoadDEBUGGERSettingsForVersionNr(VersionNr: TVersionNr);
    function  LoggingToAFile: boolean;
    procedure OpenLogFile(const FileName: string);
    function  ProcNumStr(ProcNum: Integer): string;
    procedure ReloadSegNamesProcnames(Sender: TObject);
    procedure Running(IsRunning: boolean; BrkNo: integer); virtual;
    function  SegIdxFromName(const aSegName: string): TSegNameIdx;
    function  TheSegNameIdx(SegBase: longword): TSegNameIdx; virtual; abstract;
    function  UnseenProcIndex(aSegNameIdx: TSegNameIdx; aProcNr: integer): integer;
    procedure Update_Status(const aCaption: string; aColor: TColor = clBtnFace);
    procedure Update_StatusFmt(const aCaption: string;
                               Args: array of const; aColor: TColor = clBtnFace);
    property  HistIdx: integer
              read fHistIdx;
    property  History: THistoryList
              read fHistory;
    function  WatchAddrFromExpression(AddrExpr: string): longword;
    procedure UpdateDebuggerDisplay; virtual; abstract;

    Constructor Create( aOwner: TComponent;
                        Interpreter: TObject;
                        VolumesList: TVolumesList;
                        anOnUpdateStatusProc: TStatusProc;
                        TheBootParams: TBootParams); reintroduce; virtual;
    property  CurrentProcName: string
              read fCurrentProcName;

    Destructor Destroy; override;

    property   OnStatusUpdate: TStatusProc
               read fOnStatusUpdate
               write fOnStatusUpdate;
    property   DatabaseSettingsFileName: string
               read fDatabaseSettingsFileName
               write fDatabaseSettingsFileName;
  end;

var

  frmPCodeDebugger: TfrmPCodeDebuggerCustom;   // This ought to become something that is not global. i.e.,
                                               // allow multiple debuggers to be running

implementation

uses
  SysUtils, MyUtils, FilerSettingsUnit, SegmentProcname, Controls,
  PsysUnit, MyTables_Decl, Misc, Interp_Common, FileNames, Inspector,
  pSysDebugWindow, LocalVariables;

  function TfrmPCodeDebuggerCustom.CallingAProc(anOpcode: word): boolean;
  begin
    with fInterpreter as TCustomPsystemInterpreter do
      result := anOpcode in (OpsTable.Call_OPS + OpsTable.Return_OPS);
  end;

  procedure TfrmPCodeDebuggerCustom.OpenLogFile(const FileName: string);
  begin
    if not LoggingToAFile then
      begin
        AssignFile(fLogFile, FileName);
        Rewrite(fLogFile);
        WriteLn(fLogFile, 'DbgCnt', ',',
                          'IPC', ',',                    { IPC }
                          'SegName', ',',   { SegName }
                          'ProcNum', ',',                { ProcNum }
                          'ProcName', ',',
                          'Op', ',',
                          'OpName', ',',
                          'Value');
//      fLoggingToAFile := true;
      end;
  end;

  procedure TfrmPCodeDebuggerCustom.CloseLogFile;
  begin
(*
    if fLogFileName <> '' then
      begin
        CloseFile(fLogFile);
        EditTextFile(fLogFileName);
      end;
*)
    if LoggingToAFile then
      begin
        CloseFile(fLogFile);
        AlertFmt('Messages saved to file "%s"', [DEBUGGERSettings.Brks.LogFileName]);
//      fLoggingToAFile := false;
      end;
  end;

  procedure TfrmPCodeDebuggerCustom.AddHist( aProcNr: byte;
                     aRelIPC: integer;
                     anOpcode: word;
                     aName: string;
                     aSegNameIdx: TSegNameIdx;
                     ProcCallsOnly: boolean);
  const
    SCROLLSIZE = 10;
  var
    i: word;
    OK: boolean;
  begin  { Needs to be tested }
    if aRelIPC >= 0 then
      begin
        If ProcCallsOnly then
          Ok := CallingAProc(anOpcode)
        else
          Ok := true;

        if Ok then
          begin
            with fHistory[fHistIdx] do
              begin
                HistNr  := DbgCnt;
                ProcNr  := aProcNr;
                RelIPC  := aRelIPC;
                Opcode  := anOpcode;
                SegNameIdx := aSegNameIdx;
                Name    := aName;
              end;

            if fHistIdx <  fMAXHIST then
              inc(fHistIdx)
            else
              begin
                for i := 0 to fMAXHIST-SCROLLSIZE do
                  fHistory[i] := fHistory[i+SCROLLSIZE];
                for i := fMAXHIST-SCROLLSIZE+1 to fMAXHIST do
                 with fHistory[i] do
                  begin
                    HistNr  := 0;
                    ProcNr  := 0;
                    RelIPC  := 0;
                    SegNameIdx := sn_Unknown;
                    Name    := '';
                  end;
                fHistIdx := fHistIdx - SCROLLSIZE + 1;
              end;
          end;
      end
    else
      raise Exception.CreateFmt('Invalid IPC = %d', [aRelIPC]);
  end;

  procedure TfrmPCodeDebuggerCustom.AddSeenProc(aSegNameIdx: TSegNameIdx; aProcNr: integer);
  var
    Len: integer;
  begin
    if UnseenProcIndex(aSegNameIdx, aProcNr) < 0 then
      begin
        Len := Length(fSeenProcs);
        SetLength(fSeenProcs, Len+1);
        with fSeenProcs[Len] do
          begin
            spSegNameIdx      := aSegNameIdx;
            spProcNr          := aProcNr;
          end;
      end;
  end;

  function TfrmPCodeDebuggerCustom.IsUnSeenProc(aSegNameIdx: TSegNameIdx; aProcNr: word): boolean;
  begin
    result := UnseenProcIndex(aSegNameIdx, aProcNr) < 0;
  end;

procedure TfrmPCodeDebuggerCustom.Running(IsRunning: boolean; BrkNo: integer);
begin
  with fInterpreter as TCustomPsystemInterpreter do
    if IsRunning then
      Caption := Format('p-Code Debugger/Interpreter %s [ Running] ', [VersionNrStrings[VersionNr].Name])
    else
      Caption := Format('p-Code Debugger/Interpreter %s @ Breakpoint # %d', [VersionNrStrings[VersionNr].Name, BrkNo+2]);
end;



function TfrmPCodeDebuggerCustom.SegIdxFromName(const aSegName: string): TSegNameIdx;
var
  idx: integer;
begin
  result := sn_Unknown;
  if (aSegName <> '') then
    with SegNamesInDB do
      begin
        idx := IndexOf(aSegName);
        if Idx >= 0 then
          result := Integer(Objects[idx])
      end
end;

  procedure TfrmPCodeDebuggerCustom.LoadSegmentProcName(Table: TpCodesProcTable);
  var
    aSegName, aProcName, CurrentName: string;
    aSegNameIdx: TSegNameIdx;
    aProcNumber: integer;
  begin
    with Table do
      begin
        aSegName    := UCSDName(fldSegmentName.AsString);
        aProcName   := UCSDName(fldProcedureName.AsString);
        aProcNumber := fldProcedureNumber.AsInteger;
        if (aSegName <> '') and (aProcName <> '') then
          begin
            aSegNameIdx := SegIdxFromName(aSegName);
            if Empty(aProcName) then
              ErrorLine('fldProcName is empty') else
            if Empty(aSegName) then
              ErrorLine('fldSegName is empty') else
            if Empty(ProcNamesInDB[aSegNameIdx, aProcNumber]) then
              begin
                ProcNamesInDB[aSegNameIdx, aProcNumber] := aProcName;
                inc(fLoaded);
              end
            else
              begin
                CurrentName := ProcNamesInDB[aSegNameIdx, aProcNumber];
                if SameText(aProcName, CurrentName) then
                  ErrorLineFmt('Duplicate entry in pCodeProcsTable for %3d:%s.%s',
                                 [aProcNumber, aSegName, aProcName])
                else
                  ErrorLineFmt('Mismatch between pCodeProcsTable and ProcNamesInDB[] array for (%d) %s.%s <> %s.%s',
                                   [aProcNumber,
                                    aSegName, aProcName,
                                    SegNamesInDB[aSegNameIdx],
                                    CurrentName]);
              end;
          end;
      end;
  end;

  procedure TfrmPCodeDebuggerCustom.ErrorLine(const Msg: string);
  begin
    WriteLn(fErrorLogFile, Msg);
    inc(fNrErrors);
  end;

  procedure TfrmPCodeDebuggerCustom.ErrorLineFmt(const Msg: string; Args: array of const);
  begin
    ErrorLine(Format(Msg, Args));
  end;

  procedure TfrmPCodeDebuggerCustom.InitProcNames;
  begin
    // count the number of unique segment names
    fNrErrors := 0; fProcessed := 0; fLoaded := 0;

    // Load procedure names for ALL of the specified procedure names tables
    LoadProcedureNames;

    Update_StatusFmt('%d records processed. %d procedure names loaded. %d errors occurred',
                   [fProcessed, fLoaded, fNrErrors]);
  end;

  procedure TfrmPCodeDebuggerCustom.VerifySegnamesProcNames;
  var
    Msg: string;
  begin
    fNrErrors := 0;  fProcessed := 0;

    with DEBUGGERSettings do
      begin
        AssignFile(fErrorLogFile, DEBUGGERSettings.LogFileName);
        ReWrite(fErrorLogFile);
        WriteLn(fErrorLogFile, 'Errors while verifying SegName/Procedure names on ', DateTimeToStr(now));
        try
          ScanSegmentProcNames(DatabaseToUse, VerifySegmentProcName);
          if fNrErrors > 0 then
            begin
              Msg := Format('%4d records processed, %4d errors (File="%s")', [fProcessed, fNrErrors, FilerSettings.LogFileName]);
              WriteLn(fErrorLogFile, Msg);
              Message(Msg);
            end;
        finally
          CloseFile(fErrorLogFile);
        end;
      end;
  end;

procedure TfrmPCodeDebuggerCustom.LoadProcedureNames;
begin
  FreeAndNil(SegNamesInDB);
  SegNamesInDB := TSegNamesList.Create;
  SegNamesInDB.Sorted := true;

  with DEBUGGERSettings do
    begin
      AssignFile(fErrorLogFile, DEBUGGERSettings.LogFileName);
      ReWrite(fErrorLogFile);
      WriteLn(fErrorLogFile, 'Errors while loading SegName/Procedure names on ', DateTimeToStr(now));
      try
        ScanSegmentProcNames( DataBaseToUse, LoadSegmentName); // any missing ones that are in the pCodeProcs table

        ScanSegmentProcNames( DatabaseToUse, LoadSegmentProcName);
      finally
        CloseFile(fErrorLogFile);
      end;
    end;
end;

procedure TfrmPCodeDebuggerCustom.LoadSegmentName(Table: TpCodesProcTable);
var
  aSegName: string;
begin { LoadSegmentName }
  with Table do
    begin
      aSegName := UCSDName(fldSegmentName.AsString);
      if SegNamesInDB.IndexOf(aSegName) < 0 then
        begin
          SegNamesInDB.AddObject(aSegName, TObject(SegNamesInDB.Count));
          Inc(fLoaded);
        end;
    end;
end; { LoadSegmentName }

procedure TfrmPCodeDebuggerCustom.ReloadSegNamesProcnames(Sender: TObject);
begin
  inherited;
  InitProcNames;
end;

procedure TfrmPCodeDebuggerCustom.Update_Status(const aCaption: string;
  aColor: TColor);
begin
  if Assigned(fOnStatusUpdate) then
    fOnStatusUpdate(aCaption, false, true);
end;

procedure TfrmPCodeDebuggerCustom.Update_StatusFmt(const aCaption: string;
  Args: array of const; aColor: TColor);
begin
  Update_Status(Format(aCaption, Args), aColor);
end;

  procedure TfrmPCodeDebuggerCustom.VerifySegmentProcName(Table: TpCodesProcTable);
  var
    aSegName, aProcName: string;
    aSegNameIdx: TSegNameIdx;
    aProcNumber: integer;
    Line: string;
  begin
    with Table do
      begin
        aSegName    := UCSDName(fldSegmentName.AsString);
        aProcName   := UCSDName(fldProcedureName.AsString);
        aProcNumber := fldProcedureNumber.AsInteger;
        if (aSegName <> '') and (aProcName <> '') then
          begin
            aSegNameIdx := SegIdxFromName(aSegName);
            if not SameText(aProcName, ProcNamesInDB[aSegNameIdx, aProcNumber]) then
              begin
                Line := Format('Mismatch between pCodeProcsTable and ProcNamesInDB[] array for %s.%s <> %s.%s',
                               [aSegName, aProcName,
                                SegNamesInDB[aSegNameIdx], ProcNamesInDB[aSegNameIdx, aProcNumber]]);
                ErrorLine(line);
              end;
          end;
      end;
  end;

  function TfrmPCodeDebuggerCustom.UnseenProcIndex(aSegNameIdx: TSegNameIdx; aProcNr: integer): integer;
  var
    i: integer;
  begin
    for i := 0 to Length(fSeenProcs)-1 do
      with fSeenProcs[i] do            // could be sorted to increase speed
        if (aSegNameIdx      = spSegNameIdx) and
           (aProcNr          = spProcNr) then
          begin
            result := i;
            exit;
          end;
    result := -1;
  end;

function TfrmPCodeDebuggerCustom.ProcNumStr(ProcNum: Integer): string;
begin
  if ProcNum >= 0 then
    result := IntToStr(ProcNum)
  else
    result := Format('(%d)', [Abs(ProcNum)]);
end;

  function TfrmPCodeDebuggerCustom.InAltSegNames(    anErecp: word;
                         var aSegNameIdx: TSegNameIdx;
                         var aSegName: string): boolean;
  var
    i, Len: integer;
  begin
    result := false;
    Len := Length(AltSegNames);
    for i := 0 to Len-1 do
      with AltSegNames[i] do
        if xErecp = anErecp then
          begin
            aSegNameIdx      := xSegNameIdx;
            aSegName         := xSegName;
            result           := true;
            break;
          end;
  end;

  procedure TfrmPCodeDebuggerCustom.AddAltSegName(aErecp: word; aSegNameIdx: TSegNameIdx; aSegName: string); 
  var
    Len: word;
  begin
    Len := Length(AltSegNames);
    SetLength(AltSegNames, Len + 1);
    with AltSegNames[Len] do
      begin
        xSegNameIdx      := aSegNameIdx;
        xErecp           := aErecp;
        xSegName         := aSegName;
      end;
  end;

  procedure TfrmPCodeDebuggerCustom.InitDebugUnit(aInterpreter: TObject);
  begin { InitDebugUnit }
//  fDbgCnt         := 0;

    fStepping       := false;
//  fDbgCnt         := 0;
    fLastProcNr     := -1; // $FFFF;
    fLastSegmentIdx := sn_Unknown;

    fInterpreter    := aInterpreter; // save as a global
    SetLength(fSeenProcs, 0);
{$IfDef DEBUGLOGFILE}
    DebugLogFileName := ExtractFilePath(ParamStr(0)) + 'DebugLogFile.txt';
    AssignFile(DebugLogFile, DebugLogFileName);
    Rewrite(DebugLogFile);
    WriteLn(DebugLogFile, 'LogFile created at ', DateTimeToStr(Now));
{$EndIf}
{$IfDef DECODERWINDOW}
    frmDecodeWindow := DecoderWindow(TComponent(gInterpreter));       // create the decoder window
{$EndIf}
    fMAXHIST := XfDEBUGGERSettings.MaxHistoryItems;
    SetLength(fHistory, fMAXHIST+1);
    SetLength(AltSegNames, 0);
//  InitProcNames;
  end;  { InitDebugUnit }

  procedure TfrmPCodeDebuggerCustom.ScanSegmentProcNames(DBName: string;
                                                ProcCall: TScanSegNameProcCall);
  var
    TempPCodesProcTable: TpCodesProcTable;
  begin
    TempPCodesProcTable := TpCodesProcTable.Create( self,
                                                    DBName,
                                                    TableNamePCODEPROCS,
                                                    [optLevel12]);
    try
      with TempPCodesProcTable do
        begin
          Active := true;                        
          First;
          while not eof do
            begin
              Update_Status(Format('Loading #%2d  %2d:%s.%s', [ fProcessed,
                                                               fldProcedureNumber.AsInteger,
                                                               fldSegmentName.AsString,
                                                               fldProcedureName.AsString]), clGreen);
              ProcCall(TempPCodesProcTable);
              Next;
              inc(fProcessed);
            end;
        end;
    finally
      FreeAndNil(TempPCodesProcTable);
//    CloseFile(fLogFile);
      Update_StatusFmt('Processed %d records', [fProcessed]);
    end;
  end;

function TfrmPCodeDebuggerCustom.WatchAddrFromExpression(AddrExpr: string): longword;
var
  ID: TIdentCode;
begin
  result := 0;
  if Length(AddrExpr) > 0 then
    if AddrExpr[1] = '$' then
      result := ReadInt(AddrExpr) else
    if IsPureNumeric(AddrExpr) then
      result := StrToInt(AddrExpr) else
    if IsIdentifier(AddrExpr) then
      begin
        ID     := IdentCode(AddrExpr);
        result := IdentifierValue(ID);
      end;
end;

procedure TfrmPCodeDebuggerCustom.CloseDebugUnit;
begin
{$If Defined(DEBUGLOGFILE)}
    CloseFile(DebugLogFile);
{$IfEnd}
{$IfDef DebugLogFile}
    FreeAndNil(frmPSysDebugPrinter);
{$EndIf}
{$IfDef DECODERWINDOW}
    FreeAndNil(frmDecodeWindow);
{$EndIf}
end;

function TfrmPCodeDebuggerCustom.IdentCode(
  const aWord: string): TIdentCode;
begin
    for result := Low(TIdentCode) to High(TIdentCode) do
      if Sametext(aWord, IdentCodeInfo[result].Ident) then
        Exit;
    result := ic_Unknown;
end;

constructor TfrmPCodeDebuggerCustom.Create( aOwner: TComponent;
                                            Interpreter: TObject;
                                            VolumesList: TVolumesList;
                                            anOnUpdateStatusProc: TStatusProc;
                                            TheBootParams: TBootParams);
begin
  inherited Create(aOwner);

  frmPCodeDebugger  := self;    // currently a global variable -- needs to be local to something?
  fInterpreter      := Interpreter;
  fpCodesProcTableS := TStringList.Create;
  fVolumesList      := VolumesList;

  fDatabaseSettings := TDATABASESettings.Create(self);
  fDatabaseSettingsFileName := DataBaseSettingsFilesFolder + DATABASE_INI;
  DATABASESettings.LoadFromFile(fDatabaseSettingsFileName);

  fDEBUGGERSettingsFileName := DEBUGGERSettingsFileName(TheBootParams.VersionNr);

  XfDEBUGGERSettings := TDEBUGGERSettings.Create(self);
  XfDEBUGGERSettings.OnLoadFile := DoAfterDEBUGGERSettingsLoaded;
  XfDEBUGGERSettings.LoadFromFile(fDEBUGGERSettingsFileName);

  VersionNr          := TheBootParams.VersionNr;  // prepare to load the debugging database

  InitDebugUnit(Interpreter);
end;

procedure TfrmPCodeDebuggerCustom.DoAfterDEBUGGERSettingsLoaded(Sender: TObject);
begin
//Assert(false, 'Trying to create/initialize the DEBUGGERSettings.DataBaseList');
//XfDEBUGGERSettings.DatabaseList;  // create the DatabaseList and initialize it
end;


destructor TfrmPCodeDebuggerCustom.Destroy;
begin
{$IfDef DashBoard}
  FreeAndNil(fDashboardWindowsList);
{$EndIf DashBoard}

  FreeAndNil(SegNamesInDB);

  XfDEBUGGERSettings.SaveToFile(fDEBUGGERSettingsFileName);
  FreeAndNil(XfDEBUGGERSettings);

  fDatabaseSettings.SaveToFile(fDataBaseSettingsFileName);
  FreeAndNil(fDatabaseSettings);

  inherited;
end;

procedure TfrmPCodeDebuggerCustom.PrintSegmentProcNames(OutFileName: string);
var
  i, j: integer;
  OutFile: textfile;
  SegNameIdx: TSegNameIdx;
  aProcName: string;
begin
  AssignFile(OutFile, OutFileName);
  ReWrite(OutFile);
  WriteLn(OutFile, 'Segment/Procedure Names', DateTimeToStr(Now):50);
  WriteLn(OutFile, Padr('', 80, '-'));
  WriteLn(OutFile, 'SegNr Seg Name');
  WriteLn(OutFile, '      Proc Names');
  try
    WriteLn(OutFile, 'PrintSegmentProcNames is out of order');
//  Assert(false, 'This code needs to be retested');
    for i := 0 to SegNamesInDB.Count-1 do
      begin
        SegNameIdx := Integer(SegNamesInDB.Objects[i]);
        WriteLn(OutFile, SegNameIdx:5, ': ', SegNamesInDB[SegNameIdx]);
        Write(OutFile, '':7);
        for j := 0 to MAXPROCNAME-1 do
          begin
            aProcName := ProcNamesInDB[SegNameIdx][j];
            if aProcName <> '' then
              Write(OutFile, '#', j, ':', aProcName, ', ');
          end;
        WriteLn(OutFile);
        WriteLn(OutFile);
      end;
  finally
    CloseFile(OutFile);
    EditTextFile(OutFileName);
  end;
end;

procedure TfrmPCodeDebuggerCustom.DumpHistory(HowMany: word);
{$IfDef LOGCALLS}
var
  j: integer;
  aProcName, ProcName: string;
{$EndIf}
begin
{$IfDef LOGCALLS}
  WriteLn( CallsLogFile, 'Here is the preceding history:');
  for j := Max(gMAXHIST-HowMany, 0) to fHistIdx-1 do
    with fHistory[j] do
      begin
        aProcName := ProcNamesInDB[SegNameIdx, ProcNr];
        if not Empty(aProcName) then
          ProcName := SegNames[SegNameIdx] + '.' + aProcName
        else
          ProcName := Format('Seg #%d, Proc #%d', [ord(SegNameIdx), ProcNr]);

        WriteLn( CallsLogFile, HistNr:6, ': ',
                               Padr(ProcName,30),
                               RelIpc:4, ' ', Name);
      end;
  WriteLn( CallsLogFile, Padr('', 80, '='));
  WriteLn( CallsLogFile);
{$EndIf}
end;


procedure TfrmPCodeDebuggerCustom.SetVersionNr(const Value: TVersionNr);
begin
  fVersionNr := Value;
end;

function TfrmPCodeDebuggerCustom.DbgCnt: longint;
begin
  result := (fInterpreter as TCustomPsystemInterpreter).DbgCnt;
end;

procedure TfrmPCodeDebuggerCustom.IncProfile(SegNameIdx: TSegNameIdx;
  ProcNum: integer);
begin
  if (SegNameIdx < MAX_SEGNAMES) and (ProcNum < MAXPROCNAME) then
    with Profile[SegNameIdx, ProcNum] do
      Inc(Count);
end;

function TfrmPCodeDebuggerCustom.GetVersionNr: TVersionNr;
begin
  result := fVersionNr;
end;

function TfrmPCodeDebuggerCustom.LoggingToAFile: boolean;
begin
  result := false;
end;

procedure TfrmPCodeDebuggerCustom.DebuggerLoadFromUnit(aVersionNr: TVersionNr; Boot_Unit: integer);
begin
  with DEBUGGERSettings do
    begin
      VersionNr             := aVersionNr;
      LastBootedUnitNr      := Boot_Unit;
      LastBootedFileName    := fVolumesList[Boot_Unit].TheVolume.DOSFileName;
    end;

  with fInterpreter as TCustomPsystemInterpreter do
    begin
      Load_PSystem(Boot_Unit);
      Enable_Run(true);

      UpdateDebuggerDisplay;
     end;

  Update_StatusFmt('Volume #%d:%s has been loaded and is ready to run',
                    [BOOT_UNIT, fVolumesList[BOOT_UNIT].VolumeName], clLime);
end;


function TfrmPCodeDebuggerCustom.DATABASESettings: TDATABASESettings;
begin
  if not Assigned(fDataBaseSettings) then
    fDataBaseSettings := TDATABASESettings.Create(self);
  result := fDatabaseSettings;
end;

// This should be replaced with a faster version that doesn't require a procedure call
function TfrmPCodeDebuggerCustom.DEBUGGERSettings: TDEBUGGERSettings;
begin
  if not Assigned(XfDEBUGGERSettings) then
    XfDEBUGGERSettings := TDEBUGGERSettings.Create(self);
  result := XfDEBUGGERSettings;
end;

procedure TfrmPCodeDebuggerCustom.LoadDEBUGGERSettingsForVersionNr(VersionNr: TVersionNr); // This should be accessing the database file?
begin
  fDEBUGGERSettingsFileName := DEBUGGERSettingsFileName(VersionNr);
  if Assigned(XfDEBUGGERSettings) then
    FreeAndNil(XfDEBUGGERSettings); // does this need to be  saved first?

  XfDEBUGGERSettings := TDEBUGGERSettings.Create(nil);
  with XfDEBUGGERSettings do                           
    if FileExists(fDEBUGGERSettingsFileName) and (FileSize32(fDEBUGGERSettingsFileName) > 0) then
      LoadFromFile(fDEBUGGERSettingsFileName)
    else
      raise Exception.CreateFmt('Debugger settings file "%s" does not exist', [fDEBUGGERSettingsFileName]);
end;

{$IfDef DashBoard}
function TfrmPCodeDebuggerCustom.DashboardWindowsList: TDashBoardsList;
begin
  if not Assigned(fDashboardWindowsList) then
    fDashboardWindowsList := TDashBoardsList.Create;
  result := fDashboardWindowsList;
end;
{$EndIf DashBoard}

{ TFormsList }

procedure TFormsList.DeleteAll;
var
  i: integer;
begin
  for i := Count-1 downto 0 do
    begin
      TForm(ITems[i]).Free;
      Delete(i);
    end;
end;

procedure TFormsList.DeleteOne(Idx: integer);
begin
  TForm(Items[Idx]).Free;
  Delete(Idx);
end;

destructor TFormsList.Destroy;
begin
  DeleteAll;
  inherited;
end;

procedure TInspectorList.RefreshAll;
var
  i: integer;
begin
  inherited;

  for i := 0 to Count-1 do
    with TfrmInspect(Items[i]) do
      UpdateWatchNameAndValue;
end;

{$IfDef DashBoard}
{ TDashBoardsList }

procedure TDashBoardsList.DeleteAll;
var
  i: integer;
begin
  for i := Count-1 downto 0 do
    TForm(Items[i]).Free;
end;

procedure TDashBoardsList.RefreshAll;
var
  i: integer;
begin
  inherited;
  for i := 0 to Count-1 do
    with TfrmPSysDebugWindow(Items[i]) do
      UpdateDebugWindow('');
end;

procedure TDashBoardsList.SaveAll;
begin
  inherited;

end;
{$EndIf DashBoard}

constructor TVarsList.Create(aForm: TForm);
begin
  Inherited Create;
  pCodeDebugger := aForm as TfrmPCodeDebuggerCustom;
end;

procedure TVarsList.RefreshAll;
var
  i: integer;
begin
  inherited;

  for i := 0 to Count-1 do
    with TfrmLocalVariables(Items[i]), pCodeDebugger do
      begin
        UpdateDisplay( SegNamesInDB[fLastSegmentIdx],
                       pCodeDebugger.CurrentProcName,
                       fLastProcNr);
      end;
end;

procedure TVarsList.SaveAll;
var
  i: integer;
begin
  inherited;

  for i := 0 to Count-1 do
    with TfrmLocalVariables(Items[i]) do
      UpdateProcParameters(fpCodesProcTable);
end;


procedure TInspectorList.SaveAll;
begin
  inherited;
end;

end.
