unit PsysUnit;

interface

uses
  StdCtrls, Classes, SysUtils, PSysWindow, UCSDGlob, MyUtils;

CONST
  MMAXINT = 32767;

//VOL_EXT = 'VOL';
//CSV_EXT = 'CSV';

type
  integer = SmallInt;   // force all integers to be 16 bits

  FILEKIND = INTEGER;

//TFileNamesList = class(TStringList)
//end;


procedure ExtractUCSDNameParts(const s: string; var VolName: string; var FileName: string);
procedure MoveLeft(Src, Dst: pchar; Num: integer);
function  UCSDName(const Name: string): string;

var
  gMemo: TMemo;

implementation

Uses
  BitOps, StrUtils, Forms, pSysDatesAndTimes, pSys_Decl, Misc,
  pSysExceptions, pSysVolumes, pSys_Const;

{$Include BiosConst.inc}

// NAME:     UCSDName
// Function: Force a identifier to be a legal UCSD identifier
//           i.e, 8 chars max, uppercase, no '_', no trailing blanks
function UCSDName(const Name: string): string;
begin
  result := UpperCase(Trim(Copy(RemoveBadChars(Name, ['_']), 1, CHARS_PER_IDENTIFIER)));
end;

// NAME:     ExtractUCSDName
// Function: Returns the parts of a UCSD path:filename
// Parameters: s = string to process
procedure ExtractUCSDNameParts(const s: string; var VolName: string; var FileName: string);
var
  ColonP, bracketp: integer;
begin
  VolName := '';
  ColonP := Pos(':', s);
  if ColonP > 0 then
    begin
      VolName  := UpperCase(Copy(s, 1, ColonP-1));  // Volname must precede FileName (because setting FileName overwrites s
      FileName := Copy(s, ColonP+1, MAXINT);
    end else
  if (length(s) > 1) and (s[1] = '*') then
    begin
      VolName  := '*';
      FileName := Copy(s, 2, MAXINT);
    end
  else
    FileName := s;

  ColonP := Pos('[', FileName);              // look for '[*]' and remove it
  if ColonP > 0 then
    begin
      bracketp := PosEx(']', FileName, ColonP+1);
      if bracketp > 0 then
        Delete(FileName, ColonP, bracketp-ColonP+1)
    end;
  FileName := UpperCase(FileName);
end;


procedure MoveLeft(Src, Dst: pchar; Num: integer);
begin
  Move(Src, Dst, Num);
END;

{$R-}
function ScanEQ(Length: integer; chs: TSetOfChar; Buf: TPageBuf; StartIndex: integer): integer;
var
  i: integer;
begin
  for i := 0 to Length-1 do
    begin
      if StartIndex + i >= BUFSIZ then
        begin
          result := -1;
          Exit;
        end;
      if Buf[StartIndex+i] in chs then
        begin
          result := i;
          exit;
        end;
    end;
  result := -1;
end;

function ScanNE(Length: integer; chs: TSetOfChar; Buf: TPageBuf; StartIndex: integer): integer;
var
  i: integer;
begin
  for i := 0 to Length-1 do
    begin
      if StartIndex + i >= BUFSIZ then
        begin
          result := -1;
          Exit;
        end;
      if not (Buf[StartIndex+i] in chs) then
        begin
          result := i;
          exit;
        end;
    end;
  result := -1;
end;
{$R+}


initialization

end.
