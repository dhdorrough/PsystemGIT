unit pCodeDecoderUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, OpsTables, Misc, UCSDGlob, Interp_Const, Watch_Decl;

type
  TStatusUpdateProc = procedure {StatusUpdate} (const Msg: string) of object;

  TDecodeFormat = (dfUnknown, dfShortFormat, dfLongFormat,
                   dfLongFormat2, dfMemoFormat);

  TGetByteFunc            = function {GetByteAt}(p: longword): byte of object;
  TGetWordFunc            = function {GetWordAt}(p: longword): word of object;
  TGetBaseAddressFunc     = function {GetLongWordAt}: longword of object;
  TGetByteFromMemoryBased = function{GetByteFromMemoryBased}(base: word; offset: word): byte of object;
  TOnGetBasedWordFunc     = function {GetWordFromMemoryBased}(base: word; offset: word): word of object;
  TGetLongWordFunc        = function {Name}: longword of object;  // return the current JTAB for Version II
  TGetOneWordFunc         = function {Name}: word of object;  // return the current JTAB for Version II


  TAddLineProc = procedure {name}(const Line: string) of object;
  TAddLineSeparatorProc = procedure {name}(OpCode: word) of object;

  TDebugOpcodesTable = Class(TCustomOpsTable)
  end;

  EUndefinedFetchFunction = class(Exception);


  TpCodeDecoder = class(TObject)
  private
    { Private declarations }
    fErrors             : integer;
    fOnGetWord3         : TGetWordFunc;
    fOnGetCPOffset      : TGetOneWordFunc;
    fOnGetSegmentBase   : TGetLongWordFunc;
    fVersionNr          : TVersionNr;

    function GETBIG: TUnion;
    procedure BigOPR;
    procedure OpsNoOprnd;
    procedure OpsTwoOprnd;
    procedure OpsOneOprnd;
    procedure OpsSCXG;
    procedure OpsReljump;
    procedure OpsDbBig;     // OP DB B
    procedure OpsAddr;
    procedure OpsSignedWord;
    procedure OpsLongJump;
    procedure OpsUB1Ub2B;
    procedure OpsUB1WUB2;
    procedure OpsThreeOprnd;
    procedure OpsCXG;
    procedure OpsXJP;
    procedure SetProcNumber(const Value: word);
    procedure SetDecodeFormat(const Value: TDecodeFormat);
    procedure OpsNatNfo;
    procedure DECOPS;
    function GetWordAt(p: longword): word;
    function Compactify(const Line: string): string;
    procedure OpsLCO;
    function CPOffset: word;
  protected
    fBaseAddress   : longword;
    fDebugOpsTable : TCustomOpsTable;
    fDecodeFormat  : TDecodeFormat;
    fGetByteFromMemoryBased: TGetByteFromMemoryBased;
    fOnGetBaseAddressFunc: TGetBaseAddressFunc;
    fIPC           : longword;
    fOnGetJTAB     : TGetOneWordFunc;
    fOpBase        : longword;
    fOpcode        : byte;
    fOpcodeName    : string;
    fProcNumber    : word;
    fRelIPC        : word;
    fOnAddLine     : TAddLineProc;
    fOnAddLineSeparatorProc: TAddLineSeparatorProc;
    fOnGetByte3    : TGetByteFunc;
    fInterpreterOpsTable: TCustomOpsTable;
    fGetBasedWord  : TOnGetBasedWordFunc;

    procedure AddLine(const Line: string); virtual;
    procedure AddLineSeparator(OpCode: word); virtual;
    procedure InitDebugOpsTable(IncludeAllCSPOps: boolean; VersionNr: TVersionNr); virtual;
    function Lodsw: TUnion;
    procedure SetIPC(const Value: longword);
  protected
    fGetBaseAddressFunc: TGetBaseAddressFunc;

    function GetBaseAddress: word;
    procedure SetBaseAddress(const Value: word);
    function GetDebugOpsTable: TCustomOpsTable; virtual;
    function GetByteAt(p: longword): word; virtual;
    function GetByteAtAbs(p: longword): word;
    function SegmentBase: longword;
  public
    { Public declarations }
    procedure Decode( Addr: Longword;
                      Len: word;
                      StopAfterReturn: boolean = true;
                      aDecodeFormat: TDecodeFormat = dfUnknown;
                      aBaseAddr: longword = 0); virtual;
    procedure GenOpLine( OpCode: string;
                         const Oprnd1: string = '';
                         const Oprnd2: string = '';
                         const Oprnd3: string = ''); virtual;
    property DebugOpsTable: TCustomOpsTable
             read GetDebugOpsTable;
    property IPC: longword
             read fIPC
             write SetIPC;
    property RelIPC: word
             read fRelIPC
             write fRelIPC;
    property ProcNumber: word
             read fProcNumber
             write SetProcNumber;
    Constructor Create( aOwner: TComponent;
                        InterpreterOpsTable: TCustomOpsTable;
                        IncludeAllCSPOps: boolean;
                        VersionNr: TVersionNr); reintroduce; virtual;
    Destructor Destroy; override;
    property DecodeFormat: TDecodeFormat
             read fDecodeFormat
             write SetDecodeFormat;
    property ErrorCount: integer
             read fErrors
             write fErrors;
    property OnAddLine: TAddLineProc
             read fOnAddLine
             write fOnAddLine;
    property OnAddLineSeparator: TAddLineSeparatorProc
             read fOnAddLineSeparatorProc
             write fOnAddLineSeparatorProc;
    property ByteAt[p: longword]: word
             read GetByteAt;
    property WordAt[p: longword]: word
             read GetWordAt;
    property OnGetByte3: TGetByteFunc
             read fOnGetByte3
             write fOnGetByte3;
    property OnGetByteBased: TGetByteFromMemoryBased
             read fGetByteFromMemoryBased
             write fGetByteFromMemoryBased;
    property OnGetBaseAddress: TGetBaseAddressFunc
             read fGetBaseAddressFunc
             write fGetBaseAddressFunc;
    property OnGetWord3: TGetWordFunc
             read fOnGetWord3
             write fOnGetWord3;
    property OnGetBasedWord: TOnGetBasedWordFunc
             read fGetBasedWord
             write fGetBasedWord;
    property OnGetJTAB: TGetOneWordFunc
             read fOnGetJTAB
             write fOnGetJTAB;
    property BaseAddress: word
             read GetBaseAddress
             write SetBaseAddress;
    property OnGetCPOffset: TGetOneWordFunc
             read fOnGetCPOffset
             write fOnGetCPOffset;
    property OnGetSegmentBase: TGetLongWordFunc
             read fOnGetSegmentBase
             write fOnGetSegmentBase;
  end;

implementation

uses DecodeRange, MyUtils, uGetString, StStrL,
  InterpIV, PsysUnit,
  Interp_Decl;

const
  DEF_BYTECOUNT = 1000;

var
  DecopsNames: array[TDecOps] of string = (
    'Adjust',       '',
    'Add',          '',
    'Subtract',     '',
    'Negate',       '',
    'Multiply',     '',
    'divide',       '',
    'longToString', '',
    'TosToLong',    '',
    'Compare',      '',
    'IntToLong',    '',
    'longToInt');



function TpCodeDecoder.GETBIG: TUnion;
begin
{$R-}
  result.I   := CBW(ByteAt[fIpc]);  // get byte and convert to word (sign extend AL)
{$R+}
  fIpc := fIpc + 1;
  if (result.L and $80) <> 0 then // if sign bit is set
    begin
      result.L  := result.L and $7f;
      result.H  := result.L;
      result.L  := ByteAt[fIpc];
      fIpc  := fIpc + 1;
    end;
end;

procedure TpCodeDecoder.OpsXJP;
var
  Opr1: word;
begin
  Opr1 := GetBig.w;
  GenOpLine(DebugOpsTable.Ops[fOpCode].Name, IntToStr(Opr1));
end;

function TpCodeDecoder.GetDebugOpsTable: TCustomOpsTable;    // overridden for version II
begin
  if not Assigned(fDebugOpsTable) then
    fDebugOpsTable := TOpsTableIV.Create;  // overridden for version II
(* commented out 6/13/2023 - looking for a memory leak
    case fVersionNr of
      vn_VersionIV:
        fDebugOpsTable := TOpsTableIV.Create;
      vn_VersionIV_12:
        fDebugOpsTable := TOpsTableIV_12.Create;
    end;
*)
  result := fDebugOpsTable;
end;

function TpCodeDecoder.Compactify(const Line: string): string;
begin
  if Pos('''', Line) > 0 then  // Quick and dirty - simply copy any line that has a quote in it
    result := Line
  else
    result := RemoveRepeatedChar(Line, ' ');
end;


procedure TpCodeDecoder.GenOpLine( OpCode: string;
                                      const Oprnd1: string = '';
                                      const Oprnd2: string = '';
                                      const Oprnd3: string = '');
var
  Line: string;
begin
  case fDecodeFormat of
    dfShortFormat:
      Line := Compactify(Format('%s %s %s %s',
                               [Opcode,
                                Oprnd1,
                                Oprnd2,
                                Oprnd3]));
    dfLongFormat:
      Line := Format('%4s (%4d): %-6s   %6s  %6s  %6s',
                     [HexWord(fOpBase),
                      fIPC, // was fOpBase - fBaseAddress,
                      Opcode,
                      Oprnd1,
                      Oprnd2,
                      Oprnd3]);
    dfLongFormat2:
      Line := Format('%4s (%4d): [%3d] %-6s   %6s  %6s  %6s',
                     [HexWord(fOpBase),
                      fIPC, // was fOpBase - fBaseAddress,
                      fOpCode,
                      Opcode,
                      Oprnd1,
                      Oprnd2,
                      Oprnd3]);
    dfMemoFormat:
      Line := Format('%4d: %-6s   %6s  %6s  %6s',
                     [fOpBase, // was: fOpbase - fBaseAddress,
                      Opcode,
                      Oprnd1,
                      Oprnd2,
                      Oprnd3]);
  end;
  AddLine(Line);
  AddLineSeparator(fOpCode);
end;

procedure TpCodeDecoder.OpsNoOprnd;
begin
  GenOpLine(DebugOpsTable.Ops[fOpCode].Name, '');
end;

procedure TpCodeDecoder.OpsOneOprnd;
var
  Opr1: byte;
begin
  Opr1 := ByteAt[fIpc];
  inc(fIpc);
  GenOpline(fOpcodeName, IntToStr(Opr1));
end;

procedure TpCodeDecoder.OpsNatNfo;
var
  Opr1: byte;
  i: word;
  Line: string;
begin
  Opr1 := ByteAt[fIpc];
  Line := Format('Data: Len = %d, ', [Opr1]);

    for i := 1 to Opr1 do
      Line := Line + ' ' + HexByte(ByteAt[fIpc+I]);
      
  GenOpline(fOpcodeName, Line);
  fIpc := fIpc + 1 + Opr1;  // skip this many bytes
end;


procedure TpCodeDecoder.OpsThreeOprnd;
var
  Opr1, Opr2, Opr3: byte;
begin
  Opr1 := ByteAt[fIpc];
  inc(fIpc);

  Opr2 := ByteAt[fIpc];
  inc(fIpc);

  Opr3 := ByteAt[fIpc];
  inc(fIpc);

  GenOpline(fOpcodeName, IntToStr(Opr1), IntToStr(Opr2), IntToStr(Opr3));
end;



procedure TpCodeDecoder.OpsReljump;
var
  Opr1: word;
  Dest: longint;
begin
{$R-}
  Opr1 := ByteAt[fIpc];
{$R+}
  inc(fIpc);
  Dest := ShortInt(Opr1) + fIpc {- BaseAddress};
//GenOpline(fOpcodeName, IIF(RelDest > 0, '+', '') + IntToStr(RelDest));
  GenOpLine(fOpCodeName, IntToStr(Dest));
end;

procedure TpCodeDecoder.OpsLongJump;
var
  Opr1: TUnion;
  RelDest: INTEGER;
begin
  Opr1.L  := ByteAt[fIpc];
  inc(fIpc);
  Opr1.H  := ByteAt[fIpc];
  inc(fIpc);
  RelDest := Opr1.I + fIpc {- BaseAddress};
  GenOpline(fOpcodeName, IntToStr(RelDest));
end;



procedure TpCodeDecoder.OpsSCXG;
var
  Opr1: byte;
  ProcName: string;
begin
  Opr1 := ByteAt[fIpc];
  fIpc := fIpc + 1;
  if fOpcode = 112 then // SCXG1: INTERNAL CALL
    begin
      with DebugOpsTable do
        begin
          if (Opr1 <= CSPEND) then
            begin
              with CspTable[Opr1] do
                if Name <> '' then
                  ProcName := Name
                else
                  Procname := Format('Kernel %d', [Opr1]);
            end
          else
            ProcName := Format('Illegal CSP: %d', [Opr1]);
        end;
      GenOpLine('SCXG1', ProcName);
    end
  else
    GenOpLine(fOpcodeName, IntToStr(Opr1));
end;

procedure TpCodeDecoder.OpsCXG;
var
  Opr1, Opr2: byte;
  ProcName: string;
begin
  Opr1 := ByteAt[fIpc];
  inc(fIpc);
  Opr2 := ByteAt[fIpc];
  inc(fIpc);
  with DebugOpsTable do
    if Opr1 = 1 then // internal proc
      with CspTable[Opr2] do
        if Name <> '' then
          ProcName := Name
        else
          Procname := Format('Kernel %d', [Opr2])
    else
      ProcName := Format('Segment %d', [Opr1]);
  GenOpline(fOpcodeName, Procname, IntToStr(Opr2));
end;


procedure TpCodeDecoder.OpsTwoOprnd;
var
  Opr1, Opr2: byte;
begin
  Opr1 := ByteAt[fIpc];
  inc(fIpc);
  Opr2 := ByteAt[fIpc];
  inc(fIpc);
  GenOpline(fOpcodeName, IntToStr(Opr1), IntToStr(Opr2));
end;


procedure TpCodeDecoder.OpsUB1UB2B;
var
  UB1, UB2: byte;
  U: TUnion;
  B: integer;
begin
  UB1 := ByteAt[fIpc];
  inc(fIpc);
  UB2 := ByteAt[fIpc];
  inc(fIpc);
{$R-}
  U := GetBig;
  B := U.I;
{$R+}
  GenOpline(fOpcodeName, IntToStr(UB1), IntToStr(UB2), IntToStr(B));
end;

procedure TpCodeDecoder.OpsUB1WUB2;
var
  UB1, UB2: byte;
  W: integer;
begin
  UB1 := ByteAt[fIpc];
  inc(fIpc);

  W := GetBig.I;

  UB2 := ByteAt[fIpc];
  inc(fIpc);
  GenOpline(fOpcodeName, IntToStr(UB1), IntToStr(W), IntToStr(UB2));
end;



procedure TpCodeDecoder.OpsDbBig;
var
  b: byte;
  u: TUnion;
begin
  b := ByteAt[fIpc];
  Inc(fIpc);
  u := GetBig;
  GenOpLine(fOpcodeName, IntToStr(b), IntToStr(u.W));
end;

procedure TpCodeDecoder.OpsAddr;
var
  u: TUnion;
begin
  u := GetBig;
  GenOpline(fOpcodeName, IntTostr(u.W));
end;


procedure TpCodeDecoder.BigOPR;
var
  Opr: TUnion;
begin
  OPR := GetBig;
  GenOpline(fOpcodeName, IntToStr(OPR.I));
end;

function TpCodeDecoder.CPOffset: word;
begin
  if Assigned(fOnGetCPOffset) then
    result := fOnGetCPOffset
  else
    raise EUndefinedFetchFunction.Create('fOnGetCPOffset');
end;


procedure TpCodeDecoder.OpsLCO;
const
  DLEN = 80;
var
  ConstOffset: TUnion;
  Temp: string[255];
  i: integer;
  OffSet: word;
  Len: word;
//OK_CHARS: TSetOfChar;
  Line: string;
  O: longword;
begin
//OK_CHARS := IDENT_CHARS{+PUNCT}+DELIM_SET;

  ConstOffset := GetBig;  // get the offset within the constant pool (in words)
  Offset      := ConstOffset.I * 2;  // byte offset to start of string within the constant pool
{$R-}
  if Assigned(fOnGetSegmentBase) then
    begin
      O       := SegmentBase + CPOffset + Offset;  // addr of the start of the constant
      Len     := GetByteAtAbs(O);
      if Len > DLEN then
        Len := DLEN;
      SetLength(temp, Len);
      for i := 1 to Len do
        Temp[i] := chr(GetByteAtAbs(O + i));
    end
  else
    Temp := '???';  // not implemented for decoding a .CODE file. Need to calculate the CPOffset

{$R+}
//GenOpline(fOpcodeName, IntToStr(ConstOffset.I) + ' "' + CleanUpString(Temp, OK_CHARS) +'"');
  Line := Format('%d "%s"', [ConstOffset.I, Printable(Temp)]);
  GenOpLine(fOpcodeName, Line);
end;


function TpCodeDecoder.Lodsw: TUnion;
begin
  result.L := ByteAt[fIpc];
  inc(fIpc);
  result.H := ByteAt[fIpc];
  inc(fIpc);
end;

procedure TpCodeDecoder.OpsSignedWord;
begin
  GenOpLine(fOpcodeName, IntTostr(LODSW.I));
end;

procedure TpCodeDecoder.DECOPS;
var
  Opcode: TUnion;
begin
  Opcode.L := ByteAt[fIpc];
  inc(fIpc);
  Opcode.H := ByteAt[fIpc];
  inc(fIpc);
  GenOpLine(fOpCodeName, DecopsNames[TDecOps(Opcode.W)]);
end;


procedure TpCodeDecoder.InitDebugOpsTable(IncludeAllCSPOps: boolean; VersionNr: TVersionNr);
var
  i: integer;
begin
  with DebugOpsTable do
    begin
      for i := 0 to HIGHPCODE do with Ops[i] do begin Name  := ''; ProcCall := nil end;

      AddOp('SLDC',   [0..31],    OpsNoOprnd);
      AddOp('SLDL',   [32..47],   OpsNoOprnd, -1);  // Short Load Local Word
      AddOp('SLDO',   [48..63],   OpsNoOprnd, -1);  // Short Load Global Word
      AddOp('DECOPS', [64],       DECOPS);               // DECOPS
      AddOp('SLLA',   [96..103],  OpsNoOprnd, -1);
      AddOp('SSTL',   [104..111], OpsNoOprnd, -1);  // Short Store Local Word
      AddOp('SCXG',   [112..119], OpsSCXG, -1);     // Short Call Global External Procedure
      AddOp('SIND',   [120..127], OpsNoOprnd);
      AddOp('LDCB',   [128],      OpsOneOprnd);     // Load Constant Byte, high byte zero.
      AddOp('LDCI',   [129],      OpsSignedWord);   // Load Constant Word. Push W.
      AddOp('LCO',    [130],      OpsLCO);          // Load Constant Offset
      AddOp('LDC',    [131],      OpsUB1WUB2);      // Load Multiple Word Constant
      AddOp('LLA',    [132],      BIGOPR);          // Load Local Address
      AddOp('LDO',    [133],      OpsAddr);         // Load Global Word
      AddOp('LAO',    [134],      OpsAddr);         // Load Global Address
      AddOp('LDL',    [135],      OpsAddr);         // Load Local Word
      AddOp('LDA',    [136],      OpsDbBig);        // LOAD INTERMEDIATE ADDRESS
      AddOp('LOD',    [137],      OpsDbBig);        // Load intermedicate word <=======
      AddOp('UJP',    [138],      OpsReljump);      // Unconditional jump
      AddOp('JPL',    [139],      OpsLongJump);     // Unconditional long jump
      AddOp('MPI',    [140],      OpsNoOprnd);     // integer multiply
      AddOp('DVI',    [141],      OpsNoOprnd);     // INTEGER DIVIDE
      AddOp('STM',    [142],      OpsOneOprnd);     // Store Multiple
      AddOp('MODI',   [143],      OpsNoOprnd);     // modulo
      AddOp('CPL',    [144],      OpsOneOprnd);     // Call procedure local
      AddOp('CPG',    [145],      OpsOneOprnd);    // call procedure global
      AddOp('CPI',    [146],      OpsTwoOprnd);    // call internediate procedure
      AddOp('CXL',    [147],      OpsTwoOprnd);    // call local external
      AddOp('CXG',    [148],      OpsCXG);    // Call Global External Procedure
      AddOp('CXI',    [149],      OpsThreeOprnd);
      AddOp('CPF',    [151],      OpsNoOprnd);     // Call formal procedure
      AddOp('LSL',    [153],      OpsOneOprnd);    // load static link onto stack
      AddOp('LDE',    [154],      OpsDbBig);       // Load extended word
      AddOp('LAE',    [155],      OpsDbBig);       // Load extended address
      AddOp('RPU',    [150],      OpsAddr);         // Return from Procedure {OPCODE_RPU}
      AddOp('LDCN',   [152],      OpsNoOprnd);      // Load Constant NIL
      AddOp('NOP',    [156],      OpsNoOprnd);      // no operation
      AddOp('LPR',    [157],      OpsNoOprnd);      // Load Processor Register
      AddOp('BPT',    [158],      OpsNoOprnd);
      AddOp('BNOT',   [159],      OpsNoOprnd);      // Boolean NOT
      AddOp('LAND',   [161],      OpsNoOprnd);      // Logical And. AND TOS into TOS-1.
      AddOp('LOR',    [160],      OpsNoOprnd);      // Logical Or. OR TOS into TOS-1.
      AddOp('ADI',    [162],      OpsNoOprnd);      // Add integers
      AddOp('SBI',    [163],      OpsNoOprnd);      // Subtract integers
      AddOp('STL',    [164],      OpsAddr);         // Store Local Word
      AddOp('SRO',    [165],      OpsAddr);         // Store Global Word
      AddOp('STR',    [166],      OpsDbBig);          // store intermediate
      AddOp('LDB',    [167],      OpsNoOprnd);      // Load Byte
      AddOp('NAT',    [168],      OpsNoOprnd);     // native code
      AddOp('NATNFO', [169],      OpsNatNfo);      // native info
      AddOp('CAP',    [171],      OpsOneOprnd);    // Copy Array Parameter
      AddOp('CSP',    [172],      OpsOneOprnd);     // Copy String Parameter
      AddOp('SLOD',   [173, 174], OpsAddr, -1);     // Short Load Intermediate Word
      AddOp('EQUI',   [176],      OpsNoOprnd);      // Equal Integer.
      AddOp('NEQI',   [177],      OpsNoOprnd);      // Not Equal Integer
      AddOp('LEQI',   [178],      OpsNoOprnd);      // Less than or Equal Integer
      AddOp('GEQI',   [179],      OpsNoOprnd);      // Greater than or Equal Integer
      AddOp('LEUSW',  [180],      OpsNoOprnd);
      AddOp('GEUSW',  [181],      OpsNoOprnd);
      AddOp('EQPWR',  [182],      OpsNoOprnd);     // equal set
      AddOp('LEPWR',  [183],      OpsNoOprnd);     // less than or equal set
      AddOp('GEPWR',  [184],      OpsNoOprnd);     // greater than or equal set
      AddOp('SRS',    [188],      OpsNoOprnd);     // build a sub-range set
      AddOp('SWAP',   [189],      OpsNoOprnd);     // Swap TOS with TOS-1
      AddOp('TNC',    [190],      OpsNoOprnd);     // truncate real
      AddOp('DUPR',   [198],      OpsNoOprnd);     // duplicate real
      AddOp('EQBYT',  [185],      OpsUB1UB2B);
      AddOp('LEBYT',  [186],      OpsUB1UB2B);
      AddOp('GEBYT',  [187],      OpsUB1UB2B);
      AddOp('RND',    [191],      OpsNoOprnd);
      AddOp('ADR',    [192],      OpsNoOprnd);
      AddOp('SBR',    [193],      OpsNoOprnd);
      AddOp('MPR',    [194],      OpsNoOprnd);
      AddOp('DVR',    [195],      OpsNoOprnd);
      AddOp('STO',    [196],      OpsNoOprnd);      // Store Indirect
      AddOp('MOV',    [197],      OpsTwoOprnd);     // Move B words
      AddOp('ADJ',    [199],      OpsOneOprnd);    // Adjust set
      AddOp('STB',    [200],      OpsNoOprnd);      // Store Byte
      AddOp('LDP',    [201],      OpsNoOprnd);      // Load packed
      AddOp('STP',    [202],      OpsNoOprnd);      // Store into a Packed Field
      AddOp('CHK',    [203],      OpsNoOprnd);
      AddOp('FLT',    [204],      OpsNoOprnd);     // float top of stack
      AddOp('EQREAL', [205],      OpsNoOprnd);
      AddOp('LEREAL', [206],      OpsNoOprnd);
      AddOp('GEREAL', [207],      OpsNoOprnd);      // Greater than or equal real
      AddOp('LDM',    [208],      OpsOneOprnd);     // Load multiple words
      AddOp('SPR',    [209],      OpsNoOprnd);      // store processor register
      AddOp('EFJ',    [210],      OpsReljump);      // Equal False Jump
      AddOp('NFJ',    [211],      OpsReljump);      // Not Equal False Jump
      AddOp('FJP',    [212],      OpsReljump);      // False Jump
      AddOp('FJPL',   [213],      OpsLongJump);     //
      AddOp('XJP',    [214],      OpsXJP);         // case jump
      AddOp('IXA',    [215],      OpsAddr);         // Index Array
      AddOp('IXP',    [216],      OpsTwoOprnd);    // index packed array
      AddOp('STE',    [217],      OpsDbBig);       // Store extended word
      AddOp('INN',    [218],      OpsNoOprnd);      // Set Membership
      AddOp('UNI',    [219],      OpsNoOprnd);
      AddOp('INT',    [220],      OpsNoOprnd);      // Set Intersection
      AddOp('DIF',    [221],      OpsNoOprnd);
      AddOp('SIGNAL', [222],      OpsNoOprnd);
      AddOp('WAIT',   [223],      OpsNoOprnd);
      AddOp('ABI',    [224],      OpsNoOprnd);      // Absolute Value Integer
      AddOp('NGI',    [225],      OpsNoOprnd);      // Negate Integer
      AddOp('DUP1',   [226],      OpsNoOprnd);      // Duplicate One Word
      AddOp('ABR',    [227],      OpsNoOprnd);
      AddOp('NGR',    [228],      OpsNoOprnd);
      AddOp('LNOT',   [229],      OpsNoOprnd);      // Logical Not
      AddOp('IND',    [230],      OpsAddr);         // Index and Load Word
      AddOp('INC',    [231],      OpsAddr);         // Increment Field Pointer
      AddOp('EQSTR',  [232],      OpsTwoOprnd);     // Equal String
      AddOp('ASTR',   [235],      OpsTwoOprnd);     // Assign string
      AddOp('CSTR',   [236],      OpsNoOprnd);      // Check String Index
      AddOp('INCI',   [237],      OpsNoOprnd);      // Increment Integer.
      AddOp('DECI',   [238],      OpsNoOprnd);      // Decrement Integer
      AddOp('SCIP',   [239, 240], OpsOneOprnd, -1); // Short Call Intermediate Procedure
      AddOp('TJP',    [241],      OpsReljump);      // True Jump
      AddOp('STRL',   [244],      OpsNoOprnd);
      AddOp('LESTR',  [233],      OpsTwoOprnd);
      AddOp('GESTR',  [234],      OpsTwoOprnd);
      AddOp('LDCRL',  [242],      OpsAddr);
      AddOp('LDRL',   [243],      OpsNoOprnd);

      if not IncludeAllCSPOps then
        begin
          // only assign those that have an assigned procedure in the interpreter Decode list

          if Assigned(fInterpreterOpsTable) then
            begin
              CSPEND := fInterpreterOpsTable.CSPEnd;
              
              for i := 0 to CSPEND do
                if Assigned(fInterpreterOpsTable.CSPTABLE[I].ProcCall) then
                  DebugOpsTable.CSPTABLE[i].Name := fInterpreterOpsTable.CSPTABLE[I].Name
                else
                  with DebugOpsTable.CspTable[i] do begin Name  := ''; ProcCall := nil end
            end
          else
            {Assert(false, 'This may not be working correctly')};
        end
      else
        begin
          AddCspOp('EXEC_ERROR', 2);              // These could all be added to the interpreter to speed up
          AddCspOp('LOADSEG',    3);                 // see: P403_1F.VOL:UTILS.TEXT for the source to these pascal routines
          AddCspOp('RLOCSEG',    CSP_RLOCSEG);       // or see: UTILS.TXT
          AddCspOp('PTR_ADD',    5);
          AddCspOp('PTR_SUB',    6);
          AddCspOp('PTR_LESS',   7);
          AddCspOp('PTR_GTR',    8);
          AddCspOp('PTR_GEQ',    9);
          AddCspOp('PRINT',      10);
          AddCspOp('PRINTINT',   11);
          AddCspOp('WRITESTR',   12);
          AddCspOp('CHECKUNIT',  13);

          AddCspOp('MOVESEG',    14);
          AddCspOp('MOVELEFT',   15);
          AddCspOp('MOVERITE',   16);
          AddCspOp('UREAD',      18);
          AddCspOp('UWRITE',     19);
          AddCspOp('TIM',        20);
          AddCspOp('FILLCHAR',   21);
          AddCspOp('SCAN',       22);
          AddCspOp('IOC',        23);
          AddCspOp('GETPOOL',    24);
          AddCspOp('PUTPOOL',    25);
          AddCspOp('FLIPSEG',    26);
          AddCspOp('SQUIET',     27);
          AddCspOp('SENABLE',    28);
          AddCspOp('ATTACH',     29);
          AddCspOp('IOR',        30);
          AddCspOp('UBUSY',      31);
          AddCspOp('POT',        32);
          AddCspOp('UWAIT',      33);
          AddCspOp('UCLEAR',     34);
          AddCspOp('USTATUS',    36);
          AddCspOp('IDSEARCH',   37);
          AddCspOp('TREESRCH',   38);
    // Version IV.2 follows:
          if VersionNr = vn_VersionIV then
            begin
              AddCspOp('READSEG',    39);
              AddCspOp('UREAD',      40);
              AddCspOp('UWRITE',     41);
              AddCspOp('UBUSY',      42);
              AddCspOp('UWAIT',      43);
              AddCspOp('UCLEAR',     44);
              AddCspOp('USTATUS',    45);          // 45
              AddCspOp('READSEG',    46);
              AddCspOp('SETIO',      47);          // 47
              AddCspOp('FAULTHAN',   48);
              AddCspOp('WAITER',     49);
              AddCspOp('POOLSEG',    50);
              AddCspOp('COMMAND',    51);
            end;
        end;
    end;
end;


constructor TpCodeDecoder.Create( aOwner: TComponent;
                                  InterpreterOpsTable: TCustomOpsTable;
                                  IncludeAllCSPOps: boolean;
                                  VersionNr: TVersionNr);
begin
  inherited Create;
  fInterpreterOpsTable := InterpreterOpsTable;
  fVersionNr := VersionNr;
  InitDebugOpsTable(IncludeAllCSPOps, VersionNr);
end;

procedure TpCodeDecoder.Decode( Addr: longword;
                                Len: word;
                                StopAfterReturn: boolean = true;
                                aDecodeFormat: TDecodeFormat = dfUnknown;
                                aBaseAddr: longword = 0);
begin
  fDecodeFormat := aDecodeFormat;
  fBaseAddress  := aBaseAddr;
//fIpc          := Addr;
  fIpc          := 0;
  fErrors       := 0;
  while StopAfterReturn or (fIPC < Len) do
    begin
      fOpCode     := ByteAt[fIpc];
      fOpcodeName := DebugOpsTable.Ops[fOpCode].Name;
      fOpBase     := fIpc;
      fIpc        := fIpc + 1;
      with DebugOpsTable.Ops[fOpCode] do
        if Assigned(ProcCall) then
          try
            ProcCall
          except
            on e:Exception do
              begin
                AddLine(Format('Exception [%s] Opcode=$%x [%d], OpcodeName=%s, IPC=%d',
                                     [e.Message, fOpcode, fOpCode, fOpcodeName, fIpc-1]));
                inc(fErrors);
              end;
          end
        else
          begin
            AddLine(Format('Undefined operator %d in DebugOpsTable', [fOpCode]));
            inc(fErrors);
          end;
      if StopAfterReturn and (fOpCode in DebugOpsTable.Return_Ops) then
        break;
      if fErrors > 10 then
        break;
    end;
end;  { Decode }

procedure TpCodeDecoder.SetIPC(const Value: longword);
begin
  fIPC := Value;
end;

procedure TpCodeDecoder.SetProcNumber(const Value: word);
begin
  fProcNumber := Value;
end;

destructor TpCodeDecoder.Destroy;
begin
  if Assigned(fDebugOpsTable) then
    FreeAndNil(fDebugOpsTable);

  inherited;
end;

procedure TpCodeDecoder.SetDecodeFormat(const Value: TDecodeFormat);
begin
  fDecodeFormat := Value;
end;

procedure TpCodeDecoder.AddLineSeparator(OpCode: word);
begin
  if Assigned(fOnAddLineSeparatorProc) then
    fOnAddLineSeparatorProc(OpCode)
  else
    raise EUndefinedFetchFunction.Create('AddLineSeparator');
end;

procedure TpCodeDecoder.AddLine(const Line: string);
begin
  if Assigned(fOnAddLine) then
    fOnAddLine(Line)
  else
    raise EUndefinedFetchFunction.Create('AddLine');
end;

function TpCodeDecoder.GetByteAt(p: longword): word;
begin
  if Assigned(fOnGetByte3) then
    result := fOnGetByte3(fBaseAddress + p) else
  if Assigned(fGetByteFromMemoryBased) then
    result := fGetByteFromMemoryBased(BaseAddress, p)
  else
    raise EUndefinedFetchFunction.Create('OnGetByteAt');
end;

function TpCodeDecoder.GetWordAt(p: longword): word;
begin
  if Assigned(fOnGetWord3) then
    result := fOnGetWord3(p)
  else
    raise EUndefinedFetchFunction.Create('OnGetWordAt');
end;

function TpCodeDecoder.GetBaseAddress: word;
begin
  if (fBaseAddress = 0) and Assigned(fGetBaseAddressFunc) then
    fBaseAddress := fGetBaseAddressFunc;
  result := fBaseAddress;
end;

function TpCodeDecoder.SegmentBase: longword;
begin
  if Assigned(fOnGetSegmentBase) then
    result := fOnGetSegmentBase else
  if fBaseAddress <> 0 then
    result := fBaseAddress
  else
    raise EUndefinedFetchFunction.Create('fOnGetSegmentBase');
end;

function TpCodeDecoder.GetByteAtAbs(p: longword): word;
begin
  result := fOnGetByte3(p);
end;

procedure TpCodeDecoder.SetBaseAddress(const Value: word);
begin
  fBaseAddress := value;
end;

initialization
finalization
end.
