unit Interp_Decl;

interface

uses
  pSysDrivers, pSysVolumes, Interp_Const, Classes;

const
  CSYSTEM_PASCAL     = 'SYSTEM.PASCAL';

  IDLEN              = 8; { max identifier characters }
  BLOCKSIZE          = 512;
  pNIL               = 0000;      {Nil is NOW 0- add to TCustomPsystemInterpreter as a property, if not}

  LOW64K             = 65534;
  LOW128K            = LOW64K * 2;     // 65534 WORDS!

  ONEMB              = 642048;
  HIMEM              = ONEMB;  // max memory- actual depends on specific interpreter
  CHARS_PER_SEG_NAME = 8;
  DIRBLK             = 2;	(*DISK ADDR OF DIRECTORY*)
  SET_SIZE           = 256;

  (* DECOPS STUFF *)

  MAXUNIONS          = 3;
  MAXWORDS           = 12;  // MAXUNIONS * (SizeOF(INT64) div 2)

//------ RSP CONSTANTS ----------------

  INBIT   =    1;               // SET FOR INPUT
  OUTBIT  =    2;               // SET FOR OUTPUT
  CLRBIT  =    4;               // SET TO CLEAR
  STATBIT =    8;               // SET FOR STATUS
  NOECHO  =    16;              // SET FOR SYSTERM
  ALLBIT  =    INBIT+OUTBIT+CLRBIT+STATBIT; // ALL ARE POSSIBLE

type

  TBrk = ( dbUnknown,
           dbBREAK,
           dbBreakOnCall,
           dbMemChanged,
           dbDbgCnt,
           dbOpCode,
           dbSystem_Halt,
           dbException);

  TUnitInfo = record
                Control: word;
                Driver: TDriver;
//              TheOwner: TObject;
              end;

  TRealUnion = record
    case integer of
      0: (UCSDReal4: Double);
      1: (UCSDReal2: Single);
      2: (Wrd: array[0..3] of word) // 0=low, 3=high
    end;

  TSet = record
           Size: word;
           Data: array[0..SET_SIZE-1] of word;
         end;

  TRealUnionPtr = ^TRealUnion;

  TUnitsRange = set of 0..MAX_FILER_UNITNR;

  TMemAsBytes  = array[0..HIMEM] of byte;      // max value - may not all be accessed depending on the interpreter
  TMemAsWords  = array[0..HIMEM div 2] of word;

  TMemAsBytesPtr = ^TMemAsBytes;
  TMemAsWordsPtr = ^TMemAsWords;

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
             dop_longToInt    = 20);

  TLongUnion = record
                 case integer of
                   0: (lw: longword);
                   1: (sw: array[0..1] of word)
                 end;

  TDecopsUnion = record
             case integer of
               1: (int: array[0..MAXUNIONS-1] of Int64);
               2: (arr: array[0..MAXWORDS-1] of word);
             end;

  TSetupProc = procedure {Name} of object;

  TVersionInfo = record
                   Name: string;
                   Abbrev: string;
                   NumStr: string;
                   xNumVal: SmallInt;
                 end;
                 
  TTree_NodePtr = ^TTree_Node;

  TShortPtr     = word;   // dhd  

  TTree_Node = record
                 Name       : Talpha;
                 right_link : TShortPtr;
                 left_link  : TShortPtr;
                 {undefined additional fields}
               end {tree_node};

  TIDList = class(TStringList)
  protected
    procedure InitIDs; virtual; abstract;
  end;

  TMSCWFieldNr = (csDynamic, csStatic, csJTAB, csSEG, csENV, csProc, csIPC, csLocal);

  TIndexingProcedure = function {name} (Addr: longword; Offset: integer): longword of object;

  TBlock = packed Array[0..BLOCKSIZE-1] of char;


var
  // These are used in SegMap
  VersionNames: array[TVersions] of string =
                (
                 {unknown} 'unknown',
                 {ii}      '2',
                 {ii_1}    '2.1',
                 {iii}     '3',
                 {iv}      '4',
                 {v}       'unknown',
                 {vi}      'unknown',
                 {vii}     'unknown'
                 );

  VersionNrStrings: array[TVersionNr] of TVersionInfo = (
    ({vn_Unknown}     Name: 'Unknown';        Abbrev: 'Unk';    NumStr: 'xxx'),
    ({vn_VersionI_4}  Name: 'Version-I-4';    Abbrev: 'I.4';    NumStr: '1.4';   xNumVal: 1400),
    ({vn_VersionI_5}  Name: 'Version-I-5';    Abbrev: 'I.5';    NumStr: '1.5';   xNumVal: 1500),
    ({vn_VersionII}   Name: 'Version-II';     Abbrev: 'II';     NumStr: '2.0';   xNumVal: 2000),
    ({vn_VersionIV}   Name: 'Version-IV';     Abbrev: 'IV.2.2'; NumStr: '4.2.2'; xNumVal: 4220),
    ({vn_VersionIV_12}Name: 'Version-IV-12';  Abbrev: 'IV.12';  NumStr: '4.12';  xNumVal: 4120)  // does not work
  );

  SegTypes: array[Tseg_types] of string = ('NO_SEG', 'PROG_SEG', 'UNIT_SEG', 'PROC_SEG', 'SEPRT_SEG');

function VersionNrToAbbrev(VersionNr: TVersionNr): string;

implementation

function VersionNrToAbbrev(VersionNr: TVersionNr): string;
begin
  result := VersionNrStrings[VersionNr].Abbrev;
end;

end.
