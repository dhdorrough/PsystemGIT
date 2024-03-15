unit VolumeConverter;

interface

uses
  MyUtils, Classes;

const
  SECTORSIZE         = 256;
  H8DSECTORSPERTRACK = 10;
  H8DTRACKSPERDISK   = 40;
  H8DINTERLEAVE      = 2;
  BYTES_PER_SECTOR   = 256;

  BLOCKSIZE          = 512;
  DIRECTORY_BLOCK    = 2;

  BYTES_PER_BLOCK    = 512;
  NR_TRACKS          = 40;
  SECTORS_PER_TRACK  = 10;
  HALF_TRACK         = SECTORS_PER_TRACK DIV 2;
  LAST_BLOCK_NUMBER  = NR_TRACKS * SECTORS_PER_TRACK;


type
  TBlock = record
             case integer of
               0: (B: array[0..BLOCKSIZE-1] of byte);
               1: (A: array[0..BLOCKSIZE-1] of char);
             end;

  TSector = record
                case integer of
                  0: (b: packed array[0..SECTORSIZE-1] of byte);
                  1: (a: packed array[0..SECTORSIZE-1] of char)
                end;

  TStatusProc = procedure {name} (const Msg: string) of object;

  TVolumeConverter = class
  private
    TextOutFile : TextFile;
  public
    function ConvertVolume(const SrcFileName, DstFileName: string): boolean; virtual;
    function FindTextBlocksInFile(const SrcFileName: string; DstFileName: string): integer; virtual;
    function IsAsciiSector(H8DBlock: TSector): boolean;
    procedure LoadText(aSector: TSector; TextList: TStringList);
    function LogicalSectorToPhysicalSector(LogSecNum: integer): integer; virtual;
    function LoadBlock(BlockNr: integer; var aBlock: TBlock): boolean; virtual; 
    function PhysicalSectorToLogicalSector(PhysSector: integer): integer; virtual; 
  end;

  TSectorFile  = file of TSector;
  TInFileBlock = file of TBlock;

  TH8DConverter = class(TVolumeConverter)
  private
    fSkew       : integer;
    fBaseTrackNo: integer;
    fInFileName : string;
    fLastTrackNo: integer;
    fNrSectorsWritten: integer;
    fOnUpdateLog: TStatusProc;
    fSrcFileName: string;
    InFile      : TSectorFile;
    InFileBlock : TInFileBlock;
    Outfile     : TSectorFile;
    InFileOpened: boolean;
    OutFileOpened: boolean;
    InFileBlockOpened: boolean;
    CurrentSector: TSector;
    P2LTable     : array of {Track} array of {sector} integer;

    function GetSkew: integer;
    procedure SetSkew(const Value: integer);
    function GetBaseTrackNo: integer;
    procedure SetBaseTrackNo(const Value: integer);
    procedure UpdateLog(const Msg: string);
  public
    TrackNo: integer;
    TrackSector, TS2: integer;
    TrackSkew: integer;
    property BaseTrackNo: integer
             read GetBaseTrackNo
             write SetBaseTrackNo;

    property Skew: integer
             read GetSkew
             write SetSkew;

    property NrSectorsWritten: integer
             read fNrSectorsWritten
             write fNrSectorsWritten;

    property OnUpdateLog: TStatusProc
             read fOnUpdateLog
             write fOnUpdatelog;

    procedure CloseInfile;
    function  ConvertVolume(const SrcFileName, DstFileName: string): boolean; override;
    function  LoadBlock(BlockNr: integer; var aBlock: TBlock): boolean; override;
    function  LogicalSectorToPhysicalSector(LogSecNum: integer): integer; override;
    function  OpenInFile(const FileName: string): boolean;
    procedure OpenInFileBlock(const SrcFileName: string);
    procedure OpenOutFile(const FileName: string);
    function  PhysicalSectorToLogicalSector(PhysSector: integer): integer; override;
    function  ReadSector(rec: integer; var mySector: TSector): boolean;
    function  SectorTranslate(BaseTrackNo, LogSectorNo: integer): integer;
    procedure WriteSector(const mySector: TSector);
    Constructor Create;
    Destructor Destroy; override;
  end;


var

  ANYASCIICHAR: TSetOfChar;

implementation

uses SysUtils;

const
  DLE = #16; // blank compression code

Function TH8DConverter.SectorTranslate(BaseTrackNo, LogSectorNo:integer):integer;
Begin
  result := (BaseTrackNo * SECTORS_PER_TRACK) +
             LogicalSectorToPhysicalSector(LogSectorNo);
end;

function TH8DConverter.LogicalSectorToPhysicalSector(LogSecNum: integer): integer;
var
  TrackBase: integer;
begin
(*
patterns:
TRACK 0: 04 06 08 00 02 - 05 07 09 01 03
TRACK 1: 10 12 14 16 18 - 11 13 15 17 19
TRACK 2: 26 28 20 22 24 - 27 29 21 23 25
TRACK 3: 32 34 36 38 30 - 33,35,37,39,31
TRACK 4: 48,40,42,44,46 - 49,41,43,45,47
TRACK 5: 54,56,58,50,52 - 55,57,59,51,53
TRACK 6: 60,62,64,66,68 - 61,63,65,67,69
TRACK 7: 76,78,70,72,74 - 77 79
*)
(*  THIS IS THE CLOSEST VERSION
  TrackNo     := LogSecNum div 10;
  TrackBase   := TrackNo * 10;   { 10, 20, 30,... }
  TrackSector := (LogSecNum mod 10);        { 0..9 }
  TS2         := IIF(TrackSector < 5, (TrackSector * 2), ((TrackSector-5) * 2)+1);
  TrackSkew   := ((TrackNo-3) * 6) mod 10;
  result      := TrackBase + (TS2 + TrackSkew) mod 10;
*)
  TrackNo     := LogSecNum div 10;
  TrackBase   := TrackNo * 10;   { 10, 20, 30,... }
  TrackSector := (LogSecNum mod 10);        { 0..9 }
  TS2         := IIF(TrackSector < 5, (TrackSector * 2), ((TrackSector-5) * 2)+1);
  TrackSkew   := (TrackNo * Skew) mod 10;
  result      := TrackBase + (TS2 + TrackSkew) mod 10;
end;

function TVolumeConverter.IsAsciiSector(H8DBlock: TSector): boolean;
var
  Idx: integer;
  ch: char;
  mode: TSearch_Type; // (SEARCHING, SEARCH_FOUND, NOT_FOUND);
begin { IsAsciiSector }
  Idx := 0;
  mode := SEARCHING;  // for non-ascii
  repeat
    if Idx >= SECTORSIZE then
      mode := NOT_FOUND
    else
      begin
        ch := H8DBlock.A[Idx];
        if (ch = DLE) then  // ignore compression code & char following
          Idx := Idx + 1
        else
          if ch = #0 then
            mode := NOT_FOUND
          else
            if not (ch in ANYASCIICHAR) then
              mode := SEARCH_FOUND // found non-ascii
            else
              Idx := Idx + 1;
      end;
  until mode <> SEARCHING;
  result := (mode = NOT_FOUND) and (Idx >= 10);  // TRUE if we didn't find any non-ascii characters and at least 10 ASCII
end;  { IsAsciiSector }

procedure TVolumeConverter.LoadText(aSector: TSector; TextList: TStringList);
var
  Idx, i: integer;
  ch: char;
  chg: integer;
  mode: TSearch_Type; // (SEARCHING, SEARCH_FOUND, NOT_FOUND);
  Line: string;
begin { LoadText }
  TextList.Clear;
  Idx := 0;
  Line := '';
  mode := SEARCHING;  // for non-ascii
  repeat
    if Idx >= SECTORSIZE then
      begin
        TextList.Add(Line);
        mode := NOT_FOUND;
      end
    else
      begin
        ch := aSector.A[Idx];
        if (ch = DLE) then  // ignore compression code & char following
          begin
            if Idx < (SECTORSIZE-1) then  // DLE could occur at the end of a physical block
              begin
                chg     := ord(aSector.a[Idx+1])-ORD( ' ' );           // get number of blanks to insert
                for i := 1 to chg do
                  Line := Line + ' ';
              end;
            Idx := Idx + 2; // skip past the DLE & the blank count
          end else
        if ch in [#13, #10] then // CR or LF
          begin
            TextList.Add(Line);
            Line := '';
            while (Idx < SECTORSIZE) and (aSector.a[Idx] in [#13, #10]) do
              Idx := Idx + 1;
          end else
        if ch = #0 then
          begin
            TextList.Add(Line);
            mode := NOT_FOUND  // end of the text in the block
          end else
        if not (ch in ANYASCIICHAR) then
          mode := SEARCH_FOUND // found non-ascii. Time to quit. Shouldn't happen in this function
        else
          begin
            Line := Line + ch; // add the character to the line
            Idx := Idx + 1;
          end;
      end;
  until mode <> SEARCHING;
end;  { LoadText }

function TH8DConverter.LoadBlock(BlockNr: integer; var aBlock: TBlock): boolean;
var
  L1, L2: integer;
  P1, P2: integer;
  NrRead: integer;
  Union: record
           case integer of
             0: (HD8: array[0..1] of TSector);
             1: (Blk: TBlock)
           end;
begin { LoadBlock }
  L1 := BlockNr * 2;
  L2 := (BlockNr * 2) + 1;
  P1 := LogicalSectorToPhysicalSector(L1);
//N1 := ByteOffset(P1);
  P2 := LogicalSectorToPhysicalSector(L2);
//N2 := ByteOffset(P2);
  Seek(InFile, P1);
  BlockRead(InFile, Union.HD8[0], 1, NrRead);
  result := NrRead = 1;
  if result then
    begin
      Seek(InFile, P2);
      BlockRead(InFile, Union.HD8[1], 1, NrRead);
      result := NrRead = 1;
      if result then
        aBlock := Union.Blk;
    end
end;  { LoadBlock }

procedure TH8DConverter.UpdateLog(const Msg: string);
begin
  if Assigned(fOnUpdateLog) then
    fOnUpdateLog(Msg);
end;

procedure TH8DConverter.OpenInFileBlock(const SrcFileName: string);
begin
  AssignFile(InFileBlock, SrcFileName);
  reset(InfileBlock);
  InFileBlockOpened := true;
end;

function TH8DConverter.ConvertVolume(const SrcFileName,DstFileName: string): boolean;
var LogTrackNo, PhysTrackNo, LogTrackSector, LogSectorNo,
    PhysSectorNo: integer;
begin
  try
    CloseInfile;
    OpenInfile(SrcFileName);
    fSrcFileName := SrcFileName;
    OpenOutFile(DstFileName);
    NrSectorsWritten := 0;
    try
      for LogTrackNo := 0 to NR_TRACKS-1 do begin
        for LogTrackSector := 0 to SECTORS_PER_TRACK-1 do
          begin
            if LogTrackNo <> fLastTrackNo then
              UpdateLog('');
            PhysTrackNo  := LogTrackNo + BaseTrackNo;
            LogSectorNo  := (LogTrackNo * SECTORS_PER_TRACK) + LogTrackSector;
            PhysSectorNo := SectorTranslate(BaseTrackNo, LogSectorNo);
            UpdateLog(Format('LogTrackNo=%2d; PhysTrackNo=%2d, LogTrackSector=%2d; PhysSectorNo=%2d',
                           [LogTrackNo, PhysTrackNo, LogTrackSector, PhysSectorNo]));
            readSector(PhysSectorNo, CurrentSector);
            WriteSector(CurrentSector);
            NrSectorsWritten := NrSectorsWritten + 1;
            fLastTrackNo := LogTrackNo;
          end;
        end;
      result := true;
    finally
      CloseFile(OutFile);
      CloseInfile;
    end;
  except
    result := false;
  end;
end;

function TH8DConverter.GetSkew: integer;
begin
  result := fSkew;
end;

procedure TH8DConverter.SetSkew(const Value: integer);
begin
  fSkew := Value;
end;

function TH8DConverter.PhysicalSectorToLogicalSector(PhysSector: integer): integer;
var
  Track, Sector: integer;
begin
  Track  := PhysSector div H8DSECTORSPERTRACK;
  Sector := PhysSector mod H8DSECTORSPERTRACK;
  result := P2LTable[Track, Sector];
end;

constructor TH8DConverter.Create;
var
  Track, Sector: integer;
  LogSecNum, PhysSecNum: integer;
begin
  inherited;

  Skew := 6;
  BaseTrackNo := 1;

  SetLength(P2LTable, H8DTRACKSPERDISK);
  for Track := 0 to H8DTRACKSPERDISK-1 DO
    SetLength(P2LTable[Track], H8DSECTORSPERTRACK);

  for LogSecNum := 0 to (H8DTRACKSPERDISK * H8DSECTORSPERTRACK) - 1 do
    begin
      PhysSecNum := LogicalSectorToPhysicalSector(LogSecNum);
      Track      := PhysSecNum div H8DSECTORSPERTRACK;
      Sector     := PhysSecNum mod H8DSECTORSPERTRACK;
      P2LTable[Track, Sector] := LogSecNum;
    end;
end;

destructor TH8DConverter.Destroy;
begin
  CloseInfile;
  if InFileBlockOpened then
    CloseFile(InFileBlock);

  inherited;
end;

function TH8DConverter.GetBaseTrackNo: integer;
begin
  result := fBaseTrackNo;
end;

procedure TH8DConverter.SetBaseTrackNo(const Value: integer);
begin
  fBaseTrackNo := Value;
end;

function TH8DConverter.ReadSector(rec:integer; var mySector: TSector): boolean;
Begin
  result := not Eof(InFile);
  if result then
    begin
      Seek(InFile, rec);
      if not Eof(InFile) then
        Read(Infile, mySector)
      else
        result := false;
    end;
end;

Procedure TH8DConverter.WriteSector(const mySector: TSector);
Begin
  Write(Outfile, mySector);
end;

function TH8DConverter.OpenInFile(const FileName: string): boolean;
begin
  result := true;
  try
    if not InFileOpened then
      begin
        AssignFile(infile, FileName);
        fInFileName := FileName;
        reset(infile);
        InFileOpened := true;
        result       := true;
      end;
  except
    result := false;
  end;
end;

procedure TH8DConverter.CloseInfile;  // Why was this commented out?
begin
  if InFileOpened then
    begin
      CloseFile(InFile);
      InFileOpened := false;
    end;
end;

procedure TH8DConverter.OpenOutFile(const FileName: string);
begin
  AssignFile(outfile, FileName); {iisource\outfile.vol');}
  rewrite(outfile);
  OutFileOpened := true;
end;


{ TVolumeConverter }

function TVolumeConverter.FindTextBlocksInFile(const SrcFileName: string; DstFileName: string): integer;
var
  NrBlocks, NrSectors, Sector, LogSecNum, i: integer;
  H8DBlock: TSector;
  TextList: TStringList;
  InFile  : TSectorFile;
  Size    : integer;

  procedure BreakLine;
  begin
    WriteLn(TextOutFile, Padr('', 80, '-'));
  end;

begin { FindTextBlocksInFile }
  result := 0;
  Size   := FileSize32(SrcFileName);
  NrSectors := Size div BYTES_PER_SECTOR;
  AssignFile(InFile, SrcFileName);
  Reset(InFile);
  AssignFile(TextOutFile, DstFileName);
  ReWrite(TextOutFile);
  WriteLn(TextOutFile, Format('Listing of text blocks in "%s"', [SrcFileName]));
  WriteLn(TextOutFile, Format('at %s.', [DateTimeToStr(now)]));
  WriteLn(TextOutFile, Format('Assuming %d bytes/sector.', [BYTES_PER_SECTOR]));
  WriteLn(TextOutFile, Format('File has %10.2f sectors. ', [Size / BYTES_PER_SECTOR]));
  WriteLn(TextOutFile, Format('Last sector has %d bytes',  [Size mod BYTES_PER_SECTOR]));
  WriteLn(TextOutFile);
  WriteLn(TextOutFile, Format('%4s: %7s %7s %7s %7s', ['#', 'PhysSec', 'Offset', 'Track', 'LogSec']));
  try
    for Sector := 0 to NrSectors-1 do
      begin
        BlockRead(InFile, H8DBlock, 1, NrBlocks);
        if IsAsciiSector(H8DBlock) then
          begin
            LogSecNum := PhysicalSectorToLogicalSector(Sector);
            WriteLn(TextOutFile, Format('%4d: %7d %7x %7d',
                                 [result+1,
                                  Sector,
                                  Sector * SECTORSIZE,
                                  LogSecNum]));
            inc(result);
          end;
      end;
    BreakLine;

    result   := 0;
    TextList := TStringList.Create;
    try
      Reset(InFile);
      for Sector := 0 to (H8DTRACKSPERDISK * H8DSECTORSPERTRACK)-1 do
        begin
          BlockRead(InFile, H8DBlock, 1, NrBlocks);
          if IsAsciiSector(H8DBlock) then
            begin
              LogSecNum := PhysicalSectorToLogicalSector(Sector);
              WriteLn(TextOutFile, Format('%4d: Offset:%x, PhySector:%d, LogSecNum:%d',
                                   [result+1,
                                    Sector * SECTORSIZE,
                                    Sector,
                                    LogSecNum]));
              LoadText(H8DBlock, TextList);
              for i := 0 to TextList.Count-1 do
                WriteLn(TextOutFile, TextList[i]);
              BreakLine;
              inc(result);
            end;
        end;
    finally
      FreeAndNil(TextList);
    end;
  finally
    CloseFile(TextOutFile);
    CloseFile(InFile);
  end;
end;  { FindTextBlocksInFile }


function TVolumeConverter.PhysicalSectorToLogicalSector(
  PhysSector: integer): integer;
begin
  result := PhysSector;  // at this level of abstraction, its as good a guess as any
end;

function TVolumeConverter.ConvertVolume(const SrcFileName,
  DstFileName: string): boolean;
begin
  result := false;  // override this
end;

function TVolumeConverter.LoadBlock(BlockNr: integer;
  var aBlock: TBlock): boolean;
begin
  result := false;  // override this
end;

function TVolumeConverter.LogicalSectorToPhysicalSector(
  LogSecNum: integer): integer;
begin
  result := -1;    // override this
end;

initialization
  ANYASCIICHAR := [' '..'~', #13, #10];
end.
