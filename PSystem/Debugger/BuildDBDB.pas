unit BuildDBDB;
(*
* BuildDbDb isn’t doing a good job of parsing parameters for the DB. Including “var” where it should not.
  Also putting parameters in the wrong order (at least for version I.5 and/or II).
  In version I.5 and/or II, parameters are passed right-to-left
* BuildDBDB:
  { PARAMETERS }
  VAR SRC         : STRING[2]; // should not have the VAR?
  VAR DEST        : STRING[2];
* is ordering the local variables incorrectly (IN LOCALVARIABLES?) (Version I.5 and/or II, for sure)
  The word “VAR” is showing up in the parameter list (doing “var i: integer” rather than “i: ^integer”) IN LOCALVARIABLES
  Putting blanks in front of the variables listing IN LOCALVARIABLES
  Functions do not display the RESULT type
  When building the list to be displayed by Local/Global variables, the variables are not in the right order
* BuildDbDb not properly handling the “RESULT” field of a function
* BuildDbDb does not properly process VAR in procedure parameters
* BuildDbDb does not handle INTERFACE or IMPLEMENTATION
*)
(*
  MORE NOTES:
       In version 2, the passed parameters come first, i.e. is low memory. This is the order:
          function results
          parameters
          local variables
          hidden variables
*)
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, UCSDGlob, ListingUtils, Watch_Decl,
  ADOX_TLB, ADODB, MyTables_Decl, OleServer, DB,
  FilerTables, PsysUnit, DBDBParameters, pCodeDecoderUnit, pCodeDecoderII,
  pSysVolumes, OverWrite_Decl, YesNoDontAskAgain,
  OpsTables, Interp_Decl, ListingUtilitiesObject, BuildDbDb_Decl,
{$IfDef debugging}
  DebuggerSettingsUnit,
{$EndIf debugging}
  Interp_Const;

{$I BIOSCONST.INC}
  
type
  BytePtr = ^Byte;
  WordPtr = ^Word;

  TfrmBuildDBDBMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    miNewDatabase: TMenuItem;
    Functions1: TMenuItem;
    BuildDatabasefromListing1: TMenuItem;
    ParseandList1: TMenuItem;
    ADOConnection1: TADOConnection;
    Memo1: TMemo;
    lblStatus: TLabel;
    MapSegmentsinCodeFile1: TMenuItem;
    BuildUglySourceFromListing1: TMenuItem;
    ScanListingforVersionNumber1: TMenuItem;
    CleanupcompilerlistingsenttoCONSOLE1: TMenuItem;
    QDCleanupofProcedureNames1: TMenuItem;
//  procedure BtnBrowse1Click(Sender: TObject);
//  procedure btnBeginClick(Sender: TObject);
    procedure btnBrowseDBClick(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure ParseandList1Click(Sender: TObject);
    procedure BuildDatabasefromListing1Click(Sender: TObject);
    procedure miNewDatabaseClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure MapSegmentsinCodeFile1Click(Sender: TObject);
    procedure BuildUglySourceFromListing1Click(Sender: TObject);
    procedure ScanListingforVersionNumber1Click(Sender: TObject);
    procedure CleanupcompilerlistingsenttoCONSOLE1Click(Sender: TObject);
    procedure QDCleanupofProcedureNames1Click(Sender: TObject);
  private
    { Private declarations }
    fIdx                     : integer;
    fIpc                     : word;
    fInputFile, fOutputFile  : TextFile;
    fLineNumber              : integer;
    fProcNum                 : integer;
    fRootProcedure           : TProcedureInfo;
    fSegmentNumber           : integer;
    fSegmentInfoList         : TSegmentInfoList;
    fVolFilePath             : string;
    fVolume                  : TVolume;
    fOpsTable                : TCustomOpsTable;
//  SegmentInfoTable         : TSegmentInfoTable;
    pCodesProcTable          : TpCodesProcTable;
    VolumeInfoTable          : TVolumeInfoTable;
    CodeFileInfoTable        : TCodeFileInfoTable;
    NrVolRecsAdded           : integer;
    NrVolRecsEdited          : integer;
    NrCodeRecsAdded          : integer;
    NrCodeRecsEdited         : integer;
    NrProcRecsAdded          : integer;
    NrProcRecsEdited         : integer;
    frmSegOk                 : TfrmYesNoDontAskAgain;
    frmProcOk                : TfrmYesNoDontAskAgain;
    frmCodeFileOk            : TfrmYesNoDontAskAgain;

    // Decoder stuff
    fDecodedLines    : TStringList;
    fpCodeDecoder    : TpCodeDecoder;
    fpCodeDecoderII  : TpCodeDecoderII;
    fDebuggerSettings: TDebuggerSettings;
//  fBlobStream      : TStream;
    fBuffer          : pchar;
    fCodeAddr        : longword;

    function ProcessFile(VersionNr: TVersionNr; const InFileName: string): integer;
    procedure UpdateProcInfo( var ProcedureInfo: TProcedureInfo;
                              SegNameFull, ProcedureNameFull: string;
                              aSegmentType: TType_of_Symbol;
                              SegNumber: integer);
    function PrintResults(const OutputFileName: string): integer;
//  procedure CreateDatabase(var FileName: string; DBVersion: TDBVersion);
    procedure MyUpdateStatus(const Msg: string);
    procedure MyUpdateStatusFmt(const Msg: string; args: array of const);
    procedure MapSegmentsInCodeFile( Volume: TVolume;
                                     const pSysFileName: string;
                                     OverWriteOptions: TOverWriteOptions;
                                     VersionNr: TVersionNr);
    procedure AddLine(const Line: string);
    procedure AddLineSeparator(OpCode: word);
    function GetByteAt(IPC: longword): byte;
    function GetWordAt(IPC: longword): word;
    procedure BuildUglySourceFromListing(const aListingFileName,
      aOutputFileName: string);
    procedure NewDatabase(DatabaseFileName: string);
    procedure VersionReporter(const line: string);
    function ProcedureIdentifier(const SegName: string; ProcedureInfo: TProcedureInfo): string;
    function GetBasedWord(Base, Offset: word): word;
    function GetBasedByte(Base, Offset: word): byte;
//  function GetCPOffset: word;
  public
    { Public declarations }
    procedure BuildDataBaseFromListing(const aListingFileName,
                                             aDataBaseFileName,
                                             aOutputFileName: string);
    Constructor Create(aOwner: TComponent; TheDebuggerSettings: TDebuggerSettings); reintroduce;
    Destructor Destroy; override;
  end;

var
  frmBuildDBDBMain: TfrmBuildDBDBMain;

implementation

uses MyUtils, StrUtils, MyTables,
  uGetString, segmap, DbDbUtils, FilerSettingsUnit, pSysExceptions,
  ConfirmDBUpdate, pSys_Const,
  pSysVolumesNonStandard, FileNames;

{$R *.dfm}

const
  SEGMENTHEADS = [symSEGMENT, SYMPROGRAM, symUNIT];
  PROCHEADS    = [symFUNCTION, symPROCEDURE];
  UNITHEADS    = [symPROGRAM, symUNIT];

procedure TfrmBuildDBDBMain.UpdateProcInfo( var ProcedureInfo: TProcedureInfo;
                                                SegNameFull, ProcedureNameFull: string;
                                                aSegmentType: TType_of_Symbol;
                                                SegNumber: integer);
var
  IdxS, IdxP: integer;
  SegmentInfo: TSegmentInfo;
  SegName, ProcedureName: TAlpha8;
begin
  // Be sure to follow the naming rules
  SegName       := UCSDName(SegNameFull);
  ProcedureName := UCSDName(ProcedureNameFull);

  // Do we already know about this segment?
  IdxS := fSegmentInfoList.IndexOf(SegName);
  if IdxS < 0 then // No. Add it.
    begin
      SegmentInfo             := TSegmentInfo.Create;
      SegmentInfo.SegmentNumber := SegNumber;
      SegmentInfo.SegmentType := aSegmentType;
      IdxS                    := fSegmentInfoList.AddObject(SegName, SegmentInfo);
    end;

  // Do we already know about this procedure in this segment?
  SegmentInfo := fSegmentInfoList.Objects[IdxS] as TSegmentInfo;
  with SegmentInfo do
    begin
      IdxP := Procedures.IndexOf(ProcedureName);
      if IdxP < 0 then   // No. Add the procedure
        begin
          ProcedureInfo := TProcedureInfo.Create;
          ProcedureInfo.xSegmentName      := SegName;
          ProcedureInfo.SegmentNameFull   := SegNameFull;
          ProcedureInfo.ProcedureName     := ProcedureName;
          ProcedureInfo.ProcedureNumber   := fProcNum;
          ProcedureInfo.ProcedureNameFull := ProcedureNameFull;
          ProcedureInfo.SegmentNumber     := SegNumber;

          Procedures.AddObject(ProcedureName, ProcedureInfo);
          ProcedureInfo.SegmentType       := aSegmentType;
        end
      else
        // Return the pointer to the procedures info
        ProcedureInfo := TProcedureInfo(Procedures.Objects[IdxP]);
    end;

end;

function TfrmBuildDBDBMain.ProcessFile(VersionNr: TVersionNr; const InFileName: string): integer;
var
  Line: string;
//ProcNum,
  Offset, LastOffset, NestingLevel, PrevNestingLevel, CalculatedLevel: integer;
  Source: string;
  Token{, Temp}: TSymbol_Type;
  DataSeg: boolean;
  ProgSection: TProgSection;
//SymbolType: TType_of_Symbol;
(*
  SymbolType: TSymbolType;
DATASECTION:
  469   2    9:d    2       keyvalu: key;
CODESECTION:
  474   2    9:1    9    idtype := othersym;
-----                          line number
     ----                      segment number
         -----:                procedure number
              :--              nesting level number
                 ----          offset within procedure
                     --------> procedure source line
*)

  // NOTE: The NestingLevel shown in a compiler listing is always modulo 10
  //       -- i.e., always 0..9 regardless of the actual nesting level.
  //       This function attempts to guess what the actual nesting level really is.
  // Parameters:
  //       NestingLevel - the level as displayed in the compiler listing
  //       PrevNestingLevel - the previous value for NestingLevel
  // Result:
  //       The calculated (best guess) for the "actual" nesting level

  function CalculateLevel(NestingLevel, PrevNestingLevel, CalculatedLevel: integer): integer;
  var
    Dif: integer;

    function ItIs(Dif: integer): boolean;
    begin
      result := NestingLevel = ((CalculatedLevel+Dif) mod 10);
    end;

  begin { CalculateLevel }
    Dif := 0; result := -1;
    repeat
      if ItIs(Dif) then
        result := CalculatedLevel + Dif else
      if ItIs(-Dif) then
        result := CalculatedLevel - Dif;
      Dif := Dif + 1;
    until (Dif = 5) or (Result <> -1);

    if result = -1 then      // 
      result := NestingLevel;
  end;  { CalculateLevel }

  procedure ReadLine(var Source: string);
  var
    OK: boolean;
  begin
    repeat
      ReadLn(fInputFile, Line);
      OK := ProcessListingLine(VersionNr, Line, fLineNumber, fSegmentNumber, fProcNum, Offset, Source, DataSeg, NestingLevel);
      CalculatedLevel  := CalculateLevel(NestingLevel, PrevNestingLevel, CalculatedLevel);
      PrevNestingLevel := NestingLevel;
    until OK or Eof(fInputFile);
    Inc(Result);
    fIdx := 1;
  end;

  function SkipComment(const ob, cb: string): string;
  var
    obx, cbx: integer;
  begin
    obx    := fIdx;
    cbx    := PosEx(cb, Source, fIdx + Length(cb));
    if (obx > 0) and (cbx > 0) then  // single line comment
      begin
        result := Copy(Source, obx, cbx-obx+Length(cb));
        fIdx   := cbx + Length(cb);
      end
    else       // maybe multi-line comment
      repeat
        cbx := PosEx(cb, Source, fIdx + Length(cb));

        if cbx = 0 then
          begin
            fIdx  := 1;
            result := result + Copy(Source, fIdx, MAXINT);
            ReadLine(Source);
          end
        else { cbx > 0, the last line of a multi-line comment }
          begin
            result := result + Copy(Source, 1, cbx+length(cb));
            fIdx   := cbx + Length(cb);
          end;
      until (cbx > 0) or Eof(fInputFile);
  end;

  procedure SkipBlanks;
  var
    Comment : string;
  begin
    if fIdx <= Length(Source) then
      repeat
        if Source[fIdx] in WHITESPACE then
          repeat
            Inc(fIdx);
          until (fIdx > Length(Source)) or (not (Source[fIdx] in WHITESPACE));
        if (fIdx <= Length(Source)) and (Source[fIdx] in COMMENT_BEGIN_SET) then
          if Source[fIdx] = '{' then
            Comment := SkipComment('{', '}') else
          if Copy(Source, fIdx, 2) = '(*' then
            Comment := SkipComment('(*', '*)');
      until (fIdx > Length(Source)) or (not (Source[fIdx] in WHITESPACE));
  end;

  procedure InSymbol(var Symbol: TSymbol_Type);
  var
    Len: integer;
    temp: string[255];
  begin { InSymbol }
    Len := 0;
    Symbol.StringVal := '';
    if (fIdx <= Length(Source)) then
      case Source[fIdx] of
       '(', ':', ')', ';', '[', ']', '^', '@', '=', ',', '''', '-', '.':
         begin
           Symbol.StringVal := Source[fIdx];
           Symbol.Type_of_Symbol := GetSymbolType(Symbol.StringVal);
           inc(fIdx);
         end
      else
        if (Source[fIdx] in ANY_ALPHA) then
          begin
            SetLength(temp, 255);
            Inc(len);
            Temp[Len] := Source[fIdx];
            inc(fIdx);
            while (fIdx <= Length(Source)) and (Source[fIdx] in IDENT_CHARS) do
              begin
                Inc(Len);
                Temp[Len] := Source[fIdx];
                Inc(fIdx);
              end;
            SetLength(temp, Len);
            Symbol.StringVal := temp;
            Symbol.Type_of_Symbol := GetSymbolType(Symbol.StringVal);
          end else
        if (Source[fIdx] in ['0'..'9']) then
          begin
            SetLength(temp, 255);
            Inc(len);
            Temp[Len] := Source[fIdx];
            inc(fIdx);
            while (fIdx <= Length(Source)) and (Source[fIdx] in ['0'..'9']) do
              begin
                Inc(Len);
                Temp[Len] := Source[fIdx];
                Inc(fIdx);
              end;
            SetLength(temp, Len);
            Symbol.StringVal := Temp;
            if {(Source[fIdx] = '.') or} (StrToFloat(Temp) > 32767) then
              begin
                Symbol.RealVal := StrToFloat(Temp);
                Symbol.Type_of_Symbol := symRealNumber;
                while Source[fIdx] in ['0'..'9', '.'] do // Yes. I realize that this will aaccept bad real numbers
                  Inc(fIdx);
              end
            else
              begin
                Symbol.IntVal    := StrToInt(Temp);
                Symbol.Type_of_Symbol := symUnsNum;
              end;
          end
        else
          begin
            Symbol.Type_of_Symbol := symUnknown;
            Inc(fIdx);
          end;
      end
    else
     Symbol.Type_of_Symbol := symEos;
  end;  { InSymbol }

  function GetToken: TSymbol_Type;
  begin { GetToken }
    repeat
      SkipBlanks;
      InSymbol(result);
      if result.Type_of_Symbol = symEos then
        ReadLine(Source);
    until not (result.Type_of_Symbol in [symEos, symUnknown]) or Eof(fInputFile);
  end;  { GetToken }

  procedure Expected(msg: string);
  begin
    writeln(fOutputFile, 'At line ', fLineNumber, ' ', Msg, ' was expected');
    // we're in a mess. Look for the next semicolon and hope for the best
    repeat
      Token := GetToken;
    until (Token.Type_of_Symbol = symSemiColon) or Eof(fInputFile);
    Token := GetToken;
  end;

  function ProcedureNameFound(var ParentProcedureInfo: TProcedureInfo; var ProcedureInfo: TProcedureInfo): boolean;
  var
    SType: TType_of_Symbol;
    aName: string;
  begin { ProcedureNameFound }
    result := false;
    if Token.Type_of_Symbol in PROCHEADS then
      begin
        SType := Token.Type_of_Symbol;
        Token := GetToken;
        if Token.Type_of_Symbol = symIdentifier then
          begin
            if Assigned(ParentProcedureInfo) then
              UpdateProcInfo(ProcedureInfo, ParentProcedureInfo.xSegmentName, Token.StringVal, SType, fSegmentNumber);
            result := true;
          end;
      end else
    if Token.Type_of_Symbol = SYMSEGMENT then  // e.g. "SEGMENT PROCEDURE NAME" or "SEGMENT FUNCTION NAME"
      begin
        Token := GetToken;
        if Token.Type_of_Symbol in PROCHEADS then
          begin
            Token := GetToken;
            if Token.Type_of_Symbol = symIdentifier then
              begin
                UpdateProcInfo(ProcedureInfo, Token.StringVal, Token.StringVal, symSegment, fSegmentNumber);
                result := true;
              end
            else
              begin
                Expected('PROCEDURE or FUNCTION name');
                Token := GetToken;
              end;
          end
      end else
    if Token.Type_of_Symbol in UNITHEADS then
      begin
        SType := Token.Type_of_Symbol;
        Token := GetToken;
        if Token.Type_of_Symbol = symIdentifier then
          begin
            aName := UCSDName(Token.StringVal);
            UpdateProcInfo(ProcedureInfo, aName, aName, SType, fSegmentNumber);
            ParentProcedureInfo := ProcedureInfo;  // DEBUGGING 4/29/2021 - Trying to set fRootProcedure
            result := true;
          end
      end
    else
      Token := GetToken;  // skip over it whatever it is
  end;  { ProcedureNameFound }

  procedure SkipUntilLineStartsWith(SymbolSet: TSymbolSet);
  begin
    repeat
      SkipBlanks;
      InSymbol(Token);    // just the first symbol on each line
      if not (Token.Type_of_Symbol in SymbolSet) then
        Readline(Source);
    until (Token.Type_of_Symbol in SymbolSet) or Eof(fInputFile);
  end;

  procedure SkipUntil(SymbolSet: TSymbolSet);
  begin
    while not ((Token.Type_of_Symbol in SymbolSet) or Eof(fInputFile)) do
      begin
        if Token.Type_of_Symbol = symEOS then
          ReadLine(Source);
        SkipBlanks;
        InSymbol(Token);
      end;
  end;


  procedure ProcessProcedureBody(var ProcedureInfo: TProcedureInfo);
  var
    SegNumber: integer;
    EndOfBody: boolean;
    LastLineNumber: integer;

    procedure AddBodyLine(const Source: string; CalculatedLevel: integer);
    var
      Line: string;
    begin
      Line := Format('%4d: %s', [OffSet, Source]);
      ProcedureInfo.ProcedureBody.AddObject(Line, TObject(CalculatedLevel));
      // The calculated level (not currently used) could be used for indentation.
    end;

    function Next_Symbol_Is(LookingForSymbol: TType_of_Symbol): boolean;
    var
      SavedLine : string;
      SavedIdx  : integer;
      Symbol    : TSymbol_Type;
    begin { Next_Symbol_Is }
      SavedLine  := Line;
      SavedIdx   := fIdx;

      SkipBlanks;
      InSymbol(Symbol);

      result     := Symbol.Type_of_Symbol = LookingForSymbol;
      if not result then
        begin //  not what we were looking for - pretend like we didn't look ahead
          Line  := SavedLine;
          fIdx  := SavedIdx;
        end;
    end;   { Next_Symbol_Is }

  begin { ProcessProcedureBody }
    // include initial lines at the start of a proc which may have a 0 nesting level
    fProcNum := 0;
    PrevNestingLevel := 0;
    while (NestingLevel = 0) and (Token.Type_of_Symbol <> symEnd) and (not Eof(fInputFile))  do
      begin
        if Next_Symbol_Is(symEnd) then
          break;

        if ProcessListingLine(VersionNr, line, fLineNumber, ProcedureInfo.SegmentNumber, fProcNum, Offset, Source, DataSeg, NestingLevel) then
          AddBodyLine(Source, CalculatedLevel);

        ProcessListingLine(VersionNr, line, fLineNumber, SegNumber, fProcNum, Offset, Source, DataSeg, NestingLevel);

        if ProcedureInfo.ProcedureNumber = 0 then
          ProcedureInfo.ProcedureNumber := fProcNum;
          
        Readline(Source);
        Token := GetToken;
      end;

    if Token.Type_of_Symbol = symEnd then
      begin
        AddBodyLine(Source, CalculatedLevel);
        Token := GetToken;
      end;

    // now include the body of the procedure
    if not (Eof(fInputFile) or (Token.Type_of_Symbol = symSemiColon)) then
      begin
        CalculatedLevel := 0;
        repeat
          LastOffset     := Offset;
          LastLineNumber := fLineNumber;
          if ProcessListingLine(VersionNr, line, fLineNumber, SegNumber, fProcNum, Offset, Source, DataSeg, NestingLevel) then
            AddBodyLine(Source, CalculatedLevel);

          if (Offset > 0) or (NestingLevel > 0) then
            begin
              ReadLine(Source);
              ProcessListingLine(VersionNr, line, fLineNumber, SegNumber, fProcNum, Offset, Source, DataSeg, NestingLevel);
              fIdx  := 1;      // only look at the 1st symbol on the line- assumes neatly formatted
              Token := GetToken;
            end;

          EndOfBody := (Token.Type_of_Symbol = symEnd) and (CalculatedLevel = 0);   // warning: The NESTINGLEVEL cycles 0..9 - Never greater than 9

        until DataSeg
              or EndOfBody
              or Eof(fInputFile)
              or (fLineNumber = LastLineNumber);  // not making any progress

        if Token.Type_of_Symbol = symEnd then
          Token := GetToken;
        Offset := LastOffset;      // Avoid final offset of 0
        AddBodyLine(Source, CalculatedLevel);
        SkipUntil([symRightParen, symBegin] + PROCHEADS + SEGMENTHEADS);
        if Token.Type_of_Symbol = symRightParen then
          Token := GetToken;       // The IV compiler generates a listing file that has a hanging ")"
                                   // following an INCLUDEd file. We've got to just ignore it.
      end;
  end;  { ProcessProcedureBody }

  procedure SyntaxError(const Msg: string; Args: array of const);
  begin
    AlertFmt(Msg, Args);
  end;

  procedure ProcessVariableList(var ProcedureInfo: TProcedureInfo);
  var
    VarList, RebuiltList, aLine: string;
    DataSize: word;
    LocalParameters: TLocalParameters;
  begin { ProcessVariableList }
    VarList := '';
    if Token.Type_of_Symbol = symVAR then
      begin
        if fIdx < Length(Source) then
          begin
            VarList := Copy(Source, fIdx + 1, MAXINT);  // everything after the VAR
            fIdx    := fIdx + Length(varList) + 1;
          end
        else
          VarList := '';

        repeat
          Token := GetToken; // get the 1st token on each line
          if not (Token.Type_of_Symbol in PROCHEADS + [symBEGIN]) then
            begin
//            aLine := Format('%s { @%d }', [Source, Offset]); // include current offset as a comment-
                                                               // offset may get changed when varlist gets reordered
              aLine := Source;  // indent to match the body
              if not Empty(VarList) then
                VarList := VarList + CRLF + aLine
              else
                VarList := aLine;
              ReadLine(Source);
            end;
        until Token.Type_of_Symbol in PROCHEADS + [symBEGIN];

        ProcedureInfo.VarList := VarList;

        if ParseParameterNames( VarList,
                                LocalParameters,
                                DataSize,
                                false {not a parameter list},
                                TRUE {skip to ';' on error}) then
          if RebuildParamList(LocalParameters, RebuiltList, false, CR+LF, VersionNr = vn_VersionII) then
            begin
              ProcedureInfo.VarList := RebuiltList;
              with ProcedureInfo.ProcedureBody do
                Text := Text + {CRLF +} PadR('', 10) + 'VAR' + RebuiltList + CRLF;
            end;
      end;

  end;  { ProcessVariableList }

  procedure DoProcedureHeading(ProcedureInfo: TProcedureInfo; const RebuiltList: string);
  var
    ResultType: string;
    ParamString: string;
  begin
    if Assigned(ProcedureInfo) then
      with ProcedureInfo do
        begin
          ParamList     := RebuiltList;
          if ResultTypeName <> '' then
            ResultType := ': ' + ResultTypeName
          else
            ResultType := '';

        ParamString := RebuiltList;
        DeleteTrailingChar(ParamString, ';');
        ParamString := RemoveRepeatedChar(ParamString, ' ');

        with ProcedureInfo do
          ProcedureBody.Text := PadR('', 10) + Format('%s %s(%s)%s;',
                                     [TokenInfoArray[SegmentType].Name,
                                      ProcedureNameFull,
                                      ParamString,
                                      ResultType]);
      end;
  end;


  procedure ProcessParameterList(var ProcedureInfo: TProcedureInfo);
  var
    ParamString, NextSource, RebuiltList: string;
    LocalParameters: TLocalParameters;
    DataSize: word;
    rp: integer;
    Idx: integer;
  begin { ProcessParameterList }
    RebuiltList := '';
    if Token.Type_of_Symbol = symLeftParen then  // should always be true
      begin
        Idx := fIdx;
        repeat
          rp := PosEx(')', Source, Idx);
          if rp <= 0 then  // need to read in more lines
            begin
              ReadLine(NextSource);
              Source := Source + NextSource;
            end;
        until rp > 0;

        if rp > 0 then
          begin
            ParamString := Copy(Source, Idx, rp - Idx);
            fIdx        := rp + 1;  // skip over the parameter list
            ProcedureInfo.ParamList := ParamString;
            if ParseParameterNames( ParamString,
                                    LocalParameters,
                                    DataSize,
                                    TRUE {is a parameters list},
                                    TRUE  {skip to ';' on error} ) then
              if RebuildParamList(LocalParameters, RebuiltList, true, ' ', VersionNr = vn_VersionII) then
                DoProcedureHeading(ProcedureInfo, RebuiltList);
          end
        else
          SyntaxError('Right paren was expected  in line "%s"', [Line]);
      end;
  end;  { ProcessParameterList }

  procedure ParseProcedure(var ParentProcedureInfo: TProcedureInfo);
  var
    ProcedureInfo: TProcedureInfo;
  begin { ParseProcedure }
    if ProcedureNameFound(ParentProcedureInfo, ProcedureInfo) then
      begin
        Token := GetToken;
        if Token.Type_of_Symbol = symLeftParen then  // process the parameter list
          begin
            ProcessParameterList(ProcedureInfo);
            Token := GetToken;
          end;
        if Token.Type_of_Symbol = symColon then  { function result }
          begin
            Token := GetToken;
            if Token.Type_of_Symbol = symIdentifier then
              begin
                ProcedureInfo.ResultTypeName := UCSDName(Token.StringVal);
                ProcedureInfo.ResultTypeType := IdentifierType(Token.StringVal);
                Token := GetToken;
              end;
          end;
        DoProcedureHeading(ProcedureInfo, ProcedureInfo.ParamList);

        if Token.Type_of_Symbol = symSemiColon then
          Token := GetToken;

        repeat
          if Token.Type_of_Symbol in [symFORWARD, symBEGIN, symVAR, symCONST, symColon,
                                      symTYPE, symLABEL, symUSES, symINTERFACE, symIMPLEMENTATION]+PROCHEADS then
            begin
              case Token.Type_of_Symbol of
                symFORWARD:
                  begin
                    Token := GetToken;
                    Break;
                  end;

                symBEGIN:
                  begin
                    ProcessProcedureBody(ProcedureInfo);
                    Break;
                  end;

                symVAR :
                  ProcessVariableList(ProcedureInfo);

                symCONST:
                  SkipUntilLineStartsWith([symTYPE, symVAR, symBEGIN] + PROCHEADS);

                symTYPE:
                  SkipUntilLineStartsWith([symTYPE, symVAR, symBEGIN] + PROCHEADS);

                symLABEL:
                  SkipUntilLineStartsWith([symTYPE, symVAR, symCONST, symBEGIN] + PROCHEADS);

                symUSES:
                  begin
                    Token := GetToken;
//                  if Token.Type_of_Symbol = symUSING then // 10/11/2021 - I don't know what I was trying to do here
                      SkipUntilLineStartsWith([symTYPE, symVAR, symCONST, symBEGIN] + PROCHEADS)
//                  else
                      {?};
                  end;

                symPROCEDURE, symFUNCTION, symSEGMENT, symUNIT, symPROGRAM:
                  ParseProcedure(ProcedureInfo);

                symINTERFACE:
                  begin
                    ProgSection := psINTERFACE;
                    Token       := GetToken;
                  end;

                symIMPLEMENTATION:
                  begin
                    ProgSection := psIMPLEMENTATION;
                    Token       := GetToken;
                  end;
              end;
            end;
          if Token.Type_of_Symbol = symSemiColon then
            Token := GetToken;
        until (not (Token.Type_of_Symbol in [symFORWARD, symBEGIN, symVAR, symCONST,
                                             symColon, symTYPE, symLabel, symUSES]+PROCHEADS))
                 or Eof(fInputFile);
        if Token.Type_of_Symbol = symSemiColon then
          Token := GetToken;
      end;
  end;   { ParseProcedure }
(*
  procedure WriteLocalParameters(const Header: string; const LocalParameters: TLocalParameters);
  var
    pg: integer;
    RepLine: string;
  begin { WriteLocalParameters }
    for pg := 0 to Length(LocalParameters)-1 do
      with LocalParameters[pg] do
        begin
          RepLine := Format('%-8s %-8s %4d %-8s %-6s %-6s',
                            [ParamName, UCSDName(WatchTypes[ParamType].WatchName),
                             ParamSize, ParamTypeName,
                             TFString(ParamIsAVar), TFString(ParamIsAPointer)]);
          if not Empty(ParamComment) then
            RepLine := RepLine + '{ ' + ParamComment + ' } ';
          WriteLn(fOutputFile, RepLine);
        end;
  end; { WriteLocalParameters }
*)
begin { ProcessFile }
  result     := 0;
  ProgSection := psUnknown;

  AssignFile(fInputFile, InFileName);
{$I-}
  Reset(fInputFile);
{$I+}
  if IOResult = 0 then
    try
      fIdx  := 1;
      fRootProcedure := nil;
      Token := GetToken;
      while not Eof(fInputFile) do
        ParseProcedure(fRootProcedure);
    finally
      CloseFile(fInputFile);
    end;
end;  { ProcessFile }

procedure TfrmBuildDBDBMain.btnBrowseDBClick(Sender: TObject);
var
  FilePath: string;
begin
  with frmFileParameters do
    begin
      FilePath := DataBaseFileName;
      if BrowseForFile('DB File (*.ACCDB)', FilePath, ACCDB_EXT) then
        DatabaseFileName := FilePath;
    end;
end;

procedure TfrmBuildDBDBMain.Open1Click(Sender: TObject);
var
  FilePath: string;
begin
  with frmFileParameters do
    begin
      FilePath := DatabaseFileName;
      if BrowseForFile('Open Debugger Database', FilePath, ACCDB_EXT) then
        DatabaseFileName := FilePath;
    end;
end;

function TfrmBuildDBDBMain.PrintResults(const OutputFileName: string): integer;
var
  sn, sn2, pn: integer;
  ProcedureInfo  : TProcedureInfo;
  SegmentInfo    : TSegmentInfo;
begin
  result := 0;
  with frmFileParameters do
    begin
      AssignFile(fOutputFile, OutputFileName);
      Rewrite(fOutputFile);
      try
        // 1st just list the segments
//      WriteLn(fOutputFile, 'Seg#, Seg#2, SegName');
//      for sn := 0 to fSegmentInfoList.Count-1 do
//        begin
//          SegmentInfo   := fSegmentInfoList.Objects[sn] as TSegmentInfo;

//          with SegmentInfo do
//            WriteLn(fOutputFile, sn, ',',
//                               SegmentNumber, ',',
//                               fSegmentInfoList[sn]);
//        end;
//      WriteLn(fOutputFile);

        // now combine with the procedures
        WriteLn(fOutputFile, 'Seg#, SegName, SegType, Seg#2, ProcNr, SegName, SegNameFull, ProcName, ProcNameFull');
        for sn := 0 to fSegmentInfoList.Count-1 do
          begin
            SegmentInfo   := fSegmentInfoList.Objects[sn] as TSegmentInfo;

            with SegmentInfo do
              for pn := 0 to Procedures.Count-1 do
                begin
                  Write(fOutputFile, {A} SegmentNumber, ',',
                                     {B} fSegmentInfoList[sn], ',',
                                     {c} TokenInfoArray[SegmentType].Name, ',');

                  ProcedureInfo := TProcedureInfo(Procedures.Objects[pn]);
                  with ProcedureInfo do
                    begin
                      sn2 := fSegmentInfoList.GetIndexOfSegmentNumber(SegmentNumber);
      //              SegmentInfo   := fSegmentInfoList.Objects[sn2] as TSegmentInfo;
                      WriteLn(fOutputFile,
                                       {D} SegmentNumber, ',',  // Seg#2
                                       {E} ProcedureNumber, ',',
                                       {F} fSegmentInfoList[sn2], ',',
                                       {G} SegmentNameFull, ',',
                                       {H} ProcedureName, ',',
                                       {I} ProcedureNameFull
                                         );
                end;
              end;
            inc(result);
          end;
      finally
        CloseFile(fOutputFile);
        ExecAndWait(OutputFileName, '', false);
      end;
    end;
end;

procedure TfrmBuildDBDBMain.ParseandList1Click(Sender: TObject);
var
  Processed, NrWritten: integer;
begin
  with frmFileParameters do
    begin
      FunctionType := ftParseAndList;
      if ShowModal = mrOk then
        begin
          Processed := ProcessFile(VersionNr, InputListingFileName);
          MyUpdateStatusFmt('%d lines processed in file %s', [Processed, InputListingFileName]);
          NrWritten := PrintResults(OutputFileName);
          MyUpdateStatusFmt('%d lines written to file %s', [NrWritten, OutputFileName]);
        end;
    end;
end;

constructor TfrmBuildDBDBMain.Create(aOwner: TComponent; TheDebuggerSettings: TDebuggerSettings);
begin
  inherited Create(aOwner);
  fDebuggerSettings := TheDebuggerSettings;
  Assert(false, 'FilerSettings may not be accessed');
(*
  FilerSettings := TFilerSettings.Create(self);

  with FilerSettings do
    begin
      if ParamStr(1) <> '' then
        FilerSettingsFileName := ParamStr(1);
      if FileExists(FilerSettingsFileName) and (FileSize32(FilerSettingsFileName) > 0) then
        LoadFromFile(FilerSettingsFileName);
    end;
*)
  fSegmentInfoList := TSegmentInfoList.Create;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('1. This program parses a compiler listing and can update a database of procedure names.');
  Memo1.Lines.Add('   It is not very smart and assumes that the program being listing has been processed');
  Memo1.Lines.Add('   by one of the pretty print programs (such as FORMAT.CODE) prior to compilation. Key words like');
  Memo1.Lines.Add('   PROGRAM, PROCEDURE, FUNCTION, CONST, VAR, TYPE, LABEL etc');
  Memo1.Lines.Add('   are expected to be the first word on a line.');
  Memo1.Lines.Add('2. This program can also scan a .CODE file and list important information in the Segment dictionary');
  Memo1.Lines.Add('3. It can also create the debug database from scratch.');
  Memo1.Lines.Add('4. It can scan a listing file and try to guess which compiler version created it.');
  Memo1.Lines.Add('5. It can clean up a compiler listing sent to CONSOLE: and write it to a new file.');
  Memo1.Lines.Add('');
end;

destructor TfrmBuildDBDBMain.Destroy;
begin
  FreeAndNil(fSegmentInfoList);
  FreeAndNil(FilerSettings);
  inherited;
end;

procedure TfrmBuildDBDBMain.BuildDatabasefromListing1Click(
  Sender: TObject);
begin
  with frmFileParameters do
    begin
      FunctionType := ftBuildDbFromListing;
      if ShowModal = mrOK then
        begin
          NewDatabase(DatabaseFileName);
          BuildDataBaseFromListing(InputListingFileName, DatabaseFileName, OutputFileName);
        end;
    end;
end;

procedure TfrmBuildDBDBMain.MyUpdateStatus(Const Msg: string);
begin
  Memo1.Lines.Add(Msg);
  lblStatus.Caption := Msg;
  Application.ProcessMessages;
end;

procedure TfrmBuildDBDBMain.NewDatabase(DatabaseFileName: string);
begin
  if FileExists(DatabaseFileName) then
    if YesFmt('The database "%s" already exists. REPLACE it?', [DataBaseFileName]) and
       YesFmt('Are you REALLY sure that you want to DELETE "%s"?', [DataBaseFileName]) then
         DeleteFile(DataBaseFileName)
    else
      Exit;

  try
    CreateDebugDatabase(DataBaseFileName, dv_Access2007);
    MyUpdateStatusFmt('Database "%s" created', [DataBaseFileName]);
  except
    on e:Exception do
      MyUpdateStatusFmt( 'Database "%s" could not be created [%s]',
                       [DataBaseFileName, e.Message])
  end;
end;



procedure TfrmBuildDBDBMain.miNewDatabaseClick(Sender: TObject);
begin
  with frmFileParameters do
    begin
      FunctionType := ftNewDB;
{$IfDef Debugging}
//    with fDEBUGGERSettings do
//      if pCodesDatabaseFileNameS.Count > 0 then
//        leDBFileName.Text := DatabaseToUse
//      else
//        leDBFileName.Text := '';
{$Else}
      leDBFileName.Text := fDEBUGGERSettings.DataBaseToUse;
{$EndIf}
      if ShowModal = mrOk then
        NewDatabase(DatabaseFileName);
    end;
end;

procedure TfrmBuildDBDBMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmBuildDBDBMain.MyUpdateStatusFmt(const Msg: string;
  args: array of const);
begin
  MyUpdateStatus(Format(Msg, Args));
end;

function TfrmBuildDBDBMain.GetWordAt(IPC: longword): word;
begin
  result := WordPtr(fBuffer + IPC)^;
end;

function TfrmBuildDBDBMain.GetByteAt(IPC: longword): byte;
begin
  result := BytePtr(fBuffer + IPC)^;
end;

function TfrmBuildDBDBMain.ProcedureIdentifier(const SegName: string; ProcedureInfo: TProcedureInfo): string;
//var
//Short, Long: string;
begin
//Short := Format('%2d:%s.%s', [ProcedureNumber, SegName, ProcedureInfo.ProcedureName]);
//if (xSegmentName <> SegmentNameFull) or (ProcedureName <> ProcedureNameFull) then
//  Long  := Format(' (%d:%s.%s)', [ProcedureNumber, SegmentNameFull, ProcedureNameFull])
//else
//  Long := '';
//result := Short + Long;
  with ProcedureInfo do
    result := Format('%2d:%s.%s', [ProcedureNumber, SegName{from parameter}, ProcedureName]);
end;

procedure TfrmBuildDBDBMain.MapSegmentsInCodeFile(Volume: TVolume; const pSysFileName : string;
                                                  OverWriteOptions: TOverWriteOptions;
                                                  VersionNr: TVersionNr);
type
  WordPtr = ^Word;

var
  DirIdx          : integer;
  sfi             : TSegmentFileInfo;
  BaseName        : string;
  Pd              : array[1..150] of integer;

    procedure ProcessUCSDSegment(DirIdx: integer; sfi: TSegmentFileInfo; SegIdx: integer);
    const
      SEGNAME_ =      4;             // byte of ascii name
      SEGSEX_   =     12;            // byte offset byte sex
      SEGCONST_ =     14;            // byte offset of constant pool
      REALSIZE_ =     16;
    type
      WordPtr = ^Word;
      BytePtr = ^Byte;
    var
      StartingBlock  : word;
      NrBytes        : word;
      NrBytesRead    : longint;
//    SegName        : string[8];
      ProcNr         : word;
      ExitIC         : word;
      DataSize       : word;
      ParamSize      : word;
      FirstBlock     : integer;
      SegLength      : integer;
      Loc            : integer;
      PdCount        : integer;
      ProcedureInfo  : TProcedureInfo;

      procedure ProcessUCSDProcedure(ProcNr: integer);
      var
        OK            : boolean;
        JTab          : integer;
        LexLevel      : integer;
        EnterIC       : integer;
        What          : string;
        LastCode      : integer;
        RecordFound   : boolean;

        procedure AddLineF(const Cap: string; Val: integer; AsHex: boolean = true);
        begin
          if AsHex then
            AddLine(Format('%-14s: $%-4.4x (%-4d)', [Cap, Val, Val]))
          else
            AddLine(Format('%-14s: %-4d', [Cap, Val]));
        end;

      begin { ProcessUCSDProcedure}
        fDecodedLines.Clear;
        JTab      := Pd[ProcNr];
        if JTab < 0 then
          begin
            AlertFmt('Procedure address bad: SegIdx %d, ProcNr %d, $%-4.4x', [SegIdx, ProcNr, JTab]);
            Exit;
          end;
        LexLevel  := GetByteAt(succ(JTab));
        if LexLevel > 127 then
          LexLevel := LexLevel - 256;
        EnterIC     := (JTab-2) - GetWordAt(JTab-2);
        ExitIC      := (JTab-4) - GetWordAt(JTab-4);
        ParamSize   := GetWordAt(JTab-6);
        DataSize    := GetWordAt(JTab-8);
        Lastcode    := JTab-9;           // point to end of code
        fIPC        := EnterIC;

        if LexLevel < -1 then
          raise Exception.CreateFmt('Lex Level Bad! (%d)', [LexLevel]) else
        if EnterIC < 0 then
          raise Exception.CreateFmt('EnterIC Bad (%d)', [EnterIC])
        else
          begin
            with pCodesProcTable do
              begin
                AddLine(Format('%-14s: %s', ['Segment', ProcedureInfo.xSegmentName]));
                AddLineF('SegIdx',    SegIdx, false);
                if Locate(IndexName_SEGMENT_PROC_NUMBER_INDEX,
                          VarArrayOf([ProcedureInfo.xSegmentName, ProcNr]),
                          [loCaseInsensitive]) then
                  ProcedureInfo.ProcedureName := fldProcedureName.AsString
                else
                  ProcedureInfo.ProcedureName := Format('PROC%2.2d', [ProcedureInfo.ProcedureNumber]);

                ProcedureInfo.ProcedureNameFull := fldProcedureNameFull.AsString;
                
                ProcedureInfo.ProcedureNumber   := ProcNr;
                ProcedureInfo.SegmentNameFull   := fldSegmentName.AsString;

                WriteLn(fOutputFile, '':8, 'Procedure name: ', ProcNr, ':', ProcedureInfo.xSegmentName, '.',
                                     ProcedureInfo.ProcedureName);

                AddLine(Format('%-14s: #%d:%s.%s', ['Procedure', ProcNr, ProcedureInfo.xSegmentName, ProcedureInfo.ProcedureName]));

                AddLineF('LexLevel',  LexLevel, false);

                AddLineF('  0: JTAB',      JTab);
                AddLineF(' -2: EnterIC',   EnterIC);
                AddLineF(' -4: ExitIC',    ExitIC);
                AddLineF(' -6: ParamSize', ParamSize);
                AddLineF(' -8: DataSize',  DataSize);
                AddLineF('-10: Lastcode',  LastCode);

                fpCodeDecoderII.SegName := ProcedureInfo.xSegmentName;
                fpCodeDecoderII.ProcNr  := ProcNr;
                fpCodeDecoderII.JTAB    := JTAB;

                fpCodeDecoderII.Decode(fIPC, LastCode-EnterIC+1, true, dfMemoFormat, fIPC { BaseAddress });

                RecordFound := Locate( IndexName_SEGMENT_PROC_NUMBER_INDEX,
                                       VarArrayOf([ProcedureInfo.xSegmentName, ProcNr]),
                                       [loCaseInsensitive]);

                What := 'Update DB with decoded p-Code for Procedure ' + ProcedureIdentifier(ProcedureInfo.xSegmentName, ProcedureInfo);

                // put the p-Code lines into fDecodedLines using the AddLine method
                fpCodeDecoderII.JTab     := JTab;       // seems redundant
                fpCodeDecoderII.ExitIC   := ExitIC;
                fpCodeDecoderII.LastCode := LastCode;

                OK := frmUpdateConfirm.OkToOverWriteWhat( What,
                                                          OverWriteOptions,
                                                          fDecodedLines.Text,
                                                          fldSourceCode.AsString,
                                                          RecordFound,
                                                          ProcedureInfo);
                if OK then
                  begin
                    // Name or number might have gotten changed in OkToOverWriteWhat
                    RecordFound := Locate( IndexName_SEGMENT_PROC_NUMBER_INDEX,
                                           VarArrayOf([ProcedureInfo.xSegmentName, ProcedureInfo.ProcedureNumber]),
                                           [loCaseInsensitive]);

                    if RecordFound then
                      begin
                        Edit;
                        inc(NrProcRecsEdited);
                      end
                    else
                      begin
                        Append;
                        fldSegmentName.AsString      := ProcedureInfo.xSegmentName;
                        fldProcedureNumber.AsInteger := ProcNr;
                        inc(NrProcRecsAdded);
                      end;

                    if (fldProcedureName.AsString <> ProcedureInfo.ProcedureName) and
                        YesFmt('OK to overwrite procedure name "%s" with "%s"?', [fldProcedureName.AsString, ProcedureInfo.ProcedureName]) then
                      fldProcedureName.AsString  := ProcedureInfo.ProcedureName;

                    if OK then
                      begin
                        fldCodeAddr.AsInteger        := FirstBlock;
                        fldDataSize.AsInteger        := DataSize;
                        fldParamSize.AsInteger       := ParamSize;
                        fldEnterIC.AsInteger         := EnterIC;
                        fldExitIC.AsInteger          := ExitIC;
                        fldCodeSize.AsInteger        := LastCode-EnterIC+1;  // This is wrong maybe?
                        fldVersionNr.AsString        := VersionNrToAbbrev(VersionNr);
                        fldProcedureName.AsString    := ProcedureInfo.ProcedureName;
                        fldProcedureNameFull.AsString := ProcedureInfo.ProcedureNameFull;
                        fldSegmentName.AsString      := ProcedureInfo.xSegmentName;

                        fldDecodedPCode.AsString     := fDecodedLines.Text;
                        Post;
                      end;
                  end;
              end;
          end;
      end; { ProcessUCSDProcedure }

    begin { ProcessUCSDSegment }
      StartingBlock := Volume.Directory[DirIdx].FirstBlk + sfi.SegDictInfo[SegIdx].Code_Addr;  // of the segment within the volume
      NrBytes       := sfi.SegDictInfo[SegIdx].Code_Leng {div 2};             // segment length in bytes
      NrBytes       := ((NrBytes + (FBLKSIZE - 1)) div FBLKSIZE) * FBLKSIZE;  // round up to a full block
      ProcedureInfo := TProcedureInfo.Create;

      ProcedureInfo.xSegmentName      := sfi.SegDictInfo[SegIdx].SegName;
      ProcedureInfo.SegmentNameFull   := sfi.SegDictInfo[SegIdx].SegName;

      GetMem(fBuffer, NrBytes);  // make room for the entire segment

      fOpsTable       := TOpsTableII.Create;
      fPcodeDecoderII := TpCodeDecoderII.Create(self, fOpsTable);
      with fPcodeDecoderII do
        begin
          OnAddLine          := AddLine;
          OnAddLineSeparator := AddLineSeparator;
          OnGetByte3         := GetByteAt;
          OnGetWord3         := GetWordAt;
//        OnGetBaseAddress   := GetBaseAddress;
        end;
      fDecodedLines := TStringList.Create;

      try
        Volume.SeekInVolumeFile(StartingBlock);
        NrBytesRead := Volume.PartialBlockReadRel(fBuffer^, NrBytes, StartingBlock);  // load the segment into memory
        if (NrBytesRead = NrBytes) {and (IO = 0)} then
          begin
            FirstBlock   := sfi.SegDictInfo[SegIdx].Code_Addr;  // within the segment
            SegLength    := sfi.SegDictInfo[SegIdx].Code_Leng;  // of the segment (in bytes for vI.5)
            Loc          := pred(SegLength);
            PdCount      := GetByteAt(Loc);
            Loc          := Pred(Loc);

            for ProcNr := 1 to PdCount do
              begin
                Loc := Loc - 2;
                Pd[ProcNr] := Loc - GetWordAt(Loc);
                ProcessUCSDProcedure(ProcNr);
              end;
          end;
      finally
        FreeAndNil(fDecodedLines);
        FreeAndNil(fpCodeDecoder);
        FreeAndNil(fOpsTable);
        FreeMem(fBuffer);
        FreeAndNil(ProcedureInfo);
      end;
    end;  { ProcessUCSDSegment }

    procedure ProcessSoftechSegment(DirIdx: integer; sfi: TSegmentFileInfo; SegIdx: integer);
    const
      SEGNAME_ =      4;             // byte of ascii name
      SEGSEX_   =     12;            // byte offset byte sex
      SEGCONST_ =     14;            // byte offset of constant pool
      REALSIZE_ =     16;
    var
      StartingBlock  : word;
      ProcPtrOffset  : word;
      NrBytes        : word;
      NrBlocksRead   : longint;
      IO             : integer;
      NrProcs        : word;
      NrBlocks       : word;
      ProcNr         : word;
      ProcAddr       : word;         // This is a BYTE offset-- NOT a word offset.
      ExitIC         : word;
      DataSize       : word;
      CodeSize       : word;
      SegDic         : TSeg_Dict;
      ProcedureInfo  : TProcedureInfo;

      procedure ProcessSoftechProcedure(ProcNr: integer);
      var
        OK: boolean;
        What: string;
        Line: string;
        RecordFound: boolean;
      begin { ProcessSoftechProcedure}
        fDecodedLines.Clear;
        
        ProcAddr  := GetWordAt(ProcPtrOffset - (ProcNr * 2)) * 2;
        if ProcAddr > 0 then // What does it mean if the ProcAddr = 0?
          begin
            DataSize  := GetWordAt(ProcAddr);
            ExitIC    := GetWordAt(ProcAddr-2) * 2;
            fCodeAddr := ProcAddr + 2;
            CodeSize  := ProcPtrOffset - ProcAddr;      // This is not really true. Needs to be fixed

            with pCodesProcTable do
              begin
                RecordFound := Locate( IndexName_SEGMENT_PROC_NUMBER_INDEX,
                                       VarArrayOf([ProcedureInfo.xSegmentName, ProcNr]),
                                       [loCaseInsensitive]);
                if RecordFound then
                  begin
                    ProcedureInfo.ProcedureNumber   := ProcNr;
                    if frmFileParameters.EraseSourceCodeAndProcName then
                      begin
                        Edit;
                        ProcedureInfo.ProcedureName     := Format('Proc %d', [ProcNr]);
                        ProcedureInfo.ProcedureNameFull := '';
                        fldSourceCode.Clear;
                      end
                    else
                      begin
                        ProcedureInfo.ProcedureName     := fldProcedureName.AsString;
                        ProcedureInfo.ProcedureNameFull := fldProcedureNameFull.AsString;
                      end;
                  end;

                What := 'DB for Procedure ' + ProcedureIdentifier(fldSegmentName.AsString, ProcedureInfo);

                AddLine(DateTimeToStr(Now));
                AddLine(Volume.DOSFileName);
                Line := Format('%s:%s', [Volume.VolumeName, pSysFileName]);
                AddLine(Line);

                with ProcedureInfo do
                  Line := Format('#%d %s.%s', [ProcNr, Trim(xSegmentName), ProcedureName]);
                AddLine(Line);

                AddLine('');

                // put the p-Code lines into fDecodedLines using the AddLine method
                fpCodeDecoder.Decode(0, CodeSize * 2, true, dfMemoFormat, fCodeAddr);

                OK := frmUpdateConfirm.OkToOverWriteWhat( What,
                                                          OverWriteOptions,
                                                          fDecodedLines.text,
                                                          fldSourceCode.AsString,
                                                          RecordFound,
                                                          ProcedureInfo);
                if OK then
                  begin
                    if RecordFound then
                      begin
                        Edit;
                        inc(NrProcRecsEdited);
                      end
                    else
                      begin
                        Append;
                        fldSegmentName.AsString      := ProcedureInfo.xSegmentName;
                        fldProcedureNumber.AsInteger := ProcNr;
                        fldProcedureName.AsString    := Format('PROC%2.2d', [ProcNr]);
                        inc(NrProcRecsAdded);
                      end;

                    with pCodesProcTable do
                      begin
                        if Assigned(fldCodeAddr) then
                          fldCodeAddr.AsInteger        := fCodeAddr;

                        if Assigned(fldDataSize) then
                          fldDataSize.AsInteger        := DataSize;

      //                fldParamSize.AsInteger       := ParamSize;
                        if Assigned(fldExitIC) then
                          fldExitIC.AsInteger          := ExitIC;

                        if Assigned(fldVersionNr) then
                          fldVersionNr.AsString        := VersionNrToAbbrev(VersionNr);

                        if Assigned(fldDecodedPCode) then
                          fldDecodedPCode.AsString     := fDecodedLines.Text;

                        Post;
                      end;
                  end;
              end;
          end
      end; { ProcessSoftechProcedure }

    begin { ProcessSoftechSegment }
      ProcedureInfo  := TProcedureInfo.Create;
      with Volume do
        begin
          Seek(VolumeFile, Directory[DirIdx].FirstBlk);
          System.BlockRead(VolumeFile, SegDic, 1, NrBlocksRead);
          ProcedureInfo.xSegmentName    := SegDic.Seg_Name[SegIdx];
          ProcedureInfo.SegmentNameFull := SegDic.Seg_Name[SegIdx];
        end;

      StartingBlock := Volume.Directory[DirIdx].FirstBlk + sfi.SegDictInfo[SegIdx].Code_Addr;
      NrBytes       := sfi.SegDictInfo[SegIdx].Code_Leng * 2;   // Assume Code_Leng in words for Version IV. Convert to bytes.
      NrBytes       := ((NrBytes + (FBLKSIZE - 1)) div FBLKSIZE) * FBLKSIZE;  // round up to a full block
      NrBlocks      := NrBytes div FBLKSIZE;
      GetMem(fBuffer, NrBytes);

      fOpsTable     := TOpsTableIV.Create;
      fPcodeDecoder := TpCodeDecoder.Create(self, fOpsTable, TRUE, VersionNr);
      with fPcodeDecoder do
        begin
          OnAddLine                    := AddLine;
          OnAddLineSeparator           := AddLineSeparator;
          fPCodeDecoder.OnGetByte3     := GetByteAt;
          fPCodeDecoder.OnGetWord3     := GetWordAt;
          fPCodeDecoder.OnGetBasedWord := GetBasedWord;
          fPCodeDecoder.OnGetByteBased := GetBasedByte;
//        fPCodeDecoder.OnGetCPOffSet  := GetCPOffset;
        end;
      fDecodedLines := TStringList.Create;

      try
        Seek(Volume.VolumeFile, StartingBlock);
        NrBlocksRead := 0;
        System.BlockREAD(Volume.VolumeFile, fBuffer^, NrBlocks, NrBlocksRead);
        IO := IOResult;
        if (NrBlocksRead = NrBlocks) and (IO = 0) then
          begin
            ProcPtrOffset    := GetWordAt(0) * 2;
            NrProcs          := GetWordAt(ProcPtrOffset);
            for ProcNr := 1 to NrProcs do
              ProcessSoftechProcedure(ProcNr);
          end;
      finally
        FreeAndNil(ProcedureInfo);
        FreeAndNil(fDecodedLines);
        FreeAndNil(fpCodeDecoder);
        FreeMem(fBuffer);
        FreeAndNil(fOpsTable);
      end;
    end;  { ProcessSoftechSegment }

  procedure DecodeSegment;
  var
    SegIdx          : integer;
  begin  { DecodeSegment }
    with sfi do
      begin
        // Locate a record in the Volumes table with this base DOS name.
        BaseName := ExtractFileName(Volume.DOSFileName);
        with VolumeInfoTable do
          begin
            if Locate(IndexName_DOSVOLUMEFILENAME, BaseName, [loCaseInsensitive]) then
              begin
                Edit;
                inc(NrVolRecsEdited);
              end
            else
              begin // If not found, then add it.
                Append;
                fldDOSVolumeFileName.AsString := BaseName;
                inc(NrVolRecsAdded);
              end;

            fldpSysVolumeName.AsString := Volume.VolumeName;
            fldDOSFilePath.AsString    := ExtractFilePath(Volume.DOSFileName);
            fldVersionNr.AsString      := VersionNrToAbbrev(VersionNr);
            Post;
          end;

        with CodeFileInfoTable do
          begin
            // Add/Update CodeFileInfo record
            if Locate(IndexName_PSYSFILENAME, pSysFileName, [loCaseInsensitive]) THEN
              begin
                Edit;
                inc(NrCodeRecsEdited);
              end
            else
              begin
                Append;
                fldpSysFileName.AsString := pSysFileName;
                inc(NrCodeRecsAdded);
              end;
            fldNrSegments.AsInteger := sfi.NrSegsInFile;
            fldVolumeID.AsInteger   := VolumeInfoTable.fldVolumeID.AsInteger;
            Post;
          end;

        // For each segment that was found in the p-System code file
        // Add/Update a record in the SegmentInfo table.

        for SegIdx := 0 to MAXDICSEG do
          begin
            with sfi.SegDictInfo[SegIdx] do
             if (SegName <> '') {and (OldSegType <> NoSeg)} then
              begin
                case sfi.VersionSplit of
                  vsUCSD:    ProcessUCSDSegment(DirIdx, sfi, SegIdx);
                  vsSoftech: ProcessSoftechSegment(DirIdx, sfi, SegIdx);
                end;
              end;
          end;
      end;
  end;  { DecodeSegment }

begin { MapSegmentsInCodeFile }
  frmSegOk         := TfrmYesNoDontAskAgain.Create(self, 'Segments', pSysFileName);
  frmUpdateConfirm := TfrmUpdateConfirm.Create(self, 'Procedures', '');
  try
    if frmCodeFileOk.OkToOverwrite(Format('DB for Code file %s', [pSysFileName]), OverWriteOptions) then
      begin
        WriteLn(fOutputFile, 'File: ', pSysFileName);
        DirIdx := Volume.DirIdxFromString(pSysFileName);
        if DirIdx > 0 then
          begin
            if LoadSegmentFile(Volume.Directory[DirIdx].FirstBlk,
                               Volume.VolStartBlockInParent,
                               Volume{.VolumeFile},
                               sfi,
                               pSysFileName) then
              begin
                frmProcOk     := TfrmYesNoDontAskAgain.Create(self, 'Procedures', 'segment');
                try
                  DecodeSegment;  // Update Database from Segment Info
                finally
                  FreeAndNil(frmProcOk);
                end;
              end;
          end
        else
          AlertFmt('File %s could not be found in volume %s', [pSysFileName, fVolFilePath]);
      end;
  finally
    FreeAndNil(frmUpdateConfirm);
    FreeAndNil(frmSegOk);
  end;
end; { MapSegmentsInCodeFile }

function TfrmBuildDBDBMain.GetBasedWord(Base, Offset: word): word;
begin
  result := WordPtr(fBuffer + Base + Offset)^;
end;

function TfrmBuildDBDBMain.GetBasedByte(Base, Offset: word): byte;
begin
  result := BytePtr(fBuffer + Base + Offset)^;
end;


procedure TfrmBuildDBDBMain.AddLine(const Line: string);
begin
  fDecodedLines.Add(TrimRight(Line));
end;

procedure TfrmBuildDBDBMain.AddLineSeparator(OpCode: word);
begin
  with fOpsTable do
    if OpCode in (Store_OPS + Jump_OPS + Call_OPS) then
      AddLine('');
end;

procedure TfrmBuildDBDBMain.MapSegmentsinCodeFile1Click(Sender: TObject);
var
  pSysFileName : string;
  dn: integer;
begin { MapSegmentsinCodeFile1Click }
  with frmFileParameters do
    begin
      FunctionType := ftScanCodeFileAndUpdateDB;
      OverWriteOptions := ooAskToOverWrite;
      if ShowModal = mrOK then
        begin
          // Open the report file
          AssignFile(fOutputFile, OutputFileName);
          Rewrite(fOutputFile);
          WriteLn(fOutputFile, 'File processed on ', DateToStr(Now), ' at ', TimeToStr(Now));
          WriteLn(fOutputFile, 'REMINDER: program may not handle WORD_MEMORY code.');
          WriteLn(fOutputFile);

          // Open Database Files
          pCodesProcTable := TpCodesProcTable.Create(self, DataBaseFileName, TableNamePCODEPROCS, [optLevel12]);
          pCodesProcTable.Open;

          VolumeInfoTable := TVolumeInfoTable.Create(self, DataBaseFileName, TableNameVOLUMEINFO, [optLevel12]);
          VolumeInfoTable.Open;

          CodeFileInfoTable := TCodeFileInfoTable.Create(self, DataBaseFileName, TableNameCODEFILEINFO, [OptLevel12]);
          CodeFileInfoTable.Open;

          NrVolRecsAdded           := 0;
          NrVolRecsEdited          := 0;
          NrCodeRecsAdded          := 0;
          NrCodeRecsEdited         := 0;
          NrProcRecsAdded          := 0;
          NrProcRecsEdited         := 0;

          try
            fVolFilePath := FilerSettings.VolumesFolder + '*.' + VOL_EXT;
            if BrowseForFile('Locate Volume File', fVolFilePath, VOL_EXT, VOLUMEFILTERLIST) then
              begin
                // Create Volume
                fVolume      := CreateVolume(self, fVolFilePath);
                try
                  // Load the directory
                  fVolume.LoadVolumeInfo(DIRECTORY_BLOCKNR);

                  // Let the user choose which files to process
                  frmCodeFileOk := TfrmYesNoDontAskAgain.Create(self, 'Code Files', 'Volume ' + fVolume.VolumeName);
                  try
                    for dn := 1 to fVolume.NumFiles do
                      if (fVolume.Directory[dn].xDFKind = kCODEFILE) or
                         (fVolume.Directory[dn].FileNAME = 'SYSTEM.PASCAL') then
                        begin
                          pSysFileName := fVolume.Directory[dn].FileNAME;
                          MapSegmentsInCodeFile(fVolume, pSysFileName, OverWriteOptions, VersionNr);
                        end;

                  finally
                    FreeAndNil(frmCodeFileOk);
                  end;

                finally
                  MyUpdateStatus(Format('Added/Edited: VolRecs %d/%d, CodeRecs %d/%d, ProcRecs %d/%d',
                                     [NrVolRecsAdded,  NrVolRecsEdited,
                                      NrCodeRecsAdded, NrCodeRecsEdited,
                                      NrProcRecsAdded, NrProcRecsEdited]));
                  FreeAndNil(fVolume);
                  FreeAndNil(frmSegOk);
                end;
              end;
          finally
            // Close Database Files
            pCodesProcTable.Close;
            VolumeInfoTable.Close;
            CodeFileInfoTable.Close;
            FreeAndNil(frmSegOk);
            CloseFile(fOutputFile);
            if (NrVolRecsAdded > 0) or
               (NrVolRecsEdited > 0) or
               (NrCodeRecsAdded > 0) or
               (NrCodeRecsEdited > 0) or
               (NrProcRecsAdded > 0) or
               (NrProcRecsEdited > 0) then
              EditTextFile(OutputFileName);
          end;
        end;
    end;
end;  { MapSegmentsinCodeFile1Click }

procedure TfrmBuildDBDBMain.BuildDataBaseFromListing(const aListingFileName,
                                                           aDataBaseFileName,
                                                           aOutputFileName: string);
var
  sn, pn, i      : integer;
  CanOverWrite   : boolean;
  ProcedureInfo  : TProcedureInfo;
  SegmentInfo    : TSegmentInfo;
  Body           : string;
  Processed      : integer;
  AddedPPT       : integer;
  SkippedPPT     : integer;
  UpdatedPPT     : integer;
  Temp           : string;
  What           : string;
  RecFound       : boolean;
  ActionTaken    : string;
  sn2            : integer;

(*
  procedure UpdateSegmentInfo(ProcedureInfo: TProcedureInfo);
  var
    SegmentName: string;
    sn2: integer;
  begin { UpdateSegmentInfo }
    with SegmentInfoTable do
      begin
        sn2         := fSegmentInfoList.GetIndexOfSegmentNumber(ProcedureInfo.SegmentNumber);
        if sn2 >= 0 then
          begin
            ProcedureInfo.xSegmentName := UCSDName(fSegmentInfoList[sn2]);
            SegmentName := UCSDName(ProcedureInfo.xSegmentName);

            if Locate(cSEGMENTNAME, SegmentName, [loCaseInsensitive]) then
              Edit
            else
              begin
                Append;
                fldSegmentName.AsString := SegmentName;
              end;

            Post;
          end;
      end;
  end;  { UpdateSegmentInfo }
*)
  procedure WriteVarGroup(const GroupName, GroupValue: string);
  begin
    if GroupValue <> '' then
      Temp := Temp + '{ ' + GroupName + ' }' + CRLF + GroupValue + CRLF;
  end;

  procedure UpdateVolumeInfoTable(ProcedureInfo: TProcedureInfo; VersionNr: TVersionNr);
  var
    VolName, FilePath, DOSVolumeFileName: string;
  begin { UpdateVolumeInfoTable }
    with VolumeInfoTable do
      begin
        if BrowseForFile('Volume containing the .CODE file', FilePath, VOL_EXT, VOLUMEFILTERLIST) then
          begin
            DOSVolumeFileName := ExtractFileName(FilePath);
            if Locate(IndexName_DOSVOLUMEFILENAME, DOSVolumeFileName, [loCaseInsensitive]) then
              Edit
            else
              begin
                Append;
                fldDOSVolumeFileName.AsString := DOSVolumeFileName;
                fldDOSFilePath.AsString       := ExtractFilePath(FilePath);
              end;

            VolName := '';
            GetString( Format('Input Listing: %s', [aListingFileName]),
                       Format('p-Sys Volume %s was compiled from', [VolName]),
                       VolName,
                       CHARS_PER_IDENTIFIER,
                       ecUpperCase);
            fldpSysVolumeName.AsString    := UCSDName(VolName);
            fldVersionNr.AsString         := VersionNrToAbbrev(VersionNr);
            Post;
          end;
      end;
  end;  { UpdateVolumeInfoTable }

begin { TfrmBuildDBDBMain.BuildDataBaseFromListing }
  AssignFile(fOutputFile, aOutputFileName);
  ReWrite(fOutputFile);
  WriteLn(fOutputFile,
           'Seg#,SegName,Proc#,ProcName,FullProcName,Result,Action');
  frmUpdateConfirm := TfrmUpdateConfirm.Create(self, 'Procedures', '');
  try
    with frmFileParameters do
      begin
        Processed := ProcessFile(VersionNr, aListingFileName);
        Memo1.Lines.Add(Format('%d lines processed in file %s', [Processed, aListingFileName]));
        Application.ProcessMessages;

        // update the volumeinfo table
        VolumeInfoTable := TVolumeInfoTable.Create(self, aDatabaseFileName, TableNameVOLUMEINFO, [optLevel12]);
        VolumeInfoTable.Open;

        // and the SegmentInfoTable
//      SegmentInfoTable := TSegmentInfoTable.Create(self, aDatabaseFileName, TableNameSEGMENTINFO, [optLevel12]);
//      SegmentInfoTable.Open;

        // Populate the pCodesProcTable
        pCodesProcTable := TpCodesProcTable.Create(self, aDataBaseFileName, TableNamePCODEPROCS, [optLevel12]);
        pCodesProcTable.Open;

        try
          Processed := 0;  AddedPPT := 0; UpdatedPPT := 0;
          SkippedPPT := 0;

          if fSegmentInfoList.Count > 0 then
            begin // assume that all of the segments/procedures came from the same volume
              SegmentInfo   := fSegmentInfoList.Objects[0] as TSegmentInfo;
              with SegmentInfo do
                if Procedures.Count > 0 then
                  UpdateVolumeInfoTable(TProcedureInfo(Procedures.Objects[0]), VersionNr);

              for sn := 0 to fSegmentInfoList.Count-1 do
                begin
                  SegmentInfo   := fSegmentInfoList.Objects[sn] as TSegmentInfo;

                  with SegmentInfo do
                    begin
                      for pn := 0 to Procedures.Count-1 do
                        begin
                          ProcedureInfo := TProcedureInfo(Procedures.Objects[pn]);

//                        UpdateSegmentInfo(ProcedureInfo);

                          with pCodesProcTable, ProcedureInfo do
                            begin
                              RecFound := Locate(IndexName_SEGNAME_PROC_NR_NAME_INDEX,
                                        VarArrayOf([xSegmentName, ProcedureNumber, ProcedureName]),
                                        [loCaseInsensitive]);
                              if not RecFound then // We may not know the procedure name yet. Try with just the number
                                RecFound := Locate(IndexName_SEGMENT_PROC_NUMBER_INDEX,
                                        VarArrayOf([xSegmentName, ProcedureNumber]), [loCaseInsensitive]);
                              if RecFound then
                                begin
                                  sn2  := fSegmentInfoList.GetIndexOfSegmentNumber(ProcedureInfo.SegmentNumber);
                                  if sn2 >= 0 then
                                    begin
                                      What := ProcedureIdentifier(fSegmentInfoList[sn2], ProcedureInfo);

                                      if frmUpdateConfirm.OkToOverWriteWhat( What,
                                                                             OverWriteOptions,
                                                                             fldDecodedPCode.AsString,
                                                                             ProcedureBody.Text,
                                                                             RecFound,
                                                                             ProcedureInfo) then
                                        begin
                                          Edit;
                                          Inc(UpdatedPPT);
                                          ActionTaken := 'Updated';
                                          MyUpdateStatusFmt('Updated %d:%s.%s', [ProcedureNumber, xSegmentName, ProcedureName]);
                                          CanOverWrite := true;
                                        end
                                      else
                                        begin
                                          MyUpdateStatusFmt('Skipped %d:%s.%s', [ProcedureNumber, xSegmentName, ProcedureName]);
                                          Inc(SkippedPPT);
                                          ActionTaken := 'Skipped';
                                          CanOverWrite := false;
                                        end;
                                    end
                                  else
                                    begin
                                      MyUpdateStatusFmt('System error? Could not find segment info for SegmentNumber = %d',
                                                        [ProcedureInfo.SegmentNumber]);
                                      CanOverWrite := false;
                                    end;
                                end
                              else
                                begin
                                  CanOverWrite := true;
                                  Append;
                                  Inc(AddedPPT);
                                  ActionTaken := 'Added';
                                  MyUpdateStatusFmt('Added   %d:%s.%s', [ProcedureNumber, xSegmentName, ProcedureName]);
                                end;

                              if CanOverWrite then
                                begin
                                  fldSegmentName.AsString       := UCSDName(xSegmentName);
//                                fldSegmentNameFull.AsString   := xSegmentNAme;
                                  fldProcedureName.AsString     := UCSDName(ProcedureName);
                                  fldProcedureNameFull.AsString := ProcedureNameFull;
                                  fldProcedureNumber.AsInteger  := ProcedureNumber;
                                  fldSourceCode.AsString        := ProcedureBody.Text;
                                  fldVersionNr.AsString         := VersionNrToAbbrev(VersionNr);
                                  fldSegmentID.AsInteger        := SegmentNumber;

                                  Temp := '';
                                  WriteVarGroup('LOCAL VARIABLES', VarList);
                                  WriteVarGroup('HIDDEN VARIABLES', '');
                                  WriteVarGroup('PARAMETERS', ParamList);
                                  WriteVarGroup('RESULT', ResultTypeName);
                                  fldProcParameters.AsString := temp;
                                end;

                              // Save the body
                              Body := '';
                              if ProcedureBody.Count > 0 then
                                begin
                                  for i := 0 to ProcedureBody.Count-1 do
                                    Body := Body + ProcedureBody[i] + CRLF;
                                end;

                              if CanOverWrite then
                                Post;

                              WriteLn(fOutputFile,
                                       SegmentNumber, ',',
                                       xSegmentName, ',',
                                       ProcedureNumber, ',',
                                       ProcedureName, ',',
                                       ProcedureNameFull, ',',
                                       ResultTypeName,',',
                                       ActionTaken);
                              Inc(Processed);
                            end;
                        end;
                    end;
                end;
            end;

          MyUpdateStatusFmt('%d records processed' + CRLF +
                          '  pCodeProcs: %d Added, %d Updated, %d Skipped' + CRLF +
                          '  to database %s',
                          [Processed,
                           AddedPPT, UpdatedPPT, SkippedPPT,
                           DataBaseFileName]);
        finally
          FreeAndNil(pCodesProcTable);
//        FreeAndNil(SegmentInfoTable);
          FreeAndNil(VolumeInfoTable);
        end;
      end;
  finally
    FreeAndNil(frmUpdateConfirm);
    CloseFile(fOutputFile);
    MyUpdateStatusFmt('Report written to %s', [aOutputFileName]);
  end;
end;  { TfrmBuildDBDBMain.BuildDataBaseFromListing }

procedure TfrmBuildDBDBMain.BuildUglySourceFromListing(const aListingFileName,
                                     aOutputFileName: string);
var
  sn, pn: integer;
  Processed: integer;
  SegmentInfo    : TSegmentInfo;
  ProcedureInfo  : TProcedureInfo;
begin
  AssignFile(fOutputFile, aOutputFileName);
  ReWrite(fOutputFile);
  try
    with frmFileParameters do
      begin
        Processed := ProcessFile(VersionNr, aListingFileName);
        Memo1.Lines.Add(Format('%d lines processed in file %s', [Processed, aListingFileName]));
        Application.ProcessMessages;

        Processed := 0;
        for sn := 0 to fSegmentInfoList.Count-1 do
          begin
            SegmentInfo   := fSegmentInfoList.Objects[sn] as TSegmentInfo;
            with SegmentInfo do
              begin
                for pn := 0 to Procedures.Count-1 do
                  begin
                    ProcedureInfo := TProcedureInfo(Procedures.Objects[pn]);
                    with ProcedureInfo do
                      WriteLn(fOutputFile, ProcedureBody.Text);
                      
                    Inc(Processed);
                  end;
              end;
          end;

          MyUpdateStatusFmt('%d procedures written to output file %s',
                          [Processed, aOutputFileName]);
      end;
  finally
    CloseFile(fOutputFile);
  end;
end;


procedure TfrmBuildDBDBMain.BuildUglySourceFromListing1Click(
  Sender: TObject);
begin
  with frmFileParameters do
    begin
      FunctionType := ftBuildUglySource;
      if ShowModal = mrOK then
        BuildUglySourceFromListing(InputListingFileName, OutputFileName);
    end;
end;

procedure TfrmBuildDBDBMain.VersionReporter( const line: string);
begin
  Memo1.Lines.Add(Line);
end;


procedure TfrmBuildDBDBMain.ScanListingforVersionNumber1Click(
  Sender: TObject);
var
  aVersionNr: TVersionNr;
  Msg: string;
  ErrorCount: integer;
  luo: TListingUtilitiesObject;
begin
  luo := TListingUtilitiesObject.Create;
  try
    with frmFileParameters do
      begin
        FunctionType := ftScanFileForVersionNr;
        InputListingFileName := 'F:\ndas-i\d7\Projects\pSystem\Listings\Compiler-I5-Listing.txt';
        if ShowModal = mrOK then
          begin
            with luo do
              begin
                InputListingFileName := frmFileParameters.InputListingFileName;
                ReportsPath          := frmFileParameters.ReportsPath;
                GenerateOutputFiles  := frmFileParameters.GenerateOutputFiles;
                ScanListingFileForBestVersion(aVersionNr, ErrorCount, WriteCSVLine, VersionReporter);
              end;
            Msg := Format('The listing %s was most likely created by compiler version %s. There were %d errors.',
                       [InputListingFileName, VersionNrStrings[aVersionNr].Name, ErrorCount]);
            MyUpdateStatus(Msg);
            rgVersionNr.Visible  := true;
            VersionNr := aVersionNr;
          end;
      end;
  finally
    FreeAndNil(luo);
  end;
end;

procedure TfrmBuildDBDBMain.CleanupCompilerListingSentToCONSOLE1Click(
  Sender: TObject);
var
  ErrorCount: integer;
  luo: TListingUtilitiesObject;
  Msg: string;
begin
  ErrorCount := 0;
  luo := TListingUtilitiesObject2.Create;
  try
    with frmFileParameters do
      begin
        FunctionType         := ftCleanCompilerListing;
        InputListingFileName := 'F:\NDAS-I\d7\Projects\pSystem\Listings\V1.4\SYSLIST-I4-1.TXT';
        OutputFileName       := 'c:\temp\' + ExtractFileName(InputListingFileName);
        if ShowModal = mrOK then
          begin
            with luo do
              begin
                InputListingFileName := frmFileParameters.InputListingFileName;
                OutputFileName       := frmFileParameters.OutputFileName;
                GenerateOutputFiles  := true;
                ListingFormat        := frmFileParameters.ListingFormat;
                CleanCompilerListingSentToConsole(VersionNr, ErrorCount);
              end;
            Msg := Format('%d errors occurred when creating %s', [ErrorCount, OutputFileName]);
            MyUpdateStatus(Msg);
            EditTextFile(OutputFileName);
          end;
      end;
  finally
    FreeAndNil(luo);
  end;
end;

procedure TfrmBuildDBDBMain.QDCleanupofProcedureNames1Click(
  Sender: TObject);
var
  aSegmentName: string;
  UpdateCnt : integer;
begin
  FreeAndNil(pCodesProcTable);
  try
    with frmFileParameters do
      begin
        FunctionType := ftFixProcNames;
        if ShowModal = mrOk then
          begin
            pCodesProcTable := TpCodesProcTable.Create(self, DataBaseFileName, TableNamePCODEPROCS, [optLevel12]);
            if GetString('Segment to process', 'Segment Name', aSegmentName, 8, ecUpperCase) then
              with pCodesProcTable do
                begin
                  aSegmentName := UCSDName(aSegmentName);
                  Open;
                  First;
                  UpdateCnt := 0;
                  while not Eof do
                    begin
                      if SameText(aSegmentName, Trim(fldSegmentName.AsString)) then
                        begin
                          Edit;
                          fldProcedureName.AsString := UCSDName(fldProcedureNameFull.AsString);
                          Post;
                          inc(UpdateCnt);
                        end;
                      Next;
                    end;
                  MyUpdateStatus(Format('%d records were updated', [UpdateCnt]));
                end;
          end;
      end;
  finally
    FreeAndNil(pCodesProcTable);
  end;
end;

(* THIS IS INCORRECT!
function TfrmBuildDBDBMain.GetCPOffset: word;
type
  TWordBuf = array[0..255] of word;
  TWordBufPtr = ^TWordBuf;
begin
  result := TWordBufPtr(fBuffer)[SEGCONST_ div 2];
end;
*)

(* and so is this.
function TfrmBuildDBDBMain.GetCPOffset: word;
begin
  result := GetWordAt(SEGCONST_ div 2)
end;
*)

end.
