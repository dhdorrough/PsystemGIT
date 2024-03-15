unit pSysVolumesNonStandard;

interface

uses
  pSysVolumes, VolumeParams, DiskFormatUtils, Interp_Const, pSys_Decl;

type

  integer = smallint;

  TNonStandardVolume = class(TVolume)
  private
    fDiskFormat: TDiskFormats;
    fDiskFormatUtil: TDiskFormatUtil;
    fOnFetchParams: TOnFetchParams;
//  fCurrentBlockNumber: longint;
    function GetDiskFormat: TDiskFormats;
    procedure SetDiskFormat(const Value: TDiskFormats);
//  procedure SetCurrentBlockNumber(const Value: longint);
    function GetDiskFormatUtil: TDiskFormatUtil;
  protected
  public
    function  BlockRead(var buffer{: Pointer};
                            recCnt: Integer): Longint; override;
    function  BlockWrite(var buffer{: Pointer};
                            recCnt: Longint): Longint; override;
    function UnitRead(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD; override;
    function UnitWrite(var Buffer; length, BlockNumber, flag: word): TIORsltWD; override;
    Constructor Create( aOwner: TObject;
                        aDOSFileName: string;
                        aVersionNr: TVersionNr = vn_Unknown;
                        aVolStartBlockInParent: integer = 0); override;
    Destructor Destroy; override;
    procedure ResetVolumeFile; override;
    procedure SeekInVolumeFile(BlockNr: longint); override;

    property OnFetchParams: TOnFetchParams
             read fOnFetchParams
             write fOnFetchParams;
    property DiskFormatUtil: TDiskFormatUtil
             read GetDiskFormatUtil;
    property DiskFormat: TDiskFormats
             read GetDiskFormat
             write SetDiskFormat;
  end;

  TMiscVolume = class(TNonStandardVolume)
  private
    fAlg : TAlgorithms;
    procedure ConvertBlock2TS(B: integer; var T, S1, S2: longint);
  public
    function  BlockRead(var buffer{: Pointer};
                            recCnt: Integer): Longint; override;
    function  BlockWrite(var buffer{: Pointer};
                            recCnt: Longint): Longint; override;
    Constructor Create( aOwner: TObject;
                        aDOSFileName: string;
                        aVersionNr: TVersionNr = vn_Unknown;
                        aVolStartBlockInParent: integer = 0;
                        Alg: TAlgorithms = alStandard); reintroduce;
  end;

function GetNonStandardParams(DosFileName: string; var aDiskFormat: TDiskFormat): boolean;
function VOLUMEFILTERLIST: string;

implementation

uses
  Controls, SysUtils, pSysDrivers, pSysExceptions, Types, UCSDGLOB {<-FOR DEBUGGING ONLY},
  MyUtils, pSys_Const, SegMap;

{ TNonStandardVolume }

function TNonStandardVolume.BlockRead(var buffer; recCnt: Integer): Longint;
var
  sn, rn, LogSectorNo, PhysSectorNo, CurrentSectorNumber,
  LogTrackNo, LogTrackSector, SPB,
  NrSectorsRead: longint;
  p: pchar;
begin
  p := pchar(@Buffer);
  with DiskFormatUtil, DiskFormat do
    begin
      SPB := BLOCKSIZE div BPS;
      CurrentSectorNumber := fCurrentBlockNumber * SPB;
      result              := 0;  // Nr blocks read
      for rn := 0 to RecCnt - 1 do
        begin
          for sn := 0 to SPB-1 do
            begin
              LogTrackNo      := CurrentSectorNumber div SPT;
              LogTrackSector  := CurrentSectorNumber mod SPT;
//            PhysTrackNo     := LogTrackNo + Trk;
              LogSectorNo     := (LogTrackNo * SPT) + LogTrackSector;
              PhysSectorNo    := SectorTranslate(trk, LogSectorNo);;
              Seek(VolumeFile, PhysSectorNo);
              System.BlockRead(VolumeFile, p^, 1, NrSectorsRead);
              Inc(CurrentSectorNumber);
              Inc(p, BPS);
            end;
          Inc(fCurrentBlockNumber);
          inc(result);  // Nr blocks read
        end;
    end;
end;

function TNonStandardVolume.BlockWrite(var buffer; recCnt: Longint): Longint;
var
  sn, rn, LogSectorNo, PhysSectorNo, CurrentSectorNumber,
  LogTrackNo, LogTrackSector, SPB,
  NrSectorsWritten: longint;
  p: pchar;
begin
  p := pchar(@Buffer);
  with DiskFormatUtil, DiskFormat do
    begin
      SPB := BLOCKSIZE div BPS;
      CurrentSectorNumber := fCurrentBlockNumber * SPB;
      result              := 0;  // Nr blocks written
      for rn := 0 to RecCnt - 1 do
        begin
          for sn := 0 to SPB-1 do
            begin
              LogTrackNo      := CurrentSectorNumber div SPT;
              LogTrackSector  := CurrentSectorNumber mod SPT;
              LogSectorNo     := (LogTrackNo * SPT) + LogTrackSector;
              PhysSectorNo    := SectorTranslate(trk, LogSectorNo);;
              Seek(VolumeFile, PhysSectorNo);
              System.BlockWrite(VolumeFile, p^, 1, NrSectorsWritten);
              Inc(CurrentSectorNumber);
              Inc(p, BPS);
            end;
          Inc(fCurrentBlockNumber);
          inc(result);  // Nr blocks written
        end;
    end;
  fDirectoryChanged := true;
end;

constructor TNonStandardVolume.Create(aOwner: TObject;
                        aDOSFileName: string;
                        aVersionNr: TVersionNr = vn_Unknown;
                        aVolStartBlockInParent: integer = 0);
begin
  inherited Create(aOwner, aDOSFileName, aVersionNr, aVolStartBlockInParent);
  fDiskFormatUtil := TDiskFormatUtil.Create;
end;

destructor TNonStandardVolume.Destroy;
begin
  FreeAndNil(fDiskFormatUtil);
  inherited;
end;

function VOLUMEFILTERLIST: string;
var
  df: TDiskFormats;
  Temp: string;
begin
  result := 'Any File (*.*)|*.*';
  for df := Succ(Low(TDiskFormats)) to High(TDiskFormats) do
    begin
      with DiskFormatInfo[df] do
        if Ext <> '' then
          begin
            Temp := Format('%s (*.%s)|*.%s', [Desc, Ext, Ext]);
            if result = '' then
              result := Temp
            else
              result := result + '|' + Temp;
          end;
    end;
end;

function TNonStandardVolume.GetDiskFormat: TDiskFormats;
begin
  result := fDiskFormat;
end;

function GetNonStandardParams(DosFileName: string; var aDiskFormat: TDiskFormat): boolean;
var
  frmVolumeParams: TfrmVolumeParams;
begin
  frmVolumeParams := TfrmVolumeParams.Create(nil);
  try
    with frmVolumeParams do
      begin
        FileNameExtension := ExtractFileExt(DosFileName);
        result := ShowModal = mrOk;
        if result then
          with aDiskFormat do
            begin
              Desc := Description;
              Ext  := FileNameExtension;
              TPD  := TracksPerDisk;      { Tracks Per Disk }
              BPS  := BytesPerSector;     { Bytes Per Sector }
              SPT  := SectorsPerTrack;    { Sectors / Track }
              Int  := SectorInterleave;   { Interleave }
              Trk  := BaseTrackNumber;    { 1st Track }
              Skew := TrackToTrackSkew;
              Alg  := Algorithm;          { which non-standard algorithm to use }
            end;
      end;
  finally
    frmVolumeParams.Free;
  end;
end;

function TNonStandardVolume.GetDiskFormatUtil: TDiskFormatUtil;
begin
  if not Assigned(fDiskFormatUtil) then
    fDiskFormatUtil := TDiskFormatUtil.Create;
  result := fDiskFormatUtil;
end;

procedure TNonStandardVolume.ResetVolumeFile;
begin
  Reset(VolumeFile, DiskFormatUtil.DiskFormat.BPS);
  CurrentBlockNumber := 0;   // effectively rewind
end;

procedure TNonStandardVolume.SeekInVolumeFile(BlockNr: longint);
begin
  fCurrentBlockNumber := BlockNr;
end;

(*
procedure TNonStandardVolume.SetCurrentBlockNumber(const Value: longint);
begin
  fCurrentBlockNumber := Value;
end;
*)

procedure TNonStandardVolume.SetDiskFormat(const Value: TDiskFormats);
begin
  DiskFormatUtil.DiskFormat := DiskFormatInfo[Value];
  fDiskFormat               := Value;
end;

function TNonStandardVolume.UnitRead(var Buffer; length, BlockNumber,
  flag: word): TIORsltWD;
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
      raise EIOResult.CreateFmt('Error reading block %d in file "%s" (%s)',
                                [fVolStartBlockInParent+BlockNumber, fDOSFileName, e.Message]);
  end;
end;

function TNonStandardVolume.UnitWrite(var Buffer; length, BlockNumber,
  flag: word): TIORsltWD;
var
  BlocksWritten: longint;
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
        BlocksWritten := BlockWrite(Buffer, NrBlocks);
        if BlocksWritten <> NrBlocks then
          BlockError(BlocksWritten, NrBlocks, BlockNumber);
      end;

    If Remainder > 0 then
      Begin
        FillChar(TempBuf, remainder, 0);
        Move(TBytes(Buffer)[NrBlocks*BLOCKSIZE], TempBuf, remainder);
        BlocksWritten := BlockWrite(TempBuf, 1);
        if BlocksWritten <> 1 then
          BlockError(BlocksWritten, 1, BlockNumber);
      end;
    result := INOERROR;  // IOResult
  except
    on e:Exception do
      raise EIOResult.CreateFmt('Error writing block %d in file "%s" (%s)',
                                [fVolStartBlockInParent+BlockNumber, fDOSFileName, e.Message]);
  end;
end;

{ TAppleVolume }

Procedure TMiscVolume.ConvertBlock2TS(B:integer; VAR T,S1,S2:longint);   //Convert block to track and sectors
//For Apple II .DSK image in Apple Pascal
Begin
  T:=B DIV 8;
  Case B MOD 8 of {0..7 blocks per track}
    0 : begin S1:= 0; S2:=14; end;
    1 : begin S1:=13; S2:=12; end;
    2 : begin S1:=11; S2:=10; end;
    3 : begin S1:= 9; S2:= 8; end;
    4 : begin S1:= 7; S2:= 6; end;
    5 : begin S1:= 5; S2:= 4; end;
    6 : begin S1:= 3; S2:= 2; end;
    7 : begin S1:= 1; S2:=15; end;
    end;
end;

function TMiscVolume.BlockRead(var buffer; recCnt: Integer): Longint;
var
  sn, rn,
  LogTrackNo, SPB,
  NrSectorsRead: longint;
  rec: longint;
  LogTrackSector: array[0..1] of longint;
  p: pchar;
begin
  // BLOCKSIZE = 512
  // BPS       = 256
  // SPB       = 2;
  // BlocksPerTrack = 8

  p := pchar(@Buffer);
  with DiskFormatUtil, DiskFormat do
    begin
      SPB                 := BLOCKSIZE div BPS;
//    BlocksPerTrack      := SPT DIV (BLOCKSIZE DIV BPS);     // = 8
//    CurrentSectorNumber := fCurrentBlockNumber  SPB;
      result              := 0;  // Nr blocks read
      for rn := 0 to RecCnt - 1 do
        begin
          ConvertBlock2TS(fCurrentBlockNumber, LogTrackNo, LogTrackSector[0], LogTrackSector[1]);
          for sn := 0 to SPB-1 do
            begin
              rec := (LogTrackNo * 16) + LogTrackSector[sn];
              Seek(VolumeFile, rec);
              System.BlockRead(VolumeFile, p^, 1, NrSectorsRead);
              Inc(p, BPS);
            end;
          Inc(fCurrentBlockNumber);
          inc(result);  // Nr blocks read
        end;
    end;
end;

function TMiscVolume.BlockWrite(var buffer; recCnt: LONGINT): Longint;
var
  sn, rn,
  LogTrackNo, SPB,
  NrSectorsWritten: longint;
  rec: longint;
  LogTrackSector: array[0..1] of longint;
  p: pchar;
begin
  p := pchar(@Buffer);
  with DiskFormatUtil, DiskFormat do
    begin
      SPB                 := BLOCKSIZE div BPS;
      result              := 0;  // Nr blocks read
      for rn := 0 to RecCnt - 1 do
        begin
          ConvertBlock2TS(fCurrentBlockNumber, LogTrackNo, LogTrackSector[0], LogTrackSector[1]);
          for sn := 0 to SPB-1 do
            begin
              rec := (LogTrackNo * 16) + LogTrackSector[sn];
              Seek(VolumeFile, rec);
              System.BlockWrite(VolumeFile, p^, 1, NrSectorsWritten);
              Inc(p, BPS);
            end;
          Inc(fCurrentBlockNumber);
          inc(result);  // Nr blocks read
        end;
    end;
end;

constructor TMiscVolume.Create(aOwner: TObject; aDOSFileName: string;
  aVersionNr: TVersionNr; aVolStartBlockInParent: integer;
  Alg: TAlgorithms);
begin
  inherited Create( aOwner, aDOSFileName, aVersionNr, aVolStartBlockInParent);
  fAlg := Alg;
end;

end.
