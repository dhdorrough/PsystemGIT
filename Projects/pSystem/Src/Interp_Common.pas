unit Interp_Common;

interface

uses
  Interp_Decl, StdCtrls, pSysVolumes, Classes, pSysWindow,
{$IfDef debugging}
  Debug_Decl, Watch_Decl, pCodeDebugger_Decl, pCodeDecoderUnit,
{$EndIf}
  OpsTables, Interp_Const, LoadVersion{, CRTUnit};

const
  MAXHIST = 20;
  MAX_WORDS_IN_A_LONG = 12;  // MAXUNIONS * (SizeOF(INT64) div 2)
  cPSYSTEM_WINDOW_NAME = 'p-System';

type

  TQuoteBit = function {Name}(BitNr: word): string;

  TCustomPsystemInterpreter = class(Tobject)
  private
//  fSP          : word;
    fVersionNr   : TVersionNr;
    fBootParams  : TBootParams;
    procedure SetWord_Memory(const Value: boolean);
  protected
    UBLK           : WORD;                // BLOCK # FOR DISK IO.
    UBUF           : longword;            // USER'S BUFFER ADDRESS
    UCTL           : WORD;                // FLAGS (CONTROL WORD).
    ULEN           : WORD;                // LENGTH OF USER'S BUFFER.
    UREQ           : BYTE;                // HAS BITS FOR CURRENT OPERATION (RD,WRT)
    UNUM           : BYTE;                // SET TO LUN OF OPERATION (LOGICAL UNIT #)

    fBootUnit      : integer;
    fErrCode       : word;
    fFiler         : TObject;
//  fIsDebugging   : boolean;
    BootVolume     : TVolume;
    fCurProc       : integer;
    fDecodeToMemDump: TObject;
    fIDList        : TIDList;
    fLEGAL_UNITS   : TUnitsRange;
    fMemo          : TMemo;
    fOpCode        : integer;
    fOpsTable      : TCustomOpsTable;
{$IfDef debugging}
    fpCodeDecoder  : TpCodeDecoder;
{$EndIf}
//  UNITBL         : array[0..MAX_STANDARD_UNIT] of TUnitInfo;
    ProcBaseSave   : word;    // (ditto)
    xfWord_Memory  : boolean;
    fSyscomAddr    : longword;

    function GetSP: longword; virtual; abstract;
    procedure SetSP(const Value: longword); virtual; abstract;
    Procedure POP(Var x:word); overload; virtual;
    procedure POP(var x: TRealUnion); overload; virtual;
    function  POP: word; overload; virtual;
    Procedure PUSH(X: word); overload; virtual;
    procedure PUSH(X: boolean); overload; virtual;
    procedure PUSH(X: TRealUnion); overload; virtual;

    procedure DecopsMain(InitializationProc, FinalizationProc: TSetupProc);
    CLASS function GetLEGAL_UNITS: TUnitsRange; virtual; abstract;
    function GetCREALSIZE: integer; virtual; abstract;
    function GetAbsIPC: longword; virtual; abstract;
    procedure SetAbsIPC(value: longword); virtual; abstract;
//  function GetSegNum: TSegNameIdx; virtual; abstract;
    function GetSegNum: integer; virtual; abstract;
    function GetNextOpCode: byte; virtual; abstract;
{$IfDef debugging}
    function ByteFormat(Addr: longword; Param: word): string;
    procedure CheckForBreak(var TheBrkKind: TBrk; var BrkNo: integer); virtual;
    function DateFormat(Addr: longword): string;
    function DirEntryFormat(Addr: longword): string;
    function DumpSet(Addr: longword; WordCount: word; QuoteBit: TQuoteBit): string;
    function FormattedHistory(Param: integer = MAXHIST{# of entries to list}): string;
    function GetpCodeDecoder: TpCodeDecoder; virtual; abstract;
    function HexWordsFormat(Addr: longword; nrb: word): string;
    function LongIntegerFormat(Addr: longword): string;
    procedure OldDebugger(var TheBrkKind: TBrk; CURPROC, RelIPC: integer; var BrkNo: integer); virtual;
    function RealFormat(Addr: longword): string;
    function StringFormat(Addr: longword): string;
    function VolInfoFormat(Addr: longword): string;

    property pCodeDecoder: TpCodeDecoder
             read GetpCodeDecoder
             write fpCodeDecoder;
{$EndIf}
    function PopL(nwords: integer): TDecopsUnion;
    procedure PushL(nwords: integer; Value: TDecopsUnion);
    procedure FillHighWords(var Operand: TDecopsUnion; LowWordCount: word);
    function Fetch: TBrk; virtual; abstract;
    function GetGlobVar: longword; virtual; abstract;
    procedure SetJTAB(const Value: word); virtual; abstract;
    function GetLocalVar: longword; virtual; abstract;
    function GetOp: Word; virtual; abstract;
    function GetOpsTableClass: TOpsTableClass; virtual; abstract;
    function GetSegBase: longword; virtual; abstract;
    procedure SetOp(const Value: Word); virtual; abstract;
    function  GetOpsTable: TCustomOpsTable; virtual;
    procedure SetGlobVar(const Value: longword); virtual; abstract;
    procedure SetLocalVar(const Value: longword); virtual; abstract;
    procedure GetInterpMemory; virtual; abstract;
    function GetRelIPC: word; virtual; abstract;
    procedure SetRelIPC(value: word); virtual; abstract;
    procedure SetIPC(const Value: word); virtual; abstract;
    function GetMaxVolumeNr: integer; virtual; abstract;
    function GetProcBase: longword; virtual; abstract;
    procedure SetProcBase(const Value: longword); virtual; abstract;
    procedure InitJumpTable(InterpreterOpsTable: TCustomOpsTable); virtual; abstract;
    function GetWordAt(P: longword): word; virtual;
    procedure SetWordAt(P: longword; const Value: word); virtual;
    procedure InitIDTable; virtual; abstract;
    procedure SYSRD( unitnumber: word; start: longword; len, block : word); virtual;
    procedure PutIOResult(value: integer); virtual; abstract;
    procedure WriteLong; virtual;
    function GetPoolOutside: boolean; virtual;
    function GetSyscomAddr: longword; virtual;
    procedure SetSyscomAddr(const Value: longword); virtual;

  public
    BreakPtNr      : integer;
    Bytes          : TMemAsBytesPtr;  { access memory as bytes }
    Words          : TMemAsWordsPtr;  { access memory as words }
    DbgCnt         : longint;
    fVolumesList   : TVolumesList;
    EnableExternalPool: boolean;
    frmPSysWindow  : TfrmPSysWindow;
    UNITBL         : array[0..MAX_STANDARD_UNIT] of TUnitInfo;

    function ByteIndexed(Addr: longword): longword; virtual;
    function WordIndexed(Addr: longword; offset: integer): longword; virtual;
{$IfDef debugging}
    function Single_Step: TBrk; virtual;
    function SegBot0: longword; virtual;
{$EndIf}
    function Run_PSystem: TBrk; virtual;
    property OpsTable: TCustomOpsTable
             read GetOpsTable;
    property OpsTableClass: TOpsTableClass
             read GetOpsTableClass;
    property BootParams: TBootParams
             read fBootParams;

    Constructor Create( aOwner: TComponent;
                        VolumesList   : TVolumesList;
                        thePSysWindow : TfrmPSysWindow;
                        Memo: TMemo;
                        TheVersionNr: TVersionNr;
                        TheBootParams: TBootParams); {reintroduce;} virtual;
    Destructor Destroy; override;

    procedure DebugMessage(const msg: string; Wait: boolean = false);
    procedure DebugMessageFmt(const msg: string; Args: array of const; Wait: boolean = false);
    function  GetJTAB: word; virtual; abstract;
    function  GetCurProc: word; virtual; abstract;
    function  GetCPOffset: word; virtual; abstract;
    procedure SetCurProc(const Value: word); virtual;
    function  GetRealAt(P: longword): TRealUnion; virtual;
    function InterpHIMEM: longword; virtual;
    procedure Load_PSystem(UnitNr: word); virtual;
    procedure HaltPsys(const Msg: string);
    function TheVersionName: string; virtual;
{$IfDef Debugging}
    function GetLegalWatchTypes: TWatchTypesSet; virtual;
    property  LEGAL_WATCHTYPES_FOR_INTERPRETER: TWatchTypesSet
              read GetLegalWatchTypes;
    function  DecodedRange( addr: longword;
                            nrBytes: word;
                            aBaseAddr: LongWord): string; virtual;
    function  MemDumpDF( Addr: longword;
                         Form: TWatchCode = 'W';
                         Param: longint = 0;
                         const Note: string = ''): string; virtual;
    function  MemDumpDW( Addr: longword;
                         Code: TWatchType = wt_HexWords;
                         Param: longint = 0;
                         const Note: string = ''): string; virtual;
{$EndIf}
    function  CurrentSegName: string; virtual; abstract;
    Function MSCWField(MSCWAddr: word; CSType: TMSCWFieldNr): word; virtual; abstract;
    function  ProcName(MSProc: word; SegBase: longword): string; virtual; abstract;
    procedure SetRealAt(P: longword; const X: TRealUnion); virtual;
//  function SyscomAddr: longword; virtual; abstract;
    function  CalcProcBase(Addr: longword; ProcNumber: word): word; virtual;
    procedure Unimplemented(const msg: string; Wait: boolean = false);
    procedure UnTested(const msg: string = 'Untested'; Wait: boolean = TRUE);
    function SegNameFromBase(SegBase: longword): string; virtual; abstract;
    function GetStaticLink(MSCWAddr: word): word; virtual; abstract;
    function GetByteFromMemory(p: longword): byte; virtual;
    function GetWordFromMemory(p: longword): word; virtual;
    function GetBaseAddress: longword; virtual; abstract;
    function GetSegmentBaseAddress: longword; virtual; abstract;
    procedure StatusProc(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true); virtual;

    property SyscomAddr: longword
             read GetSyscomAddr
             write SetSyscomAddr; //; virtual; abstract;

    property NextOpcode: byte
             read GetNextOpCode;
    property Word_Memory: boolean
             read xfWord_Memory
             write SetWord_Memory;
    property BootUnit: integer
             read fBootUnit
             write fBootUnit;
    property CREALSIZE: integer
             read GetCREALSIZE;
    property GlobVar: longword
             read GetGlobVar
             write SetGlobVar;
    property LocalVar: longword
             read GetLocalVar
             write SetLocalVar;
    property LEGAL_UNITS: TUnitsRange
             read GetLEGAL_UNITS;
    property MAXVOLUMENR: integer
             read GetMaxVolumeNr;
    property SegBase: longword
             read GetSegBase;
    property SegNum: integer
             read GetSegNum;
    property Op: Word
             read GetOp
             write SetOp;
    property SP: longword
             read GetSP
             write SetSP;
//{$IfDef Debugging}
    property ProcBase: longword
             read GetProcBase
             write SetProcBase;
//{$endIf}
    property CurProc: word
             read GetCurProc
             write SetCurProc;
    property JTAB: word
             read GetJTAB
             write SetJTAB;
    property RealAt[P: longword]: TRealUnion
             read GetRealAt
             write SetRealAt;
    property RelIPC: word
             read GetRelIPC
             write SetRelIPC;
    property AbsIPC: longword
             read GetAbsIPC
             write SetAbsIPC;
    property VersionNr: TVersionNr
             read fVersionNr
             write fVersionNr;
    property WordAt[P: longword]: word
             read GetWordAt
             write SetWordAt;
    property PoolOutside: boolean
             read GetPoolOutside{
             write SetEnableExternalPool};
  end;

  Alpha = packed array[1..IDLEN] of char;

  function QuoteBit(BitNr: word): string;
  function NumberedBit(BitNr: word): string;

implementation

uses
  MyUtils, Misc, Variants, pSysDatesAndTimes, BitOps, pSysExceptions, SysUtils,
{$IfDef Debugging}
  DebuggerSettingsUnit,
  DecodeToMemDumpUnit,
{$EndIf}
  UCSDGlob, pSys_Decl,
  FilerMain; 

{$Include BiosConst.inc}
const
  NRBYTES = 50;

function QuoteBit(BitNr: word): string;
begin
  if (chr(BitNr) >= ' ') and (BitNr < 128) then
    result := '''' + chr(Bitnr) + ''''
  else
    result := Format('#%d', [BitNr]);
end;

function NumberedBit(BitNr: word): string;
begin
  result := IntToStr(BitNr);
end;



constructor TCustomPsystemInterpreter.Create( aOwner: TComponent;
                                              VolumesList: TVolumesList;
                                              thePSysWindow: TfrmPSysWindow;
                                              Memo: TMemo;
                                              TheVersionNr: TVersionNr;
                                              TheBootParams: TBootParams);
begin
  inherited Create;

  VersionNr      := TheVersionNr;
  fBootParams    := TheBootParams;
  fVolumesList   := VolumesList;
  frmPSysWindow  := thePSysWindow;
  fFiler         := aOwner;
  fMemo          := Memo;

  InitIDTable;    // Init compiler symbols for TREESEARCH
end;

procedure TCustomPsystemInterpreter.DebugMessage(const msg: string; Wait: boolean);
var
  BetterMessage: string;
begin
{$IfDef Debugging}
  BetterMessage := Format('%s: P#%s O#%d',
                          [Msg,
                           ProcName(CurProc, SegBase),
                           RelIPC-1]);
  if Wait then
    Alert(BetterMessage)
  else
    StatusProc(Msg);
{$else}
  BetterMessage := Format('S#%d, P#%d, I#%d: %s',
                          [SegNum, CurProc, RelIPC, Msg]);
  raise Exception.Create(BetterMessage);
{$EndIf}
end;

procedure TCustomPsystemInterpreter.DebugMessageFmt(const msg: string;
  Args: array of const; Wait: boolean);
begin
{$IfDef Debugging}
  AlertFmt(Msg, Args);
{$else}
  raise Exception.CreateFmt(Msg, Args);
{$EndIf}
end;

destructor TCustomPsystemInterpreter.Destroy;
var
  u: integer;
begin
  for u := 0 to Length(UNITBL)-1 do
    with UNITBL[U] do
      if Assigned(Driver) and (Driver.Owner = self) then
        FreeAndNil(Driver);

  FreeAndNil(fOpsTable);

  FreeAndNil(fIDList);

{$IfDef Debugging}
  frmPCodeDebugger.CloseDebugUnit;
  FreeAndNil(fDecodeToMemDump);
{$endIf}

  Dispose(Bytes);

  inherited;
end;

function TCustomPsystemInterpreter.GetWordAt(P: longword): word;
begin  // assumes little endian
  if not Odd(p) then
    result := Words[p shr 1]
  else
    raise EOddAddress.CreateFmt('GetWordAt passed an ODD address: $%4.4x', [p]);
end;

procedure TCustomPsystemInterpreter.SetWordAt(P: longword; const Value: word);
begin
  if not odd(p) then
    Words[p shr 1] := Value
  else
    raise Exception.Create(Format('SetWordAt passed an ODD address: $%4.4x', [p]));
end;

procedure TCustomPsystemInterpreter.Unimplemented(const msg: string;
  Wait: boolean);
var
  temp: string;
begin
  Temp := 'Unimplemented: ' + Msg;
  if Wait then
    Alert(Temp)
  else
    StatusProc(Temp);
end;

procedure TCustomPsystemInterpreter.UnTested(const msg: string;
  Wait: boolean);
begin
{$IfDef Debugging}
  DebugMessage('UnTested: ' + Msg, Wait);
{$else}
  raise Exception.Create('Untested');
{$EndIf}
end;

procedure TCustomPsystemInterpreter.SYSRD( unitnumber: word; start: longword; len, block : word);
begin
(*
  OutputDebugStringFmt('SysRd: UnitNumber=%d, Addr=%4.4x, Len=%d, Block=%d',
                       [UnitNumber, Start, Len, Block]);
*)
  with fVolumesList[UnitNumber].TheVolume do
    PartialBlockReadRel(Bytes[start], Len, Block);
end;

// This version can be best used when debugging at the Delphi level

  function TCustomPsystemInterpreter.ByteIndexed(Addr: longword): longword;
  begin
    if Word_Memory then
      result := Addr * 2
    else
      result := Addr;
  end;

  function TCustomPsystemInterpreter.WordIndexed(Addr: longword; offset: integer): longword;
  begin
  {$R-}
    if Word_Memory then
      result := Addr + Offset
    else
      result := Addr + (2 * Offset);
  {$R+}
  end;

{$IfDef Debugging}

  function TCustomPsystemInterpreter.DumpSet( Addr: longword { expected to be a word address };
                                              WordCount: word;
                                              QuoteBit: TQuoteBit): string;
  var
    i: integer;
    WordSet: array of word;
    bit: word;
    Element: string;
    SetAdj: string[5];

    function BitIsSet(Bit: word): boolean;
    var
      BitNr, WordNr: byte;
    begin
      BitNr     := bit mod 16;
      WordNr    := bit div 16;
      result    := Bits(WordSet[WordNr], BitNr, 1) = 1
    end;

    function BitSpan(var Bit, LowBit, HighBit: word): boolean;
    var
      b: word;
    begin
      b := bit;
      LowBit := b;
      repeat
        inc(b);
      until (b >= (WordCount * 16)) or (not BitIsSet(b));

      if b > (LowBit + 1) then
        begin
          HighBit := b - 1;
          Bit     := HighBit;
        end
      else
        begin
          Bit     := LowBit;
          HighBit := LowBit;
        end;
      result := HighBit > LowBit;
    end;

    function GetElement(var Bit: word): string;
    var
      LowBit, HighBit: word;
    begin
      if BitSpan(Bit, LowBit, HighBit) then
        result := QuoteBit(LowBit) + '..' + QuoteBit(HighBit)
      else
        result := QuoteBit(bit);
    end;

  begin { DumpSet }
    result := '';
    SetAdj := 'Set+0';
    if WordCount = 0 then
      begin
        WordCount := WordAt[Addr];
        Addr      := WordIndexed(Addr, 1);
        SetAdj    := 'Set+2';
      end;

    if WordCount <= 256 then
      begin
        if WordCount > 0 then
          begin
            SetLength(WordSet, WordCount);
            for i := 0 to WordCount-1 do
              WordSet[i] := WordAt[WordIndexed(Addr, i)];

            bit := 0;
            repeat
              if BitIsSet(Bit) then
                begin
                  Element := GetElement(Bit);

                  if result = '' then
                    result := Element
                  else
                    result := result + ',' + Element;
                end;

              inc(bit);
            until bit >= (WordCount * 16);
          end;
        result := PrefixInfo(SetAdj, Addr) + Format('%d words: ', [WordCount]) + '[' + result + ']';
      end
    else
      result := PrefixInfo(SetAdj, Addr) + Format('is INVALID: %d words: ', [WordCount]);
  end;  { DumpSet }

  function TCustomPsystemInterpreter.DirEntryFormat(Addr: longword): string;
  var
    Dir: DirEntry;
    DateStr, TimeStr: string;
    FileDateTime: TDateTime;
    aDFKind: word;
  begin { DirEntryFormat }
    Move(Bytes[Addr], Dir, SizeOf(DirEntry));
    with Dir do
      begin
//      aDFKind := DFKind and $FFF0;   // Why was I doing this?
        aDFKind := DFKind and $000F;
        if aDFKind <> 0 then
          TimeStr := Format('%2d:%2d', [HourOf(DFKind), MinutesOf(DFKind)])
        else
          TimeStr := '00:00';

        result := Format('DFirstBlk=%d, DLastBlk=%d, DFKind=%d, Time=%s', [DFIRSTBLK, DLASTBLK, DFKIND and $F, TimeStr]);
        case aDFKind of
          kSECUREDIR,
          kUNTYPEDFILE:
            begin
              FileDateTime := DAccessToTDateTime(DLASTBOOT, DFKIND);
              DateStr      := DateTimeToStr(FileDateTime);
              result := result + Format(', DVID=%s, DeovBlk=%d, DNumFiles=%d, DLASTBOOT=%S',
                                                  [DVID, DLASTBLK, DNUMFILES, DateStr]);
            end
          else
            begin
              FileDateTime := DAccessToTDateTime(DACCESS, DFKIND);
              DateStr      := DateTimeToStr(FileDateTime);
              result := result + Format(', DTID=%s, DLASTBYTE=%d, DACCESS=%s', [DTID, DLASTBYTE, DateStr]);
            end;
        end;
      end;
  end;  { DirEntryFormat }

  function TCustomPsystemInterpreter.ByteFormat(Addr: longword; Param: word): string;
  var
    Nrb, i: word;
    b: byte;
  begin
    Nrb    := IIF(Param <> 0, Param, NRBYTES);

    for i := 0 to Nrb-1 do
      begin
        b := Bytes[Addr+i];
        result := result + ' ' + HexByte(B)
      end;
  end;

  function TCustomPsystemInterpreter.HexWordsFormat(Addr: longword; nrb: word): string;
  var
    i: word;
    u: TUnion;
  begin
    i := 0;
    result := '';
    while (i < Nrb) and (Addr+i < InterpHIMEM) do
      begin
        u.l := Bytes[Addr+i];
        i := i + 1;
        u.h := Bytes[Addr+i];
        i := i + 1;
        result := result + ' ' + HexWord(u.W);
      end;
  end;

  function TCustomPsystemInterpreter.VolInfoFormat(Addr: longword {expected to be wordindexed}): string;
  begin { VolInfoFormat }
    if Addr <> pNIL then
      with TVinfoPtr(@Bytes[ByteIndexed(Addr)])^ do
        result := result + Format('Unit=%d, VID=%s', [SegUnit, SegVID])
    else
      result := result + 'NIL';
  end;  { VolInfoFormat }

  function TCustomPsystemInterpreter.StringFormat(Addr: longword): string;
  var
    Len: integer;
    i: longword;
    ch: char;
  begin
    Len := Bytes[Addr];
    SetLength(result, Len);
    for i := 1 to Len do
      begin
        if Addr + i >= InterpHIMEM then
          break;
        ch := chr(Bytes[Addr+i]);
        if ch in [' '..#127] then
          result[i] := ch
        else
          result[i] := '?';
      end;
    result := Format('Len=%d, ''%s''', [Len, result]);
  end;

  function TCustomPsystemInterpreter.DateFormat(Addr: longword): string;
  var
    Date: TDateTime;
  begin
    Date   := DAccessToTDateTime(WordAt[Addr], 0);
    if Date > 0 then
      result := {PrefixInfo('Date', Addr) +} DateToStr(Date)
    else
      result := '??/??/??';
  end;


  function TCustomPsystemInterpreter.RealFormat(Addr: longword): string;
  var
    temp: TRealUnion;
  begin
    temp   := RealAt[Addr];
    case VersionNr of
      vn_VersionI_4, vn_VersionI_5, vn_VersionII:
        result := FloatToStr(temp.UCSDReal2);
      vn_VersionIV{, vn_VersionIV_12}:
        result := FloatToStr(temp.UCSDReal4);
      else
        raise EUnknownVersion.Create('Unknown version');
    end;
  end;

  function TCustomPsystemInterpreter.FormattedHistory(Param: integer = MAXHIST{# of entries to list}): string;
  var
    j, M1, M2, M: integer;
    aSegName, aProcName, HistItem: string;
  begin
    result := '';
    with frmPCodeDebugger as TfrmPCodeDebuggerCustom do
      begin
        M1 := HistIdx-Param+1;
        M2 := HistIdx - 1;
        M  := Min(M1, M2);
        for j := HistIdx-1 downto M-1 do  // is HistIdx-1 the last one used ?
          begin
            if j < 0 then
              break;

            with History[j] do
                begin
                  aProcName := ProcNamesInDB[SegNameIdx, ProcNr];

                  aSegName    := SegNamesInDB[SegNameIdx];
                  //   HistNr=LCDI (@ S#, P#:ProcName, O#)
                  HistItem   := Format('%d=%s (%s.%s @%d)', [HistNr, Name, aSegName, aProcName, RelIPC]);
                  if result = '' then
                    result := HistItem
                  else
                    result := result + ',' + HistItem
                end;
          end;
      end;
  end;

  function TCustomPsystemInterpreter.LongIntegerFormat(Addr: longword): string;
  var
    NrWords, wc, w: word;
    A: double;
  begin
{$R-}
    result  := '';
    NrWords := WordAt[Addr];
    A       := 0.0;
    if (NrWords > 0) and (NrWords <= MAX_WORDS_IN_A_LONG) then
      begin
        wc      := NrWords;
        while wc > 0 do
          begin
            w := WordIndexed(Addr, wc);

            A      := (A * 65536.0) + w;   // make room for it and add in the next word
            Dec(wc);
          end;
        result  := Format('%d words: %g', [NrWords, A]);
      end
    else
      result := 'Invalid long integer';
{$R+}
  end;

function TCustomPsystemInterpreter.MemDumpDF( Addr: longword;
                                              Form: TWatchCode = 'W';
                                              Param: longint = 0;
                                              const Note: string = ''): string;
var
  wt: TWatchType;
begin
  if Length(Form) > 0 then
    begin
      wt     := {DebuggerSettings.WatchList.}WatchTypeFromWatchCode(Form);
      result := MemDumpDW(Addr, wt, Param, Note);
    end
  else
    result := 'Bad format';
end;

function TCustomPsystemInterpreter.MemDumpDW( Addr: longword;
                                      Code: TWatchType = wt_HexWords;
                                      Param: longint = 0;
                                      const Note: string = ''): string;
(*
const
  NRBYTES = 50;
  MAXHIST = 20;
*)

var
  i: longword;
  b: byte;
  u: TUnion;
  Nrb: word;

(*
  function VolInfoFormat(Addr: longword): string;
  begin { VolInfoFormat }
    result := PrefixInfo('VolInfo', Addr);
    if Addr <> pNIL then
      with TVinfoPtr(@Bytes[Addr])^ do
        result := result + Format('Unit=%d, VID=%s', [SegUnit, SegVID])
    else
      result := result + 'NIL';
  end;  { VolInfoFormat }
*)

  function SocketPoolInfoS(Cap: string; SocketPoolInfo: TSocketPoolInfo): string;
  begin
    if Addr <> pNIL then
      with SocketPoolInfo do
        result := Format('%s Base=$%8.8x, Size=%d', [Cap,
                                                     FulladdressToLongWord(Base),
                                                     Size])
    else
      result := 'NIL';
  end;

  function AlphaFormat(const Seg_Name: TSegment_name): string;
  var
    SegNameStr: string[CHARS_PER_SEG_NAME];
  begin
    SetLength(SegNameStr, CHARS_PER_SEG_NAME);
    Move(Seg_Name[0], SegNameStr[1], CHARS_PER_SEG_NAME);
    result := Format('Seg_Name=%s', [SegNameStr]);
  end;

  function PedHeaderFormat(Addr: longword): string;
  begin { PedHeaderFormat }
    with TPed_headerPtr(@Bytes[Addr])^ do
      begin
        result := PrefixInfo('PedHeader', Addr) +
                  Format('ped_byte_sex=%d, ped_format_level=%d, ped_library_count=%d, ped_principal_segment_count=%d, ped_subsidiary_segment_count=%d, ped_total_evec_words=%d, ped_last_system_segment=%d, ped_start_unit=%d, ped_uses_realops_unit=%s',
                         [ped_byte_sex, ped_format_level, ped_library_count, ped_principal_segment_count, ped_subsidiary_segment_count, ped_total_evec_words, ped_last_system_segment, ped_start_unit, TFString(ped_uses_realops_unit)]);
      end;
  end; { PedHeaderFormat }

  function SegRecFormat(Addr: longword): string;

    function DecodePackedStuff(packed_stuff: word): string;
    var
      seg_num: word;                { local segment number }
      has_link_info : boolean;     { needs to be linked }
      relocatable   : boolean;     { has relocatable code }
      m_type        : TMTypes;     { machine type }
      BitNr         : byte;
    begin
      BitNr         := 0;
      seg_num       := Bits(packed_stuff, BitNr, 8);
      has_link_info := Boolean(Bits(packed_stuff, BitNr, 1));
      relocatable   := Boolean(Bits(packed_stuff, BitNr, 1));
      m_type        := TMTypes(Bits(packed_stuff, BitNr, 4));
      result := Format('seg_num=%d, has_link_info=%s, relocatable=%s, m_type=%s',
                       [seg_num, TFString(has_link_info), TFString(relocatable), processor_types[m_type]]);
    end;

  begin { SegRecFormat }
    with TSegRecPtr(@Bytes[Addr])^ do
      begin
        result := PrefixInfo('SegRec', Addr) +
                    Format('seg_name=%s, right_link=%4.4x, left_link=%4.4x, seg_proc=%4.4x,seg_erec=%4.4x, code_leng=%4d, code_addr=%4.4x, vol_info=%4.4x, file_structure=%4x, %s',
                           [AlphaToStr(seg_name), right_link, left_link, seg_proc, seg_erec, code_leng, code_addr, vol_info, file_structure, DecodePackedStuff(packed_stuff)]);
        case seg_type of
          unit_seg,
          prog_Seg:
            result := result + Format(', seg_type=%s, data_size= %d, seg_ref_words=%d, max_seg_num=%d',
                                      [SegTypes[seg_type], data_size, seg_ref_words, max_seg_num]);
          proc_seg:
            result := result + Format(', seg_type=%s, host_name= %s',
                                      [SegTypes[seg_type], AlphaToStr(host_name)]);
          else
            result := result + Format(', seg_type=%d', [ord(seg_type)]);
        end;
      end;

  end;  { SegRecFormat }
(*
  function ByteFormat(Addr: longword; Param: word): string;
  var
    Nrb, i: word;
  begin
    Nrb    := IIF(Param <> 0, Param, NRBYTES);

    for i := 0 to Nrb-1 do
      begin
        b := Bytes[Addr+i];
        result := result + ' ' + HexByte(B)
      end;
  end;
*)
  function UnitTableEntryFormat(Addr: longWord; Param: word): string;

    function PackedStuff(w: word): string;
    var
      BitNr           : byte;

      UIsBlkd         : boolean;
      UIsSpecial      : boolean;
      SpecialBuf      : boolean;
      StdaMap         : boolean;
      UIsLocLocked : boolean;
    begin { PackedStuff }
      BitNr := 0;

      UIsBlkd         := Boolean(Bits(w, BitNr, 1));
      UIsSpecial      := Boolean(Bits(w, BitNr, 1));
      SpecialBuf      := Boolean(Bits(w, BitNr, 1));
      StdaMap         := Boolean(Bits(w, BitNr, 1));
                         Bits(w, BitNr, 4);         // skip over 4 bits
      UIsLocLocked    := Boolean(Bits(w, BitNr, 1));

      result := Format('UIsBlkd=%-7s, UIsSpecial=%s, SpecialBuf=%s, StdaMap=%s, UIsLocLocked=%s',
                       [TFString(UIsBlkd), TFString(UIsSpecial), TFString(SpecialBuf), TFString(StdaMap), TFString(UIsLocLocked)]);

    end;  { PackedStuff }

  begin { UnitTableEntryFormat }
    with TUTablEntryPtr(@Bytes[Addr]) ^ do
      begin
        result := PrefixInfo('UTablEntry', Addr) +
                  Format('Uvid=%-8s, %s, UEovBlk=%5d',
                         [uvid, PackedStuff(Packed_Stuff), UEovBlk]);
        if UEovBlk <> 0 then
          result := result + Format(', uphysvol=%2d, ublkoff=%4d, upvid=%-8s',
                                    [uphysvol, ublkoff, upvid]);
      end;

  end;  { UnitTableEntryFormat }

begin { MemDumpDW }
  result := '';
  try
    case Code of
      wt_Ascii,
      wt_Alpha:
        begin
          if Code = wt_Alpha then
            Param := CHARS_PER_IDENTIFIER;
          result := PrefixInfo('ASCII', Addr);
          Nrb    := IIF(Param <> 0, Param, NRBYTES);
          for i := 0 to Nrb-1 do
            begin
              if Addr < (InterpHIMEM - i) then
                begin
                  b := Bytes[Addr+i];
                  if (b > 20) and (b <= 127) then
                    result := result + Chr(B)
                  else
                    result := result + '_';
                end
              else
                break;
            end;
        end;

      wt_HexBytes:
        begin
          result := PrefixInfo('Bytes', Addr)
                    + ByteFormat(Addr, Param);
        end;

      wt_HexWords:
        begin
          result := PrefixInfo('Words', Addr);
          Nrb    := IIF(Param <> 0, Param, NRBYTES);
          result := result + HexWordsFormat(Addr, Nrb);
        end;

      wt_DecimalInteger:
        begin
          result := PrefixInfo('Decimal', Addr);
          Nrb    := IIF(Param <> 0, Param, NRBYTES);
          i := 0;
          while (i < Nrb) and (Addr+i < InterpHIMEM) do
            begin
              u.l := Bytes[Addr+i];
              i := i + 1;
              u.h := Bytes[Addr+i];
              i := i + 1;
              result := result + ' ' + IntToStr(u.i);
            end;
        end;

  //  wt_ProcedureName:
  //    result := Format('%s', [ProcName(CURPROC, Addr)]);

      wt_DirectoryEntry:
        result := PrefixInfo('DirEntry', Addr) + DirEntryFormat(Addr);

      wt_MultiWordSet:
        result := DumpSet(Addr, Param, NumberedBit);  // use ^ if indirect needed

      wt_MultiWordCharSet:
        result := DumpSet(Addr, Param, QuoteBit);

      wt_SetOfChar:
        result := DumpSet(Addr, Param, QuoteBit);

      wt_VolInfo:
        result := result + PrefixInfo('VolInfo', Addr) +
                           VolInfoFormat(Addr);

      wt_Integer:
        result := IntToStr(Integer(WordAt[Addr]));

      wt_Word:
        result := BothWays(WordAt[Addr]);

  //  wt_SegDict:
  //    result := SegDictFormat(Addr, Param);

  //  wt_SegDictP:
  //    result := SegDictformat(WordAt[Addr], Param);

      wt_DiskAddress:
        result := PrefixInfo('DiskAddress', Addr) +
                  ByteFormat(Addr, 3);

      wt_String:
        result := PrefixInfo('String', Addr) +
                  StringFormat(Addr);

      wt_boolean:
        result := PrefixInfo('Boolean', Addr) +
                  TFString(Boolean(Bytes[Addr]));

      wt_char:
        result := PrefixInfo('Char', Addr) +
                  Format('''%s''', [chr(Bytes[Addr])]);

      wt_real:
        result := PrefixInfo('Real', Addr) +
                  RealFormat(Addr);

      wt_DateRec:
        result := PrefixInfo('Date', Addr) +
                  DateFormat(Addr);

      wt_History:
        result := FormattedHistory;

      wt_LongInteger:
        result := PrefixInfo('Long Integer', Addr) +
                  LongIntegerFormat(Addr);

    end;
  except
    on e:Exception do
      result := Format('%s: Code = %s', [e.Message, WatchTypesTable[Code].WatchName]);
  end

end;  { MemDumpDW }
{$EndIf}

function TCustomPsystemInterpreter.CalcProcBase(Addr: longword;
  ProcNumber: word): word;
begin
  result := 0;
  UnImplemented('CalcProcBase');
end;

function TCustomPsystemInterpreter.GetRealAt(P: longword): TRealUnion;
begin
  result := TRealUnionPtr(@Bytes[P])^;
end;

procedure TCustomPsystemInterpreter.SetRealAt(P: longword;
  const X: TRealUnion);
begin
  TRealUnionPtr(@Bytes[P])^ := X;
end;

procedure TCustomPsystemInterpreter.Load_PSystem(UnitNr: word);
var
  aVolume: TVolume;
begin
  fBootUnit  := UnitNr;
  BootVolume := fVolumesList[fBootUnit].TheVolume;

  if Assigned(fVolumesList[fBootUnit].TheVolume) then
    begin
      for UnitNr := 1 to MAXVOLUMENR do
        if (UnitNr in LEGAL_UNITS)
            and (UnitNr <= MAX_STANDARD_UNIT)
            and Assigned(fVolumesList[UnitNr].TheVolume)
            {and (UnitNr <> fBootUnit)} then
          begin
            aVolume := fVolumesList[UnitNr].TheVolume;

            aVolume.ResetVolumeFile;
            aVolume.OnPutIOResult := self.PutIOResult;

//          aVolume.Directory[0].LastBoot := Now;
            aVolume.DI.RECTORY[0].DLASTBOOT := DateTimeToDateRec(Now); // set "current" date
            aVolume.DirectoryChanged('Load_PSystem');

            UNITBL[UnitNr].Driver  := aVolume;
            UNITBL[UnitNr].Control := ALLBIT;
          end;

      if Assigned(frmPSysWindow) then
        with frmPSysWindow do
          Caption := Format('%s (%s)', [cPSYSTEM_WINDOW_NAME, TheVersionName]);
    end
  else
    raise Exception.Create('No boot volume');
end;

{$IfDef debugging}
procedure TCustomPsystemInterpreter.CheckForBreak(var TheBrkKind: TBrk; var BrkNo: integer);
begin
  TheBrkKind := dbUnknown;
  if Assigned(frmPCodeDebugger) then
    try
(* OutputDebugStringFmt('*DbgCnt=%d, CURPROC=%d, RelIPC=%d, BrkNo=%d',
                            [DbgCnt, CurProc, RelIPC, BrkNo]); *)
      OldDebugger(TheBrkKind, CurProc, RelIPC, BrkNo);
(*      OutputDebugStringFmt(' DbgCnt=%d, CURPROC=%d, RelIPC=%d, BrkNo=%d',
                            [DbgCnt, CurProc, RelIPC, BrkNo]); *)
    except
      TheBrkKind := dbException;
    end;
end;
{$EndIf}

procedure TCustomPsystemInterpreter.StatusProc(const Msg: string; DoLog,
  DoStatus: boolean);
begin
  inherited;
  fMemo.Lines.Add(Msg)
end;

{$IfDef Debugging}
function TCustomPsystemInterpreter.Single_Step: TBrk;
var
  BrkNo: integer;
begin
  result := Fetch;
  if result = dbUnknown then
    CheckForBreak(result, BrkNo);
end;

function TCustomPsystemInterpreter.Run_PSystem: TBrk;
var
  BrkNo: integer;
begin { TCustomPsystemInterpreter.Run_PSystem }
  if Assigned(frmPCodeDebugger) then
    with frmPCodeDebugger as TfrmPCodeDebuggerCustom do
      begin
        Running(true, BrkNo);
        Repeat
          CheckForBreak(Result, BrkNo);
          if result <> dbUnknown then
            break;

          try
            result := Fetch();
            if result <> dbUnknown then
              break;
          except
            on ESYSTEMHALT do
              begin
                Running(false, BrkNo);
                raise;
              end;
          end;
        until false; { There has to be a better way to exit this loop}

        Running(false, BreakPtNr);
      end
  else
    begin
      Repeat
        try
          result := Fetch();
          if result <> dbUnknown then
            break;
        except
          on ESYSTEMHALT do
            begin
              raise;
            end;
        end;
      until false; { There has to be a better way to exit this loop}
    end;
end;  { TCustomPsystemInterpreter.Run_PSystem }

  procedure TCustomPsystemInterpreter.OldDebugger(var TheBrkKind: TBrk;
                                                      CURPROC, RelIPC: integer;
                                                  var BrkNo: integer);
  var
    bn: integer;
    Addr: word;
    aCurrentSegName: string;
    IsABreak: boolean;
    BreakInfo: TBreakInfo;
    aSegNameIdx: TSegNameIdx;
  begin { OldDebugger }
    TheBrkKind := dbUnknown;
    BrkNo      := -1;
    try
      aCurrentSegName := CurrentSegName;

      for bn := 0 to gDebuggerSettings.Brks.Count-1 do
        begin
          BreakInfo := gDebuggerSettings.Brks.Items[bn] as TBreakInfo;
          with BreakInfo do
           if not Disabled then
             begin
               IsABreak := false;

               Case Brk of
                 dbMemChanged:
                   begin
                     IsABreak := MemoryChanged(Bytes);
                     CheckSum := CalcCheckSum(Bytes);    // have to recalc or we keep breaking
                   end;

//               dbHardWired:
//                 ;

                 dbDbgCnt:
                   IsABreak := DbgCnt = Param;

                 dbOpCode:
                   IsABreak := fOpCode = Param;

                 dbBREAK:
                   begin
                     if TgtProc = ANYPROC then
                       if TgtIPC = ANYIPC then
                         IsABreak := true
                       else
                         IsABreak := RelIPC = TgtIPC
                     else
                       if TgtProc = CURPROC then
                         if TgtIPC = ANYIPC then
                           IsABreak := true
                         else
                           IsABreak := RelIPC = TgtIPC
                       else
                         if TgtProc = ANYUNSEEN then
                           with frmPCodeDebugger as TfrmPCodeDebuggerCustom do
                             begin
                               aSegNameIdx := TheSegNameIdx(SegBase);
                               if IsUnSeenProc(aSegNameIdx, CURPROC) then
                                 begin
                                   if TgtIPC = ANYIPC then
                                     IsABreak := true
                                   else
                                     IsABreak := RelIPC = TgtIPC;

                                   if IsABreak then
                                     AddSeenProc(aSegNameIdx, CURPROC)
                                 end
                             end
                         else
                           IsABreak := false;

                      if IsABreak then
                        if SegNameIdx <> sn_Unknown then // specific segment required
                          IsABreak := SameText(aCurrentSegName, SegName);
                   end;

//               dbBreakOnCall:
//                 IsABreak := fOp in CALL_OPS;
               end;

              if IsABreak then
                begin
                  BreakPtNr := bn - 1;
                  if LogMessage then
                    with frmPCodeDebugger do
                      begin
                        if WatchType <> wt_Unknown then
                          begin
                            if Indirect then
                              Addr := WordAt[WatchAddrFromExpression(AddrExpr)]
                            else
                              Addr := WatchAddrFromExpression(AddrExpr);
                              
                            with frmPCodeDebugger as TfrmPCodeDebuggerCustom do
                              begin
                                aSegNameIdx := TheSegNameIdx(SegBase);
                                AddMessage(bn, aSegNameIdx, CURPROC, RelIPC, MemDumpDW(Addr, WatchType, Param))
                              end;
                          end
                        else
                          with frmPCodeDebugger as TfrmPCodeDebuggerCustom do
                            begin
                              aSegNameIdx := TheSegNameIdx(SegBase);
                              with frmPCodeDebugger as TfrmPCodeDebuggerCustom do
                                AddMessage(bn, aSegNameIdx, CURPROC, RelIPC, Comment);
                            end;
                      end;

                 if DoNotBreak then // may be just logging it
                   TheBrkKind := dbUnknown
                 else
                   begin
                      nPassCount := nPassCount + 1;
                      if (PassCount > 0) and (nPassCount < PassCount) then  // don't break until it reaches specified nr passes
                        begin
                          TheBrkKind := dbUnknown;
                          Break;
                        end
                      else
                        begin
                          TheBrkKind := Brk;
                          Break;
                        end;
                   end;
                end;
             end;
          if TheBrkKind <> dbUnknown then
            BrkNo := BreakPtNr;
        end;
    except
        on e:Exception do
          DebugMessageFmt('%s:  DbgCnt = %0.n, CurProc = %d', [e.Message, DbgCnt * 1.0, CURPROC]);
    end;
  end;  { OldDebugger }
{$EndIf}

{$IfNDef Debugging}
function TCustomPsystemInterpreter.Run_PSystem: TBrk;
begin { TIVPsystemInterpreter.Run_PSystem }
  Repeat
    try
       Fetch();
    except
      on ESYSTEMHALT do
        raise;
    end;
  until false; { There has to be a better way to exit this loop}
end;  { TIVPsystemInterpreter.Run_PSystem }
{$EndIf}

{$IfDef Debugging}
function TCustomPsystemInterpreter.DecodedRange( addr: longword;
                                                 nrBytes: word;
                                                 aBaseAddr: LongWord): string;
begin
  if not Assigned(fDecodeToMemDump) then
    begin
      fDecodeToMemdump := TDecodeToMemDump.Create(self, pCodeDecoder, aBaseAddr);
      with fDecodeToMemDump as TDecodeToMemDump do
        begin
          OnGetByte2  := GetByteFromMemory;
          OnGetWord2  := GetWordFromMemory;
//        BaseAddress := aBaseAddr;
        end;
    end;

  with fDecodeToMemDump as TDecodeToMemDump do
    Result     := PrefixInfo('Decoded', Addr) +
                  DecodedRange(addr, nrBytes, aBaseAddr);
end;
{$EndIf}


function TCustomPsystemInterpreter.GetOpsTable: TCustomOpsTable;
begin
  if not Assigned(fOpsTable) then
    begin
      fOpsTable := OpsTableClass.Create;
      InitJumpTable(fOpsTable);
    end;
  result := fOpsTable;
end;

{$IfDef debugging}
// Name:    GetLegalWatchTypes
// Purpose: returns a set of the watch types that are legal in both Version II & IV
function TCustomPsystemInterpreter.GetLegalWatchTypes: TWatchTypesSet; // common to both V2 & V4
begin
  result := [wt_Ascii, wt_HexBytes, wt_HexWords, wt_DecimalInteger,
              wt_DirectoryEntry, wt_MultiWordSet, wt_MultiWordCharSet, wt_SetOfChar,
              wt_VolInfo, wt_Integer, wt_Word, wt_DiskAddress, wt_String, wt_boolean,
              wt_char, wt_real, wt_History, wt_LongInteger];
end;
{$EndIf}

procedure TCustomPsystemInterpreter.HaltPsys(const Msg: string);
begin
{$IfDef LogRuns}          { This should be replaced with a WM_ message thingy }
  with fFiler as TfrmFiler do
    fLastError := Msg;
{$endIf}
  if Assigned(frmPSysWindow) then
    frmPSysWindow.CancelTimer;
  raise ESYSTEMHALT.Create('p-System halted: '+Msg);
end;

  procedure TCustomPsystemInterpreter.FillHighWords(var Operand: TDecopsUnion; LowWordCount: word);
  var
    i: integer;
    GoNegative: boolean;
  begin { FillHighWords }
    if LowWordCount > 0 then
      GoNegative := Operand.arr[LowWordCount-1] = $FFFF  // this is very kludgey
    else
      GoNegative := false;

    for i := LowWordCount to MAXWORDS-1 do
      if GoNegative then
        Operand.arr[i] := $ffff
      else
        Operand.arr[i] := 0;
  end;  { FillHighWords }

  function TCustomPsystemInterpreter.PopL(nwords: integer): TDecopsUnion;
  var
    i: integer;
  begin
    for i := 0 to nwords-1 do
      result.arr[i] := Pop();

    FillHighWords(result, nwords);
  end;

  procedure TCustomPsystemInterpreter.WriteLong;
  var
    FWidth : word;
    FibP   : word;
    LongI  : TDecopsUnion;
    S      : string;
    FibPtr : TFibPtr;
    Fib    : TFib;        // debugging - just want to see if we really got a FIB
  begin
    FWidth := Pop();    // user's desired field width
    LongI  := PopL(10); // get the Decops integer off of the stack (assume length is = 10, based only on observasion)
    Str(LongI.Int[0]:FWidth, S);     // WARNING: CURRENTLY USING ONLY THE LOW ORDER WORD

    // pointer to a FIB should now be on the top of the stack
    FibP   := Pop;
    FibP   := ByteIndexed(FibP);   // possibly convert word address to a byte address
    FibPtr := @Bytes[FibP];
    Fib    := FibPtr^;
  end;


  procedure TCustomPsystemInterpreter.PushL(nwords: integer; Value: TDecopsUnion);
  var
    i: integer;
  begin
    for i := nwords-1 downto 0 do
      push(Value.arr[i]);
  end;

  // WARNING: This is NOT an official p-Code!
//          For Version I.5, II it is (currently) assuming that ALL assembly language calls are
//          the DECOPS global procedure.
//
//          For version IV it assumes that the (unassigned) opcode 64 is the DECOPS opcode (which can
//          only occur by using the librarian to link in a LONGOPS.CODE which uses the PMACHINE operator
//          to generate the proper code.

//          It will NOT work on long integer values > 64 bits.
//          ALl of the OpCodes have NOT been implemented!
//
// NOTE:    Delphi stores long words this way:   0, 1, 2, 3  (least significant -> most significant)
//          p-System stores long words this way: 3, 2, 1, 0


// dhd 5/5/2022: Why is this procedure in Interp_Common?
procedure  TCustomPsystemInterpreter.DECOPSMain(InitializationProc, FinalizationProc: TSetupProc);
const
  WORDSTOSAVE = 5;
  WORDS_PER_INT64 = 4; // Sizeof(Int64) div 2
  MAXUNIONS = 3;

type
  TInt64Words = array[0..WORDS_PER_INT64-1] of word;

  TUnion = record
             case integer of
               1: (int: array[0..MAXUNIONS-1] of Int64);
               2: (arr: array[0..MAX_WORDS_IN_A_LONG-1] of word);
             end;

  TDecops = (dop_Adjust       = 0,
             dop_Add          = 2,
             dop_Subtract     = 4,
             dop_Negate       = 6,
             dop_Multiply     = 8,
             dop_divide       = 10,
             dop_longToString = 12,
             dop_TosM1ToLong  = 14,
             dop_Compare      = 16,
             dop_IntToLong    = 18,
             dop_LongToInt    = 20);

var
  OpCode  : TDecops;
  OpType  : word;
  MaxChars    : integer;
  Op1Len, Op2Len, OpResultLen  : word;
  Operand1, Operand2, OpResult: TDecopsUnion;
  NewSize, Addr: word;
  b: boolean;
  Temp: string[255];

  procedure FillHighWords(var Operand: TDecopsUnion; LowWordCount: word);
  var
    i: integer;
    GoNegative: boolean;
  begin { FillHighWords }
    if LowWordCount > 0 then
      GoNegative := Operand.arr[LowWordCount-1] = $FFFF  // this is very kludgey
    else
      GoNegative := false;

    for i := LowWordCount to MAX_WORDS_IN_A_LONG-1 do
      if GoNegative then
        Operand.arr[i] := $ffff
      else
        Operand.arr[i] := 0;
  end;  { FillHighWords }

  procedure CheckLen(OpLen: word);
  begin { CheckLen }
    if OpLen > MAX_WORDS_IN_A_LONG then
       begin
//       BP := INTOVRC;
//       raise EXEQERR.Create('DECOPS: integer overflow. OpLen = %d words', [OpLen], INTOVRC);
         fErrCode := INTOVRC;
         raise EXEQERR.CreateFmt('DECOPS: integer overflow. OpLen = %d words', [OpLen]);
       end;
  end;  { CheckLen }

  function GetOperandLength(Operand: TDecopsUnion): integer;
  var
    n: integer;
  begin { GetOperandLength }
    result := 0;
    for n := MAX_WORDS_IN_A_LONG-1 downto 0 do
      if Operand.arr[n] <> 0 then
        begin
          result := n + 1;
          exit;
        end;
  end;  { GetOperandLength }

  function LongAdd(Operand1, Operand2: TDecopsUnion): TDecopsUnion;
  var
    i, Len: integer;
    lu: TLongUnion;
  begin { LongAdd }
(*
    result.Int[0] := Operand1.int[0] + Operand2.int[0];
*)
    FillHighWords(Operand1, Op1Len);
    FillHighWords(Operand2, Op2Len);
    FillHighWords(result, 0);
    Len := Max(Op1Len, Op2Len);
    lu.lw := 0;
    for i := 0 to Len-1 do
      begin
        lu.lw := Operand1.arr[i] + Operand2.arr[i] + lu.sw[0];
        result.arr[i] := lu.sw[0];
        lu.sw[0]      := lu.sw[1];
        lu.sw[1]      := 0;
      end;
    result.arr[len] := lu.lw;
    // needs a test for overflow
  end;  { LongAdd }

  function LongSubtract(const Operand1, Operand2: TDecopsUnion): TDecopsUnion;
  begin { LongSubtract }
    FillHighWords(result, 0);
    result.Int[0] := Operand2.int[0] - Operand1.int[0];
  end;  { LongSubtract }

  function LongMultiply(const Operand1, Operand2: TDecopsUnion): TDecopsUnion;
  begin { LongMultiply }
    FillHighWords(result, 0);
    result.Int[0] := Operand1.int[0] * Operand2.int[0];
  end;  { LongMultiply }

  function LongDiv(const Operand1, Operand2: TDecopsUnion): TDecopsUnion;
  begin { LongDiv }
    FillHighWords(result, 0);
    result.Int[0] := Operand1.int[0] div Operand2.int[0];
  end;  { LongDiv }

  procedure GetOperands;
  begin
    Op1Len        := Pop();
    CheckLen(Op1Len);

    Operand1      := PopL(Op1Len);
    Op2Len        := Pop();
    CheckLen(Op2Len);

    Operand2      := PopL(Op2Len);

    FillHighWords(OpResult, 0);
  end;

begin { DECOPSMain }

  if Assigned(InitializationProc) then
    InitializationProc;

  OpCode := TDecops(POP());

  try
    case OpCode of
      dop_Adjust {0}:
        begin
          NewSize  := Pop();
          CheckLen(NewSize);
          Op1Len   := Pop();
          Operand1 := PopL(Op1Len);
          FillHighWords( Operand1, Op1Len);
          PushL(NewSize, Operand1);
        end;

      dop_Add {2}, dop_Subtract{4}, dop_Multiply{8}, dop_divide{10}:
        begin
          GetOperands;

          case Opcode of
            dop_Add:
              OpResult := LongAdd(Operand1, Operand2);

            dop_Subtract:
              OpResult := LongSubtract(Operand1, Operand2);

            dop_Multiply:
              OpResult := LongMultiply(Operand1, Operand2);

            dop_Divide:
              OpResult := LongDiv(Operand2, Operand1);
          end;

          OpResultLen   := GetOperandLength(OpResult);
          FillHighWords( OpResult, OpResultLen);

          PushL(OpResultLen, OpResult);
          Push(OpResultLen);
        end;

      dop_Compare:
        begin
          OpType := Pop();

          GetOperands;

          OpResult      := LongSubtract(Operand1, Operand2);

          b := false;
          case OpType of
            8: { returns LINT1 < LINT2 }
               b := OpResult.int[0] < 0;

            9: { returns LINT1 <= LINT2 }
               b := OpResult.int[0] <= 0;

            10: { returns LINT1 >= LINT2 }
               b := OpResult.int[0] >=0;

            11: { returns LINT1 > LINT2 }
               b := OpResult.int[0] > 0;

            12: { returns LINT1 <> LINT2 }
               b := OpResult.int[0] <> 0;

            13: { returns LINT1 = LINT2 }
               b := OpResult.int[0] = 0;
          end;

          Push(b);
        end;

      dop_Negate {6}:
        begin 
          Op1Len        := Pop();
          CheckLen(Op1Len);

          Operand1      := PopL(Op1Len);

          Operand1.int[0] := - Operand1.int[0];   // REMINDER: This code won't handle more than 64 bits
          Op1Len        := GetOperandLength(Operand1);

          PushL(Op1Len, Operand1);
          push(Op1Len);
        end;

      dop_LongToString{12}:
        begin
          MaxChars := Pop();        // max length in chars
          Addr     := Pop();        // address to store to
          Op1Len   := Pop();        // nr words in the long integer
          Operand1 := PopL(Op1Len); // get the long integer
          System.Str(Operand1.int[0], Temp);    // convert to a string
          if Length(Temp) > 0 then
            if Length(Temp) <= MaxChars then
              Move(Temp[0], Bytes[Addr], Length(Temp)+1)
            else
              begin
//              BP := S2LONGC;
//              raise EXEQERR.Create('DECOPS: string overflow. Needed = %d, Max words = %d', [Length(Temp), MaxChars], S2LONGC);
                fErrCode := S2LONGC;
                raise EXEQERR.CreateFmt('DECOPS: string overflow. Needed = %d, Max words = %d', [Length(Temp), MaxChars]);
              end;
        end;

      dop_TosM1ToLong{14}:
        begin
          Op1Len        := Pop();
          CheckLen(Op1Len);

          Operand1        := PopL(Op1Len);

          FillHighWords(Operand2, 0);
          Operand2.int[0] := Pop();
          
          PushL(1, Operand2);      // Push Operand2
          Push(1);                 // and its length

          PushL(Op1Len, Operand1); // Restore Operand1 to TOS
          Push(Op1Len);            // and its length
        end;

      dop_IntToLong{18}:
        push(1);      // set length of integer already on the stack

      dop_LongToInt{20}:
        begin
          Untested('Decops_LongToInt');
        end;

      else
        raise Exception.CreateFmt('Unexpected DECOPS operation: %d', [Ord(OpCode)]);
    end;

  finally
    if Assigned(FinalizationProc) then
      FinalizationProc;

  end;

end;  { DECOPSMain }

{$R-}
function TCustomPsystemInterpreter.POP: word;
begin
  Pop(result);
end;

procedure TCustomPsystemInterpreter.POP(var x: TRealUnion);
var
  i: word;
begin
  for i := 0 to CREALSIZE-1 do
    Pop(x.wrd[i]);
end;

procedure TCustomPsystemInterpreter.POP(var x: word);
begin
  X  := WordAt[SP];
  SP := SP + 2;
end;

procedure TCustomPsystemInterpreter.PUSH(X: TRealUnion);
var
  i: word;
begin
  for i := CREALSIZE-1 downto 0 do
    PUSH(x.wrd[i]);
end;

procedure TCustomPsystemInterpreter.PUSH(X: boolean);
begin
  push(ord(X));
end;

procedure TCustomPsystemInterpreter.PUSH(X: word);
begin
  SP := SP - 2;
  WordAt[SP] := x;
end;
{$R+}

procedure TCustomPsystemInterpreter.SetCurProc(const Value: word);
begin
  fCurProc := Value;
end;

function TCustomPsystemInterpreter.InterpHIMEM: longword;
begin
  result := $FFFE;
end;

procedure TCustomPsystemInterpreter.SetWord_Memory(const Value: boolean);
begin
  xfWord_Memory := Value;
end;

function TCustomPsystemInterpreter.GetPoolOutside: boolean;
begin
  result := false;
end;

function TCustomPsystemInterpreter.GetByteFromMemory(p: longword): byte;
begin
  result := 0;
  UnImplemented('GetByteFromMemory');
end;

function TCustomPsystemInterpreter.GetWordFromMemory(p: longword): word;
begin
  result := 0;
  UnImplemented('GetWordFromMemory');
end;

function TCustomPsystemInterpreter.GetSyscomAddr: longword;
begin
  result := fSyscomAddr;
end;

procedure TCustomPsystemInterpreter.SetSyscomAddr(const Value: longword);
begin
  fSyscomAddr := Value;
end;

{$IfDef debugging}
function TCustomPsystemInterpreter.SegBot0: longword;
begin
  result := SegBase;
end;
{$endIf}

function TCustomPsystemInterpreter.TheVersionName: string;
begin
  result := 'Unknown';
end;

end.
