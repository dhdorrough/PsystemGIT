{$Define temporary}
(*
Interp_Common.RealFormat is basing its result on the VersionNr which is incorrect.
Initialize_Interp is also making assumptions about real size (search for CREALSIZE)
*)
{$UnDef temporary}
{$UnDef ListSyscallEvents}
Unit InterpC;

interface

uses Classes,
     StdCtrls,
     Interp_Decl,
     Interp_Const,
     UCSDglbu,
     pSysVolumes,
     pSysWindow,
     OpsTables,
     Interp_Common,      
     LoadVersion,
{$IfDef Debugging}
     Debug_Decl,
     Watch_Decl,
     pCodeDecoderUnit,
     pCodeDecoderII,
{$endIf}
     Misc,
     CRTUnit,
     Forms,
     InterpII,
     UCSDInterpreter;
{$R+}

const

(*
//------ RSP CONSTANTS ----------------

INBIT   =    1;               // SET FOR INPUT
OUTBIT  =    2;               // SET FOR OUTPUT
CLRBIT  =    4;               // SET TO CLEAR
STATBIT =    8;               // SET FOR STATUS
NOECHO  =    16;              // SET FOR SYSTERM
ALLBIT  =    INBIT+OUTBIT+CLRBIT+STATBIT; // ALL ARE POSSIBLE
*)

MAX_STANDARD_UNIT = 20;   // This is what Peter Miller called MAX_UNIT

MAXBASESTACK      = 100;  // DEBUGGING

TYPE
(*
  FREEUNION = RECORD
    CASE INTEGER OF
      1: (BUF: PACKED ARRAY [0..511] OF 0..255);
      2: (DICT: SDRECORD);
    END;
*)

  TSegDict = record
    UseCount     : integer;
    // NOTE: the following values may represent either word values or byte values
    // depending on the value of Word_Memory.
    OldKp        : word;  // Is this really OldSegBottom?
    SegTop       : word;  // this is the SEGTOP
    SegBase      : word;  // And this the SEGBOTTOM?
  end;

  TBaseStackInfo = record
    TheBase      : word;
    TheBaseMp    : word;
    EntryProcNum : word;
    EntryIPC     : word;
    ExitProcNum  : word;
    ExitIPC      : word;
  end;

  TCPsystemInterpreter = class(TUCSDInterpreter)
  private
    function GetKp: word;
    procedure SetKp(const Value: word);
    procedure MemWrByte(Addr: word; Offset: integer; value: byte);
    function MemRd(Addr: word): word;
    procedure EFJ;
    procedure NFJ;
    procedure STE;
    function jump(disp: shortint): word;
    function FetchW: word;
    procedure Ret(n: byte);
    procedure LAE;
    function ExternalAddr(Offset, SegNo: word): word;
    function ProcExitIpc(JTab: word): word;
    procedure load_system(var root_unit: integer; const file_name: string);
    function StrCmp(s1, s2: word): integer;
    procedure MoveLeft(Dst, DstO, Src, SrcO, Len: word);
    procedure SetPop(var aSet: TSet);
    procedure SetPush(const aSet: TSet);
    procedure LPA1;
    procedure LPA2;
{$IfDef debugging}
    function GetByteFromMemoryBased(base, offset: word): byte;
{$EndIf}
{$IfDef temporary}
    procedure SetIpc(const Value: word);
{$EndIf}
    function GetBase: word;
    procedure SetBase(const Value: word);
    function SysComIIPtr: TSysComIIPtr;
    procedure CSPLog;
    procedure Decops;
    procedure LCA;
  private
    fIpc       : word;            // Same as RELIPC - offset within a procedure
    CurrentIpc : word; // this is probably not necessary

//------ GENERAL IO TEMPORARY VARIABLES

    SegDict   : array[0..MAXSEG2] of TSegDict;

//  Official p-Machine Registers

(*
{$IfDef temporary}
    fIPC     : word;
{$else}
    Ipc      : word;            // Same as RELIPC - offset within a procedure
{$endIf}
*)
    fIpcBase : word;            // Starting address of procedure
    fKp      : word;            // Heap_Top- SegBottom?
    Np       : word;            // HeapTop? or is it HEAP_BOT?
    fBase     : word;
    BaseMP   : word;

// Additional Bookkeeping

    Level      : integer;
    fFlag      : integer;       // true when processing an execution error

    Procedure PUSHint(x:integer);
    Procedure POPint(var x:integer); overload;
    function  PopInt: integer; overload;
//  function OverrideSysCall(var UnitNr: integer; var BlockNr: integer; var aFileName: string): integer;

    procedure ABI;
    procedure ABR;
    procedure ADI;
    procedure ADJ;
    procedure ADR;
    procedure BPT;
    procedure CBP;
    procedure ClrGDirP;
    procedure GEQ;
    procedure CGP;
    procedure CHK;
    procedure CIP;
    procedure LEQ;
    procedure CLP;
    procedure CSP;
    procedure CXP;
//  procedure CXP02;
    procedure DIF;
    procedure DoTreeSearch;
    procedure DVI;
    procedure DVR;
    procedure EQU;
    procedure EQUI;
    procedure FJP;
    procedure FLO;
    procedure FLT;
    procedure GEQI;
    procedure GRT;
    procedure GRTI;
    procedure INCR;
    procedure Init;
    procedure InitTime;
    procedure INN;
    procedure INT;
    procedure IXA;
    procedure IXP;
    procedure IXS;
    procedure LAND;
    procedure LSA;
    procedure LDA;
    procedure LDB;
    procedure LDC;
    procedure LDCI;
    procedure LDE;
    procedure LDL;
    procedure LDM;
    procedure LDO;
    procedure LDP;
    procedure LES;
    procedure LEQI;
    procedure LESI;
    procedure LLA;
    procedure LNOT;
    procedure LOD;
    procedure LOR;
    procedure MODI;
    procedure MOV;
    procedure MVB;
    procedure MPI;
    procedure MPR;
    procedure NEQ;
    procedure NEQI;
    procedure NGI;
    procedure NGR;
    procedure NOP;
    procedure pSQR;
    procedure RBP;
    procedure RNP;
    procedure SAS;
    function  ByteCmp(ba1: word; ba2: word; len: word): integer;
    function  WordCmp(wa1: word; wa2: word; len: word): integer;
    
// set operations
    procedure SetAdj(var s: TSet; Size: word);
    function  SetNeq(var Set1, Set2: TSet): boolean;
    function  set_is_improper_subset(const haystack: TSet; const needle: TSet): boolean;
    function  set_is_proper_subset(var haystack: TSet; var needle: TSet): boolean;
//
    procedure SBI;
    procedure SBR;
    function Scan(Limit: integer; opcode, Ch: Char; Addr: longword): Integer;
    procedure SGS;
{$IfDef debugging}
//  procedure ShowProcDict(a: word; ToWindow: boolean);
//  procedure ShowSegInfo;
{$EndIf}
    procedure ShowSizes;
    procedure SIND;
    procedure SLDL;
    procedure SLDO;
    procedure SQI;
    procedure SRO;
    procedure SRS;
    procedure STB;
    procedure IND;  { Was STIND }
    procedure STL;
    procedure STM;
    procedure STO;
    procedure STP;
    procedure STRI;
    procedure UCSDExit;
    procedure UJP;
    procedure UNI;
    procedure UpdateTime;
    procedure XJP;
    procedure LDCN;
    procedure LAO;
    procedure SLDC;
    function CheckSizes: Boolean;
    procedure CallIO;
    procedure InitUnitTable;
    function TreeSearch(root: longword; var node: longword; const key: Talpha): integer;
    procedure IDSEARCH;
    procedure SYSHALT;
    procedure CSPAtan;
    procedure CSPCosine;
    procedure CSPExit;
    procedure CSPExp;
    procedure CSPFLC;
    procedure CSPLoadSegMent0;
    procedure CspLoadSegment(SegNo: byte);
    procedure CSPHalt;
    procedure CSPIOCheck;
    procedure CSPLn;
//  procedure CSPTan;
    procedure CSPMark;
    procedure CSPMemAvail;
    procedure CSPMove;
    procedure CSPNew;
    procedure CSPPwrOfTen;
    procedure CSPRelease;
    procedure CSPUnloadSegment0;
    procedure CSPUnloadSegment(SegNo: byte);
    procedure CSPRound;
    procedure CSPScan;
    procedure CSPSine;
    procedure CSPSqrt;
    procedure CSPTime;
    procedure CSPTrunc;
    procedure CSPUnitClear;
    procedure CSPUnitRead;
    procedure CSPUnitReadWriteCommon(ReqBit: word);
    procedure CSPUnitWait;
    procedure CSPUnitWrite;
    procedure CSPUnitBusy;
    procedure PutIOError(Num: TIORsltWd);
    procedure CSPIOR;
//  procedure pSysWindowClosing(Sender: TObject; var Action: TCloseAction);
    function FinalException(const Msg, TheClassName: string): TBrk;

    procedure pXEQERR(Err: word);
    procedure CSPUnitStatus;
    function GetMP: word;
    procedure SetMP(const Value: word);

// stuff taken from the "C" interpreter

    function call(NewSeg: word; ProcNr: byte; static_link: word): boolean;
    function FetchB: word;
    function FetchUB: byte;
    function Intermediate(count: byte): word;
    function IntermediateAddr(Offset: word; Count: byte): longword;
    procedure load(UnitNr: word; BlockNo, MaxBlock: word; const FileName: string);
    function LocalAddr(Offset: word): longword;
    procedure MoveLeftC(Dst: word; DstO: integer; src: word; SrcO: integer; Len: integer);
    procedure PointerCheck(p: word);
    function Proc(SegTop: word; ProcNr: byte): word;
    function ProcBase(JTab: word): word;
    procedure ProcessNative(JTab: word; ProcNr: word; callingIPC: word);
    function ProcLexLevel(JTab: word): shortint;
    function SegNumber(SegTop: word): byte;
    function SegNumProc(SegTop: word): byte;
    function SelfRelPtr(Addr: word): word;
    procedure StackCheck();
    function StaticLink(NewSeg: word; ProcNo: byte): word;
    property Kp: word           // SegBottom
             read GetKp
             write SetKp;
  protected
    byte_sex  : TByte_Sex;

    Procedure PUSH(X: word); override;
    Procedure Pop(Var x: word); override;
    Procedure Pop(var b: boolean); overload;
    Procedure Pop(var s: TSet); overload;
    procedure Pop(var x: TRealUnion); override;
    function  Pop: word; override;
    procedure PUSH(X: boolean); override;
    procedure PUSH(X: TRealUnion); override;

    function GetHeapTop: word; override;
    procedure SetHeapTop(const value: word); override;
    function GetWordAt(P: longword): word; override;
    procedure SetWordAt(P: longword; const Value: word); override;
    function GetSP: longword; override;
    procedure SetSP(const Value: longword); override;
    procedure SetJTAB(const Value: word); override;
    function GetSegBase: longword; override;
    function GetAbsIPC: longword; override;
    function GetOpsTableClass: TOpsTableClass; override;
    procedure SetAbsIPC(Value: longword); override;
    function  Fetch: TBrk; override;
    function GetGlobVar: longword; override;
    procedure SetGlobVar(const Value: longword); override;
    function GetRelIPC: word; override;
    function GetLocalVar: longword; override;
    procedure SetLocalVar(const Value: longword); override;
    function GetMaxVolumeNr: integer; override;
    procedure InitJumpTable(InterpreterOpsTable: TCustomOpsTable); override;
    function GetOp: word; override;
    procedure SetOp(const Value: Word); override;
    function GetCREALSIZE: integer; override;
    procedure SYSRD( unitnumber: word; start: longword; len, block : word); override;

{$IfDef Debugging}
    function GetProcBase: longword; override;
    function GetpCodeDecoder: TpCodeDecoder; override;
    function SegIdxFromName(const aSegName: string): TSegNameIdx;
{$endIf}
    procedure InitIDTable; override;
    procedure PutIOResult(value: integer); override;
    procedure WriteLong; override;

  public
    fSP       : word;
//  FOp       : Word;          {obsolete}

    SEGBOT      : word;        {ptr to bottom of segment}

//  ByteAddress : longword;
    Flip        : boolean;
    NewSegTop   : word;   { new SEGP - points to the END+2 of the segment}
//  IpcBase     : word;            // Starting address of procedure
    SEGNUM      : word;   {segment # currently being called}
    Progname,
    OpCodes     : ARRAY [0..255] OF TOprec;
    BUF         : PACKED ARRAY [0..511] OF 0..255;
    SD          : FREEUNION;
    PD          : ARRAY [0..149] OF word{INTEGER};
    HEXDIGIT    : PACKED ARRAY [0..15] OF CHAR;
    CRtyped     : Boolean;
    ETXtyped    : Boolean;
//  ScreenWidth : Integer;  {Syscom^.miscinfo.screenwidth, usually 79 or 80}

    StartTime   : single;

    function CurrentDataSize: word;
    function  GetCurProc: word; override;
    function GetNextOpCode: byte; override;
    function GetByteFromMemory(p: longword): byte; override;
    function GetWordFromMemory(p: longword): word; override;
    function GetEnterIC(JTab: word): word; override;
    CLASS function GetLEGAL_UNITS: TUnitsRange; override;
    function GetJTAB: word; override;
    function GetStaticLink(MSCWAddr: word): word; override;
    function GlobalAddr(Offset: word): word;
    function MSCWField(MSCWAddr: word; CSType: TMSCWFieldNr): word; override;
    function ProcParamSize(JTab: word): word;
    function SegNameFromBase(SegTop: longword): string; override;
    procedure Initialize_Interp;
    procedure StatusProc(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true); override;
    function MemRdByte(Addr: word; Offset: integer): byte; override;
{$IfDef Debugging}
//  function GetSegNum: TSegNameIdx; override;
    function GetSegNum: integer; override;
    function CurrentSegName: string; override;
    function GetLegalWatchTypes: TWatchTypesSet; override;
    function MemDumpDW( Addr: longword;
                        Code: TWatchType = wt_HexWords;
                        Param: longint = 0;
                        const Msg: string = ''): string; override;
    function  MemDumpDF( Addr: longword;
                         Form: TWatchCode = 'W';
                         Param: longint = 0;
                         const Msg: string = ''): string; override;
    function  MemDumpDFWB( WordAddr: longword; ByteOffset: word;
                         Form: TWatchCode = 'W';
                         Param: longint = 0;
                         const Msg: string = ''): string;
    function  DecodedRange( addr: longword;
                            nrBytes: word;
                            aBaseAddr: LongWord): string; override;
{$EndIf debugging}
    function ProcNumber(JTab: word): shortint;
    function  ProcDataSize(JTab: word): word; override;
    function TheVersionName: string; override;

    property Mp        : word
             read GetMP
             write SetMP;
    property Base      : word
             read GetBase
             write SetBase;

    Constructor Create( aOwner: TComponent;
                        VolumesList   : TVolumesList;
                        thePSysWindow : TfrmPSysWindow;
                        Memo: TMemo;
                        TheVersionNr: TVersionNr;
                        TheBootParams: TBootParams); override;
    Destructor Destroy; Override;
    function  InterpHIMEM: longword; override; // Is always a byte address
    procedure Load_PSystem(UnitNr: word); override;
    function  ProcName(MsProc: word; aSegTop: longword): string; override;
    property VersionNr;
    property IpcBase: word
             read fIpcBase
             write fIpcBase;
    property IPC: word
             read fIPC
             write fIPC;
    function GetBaseAddress: longword; override;
  end;


const InterpVersion = '7';

implementation

uses
  SysUtils, pSysExceptions, pSys_Decl,
{$IfDef Debugging}
  pCodeDebugger_Decl,
  DebuggerSettingsUnit,
  DecodeToMemDumpUnit,
  pCodeDebugger,
{$EndIf}
  Windows,
  MyUtils, pSysDrivers, FilerSettingsUnit, PsysUnit, BitOps,
  CompilerSymbolsII, SysCommon, MiscinfoUnit, StStrL, Math, FilerMain;

const
  KP_TOP        = $FE80;  // This could either be a byte limit or a word limit depending on Word_Memory
  HEAP_BOT      = $200;
  SP_TOP        = $200;
  SYSCOM_SIZE   = 170;    // This is what Peter Miller uses

type
    segkinds =({0}LINKED,          { no work needed, executable as is }
               {1}HOSTSEG,         { PASCAL host program outer block  }
               {2}SEGPROC,         { PASCAL segment procedure, not host }
               {3}UNITSEG,         { library unit occurance/reference }
               {4}SEPRTSEG);       { library separate proc/func TLA segment }

var
  PwrOfTen: array[0..39] of single =
                ( 1e0, 1e1, 1e2, 1e3, 1e4, 1e5,
                  1e6, 1e7, 1e8, 1e9, 1e10, 1e11,
                  1e12, 1e13, 1e14, 1e15, 1e16, 1e17,
                  1e18, 1e19, 1e20, 1e21, 1e22, 1e23,
                  1e24, 1e25, 1e26, 1e27, 1e28, 1e29,
                  1e30, 1e31, 1e32, 1e33, 1e34, 1e35,
                  1e36, 1e37, 1e38, 1e39);

{$R-}   {it gets a range check error under turbo}
  {Gracefully borrowed from Tom Swan }
  {REMEMBER that Addr is already ByteIndexed <============<}
  Function TCPsystemInterpreter.Scan(Limit:integer; opcode:char; Ch:Char; Addr: longword):Integer;
  Var
    i       : Integer;
    PosScan : Boolean;
  Begin
    PosScan := Limit>0;
    i       := 0;
    While I<>Limit do
      Begin
        Case opcode of
          '=': if Bytes[Addr+i] = ord(ch) then
                 break;
          '#': if Bytes[Addr+i] <> ord(ch) then
                 break;
        End;
        Case PosScan of
          True:  i := succ(i);
          False: i := pred(i);
        End;
      end;
    result := i;
  End;
{$R+}


Procedure TCPsystemInterpreter.InitTime;
var h, m, s, s1000: word;
    h1, m1, s1, s1001: single;
Begin
  DecodeTime(Now, h, m, s, s1000);
  h1 := h;
  m1 := m;
  s1 := s;
  s1001 := s1000;
  StartTime := s1001 + s1*60 + m1*3600 + h1*3600*24;
end;

function TCPsystemInterpreter.SysComIIPtr: TSysComIIPtr;
begin
  result := TSysComIIPtr(@Bytes[ByteIndexed(SyscomAddr)]);
end;


Procedure TCPsystemInterpreter.UpdateTime;
var x:longint; 
    h, m, s, s1000: word;
    h1,m1,s1,s1001:single;
    r:single;

Begin
  DecodeTime(Now, h, m, s, s1000);
  h1    := h;
  m1    := m;
  s1    := s;
  s1001 := s1000;
  s1001 := (s1001*0.6);


  r := s1001 + s1*60 + m1*3600 + h1*3600*24;

  X := round(R);

(* following  not needed if x is absolute lotime *)
  with SysComIIPtr^ do
    begin
      lotime := integer(x and $0000FFFF){x mod 32768};
      hitime := integer((x and $FFFF0000) shr 16){x div 32768};
    end;

end;







// Idsearch(VAR retninfo: cursrange; symbufp: ^symbufarray)
//
// The following declaration order for the compiler is assumed, as IDSCH is
// passed only ^retninfo.
//    symcur: cursrange (* index into symbufarray *);
//    sy: symbol (* symbol = (ident..othersy), set by info in reswrdtable *);
//    op: operator (* more info from reswrdtable *);
//    rettok: alfa(* packed array [1..8] of char, gets filled with first 8 chars
//            of token isolated by IDSRCH *);
// NOTE: THE ABOVE VARIABLES MUST BEGIN ON WORD BOUNDARIES!
//
// Idsearch does the following:
//    Isolate token, converting to upper case, and stash in id.
//    If token in reswrdtable set sy and op from table,
//    else set sy := 0.
//    symcur is left pointing to the last char of the token
//

procedure TCPsystemInterpreter.IDSEARCH;
var
  SymBufp    : longword;
  RetnInfoP  : longword;
  SymCursor  : word;
  c          : char;
  Key        : TAlpha;  // We declare TAlpha as packed array[0..7] of char
  i          : word;
  Idx        : integer;
  sy         : TSYMBOLTypeII;
  su         : TSymbolUnion;
  op         : TOperator;
  id         : string;
  p          : TRetnInfoPtr;
  p0         : TRetnInfoPtr;
 begin
  i         := 0;
  Key       := '        ';  // adapted from Dr Laurence Boshell's version
{$R-}
  SymBufP   := ByteIndexed(Pop());    // 2ND parameter: address of SymBufP
  RetnInfoP := Pop();    // 1st Parameter: address of SymCursor

  if Word_Memory then
    p         := TRetnInfoPtr(@Words[RetnInfoP])
  else
    p         := TRetnInfoPtr(@Bytes[RetnInfoP]);
  p0          := TRetnInfoPtr(@Bytes[ByteIndexed(RetnInfoP)]);  // debugging
  Assert(p = p0, 'Invalid assumption in IDSEarch');

  SymCursor := P^.SYMCUR;
{$R+}
  c         := chr(Bytes[SymBufP+SymCursor]);
  while (c in['A'..'Z', 'a'..'z', '0'..'9', '_'])do
    begin
      If c <> '_' then   {ignore '_' for full UCSD compatibility   /tp3}
        begin
          if (i <= High(TAlpha)) then
            key[i] := UpCase(c);
          i := i + 1;
        end;

      SymCursor := SymCursor+1;

      c := chr(Bytes^[SymBufp+SymCursor]);
    end;

  {ucsd requires that symcursor points to last char of identifier}
  SymCursor := SymCursor-1;

  Idx := fIDList.IndexOf(Key);
  if Idx >= 0 then
    begin
      su.O := fIdList.Objects[idx];
      sy   := su.sy;
      op   := su.op;
      id   := fIdList[idx];
    end
  else
    begin
      sy := IDENT;
      op := NOOP;
      id := key;
    end;
(*
  WordAt[RetnInfoP]   := SymCursor;
  WordAt[RetnInfoP+2] := ord(sy);
  WordAt[RetnInfoP+4] := ord(op);
  for i := Low(Alpha) to High(Alpha) do
    Bytes[RetnInfoP+5+i] := ord(Key[i]);
*)
// Make sure that the fields of TRetnInfo begin on word boundaries!
(*
  P.SYMCUR := SymCursor;
  P.SY     := sy;
  P.OP     := Op;
  P.RETTOK := Key;
  P.fill0  := 0;      // in case old system is including at the fill bytes
  P.fill1  := 0;
*)
  P.SYMCUR := SymCursor;
  P.SY     := ord(sy);
  P.OP     := ord(Op);
  P.RETTOK := Key;
end;


Procedure TCPsystemInterpreter.pXEQERR(Err: word);
var
  NewSeg: word;
Begin
  fFlag := 0;
  NewSeg := SegDict[0].SegTop;

  if fFlag <> 0 then
    raise Exception.Create('pXeqErr: recursion');

  Inc(fFlag);

  with SysComIIPtr^ do
    begin
      XEQERR    := Err;
                                        {dhd- 9/3/2021 no idea what the +4 is}
      BOMBIPC   := CurrentIPC;

      MISCINFO  := MISCINFO or (1 shl 10);  { ? maybe trying to set no break ? }

      call(NewSeg, 2, BaseMp);  // CXP 0 2

      BOMBP     := Mp;
    end;

  Dec(fFlag);

// longjmp(ProcessNextInstrunction, 0);  // ??

end;

// ClrGDirP - clear global directory pointer
Procedure TCPsystemInterpreter.ClrGDirP;   {check global directory pointer}
Begin
  with SysComIIPtr^ do
    If GDIRP <> pNIL then
      begin
        {else release GDIRP from heap}
        HeapTop := GDIRP;   // restore heap pointer
        GDIRP   := pNIL;
      end;
end;

Procedure TCPsystemInterpreter.PUSHint(x:integer);
begin
{$R-}
  Sp := WordIndexed(Sp, - 1);   // This should probably be using MemRd and MemWr to handle byte sex issues
  WordAt[Sp] := x;
{$R+}
end;


Procedure TCPsystemInterpreter.PUSH(x: word);
begin
  Sp := WordIndexed(Sp, - 1);
  WordAt[Sp] := x;
end;

procedure TCPsystemInterpreter.PUSH(X: boolean);
begin
  push(longword(X));
end;

procedure TCPsystemInterpreter.PUSH(X: TRealUnion);
var
  i: word;
begin
  for i := CREALSIZE-1 downto 0 do
    PUSH(longword(x.wrd[i]));
end;

Procedure TCPsystemInterpreter.Pop(Var x: word);
begin
  X  := WordAt[Sp];
  Sp := WordIndexed(Sp, +1);
end;

Procedure TCPsystemInterpreter.Pop(Var b: boolean);
begin
//b := Boolean(Pop() and $0001);
  b := (Pop() and $0001) <> 0;
end;

Procedure TCPsystemInterpreter.Pop(var s: TSet);
var
  i: integer;
begin
  s.Size := Pop();
  for i := 0 to s.Size-1 do
    S.Data[i] := Pop();
end;

function TCPsystemInterpreter.Pop: word;
begin
  Pop(result);
end;

procedure TCPsystemInterpreter.Pop(var x: TRealUnion);
var
  i: word;
begin
  for i := 0 to CREALSIZE-1 do
    Pop(x.wrd[i]);

  for i := CREALSIZE to 3 do
    x.Wrd[i] := 0;
end;

Procedure TCPsystemInterpreter.POPint(Var x:integer);
{Pop integer for integer compare opcodes}
begin
{$R-}
  X  := WordAt[Sp];
  Sp := WordIndexed(Sp, +1);
{$R+}
end;

function TCPsystemInterpreter.PopInt: integer;
begin
  PopInt(result);
end;

{error stuff}

// Name:    DoTreeSearch
//          TreeSearch(rootp:^node; VAR foundp:^node; VAR target:alfa):integer;
// Returns: 0:  FoundP points to matching node
//          +1: FoundP points to a leaf, target > foundp.key
//          -1: FoundP points to a leaf, target < foundp.key
  procedure TCPsystemInterpreter.DoTreeSearch;
  var
    KeyValueAddr  : longword;
    FoundP        : longword;                // does not change
    RootAddr      : longword;
    Node          : longword;
    KeyValue      : Talpha;
    Found         : integer;
  begin
    KeyValueAddr    := Pop();  // ptr to target.
    FoundP          := Pop();  // save address for result
    RootAddr        := Pop();  // rootp
    KeyValue        := TAlpha_Ptr(@Bytes[ByteIndexed(KeyValueAddr)])^;
  {$R-}
//  WordAt[Sp]      := TreeSearch(RootAddr, node, KeyValue);  // 10/27/2021 original
    Found           := TreeSearch(RootAddr, node, KeyValue);
    PUSH(Found);
  {$R+}
    WordAt[FoundP]  := node;
  end;

// Name:    TreeSearch
// Purpose: Search a sub-tree for a paticular string
// Entry:   root - root of the sub-tree to search
//          node - node containing the string, if found
//          key = ^ string to search for
// Return:
//          -1 left link
//          0  this node
//          +1 right link
  Function TCPsystemInterpreter.TreeSearch(root: longword; var node: longword; const key: TAlpha): integer;
  var
    last: word;
    Node_Ptr: TTree_NodePtr;
  Begin
    node := root;
    Repeat
      Node_Ptr := TTree_NodePtr(@Bytes[ByteIndexed(node)]);
      last     := node;
      if key < Node_Ptr^.name then
        begin
          node   := Node_Ptr^.left_link;
          result := -1;
        end
      else
      if key > Node_Ptr^.name then
        begin
          node   := Node_Ptr^.right_link;
          result := +1;
        end
      else
        begin
          result := 0;
          exit;
        end;
    until node = pNil;
    node := last;
  end;

procedure TCPsystemInterpreter.CSPIOR;
begin
  with SysComIIPtr^ do
    begin
      push(longword(IORSLT));
//    iorslt := INOERROR;   // NOTE: NOT clearing this may be a kludge work-around only for VI.5?
                            //       According to the source code in I5Z80Interp.txt, the IORSLT is not cleared
    end;
end;


//------------------------------------------------------------------------------
// CALLIO
//       CALL A DRIVER ROUTINE
// INPUT
//       TOS = UNIT NUMBER
// OUTPUT
//       Result := IOResult // dhd 4/9/2018
//------------------------------------------------------------------------------

procedure TCPsystemInterpreter.CallIO;
var
  result: TIORsltWD;

begin { TCPsystemInterpreter.CallIO }
  UNUM := Pop();                 // get UnitNr from TOS

  result := INOUNIT;  // Assume the worst

  if UNUM < MAX_STANDARD_UNIT then
    begin
      if (UNUM > 0) and Assigned(UNITBL[UNUM].Driver) then
        with UNITBL[UNUM] do
          result := Driver.Dispatcher(UREQ, UBLK, ULEN, Bytes[UBUF], control);
    end;

  PutIOError(result);
end;  { TCPsystemInterpreter.CallIO }

procedure TCPsystemInterpreter.PutIOError(Num: TIORsltWd);
begin
  SysComIIPtr^.IORSLT := num;
end;


procedure TCPsystemInterpreter.CSPIOCheck;
begin
  with SysComIIPtr^ do
    if IORSLT <> INOERROR then
      begin
//    raise EXEQERR.Create('IO error %d', [ord(IORSLT)], UIOERRC);
      fErrCode := UIOERRC;
      raise EXEQERR.CreateFmt('IO error %d', [ord(IORSLT)]);
      end;
end;

{NEW(VAR p:^; size:integer)}
{p  := HeapTop; HeapTop := HeapTop+size of p}
procedure TCPsystemInterpreter.CSPNew;
var
  WordCount: integer;
begin
  ClrGDirP();                                                        
  WordCount     := Pop();
  WordAt[Pop()] := HeapTop;
  HeapTop       := WordIndexed(HeapTop, WordCount);
  StackCheck;
end;

procedure TCPsystemInterpreter.MoveLeftC(Dst: word; DstO: integer; Src: word; SrcO: integer; Len: integer);
begin
(* The following may be better when trying to deal with byte sex issues
  if Len > 0 then
    if Word_Memory then
      Move(Bytes[Src*2+SrcO], Bytes[Dst*2+DstO], Len)  // convert word offsets into byte offsets
    else
      Move(Bytes[Src+SrcO], Bytes[Dst+DstO], Len);
*)
  if Len > 0 then           // test may not be necessary
    Move(Bytes[ByteIndexed(Src)+SrcO], Bytes[ByteIndexed(Dst)+DstO], Len)
end;

procedure TCPsystemInterpreter.MoveLeft(Dst, DstO, Src, SrcO, Len: word);
begin
  Move(Bytes[ByteIndexed(Src)+SrcO], Bytes[ByteIndexed(Dst)+DSTO], Len);
(* The following may be better when trying to deal with byte sex issues
  while (Len > 0) do
    begin
      Dec(Len);
      MemWrByte(Dst, DstO, MemRdByte(Src, SrcO));
      Inc(DstO);
      Inc(SrcO);
    end;
*)
end;


procedure TCPsystemInterpreter.CSPMove;
var
  Dst, DstO, Src, SrcO: word;
  Len: integer;
//temp: string;
(* It appears that version I.5 has three parameters:
     Length
     ^dest
     ^source
   ---------------------
   but version II.0 appears to have five (5) parameters:
       length
       destination index
       destination base
       src index
       src base
*)
begin { CSPMove }
{$R-}
  if VersionNr < vn_VersionII then
    begin
      Len  := Pop();     {length}
      Dst  := Pop();     {^dest}       {addr2}
      Src  := Pop();     {^source}      {addr2}
      if Len > 0 then
        Move(Bytes[Src], Bytes[Dst], Len);
    end else
  if VersionNr = vn_VersionII then
    begin
      Len    := PopInt();        { length }
      DstO   := Pop();        { destination offset }
      Dst    := Pop();        { destination base }
      SrcO   := Pop();        { source offset }
      Src    := Pop();        { source base }
//    Move(Bytes[ByteIndexed(Src)+SrcO], Bytes[ByteIndexed(Dst)+DSTO], Len);
      if Len > 0 then
        MoveLeft(Dst, DstO, Src, SrcO, Len);
    end
  else
    raise Exception.Create('Invalid version Number');
{$R+}
end;  { CSPMove }

procedure TCPsystemInterpreter.CSPExit;
begin
  UcsdExit;
end;

{ UNITREAD(UNITNUMBER,ARRAY,LENGTH,[BLOCKNUMBER], [INTEGER] }
procedure TCPsystemInterpreter.CSPUnitReadWriteCommon(ReqBit: word);
var
  Offset: word;
begin
  PutIOError(INOERROR);
  try
    Pop(UCTL);    {mode: assumed=0, if 1 then async transfer}
      
    Pop(UBLK);    {block}
    Pop(ULEN);    {length}
    OffSet := 0;
    if Word_Memory {or (VersionNr = vn_VersionI_4)} then
      Pop(Offset);  {<==byte offset from addr. Not present in V1.4, V1.5}

    UBUF := Pop();    {word addr}
    UBUF := ByteIndexed(UBUF) + Offset;    // Change from word address to byte address, if necessary

    UREQ := ReqBit;
(* *)
    OutputDebugStringFmt('UCTL=%2d, UBLK=%5d, ULEN=%5d, UBUF=%4.4x, UREQ=%2d, UNUM=%5d',
                         [UCTL, UBLK, ULEN, UBUF, UREQ, WordAt[sp]]);
(* *)    
    CallIO;
  except
    PutIOError(IBADBLOCK);
  end;
end;

procedure TCPsystemInterpreter.CSPUnitStatus;
begin
  CSPUnitReadWriteCommon(STATBIT);
  // Should this be checking for just having written a segment dictionary?
end;


procedure TCPsystemInterpreter.CSPUnitRead;
var
  DictP: SDRecordPtr;
//FileName: string;
begin
  CSPUnitReadWriteCommon(INBIT);
  DictP := SDRecordPtr(@Bytes[UBUF]);    // ByteIndex has already been applied to UBUF !!
  SaveSegInfoForFile(UNUM, INTEGER(UBLK), ULEN, 'Unknown', DictP^, High(SmallInt));
end;

procedure TCPsystemInterpreter.CSPUnitWrite;
begin
  CSPUnitReadWriteCommon(OUTBIT)
end;

{the clock increments lowtime & hitime every 1/60 sec}
procedure TCPsystemInterpreter.CSPTime;
var
  LowTimeAddr, HighTimeAddr: word;
begin
{$R-}     // assigning an integer to a word could get a range check error
  UpdateTime;
  LowTimeAddr  := Pop();                          {addr2}
  HighTimeAddr := Pop();
  with SysComIIPtr^ do                         {addr2}
    begin
      WordAt[LowTimeAddr]  := LOTIME;
      WordAt[HighTimeAddr] := HITIME;
    end;
{$R+}
end;

{FLC} {fillchar(buffer:^;count:integer;ch:char);}
procedure TCPsystemInterpreter.CSPFLC;
var
  Offset, Len, Addr: word;
  ch: byte;
begin
{$R-}   // use an integer for things like moving 65536 bytes (for example)
  ch       := Pop();  {char}
  Len      := Pop();  {byte count}

  if VersionNr = vn_VersionII then
    Offset   := Pop()  {^buffer}       {version II also passes a byte offset from the address}
  else
    Offset   := 0;

  Addr     := Pop();  { get the base address for the fill }
  if Len > 0 then
    FillChar(Bytes[ByteIndexed(Addr)+Offset], Len, ch);
{$R+}
end;

procedure TCPsystemInterpreter.CSPScan;
var
  Offset    : word;
  Buf       : word;
  Match     : word;
  limit    : integer;
  ch        : char;
  CompCode  : char;
  i         : integer;
begin
  Pop();              {junk the mask.. now obsolete }

  if word_Memory then  // vn_VersionII has another parameter
    Offset   := Pop()
  else
    Offset   := 0;

  Buf      := Pop();
  ch       := CHR(Pop());
  Match    := PopInt();
  limit    := PopInt();
  case Match of
    0: compcode := '=';
    1: compcode := '#';
    else
      raise Exception.Create('scan parameter bug');
  end;
  i := Scan(limit, compcode, Ch, ByteIndexed(Buf)+Offset);
  pushint(i);
end;

procedure TCPsystemInterpreter.CSPLoadSegMent0;
begin
  CSPLoadSegment(Pop());
end;

(*
 * Load a segment.  If a data segment is to be loaded, just allocate
 * storage on the stack.
 *)
procedure TCPsystemInterpreter.CspLoadSegment(SegNo: byte);
var
  aSegUnit  : word;
  aSegBlock : word;
  aSegSize  : word;
Begin { CspLoadSegment }
  Assert(SegNo < SEG_DICT_SIZE2);
  if (SegDict[SegNo].UseCount = 0) then
    Begin
      with SysComIIPtr^.SEGTBL[SegNo] do
        begin
          aSegUnit    := CodeUnit;
          aSegBlock   := DiskAddr;
          aSegSize    := CodeLeng;       // in bytes? Yes. I think so.
        end;

      Assert(not odd(aSegSize));
      if aSegSize = 0 then
         raise ENOPROC.Create('No procedure');

      SegDict[SegNo].OldKp := Kp;        // Old SegBottom

      if Word_Memory then                // calculate new SegBottom
        Kp := Kp - (aSegSize div 2)
      else
        Kp := Kp - aSegSize;

      SegDict[SegNo].SegBase := Kp;

      if (aSegBlock <> 0) then
        Begin
          (* if a block number is specified, load a code segment. *)
          NoteSegTopChange('CspLoadSegment', 'Unknown', SegDict[SegNo].SegTop, WordIndexed(SegDict[SegNo].OldKp, -1));
          SegDict[SegNo].SegTop := WordIndexed(SegDict[SegNo].OldKp, -1);
          SysRd( aSegUnit,
                 Kp,
                 aSegSize, // SYSRD expects the length to be passed as a byte count
                 aSegBlock);
          with SysComIIPtr^ do
            if IORSLT <> INOERROR then
              begin
//              raise EXEQERR.Create('I/O error: %d', [ord(IORSLT)], SYIOERC);
                fErrCode := SYIOERC;
                raise EXEQERR.CreateFmt('I/O error: %d', [ord(IORSLT)]);
              end;
{$IfDef Debugging}
          UpdateSegInfo( SegNo,
                         SegDict[SegNo].SegTop, // NewSegTop,
                         Kp,
                         aSegSize,
                         aSegUnit,
                         aSegBlock,
                         fLatestSegNames[SegNo])
{$EndIf Debugging}
        End
      else
        Begin
          (* otherwise, it is a Data-Segment *)
          NoteSegTopChange('CspLoadSegment', 'Unknown', SegDict[SegNo].SegTop, WordIndexed(Kp, -1));
          SegDict[SegNo].SegTop := WordIndexed(Kp, -1);
        End;
    End;
  Inc(SegDict[SegNo].UseCount);
End;  { CspLoadSegment }

{Standard proc release seg}
procedure TCPsystemInterpreter.CSPUnloadSegment0;
begin
  CSPUnloadSegment(Pop());
end;

Procedure TCPsystemInterpreter.LLA;   {load local address}
Begin
  Push(LocalAddr(FetchB()));
end;

Procedure TCPsystemInterpreter.LDL;   {load local word}
Begin
  Push(WordAt[LocalAddr(FetchB())]);
end;


Procedure TCPsystemInterpreter.STL;  {store local word}
Begin
  WordAt[LocalAddr(FetchB())] := Pop();
end;

Procedure TCPsystemInterpreter.LDA; {load intermediate address}
var
  p1: word;
Begin
  p1 := FetchUB();
  Push(IntermediateAddr(FetchB(), p1));
end;

Procedure TCPsystemInterpreter.LOD; {load intermediate word}
var
  p1: word;
Begin
  p1 := FetchUB();
  Push(WordAt[IntermediateAddr(FetchB(), p1)]);
end;


Procedure TCPsystemInterpreter.STRI;  {store intermediate word}
var
  p1: word;
Begin
  p1 := FetchUB();
  WordAt[IntermediateAddr(FetchB(), p1)] := Pop();
end;

(*
 * Returns a pointer to a variable in a data segment (a global
 * variable in a UNIT)
 *)
function  TCPsystemInterpreter.ExternalAddr(Offset: word; SegNo: word): word;
begin
  assert(SegNo < SEG_DICT_SIZE2);
  result := WordIndexed(SegDict[SegNo].SegTop, Offset);
end;

// LDE: LoaD External
procedure TCPsystemInterpreter.LDE;
var
  p1: word;
begin
  p1 := FetchUB();
  Push(WordAt[ExternalAddr(FetchB(), p1)]);
end;


Procedure TCPsystemInterpreter.STO;  {store indirect}
var
  p1: word;
Begin
  p1 := Pop();         {Value}
  WordAt[Pop()] := p1; {store at indicated address}
end;

Procedure TCPsystemInterpreter.SIND;  {248..255: short index and load word, index>0, load indirect}
const
  SIND_0 = 248;  // SIND5 = 248+5 = 253
{ $F8..$FF pcodes}
var
  Addr2, Offset: word;
Begin
  if Word_Memory then
    Push(WordAt[WordIndexed(Pop(), fOpCode - SIND_0)])
  else
    begin
      Addr2      := POP();          {addr2}
      Offset     := (fOpCode-SIND_0) * 2;    {adjust opcode for correct byte offset}
      Addr2      := Addr2  + Offset;         {calculate address}
      PUSH(WordAt[Addr2]);          {load the value and save it}
    end;
(*
  HL := POP();          {addr2}
  A  := (fOpCode-$F8) * 2;    {adjust opcode for correct offset}
  HL := HL + A;         {calculate address}
  DE := WordAt[HL];     {load the value}
  PUSH(DE);
*)
end;

Procedure TCPsystemInterpreter.IND;  {Static index and load word. Was STIND!}
var
  HL: word;
Begin
  HL := Pop();
  Push(WordAt[WordIndexed(HL, FetchB(){index})]); // Careful: Delphi MAY evaluate parameters from the RIGHT!
end;

Procedure TCPsystemInterpreter.CIP;
{call intermediate procedure}
var
  p1: word;
Begin
  p1 := FetchUB();
  call(SEGP, p1, StaticLink(SEGP, p1));
end;

function TCPsystemInterpreter.StaticLink(NewSeg: word; ProcNo: byte): word;
var
  NewJTab: word;
begin
  NewJTab := Proc(NewSeg, ProcNo);

  if ProcNumber(NewJTab) = 0 then
    result := pNIL
  else
    result := Intermediate(ProcLexLevel(JTab) - ProcLexLevel(NewJTab) + 1);
end;

procedure TCPsystemInterpreter.CXP;
var
  SegNr, ProcNr, NewSegTop: word;
begin
  SegNr  := FetchUB();     // Get segment number
  ProcNr := FetchUB();     // Get procedure number
  if (SegNr <> 0) then     // Not for Segment 0 (already loaded?)
    CspLoadSegment(SegNr);
  NewSegTop := SegDict[SegNr].SegTop;
  if call(NewSegTop, ProcNr, StaticLink(NewSegTop, ProcNr)) then
      (*
       * Only native procedures are unloaded again
       * immediately, because they have already been executed.
       * A p-code procedure has yet to be interpreted, so it
       * isn't unloaded, the ret() function (called by the RBP
       * opcode) will unload it later.
       *)
      CspUnloadSegment(SegNr);
end;

{note: RNP x where x is # of words to return NOT size of stack to cut back.
 The stack is corrected by assigning the old SP to SP.  Note also that
 all functions allow space on stack for 2 words!!    LB oct 1991}
Procedure TCPsystemInterpreter.RNP;   {return from normal procedure}
Begin
  Sp := MemRd(WordIndexed(Mp, MS_SPw));
  ret(FetchUB());
end;

(*
 * Returns the size of the storage a procedure needs for its local
 * variables.
 *)
function TCPsystemInterpreter.ProcDataSize(JTab: word): word;
begin
  PointerCheck(JTab);
  result := WordAt[WordIndexed(JTab, -(DATASIZE_OB div 2))];
end;

procedure TCPsystemInterpreter.PointerCheck(p: word);
begin
  if p = pNIL then
    raise ENilPointer.CreateFmt('NIL pointer reference: JTab = %d, @ IPC: %d',
                      [{CurrentSegName, ProcNumber(JTab),} JTab, IPC]);    // Trying to use CurrentSegName causes a stackoverflow.
end;

(*
 * check for a gap between heap and stack.
 *)
procedure TCPsystemInterpreter.StackCheck();
begin
  if (Np >= Kp) then // stack has collided with heap
    begin
      with SysComIIPtr^ do
        GDIRP := pNIL;
//    SyscomAddr := pNil;
      Kp := $8000;
      Np := $6200;
      NP := 256;  {This differs from the "C interpreter" version - HEAPTOP,  prevent recursive overflow}
      raise ESTKFAULT.Create('Stack overflow');
    end;
end;

(*
 * Returns the size of the parameters, which are passed to a
 * procedure.
 *)
function TCPsystemInterpreter.ProcParamSize(JTab: word): word;
begin
  PointerCheck(JTab);
  result := WordAt[WordIndexed(JTab, -(PARAMSIZE_OB div 2))];
end;

function TCPsystemInterpreter.MemRd(Addr: word): word;
begin
  PointerCheck(Addr);
  result := WordAt[Addr];
end;

(*
 * Returns the procedure number of a procedure.
 *)
function TCPsystemInterpreter.ProcNumber(JTab: word): shortint; // this duplicates GetCurProc
begin
  PointerCheck(JTab);
{$R-}
  result := WordAt[JTab] and $ff;
{$R+}
end;

(*
 * Returns the lex level of a procedure.
 *)
function TCPsystemInterpreter.ProcLexLevel(JTab: word): shortint;
begin
  PointerCheck(JTab);
{$R-}
  result := WordAt[JTab] shr 8;
{$R+}  
end;

(*
 * Returns a pointer to the first instruction of a procedure.
 *)
function TCPsystemInterpreter.ProcBase(JTab: word): word;
begin
  PointerCheck(JTab);
  result := SelfRelPtr(WordIndexed(JTab, -(ENTERIC_OB div 2)));
end;

(*
 * Dereference a self relocating pointer. Self relocating pointers are
 * used in the segment dictionary and in procedure activation records.
 *)
function TCPsystemInterpreter.SelfRelPtr(Addr: word): word;
begin
  if Word_Memory then
    result := Addr - (WordAt[Addr] div 2)
  else
    result := Addr - WordAt[Addr];
end;

(*
 * Returns the number of procedures in a segment.
 *)
function TCPsystemInterpreter.SegNumProc(SegTop: word): byte;
begin
  result := WordAt[SegTop] shr 8;
end;

(*
 * Return the segment number of a segment.
 *)
function TCPsystemInterpreter.SegNumber(SegTop: word): byte;
begin
  result := WordAt[SegTop] and $ff;
end;

procedure TCPsystemInterpreter.Decops;
begin
  DECOPSMain(nil, nil);
end;

procedure TCPsystemInterpreter.ProcessNative(JTab: word; ProcNr: word; callingIPC: word);
begin
  case ProcNr of
    2: DecOps;
    3: WriteLong;
  else
    raise Exception.CreateFmt('Illegal call to native code from ProcNr = %d; IPC = %d. Linking needed?', [ProcNr, callingIPC]);
  end;
end;

(*
 * Returns a pointer to the activation record of a specified procedure
 * in a specified segment.
 *)
function TCPsystemInterpreter.Proc(SegTop: word; ProcNr: byte): word;
begin
  PointerCheck(SegTop);
  if ((ProcNr < 1) or (ProcNr > SegNumProc(SegTop))) then
    raise Exception.CreateFmt('Proc: Illegal Procedure Number %d. (linking required?)', [ProcNr]);
  result := SelfRelPtr(WordIndexed(SegTop, -ProcNr));
end;

(*
 * Call a procedure.  It builds a stack frame for the new procedure
 * and sets up all registers of the p-machine.
 *
 * @returns
 *    true  if its a native procedure,
 *    false if it is a p-code procedure
*)
function TCPsystemInterpreter.call(NewSeg: word; ProcNr: byte; static_link: word): boolean;
var
  NewJTab: word;
  DataSize: word;
  ParamSize: word;
  NewMp: word;
  w: integer;
  pll: shortint;
begin
  NewJTab   := Proc(NewSeg, ProcNr);
  DataSize  := ProcDataSize(NewJTab);    // byte count for variables
  ParamSize := ProcParamSize(NewJTab);   // byte count for parameters
  w         := -((DataSize + ParamSize) div 2);     // space needed in words
  NewMp     := WordIndexed(Kp, w);       // set location of new MSCW

  if (ProcNumber(NewJTab) = 0) then  // a "native" procedure
    begin
      ProcessNative(NewJTab, ProcNr, IPC);
      result := true;
      Exit;
    end;

  Assert(not odd(ParamSize));

  MoveLeftC(NewMp{Dst}, 0, Sp{Src}, 0, ParamSize);         // copy parameters onto stack
  Sp := WordIndexed(Sp, ParamSize div 2);

  NewMp := WordIndexed(NewMp, -MS_FRAME_SIZEw);  // make room for the stack frame
  pll   := ProcLexLevel(NewJTab);
  if (pll <= 0) then
    begin
//    PushBase(Base, Kp, BaseMp);     // debugging
      Push(Base);
      Base := NewMp;
      SysComIIPtr^.STKBASE := Base;
    end;

  WordAt[WordIndexed(NewMp, MS_KPw)]   := Kp;    // build the new MSCW
  WordAt[WordIndexed(NewMp, MS_STATw)] := static_link;
  WordAt[WordIndexed(NewMp, MS_DYNw)]  := Mp;
  WordAt[WordIndexed(NewMp, MS_JTABw)] := JTab;
  WordAt[WordIndexed(NewMp, MS_SEGw)]  := SEGP;
  WordAt[WordIndexed(NewMp, MS_IPCw)]  := Ipc;
  WordAt[WordIndexed(NewMp, MS_SPw)]   := Sp;

  Kp   := WordIndexed(NewMp, -1); (* Small Hack :-( bottom of current segment? Some extra space for segment?*)
  Mp   := NewMp;
  SEGP := NewSeg;
  JTab := NewJTab;

//SysComIIPtr^.LastMP := Mp;    // this was redundant
  SysComIIPtr^.Seg    := SEGP;  // not sure why-- maybe SEGP should be moved into SYSCOM
//SysComIIPtr^.JTab   := JTab;  // this was redundant

  IpcBase := ProcBase(JTab);
  Ipc     := 0;
  Inc(Level);
  StackCheck();
  result := false;
end;

Procedure TCPsystemInterpreter.CLP;
Begin
  call(SEGP, FetchUB(), Mp);
end;

Procedure TCPsystemInterpreter.CGP;  {call global proc}
Begin
  call(SEGP, FetchUB(), Base);
end;

Procedure TCPsystemInterpreter.CBP;  {call base procedure}
Begin
  call(SEGP, FetchUB(), BaseMp);
end;

{$IfDef Debugging}
function TCPsystemInterpreter.Fetch: TBrk;
var
  aSegNameIdx: TSegNameIdx;
Begin { TCPsystemInterpreter.Fetch }
  result     := dbUnknown;
  fOpCode    := FetchUB();
  CurrentIpc := Ipc;

  try
    with Opstable.Ops[fOpCode] do
      if Assigned(ProcCall) then
        if Assigned(frmPCodeDebugger) then  // We're debugging
          with frmPCodeDebugger do
            begin
    {$IfDef History}
              aSegNameIdx := TheSegNameIdx(SegBase);
              AddHist(CURPROC, RelIPC, fOpCode, Opstable.Ops[fOpCode].Name, aSegNameIdx,
                      DEbuggerSettings.CallHistoryOnly);
    {$EndIf History}
    {$IfDef Pocahontas}
              Phits := Phits + 1;
              IncProfile(aSegNameIdx, CurProc);
    {$EndIf Pocahantas}
              ProcCall;
            end
        else
          ProcCall
      else
        raise ENOTIMPLEMENTED.CreateFmt('Unimplemented opcode %d', [fOpCode]);

    Inc(DbgCnt);
  except
    on e:EXEQERR do
      pXEQERR(fErrCode);
    on e:ENOPROC do
      pXEQERR(NOPROCC);
    on e:ENOEXIT do
      pXEQERR(NOEXITC);
    on e:ESTKFAULT do
      pXEQERR(STKFLTC);
    on e:ESYSTEMHALT do
      result := FinalException(e.Message, e.ClassName);      // break out of the FETCH loop

    // if it is an unknown exception, it needs to be rethought
    on e:Exception do
      result := FinalException(e.Message, e.ClassName);
  end;
end; { Fetch }

{$EndIf debugging}

{$IfNDef debugging}
function TCPsystemInterpreter.Fetch: TBrk;
Begin { TCPsystemInterpreter.Fetch }
  result     := dbUnknown;
  fOpCode    := FetchUB();
  CurrentIpc := Ipc;

  try
    Op     := fOpCode;

    with Opstable.Ops[fOpCode] do
      if Assigned(ProcCall) then
        ProcCall
      else
        raise ENOTIMPLEMENTED.CreateFmt('Unimplemented opcode %d', [fOpCode]);

    Inc(DbgCnt);
  except
    on e:EXEQERR do
      pXEQERR(fErrCode);
    on e:ENOPROC do
      pXEQERR(NOPROCC);
    on e:ENOEXIT do
      pXEQERR(NOEXITC);
    on e:ESTKFAULT do
      pXEQERR(STKFLTC);
    on e:ESYSTEMHALT do
      begin
//      raise ESYSTEMHALT.Create();                   // Re-raise to break out of the FETCH loop
        HaltPSys('System HALT');
      end;

    // if it is an unknown exception, it needs to be rethought
    on e:Exception do
      result := FinalException(e.Message, e.ClassName);
  end;
end; { Fetch }
{$EndIf not Debugging}


procedure TCPsystemInterpreter.CSPTrunc;
  var
    Longi:Longint;
    R1: TRealUnion;
begin
  Pop(R1);
  Longi := trunc(R1.UCSDReal2);  {8/11/04 i:=trunc(UCSDReal2) gave RTE 201}
  push(Longi);                   {convert long integer to smallint and push}
end;

procedure TCPsystemInterpreter.CSPRound;
var
  w: word;
  Longi: longint;
  R1: TRealUnion;
begin
  Pop(R1);
  Longi := round(R1.UCSDReal2);
  w     := Longi;
  push(w);
end;

procedure TCPsystemInterpreter.CSPSine;
var
  R1: TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := sin(R1.UCSDReal2);
  Push(R1);
end;

procedure TCPsystemInterpreter.CSPCosine;
var
  R1: TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := cos(R1.UCSDReal2);
  Push(R1);
end;

(*
procedure TCPsystemInterpreter.CSPTan;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := Tan(R1.UCSDReal2);
  Push(R1);
end;
*)

procedure TCPsystemInterpreter.CSPAtan;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := ArcTan(R1.UCSDReal2);
  Push(R1);
end;

{ ln y:=ln(x)}
procedure TCPsystemInterpreter.CSPLn;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := ln(R1.UCSDReal2);
  Push(R1);
end;

procedure TCPsystemInterpreter.CSPLog;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := log10(R1.UCSDReal2);
  Push(R1);
end;


{ EXP y:=exp(x)}
procedure TCPsystemInterpreter.CSPExp;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := exp(R1.UCSDReal2);
  Push(R1);
end;

{r:=sqrt(r)}
procedure TCPsystemInterpreter.CSPSqrt;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := sqrt(R1.UCSDReal2);
  Push(R1);
end;

{MARK(Var i:^integer)...store HeapTop in i}
procedure TCPsystemInterpreter.CSPMark;
begin
  ClrGDirP();
  WordAt[Pop()] := Np;
end;

{RELEASE(Var i:^integer)...store i into HeapTop}
procedure TCPsystemInterpreter.CSPRelease;
begin
  Np := WordAt[Pop()];
  StackCheck();
  SysComIIPtr^.Gdirp := pNil;
end;

{UNITBUSY}
procedure TCPsystemInterpreter.CSPUnitBusy;
begin
  UNUM := Pop();
  Push(false);  // right now, nothing is ever busy
end;

procedure TCPsystemInterpreter.CSPPwrOfTen;
var
  i: integer;
  R1  : TRealUnion;
begin
  {die if not 0<=i<=37}
  popint(i);
  if (i < 0) or (i > 39) then
    begin
//    raise EXEQERR.Create('Illegal PwrOfTen(%d)', [i], INVNDXC);
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('Illegal PwrOfTen(%d)', [i]);
    end;
  R1.UCSDReal2 := PwrOfTen[i];
  Push(R1);
end;

{UNITWAIT}
procedure TCPsystemInterpreter.CSPUNITWAIT;
begin
  UNUM := Pop();
  with UNITBL[UNUM] do
    if Assigned(Driver) then
      begin

      end
      //Driver.UnitWait  why is this commented out? Maybe because nothing is ever busy.
    else
      PutIOError(INOUNIT);
end;

procedure TCPsystemInterpreter.CSPUnitClear;
begin
  UREQ  := CLRBIT;
  UBLK  := 0;
  CallIO;
end;

procedure TCPsystemInterpreter.CSPHalt;
begin
//raise ESYSTEMHALT.Create('HALT CSP 39');
  HaltPSys('HALT CSP 39');
end;

procedure TCPsystemInterpreter.CSPMemAvail;
var
  w: word;
begin
  with SysComIIPtr^ do
    if GDIRP > 0 then
      w := Kp - GDIRP
    else
      w := Kp - Np;
  Push(w div 2);     // Should this be using Word_Memory?
end;


Procedure TCPsystemInterpreter.CSP;
var
  CSPCode: word;
Begin
  CSPCode := FetchUB();
  with OpsTable.CSPTable[CSPCode] do
    begin
{$IfDef Pocahontas}
//    if Assigned(frmPCodeDebugger) then  // We're debugging
//      with frmPCodeDebugger do
//        if (frmPCodeDebugger as TfrmPCodeDebugger).BreakonpHitsZero and (Phits = 0) then
//          OutputDebugStringFmt('pHits = 0 for OpCode = %s, %s.Proc #%d. IPC=%d',
//            [OpsTable.CSPTable[CSPCode].Name, CurrentSegName, CURPROC, RelIPC]);
      PHITS := PHITS + 1;
{$EndIf Pocahontas}
      if Assigned(ProcCall) then
        ProcCall
      else
        raise Exception.CreateFmt('Unimplemented CSP %d',[CSPCode]);
    end;
end;

// BPT: (213) compiler generated breakpoint that is generated at the start of each program
Procedure TCPsystemInterpreter.BPT;
var
  sourceline:integer;    {line that bpt refers to}
Begin
  sourceline := FetchB();  // Ignore the fetched line number
end;


{************** LOADING STORING INDEXING MOVING*****************}

(*
 * This is always a little-endian fetch, even on big-endian
 * hosts, because there is no guarantee of word alignment (and
 * that's how the native compiler is written).
 *)
Procedure TCPsystemInterpreter.LDCI;   {Load constant word}
var
  p1: word;
Begin
  p1 := FetchW();
  push(p1);
end;



Procedure TCPsystemInterpreter.LDCN;   {Load constant nil pointer}
Begin
  PUSH(pNil);
end;



{************** LOCAL VARS *****************}


Procedure TCPsystemInterpreter.SLDL; {short load local word - ? like SLDO}
{in this turbo version A is not doubled in the opcode fetch routine,
 back so at this point  A = $D8..$E7, ie the actual value of SLDL1..16}
const
  SLDL_1 = 216;
Begin
  Push(WordAt[LocalAddr(fOpCode - SLDL_1 + 1)]);
end;

{************** GLOBAL VARS *****************}

function TCPsystemInterpreter.LocalAddr(Offset: word): longword;
begin
  result := WordIndexed(Mp, MS_VARW + Offset);
end;


function TCPsystemInterpreter.GlobalAddr(Offset: word): word;
begin
  result := WordIndexed(Base, MS_VARW + Offset);
end;

function TCPsystemInterpreter.Intermediate(count: byte): word;
var
  p: word;
begin
  p := Mp;
  while Count > 0 do
    begin
      p := WordAt[WordIndexed(p, MS_STATW)];
      Dec(Count);
    end;
  result := p;
end;

function TCPsystemInterpreter.IntermediateAddr(Offset: word; Count: byte): longword;
begin
  result := WordIndexed(Intermediate(Count), MS_VARW + Offset);
end;



Procedure TCPsystemInterpreter.SLDO; {short load global word - like SLDL}
{in this turbo version A is not doubled by back so at this point A = $E8..$F7}
{ Note: $E7 = $E8 - 1, i.e., SLDO_1 }
Begin
  Push(WordAt[GlobalAddr(fOpCode - $E7)]);
end;


Procedure TCPsystemInterpreter.LAO;  {165: load global address}
{same as LLA except index from GlobVar not LocalVar}
Begin
  Push(GlobalAddr(FetchB))
end;


Procedure TCPsystemInterpreter.LDO;  {169: load global word}
Begin
  Push(WordAt[GlobalAddr(FetchB())]);
end;

Procedure TCPsystemInterpreter.SRO;    {171: store global word}
Begin
  WordAt[GlobalAddr(FetchB())] := Pop();
end;

{************** INTERMEDIATE VARS *****************}

procedure TCPsystemInterpreter.MemWrByte(Addr: word; Offset: integer; value: byte);
var
  w: word;
begin
  try
    PointerCheck(Addr);
    if Word_Memory then
      begin
        Addr   := Addr + (Offset and not 1) div 2;  // treat the offset as a word offset
        Offset := Offset and 1;                     // see if the offset refers to byte 0 or byte 1
        w      := WordAt[Addr];                     // get the word at the specified address
        if (Offset = 0) = (byte_sex = bs_BIG_ENDIAN) then
          w := (w and $00ff) or (value shl 8)
        else
          w := (w and $ff00) or (value and $00ff);

        WordAt[Addr] := w;
      end
    else  // The above is supposed to work for either word or byte memory but it dosen't (and this is faster)
      begin
        Bytes[Addr+OffSet] := Value;
      end;
  except
    // if it is a nil pointer, skip the store
    on e:Exception do
      StatusProc(e.Message);
  end;
end;

  function TCPsystemInterpreter.MemRdByte(Addr: word; Offset: integer): byte;
  begin
    PointerCheck(Addr);

    if Word_Memory then
      begin
        Addr   := Addr + (Offset and (not 1)) div 2;
        Offset := Offset and 1;     // specify odd/even byte

        // +--------+----------+--------+
        // | offset | byte sex | branch |
        // +--------+----------+--------+
        // |   0    |  little  |  else  |
        // |   1    |  little  |  then  |
        // |   0    |   big    |  then  |
        // |   1    |   big    |  else  |
        // +--------+----------+--------+

        if (Offset = 0) = (byte_sex = bs_BIG_ENDIAN) then
          result := WordAt[Addr] shr 8
        else
          result := WordAt[Addr] and $FF;
      end
    else
      begin
        Addr   := Addr + Offset;
        result := Bytes[Addr];
      end;
  end;


  function TCPsystemInterpreter.FetchB: word;
  var
    b: byte;
  begin { FetchB }
    b := MemRdByte(IpcBase, IPC);
    Ipc := Ipc + 1;

    if (b and $80) <> 0 then
      begin
        result := (((b and $7f) shl 8) + MemRdByte(IpcBase, IPC));
        Ipc := Ipc + 1;
      end
    else
      result := b;
  end;  { FetchB }

  function TCPsystemInterpreter.FetchUB(): byte;
  begin { FetchUB() }
    result := MemRdByte(IpcBase, IPC);
    IPC := IPC + 1;
  end;  { FetchUB() }

  function TCPsystemInterpreter.GetNextOpCode: byte;
  begin
    result := MemRdByte(IpcBase, IPC);
  end;

{************** Indirect records, arrays and indexing *************}

Procedure TCPsystemInterpreter.INCR;   {increment (Sp) by literal}
Begin
  if VersionNr >= vn_VersionII then
    Push(WordIndexed(Pop(), FetchB()))  // version number >= V2.0 is passing a word count
  else
    Push(Pop() + FetchB());             // version 1.4 is expecting a byte count-- this is a kludge
end;

Procedure TCPsystemInterpreter.IXA; {index array}
var
  Base, ElementSize: longword;
  Index: integer;
Begin
  Index          := PopInt();    // get the index
  Base           := Pop();       // get the array base address
  ElementSize    := FetchB();    // Elementsize is a word count
  Push(WordIndexed(Base, Index * ElementSize));
end;


Procedure TCPsystemInterpreter.MOV;   {168: move words}
var
  WordCnt,
  ByteCnt: word;
  Src, Dst: word;
Begin
  WordCnt := FetchB(); {# words to move}
  ByteCnt := WordCnt * 2;
  Src     := Pop();      {^source}       {addr2}
  Dst     := Pop();      {^dest}         {addr1}
  Move(Bytes[ByteIndexed(Src)], Bytes[ByteIndexed(Dst)], ByteCnt);
end;

procedure TCPsystemInterpreter.MVB;   {169: move bytes- V 1.4, V1.5 only}
var
  Len: word;   // ByteCnt
  Src, Dst: word;
begin
  Len     := FetchB();
  Src     := Pop();      {^source}
  Dst     := Pop();      {^dest}

  Move(Bytes[ByteIndexed(Src)], Bytes[ByteIndexed(Dst)], Len);
end;


{************** Multiple word VARS *************}

Procedure TCPsystemInterpreter.LDC;  {Load multiple word constant..const is backwards in code stream and is word aligned}
var
  cnt, w: word;
Begin
  cnt  := FetchUB();             // get the word count

  IPC := (IPC + 1) and (not 1);  // put Ipc on word boundary

  while (cnt > 0) do
    begin
      W := FetchW(); // FIXME: should this be a "native" word fetch?
      Push(W);
      Dec(cnt);
    end;
end;

Procedure TCPsystemInterpreter.LDM;  {Load multiple words (no more than 255)}
var
  p1, w: word;
  Addr: word;
Begin
  p1 := FetchUB();                    // get the word count
  w  := Pop();                        // get the starting address (we will be working from the end)
  while (p1 > 0) do
    begin
      Dec(p1);                        // point to previous word and reduce the count of words to process
      Addr := WordIndexed(w, p1);
      Push(WordAt[Addr]); // get one word and push onto stack
    end;
end;


Procedure TCPsystemInterpreter.STM;   {Store multiple words}
var
  p1, w: word;
  Addr: word;
Begin
  p1   := FetchUB();                    // get the word count
  Addr := WordIndexed(Sp, p1);
  w    := WordAt[Addr];  // get the storage address -
  while (p1 > 0) do
    begin
      WordAt[w] := Pop();             // store one from the stack
      w := WordIndexed(w, 1);         // point to the next one
      dec(p1);                        // reduce the count
    end;
  Pop();                              // now remove the storage address from the stack
end;

{*********** Character VARS AND BYTE ARRAYS *****************}

Procedure TCPsystemInterpreter.LDB;  {load byte}
var
  w: word;
  p: word;
Begin
  if VersionNr in [vn_VersionI_4, vn_VersionI_5] then
    begin  // The code below would probably work
      Assert(not word_memory);
      p := Pop();        // get the address
      w := Bytes[p];     // get the byte
      push(w);           // and return it
    end
  else
    begin
      w := Pop();
      Push(MemRdByte(Pop(), w));
    end
end;


Procedure TCPsystemInterpreter.STB;  {store byte}
var
  P1, Offset, Addr: word;
Begin
  if VersionNr in [vn_VersionI_4, vn_VersionI_5] then
    begin
      Assert(not Word_Memory);
      p1   := Pop() and $FF;  // byte to be stored
      Addr := Pop();          // get the address
      Bytes[Addr] := P1;
    end
  else
    begin
      p1      := Pop() and $FF;  // byte to be stored
      Offset  := Pop();  // offset

      MemWrByte(Pop() { base address }, Offset, p1);
    end;
end;


{*********** STRING VARS *****************}

Procedure TCPsystemInterpreter.SAS;   {String assignment}
{ on stack can either be   ^src string,  ^dst string
                      OR   a char     ,  ^dst string}
var
  MaxLen, Src, Len, Dst: word;
Begin
  MaxLen := FetchUB();         // get the max length allowed
  Src  := Pop();               // addr of src string
  if (Src and $ff00) <> 0 then  // copy string
    begin
      (* copy String *)
      Len  := MemRdByte(Src, 0);  // get the actual length in bytes
      Dst  := Pop();              // addr for destination string
      if (Len > MaxLen) then
        raise ES2LONG.CreateFmt('String too long: %s>%d', [Len, MaxLen]);
      MoveLeftC(Dst, 0, Src, 0, Len + 1);   // + 1 to include length byte
    end
  else
    begin                      // store Char
      Dst := Pop();
      MemWrByte(Dst, 0, 1);    // make string of len 1
      MemWrByte(Dst, 1, Src);  // containing char on stack
    end
end;

{ 208: Load Packed Array }
(* In version 1.4, 1.5, the LPA follows an LCA which defines the string.
(* This is the way LPA works in the Laurence Boshell version. *)
procedure TCPsystemInterpreter.LPA1;
var
  Addr: word;
begin
  Addr := Pop();          // Get address of the string
  Addr := Addr + 1;       // skip past the length byte
  Push(Addr);             // return the string address
end;

{ 208: Load Packed Array }
(*  This was the code in the PM version.
    In version II, the string data follows the LPA. *)
procedure TCPsystemInterpreter.LPA2;
var
  ByteCount: word;
begin
  ByteCount := FetchB();              // byte count

  if Word_Memory then
    Push(IpcBase + (Ipc div 2))  // push the address of the data
  else
    Push(IpcBase + Ipc);         // This branch will never be taken because the OpCodes table will branch to LPA1

  Ipc := Ipc + ByteCount;        // jump over the data
end;

{ STore Extended }
procedure TCPsystemInterpreter.STE();
var
  p1: word;
begin
  p1 := FetchUB();
  WordAt[ExternalAddr(FetchB(), p1)] := Pop();
end;


{******** PACKED ARRAYS AND RECORDS ***********}

// IXP: 192 ($C0)
// Index Packed Array. TOS is an integer index, TOS-1 is the array base
// word pointer. UB_1 is the number of elements per word, and UB_2 is the
// field-width (in bits). Compute and push a packed field pointer.
procedure TCPsystemInterpreter.IXP;
var
  p1, p2, w: word;
begin
  p1 := FetchUB();
  p2 := FetchUB();
  w  := Pop();
  Push(WordIndexed(Pop() (* array base (word pointer) *),
                   w div p1)); (* Address *)
  Push(p2);
  Push((w mod p1) * p2);
end;

Procedure TCPsystemInterpreter.LDP;      {load a packed field}
 {get the field described by right bit number, bits per element,
  ^word, all info is on the stack}
var
  Addr, NrBits, TheWord, BitNr: word;
Begin
  BitNr   := POP();           // RIGHT BIT#  0..15
  NrBits  := POP();           // BITS-PER-ELEMENT
  Addr    := POP();           // ADDR OF WORD FIELD IS IN
  TheWord := WordAt[Addr];    // CONTENTS OF WORD
  TheWord := GetBits(TheWord, BitNr, NrBits);
  PUSH(TheWord);              // PUSH THE FIELD
end;




Procedure TCPsystemInterpreter.STP;     {Store into a packed field}
{Given data, right bit number, bits per element, ^target}
var
  Offset  : word;
  Size    : word;
  Addr    : word;
  w       : word;
Begin
  w      := Pop();          // data
  Offset := Pop() and $ff;  // right bit number
  Size   := Pop();          // bits per element
  Addr   := Pop();          // ^target
  if (Offset + Size > 16) then
    begin
//    raise EXEQERR.Create('STP: Offset(%d)+Size(%d) > Bits per word', [Offset, Size], INVNDXC);
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('STP: Offset(%d)+Size(%d) > Bits per word', [Offset, Size]);
    end;

  w      := w and ((1 shl Size) - 1);
  WordAt[Addr] :=
      (
          (WordAt[Addr] and not (((1 shl Size) - 1) shl Offset))
          or
          (w shl Offset)
      )
  ;
end;






{******TOP of STACK ARITHMETIC*******}

{***** Logical}


Procedure TCPsystemInterpreter.LAND; {132: logical and}
Begin
  PUSH(Pop() and Pop());
end;

Procedure TCPsystemInterpreter.LOR;
{logical or}
Begin
  PUSH(Pop() or Pop());
end;


Procedure TCPsystemInterpreter.LNOT;
var
  I: word;
{logical not}
Begin
// Method 1
//Push(not Pop());       // can't be trusted

// Method 2:
//I := Pop();
//I := not I;
//Push(I);

// Method 3: This actually does a "boolean" not
  I := Pop();
  I := I and $1;         // low bit only
  push(I <> 1);
end;






{***** integer}

Procedure TCPsystemInterpreter.ABI; {128: absolute value}
var
  Temp: integer;
Begin
{$R-} // ABS function would assume a 32 bit integer when it is really a 16 bit integer.
      // This causes a fail on negative 16 bit values. This caused extremely difficult to detect bugs.
  Temp := Pop();
{$R+}
  PUSH(Abs(Temp));
end;


Procedure TCPsystemInterpreter.ADI;   {130: add integers}
Begin
{$R-}
  PUSH(Pop()+Pop());
{$R+}
end;

Procedure TCPsystemInterpreter.DVI; {134: divide integers}
var
  TOS, TOS1: integer;
Begin
{$R-}
  TOS  := Pop(); {divisor}
  TOS1 := Pop(); {dividend}
  PUSH(TOS1 div TOS);
{$R+}
end;



Procedure TCPsystemInterpreter.MODI; {remainder of integer division}
var
  TOS, TOS1: word;
Begin
  TOS  := Pop();
  TOS1 := Pop();
  PUSH(TOS1 mod TOS);
end;



Procedure TCPsystemInterpreter.MPI;   {integer multiply}
Begin
{$R-}
  PUSH(Pop() * Pop());
{$R+}
end;



Procedure TCPsystemInterpreter.SQI;   {integer square}
var a:integer;
Begin
  POPint(a);
  a := a * a;
  pushint(a);
end;





Procedure TCPsystemInterpreter.NGI;  {negate integer}
Begin
  PushInt(-PopInt());
end;



Procedure TCPsystemInterpreter.SBI;  {subtract integer}
var
  a, b: integer;
Begin
{$R-}
  a := Pop();
  b := Pop();
  PUSH(B-A);
{$R+}
end;



Procedure TCPsystemInterpreter.CHK;  {136: range check}
var a,b,x:integer;
{uses integer as a word that is negative integer does not compare correctly}
Begin
  b := Pop();
  a := Pop();
  x := WordAt[Sp];  // leave it on the stack
  If (x < a) or (x > b) then
    begin
//    SaveIPC;
//    raise EXEQERR.Create('RANGE CHECK ERROR. Min Value = %d, MaxValue = %d, Value = %d', [a, b, x], INVNDXC);
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('RANGE CHECK ERROR. Min Value = %d, MaxValue = %d, Value = %d', [a, b, x]);
    end;
end;

{************** Floating point stuff*************}

Procedure TCPsystemInterpreter.FLT;
{138: Pop integer off stack 2 bytes, and push real 4bytes}
var
  R1 : TRealUnion;
  N : integer;
Begin
{$R-}
  N := Pop();        {be careful to not convert a WORD TO a real-- must be an integer}
{$R+}
  R1.UCSDReal2 := N;   {DELPHI does conversion}
  PUSH(R1);
end;

//        Name: FLO
//        Purpose:
//              Float 2nd item (integer) from stack then push it and the original TOS
//        Entry:
//              TOS real
//              TOS+1 as integer
//        Returns:
//              TOS+1 floated
//              TOS
Procedure TCPsystemInterpreter.FLO;
{flo nos}
{137: Pop real off stack, Pop integer, float it, push it, push real}
Var //i:integer;
  R1, R2: TRealUnion;
Begin
  Pop(R1);             // Pop the floating point number on the TOS and save it.
  R2.UCSDReal2 := Pop();  // Pop the integer value and convert to real.
  Push(R2);              // Put back the now floated integer
  Push(R1);            //   and then the original floating number that was on the TOS.
end;





Procedure TCPsystemInterpreter.ADR;  {131: add reals}
{add reals tos and nos....leaves result on stack}
var
  R1 : TRealUnion;
  R2 : TRealUnion;
Begin
  Pop(R1);
  Pop(R2);
  R1.UCSDReal2 := R1.UCSDReal2 + R2.UCSDReal2;
  PUSH(R1);
end;



Procedure TCPsystemInterpreter.MPR;
{mult reals tos and nos....leaves result on stack}
var
  R1 : TRealUnion;
  R2 : TRealUnion;
Begin
  Pop(R1);
  Pop(R2);
  R1.UCSDReal2 := R1.UCSDReal2 * R2.UCSDReal2;
  PUSH(R1);
end;


Procedure TCPsystemInterpreter.DVR;
{divide reals nos by tos....leaves result on stack}
var
  R1 : TRealUnion;           
  R2 : TRealUnion;
Begin
  Pop(R1);        // TOS
  Pop(R2);        // NOS
  try
    R1.UCSDReal2 := R2.UCSDReal2 / R1.UCSDReal2;
  except
    R1.UCSDReal2 := 0;
{$IfDef Debugging}
    fErrCode := DIVZERC;
//  raise EXEQERR.Create('Real Divide by 0.0 in %s.Proc #%d. IPC=%d', [CurrentSegName, CURPROC, RelIPC], DIVZERC);
    raise EXEQERR.CreateFmt('Real Divide by 0.0 in %s.Proc #%d. IPC=%d', [CurrentSegName, CURPROC, RelIPC]);
{$else}
//  raise EXEQERR.Create('Real Divide by 0.0 in %s.Proc #%d', [CurrentSegName, CURPROC], DIVZERC);
    raise EXEQERR.CreateFmt('Real Divide by 0.0 in %s.Proc #%d', [CurrentSegName, CURPROC]);
{$endIf debugging}
  end;
  PUSH(R1);
end;



Procedure TCPsystemInterpreter.ABR; {129: Absolute value of real }
{absolute value of real tos ..leaves result on stack}
var
  X : TRealUnion;
Begin
  Pop(X);
  X.UCSDReal2 := abs(X.UCSDReal2);
  PUSH(X);
end;


Procedure TCPsystemInterpreter.NGR;
{negate value of real tos}
var
  R1 : TRealUnion;
Begin
  Pop(R1);
  R1.UCSDReal2 := - R1.UCSDReal2;
  PUSH(R1);
end;



Procedure TCPsystemInterpreter.SBR;
{subtract tos from nos....leaves result on stack}
var
  R1 : TRealUnion;
  R2 : TRealUnion;
Begin
  Pop(R1);
  Pop(R2);
  R1.UCSDReal2 := R2.UCSDReal2 - R1.UCSDReal2;
  PUSH(R1);
end;

Procedure TCPsystemInterpreter.pSQR;
{square reals tos ....leaves result on stack}
var
  R1 : TRealUnion;
Begin
  Pop(R1);
  R1.UCSDReal2 := sqr(R1.UCSDReal2);
  PUSH(R1);     {high}
end;





{**************word comparisons}




Procedure TCPsystemInterpreter.EQUI;
var a,b:integer;
Begin
{$R-}
  B := Pop();
  A := Pop();
  Push(a=b);
{$R+}
end;

Procedure TCPsystemInterpreter.GEQI;  {>=}
var a,b:integer;
Begin
{$R-}
  B := Pop();
  A := Pop();
  Push(A>=B);
{$R+}
end;

Procedure TCPsystemInterpreter.GRTI;  {>}
var a,b:integer;
Begin
{$R-}
  B := Pop();
  A := Pop();
  Push(A>B);
{$R+}
end;



Procedure TCPsystemInterpreter.NEQI;   {compare for <>}
var a,b:integer;
Begin
{$R-}
  B := Pop();
  A := Pop();
  Push(A<>B);
{$R+}
end;


Procedure TCPsystemInterpreter.LEQI;  {<=}
var a,b:integer;
Begin
{$R-}
  B := Pop();
  A := Pop();
  Push(A<=B);
{$R+}
end;


Procedure TCPsystemInterpreter.LESI;  {<}
var a,b:integer;
Begin
{$R-}
  B := Pop();
  A := Pop();
  Push(A<B);
{$R+}
end;

{*********** Comparison of complex things **********}



function TCPsystemInterpreter.StrCmp(s1, s2: word): integer;
var
  Len, Len1, Len2, i, ch1, ch2: byte;
begin
  Len1 := MemRdByte(s1, 0);
  Len2 := MemRdByte(s2, 0);

  Len  := IIF(Len1 < Len2, Len1, Len2); (* Length to compare *)

  for i := 1 to Len do
    begin
      Ch1 := MemRdByte(s1, i); (* Get a char from both strings *)
      Ch2 := MemRdByte(s2, i);
      if (Ch1 < Ch2) then
        begin
          result := (-1); (* S1 < S2 *)
          exit;
        end
      else if (Ch1 > Ch2) then
        begin
          result := (+1); (* S1 > S2 *)
          exit;
        end;
    end;

  (* All chars in range of common length are equal. *)
  if (Len1 < Len2) then
    result := (-1) (* S1 is shorter?  If so S1 < S2 *)
  else if (Len1 > Len2) then
    result := (+1) (* S2 is shorter? if so S1 > S2 *)
  else
    result := (0);(* both strings have the same length, so they are equal. *)
end;





{**********************************************************************}


{**************** SET ARITHMETIC  *************************************}

procedure TCPsystemInterpreter.SetPop(var aSet: TSet);
var
  i: integer;
begin
  aSet.Size := Pop();
  for i := 0 to aSet.Size-1 do
    aSet.Data[i] := Pop();
end;

procedure TCPsystemInterpreter.SetPush(const aSet: TSet);
var
  i: integer;
begin
    for i := aSet.Size-1 downto 0 do
      Push(aSet.Data[i]);
    Push(aSet.Size);
end;



// Adjust Set.
// Force the set TOS to occupy UB words, either by expansion
// (adding zeroes "between" TOS and TOS-1) or compression
// (chopping of high words of set), and discard its length word.
// After this operation, if less than 20 words are available to the
// Stack, cause a Stack fault.
Procedure TCPsystemInterpreter.ADJ;
var
  p1, p2, w: word;
  Buf: TSet;
begin
  p1 := FetchUB();
  w  := WordAt[Sp];
  if (p1 <> w) then
    begin
      SetPop(Buf);
      SetAdj(Buf, p1);
      SetPush(Buf);
    end;
  p2 := Pop();
  if (p1 <> p2) then
    raise EADJFAILURE.CreateFmt('adj failure: p1 <> p2: ', [p1, p2]);
end;




procedure TCPsystemInterpreter.DIF; {133: set difference}
var
  i: word;
  Size: word;
  aSet: TSet;
begin
  SetPop(aSet);
  Size := Pop();
  if (Size > aSet.Size) then
    SetAdj(aSet, Size);

  for i := 0 to Size-1 do
    aSet.Data[i] := Pop() and (not aSet.Data[i]);

  i := Size;
  while (i < aSet.Size) do
    begin
      aSet.Data[i] := 0;
      inc(i);
    end;
  SetPush(aSet);
end;

procedure TCPsystemInterpreter.Int;
var
//i: integer;
  i: word;
  Size: word;
  aSet: TSet;
begin
  SetPop(aSet);
  Size := Pop();
  if (Size > aSet.Size) then
    SetAdj(aSet, Size);

  for i := 0 to Size-1 do
    aSet.Data[i] := aSet.Data[i] and Pop();
  i := Size;  // because i may be undefined after loop

  while (i < aSet.Size) do
    begin
      aSet.Data[i] := 0;
      inc(i);
    end;
  SetPush(aSet);
end;



procedure TCPsystemInterpreter.UNI;
var
  i: integer;
  size: word;
  aSet: TSet;
begin
  SetPop(aSet);
  Size := Pop();
  if Size > aSet.Size then
    SetAdj(aSet, Size);
  for i := 0 to Size-1 do
    aSet.Data[i] := aSet.Data[i] or Pop();
  SetPush(aSet);
end;


procedure TCPsystemInterpreter.SetAdj(var s: TSet; Size: word);
var
//i: integer;
  i: word;
begin
  i := S.Size;
  while i < Size do // Zero extra words
    begin
      S.Data[i] := 0;
      Inc(i);
    end;
  S.Size := Size;
end;

// Name:    SetNeq
// Entry:   Set1, Set2
// result:  returns true is the sets are not equal
//          returns false if they are equal
function TCPsystemInterpreter.SetNeq(var Set1, Set2: TSet): boolean;
var
//Size, i: integer;
  Size, i: word;
begin
  Size := IIF(Set1.Size > Set2.Size, Set1.Size, Set2.Size);  // Use the larger size
  if (Set1.Size < Size) then
    SetAdj(Set1, Size);
  if (Set2.Size < Size) then
    SetAdj(Set2, Size);

  for i := 0 to Size-1 do
    if (Set1.Data[i] <> Set2.Data[i]) then
      begin
        result := true;
        Exit;
      end;
  result := false;
end;

// Function Name: ByteCmp
// Entry:         Address of two byte strings to compare
// result:        -1 if b1a < ba2
//                +1 if ba1 > ba2
//                0  if ba1 = ba2
function TCPsystemInterpreter.ByteCmp(ba1: word; ba2: word; len: word): integer;
var
  i: word;
  ch1, ch2: byte;
begin
  for i := 0 to len-1 do
    begin
      Ch1 := MemRdByte(ba1, i); (* Get a char from both strings *)
      Ch2 := MemRdByte(ba2, i);
      if (Ch1 < Ch2) then
        begin
          result := (-1); (* BA1 < BA2 *)
          exit;
        end
      else if (Ch1 > Ch2) then
        begin
          result := (1); (* BA1 > BA2 *)
          exit;
        end;
    end;
  result :=  (0);
end;

// Function Name: WordCmp
// Entry:         Address of two word strings to compare
// result:        +1 if wa1 <> wa2
//                0  if wa1 = wa2
function TCPsystemInterpreter.WordCmp(wa1: word; wa2: word; len: word): integer;
var
  i: word;
begin
  for i := 0 to Len - 1 do
    begin
      if WordAt[WordIndexed(wa1, i)] <> WordAt[WordIndexed(wa2, i)] then
        begin
          result := (1);
          exit;
        end;
    end;
  result := (0);
end;


(* EQU *)
procedure TCPsystemInterpreter.EQU;
var
  f1, f2: TRealUnion;
  s1, s2: word;
  b1, b2: boolean;
  Set1, Set2: TSet;
  len: word;
  Op: byte;
begin { EQU }
  Op := FetchUB();
  case Op of
    2: { real }
      begin
        Pop(f1);
        Pop(f2);
        Push(f2.UCSDReal2 = f1.UCSDReal2);
      end;

    4: { string }
      begin
        s1 := Pop();
        s2 := Pop();
        Push(StrCmp(s2, s1) = 0);
      end;

    6: { boolean }
      begin
        Pop(b1);
        Pop(b2);
        Push(b1 = b2);
      end;

    8: { set }
      begin
        Pop(Set1);
        Pop(Set2);
        Push(not SetNeq(Set1, Set2));
      end;

  10: { bytes }
      begin
        s1 := Pop();
        s2 := Pop();
        len := FetchB();
        Push(ByteCmp(S2, s1, Len) = 0);
      end;

  12: { words }
      begin
        len := FetchB();
        s1  := Pop();
        s2  := Pop();
        Push(WordCmp(s2, s1, len) = 0);
      end;

  else
      raise ENOTIMPLEMENTED.CreateFmt('EQU: Op %d is not implemented', [Op]);
  end;
end;


procedure TCPsystemInterpreter.NEQ;
var
  f1, f2: TRealUnion;
  s1, s2: word;
  b1, b2: boolean;
  Set1, Set2: TSet;
  len: word;
  Op: byte;
begin { NEQ }
  Op := FetchUB();
  case Op of
      2: { real }
        begin
          Pop(f1);
          Pop(f2);
          Push(f2.UCSDReal2 <> f1.UCSDReal2);
        end;

      4: { string }
        begin
          s1 := Pop();
          s2 := Pop();
          Push(StrCmp(s2, s1) <> 0);
        end;

      6: { boolean }
        begin
          Pop(b1);
          Pop(b2);
          Push(b1 <> b2);
        end;

      8: { set }
          begin
            Pop(Set1);
            Pop(Set2);
            Push(SetNeq(Set1, Set2));
          end;

      10: { byte compare }
        begin
          len := FetchB();
          s1  := Pop();
          s2  := Pop();
          Push(ByteCmp(s2, s1, Len) <> 0);
        end;

      12: { words }
        begin
          len := FetchB();
          s1  := Pop();
          s2  := Pop();
          Push(WordCmp(s2, s1, len) <> 0);
        end;

      else
        raise ENOTIMPLEMENTED.CreateFmt('NEQ: Op %d is not implemented', [Op]);
      end;
end; { NEQ }

// Function: set_is_improper_subset
// Entry:    haystack
//           needle
// Returns: true if improper
//          false if not improper
function TCPsystemInterpreter.set_is_improper_subset(const haystack: TSet; const needle: TSet): boolean;
var
//Size, i: integer;
  Size, i: word;
begin
  Size := needle.Size;
  while (Size > 0) and (needle.Data[Size - 1] = 0) do
    Dec(Size);

  if (haystack.Size < Size) then
    result := false
  else
    begin
      for i := 0 to Size-1 do
        if ((haystack.Data[i] and needle.Data[i]) <> needle.Data[i]) then
          begin
            result := false;
            exit;
          end;
      result := true;
    end
end;

function TCPsystemInterpreter.set_is_proper_subset(var haystack: TSet; var needle: TSet): boolean;
begin
  result := set_is_improper_subset(haystack, needle) and SetNeq(haystack, needle);
end;

procedure TCPsystemInterpreter.LEQ;
var
  f1, f2: TRealUnion;
  s1, s2: word;
  b1, b2: boolean;
  Needle, Haystack: TSet;
  len: word;
  Op: byte;
begin { LEQ}
  Op := FetchUB();
  case Op of
    2: { real }
      begin
        Pop(f1);
        Pop(f2);
        Push(f2.UCSDReal2 <= f1.UCSDReal2);
      end;

    4: { string }
      begin
        s1 := Pop();
        s2 := Pop();
        Push(StrCmp(s2, s1) <= 0);
      end;

      6: { boolean }
        begin
          Pop(b1);
          Pop(b2);
          Push(b2 <= b1);
        end;

      8: { sets }
          begin
            (* needle <= haystack *)
            Pop(haystack);
            Pop(needle);
            Push(set_is_improper_subset(haystack, needle));
          end;

      10: { bytes }
        begin
          Len := FetchB();
          s1  := Pop();
          s2  := Pop();
          Push(Boolean(ByteCmp(s2, s1, Len) <= 0));
        end;

      else
        raise ENOTIMPLEMENTED.CreateFmt('LEQ: Op %d is not implemented', [Op]);
  end;
end;  { LEQ }

procedure TCPsystemInterpreter.LES;
var
  f1, f2: TRealUnion;
  s1, s2: word;
  b1, b2: boolean;
  Needle, Haystack: TSet;
  len: word;
  Op: byte;
begin { LES}
  Op := FetchUB();
  case Op of
    2: { real }
      begin
        Pop(f1);
        Pop(f2);
        Push(f2.UCSDReal2 < f1.UCSDReal2);
      end;

    4: { string }
      begin
        s1 := Pop();
        s2 := Pop();
        Push(StrCmp(s2, s1) < 0);
      end;

      6: { boolean }
        begin
          Pop(b1);
          Pop(b2);
          Push(b2 < b1);
        end;

      8: { sets }
          begin
            (* needle <= haystack *)
            Pop(haystack);
            Pop(needle);
            Push(set_is_proper_subset(haystack, needle));
          end;

      10: { bytes }
        begin
          Len := FetchB();
          s1  := Pop();
          s2  := Pop();
          Push(Boolean(ByteCmp(s2, s1, Len) < 0));
        end;

      else
        raise ENOTIMPLEMENTED.CreateFmt('LES: Op %d is not implemented', [Op]);
      end;
end;  { LES }

procedure TCPsystemInterpreter.GEQ;
var
  f1, f2: TRealUnion;
  s1, s2: word;
  b1, b2: boolean;
  Needle, Haystack: TSet;
  len: word;
  Op: byte;
begin { GEQ}
  Op := FetchUB();
  case Op of
    2: { real }
      begin
        Pop(f1);
        Pop(f2);
        Push(f2.UCSDReal2 >= f1.UCSDReal2);
      end;

    4: { string }
      begin
        s1 := Pop();
        s2 := Pop();
        Push(StrCmp(s2, s1) >= 0);
      end;

      6: { boolean }
        begin
          Pop(b1);
          Pop(b2);
          Push(b2 >= b1);
        end;

      8: { sets }
          begin
            (* needle >= haystack *)
            Pop(needle);
            Pop(haystack);
            Push(set_is_improper_subset(haystack, needle));
          end;

      10: { bytes }
        begin
          Len := FetchB();
          s1  := Pop();
          s2  := Pop();
          Push(Boolean(ByteCmp(s2, s1, Len) < 0));
        end;

      else
        raise ENOTIMPLEMENTED.CreateFmt('GEQ: Op %d is not implemented', [Op]);
      end;
end;  { GEQ }

procedure TCPsystemInterpreter.GRT;
var
  f1, f2: TRealUnion;
  s1, s2: word;
  b1, b2: boolean;
  Needle, Haystack: TSet;
  len: word;
  Op: byte;
begin
  Op := FetchUB();
  case Op of
    2: { real }
      begin
        Pop(f1);
        Pop(f2);
        Push(f2.UCSDReal2 > f1.UCSDReal2);
      end;

    4: { string }
      begin
        s1 := Pop();
        s2 := Pop();
        Push(StrCmp(s2, s1) > 0);
      end;

      6: { boolean }
        begin
          Pop(b1);
          Pop(b2);
          Push(b2 > b1);
        end;

      8: { sets }
          begin
            (* needle > haystack *)
            Pop(haystack);
            Pop(needle);
            Push(not set_is_proper_subset(haystack, needle));
          end;

      10: { bytes }
        begin
          Len := FetchB();
          s1  := Pop();
          s2  := Pop();
          Push(ByteCmp(s2, s1, Len) > 0);
        end;

      else
        raise ENOTIMPLEMENTED.CreateFmt('GRT: Op %d is not implemented', [Op]);
      end;
end;

Procedure TCPsystemInterpreter.SRS;
{build a subrange set, the set [i..j]}
const
  MAXSETSIZE = 4080; // C interpreter used 512
var
  Addr, p1, p2: word;
  Size, i: integer;
Begin
  p1 := Pop();
  p2 := Pop();
  if ((p1 < MAXSETSIZE) and (p2 < MAXSETSIZE)) then
    begin
      if (p2 > p1) then
        Push(0)
      else
        begin
          Size := (p1 + 16) div 16;
          for i := 0 to Size-1 do
            Push(0);
          while (p2 <= p1) do
            begin
              Addr := WordIndexed(Sp, p2 div 16);
              WordAt[Addr] := WordAt[Addr] or (1 shl (p2 mod 16));
              inc(p2);
            end;
          Push(Size);
        end
    end
  else
    begin
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('Set size > 512: (p1=%d, p2=%d): ', [p1, p2]);
    end;
end;


Procedure TCPsystemInterpreter.SGS;  {build singleton set, the set [i]}
{ SGS is generated by the following construct:
              if c in [chr(8),'0'..'9'] then;  }
var
  BitNr: word;
  Size, i: integer;
  addr: word;
Begin
  BitNr := Pop();
  if (BitNr < 512) then
    begin
      Size := (BitNr + 16) div 16;
      for i := 0 to Size-1 do
        Push(0);
      Addr := WordIndexed(Sp, BitNr div 16);
      WordAt[Addr] := WordAt[Addr] + (1 shl (BitNr mod 16));
      Push(Size);
    end
  else
    begin
//    raise EXEQERR.Create('Invalid set index: %d', [BitNr], INVNDXC);
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('Invalid set index: %d', [BitNr]);
    end;
end;

Procedure TCPsystemInterpreter.INN;
var
  Size: word;
  Addr: word;
  Val: word;
  Mask: word;
  W: word;
Begin
  Size := Pop();
  Addr := Sp;
  Sp   := WordIndexed(Sp, Size);
  Val  := Pop();
  if (Val >= (16 * Size)) then // sets may not exceed 256 bits
    Push(false)
  else
    begin            // This can be simplified
      Mask := (1 shl (Val mod 16));   // for the bit of interest
      W    := WordAt[WordIndexed(Addr, (Val div 16))];  // get the word containing that bit
      W    := W and Mask;
      Push(W <> 0);
    end;
end;


procedure TCPsystemInterpreter.LAE;
var
  p1: word;
begin
  p1 := FetchUB();
  Push(ExternalAddr(FetchB(), p1));
end;

Procedure TCPsystemInterpreter.LSA; {166: V2.0 load string address}
begin
  Push(WordIndexed(IpcBase, Ipc div 2));  // Push the address
  Ipc := Ipc + FetchUB();
end;

Procedure TCPsystemInterpreter.LCA; {166: V1.4, V1.5 load constant address}
var
  Len: word;
begin   // NOTE: The above code (for LSA) would probably work here
  Push(IpcBase + IPC);   // save the address of the (inline) string constant
  Len := FetchUB();      // get the length
  Assert(not Word_Memory);
  Ipc := Ipc + Len;      // skip over the string
end;


Procedure TCPsystemInterpreter.IXS;   {index string pointer}
{given index, ^string, compute ^string[index]}
var
  p1, p2, B: word;
Begin
  p1 := Pop();         // get index
  p2 := Pop();         // ^string
  if Word_Memory then  // we can just leave the index on the stack
    begin
      Push(p2);
      Push(p1);
    end
  else
    Push(p2+p1);       // otherwise we have to add them and push the result

//Push(p1);
  B  := MemRdByte(p2, 0);
  if (p1 > B) then
    begin
//    raise EXEQERR.Create('Invalid index. %d > %d', [p1, B], INVNDXC);
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('Invalid index. %d > %d', [p1, B]);
    end;
end;

{$IfDef debugging}
(*
Procedure TCPsystemInterpreter.ShowSegInfo;
var i:integer;
    Line: string;
    SegName: string[8];
Begin
//with frmPsysWindow do
    begin
      fMemo.Lines.Add('SEGMENT DICTIONARY');
      fMemo.Lines.Add('------- ----------');
      Line := Format('%8s%10s%8s%8s%8s', ['SEG', 'SegName', 'UNIT', 'LENGTH', 'BLOCK'{, 'KIND', 'TEXT'}]);
      fMemo.Lines.Add(Line);
      for i := 0 to MAXSEG do
        begin            // also DiskInfo, SegNamesII, SEGKIND, SegNamesII
          With SysComIIPtr^.SEGTBL[i] do
            if (CodeLeng > 0) and (DiskAddr > 0) then
              Begin
                with sd.DICT do  // assumes that it is still loaded
                  begin
                    SegName := SegNamesII[i];
                    Line := Format('%8d%10s%8d%8d%8d',
                                   [i, SegName, codeunit, codeleng, Diskaddr
                                    {, SegKind[i], TEXTADDR[i]}
                                   ]);
                  end;
                fMemo.Lines.Add(Line);
              end;
        end;
      FmEMO.Lines.Add('')
    end;
end;
*)
(*
Procedure TCPsystemInterpreter.ShowProcDict(a:word; ToWindow: boolean);
const
  OUTLFN = 'c:\temp\ProcDict.text';
var i:integer;
    loc:word;
    hex : string;
    OutFile: TextFile;
    Line: string;
    PDCount: integer;
Begin
//ShowStack(a,20);
  {a points to byte past end of code just loaded..so A := A - 1 gives the pdcount}
  {no ..a points to byte past code just loaded so inc(a,1)   !!! LB 12/11/2004}
  LOC     := a+1;   {not PRED(a);}
  PDCOUNT := Bytes[LOC];
  LOC     := PRED(LOC); {point at segment #}

  if ToWindow then
   with fMemo.Lines do
    begin
      Add( 'PROCEDURE DICTIONARY:');
      Add( '---------------------');
      Add('');
      Line := Format('SEGMENT %D @ $%4.4X (%4D)', [Bytes[Loc], Loc, Loc]);
      Add(Line);
      Line := Format('PROCEDURE COUNT %D', [PDCOUNT]);
      Add(Line);
      Add('');
      FOR I := 1 TO PDCOUNT DO
        BEGIN
          LOC := LOC-2;

          {the Integer() type cast is to stop a RTE when all range checking is turned on}
          PD[I] := LOC-WordAt[LOC];

          Hex   := HEXWORD(PD[I]);
          Line  := Format('PROCEDURE %2d, Address %5d (%-4.4x) %4.4x',
                         [I, PD[i], PD[i], Bytes[Loc]]);
          Add(Line);
        END;
    end
  else
    begin
      AssignFile(OutFile, OUTLFN);
      ReWrite(OutFile);
      WRITELN(OutFile, 'PROCEDURE DICTIONARY:');
      WRITELN(OutFile,  '---------------------');
      WRITELN(OutFile);
      Hex := HEXWORD(Loc);
      WRITELN(OutFile, 'SEGMENT ', Bytes[LOC], ' @ $', Hex);
      WRITELN(OutFile, 'PROCEDURE COUNT ', PDCOUNT);
      WRITELN(OutFile);
      FOR I := 1 TO PDCOUNT DO
        BEGIN
          LOC := LOC-2;

          {the Integer() type cast is to stop a RTE when all range checking is turned on}
    //        PD[I] := LOC-(Bytes[LOC] + Bytes[loc+1]*256);
          PD[I] := LOC-WordAt[LOC];

          Hex := HEXWORD(PD[I]);
          WRITELN(OutFile, 'PROCEDURE ',
                    RZero(I,2),
                    ', ADDRESS ',
                    RZero(PD[I],5),
                    ' (',
                    HEX,
                    ') ',
                    WordAt[LOC]:6 {Bytes[LOC]+Bytes[loc+1]*256:6});
        END;
      CloseFile(OutFile);
      EditTextFile(OUTLFN);
    end;
end;
*)
{$EndIf debugging}

{***************** JUMPS ********************}




Procedure TCPsystemInterpreter.UJP; {Unconditional jump}
const
  SLDC_1 = 1;
  FJP    = 161;
var
  w: word;
Begin
{$R-}
  w := jump(ShortInt(FetchUB()));  // 12/19/2023
{$R+}
  if ((Ipc - w = 5) and (* check for endless loop *)
      (MemRdByte(IpcBase, w) = SLDC_1) and
      (MemRdByte(IpcBase, w + 1) = FJP) and
      (MemRdByte(IpcBase, w + 2) = 2)) then
    sleep(1); {* reduce processor load *}
  Ipc := w;
end;

{*
 * calculates the target address of a jump operation. Positive
 * displacements perform relative jumps, negative displacements are
 * used as indices into the jump table.
*}
function TCPsystemInterpreter.jump(disp: shortint): word;
begin
  if (disp >= 0) then
    begin
      result := (Ipc + disp);
      Exit;
    end;

  disp := -disp;

(*
  OutputDebugStringFmt('jtab=%4.4x, Disp=%4.4x, WordIndexed(JTab, -1)=%4.4x, MemRd(JTab - Disp)=%4.4x',
                       [jtab,       Disp,       WordIndexed(JTab, -1),       MemRd(JTab - Disp)]);
*)
  try
    if Word_Memory then
      result := (MemRd(WordIndexed(JTab, -1)) + 2 - (MemRd(JTab - disp div 2) + disp))
    else
{$R-}
      // The following code gets a RCE in the p-System when compiling using the VI.4 PM version
      result := (MemRd(WordIndexed(JTab, -1)) + 2 - (MemRd(JTab - disp) + disp));
{$R+}
  except
    on e:Exception do
      OutputDebugString(pchar(e.message));
  end;
end;


Procedure TCPsystemInterpreter.FJP;
const
  SLDC_0 = 0;
var
  p1: byte; // 1/9/2024: word --> byte
  w: word;
  b: boolean;
Begin
  p1 := FetchUB();
  w  := Pop();
//b  := Boolean(w);
  b  := (w and 1) <> 0;  // This is what the C Interpreter function "Boolean" does
  if not b then
    Begin
{$R-}
      w := jump(ShortInt(p1));
{$R+}
      if ((Ipc - w = 3) and {* check for endless loop *}
          (MemRdByte(IpcBase, w) = SLDC_0)) then
        sleep(1); (* reduce processor load *)

      Ipc := w;
    end;
end;

// Equal False Jump
procedure TCPsystemInterpreter.EFJ();
var
  p1: byte;
begin
{$R-}   // If greater than 127, it will be treated like a negative integer by "jump"
  p1 := FetchUB();
  if (Pop() <> Pop()) then
    Ipc := jump(p1);
{$R+}
end;

// Not False Jump
procedure TCPsystemInterpreter.NFJ();
var
  p1:  byte;
begin
{$R-}   // If greater than 127, it will be treated like a negative integer by "jump"
  p1 := FetchUB();
  if (Pop() = Pop()) then
    Ipc := jump(p1);
{$R+}
end;


function TCPsystemInterpreter.FetchW(): word;
var
  w: word;
begin
  w := MemRdByte(IpcBase, Ipc); IPC := IPC + 1;;             // get the low byte
  w := w + (MemRdByte(IpcBase, Ipc) shl 8); IPC := IPC + 1;; // merge with the high byte
  result := w;
  // Can I just do: w := WordAt[ByteIndexed(IpcBase)+Ipc]; ??
  // No. I don't think so.
end;


Procedure TCPsystemInterpreter.XJP;    {case jump}
{ index is (Sp).  In the code starting on a word boundary are 3 words...
                  MIN index for table
                  MAX index
                  else jump (point ipc here if index out of table range)
                  .... and the case table jump addresses
}
var
  lo, hi, value: integer;
Begin
  Ipc := (Ipc + 1) and (not 1);    // force to an even address
  {* FIXME: should these be "native" word fetches? *}
{$R-}
  lo    := FetchW();
  hi    := FetchW();
{$R+}
  value := PopInt();
  if ((value >= lo) and (value <= hi)) then
    begin
      Ipc := Ipc + 2 * (value - lo) + 2;
      Ipc := Ipc - WordAt[WordIndexed(IpcBase, Ipc div 2)];
    end;
end;

// ALL DEBUGGING !!!
(*
procedure TCPsystemInterpreter.PopBase(aBase, aKp, aBaseMp: word);
var
  ErrCnt: word;
  cpn: word;

  function CallingProcNr(): word;
  var
    jt: word;
  begin
    jt     := WordAt[WordIndexed(MP, MS_JTABw)];
    result := Bytes[jt];
  end;

  function CallingIPC(): word;
  var
    jt: word;
  begin
    result := WordAt[WordIndexed(Mp, MS_IPCw)];
  end;

begin { PopBase }
  ErrCnt := 0;
  fBaseStackTop := fBaseStackTop - 1;
  with fBaseStack[fBaseStackTop] do
    begin
      if aBase <> TheBase then
        Inc(ErrCnt);
      if aBaseMp <> TheBaseMp then
        Inc(ErrCnt);
      // Keep track of who called it
      ExitProcNum := CurProc;
      ExitIPC     := IPC;
    end;
end;  {PopBase }

// all debugging
procedure TCPsystemInterpreter.PushBase(aBase, aKp, aBaseMp: word);
begin
  inc(fNrPushes);
  with fBaseStack[fBaseStackTop] do
    begin
      TheBase      := aBase;
      TheBaseMp    := aBaseMp;
      // Keep track of who pushed it
      EntryProcNum := CurProc;
      EntryIPC     := IPC;
    end;
  fBaseStackTop := fBaseStackTop + 1;
end;
*)

{*************** PROCEDURE CALLING AND RETURNING *************}

Procedure TCPsystemInterpreter.RBP;   {return from base procedure}
//var
//MSCWPtr2: TMSCWPtr2;  // debugging
//temp: string;
//cpn: word;

Begin
//temp     := MemDumpDF(0, 'R');
//MSCWPtr2 := TMSCWPtr2(@Bytes[ByteIndexed(Mp)]);  // debugging
//SP       := MSCWPtr2^.LocalData[0];              // debugging
  Sp   := WordAt[WordIndexed(Mp, MS_SPw)];
  Base := Pop();

  SysComIIPtr^.STKBASE := Base;

  if ((Base < Kp) or (Base > BaseMp)) then
    raise Exception.CreateFmt('RBP: Base $%04x out of range ($%4x .. $%4x)', [Base, Kp, BaseMp]);

  ret(FetchUB());

//PopBase(Base, Kp, BaseMp);
end;

procedure TCPsystemInterpreter.CspUnloadSegment(SegNo: byte);
{$IfDef debugging}
var
  SegInfoRecP: TSegInfoRecP;
  FileName: string;
{$EndIf debugging}
begin
  Assert(SegDict[SegNo].UseCount > 0);
  Dec(SegDict[SegNo].UseCount);
  if (SegDict[SegNo].UseCount = 0) then
    begin
      Kp := SegDict[SegNo].OldKp;
      SegDict[SegNo].OldKp  := 0;
{$IfDef debugging}
      NoteSegTopChange('CspUnloadSegment', 'Unknown', SegDict[SegNo].SegTop, 0);
      // Remove the segment from fFilesLoadedList
      SegInfoRecFromSegTop(  SegDict[SegNo].SegTop,
                             SegInfoRecP,
                             FileName);
      if Assigned(SegInfoRecP) then
       with SegInfoRecP^ do
         begin
           TheREFCOUNT  := 0;
           TheSEGTOP    := 0;  // ^byte PAST end of segment code !! (or is it?)
           TheSEGNAME   := '';
         end;
{$endIf}
      SegDict[SegNo].SegTop := 0;
    end;
end;


procedure TCPsystemInterpreter.Ret(n: byte);
var
  OldMp, OldSegNo: word;
begin
  OldMp    := Mp;
  OldSegNo := SegNumber(SEGP);

  while (n > 0) do
    begin
      Push(WordAt[LocalAddr(n)]);
      Dec(n);
    end;

  Kp      := WordAt[WordIndexed(OldMp, MS_KPw)];
  Mp      := WordAt[WordIndexed(OldMp, MS_DYNw)];
  JTab    := WordAt[WordIndexed(OldMp, MS_JTABw)];
  IpcBase := ProcBase(JTab);
  SEGP    := WordAt[WordIndexed(OldMp, MS_SEGw)];
  Ipc     := WordAt[WordIndexed(OldMp, MS_IPCw)];

//with SysComIIPtr^ do
//  begin
//    SysComIIPtr^.LASTMP := Mp;  // This is redundant
      SysComIIPtr^.SEG  := SEGP;
//    SysComIIPtr^.JTAB := JTab;  // This is redundant.
//  end;

  if (OldSegNo <> SegNumber(SEGP)) then
    if (OldSegNo<>0) then (* Segment 0 is not managed. *)
      CspUnloadSegment(OldSegNo);
  Dec(Level);
  StackCheck();
end;

function TCPsystemInterpreter.ProcExitIpc(Jtab: word): word;
begin
  PointerCheck(JTab);
  result := WordAt[WordIndexed(JTab, -1)] - WordAt[WordIndexed(JTab, -2)] - 2;
end;

Procedure TCPsystemInterpreter.UCSDExit;
{exit a specified procedure. Make IPC of current proc point to exit code
 if current proc is the one to exit then jump GetSavedIPC
 otherwise....
 calculate parent of (BASE), ie MSCW of PROGRAM pascalsystem,
 IPC := (Mp)
 Repeat
   if IPC=system MSCW then die for exiting proc not called
   change IPC of this MSCW to point to exit code for proc
   done := proc and seg of this MSCW match passed params
   IPC:=MSDYN(IPC)
 until done
}
var
  ProcNo:   word;
  SegNo:    word;
  xMp:      word;
  xSeg:     word;
  xJTab:    word;
Begin
  ProcNo := Pop();
  SegNo  := Pop();
  xMp    := Mp;
  xSeg   := SEGP;
  xJTab  := JTab;

  Ipc := ProcExitIpc(xJTab);
  while ((ProcNumber(xJTab) <> ProcNo) or
         (SegNumber(xSeg) <> SegNo)) do
    begin
      xJTab := WordAt[WordIndexed(xMp, MS_JTABw)];
      xSeg  := WordAt[WordIndexed(xMp, MS_SEGw)];
      if (xMp = 0) or
         (xJTab = 0) or
         (xSeg = 0) then
        raise ENOEXIT.CreateFmt('No exit. S#%d, P#%d', [SegNo, ProcNo]);

      WordAt[WordIndexed(xMp, MS_IPCw)] := ProcExitIpc(xJTab);
      xMp := WordAt[WordIndexed(xMp, MS_DYNw)]; // follow the dynamic link chain
    end;
end;

procedure TCPsystemInterpreter.SLDC;
begin
  PUSH(fOpCode) {0..127}
end;

function TCPsystemInterpreter.FinalException(const Msg, TheClassName: string): TBrk;
var
  FullMsg: string;
begin
  FullMsg := Format('%s (%s): Segment:%d, ProcNum:%d, RelIPC:%d',
                        [Msg, TheClassName, SegNum, CurProc, RelIPC]);
{$IfDef debugging}
  if Assigned(frmPCodeDebugger) then
    frmPCodeDebugger.fExceptionMessage := FullMsg
  else
    Alert(FullMsg);
{$Else}
//raise Exception.CreateFmt('%s (%s): Segment:%d, ProcNum:%d, RelIPC:%d',
//                                             [Msg, TheClassName, SegNum, CurProc, RelIPC]);
  Alert(FullMsg);
{$EndIf debugging}
{$IfDef LogRuns}
  with fFiler as TfrmFiler do
    SetLastError(FullMsg);
{$endIf}
  result := dbException;
end;

procedure TCPsystemInterpreter.load(UnitNr: word; BlockNo, MaxBlock: word; const FileName: string);
var
  sn: integer;
  aCodeAddr   : word;
  CodeAddr    : word;
  aCodeLeng   : word;
//aSegInfo    : word;
//SegNo       : word;

   (*
   * Segment 0 is split, and the pointers in the Procedure Dictionary have
   * been corrected so that after loading the two halves correctly to the
   * respective "correct" the address pointer is.
   *
   * This routine corrects the pointer in the segment dictionary.  In
   * addition, it determines the first address, in which the second half
   * really should be loaded.  Then an offset is determined by the pointers
   * must be corrected in the second half.
   *)

  procedure FixupSeg0(LoadAddr: word);
  var
    SegTop, SegBase, Addr, Offset, JTab: word;
    i: integer;
  Begin
    SegTop  := SegDict[0].SegTop;
    SegBase := SegDict[0].SegBase;

    Addr := 0;

    for i := 1 to SegNumProc(SegTop)-1 do
      Begin
        JTab := Proc(SegTop, i);
        if ((JTab < SegBase) and (JTab > Addr)) then
          Addr := JTab;
      End;

    if Addr = 0 then
      Exit; (* no Fixup needed *)

    Addr   := WordIndexed(Addr, 1);
    Offset := LoadAddr - Addr;

    if (Offset = 0) then
      Exit;

    for i := 1 to SegNumProc(SegTop)-1 do
      Begin
        JTab := Proc(SegTop, i);
        if (JTab < SegBase) then
          Begin
            Addr := WordIndexed(SegTop, -i);
            if Word_Memory then
              WordAt[Addr] := WordAt[Addr] - (2 * Offset)
            else
              WordAt[Addr] := WordAt[Addr] - Offset;
          End;
      End;
  End;

var
//BitNr: byte;
//MType: word;
  aSegName: TString8;
  SDAddr: word;
//major_version: byte;
Begin { Load }
//  Reminder: The C interpreter puts the stack in low memory and the heap in high memory!
  SysRd(Unitnr, Np,    BLOCKSIZE, BlockNo);    // Load the segment dictionary
{$IfDef Debugging}
  SaveSegInfoForFile(UnitNr, BlockNo, BLOCKSIZE, FileName, SDRecordPtr(@Bytes[ByteIndexed(Np)])^, MaxBlock);
//DumpDebugInfoExt('After Load calls SysRd on segment dictionery');
{$EndIf Debugging}

  if SysComIIPtr^.IORSLT <> INOERROR then
    exit;

  (* Create the Segment Dictionary *)
  SDAddr := ByteIndexed(WordIndexed(Np, 0));  // point to the just loaded segment dictionary
                                              // Np*2 to make it a byte address
  for sn := 0 to 16-1 do                      // Using MAXSEG causes problems on some code files
                                              // (probably just VII_1 code files which have 32 segments)
    Begin
      with SDRecordPtr(@Bytes[SDAddr])^ do
        begin
          CodeAddr  := DiskInfo[sn].CODEaddr;
          aCodeAddr := CodeAddr + BlockNo;         // add in start of file
          aCodeLeng := DiskInfo[sn].CODEleng;      // always in bytes (for version I.4, I.5, II.0)
//        BitNr     := 0;
//        aSegInfo  := SegInfo[sn].SegInfo;
//        SegNo     := Bits(aSegInfo, BitNr, 8);   // bits 0..7
//        MType     := Bits(aSegInfo, BitNr, 4);   // bits 8..11
//        BitNr     := 13;
//        major_version := Bits(aSegInfo, BitNr, 3); // bits 13..15
          aSegName  := SegNamesII[sn];
        end;

      Assert(not odd(aCodeLeng));

      if (CODEaddr <> 0) and (aCodeLeng <> 0) then
        Begin
//        if MType <> 0 then               // (SegInfo & 0x0f00) <> 0
                                           // 10/21/2022: The UCSDII0 boot did not have anything in the SegInfo field
            Begin
//            with SysComIIPtr^.SEGTBL[SegNo] do
              with SysComIIPtr^.SEGTBL[sn] do // 10/21/2022: The UCSDII0 boot did not have anything in the SegInfo field (i.e. SegNo)
                begin
                  CODEUNIT := UnitNr;
                  DISKADDR := aCodeAddr;
                  CODELENG := aCodeLeng;   // The length in bytes !
                end;
            End;

//        if (SegNo = 0) then  // This may relate to version II_1
          if (sn = 0) then
            Begin
              with SegDict[0] do
                if UseCount = 0 then
                  Begin
                    Inc(UseCount);
                    OldKp  := Kp;
                    SegTop := WordIndexed(Kp, -1);   // SegTop?

                    if Word_Memory then
                      Kp    := Kp - aCodeLeng div 2      // adjust by proper number of words
                    else
                      Kp    := Kp - aCodeLeng;           // adjust by proper number of bytes

                    {SegDict[0].}SegBase := Kp;

                    SysRd(UnitNr, Kp, aCodeLeng, aCodeAddr); // load the segment
//                  Sp := WordIndexed(SegBase, -1);
{$IfDef Debugging}
                    UpdateSegInfo(sn, SegTop, SegBase, aCodeLeng, UnitNr, aCodeAddr, aSegName);
{$EndIf Debugging}
                  End
                else
                  Begin
                    UnTested('load - UseCount > 0', FALSE);
                    FixupSeg0(Kp);

                    if Word_Memory then
                      Kp := Kp - aCodeLeng div 2      // adjust by proper number of words
                    else
                      Kp := Sp - aCodeLeng;          // adjust by proper number of bytes

                    SysRd(UnitNr, Kp, aCodeLeng, aCodeAddr);  // Load the segment
//                  Sp := WordIndexed(SegBase, -1);
                  End;
            End;
        End;
    End;
End;  { Load }




Procedure TCPsystemInterpreter.Init;
Begin
  with SysComIIPtr^ do
    begin
      GDIRP  := pNIL;   {NIL ie directory not loaded..should be nil to start}
      IORSLT := INOERROR;
    end;
end;

Procedure TCPsystemInterpreter.ShowSizes;
Begin
  with frmPSysWindow do
    begin
      Writeln('STRUCTURE  SIZE (in bytes)');
      writeln(['aword    = ',sizeof(aword)]);
      writeln(['sdrecord = ',sizeof(sdrecord)]);
      writeln(['freeunion= ',sizeof(freeunion)]);
      writeln(['TOprec    = ',sizeof(TOprec)]);
      writeln(['diskinfo = ',sizeof(sd.Dict.diskinfo)]);
      writeln(['Segname  = ',sizeof(sd.dict.SegNamesII)]);
      writeln(['SegKind  = ',sizeof(sd.dict.SegKind)]);
      writeln(['SegInfo  = ',sizeof(sd.dict.SegInfo)]);
      writeln(['TUTablEntryII = ', SizeOf(TUTablEntryII)]);

      {check UCSD GLOBALS}
      Writeln('UCSD 1.5 global stuff...');
      writeln(['daterec  = ', sizeof(daterec)]);
      writeln(['unitnum  = ', sizeof(unitnum)]);
      writeln(['direntry = ', sizeof(direntry)]);
      WriteLn(['TFIB2    = ', sizeof(TFIB2)]);
//    WriteLn(['SysComII = ', SizeOf(TIISysComRec)]);
      Writeln;
    end;
end;


Function TCPsystemInterpreter.CheckSizes:Boolean;
{check structure sizes}
var Errors:integer;
Begin
  Errors := 0;
  if sizeof(aword)           <>   2 then inc(errors);
  if MAXSEG = 15 then
    begin
      if sizeof(sdrecord)        <> 288 then inc(errors);
      if sizeof(freeunion)       <> 512 then inc(errors);
      if sizeof(sd.dict.SegNamesII) <> 128 then inc(errors);
      if sizeof(sd.dict.SegKind) <>  32 then inc(errors);
      if sizeof(sd.dict.SegInfo) <>  32 then inc(errors);
    end
  else if MAXSEG = 31 then
    begin
      if sizeof(sdrecord)        <> 576 then inc(errors);
      if sizeof(freeunion)       <> 576 then inc(errors);
      if sizeof(sd.dict.SegNamesII) <> 256 then inc(errors);
      if sizeof(sd.dict.SegKind) <>  64 then inc(errors);
      if sizeof(sd.dict.SegInfo) <>  64 then inc(errors);
    end
  else
    inc(errors);

  if sizeof(TOprec)           <>  12 then inc(errors);
  if sizeof(sd.Dict.diskinfo)<>  64 then inc(errors);
  if sizeof(TUTablEntryII)   <> 12  then inc(errors);

  {check UCSD GLOBALS}
  if sizeof(daterec)         <>   2 then inc(errors);
  if sizeof(unitnum)         <>   2 then inc(errors);
  if sizeof(direntry)        <>  26 then inc(errors);
//if SizeOf(TIISysComRec)    <> SYSCOM_SIZE then inc(Errors);
//if Sizeof(TFIB2)           <> 580 then inc(errors);    // Is this really needed?
  CheckSizes := errors=0;
end;

(* ========== MAIN BODY ========== *)

constructor TCPsystemInterpreter.Create(aOwner: TComponent;
              VolumesList: TVolumesList;
              thePSysWindow: TfrmPSysWindow;
              Memo: TMemo;
              TheVersionNr: TVersionNr;
              TheBootParams: TBootParams);
begin
  inherited;

  Initialize_Interp;

  Word_Memory := TheVersionNr = vn_VersionII;

  if Word_Memory then
    begin
      GetMem(bytes, LOW128K);       // version II can access 128Kb (= 64Kb words)
      FillChar(Bytes^, LOW128K, 0); // initialize memory to all 0
    end
  else
    begin
      GetMem(bytes, LOW64K);        // version I.4, I.5 can only access 64Kb
      FillChar(Bytes^, LOW64K, 0);  // initialize memory to all 0
    end;

  move(bytes, Words, 4);    // access either as words or bytes
  move(bytes, Globals, 4);  // access to other (non-Syscom) stuff-- notice that Globals INCLUDES Syscom

  byte_sex := bs_LITTLE_ENDIAN;       // for now.

{$IfDef debugging}
  MemDumpDFWB(0, 0, '');             // force the linker to include this
{$EndIf}
end;

procedure TCPsystemInterpreter.load_system(var root_unit: integer; const file_name: string);
var
  UnitNr     : integer;
  FirstBlk   : integer;
  MaxBlocks  : integer;
  InBufPtr   : TInBufPtr;
begin
  UnitNr    := root_unit;
  try
    FirstBlk  := FindFileFirstBlockOnUnit(file_name, UnitNr);
  except
    // If it is not on this volume, it might be on some other
    FirstBlk  := 0;
  end;

  if FirstBlk > 0 then
    UnitNr := root_unit
  else
    begin
      for UnitNr := 4 to MAX_STANDARD_UNIT do
        with fVolumesList[UnitNr] do
          if Assigned(TheVolume) then
            begin
              FirstBlk  := FindFileFirstBlockOnUnit(file_name, UnitNr);
              if FirstBlk <> 0 then
                begin
                  root_unit := UnitNr;
                  break;
                end
            end;
    end;

  MaxBlocks := fVolumesList[root_unit].TheVolume.VolumeBlocks;

  if (FirstBlk = 0) or (root_unit = 0) then
    raise EFileNotFound.CreateFmt('File "%s" was not found', [file_name]);

  Load(UnitNr, FirstBlk, MaxBlocks, file_name);

  if SysComIIPtr^.IORSLT <> INOERROR then
    raise EFileNotFound.CreateFmt('File "%s" was not found', [file_name]);

  if (SegDict[0].UseCount = 0) then
    raise Exception.CreateFmt('file "%s": not a valid system, no segment 0"', [file_name]);

  Init;

  InBufPtr := TInBufPtr(@Bytes[ByteIndexed(SyscomAddr)]);

  LoadMiscInfo(fVolumesList[Unitnr].TheVolume, CSYSTEM_MISCINFO, InBufPtr^);

  with frmPSysWindow do  // 5/17/2023
    begin
      LoadCrtKeyInfo(InBufPtr, CrtInfo, KeyInfo, VersionNr);
      CrtInfo.TermType := FilerSettings.TermType;
      CrtInfo.InfoChanged;
    end;

  call(SegDict[0].SegTop, 1, pNil);

end;


procedure TCPsystemInterpreter.Load_PSystem(UnitNr: word);
begin
  inherited;
  fBootUnit := UnitNr;

  inittime;
  HEXDIGIT := '0123456789ABCDEF';
  Flip     := False;

  {now check structure sizes to match UCSD sizes}

  If Not CheckSizes then
    ShowSizes;

  Np     := HEAP_BOT;
  Kp     := KP_TOP; // memtop;
  Kp     := WordIndexed(Kp, -SYSCOM_SIZE);
  SyscomAddr := Kp;
  Sp     := SP_TOP;
  Mp     := Kp;

  with SysComIIPtr^ do
    begin
      Fillchar(segtbl, sizeof(segtbl),chr(0));
      SysUnit := UnitNr;
    end;

  load_system(fBootUnit, CSYSTEM_PASCAL);

  BaseMp := Mp;
  Sp     := WordIndexed(Sp, 1);
  WordAt[LocalAddr(1)] := SyscomAddr;
END;

function TCPsystemInterpreter.GetCurProc: word;  // this duplicates ProcNum !
begin
  if JTab <> 0 then
    result := WordAt[JTab] and $FF
  else
    result := fCurProc;
end;

{$IfDef Debugging}
function TCPsystemInterpreter.SegIdxFromName(const aSegName: string): TSegNameIdx;
var
  idx: integer;
begin
  result := sn_Unknown;
  if (aSegName <> '') and (SegNamesInDB.Count > 0) then
    begin
      idx := SegNamesInDB.IndexOf(aSegName);
      if Idx >= 0 then
        result := Integer(SegNamesInDB.Objects[idx])
    end
end;
{$endIf Debugging}

{$IfDef debugging}

function TCPsystemInterpreter.ProcName(MsProc: word; aSegTop: longword): string;
var
  aSegName: string;
  aSegNameIdx : TSegNameIdx;
//AccDbNr: integer;
begin
  aSegName    := SegNameFromBase(aSegTop);
//with frmPCodeDebugger do
//  aSegNameIdx := TheSegNameIdx(SegBase);  // this seems redundant
  aSegNameIdx := SegIdxFromName(aSegName);
  if aSegNameIdx >= 0 then
    result := Format('%s.%s', [aSegName, ProcNamesInDB[aSegNameIdx, MsProc]])
  else
    result := 'Unknown';
end;

{$Else not debugging}

function TCPsystemInterpreter.ProcName(MsProc: word; aSegTop: longword): string;
begin
  result   := Format('Proc%-2d', [MsProc]);
end;

{$EndIf debugging}

procedure TCPsystemInterpreter.SYSHALT;
begin
//raise ESYSTEMHALT.Create('SYSHALT: Opcode = ');
  HaltPSys('SYSHALT')
end;


procedure TCPsystemInterpreter.InitJumpTable(InterpreterOpsTable: TCustomOpsTable);
var
  i: integer;
begin { INITJUMPf/TABLE }
  inherited;

  with InterpreterOpsTable as TCustomOpsTable do
    begin
      for i := 0 to HIGHPCODE do with Ops[i] do begin Name  := ''; {Range := [];} ProcCall := nil end;

      AddOp('SLDC', [0..127], SLDC);     { Load constant value }
      AddOp('ABI', [128], ABI);          { absolute value }
      AddOp('ABR', [129], ABR);          { absolute value of real tos ..leaves result on stack }
      AddOp('ADI', [130], ADI);          { add integers }
      AddOp('ADR', [131], ADR);          { add reals tos and nos....leaves result on stack }
      AddOp('LAND', [132], LAND);        { logical AND }
      AddOp('DIF', [133], DIF);          { {set Difference .. AND(NOT set_b) into set a. }
      AddOp('DVI', [134], DVI);          { divide integers }
      AddOp('DVR', [135], DVR);          { divide reals nos by tos....leaves result on stack }
      AddOp('CHK', [136], CHK);          { range check }
      AddOp('FLO', [137], FLO);          { Pop real off stack, Pop integer, float it, push it, push real }
      AddOp('FLT', [138], FLT);          { Pop integer off stack 2 bytes, and push real 4bytes }
      AddOp('INN', [139], INN);          { see if integer tos-1 is in set tos }
      AddOp('INT', [140], INT);          { Set intersection. AND set_b into set_a, then zero-fill }
      AddOp('LOR', [141], LOR);          { logical or }
      AddOp('MODI', [142], MODI);        { remainder of integer division }
      AddOp('MPI', [143], MPI);          { integer multiply }
      AddOp('MPR', [144], MPR);          { mult reals tos and nos....leaves result on stack }
      AddOp('NGI', [145], NGI);          { negate integer }
      AddOp('NGR', [146], NGR);          { negate value of real tos }
      AddOp('LNOT', [147], LNOT);        { logical not }
      AddOp('SRS', [148], SRS);          { build a subrange set, the set [i..j] }
      AddOp('SBI', [149], SBI);          { subtract integer }
      AddOp('SBR', [150], SBR);          { subtract tos from nos....leaves result on stack }
      AddOp('SGS', [151], SGS);          { build singleton set, the set[i] }
      AddOp('SQI', [152], SQI);          { integer square }
      AddOp('pSQR', [153], pSQR);        { square reals tos ....leaves result on stack }
      AddOp('STO', [154], STO);          { store indirect }
      AddOp('IXS', [155], IXS);          { index string pointer }
      AddOp('UNI', [156], UNI);          { set union from z80...works fine }
      AddOp('LDE', [157], LDE);          { Load external }
      AddOp('CSP', [158], CSP);          { Call Standard Procedure }
      AddOp('LDCN', [159], LDCN);        { Load constant nil pointer }
      AddOp('ADJ', [160], ADJ);          { adjust set tos to occupy UB wordS }
      AddOp('FJP', [161], FJP);          { False JumP }
      AddOp('INC', [162], INCR);         { increment (Sp) by literal }
      AddOp('IND', [163], IND);          { Static index and load word (was STIND) }
      AddOp('IXA', [164], IXA);          { index array }
      AddOp('LAO', [165], LAO);          { load global address }
//    AddOp('LSA', [166], LSA);          { load string address }
//    AddOp('LAE', [167], LAE);          { load address extended }
      AddOp('MOV', [168], MOV);          { move words }
//    AddOp('LDO', [169], LDO);          { load global word }
      AddOp('SAS', [170], SAS);          { String assignment }
      AddOp('SRO', [171], SRO);          { store global word }
      AddOp('XJP', [172], XJP);          { case jump }
      AddOp('RNP', [173], RNP);          { return from normal procedure }
      AddOp('CIP', [174], CIP);          { call intermediate procedure }
      AddOp('EQU', [175], EQU);          { = }
      AddOp('GEQ', [176], GEQ);          { >= }
      AddOp('GRT', [177], GRT);          { > }
      AddOp('LDA', [178], LDA);          { load intermediate address }
      AddOp('LDC', [179], LDC);          { Load multiple word constant..const is backwards in code stream and is word aligned }
      AddOp('LEQ', [180], LEQ);          { LEQ: less or equal }
      AddOp('LES', [181], LES);          { LES: LESs }
      AddOp('LOD', [182], LOD);          { load intermediate word }
      AddOp('NEQ', [183], NEQ);          { NEQ: not equal }
      AddOp('STR', [184], STRI);         { store intermediate word }
      AddOp('UJP', [185], UJP);          { unconditional jump }
      AddOp('STP', [186], LDP);          { load a packed field }
      AddOp('STP', [187], STP);          { Store into a packed field }
      AddOp('LDM', [188], LDM);          { Load multiple words (no more than 255) }
      AddOp('STM', [189], STM);          { Store multiple words (no more than 255) }
      AddOp('LDB', [190], LDB);          { load byte }
      AddOp('STB', [191], STB);          { store byte }
      AddOp('IXP', [192], IXP);          { Index a packed array }
      AddOp('RBP', [193], RBP);          { return from base procedure }
      AddOp('CBP', [194], CBP);          { call base procedure }
      AddOp('EQUI', [195], EQUI);        { =  }
      AddOp('GEQI', [196], GEQI);        { >= }
      AddOp('GRTI', [197], GRTI);        { > }
      AddOp('LLA', [198], LLA);          { load local address }
      AddOp('LDCI', [199], LDCI);        { Load constant word }
      AddOp('LEQI', [200], LEQI);        { <= }
      AddOp('LESI', [201], LESI);        { < }
      AddOp('LDL', [202], LDL);          { load local word }
      AddOp('NEQI', [203], NEQI);        { compare for <> }
      AddOp('STL', [204], STL);          { store local word }
      AddOp('CXP', [205], CXP);          { call external (different segment) procedure }
      AddOp('CLP', [206], CLP);          { call local procedure }
      AddOp('CGP', [207], CGP);          { call global proc }
   // AddOp('S1P', [208], S1P);          { string to packed array on TOS }
      AddOp('STE', [209], STE);          { STore Extended }
      AddOp('EFJ', [211], EFJ);	         { Equal False Jump }
      AddOp('NFJ', [212], NFJ);	         { Not Equal false Jump }
      AddOp('BPT', [213], BPT);          { BreakPoinT }
      AddOp('XIT', [214], SYSHALT);      { eXIT operating system}
      AddOp('NOP', [215], NOP);          { no operation }
      AddOp('SLDL', [216..231], SLDL, -1);  { short load local word }
      AddOp('SLDO', [232..247], SLDO, -1);  { short load global word - like SLDL }
      AddOp('SIND', [248..255], SIND);  { Short load INDirect SIND0..SIND7 }

      // At some point, some MORON changed the meaning of several opcodes !!

      if VersionNr >= vn_VersionII then  { OpCode 167 was changed }
        begin
          Assert(Word_Memory, 'Word_Memory faulty assumption');
          AddOp('LSA', [166], LSA);        { load string address }
          AddOp('LAE', [167], LAE);        { load address extended }
          AddOp('LDO', [169], LDO);
          AddOp('LPA', [208], LPA2);       { Load Packed Array }
        end
      else  // VersionNr = 1.4, 1.5
        begin
          Assert(not Word_Memory, 'Word_Memory faulty assumption');
          AddOp('LCA', [166], LCA);
          AddOp('LDO', [167], LDO);        { load global word }
          AddOp('MVB', [169], MVB);        { move bytes}
          AddOp('LPA', [208], LPA1);       { Load Packed Array }
        end;

      for i := 0 to CSPEND do with CspTable[i] do begin Name  := ''; ProcCall := nil end;
      AddCspOp('IOCheck',          0, CSPIOCheck);
      AddCspOp('New',              1, CSPNew);
      AddCspOp('MoveLeft',         2, CSPMove);
      AddCspOp('MoveRight',        3, CSPMove);
      AddCspOp('Exit',             4, CSPExit);
      AddCspOp('UnitRead',         5, CSPUnitRead);
      AddCspOp('UnitWrite',        6, CSPUnitWrite);
      AddCspOp('IDSearch',         7, IDSearch);
      AddCspOp('TreeSearch',       8, DoTreeSearch);
      AddCspOp('Time',             9, CSPTime);
      AddCspOp('FillChar',         10, CSPFLC);
      AddCspOp('Scan',             11, CSPScan);
      AddCspOp('UnitStatus',       12, CSPUnitStatus);
    {13..20 not defined}
      AddCspOp('GetSeg',           21, CSPLoadSegment0);     // aka CSP_LDSEG
      AddCspOp('ReleaseSeg',       22, CSPUnloadSegment0);   // aka CSP_ULDSEG
      AddCspOp('Trunc',            23, CSPTrunc);
      AddCspOp('Round',            24, CSPRound);
      AddCspOp('Sine',             25, CSPSine);
      AddCspOp('Cosine',           26, CSPCosine);
      AddCspOp('Log',              27, CSPLog);
      AddCspOp('Atan',             28, CSPAtan);
      AddCspOp('Ln',               29, CSPLn);
      AddCspOp('Exp',              30, CSPExp);
      AddCspOp('Sqrt',             31, CSPSqrt);
      AddCspOp('Mark',             32, CSPMark);
      AddCspOp('Release',          33, CSPRelease);
      AddCspOp('IOR',              34, CSPIOR);
      AddCspOp('UnitBusy',         35, CSPUnitBusy);
      AddCspOp('PwrOfTen',         36, CSPPwrOfTen);
      AddCspOp('UnitWait',         37, CSPUNITWAIT);
      AddCspOp('UnitClear',        38, CSPUnitClear);
      AddCspOp('Halt',             39, CSPHalt);
      AddCspOp('MemAvail',         40, CSPMemAvail);
    end;
end;  { INITJUMPTABLE }

// NOTE: The disk volumes are passed in from FilerMain
procedure TCPsystemInterpreter.InitUnitTable;
var
  UnitNr: integer;
begin
  with UNITBL[0] do
    begin
      Control  := ALLBIT;
      Driver   := nil;
    end; // SYSTEM

  with UNITBL[1] do
    begin
      Control := ALLBIT;
      Driver  := TCharacterDriver.Create(self, nil {CONDRVR}, frmPSysWindow, Control);
    end; // CONSOLE

  with UNITBL[2] do
    begin
      control := ALLBIT + NOECHO;
      Driver  := TCharacterDriver.Create(self, nil {CONDRVR}, frmPSysWindow, Control);
    end; // SYSTERM

  with UNITBL[3] do
    begin
      Control := 0;
      Driver  := nil
    end;     // GRAPHIC

  with UNITBL[4] do
    begin
      Control := ALLBIT;
      Driver  := nil; // TVolume.Create(self, DOSFileName);
    end;     // DRIVE0

  with UNITBL[5] do
    begin
      Control := ALLBIT;
      Driver  := nil;  // TVolume.Create(self, DR1DRVR);
    end;     // DRIVE1

  with UNITBL[6] do    // PRINTER:
    begin
      Control := ALLBIT;
      Driver  := TPrinterDriver.Create(self, nil {PTRDRVR}, FilerSettings.PrinterLfn, Control);
    end;     // PRINTER

  with UNITBL[7] do    // REMIN:
    begin
      Control := INBIT+CLRBIT+STATBIT;
      Driver  := nil; // TCharacterDriver.Create(self, REMDRVR);
    end;  // REMIN

  with UNITBL[8] do   // REMOUT:  This was called REMOTE: IN VERSION 1.4
    begin
      Control := OUTBIT+CLRBIT+STATBIT;
      Driver  := TMemoDriver.Create(self, nil {PTRDRVR}, frmPSysWindow, fMemo);
    end; // REMOUT

  for UnitNr := 9 to MAX_STANDARD_UNIT do
    with UNITBL[UnitNr] do   // REMOUT:
      begin
        Control := ALLBIT;
        Driver  := nil;
      end;
end;

(*
procedure TCPsystemInterpreter.pSysWindowClosing(Sender: TObject; var Action: TCloseAction);
begin
//raise ESYSTEMHALT.Create('p-Sys Window closed');  // break out of the fetch loop. 11/7/2022 this was leaving the window open
  StatusProc('p-Sys Window closed');
end;
*)

procedure TCPsystemInterpreter.Initialize_Interp;
begin
  frmPSysWindow.Show;

  with frmPSysWindow do
    begin
      WriteLn('p-Machine based on Peter Miller ucsdpsys_vm');
      WriteLn('Translated into Delphi and integrated Filer system by Dan Dorrough 2022-2024');
      WriteLn;
//    OnClose := pSysWindowClosing;  // Causes an attempt to call a Method of a freed object
    end;

  InitUnitTable;

  Assert(CREALSIZE = 2);

{$IfDef debugging}
  WatchTypesTable[wt_real].WatchSize := SizeOf(Single); // Using 2 word reals
  WatchTypesTable[wt_real].WatchCode := 'R2';
{$endIf}

  SetRoundMode(rmUp);  // This gives good but not perfect rounding results
end;

procedure TCPsystemInterpreter.StatusProc(const Msg: string; DoLog,
  DoStatus: boolean);
begin
  inherited
end;

function TCPsystemInterpreter.GetMaxVolumeNr: integer;
begin
  result := UCSDglbu.MAXUNIT;
end;

// This is always a byte address
function TCPsystemInterpreter.InterpHIMEM: longword;
begin
  if Word_Memory then
    result := LOW64K * 2
  else
    result := LOW64K;
end;

function TCPsystemInterpreter.GetGlobVar: longword;
begin
  result := BASE;
end;

function TCPsystemInterpreter.GetLocalVar: longword;
begin
  result := WordIndexed(Mp, MS_VARw);
end;

procedure TCPsystemInterpreter.SetGlobVar(const Value: longword);
begin
  BASE := Value;
end;

procedure TCPsystemInterpreter.SetLocalVar(const Value: longword);
begin
  Mp := Value;
end;

procedure TCPsystemInterpreter.SetOp(const Value: Word);
begin
  fOpCode := Value;
end;

function TCPsystemInterpreter.GetOp: word;
begin
  result := fOpcode;
end;

destructor TCPsystemInterpreter.Destroy;
begin
  inherited;
end;

{$IfDef Debugging}
function TCPsystemInterpreter.GetProcBase: longword;
begin
  if JTab <> 0 then
    result := SelfRelPtr(WordIndexed(JTab, -1))
  else
    result := 0;
end;

function TCPsystemInterpreter.CurrentSegName: string;
begin
  result := SegNameFromSegTop(SEGP);
end;

function TCPsystemInterpreter.MemDumpDF( Addr: longword;
                                              Form: TWatchCode = 'W';
                                              Param: longint = 0;
                                              const Msg: string = ''): string;
var
  wt: TWatchType;
begin
  if Length(Form) > 0 then
    begin
      wt     := WatchTypeFromWatchCode(Form);
      result := MemDumpDW(Addr, wt, Param, Msg);
    end
  else
    result := 'Bad format';
end;

function TCPsystemInterpreter.MemDumpDW( Addr: longword;
                                          Code: TWatchType = wt_HexWords;
                                          Param: longint = 0;
                                          const Msg: string = ''): string;
const
  NRBYTES = 50;
var
  Temp: string;
  i: longword;
  b: byte;
  u: TUnion;
  Nrb: word;
  ByteAddress: longword;

  function PrefixInfo(Prefix: string; Addr: longword): string;
  begin
    if Msg <> '' then
      result := Format('%s @ %s: ', [Msg, Bothways(Addr)])
    else
      result := Format('%s @ %s: ', [Prefix, Bothways(Addr)]);
  end;

  function DiskInfoFormat(Addr: longword): string;
  var
    sn: integer;
  begin { DiskInfoFormat }
    result := '';
    for sn := 0 to MAXSEG do
      with TDiskInfoPtr(@Bytes[Addr])^[sn] do
        if (DISKADDR <> 0) and (CODELENG <> 0) then
          begin
            if result <> '' then
              result := result + ', ';
            result := result + Format('[%d]=%d/%d', [sn, DISKADDR, CODELENG]);
          end;
  end;  { DiskInfoFormat }

  function SegNamesFormat(Addr: longword): string;
  var
    SegName: TAlpha;
    sn: integer;
  begin
    result := '';
    for sn := 0 to MAXSEG do
      begin
        SegName := TSegNamesPtr(@Bytes[Addr])^[sn];
        if SegName <> '' then
          begin
            if result <> '' then
              result := result + ', ';
            result := result + Format('[%d]=%s', [sn, SegName]);
          end;
      end;
  end;

  function SegKindsFormat(Addr: longword): string;
  var
    SegKind: TSegKind;
    sn: integer;
  begin
    result := '';
    for sn := 0 to MAXSEG do
      begin
        SegKind := TSegKindsPtr(@Bytes[Addr])^[sn];
        if SegKind <> skLINKED then
          begin
            if result <> '' then
              result := result + ', ';
            result := result + Format('[%d]=%d', [sn, ord(SegKind)]);
          end;
      end;
  end;

  function CallStackFormat(Addr: longword; CSType: TMSCWFieldNr {csDynamic, csStatic}): string;
  var
    MSCWAddr  : word;
    aJTab     : word;
    aEnterIC  : word;
    aRelIPC   : word;
    aProcNr   : integer;
    aProcName : string;

    procedure AddProcCall(MSCWAddr: word; const aProcName, anIpc: string);
    var
      OneProc: string;
    begin
      OneProc := Format('%s @ %s', [aProcName, anIPC]);
      if result = '' then
        result := OneProc
      else
        result := result + ', ' + OneProc;
    end;

  begin { CallStackFormat }
    result := '';
    aProcNr  := Bytes[JTab];
    AddProcCall(0, ProcNameFromSegTop(aProcNr, SEGP), IntToStr(RelIPC));  // First the current procedure

//  MscwAddr := SysComIIPtr^.LASTMP;
    MscwAddr := Mp;

    if (aProcNr <> 0) then
      while (MscwAddr <> 0) and
            (MscwAddr <> MSCWField(MSCWAddr, csDynamic) {next MSCW addr}) and
            (aProcNr <> 0) and
            (MSCWField(MSCWAddr, csStatic) <> 0) do
        begin  // then all the other procedures on the call stack
          aJTab        := MSCWField(MSCWAddr, csJtab);
          aProcNr      := Bytes[aJtab];
          aProcName    := ProcNameFromSegTop(aProcNr, MSCWField(MSCWAddr, csSeg));

          try
//          aEnterIC  := aJtab-ENTERIC_OB - WordAt[aJTab-ENTERIC_OB];
            aRelIPC   := MSCWField(MSCWAddr, csIPC);
          except
            aRelIPC   := 0;
          end;

          AddProcCall(MscwAddr, aProcName, IntToStr(aRelIPC));

          MscwAddr  := MSCWField(MSCWAddr, CSType);   // link to previous MSCW

          if Length(Result) > 255 then // prevent infinite loop on call stack
            break;
        end;
    result := 'CallStack: ' + result;
  end;  { CallStackFormat }


  function UnitTableFormat(Addr: longWord {expected to be a word address};
                           Param: word): string;
  var
    UnitNr: word;
//  Blkd: word;
  begin { UnitTableFormat }
    if Param <> 0 then  // only a specific entry
      with TUTablePtrII(@Bytes[Addr])[Param] do
        begin
          result := PrefixInfo('UTablEntry', Addr) +
                    Format('UVID=%-8s, UISBLKD=%s',
                           [UVID, TF(Boolean(UISBLKD))]);
        end
    else  // display the entire unit table
      begin
        result := '';
        for UnitNr := 1 to MAXUNIT do
          with TUTablePtrII(@Bytes[Addr])[UnitNr] do
//          if UVID <> '' then
            if UISBLKD <> 0 then
              begin
                if result <> '' then
                  result := result + ', ';
//              Blkd := UISBLKD;
                result := result + Format('[%d]:UVid=%s;Blk=%s', [UnitNr, UVID, TF(Boolean(UISBLKD))]);
              end;
//      result := PrefixInfo('UnitTable', Addr) + result;
      end;
  end;  { UnitTableFormat }

  function RegValues(AsHex: boolean): string;

    function RegValue(const Reg: string; Num: longword; LastOne: boolean = false): string;
    begin { RegValue }
      if AsHex then
        result := Format('%s=$%4s', [Reg, HexWord(Num)])
      else
        result := Format('%s=%d', [Reg, Num]);

      if not LastOne then
        result := result + ', ';
    end; { RegValue }

    function RegValue2(const Reg: string; const Base, Offset: word): string;
    begin { RegValue2 }
      if AsHex then
        result := Format('%-4.4x:%x, ', [Base, Offset])
      else
        result := Format('%d:%d, ', [Base, Offset]);
    end;  { RegValue2 }

  begin { RegValues }
    if (JTab <> 0) then
      result := RegValue2('AbsIPC',        ProcBase(JTab), RelIPC)
              + RegValue('RelIPC',         RelIPC)
              + Regvalue('Kp (SegBottom)', Kp)
              + RegValue('Sp',             Sp)
              + RegValue('Mp (MSCW)',      Mp)
              + RegValue('Np (HeapTop)',   HeapTop)
              + RegValue('LocalVar',       LocalVar)
              + RegValue('GlobVar',        GlobVar)
              + RegValue('SegP (Segtop)',  SEGP)
              + RegValue('JTab',           JTab)
              + RegValue('IpcBase',        IpcBase)
              + RegValue('Syscom',         SyscomAddr, true)
    else
      result := 'Undefined';
  end;  { RegValues }

  function ProcedureInfo(Addr: longword; ProcNo: word): string;
  var
    SegLength, Loc, PDCount, {pn,} aJTab, EnterIC, ExitIC, DataSize, ParamSize{, SegNum}: word;
  begin
    // Assume Addr points to the Segment
    // Assume that the global SEGNUM is correct!
    SegLength := SD.Dict.DiskInfo[SEGNUM].codeleng; {Length of code segment in bytes}
    Loc       := Addr + SegLength - 2;
    PdCount   := WordAt[Loc-2] div 2;  // get the number of procedures
    SegNum    := Bytes[Loc];           // get segment number

    if ProcNo > 0 then // specific procedure
      begin
        Loc       := (Loc - 2) * (ProcNo + 1);
        aJTab     := Loc - WordAt[Loc];
        EnterIC   := (aJTab-ENTERIC_OB) - WordAt[aJTab-ENTERIC_OB];
        ExitIC    := (aJTab-EXITIC_OB) - WordAt[aJTab-EXITIC_OB];
        ParamSize := GetWordAt(aJTab-PARAMSIZE_OB);
        DataSize  := WordAt[aJTab-DATASIZE_OB];
        result    := PrefixInfo('Procedure Info', Addr) +
                       Format('SegNum=%d, Procedure=%d, JTab=$%4x, EnterIC=$%4x, ExitIC=$%4x, ParamSize=%d, DataSize=%d',
                             [SegNum, ProcNo+1, aJTab, EnterIC, ExitIC, ParamSize, DataSize]);
      end
    else  // list all procedure offsets
      begin
        result := PrefixInfo('Procedures info', Addr) + Format('PdCount=%d, ', [PdCount]);
        for ProcNo := 1 to PdCount do
          begin
            Loc       := (Loc - 2) * (ProcNo + 1);
            aJTab      := Loc - WordAt[Loc];
            result    := Result + Format('%d=%4x', [ProcNo, aJTab]);
            if ProcNo < PdCount then
              Result := Result + ', ';
          end;
      end;
  end;

  function FIBFormat(addr: longword): string;
  const
    HEADER_OFFSET = 54;
  type
    StateTypes = (FJandW, FNeedChar, FGotChar);

//   TDummy = record                 // easier to get to the FHEADER info
//           case integer of
//             0: (aFib: TFib2);
//             1: (dummy: packed array[0..HEADER_OFFSET-1] of byte;
//                 FHeader: DirEntry);
//           end;

//  TDummyPtr = ^TDummy;
  var
    IsOpen,
    EOLN,
    EOF,
    BufChngd,
    Modified, IsBlkd: boolean;
//  BitNr,
    State,
    ReptCnt: integer;
//  DirRoot: word;
    VID: string[VIDLENG];
    StateStr: string;
    ADirEntry: string;
    SoftBufAddr: longword;
    SoftBuf: boolean;
  begin { FIBFormat }
    try
      with TFIB2Ptr(@Bytes[Addr])^ do
        begin
          EOF      := FEOF <> 0;
          EOLN     := FEOLN <> 0;
{$R-}
          State    := ORD(fstate);
{$R+}
          IsOpen   := (FISOPEN <> 0);  // This is a loophole to permit viewing a FIB even if it is not open
          IsBlkd   := FISBLKD <> 0;
          Modified := FMODIFIED <> 0;
          ReptCnt  := FREPTCNT;

          if Length(FVID) <= VIDLENG then
            VID := CleanUpString(FVID, IDENT_CHARS, '?')
          else
            VID := '???????';

          case StateTypes(State) of
            FJANDW:
              StateStr := 'FJandW';
            FNEEDCHAR:
              StateStr := 'FNeedChar';
            FGOTCHAR:
              StateStr := 'FGotChar';
            else
              StateStr := Format('Unknown state: %d', [State]);
          end;

          result := PrefixInfo('FIB', Addr) +
                    Format('FWindow=%x,FEOLN=%s,FEOF=%s,FState=%s,FRecSize=%d,FIsOpen=%s',
                           [FWINDOW,   TF(EOLN), TF(EOF), StateStr, FRECSIZE, TF(ISOPEN)]);
          if IsOpen or (Param <> 0)then
            begin
//            ADirEntry := MemDumpDW(Addr+32 {offset to FHEADER field}, wt_DirectoryEntry);
              ADirEntry := DirEntryFormat(Addr+32);
              result := result + Format(',FIsBlkd=%s,FUnit=%d,FVID=%s,FMAXBLK=%D,FNXTBLK=%d,ReptCnt=%d,FModified=%s,%s',
                                      [TF(ISBLKD), FUNIT, VID, FMAXBLK, FNXTBLK, ReptCnt, TF(Modified),
                                       ADirEntry]);
              SoftBufAddr := Addr + 32 + SizeOf(DirEntry);
              with TSoftBufInfoPtr(@Bytes[SoftBufAddr])^ do
                begin
                  BufChngd    := FBUFCHNGD;
                  SoftBuf     := Boolean(WordAt[SoftBufAddr]);
                  if SOFTBUF then
                    result := result + Format(',FSOFTBUF=T,FNXTBYTE=%D,FMAXBYTE=%D,FBUFCHNGD=%s',
                                                          [FNXTBYTE, FMAXBYTE, TF(BufChngd), TF(BufChngd)])
                  else
                    result := result + ',FSOFTBUF=F';
                end;
            end;
        end;
    except
      on E:Exception do
        result := Format('Invalid FIB @ %4.4x [%s]', [Addr, e.message]);
    end;
  end;  { FIBFormat }

  function JtabFormat(Addr: longword): string;
  begin { JtabFormat }
    try
      if Addr > 10 then  // initially could be bad
        result := result + Format('ProcNr=%d, LexLevel=%d, EnterIC=$%-4.4x, ExitIC=$%-4.4x, ParamSize=%d, DataSize=%d, LastCode=%d',
                           [Bytes[Addr],  // ProcNr
                            Bytes[Addr+1],   // LexLevel
                            Addr - ENTERIC_OB - WordAt[Addr-ENTERIC_OB], // EnterIC
                            Addr - EXITIC_OB -  WordAt[Addr-EXITIC_OB],  // ExitIC
                            WordAt[Addr-PARAMSIZE_OB],          // ParamSize
                            WordAt[Addr-DATASIZE_OB],           // DataSize
                            WordAt[Addr-LASTCODE_OB]]);         // LastCode
    except
      result := result + '(bad JTab)';
    end;
  end;  { JtabFormat }

  function ProcedureNameFormat(longAddr: word): string;
  var
    aSegName, aProcName: string;
    SegNameIdx: TSegNameIdx;
  begin
    with frmPCodeDebugger do
      SegNameIdx := TheSegNameIdx(SegBase);

    aSegName   := SegNamesInDB[SegNameIdx];
    aProcName  := ProcNamesInDB[SegNameIdx, CurProc];

    result := Format('Procedure name: %d:%s.%s', [CurProc, aSegName, aProcName]);
  end;

  function SegTblFormat(Addr: longword): string;
  var
    sn: integer;
  begin
    result := '';
      for sn := 0 to MAXSEG do
        with TSegTblPtr(@Bytes[Addr])^[sn] do
          if CODEUNIT <> 0 then
            begin
              if result <> '' then
                result := result + ', ';
              result := result + Format('[%d]=%d/%d/%d', [sn, CODEUNIT, DISKADDR, CODELENG])
            end;
  end;

  function TreeStructureFormat(Addr: longword): string;
  type
     TTREEREC = RECORD
       WORDINDEX:  word;
       BITINDEX:   word;
       WIDTH:      word;
       VALNAMES:   word;
       RIGHT:      word;
       LEFT:       word;
       NAME:       string[80]
     END;

    TTreeRecPtr = ^ TTReeRec;

  var
    TreeRecP: TTreeRecPtr;
  begin
    if Addr <> 0 then
      begin
        TreeRecP := TTreeRecPtr(@Bytes[Addr]);
        try
          with TreeRecP^ do
            result := Format('WordIndex=%d, BitIndex=%d, Width=%d, ValNames=$%4.4x, Left=$%4.4x, Right=$%4.4x, Name=''%s''',
                             [WORDINDEX, BITINDEX, WIDTH, VALNAMES, LEFT, RIGHT, NAME]);
        except
          on e:Exception do
            result := e.message
        end;
      end;
  end;

  function IILinkerFormats(Addr: longword; code: TWatchType): string;
    const
      MAXSEG = 15;        { max code seg # in code files }
      MAXSEG1 = 16;       { MAXSEG+1, useful for loop vars }
      MAXLC = MAXINT;     { max compiler assigned address }
      MAXIC = 2400;       { max number bytes of code per proc }
      MAXPROC = 160;      { max legal procedure number }

    type
      { subranges }
      { --------- }

      segrange = 0..MAXSEG;       { seg table subscript type }
      segindex = 0..MAXSEG1;      { wish we had const expressions! }
      lcrange = 1..MAXLC;         { base offsets a la P-code }
      icrange = 0..MAXIC;         { legal length for proc/func code }
      procrange = 1..MAXPROC;     { legit procedure numbers }

      { miscellaneous }
      { ------------- }

      alpha = packed array [0..7] of char;
      TString8 = string[8];

      Tdiskblock = packed array [0..511] of 0..255;
      Tcodefile = word;            { trick compiler to get ^file }

      Tfilep = word;

      Tcodep = ^Tdiskblock;         { space management...non-PASCAL kludge }

      Tfinfop = word;              { forward type dec }

      Tsymp   = word;

      Tsegp   = word;

      TsegrecPtr = ^Tsegrec;

      Tsegrec = record             { info for segs to be linked to/from    }
                 srcfile: Tfinfop;         { source file of segment }
                 srcseg: segrange;        { source file seg # }
                 symtab: Tsymp;            { symbol table tree }
                 case segkind: segkinds of
                   SEPRTSEG:
                          (next: Tsegp)    { used for library sep seg list }
               end { segrec } ;

      Tfilekind = (USERHOST, USERLIB, SYSTEMLIB);

      TI5SegTblPtr = ^TI5SegTbl;

      TI5segtbl = record   { first full block of all code files -- this is just a segment dictionary - right?}
                   diskinfo: array [segrange] of
                               record
//                               codeleng, codeaddr: integer
                                 codeaddr  : integer;       // reordered for Delphi
                                 codeleng  : integer;
                               end { diskinfo } ;
                   segname: array [segrange] of alpha;
                   segkind: array [segrange] of segkinds;
                   filler: array [0..143] of integer
                 end { I5segtbl } ;

      TFileInfoRecPtr = ^Tfileinforec;

      Tfileinforec = record
                      next: Tfinfop;       { link to next file thats open }
                      code: Tfilep;        { pointer to PASCAL file...sneaky! }
                      fkind: filekind;    { used to validate the segkinds }
                      segtbl: TI5segtbl    { disk seg table w/ source info }
                    end { fileinforec } ;

      { link info structures }
      { ---- ---- ---------- }

//     placep = ^placerec;         { position in source seg }
       Tplacep = word;

       Tplacerec = record
                    srcbase, destbase: integer;
                    length: icrange
                  end { placerec } ;

//     refp = ^refnode;            { in-core version of ref lists }
       Trefp = word;

       Trefnode = record
                   next: Trefp;
                   refs: array [0..7] of integer;
                 end { refnode } ;

       Tlitypes = ({ 0}EOFMARK,         { end-of-link-info marker }
                      { ext ref types, designates      }
                      { fields to be updated by linker }
                   { 1}UNITREF,         { refs to invisibly used units (archaic?) }
                   { 2}GLOBREF,         { refs to external global addrs }
                   { 3}PUBLREF,         { refs to BASE lev vars in host }
                   { 4}PRIVREF,         { refs to BASE vars, allocated by linker }
                   { 5}CONSTREF,        { refs to host BASE lev constant }
                       { defining types, gives      }
                       {  linker values to fix refs }
                   { 6}GLOBDEF,         { global addr location }
                   { 7}PUBLDEF,         { BASE var location }
                   { 8}CONSTDEF,        { BASE const definition }
                      { proc/func info, assem }
                      { to PASCAL and PASCAL  }
                      { to PASCAL interface   }
                   { 9}EXTPROC,         { EXTERNAL proc to be linked into PASCAL }
                   {10}EXTFUNC,         {    "     func "  "    "    "      "    }
                   {11}SEPPROC,         { Separate proc definition record }
                   {12}SEPFUNC,         {   "      func     "        "    }
                   {13}SEPPREF,         { PASCAL ref to a sep proc }
                   {14}SEPFREF);        {   "    ref to a sep func }

      Tliset = set of Tlitypes;

      Topformat = ({0}of_WORD, {1}of_BYTE, {2}of_BIG);       { instruction operand field formats }

      TlientryPtr = ^Tlientry;

      Tlientry = record    { format of link info records }
                   name: alpha;
                   case litype: Tlitypes of
                     SEPPREF{13},
                     SEPFREF{14},
                     UNITREF{1},
                     GLOBREF{2},
                     PUBLREF{3},
                     PRIVREF{4},
                     CONSTREF{5}:
                      (oformat: Topformat;      { how to deal with the refs }   {THESE ARE PROBABLY IN WRONG ORDER}
                       nrefs: integer;        { words following with refs }
                       nwords: lcrange;       { size of privates in words }
                       reflist: Trefp);        { list of refs after read in }
                     EXTPROC{9},
                     EXTFUNC{10},
                     SEPPROC{11},
                     SEPFUNC{12}:
                      (srcproc: procrange;    { the procnum in source seg }
                       nparams: integer;      { words passed/expected }
                       place: Tplacep;         { position in source/dest seg }
                       );
                     GLOBDEF{6}:
                      (homeproc: procrange;   { which proc it occurs in }      {THESE ARE PROBABLY IN WRONG ORDER}
                       icoffset: icrange);    { its byte offset in pcode }
                     PUBLDEF{7}:
                      (baseoffset: lcrange);  { compiler assign word offset }
                     CONSTDEF{8}:
                      (constval: integer);    { users defined value }
                     EOFMARK{0}:
                      (nextlc: lcrange)       { private var alloc info }
                 end { lientry } ;

      TSymbolPtr = ^TSymbol;

      Tsymbol = record
//               llink, rlink,            { binary subtrees for diff names }
//               slink: symp;             { same name, diff litypes }
                 slink: Tsymp;             { re-orderd because of differing Delphi/UCSD field ordering }
                 rlink: Tsymp;
                 llink: Tsymp;
                 entry: Tlientry           { actual id information }
               end { symbol } ;

  function liTypeName(li: Tlitypes): string;
  const
    DELIMS    = ',';
    ENTRYNAME = 'EOFMARK,UNITREF,GLOBREF,PUBLREF,PRIVREF,CONSTREF,GLOBDEF,PUBLDEF,CONSTDEF,EXTPROC,EXTFUNC,SEPPROC,SEPFUNC,SEPPREF,SEPFREF';
  var
    idx: integer;
  begin
    idx := ord(li);
    result := Format('Bad TLiTypes (%d)', [Idx]);
    if (idx >= 0) and (idx <= ord(High(Tlitypes))) then
      result := Format('%s {%d}', [ExtractWordL(ord(li)+1, ENTRYNAME, DELIMS), Idx]);
  end;

  function SegKindName(sk: segkinds): string;
  const
    DELIMS = ',';
    SEGKINDNAME = 'LINKED,HOSTSEG,SEGPROC,UNITSEG,SEPRTSEG';
  var
    Idx: integer;
  begin
    Idx := ord(sk);
    result := Format('Bad segkind (%d)', [Idx]);
    if (Idx >= 0) and (Idx <= ord(High(segkinds))) then
      result := ExtractWordL(ord(sk)+1, SEGKINDNAME, DELIMS);
  end;



  function lientryFormat(Addr: word): string;
  var
    TheName: string;
  begin { lientryFormat }
    with TlientryPtr(@Bytes[Addr])^ do
      begin
        TheName := Name;            // clean it up
        result := Format('name=%s, litype=%s, ', [TheName, liTypeName(litype)]);
        case litype of
          SEPPREF,
          SEPFREF,
          UNITREF{1},
          GLOBREF{2},
          PUBLREF{3},
          PRIVREF{4},
          CONSTREF{5}:
            result := result + Format('format=%d, nrefs=%d, nwords=%d, reflist=$%4.4x',
                                      [ord(oformat), nrefs, nwords, reflist]);
          EXTPROC{9},
          EXTFUNC{10},
          SEPPROC{11},
          SEPFUNC{12}:
            result := result + Format('nparams=%d, srcproc=%d, place=%d',
                                        [srcproc, nparams, place]);
          GLOBDEF{6}:
            result := result + Format('homeproc=%d, icoffset=%d', [homeproc, icoffset]);
          PUBLDEF{7}:
            result := result + Format('baseoffset=%d', [baseoffset]);
          CONSTDEF{8}:
            result := result + Format('constval=%d', [constval]);
          EOFMARK{0}:
            result := result + Format('nextlc=%d', [nextlc]);
        end;
      end;
  end;  { lientryFormat }

  function SymbolFormat(Addr: longword): string;
  begin
    try
      with TSymbolPtr(@Bytes[Addr])^ do
        result := Format('llink=%d, rlink=%d, slink=%d, ', [llink, rlink, slink]) +
                    liEntryFormat(Addr+6)
    except
      result := Format('Bad symbol @ %d', [Addr]);
    end;
  end;

 // Version 1.5, II.0 segrec
  function segrecFormat(Addr: longword): string;
  begin { segrecFormat }
    with TsegrecPtr(@Bytes[addr])^ do
      begin
        result := Format('srcfile=%d, srcseg=%d, symtab=%d, segkind=%s', [srcfile, srcseg, symtab, SegKindName(segkind)]);
        if segkind = segkinds(SEPRTSEG) then
          result := result + Format(', next=%d', [next]);
      end;
  end;  { segrecFormat }

  function workrecFormat(Addr: longword): string;
  type
    workp = word;

    TWorkRecPtr = ^workrec;

    workrec = record        // NOTE: fields have been re-ordered from UCSD to match Delphi usage
               next: workp;          { list link }
               defsym: Tsymp;         {   "      "   "  resolving entry }
               refsym: Tsymp;               { symtab entry of unresolved name }
               defseg: Tsegp;         { seg where defsym was found }
               refseg: Tsegp;               { seg refls point into, refrange only }
               case lt: Tlitypes of       { same as litype in refsym^.entry }
                 SEPPREF,
                 SEPFREF,
                 GLOBREF:
                     (defproc: workp);       { work item of homeproc }
                 UNITREF:
                     (defsegnum: segrange);  { resolved seg #, def = ref }
                 PRIVREF:
                     (newoffset: lcrange);   { newly assigned base offset }
                 EXTPROC,
                 EXTFUNC,
                 SEPPROC,
                 SEPFUNC:
                     (needsrch: boolean;     { refs haven't been found }
                      newproc: 0..MAXPROC)   { proc #, comp or link chosen }
               end { workrec } ;             { 0 implies added proc }

  begin { workrecFormat }
    with TWorkRecPtr(@Bytes[Addr])^ do
      begin
        result := Format('next=%d, refsym=%d, defsym=%d, refseg=%d, defseg=%d, litypes=%s',
                         [next, refsym, defsym, refseg, defseg, liTypeName(lt)]);

        case lt{litypes} of
          SEPPREF,
          SEPFREF,
          GLOBREF:
            result := result + Format(', defproc=%d', [defproc]);
          UNITREF:
            result := result + Format(', defsegnum=%d', [defsegnum]);
          PRIVREF:
            result := result + Format(', newoffset=%d', [newoffset]);
          EXTPROC,
          EXTFUNC,
          SEPPROC,
          SEPFUNC:
            result := result + Format(', needsrch=%d, newproc=%d', [TF(needsrch), newproc]);
        end;
      end;
  end;  { workrecFormat }

  function SegDictFormat(Addr: longword): string;
  var
    aSegName: string;
    ch: string[2];
    SegIdx: integer;
  begin { SegDictFormat }
    result := '';
    with TI5SegTblPtr(@Bytes[Addr])^ do
      for SegIdx := 0 to MAXSEG do
        if DiskInfo[SegIdx].CodeAddr <> 0 then
          begin
            ch := '; ';
            if result = '' then
              ch := '';

            aSegName := segname[SegIdx];
            result := result + ch + Format('[%d.segname=%s, %d.codeaddr=%d, %d.codeleng=%d, %d.segkind=%s] ',
                                       [segidx,
                                        aSegName,

                                        segidx,
                                        DiskInfo[SegIdx].codeaddr,

                                        segidx,
                                        DiskInfo[SegIdx].codeleng,

                                        segidx,
                                        SegKindName(segkind[SegIdx])]);
          end;
  end;  { SegDictFormat }

  function FileInfoFormat(Addr: longword): string;
  begin { FileInfoFormat }
    with TFileInfoRecPtr(@Bytes[Addr])^ do
(*
      next: finfop;       { link to next file thats open }
      code: filep;        { pointer to PASCAL file...sneaky! }
      fkind: filekind;    { used to validate the segkinds }
      segtbl: I5segtbl    { disk seg table w/ source info }
*)
      begin
        result := Format('next=%d, code=$%4.4x, fkind=%d, ', [next, code, ord(fkind)]) + SegDictFormat(Addr+6)
      end;
  end;  { FileInfoFormat }

  begin { IILinkerFormats }
    case Code of
      wt_Linker_lientry:    result := lientryFormat(Addr);
      wt_segrec,
      wt_segrecp:           result := segrecFormat(Addr);
      wt_Linker_workrec:    result := workrecformat(Addr);
      wt_Linker_Symbol:     result := SymbolFormat(Addr);
      wt_Linker_FileInfo:   result := FileInfoFormat(Addr);
      wt_SegDict:           result := SegDictFormat(Addr);
    end;
  end;  { IILinkerFormats }

  function LongIntegerFormat(Addr: longword; Param: word): string;
  var
    NrWords, wc, w, WordAddr: word;
    A: double;
  begin
{$R-}
    result  := '';
    if Param <> 0 then
      begin
        NrWords := Param;
        Addr    := WordIndexed(Addr, -1);  // since we do not have a word count to skip over
      end
    else
      NrWords := WordAt[Addr];

    A       := 0.0;
    if (NrWords > 0) and (NrWords <= MAX_WORDS_IN_A_LONG) then
      begin
        wc      := NrWords;
        while wc > 0 do
          begin
            WordAddr := WordIndexed(Addr, wc);
            w        := WordAt[WordAddr];

            A        := (A * 65536.0) + w;   // make room for it and add in the next word
            Dec(wc);
          end;
        result  := Format('%d words: %g', [NrWords, A]);
      end
    else
      result := 'Invalid long integer';
{$R+}
  end;

begin { MemDumpDW }
// Skip the inherited because we need to deal with word/byte addressing issues.
// Addr may represent either a byte address or a word address depending on "fWord_Memory".

  ByteAddress := ByteIndexed(Addr);
  try
    case Code of
      wt_OpCodesDecoded:
        if JTab <> 0 then
          result := PrefixInfo('Decoded', Addr)
                    + DecodedRange(ByteAddress, NRBYTES, ProcBase(JTab))
        else
          result := Format('Decoded: Invalid JTab - %4.4x', [JTab]);

    wt_RegDumpHex:
      result := 'Regs(hex): ' + RegValues(true);  // Hex values

    wt_RegDumpDec:
      result := 'Regs(dec): ' + RegValues(false);  // Decimal values

    wt_ProcedureInfo:
      result := ProcedureInfo(ByteAddress, Param {Used for procedure number});

    wt_MSCWp:
      begin
  {$R-}
        with TMSCWPtr2(@Bytes[ByteAddress])^ do
          begin
            temp   := PrefixInfo('MSCW', Addr);
            result := Temp +
                      Format('StatLink=%s, DynLink=%s, MSJtab=%s, MSSEG=%s, MSIPC=%s, LocalData[0]=%s',
                             [HexWord(STATLINK), HexWord(DYNLINK), HexWord(MSJtab), HexWord(MSSEG), HexWord(MSIPC),
                              HexWord(LocalData[0])]);
  {$R+}
          end;
      end;

    wt_FIBp, wt_FIB:
      result := FIBFormat(ByteAddress);

    wt_Jtab:
      result := PrefixInfo('JTab', Addr) + JtabFormat(ByteAddress);

    wt_UnitTableP:
      result := PrefixInfo('UnitTable', Addr) + UnitTableFormat(ByteAddress, Param);

    wt_DynamicCallStack:
      result := 'Dynamic ' + CallStackFormat(ByteAddress, csDynamic);

    wt_StaticCallStack:
      result := 'Static ' + CallStackFormat(ByteAddress, csStatic);

    wt_ProcedureName:
      result := ProcedureNameFormat(ByteAddress);

    wt_DiskInfo:
      result := PrefixInfo('DiskInfo', Addr) +
                DiskInfoFormat(ByteAddress);

    wt_SegNames:
      result := PrefixInfo('SegNames', Addr) +
                SegNamesFormat(ByteAddress);

    wt_SegKinds:
      result := PrefixInfo('SegKinds', Addr) +
                SegKindsFormat(ByteAddress);

    wt_SegTable:
      result := PrefixInfo('SegTbl', Addr) +
                SegTblFormat(ByteAddress);

    wt_Tree:
      result := PrefixInfo('Tree', Addr) +
                TreeStructureFormat(ByteAddress);

    wt_Linker_lientry:
      result := PrefixInfo('lientry', Addr) +
                IILinkerFormats(ByteAddress, Code);

    wt_segrec,
    wt_SegRecP:
      result := PrefixInfo('segrec', Addr) +
                IILinkerFormats(ByteAddress, Code);

    wt_Linker_workrec:
      result := PrefixInfo('workrec', Addr) +
                IILinkerFormats(ByteAddress, Code);

    wt_Linker_Symbol:
      result := PrefixInfo('Symbol', Addr) +
                IILinkerFormats(ByteAddress, Code);

    wt_Linker_FileInfo:
      result := PrefixInfo('FileInfo', Addr) +
                IILinkerFormats(ByteAddress, Code);

    wt_SegDict, wt_SegDictP:
      result := PrefixInfo('SegDict2', Addr) +
                IILinkerFormats(ByteAddress, Code);

    wt_Ascii,
    wt_Alpha:
      begin
        result := PrefixInfo('ASCII', Addr);
        Nrb    := IIF(Param <> 0, Param, NRBYTES);
        for i := 0 to Nrb-1 do
          begin
            if Addr < (InterpHIMEM - i) then
              begin
                b := Bytes[ByteAddress+i];
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
                  + ByteFormat(ByteAddress, Param);
      end;

    wt_HexWords:
      begin
        result := PrefixInfo('Words', Addr);
        Nrb    := IIF(Param <> 0, Param, NRBYTES);
        result := result + HexWordsFormat(ByteAddress, Nrb);
      end;

    wt_DecimalInteger:
      begin
        result := PrefixInfo('Decimal', Addr);
        Nrb    := IIF(Param <> 0, Param, NRBYTES);
        i := 0;
        while (i < Nrb) and (ByteAddress+i < InterpHIMEM) do
          begin
            u.l := Bytes[ByteAddress+i];
            i := i + 1;
            u.h := Bytes[ByteAddress+i];
            i := i + 1;
            result := result + ' ' + IntToStr(u.i);
          end;
      end;

    wt_DirectoryEntry:
      result := PrefixInfo('DirEntry', Addr) + DirEntryFormat(ByteAddress);

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
                ByteFormat(ByteAddress, 3);

    wt_String:
      result := PrefixInfo('String', Addr) +
                StringFormat(ByteAddress);

    wt_boolean:
      result := PrefixInfo('Boolean', Addr) +
                TFString(Boolean(Bytes[ByteAddress]));

    wt_char:
      result := PrefixInfo('Char', Addr) +
                Format('''%s''', [chr(Bytes[ByteAddress])]);

    wt_real:
      result := PrefixInfo('Real', Addr) +
                RealFormat(ByteAddress);

    wt_DateRec:
      result := PrefixInfo('Date', Addr) +
                DateFormat(ByteAddress);

    wt_History:
      result := FormattedHistory;

    wt_LongInteger:
      result := PrefixInfo('Long Integer', Addr) +
                LongIntegerFormat(Addr, Param);

    wt_IOResult:
      with SysComIIPtr^ do
        begin
          if (IORSLT >= Low(TIORsltWD)) and (IORSLT <= HIGH(TIORsltWD)) then
            result := Format('%s (%d)', [IOResultStrings[IORSLT], ord(IORSLT)])
          else
            result := Format('Unknown IOResult = %d', [ord(IORSLT)]);
        end;

    else
      result := Format('Not implemented: %s', [WatchTypesTable[Code].WatchName]);
    // REMEMBER TO UPDATE GetLegalWatchTypes !!!
    end;
  except
    on e:Exception do
      result := Format('%s: %s', [e.message, WatchTypesTable[code].WatchName]);
  end;
end;  { MemDumpDW }

function TCPsystemInterpreter.GetpCodeDecoder: TpCodeDecoder;
begin
  if not Assigned(fpCodeDecoder) then
    begin
      fpCodeDecoder := TpCodeDecoderII.Create(nil, OpsTable, Word_Memory, VersionNr);
      fpCodeDecoder.OnGetJtab := GetJtab;
    end;
  result := fpCodeDecoder
end;
{$EndIf debugging}

procedure TCPsystemInterpreter.NOP;
begin
  { do nothing }
end;

function TCPsystemInterpreter.GetEnterIC(JTab: word): word;
begin
  // WARNING: JTab may be an Word_Memory address
  result    := (JTab-ENTERIC_OB) - WordAt[JTab-ENTERIC_OB];  // return EnterIC
end;


function TCPsystemInterpreter.GetAbsIPC: longword;
begin
//result := ByteIndexed(IpcBase) + IPC;
  result := IpcBase + IPC;
end;

//  Name:     GetRelIPC
//  Function: Return the offset from the beginning of the procedure
//  Note:     This is only used in the debugger
function TCPsystemInterpreter.GetRelIPC: word;
begin
{$R-}
  try
    result := IPC;
  except
    result := 0;
  end;
{$R+}
end;

procedure TCPsystemInterpreter.SetAbsIPC(Value: longword);
begin
  Assert(false);   // this is incorrect
  IPC := Value;
end;

function TCPsystemInterpreter.GetOpsTableClass: TOpsTableClass;
begin
  result := TOpsTableII;
end;


function TCPsystemInterpreter.GetJtab: word;
begin
  result := SysComIIPtr^.JTab;
end;

procedure TCPsystemInterpreter.SetJtab(const Value: word);
begin
  SysComIIPtr^.JTab := Value;
end;

function TCPsystemInterpreter.GetSegBase: longword;
begin
  result := SEGP;  // V1.4, 1.5, 2.0 connect everything to the segment TOP !
end;

{$IfDef debugging}
// Name:    GetLegalWatchTypes
// Purpose: returns a set of the watch types that are legal in Version II
function TCPsystemInterpreter.GetLegalWatchTypes: TWatchTypesSet;
begin
  result := inherited GetLegalWatchTypes + // Union the common WatchTypes with the version II ones
              [wt_OpCodesDecoded, {may not work properly?}
               wt_RegDumpHex, wt_RegDumpDec, wt_ProcedureInfo, wt_MSCWp, wt_FIBp, wt_FIB, wt_Jtab,
               wt_ProcedureInfo, wt_UnitTableP, wt_DynamicCallStack, wt_StaticCallStack, wt_ProcedureName,
               wt_DiskInfo, wt_SegNames, wt_SegKinds, wt_SegTable, wt_Tree,
               wt_Linker_lientry, wt_SegRec, wt_SegRecP, wt_Linker_workrec,
               wt_Linker_Symbol, wt_Linker_FileInfo, wt_SegDict, wt_SegDictP, wt_IOResult];
end;
{$EndIf debugging}

function TCPsystemInterpreter.SegNameFromBase(SegTop: longword): string;
begin
  result := SegNameFromSegTop(SegTop);  // V1.5+ always uses the SegTop
end;

function TCPsystemInterpreter.CurrentDataSize: word;
begin
  if JTab > 0 then
    result := WordAt[JTab-DATASIZE_OB]
  else
    result := 0;  // JTab not yet defined
end;

function TCPsystemInterpreter.GetStaticLink(MSCWAddr: word): word;
var
  p: TMSCWPtr2;
begin
  p      := TMSCWPtr2(@Bytes[MSCWAddr]);
  result := p^.STATLINK;
end;

{$IfDef debugging}
function TCPsystemInterpreter.GetSegNum: integer;
begin
  result := SegIdxFromSegTop(SEGP);
end;
{$EndIf}

CLASS function TCPsystemInterpreter.GetLEGAL_UNITS: TUnitsRange;
begin
  result := [4, 5, 9..UCSDglbu.MAXUNIT];
end;

Function TCPsystemInterpreter.MSCWField(MSCWAddr: word; CSType: TMSCWFieldNr): word;
var
  p: TMSCWPtr2;
begin { MSCWField }
  p := TMSCWPtr2(@Bytes[ByteIndexed(MSCWAddr)]);
  with p^ do
    case CSType of
      csDynamic:
        result := DYNLINK;
      csStatic:
        result := STATLINK;
      csJtab:
        result := MSJtab;
      csSEG:
        result := MSSEG;
      csIPC:
        result := MSIPC;
      csProc:
        result := Bytes[MSJtab];  // JTab points to the byte with the procedure number in it
      csLocal:
        result := LocalData[0];
      else
        raise Exception.CreateFmt('System error: invalid MSCW field type: %d', [ord(CSType)]);
    end;
end;  { MSCWField }

procedure TCPsystemInterpreter.InitIDTable;
begin
  inherited;
  fIDList := TIDListII.Create;
  with fIDList as TIDListII do
    InitIDs;
end;

{$IfDef debugging}

function TCPsystemInterpreter.GetByteFromMemoryBased(base: word; offset: word): byte;
begin
  if (Base > 0) and (Offset > 0) then
    result := MemRdByte(Base, offset)
  else
    result := 0;
end;

function TCPsystemInterpreter.DecodedRange( addr: longword;
                                            nrBytes: word;
                                            aBaseAddr: LongWord): string;
var
  dmd: TDecodeToMemDump;
begin
  if not Assigned(fDecodeToMemDump) then
    begin
      fDecodeToMemdump := TDecodeToMemDump.Create(self, pCodeDecoder, aBaseAddr);
      dmd := fDecodeToMemDump as TDecodeToMemDump;
      dmd.OnGetBaseAddress := self.GetProcBase;             // function {GetLongWordAt}: longword of object;
      dmd.OnGetByteBased   := self.GetByteFromMemoryBased;  // function {GetByteFromMemoryBased}(base: word; offset: word): byte of object;
      dmd.OnGetWord2       := self.GetWordFromMemory;
      dmd.OnGetJtab        := self.GetJtab;
(* *)
//    dmd.OnGetByteBased   := self.fGetByteFromMemoryBased;
//    dmd.OnGetByte3       := self.fOnGetByte2;
//    dmd.OnGetWord3       := self.fOnGetWord2;
//    dmd.OnGetBaseAddress := self.fGetBaseAddressFunc;
(* *)
    end;

  with fDecodeToMemDump as TDecodeToMemDump do
    Result     := DecodedRange(addr, nrBytes, aBaseAddr);
end;
{$endIf debugging}

function TCPsystemInterpreter.GetCREALSIZE: integer;
begin
  result := 2;  // 2 words: Not stored in Syscom.MISCINFO in version < VERSION_iv
end;

function TCPsystemInterpreter.GetMP: word;
begin
  result := SysComIIPtr^.LASTMP;
end;

procedure TCPsystemInterpreter.SetMP(const Value: word);
begin
   SysComIIPtr^.LASTMP := Value;
end;


function TCPsystemInterpreter.GetSP: longword;
begin
  result := fSP;
end;

procedure TCPsystemInterpreter.SetSP(const Value: longword);
begin
  inherited;
  fSP := Value;
end;



function TCPsystemInterpreter.GetKp: word;
begin
  result := fKp;
end;

procedure TCPsystemInterpreter.SetKp(const Value: word);
begin
  fKp := Value;
end;

function TCPsystemInterpreter.GetWordAt(P: longword): word;
begin
  if Word_Memory then
    result := Words[p] else
  if not Odd(p) then
    result := Words[p shr 1]
  else
    raise EOddAddress.CreateFmt('GetWordAt passed an ODD address: %4.4x (%d.)', [p, p]);
end;

procedure TCPsystemInterpreter.SetWordAt(P: longword; const Value: word);
begin
  if Word_Memory then
    Words[p] := Value else
  if not odd(p) then
    Words[p shr 1] := Value
  else
    raise Exception.Create(Format('SetWordAt passed an ODD address: %4.4x', [p]));
end;

// If we are in word addressing mode then we need to calculate a byte address for SYSRD
// because the inherited SYSRD expects a byte address.
procedure TCPsystemInterpreter.SYSRD(unitnumber: word; start: longword; len, block : word);
//var
//Addr: longword;
begin
  start := ByteIndexed(start);

  inherited SYSRD(unitnumber, start, len, block);
end;

function TCPsystemInterpreter.GetHeapTop: word;
begin
  result := Np;
end;

procedure TCPsystemInterpreter.SetHeapTop(const value: word);
begin
  Np := value;
end;

// GetByteFromMemory switched from below so that the External Decoder window would decode properly.
// This may not work if Word_Memory is true, or Byte_Sex = bs_BIG_ENDIAN. 
function TCPsystemInterpreter.GetByteFromMemory(p: longword): byte;
begin
  result := Bytes[p]
end;

(*
function TCPsystemInterpreter.GetByteFromMemory(p: longword): byte;
begin
  if IpcBase > 0 then
    result := MemRdByte(IpcBase, p)   // p is the offset from IpcBase
  else
    result := 0;
end;
*)

{$IfDef debugging}
// This version of MemDumpDFWB is easier to use in a Delphi watchpoint and avoids imposing a ByteAddress calculation
function TCPsystemInterpreter.MemDumpDFWB( WordAddr: longword;
                                           ByteOffset: word;
                                           Form: TWatchCode = 'W';
                                           Param: longint = 0;
                                           const Msg: string = ''): string;
begin
  result := inherited MemDumpDF(WordIndexed(WordAddr, ByteOffset), Form, Param, Msg);
end;
{$EndIf debugging}


function TCPsystemInterpreter.GetBase: word;
begin
  result := fBase;
end;

procedure TCPsystemInterpreter.SetBase(const Value: word);
begin
  fBase := Value;
end;

procedure TCPsystemInterpreter.PutIOResult(value: integer);
begin
  inherited;
  PutIOError(TIORsltWd(Value));
end;

  procedure TCPsystemInterpreter.WriteLong;
  var
    FWidth : word;
    TheWidth: word;
    FibP   : word;
    LongI  : TDecopsUnion;
    S      : string;
    Fib2Ptr : TFIB2Ptr;
    Fib2   : TFIB2;        // debugging - just want to see if we really got a FIB
  begin
    FWidth   := Pop();    // user's desired field width
    LongI    := PopL(10); // get the Decops integer off of the stack
                          // (assume length is = 10, based only on observasion of what is seen on the stack)
    Str(LongI.Int[0]:FWidth, S);     // WARNING: CURRENTLY USING ONLY THE LOW ORDER WORD
    TheWidth := FWidth;
    if TheWidth < Length(S) then
      TheWidth := Length(S);

    // pointer to a FIB should now be on the top of the stack
    FibP    := Pop;                 // Getthe address of the FIB
    FibP    := ByteIndexed(FibP);   // possibly convert word address to a byte address
    Fib2Ptr := @Bytes[FibP];        // so we can look at it Delphi
    Fib2    := FIB2Ptr^;            // for debugging
    with Fib2Ptr^ do
      begin
        // MAJOR LEAGUE KLUDGE FOLLOWS- just trying to get past some unobtainable procedures
        if FUNIT in [1 {console:}, 2 {systerm:}, 6{printer:}] then  // CONSOLE: or SYSTERM:
          if Assigned(UNITBL[FUNIT].Driver) then
            UNITBL[FUNIT].Driver.UnitWrite(s[1], TheWidth, 0, 0)
          else
            raise EWRITEERR.CreateFmt('Unit %d does not exist', [FUNIT]);
      end;
  end;


function TCPsystemInterpreter.GetBaseAddress: longword;
begin
  result := ProcBase(JTab);
end;

{$IfDef temporary}
procedure TCPsystemInterpreter.SetIpc(const Value: word);
begin
  fIPC := Value;
end;
{$Endif temporary}

function TCPsystemInterpreter.GetWordFromMemory(p: longword): word;
begin
  result := Words[p];
end;

function TCPsystemInterpreter.TheVersionName: string;
begin
  result := Format('PM %s', [VersionNrStrings[VersionNr].Name]);
end;

END .


