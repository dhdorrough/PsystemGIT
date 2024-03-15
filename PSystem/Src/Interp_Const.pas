unit Interp_Const;

interface

const
  CSYSTEM_PASCAL = 'SYSTEM.PASCAL';

  kUNTYPEDFILE= 0;
  kXDSKFILE  =  1;
  kCODEFILE  =  2;
  kTEXTFILE  =  3;
  kINFOFILE  =  4;
  kDATAFILE  =  5;
  kGRAFFILE  =  6;
  kFOTOFILE  =  7;
  kSECUREDIR =  8;
  kSUBSVOL   =  9;

  // Version I.4->II stuff
  ENTERIC_OB = 2;      {offset from JTAB in bytes}
  EXITIC_OB  = 4;      {offset from JTAB in bytes}
  PARAMSIZE_OB = 6;    {offset from JTAB in bytes}
  DATASIZE_OB = 8;     {offset from JTAB in bytes}
  LASTCODE_OB = 10;    {offset from JTAB in bytes}

  // These are now all WORD offsets
  MS_KPw   =  -1;
  MS_VARw  =  5;
  MS_SPw   =  5;        {caller's top of stack}
  MS_IPCw  =  4;        {caller's ipc (return address)}
  MS_SEGw  =  3;        {caller's segment (proc table) pointer}
  MS_JTABw =  2;        {caller's JTAB  pointer}
  MS_DYNw  =  1;        {dynamic link pointer to caller's MSCW}
  MS_STATw =  0;        {Static  link pointer to parent's MSCW}
  MS_FRAME_SIZEw = 6;

  MS_BASEw = -1;        {base link (only if CBP) pointer}
                        {to base MSCW of caller}
  CHARS_PER_IDENTIFIER = 8;

type
  integer = smallint;
  
  TShortPtr = word;

  TAlpha    = packed array[0..CHARS_PER_IDENTIFIER-1] of char;  // compiler declares this as "PACKED ARRAY [1..8] OF CHAR"
  TString8  = string[8];

  TAlpha_Ptr = ^TAlpha;

  TIORsltWD = ({0}INOERROR,
               {1}IBADBLOCK,
               {2}IBADUNIT,
               {3}IBADMODE,
               {4}ITIMEOUT,
               {5}ILOSTUNIT,
               {6}ILOSTFILE,
               {7}IBADTITLE,
               {8}INOROOM,
               {9}INOUNIT,
               {10}INOFILE,
               {11}IDUPFILE,
               {12}INOTCLOSED,
               {13}INOTOPEN,
               {14}IBADFORMAT,
               {15}ISTRGOVFL);

        TSeg_Types    =  (no_seg, prog_seg, unit_seg, proc_seg, seprt_seg);

        TVersions      =  (unknown, ii    {II},
                                    ii_1  {II.1},
                                    iii   {III},
                                    iv,
                                    v, vi, vii {non-existant});

        TVersionNr = (vn_Unknown, vn_VersionI_4, vn_VersionI_5, vn_VersionII, vn_VersionIV, vn_VersionIV_12);

        TVersionNumbers = set of TVersionNr;

 (* The TByte_Sex type is used to remember the byte ordering in 16-bit
  * words.  The name is historical, it is the term used in the UCSD
  * system sources.  (It also pre-dates "political correctness".)
  *
  * For the origins of the little-endian and big-endian names, see
  * http://en.wikipedia.org/wiki/Gulliver%27s_Travels
  * http://en.wikipedia.org/wiki/Endianness

  * The litte-endian byte sex indicates that the least significant 8 bits
  * are found in the first (lower address) byte, and the most significant
  * 8 bits are found in the second (higher address) byTVersionte.  For historical
  * reasons this is the default (the first 3 host architectures were
  * little-endian).
  */

  * The big-endian byte sex indicates that the most significant 8 bits are
  * found in the first (lower address) byte, and the least significant 8
  * bits are found in the second (higher address) byte.
*)

TByte_Sex  = (bs_UNKNOWN, bs_LITTLE_ENDIAN, bs_BIG_ENDIAN);

const
  BADVERSIONS: TVersionNumbers = [vn_VersionIV_12];

var
  IOResultStrings: array[TIORsltWD] of string =
                   (
                    'NO ERROR',
                    'BAD BLOCK',
                    'BAD UNIT',
                    'BAD MODE',
                    'TIMEOUT',
                    'LOST UNIT',
                    'LOST FILE',
                    'BAD TITLE',
                    'NO ROOM',
                    'NO UNIT',
                    'NO FILE',
                    'DUP FILE',
                    'NOT CLOSED',
                    'NOT OPEN',
                    'BAD FORMAT',
                    'STRG OVFL'
                    );

function IOResultString(IOResult: TIORsltWD): string;
function VersionNumbersString(VersionNumbers: TVersionNumbers): string;

implementation

uses
  SysUtils, Interp_Decl;

function IOResultString(IOResult: TIORsltWD): string;
begin
  if IOResult in [INOERROR..ISTRGOVFL] then
    result := IOResultStrings[IOResult]
  else
    result := Format('I/O result = %d', [ord(IOResult)]);
end;

function VersionNumbersString(VersionNumbers: TVersionNumbers): string;
var
  vn: TVersionNr;
  NrFound: integer;
  temp: string;
begin
  result  := '';
  NrFound := 0;
  for vn := succ(Low(TVersionNr)) to High(TVersionNr) do
    begin
      if vn in VersionNumbers then
        begin
          temp := VersionNrStrings[vn].Abbrev;
          if NrFound > 0 then
            result := result + ', ' + temp
          else
            result := temp;
          Inc(NrFound);
        end;
    end;
end;

end.
