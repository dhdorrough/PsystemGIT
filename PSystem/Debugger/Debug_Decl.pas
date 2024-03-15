unit Debug_Decl;

interface

uses
  Classes, UCSDGlob, Messages, Forms, Graphics, FilerTables, Watch_Decl,
  Interp_Decl;

const
  MAXHIST         = 50;
  
  ANYPROC         = -2; // Cannot use -1 because Delphi will treat it as an error code
  ANYUNSEEN       = -3; //
  ANYIPC          = -4; //

  MAXPROCNAME     = 70;

  CHARS_PER_SEG_NAME = 8;

//POINTERSIZE     = 2;

  MSG_INSPECTOR_ADDED = WM_USER + 1;

  sn_Unknown    = -2; // Cannot use -1 because Delphi will treat it as an error code

  MAX_SEGNAMES  = 200;   // This will always be exceeded by growth of the database.
                         // Code needs to change to access the DB rather than keeping in memory.
  MAX_CODE_FILES = 10;   // THIS NEEDS TO BECOME A DYNAMIC LIMIT

  CUNKNOWN      = '- UNKN -';
  CANYPROC      = '-ANY PROC-';
  CANYUNSEEN    = '-ANY UNSEEN-';
  CANYIPC       = '-ANY IPC-';

type
  integer = SmallInt;

//TCSType = (csDynamic, csStatic, csJTAB, csSEG, csENV, csProc, csIPC, csLocal);

  TSegNameIdx = sn_Unknown..MAX_SEGNAMES;

  TSetOfOpCodes = set of 0..255;

type
  TBreakInfo = class(TCollectionItem)
  private
    fBreakKind: TBrk;
    fTgtIPC: integer;
    fSegNameIdx: TSegNameIdx;
    fSegmentName: string;
    fTgtProc: integer;
    fComment: string;
    fDisabled: boolean;
    fLowAddr: longword;
    fNrBytes: word;
    fCheckSum: word;
    fWatchType: TWatchType;
    fPassCount: longint;
    fLogMessage: boolean;
    fDoNotBreak: boolean;
    fIndirect: boolean;
    fParam: longint;
    fLogToAFile: boolean;
    fLogFileOpen: boolean;
    fAddrExpression: string;
    fBreakPointDatabaseName: string;
    procedure SetSegmentName(const Value: string);
    function GetSegNameIdx: TSegNameIdx;
    function GetSegmentName: string;
    function GetLoggingToAFile: boolean;
    procedure SetBreakKind(const Value: TBrk);
    function GetDisabled: boolean;
    procedure SetDisabled(const Value: boolean);
  public
    nPassCount : longint;      // current passcount
    // ============================================================================================
    procedure Assign(Source: TPersistent); override; // REMEMBER TO UPDATE THIS IF CHANGES ARE MADE
    // ============================================================================================
    function CalcCheckSum(Bytes: TMemAsBytesPtr): word;
    function MemoryChanged(Bytes: TMemAsBytesPtr): boolean;

    property CheckSum: word
             read fCheckSum
             write fCheckSum;
    property SegNameIdx: TSegNameIdx
             read GetSegNameIdx
             write fSegNameIdx;
    Constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
    procedure OpenLogFile;
    procedure CloseLogFile;
    property LoggingToAFile: boolean             // This is true is we are actually currently logging to a file
             read GetLoggingToAFile;
    function LowAddr: word;
  published
    property SegName: string
             read GetSegmentName
             write SetSegmentName;
    property TgtIPC: integer
             read fTgtIPC
             write fTGTIPC
             default 0;
    property Brk: TBrk
             read fBreakKind
             write SetBreakKind;
    property TgtProc: integer
             read fTgtProc
             write fTgtProc;
    property Comment: string
             read fComment
             write fComment;
    property Disabled: boolean
             read GetDisabled
             write SetDisabled
             default false;
//  property LowAddr: longword
//           read GetLowAddr
//           write SetLowAddr
//           default 0;
    property NrBytes: word
             read fNrBytes
             write fNrBytes
             default 0;
    property WatchType: TWatchType
             read fWatchType
             write fWatchType
             default wt_Unknown;
    property PassCount: longint
             read fPassCount
             write fPassCount
             default 0;
    property DoNotBreak: boolean
             read fDoNotBreak
             write fDoNotBreak
             default false;
    property Indirect: boolean
             read fIndirect
             write fIndirect
             default false;
    property Param: longint
             read fParam
             write fParam
             default 0;
    property LogMessage: boolean
             read fLogMessage
             write fLogMessage
             default false;
    property LogToAFile: boolean    // this is TRUE if the users WANTS to log to a file
             read fLogToAFile
             write fLogToAFile
             default false;
    property BreakPointDatabaseName: string
             read fBreakPointDatabaseName
             write fBreakPointDatabaseName;
    property AddrExpr: string
             read fAddrExpression
             write fAddrExpression;
    // REMEMBER TO UPDATE "ASSIGN" IF CHANGES ARE MADE
  end;

// TWatchItem is the stuff that the user can change and which must be saved from run to run
  TWatchItem = class(TCollectionItem)  // TWatchList
  private
    fWatchType: TWatchType;
    fWatchParam: longint;
    fWatchComment: string;
    fWatchName: string;
    fWatchAddrExpr: string;
    fWatchIndirect: boolean;
    fParam: longint;
    fLogToAFile: boolean;
    function GetWatchAddr: longword;
  public
    // ============================================================================================
    procedure Assign(Source: TPersistent); override; // REMEMBER TO UPDATE THIS IF CHANGES ARE MADE
    // ============================================================================================
    function WatchValue(Interpreter: TObject): string;
  published
     property WatchType: TWatchType
              read fWatchType
              write fWatchType;
     property WatchAddr: longword
              read GetWatchAddr {
              write fWatchAddr};
     property WatchAddrExpr: string
              read fWatchAddrExpr
              write fWatchAddrExpr;
     property WatchParam: longint
              read fWatchParam
              write fWatchParam
              default 0;
     property WatchComment: string
              read fWatchComment
              write fWatchComment;
     property WatchName: string
              read fWatchName
              write fWatchName;
     property WatchIndirect: boolean
              read fWatchIndirect
              write fWatchIndirect
              default false;
     property Param: longint
              read fParam
              write fParam
              default 0;
     property LogToAFile: boolean
              read fLogToAFile
              write fLogToAFile;
   // REMEMBER TO UPDATE THIS IF CHANGES ARE MADE
   end;

  TBreakList = class(TCollection)   // of TBreakInfo
    procedure AddBreak( aTgtProc,
                        aTargetIPC: word;
                        aBreak: TBrk;
                        aSegNameIdx: TSegNameIdx = sn_Unknown);
  private
    fOwner: TPersistent;
    fLogFile: TextFile;
    fLogFileName: string;
    fLoggingToAFile: boolean;  // LoggingToAFile means that the file has been opened and Logging is occurring.
    fLogFileRefCount: integer;
    function GetItem(Index: Integer): TBreakInfo;
    procedure SetItem(Index: Integer; Value: TBreakInfo);
    function GetLogFileName: string;
    function GetLogFileOpen: boolean;
    procedure SetLogFileOpen(const Value: boolean);
//  procedure SetLogFileName(const Value: string);
  protected
    function  GetOwner: TPersistent; Override;
  public
    procedure CloseLogFile;
    procedure OpenLogFile;

    property LoggingToAFile: boolean  // LoggingToAFile means that the file has been opened and Logging is occurring.
             read fLoggingToAFile;
    property LogFileOpen: boolean
             read GetLogFileOpen
             write SetLogFileOpen;

    function BreakAlreadyExists( aTgtProc, aTargetIPC: word;
                                 aBreak: TBrk;
                                 aSegNameIdx: TSegNameIdx): boolean;
    function IndexOf( aTgtProc, aTargetIPC: integer;
                      aBreak: TBrk;
      aSegNameIdx: TSegNameIdx): integer;
    procedure InitBreaks(Bytes: TMemAsBytesPtr);
    Constructor Create(AOwner: TPersistent);
    function Add: TBreakInfo;
    function Insert(Index: Integer): TBreakInfo;
    property Items[Index: Integer]: TBreakInfo
             read GetItem
             write SetItem;
    property LogFile: TextFile
             read fLogFile
             write fLogFile;
    property LogFileRefCount: integer
             read fLogFileRefCount
             write fLogFileRefCount;
  published
    property LogFileName: string
             read GetLogFileName
             write fLogFileName;
  end;

  THistoryItem = packed record
                   HistNr: LONGWORD;
                   SegNameIdx: TSegNameIdx;
                   ProcNr: byte;
                   RelIPC: integer;
                   Opcode: word;
                   Name: string;
                 end;

  TSeenProc = record
                spSegNameIdx: TSegNameIdx;
                spProcNr: integer;
              end;

  TProc = procedure {name} of object;

  TIdentCodeInfo = record
    Ident: string;
    Comment: string;
    Proc: TProc;
  end;

  TIdentCode = (ic_Unknown, ic_SP_LOW, ic_SP_UPR, ic_SP, ic_MP, ic_Task_Link, ic_ERECp, ic_GlobVar, ic_DS, ic_CURTASK,
                ic_READYQ, ic_EVECp, ic_SegB, ic_SEXFLAG, ic_SEGTOP,
                ic_CPOffset, ic_LocalVar, ic_BX, ic_TOS, ic_TOS2, ic_EnterIC, ic_FaultTib, ic_FaultErec,
                ic_FaultSIB, ic_RelIPC, ic_AbsIPC, ic_DSpIPC, ic_DSpProcBase, ic_DataSize,
                ic_MemInfo, ic_JTAB, ic_SegNum, ic_IOResult);

  TFaultTypes = 128..131;

  TFaultTypeStrings = array[TFaultTypes] of string;

  TScanSegNameProcCall = procedure {name} (Table: TpCodesProcTable) of object;

  TGetWatchAddrProc = function {Name} (const WatchAddrExpr: string): word;

  TWatchList = Class(TCollection) { of TWatchItem }
                 private
                   fOwner : TPersistent;
                   fGetWatchAddrFromExpression: TGetWatchAddrProc;
                   function GetItem(Index: Integer): TWatchItem;
                   procedure SetItem(Index: Integer; Value: TWatchItem);
                 public
                   property GetWatchAddrFromExpression: TGetWatchAddrProc
                            read fGetWatchAddrFromExpression;
                   Constructor Create(aOwner: TPersistent); 
                   function Add: TWatchItem;
                   function Insert(Index: Integer): TWatchItem;
                   property Items[Index: Integer]: TWatchItem
                            read GetItem
                            write SetItem;
               end;

  TSegNamesList = class(TStringList)
  private
    function GetName(Index: integer): string;
  public
    Constructor Create;
    property Strings[Index: integer]: string
             read GetName; default;
  end;

  TBreakKindInfo = packed record
    BreakName: string[16];
    HasParam, UserSettable: boolean;
  end;

var
//Brks            : TBreakList;
{$If Defined(DEBUGLOGFILE)}
  DebugLogFile    : textfile;
  DebugLogFileName: string;
{$IfEnd}
{$If Defined(LOGCALLS)}
  CallsLogFile    : textfile;
  CallsLogFileName: string;
  CallLogIsOpen   : boolean;
  fHasBeenCalled  : TStringList;
  fHasNotBeenCalled: TStringList;
  fRL             : TRegsList;
{$IfEnd}
{$If Defined(DEBUGLOGFILE) or Defined(LOGCALLS)}
  FIndent         : integer;
{$iFeND}

  BreakKinds: array[TBrk] of TBreakKindInfo = (
      ({dbUnknown}     BreakName: 'Unknown'),
      ({dbBreak}       BreakName: 'Break Point';    UserSettable: true),
      ({dbBreakOnCall} BreakName: 'BreakOnCall'{;    UserSettable: true}),
      ({dbMemChanged}  BreakName: 'Memory Changed'; UserSettable: true),
      ({dbDbgCnt}      BreakName: 'Dbg Count';      HasParam: true; UserSettable: true),
      ({dbOpCode}      BreakName: 'Op Code';        HasParam: true; UserSettable: true),
      ({dbSystem_Halt} BreakName: 'System Halt'),
      ({dbException}   BreakName: 'Exception')
  );
//                                                   [-2..200,     -4..70]
    ProcNamesInDB  : array[TSegNameIdx, -4..MAXPROCNAME] of string;
                                                          // index 0 is not used. Its presence simplifies a few things
                                                          // Cannot use -1 because Delphi will treat it as an error code
                                                          //   ANYPROC         = -2;
                                                          //   ANYUNSEEN       = -3; //
                                                          //   ANYIPC          = -4; //

    SegNamesInDB   : TSegNamesList;

    Profile         : array[TSegNameIdx, 0..MAXPROCNAME] of
                        record
                          Count: longint;
                        end;

//  GLOBAL VARIABLES

  IdentCodeInfo: array[TIdentCode] of TIdentCodeInfo = (
          ({ic_Unknown}),
          ({ic_SP_LOW   } Ident: 'SP_LOW';        Comment: 'PME SP_LOW'),
          ({ic_SP_UPR   } Ident: 'SP_UPR';        Comment: 'PME SP_UPR'),
          ({ic_SP       } Ident: 'SP';            Comment: 'PME SP register'),
          ({ic_MP       } Ident: 'MP';            Comment: 'PME MP register'),
          ({ic_Task_Link} Ident: 'Task_Link';     Comment: 'PME Task Link'),
          ({ic_ERECp    } Ident: 'ERECp';         Comment: 'PME EREC register'),
          ({ic_GlobVar  } Ident: 'GlobVar';       Comment: 'Global Variables'),
          ({ic_DS       } Ident: 'DS';            Comment: 'PME code segment base'),
          ({ic_CURTASK  } Ident: 'CURTASK';       Comment: 'PME curtask register'),
          ({ic_READYQ   } Ident: 'READYQ';        Comment: 'PME READYQ register'),
          ({ic_EVECp    } Ident: 'EVECp';         Comment: 'PME EVEC register'),
          ({ic_SegB     } Ident: 'SegB';          Comment: 'PME SEGBASE register (Globals.LowMem.Segb)'),
          ({ic_SEXFLAG  } Ident: 'SEXFLAG';       Comment: 'PME current segment sex'),
          ({ic_SEGTOP   } Ident: 'SEGTOP';        Comment: 'PME pointer to procedure dictionary'),
          ({ic_CPOffset } Ident: 'CPOffset';      Comment: 'PME offset to constant pool'),
          ({ic_LocalVar } Ident: 'LocalVar';      Comment: 'Global data area'),
          ({ic_BX       } Ident: 'BX';            Comment: '?'),
          ({ic_TOS      } Ident: 'TOS';           Comment: 'Top word on stack'),
          ({ic_TOS2     } Ident: 'TOS2';          Comment: '2nd word on stack'),
          ({ic_ProcBase}  Ident: 'ProcBase';      Comment: 'Offset to proc within Segment'),
          ({ic_FaultTib}  Ident: 'Fault_TIB';     Comment: 'Fault TIB'),
          ({ic_FaultErec} Ident: 'Fault_EREC';    Comment: 'Fault EREC'),
          ({ic_FaultSIB}  Ident: 'Fault_SIB';     Comment: 'Fault SIB'),
//        ({ic_si}        Ident: 'SI';            Comment: 'PME SI'),
          ({ic_RelIPC}    Ident: 'RelIPC';        Comment: 'Relative IPC within proc'),
          ({ic_AbsIPC}    Ident: 'AbsIPC';        Comment: 'Absolute IPC in Bytes[]'),
          ({ic_DSpIPC}    Ident: 'DS+IPC';        Comment: '(current instruction addr)'),
          ({ic_DSpProcBase} Ident: 'DS+ProcBase'; Comment: 'DS+ProcBase (1st instructon addr'),
          ({ic_DataSize}  Ident: 'DataSize';      Comment: 'Data Size'),
          ({ic_MemInfo}   Ident: 'MemInfo';       Comment: 'MemInfo'),
          ({ic_JTAB}      Ident: 'JTAB';          Comment: '^JTAB'),
          ({ic_SEGNUM}    Ident: 'SegNum';        Comment: 'Segment Number'),
          ({ic_IOResult}  Ident: 'IOResult';      Comment: 'IO Result')
          );

  FaultTypes: TFaultTypeStrings  = (
                 ({128} 'Segment Fault'),
                 ({129} 'Stack Fault'),
                 ({130} 'Heap Fault'),
                 ({131} 'Pool Fault'));

  function FaultTypeStr(fault_type: integer): string;
  function MachTypeToStr(m_type: TMTypes): string;
  function PrefixInfo(Prefix: string; Addr: longword; const Note: string = ''): string;
  function ProcNamesF(SegNameIdx: TSegNameIdx; ProcNum: integer): string;
  function SegNamesF(SegNameIdx: TSegNameIdx): string;
  function WatchTypeFromWatchCode(wc: TWatchCode): TWatchType;
  function WatchCodeFromWatchType(WatchType: TWatchType): TWatchCode;

implementation

uses
  SysUtils,
{$IfDef Debugging}
  pCodeDebugger,
{$EndIf}  
  InterpIV, Misc, MyUtils, {FilerSettingsUnit,} pCodeDebugger_Decl,
  DebuggerSettingsUnit, Interp_Common, PsysUnit, FilerSettingsUnit;

{ TBreakInfo }

procedure TBreakInfo.Assign(Source: TPersistent);
var
  Src: TBreakInfo;
begin
  Src            := Source as TBreakInfo;

  fBreakKind     := Src.fBreakKind;
  fTgtIPC        := Src.fTgtIPC;
  fSegmentName   := Src.fSegmentName;
  fTgtProc       := Src.fTgtProc;
  fComment       := Src.fComment;
  fDisabled      := Src.fDisabled;
  fLowAddr       := Src.fLowAddr;
  fNrBytes       := Src.fNrBytes;
  fWatchType     := Src.fWatchType;
  fPassCount     := Src.fPassCount;
  fLogMessage    := Src.fLogMessage;
  fDoNotBreak    := Src.fDoNotBreak;
  fIndirect      := Src.fIndirect;
  fLogToAFile    := Src.fLogToAFile;
  fParam         := Src.fParam;
  fBreakPointDatabaseName := Src.fBreakPointDatabaseName;
  fLogMessage    := Src.fLogMessage;
  fLogToAFile    := Src.fLogToAFile;
  fAddrExpression := Src.fAddrExpression;
end;

function TBreakInfo.CalcCheckSum(Bytes: TMemAsBytesPtr): word;
var
  i: word;
  LowAddr: word;
begin
  result := 0;
  if fBreakKind = dbMemChanged then
    begin
      LowAddr :=  frmPCodeDebugger.WatchAddrFromExpression(AddrExpr);
      for i := 0 to NrBytes-1 do
        result := result XOR Bytes[LowAddr + i];
    end;
end;

procedure TBreakInfo.CloseLogFile;
begin
  with Collection as TBreakList do
    CloseLogFile;
end;

constructor TBreakInfo.Create(Collection: TCollection);
begin
  inherited;
end;

destructor TBreakInfo.Destroy;
begin
  if fLogMessage and fLogToAFile and fLogFileOpen then
    CloseLogFile;

  inherited;
end;

function TBreakInfo.GetDisabled: boolean;
begin
  result := fDisabled;
end;

function TBreakInfo.GetLoggingToAFile: boolean;
begin
  with Collection as TBreakList do
    result := fLoggingToAFile;
end;

function TBreakInfo.GetSegmentName: string;
begin
  result := fSegmentName;
end;

function TBreakInfo.GetSegNameIdx: TSegNameIdx;
var
  Idx: integer;
begin
  if fSegNameIdx <= 0 then
    begin
      Idx :=  SegNamesInDB.IndexOf(fSegmentName);
      if Idx >= 0 then
        fSegNameIdx := TSegNameIdx(SegNamesInDB.Objects[Idx]);
    end;
  result := fSegNameIdx;
end;


function TBreakInfo.LowAddr: word;
begin
  result :=  frmPCodeDebugger.WatchAddrFromExpression(AddrExpr);
end;

function TBreakInfo.MemoryChanged(Bytes: TMemAsBytesPtr): boolean;
begin
  result := fCheckSum <> CalcCheckSum(Bytes);
  if result then
    with Collection as TBreakList do
      with fOwner as TDEBUGGERSettings do
        ChangedMemBreak := Index;
end;

procedure TBreakInfo.OpenLogFile;
begin
  with Collection as TBreakList do
    LogFileOpen := true;
end;

(*
procedure TBreakInfo.SetBreakPointDatabaseName(const Value: string);
begin
  fBreakPointDatabaseName := Value;
end;
*)

(*
procedure TBreakInfo.SetLowAddr(const Value: longword);
begin
  fLowAddr := Value;
end;
*)

procedure TBreakInfo.SetBreakKind(const Value: TBrk);
begin
  fBreakKind := Value;
end;

procedure TBreakInfo.SetDisabled(const Value: boolean);
begin
  fDisabled := Value;
end;

procedure TBreakInfo.SetSegmentName(const Value: string);
begin
  fSegmentName := Value;
  fSegNameIdx  := -1;    // force it to be recalculated
end;

{ TBreakList }

function TBreakList.Add: TBreakInfo;
begin
  Result := TBreakInfo(inherited Add);
end;

procedure TBreakList.AddBreak(aTgtProc, aTargetIPC: word; aBreak: TBrk;
  aSegNameIdx: TSegNameIdx);
begin
  if not BreakAlreadyExists(aTgtProc, aTargetIPC, aBreak, aSegNameIdx) then
    with gDebuggerSettings do
      with Brks.Add as TBreakInfo do
        begin
          TgtProc := aTgtProc;
          TgtIPC  := aTargetIPC;
          Brk     := aBreak;
          SegName := SegNamesInDB[aSegNameIdx];
          SegNameIdx := aSegNameIdx;
        end;
end;


function TBreakList.BreakAlreadyExists(aTgtProc, aTargetIPC: word; aBreak: TBrk; aSegNameIdx: TSegNameIdx): boolean;
begin
  result := IndexOf(aTgtProc, aTargetIPC, aBreak, aSegNameIdx) >= 0;
end;

constructor TBreakList.Create(AOwner: TPersistent);
begin
  inherited Create(TBreakInfo);
  fOwner := aOwner;
end;

function TBreakList.GetItem(Index: Integer): TBreakInfo;
begin
  Result := TBreakInfo(inherited GetItem(Index));
end;

function TBreakList.GetOwner: TPersistent;
begin
  result := fOwner as TPersistent;
end;

function TBreakList.IndexOf( aTgtProc, aTargetIPC: integer;
                             aBreak: TBrk;
                             aSegNameIdx: TSegNameIdx): integer;
var
  i: integer;
begin
  result := -1;
  with gDebuggerSettings do
    for i := 0 to Brks.Count-1 do
      with Brks.Items[i] as TBreakInfo do
        if  (TgtProc = aTgtProc) and
            (TgtIPC  = aTargetIPC) and
            (Brk     = aBreak) and
            (SegName = SegNamesInDB[aSegNameIdx]) then
              begin
                result := i;
                Exit;  // with true result
              end;
end;


procedure TBreakList.InitBreaks(Bytes: TMemAsBytesPtr);
var
  i: integer;
  BreakInfo: TBreakInfo;
begin
  with gDebuggerSettings do
    for i := 0 to Brks.Count-1 do
      begin
        BreakInfo := Brks.Items[i] as TBreakInfo;
        with BreakInfo do
          begin
            if Brk = dbMemChanged then
              CheckSum := CalcCheckSum(Bytes);
            if fLogToAFile then
              OpenLogFile;
          end;
    end;
end;

function TBreakList.GetLogFileName: string;
begin
  if Empty(fLogFileName) then
    begin
      fLogFileName := FilerSettings.LogFileName;
      AlertFmt('Debugger Log File name set to: %s', [fLogFileName]);
    end;
  result := fLogFileName;
end;

function TBreakList.GetLogFileOpen: boolean;
begin
  result := fLoggingToAFile;
end;

procedure TBreakList.SetLogFileOpen(const Value: boolean);
begin
  if Value then            // we want to be logging to the LogFile
    if LoggingToAFile then // we already are
      { }                  // so we don't need to be doing anything differently
    else                   // file is not open, so open it
      OpenLogFile
  else                     // value = false -  we want to stop logging
    if LoggingToAFile then  // we are actually logging
      CloseLogFile
    else
      { We don't want to be logging and we currently are not };
end;

{ TWatchList }

function TWatchList.Add: TWatchItem;
begin
  Result := TWatchItem(inherited Add);
end;

constructor TWatchList.Create(aOwner: TPersistent);
begin
  inherited Create(TWatchItem);
  fOwner := aOwner;
end;

function TWatchList.GetItem(Index: Integer): TWatchItem;
begin
  Result := TWatchItem(inherited GetItem(Index));
end;

function TWatchList.Insert(Index: Integer): TWatchItem;
begin
  Result := TWatchItem(inherited Insert(Index));
end;

procedure TWatchList.SetItem(Index: Integer; Value: TWatchItem);
begin
  inherited SetItem(Index, Value);
end;

function WatchCodeFromWatchType(WatchType: TWatchType): TWatchCode;
begin
  result := WatchTypesTable[WatchType].WatchCode;
end;

function WatchTypeFromWatchCode(wc: TWatchCode): TWatchType;
var
  wt: TWatchType;
begin
  result := wt_Unknown;
  for wt := Low(TWatchType) to High(TWatchType) do
    with WatchTypesTable[wt] do
      if WatchCode = wc then
        begin
          result := wt;
          Exit;
        end;
end;

{ TWatchItem }

procedure TWatchItem.Assign(Source: TPersistent);
var
  Src: TWatchItem;
begin
  Src := Source as TWatchItem;

  fWatchType     := Src.fWatchType;
  fWatchParam    := Src.fWatchParam;
  fWatchComment  := Src.fWatchComment;
  fWatchName     := Src.fWatchName;
  fWatchAddrExpr := Src.fWatchAddrExpr;
  fWatchIndirect := Src.fWatchIndirect;
  fParam         := Src.fWatchParam;
  fLogtoAFile    := Src.fLogToAFile;
end;

function TWatchItem.GetWatchAddr: longword;
begin
{$IfDef Debugging}
  Result := frmPCodeDebugger.WatchAddrFromExpression(WatchAddrExpr);
{$else}
  Result := 0;
{$EndIf}
end;

function TWatchItem.WatchValue(Interpreter: TObject): string;
begin
{$IfDef Debugging}
  with Interpreter as TCustomPsystemInterpreter do
    if WatchIndirect then
      result := MemDumpDW(WordAt[WatchAddr], WatchType, WatchParam)
    else
      result := MemDumpDW(WatchAddr, WatchType, WatchParam);
{$else}
  result := '';
{$EndIf}
end;

function FaultTypeStr(fault_type: integer): string;
begin
  if (Fault_Type >= Low(TFaultTypes)) and (Fault_Type <= High(TFaultTypes)) then
    result := FaultTypes[Fault_Type]
  else
    result := Format('BAD VALUE: %d', [fault_type]);
end;

function PrefixInfo(Prefix: string; Addr: longword; const note: string = ''): string;
begin
  result := Format('%s%s @ %s: ', [Note, Prefix, Bothways(Addr)])
end;

function ProcNamesF(SegNameIdx: TSegNameIdx; ProcNum: integer): string;
begin
  if (SegNameIdx < sn_Unknown) or (SegNameIdx >= MAX_SEGNAMES) then
    result := Format('Invalid SegNameIdx: %d', [SegNameIdx]) else
  if ProcNum >= MAXPROCNAME then
    result := Format('Inalid ProcNum: %d', [ProcNum])
  else
    result := ProcNamesInDB[SegNameIdx, ProcNum];
end;

function SegNamesF(SegNameIdx: TSegNameIdx): string;
begin
  if (SegNameIdx < sn_Unknown) or (SegNameIdx >= MAX_SEGNAMES) then
    result := Format('Invalid SegNameIdx: %d', [SegNameIdx])
  else
    result := SegNamesInDB[SegNameIdx];
end;

function MachTypeToStr(m_type: TMTypes): string;
begin
  if (m_Type >= Low(TMTypes)) and (m_Type <= High(TMTypes)) then
    result := processor_types[m_type]
  else
    result := 'BAD m_type';
end;

{ TSegNamesList }

constructor TSegNamesList.Create;
begin
  inherited Create;
end;

function TSegNamesList.GetName(Index: Integer): string;
var
  Idx: integer;
begin
  Idx    := IndexOfObject(TObject(Index));
  if Idx >= 0 then
    result := inherited Strings[Idx]
  else
    result := CUNKNOWN;
end;

function TBreakList.Insert(Index: Integer): TBreakInfo;
begin
  Result := TBreakInfo(inherited Insert(Index));
end;

procedure TBreakList.OpenLogFile;
begin
{$I+}
  if not fLoggingToAFile then
    begin
      if fLogFileRefCount = 0 then
        begin
          try
            Rewrite(fLogFile, LogFileName);
            WriteLn(LogFile,  'DbgCnt', ',',
                                'RelIPC', ',',    { IPC }
                                'SegName', ',',
                                'ProcNum', ',',
                                'ProcName', ',',
                                'OpCode', ',',
                                'OpName', ',',
                                'Value');
            MessageFmt('Logging to file: %s', [LogFileName]);
          except
            on e:Exception do
              AlertFmt('IO Error when opening "%s: (%s)', [LogFileName, e.Message]);
          end;
          fLoggingToAFile := true;
        end;
    end;
  inc(fLogFileRefCount);
{$I-}
end;

procedure TBreakList.CloseLogFile;
var
  bn: integer;
begin
  if fLoggingToAFile then
    begin
      if fLogFileRefCount > 0 then
        Dec(fLogFileRefCount);

      if fLogFileRefCount <= 0 then
        begin
          CloseFile(fLogFile);
          fLoggingToAFile := false;
          for bn := 0 to Count-1 do
            (Items[bn] as TBreakInfo).fLogFileOpen := false;

          if YesFmt('Log file "%s" was just closed. Open it?', [LogFileName]) then
            if not ExecAndWait(LogFileName, '', false) then
              AlertFmt('Could not edit "%s"', [LogFileName]);
        end;
    end;
end;



procedure TBreakList.SetItem(Index: Integer; Value: TBreakInfo);
begin
  inherited SetItem(Index, Value);
end;

initialization
finalization
end.
