unit pSysVolumes;

interface

uses
  pSysDrivers, pSys_Decl, Search_Decl, Classes, MyUtils, Interp_Const, pSys_Const, CRTUnit;

const
  kANYFILE    = $FFFF;
  DEFAULT_FILTER = '*';
  CNOSPACE = 'Insufficient volume space to place file %s';
  BLOCKSIZE = 512;
  MAX_FILER_UNITNR    = 127;
  MAX_STANDARD_UNIT   = 74;

type

  integer = SmallInt;

type
  TBytes = array[0..MaxInt - 1] of Byte;

  TempBufType = PACKED ARRAY[0..1023] OF byte;
  TempBufPtr  = ^TempBufType;

  TOnPutIOResult = procedure {PutIOResult}(IOResult: integer) of Object;

  TVolume = class;
  
  TSearchFoundProc = procedure {SearchFoundProc} ( const FilePath, FileName, Line: string;
                                                   LastAccessTime: TDateTime;
                                                   const DOSFilePath: string = '') of object;
  TSVOLFreeProc    = procedure {SVOLFreeProc} (const VolumeBeingFreed: TVolume) of object;
  TDriverCall      = procedure {name} of object;

  TID = STRING[TIDLENG];

  LongString = string;

  TPageBuf = packed array[0..BUFSIZ] of char;

  TVolStatus = (vsUnknown, vsDosLoaded, vsPsysLoaded, vsSVOLLoaded);

  DIRRANGE = 0..MAXDIR;

  TVolumeInfo = record
                  VolumeName: string;
                  TheVolume: TVolume;
                  UnitNumber: integer;
                  ParentUnitNumber: integer;
                  RefCount: integer;
                end;

  DATEREC = word;   // Delphi dosen't pack as well as the p-system.
                    // Must use a word to get the same size

(* should switch to use the definition in UCSDGLOB --
   but there is an unresolved problem related to packing *)
  DIRENTRY = packed RECORD  // UCSD p-System version
               DFIRSTBLK: INTEGER;          {FIRST PHYSICAL DISK ADDR}
               DLASTBLK: INTEGER;           {POINTS AT BLOCK FOLLOWING}
               CASE DFKIND: word {FILEKIND} OF // dhour[5]: 0 means invalid time.
                                               //           subtract 1 for correct hour
                                               // dminute[6]:
                                               // status[1]:
                 kSECUREDIR,
                 kUNTYPEDFILE:               {normally in DIR[0]..vol info}
                   (DVID: STRING[VIDLENG];
                    DEOVBLK: INTEGER;       {LASTBLK OF VOLUME}
//                  DNUMFILES: DIRRANGE;    {NUM FILES IN DIR}  // Not this- High byte might be mis-interpreted
                    DNUMFILES: word;        {NUM FILES IN DIR}
                    DLOADTIME: word;        {TIME OF LAST ACCESS}
                    DLASTBOOT: DATEREC);    {MOST RECENT DATE SETTING}
                 kXDSKFILE,
                 kCODEFILE,
                 kTEXTFILE,
                 kINFOFILE,
                 kDATAFILE,
                 kGRAFFILE,
                 kFOTOFILE,
                 kSVOLFILE:
                   ({DTIME: WORD;}
                    {dhour: 0..24;      // 0 means invalid time.
                                        // subtract 1 for correct hour
                     dminute: 0..59;
                     status: boolean; } { these are packed after the end of the DFKIND }
                    DTID: TID;              {TITLE OF FILE}
                    DLASTBYTE: 1..BLOCKSIZE;      {NUM BYTES IN LAST BLOCK}
                    DACCESS: DATEREC)       {LAST MODIFICATION DATE}
             END {DIRENTRY};

  TDirEntry = record    // Delphi version
                FirstBlk: word;          {FIRST PHYSICAL DISK ADDR}
                LASTBLK: word;           {POINTS AT BLOCK FOLLOWING}
                CASE xDFKind: word {FILEKIND} OF
                  kSECUREDIR,
                  kUNTYPEDFILE:              {normally in DIR[0]..vol info}
                    (DVID: STRING[VIDLENG];
                     DEOVBLK: INTEGER;       {LASTBLK OF VOLUME}
                     DNUMFILES: DIRRANGE;    {NUM FILES IN DIR}
                     DLOADTIME: INTEGER;     {TIME OF LAST ACCESS}
                     LastBoot: TDateTime);   {MOST RECENT DATE SETTING}
                  kXDSKFILE,
                  kCODEFILE,
                  kTEXTFILE,
                  kINFOFILE,
                  kDATAFILE,
                  kGRAFFILE,
                  kFOTOFILE,
                  kSVOLFILE:
                    (FileNAME: TID;              {TITLE OF FILE}
                     LASTBYTE: 1..BLOCKSIZE;      {NUM BYTES IN LAST BLOCK}
                     DateAccessed: TDateTime      {LAST MODIFICATION DATE}
                     )
              end;

  PDirEntry = ^TDirEntry;

  TBlock = array[0..BLOCKSIZE-1] of byte;

  TBlockFile = file of TBlock;

  TBlockBuffer = packed array[0..BLOCKSIZE] of char;
  TVolumesList = array[0..MAX_FILER_UNITNR] OF TVolumeInfo;
  
  fcb =
    record
      FileName  : TID;
//    line      : string[255];    { current text line }
      bpos      : INTEGER;          { buffer position }
      buf       : TPageBuf;
      Buffer    : pchar;
      EndFile   : boolean;        { true when end of file }
      LastBlock : integer;
      LineNr    : integer;
      BlkNr     : integer;
      NrLines   : system.integer;
    end;

  TVolume = class(TDriver)
  private
    fFilter           : string;
    fDOSFolderName    : string;
    fOKToOverWrite    : boolean;
    fOnPutIOResult    : TOnPutIOResult;
    fOnStatusProc     : TStatusProc;
    fOnSVOLFree       : TSVOLFreeProc;
    fOutputRootFolder : string;
    fParentBlockCount : integer;
    fParentName       : string;
    fOnSearchFound    : TSearchFoundProc;
    fVersionNr        : TVersionNr;

    function  GetDOSFolderName: string;
    procedure SetDOSFolderName(const Value: string);
    procedure ReadLine(var phyle: fcb; var s: longstring);
    function  OkToOverWriteExistingFile(const FileName: string): boolean;
    procedure SetFilter(const Value: string);
    procedure UpdateDirectoryEntry(DirIdx: integer);
    procedure DeleteDirectoryEntry(DirIdx: integer);
//  function  CloseVolumeFile(ConfirmUpdate: boolean = true): boolean;
    procedure CheckVolume;
    procedure LoadSVOLInfo( const ParentVolumeFileName: string;
                            ParentDirEntry: TDirEntry;
                            ParentBlockCount: integer;
                            ParentName: string;
                            DirBlockNr: integer = DIRECTORY_BLOCKNR);
    function GetDOSFileName: string;
    procedure SetDOSFileName(const Value: string);
    procedure ScanTextFile(DirIdx: integer; SearchInfoPtr: TSearchInfoPtr);
    procedure ErrorMessageProc(const Msg: string; Args: array of const);
    procedure UpdateStatus(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true);
    procedure SearchFound(const FilePath, FileName, Line: string;
                LastAccessTime: TDateTime; const DOSFilePath: string = '');
    procedure ShowMessage(const Msg: string);
    procedure CheckBlockCount(result, NrBlocks: integer);
    procedure PutIOResult(IOResult: integer); virtual;
    procedure SetOnPutIOResult(const Value: TOnPutIOResult);
    procedure SegmentInfoScan(DirIdx: integer; const OutputFile: TextFile; SearchInfoPtr: TSearchInfoPtr);
    procedure ProcedureInfoScan(DirIdx: integer; const OutputFile: TextFile; SearchInfoPtr: TSearchInfoPtr);
  protected
    fCurrentBlockNumber: longint;
    fDirectoryChanged : boolean;
    fDirectoryChangedBy: string;
    fDOSFileName      : string;
    fVolStartBlockInParent : integer;
    procedure BlockError(NrBlocks, BlocksExpected: Longint; BlockNr: integer);
    procedure CheckBlockOffset(BlockNr: integer);
  public
    CurrentSVOL   : TVolume;
    Directory     : array [DirRange] of TDirentry;

    // WARNING: Changes to the Directory should be made to DI.RECTORY[] -- NOT to "Directory" -
    //          Because changes to Directory do NOT get saved.
    DI            : RECORD CASE BOOLEAN OF
                      TRUE: (RECTORY: ARRAY [DIRRANGE] OF DIRENTRY);
                      FALSE:(RBLOCKS: ARRAY[1..DIRECTORYBLOCKS] OF ARRAY[1..BLOCKSIZE] OF CHAR)
                    END;
    StartingDOSBlockInFile: integer;
    VolStatus     : TVolStatus;
    NumFiles      : integer;
    VolumeName    : string;
    VolumeFile    : file;
    DeovBlk       : integer;
    HasDupDir     : boolean;

    function  CloseVolumeFile(ConfirmUpdate: boolean = true): boolean;
    function Dispatcher(Request, BlockNr, Len: word; var Buffer; Control: word): TIORsltWD; override;
    function  BlockRead(var buffer{: Pointer};
                            recCnt: Integer): Longint; virtual;
    function  BlockWrite(var buffer{: Pointer};
                            recCnt: Longint): Longint; virtual;
    function CleanUpDirectory: boolean;
    Constructor Create( aOwner: TObject;
                        aDOSFileName: string;
                        aVersionNr: TVersionNr = vn_Unknown;
                        aVolStartBlockInParent: integer = 0); reintroduce; virtual;
    Destructor Destroy; override;
    function  CopyDosTxtToPSysText(     DOSFilePath: string;
                                PSysFileName: string;
                            var ErrorMessage: string;
                                ConfirmUpdate: boolean = true): boolean;
    function  CopyDosToPSys(DosFilePath, PSysFileName: string;
      var ErrorMessage: string): boolean;
    procedure CopySingleFile(FileNumber: integer; aDOSFileName: string = '');
    procedure CopySingleDataFile(FileNumber: integer; aDOSFileName: string = '');
    procedure CopySingleTextFile(FileNumber: integer; aDOSFileName: string = '');
    procedure CopyToVolume(SourceName, DestName: string; DestVol: TVolume; var ErrorMessage: string);
    property  CurrentBlockNumber: longint
              read fCurrentBlockNumber
              write fCurrentBlockNumber;
    function  DeletePSystemFile(DirIdx: integer): boolean; overload;
    function  DeletePSystemFile(FileIDString: string): boolean; overload;
    function  DirIdxFromString(const FileIdString: string): integer;
    procedure LoadVolumeInfo(DirBlockNr: integer);
    procedure CopyAllFilesToDOS(OutputFolder: string; OKToOverWrite: boolean; FileKind: word);
    procedure CopyAllTextFilesToDOS(OutputFolder: string; OKToOverWrite: boolean; xDFKIND: INTEGER);
    procedure CopyAllFilesToDOSInBinary(OutputFolder: string; OKToOverWrite: boolean);
    procedure CreateVolume(var DOSVolumeName: string; NrBlocks: integer; DirBlockNr: integer = DIRECTORY_BLOCKNR);
    procedure DirectoryChanged(const by: string);
    function  FindEmptySpace(BlocksNeeded: integer): integer;
    function  FindDirectoryEntry(const FileName: string): PDirEntry; overload;
    function  FindDirectoryEntry(const FileName: string; var DirIdx: integer): PDirEntry; overload;
    function  FixTextName(FileName: string): string;
    function  IsCodeFile(DirIdx: integer): boolean;
    procedure MountSVOL(DirIdx: integer);
    function PartialBlockReadRel(var buf; BytesToRead: longint; RelBlock: integer): longint;
    procedure pSysFileNames(List: TStringList; IncludeVolumeName: boolean);
    function  PSysNameFromDosName(const DosFilePath, Ext: string): string;
    procedure ResetVolumeFile; virtual;
    procedure ResizeVolume(NewNrBlocks: integer);
    function  RenamePSystemFile(const FileIDString: string; var NewName: string): boolean;
    function  RawStringSearch(SearchFor: string; var BlockNr: integer; var Buffer: TBlockBuffer): boolean;
    procedure ScanVolumeForHexString( SearchInfoPtr: TSearchInfoPtr);
    procedure ScanVolumeForString(SearchInfoPtr: TSearchInfoPtr);
    procedure ScanVolumeForMiscinfo(SearchInfoPtr: TSearchInfoPtr; var OutputFile: textFile);
    procedure ScanVolumeForVersionNumber(SearchInfoPtr: TSearchInfoPtr);
{$IfDef PoolInfo}
    procedure ScanVolumeForPoolInfo(SearchInfoPtr: TSearchInfoPtr; var OutputFile: TextFile);
{$endIf}
    procedure ScanVolumeForProcedureInfo(SearchInfoPtr: TSearchInfoPtr; const OutputFile: TextFile);
    procedure ScanVolumeForSegmentInfo(SearchInfoPtr: TSearchInfoPtr; const OutputFile: TextFile);
    procedure SeekInVolumeFile(BlockNr: longint); virtual;
    function UCSDBlockRead(var buf; Blocks: integer): integer;
    function UCSDBlockReadRel(var buf; Blocks, RelBlock: word): word;
    function UnitRead(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD; virtual;
    function UnitWrite(var Buffer; length, BlockNumber, flag: word): TIORsltWD; override;
    function VolumeBlocks(): integer;
    function WriteDirectoryToDisk(ConfirmUpdate: boolean = true; DirBlockNr: integer = DIRECTORY_BLOCKNR): boolean;
    procedure ZeroDirectory(const VolName: string);

    property DOSFolderName: string
             read GetDOSFolderName
             write SetDOSFolderName;
    property OutputRootFolder: string
             read fOutputRootFolder
             write fOutputRootFolder;
    property OnStatusProc: TStatusProc
             read fOnStatusProc
             write fOnStatusProc;
    property OnSearchFoundProc: TSearchFoundProc
             read fOnSearchFound
             write fOnSearchFound;
    property OnSVOLFree: TSVOLFreeProc
             read fOnSVOLFree
             write fOnSVOLFree;
    property OnPutIOResult: TOnPutIOResult
             read fOnPutIOResult
             write SetOnPutIOResult;
    property Filter: string
             read fFilter
             write SetFilter;
    property DOSFileName: string
             read GetDOSFileName
             write SetDOSFileName;
    property VolStartBlockInParent: integer
             read fVolStartBlockInParent
             write fVolStartBlockInParent;
    property VersionNr: TVersionNr
             read fVersionNr
             write fVersionNr;
  end;

function  CreateVolume( aOwner: TObject;
                        const aDOSFileName: string;
                        aVersionNr: TVersionNr = vn_Unknown;
                        aVolStartBlockInParent: integer = 0): TVolume;
function  FixDFKind(aDFKind: word): word;
function  PackDFKind(aDFKind: word; NewKind: word): word;
function  PSysFileType(DFKIND: word): string;
function  ScanEQ(Length: integer; chs: TSetOfChar; Buf: TPageBuf; StartIndex: integer): integer; forward;
function  ScanNE(Length: integer; chs: TSetOfChar; Buf: TPageBuf; StartIndex: integer): integer; forward;


implementation

uses pSysExceptions, SysUtils, pSysDatesAndTimes, BitOps, Misc, UCSDGlob,
  segmap, DiskFormatUtils, pSysVolumesNonStandard, MiscinfoUnit,
  Interp_Decl, ProcedureMapping, MyDelimitedParser, UCSDInterpreter,
  PsysUnit, FileNames;

const
  MAXBLOCKCOUNT = 225;
  MAXBLOCKSIZE = MAXBLOCKCOUNT * BLOCKSIZE;

function PackDFKind(aDFKind: word; NewKind: word): word;
begin
   result := (aDFKind and $FFF0) or NewKind;
end;

function FixDFKind(aDFKind: word): word;
begin { FixDfkind }
  result := aDFKIND and $F;
END;  { FixDfkind }

function PSysFileType(DFKIND: word): string;
begin
  Result := '     file';
  CASE FixDFKind(DFKIND) OF // higher bits are used to store the time
    kXDSKFILE: Result := 'Bad block';
    kCODEFILE: Result := 'Code file';
    kTEXTFILE: Result := 'Text file';
    kINFOFILE: Result := 'Info file';
    kDATAFILE: Result := 'Data file';
    kGRAFFILE: Result := 'Graf file';
    kFOTOFILE: Result := 'Foto file';
    kSVOLFILE: Result := 'SVol file';
    kUNTYPEDFILE: Result := 'Untyped file';
    kSECUREDIR: Result := 'SECUREDIR';
    else
               Result := Format('%4d file', [DFKIND]);
  END;
end;

function FLIP(N: word): word;
  { byte flip an integer }
  VAR
    T: word;
    TEMP: RECORD
            CASE INTEGER OF
              0: (PKD: PACKED ARRAY[0..1] OF 0..255);
              1: (wrd: word)
            END;
begin { flip }
  TEMP.wrd := N;
  T := TEMP.PKD[0];
  TEMP.PKD[0] := TEMP.PKD[1];
  TEMP.PKD[1] := T;
  result := TEMP.wrd;
END;  { flip }

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

{ TVolume }

procedure TVolume.CopyAllFilesToDOS(OutputFolder: string; OKToOverWrite: boolean; FileKind: word);
var
  i: integer;  OK: boolean;
begin
  fOKToOverWrite    := OKTOOverWrite;
  fOutputRootFolder := OutputFolder;
  for i := 1 to NumFiles do
    begin
      OK := (FileKind = kANYFILE) or (Directory[i].xDFKind = FileKind);
      if OK and
         (not Empty(Directory[i].FileName)) and
         Wild_Match(@Directory[i].FileName[1], pchar(fFilter), '*', '?', false) then
        CopySingleFile(i);
    end;
end;

procedure TVolume.CopyAllTextFilesToDOS(OutputFolder: string; OKToOverWrite: boolean; xDFKIND: INTEGER);
var
  i: integer;
begin
  fOKToOverWrite    := OKTOOverWrite;
  fOutputRootFolder := OutputFolder;
  for i := 1 to NumFiles do
    with Directory[i] do
      if (xDFKIND = kTEXTFILE) AND
         (not Empty(FileName)) and
          Wild_Match(@FileName[1], pchar(fFilter), '*', '?', false) then
        CopySingleFile(i);
end;

function TVolume.OkToOverWriteExistingFile(const FileName: string): boolean;
begin { OkToOverWriteExistingFile }
  result := false;
  if fOKToOverWrite then
    result := true
  else
    if YesFmt('The file "%s" already exists. Do you want to overwrite it?',
                  [FileName]) then
      result := true;
end;  { OkToOverWriteExistingFile }

procedure TVolume.CheckBlockOffset(BlockNr: integer);
begin
  if (Directory[0].DEOVBLK > 0) and (BlockNr > Directory[0].DEOVBLK) then
    raise EInvalidBlockNumber.CreateFmt('Seeking Invalid block number (%d) in volume "%s"',
                                    [BlockNr, VolumeName]);

  if fParentBlockCount > 0 then
    if (fVolStartBlockInParent+BlockNr) > fParentBlockCount then
      raise EInvalidBlockNumber.CreateFmt('Seeking to Invalid block number (In Parent %s:%d + Child %s:%d) in volume "%s"',
            [fParentName, fVolStartBlockInParent,
             VolumeName, BlockNr]);
end;


procedure TVolume.CopySingleDataFile(FileNumber: integer; aDOSFileName: string);
var
  pSysFileName: string;
  StartingBlock, NrBlocks: longint;
  BlocksRead, BlocksWritten: longint;
  OutFile: File;
  Phyle: fcb;
begin
  try
    with Directory[FileNumber] do
      begin
        pSysFileName := FileName;

        if Empty(aDOSFileName) then
          aDOSFileName   := ForceBackSlash(DOSFolderName) + FileName;

        if FileExists(aDOSFileName) then
          if not OkToOverWriteExistingFile(aDOSFileName) then
            Exit;

        NrBlocks      := LastBlk - FirstBlk;
        StartingBlock := FirstBlk {+ fSkipBlocks} {skip past the directory};
        CheckBlockOffset(StartingBlock);
        SeekInVolumeFile(fVolStartBlockInParent+StartingBlock);
        GetMem(Phyle.Buffer, NRBLOCKS * BLOCKSIZE);
        try
          BlocksRead := BlockRead(Phyle.Buffer^, NrBlocks);
          if BlocksRead <> NrBlocks then
            raise EIOResult.CreateFmt('BlocksRead failure: NrBlocks (%d) <> Blocksread (%d)',
                                      [NrBlocks, BlocksRead]);
          ForceDirectories(RemoveTrailingBackSlash(ExtractFilePath(aDOSFileName)));
          AssignFile(OutFile, aDOSFileName);
          ReWrite(OutFile, BLOCKSIZE);
          try
            System.BlockWrite(Outfile, Phyle.Buffer^, NrBlocks, BlocksWritten);
            if BlocksWritten <> NrBlocks then
              raise EIOResult.CreateFmt('BlocksRead failure: NrBlocks (%d) <> BlocksWritten (%d)',
                                        [NrBlocks, BlocksWritten]);
            UpdateStatus(Format('Copied file %-15s to %s', [pSysFileName, aDOSFileName]));
          finally
            CloseFile(OutFile);
            if Frac(DateAccessed) = 0 then
              DateAccessed := DateAccessed + Frac(Now);  // if time is not specified, use the current time
            FileSetDate(aDOSFileName, DateTimeToFileDate(DateAccessed));
          end;
        finally
          Dispose(Phyle.Buffer);
          Phyle.Buffer := nil;
        end;
      end;
  except
    on E:Exception do
      Alert(e.message);
  end;
end;

procedure TVolume.ReadLine(var phyle: fcb; var s: longstring);
  const
    TABWIDTH = 8;
  var chg, idx: integer;
      bcnt: LongInt;
      OutLen, I: integer;
      Temp: string;
begin { TVolume.ReadLine }
//{$R- disable string range checks }
  with phyle do
    repeat
      if (Bpos >= bufsiz) or (Buf[bpos] = CHR(0))	then { time for next buffer }  // changed 3/8/2019
        begin
          if (BlkNr >= LastBlock) then { eof }
            begin
              Endfile := true;
              s       := '';
              EXIT{(getstring)}
            end;
          CheckBlockOffset(BlkNr);
          SeekInVolumeFile(fVolStartBlockInParent+BlkNr);
          bcnt := Blockread(buf[0], 2);
          if bcnt = 2 then
            begin
              bpos  := 0;
              blknr := blknr + bcnt;
              if (BlkNr > LastBlock) then { eof }
                begin
                  Endfile := true;
                  s       := '';
                  EXIT{(getstring)}
                end;
            end
          else
            begin
              EndFile := true;
              Exit;
            end;
        end;
      chg := ScanEq(BufSiz-Bpos, [CR,LF], Buf, bpos);

      if (chg >= 0) and ((bpos + chg) < bufsiz) then { found a carriage return (or a line feed?) }
        begin
          if chg > LINEMAX then { something is very wrong }
            begin
              Phyle.EndFile := true;
              s := '';
              Exit;
            end;

//        S[0] := chr(chg);
          SetLength(S, chg);
          if chg > 0 then
            begin
              if (Bpos < 0) or (Bpos >= BUFSIZ) or (Chg >= BUFSIZ) then
                Alert('Buffer error');
              move(buf[bpos], S[1], chg);    { copy string except CR }
            end;
          bpos := bpos + chg + 1;
        end
      else
        begin
          chg := ScanEq(bufsiz-bpos, [#0], buf, bpos); { look for null }
          if (chg >= 1) and ((bpos + chg) < bufsiz) then
            begin
              if chg > LINEMAX then begin Phyle.EndFile := true; s := ''; Exit; end;

              SetLength(S, chg);
              move(buf[bpos], S[1], chg);
//            S[0] := chr(chg);
              bpos := bufsiz;
            end
          else // empty line
            begin
              s := '';
              bpos := bufsiz;
            end;
          if (BlkNr >= LastBlock) then { eof }
            begin
              Endfile := true;
//            Exit;
            end;
        end;
    until chg >= 0;
  idx := 0; OutLen := 0;
  SetLength(Temp, LINEMAX);
  while (Idx < Length(s)) and (OutLen < LINEMAX) do
    begin
      if s[idx+1] = chr(DLE) then { insert blank fill }
        begin
          chg     := ord(s[idx+2])-ORD( ' ' );           // get number of blanks to insert
          for i := 1 to chg do
            begin
              Inc(OutLen);
              if Outlen <= LINEMAX then
                Temp[OutLen] := ' ';
            end;
          Idx := Idx + 2;
        end else
      if s[idx+1] = TAB then   { expand tabs }
        begin
          Chg := TABWIDTH - (Outlen MOD TABWIDTH);
          for i := 1 to chg do
            begin
              Inc(OutLen);
              if Outlen <= LINEMAX then
                Temp[OutLen] := ' ';
            end;
          Inc(Idx);
        end
      else
        begin
          Inc(OutLen);
          Inc(Idx);
          Temp[OutLen] := s[Idx];
        end;
    end;
  SetLength(Temp, OutLen);
  S := Temp;

  Inc(Phyle.NrLines);
//UpdateStatus(Format('Line %d', [Phyle.NrLines]), false, true);
end;  { TVolume.ReadLine }
//{$R+}

procedure TVolume.SearchFound(const FilePath, FileName, Line: string; LastAccessTime: TDateTime; const DOSFilePath: string = '');
begin
  if Assigned(fOnSearchFound) then
    fOnSearchFound(FilePath, FileName, Line, LastAccessTime, DOSFilePath);
end;

procedure TVolume.ScanTextFile(DirIdx: integer; SearchInfoPtr: TSearchInfoPtr);
var
  pSysFileName: string;
  NrBlocks: integer;
  Line: LongString;
  Phyle: fcb;

  procedure CheckLine(const Line: string);
  begin { CheckLine }
    if LineContainsTarget(SearchInfoPtr^, Line) then
      SearchFound(VolumeName, Directory[DirIdx].FileNAME, Line, Directory[DirIdx].DateAccessed, DOSFileName);
  end;  { CheckLine }

begin { TVolume.ScanTextFile }
  try
    with Directory[DirIdx] do
      if (xdfkind = kTEXTFILE) then
        begin
          pSysFileName := FileName;
          CheckLine(pSysFileName);
          NrBlocks      := LastBlk - FirstBlk;

          Assert(Length(pSysFileName) <= TIDLENG, 'SYSTEM ERROR');
          
          Phyle.FileName := pSysFileName;
          Phyle.LineNr  := 0;

          Phyle.bpos    := bufsiz + 1;
          Phyle.EndFile := false;
          Phyle.BlkNr   := FirstBlk + TEXT_HEADER_BLOCKS;
          Phyle.LastBlock := FirstBlk + NrBlocks;

          Phyle.NrLines := 0;
          UpdateStatus(Format('Searching p-System text file: %s:%s', [VolumeName, pSysFileName]), false, true);
          while not (Phyle.EndFile) do
            begin
              try
                ReadLine(Phyle, Line);
                CheckLine(Line);
              except
                on e:Exception do
                  raise EBadFile.CreateFmt('[%s] in %s:%s', [e.Message, VolumeName, pSysFileName]);
              end;
            end;
//        if Assigned(fOnStatusProc) then
//          fOnStatusProc(Format('Copied %4d lines file %-15s to %s', [Phyle.NrLines, pSysFileName, aDOSFileName]));
        end
      else
        raise EInvalidFileNameType.CreateFmt('Invalid file type for string search: %s/%d', [FileName, xDFKIND]);
  except
    on e:Exception do
      if not SearchInfoPtr.Abort then
        Alert(e.Message);
  end;
end;  { TVolume.ScanTextFile }


procedure TVolume.CopySingleTextFile(FileNumber: integer; aDOSFileName: string);
var
  pSysFileName, Ext: string;

  NrBlocks: integer;
  aLine: longstring;
  OutFile: TextFile;
  Phyle: fcb;
begin { TVolume.CopySingleTextFile }
  try
    with Directory[FileNumber] do
      if (xDFKIND in [kTEXTFILE, kDATAFILE]) then
        begin
          pSysFileName := FileName;
          if Empty(aDOSFileName) then
            begin
              aDOSFileName  := FileName;
              Ext          := ExtractFileExt(aDOSFileName);
              if SameText(Ext, '.TEXT') then
                aDOSFileName := ForceExtension(aDOSFileName, 'txt')
              else
                aDOSfileName := aDOSFileName + '.txt';

              aDOSFileName   := ForceBackSlash(DOSFolderName) + aDOSFileName;
            end;

          if FileExists(aDOSFileName) then
            if not OkToOverWriteExistingFile(aDOSFileName) then
              Exit;

          ForceDirectories(RemoveTrailingBackSlash(ExtractFilePath(aDOSFileName)));
          NrBlocks      := LastBlk - FirstBlk;

          Phyle.FileName := pSysFileName;
          Phyle.LineNr  := 0;

          Phyle.bpos    := bufsiz + 1;
          Phyle.EndFile := false;
          Phyle.BlkNr   := FirstBlk + TEXT_HEADER_BLOCKS;
          Phyle.LastBlock := FirstBlk + NrBlocks;

          AssignFile(OutFile, aDOSFileName);
          ReWrite(OutFile);
          try
            Phyle.NrLines := 0;
            while not (Phyle.EndFile) do
              begin
                try
                  ReadLine(Phyle, aLine);
                except
                  on e:EBadFile do
                    raise Exception.Create(e.Message);
                end;
                WriteLn(OutFile, aLine);
              end;
          finally
            CloseFile(OutFile);
            if Frac(DateAccessed) = 0 then
              DateAccessed := DateAccessed + Frac(Now);  // if time is not specified, use the current time
            FileSetDate(aDOSFileName, DateTimeToFileDate(DateAccessed));
          end;
          UpdateStatus(Format('Copied %4d lines file %-15s to %s', [Phyle.NrLines, pSysFileName, aDOSFileName]));
        end
      else
        raise EInvalidFileNameType.CreateFmt('Invalid file name/type for copy: %s/%d', [FileName, xDFKind]);
  except
    on e:Exception do
      Alert(e.Message);
  end;
end;   { TVolume.CopySingleTextFile }


procedure TVolume.CopySingleFile(FileNumber: integer; aDOSFileName: string = '');
begin
  case Directory[FileNumber].xDFKind of
    kTextFile: CopySingleTextFile(FileNumber, aDOSFileName);
    else       CopySingleDataFile(FileNumber, aDOSFileName);  // Straight binary copy for everything else
  end;
end;

constructor TVolume.Create( aOwner: TObject;
                        aDOSFileName: string;
                        aVersionNr: TVersionNr = vn_Unknown;
                        aVolStartBlockInParent: integer = 0);
begin
  inherited Create(aOwner, nil);
  fVolStartBlockInParent := aVolStartBlockInParent;
  DOSFileName := aDOSFileName;
//UpdateStatus(Format('Creating %s, VolumeName = %s', [DOSFileNAME, VolumeName]), true);  // temporary debug
  fFilter     := DEFAULT_FILTER;
end;


function CreateVolume( aOwner: TObject;
                       const aDOSFileName: string;
                       aVersionNr: TVersionNr = vn_Unknown;
                       aVolStartBlockInParent: integer = 0): TVolume;
var
  Ext: string;
  df: TDiskFormats;
begin
  Ext := ExtractFileExt(aDOSFileName);
  if StandardVolumeFormat(Ext) then // standard format
    result := TVolume.Create(aOwner, aDOSFileName, aVersionNr, aVolStartBlockInParent)
  else  { non-standard format }
    begin
      df      := DiskFormatFromExt(Ext);
      with DiskFormatInfo[df] do
        case Alg of
          alStandard:
            result  := TNonStandardVolume.Create(aOwner, aDOSFileName, aVersionNr, aVolStartBlockInParent);

          alApple2:
            result  := TMiscVolume.Create(aOwner, aDOSFileName, aVersionNr, aVolStartBlockInParent);

          else
            raise Exception.CreateFmt('Unknown disk format: %d', [ord(Alg)]);
        end;

      with result as TNonStandardVolume do
        DiskFormat := df;  // set up interleave, skew, etc
    end;
end;

destructor TVolume.Destroy;
begin
//UpdateStatus(Format('Freeing %s, VolumeName = %s', [DOSFileNAME, VolumeName]), true);  // temporary debug
//UpdateStatus('', true);  // temporary debug
  if volStatus <> vsUnknown then
    try
      CloseFile(VolumeFile);
    except
    end;
  if Assigned(CurrentSVOL) then
    begin
      if Assigned(fOnSVOLFree) then
        fOnSVOLFree(CurrentSVOL);
      FreeAndNil(CurrentSVOL);
    end;
  fOnPutIOResult := NIL;
  inherited;
end;

function TVolume.GetDOSFolderName: string;
begin
  result := ForceBackSlash(OutputRootFolder) + VolumeName + '\';
end;

(*
procedure TVolume.FLIPDIRECTORY(BACKFLIP: BOOLEAN);
  VAR I, COUNT: INTEGER;
begin { flipdirectory }
  IF BACKFLIP THEN
    COUNT := di.Rectory[0].DNUMFILES
  ELSE
    COUNT := FLIP(di.Rectory[0].DNUMFILES);

  if (count >= 0) and (count <= MAXDIR) then
    begin
      Assert(false, 'Flip Directory needs to be fixed');
      for I := 1 to COUNT DO
        FixDfkind(di.Rectory[I].DFKIND);  // needs to deal with time info
      if Assigned(fOnStatusProc) then
        fOnStatusProc(Format('Flipping directory: %s', [VolumeName]), false);
    end
  else
    raise EInvalidDirectory.CreateFmt('Directory "%s" is mal-formed. Count of directory entries = %d?',
                              [di.Rectory[0].DTID, Count]);
END;  { flipdirectory }
*)

procedure TVolume.UpdateDirectoryEntry(DirIdx: integer);
var
  Month, Day, Year: word;

  procedure InvalidDirEntry;
  begin { InvalidDirEntry }
    UpdateStatus(Format('Invalid directory entry %d. FileName: %s', [DirIdx, DOSFILENAME]))
  end;  { InvalidDirEntry }

begin
  with Directory[DirIdx] do
    begin
      FirstBlk := DI.Rectory[DirIdx].DFIRSTBLK;
      LastBlk  := DI.Rectory[DirIdx].DLASTBLK;
      xDFKind  := FixDFKind(DI.Rectory[DirIdx].DFKIND);
      try
        if xDFKIND in [kSECUREDIR, kUNTYPEDFILE] then
          begin
            DVID      := DI.Rectory[DirIdx].DVID;
            DEOVBLK   := DI.Rectory[DirIdx].DEOVBLK;
            if DI.Rectory[DirIdx].DNUMFILES <= MAXDIR then
              DNUMFILES := DI.Rectory[DirIdx].DNUMFILES
            else
              DNUMFILES := 0;

            DateRecToYYMMDD(DI.Rectory[DirIdx].DLASTBOOT, Year, Month, Day);
            Year := Y2K(Year);

            try
              LastBoot  := EncodeDate(Year, Month, Day)
            except
              LastBoot := BAD_DATE;         // Something was wrong with the date
            end;
          end else
        if xDFKIND in [kXDSKFILE, kCODEFILE, kTEXTFILE, kINFOFILE,
                       kDATAFILE, kGRAFFILE, kFOTOFILE, kSVOLFILE] then
          begin
(*
            DateRecToYYMMDD(DI.Rectory[DirIdx].DLASTBOOT, Year, Month, Day);
            Year := Y2K(Year);

            try
              LastBoot  := EncodeDate(Year, Month, Day)
            except
              LastBoot := BAD_DATE;         // Something was wrong with the date
            end;
*)
            FileName := DI.Rectory[DirIdx].DTID;
            LastByte := DI.Rectory[DirIdx].DLASTBYTE;

            try
              with DI.Rectory[DirIdx] do
                DateAccessed := DAccessToTDateTime(DACCESS, DFKIND);
            except
              on EInvalidDate do
                DateAccessed := BAD_DATE;
            end;
          end;
      except
        on e:ERangeError do
          InvalidDirEntry;
        on Exception do
          InvalidDirEntry;
      end;
    end;
end;

procedure TVolume.LoadSVOLInfo( const ParentVolumeFileName: string;
                                ParentDirEntry: TDirEntry;
                                ParentBlockCount: integer;
                                ParentName: string;
                                DirBlockNr: integer = DIRECTORY_BLOCKNR);
var
  i: integer;
  BlocksRead: longint;
  FlipBytes: boolean;
begin { TVolume.LoadSVOLInfo }
  Assign(VolumeFile, ParentVolumeFileName);  // open secondary copy of VolumeFile
  ResetVolumeFile;
  with ParentDirEntry do
    begin
      fVolStartBlockInParent := FirstBlk;
      fParentBlockCount      := ParentBlockCount + DIRECTORYBLOCKS;
      fParentName            := ParentName;
      CheckBlockOffset(DirBlockNr);
      SeekInVolumeFile(fVolStartBlockInParent + DirBlockNr);
      BlocksRead := BlockRead(DI.RBLOCKS[1], DIRECTORYBLOCKS);
    end;
    
  if BlocksRead <> DIRECTORYBLOCKS then
    raise EIOResult.CreateFmt('Unexpected number of blocks read/expected: %d/%d', [BlocksRead, DIRECTORYBLOCKS]);

  VolumeName := DI.Rectory[0].DVID;

  CheckVolume;
  VolStatus  := vsSVOLLoaded;
  NumFiles   := DI.Rectory[0].DNUMFILES;
  DEovBlk    := DI.Rectory[0].DEOVBLK;

  FlipBytes  := not (FixDFKind(DI.Rectory[1].DFKIND) in [kUNTYPEDFILE..kSVOLFILE]);
  if FlipBytes then
    raise EBADFLIP.CreateFmt('Directory flip of "%s" is not being handled', [VolumeName]); // FlipDirectory(FlipBytes);

  for i := 0 to NumFiles do  // Start with 0 to get the Directory Info
    UpdateDirectoryEntry(i); // copy to Delphi version of the directory
end;  { TVolume.LoadSVOLInfo }

procedure TVolume.ResetVolumeFile;
begin
  fCurrentBlockNumber := 0;
  Reset(VolumeFile, BLOCKSIZE);
end;

procedure TVolume.SeekInVolumeFile(BlockNr: longint);
begin
  fCurrentBlockNumber := BlockNr;
  Seek(VolumeFile, BlockNr);
end;


procedure TVolume.LoadVolumeInfo(DirBlockNr: integer);
var
  NrBlocks, i: integer;
  BlocksRead: longint;
  FlipBytes: boolean;
  aKind: integer;
begin { TVolume.LoadVolumeInfo }
  if FileExistsSlow(DOSFileName) then
    begin
      AssignFile(VolumeFile, DOSFileName);
      try
        ResetVolumeFile;
      except
        on e:EIOResult do
          raise EIOResult.CreateFmt('IO Error = %s when opening %s', [e.Message, DOSFileName]);
      end;
    end
  else
    raise EIOREsult.CreateFmt('File %s does not exist', [DOSFileName]);

  NrBlocks := DIRECTORYBYTES DIV BLOCKSIZE;
//CheckBlockOffset(DIRECTORY_BLOCKNR);
  SeekInVolumeFile(fVolStartBlockInParent+DirBlockNr);
  BlocksRead := BlockRead(DI.RBLOCKS[1], NrBlocks);
  if BlocksRead <> NrBlocks then
    raise EIOResult.CreateFmt('Unexpected number of blocks read/expected: %d/%d', [BlocksRead, NrBlocks]);

  CheckVolume;


  VolumeName := DI.Rectory[0].DVID;
  VolStatus  := vsDosLoaded;                                                                               
  NumFiles   := DI.Rectory[0].DNUMFILES;
  DeovBlk    := DI.Rectory[0].DEOVBLK;
  HasDupDir  := Di.Rectory[1].DFIRSTBLK = 10;

  aKind      := FixDFKind(DI.Rectory[1].DFKIND);
  FlipBytes  := not (aKind in [kUNTYPEDFILE..kSVOLFILE]);
  if FlipBytes then
    raise EUnhandledFlip.CreateFmt('Directory flip of "%s" is not being handled', [VolumeName]); // FlipDirectory(FlipBytes);

  for i := 0 to NumFiles do  // Start with 0 to get the Directory Info
    UpdateDirectoryEntry(i); // copy to Delphi version of the directory
end;  { TVolume.LoadVolumeInfo }

procedure TVolume.pSysFileNames(List: TStringList; IncludeVolumeName: boolean);
var
  i: integer;
  temp: string;
begin
 List.Clear;
 Temp := '';
 if IncludeVolumeName then
   Temp := Directory[0].DVID + ':';
 for i := 1 to MAXDIR do
   List.Add(Temp + Directory[i].FileName);
end;

procedure TVolume.BlockError(NrBlocks, BlocksExpected: longint; BlockNr: integer);
var
  Msg: string;
begin
  Msg := Format('TVolume: Unexpected number of blocks read/writtten: %d/%d @ BlockNr = %d',
                            [NrBlocks, BlocksExpected, BlockNr]);
  raise EBadFile.Create(Msg);
end;

function TVolume.UnitRead( var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD;
var
  BlocksRead: longint;
  NrBlocks: integer;
  Remainder: word;
  TempBuf: packed array[0..BLOCKSIZE] of byte;
begin
  NrBlocks  := length div BLOCKSIZE;
  remainder := length mod BLOCKSIZE;

  CheckBlockOffset(BlockNumber);
  try
    SeekInVolumeFile(fVolStartBlockInParent+BlockNumber);

    if NrBlocks > 0 then
      begin
        BlocksRead := BlockRead(Buffer, NrBlocks);
        if BlocksRead <> NrBlocks then
          BlockError(Blocksread, NrBlocks, BlockNumber);
      end;

    If Remainder > 0 then
      Begin
        BlocksRead := BlockRead(TempBuf, 1);
        if BlocksRead <> 1 then
          BlockError(BlocksRead, 1, BlockNumber);
        Move(TempBuf, TBytes(Buffer)[NrBlocks*BLOCKSIZE], remainder);
      end;
    result := INOERROR;
  except
    on e:Exception do
      raise EIOResult.CreateFmt('Error reading block %d in file "%s"',
                                [fVolStartBlockInParent+BlockNumber, fDOSFileName]);
  end;
end;

function TVolume.UnitWrite(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD;
var
  BlocksWritten: longint;
  NrBlocks: integer;
  Remainder: word;
  TempBuf: packed array[0..BLOCKSIZE] of byte;
begin
{$I-}
  NrBlocks  := length div BLOCKSIZE;
  remainder := length mod BLOCKSIZE;

  CheckBlockOffset(BlockNumber);
  try
    SeekInVolumeFile(fVolStartBlockInParent+BlockNumber);

    if NrBlocks > 0 then
      begin
        BlocksWritten := BlockWrite(Buffer, NrBlocks);
        if BlocksWritten <> NrBlocks then
          BlockError(BlocksWritten, NrBlocks, BlockNumber);
      end;

    If Remainder > 0 then
      Begin
        Move(TBytes(Buffer)[NrBlocks*BLOCKSIZE], TempBuf, remainder);
        BlocksWritten := BlockWrite(TempBuf, 1);
        if BlocksWritten <> 1 then
          BlockError(BlocksWritten, 1, BlockNumber);
      end;
    result := INOERROR;
  except
    on e:Exception do
      raise EIOResult.CreateFmt('Error reading block %d in file "%s"',
                                [fVolStartBlockInParent+BlockNumber, fDOSFileName]);
  end;
{$I+}
end;


procedure TVolume.SetDOSFolderName(const Value: string);
begin
  fDOSFolderName := Value;
  UpdateStatus(Format('DOS Path set to: %s', [fDOSFolderName]));
end;

procedure TVolume.CopyAllFilesToDOSInBinary(OutputFolder: string;
  OKToOverWrite: boolean);
var
  i: integer;
begin
  fOKToOverWrite := OKTOOverWrite;
  fOutputRootFolder := OutputFolder;
  for i := 1 to NumFiles do
    if (not Empty(Directory[i].FileName)) and
        Wild_Match(@Directory[i].FileName, pchar(fFilter), '*', '?', false) then
      CopySingleDataFile(i);
end;

procedure TVolume.SetFilter(const Value: string);
begin
  fFilter := Value;
end;

function TVolume.BlockRead(var buffer{: Pointer};
                               recCnt: Integer): Longint;
begin
  System.BlockRead(VolumeFile, Buffer, recCnt, result);
  PutIOResult(IOresult);
end;

function TVolume.BlockWrite(var buffer{: Pointer};
                                recCnt: Longint): Longint;
begin
  System.BlockWrite(VolumeFile, Buffer, recCnt, result);
  PutIOResult(IOresult);
  DirectoryChanged('BlockWrite');
end;

// Returns smallest directory entry able to fit a file of the desired size.
// This returns the index of the slot to be used.
function TVolume.FindEmptySpace(BlocksNeeded: integer): integer;
var
  i, LastI: integer;
  SmallestUnneeded: integer;
  BestIdx: integer;

  procedure FREECHECK(FIRSTOPEN, NEXTUSED: INTEGER);
  VAR
    FREEAREA, UnNeeded: INTEGER;
  begin
    FREEAREA := NEXTUSED-FIRSTOPEN;
    UnNeeded := FreeArea - BlocksNeeded;
    if UnNeeded >= 0 then  // big enough
      begin
        if Unneeded < SmallestUnneeded then
          begin
            SmallestUnneeded := UnNeeded;
            BestIdx         := LastI;
          end;
      end;
  END {FREECHECK} ;

begin { TVolume.FindEmptySpace }
  BestIdx := -1;
  SmallestUnneeded := High(Integer);
  with DI.Rectory[0] do
    begin
      LastI := 0; // was: DNUMFILES+1;
      for i := 1 to DNUMFILES do
        begin
          FREECHECK(Di.rectory[i-1].DLASTBLK, Di.rectory[i].DFIRSTBLK);
          LastI := I;
        end;
      LastI := DNUMFILES;
      FREECHECK(Di.rectory[DNUMFILES].DLASTBLK, DEOVBLK);
    end;
  if BestIdx >= 0 then
    result := BestIdx + 1
  else
    result := -1;
end;  { TVolume.FindEmptySpace }

function TVolume.CopyDosTxtToPSysText(     DOSFilePath: string;
                                    PSysFileName: string;
                                var ErrorMessage: string;
                                    ConfirmUpdate: boolean = true{;
                                    VersionNr: TVersionNr = vn_VersionIV}): boolean;
const
  CR = #13;
  BUFLEN  = TEXT_HEADER_BLOCKS * BLOCKSIZE;
var
  TxtFile: TextFile;
  Line: string;
  Buf: packed array [0..BUFLEN-1] of char;
  BlocksWritten: longint;
  BlocksNeeded: integer;
  BlockCnt: integer;
  bp: integer;
  size: longint;
  DirIdx: integer;
  FirstBlock: integer;
  DosDate: TDateTime;
  creationTime, lastAccessTime, lastModificationTime: TDateTime;
  i: integer;
  Kind, HH, MM, SS, MSEC: word;
  BitNr: byte;
  DNumFiles: integer;

  procedure CopyLine(Line: string);
  var
    i: integer;
  begin
    if Length(Line) < (BUFLEN-Bp) then
      for i := 1 to Length(Line) do
        begin
          Buf[bp] := Line[i];
          Inc(bp);
        end
    else
      raise Exception.CreateFmt('Buffer overflow in CopyLine while copying %s to %s', [DOSFilePath, PSysFileName]);
  end;

  function CompressLine(line: string): string;
  var
    i: integer;
    NrBlanks, TailLen: integer;
    mode: (Searching, Found, NotFound);
  begin { CompressLine }
    mode := Searching;
    i := 0; NrBlanks := 0;
    repeat
      if i >= Length(Line) then
        mode := NotFound
      else
        begin
          Inc(i);
          if Line[i] <> ' ' then
            begin
              Mode := Found;
              NrBlanks := i-1;
            end;
        end;
    until mode <> Searching;
    
    if NrBlanks > 2 then
      begin
        SetLength(Result, Length(Line) - NrBlanks + 2);
        Result[1] := chr(DLE);
        Result[2] := chr(NrBlanks + ord(' '));
        TailLen := Length(Line)-NrBlanks;
        Move(Line[NrBlanks+1], Result[3], TailLen);
      end
    else
      result := line;
  end;  { CompressLine }

begin { TVolume.CopyDosTxtToPSysText }
  result := false;

  Size         := FileSize32(DOSFilePath);
  BlocksNeeded := ((Size+BLOCKSIZE-1) DIV BLOCKSIZE) + TEXT_HEADER_BLOCKS;

  // See if the output file already exists
  FindDirectoryEntry(PSysFileName, DirIdx);
  if DirIdx > 0 then
    if OkToOverWriteExistingFile(PSysFileName) then
      DeleteDirectoryEntry(DirIdx)
    else
      begin
        ErrorMessage := Format('File %s already exists in volume %s',
                               [PSysFileName, VolumeName]);
        Exit;
      end;

  DirIdx       := FindEmptySpace(BlocksNeeded);
  if DirIdx > 0 then  // found a slot that is big enough
    begin
      FirstBlock := Directory[DirIdx-1].LASTBLK; // the block immediately following the previous file
      if NumFiles = MAXDIR then  // directory full
        begin
          ErrorMessage := Format('Directory is full (%d files).', [MAXDIR]);
          exit;
        end;

      DNumFiles := DI.Rectory[0].DNUMFILES;
      // Make a hole in the index
      for i := DNumFiles+1 downto DirIdx+1 do
        DI.Rectory[i] := DI.Rectory[i-1];

      // Get date of the source file
      if GetFileTimes(DOSFilePath, creationTime, lastAccessTime,
                           lastModificationTime) then
        DosDate := lastModificationTime
      else
        DosDate := Now;

      // Update the file count
      with DI.Rectory[0] do
        DNUMFILES := DNUMFILES + 1;

      // update the directory entry
      with DI.Rectory[DirIdx] do
        begin
          DFIRSTBLK := FirstBlock;
          DLASTBLK  := FirstBlock + BlocksNeeded;
          KIND      := kTEXTFILE;
          DTID      := PSysFileName;
          DLASTBYTE := BLOCKSIZE;
          DACCESS   := DateTimeToDateRec(DosDate);

          DecodeTime(DosDate, HH, MM, SS, MSEC);

          // pack the Kind, Hour, Minute into the DFKIND field

          if VersionNr >= vn_VersionIV then   // Old versions do not like "time" packed into DFKIND
            begin
              BitNr    := 0;
              SetBits(DFKind, BitNr, 4, Kind);
              SetBits(DFKIND, BitNr, 5, HH);
              SetBits(DFKIND, BitNr, 6, MM);
            end;
        end;

      DirecToryChanged('CopyDosTxtToPSysText');

    end
  else
    begin
      ErrorMessage := Format(CNOSPACE, [PSysFileName]);
      Exit;
    end;

  AssignFile(TxtFile, DOSFilePath);
  Reset(TxtFile);
  try
    BlockCnt := 0;
    FillChar(Buf, PAGE_BYTES, #0);  // 1st 2 blocks not used
    CheckBlockOffset(FirstBlock);
    SeekInVolumeFile(fVolStartBlockInParent+FirstBlock);
    BlocksWritten := BlockWrite(Buf, PAGE_SIZE);

    Inc(BlockCnt, BlocksWritten);
    FillChar(Buf, PAGE_BYTES, #0);

    bp := 0;
    while not Eof(TxtFile) do
      begin
        ReadLn(TxtFile, Line);
        Line := CompressLine(Line);
        if (bp + Length(Line) + 1) >= PAGE_BYTES then // buffer full, flush to disk
          begin
            BlocksWritten := BlockWrite(Buf, PAGE_SIZE);
            Inc(BlockCnt, BlocksWritten);

            FillChar(Buf, SizeOf(Buf), #0);  // re-initialize the buffer
            bp := 0;
          end;
        CopyLine(Line);
        CopyLine(CR);
      end;
    BlocksWritten := BlockWrite(Buf, PAGE_SIZE);  // flush the last block
    Inc(BlockCnt, BlocksWritten);

    // Update the directory entry
    with DI.RECTORY[DirIdx] do
      begin
        DFIRSTBLK := FirstBlock;
        DLASTBLK  := FirstBlock + BlockCnt;
        KIND      := kTEXTFILE;
        DTID      := PSysFileName;
        DLASTBYTE := bp mod BLOCKSIZE;
        DACCESS   := DateTimeToDateRec(DosDate);

        DecodeTime(DosDate, HH, MM, SS, MSEC);

        // pack the Kind, Hour, Minute into the DFKIND field

        BitNr    := 0;
        SetBits(DFKind, BitNr, 4, Kind);    // Not for version II?
        SetBits(DFKIND, BitNr, 5, HH);
        SetBits(DFKIND, BitNr, 6, MM);
      end;

//  UpdateDirectoryEntry(DirIdx);       // I don't think that is doing anything useful.

    UpdateStatus(Format('Copied %s to (%d) %s', [DOSFilePath, DirIdx, PSysFileName]));
    result := true;
  finally
    CloseFile(TxtFile);
    CloseVolumeFile(ConfirmUpdate);
    LoadVolumeInfo(DIRECTORY_BLOCKNR);         // reload the updated volume info
  end;
end;  { TVolume.CopyDosTxtToPSysText }

function TVolume.WriteDirectoryToDisk(ConfirmUpdate: boolean = true; DirBlockNr: integer = DIRECTORY_BLOCKNR): boolean;
var
  NrBlocks: integer;
  BlocksWritten: longint;
  OK: boolean;
begin
  result := false;
  // Write the updated directory to disk
  if fDirectoryChanged then
    begin
      if ConfirmUpdate then
        OK := YesFmt('Do you want to update the directory of %s (changed by %s)', [VolumeName, fDirectoryChangedBy])
      else
        OK := true;

      if OK then
        begin
          CheckBlockOffset(DirBlockNr);
          SeekInVolumeFile(fVolStartBlockInParent+DirBlockNr);
          NrBlocks := 2048 DIV BLOCKSIZE;
          if ConfirmUpdate then
            if Pos(DI.RECTORY[0].DVID, UpperCase(fDOSFileName)) = 0 then  // Just a comfort check...
              IF NOT YESFMT('Going to write directory %s to DOS file %s. Proceed? ', [DI.RECTORY[0].DVID, fDOSFileName]) THEN
                EXIT;
          BlocksWritten := BlockWrite(DI.RBLOCKS[1], NrBlocks);
          if BlocksWritten <> NrBlocks then
            raise Exception.CreateFmt('Unexpected number of blocks read/expected: %d/%d',
                                      [BlocksWritten, NrBlocks]);
          result := true;
        end;
    end;
end;

function TVolume.PSysNameFromDosName(const DosFilePath, Ext: string): string;
var
  Temp: string;
begin
  Temp := ExtractFileBase(DosFilePath);             // c:\LongDOSFileName.txt
  Temp := Copy(Temp, 1, TIDLENG-Length(Ext)-1);     // LongDOSFil
  Temp := UpperCase(temp);                          // LONGDOSFIL
  result := Temp + '.' + Ext;                       // LONGDOSFIL.TEXT
end;

(*
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
*)

procedure TVolume.DeleteDirectoryEntry(DirIdx: integer);
var
  i: integer;
begin
  for i := DirIdx+1 to DI.RECTORY[0].DNUMFILES do
    DI.RECTORY[i-1] := DI.RECTORY[i];

  with DI.RECTORY[0] do
    DNUMFILES := DNUMFILES - 1;

  DirectoryChanged('DeleteDirectoryEntry');
end;

function TVolume.RenamePSystemFile(const FileIDString: string; var NewName: string): boolean;
var
  DirIdx, OtherIdx: integer;
  Base, Ext: string;
begin
  DirIdx  := DirIdxFromString(FileIDString);
  if (DirIdx > 0) and (DirIdx <= NumFiles) then
    begin
      Base      := ExtractFileBase(NewName);
      Ext       := ExtractFileExt(NewName);
      Base      := Copy(Base, 1, TIDLENG - Length(Ext));
      NewName   := UpperCase(Base + Ext);
      OtherIdx  := DirIdxFromString(NewName);
      if OtherIdx > 0 then
        begin
          AlertFmt('File name "%s" already exists at index #%d.', [NewName, OtherIdx]);
          result := false;
          Exit;
        end;
      DI.RECTORY[DirIdx].DTID := NewName;
      if SameText(Ext, '.TEXT') then
//      DI.RECTORY[DirIdx].DFKIND := kTEXTFILE;
        with DI.RECTORY[DirIdx] do
          DFKind := PackDFKind(DFKind, kTEXTFILE);
      UpdateDirectoryEntry(DirIdx);

      DI.RECTORY[0].DLASTBOOT := DateTimeToDateRec(Now);
      DirectoryChanged('RenamePSystemFile');

      CloseVolumeFile;
      LoadVolumeInfo(DIRECTORY_BLOCKNR);         // reload the updated volume info
      UpdateStatus(Format('Renamed "%s" to "%s"', [FileIDString, NewName]));
      result := true;
    end
  else
    result := false;
end;

function  TVolume.DirIdxFromString(const FileIdString: string): integer;
begin
  if IsPureNumeric(FileIDString) then
    result := StrToInt(FileIDString)
  else
    FindDirectoryEntry(FileIDString, result);
end;

function TVolume.CloseVolumeFile(ConfirmUpdate: boolean = true): boolean;
begin
  DI.RECTORY[0].DLASTBOOT := DateTimeToDateRec(Now);
  result := WriteDirectoryToDisk(ConfirmUpdate);
  CloseFile(VolumeFile);
  VolStatus := vsUnknown;
end;


function TVolume.DeletePSystemFile(DirIdx: integer): boolean;
begin
  if (DirIdx > 0) and (DirIdx <= NumFiles) then
    begin
      DeleteDirectoryEntry(DirIdx);
      CloseVolumeFile;
      LoadVolumeInfo(DIRECTORY_BLOCKNR);         // reload the updated volume info
      result := true;
    end
  else
    raise Exception.CreateFmt('File #%d does not exist', [DirIdx]);
end;

function TVolume.DeletePSystemFile(FileIDString: string): boolean;
var
  DirIdx: integer;
begin
  DirIdx := DirIdxFromString(FileIDString);
  if (DirIdx > 0) and (DirIdx <= NumFiles) then
    result := DeletePSystemFile(DirIdx)
  else
    raise Exception.CreateFmt('File #%d (%s) does not exist', [DirIdx, FileIDString]);
end;

function TVolume.FindDirectoryEntry(const FileName: string): PDirEntry;
var
  DirIdx: integer;
begin
  result := FindDirectoryEntry(FileName, DirIdx);
end;

function TVolume.FindDirectoryEntry(const FileName: string; var DirIdx: integer): PDirEntry;
var
  i: integer;
begin
  DirIdx := -1;
  for i := 1 to NumFiles do
    if SameText(Directory[i].FileNAME, FileName) then
      begin
        result := @Directory[i];
        DirIdx := i;
        Exit;
      end;
   result := nil;
end;

function TVolume.IsCodeFile(DirIdx: integer): boolean;

  function TryItAnyWay: boolean;
  begin
    result := YesFmt('File %s does not appear to be a code file. Try to generate a map anyway?',
                     [Directory[DirIdx].FileNAME])
  end;

begin
  if Directory[DirIdx].xDFKind = kCODEFILE then
    result := true else
  if Directory[DirIdx].FileNAME = CSYSTEM_PASCAL then
    result := true else
  if Directory[DirIdx].FileNAME = 'SYSTEM.LIBRARY' then
    result := true
  else
    result := TryItAnyway;
end;


procedure TVolume.ShowMessage(const Msg: string);
begin
 if Assigned(fOnStatusProc) then
   UpdateStatus(Msg, false)
 else
   Alert(Msg);
end;

procedure TVolume.CheckVolume;
var
  i: integer;
  Msg: string;
  Err: byte;
begin
  Err := 0;
  if DI.Rectory[0].DNumFiles <= MAXDIR then
    for i := 1 to DI.Rectory[0].DNumFiles do
      with DI.RECTORY[i] do
        begin
          if (LENGTH(DTID) <= 0) then        Err := 1 else
          if (LENGTH(DTID) > TIDLENG) then   Err := 2 else
          if (DLASTBLK < DFIRSTBLK) then     Err := 3 else
          if (DLASTBYTE > BLOCKSIZE) then    Err := 4;
//        else
//        if (DLASTBYTE < 0) then            Err := 5;
//        if (YearOfMM(DACCESS) >= 100) then Err := 5;  // Year = 100 --> "Temporary File"
          if Err > 0 then
             begin
               case Err of
                 1, 2: Msg := 'Invalid DTID length';
                 3:    Msg := 'DLASTBLK < DFIRSTBLK';
                 4:    Msg := 'DLASTBYTE > BLOCKSIZE';
//               5:    Msg := 'YearOfMM(DACCESS) >= 100';
               end;
               raise EInvalidDirectory.CreateFmt('Directory entry %d (%s) in Volume "%s" is marked as bad [%s]',
                             [i, DTID, VolumeName, Msg]);
               ShowMessage(Msg);
             end;
        end
  else
    if VolStartBlockInParent > 0 then
      raise EInvalidDirectory.CreateFmt('Invalid number of files (%d) in SUBSIDIARY volume at block: %d in file: %s',
                                       [DI.Rectory[0].DNumFiles, VolStartBlockInParent, DOSFileName])
    else
      raise EInvalidDirectory.CreateFmt('Invalid number of files (%d) in volume %s in file: %s',
                                       [DI.Rectory[0].DNumFiles, VolumeName, DOSFileName]);
end;

function TVolume.CopyDosToPSys(DosFilePath, PSysFileName: string; var ErrorMessage: string): boolean;
type
  TBlock = packed array[0..BLOCKSIZE-1] of byte;
var
  InFile: TFileStream;
  Buffer: TBlock;
  Size: longint;
  NrRead, NrBlocks: integer;
  DirIdx, I: integer;
  FirstBlock, BlockCnt: integer;
  DOSDate, creationTime, lastAccessTime, lastModificationTime: TDateTime;
  Ext: string;
  Kind: integer;
  HH, MM, SS, MSEC: word;
  BitNr: byte;
begin
  result   := false;
  Size     := FileSize32(DOSFilePath);
  Ext      := ExtractFileExt(DosFilePath);
  if SameText(Ext, CVOL) or SameText(Ext, CSVOL) then
    Kind := kSVOLFILE else
  if SameText(Ext, '.TEXT') then
    Kind := kTextFile
  else
    Kind := kDATAFILE;

  NrBlocks := (Size + (BLOCKSIZE-1)) DIV BLOCKSIZE;

  // See if the output file already exists
  if Kind = kSVOLFILE then
    PSysFileName := UpperCase(ExtractFileBase(PSysFileName) + CSVOL)
  else
    PSysFileName := UpperCase(PSysFileName);

  FindDirectoryEntry(PSysFileName, DirIdx);
  if DirIdx > 0 then
    if OkToOverWriteExistingFile(PSysFileName) then
      DeleteDirectoryEntry(DirIdx)
    else
      begin
        ErrorMessage := Format('File %s already exists in volume %s',
                               [PSysFileName, VolumeName]);
        Exit;
      end;

  DirIdx       := FindEmptySpace(NrBlocks);
  if DirIdx > 0 then  // found a slot that is big enough
    begin
      if DI.Rectory[0].DNUMFILES = MAXDIR then  // directory full
        begin
          ErrorMessage := Format('Directory is full (%d files).', [MAXDIR]);
          exit;
        end ;

      FirstBlock := Directory[DirIdx-1].LASTBLK; // the block immediately following the previous file

      // Make a hole in the index
      for i := DI.Rectory[0].DNUMFILES+1 downto DirIdx+1 do
        DI.Rectory[i] := DI.Rectory[i-1];

      // Get date of the source file1
      if GetFileTimes(DOSFilePath, creationTime, lastAccessTime,
                           lastModificationTime) then
        DosDate := lastModificationTime
      else
        DosDate := Now;

      // update the directory header entry
      DI.Rectory[0].DNUMFILES := DI.Rectory[0].DNUMFILES + 1;
      with DI.Rectory[DirIdx] do
        begin
          DFIRSTBLK := FirstBlock;
          DLASTBLK  := FirstBlock + NrBlocks;
//        DFKIND    := Kind;
          DTID      := PSysFileName;
          DLASTBYTE := BLOCKSIZE;
          DACCESS   := DateTimeToDateRec(DosDate);

          BitNr    := 0;
          SetBits(DFKind, BitNr, 4, Kind);

          if VersionNr >= vn_VersionIV then
            begin
              DecodeTime(DosDate, HH, MM, SS, MSEC);

              // pack the Kind, Hour, Minute into the DFKIND field

              SetBits(DFKIND, BitNr, 5, HH);
              SetBits(DFKIND, BitNr, 6, MM);
            end;
        end;
      DirectoryChanged('CopyDosToPSys');
    end
  else
    begin
      ErrorMessage := Format(CNOSPACE, [PSysFileName]);
      Exit;
    end;

  CheckBlockOffset(FirstBlock);
  SeekInVolumeFile(fVolStartBlockInParent+FirstBlock);

  try
    BlockCnt := 0;  NrRead := 0;

    InFile := TFileStream.Create(DOSFilePath, fmOpenRead);
    try
      while InFile.Position < InFile.Size do
        begin
          NrRead := InFile.Read(Buffer, SizeOf(TBlock));
          BlockWrite(Buffer, 1);
          Inc(BlockCnt);
        end;
    finally
      FreeAndNil(InFile);
    end;

    // Get date of the source file
    if GetFileTimes(DOSFilePath, creationTime, lastAccessTime,
                         lastModificationTime) then
      DosDate := lastModificationTime
    else
      DosDate := Now;

    DecodeTime(DosDate, HH, MM, SS, MSEC);

    // Update the directory entry
    with DI.RECTORY[DirIdx] do
      begin
        DFIRSTBLK := FirstBlock;
        DLASTBLK  := FirstBlock + BlockCnt;
//      DFKIND    := Kind;
        DTID      := PSysFileName;
        DACCESS   := DateTimeToDateRec(DosDate);
        DLASTBYTE := NrRead;

        // pack the Kind, Hour, Minute into the DFKIND field

        BitNr    := 0;
        SetBits(DFKind, BitNr, 4, Kind);
        SetBits(DFKIND, BitNr, 5, HH);
        SetBits(DFKIND, BitNr, 6, MM);

      end;

//  UpdateDirectoryEntry(DirIdx);  // Useless because of following LoadVolumeInfo

    UpdateStatus(Format('Copied %s to (%d) %s', [DOSFilePath, DirIdx, PSysFileName]));
    result := BlockCnt = NrBlocks;
  finally
    CloseVolumeFile;
    LoadVolumeInfo(DIRECTORY_BLOCKNR);         // reload the updated volume info
  end;
end;


function TVolume.FixTextName(FileName: string): string;
var
  Ext: string;
begin
  Ext := ExtractFileExt(FileName);
  if SameText(Ext, '.TEXT') then
    result := ForceExtension(FileName, TXT_EXT)
  else
    result := FileName + '.txt';
end;

procedure TVolume.CreateVolume(var DOSVolumeName: string; NrBlocks: integer; DirBlockNr: integer = DIRECTORY_BLOCKNR);
var
  BlockNr: integer;
  EmptyBlock: packed array[0..BLOCKSIZE-1] of byte;
  OK: boolean;
  FilePath, FileBase, FileExt: string;
begin
  FillChar(EmptyBlock, BLOCKSIZE, 0);
  FilePath := ExtractFilePath(DOSVolumeName);
  FileBase := UpperCase(Copy(ExtractFileBase(DOSVolumeName), 1, VIDLENG));
  FileExt  := ExtractFileExt(DOSVolumeName);

  DOSVolumeName := FilePath + FileBase + FileExt;;

  OK := true;
  if FileExists(DOSVolumeName) then
    OK := YesFmt('Volume %s already exists. Do you want to overwrite it?', [DOSVolumeName]);

  if OK then
    begin
      AssignFile(VolumeFile, DOSVolumeName);

      ReWrite(VolumeFile, BLOCKSIZE);
      for BlockNr := 1 to NrBlocks do
        BlockWrite(EmptyBlock, 1);  // writing to DOS

      with Di.RECTORY[0] do
        begin
          DNUMFILES := 0;
          DFKind    := PackDFKind(DFKIND, kUNTYPEDFILE);
          DVID      := FileBase;
          DEOVBLK   := NrBlocks;       {LASTBLK OF VOLUME}
          DLASTBLK  := DirBlockNr + DIRECTORYBLOCKS;
//        DLOADTIME := 0;     {TIME OF LAST ACCESS}
//        DLASTBOOT := 0;    {MOST RECENT DATE SETTING}
          SetDirectoryDateTime(DLASTBOOT, DLOADTIME);
        end;

      CheckBlockOffset(DirBlockNr);
      SeekInVolumeFile(fVolStartBlockInParent+DirBlockNr);
      BlockWrite(DI.Rblocks[1], DIRECTORYBLOCKS);
      CloseVolumeFile;
    end;
end;

procedure TVolume.ResizeVolume(NewNrBlocks: integer);
var
  BlockNr, OldNrBlocks: integer;
  EmptyBlock: packed array[0..BLOCKSIZE-1] of byte;
  OK: boolean;
begin
  FillChar(EmptyBlock, BLOCKSIZE, 0);

  OldNrBlocks := di.Rectory[0].DEOVBLK;

  OK := NewNrBlocks >= OldNrBlocks;
  if not OK then
    raise Exception.CreateFmt('Size may not be reduced', [VolumeName]);

  if OK then
    begin
      SeekInVolumeFile(FileSize(VolumeFile));

      for BlockNr := OldNrBlocks+1 to NewNrBlocks do
        begin
          UpdateStatus(Format('Writing block #%d', [BlockNr]), false, true);
          BlockWrite(EmptyBlock, 1);  // writing to DOS
        end;

      with Di.RECTORY[0] do
        DEOVBLK   := NewNrBlocks;       {LASTBLK OF VOLUME}

      CheckBlockOffset(DIRECTORY_BLOCKNR);
      SeekInVolumeFile(fVolStartBlockInParent+DIRECTORY_BLOCKNR);
      BlockWrite(DI.Rblocks[1], DIRECTORYBLOCKS);
      CloseVolumeFile;
    end;
end;

function TVolume.RawStringSearch(SearchFor: string; var BlockNr: integer; var Buffer: TBlockBuffer): boolean;
begin
  result := false;
  while BlockNr < DeovBlk do
    begin
      UnitRead(Buffer, BLOCKSIZE, BlockNr, 0);
      if MyStrPos(Buffer, pchar(SearchFor), BLOCKSIZE, true) <> nil then
        begin
          result := true;
          Exit;
        end;
      BlockNr := BlockNr + 1;
    end;
  BlockNr := -1;  // EOF
end;

function TVolume.Dispatcher(Request, BlockNr, Len: word; var Buffer; Control: word): TIORsltWD;
begin
  if (Request and INBIT) <> 0 then
    begin
{$I-}
      result := UnitRead(Buffer, Len, BlockNr, 0);
    end else
  if (Request and CLRBIT) <> 0 then
    result := INOERROR
  else
    result := UnitWrite(Buffer, Len, BlockNr, 0);
{$I+}
end;

procedure  TVolume.MountSVOL(DirIdx: integer);
begin
  UpdateStatus(Format('Mounting "%s" onto "%s"', [Directory[DirIdx].FileNAME, VolumeName]), false);
//UpdateStatus(Format('Mounting "%s" onto "%s"', [Directory[DirIdx].FileNAME, VolumeName]), true);  // temporary debug
//ParentName  := Format('[SVOL of %s]', [VolumeName]);
  CurrentSVOL := TVolume.Create(self, DOSFileName);
  CurrentSVOL.OnStatusProc := self.fOnStatusProc;
  CurrentSVOL.OnSearchFoundProc := self.fOnSearchFound;

  CurrentSVOL.LoadSVOLInfo(DOSFileName, Directory[DirIdx], Directory[0].DEOVBLK, VolumeName);
end;

procedure TVolume.UpdateStatus(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true);
begin
  if Assigned(fOnstatusProc) then
    fOnStatusProc(Msg, DoLog, DoStatus);
end;

procedure TVolume.ErrorMessageProc(const Msg: string; Args: array of const);
begin
  UpdateStatus(Format(Msg, Args));
end;

{$IfDef PoolInfo}
procedure TVolume.ScanVolumeForPoolInfo(SearchInfoPtr: TSearchInfoPtr; var OutputFile: TextFile);
var
  InBuf: TInBuf;
//CrtInfo: TCrtInfo;
//KeyInfo: TCrtInfo;
  InfoLine: string;
  InBufPtr: TInBufPtr;
  FileName,
  FullFileName: string;
  DirIdx: integer;
  BadInfo, b1, b2, b3, b4: Boolean;
  Warning: string;
  DateAccessed: TDateTime;
begin
  InBufPtr := @InBuf;
  DirIdx   := 1;
  while DirIdx <= NumFiles do
    begin
      try
        FileName := Directory[DirIdx].FileName;
        if Wild_Match(pchar(FileName), @SearchInfoPtr.SearchString[1], '*', '?', false) then
          begin
            FillChar(InBuf, SizeOf(InBuf), 0);
            SeekInVolumeFile(Directory[DirIdx].FirstBlk);
            BlockRead(InBuf, 1);
            FullFileName := VolumeName + ':' + FileName;

            with InBuf.sysIV.PoolInfo do
              begin
                b1 := Ord(PoolOutSide) > 1;
                b2 := not IsPowerOfTwo(resolution);
                b3 := PoolSize < 0;
                b4 := FullAddressToLongWord(PoolBaseAddr) > $20000;
                
                BadInfo := b1 or b2 or b3 or b4;
                if BadInfo then
                  with SearchInfoPtr^ do
                    Inc(NumberOfErrors);

                DateAccessed := Directory[DirIdx].DateAccessed;

                Warning := '';
                if b1 then
                  Warning := Warning + 'PoolOutside, ';
                if b2 then
                  Warning := Warning + 'Resolution, ';
                if b3 then
                  Warning := Warning + 'Poolsize, ';
                if b4 then
                  Warning := Warning + 'BaseAddr, ';

                try
                  InfoLine := Format('%s, %4.4x, %8.8x, %4.4x, %4.4x, %4d, %s, %s, %s, %s',   // smPoolInfo
//                InfoLine := Format('%s, %4.4x, %4.4x, %4.4x, %4d, %s, %s, %s',   // smPoolInfo
                                     [TF(PoolOutSide), PoolSize,
                                      FullAddressToLongWord(PoolBaseAddr), PoolBaseAddr[0], PoolBaseAddr[1],
                                      resolution,
                                      FullFileName,
                                      DateTimeToStr(DateAccessed),
                                      DOSFileName,
                                      Warning]);
                  except
                    on e:Exception do
                     InfoLine := 'System error: '+e.Message;
                  end;
              end;

            if not BadInfo then
              WriteLn(OutputFile, InfoLine);
            Inc(SearchInfoPtr.MatchesFound);
          end;
      finally
        Inc(DirIdx);  // There may be more SYSTEM.MISCINFO files on this volume
      end;
    end;
end;

{$endIf PoolInfo}

procedure TVolume.ScanVolumeForMiscinfo(SearchInfoPtr: TSearchInfoPtr; var OutputFile: textFile);
var
  InBuf: TInBuf;
  CrtInfo: TCrtInfo;
  KeyInfo: TCrtInfo;
  InfoLine: string;
  InBufPtr: TInBufPtr;
  FileName,
  FullFileName: string;
  DirIdx: integer;
begin
  InBufPtr := @InBuf;
  DirIdx   := 1;
  while DirIdx <= NumFiles do
    begin
      try
        FileName := Directory[DirIdx].FileName;
        if Wild_Match(pchar(FileName), @SearchInfoPtr.SearchString[1], '*', '?', false) then
          begin
            FillChar(InBuf, SizeOf(InBuf), 0);
            LoadMiscInfo(self, FileName, InBuf);

            CrtInfo := TCrtInfo.Create(LOW_CRT_FUNC, HIGH_CRT_FUNC);
            KeyInfo := TCrtInfo.Create(LOW_KEY_FUNC, HIGH_KEY_FUNC);

            LoadCrtKeyInfo(InBufPtr, CrtInfo, KeyInfo, VersionNr);   // This is doing unnecessary work by processing both CRT & KEY
                                                          // but only using one of them.
            FullFileName := VolumeName + ':' + FileName;
            try
              case SearchInfoPtr.SearchMode of
                smCrtInfo:
                  InfoLine := CrtInfo.CSVLine(FullFileName, DosFileName, true);

                smKeyInfo:
                  InfoLine := KeyInfo.CSVLine(FullFileName, DosFileName{, true});
              end;
              WriteLn(OutputFile, InfoLine);
              Inc(SearchInfoPtr.MatchesFound);
            finally
              FreeAndNil(KeyInfo);
              FreeAndNil(CrtInfo);
            end;
          end;
      finally
        Inc(DirIdx);  // There may be more SYSTEM.MISCINFO files on this volume
      end;
    end;
end;

procedure TVolume.ScanVolumeForVersionNumber(SearchInfoPtr: TSearchInfoPtr);
var
  DirIdx: integer;
  DoLog, DoStatus: boolean;
  aCode_Leng, aCode_Addr: longword;
  Msg: string;
  Temp: string;

  function GenFoundLine( const SegName, version: string; Comment: string = ''): string;
  begin
    result := Format('        %-8s  Version = %-10s  %s',
                     [SegName, Version, Comment]);
  end;


  function ScanMiscInfo( {1} DirIdx: integer;
                         {2} VolumeName,
                         {3} FileName: string): TPMachineVersion;
  var
    bsb: record
            case integer of
              0: (SysComRec: TIVSysComRec);
              1: (Blocks: packed array[0..2047] of char)
            end;

    NrBlocks, BlocksRead: longint;
    Version, ThepSysFileName, DateStr: string;
  begin
    result := version_Unknown;

    UpdateStatus(Format('Scanning %s:%s', [VolumeName, FileName]), false, true);

    DateStr := DateToStr(Directory[DirIdx].DateAccessed);

    ThepSysFileName := Format('%s:%s', [VolumeName, FileName]);
    UpdateStatus(Format('p-Sys File Name:  %s; File Date: %s', [ThepSysFileName, DateStr]),
                 false {DoLog},  true {DoStatus});

    with Directory[DirIdx] do
      NrBlocks := LASTBLK - FirstBlk;

    BlocksRead := BlockRead(bsb.Blocks, NrBlocks);
    if NrBlocks <> BlocksRead then
      begin
        UpdateStatus(Format('Invalid block count when reading %s:%s (%d/%d)',
                               [VolumeName, FileName, NrBlocks, BlocksRead]));
        Exit;
      end;

    inc(SearchInfoPtr^.MatchesFound);

    with bsb.SysComRec do
      if (pmachver in [pre_iv_1, iv_1, iv_2]) then
        Version := pMachineVersions[pmachver] else
      if (NrBlocks = 1) then
        Version := pMachineVersions[pre_iv_1]
      else
        Version := pMachineVersions[version_Unknown];

    SearchFound( VolumeName,
                  FileNAME,
                  Format('File size = %d blocks, Version = %s', [NrBlocks, Version]),
                  Directory[DirIdx].DateAccessed,
                  DOSFileName);
  end;

  function ScanSegmentFile( {1} DirIdx: integer;
                            {2} VolumeName,
                            {3} aFileName: string): TPMachineVersion;
  const
    CTEXT = 'Pascal  System';
    CTEXT2 = 'p-System';
    MAXLEN = 100;
    UCSDPSYSTEM = 'U.C.S.D.  Pascal  System';
  type
    TSegmentSummary = record
                        SegmentNumber: integer;
                        SegmentName: string;
                        CountOfVersion: integer;
                      end;
  var
    Buffer, BufEnd: pchar;
    NrBlocks, NrBlocksInSeg: integer;
    sfi: TSegmentFileInfo;
    SegNr: integer;
    VersionCounts: array[TVersions] of integer;
    ThepSysFileName, Line, DateStr, Version: string;
    p, p1, p2: pchar;
    i, LB, RB, NextIdx, Len: integer;
    lbs, rbs: string;

    function FindText(const s: string; var NextIdx: integer): integer;
    begin
      NextIdx := 0;
      result := Pos(s, Line);
      if result > 0 then
        NextIdx := Length(s) + 1;
    end;

  begin { ScanSegmentFile }

    result := version_Unknown;

    FillChar(VersionCounts, SizeOf(VersionCounts), 0);

    UpdateStatus(Format('Scanning %s:%s', [VolumeName, aFileName]), false {DoLog}, true {DoStatus});

    with Directory[DirIdx] do
      begin
        NrBlocks := (LASTBLK - FirstBlk) * 2;  // This is OVER estimating how much space is needed.
                                               // * 2 was to allow for uncertainty about whether aCode_Leng represents words or bytes.
                                               // No longer needed.
        GetMem(Buffer, NrBlocks * BLOCKSIZE);
        try
          ThepSysFileName := Format('%s:%s', [self.VolumeName, aFileName]);

          DateStr := DateToStr(Directory[DirIdx].DateAccessed);

          UpdateStatus(Format('DOS File Name:    %s; File Date: %s', [DOSFileName, DateTimeToStr(FileDateToDateTime(FileAge(DOSFileName)))]),
                       true {DoLog},  false {DoStatus});
          UpdateStatus(Format('p-Sys File Name:  %s; File Date: %s', [ThepSysFileName, DateStr]),
                       true {DoLog},  false {DoStatus});

          if LoadSegmentFile(FirstBlk, VolStartBlockInParent, self, sfi, ThepSysFileName, ErrorMessageProc) then
            begin
              with sfi do
                for SegNr := 0 to MAXSEG do
                  with SegDictInfo[SegNr] do
                    begin
                      if VersionSplit = vsSoftech then
                        Major_Version := iv;
                      SegName := TrimTrailing(SegName, [#0, ' ']);
                      if SegName <> '' then
                        begin
                          try
                            if Major_Version = IV then
                              aCode_Leng := Code_Leng * 2  // version IV stores a word count in Code_Len
                            else
                              aCode_Leng := Code_Leng;     // earlier versions store a byte count;
                          except
                            aCode_Leng := 0;
                          end;

                          NrBlocksInSeg  := (aCode_Leng + BLOCKSIZE -1) div BLOCKSIZE;
                          if NrBlocksInSeg > NrBlocks then  // something is wacky
                            break;

                          VersionCounts[Major_version] := VersionCounts[Major_version] + 1;

                          DateStr         := DateToStr(DateAccessed);
                          Line            := GenFoundLine( SegName,
                                                           VersionNames[Major_version]);
                          UpdateStatus(Line, true {DoLog}, false);

                          inc(SearchInfoPtr^.MatchesFound); {2}
                          if (aFileName = CSYSTEM_PASCAL) then // look for the "Welcome" message in SYSTEM.PASCAL
                            begin
                              BufEnd := Buffer + aCode_Leng;
                              aCode_Addr := VolStartBlockInParent + FirstBlk + Code_Addr;
                              SeekInVolumeFile(aCode_Addr);     // position to start of segment
                              BlockRead(Buffer^, NrBlocksInSeg);   // load the segment ++
                              p := MyStrPos( Buffer, pchar('WELCOME'), BufEnd);
                              if not Assigned(p) then
                                p := MyStrPos( Buffer, pchar('D(ebug'), BufEnd);
                              if Assigned(p) then
                                begin
                                  Line  := Copy(p, 0, MAXLEN);
                                  lb := Pos('[', Line);
                                  rb := Pos(']', Line);
                                  if (rb > lb) then
                                    begin
                                      Version := Copy(Line, LB+1, RB-LB-1);
                                      Line    := GenFoundLine( SegName, Version, 'Prompt Line');
                                      UpdateStatus(Line, true {DoLog}, false);
                                    end
                                  else
                                    begin
                                      Line := Copy(p, 0, MAXLEN);
                                      lb   := FindText(CTEXT, NextIdx);
                                      if lb = 0 then
                                        lb   := FindText(CTEXT2, NextIdx);

                                      if lb > 0 then
                                        begin
                                          rb := 0;
                                          for i := lb + NextIdx to Length(Line) do
                                            if Line[i] < ' ' then
                                              begin
                                                rb := i;
                                                break;
                                              end;
                                          if rb > lb then
                                            begin
                                              Version := Copy(Line, lb, rb-lb-1);
                                              Line    := GenFoundLine( SegName, Version, 'Welcome message');
                                              UpdateStatus(Line, true {DoLog}, false);
                                            end;
                                        end
                                    end;
                                end;
                              p := MyStrPos( Buffer, pchar(UCSDPSYSTEM), BufEnd);
                              if Assigned(p) then
                                begin
                                  p := p + Length(UCSDPSYSTEM); // skip past 'U.C.S.D.  Pascal  System'
                                  while p^ = ' ' do
                                    inc(p);
                                  Version := '';
                                  while p^ <> #0 do
                                    begin
                                      Version := Version + p^;
                                      inc(p);
                                    end;
                                  Line := GenFoundLine(SegName, Version, 'Welcome Message');
                                  UpdateStatus(Line, true {DoLog}, false);
                                end;
                              if not Assigned(p) then
                                begin
                                  lbs := '[';
                                  rbs := ']';

                                  p1  := MyStrPos( Buffer, pchar(lbs), BufEnd);
                                  while Assigned(p1) do
                                    begin
                                      if Assigned(p1) then
                                        begin
                                          p2  := MyStrPos( p1, pchar(rbs), BufEnd);
                                          if Assigned(p2) then
                                            begin
                                              Len := p2 - p1;
                                              if Len < 20 then // something like "[IV.2.2 R1.1]"
                                                begin
                                                  Version := Copy(p1+1, 0, Len-1);
                                                  if ((Length(Version)) >= 4) and
                                                     (not ContainsAny(Version, [#0..#31])) then // no non-printing
                                                    begin
                                                      Line    := GenFoundLine(SegName, Version, 'Guess');
                                                      UpdateStatus(Line, true {DoLog}, false);
                                                    end;
                                                end;
                                            end;
                                          p1 := MyStrPos( p1+1, pchar(lbs), BufEnd);
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;

              UpdateStatus('', true {DoLog}, false); // Leave some space between files
            end;
        finally
          FreeMem(Buffer);
        end;
      end;
  end; { ScanSegmentFile }

  procedure WriteMessage(const Msg: string);
  var
    DoLog: boolean;
  begin
    if Assigned(fOnStatusProc) then
      begin
        DoLog := SearchInfoPtr.LogMountingErrors;
        fOnStatusProc(Msg, DoLog, DoStatus);
        fOnStatusProc(Padr('', Length(Msg), '*'), DoLog, true);
        fOnStatusProc('', DoLog, false);
      end;
  end;


begin { TVolume.ScanVolumeForVersionNumber }
  try
    UpdateStatus(Format('Scanning VOLUME: %s, DOS File Name: %s', [VolumeName, DOSFileName]), false, true);
    for DirIdx := 1 to NumFiles do
      begin
        try
          if OkDateTime(Directory[DirIdx].DateAccessed, SearchInfoPtr.LowDate, SearchInfoPtr.HighDate) then
            if Directory[DirIdx].xDFKIND = kSVOLFILE then
              begin
                MountSVOL(DirIdx);
                try
                  CurrentSVOL.ScanVolumeForVersionNumber( SearchInfoPtr);
                finally
                  FreeAndNil(CurrentSVOL);
                end;
              end else
            with Directory[DirIdx] do
              if (xDFKIND = kDATAFILE) and (FileNAME = CSYSTEM_MISCINFO) and (Length(SearchInfoPtr.SearchString) = 0) then
                ScanMiscInfo(DirIdx, VolumeName, Directory[DirIdx].FileNAME)
              else
                begin
                  Temp := SearchInfoPtr.SearchString;
                  if (Length(Temp) = 0) or
                      Wild_Match(@FileName[1], @Temp[1], '*', '?', false) then
                    if (xDFKIND = kDATAFILE) then
                      begin
                        if (FileNAME = CSYSTEM_PASCAL) or (FileName = 'SYSTEM.LIBRARY') then
                          ScanSegmentFile(DirIdx, VolumeName, Directory[DirIdx].FileNAME)
                      end
                    else if xDFKIND = kCODEFILE then
                      ScanSegmentFile(DirIdx, VolumeName, Directory[DirIdx].FileNAME);
                end;
        except
          on e:EInvalidDirectory do  // cannot continue with this directory
            raise EInvalidDirectory.Create('Invalid directory');

          // just continue with the next file
          on e:Exception do
            begin
              UpdateStatus(e.Message);
              UpdateStatus('', true, false);
            end;
        end;
     end;
// UpdateStatus('', true, true);

  except
    on e:EInvalidDirectory do
      begin
        Msg := Format('Invalid directory while processing volume %s: [%s]',
                          [VolumeName, DOSFileName]);
        WriteMessage(Msg);
      end;

    on e:Exception do
      begin
        Msg      := Format('%s: while processing volume %s: [%s]',
                                 [e.Message, VolumeName, DOSFileName]);
        WriteMessage(Msg);
      end;
  end;
end;  { TVolume.ScanVolumeForVersionNumber }

procedure TVolume.ScanVolumeForHexString(SearchInfoPtr: TSearchInfoPtr);
type
  TBigChunk  = array[0..MAXBLOCKSIZE-1] of byte;

var
  DirIdx: integer;
  LastFileName: string;
  DoLog, DoStatus: boolean;

  procedure ScanDataFile( {1} DirIdx: integer;
                          {2} VolumeName,
                          {3} FileName: string);
  var
    NrBlocks: integer;
    BlocksRead: system.integer;
    NrBytes: system.integer;
    Buffer: ^TBigChunk;

    function MatchesSearch(indx: system.integer): boolean;
    var
      i: integer;
    begin { MatchesSearch }
      for i := 0 to SearchInfoPtr.NrHexBytes-1 do
        begin
          if Buffer^[indx+i] <> SearchInfoPtr.HexBytes[i] then
            begin
              result := false;
              exit;
            end;
        end;
      result := true;
    end;  { MatchesSearch }

    procedure FindMatchingBytes;
    var
      indx: system.integer;
      Line: string;
    begin { FindMatching Bytes }
      for indx := 0 to NrBytes-SearchInfoPtr.NrHexBytes do
        begin
          if MatchesSearch(indx) then
            begin
              Line := Format('Hex string found offset @ %s', [Bothways(indx)]);
              SearchFound(VolumeName, FileNAME, Line, Directory[DirIdx].DateAccessed, DOSFileName);

              inc(SearchInfoPtr.MatchesFound);
            end;
        end;
    end;  { FindMatchingBytes }

  begin { ScanDataFile }
    UpdateStatus(Format('Scanning %s:%s', [VolumeName, FileName]), false, true);
    NrBlocks   := Directory[DirIdx].LASTBLK - Directory[DirIdx].FirstBlk;
    NrBytes    := NrBlocks * BLOCKSIZE;
    if NrBytes >= MAXBLOCKSIZE then
      begin
        if Assigned(fOnStatusProc) then
          begin
            UpdateStatus(Format('Max block count exceeded when reading %s:%s (%d/%d)',
                                 [VolumeName, FileName, NrBlocks, MAXBLOCKCOUNT]), true, true);
            UpdateStatus(Format('    Only the first %d blocks will be searched', [MAXBLOCKCOUNT]));
          end;
        NrBlocks := MAXBLOCKCOUNT;
        NrBytes  := NrBlocks * BLOCKSIZE;
      end;
    GetMem(Buffer, NrBytes);
    try
      BlocksRead := BlockRead(Buffer^, NrBlocks);
      if NrBlocks <> BlocksRead then
        UpdateStatus(Format('Invalid block count when reading %s:%s (%d/%d)',
                               [VolumeName, FileName, NrBlocks, BlocksRead]));

      FindMatchingBytes;
    finally
      FreeMem(Buffer);
    end;
  end;  { ScanDataFile }

begin { TVolume.ScanVolumeForHexString }
  try
    LastFileName := '';
    for DirIdx := 1 to NumFiles do
      begin
        if OkDateTime(Directory[DirIdx].DateAccessed, SearchInfoPtr.LowDate, SearchInfoPtr.HighDate) then
          if Directory[DirIdx].xDFKIND = kSVOLFILE then
            begin
              MountSVOL(DirIdx);
              CurrentSVOL.ScanVolumeForHexString( SearchInfoPtr);
              FreeAndNil(CurrentSVOL);
            end else
          if not (Directory[DirIdx].xDFKIND in [kSECUREDIR, kUNTYPEDFILE, kTEXTFILE]) then
            begin
              ScanDataFile(DirIdx, VolumeName, Directory[DirIdx].FileNAME);
            end
      end;
  except
    on e:Exception do
      begin
        DoLog    := SearchInfoPtr.LogMountingErrors;
        DoStatus := true;
        if not Empty(LastFileName) then
          fOnStatusProc(Format('%s: while processing file %s on volume %s [%s]',
                       [e.Message, LastFileName, VolumeName, DOSFileName]), DoLog, DoStatus)
        else
          fOnStatusProc(Format('%s: while processing volume %s [%s]',
                       [e.Message, VolumeName, DOSFileName]), DoLog, DoStatus);
      end;
  end;
end;  { TVolume.ScanVolumeForHexString }

procedure TVolume.ScanVolumeForString( SearchInfoPtr: TSearchInfoPtr);
var
  DirIdx: integer;
  LastFileName: string;
  DoLog, DoStatus: boolean;
  VolName: string;
begin
  try
    LastFileName := '';
    for DirIdx := 1 to NumFiles do
      begin
        if OkDateTime(Directory[DirIdx].DateAccessed, SearchInfoPtr.LowDate, SearchInfoPtr.HighDate) then
          if Directory[DirIdx].xDFKIND = kSVOLFILE then
            begin
              if LineContainsTarget(SearchInfoPtr^, Directory[DirIdx].FileNAME) then
                SearchFound('', Directory[DirIdx].FileNAME, Directory[DirIdx].FileNAME,
                            Directory[DirIdx].DateAccessed, DOSFileName);

              LastFileName := '';
              MountSVOL(DirIdx);
              CurrentSVOL.ScanVolumeForString(SearchInfoPtr);
              CurrentSVOL.OnSearchFoundProc := fOnSearchFound;
              inc(SearchInfoPtr.VolumesSearched);
              FreeAndNil(CurrentSVOL);
            end else
          if (Directory[DirIdx].xDFKIND = kTEXTFILE) and (not SearchInfoPtr.OnlySearchFileNames) then
            begin
              LastFileName := '';
              ScanTextFile(DirIdx, SearchInfoPtr);
              inc(SearchInfoPtr.pSystemTextFilesSearched);
            end
          else
            begin
              LastFileName := Directory[DirIdx].FileNAME;

              if LineContainsTarget(SearchInfoPtr^, LastFileName) then
                begin
                  VolName := Format('%s:', [VolumeName]);
                  SearchFound(VolName, LastFileNAME, LastFileNAME, Directory[DirIdx].DateAccessed, DOSFileName);
                end;
             end;
        if SearchInfoPtr.Abort then
          Break;
      end;
  except
    on e:Exception do
      begin
        DoLog    := SearchInfoPtr.LogMountingErrors;
        DoStatus := true;
        if not Empty(LastFileName) then
          fOnStatusProc(Format('%s: while processing file %s on volume %s [%s]',
                       [e.Message, LastFileName, VolumeName, DOSFileName]), DoLog, DoStatus)
        else
          fOnStatusProc(Format('%s: while processing volume %s [%s]',
                       [e.Message, VolumeName, DOSFileName]), DoLog, DoStatus);
      end;
  end;
end;


function TVolume.GetDOSFileName: string;
begin
  result := fDOSFileName;
end;

procedure TVolume.SetDOSFileName(const Value: string);
begin
  fDOSFileName := Value;
end;

procedure TVolume.ZeroDirectory(const VolName: string);
var
  NrBytes: int64;
  NrBlocks: longword;
begin
  NrBytes := FileSize64(fDOSFileName);
  NrBlocks := NrBytes div FBLKSIZE;
  with DI.RECTORY[0] do
    begin
      DNUMFILES := 0;
      DVID      := VolName;
      DFKind    := PackDFKind(DFKIND, kUNTYPEDFILE);
      DEOVBLK   := NrBlocks;       {LASTBLK OF VOLUME}
      DLASTBLK  := DIRECTORY_BLOCKNR + DIRECTORYBLOCKS;
    end;
  DirectoryChanged('ZeroDirectory');
  WriteDirectoryToDisk(true);
end;

procedure TVolume.CheckBlockCount(result,
  NrBlocks: integer);
begin
  if NrBlocks <> result then
    raise Exception.CreateFmt('Blockread Error: blocks requested = %d, blocks read=%d',
                              [Nrblocks, result]);
end;

procedure TVolume.PutIOResult(IOResult: integer);
begin
  if Assigned(fOnPutIOResult) then
    fOnPutIoResult(IOResult)
  else
    if IOResult <> 0 then
      raise Exception.Create('PutIOResult not connected');
end;

//       NAME    : PartialBlockReadRel
//       Purpose : Reads a less than blocksized region from the volume
//       Entry:
//                 Buf          = ^to buffer
//                 BytesToRead  = total number of bytes to read (0..511)
//                 RelBlock     = starting block number in the volume for read
//       Returns : number of bytes read
function TVolume.PartialBlockReadRel( var buf;
                                          BytesToRead: longint; RelBlock: integer): longint;
Var
  TempBuf     : TempBufType;
  BlocksRead  : longint;
  Offset      : longint;
  NrBlocks    : integer;
  NrBytes     : word;
  BlockNr     : word;
begin
  PutIOResult(0);  // clear the error flag

  BlockNr   := RelBlock;         // For some reason, the Delphi debugger displays RelBlock incorrectly??
                                 // Maybe it is related to the use of an untyped parameter?
  result    := 0;   // tally total bytes read
  NrBlocks  := BytesToRead div BLOCKSIZE;
  NrBytes   := BytesToRead mod BLOCKSIZE;
  Offset    := 0;

  if NrBlocks > 0 then
    begin
      BlocksRead := UCSDBlockReadRel(Buf, NrBlocks, BlockNr);       // read the "complete" blocks
      Offset     := BlocksRead * BLOCKSIZE;
      result     := Offset;
    end
  else
    SeekInVolumeFile(BlockNr);  // making certain that we are positioned for a short partial read

  if NrBytes > 0 then // Then a partial block
    begin
{$I-}
      BlocksRead := Blockread(TempBuf, 1);
      CheckBlockCount(1, BlocksRead);
      PutIOResult(IOResult);  // "IOResult" is Delphi's-- not p-System
{$I+}
      Move(tempbuf, TBytes(Buf)[Offset], NrBytes);
      result := Offset + NrBytes;
    end;
end;

Function TVolume.UCSDBlockRead( var buf;
                                    Blocks:integer):integer;
 Var
    BlocksRead  :longint;
Begin              (* THIS CODE WORKS AS A STRAIGHT UCSD BLOCKREAD*)
{$I-}
  BlocksRead := Blockread(Buf, blocks);
  PutIOResult(IOResult);
{$I+}
  result := BlocksRead;
  CheckBlockCount(Result, BlocksRead);
End;

Function TVolume.UCSDBlockReadRel( var buf;
                                       Blocks: word;
                                       RelBlock: word): word;
Var
  BlocksRead : longint;
Begin
  (* THIS CODE WORKS AS A STRAIGHT UCSD BLOCKREAD*)

//WAS:  Seek(f, RelBlock+2);
  SeekInVolumeFile(RelBlock);
//{$I+}
  BlocksRead := Blockread(buf, blocks);
//{$I-}
  result     := BlocksRead;
  CheckBlockCount(BlocksRead, Blocks);
End;

procedure TVolume.CopyToVolume(SourceName, DestName: string;
  DestVol: TVolume; var ErrorMessage: string);
var
  SrcIdx, DstIdx, BlocksNeeded, DNumFiles, i: integer;

  SrcEntry: DirEntry;
  SrcBlkNr, DstBlkNr, FirstBlock: integer;
  Buffer: packed array[0..BLOCKSIZE] of char;
begin
  // Look for the source file in this volume
  FindDirectoryEntry(SourceName, SrcIdx);
//if not (SrcIdx in FILER_LEGAL_UNITS) then
  if not ((SrcIdx >= 1) and (SrcIdx <= MAXDIR)) then
    raise Exception.CreateFmt('Source file [%s] not found on current volume [%s]',
                              [SourceName, VolumeName]);
  with Directory[SrcIdx] do
    BlocksNeeded := LASTBLK - FirstBlk;

  SrcEntry := DI.Rectory[SrcIdx];  // make a copy of the source directory entry

  DestVol.FindDirectoryEntry(DestName, DstIdx);

  if DstIdx > 0 then
    if OkToOverWriteExistingFile(DestName) then
      DestVol.DeleteDirectoryEntry(DstIdx)
    else
      begin
        ErrorMessage := Format('File %s already exists in volume %s',
                               [DestName, DestVol.VolumeName]);
        Exit;
      end;

  DstIdx       := DestVol.FindEmptySpace(BlocksNeeded);
  if DstIdx > 0 then  // found a slot that is big enough
    begin
      if DestVol.Directory[0].DNUMFILES = MAXDIR then  // directory full
        begin
          ErrorMessage := Format('Directory is full (%d files).', [MAXDIR]);
          Exit;
        end;

      DNumFiles := DestVol.DI.Rectory[0].DNUMFILES;
      // Make a hole in the index
      for i := DNumFiles+1 downto DstIdx+1 do
        DestVol.DI.Rectory[i] := DestVol.DI.Rectory[i-1];

      with DestVol.DI.Rectory[0] do
        DNUMFILES := DNUMFILES + 1;

      // copy the file block by block
      SrcBlkNr   := DI.Rectory[SrcIdx].DFIRSTBLK;
      FirstBlock := DestVol.DI.Rectory[DstIdx-1].DLASTBLK; // the block immediately following the previous file
      DstBlkNr   := FirstBlock;

      // Copy the source directory entry
//    DI.RECTORY[DstIdx] := SrcEntry;
//    Temp := SrcEntry.DTID;
      DestVol.DI.RECTORY[DstIdx] := SrcEntry; // DTID would get lost because SrcEntry will be out of scope

      // and update it for its new location
      with DestVol.DI.RECTORY[DstIdx] do
        begin
          DTID      := DestName;
          DFIRSTBLK := FirstBlock; // need to set the new First Block Number
          DLASTBLK  := FirstBlock + BlocksNeeded; // need to set the new Last Block Number
          DFKIND    := FixDFKind(DFKIND);         // Version II and earlier may not be able to handle
        end;

      for i := 0 to BlocksNeeded-1 do
        begin
          // read a block from the source volume
          SeekInVolumeFile(SrcBlkNr+i);
          BlockRead(Buffer, 1);

          // write it to the destination volume
          DestVol.SeekInVolumeFile(DstBlkNr+i);
          DestVol.BlockWrite(Buffer, 1);
        end;

      DestVol.DirectoryChanged('CopyToVolume');
      // update the destination directory
      if DestVol.CloseVolumeFile then
        UpdateStatus(Format('Copied %s.%s to %s.%s', [VolumeName, SourceName,
                                                      DestVol.VolumeName, DestName]));
      DestVol.LoadVolumeInfo(DIRECTORY_BLOCKNR);         // restore the destination volume directory
    end;
end;


function TVolume.CleanUpDirectory: boolean;
var
  i: integer;
begin
  for i := 0 to DI.rectory[0].DNUMFILES do
    with DI.RECTORY[i] do
      begin
        DFKIND := FixDFKind(DFKIND);
        if i = 0 then
          begin
            DLASTBOOT := FixYear(DLASTBOOT);  // Year > 100 might get the entry deleted from the directory
//          DNUMFILES := DNUMFILES mod 256;   // Trying to fix corrupted DNUMFILES, i.e. Low Byte only
          end
        else
          DACCESS   := FixYear(DACCESS);
      end;

  result := YesFmt('Do you want to update the directory of "%s"?', [VolumeName]);
  if result then
    begin
      DirectoryChanged('CleanUpDirectory');
      CloseVolumeFile;
      LoadVolumeInfo(DIRECTORY_BLOCKNR);         // reload the updated volume info
    end;
end;

procedure TVolume.DirectoryChanged(const by: string);
begin
  fDirectoryChangedBy := by;
  fDirectoryChanged   := true;
end;

function TVolume.VolumeBlocks: integer;
begin
  result := Directory[0].DEOVBLK;
end;

procedure TVolume.SetOnPutIOResult(const Value: TOnPutIOResult);
begin
  fOnPutIOResult := Value;
end;

procedure TVolume.SegmentInfoScan(DirIdx: integer; const OutputFile: TextFile; SearchInfoPtr: TSearchInfoPtr);
const
  BYTESPERBLOCK = 512;
  WORDSPERBLOCK = BYTESPERBLOCK div 2;

var
  SegmentAsBytesPtr : TMemAsBytesPtr;
  SegmentAsWordsPtr : TMemAsWordsPtr;
  DictPtr           : SDRecordPtr;
  NrBlocks          : integer;
  SegNum            : integer;
  ByteOffset        : longword;
  WordOffset        : longword;
  NrProcs           : word;
  CodeAddr          : integer;
  CodeLengBytes     : longint;
  CodeLengWords     : longint;
  aSegNum           : integer;
  Flag              : string;
  aFileName         : string;
  Line              : string;
  StatusMsg         : string;
  MajorVersion      : TVersions;
  VersionStr        : string;
  Origin            : string;
  temp              : string;
  fld               : TFieldNumbers;
  SegDicRec         : TSegDicRec;
  Flipped           : boolean;
//Addr              : word;
//pn                : integer;
  sex               : word;
  ProcDictOffset    : word;

  procedure StatusMessage(const Msg: string);
  var
    StatusMsg: string;
  begin { StatusMessage }
    if Assigned(fOnStatusProc) then
      begin
        StatusMsg := Format('********** %s: %s:%s', [Msg, VolumeName, Fields[ord(FLD_pSys_FileName)]]);
        fOnStatusProc(StatusMsg, True, true);
      end;
  end;  { StatusMessage }

  procedure ErrorMessage(const msg: string);
  begin { ErrorMessage }
    Inc(SearchInfoPtr.NumberOfErrors);
    with SearchInfoPtr^ do
      Fields[ord(FLD_Error_Number)] := Format('Err = %d', [NumberOfErrors]);
    Line := Contruct_Delimited_Line(Fields, Delimited_Info);
    WriteLn(OutputFile, Line);   // output what we know so far

    if Assigned(fOnStatusProc) then
      begin
        StatusMsg := Format('********** %4d, %s: %s:%s', [SearchInfoPtr.NumberOfErrors, Msg, VolumeName, Fields[ord(FLD_pSys_FileName)]]);
        fOnStatusProc(StatusMsg, True, true);
      end;
  end;  { ErrorMessage }

  procedure SetCodeLengths(MajorVersion: TVersions; StoredLength: integer);
  begin
    if MajorVersion >= iv then
      begin
        CodeLengBytes := StoredLength * 2;      // CODEleng is a word count in version IV
                                                             // but a byte count in V1.4, 1.5, 2.0
        CodeLengWords := StoredLength;
      end
    else
      begin
        CodeLengBytes := StoredLength;          // CODEleng is a word count in version IV
                                                             // but a byte count in V1.4, 1.5, 2.0
        CodeLengWords := StoredLength div 2;
      end;;
  end;

  function FlipIt(w: word): word;
  begin
    result := ((w and $FF) shl 8) + (w shr 8);
  end;

begin { TVolume.SegmentInfoScan }
  try
    for fld := Low(TFieldNumbers) to High(TFieldNumbers) do
      Fields[ord(fld)] := '';    // clean out previous values

    with Directory[DirIdx] do
      begin
        Fields[ord(FLD_DOS_Volume_Name)]  := DOSFileName;
        Fields[ord(FLD_pSys_Volume_Name)] := VolumeName;
        Fields[ord(FLD_pSys_FileName)]    := PrintableOnly2(FileName);
        Fields[ord(FLD_Volume_Date)]      := DateToStr(LastBoot);
        Fields[ord(FLD_File_Date)]        := DateToStr(DateAccessed);

        NrBlocks := LASTBLK - FirstBlk;
        GetMem(SegmentAsBytesPtr, NrBlocks * BYTESPERBLOCK);
        try
          Move(SegmentAsBytesPtr, SegmentAsWordsPtr, 4); // access as words
          Move(SegmentAsBytesPtr, DictPtr, 4);           // access the first block as a segment dictionary
          // locate the file
          SeekInVolumeFile(FirstBlk);
          BlockRead(SegmentAsBytesPtr^, NrBlocks);

          with DictPtr^ do
            begin
              MajorVersion := ExtractMajorVersion(SegInfo[0].SegInfo);

              CodeAddr := DiskInfo[0].CodeAddr;
              if (CodeAddr <> 0) then
                begin
                  Flipped := ItIsFlipped(TSeg_DictPtr(DictPtr)^);
                  if Flipped then
                    begin
                      SegDicRec.Dict := TSeg_DictPtr(DictPtr)^;     // make a copy for use in FlipSegDic
                      Fields[ord(FLD_ItIsFlipped)]      := 'True';
                      FlipSegDic( SegDicRec, MajorVersion) ;        // flip the segment dictionary
                      TSeg_DictPtr(DictPtr)^ := SegDicRec.Dict;     // put it back to where it came from

                      if ItIsFlipped(TSeg_DictPtr(DictPtr)^) then   // flipping it above didn't work
                        begin
                          ErrorMessage( Format('Unable to determine gender of %s', [FileName] )) ;
                          exit;
                        end;

                      StatusMessage('Segment dictionary flipped');
                    end;
                end;
            end;

        // Process each segment in the dictionary

          for SEGNUM := 0 to MAXSEG {15} do
            with DictPtr^ do
              begin // start
                aSegNum  := SEGNUM;

                Fields[ord(FLD_SEG_NR)]           := IntToStr(SEGNUM);

                CodeAddr := DiskInfo[SEGNUM].CodeAddr;

                if CodeAddr <> 0 then
                  begin
                    Fields[ord(FLD_SegKind)]          := Hexword(SegKind[SEGNUM]);
                    Fields[ord(FLD_Info)]             := Hexword(SegInfo[SEGNUM].SegInfo);

                    SetCodeLengths(MajorVersion, DiskInfo[SEGNUM].CODEleng);

                    if (CodeAddr < 0) or (CodeLengBytes < 0) then
                      begin
                        ErrorMessage('Invalid CodeAddr or CodeLeng');
                        Break;
                      end;

                    VersionStr := MajorVersionNames[MajorVersion];

                    if MajorVersion < iv then // UCSD Version
                      Origin := 'UCSD'
                    else
                      Origin := 'SMS';

                    Temp := UCSDName(SegNamesII[SEGNUM]);

                    if IsIdentifier(temp) then
                      Fields[ord(FLD_Segment_Name)]     := temp
                    else
                      begin
                        ErrorMessage(Format('Invalid segment name in %s:%s, SegNum = %d',
                                            [VolumeName, FileName, SegNum]));
                        break;
                      end;

                    ByteOffset := CodeAddr * BYTESPERBLOCK; // to the start of the segment block
                    WordOffset := CodeAddr * WORDSPERBLOCK;

                    if (ByteOffset + CodeLengBytes) > (NrBlocks * BYTESPERBLOCK) then
                      if Assigned(fOnStatusProc) then
                        begin
                          ErrorMessage('Invalid buffer offset');
                          Break;
                        end;

                    if MajorVersion = iv then
                      begin
                        Sex            := SegmentAsWordsPtr^[WordOffset+6]; // get the byte sex flag
                        Flipped        := Sex = 256;
                        ProcDictOffset := SegmentAsWordsPtr^[WordOffset];   // The first word of the segment (does this need to be flipped?)
                        if Flipped then
                          ProcDictOffset := FlipIt(ProcDictOffset);
                        NrProcs        := SegmentAsWordsPtr^[WordOffset+ProcDictOffset];
                        if Flipped then // must be flipped
                          NrProcs    := FlipIt(NrProcs);
(*                      This code has not been tested
                        for pn := 1 to NrProcs do
                          begin
                            ProcAddr := SegmentAsWordsPtr^[WordOffset + ProcDictOffset - pn];
                            if Flipped then
                              ProcAddr := FlipIt(ProcAddr);
                          end;
*)
                      end
                    else
                      begin
                        aSegNum := SegmentAsBytesPtr^[ByteOffset+CodeLengBytes-2];    // segment number is stored in the last word of the segment
                        NrProcs := SegmentAsBytesPtr^[ByteOffset+CodeLengBytes-1];    // NrProcs is stored in the last word of the segment
                      end;

                    Flag := IIF(SEGNUM = aSegNum, ' ', 'X');

                    aFileName := FileName;

                    Fields[ord(FLD_Version)]          := VersionStr;
                    Fields[ord(FLD_Origin)]           := Origin;
                    Fields[ord(FLD_CodeFirstBlock)]   := IntToStr(CODEaddr);
//                  Fields[ord(FLD_CodeNrBlocks)]     := IntToStr(NrBlocks);
                    Fields[ord(FLD_CodeLeng)]         := IntToStr(CodeLengBytes);  (* *)
                    Fields[ord(FLD_NrProcs)]          := IntToStr(NrProcs);
                    Fields[ord(FLD_Flag)]             := Flag;

                    Line := Contruct_Delimited_Line(Fields, Delimited_Info);

                    WriteLn(OutputFile, Line);

                    with SearchInfoPtr^ do
                      inc(MatchesFound);
                  end;
              end;  // end
          finally
            FreeMem(SegmentAsBytesPtr);
          end;
      end;
  except
    on e:Exception do
      ErrorMessage(e.Message);
  end;
end;  { TVolume.SegmentInfoScan }

procedure TVolume.ProcedureInfoScan(DirIdx: integer; const OutputFile: TextFile; SearchInfoPtr: TSearchInfoPtr);
const
  BYTESPERBLOCK = 512;
  WORDSPERBLOCK = BYTESPERBLOCK div 2;

var
  SegmentAsBytesPtr : TMemAsBytesPtr;
  SegmentAsWordsPtr : TMemAsWordsPtr;
  DictPtr           : SDRecordPtr;
  NrBlocks          : integer;
  SegNum            : integer;
  ByteOffset        : longword;
  WordOffset        : longword;
  NrProcs           : word;
  CodeAddr          : integer;
  CodeLengBytes     : longint;
  CodeLengWords     : longint;
//aSegNum           : integer;
//Flag              : string;
  aFileName         : string;
  Line              : string;
  StatusMsg         : string;
  MajorVersion      : TVersions;
  VersionStr        : string;
  Origin            : string;
  temp              : string;
//fld               : TFieldNumbers;
  SegDicRec         : TSegDicRec;
  Flipped           : boolean;
//Addr              : word;
  pn                : integer;
  sex               : word;
  ProcDictOffset    : word;
  ProcAddr          : word;
  
  procedure StatusMessage(const Msg: string);
  var
    StatusMsg: string;
  begin { StatusMessage }
    if Assigned(fOnStatusProc) then
      begin
        StatusMsg := Format('********** %s: %s:%s', [Msg, VolumeName, Fields[ord(FLD_pSys_FileName)]]);
        fOnStatusProc(StatusMsg, True, true);
      end;
  end;  { StatusMessage }

  procedure ErrorMessage(const msg: string);
  begin { ErrorMessage }
    Inc(SearchInfoPtr.NumberOfErrors);
    WriteLn(OutputFile, Line);   // output what we know so far

    if Assigned(fOnStatusProc) then
      begin
        StatusMsg := Format('********** %4d, %s:%s', [SearchInfoPtr.NumberOfErrors, Msg, VolumeName]);
        fOnStatusProc(StatusMsg, True, true);
      end;
  end;  { ErrorMessage }

  procedure SetCodeLengths(MajorVersion: TVersions; StoredLength: integer);
  begin
    if MajorVersion >= iv then
      begin
        CodeLengBytes := StoredLength * 2;      // CODEleng is a word count in version IV
                                                             // but a byte count in V1.4, 1.5, 2.0
        CodeLengWords := StoredLength;
      end
    else
      begin
        CodeLengBytes := StoredLength;          // CODEleng is a word count in version IV
                                                             // but a byte count in V1.4, 1.5, 2.0
        CodeLengWords := StoredLength div 2;
      end;;
  end;

  function FlipIt(w: word): word;
  begin
    result := ((w and $FF) shl 8) + (w shr 8);
  end;

begin { ProcedureInfoScan }
  try
    with Directory[DirIdx] do
      begin
        WriteLn(OutputFile, 'DOS FileName,',     DOSFileName);
        WriteLn(OutputFile, 'Sys_Volume_Name,' , VolumeName);
        WriteLn(OutputFile, 'pSys_FileName,',    PrintableOnly2(FileName));
        WriteLN(OutputFile, 'Last Boot,',        DateToStr(LastBoot));

        NrBlocks := LASTBLK - FirstBlk;
        GetMem(SegmentAsBytesPtr, NrBlocks * BYTESPERBLOCK);
        try
          Move(SegmentAsBytesPtr, SegmentAsWordsPtr, 4); // access as words
          Move(SegmentAsBytesPtr, DictPtr, 4);           // access the first block as a segment dictionary
          // locate the file
          SeekInVolumeFile(FirstBlk);
          BlockRead(SegmentAsBytesPtr^, NrBlocks);

          with DictPtr^ do
            begin
              MajorVersion := ExtractMajorVersion(SegInfo[0].SegInfo);

              CodeAddr := DiskInfo[0].CodeAddr;
              if (CodeAddr <> 0) then
                begin
                  Flipped := ItIsFlipped(TSeg_DictPtr(DictPtr)^);
                  if Flipped then
                    begin
                      SegDicRec.Dict := TSeg_DictPtr(DictPtr)^;     // make a copy for use in FlipSegDic
                      FlipSegDic( SegDicRec, MajorVersion) ;        // flip the segment dictionary
                      TSeg_DictPtr(DictPtr)^ := SegDicRec.Dict;     // put it back to where it came from

                      if ItIsFlipped(TSeg_DictPtr(DictPtr)^) then   // flipping it above didn't work
                        begin
                          ErrorMessage( Format('Unable to determine gender of %s', [FileName] )) ;
                          exit;
                        end;

                      StatusMessage('Segment dictionary flipped');
                    end;
                end;
            end;

        // Process each segment in the dictionary

          for SEGNUM := 0 to MAXSEG {15} do
            with DictPtr^ do
              begin // start
//              aSegNum  := SEGNUM;

                CodeAddr := DiskInfo[SEGNUM].CodeAddr;

                if CodeAddr <> 0 then
                  begin

                    SetCodeLengths(MajorVersion, DiskInfo[SEGNUM].CODEleng);

                    if (CodeAddr < 0) or (CodeLengBytes < 0) then
                      begin
                        ErrorMessage('Invalid CodeAddr or CodeLeng');
                        Break;
                      end;

                    VersionStr := MajorVersionNames[MajorVersion];

                    if MajorVersion < iv then // UCSD Version
                      Origin := 'UCSD'
                    else
                      Origin := 'SMS';

                    Temp := UCSDName(SegNamesII[SEGNUM]);

                    if not IsIdentifier(temp) then
                      begin
                        ErrorMessage(Format('Invalid segment name in %s:%s, SegNum = %d',
                                            [VolumeName, FileName, SegNum]));
                        break;
                      end;

                    ByteOffset := CodeAddr * BYTESPERBLOCK; // to the start of the segment block
                    WordOffset := CodeAddr * WORDSPERBLOCK;

                    if (ByteOffset + CodeLengBytes) > (NrBlocks * BYTESPERBLOCK) then
                      if Assigned(fOnStatusProc) then
                        begin
                          ErrorMessage('Invalid buffer offset');
                          Break;
                        end;

                    if MajorVersion = iv then
                      begin
                        Sex            := SegmentAsWordsPtr^[WordOffset+6]; // get the byte sex flag
                        Flipped        := Sex = 256;
                        ProcDictOffset := SegmentAsWordsPtr^[WordOffset];   // The first word of the segment (does this need to be flipped?)
                        if Flipped then
                          ProcDictOffset := FlipIt(ProcDictOffset);
                        NrProcs        := SegmentAsWordsPtr^[WordOffset+ProcDictOffset];
                        if Flipped then // must be flipped
                          NrProcs    := FlipIt(NrProcs);
//                      This code has not been tested
                        WriteLn(OutputFile, 'File Name,',    FileName);
                        WriteLn(OutputFile, 'Segment #,',      SEGNUM);
                        Writeln(OutputFile, 'Segment Name,', Temp);
                        WriteLn(OutputFile, 'Flipped,',      TF(Flipped));
                        WriteLn(OutputFile, 'Byte Sex,',     Sex);
                        WriteLn(OutputFile, 'Version,',      VersionStr);
                        WriteLn(OutputFile, 'Origin,',       Origin);
                        WriteLn(OutputFile, 'Start block,',  CODEaddr);
                        WriteLn(OutputFile, 'Code Leng Bytes,', CodeLengBytes);
                        WriteLn(OutputFile, 'Nr Procs,',      NrProcs);

                        for pn := 1 to NrProcs do
                          begin
                            ProcAddr := SegmentAsWordsPtr^[WordOffset + ProcDictOffset - pn];
                            if Flipped then
                              ProcAddr := FlipIt(ProcAddr);
                            WriteLn(OutputFile, ',,':10, pn:5, ',', BothWays(ProcAddr));
                          end;
                      end
                    else
                      begin
                        Alert('non-version IV segments');
//                      aSegNum := SegmentAsBytesPtr^[ByteOffset+CodeLengBytes-2];    // segment number is stored in the last word of the segment
//                      NrProcs := SegmentAsBytesPtr^[ByteOffset+CodeLengBytes-1];    // NrProcs is stored in the last word of the segment
                      end;


                    aFileName := FileName;

                    with SearchInfoPtr^ do
                      inc(MatchesFound);
                  end;
              end;  // end
          finally
            FreeMem(SegmentAsBytesPtr);
          end;
      end;
  except
    on e:Exception do
      ErrorMessage(e.Message);
  end;
end; { ProcedureInfoScan }

procedure TVolume.ScanVolumeForSegmentInfo(SearchInfoPtr: TSearchInfoPtr; const OutputFile: TextFile);
var
  DirIdx: integer;
  DoLog, DoStatus: boolean;
begin
  DirIdx := 1;
  try
    while DirIdx <= NumFiles do
      begin
        if OkDateTime(Directory[DirIdx].DateAccessed, SearchInfoPtr.LowDate, SearchInfoPtr.HighDate) then
          if Directory[DirIdx].xDFKIND = kSVOLFILE then
            begin
              MountSVOL(DirIdx);
              try
                CurrentSVOL.ScanVolumeForSegmentInfo( SearchInfoPtr, OutputFile);
                inc(SearchInfoPtr.VolumesSearched);
              finally
                FreeAndNil(CurrentSVOL);
              end;
            end
          else
            with Directory[DirIdx] do
              if FileName = CSYSTEM_MISCINFO then
                { try to get version number from SYSTEM.MISCINFO }
              else
                if IsCodeFile(DirIdx) then
                  if (Length(SearchInfoPtr.SearchString) = 0) then
                    SegmentInfoScan(DirIdx, OutputFile, SearchInfoPtr)
                  else
                    if Wild_Match(@FileName[1], @SearchInfoPtr.SearchString[1], '*', '?', false) then
                       SegmentInfoScan(DirIdx, OutputFile, SearchInfoPtr);
        inc(DirIdx);
      end;
// UpdateStatus('', true, true);

  except
    on e:Exception do
      begin
        DoLog    := SearchInfoPtr.LogMountingErrors;
        DoStatus := true;
        if Assigned(fOnStatusProc) then
          fOnStatusProc(Format('%s: while processing volume %s [%s]',
                              [e.Message, VolumeName, DOSFileName]), DoLog, DoStatus);
      end;
  end;
end;

procedure TVolume.ScanVolumeForProcedureInfo(SearchInfoPtr: TSearchInfoPtr; const OutputFile: TextFile);
var
  DirIdx: integer;
  DoLog, DoStatus: boolean;
begin
  DirIdx := 1;
  try
    while DirIdx <= NumFiles do
      begin
        if OkDateTime(Directory[DirIdx].DateAccessed, SearchInfoPtr.LowDate, SearchInfoPtr.HighDate) then
          if Directory[DirIdx].xDFKIND = kSVOLFILE then
            begin
              MountSVOL(DirIdx);
              try
                CurrentSVOL.ScanVolumeForProcedureInfo( SearchInfoPtr, OutputFile);
                inc(SearchInfoPtr.VolumesSearched);
              finally
                FreeAndNil(CurrentSVOL);
              end;
            end
          else
            with Directory[DirIdx] do
              if IsCodeFile(DirIdx) then
                if (Length(SearchInfoPtr.SearchString) = 0) then
                  ProcedureInfoScan(DirIdx, OutputFile, SearchInfoPtr)
                else
                  if Wild_Match(@FileName[1], @SearchInfoPtr.SearchString[1], '*', '?', false) then
                     ProcedureInfoScan(DirIdx, OutputFile, SearchInfoPtr);
        inc(DirIdx);
      end;

  except
    on e:Exception do
      begin
        DoLog    := SearchInfoPtr.LogMountingErrors;
        DoStatus := true;
        if Assigned(fOnStatusProc) then
          fOnStatusProc(Format('%s: while processing volume %s [%s]',
                              [e.Message, VolumeName, DOSFileName]), DoLog, DoStatus);
      end;
  end;
end;

end.
