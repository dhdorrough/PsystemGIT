unit ListingUtilitiesObject;

interface

uses
  Interp_Decl, Interp_Const, DBDBParameters;

type
  TErrNum = (ERR_NOERROR, ERR_PROCESSLISTINGLINE, ERR_BADSEGNUM, ERR_BADLINENUMBER, ERR_OFFSETISZERO);

  TVersionReporter = procedure {VersionReporter}(const Line: string) of object;

  TWriteLineProc   = procedure {WriteLine}( const line: string;
                                            LineNumber: integer = 0;
                                            SegNumber: integer = 0;
                                            ProcNum: integer = 0;
                                            Offset: integer = 0;
                                            const Source: string = '';
                                            DataSeg: boolean = false;
                                            NestingLevel: integer = 0;
                                            LineIsError: TErrNum = ERR_NOERROR) of object;

  TListingUtilitiesObject = class
  private
    fReportFile: TextFile;
    fInputListingFileName: string;
    fReportsPath: string;
    fOutputFileName: string;
    fInputFile: TextFile;
    fReportFileName: string;
    fGenerateOutputFiles: boolean;
    fListingFormat: TListingFormat;
    function CalcReportName(aVersionNr: TVersionNr): string; virtual;
    procedure OpenInputFile; virtual;
    procedure OpenOutputFile(aVersionNr: TVersionNr); virtual;
    procedure CloseInputFile; virtual;
    procedure CloseOutputFile; virtual;
  public
    procedure CleanCompilerListingSentToConsole(
                                             VersionNr: TVersionNr;
                                         var ErrorCount: integer);
    procedure ScanListingFile( const FileName,
                                     ReportsPath: string;
                               VersionNr: TVersionNr;
                               var ErrorCount: integer;
                                   WriteLineProc: TWriteLineProc);
    procedure ScanListingFileForBestVersion( var VersionNr: TVersionNr;
                                             var ErrorCount: integer;
                                             WriteLineProc: TWriteLineProc;
                                             VersionReporter: TVersionReporter = nil);
    procedure WriteCSVLine( const line: string;
                            LineNumber, SegNumber,
                            ProcNum, Offset: integer;
                            const Source: string;
                            DataSeg: boolean;
                            NestingLevel: integer;
                            ErrNum: TErrNum = ERR_NOERROR);
    procedure WriteListingLine( const line: string;
                            LineNumber, SegNumber,
                            ProcNum, Offset: integer;
                            const Source: string;
                            DataSeg: boolean;
                            NestingLevel: integer;
                            ErrNum: TErrNum = ERR_NOERROR);
    property InputListingFileName: string
             read fInputListingFileName
             write fInputListingFileName;
    property ReportsPath: string
             read fReportsPath
             write fReportsPath;
    property OutputFileName: string
             read fOutputFileName
             write fOutputFileName;
    property GenerateOutputFiles: boolean
             read fGenerateOutputFiles
             write fGenerateOutputFiles;
    property ListingFormat: TListingFormat
             read fListingFormat
             write fListingFormat;
  end;

  TListingUtilitiesObject2 = class(TListingUtilitiesObject)
  private
    procedure OpenInputFile; override;
    procedure OpenOutputFile(aVersionNr: TVersionNr); override;
    function CalcReportName(aVersionNr: TVersionNr): string; override;
  public
  end;

implementation

uses
  MyUtils, ListingUtils, SysUtils;

  procedure TListingUtilitiesObject.WriteCSVLine( const line: string;
                                                LineNumber,
                                                SegNumber,
                                                ProcNum,
                                                Offset: integer;
                                                const Source: string;
                                                DataSeg: boolean;
                                                NestingLevel: integer;
                                                ErrNum: TErrNum = ERR_NOERROR);
var
  Msg: string;
begin
  case ErrNum of
    ERR_NOERROR             : Msg := '';
    ERR_BADSEGNUM           : Msg := 'Bad Segment Number';
    ERR_BADLINENUMBER       : Msg := 'Bad Line Number';
    ERR_OFFSETISZERO        : Msg := 'Offset is zero';
    ERR_PROCESSLISTINGLINE  : Msg := 'From ProcessListingLine';
  end;
  if ErrNum <> ERR_NOERROR then
    Msg := '***** ' + Msg;
  WriteLn(fReportFile, LineNumber, ',',
                      SegNumber, ',',
                      ProcNum, ',',
                      Offset, ',',
                      TFString(DataSeg), ',',
                      NestingLevel, ',',
                      Quoted(Line), ',',
                      Msg);
end;

procedure TListingUtilitiesObject.ScanListingFile( const FileName, ReportsPath: string;
                                                         VersionNr: TVersionNr;
                                                   var ErrorCount: integer;
                                                   WriteLineProc: TWriteLineProc);
var
  Line: string;
  LineNumber, PrevLineNumber: integer;
  SegNumber: integer;
  ProcNum: integer;
  Offset: integer;
  Source: string;
  DataSeg: boolean;
  LineIsError: boolean;
  NestingLevel: integer;
  BAD_FIRST_CHAR: TSetOfChar;
  ErrNum: TErrNum;

  function CleanUp(const Line: string): string;
  var
    pp: integer;
  begin
    result := Line;
    if Length(Line) > 0 then
      begin
        if result [1] = '<' then    // This occurs when dumping the CONSOLE: listing straight to a file
          begin
            pp := Pos('>', result);
            if pp > 0 then
              Delete(result, 1, pp);
          end;
        if result[1] = '.' then     // This occurs when dumping the CONSOLE: listing straight to a file
          Delete(result, 1, 1) else
      end
  end;

begin { ScanListingFile }
  BAD_FIRST_CHAR := ANY_ALPHA+DELIM_SET+[FF]-['.', '<', ' '];
  ErrorCount := 0;
  OpenInputFile;
  OpenOutputFile(VersionNr);
  try
    PrevLineNumber := -1; LineNumber := -1;
    while not eof(fInputFile) do
      begin
        ReadLn(fInputFile, Line);
        if (Length(Line) > 0) and (not (Line[1] in BAD_FIRST_CHAR)) then
          begin
            ErrNum := ERR_NOERROR;
            if Pos('* SYSTEM *)', Line) > 0 then
              ErrNum := ErrNum;   // a nice place for a break
            LineIsError := not ProcessListingLine( VersionNr,
                                                   line,
                                                   LineNumber,
                                                   SegNumber,
                                                   ProcNum,
                                                   Offset,
                                                   Source,
                                                   DataSeg,
                                                   NestingLevel);
            if LineIsError then
              ErrNum := ERR_PROCESSLISTINGLINE;
            if (SegNumber = 0) and (VersionNr > vn_VersionI_4) then      // can be 0 in Version I4
              ErrNum := ERR_BADSEGNUM;
            if (LineNumber = 0) or (LineNumber <= PrevLineNumber) then
              ErrNum := ERR_BADLINENUMBER;
//          if ((Offset = 0) and (NestingLevel <> 0)) then     // This causes the 1st line of every procedure to be flagged
//            ErrNum := ERR_OFFSETISZERO;

            if ErrNum <> ERR_NOERROR then
              LineIsError := true;

            if LineIsError then
              Inc(ErrorCount);

            if GenerateOutputFiles then
              WriteLineProc( line,
                             LineNumber,
                             SegNumber,
                             ProcNum,
                             Offset,
                             Source,
                             DataSeg,
                             NestingLevel,
                             ErrNum);
          end;
        PrevLineNumber := LineNumber;
      end;
  finally
    CloseOutputFile;
    CloseInputFile;
  end;
end;  { ScanListingFile }

procedure TListingUtilitiesObject.CloseOutputFile;
begin
  CloseFile(fReportFile);
end;

procedure TListingUtilitiesObject.CloseInputFile;
begin
  CloseFile(fInputFile);
end;


procedure TListingUtilitiesObject.OpenInputFile;
begin
  AssignFile(fInputFile, InputListingFileName);
  Reset(fInputFile);
end;

procedure TListingUtilitiesObject.OpenOutputFile(aVersionNr: TVersionNr);
begin
  fReportFileName := CalcReportName(aVersionNr);
  AssignFile(fReportFile, fReportFileName);
  ReWrite(fReportFile);
  WriteLn(fReportFile, 'Line#', ',',
                      'Seg#', ',',
                      'Proc#', ',',
                      'Offset', ',',
                      'Data', ',',
                      'Level', ',',
                      'Line', ',',
                      'Error');
end;



function TListingUtilitiesObject2.CalcReportName(aVersionNr: TVersionNr): string;
begin
  result := OutputFileName;
end;

procedure TListingUtilitiesObject.ScanListingFileForBestVersion(
                                         var VersionNr: TVersionNr;
                                         var ErrorCount: integer;
                                         WriteLineProc: TWriteLineProc;
                                         VersionReporter: TVersionReporter);
var
  vn: TVersionNr;
  BestVersionErrorCount: integer;
  BestVersionNr: TVersionNr;
  Msg: string;
begin { ScanListingFileForBestVersion }
  BestVersionNr         := vn_Unknown;
  BestVersionErrorCount := High(Smallint);
  for vn := Succ(Low(TVersionNr)) to vn_VersionIV do
    begin
      ScanListingFile(CalcReportName(vn), ReportsPath, vn, ErrorCount, WriteLineProc);
      Msg := Format('%-12s had %4d errors', [VersionNrStrings[vn].Name, ErrorCount]);
      VersionReporter(Msg);
      if ErrorCount < BestVersionErrorCount then
        begin
          BestVersionErrorCount := ErrorCount;
          BestVersionNr         := vn;
        end;
    end;
  VersionNr  := BestVersionNr;
  ErrorCount := BestVersionErrorCount;
end;  { ScanListingFileForBestVersion }

procedure TListingUtilitiesObject.WriteListingLine(const line: string;
                            LineNumber, SegNumber,
                            ProcNum, Offset: integer;
                            const Source: string;
                            DataSeg: boolean;
                            NestingLevel: integer;
                            ErrNum: TErrNum = ERR_NOERROR);
begin
  case ListingFormat of
    lfAsCompilerListing:
      WriteLn(fReportFile, Line);
    lfAsCompilerSource:
      WriteLn(fReportFile, Source);
  end;
end;


procedure TListingUtilitiesObject.CleanCompilerListingSentToConsole(
                                         VersionNr: TVersionNr;
                                         var ErrorCount: integer);
begin { CleanCompilerListingSentToConsole }
  ScanListingFile(InputListingFileName, ReportsPath, VersionNr, ErrorCount, WriteListingLine);
end;  { CleanCompilerListingSentToConsole }


{ TListingUtilitiesObject2 }

function TListingUtilitiesObject.CalcReportName(aVersionNr: TVersionNr): string;
begin
  result := InputListingFileName + ExtractFileBase(ReportsPath) + '_' + VersionNrStrings[aVersionNr].Abbrev + '.CSV';
end;

procedure TListingUtilitiesObject2.OpenInputFile;
begin
  inherited;
end;

procedure TListingUtilitiesObject2.OpenOutputFile(aVersionNr: TVersionNr);
begin
  fReportFileName := CalcReportName(aVersionNr);
  AssignFile(fReportFile, fReportFileName);
  ReWrite(fReportFile);
end;

end.
