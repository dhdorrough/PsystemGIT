unit debug2;
{ 1 read source code into memory
  2 build table of line #
  3 open and maintain a debug window
  4 provide an interfaced procedure to display line in screen
}
{debug2 --scans text file as file of char and builds array of integers
 that point to the lines}
{
 SLOW but it works!!
 Assumes you have 43/50 line display and shows source code in bottom
 18 lines
}
interface

Uses
  Forms,
  Classes,
  Codespace,
  UCSDGlob,
  SysUtils,
  PSysWindow,
  InterpII;


Var
  SourceLoaded : Boolean;   {true if debugger loaded source file}
  {DebugSP:word;}
  DebugIORSLT : Word;


//Procedure LoadSourceFile(sourcename:string);

//Procedure ShowSource(LineNum : word);
{This procedure is called when BPT encountered by p-machine}

//procedure browsemem(start :word);

type

  string2  = string[2];
  filelines  = array[1..6000] of longint;  {max 6000 lines of source}


  string3    = packed array[0..3] of char;
  string4    = string[4];

traceRec = Record    {element for tracestack}
            l:integer;
            f8:boolean;
            p : word;   {procedure num}
            s : word;   {segment num}
            lex: word;  {lex level}
            i : word;   {instruction addr}
           end;

TDebugForm = class(TfrmPSysWindow)
private
    fl        : TStringList; //^filelines;

    line      : array[1..25] of string80;
    f         : textfile;   // file of byte;
    firstline : integer;    {first line on screen}
    LastLine  : integer;    {last line on screen}
    endline   : word;    {last line in source file}
    Currentline:integer;
    screenoffset : integer; {firstline-1}
    screenline:integer;     {y coord on screen for currentline}

    tracetill : word;       {F8 causes this number to be next line to wake up at}
    F8KEY     : boolean;    {true if F8 trace}
    TracePRoc : Word;
    TraceSeg  : Word;
    TraceLEx  : Word;
    TraceI    : Word;

    TraceArray : array[1..40] of tracerec;
    TStk      : Integer;    {SP for trace stack array}

    LineTrace : Boolean;
    lt : text;
    function Get_Key: Integer;
    procedure Hex(N: Integer);
    function HexByte(N: Integer): String2;
    function Hexword(x: word): string4;
    procedure browsemem(start: word);
    procedure PushF8State;
    procedure HiVideo(x: integer);
    procedure init;
    procedure NormalVideo(x: integer);
    procedure PopF8State;
    procedure RedrawScreen(x: integer);
    procedure SELECT;
    procedure suffix(var s: string80; suff: string80; add: boolean);
  public
    constructor Create(aInterpreter: TPsystemInterpreter2);
    procedure LoadSourceFile(sourcename: string80);
    procedure ShowSource(LineNum: word);
end;

implementation

uses
  MyUtils;

const
  debugline = 5{ 25 if no windows used};       {first screen line used by debug}
  totaldebug = 18 {43-debugline if no windows used};    {total lines used by debug}

function TDebugForm.Get_Key : Integer;
  Var CH : Char;
      Int : Integer;
  begin
    CH := ReadKey;
    If CH = #0 then
      begin
        CH := ReadKey;
        int := Ord(CH);
        inc(int,256);
      end else Int := Ord(CH);
    Get_Key := Int;
    if int=3 then halt;
  end;



Procedure TDebugForm.Hex(N:Integer);
Var a,b : Integer;
    Chsppc : Packed array [0..15] of char;

Begin
  {faster code with ppc built-ins !}
  {$I-,R-}
  Chsppc := '0123456789ABCDEF';
  a:= n shr 4;
  b:= n and $0F;
  Write(Chsppc[a]);
  Write(Chsppc[b]);
  Write(' ');
End;


Function TDebugForm.HexByte(N:Integer): String2;
Var a,b : Integer;
    Chsppc : Packed array [0..15] of char;
    s2 :string2;


Begin
  {faster code with ppc built-ins !}
  {$I-,R-}
  Chsppc := '0123456789ABCDEF';
  a:= n shr 4;
  b:= n and $0F;
  s2 := '  ';
  s2[1] := Chsppc[a];
  s2[2] := Chsppc[b];
  HexByte := s2;
End;



Function TDebugForm.Hexword(x:word): string4;
Var Low,high : byte;
    hexdigit : array [0..15] of char;
    hex      : string4;
    value    : word absolute x;
Begin
{
  IF VALUE >=0 THEN
    BEGIN
}
  hexdigit:='0123456789ABCDEF';
  hex := '0000';

  low := value mod 256;
  high := value div 256;
  hex[1] := hexdigit[high div 16];
  hex[2] := hexdigit[high mod 16];
  hex[3] := hexdigit[low  div 16];
  hex[4] := hexdigit[low  mod 16];
  result := hex;
end;

procedure TDebugForm.browsemem(start :word);
var x:integer;
    StartVal : Word;

  Procedure DisplayBuffer;
  Var i,j,n,m,offset,l : word{Integer};
  Begin
    gotoxy(1,6);
    For i := 0 to 15 do
      Begin
        l := i * 16;
        offset := l;
        Write([HexWord(l+StartVal),' ']);
        {HEX DUMP}
        for j := 0 to 15 do
          Begin
            n := offset + j;
            hex(ord(bytes^[n+StartVal]));
          end;

        Write('  ');
        {ASCII DUMP};
        {$I-}
        For j := 0 to 15 do
          Begin
            n := offset + j;
            m := ord(bytes^[n+StartVal]);
            If m > 127 then m := m - 128;
            If (m> 31) and (m<127) then
              Write(chr(m))
              Else Write(' ');
          end;
        Writeln{(outfile)};
        end;
    Write('  ESC to exit memory browse');
  End;

  Procedure ShowMachineRegs;
{$IfDef OldDebug}
  var
    i:integer;
{$EndIf}
  Begin
{$IfDef OldDebug}
  (*     INTSEGT: array [ 0..Maxseg] of
                  Record
                    REFCOUNT : Word;
                    SEGADDR  : Word;
                  end;
  *)
    Writeln(['MEMTOP = ',HexWord(SYSCOM^.MEMTOP),
           '  NEWSEG = ',HexWord(NEWSEG),
           '  NEWJTB = ',HexWord(NEWJTB),
           '  RLBASE = ',HexWord(RLBASE)]);
    Writeln(['SEGBOT = ',HexWord(SEGBOT),
          '  SEGNUM = ',HexWord(SEGNUM)]);
  {        '  SEGP   = ',HexWord(SEGP));}
  (*
       SEGBOT  ptr to bottom of segment
       RLBASE  base relocation amt
       REFP    pointer to relevant refcount
       PROCBOT pc relative (proc) relocation count
       RLDELTA relocation amt for current reloc
       SEGNUM  segment # currently being called
       SEGTP   ^segtable entry for segment
       NEWSEG  new SEGP
       NEWJTB  new JTAB pointer
  *)


    for i:= 0 to 7 do
      write([HexWord(INTSEGT[1].SEGADDR),' ']);
    writeln;
    for i:= 8 to maxseg do
      write([HexWord(INTSEGT[1].SEGADDR),' ']);
    writeln;
{$EndIf}
  end;


begin { TDebugForm.browsemem }
  StartVal := Start and $FFF0;   {Start on 16 byte boundary}
  ClrScr;
  gotoxy(1,1);
  ShowMachineRegs;
  Writeln([HexWord(Start),
  '-0--1--2--3--4--5--6--7--8--9--A--B--C--D--E--F-   0123456789ABCDEF']);
  repeat
    displaybuffer;
    x:=Get_Key;
    if x = 328 {uparrow}   then dec(StartVal,16);
    if x = 329 {PgUp}      then dec(StartVal,256);
    if x = 336 {downarrow} then inc(StartVal,16);
    if x = 337 {pgDown}    then inc(StartVal,256);

  until x=27;
  Clrscr;

end;  { TDebugForm.browsemem }








Procedure TDebugForm.PushF8State;
{save current trace and allow another}
Begin
  inc(TStk);
  TraceArray[TStk].l  := TraceTill;
  TraceArray[TStk].f8 := F8Key;
  TraceArray[TStk].p  := TraceProc;
  TraceArray[TStk].s  := TraceSeg;
  TraceArray[TStk].lex:= TraceLex;
  TraceArray[TStk].i  := 0;
end;


Procedure TDebugForm.PopF8State;
{restore trace state when previous one finished}
Begin
  if TStk=0 then exit;
  TraceTill  := TraceArray[TStk].l;
  F8Key      := TraceArray[TStk].f8;
  TraceProc  := TraceArray[TStk].p;
  TraceSeg   := TraceArray[TStk].s;
  TraceLex   := TraceArray[TStk].lex;
  TraceI     := TraceArray[TStk].i;
  dec(TStk);
end;


procedure TDebugForm.suffix(var s:string80; suff:string80; add:boolean);
{  Add a suffix. If add= false, only add suffix if there is not one present
   If Add=true, always add new suffix.  }
begin
  if pos('.',s)=0 then suff := concat('.',suff);
  if pos('.', s) <> 0 then
    if add then
      s[0] := chr(pos('.', s){ - 1})
    else
      exit;{(suffix);}
  s := concat(s, suff)
end;


Procedure TDebugForm.LoadSourceFile(sourcename:string80);
var i:integer;
    c:byte;
    loc:longint;
    attr,sx,sy:byte;
    line: string;
Begin
  suffix(Sourcename,'pas',true);
  AssignFile(f,sourcename);
  reset(f);
  i:=0;
  loc:=0;
  while not Eof(f) do
    begin
      System.ReadLn(f, Line);
      fl[i] := Line;
    end;
//  fl^[1]:=0;
//  i:=2;
{$R-}
(*
  while not eof(f) do
    begin
    seek(f,loc);
    read(f,c);
    If c = 13 then
      begin
      fl^[i] := loc+2;   {point past CR LF}
      inc(i);
      end;
    inc(loc);
    end;
*)
{$R+}
  closeFile(f);  //  {dhd - was commented out ***** close later  }
  currentline:=1;
  endline:=i;



  sx:=whereX;   {save external program's screen coords}
  sy:=whereY;
(*
  {create our debugging window}
  tpcrt.Window(1,26,80,50);
  {$IFDEF windows}
  {$ELSE }

  textmode(font8x8+co80);
  attr := textattr;
  {$ENDIF}
  SourceLoaded:=False;
  gotoxy(1,debugline-1);
  {$IFNDEF windows}

//Textcolor(blue);
//TextBackground(White);
//ClrEol;

  {$ENDIF}

//gotoxy(1,debugline-2);
//for i:=1 to 79 do write('-');
//gotoxy(3,debugline-1);
//Write('Source code..any key single steps');

  {Restore external program's window}
  tpcrt.Window(1,1,80,25);
  {restore external programme's text state}
  gotoxy(sx,sy);
  {$IFNDEF windows}
  TextAttr:=Attr;
  {$ENDIF}
*)

end;







Procedure TDebugForm.NormalVideo(x:integer);
Begin
  gotoxy(1,screenline);
  write(line[x-firstline+1]);
end;



Procedure TDebugForm.HiVideo(x:integer);
var attr:byte;
Begin
  {$IFNDEF windows}
//attr:=textattr;
//TextColor(blue);
//TextBackground(white);
//gotoxy(1,screenline);
//write(line[x-firstline+1]);
//textattr:=attr;
  {$ENDIF}
end;



Procedure TDebugForm.RedrawScreen(x:integer);
{draw screen starting at line x}
var i:integer;
    y:byte;
    z:integer;  {0...20}
    c:byte;
    loc:longint;
Begin
  {first write divider between top and bottom screens}
//Textcolor(yellow);
//TextBackground(blue);
  gotoxy(1,debugline-2);
  for i:=1 to 79 do write('-');
  gotoxy(3,debugline-2);
  Write('Source code..any key single steps');


  Currentline := x;
(*
  Screenline :=debugline;     {display at top of debugscreen}
  if x>6 then
    begin
    x:=x-6;         {show 4 lines above current line}
    ScreenLine := ScreenLine+6;
    end;
  firstline:=x;
  i:=x;

  Repeat
    y:=i-firstline+debugline;
    gotoxy(1,y);
    ClrEol;
    z:=i-firstline+1;
    line[z]:='';
    loc:=fl^[i];
    seek(f,loc);
    read(f,c);

    while c<> 13 do
      begin
      line[z]:=line[z]+chr(c);  {build the line}
      inc(loc);
      seek(f,loc);
      read(f,c);

      end;
    gotoxy(1,y);
    Write(line[z]);
    inc(i);
  until (i>=firstline+totaldebug) or (i>=endline);
  lastline:=i;
  {handle past end of file}
  if (i<firstline+totaldebug) then
    begin  {clear rest of screen}
    repeat
      gotoxy(1,i-firstline + debugline);
      clreol;
      inc(i);
    until (i>=firstline+totaldebug);
    end;
*)  
end;





Procedure TDebugForm.ShowSource(LineNum : word);
label 1;
var i:integer;
    sx,sy,attr:byte;
    ch:char;
    KeyVal : integer;
    j:word;
    c:char;

  {fix for blank source lines that did not generate code}
  Function BackFromCall:boolean;
  Begin
{$IfDef OldDebug}
    BackFromCall := (TraceProc=bytes^[SYSCOM^.JTAB])
                and (TraceSeg =bytes^[SYSCOM^.SEG])
                and (TraceLex =bytes^[SYSCOM^.JTAB+1]);
{$EndIf}
  end;


Begin { TDebugForm.ShowSource }
{$IfDef OldDebug}
  If Linetrace then begin
    append(lt);
    System.Writeln(Lt,LineNum:5,' MP=',(hexword(Syscom^.LASTMP)),
                         ' BASE=',(hexword(Syscom^.STKBASE)),
                         ' SP=',(hexword(SP)));
    CloseFile(lt); // close(lt);
    exit;

    end;

1:

  if (F8key) and (not BackFromCall) {(linenum <>(* was < *) tracetill)} then
      exit
  else   {we may be back from F8 call..restore prior trace state}
    if (F8Key) and BackFromCall {(linenum>=tracetill)} then
    PopF8State;
  sx:=whereX;   {save external program's screen coords}
  sy:=whereY;
  {$IFNDEF windows}
//attr := textattr;

  {make debug window}
//tpcrt.Window(1,26,80,49);
  {$ENDIF windows}



  if linenum <1 then exit;
  if linenum > endline then exit;
  if (linenum >= firstline) and (linenum<lastline) then
    begin  {line on page....do not scroll}
    NormalVideo(Currentline);
    CurrentLine := linenum;
    ScreenLine  := linenum-firstline + debugline;
    HiVideo(CurrentLine);
    end
  else
    begin {line not on screen redraw screen}
    if linenum >= endline then exit;
    RedrawScreen(linenum);
    HiVideo(currentline);
    end;

  gotoxy(70,1);
  Write ('LN');
  write(PadL(linenum, 7));
  gotoxy(70,2);
  write ('IO');
  write([Format('%7d', [hexword(DebugIORSLT)])]);
  gotoxy(64,3); write(['BASE',PadL(Syscom^.STKBASE, 6),' ']);  write(hexword (Syscom^.STKBASE));
  gotoxy(64,4); write(['MP  ',PadL(Syscom^.LASTMP,6),' ']); write(hexword (Syscom^.LASTMP));
  gotoxy(64,5); write(['SP  ',PadL(sp,6),' ']);  write(hexword(SP));
  gotoxy(64,6); write(['NP  ',PadL(np,6),' ']);  write(hexword(NP));
(*
  for i:=40 downto 0 do
    begin
    gotoxy(65,47-i); j:=(sp+i*2); write(hexword(j));
    gotoxy(70,47-i);
    write(hexbyte(bytes^[(SP+i*2+1) ]));
    write(hexbyte(bytes^[(SP+i*2) ]));
    write(' ');
    c := chr(bytes^[SP+i*2+1]);
    if c in [' '..'~'] then write(c) else write('.');
    c := chr(bytes^[SP+i*2]);
    if c in [' '..'~'] then write(c) else write('.');

    if (sp + i*2 ) = sp then write(' <SP')
    else
    if (sp + i*2 ) = MP then write(' <MP')
    else
    if (sp + i*2 ) = BASE then write(' <BASE')
    else
      write('    ');

    end;
*)
    F8Key := False;
    KeyVal := Get_Key;
    If KeyVal=324{F10KEY   LINETRACE} then
      begin
      If not Linetrace then begin
//      Assign(lt,'c:\LINETRCE.TXT'); Rewrite(lt);
        AssignFile(lt,'c:\Temp.txt'); Rewrite(lt);
        LineTrace := true;
//      close(lt);
        closeFile(lt);
        end;
      end
    else
    If KeyVal=322{VMF8KEY} then
      begin
      PushF8State;     {save existing tracing info and trace on next line}
      tracetill := linenum+1;
      F8key := true;
      TraceProc := bytes^[SYSCOM^.JTAB];
      TraceSeg  := bytes^[SYSCOM^.SEG];
      TraceLex  := bytes^[SYSCOM^.JTAB+1];
      TraceI    := 0;
      end
    else
    if KeyVal=32 then {space shows mem}
      Begin
      BrowseMem(Syscom^.STKBASE);
      goto 1;
      end
    else
    if KeyVal = 321{F7KEY} then
      Begin
      end
    else
      begin
      tracetill := 0;
      F8key:=false;
      end;

    {Restore external program's window}
//  tpcrt.Window(1,1,80,25);
    {restore external program's text state}
    gotoxy(sx,sy);
    {$IFNDEF windows}
//  TextAttr:=Attr;
    {$ENDIF windows}
{$EndIf OldDebug}    
end;



procedure TDebugForm.init;
var attr:byte;
Begin
  SourceLoaded:=False;
  firstline:=1;
  lastline:=-1;
  currentline:=1;
  tracetill:=0;
  f8key := false;
  TStk := 0;
  pushF8State;
//new(fl);
  LineTrace := false;
end;





PROCEDURE TDebugForm.SELECT;
VAR C:CHAR;
    I,CRAP:INTEGER;
    KeyVal: Integer;
BEGIN

  REPEAT
    KeyVal := Get_Key;
{
    GOTOXY(1,1); WRITELN(C);
    WRITELN(ORD(rESULT));
}

    CASE KeyVal OF
    328 {VMUPKEY}      : ShowSource(CURRENTLINE-1);
    336  {VMDOWNKEY}   : ShowSource(CURRENTLINE+1);
    else  {VMNOTSPECIAL} ShowSource(I);
    END;
  UNTIL KeyVal= 27{VMESCAPEKEY};
END;


constructor TDebugForm.Create;
begin
  init;
end;

initialization
//init;
(*
  Loadsourcefile('debug.pas');
  ShowSource(1);
  select;
*)

END.