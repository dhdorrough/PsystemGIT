unit CRTUnit;

interface

uses pSys_Decl, MyUtils, Classes, Search_Decl, Interp_Const;

const
  MAXKEY = #255;
  ESCC = #27;

type
  integer = smallint;
  String2 = string[2];
  ShortStr = string[9];

  // WARNING: THE ORDER OF THE FOLLOWING ITEMS MAY BE SIGNIFICANT. RE-ORDER ONLY WITH CAUTION.
  //       Specifically, the function SetDefaultTermInfo ASSUMES this order.
  //       Some reports may assume some information from this order (e.g. CSVLine, CRTHeaderLine).
  TCRTFuncs = ({0}cf_Unknown,
               { screen items }
               {01}cf_LeadInToScreen,

               {02}cf_MaxRows,
               {03}cf_MaxCols,
               {04}cf_EraseToEndOfScreen,
               {05}cf_EraseToEndOfLine,
               {06}cf_MoveCursorUp,
               {07}cf_MoveCursorRight,
               {08}cf_MoveCursorDown,
               {09}cf_MoveCursorLeft,
//                 cf_DeleteChar,
               {10}cf_EraseScreen,
               {11}cf_EraseLine,
               {12}cf_MoveCursorHome,
               {13}cf_InsertLine,
               {14}cf_GotoXY,
//             cf_NonPrintingCharacter,    // if present, it becomes an escape character which causes problems


               { keyboard items }
               kf_LeadInFromKeyBoard,

               kf_BackSpace, kf_KeyForStop, kf_KeyForBreak,
               kf_KeyForFlush, kf_KeyToEndFile, kf_EditorEscapeKey,
//             kf_KeyToDeleteLine,
               kf_EditorAcceptKey,
               kf_KeyToDeleteCharacter, kf_KeyToMoveCursorLeft,
               kf_KeyToMoveCursorRight, kf_KeyToMoveCursorUp, kf_KeyToMoveCursorDown,
               kf_KeyToMoveToNextWord,  
               kf_PageDown,             kf_PageUp      
               );

const
  LOW_CRT_FUNC   = cf_LeadInToScreen;
  HIGH_CRT_FUNC  = cf_InsertLine;
  LOW_KEY_FUNC   = kf_LeadInFromKeyBoard;
//HIGH_KEY_FUNC  = kf_KeyToMoveCursorDown;
  HIGH_KEY_FUNC  = High(TCRTFuncs);

type
  TTermType = (tt_Unknown, tt_VT52, tt_Soroc, tt_Hazeltine, tt_H19, tt_ANSI, tt_IBM, tt_ADM, tt_VT100, tt_PeterMiller);

  TFuncInfo = packed record
                Pfxed  : boolean;
                ch     : char;
                vk     : word;
              end;

  TTermTypeInfo = packed record
(*                  TTName: string; *)
                    Name: string;
                    ESC:  string2;   // escape character
                    MinC: byte;      // minimum characters needed
                    Funcs: packed array[LOW_CRT_FUNC..HIGH_CRT_FUNC] of TFuncInfo;
                  end;

{$Define DebugInfo}

  string3         = string[3];
  string30        = string[30];

  TCrtInfo        = class;
  
  TInfoChangedEvent = procedure {name}(var CRTInfo: TCRTInfo) of object;

  TCRTInfo = class(TObject)
  private
    fFunctionPrefixes: TSetOfChar;
    fMaxRows: integer;
    fMaxCols: integer;
    fPrefixChar: char;
    fGotoXYPrefix: TSetOfChar;
    fStatusProc: TStatusProc;
    fCRTType: integer;
    fTermType: TTermType;
    fOnInfoChanged: TInfoChangedEvent;

    procedure DisplayStatus(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true);
    function GetPrefixChar: char;
    procedure SetTermType(const Value: TTermType);
    function GetGotoXYPrefix: TSetOfChar;
    function GetOnInfoChanged: TInfoChangedEvent;
    procedure SetPrefixChar(const Value: char);

  public
    The_Low_Func : TCRTFuncs;
    The_High_Func: TCRTFuncs;

    CRTFuncInfo  : packed array[TCRTFuncs] of TFuncInfo;
    Index        : array[#0..MAXKEY] of TCRTFuncs;

    procedure AddFunc( cf: TCRTFuncs;
                       Prefixed: boolean;
                       NewCH: char;
                       vk_: word = 0);
    function CharToCRTFunc(ch: char): TCRTFuncs;
    function CSVLine(const FileName: string; const VolumePath: string; DoGuessTermType: boolean = false): string;
    class function CRTHeaderLine(FuncLow, FuncHigh: TCrtFuncs): string;
    function GuessTerminalType: TTermType;
    procedure InfoChanged;
    function FormatCH(Pfxed: boolean; c: char): string;
    procedure LookForUnusedFuncs;
    procedure Reset(const What: string);
    procedure SetFunctionPrefixes(LeadIn, Low, High: TCRTFuncs; VersionNr: TVersionNr);
    procedure Show(const Name: string; N: integer);
    procedure ShowC(const Name: string; ch: char);

    property OnInfoChanged: TInfoChangedEvent
             read GetOnInfoChanged
             write fOnInfoChanged;
    property TheMaxCols: integer
             read fMaxCols
             write fMaxCols;
    property TheMaxRows: integer
             read fMaxRows
             write fMaxRows;
    property OnStatusProc: TStatusProc
             read fStatusProc
             write fStatusProc;
    property CRTType: integer
             read fCRTType
             write fCRTType;
    property PrefixChar: char
             read GetPrefixChar
             write SetPrefixChar;
    property FunctionPrefixes: TSetOfChar
             read fFunctionPrefixes
             write fFunctionPrefixes;
    property TermType: TTermType
             read fTermType
             write SetTermType;
    property GoToXYPrefixChar: TSetOfChar
             read GetGoToXYPrefix
             write fGoToXYPrefix;
    property StatusProc: TStatusProc
             read fStatusProc
             write fStatusProc;
    Constructor Create(Low_CF, High_CF: TCrtFuncs{; aVersionNr: TVersionNr});
    Destructor Destroy; override;
  end;

  TFuncNames = record
                 Abbrev: string;
                 SN: string;
               end;

var
  // GoToXY Sequences
  TermTypes: array[TTermType] of TTermTypeInfo = (
({ttName: 'tt_Unknown'}    ),
({ttName: 'tt_VT52';}        Name: 'VT-52';        Esc: ESCC+'Y'; Minc: 4),
({ttName: 'tt_Soroc';}       Name: 'Soroc';        Esc: ESCC+#25; Minc: 3),        // #30XY            // X+32, Y+32
({ttName: 'tt_Haz27';}       Name: 'Hazeltine';    Esc: ESCC+#17; Minc: 4),        // #27, ^Q, X, Y
({ttName: 'tt_H19';}         Name: 'H19';          Esc: ESCC+'Y'; Minc: 4),        // guessing to be like the VT52?
({ttName: 'tt_ANSI';}        Name: 'ANSI';         Esc: ESCC+'['; Minc: 5),        // <esc>[YY;XXH
({ttName: 'tt_IBM';}         Name: 'IBM';          Esc: ESCC;     Minc: 0),        // <esc>YX          // Y+32, X+32
({ttName: 'tt_ADM';}         Name: 'ADM';          Esc: ESCC+'='; Minc: 0),        // <esc>=XY         // X+32, Y+32
({ttName: 'tt_VT100';}       Name: 'VT-100';       Esc: ESCC+'['; Minc: 5),       // <esc>[Y;XH        // Y+1; X+1
({ttName: 'tt_PeterMiller';} Name: 'Peter Miller'; Esc: #$1E;     Minc: 3)        // <#30=#$1E>        // Y+32, X+32
                   );

  FuncNames : array[TCRTFuncs] of TFuncNames = (
               ({cfName: 'cf_Unknown';}              SN: 'Unknown'),

               { screen items }
               ({cfName: 'cf_LeadInToScreen';}       Abbrev: 'Lead in'; SN: 'Lead In To Screen'),

               ({cfName: 'cf_MaxRows';}              Abbrev: 'Rows';  SN: 'MaxRows'),
               ({cfName: 'cf_MaxCols';}              Abbrev: 'Cols';  SN: 'MaxCols'),

               ({cfName: 'cf_EraseToEndOfScreen';}   Abbrev: 'EEOS';  SN: 'Erase To End Of Screen'),
               ({cfName: 'cf_EraseToEndOfLine';}     Abbrev: 'EEOL';  SN: 'Erase To End Of Line'),
               ({cfName: 'cf_MoveCursorUp';}         Abbrev: 'Up';    SN: 'Move Cursor Up'),
               ({cfName: 'cf_MoveCursorRight';}      Abbrev: 'Right'; SN: 'Move Cursor Right'),
               ({cfName: 'cf_MoveCursorDown';}       Abbrev: 'Down';  SN: 'Move Cursor Down'),
               ({cfName: 'cf_MoveCursorLeft';}       Abbrev: 'Left';  SN: 'Move Cursor Left'),
//             ({cfName: 'cf_DeleteChar';}           SN: 'Delete Char'),
               ({cfName: 'cf_EraseScreen';}          Abbrev: 'ESCN';  SN: 'Erase Screen'),
               ({cfName: 'cf_EraseLine';}            Abbrev: 'ELIN';  SN: 'Erase Line'),
               ({cfName: 'cf_MoveCursorHome';}       Abbrev: 'Home';  SN: 'Move Cursor Home'),
               ({cfName: 'cf_InsertLine';}           SN: 'Insert Line'),  // This is used by the Advanced System Editor

               ({cfName: 'cf_GotoXY';}               SN: 'GotoXY'),
//             ({cfName: 'cf_NonPrintingCharacter';} SN: 'Non-Printing Character'),

               { keyboard items }
               ({cfName: 'kf_LeadInFromKeyBoard';}   Abbrev: 'LeadIn'; SN: 'Lead In From Key Board'),

               ({cfName: 'kf_BackSpace';}            Abbrev: 'BS';     SN: 'Back Space'),
               ({cfName: 'kf_KeyForStop';}           Abbrev: 'Stop';   SN: 'Key For Stop'),
               ({cfName: 'kf_KeyForBreak';}          Abbrev: 'Break';  SN: 'Key For Break'),
               ({cfName: 'kf_KeyForFlush';}          Abbrev: 'Flush';  SN: 'Key For Flush'),
               ({cfName: 'kf_KeyToEndFile';}         Abbrev: 'EOF';    SN: 'Key To End File'),
               ({cfName: 'kf_EditorEscapeKey';}      Abbrev: 'Escape'; SN: 'Editor "Escape" Key'),
//             ({cfName: 'kf_KeyToDeleteLine';}      Abbrev: 'DelLine';SN: 'Key To Delete Line'),
               ({cfName: 'kf_EditorAcceptKey';}      Abbrev: 'Accept'; SN: 'Editor "Accept" Key'),
               ({cfName: 'kf_KeyToDeleteCharacter';} Abbrev: 'DelCh';  SN: 'Key To Delete Character'),
               ({cfName: 'kf_KeyToMoveCursorLeft';}  Abbrev: 'Left';   SN: 'Key To Move Cursor Left'),
               ({cfName: 'kf_KeyToMoveCursorRight';} Abbrev: 'Right';  SN: 'Key To Move Cursor Right'),
               ({cfName: 'kf_KeyToMoveCursorUp';}    Abbrev: 'Up';     SN: 'Key To Move Cursor Up'),
               ({cfName: 'kf_KeyToMoveCursorDown';}  Abbrev: 'Down';   SN: 'Key To Move Cursor Down'),
               ({cfName: 'kf_KeyToMoveToNextWord'}   Abbrev: 'Word';   SN: 'Key To Move To Next Word'),
               ({cfName: 'kf_PageDown'}              Abbrev: 'PgDn';   SN: 'PageDown'),
               ({cfname: 'kf_PageUp'}                Abbrev: 'PgUp';   SN: 'PageUp')
              );

implementation

uses SysUtils;

{ TCRTInfo }

//  TStatusProc      = procedure {StatusProc} (const Msg: string; DoLog: boolean = true; DoStatus: boolean = true) of object;

procedure TCRTInfo.DisplayStatus(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true);
begin
  if Assigned(fStatusProc) then
    fStatusProc(Msg, DoLog, DoStatus)
end;


procedure TCRTInfo.AddFunc( cf: TCRTFuncs;
                            Prefixed: boolean;
                            NewCH: char;
                            vk_: word = 0);
begin
  if NewCH <> #0 then
    with CRTFuncInfo[cf] do
      if (Index[NewCH] = cf_Unknown) then
        begin
          if (CRTFuncInfo[cf].CH = #0) then
            begin
              Pfxed        := Prefixed;
              CH           := NewCH;
              vk           := vk_;
              Index[NewCH] := cf;
            end
          else
            DisplayStatus(Format('AddFunc %2d (%s) is already defined', [ord(cf), FuncNames[cf].SN]));
        end
      else
        DisplayStatus(Format('Attempt to assign (%s) to character #%d failed.  #%d is Already assigned to function %s.',
                             [FuncNames[CF].SN, ord(NewCH), ord(NewCH), FuncNames[Index[NewCH]].SN]));
end;


function TCRTInfo.FormatCH(Pfxed: boolean; c: char): string;
begin { FormatCH }
  result := '';

  if c <> #0 then
    begin
      if Pfxed then
        result := '*';
      if (c >= ' ') and (c < #127) then
        result := result + c
      else if c <= ' ' then
        result := result + Format('#%d', [ord(c)])
      else
        result := result + '#127';
    end
end;  { FormatCH }

procedure TCRTInfo.LookForUnusedFuncs;
var
  cf: TCRTFuncs;
  NrFound: integer;
begin { TCRTInfo.LookForUnusedFuncs }
  NrFound := 0;
  for cf := Succ(Low(TCRTFuncs)) to High(TCRTFuncs) do
    with CRTFuncInfo[cf] do
      if (ch = #0) {and (not Forced)} then
        Inc(NrFound)
      else
        DisplayStatus(Format('%6s (#%3d) %s ', [FormatCH(Pfxed, Ch), ord(ch), FuncNames[cf].SN]));

  if NrFound = 0 then
    DisplayStatus('No unused functions were found');
end;  { TCRTInfo.LookForUnusedFuncs }


procedure TCRTInfo.Reset(const What: string);
var
  Msg: string;
begin
  Fillchar(CRTFuncInfo, SizeOf(CRTFuncInfo), 0);
  FillChar(Index,       SizeOf(Index),       0);
  fTermType := tt_Unknown;
  Msg := Padr('-', 80, '-');
  DisplayStatus(Msg);
  DisplayStatus(Format('%s assignments:', [What]));
end;

  procedure TCRTInfo.ShowC(const Name: string; ch: char);
  var
   s: string;
  begin
    S := FormatCH(false, CH);
    DisplayStatus(Format('%-10s: %s', [Name, S]));
  end;

  procedure TCRTInfo.Show(const Name: string; N: integer);
  begin
    DisplayStatus(Format('%-10s: %d', [Name, N]));
  end;


function TCRTInfo.CharToCRTFunc(ch: char): TCRTFuncs;
begin
  result := Index[ch];
//if result = cf_Unknown then { what is supposed to happen here? Maybe look for a GOTOXY sequence? }

end;

function TCRTInfo.GetPrefixChar: char;
begin
//if fTermType <> tt_Unknown then
//  fPrefixChar := TermTypes[fTermType].ESC;
  result := fPrefixChar;
end;

function TCRTInfo.GetGotoXYPrefix: TSetOfChar;
begin
  if fTermType <> tt_Unknown then
    fGoToXYPrefix := [TermTypes[fTermType].ESC[1]];
  result := fGoToXYPrefix;
end;


procedure TCRTInfo.SetTermType(const Value: TTermType);
var
  Pfx: char;
  cf: TCRTFuncs;
begin
  if Value <> fTermType then
    begin
      // Set the operating characteristics for the selected terminal
      for cf := LOW_CRT_FUNC to HIGH_CRT_FUNC do
        CrtFuncInfo[cf] := TermTypes[Value].Funcs[cf];

      // and setup the GoToXY parameters
      with CrtFuncInfo[cf_GotoXY] do
        begin
          if TermTypes[Value].Esc[1] = CRTFuncInfo[cf_LeadInToScreen].ch then
            begin
              Pfxed      := true;
              Pfx        := TermTypes[Value].Esc[2];
            end
          else
            begin
              Pfxed := false;
              Pfx   := TermTypes[Value].Esc[1];
            end;

          Index[Pfx] := cf_GotoXY;  // we need to be able to index on this char
//        SetFunctionPrefixes(cf_LeadInToScreen, cf_EraseToEndOfScreen, cf_MoveCursorHome);
        end;
    end;
  // currently ignoring fact that the 2nd char might be the prefix!
  fTermType := Value;
end;

procedure TCRTInfo.InfoChanged;
begin
  if Assigned(fOnInfoChanged) then
    fOnInfoChanged(self);
end;

function TCRTInfo.GetOnInfoChanged: TInfoChangedEvent;
begin
  if Assigned(fOnInfoChanged) then
    Result := fOnInfoChanged
  else
    raise Exception.Create('fOnInfoChanged is not defined');
end;

constructor TCRTInfo.Create(Low_CF, High_CF: TCrtFuncs{; aVersionNr: TVersionNr});
begin
  The_Low_Func  := Low_CF;
  The_High_Func := High_CF;
//fVersionNr    := aVersionNr;
end;

function TCRTInfo.CSVLine(const FileName: string; const VolumePath: string; DoGuessTermType: boolean = false): string;
var
  cf: TCRTFuncs;
  val, TermType: string;
begin
  if DoGuessTermType then
    TermType := TermTypes[GuessTerminalType].Name
  else
    TermType := '??';

  result := TermType + ',' + Quoted(FileName);
  for cf := The_Low_Func to The_High_Func do
    case cf of
      cf_MaxCols:
        result := result + ',' + IntToStr(TheMaxCols);
      cf_MaxRows:
        result := result + ',' + IntToStr(TheMaxRows);
    else
      with CRTFuncInfo[cf] do
        begin
          Val := FormatCH(Pfxed, ch);
          result := result + ',' + Val;
        end;
    end;
  result := result + ',' + Quoted(VolumePath);
end;

class function TCRTInfo.CRTHeaderLine(FuncLow, FuncHigh: TCrtFuncs): string;
var
  cf: TCRTFuncs;
begin
  result := 'Term Type,File Name';
  for cf := FuncLow to FuncHigh do
    with FuncNames[cf] do
      result := result + ',' + Abbrev;
  result := result + ',' + 'Volume Path';
end;

function TCRTInfo.GuessTerminalType: TTermType;
var
  tt: TTermType;
  cf: TCrtFuncs;
  Votes: array[TTermType] of integer;
begin
  for tt := Low(TTermType) to High(TTermType) do
    Votes[tt] := 0;
  for tt := Succ(Low(TTermType)) to High(TTermType) do
    with TermTypes[tt] do
      begin
        for cf := The_Low_Func to The_High_Func do
          if not (cf in [cf_MaxRows, cf_MaxCols]) then
            if (Funcs[cf].Pfxed = CRTFuncInfo[cf].Pfxed) and
               (Funcs[cf].ch    = CRTFuncInfo[cf].ch) then   // or maybe just: Funcs[cf] = CRTFuncInfo[cf]
                 Inc(Votes[tt]);
      end;
  result := tt_Unknown;
  for tt := Succ(Low(TTermType)) to High(TTermType) do
    if Votes[tt] > Votes[result] then
      result := tt;
end;

destructor TCRTInfo.Destroy;
begin
  inherited;
end;

procedure TCRTInfo.SetPrefixChar(const Value: char);
begin
  fPrefixChar := Value;
end;

{ TCRTInfoPSys }

procedure TCRTInfo.SetFunctionPrefixes(LeadIn, Low, High: TCRTFuncs; VersionNr: TVersionNr);
var
  cf: TCrtFuncs;

  procedure AddPrefix(cf: TCRTFuncs);
  begin { AddPrefix }
    with CRTFuncInfo[cf] do
      if ch <> #0 then
        FunctionPrefixes := FunctionPrefixes + [ch];
  end;  { AddPrefix }

begin { SetFunctionPrefixes }
  PrefixChar := CRTFuncInfo[LeadIn].ch;
  FunctionPrefixes := [];
  AddPrefix(LeadIn);
  if VersionNr > vn_VersionI_4 then // VI.4 does not have MISCINFO settings for "Prefixed"
    begin
      for cf := Low to High do
        if not CrtFuncInfo[cf].Pfxed then
          AddPrefix(cf);

      AddPrefix(cf_GotoXY);
    end
  else
    begin
      // For VI.4 assume that if it is one of the movement characters,
      // and there is an ESCAPE char defined, then the movement char
      // must be prefixed by the ESCAPE char.
      if PrefixChar <> #0 then
        for cf := Low to High do
          begin
            CrtFuncInfo[cf].Pfxed := (cf in [cf_EraseToEndOfScreen, cf_EraseToEndOfLine, cf_MoveCursorUp,
                                             cf_MoveCursorRight, cf_MoveCursorDown, cf_MoveCursorLeft, cf_EraseScreen,
                                             cf_EraseLine, cf_MoveCursorHome, cf_GotoXY]) and
                                     (CrtFuncInfo[cf].ch >= ' ');
          end;
    end;
end;  { SetFunctionPrefixes }

initialization
  // Set the default CRT control characters in case we want to guess what kind of terminal we have.
  // This should really all be placed into an editable text file that gets loaded.
  with TermTypes[tt_VT52] do
    begin
{01}  with Funcs[cf_LeadInToScreen]     do begin Pfxed := FALSE; ch := #27 end;
{02}  with Funcs[cf_MaxRows]            do begin Pfxed := FALSE; ch := #24 end;
{03}  with Funcs[cf_MaxCols]            do begin Pfxed := FALSE; ch := #80 end;
{04}  with Funcs[cf_EraseToEndOfScreen] do begin Pfxed := TRUE ; ch := 'J' end;
{05}  with Funcs[cf_EraseToEndOfLine]   do begin Pfxed := TRUE ; ch := 'K' end;
{06}  with Funcs[cf_MoveCursorUp]       do begin Pfxed := TRUE ; ch := 'A' end;
{07}  with Funcs[cf_MoveCursorRight]    do begin Pfxed := TRUE ; ch := 'C' end;
{08}  with Funcs[cf_MoveCursorDown]     do begin Pfxed := TRUE;  ch := 'B' end;
{09}  with Funcs[cf_MoveCursorLeft]     do begin Pfxed := TRUE;  ch := 'D' end;
{10}  with Funcs[cf_EraseScreen]        do begin Pfxed := TRUE ; ch := 'E' end;
{11}  with Funcs[cf_EraseLine]          do begin Pfxed := TRUE ; ch := 'I' end;
{12}  with Funcs[cf_MoveCursorHome]     do begin Pfxed := TRUE ; ch := 'H' end;
{13}  with Funcs[cf_InsertLine]         do begin Pfxed := TRUE ; ch := 'I' end;
    end;

  with TermTypes[tt_PeterMiller] do
    begin
//    with Funcs[cf_LeadInToScreen]     do begin Pfxed := FALSE; ch := #$19 end;
      with Funcs[cf_MaxRows]            do begin Pfxed := FALSE; ch := #24 end;
      with Funcs[cf_MaxCols]            do begin Pfxed := FALSE; ch := #80 end;
      with Funcs[cf_EraseToEndOfScreen] do begin Pfxed := FALSE; ch := #11 end;
      with Funcs[cf_EraseToEndOfLine]   do begin Pfxed := FALSE; ch := #29 end;
      with Funcs[cf_MoveCursorUp]       do begin Pfxed := FALSE; ch := #11 {#$0B} end;
      with Funcs[cf_MoveCursorRight]    do begin Pfxed := FALSE; ch := #12 {#$0C} end;
      with Funcs[cf_MoveCursorDown]     do begin Pfxed := FALSE; ch := #10 {#$0A} end;
      with Funcs[cf_MoveCursorLeft]     do begin Pfxed := FALSE; ch := #8 end;
//    with Funcs[cf_EraseScreen]        do begin Pfxed := TRUE ; ch := '*' end;
//    with Funcs[cf_EraseLine]          do begin Pfxed := FALSE; ch := #0 end;
      with Funcs[cf_MoveCursorHome]     do begin Pfxed := FALSE; ch := #$19 end;
    end;

  with TermTypes[tt_Soroc] do
    begin
      with Funcs[cf_LeadInToScreen]     do begin Pfxed := FALSE; ch := #27 end;
      with Funcs[cf_MaxRows]            do begin Pfxed := FALSE; ch := #24 end;
      with Funcs[cf_MaxCols]            do begin Pfxed := FALSE; ch := #80 end;
      with Funcs[cf_EraseToEndOfScreen] do begin Pfxed := TRUE ; ch := 'Y' end;
      with Funcs[cf_EraseToEndOfLine]   do begin Pfxed := TRUE ; ch := 'T' end;
      with Funcs[cf_MoveCursorUp]       do begin Pfxed := FALSE; ch := #11 end;
      with Funcs[cf_MoveCursorRight]    do begin Pfxed := FALSE; ch := #12 end;
      with Funcs[cf_MoveCursorDown]     do begin Pfxed := FALSE; ch := #10 end;
      with Funcs[cf_MoveCursorLeft]     do begin Pfxed := FALSE; ch := #8 end;
      with Funcs[cf_EraseScreen]        do begin Pfxed := TRUE ; ch := '*' end;
      with Funcs[cf_EraseLine]          do begin Pfxed := FALSE; ch := #0 end;
      with Funcs[cf_MoveCursorHome]     do begin Pfxed := FALSE; ch := #30 end;
    end;

  TermTypes[tt_H19] := TermTypes[tt_VT52]; // H19 is the same as a VT-52
  TermTypes[tt_H19].Name := 'H19';

  with TermTypes[tt_ADM] do   // untested
    begin
      with Funcs[cf_LeadInToScreen]     do begin Pfxed := FALSE; ch := #27 end;
      with Funcs[cf_MaxRows]            do begin Pfxed := FALSE; ch := #24 end;
      with Funcs[cf_MaxCols]            do begin Pfxed := FALSE; ch := #80 end;
      with Funcs[cf_EraseToEndOfScreen] do begin Pfxed := TRUE ; ch := 'Y' end;
      with Funcs[cf_EraseToEndOfLine]   do begin Pfxed := TRUE ; ch := 'T' end;
      with Funcs[cf_MoveCursorUp]       do begin Pfxed := FALSE; ch := #11 end;
      with Funcs[cf_MoveCursorRight]    do begin Pfxed := FALSE; ch := #12 end;
      with Funcs[cf_MoveCursorDown]     do begin Pfxed := FALSE; ch := #10 end;
      with Funcs[cf_MoveCursorLeft]     do begin Pfxed := FALSE; ch := #8 end;
      with Funcs[cf_EraseScreen]        do begin Pfxed := TRUE ; ch := #26 end;
      with Funcs[cf_EraseLine]          do begin Pfxed := FALSE; ch := #0 end;
      with Funcs[cf_MoveCursorHome]     do begin Pfxed := FALSE; ch := #30 end;
    end;

  with TermTypes[tt_Hazeltine] do
    begin
      with Funcs[cf_LeadInToScreen]     do begin Pfxed := FALSE; ch := '~' end;
      with Funcs[cf_MaxRows]            do begin Pfxed := FALSE; ch := #24 end;
      with Funcs[cf_MaxCols]            do begin Pfxed := FALSE; ch := #80 end;
      with Funcs[cf_EraseToEndOfScreen] do begin Pfxed := TRUE ; ch := #24 end;
      with Funcs[cf_EraseToEndOfLine]   do begin Pfxed := TRUE ; ch := #15 end;
      with Funcs[cf_MoveCursorUp]       do begin Pfxed := TRUE;  ch := #12 end;
      with Funcs[cf_MoveCursorRight]    do begin Pfxed := TRUE;  ch := #127 end;
      with Funcs[cf_MoveCursorDown]     do begin Pfxed := FALSE; ch := #10 end;
      with Funcs[cf_MoveCursorLeft]     do begin Pfxed := FALSE; ch := #8 end;
      with Funcs[cf_EraseScreen]        do begin Pfxed := TRUE ; ch := #28 end;
      with Funcs[cf_EraseLine]          do begin Pfxed := FALSE; ch := #0 end;
      with Funcs[cf_MoveCursorHome]     do begin Pfxed := TRUE;  ch := #18 end;
    end;
(*
  with TermTypes[tt_vt100] do // UNTESTED
    begin
      with Funcs[cf_LeadInToScreen]     do begin Pfxed := FALSE; ch := #27 end;
      with Funcs[cf_MaxRows]            do begin Pfxed := FALSE; ch := #24 end;
      with Funcs[cf_MaxCols]            do begin Pfxed := FALSE; ch := #80 end;
      with Funcs[cf_EraseToEndOfScreen] do begin Pfxed := TRUE ; ch := 'J' end;
      with Funcs[cf_EraseToEndOfLine]   do begin Pfxed := TRUE ; ch := 'K' end;
      with Funcs[cf_MoveCursorUp]       do begin Pfxed := TRUE; ch := 'A' end;
      with Funcs[cf_MoveCursorRight]    do begin Pfxed := TRUE; ch := 'C' end;
      with Funcs[cf_MoveCursorDown]     do begin Pfxed := FALSE; ch := #10 end;
      with Funcs[cf_MoveCursorLeft]     do begin Pfxed := FALSE; ch := #8 end;
      with Funcs[cf_EraseScreen]        do begin Pfxed := TRUE ; ch := #42 end;
      with Funcs[cf_EraseLine]          do begin Pfxed := FALSE; ch := #0 end;
      with Funcs[cf_MoveCursorHome]     do begin Pfxed := TRUE;  ch := 'H' end;
    end;
*)

end.
