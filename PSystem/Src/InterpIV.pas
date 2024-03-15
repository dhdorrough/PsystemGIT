{
  SEE:
  M:\NDAS-I\Floppy Diskette\PSysSrcs2\421.2F
  See Step 16 for register usage
}

{ There are multiple ways to debug this, however,

    1. the most useful are Delphi watch expressions like:

      TErecPtr(@Bytes[$9BA]
      
           with the watch display set to "Record/Structure"

      This can be extended to complex expressions like:

           TSibPtr(@TErecPtr(@Bytes[$9BA])^.Env_Sib)^
           
    2. Another way is to use the MemDumpDF(...) procedure as a Delphi watch expression.
       See the MemDump source code for more information.

    3. There are also various debug windows which may be used but these
       make it difficult to just look at information while paused at a breakpoint
       (unless using the method indicated in item 1 or item 2). Most of the debug
       windows were written to find specific bugs and have not been maintained.
       They may no longer work correctly or even exist.

    4. You may also set p-Code breaks of various kinds using the built-in
       debugger. These may be combined with Delphi breaks of various kinds
       to break on many different conditions.

    5. Run an old copy of PSYSTEM.COM or PSYSTEM.EXE under Turbo Debugger on
       a PC (or virtual PC) that can still run 16 bit binaries

    6. There is now a built-in debugger which can trace through p-Code and
       also through source code although the source code is sometimes just a
       guess or is not accurate.
}

{$N+}    {for ucsd reals to be turbo single reals}

unit InterpIV;

interface

uses SysUtils,
     UCSDGlob,
     Interp_Decl,
     PSysWindow,
     Classes,
     pSys_Decl,
     PsysUnit,
     OpsTables,
     Misc,
     Variants,
     pSysVolumes,
     Interp_Const,
     Interp_Common,
     StdCtrls,
     LoadVersion
{$IfDef debugging}
     ,
     Debug_Decl,
     pCodeDebugger,
     Watch_Decl,
     pCodeDecoderUnit
{$endIf}
     ;

{$R+}

{$include BiosConst.inc}

const

DEFAULT_PROCESSOR_TYPE = m_8086;
LOWMEMSIZE_V4_20 = $E6;
LOWMEMSIZE_V4_12 = $38;

CREALSIZE  = 4;        // for version 4

type
  Integer = SmallInt;       // must use 16 bit integers

  TIVLowMem = packed record    // needs to be packed to guarantee p-Code compatability
                  case integer of
                    0: (case integer of
                          0: (Space:  packed array[0..LOWMEMSIZE_V4_20-1] of byte;
                              SyscomSpace: TIVSysComRec);         // Syscom will be located in this area but V4.12 may differ from V4.20.
                          1: (Fill0: packed array[0..$23] of byte; // force same addresses as on PSYSTEM.COM version.
                                                                   // This overlays Space above.
                              IPCSAV: word;               { $24 }
                              MPPlus: word;               { $26 LocalVars }
                              BASEPLUS: word;             { $28 }
//                            SEGB: word;
//                            NIPSAVE: word;
                              SegB: longword;             { $2A }
                              xMP: WORD;            // this needs to be here because of p-code direct access (?? is this still true ??)
                              BASE: word;                 { $2E }
                              CURPROC: integer;           { $30 }
                              SIBP: word;                 { $32 }
                              SEGTOP: word;         // points to the procedure dictionary
                              READYQ: word;               { $36 }
                              EVECp: word;                { $38 }
                              CURTASK: word;              { $3A }
                              ERECp: word;                { $3C }
                              OLDEREC: word;              { $3E }
                              CPOFFSET: word;             { $40 }
                              SEXFLAG: word;
                              EXTEND: word);
                       );
                    end;  { 326 bytes }

  TIVGlobalsPtr = ^TGlobals;

  TGlobals  = record
                LowMem    : TIVLowMem;
                MemInfo   : TMemInfo_Rec;
     { 110 }    RootTask  : TTib;
     { 138 }    MAINMSCW  : TMscw;  // This should be located in low memory
//              XEQERR    : INTEGER;
                MemTop    : longword;
              end;

  TIVPsystemInterpreter = class(TCustomPsystemInterpreter)
  private
    fSI            : word;
//  fAF            : TUnion;
    fAX            : TUnion;
    fBC            : TUnion;
    fBX            : TUnion;
    fBP            : TUnion;
    fCX            : TUnion;
    fDE            : TUnion;
    fDI            : word;

    fDX            : word;
    fMP            : word;

//  Segment registers
    fSP            : Longword;
    fDS            : Longword;
    fES            : Longword;
    fSS            : Longword;

    fOp            : WORD;
    fSSDSVAL       : WORD;

    procedure SetSI(const Value: word);
    function  GetSI: word;

    procedure FJPL;
    procedure XJP;
    procedure UJPL;
    procedure LDCB;
    procedure LOD;
    procedure SLOD;
    function  GETSTA1(): word;
    function CLRMSKp(n: word): word;
    procedure LCO;
    procedure ParmDscr(var Src, Dst: longword; var SrcO, DstO: word); overload;
    procedure CAP;
    procedure UWRITE;
    procedure UIO;
    procedure SYSIO;
    procedure SetDI(const Value: word);
    procedure SetDS(const Value: longword);
    procedure SetES(const Value: longword);
    procedure IND;
    procedure EQSTR;
    function StrCompare(): integer;
    procedure TJP;
    procedure NFJ;
    procedure UREAD;
    procedure DUP1;
    procedure EFJ;
    procedure ASTR;
    procedure MYFILLCHAR;
    procedure SCAN;
    procedure MYMOVE;
    procedure EQBYT;
    function  BYTECMP(): integer;
    function  LODSW: integer;
    function  LODUW: word;
    procedure STR;
    procedure SPR;
    procedure Restore;
    procedure STM;
    procedure BNOT;
    procedure FLIPSEG;
    procedure IXP;
    procedure LDM;
    procedure SetMP(const Value: word);
    procedure RLOCSEG;
    procedure SIGNAL;
    procedure USR_BREAK(TibAddr: word);
    procedure SIG_EVENT;
    function  QLOAD: BYTE;
    procedure TASKSW;
    procedure NOP;
    procedure WAIT;
    function  DELINK(): word;
    procedure EXTADR;
    procedure STE;
    procedure LAE;
    procedure LDE;
    procedure SRS;
    procedure TIM;
    procedure SSTKBACK;
    procedure USTATUS;
    procedure SYSCLR;
    procedure UCLR;
    procedure UWAIT;
    procedure CXI;
    procedure CPG;
    procedure CFP;
    procedure XCFP;
    procedure LSL;
    procedure FLT;
    procedure DUPR;
    procedure MOVSW(N: integer); overload;
    procedure MOVSW( Src {DS}: longword; var SrcO {SI}: word;
                     Dst {ES}: longword; var DstO {DI}: word;
                     N: integer); overload;
    procedure CHK;
    procedure UNI;
    procedure DIF;
    procedure GESTR;
    procedure LESTR;
    procedure STRL;
    procedure LDRL;
    procedure LDCRL;
    procedure GEUSW;
    procedure LEUSW;
    procedure GEBYT;
    procedure LEBYT;
    procedure PCSETUP;
    procedure EQPWR;
    procedure GEPWR;
    procedure LEPWR;
    procedure ZERCHKA;
    procedure ZERCHKB;
    procedure SWAP;
    procedure NAT;
    procedure NATI;
    procedure TNC;
    procedure RND;
    procedure EQREAL;
    procedure GEREAL;
    procedure LEREAL;
    procedure BPT;
    procedure CPI;
    procedure CXL;
    procedure MOVESEG;
    procedure PutPool;
    procedure SetSSDSVAL(const Value: WORD);
    function TreeSearch(root: word; var node: word; const key: TAlpha): integer;
    procedure TREESRCH;
    procedure IOC;
    procedure POT;
//  function GetRealAt(P: longword): TRealUnion; override;
//  procedure SetRealAt(P: longword; const X: TRealUnion); override;
    procedure PTRDRVR;
    procedure CloseStuff;
    function GetDSWord(P: longword): word;
    function GetESWord(p: longword): word;
    procedure SetDSWord(P: longword; const Value: word);
    procedure SetESWord(p: longword; const Value: word);
    procedure IDSEARCH;
    function GetDS: longword;
    procedure HandleBreakKey;
  protected
    function GetOpsTableClass: TOpsTableClass; override;
    function GetAbsIPC: longword; override;
    function GetGlobVar: longword; override;
    procedure SetGlobVar(const Value: longword); override;
    function GetLocalVar: longword; override;
    procedure SetLocalVar(const Value: longword); override;
    function GetRelIPC: word; override;
    procedure GetInterpMemory; override;
    function GetSegBase: longword; override;
    procedure InitJumpTable(InterpreterOpsTable: TCustomOpsTable); override;
{$IfDef Debugging}
    function GetProcBase: longword; override;
    procedure SetProcBase(const Value: longword); override;
    function GetpCodeDecoder: TpCodeDecoder; override;
{$EndIf}
    function Fetch: TBrk; override;
    procedure InitIDTable; override;
    function GetCREALSIZE: integer; override;
//  procedure SetEnableExternalPool(const Value: boolean); override;
    function GetPoolOutside: boolean; override;
    function GetSyscomAddr: longword; override;

private
  StackOverFlow  : boolean;
  IsZero         : boolean;     // IsZero is true to indicate result is 0;
  IsSegFault     : boolean;

//------ GENERAL IO TEMPORARY VARIABLES

  BDLEMSK: BYTE;                // DLE MASK BIT # FOR CURRENT DEVICE
  ESVAL:   LONGWORD;            // VALUE TO USE FOR ES DURING I/O
  SAVDS:   LONGWORD;                //

// Temp data used by assorted routines

  TEMP0   : word;
  NEWSP   : word;
  SAVEPAR : word;
  SAVEPROC: word;

    //------ FLAG BYTES -------------------

    DLEFLG  : packed array[0..3] of byte;  // BIT ARRAY. 1 IF LAST CHAR ON THAT DEVICE
                                           // WAS DLE, 0 OTHERWISE.
    ALFAFLAG: packed array[0..3] of byte;  // ALPHALOCK FLAGS (SAME FORMAT)

    //---- CHRDRVR'S BIOS JUMP VECTOR OFFSETS

    BREQRD:  BYTE;                 //READ REQUEST.
    BREQWR:  BYTE;                 //WRITE REQUEST.
    BREQIN:  BYTE;                 //INITIALIZE REQUEST.
    BREQST:  BYTE;                 //STATUS REQUEST.


    //------ BIOS VARIABLES -----------------

    procedure ABI;
    procedure ABR;
    procedure ADI;
    procedure ADJ;
    procedure ADR;
    procedure ATTACH;
    procedure CPL;
    procedure CSP;
    procedure DECOPS;
    procedure DVI;
    procedure DVR;
    procedure ENVSAVE;
    procedure EQUI;
    procedure FJP;
    procedure GEQI;
    procedure GetSavedIPC;
    procedure INCF;
    procedure InitSets;
    procedure INN;
    procedure INT;
    procedure IOR;
    procedure IXA;
    procedure LAND;
    procedure LAO;
    procedure LDA;
    procedure LDB;
    procedure LDC;
    procedure LDCI;
    procedure LDCN;
    procedure LDL;
    procedure LDO;
    procedure LDP;
    procedure LEQI;
    procedure LLA;
    procedure LNOT;
    procedure LOR;
    procedure MODI;
    procedure MOV;
    procedure MPI;
    procedure MPR;
    procedure NEQI;
    procedure NEWENV;
    procedure NGI;
    procedure NGR;
    procedure PushProcCall(ProcCall: TProcCall);
    procedure ReadSeg;
    procedure SBI;
    procedure SBR;
    procedure Setup; overload;
    procedure Setup( var SIZEA, SIZEB: WORD;
                     var NEWSP: WORD;
                     var SETA, SETB: WORD;
                     var CX: word); overload;
    procedure SIND;
    procedure SLDL;
    procedure SLDO;
    procedure SRO;
    procedure STB;
    procedure STKFAULT;
    procedure STL;
    procedure STO;
    procedure STP;
    procedure SYSRBOOT;
    procedure UJP;
    procedure XENABLE;
    procedure XQUIET;
    procedure STKCHK;
    procedure SaveIPC;
    procedure BLDFRM;
    procedure STKBACK;
    procedure XCHG(var W1, W2: word); overload;
    procedure XCHG(var B1, B2: byte); overload;
    procedure SCXG;
    procedure SLDC;
    procedure CXGIMMED;
    procedure NEWSEGMENT;
    procedure SEGBACK;
    procedure SEGFAULT;
    procedure CHGSIB;
    procedure UCLEAR;
    procedure CallIO;
    procedure GETU(var UNUM: byte; var UBLK: word);
    procedure CONDRVR;
    procedure STFRSLT;
    procedure ENABLE(TibAddr: word);
    procedure InitUnitTable;
    procedure CHDRVR;
    procedure UBREAK;
    procedure RSTDLE;
    procedure RES_JT;
    procedure XEQERROR(ErrCode: word);
    procedure XXEQERROR;
    procedure FaultCom;
    procedure SetupSW(ProcCall: OpsTables.TProcCall);
    procedure SIG;
    procedure DEQUE(var Queue{AX}, NewTib {BX}: word);
    function  ENQUE(Queue{AX}, TibAddr{BX}: Word): word;
    procedure LPR;
    procedure SAVEREG;
    procedure INCI;
    procedure DECI;
    procedure SCIP;
    procedure CPIIMMED;
    function  GetBigB(): word;
    function  GetBig(): word;
    function  GetAdr(OffSet: word): word;
    procedure SLLA;
    procedure CSTR;
    procedure RPU;
    procedure SETSTAMP;
    procedure SSTL;
    procedure CXG;
    procedure GetPool;
    procedure MOVSB(Src, Dst: longword; Len: word); overload;
    function  GetStAdr(): word;
  protected
    function GetMaxVolumeNr: integer; override;
    procedure SetSP(const Value: longword); override;
    function GetSP: longword; override;
    function GetOp: word; override;
    procedure SetOp(const Value: Word); override;
    procedure PutIOResult(value: integer); override;
  public
    (****************************************************************
          MEMORY WORDS USED TO STORE INTERNAL P-MACHINE VALUES.     *
    *****************************************************************)

    // LOCATIONS TO MAKE PERMANENT THINGS STORED IN REGISTERS

    // to hold less well known p-machine values

    IgnoreStackOverFlow : BOOLEAN; // STACK OVERFLOW OK IN BLKFRM & CPF
    MainMSCWP : word;              // pointer to MainMSCW
    SAVESTAT  : word;
    Globals   : TIVGlobalsPtr;

    fProcBase  : word;      // DEBUG <==== make it easier to see code offset within a proc
{$IfDef Debugging}
    CodePoolBase: longword;
{$EndIf}
    CS        : word;
    TaskSwitch: TProcCall;
    SyscomPtr : TSysComPtr;

    function InterpHIMEM: longword; override;
    function GetJTAB: word; override;
    function GetNextOpCode: byte; override;
    procedure Initialize_Interp;
    procedure Load_PSystem(UnitNr: word); override;
    procedure FinalException(Op: word; Msg: string);
    function  CurrentSegName: string; override;
    function SegNameFromBase(SegBase: longword): string; override;
{$IfDef debugging}
    function GetStaticLink(MSCWAddr: word): word; override;
    function GetLegalWatchTypes: TWatchTypesSet; override;
    function MemDumpDF(Addr: longword; Form: TWatchCode = 'W';         Param: longint = 0; const Note: string = ''): string; override;
    function MemDumpDW(Addr: longword; Code: TWatchType = wt_HexWords; Param: longint = 0; const Note: string = ''): string; override;
    function  DecodedRange( addr: longword;
                            nrBytes: word;
                            aBaseAddr: LongWord): string; override;
    function TOS: word;
{$EndIf}
    function  GetCurProc: word; override;
    function  PoolBase(PoolDescInfoAddr: word): longword;
    function  CalcProcBase(Addr: longword; ProcNumber: word): word; override;
    Constructor Create( aOwner: TComponent;
                        VolumesList   : TVolumesList;
                        thePSysWindow : TfrmPSysWindow;
                        Memo: TMemo;
                        TheVersionNr: TVersionNr;
                        TheBootParams: TBootParams); override;
    Destructor Destroy; override;
    function MSCWField(MSCWAddr: word; MSCWFieldNr: TMSCWFieldNr): word; override;
    function ProcName(MsProc: word; Segb: longword): string; override;
    function GetBaseAddress: longword; override;
    function GetByteFromMemory(p: longword): byte; override;
    function GetWordFromMemory(p: longword): word; override;
    function GetCPOffset: word; override;
    function GetSegmentBaseAddress: longword; override;
    procedure StatusProc(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true); override;
    function TheVersionName: string; override;

    CLASS function GetLEGAL_UNITS: TUnitsRange; override;

    property DSWord[P: longword]: word
             read GetDSWord
             write SetDSWord;

    property ESWord[p: longword]: word
             read GetESWord
             write SetESWord;

    property SP: longword
             read GetSP
             write SetSP;

    property AX    : Word
             read fAX.w
             write fAX.w;

    property AL    : byte
             read fAX.l
             write fAX.l;

    property AH    : byte
             read fAX.h
             write fAX.h;

    property BP    : word
             read fBP.w
//           write SetBP;
             write fBP.w;

    property C     : Byte
             read fBC.l
             write fBC.l;

    property B     : Byte
             read fBC.h
             write fBC.h;

    property LocalVar: LongWord
             read GetLocalVar
             write SetLocalVar;

    property BH    : Byte
             read fBX.h
             write fBX.h;

    property BL    : byte
             read fBX.l
             write fBX.l;

    property CX    : word
             read fCX.w
             write fCX.W;

    property CH    : byte
             read fCX.h
             write fCX.h;

    property CL    : byte
             read fCX.l
             write fCX.l;

    property DI    : word
             read fDI
             write SetDI;

    property DS : Longword
             read GetDS
             write SetDS;

    property E     : Byte
             read fDE.l
             write fDE.l;

    property D     : Byte
             read fDE.h
             write fDE.h;

    property DE    : Word
             read fDE.w
             write fDE.w;

    property GlobVar: longword
             read GetGlobVar
             write SetGlobVar;

    property ES : LongWord
             read fES
             write SetES;

    property SI: word
             read GetSI
             write SetSI;

    property MP: word
             read fMP
             write SetMP;

    property SSDSVAL   : WORD    // "THIS HAS TO BE LOCATED IN CS" -- SS & DS value
             read fSSDSVAL
             write SetSSDSVAL;     // This should go AWAY!

    property VersionNr;
end;

var
  LogON: boolean;

implementation

uses
  MyUtils, Forms, Types, BitOps,
{$IfDef debugging}
//pCodeDecoderUnit,
  pCodeDebugger_Decl,
  DebuggerSettingsUnit,
  DecodeToMemDumpUnit,
{$EndIf}
  Windows,
  Math, FilerSettingsUnit, pSysDatesAndTimes,
  pSysExceptions, pSysDrivers, CompilerSymbolsIV, pSys_Const, MiscinfoUnit;

CONST idnum = 46;
  HIMEM = ONEMB;

VAR
  BITTBL    : packed array[0..7] of byte = (1, 2, 4, 8, 16, 32, 64, 128);

  {Warning..the declaration order of CLRMSK and bitter must
   be one after the other as below}

  CLRMSK   : word ;
  bitter   : array[0..15] of word;  {element -1 contains CLRMSK}
  unbitter : array[0..15] of word;

{ NOTE: THE FOLLOWING STUFF SHOULD REALLY BE PART OF THE TPsystemInterpreter CLASS TO PERMIT
  MULTIPLE INSTANCES OF THE INTERPRETER TO BE CREATED BUT I DON'T THINK THAT THEY ARE EVEN BEING USED }
  NOEVENT  : boolean = true;            // if true event int are disabled
  BREAKP   : boolean = false;           // if true, breaks is in progress

  EVENTQIB: record
              QIBp: word;           //  POINTER TO QUEUE
              QIBSize: word;        //  QUEUE SIZE
              QIBOfsS: word;        //  QUEUE OFFSET TO STORE NEXT CHARACTER
              QIBOfsR: word;        //  QUEUE OFFSET TO RETRIEVE NEXT CHARACTER
              EVENTQUE: array[0..32-1] of byte; //
            end;

//       Event vector

EVENTVEC : array[0..MAXEVENT+1] of integer;  // Nils by default

//------------------------------------------------------------------------------
// STFRSLT
//       SET IORESULT AND EXIT RSP
// INPUT
//       AH = IORESULT
//       URTN = ADDRESS TO EXIT TO
// OUTPUT
//       SYSCOM.IORSLT = IORESULT
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.STFRSLT;
begin
  Untested('STFRSLT');   // probably bad because of the unmatched POPs

//with Globals.LowMem.SysCom do
  with SysComPtr^ do
    begin
//    iorslt := INOERROR;
      iorslt := TIORsltWD(fAX.H);
    end;
  SI := POP();
  GlobVar := POP();
//      URTN;                  // Always return to caller now
end;

// QLOAD
// WAS: ------------------------------------------------------------------------
//        RETRIEVE EVENT # FROM QUEUE
//  INPUT
//        BX = ^QIB
//  RETURNS
//        EVENT #
//        0 if Queue empty
// -----------------------------------------------------------------------------
(* is:
   QLOAD
          RETRIEVE EVENT # FROM QUEUE
   INPUT
          EVENTQIB
   RETURNS
          EVENT #
          0 if queue empty
*)
function TIVPsystemInterpreter.QLOAD: BYTE;
var
  tempLoadIndex: byte;
begin
  result := 0;
  with EVENTQIB do
    begin
      tempLoadIndex := QIBOfsR;
      if tempLoadIndex <> QIBOfsS then    // queue not empty
        begin
          Untested('QLOAD', false);
          result  := EVENTQUE[tempLoadIndex];  // 8. FETCH event from Queue
          tempLoadIndex := tempLoadIndex + 1;   // 9. bump load index
          if tempLoadIndex = QIBSIZE then
            tempLoadIndex := 0;           // 12. ZERO LOAD INDEX IF AT END OF QUEUE

          if tempLoadIndex = QIBOfsS then     // 13. LOAD INDEX = STORE INDEX ?
            QIBOfsS := 0;                     // 15. RESET STORE INDEX

          QIBOfsR := tempLoadIndex;           // 17. RESET LOAD INDEX
        end;
    end;
end;


// ------------------------------------------------------------------------------
//  SIG_EVENT
//        SIGNAL ALL EVENTS IN EVENT QUEUE
// ------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.SIG_EVENT;
begin
  AX := QLOAD();  //  get event # in al
  while AX <> 0 do
    begin
      DI      := AX;
      PUSH(DS);           // save DS since fast PME changes it !!
//    EVENTV;             // call current EVENT proc
      Unimplemented('EVENTV call');
      DS      := POP();
    end;
  NOEVENT := FALSE;       //  enable more events
end;

PROCEDURE TIVPsystemInterpreter.ENABLE(TibAddr: word);
begin
  IF BREAKP THEN          //  SEE IF BREAK IS IN PROGRESS
    BEGIN
      BREAKP := FALSE;
      USR_BREAK(TibAddr); //  let PME know about this
    END;

  SIG_EVENT;              //  signal all queued events
end;

//------------------------------------------------------------------------------
// BIOS
//       INVOKE BIOS ROUTINE
// INPUT
//       BX = OFFSET INTO BIOS JUMP VECTOR
// OUTPUT
//       NONE
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// RSTDLE
//       RESET BIT IN DLE FLAG INDICATED BY DLE MASK
// INPUT
//       BDLEMSK = DLE BIT MASK FOR CURRENT DEVICE
//       DLEFLAG = DLE FLAGS FOR ALL DEVICES
// OUTPUT
//       AL      = NOT BDLEMSK
//       DLEFLAG = NEW DLEFLAGS
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.RSTDLE;
begin
  fAX.l := BDLEMSK;        // ONLY ONE BIT IN MASK SET.
  fAX.L := NOT fAX.l;     // ALL BUT THAT BIT SET
  DLEFLG[SI] := DLEFLG[SI] AND fAX.l; // CLEAR THAT BIT IN FLAG.
end;



//------------------------------------------------------------------------------
// CHDRVR
//       MAIN DRIVER FOR CHARACTER ORIENTED DEVICES
// INPUT
//       AL   = DLE FLAG BIT #
//       ULEN = BYTE LENGTH
//       UBUF = BUFFER ADDRESS
//       UREQ = REQUEST
// OUTPUT
//       BDLEMASK = DLE BIT MASK
//       SI       = INDEX INTO FLAG BYTE ARRAY
//       DI       = BYTE LENGTH
//       BP       = BUFFER ADDRESS
//       AL       = REQUEST
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.CHDRVR;
var
  BX: word;
begin
  fAX.h := 0;
  SI      := AX;
  SI      := SI shr 3;    // index into flag bytes (why 3 single shifts above?)
  fAX.l   := fAX.L and $7;
  BX      := AX;
  fAX.L   := BITTBL[BX];
  BDLEMSK := AX;

  DI      := ULEN;
  BP      := UBUF;

  if (UREQ and OUTBIT) <> 0 then  // CHWRITE
    begin
      Unimplemented('CHWRITE');
    end else
  if (UREQ and INBIT) <> 0 then  // CHREAD
    begin
      Unimplemented('CHREAD');
    end else
  if (UREQ and STATBIT) <> 0 then // CHSTAT
    begin
      Unimplemented('CHSTAT');
    end
  else // CHCLR
    begin
      RSTDLE;                 // CLEAR DLE FLAG FOR THIS DEVICE
      ALFAFLAG[SI] := ALFAFLAG[SI] and fAX.L; // CLEAR ALPHALOCK FLAG FOR THIS DEVICE
      fAX.L        := BREQIN;
      if fAX.L = BCONIN then   // PASS POINTERS ONLY DURING CONSOLE INIT
        begin
          PUSH(0);             // POINTER TO SYSCOM (Is this still relevent? Is it correct?)
          PushProcCall(UBREAK);
          Unimplemented('CHDRVR: Need to push break handler');
        end;

      fCX.L := UNUM;
//          BIOS(AL);
      Unimplemented('BIOS');
      STFRSLT;
    end;
end;

//------------------------------------------------------------------------------
// CONDRVR
// PTRDRVR
// REMDRVR
//       DEVICE DRIVER ROUTINES FOR CONSOLE, PRINTER, AND REMOTE PORT
// INPUT
//       NONE
// OUTPUT
//       BREQRD = BIOS VECTOR OFFSET OF READ ROUTINE
//       BREQWR = BIOS VECTOR OFFSET OF WRITE ROUTINE
//       BREQIN = BIOS VECTOR OFFSET OF INITIALIZATION ROUTINE
//       BREQST = BIOS VECTOR OFFSET OF STATUS ROUTINE
//       AL     = BIT MASK FOR DLE
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.CONDRVR;
begin
  BREQRD := BCONRD;   // these are WORD offsets into the BIOS jump table
  BREQWR := BCONWR;
  BREQIN := BCONIN;
  BREQST := BCONST;
  fAX.L  := CONBIT;
  CHDRVR;
end;

procedure TIVPsystemInterpreter.PTRDRVR;
begin
  BREQRD := BPTRRD;
  BREQWR := BPTRWR;
  BREQIN := BPTRIN;
  BREQST := BPTRST;
  fAX.L  := PTRBIT;
  CHDRVR;
end;

// *****************************
//     E x e c  E r r o r s    *
// *****************************
// bummer, someone's blown it. BP has error number. SI restart Ipc
//procedure TIVPsystemInterpreter.XEQERROR(ErrCode: word);
procedure TIVPsystemInterpreter.XEQERROR;
begin
  SAVEIPC;
  BP := fErrCode;
  XXEQERROR;
end;

procedure TIVPsystemInterpreter.XXEQERROR;  // external entry point
 begin
  PUSH(BP);               // dummy parameter
  PUSH(BP);               // even dummer one
  IgnoreStackOverFlow := true;        // circumvent stack checking ("stack overflow is OK")
//      push parameters and call execerror in opsys
  PUSH(BP);               // push the error number
  PUSH(Globals.Lowmem.BASE);             // get addr of lex_0 activation record
                          //  as static link for call
  PUSH(Globals.MAINMSCW.MSENV); // ^ERec for segment 1 (assume that MSSEG and K_EREC refer to the same location)
//      DebugMessage('XXEQERROR: assume that MSSEG and K_EREC refer to the same location', true);
  PUSH(2);                // procedure number to call
  XCFP;                   // execute CPF seg-1, proc-2, global
end;

procedure TIVPsystemInterpreter.UBREAK;
begin
  RES_JT;                 // restore p-code jmp table
  SI := SI - 1;
  XEQERROR(UBREAKC);
end;

//*****************************************************************************
//   Function Name     : STKCHK
//   Useage            : STKCHK
//   Function Purpose  : Verify that there is enough stack space to add CX words
//   Assumptions       :
//   Parameters        : SP = current TOS
//                       AX = slop space in words
//                       CX = number of words required
//   Return Value      : AX = proposed new TOS
//*******************************************************************************}


Procedure TIVPsystemInterpreter.STKCHK;
var
  SaveBP: word;
Begin
  SaveBP  := BP;                // 1. preserve BP {see we're nice folks, really}
  bp      := cx;                // 2. save required words in case of fault
  bp      := bp + ax;           // 3. plus a little slop
  Globals.LowMem.EXTEND := bp;                // 4.
  bp      := Globals.Lowmem.CURTASK;           // 5. addr of current tib
  bp      := WordAt[bp+TIBLSPL];  // 6. BP := task's lower stack bound
  ax      := ax shl 1;          // 7. +safe space
  bp      := bp + ax;           // 8. in bytes
//ax      := 2;                 // 9. using 2 in this call so ignore them
  ax      := 0;                 // 9. not using any in this call
{$R-}                           //    ignore underflow
  ax      := ax - cx;           // 10. ax := -(number of words needed)
  ax      := ax shl 1;          // 11. now bytes
  ax      := ax + sp;           // 12. where sp would be if you got them
{$R+}
  StackOverFlow := bp > ax;     // 14. carry is set if splow>new_sp
  BP      := SaveBP;            // 15. restore BP
end;

// PROCEDURES USED BY PROCEDURE CALLS

// Name:      NEWSEGMENT
// Purpose:   Create new segment
// Entry:     BP = segment number
//            find the new ERec
// Returns:   BP = NewErec
//            IsSegFault if segment fault has occurred
procedure TIVPsystemInterpreter.NEWSEGMENT;
begin
  BP  := BP shl 1;        // [BYTEADR BP] byte displ of local name of seg
  BP  := Globals.Lowmem.EVECp + BP;      //   from local env vector gets ^newErec
  BP  := WordAt[BP];   // BP := ^new ERec

  ENVSAVE;
end;

// BP = ^ERec. Establish New Segment State: ERec, EVec, Seg...

// NOTE:  NEWENV, BLDFRM, CHGSIB, SETSTAMP assume DS = SS, ES = SEGB !!!!

procedure TIVPsystemInterpreter.ENVSAVE;
begin
  with Globals.Lowmem do
    OLDEREC := ERECp;

  NEWENV;
end;


// NAME:    NEWENV
// PURPOSE: Establish New Segment State: ERec, EVec, Seg...
// ENTRY:   Was assuming that DS <-- SS. No longer necessary
//          BP = ^ERec.
// RETURNS: IsSegFault
//          Globals = BasePlus register
//          Check for segment fault
// USES:    AX, BP AND DI, DX & Bases set

procedure TIVPsystemInterpreter.NEWENV;
var
  ER: TErecPtr;
  SibPtr: TSibPtr;
  ProcDictP, CPO: word;         // ^GlobalDataSegment}
  NewPoolBase: longword;
begin
  ER := TErecPtr(@Bytes[BP]);
  with Globals.LowMem, ER^ do
    begin
      ERECp    := BP;
      Base     := env_data;
      BasePlus := env_data + MSCWDISP;
      EvecP    := Env_Vect;
      SibP     := Env_Sib;
      GlobVar  := BasePlus;           // may be needed elsewhere
      SIBPtr   := TSibPtr(@Bytes[SibP]);
    end;
    
  IsSegFault := true;           // return with IsSegFault true and BP=^ERec
  if ER.Env_SIB <> pNIL then
    begin
      NewPoolBase := PoolBase(SIBPtr^.seg_pool);

      ES      := NewPoolBase + SIBPtr^.seg_base;          // Segment Base Register

      Globals.Lowmem.SEXFLAG  := ESWord[SEGSEX_];         // segment sex flag
      ProcDictP               := ESWord[SEGPROC_];        // word pointer to proc dict
      CPO                     := ESWord[SEGCONST_] shl 1;        // ConstPoolOffset - convert to byte offset
      with Globals.LowMem, TSeg_DictPtr(SIBPtr^.seg_base)^ do
        begin
          SegB      := ES;    // SIBPtr^.seg_base;
          SegTop    := ProcDictP SHL 1;
          CPOffset  := CPO;
        end;
      IsSegFault              := CPO = 0;          // set flag to indicate segment fault
      StackOverFlow           := false;
    end;
end;

// Name:     BLDFRM
// Function: build an activation record and mscw for a proc in current segment
// Parameters:  BP = proc # of frame being built
//              (TOS) StaticLink
// Returns:     MP = Local activation record
//              BX = MPPLUS
//              StackOverFlow if stack fault
// USES:        DI,AX,BP AND CX.
procedure TIVPsystemInterpreter.BLDFRM;
label
  99;
const
  PROCSLOP = 60;   // stack insurance for proc call
var
  temp: integer;

//*****************************************************************************
//   Function Name     : BLDFRM
//   Useage            : build an activation record and mscw for a proc in
//                       current segment ;called w/ proc_# in BP and static link
//                       on tos under return address
//   Function Purpose  : Build Stack Frame
//   Assumptions       : ES = SegB
//   Parameters        : BP = Procedure Number
//                     : MP = dynamic link
//                       (TOS) = static link
//   Return Value      : DI = address of first instruction in procedure
//                       BX = MPPLUS register
//*******************************************************************************}

begin { BldFrm}               //  No need to save return address to SAVERET in Delphi
  SAVESTAT := POP();          //  2. static link for new mscw
  SAVEPROC := BP;             //  3. Save new proc number
{$R-}
  BP       := BP SHL 1;       //  4.
  BP       := - BP;           //  5. BP := neg byte index from top of segment
  BP       := BP + Globals.Lowmem.SEGTOP;    //  6. (OK) ES:BP := ^procDictEntry for callee

  DI       := ESWord[BP];  //  7. (OK) DS:DI := ^word offset of proc.datasize
{$R+}
                              //     (OK) DI = word offset of Proc.datasize
  if DI = 0 then
    raise ENOPROC.Create('No Procedure. Segment does not exist');

  DI       := DI SHL 1;       // 11. DI = byte offset of Proc.DataSize

{$R-}
  temp     := ESWord[DI];  // 12. CX := desired activation record words
  cx       := temp;
{$R+}

  DI       := DI + 2;         // 13. move new ipc past datasize field
  if temp >= 0 then           // 14. if negative datasize then its native code
    begin
      AX := PROCSLOP;         // 16. parameter to STKCHK, fudge factor for stack check

      if not IgnoreStackOverFlow then     // 17. shall I enforce stack check?
        begin                 //     Yes. Enforce it.
          StkChk;
          if StackOverFlow then
            EXIT;
          // Or should it be:
//          raise Exception.Create('Stack overflow');  //     stack fault
        end
      else                    //     No. Don't enforce it.
        StkChk;               // 18. No. Call STKCHK to get new stack pointer
                              //     but ignore stack fault.
      SP            := AX;    // 22. set new stack pointer

      // build a new activation record on the stack (23-30)

      Push(Globals.Lowmem.CURPROC);          // 23. mscw.proc
//    AX            := SAVEPROC; // 24. and p-mach reg
      Globals.Lowmem.CURPROC := SAVEPROC;    // 25. update p-mach proc_no reg
      PUSH(Globals.Lowmem.ERECp);            // 26. mscw.env
      PUSH(SI);               // 27. mscw.ipc
      SI            := DI;    //
{$IfDef debugging}
      ProcBase      := DI;    // DEBUG <==== save the starting IPC of the procedure
                              // to make it easier to see code offset within a proc
{$EndIf}
      PUSH(MP);               // 29. mscw.dyn
      PUSH(SAVESTAT);         // 30. mscw.static
      LocalVar      := SP;    // 31. right now, SP points to the newly created MSCW (activation record)
      MP            := LocalVar;    // 32. MP (activation record)

      LocalVar      := LocalVar + MSCWDISP;
                              // 33. BX = MpPlus p-machine reg.
      StackOverFlow := FALSE; //     carry is reset per 8086 usage
      Globals.Lowmem.MPPLUS := LocalVar;    // 34. Save BX to MPPLUS
    end
  else
    Unimplemented(Format('p-code calling native code at DS:DI (%4.4x:%4.4x)', [DS, DI]));
end;   { BldFrm }

// NOTE:  NEWENV, BLDFRM, CHGSIB, SETSTAMP assume DS = SS, ES = SEGB !!!!

procedure TIVPsystemInterpreter.CHGSIB;
begin
  BP      := MP;          // in new stack marker
  DI      := Globals.Lowmem.OLDEREC;     //   DI := ^oldERec
  WordAt[BP+MSCWDISP-MSENV] := DI; // fix up mscw.env
  BP      := WordAt[DI+ENVSIB];     // BP := ^oldSib
  SETSTAMP;               // set new time stamp
  BP      := Globals.Lowmem.SIBP;         // in new segment
  WordAt[BP+SIBREFS] := WordAt[BP+SIBREFS] + 1; //   increment newSib.usageCount
end;

// Name:     SETSTAMP
// Function: increments syscom time stamp value
//           sets time stamp into sib activity field
// assumes BP = ^sib, uses AX

// NOTE:  NEWENV, BLDFRM, CHGSIB, SETSTAMP assume DS = SS, ES = SEGB !!!!

procedure TIVPsystemInterpreter.SETSTAMP;
var
  SibPtr: TSibPtr;
begin
{$R-}
  SibPtr := TSibPtr(@Bytes[BP]);
  with SysComPtr^ do
    begin
      try
        timestamp := timestamp + 1;
      except
        on ERangeError do
          timestamp := 0;
      end;
      SibPtr^.timestamp := timestamp;
    end;
{$R+}
end;
                                                           
// NAME:      RPU
//            150 {$0096}
// Function:  Return from Procedure. Restore state of calling procedure from MSCW
//            and discard. Pop MSCW from Stack.
//            Cut back an additional B words from Stack, leaving function value,
//            if appropriate.
//            If returning to different segment (Mark Stack E_Rec <> current E_Rec)
//            then issue a segment fault if necessary.
//            If procedure number in MSCW is < 0, return to EXITIC of procedure,
//            not MSCW's IPC.
procedure TIVPsystemInterpreter.RPU;
VAR
  LCL_SAVEPAR: WORD;
begin
  SaveIPC;                // in case of segment fault
  AX      := GetBigB();    // bytes to cut off stack
  ES      := DS;          // ES = DS = SEGB
  SAVEPAR := AX;          // save bytes to cut for later

  LCL_SAVEPAR := AX;      // DEBUG

  BP      := MP;          // addr of returning mscw
  BP      := WordAt[BP+MSCWDISP-MSENV]; // BP := rpu_mscw.env=caller's_env
  DI      := Globals.Lowmem.ERECp;        //DI := rpu.env
  if BP <> DI then        // different environment
    begin
      Globals.Lowmem.OLDEREC := DI;      //{90} save old environment
//XRPU    // Entry point from NATRPU
      NEWENV;             //{91} establish caller's erec and check
      if IsSegFault then      // DS is the OLD environment, ES is the NEW environment
        raise ESEGBACK.Create('Segment fault');

      DI      := Globals.Lowmem.OLDEREC;     //{93} restore ^returning_env
      with TErecPtr(@Bytes[DI])^ do
        begin
          BP := Env_SIB;
          with TSibPtr(@Bytes[BP])^ do
            Seg_Refs := Seg_Refs - 1;
        end;
//          BP      := WordAt[DI+ENVSIB]; //{94}
      SETSTAMP;               //{95} set rpu_sib.activity
//          WordAt[BP+SIBREFS] := WordAt[BP+SIBREFS] - 1; //{96} decrement rpu_sib.refCount
    end;
//SAMEENV
  AX       := MP;          //{97} reset to word under old MSCW
  AX       := AX - 2;      //{98}
  SP       := AX;          //{99} prune SP
  DI       := POP();       //{100} pickup possible NAT return IP
              POP();       //{101} discard rpu_mscw.staticLink
  LocalVar := POP();       //{102} newMp := rpu_mscw.dynamicLink
  MP       := LocalVar;          //{103} p-machine MP
  LocalVar := LocalVar + MSCWDISP;//{104}  and fast ar base reg
  Globals.Lowmem.MPPLUS  := LocalVar;          //{105}
  SI       := POP();       //{106} p-machine Ipc
  AX       := POP();       //{107} caller's environment already handled
  BP       := POP();       //{108} caller's procedure number
  Assert(SAVEPAR = LCL_SAVEPAR, ' SYSTEM ERROR');  // Check "bytes to cut"
  try               // DEBUGGING
    SP       := SP + SAVEPAR; //{109} discard returning proc's activation rec
  except
    on e:Exception do
      AlertFmt('Exception (%s): SP = $%4.4X, SAVEPAR: $%4.4X, SP+SAVEPAR: $%4.4X',
               [e.message, SP, SAVEPAR, SP+SAVEPAR]);
  end;
{$R-}
  Globals.Lowmem.CURPROC := BP;           //{110}
{$R+}
  if Globals.LowMem.CURPROC >= 0 then    // {111,112} if proc # >= 0
    begin
{$IfDef Debugging}
      with Globals.LowMem do
        ProcBase := CalcProcBase(SEGb, CURPROC);   // <======= DEBUG =====
{$endIf}
      if SI = 0 then      //{113,114} THEN Native return flag
        begin
          Untested('Native return flag');
          PUSH(ES);       //{134} new CS
          PUSH(DI);       //{135} new IP
          BP := LocalVar;       //{136} set BP to MPPLUS
          DI := GlobVar;  //{137} set DI to BASEPLUS
        end
      else                //{112} Procedure number negative
        DS := ES;       //{115} no: DS = ES = SEGB
    end
  else
    begin
      // Move to exitic if not already in termination code
      with Globals.Lowmem do
        CURPROC := - CURPROC;   //{117} make proc number positive
{$R-}
      BP      := BP + BP;     //{118} negative proc number times 2
      BP      := BP + Globals.Lowmem.SEGTOP; //{119} ^proc dictionary entry
{$R+}
      BP       := ESWord[BP];  //{120} proc dictionary entry = ^datasize

{$IfDef Debugging}
      ProcBase := (BP * 2) + 2;     // pointer to first instruction
{$EndIf}
      DEC(fBP.w);             //{121} ^exitic
      BP      := BP + BP;     //{122} convert to byte offset?
      AX      := ESWord[BP];  //{123} pick up exitic
      if SI <> 0 then         //{124,125}
        begin
          if SI < AX then     // IF IPC >= exitic THEN keep current IPC
            SI := AX;         // ELSE Get exitic in SI
          DS := ES;           //DS = ES = SEGB
        end
      else                    // SI = 0
        begin
          Untested('RPU: IPC = 0');
          if DI < AX then     //{132} NATIPC >= exitic ?
            begin             //{133}  no: reset to exit
              SI := AX;       //{128} get exitic in SI
{ $20}        AX := ES;       //{129} DS = ES = SEGB
              DS := AX;       //{130}
            end;
//  $40     //return to native code
{40:}     PUSH(ES);           //new CS
          PUSH(DI);           //new IP
          BP  := LocalVar;          //set BP to MPPLUS
          DI  := GlobVar;     //set DI to BASEPLUS
        end;
    end;
end;

// Name:    CLP - Call Local Procedure. Call procedure UB,
//                which is an immediate child of the currently executing
//                procedure and in the same segment.
// return:  Static link of the new MSCW is set to old MP.
Procedure TIVPsystemInterpreter.CPL; // Call Procedure Local
Begin
  SaveIPC;                // in case of segfault
  BP      := Bytes[DS+SI];  // BP := called_procedure_#
  SI      := SI + 1;
  ES      := DS;          // ES = DS = SEGB
  Globals.Lowmem.OLDEREC := pNIL;        // for BLDFRM
  PUSH(MP);               // static link for new frame
  BLDFRM;                 // build the stack frame
  Assert(DS=ES);
  if StackOverFlow then
    STKBACK;              // if there's not enough room
end;

procedure TIVPsystemInterpreter.CPG;
begin
  SAVEIPC;                // in case of segfault
  BP := Bytes[DS+SI];     // BP := called_procedure_#
  SI := SI + 1;
  ES := DS;
  Globals.Lowmem.OLDEREC := pNIL;        // for buildframe
  PUSH(Globals.Lowmem.BASE);             // static link for new frame
  BLDFRM;                 // build the stack frame

  Assert(DS=ES);

//DS := ES;          //  DS = ES = SEGB

  if StackOverFlow then
    STKBACK;              // if there's not enough room
end;

// Call Intermediate Procedure: $92 (146)
// Call procedure UB, which is at lex level DB
// less than the currently executing procedure and in the same segment.
// Use that activation record's static link as the static link of the new MSCW
procedure TIVPsystemInterpreter.CPI;
begin
   SAVEIPC;                // in case of segfault
   CX      := Bytes[DS+SI];
   SI      := SI + 1;
   CPIImmed;
end;

// Call Local External Procedure: $93 (147)
// Call procedure UB_2, which is an immediate
// child of the currently executing procedure and in the segment UB 1.
procedure TIVPsystemInterpreter.CXL;
begin
  SAVEIPC;                // in case of fault
  BP := Bytes[DS+SI];// local name of target segment (BP points to Segment Base Info)
  SI := SI + 1;
{$R-}
  AX := CBW(Bytes[DS+SI]);  // (LODSB) get byte and convert to word (sign extend AL)
                          // get procedure number
{$R+}
  SI := SI + 1;

  ES      := DS;          //  ES = DS = SEGB
  SAVEPAR := AL;          // and remember it
  NEWSEGMENT;             // save old and establish new environment
  if IsSegFault then
    raise ESEGBACK.Create('Segment fault in CXL');              // possible segment fault
  PUSH(MP);               // static link of new mscw
  AL      := SAVEPAR;     // procedure number
  AH      := 0;
  XCHG(fAX.w,fBP.w);           //
  BLDFRM;                 // build the stack frame for the callee
  if StackOverFlow THEN
    raise ESSTKBACK.Create('Stack fault in CXL');             //   if there's not enough room
  CHGSIB;                 // patch it up for cross segment call
  DS      := ES;          //  DS = ES = SEGB
end;



// SCIP (239, 240) or ($EF, $F0)
// Short Call Intermediate Procedure. Set the static chain to point to the lexical
// parent (CPI1) or grandparent (CPI2) of the calling environment.
// Call procedure UB.
procedure TIVPsystemInterpreter.SCIP;
begin
  SAVEIPC;
  CX := fOp - 238;  // SCIP1 OR SCIP2
  CPIIMMED;
end;

{*************** PROCEDURE CALLING AND RETURNING *************}

// CPIIMMED
//         Input: AX = called procedure number
//                CX = Lexical levels change
//
procedure TIVPsystemInterpreter.CPIIMMED;
begin { TIVPsystemInterpreter.CPIIMMED }
  AH      := 0;          // 1. AX := called_procedure_#
  AL      := Bytes[DS+SI]; // 2.
  SI      := SI + 1;     // 2.
  ES      := DS;         // 3, 4. ES = DS = SEGB
  Globals.Lowmem.OLDEREC := pNIL;       // 7. for BLDFRM
  BP      := MP;         // 8. BP := ^callers_mcsw
  if CX <> 0 then        // 9. check for delta_lex being zero right off
    repeat
      BP := WordAt[BP];  // 10. traverse static chain for CX mscws
      CX := CX - 1;
    until CX = 0;        // 11.
  PUSH(BP);              // 12. static link for new mscw
  XCHG(fAX.w, fBP.w);    // 13. after: BP = ProcNum, AX = static frame
  BLDFRM;                // 14. build the stack frame
  Assert(DS=ES);
  if StackOverFlow then
    raise ESTKBACK.Create('Stack fault in CPIIMMED');             // 17. if there's not enough room
end;  { TIVPsystemInterpreter.CPIIMMED }

// Name   : PoolBase
// input  : BP = ^TPoolDescInfo
// result : base of pool
// uses   : AX, BP
function TIVPsystemInterpreter.PoolBase(PoolDescInfoAddr: word): longword;
begin
  if (PoolDescInfoAddr <> 0) and PoolOutside then         // if pointer is not nil
    begin
//    result := WordAt[BP+2];   // poolbase 16 LSW
//    BP     := WordAt[BP];     // poolbase 16 MSW
      with TPoolDescInfoPtr(@Bytes[PoolDescInfoAddr])^ do
        result := FullAddressToLongWord(PoolBaseAddr);
    end
  else
    result := 0;
end;

//------------------------------------------------------------------------------
// SYSRBOOT
//       UNIT I/O FROM BOOTSTRAP
// INPUT

//       TOS    = RETURN ADDRESS IN BOOT (obsolete)

//       TOS+0  = BLOCK #
//       TOS+2  = LENGTH
//       TOS+4  = BYTE OFFSET
//       TOS+8  = WORD BASE
//       TOS+10 = UNIT NUMBER
// OUTPUT
//       Globals.LowMem.IOResult    (* was: AX     = IOResult *)
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.SYSRBOOT;
begin
  PUSH(0);              // This is the control word
  AL      := INBIT;
  ESVal   := ES;
  SYSIO;
end;

//  Name:     ReadSeg
//  Entry:    (TOS) = ^EREC
//            (TOS+2) = function return space
procedure TIVPsystemInterpreter.ReadSeg;
const
  ERRMSG = 'System error in ReadSeg';
var
  ERECAddr: word;
begin { TIVPsystemInterpreter.ReadSeg }
  SaveIPC;                 // 1.
  ERECAddr := POP();       // 2. ^erec
  AX       := POP();       // 3. function return space (is this needed in Delphi? Yes.)
  with TErecPtr(@Bytes[ERECAddr])^ do
    with TSibPtr(@Bytes[ENV_SIB])^ do
      begin
        with TVInfoPtr(@Bytes[vol_Info])^ do
          PUSH(SegUnit);
        PUSH(Seg_Base);       // 10. offset in pool
        PUSH(0);              // 12. byte offset from load address
        PUSH(Seg_Leng shl 1); // 15. number of bytes in segment
        PUSH(Seg_Addr);       // 16. starting block # of segment
        ES := PoolBase(Seg_Pool); // 17. ^pooldesc, 19. point ES at base of code pool
      end;
  SYSRBOOT;               // 21. RSP disk read routine
//Push(word(Globals.LowMem.SysCom.iorslt)); // 24. leave ioresult on stack
  Push(word(SysComPtr^.iorslt)); // 24. leave ioresult on stack

(*  This may be unnecessary: *)
  LocalVar := Globals.Lowmem.MPPLUS;   // <============= DEBUGGING ===============<
  DS       := Globals.Lowmem.SEGB;
  SI       := Globals.Lowmem.IPCSav;
(*
  Assert(LocalVar = Globals.Lowmem.MPPLUS,   ERRMSG);  // just checking (skip save/restores)
  Assert(DS = Globals.Lowmem.SEGB,     ERRMSG);
  Assert(SI = Globals.Lowmem.IPCSav,   ERRMSG);
*)
end;  { TIVPsystemInterpreter.ReadSeg }

// Name:     CXI 149 ($95)
// Function: Call Intermediate External Procedure.
//           Call procedure UB_2 which is at lex level DB less than the currently
//           executing procedure, and in the segment UB 1.

procedure TIVPsystemInterpreter.CXI;
begin
        SAVEIPC;                // in case of fault
        BP      := Bytes[DS+SI];     // [BYTETOBP] Local Segment Number
        SI      := SI + 1;
        AX      := LODUW;       // AL=delta_lex, AH=proc_number
        ES      := DS;          //  ES = DS = SEGB
        SAVEPAR := AX;          //   saved
        NEWSEGMENT;             // establish new environment
        if IsSegFault then        // 20.
          raise ESEGBACK.Create('Segment fault in CXI'); // 20. OOPS, Segment fault (this should then try to load the segment!)
        BP      := MP;          // starting at current marker
        CH      := 0;           // for delta_lex levels
        CL      := SAVEPAR and $FF;    // only want the low byte
        while CL > 0 DO
          begin
            BP := WordAt[BP];       // follow up static chain
            CL := CL - 1;
          end;
        PUSH(BP);               // found mscw will become new_mscw.static
        AH       := 0;          // procedure number
        AL      := SAVEPAR shr 8;  // we only want the HIGH byte from SAVEPAR
        XCHG(fAX.w, fBP.w);     //  BP = proc #
        BLDFRM;                 // build the new stack frame
        if StackOverFlow then     //
          raise ESSTKBACK.Create('Stack fault in CXI'); // 26. OOPS, stack fault
        CHGSIB;                 // fix up the new mscw from cross segment call
        DS      := ES;          //  DS = ES = SEGB
end;

// Call procedure formal

procedure TIVPsystemInterpreter.CFP;
begin
  SAVEIPC;
  XCFP;
end;

// Entry point from XEQERROR
procedure TIVPsystemInterpreter.XCFP;
begin
  CX      := POP();       // procedure number
  BP      := POP();       // ^ERec
  ES      := DS;          //  ES = DS = SEGB
  ENVSAVE;                // establish new environment
  if not IsSegFault then          // no fault
    begin
      BP      := CX;          // procedure number
      if not IgnoreStackOverFlow then    // should we enforce stack check
        begin                 // yes
        // shouldn't the static link get pushed here?
          BLDFRM;             // using static link on stk from p-code
          if StackOverFlow then
            begin                 //   possibly causing stack to bump into...
              PUSH(SAVESTAT);
              PUSH(Globals.Lowmem.ERECP);
              PUSH(SAVEPROC);
              raise ESTKBACK.Create('Stack fault in XCFP');
            end;
        end
      else
        begin
          IgnoreStackOverFlow := false;   // no, clear the flag
          BLDFRM;         //     and don't check carry
        end;
//    PUSH(Globals.LowMem.NIPSAVE);       // save NAT return under MSCW in case
      PUSH(0);            // NO NAT code stuff implemented
      CHGSIB;             // touch up mscw for cross segment call
      DS := ES;
    end
  else
    begin
      StackOverFlow := false; // segment fault in CPF
      SAVEPROC := CX;
      PUSH(Globals.Lowmem.ERECp);            // return ^Env to tos
      PUSH(SAVEPROC);        // return proc_number to tos
      raise ESSTKBACK.Create('Segment fault in XCFP');
    end;
end;

// LOAD STATIC LINK ONTO STACK

procedure TIVPsystemInterpreter.LSL;
begin
  Untested('LSL - load static link');
  BP      := SP;          // BP:=CURRENT MP
  CH      := 0;           // GETCOUNT (assume > 0)
  CL      := Bytes[DS+SI];
  SI      := SI + 1;
  while CX <> 0 do
    begin
      BP      := WordAt[BP]; // LOOP UNTIL GET CORRECT STATIC LINK
      CX      := CX - 1;
    end;
  PUSH(BP);               // PUSH THE REQUESTED STATIC LINK
end;

// BPT - BreakPoint: $9E (158)
procedure TIVPsystemInterpreter.BPT;
begin
  Unimplemented('BPT');
end;




//*****************************************************************************
//   Function Name     : SCXG ($70)
//   Useage            :
//   Function Purpose  : Short Call External Global Procedure.
//                       The segment number is indicated by the opcode (1-8)
//                       and UB is the procedure number.
//   Note              : SCXGl may refer to a procedure embedded in the
//                       Interpreter. If this is the case, an Interpreter
//                       table contains the procedure's location.
//   Parameters        : fOp = Procedure Number to call
//                       The Opcode (A) indicates the segment number
//   Return Value      :
//*******************************************************************************}

procedure TIVPsystemInterpreter.SCXG;
begin
  SAVEIPC;
                        // SHR     DI,1       // is not here because FETCH no longer does SHL DI,1
  BP      := fOp - $6F;  // SCXG1 is $6F ==> get internal proc #
  CXGIMMED;
end;

procedure TIVPsystemInterpreter.FLIPSEG;
var
  PEREC, PSIB: WORD;
begin
  CX      := Pop();       // number of words
  DI      := Pop();       // word offset
  PEREC   := Pop();       // ^erec

  // set up addressing

  PSIB    := WordAt[PEREC+ENVSIB];  // ^sib
  DI      := DI SHL 1;    // words to bytes
  DI      := DI + WordAt[PSIB+SIBBASE]; // add pool offset to segment offset
  BP      := WordAt[PSIB+SIBPOOL];      // ^pool desc
  ES      := PoolBase(BP);

  // do flipping

  repeat
    AX := ESWord[DI];  // get a word
    XCHG(fAX.h, fAX.l);   // flip it
    ESWord[DI] := AX;  // write it back
    DI := DI + 2;
    CX := CX - 1;
  until CX = 0;

  Assert(DS = Globals.LowMem.SEGB);
//      DS := Globals.LowMem.SEGB; // restore DS = SEGB
end;

{$R-}       // Disable range checking on common p-system "memory" references
            // to improve interpreted speed.

// RETURN: operand as byte offset
function TIVPsystemInterpreter.GetBigB(): word;
begin
  result := GetBig() shl 1;
end;

// RETURN: operand as word offset
function TIVPsystemInterpreter.GetBig(): word;
begin
  AX := CBW(Bytes[DS+SI]);  // get byte and convert to word (sign extend AL)
  SI := SI + 1;
  if (AL and $80) <> 0 then   // if sign bit is set
    begin
      AL  := AL and $7f;
      AH  := AL;
      AL  := Bytes[DS+SI];
      SI  := SI + 1;
    end;
  result := AX;
end;

// returns ADDRESS (IN THE ACTIVATION RECORD YOU WANTED)
// Entry:   CX = number of links to traverse
function TIVPsystemInterpreter.GETSTA1(): word;
begin
  BP := LocalVar - MSSTAT;     // GET POINTER TO STAT LINK
  while cx <> 0 do
    begin
      BP := WordAt[BP];     // BP GETS POINTER TO NEXT STATIC MP
      CX := CX - 1;            // DEC CX
    end;                       // AND DO AGAIN IF CX>0
  AX := GetBigB();             // get the byte offset
  BP := BP + AX;
  result := BP + MSCWDISP;     // ADD 8 SO PARAM,VAR,ETC OFFSETS ARE CORRECT
end;

function TIVPsystemInterpreter.GetDSWord(P: longword): word;
begin
  result := Words[(DS + p) shr 1];
end;

function TIVPsystemInterpreter.GetESWord(p: longword): word;
begin
  result := Words[(ES + p) shr 1];
end;

procedure TIVPsystemInterpreter.SetDSWord(P: longword; const Value: word);
begin
  Words[(DS + p) shr 1] := Value;
end;

procedure TIVPsystemInterpreter.SetESWord(p: longword; const Value: word);
begin
  Words[(ES + p) shr 1] := Value;
end;

// IND: 230 ($E6)
// Index and Load Word. TOS is the address of a record. Replace it with
// the B'th word in the record.
procedure TIVPsystemInterpreter.IND;
begin
  AX      := GetBigB();    // Get byte index.
  DI      := POP();       // Word pointer
  BP      := AX;
  PUSH(WordAt[BP+DI]);    //  Push word pointed to.
end;

// STO: 196 ($c4)
// Store Indirect. Store TOS into the word pointed to by TOS-1.
Procedure TIVPsystemInterpreter.STO;  {store indirect}
Begin
  AX := Pop();   {value}
  BP := Pop();   {address}

  WordAt[BP] := AX;
end;
{$R+}

procedure TIVPsystemInterpreter.SaveIPC;
begin
  Globals.Lowmem.IPCSav := SI;
{$IfDef debugging}
  ProcBaseSave := ProcBase;
{$EndIf}
end;


Procedure TIVPsystemInterpreter.GetSavedIPC;
Begin
  SI := Globals.Lowmem.IPCSav;
{$IfDef debugging}
  ProcBase := ProcBaseSave;
{$EndIf}
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

//    If token in reswrdtable then
//        set sy and op from table,
//    else
//        set sy := 0.

//    symcur is left pointing to the last char of the token
//

procedure TIVPsystemInterpreter.IDSEARCH;
var
  SymBufp    : word;
  RetnInfoP  : word;
  SymCursor  : word;
  c          : char;
  Key        : TAlpha;
  i          : word;
  Idx        : integer;
  sy         : TSYMBOLtypeIV;
  su         : TSymbolUnion;
  op         : TOperator;
  id         : string;
  p          : TRetnInfoPtr;
begin { TIVPsystemInterpreter.IDSEARCH }
  i         := 0;
  Key       := '        ';  // adapted from Dr Laurence Boshell's version
  SymBufP   := POP();    // address of SymBufP
  RetnInfoP := POP();    // address of SymCursor
  p         := TRetnInfoPtr(@Bytes[RetnInfoP]);

  SymCursor := WordAt[RetnInfoP];
  c         := chr(Bytes[SymBufP+SymCursor]);
  while (c in['A'..'Z','a'..'z','0'..'9','_'])do
    begin
      If c <> '_' then   {ignore '_' for full UCSD compatibility   /tp3}
        begin
          if (i < High(Alpha)) then
            key[i] := upcase(c);
          i := i + 1;
        end;

      symcursor := symcursor+1; {do not use   bumpcursor(1);} {/tp4}

      c := chr(Bytes^[symbufp+symcursor]);
    end;

  {ucsd requires that symcursor points to last char of identifier}
  symcursor := symcursor-1;

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
  P.SYMCUR := SymCursor;
  P.SY     := sy;
  P.OP     := Op;
  P.RETTOK := Key;
end; { TIVPsystemInterpreter.IDSEARCH }

// Name:    DoTreeSearch
//          TreeSearch(rootp:^node; VAR foundp:^node; VAR target:alfa):integer;
// Returns: 0:  FoundP points to matching node
//          +1: FoundP points to a leaf, target > foundp.key
//          -1: FoundP points to a leaf, target < foundp.key
  procedure TIVPsystemInterpreter.TREESRCH;
  var
    KeyValueAddr  : word;
    FoundP        : word;                // does not change
    RootAddr      : word;
    Node          : word;
    KeyValue      : TAlpha;
  begin
    KeyValueAddr    := POP();  // ptr to target.
    FoundP          := POP();  // save address for result
    RootAddr        := POP();  // rootp
    KeyValue        := TAlpha_Ptr(@Bytes[KeyValueAddr])^;
  {$R-}
    WordAt[SP]      := TreeSearch(RootAddr, node, KeyValue);;
  {$R+}
    WordAt[FoundP]  := node;
  end;

  Function TIVPsystemInterpreter.TreeSearch(root: word; var node: word; const key: TAlpha): integer;
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
          result := 1;
        end
      else
        begin
          result := 0;
          exit;
        end;
    until node = pNil;
    node := last;
  end;

//------------------------------------------------------------------------------
// IOR
//       STANDARD FUNCTION IORESULT
// INPUT
//       DI = ADDRESS OF FETCH
// OUTPUT
//       TOS = SYSCOM.IORSLT
//------------------------------------------------------------------------------

Procedure TIVPsystemInterpreter.IOR;  {IO result - return IORSLT}
Begin
  Pop();                               // JUNK FUNCTION RETURN SPACE
//PUSH(Integer(Globals.Lowmem.Syscom.iorslt));
//Globals.Lowmem.Syscom.iorslt := INOERROR;   // clear it after accessed
  PUSH(Integer(SyscomPtr^.iorslt));
  SyscomPtr^.iorslt := INOERROR;   // clear it after accessed
end;

//  Name:      ParmDscr
//  Entry:     ^parmDscr on tos
//  returns:   Src  = ^source_base  (was DS),
//             SrcO = source_offset (was SI)
//             Dst  = ^dest_base,   (was ES)
//             DstO = dest_offset   (was DI)
//  uses:      BP, AX, DI; may seg_fault! please IpcSave before calling
(*
  To copy value parameters of type string or packed array of char into the
  activation record of a called routine, the calling routine generates a "parameter
  descriptor." This descriptor is a 2-word record. The first (low address) word is
  either NIL, or a painter to an E_Rec. If the first word is NIL, the second word is
  the address of the parameter. If the first word points to an E_Rec, the second
  word is an offset relative to the designated segment (the offset is generated by an
  LCO instruction).
*)

procedure TIVPsystemInterpreter.ParmDscr(var Src, Dst: longword; var SrcO, DstO: word);
// I was getting crazy results when I tried to define TParmDescPtr here?
var
  ErecAddr, SibAddr, SegAddr: word;
  ParmDescrAddr: word;
  p : TParmDescPtr;
begin { ParmDscr }
  ParmDescrAddr := POP();         //  2. ParmDescrP = ^parm dscr (BP)
  DstO          := Pop();
  P             := TParmDescPtr(@Bytes[ParmDescrAddr]);
  SrcO          := p^.Parm_Addr;
  ErecAddr      := p^.Erec_Addr;
  if ErecAddr <> pNIL then      // 10. then ErecP points to ERec
    with TErecPtr(@Bytes[ErecAddr])^ do
      begin
        SibAddr  := Env_SIB;  // 10. else BP := ^Sib
        with TSibPtr(@Bytes[SibAddr])^ do
          begin
            SegAddr  := Seg_Base; // 11. AX := ^segment
            if SegAddr <> pNIL then   // 12. If segment present
              begin
                Src := PoolBase(Seg_Pool) + SegAddr;
                Dst := 0;
              end
            else  // segment fault
              begin
                PUSH(ParmDescrAddr);      // 26. restore Tos to ^parmDscr
                BP      := ErecAddr;
                GetSavedIPC;              // 27. restore Ipc to before IFetch
                SI      := SI - 1;        // 28.    of the opcode

                raise ESEGFAULT.Create('SEGFAULT');  // 27. and fault w/ BP = ^ERec
              end;
          end;
      end
  else
    begin
      Src      := 0;          // 28. DS is already a good source base
      Dst      := 0;          // 29. ES := dest_base
    end;
end;   { ParmDscr }

//  Copy Array Parameter
//  copy B words at Tos^.ParmDscr^ to (Tos-1)^
procedure TIVPsystemInterpreter.CAP;
var
  Src, Dst: longword;
  Len, SrcO, DstO: word;
begin
  SAVEIPC;                //  1. in case of segment fault
  Len := GetBigB();   //  2. number of bytes to copy

  ParmDscr(Src, Dst, SrcO, DstO);               //  4. set up source and dest, may seg_fault
  if Integer(Len) > 0 then
    MOVE(Bytes[Src+SrcO], Bytes[Dst+DstO], Len);  // 5.

  Assert(DS = Globals.LowMem.SegB);
//      DS := Globals.Lowmem.SEGB;  //  restore segment base
  GetSavedIPC;                     //  7. ipc before operand

  if Bytes[DS+SI] and $80 <> 0 then // 9.
    SI := SI + 1;         //  10. yes, extra increment of ipc

  SI := SI + 1;           //  11. bump ipc past operand
end;

// CSP: (172 or $AC)
// Copy String Parameter.
//
// TOS is the address of the parameter descriptor for a string.
// Cause a segment fault if the descriptor designates a non-resident
// segment. Otherwise, compare the dynamic length of the designated string
// to UB, the declared size (in bytes) of the destination formal parameter.
//
// Cause a string overflow fault if the length of the source is greater than
// the capacity of the destination. Otherwise, copy, for the length of the
// source, into the destination, whose address is in TOS-1.
procedure TIVPsystemInterpreter.CSP;
var
  Src, Dst: longword;
  SrcO, DstO: word;
  SrcLen, Len, MaxLen: integer;
begin
  SaveIPC;                // 1. watch out for faulty segments

  MaxLen := Bytes[ds+SI];  // 2. maximum length (CH)

  ParmDscr(Src, Dst, SrcO, DstO); // 3. set up source and dest;
                          //  returns: Src = ^source_base, SrcO = source_offset
                          //           Dst = ^dest_base,   DstO = dest_offset

  SrcLen := Bytes[Src+SrcO];  // 4. source length (CL)

  if MaxLen >= SrcLen then        //
    begin
      Len := SrcLen + 1;       // 8. copy length byte too
      if Len > 0 then
        Move(Bytes[Src+SrcO], Bytes[Dst+DstO], Len); // 9. the move

      Assert(DS=Globals.LowMem.Segb);

      SI := SI + 1;       // 12. then fixed up
    end
  else                    // 5. then fault
    begin
      PUSH(DstO);         // 14. restore tos: ^dest (PUSH DI)
      PUSH(SAVEPAR);      // 15. and ^parmDscr

      DS := Globals.Lowmem.SegB;         // 16. segment base

      Assert(SI=Globals.Lowmem.IPCSav);

      GetSavedIPC;        // 17. ipc before operand fetch
      SI := SI + 1;       // 18. then fixed up

//    raise EXEQERR.Create('String too long: CH=%d, CL=%d', [CH, CL], S2LONGC);
      raise EXEQERR.CreateFmt('String too long: CH=%d, CL=%d', [CH, CL]);
    end;
end;


{************** LOADING STORING INDEXING MOVING*****************}

{************** LOCAL VARS *****************}

// SLLA1..SLLA8: (96..103, $60..$67) Short Load Local Address.
// Push the address of the indicated offset in the local activation record.
// Parameters:
//       fOp = OpCode
//       BX = MPPlus register
procedure TIVPsystemInterpreter.SLLA;
begin
  DI      := fOp - 95;     // get OpCode x (as in "SLLAx")
  DI      := DI shl 1;    // convert to a byte offset
  DI      := DI + LocalVar;     // Add MPPLUS register
  PUSH(DI);
end;

// SSTL: 104..111 ($68..$6F)
// Short Store Local Word. Store TOS in the indicated offset in the local
// activation record.
// <word>:<>
procedure TIVPsystemInterpreter.SSTL;
var
  Addr, Val, Opc: word;
begin
    BP   := LocalVar;
    Opc  := fOp - 103;   // 104 = base opcode for SSTL
    Addr  := BP + (2*Opc);
    Pop(Val);
    WordAt[Addr] := Val;
end;


// SLDL1..SLD16: (32..47, $20..$2F)
// Short Load Local Word. SLDLx: fetch the word with offset x in the local
// activation record and push it.
Procedure TIVPsystemInterpreter.SLDL;
var
  Addr, Val, Opc: word;
Begin
//BP   := BX;             // addr of local activation record
  Opc  := fOp - 31;
  Addr := LocalVar+(2*Opc);
  Val  := WordAt[Addr];
  PUSH(Val);
end;


// LLA: 132 or $84
// Load Local Address. Calculate address of the word with offset B in the local
// activation record and push it.
Procedure TIVPsystemInterpreter.LLA;   {load local address}
Begin
  AX := GetAdr(LocalVar);            // addr + offset to AX
  PUSH(AX);
end;

// LDL: 32..47 ($20..$2F)
// Load Local Word. LDLx: fetch the word with offset x in the local
// activation record and push it
Procedure TIVPsystemInterpreter.LDL;   {load local word}
Begin
  BP := GetAdr(LocalVar);
  PUSH(WordAt[BP]);
end;

// Get address to AX
function TIVPsystemInterpreter.GetAdr(OffSet: word): word;
begin
  AX := GetBigB();     // byte adr to AX
{$R-}                      // an overflow can occur but assembler version just ignores it
  result := AX + Offset;   // add the offset
{$R+}
end;

// Name:     STL (164 or $A4)
// Function: store local word
//           Store Local Word. Store TOS into word with offset B in the local activation
//           record.
Procedure TIVPsystemInterpreter.STL;
var
  Val: word;
Begin
  BP := GetAdr(LocalVar);       // get local address to BP
  Val := POP();           // get the value to store
  WordAt[BP] := Val;   // and store it
end;



{************** GLOBAL VARS *****************}

// SLDO1..SLDO16: 48..63 ($30..$3F)
// Short Load Global Word. SLDOx: fetch the word with offset x in the global
// data area of the current segment and push it.
Procedure TIVPsystemInterpreter.SLDO; {short load global word - like SLDL}

var
  Addr, Opc: word;
Begin
  Opc := fOp - 47; // SLDO1, SLDO2, ...
  Addr := GlobVar + (2*Opc);  // debugging
  PUSH(WordAt[Addr]);
end;

// -----------------------------------------------------------------------------
// INTERMEDIATE ONE-WORD LOADS AND STORES

// Name:     LOD 137
// Entry:    CX = count
// RETURN:   Static ADDRESS (IN THE ACTIVATION RECORD YOU WANTED)
//
function TIVPsystemInterpreter.GetStAdr(): word;
var
  Count: word;
begin
//AH     := 0;             // 1.
  Count  := Bytes[DS+SI];  // 2. GET COUNT of # OF STATIC LINKS
  SI     := SI + 1;        // 2.
  BP     := LocalVar - MSSTAT;   // 6.
  while count <> 0 do
    begin
      BP    := WordAt[BP];
      Count := Count - 1;
    end;
  AX      := GetBigB();    // 10. GET THE byte OFFSET
  result  := BP + AX + MSCWDISP;   // 12. ADD 8 SO PARAM,VAR,ETC OFFSETS ARE CORRECT.
end;

// Name:    LDC: 131 ($83)
// Function:     Load Multiple Word Constant.
// Explanation:  B is a word offset into the constant pool of the current segment.
//               Push the UB_2 words starting at that offset onto the evaluation Stack.
//               If UB_1, the mode, is 2, and the current segment is of opposite byte sex
// from the host, swap the bytes of each word as it is pushed.
// If less than B+20 -words available to the Stack, issue a Stack fault.
procedure TIVPsystemInterpreter.LDC;
begin
    SaveIPC;                // In case of stack fault
    AL      := Bytes[DS+SI]; // Get Mode {2 if byte sexual}
    SI      := SI + 1;
    TEMP0   := AL;          // save mode
    BP      := GetBigB();    // byte offset in Const Pool
    CH      := 0;
    CL      := Bytes[DS+SI];
    SI      := SI + 1;
    AX      := STKSLOP;
    STKCHK;                 // Will there be enough room?
    if not StackOverFlow then       // Yes.
      begin
        BP      := BP + Globals.Lowmem.CPOFFSET; //B is Offset into Const Pool, so base it
        BP      := BP + (CX*2);   //Point past the end
        if (TEMP0 = 2) and        // sensitive. Check for other gender
           (Globals.Lowmem.SEXFLAG <> 1) then    //Sex adjustment necessary
          repeat
            BP      := BP - 2;
            AX      := DSWord[BP];
            XCHG(fAX.l,fAX.h);
            PUSH(AX);
            CX      := CX - 1;
          until cx = 0
        else
          begin
            repeat           // Sex change not needed
              BP := BP - 2;
              PUSH(DSWord[BP]);
              CX := CX - 1;
            until cx = 0;
          end;
      end
    else
      raise ESTKBACK.Create('Stack fault in LDC');        //No, Stack fault and retry op
end;

// LDM: 208
// Load multiple words
// Load Multiple Words. TOS is a pointer to the beginning of a block of UB
// words. Push the block onto the Stack, preserving the order of words in
// the block. If less than UB+20 words available to the Stack,
// issue a Stack fault.
procedure TIVPsystemInterpreter.LDM;
begin
    SaveIPC;                // In case of stack fault
    BP      := POP();       // GET POINTER TO BLOCK OF WORDS
    CH      := 0;           // GETCOUNT (assume > 0)
    CL      := Bytes[DS+SI];
    SI      := SI + 1;
    AX      := STKSLOP;
    STKCHK;                // Check for stack overflow
    if StackOverFlow then
      raise ESTKBACK.Create('Stack fault in LDM');
      
    BP      := BP + (CX * 2);
    repeat
      BP := BP - 2;
      PUSH(WordAt[BP]);
      CX := CX - 1;
    until cx = 0;
end;

// STM: 142 ($8E)
// Store Multiple Words. TOS is a block of UB words. Transfer the block from
// the Stack to the destination block starting at the address TOS-1, and
// preserving the order of words in the block.
procedure TIVPsystemInterpreter.STM;
begin
    CH      := 0;           // 1. GETCOUNT
    CL      := Bytes[DS+SI];
    SI      := SI + 1;
    BP      := CX;          // 2.
    BP      := BP SHL 1;    // 3. to byte count
    BP      := BP + SP;     // 4. NOW BP POINTS TO LoCATION ON STACK
                            //    OF DESTINATION PTR.
    BP      := WordAt[BP]; // 5. PUT DEST ADDRESS IN BP
    repeat
      WordAt[BP] := Pop(); // 6. POP STACK INTO DEST ADDRESS
      BP      := BP + 2;      // 7. BUMP DEST Addr BY 1 WORD
      CX      := CX - 1;      // DECREMENT WORD COUNT
    until CX = 0;
    SP      := SP + 2;        // GET RID OF DEST PTR.
//  PJUMP;
end;

// IXP: 216 ($D8)
// Index Packed Array. TOS is an integer index, TOS-1 is the array base
// word pointer. UB_1 is the number of elements per word, and UB_2 is the
// field-width (in bits). Compute and push a packed field pointer.
procedure TIVPsystemInterpreter.IXP;
var
  Temp: word;
begin
    BP := Bytes[DS+SI];      // (BYTETOBP) # Elements / word
    SI := SI + 1;             // assume that DF is always 0
    AH := 0;                // 8/20/2021 - I think that this is irrelevent
{$R-}
    AX := CBW(Bytes[DS+SI]);  // (LODSB) get byte and convert to word (sign extend AL)
{$R+}
    SI := SI + 1;
    XCHG(fAX.w,fCX.w);      // CX := FIELD WIDTH (# OF BITS PER ELEMENT)
    AX  := POP();           // INDEX INTO PACKED ARRAY
    DI  := POP();           // BASE OF PACKED ARRAY
    Temp  := AX MOD BP;       // remainder
    AX  := AX DIV BP;       // quotient (INDEX/ELEMENTS PER WORD)
                            // BP STILL HAS # OF ELEMENTS PER WORD
    AX  := AX SHL 1;        // # OF BYTES TO ADD TO BASE TO BE POINTING
                            // AT CORRECT WORD
    DI  := DI + AX;
    PUSH(DI);               // PUSH POINTER TO INDEXED WORD
    PUSH(CX);               // PUSH BITS PER ELEMENT
    AX  := Temp * CL;         // REMAINDER*BITS-PER-ELEMENT
    PUSH(AX);               // PUSH RIGHT BIT #
    GlobVar  := Globals.Lowmem.BASEPLUS         // GBASEPLUS: BASE+MSCWDISP // 8/20/2021 - dhd - I think this can go
//  PJUMP
end;

// LOAD A PACKED FIELD
// WANT FIELD TO BE AT RIGHT end OF PUSHED WORD WITH LEADING 0'S
//
// Load a Packed Field. Replace the packed field pointer TOS with the field
// it designates.
// Before being pushed on the Stack, the field is right-justified and zero-filled.
procedure TIVPsystemInterpreter.LDP;
begin
  CX := POP();              //RIGHT BIT#  0..15
  AX := POP();              //BITS-PER-ELEMENT
  BP := POP();              //ADDR OF WORD FIELD IS IN
  BP := WordAt[BP];         //MOVE CONTENTS OF WORD INTO BP
  BP := BP SHR CL;
  XCHG(fAX.w, fBP.w);
//      BP := BP shl 1;          // using WORD index in Delphi
  AX      := AX AND CLRMSKp(BP);  //PUT 0'S TO LEFT OF FIELD WE WANT
  PUSH(AX);              //PUSH THE FIELD
end;

// Store into a Packed Field.
// TOS is the right-justified data,
// TOS-1 a packed field pointer.
// Store TOS into the field described by TOS-1.

// STORE INTO A PACKED FIELD HERE IS WHAT WE'LL DO.
// 1. GET WORD TO STORE INTO.
// 2. ROTATE RIGHT BY BIT # BITS.
// 3. GET CLRMASK+BITS-PER-ELEMENT & COMPLEMENT IT.
// 4. AND THAT WITH THE WORD TO STORE INTO.
// 5. OR RESULT WITH NEW DATA (TOS).
// 6. ROTATE LEFT BY BIT # BITS STORE THE WORD AGAIN

procedure TIVPsystemInterpreter.STP;
var
  aWord: word;
begin
        // stack: new data, right-bit, bits per element
        DI := POP();            //NEW DATA WITH LEADING 0'S
        CX := POP();            //RIGHT BIT #
        BP := POP();            //BITS-PER-ELEMENT
//      BP := BP SHL 1;         //not needed for Delphi
        AX := CLRMSKP(BP);      //CORRECT MASK IS IN AX
        DI := DI AND AX;        //MASK DATA TO INSERT
        AX := NOT AX;           //COMPLEMENT THE MASK
        BP := POP();            //ADDRESS OF WORD TO STORE INTO
        aWord := WordAt[BP];    //CURRENT VALUE OF WORD TO BE STORE INTO
        aWord := ROR(aWord, CL);   //GET FIELD YOU WANT TO RIGHT SIDE OF WORD
        aWord := aWord AND AX;     //CLEAR FIELD YOU WANT
        aWord := aWord OR DI;      //PUT NEW DATA IN FIELD
        aWord := ROL(aWord, CL);   //GET FIELD BACK IN CORRECT PLACE
        WordAt[BP] := aWord;    //STORE AGAIN
        Assert(GlobVar = Globals.Lowmem.BASEPLUS);
//      GlobVar := Globals.Lowmem.BASEPLUS;         //"GBASEPLUS" - no longer necessary since DX is not used
end;

// LDA: 136 ($88)
// Load Intermediate Address. DB indicates the activation record as for
// LOD. Push the address of offset B in that record.
procedure TIVPsystemInterpreter.LDA;
begin
  BP := GetStAdr();
  PUSH(BP);
end;

// Load Global Address. Push the word address of the word with offset B in the
// global data area of the current segment.
Procedure TIVPsystemInterpreter.LAO;  {load global address}
Begin
  AX  := GetBigB();       // get the byte offset to AX
  AX  := AX + GlobVar;    // add BASEPLUS
  PUSH(AX);               // push resulting address
end;


// Load Global Word. Fetch the word with offset B in the global data area of the
// of the current segment and push it.

Procedure TIVPsystemInterpreter.LDO;  {133: load global word}
Begin
  AX := GetBigB();    // to AX
//AX := AX shl 1;    // to byte offset
  AX := AX + GlobVar;
  XCHG(fAX.w, fBP.w);
  PUSH(WordAt[BP]);
end;

// SRO: 165 ($A5)
// Store Global Word. Store TOS into the word with offset B in global data area
// of the current segment.
Procedure TIVPsystemInterpreter.SRO;    {165: store global word}
var
  Val: word;
Begin
  AX      := GetBigB();    // get byte offset
//AX      := AX SHL 1;
  AX      := AX + GlobVar;
  XCHG(fAX.w, fBP.w);
  Val     := POP();
  WordAt[BP] := Val;
end;

{************** INTERMEDIATE VARS *****************}

{************** Indirect records, arrays and indexing *************}

// INCI: 237 ($ED)
// Increment Integer.
// Add 1 to TOS.
procedure TIVPsystemInterpreter.INCI;
begin
{$R-}
  WordAt[SP] := WordAt[SP] + 1;
{$R+}
end;

// DECI: 238 ($EF)
// Decrement Integer. Subtract 1 from TOS.
procedure TIVPsystemInterpreter.DECI;
begin
{$R-}
  WordAt[SP] := WordAt[SP] - 1;
{$R+}
end;

// INCF: 231 ($E7)
// Increment Field Pointer. The word pointer TOS is indexed by B words and
// the resultant pointer is pushed.
Procedure TIVPsystemInterpreter.INCF;   {increment (SP) by literal}
Begin
  PUSH(POP() + GetBigB()); // Get Address on TOS and add the Increment
end;


// SIND0..SIND7: (120..127, IE. $78..$7F)
// Short Index and Load Word.
// TOS is the address of a record.
// SINDx: replace it with word x of the record.
Procedure TIVPsystemInterpreter.SIND;  {120 = $78: short index and load word, index=0,
                                      load indirect}
var
  Val: word; Addr, Opc: word;
Begin
  BP  := Pop();       // get address of record
  Addr := BP;          // DEBUG
  Opc := (fOp-$78);     // adjust opcode for correct offset
  Addr := Addr +(2*Opc);  // DEBUG
  Val := WordAt[Addr]; // DEBUG
  PUSH(Val);
end;

// Name:     LOD
// Function: Load Intermediate Word. DB Indicates the number of static links
//           to traverse to find the activation record to use.
//           Push the word at offset B in that activation record.
procedure TIVPsystemInterpreter.LOD;
begin
  BP := GETSTADR;
  PUSH(WordAt[BP]);
end;

// SLOD (173, 174) OR ($AD, $AE)
// Short Load Intermediate Word
procedure TIVPsystemInterpreter.SLOD;
begin
  CX := fOp - 172;                // 173-->1, 174-->2
  BP := GETSTA1();
  PUSH(WordAt[BP]);
end;

// STR: 166 ($A6)
// Store intermediate word. Store TOS at offset B in the activation record
// indicated by DB.
procedure TIVPsystemInterpreter.STR;
var
  val: word;
begin
  BP      := GetStAdr(); // get address of activation record offset to BP
  VAL     := POP();        // GET tos
  WordAt[BP] := Val;    // store TOS there
end;


// LDCB: 128 ($80)
// Load Constant Byte, high byte zero.
procedure TIVPsystemInterpreter.LDCB;
begin
  AL := Bytes[DS+SI];
  SI := SI + 1;      // assume that DF is always 0

  AH := 0;
  PUSH(AX);
end;

// LDCI: 129 ($81)
// Load Constant Word. Push W.
procedure TIVPsystemInterpreter.LDCI;
begin
//  LODSW;
    PUSH(LODUW);
end;

// Loads signed word
function TIVPsystemInterpreter.LODSW: integer;
var
  U: TUnion;
begin
//  AL := Bytes[DS+SI];
//  SI := SI + 1;
//  AH := Bytes[DS+SI];
//  SI := SI + 1;
  U.L := Bytes[DS+SI];
  SI := SI + 1;
  U.H := Bytes[DS+SI];
  SI := SI + 1;
  result := U.I;
end;

// Loads UN-signed word 
function TIVPsystemInterpreter.LODUW: word;
var
  U: TUnion;
begin
  U.L := Bytes[DS+SI];
  SI := SI + 1;
  U.H := Bytes[DS+SI];
  SI := SI + 1;
  result := U.W;
end;



// LDCN: 152 ($98)
// Load Constant NIL. Push NIL. The value may vary across processors.
procedure TIVPsystemInterpreter.LDCN;
begin
  PUSH(pNIL);
end;


// To copy value parameters of type string or packed array of char into the
// activation record of a called routine, the calling routine generates
// a "parameter descriptor." This descriptor is a 2-word record. The first
// (low address) word is either NIL, or a painter to an E_Rec. If the first
// word is NIL, the second word is the address of the parameter.
// If the first word points to an E_Rec, the second word is an offset
// relative to the designated segment (the offset is generated by an
// LCO instruction).

// Load Constant Offset. B is a word offset into the constant pool of the
// current segment. Convert B to a segrelative word offset. If operating
// on a byte addressed machine, then convert to a byte offset. Push the
// offset on the Stack.
procedure TIVPsystemInterpreter.LCO;
begin
  AX      := GetBigB();                 // get byte offset in constant pool to AX
  AX      := AX + Globals.LowMem.CPOFFSET;   // offset within the pool + offset to the pool

  PUSH(AX);              // AX + SEGb (AX + DS) is the actual address
end;


// IXA: 215 ($d7)
// INDEX ARRAY   (ADD 2*B*TOS TO TOS-1)
// TOS is an integer index,
// TOS-1 is the array base word pointer,
// and B is the size (in words) of an array element.
// Push a word pointer to the indexed element.
Procedure TIVPsystemInterpreter.IXA; {index array}
Begin
  AX    := GetBigB();     // 1. AX <- get array element size in bytes
{$R-}
  BP    := POP();         // 3. get index
  AX    := AX * BP;       // 4. AX := AX * BP : COMPUTE OFFSET
  BP    := POP();         // 6. GET ARRAY BASE
  BP    := BP + AX;       // 7. ADD BASE TO OFFSET
{$R+}
  PUSH(BP);               // 8. PUSH ADDRESS OF ELEMENT
end;

        //***********************************************
        //      EXTENDED ONE WORD LOADS AND STORE       *
        //***********************************************

        //Seg Number and Word Offset in Code Stream as UB,B
        //BP := Address of Refd Global Data

procedure TIVPsystemInterpreter.EXTADR;
begin
  BP := Bytes[DS+SI];     // Local Segment Number
  SI := SI + 1;           //
  BP := BP shl 1;         //  Byte offset into EVec
//      DI := WordAt[EVECp]; // addr of EVec
  DI := Globals.LowMem.EVECp;         // addr of EVEC
  BP := WordAt[BP+DI]; // BP := ^EnvRec[Seg#_BP]
  BP := WordAt[BP+ENVDATA]; //BP := ^Global Data Seg
  AX := GetBigB();        // byte Offset into Data Seg
  AX := AX + MSCWDISP;    // Displace past phony stack mark
  BP := BP + AX;          // base + displacement
end;

// STE: 217 ($D9)
// Store extended word. Store TOS at offset B in the global data area of
// local segment UB.
procedure TIVPsystemInterpreter.STE;
var
  Val: word;
begin
  EXTADR;
  Val := POP();           // get the value to store
  WordAt[BP] := Val;   // and store it
end;

// LDE : 154 ($9A)
// Load Extended Word. Push the word at offset B in the global data area of
// local segment UB.

procedure TIVPsystemInterpreter.LDE;
begin
  EXTADR;
  PUSH(WordAt[BP]);    // BP CONTAINS THE WORD ADDRESS
end;

// LAE: 155 ($9B)
// Load extended address. Push the address of the word at offset B in the
// global data area of local segment UB.
procedure TIVPsystemInterpreter.LAE;
Begin
  EXTADR;
  PUSH(BP);               // push address
end;

// MOV: 197 ($C5).
// Move B words from the source designated by TOS to the destination
//   designated by TOS-1.
// TOS is either the address of a word block (if UB is zero)
// of the offset of a constant word block in the current segment.
// If UB is 2, and the current segment has opposite byte sex from the host,
// swap the bytes of each word as it is moved.
Procedure TIVPsystemInterpreter.MOV;
var
  Src, Dst: longword;
  SrcO, DstO: word;
  Len: word;
  Mode: byte;
Begin
//      0-data, 1-sexless const, 2-sexed const

  Mode    := Bytes[DS+SI];  // 1. mode byte
  SI      := SI + 1;      // 1.
  Len     := GetBigB();   // 4. # bytes to move to Len

  SaveIPC;                // 6. Fault handlers may depend on this having been done

  SrcO := POP();          // 7. source byte offset
  DstO := POP();          // 8. dest byte offset

  Dst := 0;               // 9, 10. destination is always in stack/heap
  Src := DS;              // Refer to the current data segment

  if Mode <> 0 then         // 11. if source is in constant pool
    begin
      // move from const pool at byte displacement SI in Seg
      // Src is already = SEGB     // point source at segment
      if (Mode = 1)                // if byte sex is not important
        or (Globals.Lowmem.SEXFLAG = 1) then     // if byte sex is already correct
                          // 12. then just copy
          if Integer(Len) > 0 then
            Move(Bytes[Src+SrcO], Bytes[Dst+DstO], Len)
          else
            { this case should never happen but it it does, it is a major problem }
      else   // move constant while flipping
        begin  // This code has never been tested. In particular, usage of "Src" is dubious
          UnTested;
          repeat
            AX        := WordAt[Src+SrcO];  // 18.
            SrcO      := SrcO + 2;
            XCHG(fAX.l, fAX.h);             // 19.
            WordAt[Dst+DstO] := AX;         // 20.
            DstO      := DstO + 2;
            Len       := Len - 2;
          until Len <= 0;
        end
    end
  else
    if Integer(Len) > 0 then
      MOVE(Bytes[SrcO], Bytes[Dst+DstO], Len); // 27. move data without flipping
//    begin
//      MOVE(Bytes[Src+SrcO], Bytes[Dst+DstO], Len); // 27. move data without flipping
//      StatusProc('the above line should still be considered as being debugged'); // See "MOVV" in PME-debug.txt
//    end;
end;


//  Name:   SCAN
//  Entry:
//        (TOS)   = mask param (unused)
//        (TOS+1) = Start address
//        (TOS+2) = byte Offset
//        (TOS+3) = character to scan for
//        (TOS+4) = RELATIONAL OPERATOR <>(1) OR =(0)
//        (TOS+5) = length to scan for
//        (TOS+6) = function return space
//  Returns:
//        (TOS)   = function value (i.e., offset from start)
procedure TIVPsystemInterpreter.SCAN;
var
  CH: byte;
  Len: integer;
  SrcO: word;
  OP: word;
  StartAddress: word;
begin
             POP();       // 1.  EXTRA MASK PARAM, NOT USED YET
  DI      := POP();       // 2.  GET ADR TO START SCAN IN DI
  AX      := POP();       // 3.  Byte offset?
  SrcO    := DI+AX;       // 4.
  StartAddress := SrcO;

  CH      := POP();       // 5. AL := CHAR TO SCAN FOR
  Op      := POP();       // 6. RELATIONAL OPERATOR <>(1) OR =(0)
{$R-}
  Len     := POP();       // 8. LENGTH TO SCAN FOR

  BP      := POP();       // 9. JUNK FUNC RETURN SPACE.
  PUSH(Len);              // 10. ASSUME NOT FOUND
{$R+}
  if Len <> 0 then
    begin
      if Len > 0 then     // scan to the right
        begin
          if Op = 1 then  // looking for <>
            begin
              while (ch = Bytes[SrcO]) and (Len <> 0) do
                begin
                  SrcO := SrcO + 1;
                  Len  := Len - 1;
                end
            end else
          if Op = 0 then  // looking for =
            begin
              while (ch <> Bytes[SrcO]) and (Len <> 0) do
                begin
                  SrcO := SrcO + 1;
                  Len  := Len - 1;
                end;
            end;
          Len := SrcO - StartAddress;
          pop();     // trash the length from step 10
          PUSH(Len); // need to push signed length onto the stack
        end
      else
        begin             // scan to the left
          if Op = 1 then  // looking for <>
            begin
              while (ch = Bytes[SrcO]) and (Len <> 0) do
                begin
                  SrcO := SrcO - 1;
                  Len  := Len + 1;
                end
            end else
          if Op = 0 then  // looking for =
            begin
              while (ch <> Bytes[SrcO]) and (Len <> 0) do
                begin
                  SrcO := SrcO - 1;
                  Len  := Len + 1;
                end;
            end;
{$R-}
          Len := SrcO - StartAddress;
          pop();     // trash the length from step 10
          PUSH(Len); // need to push signed length onto the stack
{$R+}
        end
    end;
end;

procedure TIVPsystemInterpreter.MYFILLCHAR;
var
  Cnt: integer;
begin
{$R-}                       // Cnt may be negative. Prevent range check error.
    AX      := POP();       //  1. AL:=CHAR TO FILL WITH
    AH      := AL;          //  2. AH:=AL
    Cnt     := POP();       //  3. COUNT OF CHARS TO FILL
    if Cnt > 0 then          //  5. IS COUNT > 0
      begin
//      ES      := SS;          // 7. ES = STACK/HEAP
        DI      := POP();       // 8. MAKE DI=COMPLETE BYTE Addr
        BP      := POP();       // 9.
        DI      := DI + BP;     // 10.
//      BP      := DI;          // 11. PUT Addr IN BP
        FILLCHAR(Bytes[DI], Cnt, AL);
//      DI      := DI + CX;     // IS THIS NEEDED?
      end
    else
      SP      := sp + 4;      // REMOVE DEST Addr FROM STACK;
{$R+}
end;


{*********** Character VARS AND BYTE ARRAYS *****************}

// Load Byte. 167 ($A7)
// TOS is a byte pointer. Pop it and push a word with the byte it
// designated in the least significant bits and a most significant byte of zero.
// <byte-ptr>:<word>
Procedure TIVPsystemInterpreter.LDB;  {load byte}
Begin
  DI      := Pop();       // get index
  BP      := Pop();       // get base
{$R-}
  AX      := Bytes[BP+DI];  // get the byte
  PUSH(AX);
{$R+}
end;

// STB: 200 ($C8)
// Store Byte. Store byte TOS into the location specified by byte
// pointer TOS-1.
Procedure TIVPsystemInterpreter.STB;  {store byte}
Begin
  AX      := POP();       // GET THE BYTE
  DI      := POP();       // Get index.
  BP      := POP();       // Get base.
  Bytes[BP+DI] := AL;    // Store the byte.
end;





{*********** STRING VARS *****************}


function TIVPsystemInterpreter.CLRMSKp(n: word): word;
begin
  if n = 0 then
    result := CLRMSK else
  if n <= 16 then
    result := Bitter[n-1]
  else
    raise exception.CreateFmt('Unexpected CLRMSKp param: %d', [n]);
end;

// DECOPS: 64 ($40)
// WARNING: This is NOT an official p-Code!
//          This requires that the LONGOPS.CODE unit be libraried into the
//          system or USERLIBed in.
//          Furthermore, it will NOT work on long integer values > 64 bits.
//          ALl of the OpCodes have NOT been implemented!
//
// NOTE:    Delphi stores long words this way:   0, 1, 2, 3  (least significant -> most significant)
//          p-System stores long words this way: 3, 2, 1, 0

// NOTE:    ALL OF THIS STUFF EXISTS IN Interp_Common AND THAT IS THE ONE THAT SHOULD BE USED

procedure TIVPsystemInterpreter.DECOPS;
const
  WORDSTOSAVE = 5;
//WORDS_PER_INT64 = 4; // Sizeof(Int64) div 2
//MAXUNIONS = 3;
//MAXWORDS = 12;  // MAXUNIONS * (SizeOF(INT64) div 2)
(*

type
//  TInt64Words = array[0..WORDS_PER_INT64-1] of word;
  TUnion = record
             case integer of
               1: (int: array[0..MAXUNIONS-1] of Int64);
               2: (arr: array[0..MAXWORDS-1] of word);
             end;
*)
var
  OpCode  : TDecops;
  OpType  : word;
  i       : integer;
  MaxChars    : integer;
  Op1Len, Op2Len, OpResultLen  : word;
  SavedMSCW: array[0..WORDSTOSAVE-1] of word;
  Operand1, Operand2, OpResult: TDecopsUnion;
  NewSize, Addr: word;
  b: boolean;
  Temp: string[255];

(*
  procedure FillHighWords(var Operand: TUnion; LowWordCount: word);
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
*)
(*
  function PopL(nwords: integer): TUnion;
  var
    i: integer;
  begin
    for i := 0 to nwords-1 do
      result.arr[i] := Pop();

    FillHighWords(result, nwords);
  end;

  procedure PushL(nwords: integer; Value: TUnion);
  var
    i: integer;
  begin
    for i := nwords-1 downto 0 do
      push(Value.arr[i]);
  end;
*)
  procedure CheckLen(OpLen: integer);
  begin { CheckLen }
    if OpLen > MAXWORDS then
       begin
//       raise EXEQERR.Create('DECOPS: integer overflow. OpLen = %d words', [OpLen], INTOVRC);
         raise EXEQERR.CreateFmt('DECOPS: integer overflow. OpLen = %d words', [OpLen]);
       end;
  end;  { CheckLen }

  function GetOperandLength(Operand: TDecopsUnion): integer;
  var
    n: integer;
  begin { GetOperandLength }
    result := 0;
    for n := MAXWORDS-1 downto 0 do
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

begin { DECOPS }
  Operand1.int[0] := $300020001;  // just testing

  for i := 0 to WORDSTOSAVE-1 do  // save the MSCW from TOS
    SavedMSCW[i] := Pop();

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
//              raise EXEQERR.Create('DECOPS: string overflow. Needed = %d, Max words = %d', [Length(Temp), MaxChars], S2LONGC);
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

      dop_longToInt{20}:
        begin
          Untested('Decops_LongToInt');
        end;
    end;

  finally
    // move the MSCW to new location

    for i := WORDSTOSAVE-1 downto 0 do  // restore stuff to TOS
      Push(SavedMSCW[i]);

    MP := SP;
  end;

end;  { DECOPS }


{******TOP of STACK ARITHMETIC*******}

{***** Logical}

// LAND: 161 ($A1)
// Logical And. AND TOS into TOS-1.
Procedure TIVPsystemInterpreter.LAND;
Begin
  PUSH(Pop() and Pop());
end;

// LOR: 160 ($A0)
// Logical Or.
// OR TOS into TOS-1.
Procedure TIVPsystemInterpreter.LOR;
Begin
  PUSH(POP() or POP());
end;

// LNOT: 229 ($E5)
// Logical Not. Take one's complement of TOS.
Procedure TIVPsystemInterpreter.LNOT;
Begin
  PUSH(not Pop());
end;

// BNOT: 159 ($9F)
// Boolean Not. Complement the low bit and clear the remainder of TOS.
procedure TIVPsystemInterpreter.BNOT;
begin
  WordAt[SP] := (not WordAt[SP]) and $01;
end;

{***** integer}

// ABI: 224 ($E0)
// Absolute Value Integer. Take absolute value of integer TOS. Result is
// undefined if TOS is initially -32768.
Procedure TIVPsystemInterpreter.ABI; {absolute value}
var
  Temp: integer;
Begin
{$R-} // ABS function would assume a 32 bit integer when it is really a 16 bit integer.
      // This causes a fail on negative 16 bit values. This caused extremely difficult to detect bugs.
  Temp := Pop();
{$R+}
  PUSH(Abs(Temp));
end;

// ADI: 162 ($A2)
// Add Integers. Add TOS into TOS-1.
Procedure TIVPsystemInterpreter.ADI;   {add integers}
Begin
{$R-}
  PUSH(POP()+POP());
{$R+}
end;

// SBI: 163 ($a3)
// Subtract integers
// Subtract Integers. Subtract TOS from TOS-1.
Procedure TIVPsystemInterpreter.SBI;  {subtract integer}
var
  a, b: integer;
Begin
{$R-}
  a := Pop();
  b := Pop();
  PUSH(B-A);
{$R+}
end;

// DVI: 141 ($8D)
// Divide Integers. Divide TOS-1 by TOS and PUSH quotient.
// If TOS is 0, cause an execution error.
Procedure TIVPsystemInterpreter.DVI; {divide integers}
var TOS, TOS1: integer;
Begin
{$R-}
  TOS  := Pop(); {divisor}
  TOS1 := Pop(); {dividend}
  try
    PUSH(TOS1 div TOS);
  except
//  raise EXEQERR.Create('Divide by 0: %d/%d', [TOS1, TOS], DIVZERC);
    raise EXEQERR.CreateFmt('Divide by 0: %d/%d', [TOS1, TOS]);
  end;
{$R+}
end;




Procedure TIVPsystemInterpreter.MPI;   {integer multiply}
Begin
{$R-}
  PUSH(Pop() * Pop());
{$R+}
end;

// MISCELANEOUS OPCODES

// DUP1: 226 ($E2)
// Duplicate One Word, word on TOS.
procedure TIVPsystemInterpreter.DUP1;
var
  temp: word;
begin
  temp := POP();
  PUSH(temp);
  PUSH(temp);
end;

// Swap: $BD (189)
// Swap TOS with TOS-1.
procedure TIVPsystemInterpreter.SWAP;
var
  temp: word;
begin
  temp := WordAt[SP];
  WordAt[SP] := WordAt[SP+2];
  WordAt[SP+2] := temp;
end;

// Native Code. Transfer control to native code that begins directly after
// this instruction. Details are machine-dependent.
procedure TIVPsystemInterpreter.NAT;
begin
  Unimplemented('NAT');
end;

// Native Code Information. Ignore the next B bytes in the P-code stream.
// This information is used in the generation of native code. Treat
// the instruction as a long form of NOP.
procedure TIVPsystemInterpreter.NATI;
begin
  GETBIG;                 // number of bytes to skip
  SI := SI + AX;          // added to ipc
end;



// NGI: 225 ($E1)
// Negate Integer. Take the two's complement of TOS.
Procedure TIVPsystemInterpreter.NGI;  {negate integer}
Begin
{$R-}
  WordAt[SP] := - WordAt[SP];
{$R+}
end;

{************** Floating point stuff*************}

Procedure TIVPsystemInterpreter.FLT;
{pop integer off stack 2 bytes, and push real }
var
  X : TRealUnion;
  N : integer;
Begin
{$R-}
  N := Pop();        {be careful to not convert a WORD TO a real-- must be an integer}
{$R+}
  X.UCSDReal4 := N;   {DELPHI does conversion}
  PUSH(X);
end;

// Equal Real. Push Boolean
// result of real comparison TOS-1 = TOS.
procedure TIVPsystemInterpreter.EQREAL;
var
  UCSDReal0 : TRealUnion;
  UCSDReal2 : TRealUnion;
begin
  POP(UCSDReal0);
  POP(UCSDReal2);
  PUSH(UCSDReal0.UCSDReal4 = UCSDReal2.UCSDReal4);
end;

// Less than or Equal Real. Push Boolean
// result of real comparison TOS-1 <= TOS.
procedure TIVPsystemInterpreter.LEREAL;
var
  UCSDReal0 : TRealUnion;
  UCSDReal2 : TRealUnion;
begin
  POP(UCSDReal0);
  POP(UCSDReal2);
  PUSH(UCSDReal2.UCSDReal4 <= UCSDReal0.UCSDReal4);
end;

// Less than or Equal Real. Push Boolean
// result of real comparison TOS-1 >= TOS.
procedure TIVPsystemInterpreter.GEREAL;
var
  UCSDReal0 : TRealUnion;            { TOS }
  UCSDReal2 : TRealUnion;            { TOS-1 }
begin
  POP(UCSDReal0);
  POP(UCSDReal2);
  PUSH(UCSDReal2.UCSDReal4 >= UCSDReal0.UCSDReal4);
end;

// Name:     MovSW
// Function: Move signed words
// Entry:    Src = Source Base
//           SrcO = Source offset
//           Dst = Destination Base
//           DstO = Destination Offset
//           N = the increment
// Returns:  Updated SrcO and DstO
procedure TIVPsystemInterpreter.MOVSW(Src {DS}: longword; var SrcO {SI}: word;
                                      Dst {ES}: longword; var DstO {DI}: word;
                                      N: integer);
begin
  WordAt[Dst+DstO] := WordAt[Src+SrcO];
  SrcO := SrcO + N;
  DstO := DstO + N;
end;

procedure TIVPsystemInterpreter.MOVSW(N: integer);
begin
  ESWord[DI] := DSWord[SI];
  DI := DI + N;      // Increment or decrement
  SI := SI + N;
end;

//  DUPR $C6 (198)  Duplicate real on TOS
procedure TIVPsystemInterpreter.DUPR;
var
  X: TRealUnion;
begin
  Pop(X);
  Push(X);
  Push(X);
end;


Procedure TIVPsystemInterpreter.ADR;
{add reals tos and nos....leaves result on stack}
var
  UCSDReal0 : TRealUnion;
  UCSDReal2 : TRealUnion;
Begin
  POP(UCSDReal0);
  POP(UCSDReal2);
  UCSDReal0.ucsdreal4 := UCSDReal0.ucsdreal4 + UCSDReal2.UCSDReal4;
  PUSH(UCSDReal0);
end;



Procedure TIVPsystemInterpreter.MPR;
{mult reals tos and nos....leaves result on stack}
var
  UCSDReal0 : TRealUnion;
  UCSDReal2 : TRealUnion;
Begin
  POP(UCSDReal0);
  POP(UCSDReal2);
  UCSDReal0.ucsdreal4 := UCSDReal0.ucsdreal4 * UCSDReal2.UCSDReal4;
  PUSH(UCSDReal0);
end;


Procedure TIVPsystemInterpreter.DVR;
{divide reals nos by tos....leaves result on stack}
var
  UCSDReal0 : TRealUnion;
  UCSDReal2 : TRealUnion;
Begin
  POP(UCSDReal0);        // TOS
  POP(UCSDReal2);        // NOS
  try
    UCSDReal0.UCSDReal4 := UCSDReal2.UCSDReal4 / UCSDReal0.UCSDReal4;
    PUSH(UCSDReal0);
  except
    UCSDReal0.UCSDReal4 := 0;
//  PUSH(UCSDReal0);
//  BP := DIVZERC;
{$IfDef Debugging}
//  raise EXEQERR.Create('Real Divide by 0.0 in %s.Proc #%d. IPC=%d', [CurrentSegName, Globals.LowMem.CURPROC, SI-ProcBase-1], DIVZERC);
    raise EXEQERR.CreateFmt('Real Divide by 0.0 in %s.Proc #%d. IPC=%d', [CurrentSegName, Globals.LowMem.CURPROC, SI-ProcBase-1]);
{$else}
//  raise EXEQERR.Create('Real Divide by 0.0 in %s.Proc #%d.d', [CurrentSegName, Globals.LowMem.CURPROC], DIVZERC);
    raise EXEQERR.CreateFmt('Real Divide by 0.0 in %s.Proc #%d.d', [CurrentSegName, Globals.LowMem.CURPROC]);
{$endIf}
  end;
end;


// Absolute real: $E3 (227)
Procedure TIVPsystemInterpreter.ABR;
{absolute value of real tos ..leaves result on stack}
var
  X : TRealUnion;
Begin
  POP(X);
  X.UCSDReal4 := abs(X.UCSDReal4);
  PUSH(X);
end;

{$R-}
// Truncate real: $BE (190)
procedure TIVPsystemInterpreter.TNC;
var
  X : TRealUnion;
  N : integer;
begin
  POP(X);
  N := Trunc(X.UCSDReal4);
  PUSH(N);
end;

// Round real: $BD (191)
procedure TIVPsystemInterpreter.RND;
var
  X : TRealUnion;
  N : integer;
begin
  POP(X);
  N := Round(X.UCSDReal4);
  PUSH(N);    // expecting a word but might get a negative integer
end;
{$R+}


Procedure TIVPsystemInterpreter.NGR;
{negate value of real tos}
var
  X : TRealUnion;
Begin
  POP(X);
  X.UCSDReal4 := - X.UCSDReal4;
  PUSH(X);
end;



Procedure TIVPsystemInterpreter.SBR;
{subtract tos from nos....leaves result on stack}
var
  UCSDReal0 : TRealUnion;
  UCSDReal2 : TRealUnion;
Begin
  POP(UCSDReal0);
  POP(UCSDReal2);
  UCSDReal0.UCSDReal4 := UCSDReal2.UCSDReal4 - UCSDReal0.UCSDReal4;
  PUSH(UCSDReal0);
end;

// Store Real. $F4 (244)
// TOS is the value of a real variable.
// TOS-1 is an address.
// Store TOS at the address in TOS-1.
procedure TIVPsystemInterpreter.STRL;
var
  X : TRealUnion;
  Dst: longword;
begin
  Pop(X);              // avoid "X := Pop()" because it won't POP the whole thing
  Dst := Pop();        // get target address
  RealAt[Dst] := X;    // save in desired location
end;

// LDRL $F3 (243)
// Load real.
// TOS is the address of a real variable.
// Replace the address by the value of the variable.
procedure TIVPsystemInterpreter.LDRL;
var
  Addr: word;
  X: TRealUnion;
begin
  Addr := Pop();          // get the address from the stack
  X    := RealAt[Addr];   // get the value
  PUSH(X);                // and return it
end;

procedure TIVPsystemInterpreter.POT;
var
  Exponent: integer;
  X: TRealUnion;
begin
  Exponent := Pop();
  SP       := SP + (CREALSIZE*2);  // remove function return space
  if Exponent <= MAXPOT then
    begin
      X.UCSDReal4 := Power(10, Exponent);
      PUSH(X);
    end
  else
    begin
      Globals.LowMem.IPCSAV := SI;
      raise EOVRFLO.Create('Exponent too large in POT');
    end;
end;


procedure TIVPsystemInterpreter.LDCRL;
var
  X: TRealUnion;
  CPAddr: longword;
begin
  CPAddr  := DS + GetBigB() + Globals.LowMem.CPOFFSET; // calc addr in const pool of the segment
  X       := RealAt[CPAddr]; // get the constant
  PUSH(X);
end;


{**************word comparisons}

// EQUI: 176 ($B3)
// Equal Integer. Push Boolean result of integer comparison TOS-1 = TOS.
Procedure TIVPsystemInterpreter.EQUI;
Begin
  PUSH(Pop() = Pop());
end;

// GEQI: 179 ($B3)
// Greater than or Equal Integer. Push Boolean result of integer comparison
// TOS-1 >= TOS.
Procedure TIVPsystemInterpreter.GEQI;  {>=}
var
  a, b: integer;
Begin
//  Push(POP() { TOS } >= POP() { TOS-1 });
{$R-}
  a := Pop();    // TOS
  b := Pop();    // TOS-1
  PUSH(B >= A);
{$R+}
end;

// modes in code stream UB, UB B=Len; addrs on tos
// returns:
//   = 0:  If S1 = S2
//   > 0:  If S1 > S2
//   < 0:  If S1 < S2, etc
function TIVPsystemInterpreter.BYTECMP(): integer;
var
  Src, Dst: longword;
  SrcO, DstO: word;
  Len: integer;
  SrcMode, DstMode: byte;
begin
  AX      := LODUW;       //AL=tos.mode, AH=tos-1.mode
  SrcMode := AL;
  DstMode := AH;

  Len      := GetBig();   // Get comparison length in bytes

  SaveIPC;                // fault handlers may depend on this

  SrcO    := POP();       //offset of tos, the source
  DstO    := POP();       //offset of tos-1, the destination

  Dst     := DS;
  Src     := DS;

  if DstMode = 0 then      //is tos-1 in data segment
    Dst := 0;             //  then dest base is data segment

  if SrcMode = 0 then      //is tos in data segment?
    Src := 0;             // ELSE source base is in data segment

  result  := 0;           // to initialize comparison result if Len=0

  while (result = 0) and (Len > 0) DO  //compare while equal
    begin
{$R-}
//          result := Bytes[Src+SrcO] - Bytes[Dst+DstO];
      result := Bytes[Dst+DstO] - Bytes[Src+SrcO];
{$R+}
      SrcO   := SrcO + 1;
      DstO   := DstO + 1;
      Len    := Len - 1;
    end;
end;

// EQBYT: 185 ($B9)
// BYTE ARRAY =, ALL BYTES IN THE ARRAYS MUST BE =
// Equal Byte Array. TOS and TOS-1 are each a pointer to a byte array
// (if the corresponding UB is zero) or the offset
// of the constant byte array in the current segment.
// B is the size (in bytes) of that array.
// UB_1 and UB_2 are mode flags.
// They refer to TOS and TOS-1, respectively.
// If the byte sex of the segment is different from the host,
// and the corresponding mode is 2, swap the bytes of each word of that operand,
// before doing the comparison.
// Push the Boolean result of the byte array
// comparison TOS-1 - TOS.
procedure TIVPsystemInterpreter.EQBYT;
begin
  PUSH(BYTECMP() = 0);
end;

procedure TIVPsystemInterpreter.LEBYT;
begin
  PUSH(BYTECMP() <= 0);
end;

procedure TIVPsystemInterpreter.GEBYT;
begin
  PUSH(BYTECMP() >= 0);
end;



// String comparison between (TOS) and (TOS-1).
// result is (TOS) - (TOS-1)
//
// Equal String. TOS and TOS-1 each <addr|offset,addr|offset>:<Bool>
// point to a string variable (if the corresponding UB is zero) or the
// offset of a constant string in the current segment.
// UB_1 and UB_2 refer to TOS and TOS-1, respectively. Push
// the Boolean result of the string comparison TOS-1 = TOS.
function TIVPsystemInterpreter.StrCompare(): integer;
var
  Src, Dst: longword;
  SrcO, DstO: word;
  DstLen, SrcLen, Len: byte;
begin
  AX     := LODUW;        // get the mode flags to AX [AH = destination mode, AX = source mode]

  SaveIPC;                // fault handlers may depend on this

  SrcO   := POP();        //5.  offset of tos, the source
  DstO   := POP();        //6.  offset of tos-1, the destination

  Src     := DS;          // Start by assuming that SRC is in the data segment
  Dst     := DS;          //8.  ### assume dest is in constant pool

  if AH = 0 then          //10.  if tos-1 is in data segment
    Dst := 0;             //12, 13. then dest base is data segment

  if AL = 0 then          //14. if tos is in data segment
    Src := 0;             //16.  ### ELSE source base is in data segment

  DstLen  := Bytes[Dst+DstO];  //19. len of tos-1
  DstO      := DstO + 1;       //20.

  SrcLen  := Bytes[Src+SrcO];  //21. len of tos
  SrcO      := SrcO + 1;       //21.

  Len := DstLen;               // default the comparison length
  if SrcLen < DstLen then      //22. compare len(tos), len(tos-1)
    Len := SrcLen;             //  len(tos) < len(tos-1), use len(tos)

  result := 0;            //  to initialize comparison result if Len=0
  while (result = 0) and (Len > 0) DO
    begin
      result := Bytes[Dst+DstO] - Bytes[Src+SrcO];
      SrcO   := SrcO + 1;
      DstO   := DstO + 1;
      Len    := Len - 1;
    end;

  if result = 0 then      //29. if still equal
    result := DstLen - SrcLen;    //30.   then compare len(tos),len(tos-1)

//  Assert(DS=Globals.LowMem.SegB);  // Switch to following line if I figure out why.
  DS := Globals.LowMem.SEGB;
end;

// EQSTR: 232 ($E8)
// Equal String. TOS and TOS-1 each <addr|offset,addr|offset>:<Bool>
// point to a string variable (if the corresponding UB is zero) or the
// offset of a constant string in the current segment.
// UB_1 and UB_2 refer to TOS and TOS-1, respectively. Push
// the Boolean result of the string comparison TOS-1 = TOS.
procedure TIVPsystemInterpreter.EQSTR;
begin
  PUSH(StrCompare() = 0);
end;

// Less or Equal String: $E9 (233)
// TOS and TOS-1 <addr|offset,addrloffset>:<Bool> each point to a string variable
// (if the corresponding UB is zero) or the offset of a constant string in the
// current segment. UB_1 and UB_2 refer to TOS and TOS-1, respectively.
// Push the Boolean result of the string comparison TOS-1 <= TOS.
procedure TIVPsystemInterpreter.LESTR;
begin
  PUSH(StrCompare() <= 0);
end;

procedure TIVPsystemInterpreter.GESTR;
begin
  PUSH(StrCompare() >= 0);
end;



// ASTR: 235 ($EB)
// Assign String.
// TOS-1 is the address of the destination string variable.
// UB_2 is the declared size of that string.
// TOS represents the source for the assignment.
//   It is either the address of a string variable (if the mode, UB_1,
//   is 0) or the offset of a string constant in the current segment.
// Cause a string overflow fault if the dynamic size of the source string
// is greater than the declared size of the destination.
// Otherwise, copy the source into the destination.
procedure TIVPsystemInterpreter.ASTR;
var
  Src, Dst: longword;
  SrcO, DstO: word;
  SrcMode, DstLen, SrcLen: byte;
begin
    SrcMode := Bytes[DS+SI];
    SI      := SI + 1;
    DstLen  := Bytes[DS+SI]; // 1. AH=len(dest)
    SI      := SI + 1;

    SaveIPC;                // fault handlers may depend on this
    
    SrcO    := POP();       // 3. get byte offset of source
    DstO    := POP();       // 4. get byte offset of destination

    Dst     := 0;

    Src     := DS;
    if SrcMode = 0 then          // 9. if source NOT in code segment {mode=0}
      Src := 0;

    SrcLen  := Bytes[Src+SrcO]; // 13. length of source

    if SrcLen <= DstLen then        // 14. prevent source_length > max_dest_length
      Move(Bytes[Src+SrcO], Bytes[Dst+DstO], SrcLen+1 {include length byte})
    else
      begin // bummer, one too many tomatoes
        GetSavedIPC;           // 20. restore IPC
        raise ES2LONG.Create('S2LONG');             // execution error.
      end;
end;

// Check String Index. TOS-1 is the address of a string variable.
// TOS is an index into that variable. Check that the index is between 1 and
// the current dynamic length of the variable. If not, cause a range-check
// execution error.

procedure TIVPsystemInterpreter.CSTR;
begin
  POP(fAX.w);             // proposed index
  POP(fBP.w);             // offset of string being checked
  PUSH(BP);
  PUSH(AX);
  if (ah <> 0) or (al = 0) or (al > Bytes[bp]) then // valid length
//  raise EXEQERR.Create('Invalid string length: %d', [AX], INVNDXC);
    begin
      fErrCode := INVNDXC;
      raise EXEQERR.CreateFmt('Invalid string length: %d', [AX]);
    end;
end;

// integer modulus : TOS-1 MOD TOS
Procedure TIVPsystemInterpreter.MODI; {remainder of integer division}
var
  TOS, TOS1: word;
Begin
  TOS  := POP();
  TOS1 := POP();
  PUSH(TOS1 mod TOS);
end;

// Check Subrange Bounds. $CB (203)
// Insure that // TOS-1 <= TOS-2 <= TOS, leaving TOS-2 // on the Stack.
// If conditions are not satisfied, cause a runtime error.
procedure TIVPsystemInterpreter.CHK;
var
 LowV, Val, HighV: integer;
begin
{$R-}
  HighV   := POP();       // TOS     (high value)
  LowV    := POP();       // TOS-1   (low value)
  Val     := POP();       // TOS-2   (test value)

  PUSH(Val);              // leave value on tos
  if (Val < LowV) or (Val > HighV) then
//  raise EXEQERR.Create('Range Check error: %d <= %d <= %d failed', [LowV, Val, HighV], INVNDXC);
    raise EXEQERR.CreateFmt('Range Check error: %d <= %d <= %d failed', [LowV, Val, HighV]);
{$R+}
end;

// ****************************
//            JUMPS           *
// ****************************

// XJP: 214 ($D6)

Procedure TIVPsystemInterpreter.XJP;    {case jump}
{ index is (SP).  Case jump.
  The first word, Wl, with word offset B in the constant pool of the current segment
  is word-aligned and is the minimum index of the table.
  The next word, W2, is the maximum index.
  The case table is the next (W2-W1)+1 words.
  If the byte sex of the segment is opposite to the host,
  any of these words must be byte-swapped before they are used.

  If TOS, the actual index, is in the range W1..W2,
  then jump W3 words from the current location,
  where W3 is the contents of the word pointed at by TOS.
  Otherwise do nothing.
}
var
  Low_Boundary, High_Boundary, Value: integer;        // these must be signed values
Begin
{$R-}
  BP      := POP();       // the value itself
  Value   := BP;          // get as a signed value
//AX      := GetBigB();   // byte offset of block
//XCHG(fAX.W, fDI);
  fDI     := GetBigB();   // byte offset of block
  DI      := DI + Globals.LowMem.CPOFFSET;  // displace into constant pool of curr seg
  if Globals.LowMem.SEXFLAG = 1 then        // if seg is of my byte sex
    begin
      Low_Boundary := DSWord[DI];          // get as a signed value
      if Value >= Low_Boundary then              // above the low boundary
        begin
          High_Boundary := DSWord[DI+2];   // get as a signed word
          if Value <= High_Boundary then         // below the high boundary
            begin
              BP      := BP - DSWord[DI];  // BP := BP - MIN INDEX
              BP      := BP SHL 1;    // # OF BYTES OFFSET
              // (DI) IS THE # OF BYTES PAST THAT WORD
              // THE CONTENTS OF THAT LOCATION IS ADDED
              // TO SI (THE IPC).
              SI      := SI + DSWord[BP+DI+4];//  (DI+4)  POINTS TO 1ST WORD IN CASE TABLE
            end
        end
    end
  else
    begin
      AX  := DSWord[DI];  // minimum
      XCHG(fAX.l, fAX.h);    //   flipped

      Low_Boundary := AX;
      if Value >= Low_Boundary then       //     and checked
        begin
          CX      := DSWord[DI+2];  // maximum
          XCHG(fCX.h, fCX.l);     //   flipped
          High_Boundary := CX;
          if Value <= High_Boundary then
            begin
              Value   := Value - Low_Boundary;        // subtract minimum
              Value   := Value SHL 1;                 //   make into byte offset
              AX      := DSWord[Value+DI+4];          // DIth  entry in jump table
              XCHG(fAX.l, fAX.h);                     //   flipped
              SI   := SI + AX;
{$R+}
            end
        end
    end;
end;

// EFJ: 210 ($D2)
// Equal False Jump. Jump by byte offset SB if TOS <> TOS-1.
procedure TIVPsystemInterpreter.EFJ;
begin
    AX := POP();
    BP := POP();
    if BP <> AX then
      UJP
    else
      SI := SI + 1;
end;

// NFJ: 211 ($D3)
// Not Equal False Jump. Jump by byte offset SB if TOS = TOS-1.
procedure TIVPsystemInterpreter.NFJ;
begin
    AX := POP();
    BP := POP();
    if BP = AX then
      UJP
    else
      SI := SI + 1;
end;

// TJP: 241 ($F1)
// True Jump. Jump by byte offset SB if TOS is true.
procedure TIVPsystemInterpreter.TJP;
begin
  AX      := POP();   // GET BOOLEAN
  if ODD(AX) then     // if odd, then it is true, so jump
    begin
{$R-}
      try
        AX := CBW(Bytes[ds+si]);   // note: sign extension into AX
        SI := SI + AX + 1;
      except
        Ax := AX;  // DEBUGGING
      end;
{$R+}
    end
  else
    SI := SI + 1;                 // INC SI TO SKIP SIGNED BYTE
end;

// UJP: 138 ($8A)
// Unconditional Jump. Jump by byte offset SB.
Procedure TIVPsystemInterpreter.UJP; {Unconditional jump}
var
  I: integer;
Begin
  AL  := Bytes[DS+SI];
  SI  := SI + 1;
{$R-}
  I   := CBW(AL);
  SI  := SI + I;         // add to IPC
{$R+}
end;

// FJP: 212 ($D4)
// False Jump. Jump by byte offset SB if TOS is false.
Procedure TIVPsystemInterpreter.FJP;
var
  i: integer;
Begin
    AX      := POP();       // GET BOOLEAN
    if not ODD(AX) then     // if true then don't jump
      begin
{$R-}
        I := CBW(Bytes[ds+si]);   // note: sign extension into I
        si := si + I;
{$R+}
      end;
    SI := SI + 1;
end;


procedure TIVPsystemInterpreter.UJPL;
var
  I: integer;
begin
//LODSW;            // PUT DISPLACEMENT IN AX
{$R-}
  I  := LODSW; // must do this first because it changes SI
  SI := SI + I;
{$R+}
end;

// FJPL: 213 ($D5)
// False Long Jump. Jump W bytes from current location if TOS is false.
procedure TIVPsystemInterpreter.FJPL;
begin
  AX      := POP();       // GET BOOLEAN
  if NOT ODD(AX) then     // if EVEN, then it is false, so jump
    UJPL
  else
    SI := SI + 2;                 // INC SI TO SKIP SIGNED BYTE

end;


//  Not Equal Integer. Push Boolean result of integer comparison TOS-1 <> TOS.
Procedure TIVPsystemInterpreter.NEQI;   {compare for <>}
Begin
{$R-}
  PUSH(POP()<>POP());
{$R+}
end;


// LEQI: 178 ($B2)
// Less than or Equal Integer. Push Boolean result of integer comparison
// TOS-1 <= TOS.
Procedure TIVPsystemInterpreter.LEQI;  {<=}
var a,b:integer;
Begin
{$R-}
  b := Pop();
  a := Pop();
  PUSH(a <= b);
{$R+}  
end;

procedure TIVPsystemInterpreter.LEUSW;
begin
  AX  := POP();
  BP  := POP();
  PUSH(BP <= AX);
end;

// GEUSW: 181 ($B5)
// Greater Than or Equal Unsigned. Push
// Boolean result of unsigned comparison TOS-1 >= TOS.
procedure TIVPsystemInterpreter.GEUSW;
begin
  AX  := POP();       // (TOS)
  BP  := POP();       // (TOS-1)
  PUSH(BP >= AX);     // (TOS-1) >= (TOS)
end;



{$IfDef debugging}
function TIVPsystemInterpreter.TOS: word;
begin
  result := WordAt[sp];
end;

// This version can be best used when debugging at the Delphi level

function TIVPsystemInterpreter.MemDumpDF( Addr: longword;
                                      Form: TWatchCode = 'W';
                                      Param: longint = 0;
                                      const Note: string = ''): string;
var
  wt: TWatchType;
begin
  if Length(Form) > 0 then
    begin
      wt := {DebuggerSettings.WatchList.}WatchTypeFromWatchCode(Form);
      result := inherited MemDumpDW(Addr, wt, Param, Note);
      if result = '' then
        result := MemDumpDW(Addr, wt, Param);
    end
  else
    result := 'Bad format';
end;

function TIVPsystemInterpreter.MemDumpDW( Addr: longword;
                                      Code: TWatchType = wt_HexWords;
                                      Param: longint = 0;
                                      const Note: string = ''): string;
const
  NRBYTES = 50;

var
  i: longword;
  b: byte;
//u: TUnion;
  SegNameStr: string[CHARS_PER_SEG_NAME];
  Delim: string;
//Nrb: word;

  function SegBaseFormat(SegAdr: longword; Param: word): string;
  var
    ProcPtrOffset,
    RelocListOffset,
    ByteSex,
    ConstPoolOffset, NumberOfProcedures,
    RealSubPoolOffset,
    RealSize,
    NumberOfRealConstants,
    AddrOfNumberOfRealConstants,
    AddrOfNumberProcedures, ConstPoolPtrAddr,
    RealSizeOffset: longword;
    SizeOfConstantPool: integer;
    SegName: string[8];

    procedure AddPiece(const aCaption: string; aVal: variant);
    var
      Piece: string;
    begin
      case VarType(aVal) of
        varSmallint, varInteger, varShortInt, varInt64:
          Piece := IntToStr(aVal);
        varWord, varLongWord:
          Piece := HexWord(aVal);
        varByte:
          Piece := HexByte(aVal);
        varString:
          Piece := aVal;
      end;
      Piece  := aCaption + '= ' + Piece;
      if result <> '' then
        result := result   + ', ' + Piece
      else
        result := Piece;
    end;

  begin { SegBaseFormat }
    result := PrefixInfo('SegBase', SegAdr, Note);  // 3/1/2023 "result" changed from below
//  result := '';
    if SegAdr <> 0 then
      if not Odd(SegAdr) then
        begin
          try
            ProcPtrOffset               := WordAt[SegAdr] * 2;    // * 2 (convert word offset to byte offset)
            RelocListOffset             := WordAt[SegAdr+2] * 2;
            SetLength(Segname, 8);
            Move(Bytes^[SegAdr+4], SegName[1], 8);
            ByteSex                     := WordAt[SegAdr+4+8];
            ConstPoolPtrAddr            := SegAdr+SEGCONST_; // (proc dict ptr) + (reloc list ptr) + (name of segment) + (byte sex indicator)
            ConstPoolOffset             := WordAt[ConstPoolPtrAddr] * 2;
            RealSubPoolOffset           := WordAt[SegAdr+ConstPoolOffset] * 2;
            AddrOfNumberOfRealConstants := SegAdr+RealSubPoolOffset;
            NumberOfRealConstants       := WordAt[AddrOfNumberOfRealConstants];
          //MainSubPoolAddr             := AddrOfNumberOfRealConstants + NumberOfRealConstants + 2;
            RealSizeOffset              := 4+8+2+2;
            RealSize                    := WordAt[SegAdr+RealSizeOffset];
            AddrOfNumberProcedures      := SegAdr+ProcPtrOffset;
            NumberOfProcedures          := WordAt[AddrOfNumberProcedures];
//          OutputDebugStringFmt('SegBase=%4.4x, ProcPtrOffset=%4.4x, ConstPoolOffset=%4.4x, NumberOfProcedures=%d ',
//                                 [SegAdr, ProcPtrOffset, ConstPoolOffset, NumberOfProcedures]);
            SizeOfConstantPool          := ProcPtrOffset - ConstPoolOffset - (NumberOfProcedures * 2);

            AddPiece('DictOffs',         ProcPtrOffset);
            AddPiece('RelocOffs',        RelocListOffset);
            AddPiece('SegName',          SegName);
            AddPiece('Sex',              ByteSex);
            AddPiece('CPOffset',         ConstPoolOffset);
            AddPiece('NrReal',           NumberOfRealConstants);
            AddPiece('RealSize',         RealSize);
            AddPiece('RealSubpOffs',     RealSubPoolOffset);
            AddPiece('NrProc',           NumberOfProcedures);
            AddPiece('ConstPoolSize',    SizeOfConstantPool);
          except
            on e:Exception do
              result := result + 'Invalid Segment Info: ' + e.message;
          end;
        end
      else
        result := Format('SegBase Odd address = %4x', [SegAdr])
    else
      result := result + 'INVALID ADDRESS FOR SEGMENT INFO';
  end;  { SegBaseFormat }

  function EVECFormat(EVECAddr: longword; Param: word = 0): string;
  var
    i: integer;
  begin { EVECFormat }
    case Param of
      0: begin  // expanded format
          result := PrefixInfo('EVEC', EvecAddr, Note);
          if Addr <> pNil then
            with TEvecPtr(@Bytes[EVECAddr])^ do
              begin
                result := result + Format('Vect_Length=%d, ', [Vect_Length]);
        {$R-}
                if Vect_Length > 255 then
                  result := result + '[BAD VECTOR]';

                for i := 1 to Min(Vect_Length, 60) do  // enough items to see what is going on
                  begin
                    result := result + Format('Map[%2d]=%4.4x', [i, Map[i]]);
                    if i < Vect_Length then
                      result := result + ', ';
                  end;
        {$R+}
              end
          else
            result := result + 'NIL';
         end;
      1: begin  // basic info only
          result := PrefixInfo('EVEC', EvecAddr, Note);
          if Addr <> pNil then
            with TEvecPtr(@Bytes[EVECAddr])^ do
              begin
                result := result + Format('Vect_Length=%d, ', [Vect_Length]);
        {$R-}
                if Vect_Length > 255 then
                  result := result + '[BAD VECTOR]';

                for i := 1 to Min(Vect_Length, 60) do  // enough items to see what is going on
                  begin
                    if Map[i] <> 0 then
                      result := result + Format('%4.4x', [Map[i]])
                    else
                      result := result +'0';

                    if i < Vect_Length then
                      result := result + ', ';
                  end;
        {$R+}
              end
          else
            result := result + 'NIL';
         end;
      else
        result := Format('%s: Unexpected param = %s', [result, Param]);
    end;

  end;  { EVECFormat }

  function VolInfoFormat(Addr: longword): string;
  begin { VolInfoFormat }
    result := PrefixInfo('VolInfo', Addr, Note);
    if Addr <> pNIL then
      with TVinfoPtr(@Bytes[Addr])^ do
        result := result + Format('Unit=%d, VID=%s', [SegUnit, SegVID])
    else
      result := result + 'NIL';
  end;  { VolInfoFormat }

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

  function SIBFormat(SibAdr: word; Param: word): string;
  begin { SIBFormat }
    result := PrefixInfo('SIB', SibAdr, Note);
    if SibAdr <> pNil then
      with TSibPtr(@Bytes[SibAdr])^ do
        begin
          if Param = 0 then
            begin
              SegNameStr := AlphaToStr(Seg_Name);

              SegNameStr := CleanUpString(Trim(SegNameStr), IDENT_CHARS, '?');   // Could just be garbage

              result := result + Format('Seg_Pool=%4.4x, SegBase=%4.4x, SegRefs=%d, TimeStamp=%3d, SegPieces=%d, '
+ 'Residency=%d, SegName=%-8s, SegLeng=%4d, SegAddr=%4d, VolInfo=%4.4x, DataSize=%4d, NextSIB=%4.4x, PrevSIB=%4.4x, MType=%s, NextSort=%4.4x, NewLoc=%4.4x',
                               [seg_pool, seg_base,
                                seg_refs, timestamp, seg_pieces, residency,
                                SegNameStr, Seg_Leng,
                                Seg_Addr, Vol_Info, Data_Size,
                                res_sibs.Next_SIB, res_sibs.Prev_SIB, MachTypeToStr(TMTypes(mtype)), res_sibs.next_sort, res_sibs.new_loc]);
            end else
          if Param = 1 then // link to the base info
            result := SegBaseFormat(Seg_Base, 0);
        end
    else
      result := result + 'NIL';
  end;  { SIBFormat }

  function ErecFormat(ErecAdr: word; Param: word): string;
  var
    SibAdr, SegBase, EvecAddr, VolInfoAddr: word;
  begin { ErecFormat }
    try
      case Param of
        0: // Erec
          begin
            result := PrefixInfo('EREC', ErecAdr, Note);
            if ErecAdr <> pNil then
              with TErecPtr(@Bytes[ErecAdr])^ do
                begin
{$R-}
                  result := result + Format('Env_Data=%s, Env_Vect=%s, Env_Sib=%s, link_count=%d, next_rec=%s',
                                   [Bothways(Env_Data), BothWays(Env_Vect), Bothways(Env_Sib), link_count, BothWays(next_rec)]);
{$R+}
                end
            else
              result := result + 'NIL';
          end;
        1: // EREC->SIB
          begin
            SIBAdr := TErecPtr(@Bytes[ErecAdr])^.Env_Sib;
            result := SIBFormat(SIBAdr, 0);
          end;
        2: // EREC->SIB->SegBase
          begin
            SIBAdr  := TErecPtr(@Bytes[ErecAdr])^.Env_Sib;
            SegBase := TSibPtr(@Bytes[SIBAdr])^.seg_base;
            result  := SegBaseFormat(SegBase, 0)
          end;
        3: // EREC->EVEC
          begin
            EvecAddr := TErecPtr(@Bytes[ErecAdr])^.env_vect;
            result   := EVECFormat(EvecAddr);
          end;
        4: // EREC->SIB->VolInfo
          begin
            SIBAdr      := TErecPtr(@Bytes[ErecAdr])^.Env_Sib;
            VolInfoAddr := TSibPtr(@Bytes[SIBAdr])^.vol_info;
            result      := VolInfoFormat(VolInfoAddr);
          end;
      end;
    except
      on e:Exception do
        result := Format('Invalid EREC @ $%x (Param:%d) [%s]', [ErecAdr, Param, e.Message]);
    end;
  end;  { ErecFormat }

  function TibFormat(TibAddr: longword; Param: word): string;
  var
    ErecAddr: word;
    SIBAddr: word;
  begin { TibFormat }
    with TTibPtr(@Bytes[TibAddr])^, regs do
      begin
        case Param of
          0: {TIB}
             result := PrefixInfo('TIB', TibAddr, Note) +
                  Format('wait_q=%4x, prior=%x, flags=%x, sp_low=%4x, sp_upr=%4x, sp=%4x, '+
                         'mp=%4x, task_link=%4x, ipc=%4x, env=%4x, ProcNum=%2s, TIBIoResult=%2d, '+
                         'hang_p=%2x, m_depend=%4x, task_stuff=%4x,  Start_Mscw=%4x',
                         [wait_q,prior,flags,sp_low,sp_upr,sp,
                          mp,task_link,ipc,env,frmPCodeDebugger.ProcNumStr(ProcNum),TibIoResult,
                          hang_p,m_depend, task_stuff, start_mscw]);

          1: {TIB->EREC}
            begin
              ERECAddr := ENV;
              result   := ERECFormat(ERECAddr, 0);
            end;

          2: {TIB->EREC->SIB}
            begin
              ERECAddr := ENV;
              with TErecPtr(@Bytes[ErecAddr])^ do
                result := SibFormat(env_sib, 0);
            end;

          3: {TIB->EREC->SIB->SegBaseFormat}
            begin
              ERECAddr := ENV;
              with TErecPtr(@Bytes[ErecAddr])^ do
                SibAddr := env_sib;
              with TSibPtr(@Bytes[SibAddr])^ do
                result := SegBaseFormat(seg_base, 0);
            end;
        end;
      end;
  end;  { TibFormat }

  function CallStack(MSCWFieldNr: TMSCWFieldNr): string;
  var
    MSCWAddr: word;
    MSCWp: word;
    p: TMscwPtr;
    aProcName: string;
    aSegNameIdx: TSegNameIdx;

    function GetSegBase: word;
    var
      ERECp: word;
      SIBAddr: word;
    begin
      Erecp    := TMSCWPtr(@Bytes[MSCWp])^.MSENV;     // MSCW.env --> ERECp
      SIBAddr  := TERECPtr(@Bytes[Erecp])^.ENV_SIB;   // EREC.env_sib --> TIBp
      result   := TSIBPtr(@Bytes[SIBAddr])^.seg_base; // TIB.seg_base --> Segment record
    end;

    Function NextMSCW(p: TMscwPtr; MSCWFieldNr: TMSCWFieldNr): word;
    begin { NextMSCW }
      with p^ do
        case MSCWFieldNr of
          csDynamic:
            result := DYNLINK;
          csStatic:
            result := STATLINK;
          else
            raise Exception.Create('System error: invalid call stack type');
      end;
    end;  { NextMSCW }

    function Addrs(p: word): string;
    begin
      result := Format('@%4x=', [p]);
    end;

    function IPCWithinProc(anIPC, ErecAddr: word; ProcNr: integer): word;
    var
      Erec: TErec;
      SIB   : TSib;
      Seg   : word;
      aProcBase: word;
    begin
      Erec := TErecPtr(@Bytes[ErecAddr])^;
    {$R-}
      SIB  := TSibPtr(@Bytes[Erec.env_sib])^;
      Seg  := SIB.Seg_Base;

      aProcBase := CalcProcBase(SEG, Abs(ProcNr));

      result := anIPC - aProcBase;
    {$R+}
    end;

    function IPCWithinProcStr(anIPC, ErecAddr: word; ProcNr: integer): string;
    begin { IPCWithinProc }
      result := IntToStr(IPCWithinProc(anIPC, ErecAddr, Abs(ProcNr)));  // ProcNr in MSCW may be negative during S_EXIT
    end;  { IPCWithinProc }

    procedure AddProcCall(MSCWAddr: word; const aProcName, anIpc: string);
    var
      OneProc: string;
    begin { AddProcCall }
      OneProc := Format('%s @ %s', [aProcName, anIPC]);
      if result = '' then
        result := OneProc
      else
        result := result + ', ' + OneProc;
    end;  { AddProcCall }

  begin { CallStack }
      result   := '';
      MscwAddr := MP;
      p        := TMscwPtr(@Bytes[MscwAddr]);

      AddProcCall(MscwAddr, ProcName(Globals.LowMem.CurProc, DS), IntToStr(SI-ProcBase));  // First the current procedure

      try
        if (p^.MSPROC <> 0) then
          begin
            while (MscwAddr <> 0) and (MscwAddr <> MAINMSCWp) and (p^.MSProc <> 0) do
              begin
                if p^.MSProc <> 0 then
                  begin
{$R-}               // MSPROC may be negative
                    if Assigned(frmPCodeDebugger) then
                      begin
                       with frmPCodeDebugger as TfrmPCodeDebugger do
                         begin
//                         GetAccDbAndSegNameIdx(p^.MSENV, TheSegNameIdx);
//                         aSegNameIdx := TheSegNameIdx(p^.MSENV);  // 12/11/2023 - I don't think that this does anything useful
                                                                    //              make sure that
                           aProcName   := ProcNameFromErec(p^.MSPROC, p^.MSENV);
                         end;
                      end
                    else
                      begin
                        aProcName := ProcName(p^.MSPROC, P^.MSENV);
                      end;
                    MscwAddr  := NextMSCW(p, MSCWFieldNr);
                    AddProcCall(MscwAddr, aProcName, IPCWithinProcStr(p^.MSIPC, p^.MSENV, p^.MSPROC));
{$R+}
                    p         := TMscwPtr(@Bytes[MscwAddr]);
                  end;
              end;
            result := 'CallStack: ' + result;
          end;
      except
        on ex:Exception do
          AddProcCall(MscwAddr, ex.Message, aProcName);
      end;
  end;  { CallStack }

  function ShowDirEntry(Addr: longword): string;
  var
    Dir: DirEntry;
    TimeStr: string;
  begin { ShowDirEntry }
    Move(Bytes[Addr], Dir, SizeOf(DirEntry));
    with Dir do
      begin
        if (DFKind and $FFF0) <> 0 then
          TimeStr := Format('%2d:%2d', [HourOf(DFKind), MinutesOf(DFKind)])
        else
          TimeStr := '00:00';
        result := Format('DFirstBlk=%d, DLastBlk=%d, DFKind=%d, Time=%s', [DFIRSTBLK, DLASTBLK, DFKIND and $F, TimeStr]);
        case DFKIND of
          kSECUREDIR,
          kUNTYPEDFILE:
            result := result + Format(', DVID=%s, DeovBlk=%d, DNumFiles=%d',
                                                  [DVID, DLASTBLK, DNUMFILES]);
          else
            begin
              result := result + Format(', DTID=%s', [DTID]);
            end;
        end;
      end;
  end;  { ShowDirEntry }

{$R-}
  function RegValues(AsHex: boolean): string;

    function RegValue(Reg: string; Num: word): string;
    begin { RegValue }
      if AsHex then
        result := Format('%s=$%4s, ', [Reg, HexWord(Num)])
      else
        result := Format('%s=%d, ', [Reg, Num]);
    end; { RegValue }

  begin { RegValues }
    RegValue('BP', BP);
    with Globals.LowMem do
    result := RegValue('AX', AX) + RegValue('LocalVar', LocalVar) + RegValue('CX', CX) + RegValue('GlobVar', GlobVar)
            + RegValue('SI', SI) + Regvalue('DI', DI) + RegValue('BP', BP) + RegValue('SP', SP)
            + Regvalue('DS', DS) + RegValue('ES', ES) + RegValue('CS', CS)
            + RegValue('MP', MP) + RegValue('MPPlus', MPPlus) + RegValue('BASEPLUS', BASEPLUS)
            + RegValue('SEGB', SEGB) + RegValue('BASE', BASE) + RegValue('CURPROC', CURPROC)
            + RegValue('SIBP', SIBP) + RegValue('SEGTOP', SEGTOP) + RegValue('READYQ', READYQ)
            + RegValue('EVECp', EVECp) + RegValue('CURTASK', CURTASK) + RegValue('ERECp', ERECp)
            + RegValue('CPOFFSET', CPOFFSET)
  end;  { RegValues }
{$R+}

  function SetValue(Addr: longword; NrWords: word = 0): string;
  var
    wc, i, aWord: word;
    Prefix: string;
  begin { SetValue }
    aWord := $FFFF;
    wc    := $FFFE;
    i     := $FFFD;
    try
      if NrWords <> 0 then
        begin
          wc   := NrWords;     // length passed as a parameter
          Addr := Addr - 2;    // first word is data
        end
      else
        begin
          wc := WordAt[Addr];  // first word is length
        end;

      result := '';
      Prefix := Format('%2d words: ', [wc]);
      if wc <= 32 then // plausible set
        begin
          I := 0;
          repeat
            Addr   := Addr + 2;
            aWord  := WordAt[Addr];
            result := HexWord(aWord) + ',' + result;
            I := I + 1;
          until i = wc;
          result := Prefix + result;
        end
      else
        result := Prefix + 'Impossible set';
    except
      on e:Exception do
        result := Format('Exception in SetValue: [%s] wc=%d, i=%d, Addr=%x, aWord=%x',
                         [e.Message, wc, i, Addr, aWord]);
    end;
  end;  { SetValue }

  function CharSet(Addr: word): string;
  var
    wc, wn, aWord: word;
    Prefix, Region: string;
    c, BitNr, LastBitNr, LowBit, HighBit: byte;
    Contiguous, PrevBitWasSet: boolean;
(*
    function CharName(BitNr: word): string;
    begin { CharName }
      if (BitNr >= ord(' ')) and
         (BitNr < 127) then
        result := '''' + chr(BitNr) + ''''
      else
        result := '#' + IntToStr(BitNr);
    end;  { CharName }
*)
    procedure AddRegion(const s: string);
    begin { AddRegion }
      if result = '' then // nothing so far
        result := s
      else
        result := result + ',' + s
    end;  { AddRegion }

    procedure Checkit;
    begin
      if Contiguous then  // we were in a contiguous region
        begin
          HighBit := BitNr - 1;
          if HighBit > LowBit then  // it has more than one element (IS THIS ALWAYS TRUE?)
            begin
              Region := CharName(LowBit) + '..' + CharName(HighBit);
              AddRegion(Region);    // output the region string
              Contiguous := false;
            end
          else                      // only had the previous bit
            begin
              Region := CharName(LastBitNr);
              AddRegion(Region);
            end;
        end;
    end;

  begin { CharSet }
    aWord := $FFFF;
    wc    := $FFFE;
    LowBit := 0;
    Contiguous := false;
    PrevBitWasSet := false;
    try
      wc := WordAt[Addr];
      result := '';
      Prefix := Format('%2d words: [', [wc]);
      if (wc > 0) and (wc <= 32) then // plausible set
        begin
          wn := 0;
          repeat
            Addr   := Addr + 2;
            aWord  := WordAt[Addr];
            for c := 0 to 15 do
              begin
                BitNr := (wn * 16) + c;
                if (aWord and 1) <> 0 then //  bit is set
                  begin
                    if not Contiguous then // not already in a contiguous region
                      begin
                        Contiguous := PrevBitWasSet;
                        LowBit     := BitNr - 1;
                      end;
                    PrevBitWasSet := true;
                  end
                else
                  begin
                    PrevBitWasSet := false;
                    CheckIt;
                  end;
                aWord := aWord shr 1;
                LastBitNr  := BitNr;
              end;
            wn := wn + 1;
          until wn = wc;
          CheckIt;
          result := Prefix + result + ']';
        end
      else
        result := Prefix + 'Impossible set';
    except
      on e:Exception do
        result := Format('Exception in SetValue: [%s] wc=%d, i=%d, Addr=%x, aWord=%x',
                         [e.Message, wc, i, Addr, aWord]);
    end;
  end;  { CharSet }

  function DumpChSet(WordCount: word; Addr: word): string;
  var
    i: word;
    WordSet: array of word;
    bit: word;
    Element: string;

    function QuoteBit(BitNr: word): string;
    begin
      if (chr(BitNr) >= ' ') and (BitNr < 128) then
        result := '''' + chr(Bitnr) + ''''
      else
        result := Format('#%d', [BitNr]);
    end;

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

  begin { DumpChSet }
    SetLength(WordSet, WordCount);
    for i := 0 to WordCount-1 do
      WordSet[i] := WordAt[Addr + (i*2)];

    result := '';
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
    result := '[' + result + ']';
  end;  { DumpChSet }

  function VectorInfo(func: TWatchType; Param: word): string;
  var
    EvecP: TEvecPtr;

    ErecAddr: word;
    ErecP: TErecPtr;
    Erec: TErec;

    SibAddr: word;
    SibP: TSibPtr;
    Sib: TSib;
    
    SegAddr: word;
  begin { VectorInfo }
    Evecp  := TEvecPtr(@bytes[Addr]);
//  Evec   := Evecp^;                // This does not copy the entire vector!
    {$R-}
    if func = wt_V_VectorMap then      // display the Nth vector
      begin
        if param = 0 then
          result := PrefixInfo('VecLen', Addr) + Format('Length = %d', [Evecp^.vect_length])
        else
          result := PrefixInfo('Vector', Addr) + Format('%s', [BothWays(Evecp^.Map[param])]);
      end;

    if func in [ wt_W_ErecFromVectorMapN,
                 wt_X_SibFromVectorMapN,
                 wt_Y_SegBaseFromVectorMapN] then      // display the erec referenced
      begin                              // This probably isn't working. Change to use the ErecFormat with a param
        try
          ErecAddr := Evecp^.map[param];
          ErecP    := TErecPtr(@bytes[ErecAddr]);
          Erec     := ErecP^;

          SibAddr  := Erec.env_sib;
          SibP     := TSibPtr(@Bytes[SibAddr]);
          Sib      := SibP^;

          SegAddr   := SIB.seg_base;

          case func of
            wt_W_ErecFromVectorMapN:
              result := PrefixInfo('EREC', ErecAddr) + ErecFormat(ErecAddr, Param);
            wt_X_SibFromVectorMapN:
              result := PrefixInfo('SIB', SIBAddr) + SIBFormat(SIBAddr, Param);
            wt_Y_SegBaseFromVectorMapN:
              result := PrefixInfo('SegBase', SegAddr) + SegBaseFormat(SegAddr, Param);
          end;

        except
          result := result + Format('Exception processing form = %s', [WatchTypesTable[Func].WatchName]);
        end;
      end;
    {$R+}
  end;  { VectorInfo }

  function SemaphoreFormat(Addr: longword): string;
  begin { SemaphoreFormat }
    with TSemaphorePtr(@Bytes[Addr])^ do
      result := Format('Sem_Count= %4d, sem_wait_q= %10s', [Sem_Count, BothWays(sem_wait_q)]);
  end;  { SemaphoreFormat }

  function FIBFormat(addr: longword): string;
  const
    HEADER_OFFSET = 54;
  type
    StateTypes = (FJandW, FNeedChar, FGotChar);

    TDummy = record                 // easier to get to the FHEADER info
             case integer of
               0: (aFib: TFib);
               1: (dummy: packed array[0..HEADER_OFFSET-1] of byte;
                   FHeader: DirEntry);
             end;

    TDummyPtr = ^TDummy;
  var
    IsOpen,
    EOLN,
    EOF,
    BufChngd,
    Modified, IsBlkd: boolean;
    BitNr,
    State,
    ReptCnt: byte;
    DirRoot: word;
    VID: string[VIDLENG];
    StateStr: string;
    DirInfo: DirEntry;

//  All of the following is packed into a single word
//        {bit 0} FEoln,
//        {1}     FEof:     boolean;
//        {2-3}   FState:   (0=FJandW, 1=FNeedChar, 2=FGotChar);
//        {7}     FBufChngd,
//        {6}     FModified,            {new date must be set by close}
//        {5}     FIsBlkd,              {file is on blocked device}
//        {4}     FIsOpen:  boolean;
//        {8-15}  FReptCnt: byte;       {blank expansion repetition count}
  begin { FIBFormat }
    with TFIBPtr(@Bytes[Addr])^ do
      begin
        BitNr    := 0;
        EOF      := Boolean(Bits(Stuff, BitNr, 1));
        EOLN     := Boolean(Bits(Stuff, BitNr, 1));
//      NrBits   := 1;
        State    := Bits(Stuff, BitNr, 2);
        IsOpen   := Boolean(Bits(Stuff, BitNr, 1));
        IsBlkd   := Boolean(Bits(Stuff, BitNr, 1));
        Modified := Boolean(Bits(Stuff, BitNr, 1));
        BufChngd := Boolean(Bits(Stuff, BitNr, 1));
        ReptCnt  := Bits(Stuff, BitNr, 8);
        DirRoot    := DiskAddr_to_Word(FDirRoot);

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

        result := PrefixInfo('FIB', Addr, Note) +
                  Format('FWindow=%x,FRecSize=%d,Flock=%S,FIsOpen=%s,ReptCnt=%d',
                         [FWINDOW,     FRECSIZE,    SemaphoreFormat(Addr+6), TFString(ISOPEN), ReptCnt]);
//      if IsOpen then
          result := result + Format(', FIsBlkd=%s,FUnit=%d,FVID=%s,DirRoot=%d,FModified=%s,FTempFile=%s,FExclusive=%s, ',
                                    [TFString(ISBLKD),
                                                  FUNIT,   VID,   DirRoot,    TFString(Modified),
                                                                                             TFString(FTempFile),
                                                                                                           TFString(FExclusive)]) +
                             Format('EOF=%s, EOLN=%S, State=%s, IsBlkd=%s, BufChngd=%s',
                                    [TFString(EOF), TFString(EOLN), StateStr, TFString(IsBlkd), TFString(BufChngd)]);
        // the rest of a FIB may not be properly aligned on Delphi boundaries
        with TDummyPtr(@Bytes[Addr])^ do
          begin
            DirInfo := FHeader;
//          result := result + MemDump(Addr + HEADER_OFFSET, wt_ascii);
            result  := result + ',' + ShowDirEntry(Addr + HEADER_OFFSET);
          end
      end;
  end;  { FIBFormat }

  function ParamDescriptorFormat(Addr: longword): string;
  begin { ParamDescriptorFormat }
    with TParameterDescriptorPtr(@Bytes[Addr])^ do
      result := PrefixInfo('Parm Descr', Addr, Note)
                  + Format('ERecp=$%4x, source_offset=$%4x',
                            [addr_of_ERec, source_offset]);
  end;  { ParamDescriptorFormat }

  function HeapInfoFormat(addr: longword): string;
  begin
    with THeap_InfoPtr(@Bytes[Addr])^ do
      begin
        result := PrefixInfo('Heap_Info', Addr, NOte) +
                  Format('Lock=%s, Heap_Top=$%4x, Top_Mark=%4x',
                         [SemaphoreFormat(Addr), Heap_Top, Top_Mark]);
      end;
  end;

  function TaskInfoFormat(Addr: longword): string;
  var
    S1, S2: string;
  begin
    with TTask_infoPtr(@Bytes[Addr])^ do
      begin
        S1 := SemaphoreFormat(Addr);
        S2 := SemaphoreFormat(Addr + SizeOf(TSemaphore));  // cheating to get an address
        result := PrefixInfo('Task_Info', Addr) +
                    Format('Task_done= %s, Lock= %s, n_tasks= %d',
                           [S1, S2, n_tasks]);
      end;
  end;

  function PedPseudoSIBFormat(Addr: longword): string;
  var
    BitNr: byte;
    Ps_Mach_Type: TMTypes;
    Relocatable: boolean;
  begin
    with TPedSseudoSibPtr(@Bytes[Addr])^ do
      begin
        BitNr        := 0;
        with PsSegAttributes do
          begin
            Relocatable  := Boolean(Bits(Attributes, BitNr, 1));  { bit 0 }
            ps_mach_type := TMTypes(Bits(Attributes, BitNr, 4));  { bit 1..4 }
          end;
        result := PrefixInfo('PedPseudoSIB', Addr) +
                  Format('PsSegName=%s, PsSegLeng=%d, PsSegAddr=$%4x, PsSegDataSize=%4d, PsSegLibNum=%d, Relocatable=%s, PsMachType:%s',
                         [AlphaToStr(PsSegName), PsSegLeng, PsSegAddr, PsSegDataSize,
                          PsSegLibNum, TFString(Relocatable), MachTypeToStr(Ps_Mach_Type)]);
      end;
  end;

  function AlphaFormat(const Seg_Name: TSegment_name): string;
  var
    SegNameStr: string[CHARS_PER_SEG_NAME];
  begin
    SetLength(SegNameStr, CHARS_PER_SEG_NAME);
    Move(Seg_Name[0], SegNameStr[1], CHARS_PER_SEG_NAME);
    result := Format('Seg_Name=%s', [SegNameStr]);
  end;

  function SegDictFormat(Addr: longword; Param: longint): string;

    function SegCodeRecFormat(const Seg_Code_Rec: TSeg_Code_Rec): string;
    begin
      with Seg_Code_Rec do
        result := Format('code_addr=%d, code_leng=%d', [code_addr, code_leng]);
    end;

    function SegMiscRecFormat(const Seg_Misc_Rec: TSeg_Misc_Rec): string;
    begin
      with Seg_Misc_Rec do
        result := Format('SegMisc=%s', [BothWays(SegMiscRec)]);
    end;

    function SegTextFormat(const Seg_Text_Rec: integer): string;
    begin
      result := Format('Seg_Text=%d', [Seg_Text_Rec]);
    end;

    function SegFamilyRecFormat(const Seg_Famly_Rec: TSeg_Famly_Rec): string;
    begin
      with Seg_Famly_Rec do
        result := Format('data_size= %d, seg_ref_words=%d, max_seg_size=%d, text_size=%d',
                         [data_size, seg_ref_words, max_seg_num, text_size]);

    end;

    var
      p: TSeg_DictPtr;
  begin { SegDictFormat }
    result := PrefixInfo('SegDict', Addr);
    try
      p := TSeg_DictPtr(@Bytes[Addr]);
      with p^ do
        if Param >= 0 then
           result := result +
                    SegCodeRecFormat(Disk_Info[Param]) + ', ' +
                    AlphaFormat(Seg_Name[Param]) + ', ' + 
                    SegMiscRecFormat(Seg_Misc[Param]) + ', ' +
                    SegTextFormat(Seg_Text[Param]) + ', ' +
                    SegFamilyRecFormat(Seg_Family[Param]) + ', ' +
                    Format('next_dict=%d, ped_block=%d, ped_blk_count=%d, Sex=%d, Copyright=%s',
                           [next_dict, ped_block, ped_blk_count, Sex, Copyright])
        else
          result := result +
                    Format('checksum=%4.4x, ped_block=%d, ped_blk_cnt=%d, part_number=%4.4x:%4.4x, copyright=%s, sex=%d',
                           [checksum, ped_block, ped_blk_count, part_number[0], part_number[1], copyright, sex]);
    except
      on e:ERangeError do
        begin
          result := Format('%s is invalid. (%s)', [result, e.Message]);
        end;
    end;
  end;  { SegDictFormat }

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

  function UnitTableFormat(TableAddr: longWord; Param: word): string;
  var
    aUVID, aUPVID: string;   // Strings stuffed into pSystem records don’t always
                           // have a trailing zero byte so I copy them to local variables to fix.

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

      result := Format('UIsBlkd=%s,UIsSpecial=%s,SpecialBuf=%s,StdaMap=%s,UIsLocLocked=%s',
                       [TFString(UIsBlkd), TFString(UIsSpecial), TFString(SpecialBuf), TFString(StdaMap), TFString(UIsLocLocked)]);

    end;  { PackedStuff }

  begin { UnitTableFormat }
//  if Param <> 0 then
      with TUTablePtr(@Bytes[Addr])^[Param] do
        begin
          aUVID  := UVID;
          aUPVID := UPVID;
          result := PrefixInfo('UTablEntry', Addr) +
                    Format('Uvid=%-8s,%s,UEovBlk=%5d',
//                  Format('Uvid=%-8s, UEovBlk=%5d',       // Ignoring packed stuff for now
                           [aUVID, PackedStuff(Packed_Stuff), UEovBlk]);
          if UEovBlk <> 0 then
            result := result + Format(',uphysvol=%d,ublkoff=%d,upvid=%s',
                                      [uphysvol, ublkoff, aUPVID]);
        end;

  end;  { UnitTableFormat }

  function UnitTableEntryFormat(EntryAddr: word): string;
  begin
    result := UnitTableFormat(EntryAddr, 0);
  end;

  function StringFormat(Addr: longword): string;
  var
    Len: integer;
    i: longword;
    ch: char;
  begin
    Len := Bytes[Addr];
    SetLength(result, Len);
    for i := 1 to Len do
      begin
        if Addr + i >= HIMEM then
          break;
        ch := chr(Bytes[Addr+i]);
        if ch in [' '..#127] then
          result[i] := ch
        else
          result[i] := '?';
      end;
    result := Format('Len=%d, ''%s''', [Len, result]);
  end;

  function StringDescriptorFormat(Addr: longword): string;
  var
    Src: longWord;
    SrcO, SibAddr, SegAddr, ErecAddr: word;
    P: TParmDescPtr; 
  begin
    P             := TParmDescPtr(@Bytes[Addr]);
    Src           := 0;
    SrcO          := p^.Parm_Addr;
    ErecAddr      := p^.Erec_Addr;
    if ErecAddr <> pNIL then      // 10. then ErecP points to ERec
      begin
        with TErecPtr(@Bytes[ErecAddr])^ do
          begin
            SibAddr  := Env_SIB;  // 10. else BP := ^Sib
            with TSibPtr(@Bytes[SibAddr])^ do
              begin
                SegAddr  := Seg_Base; // 11. AX := ^segment
                if SegAddr <> pNIL then   // 12. If segment present
                  Src := PoolBase(Seg_Pool) + SegAddr;
              end;
          end;
      end;

    result := StringFormat(Src+SrcO);
  end;

  function RealFormat(Addr: longword): string;
  var
    temp: TRealUnion;
  begin
    temp   := RealAt[Addr];
    result := FloatToStr(temp.UCSDReal4);
  end;

  function HexWordsFormat(Addr: longword; nrb: word): string;
  var
    i: word;
    u: TUnion;
  begin
    i := 0;
    result := '';
    while (i < Nrb) and (Addr+i < HiMem) do
      begin
        u.l := Bytes[Addr+i];
        i := i + 1;
        u.h := Bytes[Addr+i];
        i := i + 1;
        result := result + ' ' + HexWord(u.W);
      end;
  end;
(*
  function SegDictFormat(Addr: longword; Param: longint): string;

    function SegCodeRecFormat(const Seg_Code_Rec: TSeg_Code_Rec): string;
    begin
      with Seg_Code_Rec do
        result := Format('code_addr=%d, code_leng=%d', [code_addr, code_leng]);
    end;

    function SegMiscRecFormat(const Seg_Misc_Rec: TSeg_Misc_Rec): string;
    begin
      with Seg_Misc_Rec do
        result := Format('SegMisc=%s', [BothWays(SegMiscRec)]);
    end;

    function SegTextFormat(const Seg_Text_Rec: integer): string;
    begin
      result := Format('Seg_Text=%d', [Seg_Text_Rec]);
    end;

    function SegFamilyRecFormat(const Seg_Famly_Rec: TSeg_Famly_Rec): string;
    begin
      with Seg_Famly_Rec do
        result := Format('data_size= %d, seg_ref_words=%d, max_seg_size=%d, text_size=%d',
                         [data_size, seg_ref_words, max_seg_num, text_size]);

    end;

  begin { SegDictFormat }
    result := PrefixInfo('SegDict', Addr);
    with TSeg_DictPtr(@Bytes[Addr])^ do
      if Param >= 0 then
         result := result +
                  SegCodeRecFormat(Disk_Info[Param]) + ', ' +
                  AlphaFormat(Seg_Name[Param]) + ', ' +
                  SegMiscRecFormat(Seg_Misc[Param]) + ', ' +
                  SegTextFormat(Seg_Text[Param]) + ', ' +
                  SegFamilyRecFormat(Seg_Family[Param]) + ', ' +
                  Format('next_dict=%d, ped_block=%d, ped_blk_count=%d, Sex=%d, Copyright=%s',
                         [next_dict, ped_block, ped_blk_count, Sex, Copyright]) 
      else
        result := result +
                  Format('checksum=%4.4x, ped_block=%d, ped_blk_cnt=%d, part_number=%4.4x:%4.4x, copyright=%s, sex=%d',
                         [checksum, ped_block, ped_blk_count, part_number[0], part_number[1], copyright, sex]);
  end;  { SegDictFormat }
*)
begin { MemDumpDW }
  result := inherited MemDumpDW(Addr, Code, Param);

  if result = '' then
  case Code of
    wt_Semaphore, wt_SemaphoreP:   // indirection must have already been handled
      result := SemaphoreFormat(Addr);

    wt_ERECp:
      result := ErecFormat(Addr, Param);

    wt_TIBp:
      result := TibFormat(Addr, Param);

    wt_SIBp:
      result := SIBFormat(Addr, Param);

    wt_MSCWp:
      begin
  {$R-} // MSPROC is a word but ProcNumStr() expects an integer
        with TMSCWPtr(@Bytes[Addr])^ do
          begin
            result := PrefixInfo('MSCW', Addr) +
                      Format('StatLink=%4s, DynLink=%4s, MSIPC=%4s, MSENV=%4s, MSPROC=%s, LocalData[0]=%s',
                             [HexWord(STATLINK), HexWord(DYNLINK), HexWord(MSIPC), HexWord(MSENV), ProcNumStr(MSPROC),
                              HexWord(LocalData[0])]);
  {$R+}
          end;
      end;

    wt_EVECp:
      Result := EVECFormat(Addr, Param);

    wt_Poolinfo:
      with TPoolInfoPtr(@Bytes[Addr])^ do
        result := PrefixInfo('PoolInfo', Addr) + Format('PoolOutside=%s, PoolSize=%d, PoolBase=%8.8x, Resolution=%d',
                           [TFString(pooloutside),
                            poolsize,
                            FulladdressToLongWord(PoolBaseAddr),
                            resolution]);

    wt_PoolDescInfo:
      with TPoolDescInfoPtr(@Bytes[Addr])^ do
          result := PrefixInfo('PoolDescInfo', Addr) + Format('PoolBase=$%8.8x, PoolSize=$%x, MinOffset=%s, MaxOffset=%s, Resolution=$%x, PoolHead=$%x, PermSIB=$%x, Extended=%s, NextPool=$%x, MustCompact=%s',
                             [FullAddressToLongWord(PoolBaseAddr),
                              poolsize, BothWays(minoffset), BothWays(maxoffset), resolution, poolhead, permsib,
                              TFString(extended), nextpool, TFString(mustcompact)]);

    wt_ProcedureName:
      with Globals.LowMem do
        result := Format('%s', [ProcName(CURPROC, Addr)]);

    wt_FIBp, wt_FIB:
      result := FIBFormat(Addr);

    wt_FaultMessage:
      begin
        with SyscomPtr^.fault_sem.Fault_Message do
          begin
//          Addr   := Integer(@TGlobals(nil^).Lowmem.Syscom.fault_sem.Fault_Message); // this gives the offset within SysCom of the Fault Handler
            Addr   := Integer(@TSyscomPtr(nil^).fault_sem.Fault_Message); // this gives the offset within SysCom of the Fault Handler

            result := PrefixInfo('FaultMessage', Addr) +
                      Format('fault_tib=%s, fault_erec=%s, fault_words=%d, fault_type=%s',
                                      [BothWays(fault_tib), BothWays(fault_e_rec), fault_words, FaultTypeStr(fault_type)]);
            if Param = 0 then
              Delim := '; '
            else
              Delim := CRLF + CRLF;

            if Fault_TIB <> 0 then
              result := result  + Delim + TibFormat(fault_tib, 0);

            if fault_e_rec <> 0 then
              begin
                result := result + Delim + ErecFormat(fault_e_rec, 0);
                with TErecPtr(@Bytes[fault_e_rec])^ do
                  begin
                    if env_sib <> 0 then
                      begin
                        result := result + Delim + SibFormat(env_sib, 0);
                        with TSibPtr(@Bytes[env_sib])^ do
                          if Seg_Base <> 0 then
                            result := result + Delim + SegBaseFormat(Seg_Base, 0);
                      end;
                  end;
              end;
          end;
      end;

    wt_OpCodesDecoded:
      result := PrefixInfo('Decoded', Addr)
                + DecodedRange(addr, NRBYTES, Addr);

    wt_DynamicCallStack:
      result := 'Dynamic: ' + CallStack(csDynamic);

    wt_StaticCallStack:
      result := 'Static: ' + CallStack(csStatic);

    wt_RegDumpHex:
      result := 'Regs(hex): ' + RegValues(true);  // Hex values

    wt_RegDumpDec:
      result := 'Regs(dec): ' + RegValues(false);  // Decimal values

    wt_SegBaseInfo:
      result := SegBaseFormat(Addr, Param);

    wt_V_VectorMap,
    wt_W_ErecFromVectorMapN,
    wt_X_SibFromVectorMapN,
    wt_Y_SegBaseFromVectorMapN:
      result := VectorInfo(Code, Param);

    wt_MemInfo:
      begin
        with TMemInfoPtr(@Bytes[Addr])^ do
          result := PrefixInfo('MemInfo', Addr) + Format('NWords=%d, %s, %s',
                           [NWords,
                            SocketPoolInfoS('FreeSpaceInfo',  FreeSpaceInfo),
                            SocketPoolInfoS('SocketPoolInfo', SocketPoolInfo)]);
      end;

    wt_ParamDescrP:
      Result := ParamDescriptorFormat(Addr);

    wt_HeapInfo:
      result := HeapInfoFormat(Addr);

    wt_TaskInfo:
      result := TaskInfoFormat(Addr);

    wt_Ped_Pseudo_Sibp:
      result := PedPseudoSIBFormat(Addr);

    wt_PedHeader:
      result := PedHeaderFormat(Addr);

    wt_SegRecP:   // indirection must have already been handled
      result := SegRecFormat(Addr);

//  wt_DiskAddress:
//    result := PrefixInfo('DiskAddress', Addr) +
//              Format('(%d)', [DiskAddr_to_Word(?)]) +
//              ByteFormat(Addr, 3);

    wt_UnitTableP:
      result := UnitTableFormat(Addr, Param {0=all, n=UNUM});

    wt_UnitTabEntry:
      result := UnitTableEntryFormat(Addr);

    wt_StringP:
      result := PrefixInfo('SDesc', Addr) +
                StringDescriptorFormat(Addr);

    wt_FullAddress:
      result := PrefixInfo('Full Address', Addr) +
                HexWordsFormat(Addr, 4);

    wt_SegDict:
      result := SegDictFormat(Addr, Param);
  end;
end;  { MemDumpDW }

{$EndIf}

{**************** SET ARITHMETIC  *************************************}

Procedure TIVPsystemInterpreter.Setup;
begin
  BP      := Pop();       // BP:=SIZEB
  AX      := BP;          // AL:=SIZEB
  BP      := BP shl 1;    // GET TO SIZEA
  BP      := BP + SP;     // BP POINTS TO SIZEA
  AH      := Bytes[BP];// AH:=SIZEA
  NEWSP   := BP;          // FUTURE SP
  BP      := BP + 2;      // SKIP OVER SIZEA AND POINT TO SETA
  CH      := 0;           // CX IS USED AS LOOP COUNT IN ALL CALLERS TO SETUP
end;

Procedure TIVPsystemInterpreter.Setup( var SIZEA, SIZEB: WORD;
                                     var NEWSP: WORD;
                                     var SETA, SETB: WORD;
                                     var CX: word);
{routine to give needed information about sets on the stack
 to INT, DIF, and UNI set operators}

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
      AH:=SIZEA & AL:=SIZEB
      NEWSP = New stack pointer
}
Begin
//POP     DI              // RETURN ADDRESS
  SIZEB   := Pop();       // BP:=SIZEB
  SIZEA   := Bytes[(SIZEB shl 1) + SP];   // AH:=SIZEA
  NEWSP   := BP;          // FUTURE SP
  SETA    := BP + 2;      // SKIP OVER SIZEA AND POINT TO SETA
  SETB    := SP;
  CX      := 0;           // CX IS USED AS LOOP COUNT IN ALL CALLERS TO SETUP
end;


// ADJ: 199 ($C7)
// Adjust Set.
// Force the set TOS to occupy UB words, either by expansion
// (adding zeroes "between" TOS and TOS-1) or compression
// (chopping of high words of set), and discard its length word.
// After this operation, if less than 20 words are available to the
// Stack, cause a Stack fault.
Procedure TIVPsystemInterpreter.ADJ;
var
  ByteCnt: word;
  RequestedSize {al}  : word;    // In words
  ActualSize {di}     : word;    // In words
  OldSrc {si}         : word;
  SizeDif {ax}        : word;
  Dst                 : word;
  CurrentHigh         : word;
  FutureHigh          : word;
begin
  // We assume both sizes >= 0.
  RequestedSize := Bytes[DS+SI];   // 2. GET REQUESTED SET SIZE IN WORDS (AL)
  SI      := SI + 1;

  ActualSize      := POP();        // 4. GET ACTUAL SET SIZE
  if ActualSize < RequestedSize then
    begin  // expand
      SaveIPC;                     // 27.
      OldSrc := SP;                // 28. SOURCE OF OLD SET POINTED TO BE SI

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

      CX      := 0;           // 47. Check Stack for no space

      Assert(DS=Globals.LowMem.SEGB);

      AX      := STKSLOP;     // 50.  but slop
      STKCHK;                 // 51.
      if StackOverFlow then
        begin
          BP := Globals.LowMem.ERECp;            // 52.
          raise ESTKFAULT.Create('Stack fault in ADJ');   // Stack fault in 
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
      //     |              SI-| new high word         |       |THE OLD     -
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
Procedure TIVPsystemInterpreter.INT;
Begin
    //  AND SETB INTO SETA, THEN ZERO-FILL SET A IF SIZEA>SIZEB

    SETUP;                  // 1. We assume set sizes in range 255>=S>=0.
{$R-}
    AH      := AH - AL;     // 2. AL := MIN(SIZEA,SIZEB)
                            // 3. AH := MAX(SIZEA-SIZEB,0)
//  JAE     $1              // 4. JUMP IF SIZEA>SIZEB
    if (AH and $80) <> 0 then
      begin
        AL   := AL + AH;        // 5. SIZEA=MIN
        AH   := 0;              // 6. MAX=0
      end;
{$R+}

      if AL <> 0 then           // 7. IF MIN(SIZEA,SIZEB) <> 0 THEN DO THE INTERSECTION LOOP
        begin
          //  INTERSECTION LOOP

          CL      := AL;          // 9. CL:=COUNT, CH ZEROED IN SETUP
          repeat
            DI      := POP();       // 10. GET ELEMENT FROM SETB
            WordAt[BP] := WordAt[BP] and DI;  //  AND INTO ELEMENT FROM SETA
            BP      := BP + 2;
            CX      := CX - 1;
          until CX = 0;
        end;

    // ZERO FILL

    if AH <> 0 then             // 14. SIZEA>SIZEB THEN DO ZERO FILL
      begin
//      CL    := AH;
//      DI    := 0;
        repeat
          WordAt[BP] := 0;
          BP         := BP + 2;
          CX         := CX - 1; // added 10/14/2021
        until CX = 0;
      end;
                              // WHY IS THIS CODE COMMENTED OUT?
   SP := NEWSP;
end;


// INN: 218 ($DA)
// Set Membership.
// Push Boolean result of TOS-1 IN TOS.
//
//               STACK AT PROC ENTRY
//
//            | rest of stack  |
//            | integer i      |  WANT TO SEE IF I IS IN THE SET
//            |                |
//            |    set-A       |
//            |                |
//            |   size of A    |-SP

Procedure TIVPsystemInterpreter.INN;
VAR
  I: INTEGER;
  Result: boolean;
Begin
  Result  := false;
  DI      := POP();       //  1. DI:=SET SIZE IN # OF WORDS
  BP      := DI;          //  2. DI:=SET SIZE
  BP      := BP SHL 1;    //  3. # OF BYTES TO SKIP
  BP      := BP + SP;     //  4. BP := POINTS TO I & WILL BE PLACE SP POINTS
                          //  WHEN WE LEAVE THIS PROCEDURE
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
          AX  := AX SHL 1;       // 12.
          SP  := SP + AX;        // 13. SP POINTS TO WORD BIT # I SHOULD BE IN
          AX  := POP();          // 14. AX:=WORD I'S BIT IS IN
          DI  := WordAt[BP];  // 15. DI:=I
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

// Set Union. $DB (219)
// Push the union of sets TOS and TOS-1. (TOS OR TOS-1)
procedure TIVPsystemInterpreter.UNI;
begin
        SETUP;                  // 1.
        if AH >= AL then        // 2. We assume set sizes in range 255>=S>=0.
          begin                 // 3a. set B was smaller
            // 4. SET A WAS LARGER OR THEY ARE = SO UNION SETB INTO SETA
            if AL <> 0 then
              begin
                // 7. UNION LOOP, B INTO A
                CL      := AL;          // 8. PUT COUNT IN CX, CH ZEROED IN SETUP
                repeat
                  AX      := POP();       // 9. GET ELEMENT FROM SETB
                  WordAt[BP] := WordAt[BP] or AX; // 10. OR INTO ELEMENT FROM SETA
                  BP      := BP + 2;      // 11. INC SETA PTR
                  CL      := CL - 1;           // 12.
                until cl = 0;
              end
            else
     { $2 }   begin                 // 6. SIZEB = 0 SO NO NEED TO UNION
                SP      := NEWSP;   // 13. SP POINTS TO THE NEW SET
//              PJUMP               // 14.
              end;
          end
        else
          begin                     // 3b. set B was larger
    { $3 }     // 15. SIZEB>SIZEA SO UNION SETA INTO SETB THEN MOV SETB UP TO NEW TOS
            SAVEIPC;                // 16.
            if AH <> 0 then
              begin
                CL      := AH;          // 19. PUT COUNT IN CX, CH ZEROED IN SETUP
                DI      := SP;          // 20. DI POINTS TO SETB
                repeat
                  SI      := WordAt[BP]; // 21. GET ELEMENT FROM SET A
                  WordAt[DI] := WordAt[DI] or SI; // 22. OR INTO ELEMENT FROM SET B
                  DI      := DI + 2;      // 23. BUMP POINTERS
                  BP      := BP + 2;      // 24.
                  CL      := CL - 1;      // 25.
                until CL = 0;
              end;
                                    // 26. NOW BP POINTS JUST ABOVE SETA
            SI      := NEWSP;       // 27. NOW SI POINTS JUST ABOVE SETB
            DI      := BP;          // 28. NOW DI POINTS JUST ABOVE SETA
            SI      := SI - 2;      // 29. SI POINTS TO HIGH WORD IN SETB
            DI      := DI - 2;      // 30. DI POINTS TO HIGH WORD IN SETA
            CL      := AL;          // 31.
//          STD                     // 32. SET UP FOR AUTO DECREMENT
//          ES      := SS;          // 33. AS DI USED ES AS BASE REGISTER
//          PUSH(DS);               // 35. SAVE DS = SEGB
//          DS      := SS;          // 35. DS = SS
            repeat
              MOVSW(fSS, fSI, fSS, fDI, -2);
              CL    := CL - 1;
            until cl = 0;

           // Loop above can be probably optimized to simple MOVE
           // but caution is needed since the move starts at the end and moves
           // towards the front

//          DS      := POP();       // 40. RESTORE DS TO SEGB
            SP      := DI + 2;      // 42.
            AH      := 0;           // 43.
            PUSH(AX);               // 44. SIZE OF SET B AND THE NEW SET TOO.
            GetSavedIPC;            // 45.
//          PJUMP                   // 46.
          end
end;

// SET DIFFERENCE    AND (NOT SETB) INTO SETA
procedure TIVPsystemInterpreter.DIF;
begin
  SETUP;                  // 1. ASSUME SIZES IN RANGE 0-255.

  if AH < AL then         // 2. SIZEA-SIZEB AND AL:=MIN(SIZEA,SIZEB)
    AL := AH;           // 4.

  if AL <> 0 then     // 6.
    begin
      CL  := AL;                // 8. DIFFERENCE LOOP
      repeat
        DI     := POP();        // 9. GET ELEMENT OF SETB
        DI     := NOT DI;       // 10. NOT (ELEMENT OF SETB)
        WordAt[BP] := WordAt[BP] and DI; // 11. AND WITH ELEMENT OF SETA
        BP     := BP + 2;       // 12.
        CL     := CL - 1;
      until CL = 0;
    end;
  SP := NEWSP;    // 14.
end;

// **********************
// *   SET COMPARES     *
// **********************

// ROUTINES USED IN SET COMPARISONS

// PROCEDURE PCSETUP
//       RETURNS:
//          BP := POINTER TO SETA
//          SP := POINTER TO SETB
//          CX := MIN(SIZEA,SIZEB)    // FOR LOOP COUNTS
//          AH := SIZEB-SIZEA
//          AL := A<=B
//          NEWSP := PLACE TO CUT STACK BACK TO
//          ZF IS SET IF B=0
procedure TIVPsystemInterpreter.PCSETUP;
var
  SizeA, SizeB: word;
begin
  SizeB   := Pop();
  BP      := SP+(SizeB*2);      // point to SetA length in words

  SizeA   := WordAt[BP];
  BP      := BP + 2;            // 8. NOW BP POINTS TO SETA
  NEWSP   := (SizeA * 2) + BP;  // 13. NOW NEWSP IS CORRECT
  CX      := Min(SizeA, SizeB);
{$R-}
  AH      := SizeB - SizeA;
  AL      := Integer(SizeA <= SizeB);
{$R+}
  IsZero  := SizeB = 0;
end;

// EQPWR:
// COMPARE SETS FOR = & PUSH TRUE OR FALSE
// Equal Set. Push the Boolean result of set comparison TOS-1 = TOS.

procedure TIVPsystemInterpreter.EQPWR;
var
  flag: boolean;
  result: boolean;
begin
  PCSETUP;
  if IsZero OR (CX = 0) THEN
    begin  // SO FAR SETS ARE =, MAKE SURE LARGER SET HAS ONLY 0'S AT END.
      if AL = 0 then      // SEE IF A<=B
        ZERCHKA           // SETA IS LARGER
      else
        ZERCHKB;          // SETB IS LARGER
    end
  else
    begin
      repeat
        DI    := POP();        // WORD FROM SETB
        flag  := WordAt[BP] <> DI; // COMPARE WITH WORD FROM SETA
        if flag then
          break;               // IF WE BREAK, SETS ARE NOT EQUAL
        BP    := BP + 2;
        CL    := CL - 1;
      until cl = 0;
      result := CL = 0;
      SP := NEWSP;            // SP POINTS TO 1ST WORD OF 'REST OF STACK'
      PUSH(result);            // USE AL FOR RESULT
    end;
end;

// ZERCHKA - MAKE SURE THE REST OF SETA IS ZEROES.
procedure TIVPsystemInterpreter.ZERCHKA;
begin
  SP      := BP;          // NOW SP POINTS TO 1ST WORD WE NEED TO CHECK FOR ALL 0'S
{$R-}
  AH      := - AH;        // NOW WE HAVE SIZEA-SIZEB
{$R+}
  ZERCHKB;
end;

// ZERCHKB - MAKE SURE REST OF SETB IS 0'S.
// SP=^ PLACE TO START IN SET, AH=# OF WORDS TO CHECK
// RETURN AL=1 (ONLY ZEROS LEFT) , OR AL=0 (NOT ONLY ZEROS LEFT)

procedure TIVPsystemInterpreter.ZERCHKB;
begin
//  UnTested('ZERCHKB');
  if AH <> 0 then
    begin
      CL      := AH;          // LOOP COUNT (CH SHOULD BE 0 FROM PCSETUP)
      AL      := 0;           // ASSUME NOT ONLY 0'S LEFT
      repeat
        BP := POP();          // GET A WORD
        if BP <> 0 then
          begin
            SP := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
            PUSH(FALSE);
            Exit;
          end;
        CL := CL - 1;
      until CL = 0;
      AL := AL + 1;           // O.K. ONLY ZEROS WERE LEFT
      SP := NEWSP;            // SP POINTS TO 1ST WORD OF 'REST OF STACK'
      AH := 0;
      PUSH(AX);
    end;
end;

// LEPWR:
// COMPARE SETS FOR <= & PUSH TRUE OR FALSE
// Equal Set. Push the Boolean result of set comparison TOS-1 = TOS.

// LEPWR   ;SEE IF SETA IS A SUBSET OF SETB,(I.E. SETA-SETB)=NULL-SET
//         ;SETA<=SETB
procedure TIVPsystemInterpreter.LEPWR;
var
  temp: word;
  {SetAWord,}SetBWord: word;
begin
  PCSETUP;
  if (not IsZero) or (CX <> 0) then
    begin
      repeat
        SetBWord      := POP();        // 5. WORD FROM SETB
        temp          := WordAt[BP] and (NOT SetBWord);
        WordAt[BP] := temp;     // 7. "AND" INVERSE WITH CORRESPONDING A WORD
        if temp <> 0 then
          begin
            SP := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
            PUSH(FALSE);
            Exit;
          end
        else
          BP := BP + 2;
        CL := CL - 1;
      until CL = 0;
    end;
                             // OK SO FAR, NOW SEE IF SET A IS BIGGER & ZERO CHECK IT
  if AL <> 0 then
    begin   // PCTRUE
      SP := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
      PUSH(TRUE);
    end
  else
    ZERCHKA;
end;

// GEPWR:
// COMPARE SETS FOR >= & PUSH TRUE OR FALSE
// Equal Set. Push the Boolean result of set comparison TOS-1 >= TOS.

procedure TIVPsystemInterpreter.GEPWR;
var
  SetAWord, SetBWord: word;
begin
  PCSETUP;

  if (not IsZero) or (CX <> 0) then
    begin
      repeat
        SetBWord := POP();       // GET WORD FROM SETB
        SetAWord := WordAt[BP];
        if (((NOT SetAWord) AND SetBWord)) <> 0 then
//      if SetAWord <> 0 then
          begin  // GIPCFLSE
            SP := NEWSP;           // SP POINTS TO 1ST WORD OF 'REST OF STACK'
            PUSH(FALSE);
            Exit;
          end
        else
          BP := BP + 2;           // BUMP POINTER

        CL := CL - 1;
      until CL = 0;
      push(true);
    end
  else
{2}
    begin
      if AL <> 0 then
        begin    // PCTRUE          // IF JUMP THEN SIZEB<SIZEA
          SP := NEWSP;              // SP POINTS TO 1ST WORD OF 'REST OF STACK'
          PUSH(TRUE);               // THE RESULT
        end
      else
        ZERCHKB;
    end;
end;




// SRS: 188 ($BC)
// Build a Subrange Set. The integers TOS and TOS-1 must be in [0..4079].
// If not, cause a runtinne error, else push the set . If TOS-1 > TOS,
// push the empty set.-
// Before this operation, if less than 20 words available to the Stack,
// cause a Stack fault.
procedure TIVPsystemInterpreter.SRS;
var
  XX: word;
  t, I, J: integer;
begin
        SAVEIPC;                // in case of faults
        CX      := 0;           // check for stack room for nothing
        AX      := STKSLOP;     //   but slop
        STKCHK;
        if StackOverFlow then
          raise ESTKBACK.Create('Stack fault in SRS');
        J      := POP();       // (AX = J) HIGHER VALUE J OF I..J THE RANGE OF THE NEW SET
        I      := POP();       // (BP = I) LOWER VALUE, I
        if (I >= 0) and (J <= 4079) then // I<0 IMPLIES AN ERROR
          begin                          // J>4079 IMPLIES AN ERROR
            if I <= J then
              begin
                // ALGORITHM TO BUILD THE SET
                //
                //  XX:=BITTER[J MOD 16]
                //  T:=J DIV 16
                //  WHILE T>(I DIV 16) DO
                //   BEGIN  PUSH(XX)
                //   XX:=<ALL 1'S>
                //   T:=T-1
                //  END
                //  XX:=XX AND UNBITTER[I MOD 16]
                //  T:=I DIV 16//
                //  WHILE T>=0 DO
                //   BEGIN  PUSH(XX)
                //   XX:=<ALL 0'S>
                //   T:=T-1
                //   END//
                //  PUSH((J DIV 16)+1)  (* SET SIZE IN # OF WORDS*)
                XX := BITTER[J MOD 16];
                T  := J DIV 16;
                WHILE T>(I DIV 16) DO
                  BEGIN
                    PUSH(XX);
                    XX := Bitter[15];  // all 1's
                    T  := T-1;
                  END;
                XX := XX AND UNBITTER[I MOD 16];
                T  := I DIV 16;
                WHILE T>=0 DO
                  BEGIN
                    PUSH(XX);
                    XX := ClrMsk;       // all 0's
                    T  := T-1;
                  END;
                PUSH((J DIV 16)+1);  (* SET SIZE IN # OF WORDS*)
              end
            else
              push(0) // null set
          end
        else
          begin
            PUSH(0);
//          InvNdx;
            raise Exception.CreateFmt('Invalid index: %d', [I]);
          end;
end;


{**********************************************************************}

// NOP: 156 ($9C)
// No Operation
procedure TIVPsystemInterpreter.NOP;
begin

end;

procedure TIVPsystemInterpreter.XCHG(var B1, B2: byte);
var
  Temp: byte;
begin
  Temp := B1;
  B1   := B2;
  B2   := Temp;
end;

procedure TIVPsystemInterpreter.XCHG(var W1, W2: word);
var
  Temp: word;
begin
  Temp := W1;
  W1   := W2;
  W2   := Temp;
end;


//*****************************************************************************
//   Function Name     : CalcProcBase
//   Useage            :
//   Function Purpose  : Return the address of the 1st code byte for a procedure
//   Assumptions       :
//   Parameters        : Addr = Base address of a segment
//                       ProcNumber = the procedure number of interest
//   Return Value      : Address (within Bytes[] of the 1st instruction of the proc)
//*******************************************************************************}

function TIVPsystemInterpreter.CalcProcBase(Addr: longword; ProcNumber: word): word;
var
  AddrOfNumberProcedures, ProcPtrAddr: longword;

  ProcPtrOffset: word;
begin
{$R-}
  ProcPtrOffset               := WordAt[Addr] * 2;    // * 2 (convert word offset to byte offset)
  AddrOfNumberProcedures      := Addr + ProcPtrOffset;
//OutputDebugStringFmt('Addr=%4.4x, ProcNumber=%d, ProcPtrOffSet=%4.4x, AddrOfNumberProcedures=%4.4x, DbgCnt=%10.0n, RelIPC=%d',
//                     [Addr, ProcNumber, ProcPtrOffset, AddrOfNumberProcedures, DbgCnt*1.0, RelIPC]);
  try
    ProcPtrAddr                 := AddrOfNumberProcedures - (ProcNumber*2);
    result                      := (WordAt[ProcPtrAddr] * 2) + 2;
  except
    on e:EIntOverflow do
      result := 0;                // temporary exception handler to get past problems
  end;
{$R+}
end;


// TASK ------------------------------------------------------------------------

// Name:    SaveReg
// Purpose: moves the interpreter internal versions of the tib registers
//          into the current task tib
// output : BP = ^current tib
// uses:    BP, CX

procedure TIVPsystemInterpreter.SAVEREG;
begin { SAVEREG }
  BP      := Globals.LowMem.CURTASK;        // 1. ^ Current Tib (output expected)

  with TTibPtr(@Bytes[BP])^ do
    begin
      Regs.SP           := SP;
      Regs.MP           := MP;
      Regs.ProcNum      := Globals.LowMem.CURPROC;
      Regs.TibIOResult  := ord(SyscomPtr^.iorslt);
      Regs.IPC          := SI;
      Regs.env          := Globals.LowMem.ERECp;
    end;
end;  { SAVEREG }

//RESTORE ; load p-machine registers from the current tib
//        ; output : BP = ^current tib
//                   Globvar set
//                   LocalVar set
//        ; uses AX, BP, CX
procedure TIVPsystemInterpreter.Restore;
var
  CurTaskAddr: word;
  ErecAddr: word;
  SibAddr: word;
begin
  CurTaskAddr := Globals.LowMem.CURTASK;
  with TTibPtr(@Bytes[CurTaskAddr])^ do
    begin
      Globals.LowMem.CURPROC       := Regs.ProcNum and $FF;
      SyscomPtr^.iorslt            := TIORsltWD((Regs.ProcNum shr 8) and $FF);    // IO Result
      ErecAddr                     := Regs.Env;
      Globals.LowMem.ERECp         := ErecAddr;
      with TErecPtr(@Bytes[ErecAddr])^ do
        begin
          Globals.Lowmem.BASE     := Env_Data;                   // erec.GlobalDataSeg
          Globals.Lowmem.BASEPLUS := Env_Data + MSCWDISP;
          GlobVar                 := Globals.Lowmem.BASEPLUS;
          Globals.LowMem.EVECp    := Env_Vect;
          SibAddr                 := Env_SIB;
          Globals.Lowmem.SIBP     := SibAddr;
          with TSibPtr(@Bytes[SibAddr])^ do
            begin
              ES  := PoolBase(Seg_Pool) + Seg_Base;  // add segment base offset to PoolBase
              Globals.LowMem.SEGB := ES;             // to get base of segment
              with TSegStructPtr(@Bytes[ES])^ do
                begin
                  Globals.Lowmem.SEGTOP   := ProcDictOffset SHL 1;   // byte offset to top word in segment
                  Globals.LowMem.SEXFLAG  := SegSex;
                  Globals.LowMem.CPOFFSET := SegConst SHL 1;         //  const pool offset from ES prefix
                end;
{$IfDef Debugging}
              ProcBase := CalcProcBase(Globals.LowMem.SEGB, Globals.LowMem.CURPROC);   // <======= DEBUG =====
{$endIf}
            end;
        end;
      SI       := regs.IPC;
      MP       := regs.mp;                    //
      LocalVar := MP + MSCWDISP;         // ^currentActivationRecord
      Globals.Lowmem.MPPLUS   := LocalVar;
      SP       := TTibPtr(@Bytes[CurTaskAddr])^.regs.sp;

      DS       := ES;
      BP       := CurTaskAddr;
    end;
end;

// Load Processor Register.
// TOS is a register number.
// Push the contents of the register indicated in this fashion: (for SPR, also):
// a) register number is positive: it is a word index into the current TIB.
//    0 indicates wait_q
//    1 indicates prior + flags
//    2 indicates sp_low
//    3 indicates sp_upr
//    4 indicates sp
//    5 indicates mp
//    6 indicates task_link
//    7 indicates ipc
//    8 indicates erec
//    9 indicate procnum
// b) register number is negative:
//    -1 indicates the pointer to the TIB of the currently running task
//    -2 indicates the current E_Vec_P
//    -3 Indicates the pointer to the TIB at the head of the ready queue

procedure TIVPsystemInterpreter.LPR;
var
  Reg: integer;
begin
{$R-}                     // may be negative
  Reg := POP();           // register number
{$R+}
  SAVEREG;                // force regs to be current, assumes that after call BP = ^Tib
  if Reg >= 0 then
    PUSH(WordAt[BP + (Reg shl 1)])  // PUSH REGISTER CONTENTS
  else
    case Reg of             // handle negative register offset
      -1: PUSH(Globals.LowMem.CURTASK);   // (-1) Current Tib Pointer
      -2: PUSH(Globals.LowMem.EVECp);     // (-2) Pointer to Global EVec Vector
      -3: PUSH(Globals.Lowmem.READYQ);    // (-3) READY QUEUE POINTER
    end;
 end;

// SPR: 209 ($D1)
// Store Processor Register.
// TOS-1 is a register number (defined as for LPR).
// Store TOS in indicated register.
procedure TIVPsystemInterpreter.SPR;
var
  Reg: integer;
begin
{$R-}
  AX  := POP();                 // get value to store
  Reg := POP();                 // get destination register as integer
{$R+}
  SaveReg;                      // force regs to be current, assumes that BP = ^TIB

  if Reg < 0 then
    case Reg of
      -1: Globals.LowMem.CURTASK := AX;
      -2: Globals.LowMem.EVECp   := AX;
      -3: Globals.Lowmem.ReadyQ  := AX;
    end
  else
    WordAt[BP+(Reg shl 1)] := AX;     // update the register

  Restore;                      // in case something vital changed
end;

// places a tib pointer into a priority queue
// input  : AX = head of queue,
//          BX = ^tib
//          DS = SSDSVAL
// was output : AX = new ^queue, BX unchanged
// Now output : result = new ^queue, BX unchanged
// uses:    AX, BX, CX
function TIVPsystemInterpreter.ENQUE(Queue{AX}, TibAddr{BX}: Word): word;
var
  CurrentListElement: word;  // SI
  PreviousListElement: word; // DI
  Priority: word;            // CL
//DI, SI: word;
begin
    Result                  := Queue;
    CurrentListElement      := Queue;       // 3. starting values
    PreviousListElement     := pNIL;        // 4.
    while CurrentListElement <> pNIL do     // 5. while not the end of the list
      begin
        Priority := Bytes[SSDSVAL+CurrentListElement+TIBPRI];       // 7. priority of current entry
        if Priority < Bytes[SSDSVAL+TibAddr+TIBPRI] then // 8. compare to priority of new entry
          BREAK                           // 9. break if current < new
        else
          begin
            PreviousListElement := CurrentListElement;          // 10. next entry in queue
            CurrentListElement  := WordAt[SSDSVAL+CurrentListElement+TIBLINK]; // 11.
          end;
      end;

//   enter element into list

    WordAt[SSDSVAL+TibAddr+TIBLINK] := CurrentListElement; // 13. point new element at next element
    if PreviousListElement = pNIL then            // 14.
      result  := TibAddr
    else
      WordAt[SSDSVAL+PreviousListElement+TIBLINK] := TibAddr; // 16. point next highest at new element
end;

// Name        : DEQUE
// Purpose     : removes the head of a queue
// input       : AX = ^queue

// was output  : AX = new ^queue,
//             : BX = ^new tib

// now output  : Queue  = new ^queue,
//             : NewTib = ^new tib
procedure TIVPsystemInterpreter.DEQUE(var Queue{AX}, NewTib {BX}: word);
begin
    NewTib := Queue;          // new ^tib
    with TTibPtr(@Bytes[NewTib])^ do
      begin
        Queue           := Regs.Wait_Q;
        Regs.Wait_Q     := pNIL;
      end;
end;

// DELINK  ; removes curtask from readyq
// output : BP = ^curproc
// uses AX, BP
function TIVPsystemInterpreter.DELINK(): word;
var DI: word; // rather than push/pop to preserve
begin
//  PUSH(DI);               //  1.
    BP  := Globals.Lowmem.READYQ;          //  2. point at readyq
    DI  := BP;                             //  3. DI is last element
    BP  := WordAt[BP+TIBLINK];          //  4. chain down one element
    if DI = Globals.LowMem.CURTASK then    //  5. is first element curtask
      begin
        //  curtask is at head of queue
        Globals.Lowmem.READYQ  := BP;      //  7. new head of list
        BP      := DI;
      end
    else
      begin
        while BP <> Globals.LowMem.CURTASK do //  curtask if not at head of queue
          begin
            DI   := BP;                    //  12. chain down one element
            BP   := WordAt[BP+TIBLINK]; // 13.
          end;
        AX := WordAt[BP+TIBLINK];       //  15. remove curtask from list
        WordAt[DI+TIBLINK] := AX;
      end;

//  DI := POP();            //  17.
    result := BP;
end;

// Name:     WAIT: 223 ($DF)
// Function: wait on a semaphore
// Entry:    (TOS) = semaphore to wait on
// Uses:     AX, BP, DI
procedure TIVPsystemInterpreter.WAIT;
var
  TibAddr: word;
begin
  XQUIET;                     // 1. start critical section
  DI      := POP();           // 2. semaphore
  if WordAt[DI] = 0 then   // 3. if semaphore count = 0,
                              // 4. we must switch tasks
    begin
      //  Wait for Someone to Signal this Semaphore
      TibAddr := DELINK;      // 7. remove curproc from readyq, BX = ^cur
      AX   := WordAt[SSDSVAL+DI+SEMWAITQ]; // 12. ^wait queue for semaphore
      AX   := ENQUE(AX, TibAddr);               //  13. Queue current task on the semaphore
      WordAt[SSDSVAL+DI+SEMWAITQ] := AX; //  14. possible new head for sema's queue
      WordAt[SSDSVAL+TibAddr+TIBHANG] := DI;  //  15. pointer to sem this task waits on
      SETUPSW(TASKSW);         // 18. 19. setup for TASK SWITCH
    end
  else
    WordAt[DI] := WordAt[DI] - 1;  // 5. else decrement count

  XENABLE;                    //  end critical section
end;

// Name:     SIG
// Function: does the work of signal
//           called from SIGNAL p-code or from EVENT
// input :   DI = semaphore being signaled
//           BX = Start of LocalData (MPPlus)
//                (actually seems to be assuming that BX is pointing to a TIB?)
// uses AX
procedure TIVPsystemInterpreter.SIG;
var
  TibAddr: word;
begin { TIVPsystemInterpreter.SIG; }
    AX  := WordAt[SSDSVAL+DI+SEMCNT];  // 4. Get count of semaphores
    if Integer(AX) >= 0 then
      begin
        AX := WordAt[SSDSVAL+DI+SEMWAITQ]; // 7. DI is the semaphore being signaled, SEMWAITQ (=2) is offset to Queue        // 11/12/2019
        if AX <> pNIL then                 // 8. if someone waiting on semaphore, then
          begin                            // 9. task switch
            DEQUE(fAX.w, TibAddr);           // 12. get first task in wait queue (output : AX = new ^queue, BX = ^new tib)
            WordAt[SSDSVAL+DI+SEMWAITQ] := AX;  // 13. new tib to head of wait queue
            WordAt[SSDSVAL+TibAddr+TIBHANG] := pNIL; // 14. clear wait flag for new task
            AX  := Globals.Lowmem.READYQ;                 // 15. put new task in ready queue
            AX  := ENQUE(fAX.w, TibAddr);                        // 16. (Params: AX = head of queue, BX = ^tib, DS = SSDSVAL)
            Globals.Lowmem.READYQ := AX;                  // 17. set new ^ready queue
            DI     := Globals.LowMem.CURTASK;             // 18.
            AL     := Bytes[SSDSVAL+TibAddr+TIBPRI]; // 19. priority of new task
            if AL >= Bytes[SSDSVAL+DI+TIBPRI] then  // 20. priority of current task
              SETUPSW(TASKSW)
            else
              { 21. exit if new < current };
          end
        else
          WordAt[SSDSVAL+DI] := WordAt[SSDSVAL+DI] + 1  // 10 & 11. bump semaphore count and exit        // 11/12/2019
      end
    else
      WordAt[SSDSVAL+DI] := WordAt[SSDSVAL+DI] + 1;  // 6. If count < 0 then bump  // 11/12/2019

//  BX := POP();
//  DS := POP()
end;  { TIVPsystemInterpreter.SIG; }

// SIGNAL: 222 ($DE)
// Signal. TOS is a semaphore address.
procedure TIVPsystemInterpreter.SIGNAL;
begin
  XQUIET;          //  begin critical section
  DI := POP();     //  semaphore
  SIG;             //  do the signal
  XENABLE;         //  end critical section
//PJUMP
end;

// TASKSW  ; causes a task switch by being jumped to from p-code fetch.
// Assumes readyq has something of higher priority
procedure TIVPsystemInterpreter.TASKSW;
begin
  SI      := SI - 1;      //  1. point back at p-code

  SAVEREG;                //  2. save state of current task into tib

  RES_JT;                 //  3. restores jump table

  BP := Globals.Lowmem.SIBp;             //  4.
  SETSTAMP;               //  5. timestamp exiting segment
  XQUIET;                 //  6. start critical section
  Globals.LowMem.CURTASK := Globals.Lowmem.READYQ;      //  8. set curtask to first task on readyq
  RESTORE;                //  9. Load regs from Tib of new task
  XENABLE;                //  10. end critical section
  BP := Globals.Lowmem.SIBp;             //  11. insure segment presence
  if WordAt[BP+SIBBASE] <> pNil then {aka: seg_base}
    begin
      if SI = 0 then       // 13. NAT fault flag?
        begin
          AX      := 0;           // 16. Return to NAT fault handler
          DS      := AX;          // 17. DS = SS
          DI      := AX;          // 18. BASEPLUS in DI
          BP      := Globals.LowMem.CURTASK;     // 19. Return address saved in machine-
//        JMP     (BP+TIBMDEP)    // 20. dependent word of TIB
          Unimplemented('NAT fault flag');
        end
    end
  else
    begin                         // 12. start interpreting new task
      BP      := Globals.LowMem.ERECp;
      SEGFAULT;                   // 22. and segment fault
    end;
end;

procedure TIVPsystemInterpreter.XQUIET;    // 11/15/2019 5:25pm
begin
  NOEVENT := TRUE;
end;

// associates a semaphore with an event number

procedure TIVPsystemInterpreter.ATTACH;
begin
        XQUIET;                // start of critical section
        DI      := Pop();      // event #
        AX      := Pop();      // semaphore
        EVENTVEC[DI] := AX;
        XENABLE;         // end of critical section
end;

procedure TIVPsystemInterpreter.RES_JT;
begin
  TaskSwitch := nil;
end;

// SETUP for Task Switch to happen on next p-code
// Input: ProcCall = Addr of Switch routine (was AX)
//        p-code Jump Table at CS:0000 to 0200 will have AX.
// Apparently the entire jump table was being
// overwritten so as to force the next instruction to go to desired opcode.
procedure TIVPsystemInterpreter.SetupSW(ProcCall: OpsTables.TProcCall);
begin
  TaskSwitch := ProcCall;
end;

// Called from BIOS when BREAK Key is depressed.
//   If MAIN_TASK then Set_UBREAK
//   Else AX := 0 ;
procedure TIVPsystemInterpreter.USR_BREAK(TibAddr: word);
begin
  Untested('USR_BREAK', true);

  AX      := 0;
  if (SyscomPtr^.miscinfo.FLAGS and $40 { the "nobreak" bit }) = 0 then
    begin
      Globals.LowMem.CURTASK := TibAddr;
      AX      := WordAt[SSDSVAL+TibAddr+TIBMNTSK] AND 1; // right_most bit is maintask
      if AX <> 0 then     //   If MAIN_TASK
        begin
//        LEA     AX,UBREAK       //  set UBREAK for next p-code
          SETUPSW(UBREAK);        //
        end;
    end;
end;


// Stack fault occurred in call to new segment


//STKFAULT                        ;BP - ^ bad ERec
procedure TIVPsystemInterpreter.STKFAULT;
begin
// Special case, can't use ExecError because it would need a frame in
// which to run! Instead, we signal FltSem after placing parameters in
// SysCom.
  with SyscomPtr^.fault_sem.Fault_Message do
    begin
      fault_e_rec := BP;          // ^BadERec into SysCom
      fault_words := Globals.LowMem.EXTEND;      // number of words we need
      SyscomPtr^.fault_sem.Fault_Message.fault_type := STKFLTC;  // save fault number
    end;
  FAULTCOM;
end;

procedure TIVPsystemInterpreter.FaultCom;
begin
  SyscomPtr^.Fault_Sem.Fault_Message.Fault_TIB := Globals.LowMem.CURTASK;
  SAVEIPC;

//DI :=  Integer(@TGlobals(nil^).Lowmem.SyscomSpace.fault_sem.real_sem); // address of semaphore in SysCom
  DI :=  Integer(@TIVSysComRec(nil^).fault_sem.real_sem) + SyscomAddr;   // p-System address of the semaphore in SysCom
  SIG;                    // should cause task switch
  GetSavedIPC;            // IPCFETCH
end;

// NOTE:  NEWENV, BLDFRM, CHGSIB, SETSTAMP assume DS = SS, ES = SEGB !!!!

  function TIVPsystemInterpreter.CurrentSegName: string;
  begin
    SetLength(result, CHARS_PER_IDENTIFIER);
    Move(Bytes[DS+SEGNAME_], result[1], CHARS_PER_IDENTIFIER);
    result := Trim(result);
  end;

{$IfNDef Debugging}
  function TIVPsystemInterpreter.ProcName(MsProc: word; Segb: longword): string;
  begin
    result := Format('Procedure #%d in %s', [MsProc, CurrentSegName]);
  end;
{$EndIf}

{$IfDef Debugging}
function TIVPsystemInterpreter.ProcName(MSProc: word; SegB: longword): string;
var
  Segname: string;
  MySegIdx: TSegNameIdx;
//AccDbFileNumber: integer;
  aProcName: string;
  ProcNr, AbsProcNr: integer;
  ProcNrStr: string;
begin
{$R-}
  ProcNr    := MSProc;   // procedure number is negative during "Exit" processing
{$R+}
  if ProcNr >= 0 then
    ProcNrStr := IntToStr(ProcNr)
  else
    ProcNrStr := Format('(%d)', [ProcNr]);

  AbsProcNr := Abs(ProcNr);
//  MySegIdx   := DU.TheSegNameIdx(SegBase);

  if Assigned(frmPCodeDebugger) then
    begin
      with frmPCodeDebugger do
        MySegIdx := TheSegNameIdx(SegB);
      SegName   := SegNamesF(MySegIdx);

      if MySegIdx <> sn_Unknown then
        if (AbsProcNr <= MAXPROCNAME) and
            (not Empty(ProcNamesF(MySegIdx, AbsProcNr))) then
          aProcName := ProcNamesF(MySegIdx, AbsProcNr)
        else
          aProcName := Format('PROC%s', [ProcNumStr(ProcNr)])
      else
        aProcName := CUNKNOWN;
    end
  else
    begin
      SegName   := SegNameFromBase(SegB);
      aProcName := Format('PROC%s', [ProcNumStr(ProcNr)])
    end;

  result  := Format('%s: %s.%s', [ProcNumStr(ProcNr), SegName, aProcName])
end;

{$endIf}

{$IfNDef Debugging}
procedure TIVPsystemInterpreter.FinalException(Op: word; Msg: string);
var
  Temp: string;
begin
  Temp := Format('%s: CurProc = %d, SegName = %s @ $%4.4x',
                    [Msg,
                     Globals.LowMem.CURPROC,
                     CurrentSegName,
                     DS]);
//raise ESYSTEMHALT.Create(temp);
  HaltPSys(temp);
end;
{$endIf}

{$IfDef Debugging}
procedure TIVPsystemInterpreter.FinalException(Op: word; Msg: string);
var
  Temp: string;
  LastOpCode: string[10];
begin
  if (Op <= Length(OpsTable.Ops)) then
    with Opstable.Ops[fOp] do
      if not Empty(Name) then
        LastOpcode := Opstable.Ops[Op].Name
      else
        LastOpCode := Format('OpCode # %d', [Op]);

  Temp := Format('%s: DbgCnt = %0.n, CurProc = %s, Offset = %d, LastOpCode = %s',
                    [Msg,
                     DbgCnt * 1.0,
                     ProcName(Globals.LowMem.CURPROC, DS),
                     SI-ProcBase-1,
                     LastOpCode]);
//raise ESYSTEMHALT.Create(temp);
  HaltPSys(temp);
end;
{$EndIf}

procedure TIVPsystemInterpreter.CloseStuff;
begin
end;


procedure TIVPsystemInterpreter.HandleBreakKey();
begin
  SI := SI - 1;    // point back at broken p-code
  XEQERROR(UBREAKC);
end;

function TIVPsystemInterpreter.Fetch: TBrk;
{$IfDef History}
var
  aSegNameIdx: TSegNameIdx;
{$EndIf}
begin
  result := dbUnknown;
  try
    fOp     := Bytes[DS+SI];
//  fOpCode := fOp;
    SI      := SI + 1;
    with Opstable.Ops[fOp] do
      if Assigned(ProcCall) then
        begin
{$IfDef Debugging}
          if Assigned(frmPCodeDebugger) then
            begin
      {$IfDef pocahontas}
              Phits := Phits + 1;
      {$EndIf}
              with Globals.LowMem, frmPCodeDebugger do
                begin
    {$IfDef History}
                  aSegNameIdx := TheSegNameIdx(SegB);
                  AddHist(CURPROC, RelIPC, fOp, Opstable.Ops[fOp].Name, aSegNameIdx,
                          DebuggerSettings.CallHistoryOnly);
    {$EndIf}
    {$IfDef Profile}
                  frmPCodeDebugger.IncProfile(aSegNameIdx, CurProc);
    {$EndIf}
                end;
            end;
{$EndIf debugging}

         if Assigned(TaskSwitch) then
            TaskSwitch
          else
            ProcCall;
        end
      else
        raise Exception.CreateFmt('Operator %d [%s] is not assigned', [fOp, Name]);
{$IfDef Debugging}
    Inc(DbgCnt);
{$EndIf Debugging}
  except
    on e:ESEGFAULT do
      SEGFAULT;
    on e:ESEGBACK do
      SEGBACK;
    on e:ESSTKBACK do
      SSTKBACK;
    on e:ESTKBACK do
      STKBACK;
    on e:ESTKFAULT do
      STKFAULT;
    on EXEQERR do
      XEQERROR(fErrCode);
    on e:ESYSTEMHALT do
      begin
        CloseStuff;
        raise;
      end;
    on e:ERANGEERROR do
      XEQERROR(INVNDXC);
    on e:Exception do
      begin
{$IfDef Debugging}
        frmPCodeDebugger.fExceptionMessage := e.Message;
{$EndIf}
        OutputDebugStringFmt('Exception: %s in procedure %s:%d at IPC = %d',
                             [e.Message, CurrentSegName, CurProc, RelIpc]);
        result := dbException;
        XEQERROR(SYSERRC);
      end;
  end;

//Inc(DbgCnt);   (* this is where it belongs *)

end;

// FAULT HANDLING

procedure TIVPsystemInterpreter.SEGBACK;
begin
  GetSavedIPC;      //restore Ipc to just after Fetch
  SI := SI - 1;     //then back up to offending op-code
  PUSH(Globals.Lowmem.ERECp);      //save offending ERec
  BP := Globals.Lowmem.OLDEREC;    //restore the previous environment
  NEWENV;
  BP := POP();      //pointer to offending environment
  DS := ES;         // DS = ES = SEGB
  SEGFAULT;         // or should this be...
//    raise ESEGFAULT.Create('SEGFAULT');         //generate fault
end;

//  SEGFAULT
//  Entry: BP - ^ERec of seg for which we yearn
procedure TIVPsystemInterpreter.SEGFAULT;
//var
//  FMP: ^TFault_message;
begin
//  FMP := @SyscomPtr^.Fault_Sem.Fault_Message;
//  with FMP^ do
//    begin
//      fault_e_rec {FLTEREC} := BP;             // EREC OF DESIRED SEG
//      fault_words {FLTNWDS} := 0;              // TRASH
//      fault_type  {FLTNUM}  := SEGFLTC;        // SEGMENT FAULT CODE
//    end;
//  FAULTCOM;
// 4/28/2023: changed to:
    with SyscomPtr^.Fault_Sem.Fault_Message do
      begin
        fault_e_rec {FLTEREC} := BP;             // EREC OF DESIRED SEG
        fault_words {FLTNWDS} := 0;              // TRASH
        fault_type  {FLTNUM}  := SEGFLTC;        // SEGMENT FAULT CODE
      end;
    FAULTCOM;
end;

// Stack fault occurred, cleanup and fault
procedure TIVPsystemInterpreter.STKBACK;
begin
  GetSavedIPC;
  SI := SI - 1;       // restore Ipc to just after IFetch then back up to op-code causing fault
  BP := Globals.Lowmem.ERECp;
  STKFAULT;
end;

procedure TIVPsystemInterpreter.SSTKBACK;
begin
  GetSavedIPC;
  SI := SI - 1;                 // Restore IPC to offending p-code
  BP := Globals.Lowmem.ERECp;                  // point to offending environment
  PUSH(BP);
  BP := Globals.Lowmem.OLDEREC;
  NEWENV;                       // restore environment
  BP := POP();
//PUSH(ES);
//DS := POP();                  
  DS := ES;                     // DS = ES = SEGB
  STKFAULT;                     // or should this be an exception?
end;


{ 02/09/2018    dhd - also see the interpreter in P4211FA
{ 01/25/2018    dhd - notes based on TERTBOOT.TEXT, TERTBOOT.A.TEXT }

Procedure TIVPsystemInterpreter.InitSets;
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

procedure QINIT;
begin { QINIT }
  with EVENTQIB do
    begin
      QIBSize := SizeOf(EVENTQUE);
      QIBOfsS := 0;  // CLEAR STORE INDEX
      QIBOfsR := 0;  // CLEAR LOAD INDEX
    end;
end;  { QINIT }

procedure TIVPsystemInterpreter.Load_PSystem(UnitNr: word);
const
  MAX_SEGS       = 32;   // THIS CODE CURRENTLY IGNORES ANYTHING IN THE SEGMENT DICTIONARY
                         // AFTER THE FIRST DICTIONARY BLOCK.
  EVEC_ByteCount = (MAX_SEGS * 2) + 2;  // +2 for Vect_Length
  EREC_ByteCount = Sizeof(TEREC) * MAX_SEGS;
  SIB_ByteCount  = SizeOf(TSib) * MAX_SEGS;
var
  DelphiDirEntryP  : PDirEntry;
  DelphiDirEntry   : TDirEntry;
  I                : word;
  InBufPtr         : TInBufPtr;
  OS_BlockNr       : word;
  RootTaskP        : word;              // pointer to RootTask TIB
//SysComOffset     : word;
  SegmentDictionary: TSeg_Dict;
  SegSex           : word;
  SegLength        : word;
  SegDictP         : word;              // pointer to segdict on stack
  UserBase         : word;
  Wrd              : word;
  EvecStuffAddr    : word;
  EvecStuffLen     : word;
  
  procedure BuildEnvironmentIV;
  begin { BuildEnvironMentIV }
  // STEP 13 - Build Environment

    SP      := SP - (3 + 5 + 18) * 2; // 3 word EVEC, 5 word EREC, 18 word SIB

    with Globals.LowMem do
      begin
        EVECp   := SP;          // point EVECp at EVEC allocated
        ERECp   := SP + 6;      // point ERECp at EREC allocated.
        SIBp    := SP + 16;
      end;

  // initialize the EVEC

  {$R-}
    with TEvecPtr(@Bytes[Globals.LowMem.EVECp])^ do
      begin
        vect_length      := 2;
        map[1]           := pNIL;
        map[vect_length] := Globals.LowMem.ERECp;   // range check if not $R-
      end;
  {$R+}

  // Initialize the Erec

    with TErecPtr(@Bytes[Globals.LowMem.ERECp])^ do
      begin
        env_data     := MAINMSCWp;
        env_vect     := Globals.LowMem.EVECp;
        env_sib      := Globals.Lowmem.SIBp;
        Link_Count   := 0;
        next_rec     := pNIL;
      end;

  //      initialize the SIB

    with TSibPtr(@Bytes[Globals.Lowmem.SIBp])^ do
      begin
        Seg_Pool    := pNil;
        Seg_Base    := UserBase;
        Seg_Refs    := 1;
        TimeStamp   := 0;
        seg_pieces  := 0;
        residency   := 0;
        seg_name    := SegmentDictionary.seg_name[USERPROGNR];
        seg_leng    := SegmentDictionary.disk_info[USERPROGNR].code_leng;
        seg_addr    := SegmentDictionary.disk_info[USERPROGNR].code_addr + OS_BlockNr;
        vol_info    := UnitNr;
        data_size   := 0;
        res_sibs.prev_sib := pNIL;
        res_sibs.next_sib := pNIL;
        mtype       := 0;
      end;

  end;   { BuildEnvironMentIV }


  procedure BuildEnvironmentIV4_12(LowAddress: word; HighAddress: word);
  const
    MAX_SEGS = 32;   // THIS CODE CURRENTLY IGNORES ANYTHING IN THE SEGMENT DICTIONARY AFTER THE FIRST DICTIONARY BLOCK.
  var
    EVECByteCount : word;          // length of the EVEC

    EVECAddr : word;               // p-System addr of the EVEC
    EVECPtr  : TEvecPtr;           // Pointer to the Evec

    ERECAddr : word;               // p-System addr of the currect EREC
    ERECPtr  : TErecPtr;           // Pointer to the current Erec

    SIBAddr  : word;               // p-System addr of the current SIB
    SIBPtr   : TSibPtr;            // Pointer to the current SIB

    SegNr    : word;
//  SlotNr   : word;
  begin { BuildEnvironmentIV4_12 }
    // Allocate room for the EVEC - assume 32 possible segments in the EVEC
    EVECByteCount := (MAX_SEGS * 2);

    // start at the bottom and build towards the top. I.e.:
    //       SIB32               - high memory
    //       EREC32
    //       ...
    //       SIB01
    //       EREC01
    //       ...
    //       EVEC.MAP[32]
    //       ...
    //       EVEC.Map[02]
    //       EVEC.Map[01]
    //       EVEC.vect_length    - low memory
    EVECAddr      := LowAddress; // we need 2 words for each pointer + 2 for Vect_Len
    EVECPtr       := TEVECPtr(@Bytes[EVECAddr]);

    with EVECPtr^ do
      vect_length := MAX_SEGS;

    ERECAddr      := EVECAddr + EVECByteCount + 2;  // starting address of the 1st EREC. + 2 for the length
    SIBAddr       := ERECAddr + SizeOf(TErec);   // starting address of the 1st SIB just below the EREC

    // The following is just a guess as to which values should be set in low memory.
    // Currently I am setting them to point to the Kernel. Maybe they should be set to USERPROG?
    with Globals.LowMem do
      begin
        EVECp   := EVECAddr;      // point EVECp at EVEC allocated
        ERECp   := ERECAddr;      // point ERECp at EREC allocated
        SIBp    := SIBAddr;
      end;

    // Do the 1st 16 segments
    // The 1st block of the segment dictionary got loaded at SegDictP

    SegNr := 0;    // should the SegNr be coming from the segment dictionary? TSeg_info_rec?
    repeat
//    SegNr := SegmentDictionary.seg_info[SlotNr].SegInfo and $F; // SegNr is in the low 8 bits.
                                                                  // This is not the correct SegNr.
{$R-}
      EVECPtr^.map[SegNr+1] := ERECAddr;
{$R+}
      // Initialize an EREC
      ERECPtr := TErecPtr(@Bytes[ERECAddr]);
      with ERECPtr^ do
        begin
          if SegNr = KERNELPROGNR then
            env_data     := MAINMSCWp  // only for the Kernel
          else
            env_data     := pNil;

          env_vect     := EVECAddr;
          env_sib      := SIBADDR;
          Link_Count   := 0;
          next_rec     := pNIL;
        end;

      // Initialize a SIB
      SIBPtr := TSIBPtr(@Bytes[SIBAddr]);
      with SIBPtr^ do
        begin
          Seg_Pool    := pNil;         // should this really be using poolbase?
          if SegNr = KERNELPROGNR then
            Seg_Base    := UserBase    // only for the Kernel
          else
            Seg_Base    := pNil;

          Seg_Refs    := 1;
          TimeStamp   := 0;
          seg_pieces  := 0;
          residency   := 0;
          seg_leng    := SegmentDictionary.disk_info[SegNr].code_leng;
          seg_addr    := SegmentDictionary.disk_info[SegNr].code_addr + OS_BlockNr;
          seg_name    := TAlpha(SegmentDictionary.seg_name[SegNr]);
          vol_info    := UnitNr;  // In version 4+, unitnumber gets changed, at run-time, to a pointer to a TVip record !
          data_size   := SegmentDictionary.seg_family[SegNr].data_size;
          res_sibs.prev_sib := pNIL;
          res_sibs.next_sib := pNIL;
          mtype       := 0;
        end;

      ERECAddr := SIBAddr + SizeOf(TSIB);
      SIBAddr  := ERECAddr + SizeOf(TErec);
      SegNr    := SegNr + 1;
    until SegNr >= 16;  // We only loaded the 1st block of the dictionary (1st 16 segment entries)

  end;  { BuildEnvironmentIV4_12 }

begin { Load_PSystem }
  inherited;

  SyscomPtr^.SYSUNIT  := fBootUnit;
  SyscomPtr^.GDIRP  := pNIL;   {NIL ie directory not loaded..should be nil to start}
  SyscomPtr^.IORSLT := INOERROR;

  InitSets;

  QINIT;

  try

    Globals.MemTop := LOW64K;      // Codepool is external

  //DebugMessage('STEP 4: Read in boot unit directory');

    SP := Globals.MemTop - DIRECTORYBYTES; // make room to load the directory into high memory
    Seek(BootVolume.VolumeFile, DIRECTORY_BLOCKNR);
    BootVolume.UCSDBlockread(Bytes[SP], DIRECTORYBLOCKS);

    // set Syscom.GDIRP to point to directory

    SyscomPtr^.gdirp := SP;

    if Bytes[SyscomPtr^.gdirp+2] = 0 then // correct byte sex
      raise Exception.Create('Incorrect byte sex for directory');

    // STEP 6

    DelphiDirEntryP := BootVolume.FindDirectoryEntry(CSYSTEM_PASCAL);
    if Assigned(DelphiDirEntryP) then
      DelphiDirEntry  := DelphiDirEntryP^
    else
      raise Exception.CreateFmt('SYSTEM.PASCAL not found on volume %s', [BootVolume.VolumeName]);

    OS_BlockNr        := DelphiDirEntry.FirstBlk;  // starting block of SYSTEM.PASCAL
    BootVolume.SeekInVolumeFile(OS_BlockNr);       // position to load SYSTEM.PASCAL

    SP := SP - BLOCKSIZE;   // allocate 1 block for segdict on stack

    SegDictP := SP;          // set SEGDICT to point to the segment dictionary
    BootVolume.UCSDBlockread(Bytes[SegDictP], 1); // load the segment dictionary for SYSTEM.PASCAL

    move(Bytes[SegDictP], SegmentDictionary, SizeOf(SegmentDictionary));


  // STEP 7

  //DebugMessage('STEP 7: Flip segment dictionary if opposite byte sex');

    SegSex := SegmentDictionary.sex; // last word of the block

    if SegSex <> 1 then
      begin
        DebugMessage('Segment dictionary: byte sex is being flipped');
        with SegmentDictionary do  // using local copy
          begin
            for i := 0 to MAXSEG do
              begin
                with disk_info[i] do
                  begin
                    FlipSex(code_addr);
                    FlipSex(code_leng);
                  end;
                FlipSex(seg_misc[i].SegMiscRec);
              end;
            FlipSex(Sex);

            // update in p-Sys Memory
          end;
      end;

  // STEP 8

  //DebugMessage('STEP 8: Read USERPROG code segment');

    BP := SegDictP;

  // make sure segment length is a multiple of the word resolution (8 words)
  // by ADDing with resolution-1, and then ANDing with NOT(resolution-1).

    with SegmentDictionary.disk_info[USERPROGNR] do
      begin
        Wrd       := Code_Leng; // WordAt[SegDict+31];
        Wrd       := Wrd + (RESOLUTION-1);
        Code_Leng := Wrd and (NOT (Resolution - 1));
        AX        := Code_Addr + OS_BlockNr;
        SegLength := Code_leng;  // get UserProg segment length
      end;

    move(SegmentDictionary, Bytes[SegDictP], SizeOf(SegmentDictionary));

  //  Allocate space on stack for USERPROG

    SegLength := SegLength SHL 1;       // convert from word count to byte count
    SP        := SP - SegLength;        // allocate space on the stack
    SP        := SP AND $FFF0;          // make sure its on a segment boundry
    UserBase  := SP;

    LocalVar  := SP;

    Globals.LowMem.SEGB     := SP;      // Trying to set the segment base (on the stack)

    ES       := Globals.LowMem.SEGB;       // save addr of 1st byte of executable code
    DS       := Globals.LowMem.SEGB;

    SysRd(fBootUnit, UserBase, SegLength, AX);  // Load UserProg

  // STEP 9 - Flip USERPROG code segment if opposite byte sex

//  BP      := UserBase;
    AX      := Bytes[UserBase+SegSex_];
    if AX <> 1 then // incorrect byte sex
      raise Exception.Create('STEP 9: Flip USERPROG code segment if opposite byte sex');

  // STEP 10 - Build MEMINFO record

    AX      := (Globals.MemTop) div BLOCKSIZE; // FREE SPACE IN BLOCKS

    SyscomPtr^.mem_info := Integer(@TGlobals(nil^).MemInfo); // create pointer to meminfo
    with Globals.MemInfo.FreeSpaceInfo do
      begin
        if PoolOutside then
          begin
            Base    := LongIntToFullAddress(LOW64K+2);
            Size    := HIMEM div BLOCKSIZE;
          end
        else
          begin
            Size    := (Globals.MemTop) div BLOCKSIZE; // set free space size in blocks
            Base[0] := Globals.MemTop;               // save as least sig word of 32 bit addr
            Base[1] := 0;  // save as most sig word of 32 bit addr
          end;
  {$Ifdef Debugging}
        CodePoolBase := FullAddressToLongWord(Base);
  {$EndIf}
      end;

  // STEP 11 - Build TIB
  // STEP 12 - Build KERNEL Global Data Area

    // 2, 3. get datasize for kernel globals in bytes
    AX := (SegmentDictionary.seg_family[KERNELPROGNR].data_size) SHL 1;    // 3. convert to bytes

    AX := AX + MSCWSIZE;   // 4. add size of MSCW (excluding TrickArray)

//  The following three lines are wrong! (Maybe not :)
    EvecStuffAddr := AX;   // This is where we will load the EVEC, ERECs and SIBs for VERSION 4.12
    EvecStuffLen  := EVEC_ByteCount + EREC_ByteCount + SIB_ByteCount;
    AX := AX + EvecStuffLen;  // make room for the EVEC, ERECs, and SIBs

    MAINMSCWp := Integer(@TGlobals(nil^).MAINMSCW); // 5. Offset to global variable MSCW
  //with TMSCWPtr(@Bytes[MAINMSCWp])^ do            // Assembler refers to MAIN_MSCW
  //  begin
  //    STATLINK := MAINMSCWp;
  //    DYNLINK  := MAINMSCWp;
  //  end;

    RootTaskP := Integer(@TGlobals(nil^).RootTask); // Offset to global RootTask
    with TTibPtr(@Bytes[RootTaskP])^ do
      begin
        with regs do
          begin
            sp_upr  := Globals.MemTop;
            sp_low  := MAINMSCWp + AX;   // 7. set TIB.SP_LOW. This is also the high address of the code pool for the segment
            prior   := $80;
            procnum := 1;
          end;
        Task_Stuff  := 3;        // [bit 0] indicates operating system main task; [bit 1] indicates system tasks
        Start_MSCW  := MAINMSCWp;
      end;

    if VersionNr = vn_VersionIV then
      BuildEnvironmentIV
    else
      BuildEnvironmentIV4_12(EvecStuffAddr, EvecStuffAddr + EvecStuffLen);

  // STEP 14 - Build MSCW
  // allocate 5 words on stack for mscw

    SP      := SP - MSCWSize;        // 14 (NOT SizeOf(TMscw) which includes TrickArray)
    MP      := SP;                   // 14b. set "Local Activation Record" address
    WordAt[MP+2] := MP;              // 3/1/2023 DEBUGGING - KLUDGE - TRYING TO ENSURE THAT
                                     //          VERSION 4.12 WILL HAVE A INITIAL SP SET
    Globals.Lowmem.MPPlus  := MP + MSCWDISP;        // 14d.

    with TTibPtr(@Bytes[RootTaskP])^ do
      begin
        regs.SP  := MP;
        regs.mp  := MP;
        regs.env := Globals.LowMem.ERECp;   // Points to the Kernel's EREC
      end;

  //  Initialize the MAIN MSCW

    Globals.LowMem.CURPROC := 1;

    // Link back to the main mscw

//  SysComOffset := Integer(@TGlobals(nil^).LowMem.SysCom);
//  Assert(SysComOffset = LOWMEMSIZE, 'System error: SycCom not properly located');

    with TMscwPtr(@Bytes[MAINMSCWp])^ do
      begin
        STATLINK     := MAINMSCWp;
        DYNLINK      := MAINMSCWp;
        MSENV        := Globals.LowMem.ERECp;
        MSPROC       := Globals.LowMem.CURPROC;
//      LOCALDATA[0] := SysComOffset;  // set address of SysCom (=$E6)
        LOCALDATA[0] := SyscomAddr;
      end;

  // STEP 15 - Init PME Registers

    with Globals.LowMem do
      begin
        ReadyQ    := RootTaskP;
        CurTask   := RootTaskP;
        Base      := MainMscwP;
        BasePlus  := Base + MSCWDISP;
        GlobVar   := BasePlus;                      // point to global data area
        CPOFFSET  := ESWord[SEGCONST_] * 2;         // byte offset to constant pool offset word
        SI        := WordAt[SEGB + SEGPROC_] * 2;   // byte offset to procedure dictionary
        SegTop    := SI;                            // point to procedure dictionary
        SI        := SI - 2;                        // offset of proc 1 entry
        SI        := WordAt[SEGB + SI] * 2;         // byte offset to procedure 1 code
        SI        := SI + 2;                        // skip over proc 1 datasize
        Globals.MAINMSCW.MSIPC    := SI;
        Globals.RootTask.regs.ipc := SI;            // set TIB.REGS.IPC
        WordAt[MP+MSIPCL]      := SI;            // set MSCW.MS_IPC
                                                    // SI is now correct IPC pointer
      end;

  //      something needs to be pointing at Segment Dictionary

  // STEP 16 - Start PME
  (*
  Params: BX - PME MPPLUS register          {start of local data}
          SP - PME SP register
          DX - PME BASEPLUS register
          SI - PME IPC register
          DS - PME code segment base        (Same as Globals.LowMem.SEGb)
          CS - PME 8086 segment address of PME
          SS:MP      - PME MP register      (current MSCW)
          SS:CURTASK - PME curtask register (^Current TIB)
          SS:READYQ  - PME READYQ register
          SS:EVEC    - PME EVEC register    (EVECp)
          SS:EREC    - PME EREC register    (ERECp)
          SS:SegBot  - PME SEGBASE register (Globals.LowMem.Segb)
          SS:CURPROC - PME CURPROC register
          SS:SEXFLAG - PME current segment sex
          SS:SEGTOP  - PME pointer to procedure dictionary
          SS:CPOffset- PME offset to constant pool
          CS:SSDSVAL - PME 8086 segment address of stack/heap space

          BASE       - Global data area
  *)

    LocalVar      := Globals.Lowmem.MpPlus;       // Point to the local data area

  //      Now we can go for it...

    DS       := ES;          // DS = ES = SegBot
  {$IfDef debugging}
    ProcBase := SI;          // CalcProcBase(Globals.LowMem.SEGB, 1);
  {$EndIf}

    InBufPtr := @SyscomPtr^;
    // Could the above just be:
    // InBufPtr := TInBufPtr(SyscomPtr);
    // ?
    LoadMiscInfo(fVolumesList[Unitnr].TheVolume, CSYSTEM_MISCINFO, InBufPtr^);

    with frmPSysWindow do
      begin
        OnBreakKeyPressed := HandleBreakKey;
        LoadCrtKeyInfo(InBufPtr, CrtInfo, KeyInfo, VersionNr);
        CrtInfo.TermType := FilerSettings.TermType;
        CrtInfo.InfoChanged;
      end;

    // following are for debugging purposes
    with SyscomPtr^ do
      begin
  //    if gdirp <> 0 then
  //      begin  // attempting to set the current date/time
  //        DirPtr := TDirectoryPtr(@Bytes[gdirp]);
  //        with DirPtr^[0] do
  //          SetDirectoryDateTime(DLASTBOOT, DLOADTIME);
  //      end;
        Miscinfo.FLAGS  := 999;
        Processor       := DEFAULT_PROCESSOR_TYPE;  {9}
        pmachver        := iv_1;
        Assert(realsize = CREALSIZE, 'SYSTEM.MISCINFO has incompatible realsize');
      end;
  except
    on e:Exception do
      DebugMessageFmt('System error: %s', [e.message]);
  end;
end;   { Load_PSystem }

//   TStatusProc = procedure {StatusProc} (const Msg: string; DoLog: boolean = true; DoStatus: boolean = true) of object;
procedure TIVPsystemInterpreter.StatusProc(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true);
begin
  inherited;
end;

procedure TIVPsystemInterpreter.Initialize_Interp;
begin { TIVPsystemInterpreter.Initialize_Interp }
  frmPSysWindow.Show;

  with frmPSysWindow do
    begin
      WriteLn('1Mb p-machine (IV) Dan Dorrough 2018/2024');
      Writeln([' Ver 1.0  dhdorrough@gmail.com']);
    end;

{$IfDef debugging}
  WatchTypesTable[wt_real].WatchSize := SizeOf(Double); // Using 4 word reals
  WatchTypesTable[wt_real].WatchCode := 'R4';
{$endIf}  

  InitUnitTable;
end;  { TIVPsystemInterpreter.Initialize_Interp }

procedure TIVPsystemInterpreter.XENABLE;
begin
  ENABLE(Globals.LowMem.CURTASK);
end;

(*
// CALLED FROM BIOS, EXTEVENT - IV2
// does a signal operation on the semaphore connected
// with the event # passed in DI
procedure TIVPsystemInterpreter.EVENT;
begin
  Unimplemented('EVENT');
  if DI < MAXEVENT then
    begin
      DI := EVENTVEC[DI];
      if DI <> pNIL then // ignore NIL entry
        SIG;
    end;
end;
*)

Constructor TIVPsystemInterpreter.Create( aOwner: TComponent;
                                        VolumesList   : TVolumesList;
                                        thePSysWindow : TfrmPSysWindow;
                                        Memo          : TMemo;
                                        TheVersionNr  : TVersionNr;
                                        TheBootParams    : TBootParams);
begin
  inherited;

  Assert(CREALSIZE = 4, 'Real operators may not work unless realsize = 4');

//VersionNr := vn_VersionIV;

  new(bytes);
  move(bytes, Words, 4);       // access either as words or bytes
  move(bytes, Globals, 4);     // access to other (non-syscom) stuff-- notice that Globals INCLUDES SysCom

  FillChar(Bytes^, InterpHIMEM, 0);  // initialize memory to all 0

  SyscomPtr := TSyscomPtr(@Bytes[SyscomAddr]);

  Initialize_Interp;
end;

procedure TIVPsystemInterpreter.SetSP(const Value: longword);
begin
  fSP := Value;
end;

// SLDC: 0..31 (0..$1F)
// Short Load Word Constant. Push the opcode, with the high byte zero.
procedure TIVPsystemInterpreter.SLDC;
begin
  PUSH(fOp);    // constant from 0..31
end;

//------------------------------------------------------------------------------
// GETU
//       GET LOGICAL UNIT NUMBER AND VALIDATE REQUEST SUBROUTINE
// INPUT
//       TOS   = Logical unit number
//       UBLK  = Logical block number
// OUTPUT
//       UNUM  = physical unit number
//       UBLK  = physical block number
//       IORSLT
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.getu(var UNUM: byte; var UBLK: word);
var
  UTablePtr: TUTablePtr;
//UTableEntryPtr: TUTablEntryPtr;
  UTableEntry: TUTablEntry;
  SvolOffset: word;
begin
  SyscomPtr^.iorslt := INOError;     // ASSUME ALL WILL BE VALID.
  UNUM  := POP();       // LOGICAL UNIT NUMBER (LUN)

  if UNUM <= 8 then // standard unit
    begin
      if (UNUM in [4,5]) // disk volumes
         and (not Assigned(fVolumesList[UNUM].TheVolume)) then
        begin
          SyscomPtr^.iorslt := INOUNIT;
//        raise EIOResult.CreateFmt('Unknown unit = #%d', [UNUM]);   // Does not deserve and exception
        end
    end
  else
    begin
      // subsidiary volume if (UNUM >= OSVOLSTRT) and (UNUM <= OSVOLMAX)
      with SyscomPtr^ do                                                                                         
        if (UNUM >= SubSidStart) and (UNUM <= SubSidStart + UnitDivision.SubsidMax) then
          begin
            UTablePtr      := TUTablePtr(@Bytes[SyscomPtr^.UnitTable]);
            UTableEntry    := UTablePtr^[UNUM];
            SvolOffset     := UTableEntry.uBlkOff;
            if SVolOffset = 0 then
              IORslt := INOUNIT
            else
              begin
                if UBLK >= UTableEntry.UEOVBLK then
                  iorslt := IBADBLOCK
                else
                  begin
                    UBLK := UBLK + UTableEntry.UBLKOFF;
                    UNUM := UTableEntry.UPHYSVOL;   // This is the physical unit that will actually be read
                  end;
              end;
          end
        else
          if (UNUM > MAX_FILER_UNITNR) or (not Assigned(fVolumesList[UNUM].TheVolume)) then
            IORslt := INOUNIT;
    end;
end;

procedure TIVPsystemInterpreter.MOVSB(Src, Dst: longword; Len: word);
begin
  if Integer(Len) > 0 then
    Move(Bytes[Src], Bytes[Dst], Len);
end;

//  Name:   GetPool
//
//  ENTRY: (tos) = number of bytes to move
//         (tos+2) = pool offset
//         (tos+4) = poolptr
//         (tos+6) = destination address
procedure TIVPsystemInterpreter.GetPool;
var
  Src: longword; SrcO, DstO: word;
begin
  SaveIPC;                // fault handlers may depend on this

  CX   := POP();          // number of bytes to move
  SrcO := POP();          // pool offset
  BP   := POP();          // poolptr
  DstO := POP();          // destination offset

  Src  := PoolBase(BP);   // get pool address-- source is in pool

  MovSB(Src+SrcO, DstO, CX);  // do move
  //              DS := ES?
  //              ES := SAVEDES
end;

procedure TIVPsystemInterpreter.PutPool;
var
  {Src,} Dst: longword; SrcO, DstO: word;
begin
  SaveIPC;
  CX      := POP();       // number of bytes to move
  DstO    := POP();       // pool offset
  BP      := POP();       // poolptr
  SrcO    := POP();       // source address

  Dst     := PoolBase(BP);   // get base address of pool
//Src     := 0;                 // Src is in the stack segment (low 64kb)
  MovSB({Src+}SrcO, Dst+DstO, CX);
end;


//  ------------------------------------------------------------------------------
//   UREAD
//   UWRITE
//         STANDARD PROCEDURE UNITREAD
//         STANDARD PROCEDURE UNITWRITE
//   INPUT
//         TOS    = CONTROL WORD
//         TOS+2  = BLOCK NUMBER
//         TOS+4  = BYTE COUNT
//         TOS+6  = BYTE OFFSET
//         TOS+8  = WORD BASE
//         TOS+10 = UNIT NUMBER
//   OUTPUT
//         TOS    = UNIT NUMBER
//  ------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.UWRITE;
var
  BYTEOFFSET,
  WORDBASE,
  UNITNUMBER: word;
begin
  AL      := OUTBIT;
  BP      := SP;
  if WordAt[BP+10] = 1 then  // console write
    begin
      Pop(UCTL);
      Pop(UBLK);
      Pop(ULEN);
      Pop(BYTEOFFSET);
      Pop(WORDBASE);
      Pop(UNITNUMBER);
      UNITBL[UnitNumber].Driver.UnitWrite(Bytes[WORDBASE+BYTEOFFSET], ULen, UBlk, UCtl);
    end
  else
    UIO;
end;

procedure TIVPsystemInterpreter.TIM;
var
  aWord: record
           case integer of
             1: (lw: longword);     // time in ms
             2: (wlow: word; whigh: word)
         end;
  AddrL, AddrH: word;
begin
  aWord.lw := Round(GetTickCount / SysUtils.MSecsPerSec) * 60;  // time in 60ths of a second
  AddrL := Pop();
  AddrH := Pop();
  WordAt[AddrH] := aWord.whigh;
  WordAt[AddrL] := aWord.wlow;
end;

procedure TIVPsystemInterpreter.IOC;
begin
  with SyscomPtr^ do
    if iorslt <> INOERROR then
      begin
//      BP := UIOERRC;
        fErrCode := UIOERRC;
//      raise EXEQERR.Create('IOResult = %s', [IOResultStrings[iorslt]], UIOERRC);
        raise EXEQERR.CreateFmt('IOResult = %s', [IOResultStrings[iorslt]]);
      end;
end;




procedure TIVPsystemInterpreter.UREAD;
begin
  AL := INBIT;
  UIO
end;

                                      
procedure TIVPsystemInterpreter.UIO;
begin
  ESVAL := 0;
  SYSIO;
end;

//  Name     :  SYSIO
//  Function : Perform an IO function
//  Entry    : AX           // the request
//             (TOS)        // load address
//             (TOS+1)      // byte offset
//             (TOS+2)      // byte count
//             (TOS+3)      // block number
//             (TOS+4)      // control word
//  Returns  : SyscomPtr^.iorslt

procedure TIVPsystemInterpreter.SYSIO;
var
  Base_Addr, Byte_Offset: word;
begin
  UREQ        := AL;          // REQUEST
  UCTL        := POP();       // CONTROL
  UBLK        := POP();       // BLOCK #
  ULEN        := POP();       // BYTE COUNT (BUFFER LENGTH)
  Byte_Offset := POP();       // BYTE OFFSET
  Base_Addr   := POP();       // LOAD ADDRESS
                              // at this point, the UNUM is now TOS
  UBUF        := Base_Addr + Byte_Offset;     // make buffer address
//AX          := word(CALLIO);      // Some callers still expected AX to contain the IO result
  CallIO;                     // 5/12/2022 turned it into a procedure that returns to SyscomPtr^.iorslt
end;


//------------------------------------------------------------------------------
// CALLIO
//       CALL A DRIVER ROUTINE
// INPUT
//       TOS = UNIT NUMBER
// OUTPUT
//       Result := IOResult // dhd 4/9/2018
//------------------------------------------------------------------------------

procedure TIVPsystemInterpreter.CallIO;
var
//UTableAddr: word;
  result: TIoRsltWD;
begin
  GetU(UNUM, UBLK);                 // get UnitNr from TOS

  result := INOUNIT;

  if UNUM = 0 then
//  raise ESYSTEMHALT.Create('System HALT in CALLIO')
    HaltPsys('System HALT in CALLIO')
  else
    if UNUM < MAX_STANDARD_UNIT then
      begin
        if (UNUM > 0) and Assigned(UNITBL[UNUM].Driver) then
          with UNITBL[UNUM] do
            begin
              result := Driver.Dispatcher(UREQ, UBLK, ULEN, Bytes[ESVAL+UBUF], control);
(*
              if UNUM >= 4 then
                OutputDebugStringFmt('CallIO: UNUM=%d, UBLK=%d, ULEN=%d, UBUF=$%4.4X, RESULT=%d',
                                      [UNUM, UBLK, ULEN, ESVAL+UBUF, ord(RESULT)]);
*)
            end
        else
          result := IBADUNIT;
      end;

  SyscomPtr^.iorslt := result;
end;



//------------------------------------------------------------------------------
// UCLEAR
//       STANDARD PROCEDURE UNITCLEAR
// INPUT
//       TOS = UNIT NUMBER
// OUTPUT
//       NONE
//------------------------------------------------------------------------------

procedure TIVPsystemInterpreter.UCLEAR;
begin
  SAVDS   := DS;          // save PME reg
  UREQ    := CLRBIT;
  UCLR;
end;

procedure TIVPsystemInterpreter.UCLR;
begin
  SYSCLR;
end;

procedure TIVPsystemInterpreter.SYSCLR;
begin
  UBLK    := 0;
  ESVAL   := 0;
  CALLIO;
end;



//------------------------------------------------------------------------------
// UWAIT
//       STANDARD PROCEDURE UNITWAIT
//       (NO WAIT FOR SYNCHRONOUS I/O.)
// INPUT
//       TOS = UNIT NUMBER
// OUTPUT
//       NONE
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.UWAIT;
begin
  SAVDS   := DS;          // save PME reg
//DS      := CS;
  UREQ    := INBIT OR OUTBIT;  // ASSURE VALID REQUEST
  UBLK    := 0;
  GETU(UNUM, UBLK);
end;

//------------------------------------------------------------------------------
// USTATUS
//       STANDARD PROCEDURE UNITSTAUTS
// INPUT
//       TOS   = CONTROL WORD
//       TOS+2 = ^STATUS RECORD
//       TOS+4 = UNIT NUMBER
// OUTPUT
//       NONE
//------------------------------------------------------------------------------
procedure TIVPsystemInterpreter.USTATUS;
begin
        SAVDS   := DS;          // save PME register
//      DS      := CS;
//      SAVBX   := BX;
        UCTL    := POP();       // CONTROL WORD
        UBUF    := POP();       // STATUS RECORD POINTER
        UREQ    := STATBIT;     // REQUEST = STATUS
        UCLR;
end;


// MOVE A BLOCK OF BYTES LEFT. ASSUMING BOTH BLOCKS ARE OFF SP:DS VAL
procedure TIVPsystemInterpreter.MYMOVE;
var
  SrcO: word;
  DstO: word;
  cnt: integer;
begin
    SaveIPC;                // fault handlers may depend on this
{$R-}                       // count might be negative
    cnt      := POP();       // 1. CX:=# OF BYTES TO MOVE
    if cnt > 0 then
      begin
        DstO    := Pop() + Pop();  // Get destination
        SrcO    := Pop() + Pop();  // Get source

        MOVE(Bytes[SrcO], Bytes[DstO], cnt);
      end
    else
      SP := SP + 8;             // because nothing got popped
{$R+}
end;

// Name:     MOVESEG
// Function: Relocate a segment
// Entry:    (TOS) = source offset
//           (TOS+1) = ^source pool descriptor
//           (TOS+2) = ^destination SIB
//           (TOS+3) = source pool base
//
procedure TIVPsystemInterpreter.MOVESEG;
var
  Src, Dst: longword;
  SrcO, DstO: word;
  SibAddr : word;
  Len: integer;
begin
  SrcO    := POP();       //  2. source offset [SrcO]
  BP      := POP();       //  3. ^source pool descriptor
  SibAddr := POP();       //  4. ^destination sib

  Src     := PoolBase(BP);     //  6. set up source address

  //  set up destination address

  with TSibPtr(@Bytes[SibAddr])^ do
    begin
      DstO  := Seg_Base;
      BP    := Seg_Pool;
      Dst   := PoolBase(BP);          //  13. destination pool base
      Len   := Seg_Leng SHL 1;
      if Len > 0 then
        MOVE(Bytes[Src+SrcO], Bytes[Dst+DstO], Len);
    end;
end;

procedure TIVPsystemInterpreter.RLOCSEG;
label 9;
var
  RelEvec : word;
  ErecPtr : TErecPtr;
  ErecAddr: word;
  Src: longword;
  SrcO: word;
begin { RLOCSEG }
  ErecAddr := Pop();                 // 1. ^ erec

  ErecPtr  := TErecPtr(@Bytes[ErecAddr]);
  with ErecPtr^ do
    begin
      RelEvec := {ErecPtr^}Env_Vect;  // save evec for later
      with TSibPtr(@Bytes[env_sib])^ do
        begin
          BP  := Seg_Pool;            // ^PoolDescInfo
          Src := PoolBase(BP) + Seg_Base; // 7. find PoolBase, add offset in pool (Src == DS)
        end;
    end;

  //  Src now has seg base address
  SrcO      := WordAt[Src+SEGRELOC_]; // 13. seg relative word offset of relList.
                                  //     i.e.: MOV SI,SEGRELOC; MOV     SI,(SI)
  if SrcO <> 0 then                 // 15. exit if no list
    begin
      raise Exception.Create('Assembly language proc called (LONGINT?). RLOCSEG cannot handle relocation lists');
      SrcO      := SrcO SHL 1;    // 16. words to bytes
//    STD                     // 17. set DIRECTION flag to negative

//$0  //  DS:(SI) is top of a sublist. if real, relocate it
      repeat
        repeat
          AX     := WordAt[Src+SrcO];// 18. (LODSW) AH=reloctype, AL=datasegnum
          SrcO     := SrcO - 2;
          if AH = 0 then              // 19. if rloctype = 0
            goto 9;                   // 20.   then end of list

          CX       := WordAt[Src+SrcO];    // 22. (LODSW) CX = list size {elements in list}
          SrcO     := SrcO - 2;           //
        until cx <> 0;

        case AH of
          1: // 25. if rloctype = 1 then seg relative }
{ $4}       begin //  skip a relocation sublist
              CX      := CX SHL 1;    //  26. double count to become bytes in entries
              SrcO      := SrcO - CX;     //  27. decrement pointer to the next sublist
            end;
          2: { if rloctype = 2 then base relative }
{ $3}       begin //  base relative relocation sublist

              AH        := 0;       // Local segname of segment ref'd  [addr: $1b8c]
              BP        := AX;
              BP        := BP SHL 1;   // now a byte offset
              BP        := RelEvec + BP; // now ^local_evec[refd_seg]           // BP := EvecPtr^.Map[AX]
              BP        := WordAt[BP];
              AX        := WordAt[BP+EnvData];  // base address of ref'd environment so relocate to it

              //  reloc one sublist by AX

              repeat
                DI    := WordAt[Src+SrcO];   // OK TO HERE!
                WordAt[Src+DI] := WordAt[Src+DI] + AX;   // OK to here thru 1st pass!  [addr: $1b9f]
                SrcO  := SrcO - 2;
                CX    := CX - 1;     // CX is wrong - MAYBE -  Use F7 in TD
              until cx = 0;
            end;
          3: { if rloctype = 3 then interp relative }
            begin
  // $1      //  interpreter relative relocation
              Unimplemented('rloctype = 3: interpreter relative relocation');
(*
              repeat
                DI      := DSWord[SI];   // 38. DI :+ byte_offset of reloc victim
                SI      := SI - 2;          // 39. move pointer down to next element
                BP      := DSWord[SI];   // 40. add factor to location in segment
                if (BP and $8000) = 0 then  // 42. check for negative displacement
                  WordAt[Src+DI+2] := CS;    // 43. set CS of PME
    // $01
                repeat
                  BP      := WordAt[BP+IRELTABLE]; // 44. get offset
                  WordAt[Src+DI] := BP;    // 45. set offset
                  CX    := CX - 1;
                until CX = 0;
              until cx = 0;
*)
            end;
          else
            Unimplemented('rloctype > 3');
        end;
      until false;
    end;
9: // $9
//DS      := POP();       //  restore SEGB
  GetSavedIPC;            // IPCFETCH - deleted 3/16/2020 because its presence was causing the instruction
                          //            that followed a SCXG RLOCSEG to be skipped
end;  { RLOCSEG }

// Name:     CXG: 148 ($94)
// Function: Call Global External Procedure. Call procedure UB_2 which is at lex level 1
//           and in the segment UB 1. If the segment number is 1, then the procedure
//           code may be embedded in the Interpreter; an Interpreter table contains its
//           location.
procedure TIVPsystemInterpreter.CXG;
begin
  SaveIPC;                  //in case of fault
  BP := Bytes[DS+SI];       //local number for target segment
  SI := SI + 1;
  CXGIMMED;
end;

//*****************************************************************************
//   Function Name     : CXGIMMED
//   Useage            :
//   Function Purpose  :
//   Assumptions       :
//   Parameters        : BP = procedure number to call
//   Return Value      :
//*******************************************************************************}

procedure TIVPsystemInterpreter.CXGIMMED;

  procedure CXGERROR;
  begin { CXGERROR }
    raise Exception.CreateFmt('CSPTABLE procedure %d:%s [$%s] is undefined',
                              [DI, OpsTable.CSPTABLE[DI].Name, HexWord(DI)]);
    SI := SI + 1;
  end;  { CXGERROR }

  procedure Inner;
  begin { INNER }
//    try
{ $0}
      AL    := Bytes[DS+SI];// 13. Get procedure number
      SI    := SI + 1;
      ES    := DS;           // 15. ES = DS = SEGB
//    DS    := SS;           // 17. DS = SS
      SAVEPAR := AL;         // 18. and remember it?
      NEWSEGMENT;            // 19. build new environment
      if IsSegFault then        // 20.
        raise ESEGBACK.Create('Segment fault in CXGIMMED'); // 20. OOPS, Segment fault (this should then try to load the segment!)
      PUSH(Globals.Lowmem.BASE);            // 21. static link to be put into new frame
      fAX.L    := SAVEPAR;   // 22. procedure number
      fAX.H    := 0;         // 23.
      XCHG(fAX.w, fBP.w);    // 24.
      BLDFRM;                // 25.
      if StackOverFlow then     //
        raise ESSTKBACK.Create('Stack fault in CXGIMMED'); // 26. OOPS, stack fault
      CHGSIB;                // 27. clean up the stack marker
      DS := ES;              // 29. DS = ES = SEGB
  end;  { INNER }

begin { CXGIMMED }
  if BP = 1 then          // 1. this procedure is embedded in the interpreter
    begin
      DI := (Bytes[DS+SI] and $FF); // 3. then get the procedure number from p-code stream
      if (DI <= OpsTable.CSPEnd) then
        if Assigned(OpsTable.CSPTABLE[DI].ProcCall) then // 5. make sure it is in table
          begin
            SI     := SI + 1;     // 11. bump the IPC
            if DI <> CSP_RLOCSEG then  // KLUDGEOLA
              SaveIPC;            // in the Z80 interpreter, the procedure is JUMPED to-- not called,
                                  // 11/6/2019: so, to prevent an obsolete SI from being restored,
                                  //            we need to save it again (except for RLOCSEG)
            with OpsTable.CSPTABLE[DI] do
              begin
                ProcCall; // 12. and call the procedure
{$IfDef pocahontas}
                Inc(PHITS);
{$EndIf}                      
              end;
          end
        else
          Inner
      else
        Inner;
    end
  else
    Inner;
end;  { CXGIMMED }

procedure TIVPsystemInterpreter.InitJumpTable(InterpreterOpsTable: TCustomOpsTable);
Var
  i: integer;
begin { InitJumpTable }
  with InterpreterOpsTable do
    begin
      for i := 0 to OpsTable.HighPCode do with Ops[i] do begin Name  := ''; {Range := [];} ProcCall := nil end;

      AddOp('SLDC',   [0..31],    SLDC);      // short load constant
      AddOp('SLDL',   [32..47],   SLDL, -1);  // Short Load Local Word (SLDL 1.. SLDL 16)
      AddOp('SLDO',   [48..63],   SLDO, -1);  // Short Load Global Word
      AddOp('DECOPS', [64], DECOPS);               // DECOPS
      AddOp('SLLA',   [96..103],  SLLA, -1);  // Short load Local address (SLLA 1.. SLLA8)
      AddOp('SSTL',   [104..111], SSTL, -1);  // Short Store Local Word
      AddOp('SCXG',   [112..119], SCXG, -1);  // Short Call Global External Procedure
      AddOp('SIND',   [120..127], SIND);    // Short index and load word
      AddOp('LDCB',   [128],      LDCB);    // Load Constant Byte, high byte zero.
      AddOp('LDCI',   [129],      LDCI);    // Load Constant Word. Push W.
      AddOp('LCO',    [130],      LCO);     // Load Constant Offset
      AddOp('LDC',    [131],      LDC);     // Load Multiple Word Constant
      AddOp('LLA',    [132],      LLA);     // Load Local Address
      AddOp('LDO',    [133],      LDO);     // Load Global Word
      AddOp('LAO',    [134],      LAO);     // Load Global Address
      AddOp('LDL',    [135],      LDL);     // Load Local Word
      AddOp('LOD',    [137],      LOD);     // Load intermedicate word
      AddOp('LDA',    [136],      LDA);     // LOAD INTERMEDIATE ADDRESS
      AddOp('UJP',    [138],      UJP);     // Unconditional jump
      AddOp('JPL',    [139],      UJPL);    // Unconditional long jump
      AddOp('MPI',    [140],      MPI);     // integer multiply
      AddOp('DVI',    [141],      DVI);     // INTEGER DIVIDE
      AddOp('MODI',   [143],      MODI);    // integer modulo
      AddOp('STM',    [142],      STM);     // Store Multiple
      AddOp('CPL',    [144],      CPL);     // Call procedure local
      AddOp('CPG',    [145],      CPG);     // Call procedure global
      AddOp('CPI',    [146],      CPI);     // Call intermediate procedure
      AddOp('CXL',    [147],      CXL);     // Call local external procedure
      AddOp('CXG',    [148],      CXG);     // Call Global External Procedure
      AddOp('CXI',    [149],      CXI);     // Call external internediate
      AddOp('RPU',    [150],      RPU);     // Return from Procedure {OPCODE_RPU}
      AddOp('CFP',    [151],      CFP);     // Call procedure formal
      AddOp('LDCN',   [152],      LDCN);    // Load Constant NIL
      AddOp('LSL',    [153],      LSL);     // Load static link
      AddOp('LDE',    [154],      LDE);    // Load extended word
      AddOp('LAE',    [155],      LAE);    // Load extended address
      AddOp('NOP',    [156],      NOP);    // no operation
      AddOp('LPR',    [157],      LPR);    // Load Processor Register
      AddOp('BPT',    [158],      BPT);    // break point
      AddOp('BNOT',   [159],      BNOT);   // Boolean NOT
      AddOp('LOR',    [160],      LOR);    // Logical Or. OR TOS into TOS-1.
      AddOp('LAND',   [161],      LAND);   // Logical And. AND TOS into TOS-1.
      AddOp('ADI',    [162],      ADI);    // Add integers
      AddOp('SBI',    [163],      SBI);    // Subtract integers
      AddOp('STL',    [164],      STL);    // Store Local Word
      AddOp('SRO',    [165],      SRO);    // Store Global Word
      AddOp('STR',    [166],      STR);    // store immendiate word
      AddOp('LDB',    [167],      LDB);    // Load Byte
      AddOp('NAT',    [168],      NAT);    // Native code
      AddOp('NATI',   [169],      NATI);   // Native code information
      AddOp('CAP',    [171],      CAP);    // Copy Array Parameter
      AddOp('CSP',    [172],      CSP);    // Copy String Parameter
      AddOp('SLOD',   [173, 174], SLOD, -1); // Short Load Intermediate Word
      AddOp('EQUI',   [176],      EQUI);   // Equal Integer.
      AddOp('NEQI',   [177],      NEQI);   // Not Equal Integer
      AddOp('LEQI',   [178],      LEQI);   // Less than or Equal Integer
      AddOp('GEQI',   [179],      GEQI);   // Greater than or Equal Integer
      AddOp('LEUSW',  [180],      LEUSW);  // Less Than or Equal Unsigned
      AddOp('GEUSW',  [181],      GEUSW);  // Greater Than or Equal Unsigned
      AddOp('EQPWR',  [182],      EQPWR);  // Equal set
      AddOp('LEPWR',  [183],      LEPWR);  // less than or equal set
      AddOp('GEPWR',  [184],      GEPWR);  // greater than of equal set
      AddOp('EQBYT',  [185],      EQBYT);  // equal byte array
      AddOp('LEBYT',  [186],      LEBYT);  // less than or equal byte array
      AddOp('GEBYT',  [187],      GEBYT);  // greater than of equal byte array
      AddOp('SRS',    [188],      SRS);    // Sub-range set
      AddOp('SWAP',   [189],      SWAP);   // SWAP TOS with TOS-1
      AddOp('TNC',    [190],      TNC);    // truncate real
      AddOp('RND',    [191],      RND);    // round real
      AddOp('ADR',    [192],      ADR);    // Add real
      AddOp('SBR',    [193],      SBR);    // Subtract real
      AddOp('MPR',    [194],      MPR);    // Multiply real
      AddOp('DVR',    [195],      DVR);    // divide real
      AddOp('STO',    [196],      STO);    // Store Indirect
      AddOp('MOV',    [197],      MOV);    // Move B words
      AddOp('DUPR',   [198],      DUPR);   // Duplicate real on TOS
      AddOp('ADJ',    [199],      ADJ);    // Adjust set
      AddOp('STB',    [200],      STB);    // Store Byte
      AddOp('LDP',    [201],      LDP);    // Load packed
      AddOp('STP',    [202],      STP);    // Store into a Packed Field
      AddOp('CHK',    [203],      CHK);    // Range check
      AddOp('FLT',    [204],      FLT);    // Convert to floating point
      AddOp('EQREAL', [205],      EQREAL); // Equal real
      AddOp('LEREAL', [206],      LEREAL); // Less than or equal real
      AddOp('GEREAL', [207],      GEREAL); // Greater than or equal real
      AddOp('LDM',    [208],      LDM);    // Load multiple words
      AddOp('SPR',    [209],      SPR);    // store processor register
      AddOp('EFJ',    [210],      EFJ);    // Equal False Jump
      AddOp('NFJ',    [211],      NFJ);    // Not Equal False Jump
      AddOp('FJP',    [212],      FJP);    // False Jump
      AddOp('FJPL',   [213],      FJPL);   // Long False Jump
      AddOp('XJP',    [214],      XJP);    // case jump
      AddOp('IXA',    [215],      IXA);    // Index Array
      AddOp('IXP',    [216],      IXP);    // Index packed array
      AddOp('STE',    [217],      STE);    // Store extended word
      AddOp('INN',    [218],      INN);    // Set Membership
      AddOp('UNI',    [219],      UNI);    // Set union
      AddOp('INT',    [220],      INT);    // Set Intersection
      AddOp('DIF',    [221],      DIF);    // Set Difference
      AddOp('SIGNAL', [222],      SIGNAL); // signal
      AddOp('WAIT',   [223],      WAIT);   // wait
      AddOp('ABlI',   [224],      ABI);    // Absolute Value Integer
      AddOp('NGI',    [225],      NGI);    // Negate Integer
      AddOp('DUP1',   [226],      DUP1);   // Duplicate One Word
      AddOp('ABR',    [227],      ABR);    // Absolute real
      AddOp('NGR',    [228],      NGR);    // negate real
      AddOp('LNOT',   [229],      LNOT);   // Logical Not
      AddOp('IND',    [230],      IND);    // Index and Load Word
      AddOp('INC',    [231],      INCF);   // Increment Field Pointer
      AddOp('EQSTR',  [232],      EQSTR);  // Equal String
      AddOp('LESTR',  [233],      LESTR);  // Less than or equal string
      AddOp('GESTR',  [234],      GESTR);  // Greater than or equal string
      AddOp('ASTR',   [235],      ASTR);   // assign string
      AddOp('CSTR',   [236],      CSTR);   // Check String Index
      AddOp('INCI',   [237],      INCI);   // Increment Integer.
      AddOp('DECI',   [238],      DECI);   // Decrement Integer
      AddOp('SCIP',   [239, 240], SCIP, -1);   // Short Call Intermediate Procedure
      AddOp('TJP',    [241],      TJP);    // True Jump
      AddOp('LDCRL',  [242],      LDCRL);  // load real constant
      AddOp('LDRL',   [243],      LDRL);   // Load real
      AddOp('STRL',   [244],      STRL);   // Store real

      for i := 0 to CSPEND do with CspTable[i] do begin Name  := ''; ProcCall := nil end;

      AddCspOp('EXEC_ERROR', 2);              // These could all be added to the interpreter to speed up
      AddCspOp('LOADSEG', 3);                 // see: P403_1F.VOL:UTILS.TEXT for the source to these pascal routines
      AddCspOp('RLOCSEG', CSP_RLOCSEG,  RLOCSEG);       // or see: UTILS.TXT
      AddCspOp('PTR_ADD', 5);
      AddCspOp('PTR_SUB', 6);
      AddCspOp('PTR_LESS', 7);
      AddCspOp('PTR_GTR', 8);
      AddCspOp('PTR_GEQ', 9);
      AddCspOp('PRINT',   10);
      AddCspOp('PRINTINT', 11);
      AddCspOp('WRITESTR', 12);
      AddCspOp('CHECKUNIT', 13);

      AddCspOp('MOVESEG',  14, MOVESEG);
      AddCspOp('MOVELEFT', 15, MYMOVE);
      AddCspOp('MOVERITE', 16, MYMOVE);
      // There is no 17
      AddCspOp('UREAD',    18, UREAD);
      AddCspOp('UWRITE',   19, UWRITE);
      AddCspOp('TIM',      20, TIM);
      AddCspOp('FILLCHAR', 21, MYFILLCHAR);
      AddCspOp('SCAN',     22, SCAN);
      AddCspOp('IOC',      23, IOC);
      AddCspOp('GETPOOL',  24, GetPool);
      AddCspOp('PUTPOOL',  25, PutPool);
      AddCspOp('FLIPSEG',  26, FLIPSEG);
      AddCspOp('SQUIET',   27, XQUIET);
      AddCspOp('SENABLE',  28, XENABLE);
      AddCspOp('ATTACH',   29, ATTACH);
      AddCspOp('IOR',      30, IOR);
      AddCspOp('UBUSY',    31);
      AddCspOp('POT',      32, POT);
      AddCspOp('UWAIT',    33, UWAIT);
      AddCspOp('UCLEAR',   34, UCLEAR);
      // there is no 35
      AddCspOp('USTATUS',  36, USTATUS);
      AddCspOp('IDSEARCH', 37, IDSEARCH);
      AddCspOp('TREESRCH', 38, TREESRCH);
// Version IV.2 follows:
      AddCspOp('READSEG',  39, READSEG);
      AddCspOp('UREAD',    40, UREAD);
      AddCspOp('UWRITE',   41);
      AddCspOp('UBUSY',    42);
      AddCspOp('UWAIT',    43);
      AddCspOp('UCLEAR',   44);
      AddCspOp('USTATUS',  45);          // 45
      AddCspOp('READSEG',  46);
      AddCspOp('SETIO',    47);          // 47
      AddCspOp('FAULTHAN', 48);
      AddCspOp('WAITER',   49);
//    AddCspOp('POOLSEG',  50);
//    AddCspOp('COMMAND',  51);
    end;
end;  { InitJumpTable }


procedure TIVPsystemInterpreter.InitUnitTable;
begin
  with UNITBL[0] do
    begin
      Control  := ALLBIT;
      Driver   := nil;
    end; // SYSTEM

  with UNITBL[1] do
    begin
      Control := ALLBIT;
      Driver  := TCharacterDriver.Create(self, CONDRVR, frmPSysWindow, Control);
    end; // CONSOLE

  with UNITBL[2] do
    begin
      control := ALLBIT + NOECHO;
      Driver  := TCharacterDriver.Create(self, CONDRVR, frmPSysWindow, Control);
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
      Driver  := TPrinterDriver.Create(self, PTRDRVR, FilerSettings.PrinterLfn, Control);
    end;     // PRINTER

  with UNITBL[7] do    // REMIN:
    begin
      Control := INBIT+CLRBIT+STATBIT;
      Driver  := nil; // TCharacterDriver.Create(self, REMDRVR);
    end;  // REMIN

  with UNITBL[8] do   // REMOUT:
    begin
      Control := OUTBIT+CLRBIT+STATBIT;
      Driver  := TMemoDriver.Create(self, PTRDRVR, frmPSysWindow, fMemo);
    end; // REMOUT
end;

procedure TIVPsystemInterpreter.PushProcCall(ProcCall: OpsTables.TProcCall);
var
  dummy:  record
            case integer of
              0: (wrd: array[0..1] of word);
              1: (prc: TProcCall);
          end;
begin
  SP := SP - 4;
  Dummy.prc := ProcCall;
  PUSH(Dummy.wrd[1]);
  PUSH(Dummy.wrd[0]);
  raise Exception.Create('PushProcCall');
end;

procedure TIVPsystemInterpreter.SetSI(const Value: word);
begin
  fSI := Value;
end;

procedure TIVPsystemInterpreter.SetDI(const Value: word);
begin
  fDI := Value;
end;

function TIVPsystemInterpreter.GetDS: longword;
begin
  result := fDS;
end;

function TIVPsystemInterpreter.GetSegBase: longword;
begin
  result := fDS;
end;


procedure TIVPsystemInterpreter.SetDS(const Value: longword);
begin
  if fDs <> Value then // the IF is for debugging
    fDS := Value;
end;

procedure TIVPsystemInterpreter.SetES(const Value: longword);
begin
  fES := Value;
end;

procedure TIVPsystemInterpreter.SetMP(const Value: word);
begin
  fMP := Value;
end;


function TIVPsystemInterpreter.GetSP: longword;
begin
  result := fSP;
end;

destructor TIVPsystemInterpreter.Destroy;
begin
//  FreeAndNil(DebuggerSettings);

  inherited;
end;

procedure TIVPsystemInterpreter.SetSSDSVAL(const Value: WORD);
begin
  fSSDSVAL := Value;
end;

function TIVPsystemInterpreter.GetCurProc: word;
begin
  result := Globals.LowMem.CURPROC;
end;

function TIVPsystemInterpreter.GetMaxVolumeNr: integer;
begin
  result := MAX_FILER_UNITNR;
end;

{$IfDef Debugging}
function TIVPsystemInterpreter.GetProcBase: longword;
begin
  result := fProcBase;
end;

procedure TIVPsystemInterpreter.SetProcBase(const Value: longword);
begin
  inherited;
  fProcBase := Value;
end;
{$EndIf}

function TIVPsystemInterpreter.GetSI: word;
begin
  result := fSI;
end;

function TIVPsystemInterpreter.GetRelIPC: word;
begin
  result := fSI - fProcBase;
end;

function TIVPsystemInterpreter.InterpHIMEM: longword;
begin
  result := HIMEM;
end;

procedure TIVPsystemInterpreter.GetInterpMemory;
begin
  inherited;

end;

function TIVPsystemInterpreter.GetGlobVar: longword;
begin
  result := fDX;
end;

procedure TIVPsystemInterpreter.SetGlobVar(const Value: longword);
begin
  fDx := Value;  // SetDX;
end;

function TIVPsystemInterpreter.GetLocalVar: LongWord;
begin
  result := fBX.w;
end;

procedure TIVPsystemInterpreter.SetLocalVar(const Value: LongWord);
begin
  fBX.W := Value;
end;

function TIVPsystemInterpreter.GetOp: word;
begin
  result := fOp;
end;

procedure TIVPsystemInterpreter.SetOp(const Value: Word);
begin
  inherited;
  fOp := Value;
end;

function TIVPsystemInterpreter.SegNameFromBase(SegBase: longword): string;
begin
  if SegBase <> 0 then
    begin
      SetLength(Result, CHARS_PER_SEG_NAME);
      Move(Bytes[SegBase+SEGNAME_], Result[1], CHARS_PER_SEG_NAME);
      result := UCSDName(result);
    end;
end;

{$IfDef Debugging}
function TIVPsystemInterpreter.GetpCodeDecoder: TpCodeDecoder;
begin
  if not Assigned(fpCodeDecoder) then
    fpCodeDecoder := TpCodeDecoder.Create(nil, OpsTable, FALSE, VersionNr);
  result := fpCodeDecoder;
end;
{$EndIf}

function TIVPsystemInterpreter.GetAbsIPC: longword;
begin
  result := DS+SI;
end;

function TIVPsystemInterpreter.GetOpsTableClass: TOpsTableClass;
begin
  case VersionNr of
    vn_VersionIV:
      result := TOpsTableIV;
//  vn_VersionIV_12:
//    result := TOpsTableIV_12;
    else
      raise EUnknownVersion.Create('Invalid Version Number');
  end;
end;

function TIVPsystemInterpreter.GetSyscomAddr: longword;
begin
  if VersionNr = vn_VersionIV then // version 4.2
    result := LOWMEMSIZE_V4_20 else
  if VersionNr = vn_VersionIV_12 then
    result := LOWMEMSIZE_V4_12
  else
    raise Exception.CreateFmt('Unknown version: %s', [VersionNrStrings[VersionNr].Abbrev]);
end;

{$IfDef debugging}
// Name:    GetLegalWatchTypes
// Purpose: returns a set of the watch types that are legal in Version IV
function TIVPsystemInterpreter.GetLegalWatchTypes: TWatchTypesSet;
begin
  result := inherited GetLegalWatchTypes + // Union the common WatchTypes with the IV ones
           [wt_OpCodesDecoded, wt_RegDumpHex, wt_RegDumpDec, wt_Semaphore, wt_ERECp,
            wt_TIBp, wt_SIBp, wt_MSCWp, wt_EVECp, wt_Poolinfo, wt_PoolDescInfo,
            wt_ProcedureName, wt_FIBp, wt_FIB, wt_FaultMessage, wt_OpCodesDecoded,
            wt_DynamicCallStack, wt_StaticCallStack, wt_RegDumpHex, wt_RegDumpDec,
            wt_SegBaseInfo, wt_V_VectorMap, wt_W_ErecFromVectorMapN, wt_X_SibFromVectorMapN,
            wt_Y_SegBaseFromVectorMapN, wt_MemInfo, wt_ParamDescrP, wt_HeapInfo,
            wt_TaskInfo, wt_Ped_Pseudo_Sibp, wt_PedHeader, wt_SegRecP, wt_UnitTableP, wt_UnitTabEntry,
            wt_StringP, wt_FullAddress, wt_SegDict];
end;

function TIVPsystemInterpreter.GetStaticLink(MSCWAddr: word): word;
var
  p: TMSCWPtr;
begin
  p      := TMSCWPtr(@Bytes[MSCWAddr]);
  result := p^.STATLINK;
end;
{$endIf}

function TIVPsystemInterpreter.GetJTAB: word;
begin
  result := 0; // not needed in V4
end;

CLASS function TIVPsystemInterpreter.GetLEGAL_UNITS: TUnitsRange;
begin
  result := [4, 5, 9..MAX_FILER_UNITNR];
end;

  Function TIVPsystemInterpreter.MSCWField(MSCWAddr: word; MSCWFieldNr: TMSCWFieldNr): word;
  var
    p: TMSCWPtr;
  begin { MSCWField }
    p := TMSCWPtr(@Bytes[MSCWAddr]);

    with p^ do
      case MSCWFieldNr of
        csDynamic:
          result := DYNLINK;
        csStatic:
          result := STATLINK;
        csENV:
          result := MSENV;
        csProc:
          result := MSPROC;
        csIPC:
          result := MSIPC;
        else
          raise Exception.Create('System error: invalid call stack type');
    end;
  end;  { MSCWField }

procedure TIVPsystemInterpreter.InitIDTable;
begin
  inherited;
  fIDList := TIDListIV.Create;
  with fIDList as TIDListIV do
    InitIDs;
end;

function TIVPsystemInterpreter.GetCREALSIZE: integer;
begin
  result := 4;
end;

procedure TIVPsystemInterpreter.PutIOResult(value: integer);
begin
  SyscomPtr^.iorslt := TIORsltWD(Value);
end;

function TIVPsystemInterpreter.GetBaseAddress: longword;
begin
  result := DS + SI;
end;

function TIVPsystemInterpreter.GetByteFromMemory(p: longword): byte;
begin
  result := Bytes[p];
end;

function TIVPsystemInterpreter.GetWordFromMemory(p: longword): word;
begin
  result := Words[p];
end;

function TIVPsystemInterpreter.GetPoolOutside: boolean;
begin
//result := SyscomPtr^.PoolInfo.pooloutside;
  result := EnableExternalPool;  // 2/22/2023
end;

function TIVPsystemInterpreter.GetCPOffset: word;
begin
  result := Globals.LowMem.CPOFFSET;
end;

function TIVPsystemInterpreter.GetSegmentBaseAddress: longword;
begin
  result := SegBase; // or: result := DS;
end;

{$IfDef debugging}
function TIVPsystemInterpreter.DecodedRange(addr: longword; nrBytes: word;
  aBaseAddr: LongWord): string;
begin
  if not Assigned(fDecodeToMemDump) then
    begin
      fDecodeToMemdump := TDecodeToMemDump.Create(self, pCodeDecoder, aBaseAddr);
      with fDecodeToMemDump as TDecodeToMemDump do
        begin
          OnGetByte2 := GetByteFromMemory;
          OnGetWord2 := GetWordFromMemory;
//        OnGetJTAB  := GetJTAB;
        end;
    end;

  with fDecodeToMemDump as TDecodeToMemDump do
    Result     := DecodedRange(addr, nrBytes, aBaseAddr);
end;
{$endIf}

function TIVPsystemInterpreter.TheVersionName: string;
begin
  result := Format('LB %s', [VersionNrStrings[VersionNr].Name]);
end;

function TIVPsystemInterpreter.GetNextOpCode: byte;
begin
  result   := Bytes[DS+SI];
end;

initialization
finalization
end.

