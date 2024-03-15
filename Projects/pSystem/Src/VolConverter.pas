unit VolConverter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VolumeParams, StdCtrls, ExtCtrls, ovcbase, ovcef, ovcpb, ovcnf,
  pSys_Decl, DiskFormatUtils;

type
  TConversionDirection = (cdUnknown, cdOtherToVol, cdVolToOther);

  TfrmVolConverter = class(TfrmVolumeParams)
    leInputFileName: TLabeledEdit;
    btnBrowseInputFile: TButton;
    leOutputFileName: TLabeledEdit;
    btnBrowseOutputFolder: TButton;
    Memo1: TMemo;
    rbOtherToVol: TRadioButton;
    rbVolToOther: TRadioButton;
    lblNrTracks: TLabel;
    lblNrBlocks: TLabel;
    cbListTracksSectors: TCheckBox;
    cbDebugging: TCheckBox;
    procedure leInputFileNameExit(Sender: TObject);
    procedure btnBrowseInputFileClick(Sender: TObject);
    procedure btnBrowseOutputFolderClick(Sender: TObject);
    procedure RecalcStuff(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure ovcBytesPerSectorChange(Sender: TObject);
    procedure rbOtherToVolClick(Sender: TObject);
    procedure rbVolToOtherClick(Sender: TObject);
  private
    fDiskFormatUtil: TDiskFormatUtil;
    fLogFile    : text;
    CurrentSector: TSector;
    fInFileName : string;
    fOnUpdateLog: TStatusProc;
    InFile      : File;
    Outfile     : File;
    InFileOpened: boolean;
    OutFileOpened: boolean;

    procedure ConvertOtherToVOL;
    procedure ConvertVOLToOther;
    function GetFileNameExtension(Which: TWitch): string;
    function GetInputFileName: string;
    function GetOutputFileName: string;
    procedure LogHeaderInfo;
    function OpenInFile(const FileName: string): boolean;
    procedure OpenOutFile(const FileName: string);
    function  ReadSector(rec: integer; var mySector: TSector): boolean; overload;
    function  ReadSector(var mySector: TSector): boolean; overload;
    procedure WriteSector(const mySector: TSector); Overload;
    function  WriteSector(rec: integer; const mySector: TSector): boolean; Overload;
    procedure SetInputFileName(const Value: string);
    procedure SetOutputFileName(const Value: string);
    procedure UpdateLog(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true);
    procedure RecalcTrackCount;
    procedure CloseInfile;
    procedure PopulateDiskFormatInfo;
    function GetConversionDirection: TConversionDirection;
    procedure SetConversionDirection(const Value: TConversionDirection);
    function GetDiskFormatUtil: TDiskFormatUtil;
  protected
    { Private declarations }
    procedure Enable_Buttons; override;
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
    Destructor Destroy; override;
    property DiskFormatUtil: TDiskFormatUtil
             read GetDiskFormatUtil;

    property InputFileName: string
             read GetInputFileName
             write SetInputFileName;

    property OutputFileName: string
             read GetOutputFileName
             write SetOutputFileName;

    property ConversionDirection: TConversionDirection
             read GetConversionDirection
             write SetConversionDirection; 

  end;

var
  frmVolConverter: TfrmVolConverter;

implementation

{$R *.dfm}

uses
  MyUtils, PsysUnit, pSys_Const, pSysVolumes, pSysVolumesNonStandard,
  FileNames;

procedure TfrmVolConverter.btnBrowseInputFileClick(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leInputFileName.Text;
  if BrowseForFile('Input volume', FilePath, GetFileNameExtension(wInput)) then
    leInputFileName.Text := FilePath;
end;

procedure TfrmVolConverter.btnBrowseOutputFolderClick(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leOutputFileName.Text;
  if BrowseForFile('Output volume', FilePath, GetFileNameExtension(wOutput)) then
    leOutputFileName.Text := FilePath;
end;


procedure TfrmVolConverter.CloseInfile;
begin
  if InFileOpened then
    begin
      CloseFile(InFile);
      InFileOpened := false;
    end;
end;

procedure TfrmVolConverter.ConvertVOLToOther;
var
    InVolume: TVolume;
    OutVolume: TVolume;
    Buffer: packed array[0..BLOCKSIZE-1] of char;
    NrBlocks, i: integer;
    OutputFile: File;
begin { TfrmVolumeConverter.ConvertVOLToOther }
    // Pre-extend the output file to the proper size
    AssignFile(OutputFile, OutputFileName);
    NrBlocks := FileSize32(InputFileName) div BLOCKSIZE;
    Rewrite(OutputFile, BLOCKSIZE);
    FillChar(Buffer, SizeOf(Buffer), 0); // start with a nice clean slate (probably not necessary)
    for i := 1 to NrBlocks do
      System.BlockWrite(OutputFile, Buffer, 1);
    CloseFile(OutputFile);

    InVolume  := CreateVolume(self, InputFileName);
    AssignFile(InVolume.VolumeFile, InputFileName);
    InVolume.ResetVolumeFile;

    OutVolume := CreateVolume(self, OutputFileName);
    AssignFile(OutVolume.VolumeFile, OutputFileName);

    PopulateDiskFormatInfo;

    with OutVolume as TNonStandardVolume do
      begin
        DiskFormatUtil.DiskFormat := self.DiskFormatUtil.DiskFormat;
        OutVolume.ResetVolumeFile;
      end;

    while not Eof(InVolume.VolumeFile) do
      begin
        InVolume.BlockRead(Buffer, 1);
        if not cbDebugging.Checked then
          OutVolume.BlockWrite(Buffer, 1);
      end;

    FreeAndNil(OutVolume);
    FreeAndNil(InVolume);
end;  { TfrmVolumeConverter.ConvertVOLToOther }

procedure TfrmVolConverter.ConvertOtherToVOL;
var LogTrackNo, PhysTrackNo, LogTrackSector, LogSectorNo,
    PhysSectorNo, SPB: integer;
begin
  UpdateLog('ConvertOtherToVOL has not been tested');
  fDiskFormatUtil.InitP2LTable;
  CloseInfile;

  OpenInfile(InputFileName);
  if FileExists(OutputFileName) then
    if not YesFmt('File "%s" already exists. Do you want to overwrite it?', [OutputFileName]) then
      Exit;
  OpenOutFile(OutputFileName);
  LogHeaderInfo;
  NrSectorsWritten := 0;
  SPB := BLOCKSIZE div BytesPerSector;
  try
    for LogTrackNo := 0 to TracksPerDisk-1 do  // might be better with LogSectorNo := 0 to BlocksPerDisk-1 do
      begin
        for LogTrackSector := 0 to SectorsPerTrack-1 do
          begin
            PhysTrackNo  := LogTrackNo + BaseTrackNumber;
            LogSectorNo  := (LogTrackNo * SectorsPerTrack) + LogTrackSector;
            PhysSectorNo := fDiskFormatUtil.SectorTranslate(BaseTrackNumber, LogSectorNo);
            if cbListTracksSectors.Checked then
              UpdateLog(Format('BlockNr=%4d, LogSectorNo=%4d; LogTrackNo=%2d; PhysTrackNo=%2d, LogTrackSector=%2d; PhysSectorNo=%2d',
                             [LogSectorNo div SPB, LogSectorNo, LogTrackNo, PhysTrackNo, LogTrackSector, PhysSectorNo]), true, true);
            ReadSector(PhysSectorNo, CurrentSector);
            if not cbDebugging.Checked then
              WriteSector(CurrentSector);
            NrSectorsWritten := NrSectorsWritten + 1;
          end;
      end;
  finally
    CloseFile(OutFile);
    CloseInfile;
  end;
end;

function TfrmVolConverter.GetFileNameExtension(Which: TWitch): string;
begin
  if rbVolToOther.Checked then
    case Which of
      wInput: result := cVOL;
      wOutput: result := leFileNameExtension.Text;
    end else
  if rbOtherToVol.Checked then
    case which of
      wInput: result := leFileNameExtension.Text;
      wOutput: result := cVOL;
    end;
end;

function TfrmVolConverter.GetInputFileName: string;
begin
  result := leInputFileName.Text;
end;

function TfrmVolConverter.GetOutputFileName: string;
begin
  result := leOutputFileName.Text;
end;


procedure TfrmVolConverter.leInputFileNameExit(Sender: TObject);
begin
  leOutputFileName.Text := ForceExtension(leInputFileName.Text, VOL_EXT);
end;

(*
function TfrmVolConverter.LoadBlock(BlockNr: integer;
  var aBlock: TBlock): boolean;
var
  I, L: integer;
  P: integer;
  NrRead: longint;
  aSector: TBlock;
  Blk: TBlock;
  SectorsPerBlock: integer;
begin
  result := true;
  SectorsPerBlock := BLOCKSIZE DIV BytesPerSector;
  for i := 0 to SectorsPerBlock-1 do
    begin
      L := (BlockNr * SectorsPerBlock) + i;
      P := fDiskFormatUtil.LogicalSectorToPhysicalSector(L);
      Seek(InFile, P);
      BlockRead(InFile, aSector, 1, NrRead);
      result := result and (NrRead = 1);
      Move(aSector.b[0], Blk.b[BytesPerSector*i], BytesPerSector);
    end;
  aBlock := Blk;
end;
*)

procedure TfrmVolConverter.LogHeaderInfo;
var
  Ext: string;
begin
  if cbListTracksSectors.Checked then
    begin
      UpdateLog(Format('Volume Conversion on %s', [DateTimeToStr(Now)]));
      Ext := leFileNameExtension.Text;
      if rbVOLToOther.Checked then
        UpdateLog(Format('.VOL --> %s', [Ext])) else
      if rbOtherToVol.Checked then
        UpdateLog(Format('%s --> .VOL', [Ext]));

      UpdateLog(Format('Input File Name:     %s', [InputFileName]));
      UpdateLog(Format('Output File Name:    %s', [OutputFileName]));
      UpdateLog(Format('Bytes/Sector:        %d', [BytesPerSector]));
      UpdateLog(Format('Sectors/Track:       %d', [SectorsPerTrack]));
      UpdateLog(Format('Base Track Number:   %d', [BaseTrackNumber]));
      UpdateLog(Format('Tracks/Disk:         %d', [TracksPerDisk]));
      UpdateLog(Format('Track To Track Skew: %d', [TrackToTrackSkew]));
      UpdateLog(Format('Sector Interleave:   %d', [SectorInterleave]));
    end;
end;

function TfrmVolConverter.OpenInFile(const FileName: string): boolean;
begin
  result := true;
  try
    if not InFileOpened then
      begin
        fInFileName := FileName;
        AssignFile(infile, FileName);
        if rbOtherToVol.Checked then
          reset(infile, BytesPerSector) else
        if rbVOLToOther.Checked then
          reset(infile, BytesPerSector);
        InFileOpened := true;
        result       := true;
      end;
  except
    result := false;
  end;
end;

procedure TfrmVolConverter.OpenOutFile(const FileName: string);
begin
  AssignFile(outfile, FileName);
  ReWrite(outfile, BytesPerSector);
  OutFileOpened := true;
end;

procedure TfrmVolConverter.RecalcTrackCount;
var
  NrSectors, NrTracks: longint;
begin
  NrSectors := FileSize32(InputFileName) div BytesPerSector;
  if SectorsPerTrack > 0 then
    NrTracks := (NrSectors div SectorsPerTrack) + BaseTrackNumber
  else
    NrTracks := 0;
  lblNrTracks.Caption := Format('Calc''d Nr of tracks = %d', [NrTracks]);
  lblNrBlocks.Caption := Format('Number of blocks = %d', [FileSize32(InputFileName) div BLOCKSIZE]);
end;

procedure TfrmVolConverter.SetInputFileName(const Value: string);
begin
  leInputFileName.Text := Value;
  Enable_Buttons;
end;

procedure TfrmVolConverter.SetOutputFileName(const Value: string);
begin
  leOutputFileName.Text := Value;
end;

procedure TfrmVolConverter.UpdateLog(const Msg: string; DoLog: boolean = true; DoStatus: boolean = true);
begin
  if Assigned(fOnUpdateLog) then
    fOnUpdateLog(Msg, DoLog, DoStatus)
  else
    begin
//    Memo1.Lines.Add(Msg);
      if DoLog then
        WriteLn(fLogFile, Msg);
      if DoStatus then
        begin
          lblStatus.Caption := Msg;
          Application.ProcessMessages;
        end;
    end;
end;

procedure TfrmVolConverter.RecalcStuff(Sender: TObject);
begin
  inherited;
  RecalcTrackCount;
end;

constructor TfrmVolConverter.Create(aOwner: TComponent);
begin
  inherited;
end;

destructor TfrmVolConverter.Destroy;
begin
  FreeAndNil(fDiskFormatUtil);
  inherited;
end;

procedure TfrmVolConverter.Enable_Buttons;
begin
  inherited;
  btnOK.Enabled := btnOK.Enabled and FileExists(leInputFileName.Text);  // notice the "inherited" call which sets btnOk.Enabled
end;

procedure TfrmVolConverter.btnOKClick(Sender: TObject);
const
  LOGFILENAME = 'c:\temp\LogFile.txt';
begin
  AssignFile(fLogFile, LOGFILENAME);
  ReWrite(fLogFile);
  try
    PopulateDiskFormatInfo;
    if rbOtherToVol.Checked then
      ConvertOtherToVOL else
    if rbVolToOther.Checked then
      ConvertVOLToOther;
  finally
    CloseFile(fLogFile);
    if cbListTracksSectors.Checked then
      EditTextFile(LOGFILENAME);
  end;
end;

procedure TfrmVolConverter.PopulateDiskFormatInfo;
begin
  with DiskFormatUtil.DiskFormat do
    begin
      Desc  := Description;
      BPS   := BytesPerSector;
      SPT   := SectorsPerTrack;
      TPD   := TracksPerDisk;
      Int   := SectorInterleave;
      Trk   := BaseTrackNumber;
      Skew  := TrackToTrackSkew;
      Ext   := leFileNameExtension.Text;
    end;
end;


procedure TfrmVolConverter.ovcBytesPerSectorChange(Sender: TObject);
begin
  inherited;
  Enable_Buttons;
end;

function TfrmVolConverter.ReadSector(rec: integer;
  var mySector: TSector): boolean;
begin
  result := not Eof(InFile);
  if result then
    begin
      Seek(InFile, rec);
      if not Eof(InFile) then
        BlockRead(Infile, mySector.b[0], 1)
      else
        result := false;
    end;
end;

function TfrmVolConverter.ReadSector(var mySector: TSector): boolean;
var
  NrRead: longint;
begin
{$I-}
  Blockread(InFile, MySector, 1, NrRead);
  result := (NrRead = 1) and (IOResult = 0)
{$I+}
end;

procedure TfrmVolConverter.WriteSector(const mySector: TSector);
begin
  BlockWrite(Outfile, mySector, 1);
end;

function TfrmVolConverter.WriteSector(rec: integer;
  const mySector: TSector): boolean;
begin
{$I-}
  Seek(OutFile, rec);
  BlockWrite(OutFile, mySector.b[0], 1);
{$I+}
  result := IOResult = 0;
end;

procedure TfrmVolConverter.rbOtherToVolClick(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmVolConverter.rbVolToOtherClick(Sender: TObject);
begin
  Enable_Buttons;
end;

function TfrmVolConverter.GetConversionDirection: TConversionDirection;
begin
  if rbOtherToVol.Checked then
    result := cdOtherToVol else
  if rbVolToOther.Checked then
    result := cdVolToOther
  else
    result := cdUnknown;
end;

procedure TfrmVolConverter.SetConversionDirection(
  const Value: TConversionDirection);
begin
  case Value of
    cdOtherToVol: rbOtherToVol.Checked := true;
    cdVolToOther: rbVolToOther.Checked := true;
  end;
  Enable_Buttons;
end;

function TfrmVolConverter.GetDiskFormatUtil: TDiskFormatUtil;
begin
  if not Assigned(fDiskFormatUtil) then
    fDiskFormatUtil := TDiskFormatUtil.Create;
  result := fDiskFormatUtil;
end;

end.
