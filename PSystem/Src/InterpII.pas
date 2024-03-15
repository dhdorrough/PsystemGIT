{$UnDef ListSyscallEvents}
Unit InterpII;

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
{$IfDef Debugging}
     Debug_Decl,
     Watch_Decl,
     pCodeDecoderUnit,
     pCodeDecoderII,
{$endIf}
     Misc,
     CRTUnit,
     Forms,
     UCSDInterpreter,
     LoadVersion;
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

MAX_STANDARD_UNIT = 74;   // for now

  LINKED          = 0;
  HOSTSEG         = 1;
  SEGPROC         = 2;
  UNITSEG         = 3;
  SEPRTSEG        = 4;
  UNLINKEDINTRINS = 5;
  LINKEDINTRINS   = 6;
  DATASEG         = 7;

  MSSP   = 10;        {caller's top of stack}
  MSIPC  =  8;        {caller's ipc (return address)}
  MSSEG  =  6;        {caller's segment (proc table) pointer}
  MSJTAB =  4;        {caller's JTAB  pointer}
  MSDYN  =  2;        {dynamic link pointer to caller's MSCW}
  MSSTAT =  0;        {Static  link pointer to parent's MSCW}
  MSBASE = -2;        {base link (only if CBP) pointer}
                      {to base MSCW of caller}

//CREALSIZE = 2;      {for version 1.5}


TYPE
  aWORD = PACKED RECORD
            CASE INTEGER OF
              0: (Bite: PACKED ARRAY [0..1] OF 0..255);
              1: (C: PACKED ARRAY [0..1] OF CHAR);
              3: (I: INTEGER);
            END;

  FREEUNION = RECORD
    CASE INTEGER OF
      1: (BUF: PACKED ARRAY [0..511] OF 0..255);
      2: (DICT: SDRECORD);
    END;


  STRING1 = PACKED ARRAY [0..1] OF CHAR;

  STRING3 = PACKED ARRAY [0..3] OF CHAR;

  STRING7 = STRING[7];

  Ptype = integer; {was an eneuremated type 0..11}


  TOprec = RECORD
            MNEMONIC: STRING7;
            {P1, P2: PTYPE;}
            p2 : ptype;
            p1 : ptype;
          END;

  TOldSegInfo = record
                 REFCOUNT : Word;
                 SEGTOP   : Word;    // ^byte PAST end of segment code !!
//               SEGNAME  : TAlpha;
                end;


  TIIPsystemInterpreter = class(TUCSDInterpreter)
  private
    fSP       : word;
    fAF       : TUnion;
    fBC       : TUnion;          // AbsIPC
    fDE       : TUnion;
    fHL       : TUnion;
    FOp       : Word;

    StackOverFlow : boolean;

    IsZero        : boolean;     // IsZero is true to indicate result is 0;
    IsLessThan    : boolean;
    IsEqual       : boolean;
    IsGreaterThan : boolean;
    IsGreaterThanOrEqual: boolean;
    IsLessThanOrEqual: boolean;
    CodeWasReadIn    : boolean;

    IPCSAV    : Word;
    fProcBase : word;

//------ GENERAL IO TEMPORARY VARIABLES

    NEWJTB : word;   { new JTAB pointer}

    CLRMSK    : word ;
    bitter    : array[0..15] of word;
    {element -1 contains CLRMSK}
    unbitter  :array[0..15] of word;
    fHeapTop  : word;

    Procedure PUSHint(x:integer);
    Procedure POPint(var x:integer); overload;
    function  PopInt: integer; overload;
    function GETSEG(SegNum: word; var SegWasReadIn: boolean): word;
    Procedure BLDMSCW;

    procedure ABI;
    procedure ABR;
    procedure ADI;
    procedure ADJ;
    procedure ADR;
    procedure GetSavedIPC;
    procedure BLD3;
    procedure BOOLC;
    procedure BPT;
    procedure BYTEC;
    procedure CBP;
    procedure CBPXNL;
    procedure CEQU;
    procedure ClrGDirP;
    procedure CGEQ;
    procedure CGP;
    procedure CGTR;
    procedure CHK;
    procedure CIP;
    procedure CIPXNL;
    procedure CLEQ;
    procedure CLP;
    procedure CLSS;
    procedure CNEQ;
    procedure CSETUP;
    procedure CSP;
    procedure CXP;
    procedure CXP02;
    function  DECREF(SegIdx: word; SegTop: word): boolean;
    procedure DIF;
    procedure DoTreeSearch;
    procedure DVI;
    procedure DVR;
    procedure EQUI;
    procedure EX(var xx, yy: word);
    procedure FJP;
    procedure FLO;
    procedure FLT;
    function  GetBig: word;
    procedure GEQI;
    procedure GETIA;
    procedure GTRI;
    procedure INCR;
//  function  INCREF(SegIdx: word; SegTop: word): boolean;
    procedure Init;
    procedure initsets;
    procedure InitTime;
    procedure INN;
    procedure INT;
    procedure INVNDX;
//  procedure IOR
    procedure IXA;
    procedure IXP;
    procedure IXS;
    procedure LAND;
    procedure LCA;
    procedure LDA;
    procedure LDB;
    procedure LDC;
    procedure LDCI;
    procedure LDL;
    procedure LDM;
    procedure LDO;
    procedure LDP;
    procedure LEQI;
    procedure LESI;
    procedure LLA;
    procedure LNOT;
    procedure LoadSEGDICT(BlockNr: integer; const FileName: string);
    procedure LOD;
    procedure LOR;
    procedure MODI;
    procedure MOV;
    procedure MPI;
    procedure MPR;
    procedure MVB;
    procedure NEQI;
    procedure NGI;
    procedure NGR;
    procedure NOP;
//  procedure PCRSLT;
    procedure POWRC;
    procedure pSQR;
//  procedure XEQERR;
    procedure RBP;
    procedure ReadSeg(var FileName: string; var NewSegTop: word);
    procedure REALC;
    procedure RNP;
    procedure LPA;
    procedure S2LONG;
    procedure SAS;
    procedure SaveIPC;
    procedure SBI;
    procedure SBR;
    function Scan(Limit: integer; opcode, Ch: Char; Addr: word): Integer;
    procedure SGS;
{$IfDef debugging}
//  procedure ShowProcDict(a: word; ToWindow: boolean);
//  procedure ShowSegInfo;
    procedure OverrideSysCall(var UnitNr: integer; var BlockNr: integer; var aFileName: string);
{$EndIf}
    procedure ShowSizes;
//  procedure ShowStack(address, lines: word);
    procedure SIND;
    procedure SIND0;
    procedure SLDL;
    procedure SLDO;
    procedure SQI;
    procedure SRO;
    procedure SRS;
    procedure StartPME;
    procedure STB;
    procedure STIND;
    procedure STKCHK;
    procedure stkovr;
    procedure STL;
    procedure STM;
    procedure STO;
    procedure STP;
    procedure STR;
    procedure STRGC;
    procedure UCSDExit;
    procedure UJP;
    procedure UNI;
    procedure UpdateTime;
    procedure WORDC;
    procedure XJP;
    procedure LDCN;
    procedure LAO;
    procedure SLDC;
    function CheckSizes: Boolean;
    procedure SetHL(const Value: word);
    procedure SetBC(const Value: word);
    procedure CallIO;
    procedure InitUnitTable;
    function TreeSearch(root: word; var node: word; const key: Talpha): integer;
    procedure IDSEARCH;
    procedure SYSHALT;
    procedure Setup(var SIZEA, SIZEB, NEWSP, SETA, SETB: word);
//  procedure SetSP(const Value: word);
    procedure CSPAtan;
    procedure CSPCosine;
    procedure CSPExit;
    procedure CSPExp;
    procedure CSPFLC;
    procedure CSPGetSeg;
    procedure CSPHalt;
    procedure CSPIOCheck;
    procedure CSPLn;
    procedure CSPLog;
    procedure CSPMark;
    procedure CSPMemAvail;
    procedure CSPMove;
    procedure CSPNew;
    procedure CSPPwrOfTen;
    procedure CSPRelease;
    procedure CSPReleaseSeg;
    procedure CSPRound;
    procedure CSPScan;
    procedure CSPSine;
    procedure CSPSqrt;
    procedure CSPTime;
    procedure CSPTrunc;
    procedure CSPUnitClear;
    procedure CSPUnitRead;
    procedure CSPUnitReadWriteCommon(ReqBit: word);
    procedure CSPUNITWAIT;
    procedure CSPUnitWrite;
    procedure CSPUnitBusy;
    procedure IOError(Num: TIORsltWd);
    procedure CSPIOR;
//  procedure EnterExit(const DoingWhat, FromWhere: string; d: integer = 0);
//  procedure pSysWindowClosing(Sender: TObject; var Action: TCloseAction);
    function FinalException(const Msg, TheClassName: string): TBrk;
    procedure Decops;
    procedure pXEQERR(Err: word; const Msg: string);
    procedure DecopsInitialization;
(*
{$IfDef DumpDebugInfo}
    procedure DumpDebugInfo(const Caption: string);
{$EndIf}
*)
  protected
    function GetSP: longword; override;
    procedure SetSP(const Value: longword); override;
    function GetHeapTop: word; override;
    procedure SetHeapTop(const Value: word); override;

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
    procedure PutIOResult(value: integer); override;
    procedure InitIDTable; override;
    function GetProcBase: longword; override;
    procedure SetProcBase(const Value: LongWord); override;
    function GetSyscomAddr: longword; override;
{$IfDef Debugging}
    function GetpCodeDecoder: TpCodeDecoder; override;
    function SegIdxFromName(const aSegName: string): TSegNameIdx;
{$endIf}
  public
    MPD0        : word;        {^local var with offset zero}
    BASED0      : word;        {^global var with offset zero}

    SEGBOT      : word;        {ptr to bottom of segment}

    achar       : char;
    Flip        : boolean;
    PDCOUNT,
    FIRSTADDR,
    FIRSTBLOCK,
    CURRENTBLOCK: INTEGER;
    NewSegTop   : word;   { new SEGP - points to the END+2 of the segment}
    SEGNUM      : word;   {segment # currently being called}
    Progname,
    OpCodes     : ARRAY [0..255] OF TOprec;
    BUF         : PACKED ARRAY [0..511] OF 0..255;
    SD          : FREEUNION;
    PD          : ARRAY [0..149] OF word{INTEGER};
    HEXDIGIT    : PACKED ARRAY [0..15] OF CHAR;
    CRtyped     : Boolean;
    ETXtyped    : Boolean;
    ScreenHeight: Integer;  {syscom^.miscinfo.screenheight, usually 24 or 25}
    ScreenWidth : Integer;  {syscom^.miscinfo.screenwidth, usually 79 or 80}

    StartTime   : single;

    function CurrentDataSize: word;
    function GetByteFromMemory(p: longword): byte; override;
    function GetWordFromMemory(p: Longword): word; override;
//  function GetByteFromMemoryBased(base: word; offset: word): byte;
    function  GetCurProc: word; override;
    CLASS function GetLEGAL_UNITS: TUnitsRange; override;
    function GetEnterIC(JTAB: word): word; override;
    function GetJTAB: word; override;
//  function GetSegNum: TSegNameIdx; override;
    function GetNextOpCode: byte; override;
    function GetSegNum: integer; override;
    function GetStaticLink(MSCWAddr: word): word; override;
    function MSCWField(MSCWAddr: word; CSType: TMSCWFieldNr): word; override;
    function SegNameFromBase(SegTop: longword): string; override;
    procedure StatusProc(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true); override;
    procedure Initialize_Interp;
    function TheVersionName: string; override;
{$IfDef Debugging}
    function CurrentSegName: string; override;
    function GetLegalWatchTypes: TWatchTypesSet; override;
    function MemDumpDW( Addr: longword;
                        Code: TWatchType = wt_HexWords;
                        Param: longint = 0;
                        const Msg: string = ''): string; override;
    function  DecodedRange( addr: longword;
                            nrBytes: word;
                            aBaseAddr: LongWord): string; override;
    function GetBaseAddress: longword; override;
{$EndIf}
    function  CalcProcBase(aSegTop: longword; ProcNumber: word): word; override;

    property AF: word
             read fAF.w
             write fAF.w;

    property A: byte
             read fAF.h
             write fAF.h;

    property Flags: byte
             read fAF.l
             write fAF.l;

    property BC: word           // AbsIPC
             read fBC.w
             write SetBC;

    property B: byte
             read fBC.h
             write fBC.h;

    property C: Byte
             read fBC.l
             write fBC.l;

    property DE: word
             read fDE.w
             write fDE.w;

    property E: byte
             read fDE.h
             write fDE.h;

    property D: byte
             read fDE.l
             write fDE.l;

    property HL: word
             read fHL.w
             write SetHL;

    property H: byte
             read fHL.h
             write fHL.h;

    property L: byte
             read fHL.l
             write fHL.l;

    Constructor Create( aOwner: TComponent;
                        VolumesList   : TVolumesList;
                        thePSysWindow : TfrmPSysWindow;
                        Memo: TMemo;
                        TheVersionNr: TVersionNr;
                        TheBootParams: TBootParams); override;
    Destructor Destroy; Override;
    function  InterpHIMEM: longword; override;
    procedure Load_PSystem(UnitNr: word); override;
    function  ProcName(MsProc: word; aSegTop: longword): string; override;
    property VersionNr;
  end;


const InterpVersion = '7';

implementation

uses
  SysUtils, pSysExceptions, pSys_Decl,
{$IfDef Debugging}
  pCodeDebugger_Decl,
  DebuggerSettingsUnit,
  DecodeToMemDumpUnit,
  Windows,
  pCodeDebugger,
{$EndIf}
  MyUtils, pSysDrivers, FilerSettingsUnit, PsysUnit, BitOps,
  CompilerSymbolsII,
  SysCommon, MiscinfoUnit, StStrL, FilerMain;

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
  Function TIIPsystemInterpreter.Scan(Limit:integer; opcode:char; Ch:Char; Addr: word):Integer;
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


Procedure TIIPsystemInterpreter.InitTime;
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



Procedure TIIPsystemInterpreter.UpdateTime;
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
  with Globals.LowMem.Syscom do
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
// NOTE: The above variables MUST begin on word boundaries!
//
// Idsearch does the following:
//    Isolate token, converting to upper case, and stash in id.
//    If token in reswrdtable set sy and op from table,
//    else set sy := 0.
//    symcur is left pointing to the last char of the token
//

procedure TIIPsystemInterpreter.IDSEARCH;
var
  SymBufp    : word;
  RetnInfoP  : word;
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
begin
  i         := 0;
  Key       := '        ';  // adapted from Dr Laurence Boshell's version
  SymBufP   := POP();    // address of SymBufP
  RetnInfoP := POP();    // address of SymCursor
  p         := TRetnInfoPtr(@Bytes[RetnInfoP]);

  SymCursor := WordAt[RetnInfoP];
  c         := chr(Bytes[SymBufP+SymCursor]);
  while (c in['A'..'Z', 'a'..'z', '0'..'9', '_'])do
    begin
      If c <> '_' then   {ignore '_' for full UCSD compatibility   /tp3}
        begin
          if (i < High(Alpha)) then
            key[i] := UpCase(c);
          i := i + 1;
        end;

      SymCursor := SymCursor+1; {do not use   bumpcursor(1);} {/tp4}

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



Procedure TIIPsystemInterpreter.CXP02;   {EXECERROR}
var
  Err: integer;
  Msg: string;
 Begin
  with frmpSysWindow do
    begin
      Err := Globals.LowMem.Syscom.XEQERR;
      Msg := Format('Error = %d, EnterIC = $%4.4x (%d), LexLevel = %d, S#%d, P#%d, O#%d',
                    [Err, ProcBase, ProcBase, Bytes[JTAB+1], Bytes[SEGP], Bytes[JTAB], RelIPC]);
      WriteLn(Msg);
      PressAnyKey;          // and then return to FETCH
//    Raise ESYSTEMHALT.Create(Msg);
    end;
end;


Procedure TIIPsystemInterpreter.pXEQERR(Err: word; const Msg: string);
Begin
  Globals.LowMem.Syscom.XEQERR := Err;
  Globals.LowMem.Syscom.BOMBP  := SP-(MSCWSize+4);    {change 14 if MSCW size changes with 2 word ptrs}
                                                      {dhd- 9/3/2021 no idea what the +4 is}
  Globals.LowMem.Syscom.BOMBIPC:= IPCSAV;
{$IfDef LogRuns}
  with fFiler as TfrmFiler do
    SetLastError(Format('XEQ Err = %d, Msg = %s', [Err, Msg]));
{$endIf}
  CXP02;  {simulate CXP 0 2 }
end;


Procedure TIIPsystemInterpreter.StkOvr;
Begin
  HeapTop := 256;  {INTEND,  prevent recursive overflow}
//HL := STKOVRC;   {STK OVERFLW}
  raise ESTKFAULT.Create('Stack overflow');
end;

Procedure TIIPsystemInterpreter.STKCHK;
{check for stack overflow return StackOverFlow true if overflow}
Var HL : word;
Begin
  HL := SP - 60; {leave room for 30 word eval stack}
  StackOverFlow := HeapTop >= HL;
end;



procedure TIIPsystemInterpreter.DecopsInitialization;
begin
  POP();  // dispose of Garbage put onto the stack
end;


procedure TIIPsystemInterpreter.Decops;
begin
  DECOPSMain(DecopsInitialization, nil);
end;


{$IfDef debugging}
// Kludge to allow access to information needed for debugging
procedure TIIPsystemInterpreter.OverrideSysCall(var UnitNr: integer; var BlockNr: integer; var aFileName: string);
var
  CallNum, Src, FIBAddr: word;
  FIB: TFib2;
  BlksRead, Len: integer;
  SD: FreeUnion;
  idx, NrEntries, MaxBlock: integer;
  aVolName: string;
  SavedBlockNumber: longint;
begin
  CallNum := Bytes[BC];     // get the call number from the code stream
  case CallNum of
     5 : Begin   {RESET/REWRITE}
           // Trying to maintain a list of relevent segment names.
           // Note: This will save the info even if the file is not being executed but merely opened.
//         Mode := integer(WordAt[SP+2]);  {FOPENOLD 0=REWRITE, 1=reset}
           Src  := WordAt[SP+4];  {^TID (name)}
           Len  := Bytes[Src];
           if Len = 0 then
             exit;
           SetLength(aFileName, Len);
           move(Bytes[Src+1], aFileName[1], Bytes[Src]);   {get the filename}
           ExtractUCSDNameParts(aFileName, aVolName, aFileName);

           FIBAddr := WordAt[SP+6];  // ^FIB
           FIB     := TFIB2Ptr(@Bytes[FIBAddr])^;
           with Globals.LowMem.Syscom do
             if gDirp <> pNIL then
               begin
                 with TDIRPtr(@Bytes[gDirp])[0] do
                   begin
                     NrEntries := DNUMFILES;
                     MaxBlock  := DEOVBLK;
                   end;
                 // search the directory for the specified file name
                 if NrEntries <= MAXDIR then
                   for Idx := 1 to NrEntries do
                     with TDIRPtr(@Bytes[gDirp])[Idx] do
                       if (dfkind = kCODEFILE) and SameText(aFileName, DTID) then // we found a matching code file
                         begin
                           BlockNr := DFIRSTBLK;
                           with fVolumesList[UnitNr].TheVolume do
                             begin
                               SavedBlockNumber := CurrentBlockNumber;
                               try
                                 SeekInVolumeFile(BlockNr);
                                 BlksRead := BlockRead(SD.Buf, 1);  // load the segment dictionary
//                               if (BlksRead = 1) and ValidDictionary(UnitNr, BlockNr, SizeOf(SDRECORD), sd.DICT, MaxBlock) then               // we read it successfully
                                 if BlksRead = 1 then               // we read it successfully
                                   SaveSegInfoForFile(UnitNr, BlockNr, SizeOf(SDRECORD), DTID, sd.DICT, MaxBlock);
                               finally
                                 SeekInVolumeFile(SavedBlockNumber);  // try to leave file position undisturbed
                               end;
                               Break;
                             end;
                         end
               end;
         end;
    else
      begin
{$IfDef ListSyscallEvents}
        case CallNum of
          3: Msg := 'Build FIB';
          4: Msg := 'Reset';
          5: Msg := 'Reset/Rewrite';
          6: Msg := 'Close';
          7: Msg := 'Get';
          8: Msg := 'Put';
          9: Msg := 'Seek';
          10: Msg := 'EOF';
          11: Msg := 'FEOLN';
          12: Msg := 'Read integer';
          13: Msg := 'Write integer';
          14: Msg := 'Read real';
          15: Msg := 'Write real';
          16: Msg := 'Read char';
          17: Msg := 'Write char';
          18: Msg := 'Read string';
          19: Msg := 'Write string';
          20: Msg := 'Write array of char';
          21: Msg := 'ReadLn';
          22: Msg := 'WriteLn';
          23: Msg := 'Concat';
          24: Msg := 'Insert';
          25: Msg := 'Copy';
          26: Msg := 'Delete';
          27: Msg := 'Pos';
          28: Msg := 'BlockRead/BlockWrite';
          29: Msg := 'GotoXY';
    {to maintain compatibility with old pcode files,
     cxp 0 30 to cxp 0 48 are reserved}
          30: Msg := 'VolSearch (Obsolete)';
          31: Msg := 'WriteDir (Obsolete)';
          32: Msg := 'DirSearch (Obsolete)';
          33: Msg := 'ScanTitle (Obsolete)';
          34: Msg := 'DelEntry (Obsolete)';
          35: Msg := 'InsEntry (Obsolete)';
          36: Msg := 'HomeCursor (Obsolete)';
          37: Msg := 'ClearScreen (Obsolete)';
          38: Msg := 'ClearLine (Obsolete)';
          39: Msg := 'Prompt (Obsolete)';
          40: Msg := 'SpaceWait (Obsolete)';
          41: Msg := 'GetChar (Obsolete)';
     { }
          49: Msg := 'DECOPS';
          50: Msg := 'ReadDec';
          51: Msg := 'WriteDec';
          52: Msg := 'ReadStructure';
          53: Msg := 'WriteStructure';
          54: Msg := 'FReadInt2';
          55: Msg := 'FWriteInt2';
          56: Msg := 'Int2Ops';
          else
              Msg := Format('Unknown %d [%s]', [CallNum, MemDumpDw(0, wt_DynamicCallStack)]);
        end;
        OutputDebugStringFmt('System call (%d) %s', [CallNum, Msg]);
{$EndIF ListSyscallEvents}
      end;
  end;
end;
{$endIf Debugging}

// ClrGDirP - clear global directory pointer
Procedure TIIPsystemInterpreter.ClrGDirP;   {check global directory pointer}
Begin
  with Globals.LowMem.Syscom do
    If GDIRP <> pNIL then
      begin
        {else release GDIRP from heap}
        HeapTop := GDIRP;   // restore heap pointer
        GDIRP   := pNIL;
      end;
end;

Procedure TIIPsystemInterpreter.PUSHint(x:integer);
begin
{$R-}
  SP := SP - 2;
  WordAt[SP] := x;
{$R+}
end;


Procedure TIIPsystemInterpreter.POPint(Var x:integer);
{pop integer for integer compare opcodes}
begin
{$R-}
  X  := WordAt[SP];
  SP := SP + 2;
{$R+}
end;

function TIIPsystemInterpreter.PopInt: integer;
begin
  PopInt(result);
end;

{error stuff}

Procedure TIIPsystemInterpreter.INVNDX;
Begin
  UnImplemented('INVNDX');
//XEQERR(INVNDXC);
end;

Procedure TIIPsystemInterpreter.S2LONG;
Begin
  UnIMplemented('S2LONGC');
//XEQERR(S2LONGC);
end;

Procedure TIIPsystemInterpreter.EX(Var xx,yy:word);
var temp : word;
Begin
  Temp := xx;
  xx   := yy;
  yy   := temp;
end;

(*
Procedure TIIPsystemInterpreter.RRD;
{          ___________  ____
           |          | |   |
           |          v |   v
   ___________      ___________
   |7..4|3..0|      |7..4|3..0|
   -----------      -----------
           ^                |
           |________________|

      A                (HL)
}

Var loA,HiHL,LoHL : 0..$F;
Begin
  loA := A AND $F;
  loHL:= Bytes[HL] AND $F;
  hiHL:= (Bytes[HL] and $F0) shr 4;
  {now do it}
  A:= A AND $F0;
  A:= A OR loHL;
  Bytes[HL] := (loA shl 4) + hiHL;
end;
*)


Procedure TIIPsystemInterpreter.SaveIPC;
Begin
  IPCSAV := BC;
{$IfDef debugging}
  ProcBaseSave := ProcBase;
{$EndIf}
end;

// Name:    DoTreeSearch
//          TreeSearch(rootp:^node; VAR foundp:^node; VAR target:alfa):integer;
// Returns: 0:  FoundP points to matching node
//          +1: FoundP points to a leaf, target > foundp.key
//          -1: FoundP points to a leaf, target < foundp.key
  procedure TIIPsystemInterpreter.DoTreeSearch;
  var
    KeyValueAddr  : word;
    FoundP        : word;                // does not change
    RootAddr      : word;
    Node          : word;
    KeyValue      : Talpha;
  begin
    KeyValueAddr    := POP();  // ptr to target.
    FoundP          := POP();  // save address for result
    RootAddr        := POP();  // rootp
    KeyValue        := TAlpha_Ptr(@Bytes[KeyValueAddr])^;
  {$R-}
//  WordAt[SP]      := TreeSearch(RootAddr, node, KeyValue);  // 10/27/2021 original
    PUSH(TreeSearch(RootAddr, node, KeyValue));               // 10/27/2021
  {$R+}
    WordAt[FoundP]  := node;
  end;

// Name:    TreeSearch
// Purpose: Search a sub-tree for a paticular string
// Entry:   root - root of the sub-tree to search
//          node - node containing the string, if found
//          key = ^ string to search for
  Function TIIPsystemInterpreter.TreeSearch(root: word; var node: word; const key: TAlpha): integer;
  var
    last: word;
    Node_Ptr: TTree_NodePtr;
  Begin
    node := root;
    Repeat
      Node_Ptr := TTree_NodePtr(@Bytes[node]);
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

procedure TIIPsystemInterpreter.CSPIOR;
begin
  with Globals.LowMem.Syscom do
    begin
      push(ord(IORSLT));
//    iorslt := INOERROR;   // NOTE: NOT clearing this may be a kludge work-around only for VI.5?
                            //       According to the source code in I5Z80Interp.txt, the IORSLT is not cleared
    end;
end;

(*
   function TIIPsystemInterpreter.CheckForSegDict(aResult: TIORsltWD; UBLK, UNUM: word): TSegInfoRecP;  // Kludge - see if we just read a segment dictionary. If so, save the segment names.
   var
      Idx, NrEntries: word;
      Dict: SDRECORD;
      MaxBlock: integer;
   begin
     RESULT := NIL;
     with Globals.Lowmem.Syscom do
       begin
         // Look for this block number as the first block of a file in the directory and check if this is a code file.
         // gDirp should have already been verified as <> pNil before we got here.
         with TDIRPtr(@Bytes[gDirp])[0] do
           begin
             NrEntries := DNUMFILES;
             MaxBlock  := DEOVBLK;
           end;

         if NrEntries <= MAXDIR then
           for Idx := 1 to NrEntries do
             with TDIRPtr(@Bytes[gDirp])[Idx] do
               if (UBLK = DFIRSTBLK) and (DFKIND = kCODEFILE) then // we found a matching code file
                 begin  // So the buffer actually contains a segment dictionary
                   Dict := SDRecordPtr(@Bytes[UBUF])^;
                   // The buffer should already have a segment dictionary loaded-- add it to the list of known .code files
                   SaveSegInfoForFile(UNUM, UBLK, DTID, Dict, MaxBlock);  // Save the segment names
                   Break;
                 end;
       end;
   end;
*)


//------------------------------------------------------------------------------
// CALLIO
//       CALL A DRIVER ROUTINE
// INPUT
//       TOS = UNIT NUMBER
// OUTPUT
//       Result := IOResult // dhd 4/9/2018
//------------------------------------------------------------------------------

procedure TIIPsystemInterpreter.CallIO;
var
  result: TIORsltWD;

begin { TIIPsystemInterpreter.CallIO }
  UNUM := POP();                 // get UnitNr from TOS

//IOError(INOUNIT);  // assume the worst
  result := INOUNIT;  // Assume the worst

  if UNUM < MAX_STANDARD_UNIT then
    begin
      if (UNUM > 0) and Assigned(UNITBL[UNUM].Driver) then
        with UNITBL[UNUM] do
          begin
            result := Driver.Dispatcher(UREQ, UBLK, ULEN, Bytes[UBUF], control);

            if (result = INOERROR)              // Did the operation succeed?
                and  (UNUM in LEGAL_UNITS)      // is a disk operation (not console, etc)?
//              and  (ULEN = BLOCKSIZE)         // is a blocksize operation?  V1.4 only loads 1st 64 bytes of SYSTEM.COMPILER
                and  (UREQ in [INBIT, OUTBIT])  // Was it an input/output operation?
                and  (Globals.Lowmem.Syscom.gDirp <> pNil) then      // has the directory been loaded?
              CheckForSegDict(result, UBLK, UNUM);  // Kludge - see if we just read/wrote a segment dictionary. If so, save the segment names.
          end;
    end;

  IOError(result);
end;  { TIIPsystemInterpreter.CallIO }

procedure TIIPsystemInterpreter.IOError(Num: TIORsltWd);
begin
  Globals.LowMem.SysCom.IORSLT := num;
end;


procedure TIIPsystemInterpreter.CSPIOCheck;
begin
  with Globals.LowMem.Syscom do
    if IORSLT <> INOERROR then
      begin
//      raise EXEQERR.Create('IO error %d', [ord(IORSLT)], UIOERRC);
        fErrCode := UIOERRC;
        raise EXEQERR.CreateFmt('IO error %d', [ord(IORSLT)]);
      end;
end;

{NEW(VAR p:^; size:integer)}
{p  := HeapTop; HeapTop := HeapTop+size of p}
procedure TIIPsystemInterpreter.CSPNew;
begin
  ClrGDirP;         {release GDIRP if necessary}
  DE := POP();      {size p IN WORDS}
  HL := Pop();      {^p}            {addr2}
                    {p:=HeapTop}
  FillChar(Bytes[HeapTop], DE*2, 0);   // just zeroing the memory 11/17/2021

  WordAt[HL] := HeapTop;
                  {extend heap}
  HeapTop := HeapTop + DE*2; {NOTE that the size is in words so *2 to bytes}
  STKCHK;
  if StackOverFlow then
    stkovr;
end;

procedure TIIPsystemInterpreter.CSPMove;
var
  Len: integer;
begin
{$R-}
  Len := POP();     {length}
{$R+}
  if Len > 0 then
    begin
      DE  := POP();     {^dest}       {addr2}
      HL  := Pop();     {^source}      {addr2}
      Move(Bytes[HL], Bytes[DE], Len);
    end;
end;

procedure TIIPsystemInterpreter.CSPExit;
begin
  UcsdExit;
end;

{ UNITREAD(UNITNUMBER,ARRAY,LENGTH,[BLOCKNUMBER], [INTEGER] }
procedure TIIPsystemInterpreter.CSPUnitReadWriteCommon(ReqBit: word);
begin
  IOError(INOERROR);
  try
    POP(UCTL);  {assumed=0, if 1 then async transfer}
    POP(UBLK);
    POP(ULEN);

    UBUF := POP();

    UREQ := ReqBit;

    CallIO;
  except
    IOError(IBADBLOCK);
  end;
end;



procedure TIIPsystemInterpreter.CSPUnitRead;
begin
  CSPUnitReadWriteCommon(INBIT)
end;

procedure TIIPsystemInterpreter.CSPUnitWrite;
begin
  CSPUnitReadWriteCommon(OUTBIT)
end;

{the clock increments lowtime & hitime every 1/60 sec}
procedure TIIPsystemInterpreter.CSPTime;
begin
{$R-}     // assigning an integer to a word could get a range check error
  UpdateTime;
  HL := Pop();                          {addr2}
  WordAt[HL] := Globals.LowMem.SysCom.LOTIME;
  HL := Pop();                          {addr2}
  WordAt[HL] := Globals.LowMem.Syscom.HITIME;
{$R+}
end;

{FLC} {fillchar(buffer:^;count:integer;ch:char);}
procedure TIIPsystemInterpreter.CSPFLC;
var
  Len: integer;
begin
{$R-}   // use an integer for things like moving 65536 bytes (for example)
  DE  := POP();  {char}
  Len := POP();  {count}
  HL  := Pop();  {^buffer}       {addr2}
  if Len > 0 then
    FillChar(Bytes[HL], Len, DE);
{$R+}
end;

procedure TIIPsystemInterpreter.CSPScan;
var
  Start    : word;
  ForPast  : word;
  MaxDisp  : integer;
  ch       : char;
  CompCode : char;
  i        : integer;
begin
  HL      := Pop();   {junk the mask.. now obsolete }
  start   := Pop();   {addr2}
  ch      := CHR(POP());
  forpast := PopInt();
  maxdisp := PopInt();
  case forpast of
    0: compcode := '=';
    1: compcode := '#';
    else
      raise Exception.Create('scan parameter bug');
  end;
  i := Scan(maxdisp, compcode, Ch, start);
  pushint(i);
end;

{used in loading units ? other uses as well}
procedure TIIPsystemInterpreter.CSPGetSeg;
var
  SegWasReadIn: boolean;
begin
  HL := Pop();
  SEGP := GETSEG(L, SegWasReadIn);       {with A=segnum}
  STKCHK;          {make sure we did not wipe out heap}
  GetSavedIPC;
end;

{Standard proc release seg}
procedure TIIPsystemInterpreter.CSPReleaseSeg;
begin
        {decs refcount then junks seg if count = 0}
  Assert(false, 'CSPReleaseSeg is not implemented');
(*
    HL := Pop();
    if DecRef(L) then
      begin
      GetSavedIPC;
      Exit;
      end;
    {refcount=0,  set DE:=^seg} {addr2}
    {here if refcount=0, then decref should leave HL:=^entry in intseg}
    {but pascal version of interp had HL==seg# to dec BUG 16}
    {so next pascal line replaces 3 commented out lines}
    {assumes HL still has seg # }
    DE := INTSEGT[HL].SEGTOP;     {bug 16 fix 15/7/93 Interp7}

    ex(fDE.w,fHL.w);    {then set SP:=^seg+2}
    L := L + 1;
    inc(fHL.w);
    SP:=HL;
    GetSavedIPC;
  end;
*)
end;

procedure TIIPsystemInterpreter.CSPTrunc;
  var
    Longi:Longint;
    R1: TRealUnion;
begin
  Pop(R1);
  Longi := trunc(R1.UCSDReal2);  {8/11/04 i:=trunc(UCSDReal2) gave RTE 201}
  push(Longi);                   {convert long integer to smallint and push}
end;

procedure TIIPsystemInterpreter.CSPRound;
var
  w: word;
  Longi: longint;
  R1: TRealUnion;
begin
  Pop(R1);
  Longi := round(R1.UCSDReal2);
{$R-}    // the following line might overflow
  w     := Longi;
{$R+}
  push(w);
end;

procedure TIIPsystemInterpreter.CSPSine;
var
  R1: TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := sin(R1.UCSDReal2);
  Push(R1);
end;

procedure TIIPsystemInterpreter.CSPCosine;
var
  R1: TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := cos(R1.UCSDReal2);
  Push(R1);
end;

procedure TIIPsystemInterpreter.CSPLog;
begin
  UnImplemented('CSPLog');
end;

procedure TIIPsystemInterpreter.CSPAtan;
var
  R1  : TRealUnion;
begin
  pop(R1);
  R1.UCSDReal2 := ArcTan(R1.UCSDReal2);
  Push(R1);
end;

{ ln y:=ln(x)}
procedure TIIPsystemInterpreter.CSPLn;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := ln(R1.UCSDReal2);
  Push(R1);
end;

{ EXP y:=exp(x)}
procedure TIIPsystemInterpreter.CSPExp;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := exp(R1.UCSDReal2);
  Push(R1);
end;

{r:=sqrt(r)}
procedure TIIPsystemInterpreter.CSPSqrt;
var
  R1  : TRealUnion;
begin
  Pop(R1);
  R1.UCSDReal2 := sqrt(R1.UCSDReal2);
  Push(R1);
end;

{MARK(Var i:^integer)...store HeapTop in i}
procedure TIIPsystemInterpreter.CSPMark;
begin
  ClrGDirP;    {release gdirp if necessary}
  DE := POP();   {addr2}
  WordAt[DE] := HeapTop;
end;

{RELEASE(Var i:^integer)...store i into HeapTop}
procedure TIIPsystemInterpreter.CSPRelease;
begin
  HL := Pop();     {^i}   {addr2}
  HeapTop := WordAt[HL];
  Globals.LowMem.Syscom.GDIRP := pNIL;
end;

{UNITBUSY}
procedure TIIPsystemInterpreter.CSPUnitBusy;
begin
  UNUM := Pop();
  Push(false);  // right now, nothing is ever busy
end;

procedure TIIPsystemInterpreter.CSPPwrOfTen;
var
  i: integer;
  R1  : TRealUnion;
begin
  {die if not 0<=i<=37}
  popint(i);
  {add check for 0..37 here}
  R1.UCSDReal2 := PwrOfTen[i];
  Push(R1);
end;

{UNITWAIT}
procedure TIIPsystemInterpreter.CSPUNITWAIT;
begin
  UNUM := POP();
  with UNITBL[UNUM] do
    if Assigned(Driver) then
      begin

      end
      //Driver.UnitWait  why is this commented out? Maybe because nothing is ever busy. 
    else
      IOError(INOUNIT);
end;

procedure TIIPsystemInterpreter.CSPUnitClear;
begin
  UREQ  := CLRBIT;
  UBLK  := 0;
  CallIO;
end;

procedure TIIPsystemInterpreter.CSPHalt;
begin
//raise ESYSTEMHALT.Create('HALT CSP 39');
  HaltPSys('HALT CSP 39');
end;

procedure TIIPsystemInterpreter.CSPMemAvail;
begin
  HL := SP - HeapTop;
  HL := HL shr 1;   {convert to words}      {byte to words}
  PUSH(HL);         {push function result}
end;


Procedure TIIPsystemInterpreter.CSP;
var
  CSPCode: word;
Begin
  CSPCode := Bytes[BC];
//ENTERING('CSP', CSPCode);
  inc(fBC.w);
  SaveIPC;      // If a segment gets loaded, the saved IPC will be needed
  with OpsTable.CSPTable[CSPCode] do
    begin
{$IfDef Pocahontas}
      PHITS := PHITS + 1;
{$EndIf}
      if Assigned(ProcCall) then
        ProcCall
      else
        raise Exception.CreateFmt('Unimplemented CSP %d',[CSPCode]);
    end;
//EXITING('CSP', CSPCode);
end;



function TIIPsystemInterpreter.GetBig: word;
var
  DE: TUnion;
Begin
  A   := Bytes[BC];    {get byte from code stream}
  INC(fBC.w);
  DE.W := A;
  If (A and $80) <> 0 then  // if signed
    begin
      {if here is big}
      DE.H := A and $7f;
      DE.L := Bytes[BC];
      INC(fBC.w);
    end;
  result := DE.W;
//result := DE.W SHL 1;  // Only for Version II -- NOT I.5
end;



Procedure TIIPsystemInterpreter.BPT;
//var
//  sourceline:integer;    {line that bpt refers to}
Begin
  {SourceLine  :=} GetBig;  // Why?  Could I use this to flag that a new program has started and do something useful?
  Unimplemented('BPT');
end;


{************** LOADING STORING INDEXING MOVING*****************}

Procedure TIIPsystemInterpreter.LDCI;   {Load constant word}
Begin
  L  := Bytes[BC];     // get the low byte
  H  := Bytes[BC+1];   // get the high byte
  PUSH(HL);
  BC := BC + 2;
end;



Procedure TIIPsystemInterpreter.LDCN;   {Load constant nil pointer}
Begin
  PUSH(pNil);
end;



{************** LOCAL VARS *****************}


Procedure TIIPsystemInterpreter.SLDL; {short load local word - ? like SLDO}
{in this turbo version A is not doubled in the opcode fetch routine,
 back so at this point  A = $D8..$E7, ie the actual value of SLDL1..16}
Begin
  A  := (fOpCode-$D7) * 2;    {adjust opcode for correct byte offset}
  HL := LocalVar + A;       {compute address of var}  {addr2}

  DE    := WordAt[HL];
  PUSH(DE);
end;



Procedure TIIPsystemInterpreter.LLA;   {load local address}
Begin
  DE := GetBig;
  HL := LocalVar + DE*2;    {addr2}
  PUSH(HL);
end;

Procedure TIIPsystemInterpreter.LDL;   {load local word}
Begin
  DE := GetBig;
  HL := LocalVar + DE*2;           {addr2}
  DE := WordAt[HL];
  PUSH(DE);
end;


Procedure TIIPsystemInterpreter.STL;  {store local word}
Begin
  DE := GetBig;
  HL := LocalVar + DE*2;     {addr2}
  DE := POP();
  WordAt[HL] := DE;
end;



{************** GLOBAL VARS *****************}




Procedure TIIPsystemInterpreter.SLDO; {short load global word - like SLDL}
{in this turbo version A is not doubled by back so at this point
 A = $E8..$F7}
Begin
  A  := (fOpCode-$E7) * 2;    {adjust opcode for correct offset}
  HL := GlobVar + A;     {addr2}
  DE := WordAt[HL];
  PUSH(DE);
end;


Procedure TIIPsystemInterpreter.LAO;  {load global address}
{same as LLA except index from GlobVar not LocalVar}
Begin
  DE := GetBig;
  HL := GlobVar + DE*2;         {addr2}
  PUSH(HL);
end;




Procedure TIIPsystemInterpreter.LDO;  {load global word}
Begin
  DE := GetBig;
  HL := GlobVar + DE*2;   {addr2}
  Push(WordAt[HL])
end;



Procedure TIIPsystemInterpreter.SRO;    {store global word}
Begin
  DE := GetBig;
  HL := GlobVar + DE*2;   {addr2}
  DE := POP();
  WordAt[HL]  := DE;
end;

{************** INTERMEDIATE VARS *****************}
Procedure TIIPsystemInterpreter.GETIA; {get intermediate address into HL, used by LDA, LOD, STR}
Begin
  A := Bytes[BC];   {get # of lex levels..always > 1 {dhd: I think this should be > 0?}
  INC(fBC.w);
  HL := Globals.LowMem.Syscom.LASTMP;        {addr2- Get latest MPCW}

  {DE := Bytes[HL] + Bytes[HL+1] * 256;} {go up static links till right MSCW}
(*
  repeat
    E  := Bytes[HL];
    D  := Bytes[HL+1];    {do it thus to avoid rte 201}
//  DE := WordAt[HL];       // Why is this not the same as above?
    INC(fHL.w);
    EX (fDE.w, fHL.w);    {use the static link as the next MSCW. Next static link --> HL}
    A := A - 1;
  until A = 0;
*)
  repeat
    HL := WordAt[HL];     // Get the current static link
    A := A - 1;
  until A = 0;

  // At this point, HL has the desired MSCW
  DE := GetBig;
  HL := HL + DE*2 + DISP0;    {point to the desired variable within the specified procedure}
end;




Procedure TIIPsystemInterpreter.LDA; {load intermediate address}
Begin
  GETIA;
  PUSH(HL);    {addr2}
end;




Procedure TIIPsystemInterpreter.LOD; {load intermediate word}
Begin
  GETIA;       {addr2}
  DE    := WordAt[HL];
  PUSH(DE);
end;



Procedure TIIPsystemInterpreter.STR;  {store intermediate word}
Begin
  GETIA;      {addr2}
  DE := POP();
//Bytes[HL] := DE mod 256;
//Bytes[HL+1] := (DE and $FF00) shr 8;
  WordAt[HL] := DE;
end;



{************** Indirect records, arrays and indexing *************}

Procedure TIIPsystemInterpreter.INCR;   {increment (SP) by literal}
Begin
  DE := GetBig;     // get increment
  if VersionNr >= vn_VersionII then
    DE := DE shl 1;  // version II passes a word addr which we must convert to a byte addr
  HL := Pop();    // get the number
  HL := HL + DE;  // increment it
  PUSH(HL);       // put it back where we got it
end;

Procedure TIIPsystemInterpreter.STO;  {store indirect}
Begin
  DE := POP();   {value}
  HL := Pop();   {address}    {addr2}
  WordAt[HL] := DE;
end;

{$R-}
Procedure TIIPsystemInterpreter.SIND0;  {Short index and load word, index=0, load indirect.}
                                        {This is just a special slightly faster case of SIND}
Begin
  HL := Pop();   {addr2}
  DE := WordAt[HL];
  PUSH(DE);
end;
{$R+}



Procedure TIIPsystemInterpreter.SIND;  {short index and load word, index>0, load indirect}
{ $F9..$FF pcodes}
Begin
  HL := POP();          {addr2}
  A  := (fOpCode-$F8) * 2;    {adjust opcode for correct offset}
  HL := HL + A;         {calculate address}
  DE := WordAt[HL];     {load the value}
  PUSH(DE);
end;






Procedure TIIPsystemInterpreter.STIND;  {Static index and load word}
Begin
  HL := Pop();        {Base address}  {addr2}
  DE := GetBig;       {get index from code}
  HL := HL+DE*2;      {word index to byte index and add base}
//DE := Bytes[HL] + Bytes[HL+1]*256; {load it}
  DE := WordAt[HL]; { load it }
  PUSH(DE);
end;




Procedure TIIPsystemInterpreter.IXA; {index array}
var
  Base, Idx, ElementSize: integer;
  Offset: integer;
Begin
  ElementSize := GetBig;   {get array element size in words}
{$R-}
  Idx         := POP();     {word INDEX}
  Offset := Idx * ElementSize;
  Offset := Offset + Offset;  {make into byte offset}
  Base   := POP();            {get array base (word pointer)}   {addr2}
  Offset := Base + Offset;    {calculate item address}
  PUSH(Offset);     {addr2}   {pushes an addr}
{$R+}  
end;



Procedure TIIPsystemInterpreter.MOV;   {move words}
var
  WordCnt, ByteCnt, Src, Dst: word;
Begin
  WordCnt := GetBig;      {DE := # words to move}
  ByteCnt := WordCnt*2; {BC:= # bytes to move}
  Src     := Pop();    {^source}       {addr2}
  Dst     := POP();    {^dest}         {addr2}

  Move(Bytes[src], Bytes[Dst], ByteCnt);
//Repeat
//  Bytes[Dst] := Bytes[Src];
//  inc(Dst);
//  inc(Src);
//  dec(ByteCnt);
//until ByteCnt = 0;
end;

{************** Multiple word VARS *************}

Procedure TIIPsystemInterpreter.LDC;  {Load multiple word constant..const is backwards in code stream
                                       and is word aligned}
var b:byte;
{note for 2 word pointer expansion: here the addr is implicit in the pcode ipc BC}
Begin
  A  := Bytes[BC];    {BC=#words to load}
  HL := BC + 2;       {put HL on word boundary}   {? check word alignment later}
  B  := A;            {b:= # words to move}
  HL := HL and $FFFE;
  While B > 0 do
    Begin
      DE := WordAt[HL];
      HL := HL + 2;
      PUSH(DE);     {....to stack}
      Dec(B);
    end;
  BC := HL;      {fix up ipc}
end;


Procedure TIIPsystemInterpreter.LDM;  {Load multiple words (no more than 255)}
var
  BP: word;
  CX: word;
Begin
(*
  DE := POP();       {DE := ^source}   {addr2}
  A  := Bytes[BC]; {a := # words to transfer}
  INC(fBC.w);       {point IPC past # words to load}
  If A = 0 then exit; {supposedly unnecessary ...just in case}

  HL := DE + A*2;
  While A > 0 do
    Begin
    DEC(fHL.w);    {yes this is correct....zero not 1 based indexing}
    DE := Bytes[HL]*256 + Bytes[HL-1];
    DEC(fHL.w);
    PUSH(DE);     {....to stack}
    A := A - 1;
    end;
*)
    BP      := POP();       // GET POINTER TO BLOCK OF WORDS
    CX      := Bytes[BC];  // GETCOUNT (assume > 0)
    BC      := BC + 1;
                           // Version IV does a stack check here
    BP      := BP + (CX * 2);  // start at the end
    repeat
      BP := BP - 2;
      PUSH(WordAt[BP]);
      CX := CX - 1;
    until cx = 0;
end;



Procedure TIIPsystemInterpreter.STM;   {Store multiple words}
Begin
  A := Bytes[BC];   {number of words to transfer}
  INC(fBC.w);       {point IPC past # of words to load}
  If A<>0 then
    begin
      HL := SP + A*2; {HL := ^dest...buried under words on stack} {addr2} {convert from word offset to byte offset }
      DE := WordAt[HL];
      HL := DE;           // HL is now the destination
      While A > 0 do
        Begin
          WordAt[HL] := POP();  {transfer the stuff from stack}
          HL := HL + 2;
          A := A - 1;
        end;
    end;
  HL := POP();       {junk ^dest} {addr2....but already referenced/not popped above}
end;





Procedure TIIPsystemInterpreter.MVB;    {Move bytes}
var
  Src, Dst, ByteCnt: word;
Begin
  ByteCnt := GetBig;
  Src := Pop();     {^source}      {addr2}
  Dst := POP();     {^dest}        {addr2}

  Move(Bytes[Src], Bytes[Dst], ByteCnt);
end;


{*********** Character VARS AND BYTE ARRAYS *****************}

Procedure TIIPsystemInterpreter.LDB;  {load byte}
Begin
  HL := POP();     {HL := ^CHAR}  {addr2}
  DE := Bytes[HL];
  PUSH(DE);    {hi order byte = 0}  {?should we explicitly clear it}
end;


Procedure TIIPsystemInterpreter.STB;  {store byte}
Begin
  DE := POP();     {E = char}
  HL := Pop();     {HL := ^dest}  {addr2}
  Bytes[HL] := (DE and $00FF);   {what about := E only}
     {hi order byte = 0}
end;





{*********** STRING VARS *****************}

Procedure TIIPsystemInterpreter.SAS;   {String assignment}
{ on stack can either be   ^src string,  ^dst string
                      OR   a char     ,  ^dst string}

var MaxLen : integer;  {declared size of dest string}
    i,len:integer;  (* debugging only to show the string that was too long*)
    Msg: string;
Begin
  A      := Bytes[BC];     // Get declared length of string
  MaxLen := A;
  INC(fBC.w);
//SaveIPC;
  HL := POP();     {get the source}   {addr2}  {but be careful here}
  If HL div 256 = 0 then {lose first 256 bytes of heap for this shitty code! LB}
    begin   {if char then hi byte = 0}
      If MaxLen < 1 {source for char} then
        begin
          HL := POP();  {junk dest}
          Msg := Format('S2LONG ERR: Len = 1 (a char), Maxlen = %d', [MaxLen]);
          frmPSysWindow.Writeln(Msg);
          S2LONG;
//        raise ESYSTEMHALT.Create(Msg);
          HaltPSys(Msg);
        end;
      DE := POP();    {DE := ^dst str}  {addr2}
      Bytes[DE] := 1;  {string 1 char long}
      Bytes[DE+1] := HL mod 256;  {the actual char}
    end
  else
    begin
(*TEMP PATCH TO STOP S2LONG ERROR*)
//    If Bytes[HL] > maxlen then
//      Bytes[HL] := maxlen;
      Len := Bytes[HL];
      If Len > MaxLen then
        Begin
          frmPSysWindow.Writeln(['S2LONG ERR: Len = ', Len, ' MaxLen =', MaxLen]);
          (* show the string *)
          for i := 1 to Len do
            frmPSysWindow.write(chr(Bytes[HL+i]));
          HL := POP();  {junk dest}       {addr2}
          S2LONG;
          SYSHALT;
        end;
      DE  := POP();    { DE := ^dest}    {addr2}
      Len := Bytes[HL];
      INC(Len);    {for length byte}
      Move(Bytes[HL], Bytes[DE], Len);
    end;
end;


Procedure TIIPsystemInterpreter.LPA;   {208: LPA 2.0}
{string to packed array on TOS}
Begin
  DE := POP();    {addr2}
  INC(fDE.W);    {just point pointer past length byte}
  PUSH(DE);   {addr2}
end;

{******** PACKED ARRAYS AND RECORDS ***********}


// IXP: 192 ($C0)
// Index Packed Array. TOS is an integer index, TOS-1 is the array base
// word pointer. UB_1 is the number of elements per word, and UB_2 is the
// field-width (in bits). Compute and push a packed field pointer.
procedure TIIPsystemInterpreter.IXP;
var
  BP, DI, Temp: word;
  AX, CX: TUnion;
begin
    BP := Bytes[BC];      // (BYTETOBP) # Elements / word
    BC := BC + 1;             // assume that DF is always 0
//  AH.h := 0;
{$R-}
    AX.W := CBW(Bytes[BC]);  // (LODSB) get byte and convert to word (sign extend AL)
{$R+}
    BC := BC + 1;
    EX(AX.w, CX.w);         // CX := FIELD WIDTH (# OF BITS PER ELEMENT)
    AX.w  := POP();         // INDEX INTO PACKED ARRAY
    DI    := POP();         // BASE OF PACKED ARRAY
    Temp  := AX.w MOD BP;   // remainder
    AX.w  := AX.w DIV BP;   // quotient (INDEX/ELEMENTS PER WORD)
                            // BP STILL HAS # OF ELEMENTS PER WORD
    AX.w  := AX.w SHL 1;    // # OF BYTES TO ADD TO BASE TO BE POINTING
                            // AT CORRECT WORD
    DI  := DI + AX.w;
    PUSH(DI);               // PUSH POINTER TO INDEXED WORD
    PUSH(CX.W);             // PUSH BITS PER ELEMENT
    AX.w  := Temp * CX.l;   // REMAINDER*BITS-PER-ELEMENT
    PUSH(AX.w);             // PUSH RIGHT BIT #
end;



Procedure TIIPsystemInterpreter.LDP;      {load a packed field}
 {get the field described by right bit number, bits per element,
  ^word, all info is on the stack}
var
  Addr, NrBits, TheWord, BitNr: word;
Begin
  BitNr   := POP();           // RIGHT BIT#  0..15
  NrBits  := POP();           // BITS-PER-ELEMENT
  Addr    := POP();           // ADDR OF WORD FIELD IS IN
  TheWord := WordAt[Addr];      // MOV CONTENTS OF WORD INTO BP
  TheWord := GetBits(TheWord, BitNr, NrBits);
  PUSH(TheWord);              //PUSH THE FIELD
end;




Procedure TIIPsystemInterpreter.STP;     {Store into a packed field}
{Given data, right bit number, bits per element, ^target}
var
  Addr, NrBits, TheWord, NewData: word;
  BitNr: byte;
Begin
  NewData := POP();      {New data}
  BitNr   := POP();      {right bit number}
  NrBits  := POP();      {width}
  Addr    := POP();      {where to get the value to be stored into}
  TheWord := WordAt[Addr];
  SetBits(TheWord, BitNr, NrBits, NewData);
  WordAt[Addr] := TheWord;
end;






{******TOP of STACK ARITHMETIC*******}

{***** Logical}


Procedure TIIPsystemInterpreter.LAND;
{logical and}
Begin
//HL := pop();
//DE := POP();
//HL:= HL and DE;
//push(HL);
  PUSH(Pop() and Pop());
end;

Procedure TIIPsystemInterpreter.LOR;
{logical or}
Begin
//HL := pop();
//DE := POP();
//HL := HL or DE;
//push(HL);
  PUSH(POP() or POP());
end;


Procedure TIIPsystemInterpreter.LNOT;
var
  i: integer;
{logical not}
Begin
//Push(not POP());       // can't be trusted
  i := POP();
  i := i and $1;         // low bit only
  push(not Boolean(i));
end;






{***** integer}

Procedure TIIPsystemInterpreter.ABI; {absolute value}
var
  Temp: integer;
Begin
{$R-} // ABS function would assume a 32 bit integer when it is really a 16 bit integer.
      // This causes a fail on negative 16 bit values. This caused extremely difficult to detect bugs.
  Temp := Pop();
{$R+}
  PUSH(Abs(Temp));
end;


Procedure TIIPsystemInterpreter.ADI;   {add integers}
Begin
{$R-}
  PUSH(POP()+POP());
{$R+}
end;

Procedure TIIPsystemInterpreter.DVI; {divide integers}
var
//a,b:integer;
  TOS, TOS1: integer;
Begin
{$R-}
  TOS  := Pop(); {divisor}
  TOS1 := Pop(); {dividend}
  PUSH(TOS1 div TOS);
{$R+}
end;



Procedure TIIPsystemInterpreter.MODI; {remainder of integer division}
var
  TOS, TOS1: word;
Begin
//SaveIPC;
//BC := POP();  {divisor}
//DE := POP();  {dividend}
//DIVD;
//PUSH(HL); {remainder}
//GetSavedIPC;
  TOS  := POP();
  TOS1 := POP();
  PUSH(TOS1 mod TOS);
end;



Procedure TIIPsystemInterpreter.MPI;   {integer multiply}
//var a,b:integer;
Begin
//POPint(b);
//POPint(a);
//a := a*b;
//pushint(a)
{$R-}
  PUSH(Pop() * Pop());
{$R+}
end;



Procedure TIIPsystemInterpreter.SQI;   {integer square}
var a:integer;
Begin
  POPint(a);
  a := a*a;
  pushint(a);
end;





Procedure TIIPsystemInterpreter.NGI;  {negate integer}
Begin
  HL := POP();
{$R-}           {of a word then next line dies with r+ }
  HL := -HL;    {forget range checking as RTE sometimes}
  PUSH(HL);
{$R+}
end;



Procedure TIIPsystemInterpreter.SBI;  {subtract integer}
var
  a, b: integer;
Begin
{$R-}
  a := Pop();
  b := Pop();
  PUSH(B-A);
{$R+}
end;



Procedure TIIPsystemInterpreter.CHK;  {range check}
var a,b,x:integer;
{uses integer as a word that is negative integer does not compare correctly}
Begin
  b := pop(); // popint(b); {POP(HL);}    {MAX}
  a := pop(); // popint(a); {DE := POP();}    {MIN}
//x := Bytes[SP] + Bytes[sp+1]*256;   {leave it on stack}
  x := WordAt[SP];  // leave it on the stack
  If (x < a{DE}) or (x > b{HL}) then
    begin
      SaveIPC;
//    raise EXEQERR.Create('RANGE CHECK ERROR. Min Value = %d, MaxValue = %d, Value = %d', [a, b, x], INVNDXC);
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('RANGE CHECK ERROR. Min Value = %d, MaxValue = %d, Value = %d', [a, b, x]);
    end;
//  begin
//    SaveIPC;
//    INVNDX;
//  end;
end;

{************** Floating point stuff*************}

Procedure TIIPsystemInterpreter.FLT;
{pop integer off stack 2 bytes, and push real 4bytes}
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
Procedure TIIPsystemInterpreter.FLO;
{flo nos}
{pop real off stack, pop integer, float it, push it, push real}
Var //i:integer;
  R1, R2: TRealUnion;
Begin
  Pop(R1);             // Pop the floating point number on the TOS and save it.
  R2.UCSDReal2 := Pop();  // Pop the integer value and convert to real.
  Push(R2);              // Put back the now floated integer
  Push(R1);            //   and then the original floating number that was on the TOS.
end;





Procedure TIIPsystemInterpreter.ADR;
{add reals tos and nos....leaves result on stack}
var
  R1 : TRealUnion;
  R2 : TRealUnion;
Begin
  POP(R1);
  POP(R2);
  R1.UCSDReal2 := R1.UCSDReal2 + R2.UCSDReal2;
  PUSH(R1);
end;



Procedure TIIPsystemInterpreter.MPR;
{mult reals tos and nos....leaves result on stack}
var
  R1 : TRealUnion;
  R2 : TRealUnion;
Begin
  POP(R1);
  POP(R2);
  R1.UCSDReal2 := R1.UCSDReal2 * R2.UCSDReal2;
  PUSH(R1);
end;


Procedure TIIPsystemInterpreter.DVR;
{divide reals nos by tos....leaves result on stack}
var
  R1 : TRealUnion;
  R2 : TRealUnion;
Begin
  POP(R1);        // TOS
  POP(R2);        // NOS
  try
    R1.UCSDReal2 := R2.UCSDReal2 / R1.UCSDReal2;
  except
    R1.UCSDReal2 := 0;
{$IfDef Debugging}
    raise EXEQERR.CreateFmt('Real Divide by 0.0 in %s.Proc #%d. IPC=%d', [CurrentSegName, CURPROC, RelIPC], );
{$else}
    raise EXEQERR.CreateFmt('Real Divide by 0.0 in %s.Proc #%d.d', [CurrentSegName, CURPROC]);
{$endIf}
  end;
  PUSH(R1);
end;



Procedure TIIPsystemInterpreter.ABR;
{absolute value of real tos ..leaves result on stack}
var
  X : TRealUnion;
Begin
  POP(X);
  X.UCSDReal2 := abs(X.UCSDReal2);
  PUSH(X);
end;


Procedure TIIPsystemInterpreter.NGR;
{negate value of real tos}
var
  R1 : TRealUnion;
Begin
  POP(R1);
  R1.UCSDReal2 := - R1.UCSDReal2;
  PUSH(R1);
end;



Procedure TIIPsystemInterpreter.SBR;
{subtract tos from nos....leaves result on stack}
var
  R1 : TRealUnion;
  R2 : TRealUnion;
Begin
  POP(R1);
  POP(R2);
  R1.UCSDReal2 := R2.UCSDReal2 - R1.UCSDReal2;
  PUSH(R1);
end;

Procedure TIIPsystemInterpreter.pSQR;
{square reals tos ....leaves result on stack}
var
  R1 : TRealUnion;
Begin
  pop(R1);    
  R1.UCSDReal2 := sqr(R1.UCSDReal2);
  PUSH(R1);     {high}
end;





{**************word comparisons}




Procedure TIIPsystemInterpreter.EQUI;
var a,b:integer;
Begin
{$R-}
  B := Pop();
  A := POP();
  Push(a=b);
{$R+}
end;

Procedure TIIPsystemInterpreter.GEQI;  {>=}
var a,b:integer;
Begin
{$R-}
  B := POP();
  A := POP();
  Push(A>=B);
{$R+}
end;

Procedure TIIPsystemInterpreter.GTRI;  {>}
var a,b:integer;
Begin
{$R-}
  B := POP();
  A := POP();
  Push(A>B);
{$R+}
end;



Procedure TIIPsystemInterpreter.NEQI;   {compare for <>}
var a,b:integer;
Begin
{$R-}
  B := POP();
  A := POP();
  Push(A<>B);
{$R+}
end;


Procedure TIIPsystemInterpreter.LEQI;  {<=}
var a,b:integer;
Begin
{$R-}
  B := POP();
  A := POP();
  Push(A<=B);
{$R+}
end;


Procedure TIIPsystemInterpreter.LESI;  {<}
var a,b:integer;
Begin
{$R-}
  B := POP();
  A := POP();
  Push(A<B);
{$R+}
end;

{*********** Comparison of complex things **********}




Procedure TIIPsystemInterpreter.REALC;
{Real compare}
var 
    R1, R2: TRealUnion;
Begin
  Pop(R2);
  Pop(R1);

  IsEqual              := R1.UCSDReal2 = R2.UCSDReal2;
  IsLessThan           := R1.UCSDReal2 < R2.UCSDReal2;
  IsGreaterThan        := R1.UCSDReal2 > R2.UCSDReal2;
  IsGreaterThanOrEqual := IsGreaterThan or IsEqual;
  IsLessThanOrEqual    := IsLessThan or IsEqual;
end;





Procedure TIIPsystemInterpreter.BOOLC;
{boolean compare}
var a,b:word;
Begin
  pop(b);
  pop(a);

  {only look at bit 0}
  b:= b AND $0001;
  a:= a AND $0001;

  IsEqual              := a = b;
  IsLessThan           := a < b;
  IsGreaterThan        := a > b;
  IsGreaterThanOrEqual := IsGreaterThan or IsEqual;
  IsLessThanOrEqual    := IsLessThan or IsEqual;

end;






Procedure TIIPsystemInterpreter.STRGC;
{Lexicographic string compare}
Var S1, S2: string[255];  // must use old style string in Delphi
Begin
  HL := Pop();    {HL=^S2}          {addr2}
  DE := POP();    {DE=^S1}          {addr2}
  {see if HL or DE (but not both) is really a single char..handle as sas}
  {this assumes that ^S1 or ^S2 is not in first page of memory. Is this a }
  {possible bug in future? LB. It may be if the string is p^.string!! LB}
  {For now assume that ^S1 or ^S2 is not first page of mem 0..$00FF       }
  {Later.. it WAS a bug and the fix is to initialize HeapTop as $0100 not $00}

  If (HL and $FF00) = 0 then {it is a char}  {shitty code LB}
    Begin
      S2 := ' '; S2[1] := chr(HL mod 256);
      move(Bytes[DE],S1,Bytes[DE]+1);   {get the string}
    end
  else
  If (DE and $FF00) = 0 then {it is a char}
    Begin
      S1 := ' '; S1[1] := chr(DE mod 256);
      move(Bytes[HL], S2 ,Bytes[HL]+1);   {get the string}
    end
  else
    Begin
      move(Bytes[DE], S1, Bytes[DE]+1);   {get the string}
      move(Bytes[HL], S2, Bytes[HL]+1);   {get the string}
    end;

  {Here S1 and S2 are strings in turbo}
  IsEqual              := S1 = S2;
  IsLessThan           := S1 < S2;
  IsGreaterThan        := S1 > S2;
  IsGreaterThanOrEqual := IsGreaterThan or IsEqual;
  IsLessThanOrEqual    := IsLessThan or IsEqual;
end;



Procedure TIIPsystemInterpreter.BYTEC; {byte array compare}
var
  NoMatch : boolean;
  N, b1, b2:  byte;
  Adr1, Adr2: word;
Begin
  N := GetBig;     {DE:=# bytes to  compare}
  SaveIPC;         { probably unnecessary }
//BC := DE;     {BC:=# of bytes}
  Adr2 := Pop();  {HL:=^b}      {addr2}
  Adr1 := POP();  {DE:=^a}      {addr1}
  repeat
    b1      := Bytes[Adr1];
    b2      := Bytes[Adr2];
    NoMatch := b1 <> b2;
    Inc(Adr1);
    Inc(Adr2);
    Dec(N);
  until NoMatch or (N=0);
//if (BC=0) and (nomatch=false) then Zero := 1 {means last compare was equal}
//                              else Zero :=0;

  IsEqual              := (N=0) and (not NoMatch);
  IsGreaterThan        := B1 > B2;
  IsLessThan           := B1 < B2;
  IsGreaterThanOrEqual := IsGreaterThan or IsEqual;
  IsLessThanOrEqual    := IsLessThan or IsEqual;
end;





Procedure TIIPsystemInterpreter.WORDC; {Word array compare, or multiple record comp}
var nomatch : boolean;
Begin       // Nov 28, 2022: dhd- this could be simplified and clarified
  DE := GetBig;       {DE := # words to  compare}
  SaveIPC;
  ex(fDE.w,fHL.w);    {HL := # words to compare}
  HL := HL*2;         {HL := # bytes to compare}
  C  := L;            {Better: BC := HL}
  B  := H;

  HL := Pop();  {HL:=^b}      {addr2}
  DE := POP();  {DE:=^a}      {addr2}
  repeat
    nomatch := Bytes[HL] <> Bytes[DE];
    inc(fHL.w);
    inc(fDE.w);
    dec(fBC.w);
  until nomatch or (BC=0);
//if (BC=0) and (nomatch=false) then Zero:=1 {means last compare was equal}
//                              else Zero :=0;
  IsEqual := (BC = 0) and (not NoMatch);
end;

Procedure TIIPsystemInterpreter.CSETUP;
{find out type of things being compared..dispatch to correct routine}
Begin
  A := Bytes[BC];     {a:= type of stuff to compare}
  inc(fBC.w);
  SaveIPC;
  Case A of
    2 : REALC;
    4 : STRGC;
    6 : BOOLC;
    8 : POWRC;
    10: BYTEC;
    12: WORDC;
    else
      raise Exception.CreateFmt('Unimp compare in CSETUP compare type = %d',[a]);
  end; {case}

end;

Procedure TIIPsystemInterpreter.CEQU;
Begin
  CSETUP;
  Push(IsEqual);
  GetSavedIPC;
end;

Procedure TIIPsystemInterpreter.CNEQ;
Begin
  CSETUP;
  Push(not IsEqual);
  GetSavedIPC;      // dhd: probably unnecessary
end;



Procedure TIIPsystemInterpreter.CGTR;
Begin
  CSETUP;
  Push(IsGreaterThan);
  GetSavedIPC;
end;



Procedure TIIPsystemInterpreter.CLEQ;
Begin
  CSETUP;
  Push(IsLessThanOrEqual);
  GetSavedIPC;
end;




Procedure TIIPsystemInterpreter.CLSS;
Begin
  CSETUP;
  Push(IsLessThan);
  GetSavedIPC;
end;




Procedure TIIPsystemInterpreter.CGEQ;
Begin
  CSETUP;
  Push(IsGreaterThanOrEqual);
  GetSavedIPC;
end;

{**********************************************************************}


{**************** SET ARITHMETIC  *************************************}

{routine to give needed information about sets on the stack
 to INT, DIF, and UNI set operators}

Procedure TIIPsystemInterpreter.Setup( var SIZEA{ah}, SIZEB{bp}: WORD;
                                       var NEWSP: WORD;
                                       var SETA{BP+2}, SETB: WORD);
var
  SizaAAddr: word;
{
                       THE STACK

        BEFORE                          AFTER
        ------                          -----
   |                  |          |                     |
   | rest of stack    |          |   rest of stack     |
   |    set-A         |          |       set-A         |-BP
   | size of set-A    |          | size of set-A       |-NEWSP
   |    set-B         |          |       set-B         |-SP
   | size of set-B    |-SP
    ALSO:
      AH    = SIZEA
      AL    = SIZEB
      NEWSP = New stack pointer
}
Begin
  SIZEB     := Pop();       // BP := SIZEB
  SizaAAddr := SP + (SIZEB shl 1);  // ^SIZEA
  SIZEA     := Bytes[SizaAAddr];   // AH := SIZEA
  NEWSP     := SizaAAddr;          // FUTURE SP
  SETA      := SizaAAddr + 2;      // SKIP OVER SIZEA AND POINT TO SETA
  SETB      := SP;
  IsZero    := SizeB = 0;
end;


// Adjust Set.
// Force the set TOS to occupy UB words, either by expansion
// (adding zeroes "between" TOS and TOS-1) or compression
// (chopping of high words of set), and discard its length word.
// After this operation, if less than 20 words are available to the
// Stack, cause a Stack fault.
Procedure TIIPsystemInterpreter.ADJ;
var
  ByteCnt             : word;
  RequestedSize {al}  : word;    // In words
  ActualSize {di}     : word;    // In words
  OldSrc {si}         : word;
  SizeDif {ax}        : word;
  Dst                 : word;
  CurrentHigh         : word;
  FutureHigh          : word;
begin
  // We assume both sizes >= 0.
  RequestedSize := Bytes[BC];   // 2. GET REQUESTED SET SIZE IN WORDS (AL)
  BC      := BC + 1;

  ActualSize      := POP();        // 4. GET ACTUAL SET SIZE
  if ActualSize < RequestedSize then
    begin  // expand
      SaveIPC;                     // 27.
      OldSrc := SP;                // 28. SOURCE OF OLD SET POINTED TO BE BC

      SizeDif := RequestedSize - ActualSize;  // 30. DI:=DIFFERENCE IN SIZES (IN words)
                                              //     Number of words to zero

      SP      := SP - (SizeDif*2);  // 32. ADD EXTRA SPACE ON TOP OF STACK
      Dst     := SP;          // 33. NOW DI IS DESTINATION FOR SET

      ByteCnt := ActualSize * 2;

      if ActualSize > 0 then          // 36. IF ACTUAL SIZE > 0 THEN THERE IS SOMETHING TO COPY
        begin
          if Integer(ByteCnt) > 0 then
            Move(Bytes[OldSrc], Bytes[Dst], ByteCnt); // 41.
          Dst := Dst + ByteCnt;
        end;

      // NOW ActualSize POINTS TO 1ST WORD TO BE ZEROED

      FillChar(Bytes[Dst], SizeDif * 2, 0);

//    CX      := 0;           // 47. Check Stack for no space

//    AX      := STKSLOP;     // 50.  but slop
      STKCHK;                 // 51.
      if StackOverFlow then
        begin
//        BP := Globals.LowMem.ERECp;            // 52.
//        raise ESTKFAULT.Create('Stack fault in ADJ');   // Stack fault in
          StkOvr;
        end;

      // SUMMARY OF EXPAND ON STACK

      //                 BEFORE                             AFTER
      //                 ------                             -----

      //             |other stuff  |                  |same other stuff|
      //             |on stack     |                  | on stack       |
      //   -         |             |    -             |                |  -
      //   | OLD     |             |    | ZERO FILLED |                |  |
      //   | SET     |             |    |   AREA      |                |  |
      //   |         |             |    -             |                |  |  NEW
      //   -   OLDSP-|             |    -             |                |  |
      //                                | NEW LOC OF  |                |  |  SET
      //                                |  OLD SET    |                |  |
      //                                |             |                |  |
      //                                -       NEWSP-|                |  -
      //
    end else
  if ActualSize > RequestedSize then
    begin  // compress
      SAVEIPC;
      FutureHigh      := RequestedSize SHL 1;    // 9. POINT FutureHigh AT FUTURE HIGH WORD OF SET
      SP              := SP - 2;      // 11.
      FutureHigh      := SP + FutureHigh;        // 12.
      CurrentHigh     := SP + (ActualSize SHL 1);  // 13. POINT CurrentHigh AT CURRENT HIGH WORD OF SET

      //  THE STACK NOW LOOKS LIKE:

      //                       |                       |
      //     -              DI-| current high word     |       -
      //     |NEW              |                       |       |
      //     |                 |                       |       |
      //     |SET              |                       |       |
      //     |              BC-| new high word         |       |THE OLD     -
      //     |LOCATION         |                       |       |            |OLD
      //     |                 |                       |       |SET SIZE    |
      //     |NEW SIZE=CX      |                       |       |            |LOCATION
      //     | (10 for this    |                       |       |  AND       |
      //     -    example)     |                       |       |            |OF NEW
      //                       |                       |       |LOCATION    |
      //                       |                       |       |            |SET
      //                       |                       |       |            |
      //                       | old and new low word  |       -            -
      //                    SP-| set size              |
      //

//    ES      := SS;          // 15. PUT STACK BASE IN ES
//    DS      := SS;          // 18. also in DS
//    STD                     // 19. SO MOVE WILL AUTO DECREMENT
      while RequestedSize > 0 do         // 20. DO THE MOVE
        begin
          WordAt[CurrentHigh] := WordAt[FutureHigh];
          FutureHigh     := FutureHigh - 2;
          CurrentHigh    := CurrentHigh - 2;
          RequestedSize  := RequestedSize - 1;
        end;

      // NOW CurrentHigh POINTS TO THE WORD ABOVE SET
      // (THE FIRST EMPTY WORD ON THE STACK)

      SP  := CurrentHigh + 2;  // 22. NOW CurrentHigh POINTS WHERE SP SHOULD BE

//    GetSavedIPC;             // 25.
    end
end;




// INT: 220 ($DC)
// Set Intersection. Push the intersection of sets TOS and TOS-1.
// (TOS AND TOS-1)
Procedure TIIPsystemInterpreter.INT;
var
  SIZEA, SIZEB, NEWSP, SETA, SETB, CX: word;
//SETABASE, SETBBASE: WORD;

  AH, AL, DI: WORD;
Begin
    //  AND SETB INTO SETA, THEN ZERO-FILL SET A IF SIZEA>SIZEB

    SETUP(SIZEA{ah}, SIZEB{al}, NEWSP, SETA{hl}, SETB);                  // 1. We assume set sizes in range 255>=S>=0.
//  SETABASE := SETA;           // Just to simplify debugging
//  SETBBASE := SETB;
{$R-}
    AL := Min(SIZEA, SIZEB);
    AH := Max(SIZEA, SIZEB);
    if (AH and $80) <> 0 then
      begin
        AL   := AL + AH;        // 5. SIZEA=MIN
        AH   := 0;              // 6. MAX=0
      end;
{$R+}
      if AL <> 0 then           // 7. IF MIN(SIZEA,SIZEB) <> 0 THEN DO THE INTERSECTION LOOP
        begin
          //  INTERSECTION LOOP

          CX      := AL;          // 9. CL:=COUNT, CH ZEROED IN SETUP
          repeat
            DI           := POP();       // 10. GET ELEMENT FROM SETB
            WordAt[SETA] := WordAt[SETA] and DI;  //  AND INTO ELEMENT FROM SETA
            SETA         := SETA + 2;
            CX           := CX - 1;
          until CX = 0;
        end;

    // ZERO FILL

    if SIZEA > SIZEB then             // 14. SIZEA>SIZEB THEN DO ZERO FILL
      begin
        CX   := AH;                   // AH = the larger size
        repeat
          WordAt[SETA] := 0;
          SETA         := SETA + 2;
          CX           := CX - 1;
        until CX = 0;
      end;

   SP := NEWSP;
end;

procedure TIiPsystemInterpreter.DIF;
var
  SIZEA, SIZEB, NEWSP, SETA, SETB, LoopCount: word;
  DI: WORD;
begin
  SETUP(SIZEA{ah}, SIZEB{al}, NEWSP, SETA{hl}, SETB);                  // 1. ASSUME SIZES IN RANGE 0-255.

//if AH < AL then         // 2. SIZEA-SIZEB AND AL:=MIN(SIZEA,SIZEB)
//  AL := AH;           // 4.
  LoopCount := Min(SIZEA, SIZEB);

  if LoopCount <> 0 then     // 6.
    begin
//    CL  := AL;                // 8. DIFFERENCE LOOP
      repeat
        DI     := POP();        // 9. GET ELEMENT OF SETB
        DI     := NOT DI;       // 10. NOT (ELEMENT OF SETB)
        WordAt[SETA] := WordAt[SETA] and DI; // 11. AND WITH ELEMENT OF SETA
        SETA      := SETA + 2;       // 12.
        LoopCount := LoopCount - 1;
      until LoopCount = 0;
    end;
  SP := NEWSP;    // 14.
end;


// Set Union. $DB (219)
// Push the union of sets TOS and TOS-1. (TOS OR TOS-1)
procedure TIIPsystemInterpreter.UNI;
var
  SIZEA, SIZEB, NEWSP, SETA, SETB, LoopCount, AX, AddrA, AddrB: word;
begin
  SETUP(SIZEA{ah}, SIZEB{al}, NEWSP, SETA{hl}, SETB);                  // 1.
  if SIZEA >= SIZEB then        // 2. We assume set sizes in range 255>=S>=0.
    begin                 // 3a. set B was smaller
      // 4. SET A WAS LARGER OR THEY ARE = SO UNION SETB INTO SETA
      if SIZEB <> 0 then
        begin
          // 7. UNION LOOP, B INTO A
          LoopCount := SIZEB;          
          repeat
            AX           := POP();       // 9. GET ELEMENT FROM SETB
            WordAt[SETA] := WordAt[SETA] or AX; // 10. OR INTO ELEMENT FROM SETA
            SETA         := SETA + 2;      // 11. INC SETA PTR
            LoopCount           := LoopCount - 1;        // 12.
          until LoopCount = 0;
        end
      else
{ $2 }   begin                 // 6. SIZEB = 0 SO NO NEED TO UNION
          SP      := NEWSP;   // 13. SP POINTS TO THE NEW SET
//              PJUMP               // 14.
        end;
    end
  else
    begin // SIZEA < SIZEB
      if SIZEA <> 0 then
        begin
          LoopCount := SIZEA;
          repeat
            WordAt[SETB] := WordAt[SETB] or WordAt[SETA]; // 22. OR INTO ELEMENT FROM SET B
            SETB       := SETB + 2;      // 23. BUMP POINTERS
            SETA       := SETA + 2;      // 24.
            LoopCount  := LoopCount - 1;      // 25.
          until LoopCount = 0;
        end;

      AddrB      := NEWSP - 2;     // 29. SI POINTS TO HIGH WORD IN SETB
      AddrA      := SETA - 2;      // 30. DI POINTS TO HIGH WORD IN SETA

      // Replace Set A with Set B
      LoopCount := SIZEB;
      repeat
        WordAt[AddrA] := WordAt[AddrB];
        Dec(AddrA, 2);
        Dec(AddrB, 2);
        Dec(LoopCount);
      until LoopCount = 0;

     // Loop above can be probably optimized to simple MOVE
     // but caution is needed since the move starts at the end and moves
     // towards the front

      SP      := AddrA + 2;      // 42.
      PUSH(SIZEB);            // 44. SIZE OF SET B AND THE NEW SET TOO.
    end;
end;



// ROUTINES USED IN SET COMPARISONS

// COMPARE SETS FOR & return TRUE OR FALSE
// Push the Boolean result of set comparison TOS-1 op TOS.
// Note: adapted from Version IV code. It should be cleaned up and simplified.

Procedure TIIPsystemInterpreter.POWRC;  {set compares}
var
  SIZEA, SIZEB, NEWSP, SETA{BP}, SETB{SP}, LOOPCOUNT: word;
  SETABASE, SETBBASE: WORD;

// ZERCHKB - MAKE SURE REST OF SETB IS 0'S.
// SP=^ PLACE TO START IN SET, SIZEB-SIZEA=# OF WORDS TO CHECK
// RETURN TRUE (ONLY ZEROS LEFT) , OR FALSE (NOT ONLY ZEROS LEFT)

  procedure ZERCHKB(LOOPCOUNT: INTEGER);
  var
    SetBWord: word;
  begin { ZERCHKB }
    if SIZEB <> SIZEA then
      begin
        repeat
          SetBWord := POP();          // GET A WORD FROM SETB
          if SetBWord <> 0 then
            begin
              SP := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
              IsEqual := false;
              Exit;
            end;
          LOOPCOUNT := LOOPCOUNT - 1;
        until LOOPCOUNT = 0;
        SP := NEWSP;            // SP POINTS TO 1ST WORD OF 'REST OF STACK'
        IsEqual := true;        // All trailing words were zero
      end;
  end;  { ZERCHKB }

  // ZERCHKA - MAKE SURE THE REST OF SETA IS ZEROES.
  procedure ZERCHKA(LOOPCOUNT: INTEGER);
  begin
    SP := SETA;          // NOW SP POINTS TO 1ST WORD WE NEED TO CHECK FOR ALL 0'S
    ZERCHKB(LOOPCOUNT);
  end;

  // PROCEDURE PCSETUP
  //       RETURNS:
  //          SIZEA : SetA length in words
  //          SIZEB : SetB length in words
  //          SETA := POINTER TO SETA
  //          SETB := POINTER TO SETB
  //          LOOPCOUNT := MIN(SIZEA,SIZEB)    // FOR LOOP COUNTS
  //          NEWSP := PLACE TO CUT STACK BACK TO
  //          IsZero is set if SIZEB=0
  // Note: this (mostly?) duplicates the code in SETUP and should be shared
  procedure PCSETUP;
  begin
    SETBBASE             := SP;
    SIZEB                := Pop();
    SETABASE             := SP+(SizeB*2);      // point to SetA length in words

    SIZEA                := WordAt[SETABASE];
    SETA                 := SETABASE + 2;            // 8. NOW BP POINTS TO SETA
    NEWSP                := (SizeA * 2) + SETA;  // 13. NOW NEWSP IS CORRECT
    LOOPCOUNT            := Min(SIZEA, SIZEB);
    IsZero               := SIZEB = 0;
    IsEqual              := false;
    IsGreaterThanOrEqual := false;
    IsLessThanOrEqual    := false;
    SETB                 := SP;
  end;

  procedure GEPWR;
  var
    SetAWord, SetBWord: word;
  begin { TIIPsystemInterpreter.GEPWR }
    PCSETUP;
    if (not IsZero) or (LOOPCOUNT <> 0) then
      begin
        repeat
          SetBWord := POP();       // GET WORD FROM SETB
          SetAWord := NOT WordAt[SETA] AND SetBWord;
          if SetAWord <> 0 then
            begin
              SP := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
              IsEqual := false;
              Exit;
            end
          else
            SETA := SETA + 2;           // BUMP POINTER

          LOOPCOUNT := LOOPCOUNT - 1;
        until LOOPCOUNT = 0;
      end;

    if SIZEB <= SIZEA then
      begin
        SP := NEWSP;              // SP POINTS TO 1ST WORD OF 'REST OF STACK'
        IsEqual := true;               // THE RESULT
      end
    else
      ZERCHKB(SIZEA - SIZEB);
  end;  { TIIPsystemInterpreter.GEPWR }

  // LEPWR:
  // COMPARE SETS FOR <= & RETURN TRUE OR FALSE
  // Equal Set. return true if set comparison TOS-1 = TOS.

  // LEPWR   ;SEE IF SETA IS A SUBSET OF SETB,(I.E. SETA-SETB)=NULL-SET
  //         ;SETA<=SETB
  procedure LEPWR;
  var
    temp: word;
    SetBWord: word;
  begin { LEPWR }
    PCSETUP;
    if (not IsZero) or (LOOPCOUNT <> 0) then
      begin
        repeat
          SetBWord      := POP();        // 5. WORD FROM SETB
          temp          := WordAt[SETA] and (NOT SetBWord);
          WordAt[SETA]  := temp;     // 7. "AND" inverse with corresponding A word
          if temp <> 0 then
            begin
              SP := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
              IsEqual := false;           // IsEqual was defaulted to FALSE
              Exit;
            end
          else
            SETA := SETA + 2;
          LOOPCOUNT := LOOPCOUNT - 1;
        until LOOPCOUNT = 0;
      end;
                               // OK SO FAR, NOW SEE IF SET A IS BIGGER & ZERO CHECK IT
    if SIZEA <= SIZEB then
      begin
        SP      := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
        IsEqual := true;
      end
    else
      ZERCHKA(SIZEB-SIZEA);
  end;  { LEPWR }

  procedure EQPWR;

    // PROCEDURE PCSETUP
    //       RETURNS:
    //          ADDRESS OF SETA
    //          ADDRESS OF SETB
    //          CX := MIN(SIZEA,SIZEB)    // FOR LOOP COUNTS
    //          AH := SIZEB-SIZEA
    //          AL := A<=B
    //          NEWSP := PLACE TO CUT STACK BACK TO
    //          IsZero IS SET IF B=0
    // NOTE: This duplicates code in the other ZERCHKB and the two should be integrated.
  begin { TIIPsystemInterpreter.EQPWR }
    PCSETUP;
    if IsZero or (LoopCount = 0) then
      begin  // SO FAR SETS ARE =, MAKE SURE LARGER SET HAS ONLY 0'S AT END.
        if SIZEA > SIZEB then      // SEE IF A<=B
          ZERCHKA(SIZEA-SIZEB)     // SETA IS LARGER
        else
          ZERCHKB(SIZEB-SIZEA);    // SETB IS LARGER
      end
    else
      begin
        repeat
          if WordAt[SETA] <> POP() {from set B} then
            begin
              SP := NEWSP;
              IsEqual := false;
              EXIT;
            end;
          SETA      := SETA + 2;
          LoopCount := LoopCount - 1;
        until LoopCount = 0;

        // Everything equal
        SP      := NEWSP;            // SP POINTS TO 1ST WORD OF 'REST OF STACK'
        IsEqual := true;
      end;
  end;  { TIIPsystemInterpreter.EQPWR }

Begin { TIIPsystemInterpreter.POWRC }
      {find out what relop to do..}
  A  := Bytes[BC-2];       {A := p-machine op that got us here}
  A  := (a+a) and $FF;     {probably a simpler way in pascal & target native code}
  A  := A-$5E;
  {here a=0 if pceql}
  Case A of
    0: {=}
       begin
         EQPWR;
       end;

    2: {>=}
        begin
          GEPWR;
          IsGreaterThanOrEqual := IsEqual;
        end;
    10: {<=}
        begin
          LEPWR;
          IsLessThanOrEqual := IsEqual;
        end;
    16: {<>}
        begin
          EQPWR;
        end;
    else
      raise Exception.Create('Illegal argument in POWRC');
  end; {case a}
end;  { TIIPsystemInterpreter.POWRC }


Procedure TIIPsystemInterpreter.SRS;
{build a subrange set, the set [i..j]}
label 90,99;
var
//  IDIV : byte ABSOLUTE BYTE1;
//  JDIV : byte ABSOLUTE BYTE1;
    i,j,t:integer;
    xx:word;

Begin
  SaveIPC;
  {are i,j valid?}
  DE := POP();     {DE:=j}
  BC := POP();     {BC:=i}
//if BC<0 then goto 99;   {sets = 0..4079 elements..eat ya heart out turbo}
  if DE>=4080 then goto 99;
  if DE<BC then goto 90;  {push a null set}
  i:=BC;
  j:=DE;
  xx:=Bitter[j mod 16]; t:=j div 16;
  While t> i div 16 do
    begin push(xx); xx:= $FFFF; dec(t); end;
  xx:= xx and unbitter[i mod 16]; t:= i div 16;
  While t>= 0 do
    begin push(xx); xx:=$0000; dec(t); end;
  push((j div 16) +1);    {set size}
  GetSavedIPC;
  exit;
90:
  push(00);   {push null set}
  GetSavedIPC;
  exit;
99:
  push(00);
  Writeln('INVALID SET INDEX from P-code SRS');
  {see Eli Willner's book pg 344}
  invndx;
  GetSavedIPC;
end;


Procedure TIIPsystemInterpreter.SGS;  {build singleton set, the set [i]}
{ SGS is generated by the following construct:
              if c in [chr(8),'0'..'9'] then;  }
Begin
  DE := POP();  {Get the bit number}
  push(DE);
  push(DE);
  SRS;     {just call srs}
end;

Procedure TIIPsystemInterpreter.INN;
VAR
  I: INTEGER;
  Result: boolean;
  DI, BP, AX, CX: word;
Begin
  Result  := false;
  DI      := POP();       //  1. DI:=SET SIZE IN # OF WORDS
  BP      := DI;          //  2. DI:=SET SIZE
  BP      := BP SHL 1;    //  3. # OF BYTES TO SKIP
  BP      := BP + SP;     //  4. BP := POINTS TO I & WILL BE PLACE SP POINTS
                          //           WHEN WE LEAVE THIS PROCEDURE
{$r-}
  I       := WordAt[BP];  // 5. AX:=I
  AX      := I;
{$r+}
  if I >= 0 then           // 7. NEG SET INDEXES NOT ALLOWED
    begin
      AX      := AX SHR 4;           // 9. AX:=I DIV 16, THE WORD INDEX OF I
                                     //    STARTING AT 0
      if AX < DI then                // 11. IF INDEX IS NOT TOO HIGH FOR SET-A
        begin
          AX  := AX SHL 1;       // 12. byte index
          SP  := SP + AX;        // 13. SP POINTS TO WORD BIT # I SHOULD BE IN
          AX  := POP();          // 14. AX := WORD I'S BIT IS IN
          DI  := WordAt[BP];     // 15. DI:=I
          DI  := DI AND $F;      // 16. ONLY NEED LOWER 4 BITS OF I, 0..15

          CX  := BITTER[DI];     // 18. CX:=(BITTER+DI)
{$R-}
          CX  := CX xor BITTER[DI-1]; // 19. CX:=CX AND (BITTER-1+DI)
                                      // SO ONLY BIT I IS ON IN CX
{$R+}
          AX  := AX AND CX;      // 20. SEE if BIT I IS ACTUALLY ON IN AX
          if AX <> 0 then        // 21.
            result := TRUE;
        end
    end;

  BP := BP + 2;            //  25. NOW BP IS WHERE SP SHOULD POINT
  SP := BP;                //  26.
  PUSH(result);            //  27. PUSH RESULT
end;

// NAME:     CBPXNL
// ENTRY:    HL?
//           BC = new IPC
Procedure TIIPsystemInterpreter.CBPXNL;
Begin
  HL := Globals.LowMem.Syscom.STKBASE;   {save old base pointer}
  PUSH(HL);             {starting to crete a new stack frame?}
  PUSH(BC);             {save new ipc}
    EX(fDE.w,fHL.w);    {then make this MSCW the new base}
    GlobVar := LocalVar;
    Globals.LowMem.Syscom.STKBASE := Globals.LowMem.Syscom.LASTMP;
    HL := Globals.LowMem.Syscom.LASTMP;
    EX(fDE.w, fHL.w);    {use the old base's stat link....}
      BC := WordAt[HL];
      inc(fHL.w);
    EX(fDE.w, fHL.w);    {...as our own stat link}
    WordAt[HL] := BC;
  BC := POP();      {recover ipc}
end;

Procedure TIIPsystemInterpreter.CIPXNL;
Label 10;
Begin
  PUSH(BC);  {save BC (IPC) for a while}
  BC := Globals.LowMem.Syscom.LASTMP;  {BC := ^new MSCW}
  A  := Bytes[JTAB+1];      // A := Lex lev of called proc}
{$R-}
  A  := A - 1;
{$R+}
  if (A and $80) <> 0 then  // if lex level <= 0, base procedure
    Begin
      BC := POP();   {get back ipc}
      CBPXNL;
    end
  else
    Begin
    {find first proc with lex level one less than ours}
    {see if this is the MSCW that has the goods we need}
      repeat
        HL := MSJTAB+1 + BC;
        DEC(fHL.w);

        DE := WordAt[HL];  // verify this

        DEC(fHL.w);
        DEC(fHL.w);

        BC := WordAt[HL];

        EX(fDE.w,fHL.w);      {get LexL from jtab}
        inc(fHL.w);
      until (A {- 1}) = Bytes[HL];
      DE := POP();      {get IPC (from PUSH(BC) above)}

      HL := Pop();      {junk old stat link}

      PUSH(BC);        {new msstat is the found mscw};
      BC  := DE;       {restore IPC}
//    ENTERING('CIPXNL');
    end;
end;


(*
procedure TIIPsystemInterpreter.EnterExit(const DoingWhat, FromWhere: string; d: integer = 0);
var
  Msg, CodeStr: string;
begin
  if d >= 0 then
    CodeStr := Format('%02d', [d])
  else
    CodeStr := '  ';

  Msg := Format('%-7s%2s %-9s %20s: SP = %4.4x, SegNum = %2d, SegBot = %5d, SegTop = %5d',
                [FromWhere, CodeStr, DoingWhat, Padr(ProcName(CurProc, Segp), 20), SP,   SegNum, SegBot, NewSegTop]);
                 {CSP       00       INITIALI.INITHEAP                  BB32  0       53664   64612 }
  OutputDebugString(pchar(Msg));
end;
*)

Procedure TIIPsystemInterpreter.CIP;
{call intermediate procedure}
Begin
  BLDMSCW;   {then try to point stat link at parent}
  CIPXNL;
//ENTERING('CIP');
end;

Procedure TIIPsystemInterpreter.CXP;
{call external (different segment) procedure}
{find or read in desired seg then CIP it}
var
{$IfDef debugging}
  UnitNr: INTEGER;
  BlockNr: integer;
  FileName: string;
{$EndIf debugging}
  SegWasReadIn: boolean;
Begin { CXP }
  A      := Bytes[BC];    {A := Seg NUM}
  INC(fBC.w);

  SegNum := A;
  If SegNum = Bytes[SEGP] then
    CIP {in same seg so CIP it}
  else {not same seg}
    Begin
{$IfDef debugging}
      If SegNum = 0 then
        begin
          UnitNr := Globals.LowMem.SysCom.SegTbl[SegNum].CODEUNIT;
          OverrideSysCall(UnitNr, BlockNr, FileName);   {SegNum=0 ==> ...a System call - effectively preprocess it to get some needed debug information}
        end;
{$endIf}
      SaveIPC;
      NewSegTop := GETSEG(SegNum, SegWasReadIn);       {SegNum=seg #, get seg into memory} {NewSegTop=^segtop, SegWasReadIn set if read in}
      PUSH(SegWasReadIn);     {push SegWasReadIn=1} {later popped in bld3}
      Assert(BC = IPCSAV, 'System error. BC got changed');
//    GetSavedIPC;     {get ipc, do not touch DE}
      BLD3;            {build a MSCW}
      CIPXNL;          {then set up stat link}
//    ENTERING('CXP+');
    end; {else}
end;   { CXP }


Procedure TIIPsystemInterpreter.LCA; {166: load constant string address- LB version ONLY}
Begin
  PUSH(BC);      {address of string}   {addr2}
  A := Bytes[BC]; {get length}
  INC(fBC.w);
  BC := BC+A;    {skip over chars}
end;



Procedure TIIPsystemInterpreter.IXS;   {index string pointer}
{given index, ^string, compute ^string[index]}
var
  Idx: integer;
Begin
  Idx := POP();      {index}
  HL := Pop();      {^string}   {addr2}

  {change the 1 to 0 for complete turbo pascal compatibility}
  If (Idx >= 0) and (Idx <= 255) then {1<=index<=255}
    if (Idx <= Bytes[HL]) then {index<=string length}
      begin
        HL := HL + Idx;    {perform indexing}
        PUSH(HL);             {addr2}
//{add a little message for index 0 eg FILLER[0] := CHR(anything) }
//      if DE=0 then
//       { comment out next line to allow it with $R+ }
//       { Message('INTERP: Assignment to string[0] allowed')};
        exit;
      end;
  {if here then invalid index}
  INC(fHL.w);
  PUSH(HL);  {leave ^string1 on tos} {addr2}
  SaveIPC;
//Writeln;
  fErrCode := INVNDXC;
//raise EXEQERR.Create('INVALID STRING INDEX from p-code IXS Index=%d, String Len=',[DE, Bytes[HL-1]], INVNDXC);
  raise EXEQERR.CreateFmt('INVALID STRING INDEX from p-code IXS Index=%d, String Len=',[DE, Bytes[HL-1]]);
end;

{$IfDef debugging}
(*
Procedure TIIPsystemInterpreter.ShowSegInfo;
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
          With Globals.LowMem.Syscom.SEGTBL[i] do
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

Procedure TIIPsystemInterpreter.ShowProcDict(a:word; ToWindow: boolean);
const
  OUTLFN = 'c:\temp\ProcDict.text';
var i:integer;
    loc:word;
    hex : string;
    OutFile: TextFile;
    Line: string;
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
{$EndIf}



{***************** JUMPS ********************}




Procedure TIIPsystemInterpreter.UJP; {Unconditional jump}
var offset : integer;
Begin
  A := Bytes[BC];
  INC(fBC.w);
  If A < 128 then  {if small then short relative jump}
    Begin
      BC := BC+A;
      exit;
    end;
//HL     := JTAB;
  offset := 256 - A;   {should be negative} {convert  to positive number}
  HL     := JTAB - offset;   {offset is neg- point to word in jump table}
  DE     := WordAt[HL];
  BC     := HL - DE;       {selrel}
{  Writeln('UJP not fully tested for long jump'); halt;}
end;



Procedure TIIPsystemInterpreter.FJP;
Begin
  HL := Pop();
  HL := HL and $0001;    {ignore all bits except 0, LNOT/BNOT fix}
  If HL = $0000 {FALSE} then
    UJP
  else
    INC(fBC.w);
end;


Procedure TIIPsystemInterpreter.XJP;    {case jump}
{ index is (SP).  In the code starting on a word boundary are 3 words...
                  MIN index for table
                  MAX index
                  else jump (point ipc here if index out of table range)
                  .... and the case table jump addresses
}
var
//lbc,lde,lhl : integer;   {for signed arith to work}
  MinIndex, MaxIndex, Index, lhl: integer;
  Base: word;
Begin
  INC(fBC.w);
  Base := BC and $FFFE;    {put Base on word boundary}
{$R-}
  MinIndex := WordAt[Base];  {MinIndex(BC) = MIN }
  MaxIndex := WordAt[Base+2]; {MaxIndex(DE) = MAX}

{stop RTE on some case statements LB 25/12/96}
  Index    := Pop();        {get index}
{$R+}

  if (Index >= MinIndex) and (Index <= MaxIndex) then
    begin
      lhl      := Index - MinIndex + 3;     {word OFFSET from Base}
      HL       := lhl + lhl;  {HL+HL;}      {byte offset from Base}
      HL       := Base + HL;                {address of case statement address}

      BC       := HL - WordAt[HL];          {entry is negative self relative again}
    end {
  else
    BC := BC + 4};   // otherwise fall into the "Jump over" instruction
end;

























{*************** PROCEDURE CALLING AND RETURNING *************}

Procedure TIIPsystemInterpreter.RBP;   {return from base procedure}
Begin
//EXITING('RBP');                      {RNP below will get it}
  HL := Globals.LowMem.Syscom.LASTMP;      {HL:=old base}
  HL := HL - 2;
  DE := WordAt[HL];
  EX(fDE.w, fHL.w);
  Globals.LowMem.Syscom.STKBASE := HL;    {restore previous base environment}
  HL := HL + DISP0;

  GlobVar := HL;
  RNP;   {now fall into RNP}
end;

Procedure TIIPsystemInterpreter.RNP;   {return from normal procedure}
{note: RNP x where x is # of words to return NOT size of stack to cut back.
 The stack is corrected by assigning the old SP to SP.  Note also that
 all functions allow space on stack for 2 words!!    LB oct 1991}
var
  BytesToReturn: word;
  MSCWp: TMSCWPtr2;
Begin
  HL := LocalVar;
  DE := WordAt[HL];  {DE := old sp}
  A  := Bytes[BC];   {A:=number of WORDS to return}

  if A > 127 then
    raise Exception.CreateFmt('Invalid RNP, A=%d',[a]); {readln};

  BytesToReturn  := A*2     ;   {double A for bytes}{Allow for the possibility of returning structured types?}
  If BytesToReturn > 0 then
    Begin
      HL := LocalVar + BytesToReturn + 1; { Just above the parameters }
      DEC(fDE.w);       {do the move}
      Repeat            {LDDR}
        Bytes[DE] := Bytes[HL];
        DEC(fDE.w);
        DEC(fHL.w);
        DEC(BytesToReturn);
      Until BytesToReturn = 0;
      INC(fDE.w);        {either way to $20, DE = NEW SP}
    end;

  { $20 use info in MSCW to restore machine state}
  MSCWp    := TMSCWPtr2(@Bytes[Globals.LowMem.Syscom.LASTMP]);
  with MSCWp^ do
    begin
      Globals.LowMem.Syscom.LASTMP   := DYNLINK;      {new local MSCW := dyn link}
      LocalVar := Globals.LowMem.Syscom.LASTMP+DISP0;
//    HL   := MSSEG;                                  { byte past end of segment }
      BC   := MSIPC;
      JTAB := MSJTAB;
      if MSSEG <> SEGP then
        Begin {it is different, dec refcount for current seg}
          A  := Bytes[SEGP];
          DECREF(A, SEGP);  {dec ref count for seg A}
        end;
      SEGP := MSSEG;        {set new pointer to byte past end of segment}
    end;
  ProcBase := GetEnterIC(JTAB);
  SP       := DE;
end;




// Name     : DECREF
// Purpose  : decrement the segment reference count
// Returns  : true, if RefCount goes to 0
function TIIPsystemInterpreter.DECREF(SegIdx: word; SegTop: word): boolean;
var
  SegInfoRecP: TSegInfoRecP;
  FileName: string;
{$IfDef DumpDebugInfo}
  Msg: string;
{$EndIf}
Begin
  result := false;
  SegInfoRecFromSegTop(SegTop, SegInfoRecP, FileName);

  if Assigned(SegInfoRecP) then
    with SegInfoRecP^ do
      begin
        Dec(TheRefCount);
        result := TheRefCount = 0;
        if result then   // no one cares anymore
          begin
            NoteSegTopChange('DECREF ', TheSEGNAME, TheSEGTOP, 0, true);
//          TheSEGTOP := 0;
          end
      end
{$IfDef DumpDebugInfo}
  else
    begin
      Msg := Format('Unknown SegTop = %d', [SegTop]); // should this be an exception?;
      DumpDebugInfo(Msg);
    end;
{$EndIf}
end;


// Name:    BLD3
// Purpose: Prepare to call procedure
// Entry:   NewSegTop
//          BC = Current AbsIPC
// Uses:    HL, DE
Procedure TIIPsystemInterpreter.BLD3;
{on entry BC points to byte after opcode}
const
  DATASZ = 8;   {these are offsets only}
  PARMSZ = 6;
Var
//LocalDataSize : word;     {22/9/95}
  LOC: word;
  PARAMSIZE: word;                 { leave the p-Machine register alone }
  EnterIC: word;
Begin
  A        := Bytes[BC];    { A := proc num;}
  inc(fBC.w);

  SaveIPC;

  {there may be a bug here as NewSegTop may ^byte past end of proc dict...
  however if NewSegTop:=segp then did segp ^byte past end of proc dict??}

  LOC      := NewSegTop;
    {now get JTAB}
  LOC      := LOC - 2*A;

  HL       := LOC - WordAt[LOC];  // HL := ^JTAB;
  NEWJTB   := HL;

  A := Bytes[NEWJTB]; {get proc#, if 0 then assembly}
  If A=0 then
    begin
      // Let's pretend that this is a call to DECOPS and see how far we can get...
      DECOPS;
      Exit;
    end;

  {regular procedure..now get DATASZ+PARMSZ}
  HL     := HL - DATASZ;    {HL = Addr of Data Size field}

  DE     := WordAt[HL];     {DE := Local DataSize}

  HL     := HL + 2;
  ParamSize     := WordAt[HL];     {ParamSize := Passed PARAMSIZE}

  CodeWasReadIn := boolean(Pop());

  if not CodeWasReadIn then
    Begin {code not read in so extend by datasize}
      HL    := SP - DE;    {HL := sp-DATASZ}
      SP    := HL;         {SP := SP-DATASZ}
      ex(fDE.w, fHL.w);    {DE := HL;}
      HL    := HL + DE;    {fHL.w := ^PARMS}
    end
  else { $50}
    Begin {code was read in so extend by PARMSZ+DATASZ}
      ex(fDE.w,fHL.w);
      HL    := HL + ParamSize;      {HL := DATASIZE+PARAMSIZE;}
      HL    := SP - HL;
      SP    := HL;           {SP := SP-DATASZ-PARAMSZ}
      ex(fDE.w,fHL.w);       {DE := ^param dest}
      HL    := NewSegTop;    {hl := ^params}
      INC(fHL.w, 2);
    end;

  Move(Bytes[HL], Bytes[DE], ParamSize);   // Move parameters to new location on top of stack
  HL := HL + ParamSize;

  {now build MSCW as if this were a CLP}
  PUSH(HL);                            {mssp}
  PUSH(IPCSAV);                        {msipc}
  PUSH(SEGP);                          {msseg- i.e. segment END+2}
  PUSH(JTAB);                          {msjtab}
  PUSH(Globals.LowMem.Syscom.LASTMP);  {msdyn}
  PUSH(Globals.LowMem.Syscom.LASTMP);  {msstat}

  StkChk;
  If StackOverFlow then
    StkOvr;

  {set up environment for called proc}

  Globals.LowMem.Syscom.LASTMP := SP;     {LB 1995 is this like push bp ; mov bp,sp ...probably}
  LocalVar := SP + DISP0;
  SEGP     := NewSegTop;
  JTAB     := NEWJTB;

  HL       := JTAB - 2;      // HL = ^EnterIC
  EnterIC  := WordAt[HL];    // Get ENTERIC.

  BC       := HL - EnterIC;  // BC points to the next p instruction
  ProcBase := BC;            // Save base address of procedure
end;



Procedure TIIPsystemInterpreter.BLDMSCW;
{Build a MSCW, copy down parameters and set proper envir. for called proc}
Begin
  NewSegTop := SEGP;
  A:=0;
  CodeWasReadIn := false;
  push(A);  {bug fix LB 30/4/91; DHD says: what the hell is this?}
  BLD3;
end;


Procedure TIIPsystemInterpreter.CLP;
Begin
  BLDMSCW;    {does it all for CLP}
//ENTERING('CLP');
end;

Procedure TIIPsystemInterpreter.CGP;  {call global proc}
Begin
  BLDMSCW;
  HL := Pop();     {junk stat pointer BLDMSCW gave us}
  HL := Globals.LowMem.Syscom.STKBASE;
  PUSH(HL);    {...and make stat point to BASE}
end;

Procedure TIIPsystemInterpreter.CBP;  {call base procedure}
Begin
  BLDMSCW;      {and the make this a BASE MSCW}
  CBPXNL;
end;


//      Name:    ReadSeg
//      Entry:   SegNum = Segment number to be loaded
//               FileName = file that we are reading from
//      changes: NewSegTop = points to byte after last byte of seg just read in
//               SegBot = points to start of segment just read in
//      returns: NewSegTop
//               name of file containing the segment
//      Assumes:  (1) Globals.LowMem.Syscom.SEGTBL[SEGNUM] has the information needed
//                (2) Has just been loaded with the segment dictionary information for the code file
//      Side Effects: sets the global IOResult flag
//      Note:    DO NOT USE BC
procedure TIIPsystemInterpreter.ReadSeg(var FileName: string; var NewSegTop: word);  {read segment from disk, setting NewSegTop, segbot
                                           use segnum as index into segment directory}
var  Seglen : word;
     SegName: TString8;
     SegIdx: integer;
     SegInfoRecP: TSegInfoRecP;
{$IfDef DumpDebugInfo}
     Msg: string;
{$EndIf}
Begin { ReadSeg }
  SegLen := Globals.LowMem.Syscom.SEGTBL[SEGNUM].Codeleng; {get length of segment}
  if SegLen = 0 then
    with frmPSysWindow do
      Begin
        Writeln(['ERROR READING SEGMENT NUMBER',SEGNUM,'.  Possibly an unlinked segment']);
        Writeln('...Readseg tried to load segment of length 0 or seg non-existent');
        if SEGNUM > 1 then
          begin
            Move(SD.DICT.SegNamesII[SEGNUM], SegName, IDLEN);
            Writeln([SegName,' needs to be linked to this code file']);
            Writeln('THIS IS PROBABLY A UNIT THAT NEEDS TO BE LINKED INTO THIS FILE');
            raise Exception.Create('Invalid segment length');
          end;
    end
  else
    begin
{$R-}
      SegName[0] := CHR(IDLEN);
      Move(SD.DICT.SegNamesII[SEGNUM], SegName[1], IDLEN);
{$R+}

      {NewSegTop will point to last word of seg to be read in}
      NewSegTop := SP-2;

      SP     := SP - SegLen; {extend stack}
      SEGBOT := SP;          {starting address of the segment}

      with Globals.LowMem.Syscom do
        begin
          IOError(INOERROR);  // Assume that the SYSRD will work
          SYSRD( SEGTBL[SEGNUM].CODEUNIT,
                 SEGBOT, SegLen,
                 SEGTBL[SEGNUM].DISKADDR);

          if IORSLT <> INOERROR then
            begin
//            raise EXEQERR.Create('SYSRD error', [], SYIOERC);
              fErrCode :=  SYIOERC;
              raise EXEQERR.CreateFmt('SYSRD error IORESULT = %d', [ord(IORSLT)]);
            end;
{$IfDef DumpDebugInfo}
          Msg := Format('READSEG: SegNum = %2d, SegBot = %5d, NewSegTop = %5d, DISKADDR = %5d, CODELENG = %5d',
                        [SegNum, SegBot, NewSegTop, SEGTBL[SEGNUM].DISKADDR, SegLen]);
          Writeln(fLogfile, Msg);
{$EndIf DumpDebugInfo}
//        UpdateSegInfo(SegNum, NewSegTop, SegBot, SegLen, SEGTBL[SegNum].CODEUNIT, SEGTBL[SEGNUM].DISKADDR);
(* BEGIN replace with call to UpdateSegInfo *)
          If SEGNUM <> Bytes[NewSegTop] then    // segment number is stored in the last word of the segment (I think)
            with frmPSysWindow do
              raise ENOPROC.Create('ERROR...Readseg no proc');

          SegInfoRecP := UpdateSegStuff( SEGNUM,  { Use SegTbl[SEGNUM] }
                                      SegIdx,
                                      FileName,
                                      SegName,
                                      NewSegTop,
                                      SEGTBL[SEGNUM].CODEUNIT, // WARNING: passing CODEUNIT has not been tested
                                      SEGTBL[SEGNUM].DISKADDR,
                                      SegLen);
{$IfDef DumpDebugInfo}
          Msg := Format('         SegNum = %2d, SegBot = %5d, NewSegTop = %5d, DiskAddr = %5d, SegName = %8s, FileName = %s',
                        [         SegNum,       SEGBOT,      NewSegTop,    SEGTBL[SEGNUM].DISKADDR,
                                                                                               SegName,       FileName]);
          Writeln(fLogFile, Msg);
{$EndIf DumpDebugInfo}

          if not Assigned(SegInfoRecP) then
            SegInfoRecP := FindSegInfoRec( SEGTBL[SEGNUM].CODEUNIT,  // must assume that we have already loaded info about the code file.
                                           SEGTBL[SEGNUM].DISKADDR);
          if Assigned(SegInfoRecp) then
            with SegInfoRecp^ do
              begin
{$IfDef SegInfoRec}
                NoteSegTopChange('READSEG', TheSEGNAME, TheSEGTOP, SEGBOT + SegLen - 2);
{$endIf}
                TheSEGTOP   := SEGBOT + SegLen - 2;  // point to last word of segment
                TheRefCount := 1;
              end
          else
            begin
{$IfDef SegInfoRec}
//            with Globals.Lowmem.SysCom.SEGTBL[SegNum] do
//              Msg := Format('Did not find info for SegNum = %2d, @ NewSegTop = %5d, DISKADDR = %5d, CODELENG = %5d, SP = %4.4x',
//                             [SegNum, NewSegTop, DiskAddr, CODELENG, SP]);
//            DumpDebugInfo(Msg);
{$EndIf}
            end;
(* END replace with call to UpdateSegInfo *)
        end;
    end;
end;  { ReadSeg }

(*
function TIIPsystemInterpreter.GetSegInfoRecPFromSegTbl(SegNum: word): TSegInfoRecP;
begin
  with Globals.LowMem.Syscom.SEGTBL[SegNum] do
    result := GetSegInfoRec(SegNum, DiskAddr, CodeUnit)
end;
*)

// Function: GETSEG
// Purpose:  Callable routine to insure a segment is in memory
// Entry:    A = SegNum
// Return:   ^high word of seg
//           SegWasReadIn set if code read in
// Comment: Look in internal table to get refcount for seg
//          if refcount > 0, seg in memory, and so inc refcount
//          otherwise open space on stack, read in seg,
//          relocate any assembly stuff (proc#=0),
//          make the refcount = 1, fill in the entry telling where the seg is}
// Note:    DO NOT USE BC

function TIIPsystemInterpreter.GETSEG( SegNum: word;
                                       var SegWasReadIn: boolean): word;
var
  SegInfoRecP: TSegInfoRecP;
  FileName: string;
Begin
  SegWasReadIn := false;
  SegInfoRecP := GetSegInfoRecPFromSegTbl(SegNum);
  if Assigned(SegInfoRecP) and (SegInfoRecP.TheREFCOUNT > 0) then   // segment is in core
    with SegInfoRecP^ do
      begin
        Inc(TheRefCount);
        result := TheSEGTOP;
      end
  else
    Begin
      READSEG(FileName, NewSegTop);

      {RELOCATION code call should go here}
      {build a data segment below code just loaded}
      {point at proc 1}

      SegWasReadIn := true;

      {to do:
       open space on stack for code+data
       fill in entry telling where seg is }
      result := NewSegTop;
    end;
end;

Procedure TIIPsystemInterpreter.UCSDExit;
{exit a specified procedure. Make IPC of current proc point to exit code
 if current proc is the one to exit then jump GetSavedIPC
 otherwise....
 calculate parent of (BASE), ie MSCW of PROGRAM pascalsystem,
 BC := (MP)
 Repeat
   if BC=system MSCW then die for exiting proc not called
   change IPC of this MSCW to point to exit code for proc
   done := proc and seg of this MSCW match passed params
   BC:=MSDYN(BC)
 until done
}
Label 10,20,40;
Var PROCNUM,SYSMSCW : WORD;
Begin
  PROCNUM     := Pop();                   {param proc num}
  SEGNUM      := Pop();                   {param seg num}

  {fix IPC of current proc}
  HL      := JTAB-4{exitic};              {HL := ^exitic}
  DE      := WordAt[HL];                  {DE := exitic(unmodified)}

  HL      := HL-DE;                       {negative self-relative}
  IPCSAV  := HL;
  ProcBaseSave := GetEnterIC(JTAB);

  If Bytes[JTAB] <> procnum then
    goto 10;
    
  If Bytes[SEGP] = SEGNUM then
    Begin
      GetSavedIPC; exit;       {this is the exit for current proc/seg #}
    end;

10: {here if proc# or seg# are not the same as params passed}
  HL      := Globals.LowMem.Syscom.STKBASE;      {SYSMSCW := ^PASCALSYSTEM MSCW}
  DE      := WordAt[HL];
  SYSMSCW := DE{HL};
  BC      := Globals.LowMem.Syscom.LASTMP;

20:
  {?you could also die if BC=base...another way of detecting bad exit LB}
  If SYSMSCW = BC then     {about to exit pascalsystem ?}
    raise ENOEXIT.Create('die for exiting procedure not called...');
{30:}
  {nope it's cool. change this MSCW's IPC}
//HL := MSJTAB;     {DE := ^procnum}

  HL := MSJTAB+BC;
  DE := WordAt[HL];
  PUSH(DE);       {save for later}
  HL := DE-4;     {DE := Exitic (unmodified)}

  DE := WordAt[HL];

  DE := HL-DE;

  HL := MSIPC+BC;                    {HL := ^MSIPC}

  WordAt[HL] := DE;
  DEC(fHL.w);                         {fHL.w:=^MSSEG}
  DEC(fHL.w);
  EX(fDE.w,fHL.w);
  {done yet ?}
  HL := Pop();        {HL := ^procnum}
  {extra debugging code as there is no OS sysmscw added at interp 7}
  If Bytes[HL] < 1 then
    Begin
    Writeln('die for exiting procedure not called'); SYSHALT
    end;
  If Bytes[HL] <> PROCNUM then
    goto 40;
  EX(fDE.w,fHL.w);      {HL:=^MSSEG}
//DE := Bytes[HL] + Bytes[HL+1]*256;
  DE := WordAt[HL];
  INC(fHL.w);
  EX(fDE.w,fHL.w);
  If Bytes[HL] = SEGNUM then  {YEA this is the exit}
    Begin
    GetSavedIPC; exit;
    end;
40:
  {go up dynamic link}
  HL := BC;
  INC(fHL.w);
  INC(fHL.w);
  BC  := WordAt[HL];
  INC(fHL.w);
  goto 20;
end;

// Function Name: LoadSEGDICT
// Function purpose: Loads the segment dictionary which starts at block BlockNr into SD.DICT
//                   and then loads the Globals.LowMem.Syscom.SEGTBL
procedure TIIPsystemInterpreter.LoadSEGDICT(BlockNr: integer; const FileName: string);    {read blk 0, update SEGTBL for seg=0..15}
var
  LSEG,i: INTEGER;
  MaxBlock: integer;
begin { LoadSEGDICT }
  with fVolumesList[BootUnit].TheVolume do
    begin
      if UCSDBlockReadRel(SD.BUF, 1, BlockNr) <> 1 then
        raise Exception.Create('ERROR IN READING SEGMENT DICTIONARY');
      MaxBlock :=DeovBlk;
    end;

  with SD.DICT do
    begin
      if flip then
        for i := 0 to MAXSEG do
          with Diskinfo[i] do
            begin
              codeaddr := FlipSex(codeaddr);
              codeleng := FlipSex(codeleng);
            end;
    end;

  {copy unit#, code length and relative address (warning ucsd=absolute disk address) into syscom}

   For LSEG := 0 to MAXSEG do
     With Globals.LowMem.Syscom.SEGTBL[LSEG] do
       Begin
         CodeUnit := fBootUnit;
         CODELENG := SD.DICT.DISKINFO[LSEG].codeleng;    // in words
         DISKADDR := SD.DICT.DISKINFO[LSEG].CODEADDR + BlockNr {CODEFIBP^.FHEADER.DFIRSTBLK}; {FIX LATER}
       end;

   SaveSegInfoForFile( BootUnit, BlockNr, SizeOf(SD.BUF), FileName, SD.DICT, MaxBlock)
end;  { LoadSEGDICT }




Procedure TIIPsystemInterpreter.GetSavedIPC;
Begin
  BC := IPCSAV;
{$IfDef debugging}
  ProcBase := ProcBaseSave;
{$EndIf}
end;

procedure TIIPsystemInterpreter.SLDC;
begin
  PUSH(fOpCode) {SLDI0..SLDI127}
end;

function TIIPsystemInterpreter.FinalException(const Msg, TheClassName: string): TBrk;
var
  FullMsg: string;
begin
{$If Defined(Debugging) or Defined(LogRuns)}
  FullMsg := Format('%s (%s): Segment:%d, ProcNum:%d, RelIPC:%d',
                [Msg, TheClassName, SegNum, CurProc, RelIPC]);
{$IfEnd}
{$IfDef Debugging}
  if Assigned(frmPCodeDebugger) then
    frmPCodeDebugger.fExceptionMessage := FullMsg
  else
    Alert(FullMsg);
{$else}
  Alert(FullMsg);
{$EndIf}
{$IfDef LogRuns}
  with fFiler as TfrmFiler do
    SetLastError(FullMsg);
{$endIf}
  result := dbException;
end;


{$IfNDef debugging}
function TIIPsystemInterpreter.Fetch: TBrk;
Begin { TIIPsystemInterpreter.Fetch }
  result  := dbUnknown;
  fOpCode := Bytes[BC];
  try
    INC(fBC.w);

    Op    := fOpCode;

    with Opstable.Ops[fOpCode] do
      if Assigned(ProcCall) then
        ProcCall
      else
        raise ENOTIMPLEMENTED.CreateFmt('Unimplemented opcode %d', [fOpCode]);

    Inc(DbgCnt);
  except
    on e:EXEQERR do
      pXEQERR(fErrCode, e.Message);
    on e:ENOPROC do
      pXEQERR(NOPROCC, e.Message);
    on e:ENOEXIT do
      pXEQERR(NOEXITC, e.Message);
    on e:ESTKFAULT do
       pXEQERR(STKFLTC, e.Message);
    on e:ESYSTEMHALT do
      begin
//      raise ESYSTEMHALT.Create('System HALT');                   // Re-raise to break out of the FETCH loop
        HaltPSys(e.Message);
      end;

    // if it is an unknown exception, it needs to be rethought
    on e:Exception do
      result := FinalException(e.Message, e.ClassName);
  end;
end; { Fetch }
{$EndIf debugging}

{$IfDef debugging}
function TIIPsystemInterpreter.Fetch: TBrk;
var
  aSegNameIdx: TSegNameIdx;
Begin { TIIPsystemInterpreter.Fetch }
  result  := dbUnknown;
  fOpCode := Bytes[BC];
  try
    INC(fBC.w);

    Op    := fOpCode;

    with Opstable.Ops[fOpCode] do
      if Assigned(ProcCall) then
        with frmPCodeDebugger do
          begin
  {$IfDef History}
//          if fIsDebugging then
              begin
                aSegNameIdx := TheSegNameIdx(SegBase);
                AddHist(CURPROC, RelIPC, fOp, Opstable.Ops[fOp].Name, aSegNameIdx,
                        DebuggerSettings.CallHistoryOnly);
  {$IfDef Pocahontas}
                Phits := Phits + 1;
                IncProfile(aSegNameIdx, CurProc);
  {$EndIf}
              end;
  {$EndIf}
            ProcCall;
          end
      else
        raise ENOTIMPLEMENTED.CreateFmt('Unimplemented opcode %d', [fOpCode]);

    Inc(DbgCnt);
  except
    on e:EXEQERR do
      pXEQERR(fErrCode, e.Message);
    on e:ENOPROC do
      pXEQERR(NOPROCC, e.Message);
    on e:ENOEXIT do
      pXEQERR(NOEXITC, e.Message);
    on e:ESTKFAULT do
      pXEQERR(STKFLTC, e.Message);
    on e:ESYSTEMHALT do
      begin
        result := FinalException(e.Message, e.ClassName);      // break out of the FETCH loop
      end;

    // if it is an unknown exception, it needs to be rethought
    on e:Exception do
      result := FinalException(e.Message, e.ClassName);
  end;
end; { Fetch }
{$EndIf debugging}



{******** SOME CODE FROM  8086 INTERP****************}
Procedure TIIPsystemInterpreter.StartPME;
{assumes file already open}
{no call to initsegtbl as this done by read segdict}
var DataSize, ParamSize: word;
    SegWasReadIn: boolean;
//  FirstBlk: integer;
//  DataSize0: word;
//  xJTAB: WORD;
Begin { TIIPsystemInterpreter.StartPME }
  {patch LB for dummy os vars: input output kbd}  {These three lines are irrelevent}
  PUSH(02) ; {Keyboard}
  PUSH(01) ; {output}
  PUSH(00) ; {input}
  SP := SP - DISP0 - 4;   {I don't know why we need extra 4 }
  Globals.LowMem.Syscom.LASTMP := SP;
  { end of patch MP holds for os -1}

//FirstBlk := FindFileFirstBlockOnUnit(CSYSTEM_PASCAL, fBootUnit);
//A := 0;
  SEGP := GetSeg(0, SegWasReadIn);  // Load PascalSys, segment 0
  {Returns DE ^segp (is it out by 2? LB?}

  {init all p-machine regs}
  HL     := SEGP { - 2};{patch/1} {used to be:HL := MEMTOP-2}
//SEGP   := HL;

  DEC(fHL.w);
  DEC(fHL.w);

  JTAB   := HL - WordAt[HL];      // ^ Last word of segment
  HL := HL - 4;

  with Globals.LowMem.Syscom do
    IPCSAV     := JTAB-2 - WordAt[JTAB-2];  // point to the 1st instruction in the segment code

  ProcBaseSave := IPCSAV;  // save address of 1st byte of procedure
  ProcBase     := IPCSAV;

  DataSize     := WordAt[JTAB-8];        // DataSize
  SP           := SP - DataSize;  {allocate data space}
  SP           := SP-6;     {patch lb...leave space for 3 predeclared files inp/out/kbd}

  ParamSize    := WordAt[JTAB-6];  // ParamSize
  SP           := SP - ParamSize;                               // allocate room for parameters
  HL           := SP;

  PUSH(Integer(@TIIGlobals(nil^).Lowmem.Syscom)); // ^Syscom (actually = 0)

  PUSH(HL);     {MSSP: create MSCW, dummy save state, push stack pointer};
  HL  := SP - 4; {address of abort opcode}
  PUSH(HL);     {MSIPC: push ipc}
  PUSH(SEGP);   {MSSEG: SEGTOP for system segment. Was: PUSH($00D6)};
  PUSH(JTAB);   {MSJTAB: abort opcode OR maybe Was: PUSH($00D6)};
  HL := SP - 4;
  PUSH(HL);     {STAT + DYN must be self ref}
  PUSH(Globals.LowMem.Syscom.LASTMP);  {MSDYN: used to be PUSH(HL)}  {Patch LB PUSH(Globals.LowMem.Syscom.LASTMP)}
  PUSH(Globals.LowMem.Syscom.LASTMP);  {MSSTAT: bug15 fix...as we simulate seg0...see bug15.pas, interp7} {DHD: what was supposed to happen here?}

  Globals.LowMem.Syscom.LASTMP  := HL;    {set all MSCW pointers}
  Globals.LowMem.Syscom.STKBASE := HL;
  LocalVar   := HL + DISP0;
  GlobVar    := LocalVar;
  HeapTop    := 256; {start of heap, ? same as INTEND in Z80 interp}
  {Note.. HeapTop was 0 BUT.... make it 256 as some operations (CLSS,SAS) assume
   that if the hi byte of ^string is 0 then it is a char not a pointer.
   It is possible to introduce a bug if a pointer to a string is allocated
   within the first page of memory.  Hence the pmachine may mistake it for
   a char instead of a real pointer ...see lexicographic string compare
   LB 17/4/91}

  GetSavedIPC;         {restore ipc}
end; { TIIPsystemInterpreter.StartPME }
{********END OF 8086 CODE****************}



Procedure TIIPsystemInterpreter.initsets;
begin
  CLRMSK     := $0000;
  bitter[ 0] := $0001;
  bitter[ 1] := $0003;
  bitter[ 2] := $0007;
  bitter[ 3] := $000F;
  bitter[ 4] := $001F;
  bitter[ 5] := $003F;
  bitter[ 6] := $007F;
  bitter[ 7] := $00FF;
  bitter[ 8] := $01FF;
  bitter[ 9] := $03FF;
  bitter[10] := $07FF;
  bitter[11] := $0FFF;
  bitter[12] := $1FFF;
  bitter[13] := $3FFF;
  bitter[14] := $7FFF;
  bitter[15] := $FFFF;


  unbitter[ 0] := $FFFF;
  unbitter[ 1] := $FFFE;
  unbitter[ 2] := $FFFC;
  unbitter[ 3] := $FFF8;
  unbitter[ 4] := $FFF0;
  unbitter[ 5] := $FFE0;
  unbitter[ 6] := $FFC0;
  unbitter[ 7] := $FF80;
  unbitter[ 8] := $FF00;
  unbitter[ 9] := $FE00;
  unbitter[10] := $FC00;
  unbitter[11] := $F800;
  unbitter[12] := $F000;
  unbitter[13] := $E000;
  unbitter[14] := $C000;
  unbitter[15] := $8000;


end;





Procedure TIIPsystemInterpreter.Init;
{var thetime : longint ABSOLUTE lotime;}
Begin
  Globals.LowMem.Syscom.GDIRP := pNIL;   {NIL ie directory not loaded..should be nil to start}
  initsets;
  Globals.LowMem.Syscom.IORSLT := INOERROR;
  InitTime;
end;

Procedure TIIPsystemInterpreter.ShowSizes;
(*
type
  pword = ^word;
var
  aFIB: TFIB2;

  procedure Wline(Cap: string; Offset: pword);
  var
    o: integer;
  begin
    o := ((Longint(Offset)-Longint(@aFIB)) div 2) + 3;
    with frmPSysWindow do
      WriteLn([Cap, o]);
  end;
*)
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

      {check UCSD GLOBALS}
      Writeln('UCSD 1.5 global stuff...');
      writeln(['daterec  = ',sizeof(daterec)]);
      writeln(['unitnum  = ',sizeof(unitnum)]);
      writeln(['direntry = ',sizeof(direntry)]);
      WriteLn(['TFIB2    = ',sizeof(TFIB2)]);
      Writeln;
    end;
end;


Function TIIPsystemInterpreter.CheckSizes:Boolean;
{check structure sizes}
var Errors:integer;
Begin
  Errors := 0;
  if sizeof(aword)           <>   2 then inc(errors);
  if sizeof(sdrecord)        <> 288 then inc(errors);
  if sizeof(freeunion)       <> 512 then inc(errors);
  if sizeof(TOprec)           <>  12 then inc(errors);
  if sizeof(sd.Dict.diskinfo)<>  64 then inc(errors);
  if sizeof(sd.dict.SegNamesII) <> 128 then inc(errors);
  if sizeof(sd.dict.SegKind) <>  32 then inc(errors);
  if sizeof(sd.dict.SegInfo) <>  32 then inc(errors);

  {check UCSD GLOBALS}
  if sizeof(daterec)         <>   2 then inc(errors);
  if sizeof(unitnum)         <>   2 then inc(errors);
  if sizeof(direntry)        <>  26 then inc(errors);
//if Sizeof(TFIB2)           <> 580 then inc(errors);    // Is this really needed?
  CheckSizes := errors=0;
end;





//var i:integer;


// xs,
//   xo:word;
// xp,
// xa:pointer;

(* ========== MAIN BODY ========== *)

constructor TIIPsystemInterpreter.Create(aOwner: TComponent;
                VolumesList: TVolumesList;
                thePSysWindow: TfrmPSysWindow;
                Memo: TMemo;
                TheVersionNr: TVersionNr;
                TheBootParams: TBootParams);
begin
  inherited;

//VersionNr := vn_VersionII;

  GetMem(bytes, LOW64K);    // version II can only access 64Kb
  FillChar(Bytes^, LOW64K, 0);  // initialize memory to all 0

  move(bytes, Words, 4);    // access either as words or bytes
  move(bytes, Globals, 4);  // access to other (non-syscom) stuff-- notice that Globals INCLUDES SysCom

  Initialize_Interp;

{$If Defined(DumpDebugInfo) and Defined(SegInfoRec)}
  fLogFileName := FilerSettings.ReportsPath + 'DumpDebugInfo' + TXT_EXT;
  AssignFile(fLogFile, fLogFileName);
  Rewrite(fLogFile);
  WriteLn(fLogFile, 'Log file created @ ', DateTimeToStr(Now));
  fDumpsMade := false;
{$IfEnd Defined(DumpDebugInfo) and Defined(SegInfoRec)}
end;


procedure TIIPsystemInterpreter.Load_PSystem(UnitNr: word);
var
  FirstBlk: integer;
//MaxBlocks: integer;
  FileName: string;
  InBufPtr: TInBufPtr;
begin { Load_PSystem }
  inherited;

  inittime;
  HEXDIGIT := '0123456789ABCDEF';
  Flip     :=False;

  {now check structure sizes to match UCSD sizes}

  If Not CheckSizes then
    ShowSizes;

  with Globals.LowMem.Syscom do
    begin
      Fillchar(segtbl, sizeof(segtbl),chr(0));
      memtop := InterpHIMEM-900; {leave 900 bytes for?3 fibs? LB 28/4/91}
      SP     := memtop;
      SysUnit := UnitNr;
    end;

  {LB: don't clear first page: syscom is at 0}

  FileName := CSYSTEM_PASCAL;
  FirstBlk := FindFileFirstBlockOnUnit(FileName, fBootUnit); // SYSTEM.PASCAL getting loaded twice?

  LoadSegDict(FirstBlk, FileName);

//ShowSeginfo;

  Init;

  InBufPtr := @Globals.LowMem.Syscom;

  LoadMiscInfo(fVolumesList[Unitnr].TheVolume, CSYSTEM_MISCINFO, InBufPtr^);

  with frmPSysWindow do
    begin
      LoadCrtKeyInfo(InBufPtr, CrtInfo, KeyInfo, VersionNr);
      CrtInfo.TermType := FilerSettings.TermType;
      CrtInfo.InfoChanged;
    end;

  StartPME;

  {save sp now and check before RBP opcode}
//startsp := sp;    {debugging code for interp}


{ Copyright Dr Laurence Boshell 1986 thru 2005 }
{ 47 Martin Place LINDEN 2778 NSW Australia  047 531086}
{ Absolutely NO apologies made for this code... It was feverishly written
  to bootstrap an early version of the UCSD system. I just about went mad
  trying to deduce the p-machine architecture, and finally an early version
  of I.5 to come to life, albeit with many bugs and crashes.  There after
  it was a rapid hack, purely designed to implement most of the pcodes.
  Needless to say, the call structures CBP etc were a struggle. The code is
  slapped together and is quick and dirty, but I'll come back to it when
  time permits in between operating and delivering babies.
  When time permits I may even recode it in Assem or even C!

  There are some very minor additions to run under MSDOS, but these do no
  detract from the original p-system implementation.  I have not done any
  support code for system level 0 as this is the actual UCSD OS.  However,
  there is no reason why it could not be added to the interp.

  Debugger support and single stepping implemented in 20 minutes. I need to
  come back and clean up the code and the design.

  25/12/96
  This code is for TP6.0 and TP7.0, it'll probably compile with TP4.0 and up.
  As far as I can determine, the I.5 p codes are faithfully emulated in this
  version.  The p-code versions of compiler, linker and librarian work.
  Even the naughty techniques of memory addressing used in the I.5 linker
  are correctly executed.  The compiler compiles itself to provide a fertile
  descendent compiler.

  I've also just about finished FET...Fast execution translator.  Takes p-code
  file and converts it to assembly file according to state machine description
  for 80x86.  It will also do about 10 levels of optimisation.
  }

{   INTERP 7, descended from ? DECODE 4
    4 : incorporates dos2io...i.e. file handles

    6 : Attempt at 64K for pcodes by changing most global vars to
        words.  A limitation of turbo means the data space is a total
        of 64K including all other global vars. Actual pcode space is about
        55K
    7 : code[] changed to dataspace^[]

    WARNING                     LB 23/3/91
    the sequence Dataspace^[x] := a mod 256;
                 Dataspace^[x+1]:=a div 256
    may give bad hi byte results when dealing with a neg number
    suggest      Dataspace^[x+1]:=(a and $FF00) shr 8
    for the hi byte to be sure..


    nil is considered 0001;
    NIL is now considered 0000    LB 3/7/91
    see const pNIL;


    True is considered 0001
    bug fix interp7
    True is now........ffff   LB 5/2/93

    False is           0000

    true is now........0001   LB 26/12/96



    There is an LNOT/BNOT bug (?) in the compiler eg
    for the code
     b:=true;
     f:=b;
     if not f then write('boolean failure');

    the compiler used LNOT
    FIX....
    Make the interp check only bit 0 in FJP.  See FJP in this listing

    Further fix 5/2/93
      make true=$FFFF ie not(false)
      but mask of all save bit 0 for boolean checks
    Note 26/12/96 true=$ffff was a bad idea as ord(16>0) returned -1!!!
    So changed back to true = $0001 on 26/12/96

    Bitter is made an array of words to there are subtle differences in the
    direct translation form the machine code version to this pascal version
    mainly to do with the way the array bitter is indexed  (also unbitter)


   STR only for integers

   INTEGER[n] causes the compiler to fall over

   1.5 patches from 2.0
   MVB replaces LDO    $A9



   SETS needed a little bit of work as the z80 machine code version
   stuffed up the ret address.  See variable AbortCompare in comparison
   of complex things.  This needs to be cleaned up later, but for now
   it passes the set validation tests.

   19/2/93 interp7: Int2Ops procedure CXP 0 56 added

   8/11/2004 Minor changes to pcode for trunc and round to stop turbo rte 201
}


{there is a quirk in UCSD as the compiler generates code to close any
 local files declared... This is ok till the interp runs under dos...
 DOS returns an error if you try to close a closed file, ucsd does not
 TEMP FIX... dont close if dos handle=0
 LONG TERM FIX...remove compiler code that generates the extra close
              ...at the same time ? introduce assign?? }



{$N+}    {for ucsd reals to be turbo single reals}


{ patches to UCSD struct by L.Boshell to make turbo allocate
 same size records}




{in CSETUP must add 14 LONGC and 16 OBJC}




{********************************************************************  }
{                                                                      }
{ 26/1/93  Bug10  See apple pascal 1.3 manual pg III-168 about         }
{          eof with interactive files on opening                       }
{                                                                      }
{ 30/1/93  Extensive work on EOF/EOLN .. works ok (interp7)            }
{                                                                      }
{ 12/7/93  some work done to read string.  Think about WINCRT.PAS      }
{                                                                      }
{ 15/7/93  Interp 7 Bug 16 fix. Unload segment stuffed up the stack    }
{          as decref was supposed to point HL at entry in intsegt      }
{          but it left HL still holding the segment number.            }
{          Fix was to correct the way HL is used in unload seg.        }
{ 11/9/93  Bug 17 fix...readln(i) died on negative number. Fixed       }
{                                                                      }
{ 22/9/95  Minor oversight in original code fixed.  A copy of params   }
{          was done even when not needed (if LocalDataSize=0). Fixed.    }
{                                                                      }
{  3/10/95 CSP 54 is inc(i) or inc(i,x)                                }
{  3/10/95 CSP 55 is dec(i) or dec(i,x)                                }
{ 26/12/96 Bug18. Fixed. PUSHTRU is push($0001) not push($FFFF)        }
{                                                                      }
{ 13/11/04 Better ShowStack procedure: now as words with TOS marked    }
{ 21/05/2005 Bug fix: Only Globals.LowMem.Syscom.segtable[1] and [7] were being      }
{            filled in correctly.  Noted when running L2, it looked    }
{            these entries to calc buffer size.  Now fixed, all        }
{            elements of the array are populated, not just 1 and 7     }
{              this....                                                }
{            For LSEG := 1 to MAXSEG do                                }
{              not this ...                                            }
{            For LSEG := 1 to MAXSEG do If (LSEG=1) or (LSEG>=7) then  }
{            I was using a separate var MP when it should have been    }
{             Globals.LowMem.Syscom.LASTMP                                           }
{            MP changed to Globals.LowMem.Syscom.LASTMP and var MP deleted           }
{            BASE changed to Globals.LowMem.Syscom.STKBASE and var BASE deleted      }
{ 26/06/2005 Bug in Reset fixed. Reset(Keyboard) klobbered hi memory   }
{  2/07/2005 Bug in time intrinsic fixed: AND with $FFFF not $EFFF     }

{**********************************************************************}
END;

function TIIPsystemInterpreter.GetCurProc: word;
begin
//result := fCurProc;
  result := Bytes[JTAB];
end;

{$IfDef Debugging}
function TIIPsystemInterpreter.SegIdxFromName(const aSegName: string): TSegNameIdx;
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
{$endIf}


function TIIPsystemInterpreter.ProcName(MsProc: word; aSegTop: longword): string;
{$IfDef debugging}
var
  aSegName: string;
  aSegNameIdx : TSegNameIdx;
{$EndIf debugging}
begin
{$IfDef debugging}
  aSegName    := SegNameFromBase(aSegTop);
  with frmPCodeDebugger do
    aSegNameIdx := TheSegNameIdx(SegBase);
//aSegNameIdx := SegIdxFromName(aSegName);    // This seems redundant
  if aSegNameIdx >= 0 then
    result := Format('%s.%s', [aSegName, ProcNamesInDB[aSegNameIdx, MsProc]])
  else
    result := 'Unknown';
{$else}
  result   := Format('Proc%-2d', [MsProc]);
{$endIf}
end;

procedure TIIPsystemInterpreter.SYSHALT;
begin
//raise ESYSTEMHALT.Create('SYSHALT: Opcode = ');
  HaltPSys('SYSHALT');
end;


procedure TIIPsystemInterpreter.InitJumpTable(InterpreterOpsTable: TCustomOpsTable);
var
  i: integer;
begin { INITJUMPTABLE }
  inherited;

  with InterpreterOpsTable as TCustomOpsTable do
    begin
      for i := 0 to HIGHPCODE do with Ops[i] do begin Name  := ''; {Range := [];} ProcCall := nil end;

      AddOp('SLDC', [$0..$7F], SLDC);        {Load constant value}
      AddOp('ABI', [$80], ABI);              {absolute value}
      AddOp('ABR', [$81], ABR);              {absolute value of real tos ..leaves result on stack}
      AddOp('ADI', [$82], ADI);              {add integers}
      AddOp('ADR', [$83], ADR);              {add reals tos and nos....leaves result on stack}
      AddOp('LAND', [$84], LAND);            {logical AND}
      AddOp('DIF', [$85], DIF);              {{set Difference .. AND(NOT set_b) into set a.}
      AddOp('DVI', [$86], DVI);              {divide integers}
      AddOp('DVR', [$87], DVR);              {divide reals nos by tos....leaves result on stack}
      AddOp('CHK', [$88], CHK);              {range check}
      AddOp('FLO', [$89], FLO);              {pop real off stack, pop integer, float it, push it, push real}
      AddOp('FLT', [$8A], FLT);              {pop integer off stack 2 bytes, and push real 4bytes}
      AddOp('INN', [$8B], INN);              {see if integer tos-1 is in set tos}
      AddOp('INT', [$8C], INT);              {Set intersection. AND set_b into set_a, then zero-fill}
      AddOp('LOR', [$8D], LOR);              {logical or}
      AddOp('MODI', [$8E], MODI);            {remainder of integer division}
      AddOp('MPI', [$8F], MPI);              {integer multiply}

      AddOp('MPR', [$90], MPR);              {mult reals tos and nos....leaves result on stack}
      AddOp('NGI', [$91], NGI);              {negate integer}
      AddOp('NGR', [$92], NGR);              {negate value of real tos}
      AddOp('LNOT', [$93], LNOT);            {logical not}
      AddOp('SRS', [$94], SRS);              {build a subrange set, the set [i..j]}
      AddOp('SBI', [$95], SBI);              {subtract integer}
      AddOp('SBR', [$96], SBR);              {subtract tos from nos....leaves result on stack}
      AddOp('SGS', [$97], SGS);              {build singleton set, the set[i]}
      AddOp('SQI', [$98], SQI);              {integer square}
      AddOp('pSQR', [$99], pSQR);            {square reals tos ....leaves result on stack}
      AddOp('STO', [$9A], STO);              {store indirect}
      AddOp('IXS', [$9B], IXS);              {index string pointer}
      AddOp('UNI', [$9C], UNI);              {set union from z80...works fine}
      AddOp('CSP', [$9E], CSP);
      AddOp('LDCN', [$9F], LDCN);            {Load constant nil pointer}

      AddOp('ADJ', [$A0], ADJ);              {adjust set tos to occupy UB wordS}
      AddOp('FJP', [$A1], FJP);
      AddOp('INC', [$A2], INCR);             {increment (SP) by literal}
      AddOp('STIND', [$A3], STIND);          {Static index and load word}
      AddOp('IXA', [$A4], IXA);              {index array}
      AddOp('LAO', [$A5], LAO);              {load global address}
      AddOp('LCA', [$A6], LCA);              {166: load constant address}
      AddOp('LDO', [$A7], LDO);              {167: load global word}
      AddOp('MOV', [$A8], MOV);              {168: move words}
      AddOp('MVB', [$A9], MVB);              {169: move bytes}
      AddOp('SAS', [$AA], SAS);              {String assignment}
      AddOp('SRO', [$AB], SRO);              {store global word}
      AddOp('XJP', [$AC], XJP);              {case jump}
      AddOp('RNP', [$AD], RNP);              {return from normal procedure}
      AddOp('CIP', [$AE], CIP);              {call intermediate procedure}
      AddOp('CEQU', [$AF], CEQU);            {set compare =}

      AddOp('CGEQ', [$B0], CGEQ);            {set compare >=}
      AddOp('CGTR', [$B1], CGTR);            {set compare >}
      AddOp('LDA', [$B2], LDA);              {load intermediate address}
      AddOp('LDC', [$B3], LDC);              {Load multiple word constant..const is backwards in code stream
                                              and is word aligned}
      AddOp('CLEQ', [$B4], CLEQ);
      AddOp('CLSS', [$B5], CLSS);            {LES}
      AddOp('LOD', [$B6], LOD);              {load intermediate word}
      AddOp('CNEQ', [$B7], CNEQ);            {set compare <>}
      AddOp('STR', [$B8], STR);              {store intermediate word}
      AddOp('UJP', [$B9], UJP);              {unconditional jump}
      AddOp('STP', [$BA], LDP);              {load a packed field}
      aDDoP('STP', [$BB], STP);              {Store into a packed field}
      AddOp('LDM', [$BC], LDM);              {Load multiple words (no more than 255)}
      AddOp('STM', [$BD], STM);              {Store multiple words (no more than 255)}
      AddOp('LDB', [$BE], LDB);              {load byte}
      AddOp('STB', [$BF], STB);              {store byte}

      AddOp('IXP', [$C0], IXP);              {Index a packed array}
      AddOp('RBP', [$C1], RBP);              {return from base procedure}
      AddOp('CBP', [$C2], CBP);              {call base procedure}
      AddOp('EQUI', [$C3], EQUI);            { = }
      AddOp('GEQI', [$C4], GEQI);            {>=}
      AddOp('GTRI', [$C5], GTRI);            {>}
      AddOp('LLA', [$C6], LLA);              {load local address}
      AddOp('LDCI', [$C7], LDCI);            {Load constant word}
      AddOp('LEQI', [$C8], LEQI);            {<=}
      AddOp('LESI', [$C9], LESI);            {<}
      AddOp('LDL', [$CA], LDL);              {load local word}
      AddOp('NEQI', [$CB], NEQI);            {compare for <>}
      AddOp('STL', [$CC], STL);              {store local word}
      AddOp('CXP', [$CD], CXP);              {call external (different segment) procedure}
      AddOp('CLP', [$CE], CLP);              {call local procedure}
      AddOp('CGP', [$CF], CGP);              {call global proc}
      AddOp('LPA', [$D0], LPA);              {string to packed array on TOS}
      AddOp('NOP', [$D7], NOP);              {no operation}

     { $D2 : GONATIVE;} {used to be BYT, not generated by compiler}

      AddOp('BPT', [$D5], BPT);
      AddOp('HALT', [$D6], SYSHALT);

      AddOp('SLDL', [$D8..$E7], SLDL, -1);   {short load local word}
      AddOp('SLDO', [$E8..$F7], SLDO, -1);   {short load global word - like SLDL}
      AddOp('SIND0', [$F8], SIND0);
      AddOp('SIND', [$F9..$FF], SIND, -1);

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
    {12..20 not defined}
      AddCspOp('GetSeg',           21, CSPGetSeg);
      AddCspOp('ReleaseSeg',       22, CSPReleaseSeg);
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
procedure TIIPsystemInterpreter.InitUnitTable;
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

  with UNITBL[8] do   // REMOUT:
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
procedure TIIPsystemInterpreter.pSysWindowClosing(Sender: TObject; var Action: TCloseAction);
begin
//raise ESYSTEMHALT.Create('p-Sys Window closed');  // break out of the fetch loop. 11/7/2022 this was leaving the window open
  StatusProc('p-Sys Window closed');
end;
*)

procedure TIIPsystemInterpreter.Initialize_Interp;
begin
  frmPSysWindow.Show;

  with frmPSysWindow do
    begin
      WriteLn('original 64K p-machine (I.5) (c) Laurie Boshell 1986/2005');
      Writeln([' Ver 0.7  laurie@pnc.com.au']);
      WriteLn('Integration into Filer system by Dan Dorrough 2021-2024');
      WriteLn;
//    OnClose := pSysWindowClosing;  // Causes an attempt to call a Method of a freed object
    end;

  InitUnitTable;

  Assert(CREALSIZE = 2);
{$IfDef debugging}
  WatchTypesTable[wt_real].WatchSize := SizeOf(Single); // Using 2 word reals
  WatchTypesTable[wt_real].WatchCode := 'R2';
{$EndIf}
end;

procedure TIIPsystemInterpreter.StatusProc(const Msg: string; DoLog,
  DoStatus: boolean);
begin
  inherited
end;

function TIIPsystemInterpreter.GetMaxVolumeNr: integer;
begin
  result := UCSDglbu.MAXUNIT;
end;

function TIIPsystemInterpreter.InterpHIMEM: longword;
begin
  result := LOW64K;
end;

function TIIPsystemInterpreter.GetGlobVar: longword;
begin
  result := BASED0;
end;

function TIIPsystemInterpreter.GetLocalVar: longword;
begin
  result := MPD0;
end;

procedure TIIPsystemInterpreter.SetGlobVar(const Value: longword);
begin
  BASED0 := Value;
end;

procedure TIIPsystemInterpreter.SetLocalVar(const Value: longword);
begin
  MPD0 := Value;
end;

procedure TIIPsystemInterpreter.SetOp(const Value: Word);
begin
  fOp := Value;
end;

function TIIPsystemInterpreter.GetOp: word;
begin
  result := fOp;
end;

destructor TIIPsystemInterpreter.Destroy;
begin
{$IfDef DumpDebugInfo}
  if fLogFileIsOpen then
    begin
      CloseFile(fLogFile);
      fLogFileIsOpen := false;
    end;
  if fDumpsMade then
    EditTextFile2(FilerSettings.EditorFilePath,  fLogFileName)
  else
    StatusProc('No DebugDumpInfo dumps were made', true, true);
{$EndIf DumpDebugInfo}
  inherited;
end;

function TIIPsystemInterpreter.GetProcBase: longword;
begin
  result := fProcBase;
end;

{$IfDef Debugging}
function TIIPsystemInterpreter.CurrentSegName: string;
begin
  result := SegNameFromSegTop(SEGP);
end;

function TIIPsystemInterpreter.MemDumpDW( Addr: longword;
                                          Code: TWatchType = wt_HexWords;
                                          Param: longint = 0;
                                          const Msg: string = ''): string;
const
  NRBYTES = 50;
var
  Temp: string;

  function PrefixInfo(Prefix: string; Addr: longword): string;
  begin
    if Msg <> '' then
      result := Format('%s @ %s: ', [Msg, Bothways(Addr)])
    else
      result := Format('%s @ %s: ', [Prefix, Bothways(Addr)]);
  end;

  function DiskInfoFormat(Addr: word): string;
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

  function SegNamesFormat(Addr: word): string;
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

  function SegKindsFormat(Addr: word): string;
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
    aJTAB     : word;
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
    aProcNr  := Bytes[JTAB];
    AddProcCall(0, ProcNameFromSegTop(aProcNr, SEGP), IntToStr(RelIPC));  // First the current procedure

    MscwAddr := Globals.LowMem.Syscom.LASTMP;

    if (aProcNr <> 0) then
      while (MscwAddr <> 0) and
            (MscwAddr <> MSCWField(MSCWAddr, csDynamic) {next MSCW addr}) and
            (aProcNr <> 0) and
            (MSCWField(MSCWAddr, csStatic) <> 0) do
        begin  // then all the other procedures on the call stack
          aJTAB        := MSCWField(MSCWAddr, csJTAB);
          aProcNr      := Bytes[aJTAB];
          aProcName    := ProcNameFromSegTop(aProcNr, MSCWField(MSCWAddr, csSeg));

          try
            aEnterIC  := aJTAB-2 - WordAt[aJTAB-2];
            aRelIPC   := MSCWField(MSCWAddr, csIPC) - aEnterIC;
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


  function UnitTableFormat(Addr: longWord; Param: word): string;
  var
    UnitNr: word;
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
            if UVID <> '' then
              begin
                if result <> '' then
                  result := result + ', ';
                result := result + Format('[%d]:UVid=%s;Blk=%s', [UnitNr, UVID, TF(Boolean(UISBLKD))]);
              end;
        result := PrefixInfo('UnitTable', Addr) + result;
      end;
  end;  { UnitTableFormat }

  function RegValues(AsHex: boolean): string;
  var
    RegValue2: string;

    function RegValue(Reg: string; Num: word; LastOne: boolean = false): string;
    begin { RegValue }
      if AsHex then
        result := Format('%s=$%4s', [Reg, HexWord(Num)])
      else
        result := Format('%s=%d', [Reg, Num]);

      if not LastOne then
        result := result + ', ';
    end; { RegValue }

  begin { RegValues }
    if AsHex then
      RegValue2 := Format('A=$%2x, ', [A])
    else
      RegValue2 := Format('A=%02d, ', [A]);

    result := RegValue2 + RegValue('BC', BC) + RegValue('DE', DE) + Regvalue('HL', HL) + RegValue('SP', SP)
            + RegValue('HeapTop', HeapTop) + RegValue('LocalVar', LocalVar) + RegValue('GlobVar', GlobVar)
            + RegValue('SEGTOP', SEGP)
            + RegValue('JTAB', JTAB)
            + RegValue('SegBase', SegBase) + RegValue('IPCSAV', IPCSAV) + RegValue('SEGP', SEGP, true)
  end;  { RegValues }

  function ProcedureInfo(Addr: word; ProcNo: word): string;
  var
    SegLength, Loc, PDCount, {pn,} JTab, EnterIC, ExitIC, DataSize, ParamSize{, SegNum}: word;
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
        JTab      := Loc - WordAt[Loc];
        EnterIC   := (JTab-2) - WordAt[JTab-2];
        ExitIC    := (Jtab-4) - WordAt[JTab-4];
        ParamSize := GetWordAt(JTab-6);
        DataSize  := WordAt[JTab-8];
        result    := PrefixInfo('Procedure Info', Addr) +
                       Format('SegNum=%d, Procedure=%d, JTAB=$%4x, EnterIC=$%4x, ExitIC=$%4x, ParamSize=%d, DataSize=%d',
                             [SegNum, ProcNo+1, JTAB, EnterIC, ExitIC, ParamSize, DataSize]);
      end
    else  // list all procedure offsets
      begin
        result := PrefixInfo('Procedures info', Addr) + Format('PdCount=%d, ', [PdCount]);
        for ProcNo := 1 to PdCount do
          begin
            Loc       := (Loc - 2) * (ProcNo + 1);
            JTab      := Loc - WordAt[Loc];
            result    := Result + Format('%d=%4x', [ProcNo, JTab]);
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
    SoftBufAddr: word;
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
              ADirEntry := MemDumpDW(Addr+32 {offset to FHEADER FIELD}, wt_DirectoryEntry);  // Seems like the 32 should actually be 26
//            ADirEntry := MemDumpDW(Addr+27 {offset to FHEADER FIELD}, wt_DirectoryEntry);  // Seems like the 32 should actually be 26
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

  function JTABFormat(Addr: word): string;
  begin { JTABFormat }
    result := PrefixInfo('JTAB', Addr);
    try
      if Addr > 10 then  // initially could be bad
        result := result + Format('ProcNr=%d, LexLevel=%d,EnterIC=$%-4.4x, ExitIC=$%-4.4x, ParamSize=%d, DataSize=%d, LastCode=%d',
                           [Bytes[Addr],  // ProcNr
                            Bytes[Addr+1],   // LexLevel
                            Addr-2 - WordAt[Addr-2], // EnterIC
                            Addr-4 - WordAt[Addr-4], // ExitIC
                            WordAt[Addr-6],          // ParamSize
                            WordAt[Addr-8],          // DataSize
                            WordAt[Addr-10]]);       // LastCode
    except
      result := result + '(bad JTAB)';
    end;
  end;  { JTABFormat }

  function ProcedureNameFormat(Addr: word): string;
  var
    aSegName, aProcName: string;
    SegNameIdx: TSegNameIdx;
  begin
    with frmPCodeDebugger do
      SegNameIdx := TheSegNameIdx(SegBase);

    aSegName   := SegNamesInDB{[AccDbNr]}[SegNameIdx];
    aProcName  := ProcNamesInDB[SegNameIdx, CurProc];

    result := Format('Procedure name: %d:%s.%s', [CurProc, aSegName, aProcName]);
  end;

  function SegTblFormat(Addr: word): string;
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

  function TreeStructureFormat(Addr: word): string;
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

  function IILinkerFormats(Addr: word; code: TWatchType): string;
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

      diskblock = packed array [0..511] of 0..255;
//    codefile = file;            { trick compiler to get ^file }
      codefile = word;            { trick compiler to get ^file }

//    filep = ^codefile;
      filep = word;

      codep = ^diskblock;         { space management...non-PASCAL kludge }

      segkinds =({0}LINKED,          { no work needed, executable as is }
                 {1}HOSTSEG,         { PASCAL host program outer block  }
                 {2}SEGPROC,         { PASCAL segment procedure, not host }
                 {3}UNITSEG,         { library unit occurance/reference }
                 {4}SEPRTSEG);       { library separate proc/func TLA segment }

//    finfop = ^fileinforec;      { forward type dec }
      finfop = word;              { forward type dec }

//    symp = ^symbol;
      symp   = word;

//    segp = ^segrec;             { this structure provides access to all }
      segp   = word;

      segrecPtr = ^segrec;

      segrec = record             { info for segs to be linked to/from    }
                 srcfile: finfop;         { source file of segment }
                 srcseg: segrange;        { source file seg # }
                 symtab: symp;            { symbol table tree }
                 case segkind: segkinds of
                   SEPRTSEG:
                          (next: segp)    { used for library sep seg list }
               end { segrec } ;

      filekind = (USERHOST, USERLIB, SYSTEMLIB);

      TI5SegTblPtr = ^I5SegTbl;

      I5segtbl = record   { first full block of all code files -- this is just a segment dictionary - right?}
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

      TFileInfoRecPtr = ^fileinforec;

      fileinforec = record
                      next: finfop;       { link to next file thats open }
                      code: filep;        { pointer to PASCAL file...sneaky! }
                      fkind: filekind;    { used to validate the segkinds }
                      segtbl: I5segtbl    { disk seg table w/ source info }
                    end { fileinforec } ;

      { link info structures }
      { ---- ---- ---------- }

//     placep = ^placerec;         { position in source seg }
       placep = word;

       placerec = record
                    srcbase, destbase: integer;
                    length: icrange
                  end { placerec } ;

//     refp = ^refnode;            { in-core version of ref lists }
       refp = word;

       refnode = record
                   next: refp;
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

      liset = set of Tlitypes;

      opformat = ({0}of_WORD, {1}of_BYTE, {2}of_BIG);       { instruction operand field formats }

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
                      (oformat: opformat;      { how to deal with the refs }   {THESE ARE PROBABLY IN WRONG ORDER}
                       nrefs: integer;        { words following with refs }
                       nwords: lcrange;       { size of privates in words }
                       reflist: refp);        { list of refs after read in }
                     EXTPROC{9},
                     EXTFUNC{10},
                     SEPPROC{11},
                     SEPFUNC{12}:
                      (srcproc: procrange;    { the procnum in source seg }
                       nparams: integer;      { words passed/expected }
                       place: placep;         { position in source/dest seg }
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

      TSymbolPtr = ^Symbol;

      symbol = record
//               llink, rlink,            { binary subtrees for diff names }
//               slink: symp;             { same name, diff litypes }
                 slink: symp;             { re-orderd because of differing Delphi/UCSD field ordering }
                 rlink: symp;
                 llink: symp;
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
      result := ExtractWordL(ord(li)+1, ENTRYNAME, DELIMS);
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

  function SymbolFormat(Addr: word): string;
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
  function segrecFormat(Addr: word): string;
  begin { segrecFormat }
    with segrecPtr(@Bytes[addr])^ do
      begin
        result := Format('srcfile=%d, srcseg=%d, symtab=%d, segkind=%s', [srcfile, srcseg, symtab, SegKindName(segkind)]);
        if segkind = segkinds(SEPRTSEG) then
          result := result + Format(', next=%d', [next]);
      end;
  end;  { segrecFormat }

  function workrecFormat(Addr: word): string;
  type
    workp = word;

    TWorkRecPtr = ^workrec;

    workrec = record        // NOTE: fields have been re-ordered from UCSD to match Delphi usage
               next: workp;          { list link }
               defsym: symp;         {   "      "   "  resolving entry }
               refsym: symp;               { symtab entry of unresolved name }
               defseg: segp;         { seg where defsym was found }
               refseg: segp;               { seg refls point into, refrange only }
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
    TheSegName: string;
    ch: string[1];
    SegIdx: integer;
  begin { SegDictFormat }
    result := '';
    with TI5SegTblPtr(@Bytes[Addr])^ do
      for SegIdx := 0 to MAXSEG do
        if DiskInfo[SegIdx].CodeAddr <> 0 then
          begin
            ch := ',';
            if result = '' then
              ch := '';

            TheSegName := segname[SegIdx];
            result := result + ch + Format('[%d.segname=%s, %d.codeaddr=%d, %d.codeleng=%d, %d.segkind=%s]; ',
                                       [segidx,
                                        TheSegName,

                                        segidx,
                                        DiskInfo[SegIdx].codeaddr,

                                        segidx,
                                        DiskInfo[SegIdx].codeleng,


                                        segidx,
                                        SegKindName(segkind[SegIdx])]);
          end;
  end;  { SegDictFormat }

  function FileInfoFormat(Addr: word): string;
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

begin { MemDumpDW }
  result := inherited MemDumpDW(Addr, Code, Param);

  if result = '' then
    case Code of
      wt_OpCodesDecoded:
        if AbsIPC > 0 then // DEBUGGING
          result := PrefixInfo('Decoded', Addr)
                    + DecodedRange(addr, NRBYTES, Addr);

    wt_RegDumpHex:
      result := 'Regs(hex): ' + RegValues(true);  // Hex values

    wt_RegDumpDec:
      result := 'Regs(dec): ' + RegValues(false);  // Decimal values

    wt_ProcedureInfo:
      result := ProcedureInfo(Addr, Param {Used for procedure number});

    wt_MSCWp:
      begin
  {$R-}
        with TMSCWPtr2(@Bytes[Addr])^ do
          begin
            temp   := PrefixInfo('MSCW', Addr);
            result := Temp +
                      Format('StatLink=%s, DynLink=%s, MSJTAB=%s, MSSEG=%s, MSIPC=%s, LocalData[0]=%s',
                             [HexWord(STATLINK), HexWord(DYNLINK), HexWord(MSJTAB), HexWord(MSSEG), HexWord(MSIPC),
                              HexWord(LocalData[0])]);
  {$R+}
          end;
      end;

    wt_FIBp, wt_FIB:
      result := FIBFormat(Addr);

    wt_JTAB:
      result := JTABFormat(Addr);

    wt_UnitTableP:
      result := UnitTableFormat(Addr, Param);

    wt_DynamicCallStack:
      result := 'Dynamic ' + CallStackFormat(Addr, csDynamic);

    wt_StaticCallStack:
      result := 'Static ' + CallStackFormat(Addr, csStatic);

    wt_ProcedureName:
      result := ProcedureNameFormat(Addr);

    wt_DiskInfo:
      result := PrefixInfo('DiskInfo', Addr) +
                DiskInfoFormat(Addr);

    wt_SegNames:
      result := PrefixInfo('SegNames', Addr) +
                SegNamesFormat(Addr);

    wt_SegKinds:
      result := PrefixInfo('SegKinds', Addr) +
                SegKindsFormat(Addr);

    wt_SegTable:
      result := PrefixInfo('SegTbl', Addr) +
                SegTblFormat(Addr);

    wt_Tree:
      result := PrefixInfo('Tree', Addr) +
                TreeStructureFormat(Addr);

    wt_Linker_lientry:
      result := PrefixInfo('lientry', Addr) +
                IILinkerFormats(Addr, Code);

    wt_segrec,
    wt_SegRecP:
      result := PrefixInfo('segrec', Addr) +
                IILinkerFormats(addr, Code);

    wt_Linker_workrec:
      result := PrefixInfo('workrec', Addr) +
                IILinkerFormats(Addr, Code);

    wt_Linker_Symbol:
      result := PrefixInfo('Symbol', Addr) +
                IILinkerFormats(Addr, Code);

    wt_Linker_FileInfo:
      result := PrefixInfo('FileInfo', Addr) +
                IILinkerFormats(Addr, Code);

    wt_SegDict, wt_SegDictP:
      result := PrefixInfo('SegDict2', Addr) +
                IILinkerFormats(Addr, Code);

    // REMEMBER TO UPDATE GetLegalWatchTypes !!!
    end;
end;  { MemDumpDW }

function TIIPsystemInterpreter.GetpCodeDecoder: TpCodeDecoder;
begin
  if not Assigned(fpCodeDecoder) then
    begin
      fpCodeDecoder := TpCodeDecoderII.Create(nil, OpsTable, Word_Memory, VersionNr);
      fpCodeDecoder.OnGetJTAB := GetJTAB;
    end;
  result := fpCodeDecoder
end;
{$EndIf}

procedure TIIPsystemInterpreter.NOP;
begin
  { do nothing }
end;



procedure TIIPsystemInterpreter.SetHL(const Value: word);
begin
  fHL.w := Value;
end;

function TIIPsystemInterpreter.CalcProcBase(aSegTop: longword;
  ProcNumber: word): word;
var
  Loc,
//PDCount,
  aJTAB: word;
begin
  Loc       := aSegTop - 2;
//PdCount   := WordAt[Loc-2] div 2;  // get the number of procedures
  Loc       := (Loc - 2) * (ProcNumber + 1);
  aJTab      := Loc - WordAt[Loc];
//result    := (JTab-2) - WordAt[JTab-2];  // return EnterIC
  result    := GetEnterIC(aJTAB);
end;

function TIIPsystemInterpreter.GetEnterIC(JTAB: word): word;
begin
  result    := (JTab-2) - WordAt[JTab-2];  // return EnterIC
end;


function TIIPsystemInterpreter.GetAbsIPC: longword;
begin
  result := BC;
end;

//  Name:     GetRelIPC
//  Function: Return the offset from the beginning of the procedure
//  Note:     This is only used in the debugger
function TIIPsystemInterpreter.GetRelIPC: word;
begin
{$R-}
  try
    result := BC - ProcBase;
  except
    result := 0;
  end;
{$R+}
end;

procedure TIIPsystemInterpreter.SetAbsIPC(Value: longword);
begin
  BC := Value;
end;

function TIIPsystemInterpreter.GetOpsTableClass: TOpsTableClass;
begin
  result := TOpsTableII;
end;


procedure TIIPsystemInterpreter.SetBC(const Value: word);
begin
  fBC.w := Value;
end;

procedure TIIPsystemInterpreter.SetProcBase(const Value: LongWord);
begin
  fProcBase := Value;
end;


function TIIPsystemInterpreter.GetJTAB: word;
begin
  result := Globals.LowMem.SysCom.JTAB;
end;

procedure TIIPsystemInterpreter.SetJTAB(const Value: word);
begin
  Globals.LowMem.SysCom.JTAB := Value;
end;

function TIIPsystemInterpreter.GetSegBase: longword;
begin
  result := SEGP;  // V1.5 connects everything to the segment TOP !
end;

{$IfDef debugging}

// Name:    GetLegalWatchTypes
// Purpose: returns a set of the watch types that are legal in Version II
function TIIPsystemInterpreter.GetLegalWatchTypes: TWatchTypesSet;
begin
  result := inherited GetLegalWatchTypes + // Union the common WatchTypes with the version II ones
              [wt_OpCodesDecoded, wt_RegDumpHex, wt_RegDumpDec, wt_ProcedureInfo, wt_MSCWp, wt_FIBp, wt_FIB, wt_JTAB,
               wt_ProcedureInfo, wt_UnitTableP, wt_UnitTabEntry, wt_DynamicCallStack, wt_StaticCallStack, wt_ProcedureName,
               wt_DiskInfo, wt_SegNames, wt_SegKinds, wt_SegTable, wt_Tree,
               wt_Linker_lientry, wt_SegRec, wt_SegRecP, wt_Linker_workrec,
               wt_Linker_Symbol, wt_Linker_FileInfo, wt_SegDict, wt_SegDictP];
end;
{$EndIf}

function TIIPsystemInterpreter.SegNameFromBase(SegTop: longword): string;
begin
  result := SegNameFromSegTop(SegTop);  // V2 always uses the SegTop
end;

function TIIPsystemInterpreter.CurrentDataSize: word;
begin
  result := WordAt[JTAB-8];
end;

function TIIPsystemInterpreter.GetStaticLink(MSCWAddr: word): word;
var
  p: TMSCWPtr2;
begin
  p      := TMSCWPtr2(@Bytes[MSCWAddr]);
  result := p^.STATLINK;
end;

(*
function TIIPsystemInterpreter.GetSegNum: TSegNameIdx;
begin
  result := SegIdxFromSegTop(SEGP);
end;
*)
function TIIPsystemInterpreter.GetSegNum: integer;
begin
  result := SegIdxFromSegTop(SEGP);
end;

CLASS function TIIPsystemInterpreter.GetLEGAL_UNITS: TUnitsRange;
begin
  result := [4, 5, 9..UCSDglbu.MAXUNIT];
end;

Function TIIPsystemInterpreter.MSCWField(MSCWAddr: word; CSType: TMSCWFieldNr): word;
var
  p: TMSCWPtr2;
begin { MSCWField }
  p := TMSCWPtr2(@Bytes[MSCWAddr]);
  with p^ do
    case CSType of
      csDynamic:
        result := DYNLINK;
      csStatic:
        result := STATLINK;
      csJTAB:
        result := MSJTAB;
      csSEG:
        result := MSSEG;
      csIPC:
        result := MSIPC;
      csProc:
        result := Bytes[MSJTAB];  // JTAB points to the byte with the procedure number in it
      csLocal:
        result := LocalData[0];
      else
        raise Exception.CreateFmt('System error: invalid MSCW field type: %d', [ord(CSType)]);
    end;
end;  { MSCWField }

procedure TIIPsystemInterpreter.InitIDTable;
begin
  inherited;
  fIDList := TIDListII.Create;
  with fIDList as TIDListII do
    InitIDs;
end;

{$IfDef debugging}
function TIIPsystemInterpreter.DecodedRange( addr: longword;
                                             nrBytes: word;
                                             aBaseAddr: LongWord): string;
begin
  if not Assigned(fDecodeToMemDump) then
    begin
      fDecodeToMemdump := TDecodeToMemDump.Create(self, pCodeDecoder, aBaseAddr);
      with fDecodeToMemDump as TDecodeToMemDump do
        begin
          OnGetByte2 := GetByteFromMemory;
          OnGetWord2 := GetWordFromMemory;
          OnGetJTAB  := GetJTAB;
        end;
    end;

  with fDecodeToMemDump as TDecodeToMemDump do
    Result     := DecodedRange(addr, nrBytes, aBaseAddr);
end;
{$EndIf}

function TIIPsystemInterpreter.GetCREALSIZE: integer;
begin
  result := 2;  // Not stored in SYSCOM.MISCINFO in version < VERSION_iv
end;

function TIIPsystemInterpreter.GetSP: longword;
begin
  result := fSP;
end;

procedure TIIPsystemInterpreter.SetSP(const Value: longword);
begin
  inherited;
  fSP := Value;
end;

function TIIPsystemInterpreter.GetHeapTop: word;
begin
  result := fHeapTop;
end;

procedure TIIPsystemInterpreter.SetHeapTop(const Value: word);
begin
  fHeapTop := Value;
end;

(*
{$IfDef DumpDebugInfo}
procedure TIIPsystemInterpreter.DumpDebugInfo(const Caption: string);
begin
  UnImplemented('DumpDebugInfo');
end;
{$endIf}
*)

procedure TIIPsystemInterpreter.PutIOResult(value: integer);
begin
  inherited;
  with Globals.LowMem.Syscom do
    IORSLT := TIORsltWD(Value);
end;


function TIIPsystemInterpreter.GetSyscomAddr: longword;
begin
  result := 0;
end;


function TIIPsystemInterpreter.GetByteFromMemory(p: longword): byte;
begin
  result := Bytes[p];
end;

function TIIPsystemInterpreter.GetWordFromMemory(p: Longword): word;
begin
  result := Words[p];
end;

(*
function TIIPsystemInterpreter.GetByteFromMemoryBased(base,
  offset: word): byte;
begin
  result := Bytes[Base + Offset];
end;
*)

function TIIPsystemInterpreter.TheVersionName: string;
begin
  result := Format('LB %s', [VersionNrStrings[VersionNr].Name]);
end;

function TIIPsystemInterpreter.GetNextOpCode: byte;
begin
  result   := Bytes[AbsIPC];
//  Assert(false, 'This has not been tested for InterpII');
end;

{$IfDef debugging}
function TIIPsystemInterpreter.GetBaseAddress: longword;
begin
  result := SegBot0 + ProcBase;
end;
{$EndIf debugging}

initialization
finalization
END .

