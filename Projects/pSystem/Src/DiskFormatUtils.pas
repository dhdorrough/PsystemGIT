unit DiskFormatUtils;

interface

const

  BLOCKSIZE          = 512;

type
  TWitch = (wInput, wOutput);

  TAlgorithms = ({alUnknown,}
                 alStandard,
                 alApple2);

  TDiskFormat = record
    Desc: string;
    Ext: string[4];    { Should not include dot }
    TPD: integer;      { Tracks Per Disk }
    BPS: integer;      { Bytes Per Sector }
    SPT: byte;         { Sectors / Track }
    Int: byte;         { Interleave }
    Trk: byte;         { 1st Track }
    Skew: byte;
    Alg: TAlgorithms;
  end;

  TDiskFormatPtr = ^TDiskFormat;

  TSector128 = Packed array[0..127] of byte;

  TSector256 = Packed array[0..255] of byte;

  TBlock = record
             case integer of
               0: (B: array[0..BLOCKSIZE-1] of byte);
               1: (A: array[0..BLOCKSIZE-1] of char);
               2: (S128: array[0..3] of TSector128);
               3: (S256: array[0..1] of TSector256);
             end;

  TBlockPtr = ^TBlock;

  TSector = record
                case integer of
                  0: (b: packed array[0..BLOCKSIZE-1] of byte); // Allow for largest possible sector
                  1: (c: packed array[0..BLOCKSIZE-1] of char);
                end;
(*
  TSector = pchar;
*)
//TSectorFile  = file of TSector;

  TInFileBlock = file of TBlock;

  TOnFetchParams = procedure {Name} (DiskFormatPtr: TDiskFormatPtr) of object;

  TDiskFormats = (
                  dfUnknown,
                  dfStandardVOL,
                  dfStandardSVOL,
                  dfHeathkitH8D,
                  dfStandardSD,
                  dfTRS80II,
                  dfTRS80Quad,
                  dfTerak,
                  dfAdap1st,
                  dfAdap2nd,
                  dfIBMDisplayWriter,
                  dfTRS80Old16,
                  dfNECAPC,
                  dfSage,
                  dfRaw,
                  dfNorthStar,
                  dfMisc,
                  dfPeterW
                  );

  TDiskFormatUtil = class(TObject)
  public
    DiskFormat : TDiskformat;

    P2LTable   : array of {Track} array of {sector} integer;

    procedure InitP2LTable;
    function  LogicalSectorToPhysicalSector(LogSecNum: integer): integer; virtual;
    function  PhysicalSectorToLogicalSector(PhysSector: integer): integer; virtual;
    function  SectorTranslate(BaseTrackNo, LogSectorNo: integer): integer;
  end;

  function DiskFormatString(const DiskFormat: TDiskFormat): string;

var
  DiskFormatInfo: array[TDiskFormats] of TDiskFormat = (  // WARNING: MOST OF THESE HAVE NOT BEEN TESTED
    ({dfUnknown}),
    ({dfStandardVOL} Desc: 'Standard VOL file'; Ext: 'VOL'),
    ({dfStandardSVOL}Desc: 'Standard SVOL file'; Ext: 'SVOL'),
    ({dfHeathkitH8D} Desc: 'Heathkit H8D'; Ext:'H8D'; TPD:40;  BPS:256; SPT:10; Int:2; Trk:1; Skew:6),
    ({dfStandardSD}  Desc: 'Standard Single	density'; TPD:80;  BPS:BLOCKSIZE; SPT:10; Int:1; Trk:0; Skew:0),
    ({dfTRS80II}     Desc: 'TRS-80 II Double density';TPD:80;  BPS:BLOCKSIZE; SPT:10; Int:1; Trk:0; Skew:0),
    ({dfTRS80Quad}   Desc: 'TRS-80 16 Quad density';  TPD:80;  BPS:BLOCKSIZE; SPT:10; Int:1; Trk:0; Skew:0),
    ({dfTerak}       Desc: 'Terak DSDD';              TPD:154; BPS:BLOCKSIZE; SPT:15; Int:2; Trk:1; Skew:2),
    ({dfAdap1st}     Desc: 'Adaptable 1st vol';       TPD:80),
    ({dfAdap2nd}     Desc: 'Adaptable 2nd vol';       TPD:80;  BPS:BLOCKSIZE; SPT:10; Int:1; Trk:0; Skew:0),
    ({dfIBMDWriter}  Desc: 'IBM DWriter DSDD (2D)';   TPD:154; BPS:256; SPT:26; Int:1; Trk:2; Skew:0),
    ({dfTRS80Old16}  Desc: 'TRS-80 16 Old format';    TPD:154; BPS:256; SPT:26; Int:5; Trk:3; Skew:5),
    ({dfNECAPC}      Desc: 'NEC APC	(TIcom Systems)'; TPD:154; BPS:BLOCKSIZE; SPT:15; Int:1; Trk:2; Skew:0),
    ({dfSage}        Desc: 'Sage II';                 TPD:80;  BPS:BLOCKSIZE; SPT:10; Int:1; Trk:0; Skew:0),
    ({dfRaw}         Desc: 'Z80 Emulator'; Ext:'RAW'; TPD:333; BPS:128; SPT:26; Int:2; Trk:1; Skew:6),
    ({dfNorthStar}   Desc: 'NorthStar';    Ext:'NSI';          BPS:256; SPT:10; Int:1; Trk:2; Skew:0),
    ({dfApple}       Desc: 'Apple II';     Ext:'DSK'; TPD:50;  BPS:256; SPT:16; Int:14; Trk:0; Skew:0; Alg: alApple2),
    ({dfPeterW}      Desc: 'PeterW';       Ext:'PW';  TPD:154; BPS:BLOCKSIZE; SPT:16; Int:1;  Trk:2; Skew:0)
 );

  TAlgorithmInfo: array[TAlgorithms] of string =
    {alUnknown} ({'Unknown',}
    {alStandard} 'Standard',
    {alApple2}   'Apple2');

function DiskFormatFromDescription(const Desc: string): TDiskFormats;
function DiskFormatFromExt(Ext: string): TDiskFormats;
function StandardVolumeFormat(const Ext: string): boolean;
function LegalPSysVolumeExt(Ext: string): boolean;

implementation

uses
  MyUtils, SysUtils;

function DiskFormatFromDescription(const Desc: string): TDiskFormats;
begin
  for result := Succ(Low(TDiskFormats)) to High(TDiskFormats) do
    if SameText(Desc, DiskFormatInfo[result].Desc) then
      Exit;
  result := dfStandardVOL;
end;

function StandardVolumeFormat(const Ext: string): boolean;
var
  b: boolean;
begin
  b := DiskFormatFromExt(Ext) in [dfStandardVOL, dfStandardSVOL];
  result := b;
end;

function LegalPSysVolumeExt(Ext: string): boolean;
var
  df: TDiskFormats;
  KnownExtensions: set of TDiskFormats;
begin
  KnownExtensions := [];
  for df := Succ(Low(TDiskFormats)) to High(TDiskFormats) do
    if DiskFormatInfo[df].Ext <> '' then
      KnownExtensions := KnownExtensions + [df];
  result := DiskFormatFromExt(Ext) in KnownExtensions;;
end;

function DiskFormatFromExt(Ext: string): TDiskFormats;
var
  I: TDiskFormats;
begin
  result := dfUnknown;
  if Ext <> '' then
    begin
      Ext := FixExt(Ext);
      for I := Succ(Low(TDiskFormats)) to High(TDiskFormats) do
        if SameText(Ext, DiskFormatInfo[I].Ext) then
          begin
            result := I;
            Exit;
          end;
    end;
end;


procedure TDiskFormatUtil.InitP2LTable;
var
  Track, LogSecNum, PhysSecNum, Sector: integer;
begin
  with DiskFormat do
    begin
      SetLength(P2LTable, TPD);
      for Track := 0 to TPD-1 DO
        SetLength(P2LTable[Track], SPT);

      for LogSecNum := 0 to (TPD * SPT) - 1 do
        begin
          PhysSecNum := LogicalSectorToPhysicalSector(LogSecNum);
          Track      := PhysSecNum div SPT;
          Sector     := PhysSecNum mod SPT;
          P2LTable[Track, Sector] := LogSecNum;
        end;
    end;
end;


function TDiskFormatUtil.LogicalSectorToPhysicalSector(
  LogSecNum: integer): longint;
var
  TrackBase  : integer;
  TS1        : integer;
  TS2        : integer;
  TrackNo    : integer;
  TrackSector: integer;
  TrackSkew  : integer;
begin
  TrackNo     := LogSecNum div DiskFormat.SPT;
  TrackBase   := TrackNo * DiskFormat.SPT;            { 10, 20, 30,... }
  TrackSector := LogSecNum mod DiskFormat.SPT;        { 0..9 }
  TS1         := DiskFormat.SPT div DiskFormat.Int;
  TS2         := IIF(TrackSector < TS1,
                    (TrackSector * DiskFormat.Int),
                    ((TrackSector-TS1) * DiskFormat.Int)+1);
  TrackSkew   := (TrackNo * DiskFormat.Skew) mod DiskFormat.SPT;
  result      := TrackBase + (TS2 + TrackSkew) mod DiskFormat.SPT;
end;

function TDiskFormatUtil.PhysicalSectorToLogicalSector(
  PhysSector: integer): integer;
var
  Track, Sector: integer;
begin
  Track  := PhysSector div DiskFormat.SPT;
  Sector := PhysSector mod DiskFormat.SPT;
  result := P2LTable[Track, Sector];
end;

function TDiskFormatUtil.SectorTranslate(BaseTrackNo,
  LogSectorNo: longint): longint;
begin
  with DiskFormat do
    result := (Trk * SPT) +
               LogicalSectorToPhysicalSector(LogSectorNo);
end;

  function DiskFormatString(const DiskFormat: TDiskFormat): string;
  var
    AlgStr: string;
  begin
(*
    Desc: string;
    Ext: string[4];    { Should not include dot }
    TPD: integer;      { Tracks Per Disk }
    BPS: integer;      { Bytes Per Sector }
    SPT: byte;         { Sectors / Track }
    Int: byte;         { Interleave }
    Trk: byte;         { 1st Track }
    Skew: byte;
    Alg: TAlgorithms;
*)
    with DiskFormat do
      begin
        if Alg <> alStandard then
          AlgStr := ', Algorithm: ' + TAlgorithmInfo[Alg]
        else
          AlgStr := '';

        result := Format('Desc: %8s, Ext; %5s, BPS: %3d, SPT: %2d, INT: %2d, TRK0: %d, Skew: %2d %s',
                        [Desc, Ext, BPS, SPT, INT, Trk, Skew, AlgStr]);
      end;
  end;


end.
