
// REMINDER: Parameters and variables may be passed in reverse order. This also depends on the version number.

// Version 1.5: These variables are stored in order
//     var
//       Intm1 := 1;
//       Intm2 := '2';
//       IntM3 := 3.0;
// Version 1.5: These variables are stored in reverse order (i.e., Intm6, Intm5, Intm4)
//     var
//       Intm4, Intm5, Intm6: integer;
// Version 1.5
//     function Length2(p1: integer; p2: integer; p3: integer): integer;
//     will allocate 2 words for the function result and then
//     parameters will be stored in sequential order, i.e.
//       p1: integer;
//       p2: integer;
//       p3: integer;
// Version 1.5
//     function Length2(p1, p2, p3: integer): integer;
//     will allocate 2 words for the function result and then
//     parameters will be stored in reverse order, i.e.
//       p3: integer;
//       p2: integer;
//       p1: integer;

unit ListingUtils;

interface

uses
  SysUtils, Watch_Decl, UCSDGlob, MyUtils, Interp_Decl, Interp_Const;

const

  DEF_TYPENAME_LEN = 15;
  WHITESPACE{: TSetOfChar} = [' ', TAB, CR, LF];
  COMMENTCHAR   = ['(', '{'];
  COMMENT_BEGIN_SET = ['{', '('];
  COMMENT_END_SET   = ['}', ')'];

  CRLF = CR + LF;

type
  TType_of_Symbol = ( symUnknown,
                      symEOS, 
                      symPROGRAM,
                      symSEGMENT,
                      symUNIT,
                      symPROCEDURE,
                      symFUNCTION,
                      symLeftParen, 
                      symColon, 
                      symSemiColon,
                      symRightParen,
                      symFORWARD,
                      symComma, 
                      symVAR, 
                      symStrRef, 
                      symIntRef,
                      symUnsNum, 
                      symIdentifier, 
                      symLeftBracket, 
                      symRightBracket, 
                      symUpArrow,
                      symAtSign,
                      symBEGIN,
                      symCONST,
                      symEqual,
                      symQuote,
                      symTYPE,
                      symEND,
                      symLABEL,
                      symElipsis,
                      symDash,
                      symUSES,
//                    symUSING,        // 10/11/2021 dhd - I have no idea why I did this
                      symINTERFACE,
                      symIMPLEMENTATION,
                      symDot,
                      symRealNumber);

  TProgSection = (psUnknown, psInterface, psImplementation);

  TSymbolSet = set of TType_of_Symbol;

  TSymbol_Type = record
    Type_of_Symbol : TType_of_Symbol;
    StringVal      : string;
    IntVal         : integer;
    RealVal        : single;
  end;

  TLocalParameter = packed record
    ParamAddr      : longword;   // This is in the current indexing scheme (Word_Memory or not)
    ParamOffset    : word;       // This is in the current indexing scheme (Word_Memory or not)
    ParamName      : string;
    ParamType      : TWatchType;
    UnitSize      : word;       // number of units (bytes OR words)
    ByteStreamLen  : word;

    ParamTypeName  : string[DEF_TYPENAME_LEN];
    RefdAddr       : longword;
    ParamComment   : string;
    ParamIsAVar    : boolean;
    ParamIsAPointer: boolean;
  end;

  TLocalParameters = array of TLocalParameter;

  ESyntaxError = class(Exception)
  public
    ErrIdx: integer;
  end;

  TTokenInfo = record
                 Name: string;
               end;

  TPositionInfo = record
                    LNB, LNW: word;  // Line number
                    SNB, SNW: word;  // segment number
                    PNB, PNW: word;  // procedure offset
                    NLB, NLW: word;  // nesting level
                    OB,  OW:  word;
                    SCB, SCW: word;  // source code line
                    WMB, WMW: word   // possible warning message ""
                  end;

var
  TokenInfoArray: Array[TType_of_Symbol] of TTokenInfo =
                    ({symUnknown}          (Name: 'Unknown'),
                     {symEOS}              (Name: ''),
                     {symProgram}          (Name: 'PROGRAM'),
                     {symSegment}          (Name: 'SEGMENT'),
                     {symUnit}             (Name: 'UNIT'),
                     {symProcedure}        (Name: 'PROCEDURE'),
                     {symFunction}         (Name: 'FUNCTION'),
                     {symLeftParen}        (Name: '('),
                     {symColon}            (Name: ':'),
                     {symSemiColon}        (Name: ';'),
                     {symRightParen}       (Name: ')'),
                     {symFORWARD}          (Name: 'FORWARD'),
                     {symComma}            (Name: ','),
                     {symVar}              (Name: 'VAR'),
                     {symStrRef}           (Name: ''),
                     {symIntRef}           (Name: ''),
                     {symUnsNum}           (Name: ''),
                     {symIdentifier}       (Name: ''),
                     {symLeftBracket}      (Name: '['),
                     {symRightBracket}     (Name: ']'),
                     {symUpArrow}          (Name: '^'),
                     {symAtSign}           (Name: '@'),
                     {symBEGIN}            (Name: 'BEGIN'),
                     {symCONST}            (Name: 'CONST'),
                     {symEqual}            (Name: '='),
                     {symQuote}            (Name: ''''),
                     {symTYPE}             (Name: 'TYPE'),
                     {symEND}              (Name: 'END'),
                     {symLABEL}            (Name: 'LABEL'),
                     {symElipsis}          (Name: '..'),
                     {symDash}             (Name: '-'),
                     {symUSES}             (Name: 'USES'),
//                   {symUSING}            (Name: 'USING'),
                     {symINTERFACE}        (Name: 'INTERFACE'),
                     {symIMPLEMENTATION}   (Name: 'IMPLEMENTATION'),
                     {symDot}              (Name: '.'),
                     {symRealNumber}       (Name: '')
                    );

function GetSymbolType(const s: string): TType_of_Symbol;
function IdentifierType(Ident: string): TWatchType;

function ParseParameterNames( const Source: string;
                               var LocalParameters: TLocalParameters;
                               var DataSize: word;
                               IsAParameterList: boolean = false;
                               SkipToSemiColonOnError: boolean = false;
                               Word_Memory: boolean = false): boolean;
function ProcessListingLine(VersionNr: TVersionNr;
                      const line: string;
                      var LineNumber: integer;
                      var SegNumber: integer;
                      var ProcNum: integer;
                      var Offset: integer;
                      var Source: string;
                      var DataSeg: boolean;
                      var NestingLevel: integer): boolean;
(*
procedure ScanListingFile(const FileName, ReportsPath: string; VersionNr: TVersionNr; var ErrorCount: integer);
procedure ScanListingFileForBestVersion( const FileName: string;
                                         ReportsPath: string;
                                         var VersionNr: TVersionNr;
                                         var ErrorCount: integer;
                                         VersionReporter: TVersionReporter);
*)
function RebuildParamList(const LocalParameters: TLocalParameters;
                          var RebuiltList: string;
                          IsAParameterList: boolean;
                          SepStr: string;
                          Word_Memory: boolean): boolean;

var
  ListingInfo: array[TVersionNr] of TPositionInfo = // column offsets and widths of compiler listing file
                (
                  ({vn_Unknown}),
                  ({vn_VersionI_4} LNB: 1; LNW:6;    // Line number
                                  SNB: 7; SNW:4;    // segment number
                                  PNB:11; PNW:5;    // procedure number
                                  NLB:17; NLW:1;     // nesting level
                                  OB: 18; OW: 6;    // ipc offset
                                  SCB:24; SCW:255;
                                  WMB: 7; WMW:15),  // WARNING MESSAGE UNTESTED ON VERSION I.4
                  ({vn_VersionI_5} LNB: 1; LNW:6;    // Line number
                                  SNB: 7; SNW:4;    // segment number
                                  PNB:11; PNW:5;    // procedure offset
                                  NLB:16; NLW:1;    // nesting level
                                  OB: 18; OW: 6;    // ipc offset
                                  SCB:24; SCW:255;
                                  WMB: 7; WMW:15),  // WARNING MESSAGE UNTESTED ON VERSION I.5
                  ({vn_VersionII} LNB: 1; LNW:6;    // Line number
                                  SNB: 7; SNW:4;    // segment number
                                  PNB:11; PNW:5;    // procedure offset
                                  NLB:17; NLW:1;    // nesting level
                                  OB: 18; OW: 6;    // ipc offset
                                  SCB:24; SCW:255;
                                  WMB: 7; WMW:15),  // WARNING MESSAGE UNTESTED ON VERSION II
                  ({Version-IV.22} LNB:1;  LNW:5;
                                  SNB:6;  SNW:4;
                                  PNB:10; PNW:5;
                                  NLB:16; NLW:2;
                                  OB: 17; OW :5;
                                  SCB:22; SCW:255;
                                  WMB: 7; WMW:15),
                  ({Version-IV.12} LNB:1;  LNW:5; // Untested
                                  SNB:6;  SNW:4;
                                  PNB:10; PNW:5;
                                  NLB:16; NLW:2;
                                  OB: 17; OW :5;
                                  SCB:22; SCW:255;
                                  WMB: 7; WMW:15)
                );

implementation

uses
  StrUtils;
const
  POINTERSIZE = 2;     // always in bytes
  WARNING_MESSAGE = 'commented '';''';

function IdentifierType(Ident: string): TWatchType;
begin
  Ident := RemoveBadChars( Ident, ['_']);

  for result := Succ(Low(TWatchType)) to High(TWatchType) do
    if SameText(Ident, WatchTypesTable[result].WatchName) then
      exit;
  result := wt_Unknown;
end;

function ParseParameterNames( const Source: string;
                               var LocalParameters: TLocalParameters;
                               var DataSize: word;
                               IsAParameterList: boolean = false;
                               SkipToSemiColonOnError: boolean = false;
                               Word_Memory: boolean = false): boolean;
const
  EOS = #0;

type
  TIdInfo = record
    Name: string;
    Comment: string;
  end;

  TIDLIst = array of TIDInfo;

  TVariableList = packed record    // A list of variables separated by commas
    NrItems: integer;              // There may be multiple variables
    IdList: TIDList;               // each variable has a name and may have a comment
    VarTypeName: string[DEF_TYPENAME_LEN];
    VarType: TWatchType;           // but they must all have the same type
    IsAVarParam: boolean;          // true if this is a VAR param
    IsAPointer: boolean;           // true if this is a pointer to a variable
    VarUnits: word;                // variable size (in bytes/words based on Word_Memory)
    VarByteStreamLen: word;        // number of bytes to be displayed
    VarOffset: word;               // Offset from address base (in bytes/word based on Word_Memory)
  end;

var
  Idx: Integer;
  ch: char;
  Symbol: TSymbol_Type;
  VariableList: TVariableList;
  Offset: integer;

  procedure BadExpression(const Msg: string; SkipToSemicolon: boolean = false);
    Forward;

  procedure NextCh;
  begin { TParser.NextCh }
    if Idx <= length(Source) then
      begin
        ch := Source[Idx];
        inc(Idx);
      end
    else
      ch := EOS;
  end;  { TParser.NextCh }

  // Name:    ReadComment
  // Returne: The comment that was read
  // Assumes: That the comment, if present, is all within "source"
  function ReadComment(ob, cb: string): string;
  var
    obx, cbx: integer;
    Comment: string;
  begin { ReadComment }
    if ob = Copy(Source, Idx-1, Length(ob)) then // matches opening bracket
      begin
        obx     := Idx - 1;
        cbx     := PosEx(cb, Source, obx + Length(ob)); // look for closing bracket
        if cbx <= 0 then
          begin
            BadExpression('Comment Close Missing', SkipToSemiColonOnError);
            Exit;
          end;
        Comment := Copy(Source, obx, cbx - obx + Length(ob) + Length(cb) - 1);
        Idx := cbx + Length(cb);
        NextCh;       // move past the closing bracket

        with VariableList do
          if NrItems > 0 then // assume the comment is connected to the previous identifier
            IdList[NrItems-1].Comment := Comment;

        result := Comment;
      end;
  end;  { ReadComment }

  procedure Skip_Blanks;
  begin { TParser.Skip_Blanks }
    repeat
      while Ch in WHITESPACE do
        NextCh;
      if ch in COMMENTCHAR then  // read comment
        if ch = '{' then
          ReadComment('{', '}')
        else if ch = '(' then
          ReadComment('(*', '*)');
    until not (ch in (WHITESPACE{+COMMENTCHAR}));
  end;  { TParser.Skip_Blanks }

  procedure InSymbol(var Symbol: TSymbol_type);

    function ReadString(CharSet: TSetOfChar): string;
    begin { TParser.ReadString }
      result := '';
      repeat
        result := result + ch;
        NextCh;
      until not (ch in CharSet);
    end;  { TParser.ReadString }

    procedure ReadNumber;
    begin { ReadNumber }
      with Symbol do
        begin
          StringVal := ReadString(HEX_DIGITS + ['$']);
          if Length(StringVal) > 0 then
            if StringVal[1] = '$' then
              IntVal := HexStrToWord(Copy(StringVal, 2, Length(StringVal)-1))
            else
              IntVal := StrToInt(StringVal)
          else
            IntVal := 0;
          Type_of_Symbol := symUnsNum;
        end;
    end;  { ReadNumber }

  begin { InSymbol }
    with Symbol do
      begin
        StringVal   := '';
        IntVal      := 0;
        Type_of_Symbol := symUnknown;
        Skip_Blanks;
        if ch = EOS then
          Type_of_Symbol := symEOS else
        if ch = '$' then
          ReadNumber else
        if ch in NUMERIC then
          ReadNumber else
        if ch in ANY_ALPHA then
          begin
            StringVal      := ReadString(ANY_ALPHA+numeric+['_']);
            Type_of_Symbol := GetSymbolType(StringVal);
            if Type_of_Symbol = symUnknown then
              Type_of_Symbol := symIdentifier;
          end else
        if ch = '.' then
          begin
            NextCh;
            if ch = '.' then // elipsis ".."
              begin
                Type_of_Symbol := symElipsis;
                NextCh;
              end
          end else
        if GetSymbolType(ch) <> symUnknown then
          begin
            Type_of_symbol := GetSymbolType(ch);
            NextCh;
          end else
(*
        if ch = '[' then
          begin
            StringVal := '[';
            Type_of_Symbol := symLeftBracket;
            NextCh;
          end else
        if ch = ']' then
          begin
            StringVal := ']';
            Type_of_Symbol := symRightBracket;
            NextCh;
          end else
        if ch = ',' then
          begin
            Type_Of_Symbol := symComma;
            StringVal := ',';
            NextCh;
          end else
        if ch = ':' then
          begin
            Type_Of_Symbol := symColon;
            NextCh;
          end else
        if ch = '^' then
          begin
            Type_Of_Symbol := symUpArrow;
            NextCh;
          end else
        if ch = ';' then
          begin
            Type_Of_Symbol := symSemiColon;
            NextCh;
          end else
        if ch = '@' then
          begin
            Type_Of_Symbol := symAtSign;
            NextCh;
          end else
*)
        if not (ch in [CR, LF, TAB, '{']) then
          BadExpression('Unexpected character', SkipToSemiColonOnError);

        Skip_Blanks;
      end;
  end;  { InSymbol }

  procedure BadExpression(const Msg: string; SkipToSemicolon: boolean = false);
  var
    e: ESyntaxError;
    Comment: string;
  begin { BadExpression }
    Comment := Format('%s in line "%s" @ Idx = %d, Symbol = "%s"',
                                    [Msg,
                                     RemoveBadChars(Copy(Source, Idx-1, 10), ['{', '}']),
                                     Idx,
                                     TokenInfoArray[Symbol.Type_of_Symbol].Name]);
    if not SkipToSemicolon then
      begin
        E := ESyntaxError.Create(Comment);
        E.ErrIdx := Idx;
        raise E;
      end
    else
      begin
        NextCh;
        while not (Symbol.Type_of_Symbol in [symSemiColon, symEOS]) do
          InSymbol(Symbol);
        InSymbol(Symbol);

        with VariableList do
          if NrItems > 0 then // assume the error is connected to the previous identifier
            IdList[NrItems-1].Comment := Comment;
      end;
  end;  { BadExpression }

  function IdentifierSize(Ident: string; Word_Memory: boolean): word;
  var
    wt: TWatchType;
    dummy: word;
  begin
    result := 0;
    Ident  := RemoveBadChars( Ident, ['_']);

    for wt := Succ(Low(TWatchType)) to High(TWatchType) do
      if SameText(Ident, WatchTypesTable[wt].WatchName) then
        begin
          GetWatchTypeSize(wt, Word_Memory, result, dummy);
          Exit;
        end;
  end;

  procedure ParseDataSize;
  begin
    InSymbol(Symbol);
    if Symbol.type_of_Symbol = symIdentifier then
      begin
        if SameText(Symbol.StringVal, 'DATASIZE') then
          begin
            InSymbol(Symbol);
            if Symbol.Type_of_Symbol = symColon then
              begin
                InSymbol(Symbol);
                if Symbol.Type_of_Symbol = symUnsNum then
                  begin
                    DataSize := Symbol.IntVal;
                    InSymbol(Symbol);
                  end
                else
                  BadExpression('Integer expected', SkipToSemiColonOnError)
              end
            else
              BadExpression('Colon expected', SkipToSemiColonOnError)
          end
        else
          BadExpression('Unexpected ID', SkipToSemiColonOnError);

        if Symbol.Type_of_Symbol = symRightBracket then
          InSymbol(Symbol)
        else
          BadExpression('Right bracket expected', SkipToSemiColonOnError)
      end
    else
      BadExpression('Unexpected symbol', SkipToSemiColonOnError);
  end;


  // Name:     ParseVariableList
  // Function: Parse the variables linked to a single type (separated by commas)
  //
  procedure ParseVariableList(var VariableList: TVariableList; Word_Memory: boolean);
  label
    999;
  begin { ParseVariableList }
    InSymbol(Symbol);
    with VariableList do
      begin
        NrItems  := 0;
        SetLength(IdList, NrItems);
        VarType      := wt_Unknown;
        VarUnits     := 0;
        VarByteStreamLen := 0;
        IsAVarParam  := false;
        IsAPointer   := false;
        VarOffset    := 0;
        VarTypeName  := 'Unknown';

        if Symbol.Type_of_Symbol <> symEos then
          repeat
            repeat
              if Symbol.Type_of_Symbol = symLeftBracket then   // [DATASIZE:nnn]
                ParseDataSize;
              if Symbol.Type_of_Symbol = symVar then
                begin
                  IsAVarParam := true;
                  InSymbol(Symbol);
                end;
              if Symbol.Type_of_Symbol = symIdentifier then
                begin
                  NrItems := NrItems + 1;
                  SetLength(IdList, NrItems);
                  IdList[NrItems-1].Name := Symbol.StringVal;
                  InSymbol(Symbol);
                end;
              if Symbol.Type_of_Symbol = symComma then
                InSymbol(Symbol)
              else
                if not (Symbol.Type_of_Symbol in [symComma, symColon, symEOS, symPROCEDURE, symFUNCTION, symSEGMENT]) then
                  begin
                    BadExpression('Comma or Colon expected', SkipToSemiColonOnError);
                    goto 999;            // We're in over our heads
                  end;
            until Symbol.Type_of_Symbol in [symColon, symEOS, symPROCEDURE, symFUNCTION, symSEGMENT];

            if Symbol.Type_of_Symbol = symColon then
              begin
                InSymbol(Symbol);
                if Symbol.Type_of_Symbol = symUpArrow then
                  begin
                    VariableList.IsAPointer := true;
                    if Word_Memory then
                      VariableList.VarUnits    := 1   // for now, assume that all pointers require 1 word
                    else
                      VariableList.VarUnits    := 2;   // for now, assume that all pointers require 2 bytes

                    InSymbol(Symbol);
                  end;
                if Symbol.Type_of_Symbol = symIdentifier then
                  with VariableList do
                    begin
                      VarType     := IdentifierType(Symbol.StringVal);
                      VarTypeName := Symbol.StringVal;
//                    VarUnits     := GetWatchTypeSize(VarType, Word_Memory);
                      GetWatchTypeSize(VarType, Word_Memory, VarUnits, VarByteStreamLen);
                      InSymbol(Symbol);
                    end;
                if Symbol.Type_of_Symbol = symLeftBracket then
                  begin
                    InSymbol(Symbol);
                    if Symbol.Type_of_Symbol in [symUnsNum, symIdentifier] then
                      begin
                        with VariableList do
                          begin
                            if Symbol.Type_of_Symbol = symUnsNum then
                              case VarType of
                                wt_char:
                                  VarUnits := Symbol.IntVal;
                                wt_String:
                                  VarUnits := Symbol.IntVal + 1;
                                wt_HexBytes:
                                  VarUnits := Symbol.IntVal;
                                wt_MultiWordCharSet,
                                wt_MultiWordSet:
                                  VarUnits := Symbol.IntVal;  // number of words in a stored set
                                wt_Real:
                                  VarUnits := IdentifierSize(VarTypeName, Word_Memory);
                                wt_Longinteger:
                                  VarUnits := Symbol.IntVal; // number of words in a stored long integer
                                else
                                  VarUnits := Symbol.IntVal;  // implement something like INTEGER[10]
                              end
                            else // symUnsNum
                              VarUnits := Symbol.IntVal;

                          if Word_Memory then
                            VarUnits := (VarUnits+1) shr 1   // div 2: convert variable[num] from bytes to words (rounding up)
                          else
                            if Odd(VarUnits) then       // byte indexing: force to a word boundary
                              VarUnits := VarUnits + 1;
                          end;
                        InSymbol(Symbol);

                        if Symbol.Type_of_Symbol = symElipsis then
                          begin
                            InSymbol(Symbol);
                            if Symbol.Type_of_Symbol = symIdentifier then
                              InSymbol(Symbol);
                          end;

                        if Symbol.Type_of_Symbol <> symRightBracket then
                          BadExpression('Right ] expected', SkipToSemiColonOnError);
                        InSymbol(Symbol);
                      end
                    else
                      BadExpression('Unexpected Symbol', SkipToSemiColonOnError)
                  end;

                if Symbol.Type_of_Symbol = symAtSign then
                  begin
                    InSymbol(Symbol);
                    if Symbol.Type_of_Symbol = symUnsNum then
                      begin
                        VarOffset := Symbol.IntVal;
                        InSymbol(Symbol);
                      end;
                  end;
              end;
            Skip_Blanks;
999:
          until Symbol.Type_of_Symbol in [symSemiColon, symEOS, symPROCEDURE, symFUNCTION, symSEGMENT];
    end;
  end;  { ParseVariableList }

  // Process a single list of comma separated variables
  procedure ProcessVariableList( const VariableList: TVariableList;
                                 IsAParameterList: boolean = true;
                                 WordMemory: boolean = false);
  var
    i: integer;
    Idx, LastItem: integer;
    aPointerSize: word;
    // This is necessary because the parameters in a comma separated list
    // are allocated memory in order from last to first.

    procedure ProcessOneItem(ItemNr: integer);
    begin { ProcessOneItem }
      with LocalParameters[Idx] do
        begin
          if WordMemory then
            ParamOffset := VariableList.VarOffset
          else
            ParamOffset := VariableList.VarOffset * 2;

          if ParamOffset > 0 then    // User is forcing variable offset via @Offset
            Offset := ParamOffset;

          ParamName       := VariableList.IdList[ItemNr].Name;
          ParamType       := VariableList.VarType;
          ParamTypeName   := VariableList.VarTypeName;
          UnitSize       := VariableList.VarUnits;
          ByteStreamLen   := VariableList.VarByteStreamLen;
          ParamIsAVar     := VariableList.IsAVarParam;
          ParamIsAPointer := VariableList.IsAPointer;

          with VariableList.IdList[ItemNr] do
            if (not IsAParameterList) and (Comment <> '') then
              ParamComment    := Format('{ %s }', [Comment]);

          if ParamIsAPointer or ParamIsAVar then
            UnitSize := aPointerSize;

//        if ParamIsAPointer or ParamIsAVar then
//          OffSet := Offset + aPointerSize
//        else
            Offset := OffSet + UnitSize;

          if Word_Memory and odd(Offset) then
            Offset := Offset + 1;

          Idx := Idx + 1;
        end;
    end;  { ProcessOneItem }

  begin { ProcessVariableList }
    Idx := Length(LocalParameters);  // next available slot
    SetLength(LocalParameters, Length(LocalParameters) + VariableList.NrItems);
    LastItem := VariableList.NrItems-1;

    aPointerSize := IIF(Word_Memory, 1, 2);

    for i := LastItem downto 0 do
      ProcessOneItem(i)
  end;  { ProcessVariableList }

begin { ParseParameterNames }
  SetLength(LocalParameters, 0);    // reset
  FillChar(VariableList, SizeOf(VariableList), 0);

  Symbol.Type_of_Symbol := symUnknown;
  idx := 1;
  NextCh;
  Skip_Blanks;

  Offset := IIF(Word_Memory, 1, 2);
  while Symbol.Type_of_Symbol <>  symEOS do
    begin
      ParseVariableList(VariableList, Word_Memory);
      ProcessVariableList(VariableList, IsAParameterList, Word_Memory);
    end;
  result := true;
end;  { ParseParameterNames }

function ProcessListingLine(VersionNr: TVersionNr;
                      const line: string;
                      var LineNumber: integer;
                      var SegNumber: integer;
                      var ProcNum: integer;
                      var Offset: integer;
                      var Source: string;
                      var DataSeg: boolean;
                      var NestingLevel: integer): boolean;
var
  LineNumberStr, SegNumberStr, ProcNumStr, OffsetStr, NestLevelStr: string;
  ReadItAnyWay: boolean;
  Source0: string;
begin
  with ListingInfo[VersionNr] do
  try
    LineNumberStr := Copy(Line, LNB, LNW);
    LineNumber    := StrToIntSafe(LineNumberStr);  // do StrToIntSafe to avoid annoying exceptions

    SegNumberStr  := Copy(Line, SNB, SNW);
    SegNumber     := StrToIntSafe(SegNumberStr);

    ProcNumStr    := Copy(Line, PNB, PNW);
    ProcNum       := StrToIntSafe(ProcNumStr);;

    NestLevelStr  := UpperCase(Trim(Copy(Line, NLB, NLW)));
    DataSeg       := NestLevelStr = 'D';
    if not DataSeg then
      begin
        NestingLevel := StrToIntSafe(NestLevelStr);
{
        if (NestingLevel = 9) and (PrevNestingLevel = 0) then
          NestingLevel := NestingLevel +10 else
        if (NestingLevel = 9) and (PrevNestingLevel >= 10) then
          NestingLevel := NestingLevel + 10;
        PrevNestingLevel := NestingLevel;
}
      end
    else
      NestingLevel := -1;

    OffsetStr     := Copy(Line, OB, OW);
    Offset        := StrToIntSafe(OffsetStr);

    Source0       := Copy(Line, SCB, SCW);
    Source        := TabsToSpaces(Source0);

    ReadItAnyWay  := (Copy(Line, WMB, Length(WARNING_MESSAGE)) = WARNING_MESSAGE)
                                          // Commented ';' but we may need line anyway because UCSD compiler
                          or              // does not allow procedure parameters to be re-specified following
                                          // a FORWARD definition
                     ((SegNumber > 0) and (LineNumber > 0) and (not Empty(ProcNumStr))); // Line containing the "end." is peculiar
    result        := (ProcNum <> 0) or DataSeg or ReadItAnyway;


  except
    on e:Exception do
      result := false;
  end;
end;

function RebuildParamList( const LocalParameters: TLocalParameters;
                           var RebuiltList: string;
                           IsAParameterList: boolean;
                           SepStr: string;
                           Word_Memory: boolean): boolean;
var
  idx: integer;
  UnitCount: word;         // number of bytes OR words
  ByteStreamCount: word;   // number of bytes in the Ascii string
  Line, Comment, IndirectStr, VarStr, TypeNameAndSize, IndentStr: string;

  function IndentSpaces(n: integer): string;
  begin { IndentSpaces }
    if not IsAParameterList then
      result := Padr('', n)
    else
      result := '';
  end;   { IndentSpaces }

begin { RebuildParamList }
  try
    RebuiltList := '';
    for idx := 0 to Length(LocalParameters)-1 do
      with LocalParameters[idx] do
        begin
          Comment := ParamComment;

          VarStr      := '';
          IndirectStr := '';

          if IsAParameterList then
            begin
              IndentStr := '';
              if ParamIsAVar then
                VarStr      := 'VAR '
            end
          else  // Is a list of local/global variables
            begin
              IndentStr   := Padr('', 12);
              if ParamIsAVar then
                IndirectStr := '^';
            end;

          TypeNameAndSize := '';
          GetWatchTypeSize(ParamType, Word_Memory, UnitCount, ByteStreamCount);
          if (UnitSize <> ByteStreamCount) then
            TypeNameAndSize := Format('%s[%d]', [ParamTypeName, ByteStreamCount])
          else
            TypeNameAndSize := ParamTypeName;

          Line := Format('%s%s%-15s : %s%s%s;', [IndentStr, VarStr, ParamName, IndirectStr, TypeNameAndSize, Comment ]);

          if RebuiltList = '' then
            RebuiltList := SepStr + Line
          else
            RebuiltList := RebuiltList + SepStr + Line;
        end;
    result := true;
  except
    result := false;
  end;
end;  { RebuildParamList }

(*
function ProcessListingLine(VersionNr: TVersionNr;
                      const line: string;
                      var LineNumber: integer;
                      var SegNumber: integer;
                      var ProcNum: integer;
                      var Offset: integer;
                      var Source: string;
                      var DataSeg: boolean;
                      var NestingLevel: integer): boolean;
var
  LineNumberStr, SegNumberStr, ProcNumStr, OffsetStr, NestLevelStr: string;
  ReadItAnyWay: boolean;
  Source0: string;
begin
  with ListingInfo[VersionNr] do
  try
    LineNumberStr := Copy(Line, LNB, LNW);
    LineNumber    := StrToIntSafe(LineNumberStr);  // do StrToIntSafe to avoid annoying exceptions

    SegNumberStr  := Copy(Line, SNB, SNW);
    SegNumber     := StrToIntSafe(SegNumberStr);

    ProcNumStr    := Copy(Line, PNB, PNW);
    ProcNum       := StrToIntSafe(ProcNumStr);;

    NestLevelStr  := UpperCase(Trim(Copy(Line, NLB, NLW)));
    DataSeg       := NestLevelStr = 'D';
    if not DataSeg then
      begin
        NestingLevel := StrToIntSafe(NestLevelStr);
{
        if (NestingLevel = 9) and (PrevNestingLevel = 0) then
          NestingLevel := NestingLevel +10 else
        if (NestingLevel = 9) and (PrevNestingLevel >= 10) then
          NestingLevel := NestingLevel + 10;
        PrevNestingLevel := NestingLevel;
}
      end
    else
      NestingLevel := -1;

    OffsetStr     := Copy(Line, OB, OW);
    Offset        := StrToIntSafe(OffsetStr);

    Source0       := Copy(Line, SCB, SCW);
    Source        := TabsToSpaces(Source0);

    ReadItAnyWay  := (Copy(Line, WMB, Length(WARNING_MESSAGE)) = WARNING_MESSAGE)
                                          // Commented ';' but we may need line anyway because UCSD compiler
                          or              // does not allow procedure parameters to be re-specified following
                                          // a FORWARD definition
                     ((SegNumber > 0) and (LineNumber > 0) and (not Empty(ProcNumStr))); // Line containing the "end." is peculiar
    result        := (ProcNum <> 0) or DataSeg or ReadItAnyway;


  except
    on e:Exception do
      result := false;
  end;
end;
*)

function GetSymbolType(const s: string): TType_of_Symbol;
(* ttProgram, ttSegment, ttUnit, ttIdent, ttProcedure, ttFunction *)
var
  tt: TType_of_Symbol;
begin
  result := symUnknown;
  for tt := Succ(Low(TType_of_Symbol)) to high(TType_of_Symbol) do
    if SameText(s, TokenInfoArray[tt].Name) then
      begin
        result := tt;
        exit;
      end;
  if IsIdentifier(s) then
    result := symIdentifier;
end;

end.
