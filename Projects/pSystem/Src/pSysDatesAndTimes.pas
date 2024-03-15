unit pSysDatesAndTimes;

interface

uses
  UCSDGlob;

const
  PIVOT_YEAR     = 70;
  FLAGYEAR       = 100; // Year = 100: temporary file. Year > 100 may get deleted from directory.

  BAD_DATE = -1;
  UNKNOWN_DATE = 'Unknown';

var
  Months: ARRAY [0..15] OF STRING[3];

function  DAccessToTDateTime(PSysDate: DateRec; DFKIND: word): TDateTime;
procedure DateRecToYYMMDD(aDateRec: DateRec; var YY, MM, DD: word);
function  DateTimeToDateRec(DateTime: TDateTime): DATEREC;
function  DateToPSysStr(DateTime: TDateTime): string;
function  DateTimeToTIMEREC(DateTime: TDateTime): word;
function  DayOf(Date: DateRec): word;
function  FixYear(aDateRec: DateRec): DateRec;
procedure GetTime(var h1,m1,s1,s100: word);
function  HourOf(DFKIND: word): word;
function  MinutesOf(DFKIND: word): word;
function  MonthOf(Date: DateRec): word;
function  MyDisplayDate(Year, Month, Day: word): string;
function  OKDateTime(DateTime: TDateTime; LowDate, HighDate: TDateTime): boolean;
function  OKFileDateTime(FileDate: system.integer; LowDate, HighDate: TDateTime): boolean;
procedure SetDirectoryDateTime(var DLASTBOOT, DLOADTIME: word);
function  YearOf(Date: DateRec): word;
function  YearOfMM(Date: DateRec): word;
function  Y2K(Year: word): word;

implementation

uses
  SysUtils, BitOps, pSysExceptions, MyUtils;

procedure SetDirectoryDateTime(var DLASTBOOT, DLOADTIME: word);
begin
  DLASTBOOT := DateTimeToDateRec(Now);
  DLOADTIME := DateTimeToTimeRec(Now);
end;

function  DateTimeToDateRec(DateTime: TDateTime): DATEREC;
var
  YYYY, MM, DD: word;
begin
  DecodeDate(DateTime, YYYY, MM, DD);
  YYYY := YYYY mod 100;  // p-Sys deletes directory entries with Year > 100
  result := (((YYYY shl 5) + DD) shl 4) + MM;
end;

function DateTimeToTIMEREC(DateTime: TDateTime): word;
var
  HH, MM, SS, Msec: word;
  BitNr: byte;
begin
  DecodeTime(DateTime, HH, MM, SS, MSEC);

  BitNr    := 0;
  SetBits(result, BitNr, 5, HH);
  SetBits(result, BitNr, 6, MM);
end;

(*
procedure Time(var HiWord, LoWord: SmallInt);
VAR
  TIMESTAMP: TTIMESTAMP;
  Convert: record
             case integer of
               1: (Int32: Integer);
               2: (Int16: record
                            LowWord: Smallint;
                            HighWord: SmallInt;
                          end);
             end;
begin
  TIMESTAMP := DateTimeToTimeStamp(SYSUTILS.TIME); { time in ms converted to 60ths of a second }
  Convert.Int32 := Round(TimeStamp.Time / 60);
  HiWord := Convert.Int16.HighWord;       // p-system expected these 16-bit values
  LoWord := Convert.Int16.LowWord;
END;
*)

//  DateRec (16 bits): YYYYYYYDDDDDMMMM

procedure DateRecToYYMMDD(aDateRec: DateRec; var YY, MM, DD: word);
var
  BitNr: byte;
begin
  BitNr := 0;
  MM := Bits(aDateRec, BitNr, 4);
  DD := Bits(aDateRec, BitNr, 5);
  yy := Bits(aDateRec, BitNr, 7);
end;

function MonthOf(Date: DateRec): word;
begin
  result := Date and $f;
end;

function DayOf(Date: DateRec): word;
begin
  result := (Date shr 4) and $1F;
end;

function YearOfMM(Date: DateRec): word;
begin
  result := Date shr 9;
end;

function FixYear(aDateRec: DateRec): DateRec;
var
  Y: word;
begin
  Y := aDateRec shr 9; // the year, as stored
  if Y < 100 then
    result := aDateRec
  else
    result := ((Y mod 100) shl 9) and (aDateRec and $1FF);
end;



function  Y2K(Year: word): word;
begin
(* WARNING: p-System treats a date > 100 as a bad date and deletes the directory entry.
            Therefore ALL dates are stored as 1900.. 1999.
            This is a Y2K problem which cannot be resolved without having the sources to SYSTEM.PASCAL. *)
  if year <= PIVOT_YEAR then
    result := year + 2000
  else
    result := year + 1900;
(*
  if Year > 100 then
    result := year - 100 + 1900
  else
    result := year + 1900
*)
end;

function YearOf(Date: DateRec): word;
begin
  result := Y2K(Date shr 9);
end;

procedure GetTime(var h1,m1,s1,s100: word);
begin
  DecodeTime(Now, h1, m1, s1, s100);
end;

{$I+}
function HourOf(DFKIND: word): word;
var
  DHour: word;
  BitNr: byte;
begin
  result   := 0;  // lowest 4 bits are the file "kind"
  BitNr    := 4;
  DHour    := Bits(DFKIND, BitNr, 5);
  if (DHour > 0) and (DHour < 24) then  // possibly valid time
    result    := DHOUR - 1;
end;

function MinutesOf(DFKIND: word): word;
var
  DHour: WORD;
//DMinutes: word;
  BitNr: byte;
begin
  result   := 0;
  BitNr    := 4;  // lowest 4 bits are the file "kind"
  DHour    := Bits(DFKIND, BitNr, 5);  // get bits 4-8
//DMinutes := 0;
  if (DHour > 0) and (DHour < 24) then  // possibly valid time
    result := Bits(DFKIND, BitNr, 6);
end;

function OKFileDateTime(FileDate: system.integer; LowDate, HighDate: TDateTime): boolean;
var
  DateTime: TDateTime;
  B1, B2: boolean;
begin
  DateTime := FileDateToDateTime(FileDate);

  if (LowDate <> BAD_DATE) then
    b1 := (LowDate <= DateTime)
  else
    b1 := true;

  if (HighDate <> BAD_DATE) then
    b2 := (DateTime <= HighDate)
  else
    b2 := true;

  result := b1 and b2;
end;

function  OKDateTime(DateTime: TDateTime; LowDate, HighDate: TDateTime): boolean;
var
//FileDateTime: TDateTime;
  B1, B2: boolean;
begin
  if (LowDate <> BAD_DATE) then
    b1 := (LowDate <= DateTime)
  else
    b1 := true;

  if (HighDate <> BAD_DATE) then
    b2 := (DateTime <= HighDate)
  else
    b2 := true;

  result := b1 and b2;
end;

function DAccessToTDateTime(PSysDate: DateRec; DFKIND: word): TDateTime;
var
  Month, Day, Year, DMinutes, DHour: word;
begin
  result   := BAD_DATE;

  Month    := MonthOf(PSysDate);

  if (Month >= 1) and (Month <= 12) then
    begin
      Day          := DayOf  (PSysDate);
      Year         := YearOf (PSysDate);
//    Year         := FixYear(PSysDate);
      DMinutes     := MinutesOf(DFKIND);
      DHour        := HourOf(DFKIND);
      if (Day >= 1) and (Day <= 31) then
        try
          result := EncodeDate(Year, Month, Day)
                               + EncodeTime(DHour, DMinutes, 0, 0);
        except
          on e:EConvertError do
            raise EInvalidDate.CreateFmt('%s: %d/%d/%d', [e.Message, Month, Day, Year]);
        end;
    end;
end;

function MyDisplayDate(Year, Month, Day: word): string;
begin
  result := Rzero(Day, 2) + '-' + Months[Month] + '-' + RZero(Year, 2);
end;

function  DateToPSysStr(DateTime: TDateTime): string;
var
  yyyy, MM, DD: word;
begin
  DecodeDate(DateTime, YYYY, MM, DD);
  YYYY   := YYYY mod 100;  // p-Sys demands dates in the range 0..99
  result := MyDisplayDate(YYYY, MM, DD);
end;

initialization
  Months[ 0] := '???';
  Months[ 1] := 'Jan';
  Months[ 2] := 'Feb';
  Months[ 3] := 'Mar';
  Months[ 4] := 'Apr';
  Months[ 5] := 'May';
  Months[ 6] := 'Jun';
  Months[ 7] := 'Jul';
  Months[ 8] := 'Aug';
  Months[ 9] := 'Sep';
  Months[10] := 'Oct';
  Months[11] := 'Nov';
  Months[12] := 'Dec';
  Months[13] := '???';
  Months[14] := '???';
  Months[15] := '???';
end.
