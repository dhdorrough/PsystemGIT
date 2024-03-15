unit Misc;

interface

uses
  UCSDGlob, Graphics, MyUtils, Interp_Const;

const
  CRLF          = #13#10;
(*
  EXTENSION_TXT = 'TXT';
  CSV_EXT       = 'CSV';
*)

type

  Str2 = packed array[0..1] of char;
  Str4 = packed array[0..3] of char;

  TUnion = packed record
             case integer of
               0: (W: word);
               1: (L: Byte; H: Byte);
               2: (I: integer);
               3: (s: str2)
           end;

  TLIUnion = packed record
    case integer of
      0: (LI: LongWord);
      1: (FA: FullAddress);
    end;

  STRING7 = STRING[7];

function  AlphaToStr(const Alfa: TAlpha): string;
function  DiskAddr_to_Word( addr: TdiskAddress ): word;
function  BothWays(aWord: LongWord): string;
function  CBW(b: byte): integer;
function  DOSVersion: integer;
Function  FlipSex(val:word):integer;
function  HexByte(value:byte): string;
function  Hexword(value: LongWord): string;
function  ReadInt(const s: string): longword;
function  Printable(const s: string): string;
function  ProcNumStr(ProcNum: Integer): string;
function  ThreeWays(aWord: LongWord): string;
function  LongintToFulladdress(li: longint): FullAddress;
function  FulladdressToLongWord(fa: Fulladdress): longword;
procedure upStr(Var s: string);
Function  WordToHex(w:word):String;

implementation

uses
  SysUtils;

const
  HEXDIGIT: PACKED ARRAY[0..15] OF CHAR = '0123456789ABCDEF';


function AlphaToStr(const Alfa: TAlpha): string;
var
  i: integer;
begin
  SetLength(result, CHARS_PER_IDENTIFIER);
  for i := 0 to CHARS_PER_IDENTIFIER-1 do
    Result[i+1] := Alfa[i];
  result := Trim(PrintableOnly2(Alfa));
end;

{$R-}
// FUNCTION: CBW - convert byte to an integer
function CBW(b: byte): integer;   // was b: shortint
begin
  if (b and $80) <> 0 then
    result := $FF00 + b
  else
    result := b;
end;
{$R+}

Procedure upStr(Var s:string);
var i : integer;
begin
  for i:= 1 to length(s) do
    if s[i] in ['a'..'z'] then
      s[i] := chr(ord(s[i])-32);
end;

function  DOSVersion: integer;
begin
  result := 7;
end;

Function FlipSex(val: word): integer;
Var temp:TUnion;
    b: byte;
Begin
  temp.w   := val;
  b        := temp.L;
  temp.L   := temp.H;
  temp.H   := b;
  result   := temp.I;
end;



function HexBYTE(value:byte): string;
{Returns a string corresponding to a byte}
Begin
  result := 'xx';
  result[1] := HEXDIGIT[value div 16];
  result[2] := HEXDIGIT[value mod 16];
End;

function Hexword(value: LongWord): string;
{Returns a string corresponding to a word}
Begin
  if Value > $FFFF then
    result := Format('%8.8x', [Value])
  else
    result := Format('%4.4x', [Value]);
End;

function BothWays(aWord: LongWord): string;
begin
  result := Format('$%4s [%5d]', [HexWord(aWord), aWord]);
end;

function ThreeWays(aWord: LongWord): string;
var
  Union: TUnion;
begin
  Union.W := aWord;
  result := Format('%s ($%s $%s)',
                   [BothWays(aWord), HexByte(Union.l), HexByte(Union.h)]);
end;

function  LongintToFulladdress(li: longint): FullAddress;
var
  temp1, temp2: TLIUnion;
begin
  temp1.LI := LI;

  // reverse the words
  temp2.FA[0] := temp1.FA[1];
  temp2.FA[1] := temp1.FA[0];

  // flip the bytes in each word
//FlipBytes(Temp2.FA[0]);
//FlipBytes(Temp2.FA[1]);

  result := temp2.FA;
end;

function  FulladdressToLongWord(fa: Fulladdress): longword;
var
  Temp1, Temp2: TLIUnion;
begin
  temp1.FA := fa;

  // reverse the words
  temp2.fa[0] := temp1.fa[1];
  temp2.fa[1] := temp1.fa[0];

  // flip the bytes in each word
//FlipBytes(Temp2.fa[0]);
//FlipBytes(Temp2.fa[1]);

  result := temp2.li;
end;

function DiskAddr_to_Word( addr: TDiskAddress ): word;
var cvt: packed record case boolean of
          true :(i:word);
          false:(hibyte,lobyte:byte);
         end {cvt};
begin
  cvt.hibyte := addr.v1[1];
  cvt.lobyte := addr.v1[2];
  result := cvt.i;
end {Int_to_Addr};

function  ReadInt(const s: string): longword;
begin
  result := 0;
  if Length(s) > 0 then
    if s[1] = '$' then
      result := HexStrToWord(Copy(s, 2, 10))
    else
      result := StrToInt(s);
end;

  function Printable(const s: string): string;
  var
    i: integer;
  begin
    result := s;
    for i := 1 to Length(s) do
      if s[i] < ' ' then
        result[i] := '.'
      else
        result[i] := s[i];
  end;

Function WordToHex(w:word):String;
Begin
  result := HexWord(w);
end;

function ProcNumStr(ProcNum: Integer): string;
begin
  if ProcNum >= 0 then
    result := IntToStr(ProcNum)
  else
    result := Format('(%d)', [Abs(ProcNum)]);
end;

end.
