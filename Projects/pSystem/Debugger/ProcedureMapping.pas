{$Define NewWay}
  { Based on:
  {        UCSD     P-CODE     DISASSEMBLER                }
  {        Release level:      I.5    Sept, 1978           }
  {        Written by     William  P.  Franks              }

unit ProcedureMapping;

interface

uses
  pSysVolumes, UCSDInterpreter, uGetString, MyUtils, FilerSettingsUnit, SysUtils,
  Misc, Interp_Decl, pSysDatesAndTimes, MyDelimitedParser;

const
  DISPLAY    = TRUE;

  MAXSEG     = 15;

  W_NR       = 2;
  W_SEGMENTNAME = 10;
  W_ADDR     = 8;
  W_LENG     = 8;
  W_NRPROCS  = 8;
  W_KIND     = 8;
  W_INFO     = 8;
  W_FLAG     = 6;

  MAXPROCNUM = 150;

type
  TFieldNumbers = (
    FLD_pSys_Volume_Name,
    FLD_Volume_Date,
    FLD_pSys_FileName,
    FLD_File_Date,
    FLD_SEG_NR,
    FLD_Flag,
    FLD_Segment_Name,
    FLD_ItIsFlipped,
    FLD_Version,
    FLD_Origin,
    FLD_CodeFirstBlock,
    FLD_CodeLeng,       // Word / byte (?) count based on DICT.DiskInfo[SEGNUM].CODEleng
    FLD_NrProcs,
    FLD_SegKind,
    FLD_Info,
    FLD_DOS_Volume_Name,
    FLD_Error_Number
    );

var
  Fields            : TFieldArray;
  FieldNames        : TFieldArray;
  HeaderLine        : string;
  Delimited_Info    : TDelimited_Info;


implementation

end.
