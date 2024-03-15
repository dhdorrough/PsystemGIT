unit VolumeParams;
// This was previously named VolConverter

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pSys_Decl, MyUtils, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf,
  ExtCtrls, DiskFormatUtils;

type
  integer = SmallInt;

  TfrmVolumeParams = class(TForm)
    ovcBaseTrackNumber: TOvcNumericField;
    Label1: TLabel;
    Label2: TLabel;
    ovcNumberOfTracks: TOvcNumericField;
    ovcBytesPerSector: TOvcNumericField;
    lblBytesPerSector: TLabel;
    Label3: TLabel;
    ovcSectorsPerTrack: TOvcNumericField;
    btnCancel: TButton;
    btnOK: TButton;
    cbDiskFormat: TComboBox;
    Label6: TLabel;
    leFileNameExtension: TLabeledEdit;
    lblStatus: TLabel;
    Label7: TLabel;
    lbAlgorithm: TComboBox;
    pnlAlgorithm: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    ovcSectorInterleave: TOvcNumericField;
    ovcTrackToTrackSkew: TOvcNumericField;
    procedure cbDiskFormatClick(Sender: TObject);
    procedure ovcBytesPerSectorChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    fDiskFormatUtil: TDiskFormatUtil;
    fNrSectorsWritten: integer;
    fOnUpdateLog: TStatusProc;

    function GetBaseTrackNumber: integer;
    procedure SetBaseTrackNumber(const Value: integer);
    function GetTracksPerDisk: integer;
    procedure SetTracksPerDisk(const Value: integer);
    function GetSectorsPerTrack: integer;
    procedure SetSectorsPerTrack(const Value: integer);
    function GetBytesPerSector: integer;
    procedure SetBytesPerSector(const Value: integer);
    function GetSectorInterleave: integer;
    procedure SetSectorInterleave(const Value: integer);
    function GetTrackToTrackSkew: integer;
    procedure SetTrackToTrackSkew(const Value: integer);
    function GetDiskFormat: TDiskFormats;
    procedure SetDiskFormat(const Value: TDiskFormats);
    procedure DiskFormatChange(aDiskFormat: TDiskFormats);
    function GetBlocksPerDisk: integer;
    function GetDescription: string;
    function GetFileNameExtension: string;
    function FormatFromExtension(const Ext: string): TDiskFormats;
    function GetAlgorithm: TAlgorithms;
    procedure SetAlgorithm(const Value: TAlgorithms);
  protected
    procedure Enable_Buttons; virtual;
    procedure SetFileNameExtension(const Value: string);
  public
    { Public declarations }
    TrackNo: integer;
    TrackSector{, TS2}: integer;
    TrackSkew: integer;
    property BaseTrackNumber: integer
             read GetBaseTrackNumber
             write SetBaseTrackNumber;

    property NrSectorsWritten: integer
             read fNrSectorsWritten
             write fNrSectorsWritten;

    property OnUpdateLog: TStatusProc
             read fOnUpdateLog
             write fOnUpdatelog;

    property TracksPerDisk: integer
             read GetTracksPerDisk
             write SetTracksPerDisk;

    property SectorsPerTrack: integer
             read GetSectorsPerTrack
             write SetSectorsPerTrack;

    property BytesPerSector: integer
             read GetBytesPerSector
             write SetBytesPerSector;

    property SectorInterleave: integer
             read GetSectorInterleave
             write SetSectorInterleave;

    property TrackToTrackSkew: integer
             read GetTrackToTrackSkew
             write SetTrackToTrackSkew;

    property DiskFormat: TDiskFormats
             read GetDiskFormat
             write SetDiskFormat;

    property Description: string
             read GetDescription;

    property FileNameExtension: string
             read GetFileNameExtension
             write SetFileNameExtension;

    property BlocksPerDisk: integer
             read GetBlocksPerDisk;

    property Algorithm: TAlgorithms
             read GetAlgorithm
             write SetAlgorithm;

    Constructor Create(aOwner: TComponent); override;
    Destructor Destroy; override;
  end;

implementation

uses Misc, PsysUnit;

{$R *.dfm}

{ TfrmVolumeConverter }

constructor TfrmVolumeParams.Create(aOwner: TComponent);
var
  df: TDiskFormats;
  al: TAlgorithms;
begin
  inherited;
  with cbDiskFormat do
    begin
      for df := Succ(Low(TDiskFormats)) to High(TDiskFormats) do
        Items.AddObject(DiskFormatInfo[df].desc, TObject(df));
      Sorted := true;
    end;
  with lbAlgorithm do
    begin
      Items.Clear;
      for al := Low(TAlgorithms) to High(TAlgorithms) do
        Items.AddObject(TAlgorithmInfo[al], TObject(al));
      ItemIndex := Items.IndexOfObject(TObject(alStandard));
    end;
  lblStatus.Caption := '';
  fDiskFormatUtil := TDiskFormatUtil.Create;
end;

destructor TfrmVolumeParams.Destroy;
begin
  FreeAndNil(fDiskFormatUtil);
  inherited;
end;

function TfrmVolumeParams.GetBaseTrackNumber: integer;
begin
  result := ovcBaseTrackNumber.AsInteger;
end;

function TfrmVolumeParams.GetBytesPerSector: integer;
begin
  result := ovcBytesPerSector.AsInteger;
end;

function TfrmVolumeParams.GetSectorInterleave: integer;
begin
  result := ovcSectorInterleave.AsInteger;
end;

function TfrmVolumeParams.GetSectorsPerTrack: integer;
begin
  result := ovcSectorsPerTrack.AsInteger;
end;

function TfrmVolumeParams.GetTracksPerDisk: integer;
begin
  result    := ovcNumberOfTracks.AsInteger;
end;

function TfrmVolumeParams.GetTrackToTrackSkew: integer;
begin
  result := ovcTrackToTrackSkew.AsInteger;
end;

procedure TfrmVolumeParams.SetBaseTrackNumber(const Value: integer);
begin
  ovcBaseTrackNumber.AsInteger := Value;
end;

procedure TfrmVolumeParams.SetBytesPerSector(const Value: integer);
begin
  ovcBytesPerSector.AsInteger := Value;
end;

procedure TfrmVolumeParams.SetSectorInterleave(const Value: integer);
begin
  ovcSectorInterleave.AsInteger := value;
end;

procedure TfrmVolumeParams.SetSectorsPerTrack(const Value: integer);
begin
  ovcSectorsPerTrack.AsInteger := Value;
end;

procedure TfrmVolumeParams.SetTracksPerDisk(const Value: integer);
begin
  ovcNumberOfTracks.AsInteger := Value;
end;

procedure TfrmVolumeParams.SetTrackToTrackSkew(const Value: integer);
begin
  ovcTrackToTrackSkew.AsInteger := Value;
end;

function TfrmVolumeParams.GetDiskFormat: TDiskFormats;
begin
  with cbDiskFormat do
    if ItemIndex >= 0 then
      result := TDiskFormats(Items.Objects[ItemIndex])
    else
      result := dfStandardVOL;
end;

procedure TfrmVolumeParams.SetDiskFormat(const Value: TDiskFormats);
var
  idx: integer;
begin
  with cbDiskFormat do
    begin
      Idx := Items.IndexOfObject(TObject(Value));
      if Idx >= 0 then
        begin
          ItemIndex := Idx;
          DiskFormatChange(DiskFormat);
        end
      else
        SysUtils.Beep;
    end;
end;

procedure TfrmVolumeParams.DiskFormatChange(aDiskFormat: TDiskFormats);
begin
  with DiskFormatInfo[aDiskFormat] do
    begin
      BytesPerSector    := BPS;
      SectorsPerTrack   := SPT;
      TracksPerDisk     := TPD;
      SectorInterleave  := Int;
      BaseTrackNumber   := Trk;
      TrackToTrackSkew  := Skew;
      leFileNameExtension.Text := Ext;
      Algorithm         := Alg;
    end;
  Enable_Buttons;
end;


procedure TfrmVolumeParams.cbDiskFormatClick(Sender: TObject);
begin
  DiskFormatChange(DiskFormat);
  Enable_Buttons;
end;

function TfrmVolumeParams.GetBlocksPerDisk: integer;
begin
  result := BytesPerSector * SectorsPerTrack * TracksPerDisk div BLOCKSIZE;
end;

procedure TfrmVolumeParams.Enable_Buttons;
begin
  btnOK.Enabled := (BytesPerSector >= 128) and
                   (SectorsPerTrack >= 1) and
                   (BaseTrackNumber >= 0) and
                   (TracksPerDisk >= 1);
  pnlAlgorithm.Visible := Algorithm <> alApple2;
end;


procedure TfrmVolumeParams.ovcBytesPerSectorChange(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmVolumeParams.btnOKClick(Sender: TObject);
begin
  fDiskFormatUtil.InitP2LTable;
end;

function TfrmVolumeParams.GetDescription: string;
begin
  result := cbDiskFormat.Text;
//with cbDiskFormat do
//  if ItemIndex >= 0 then
//    result := cbDiskFormat.Items[ItemIndex];
end;

function TfrmVolumeParams.GetFileNameExtension: string;
begin
  result := leFileNameExtension.Text;
end;

function TfrmVolumeParams.FormatFromExtension(const Ext: string): TDiskFormats;
var
  df: TDiskFormats;
begin
  result := dfUnknown;
  for df := Succ(Low(TDiskFormats)) to High(TDiskFormats) do
    if SameText(DiskFormatInfo[df].Ext, Ext) then
      begin
        result := df;
        Exit;
      end;
end;


procedure TfrmVolumeParams.SetFileNameExtension(const Value: string);
var
  Ext: string; df: TDiskFormats;
begin
  Ext := Value;
  if (Ext <> '') and (Ext[1] = '.') then
    Delete(Ext, 1, 1);
  df := FormatFromExtension(Ext);
  if StandardVolumeFormat(Ext) then
    begin
      with cbDiskFormat do
        begin
          ItemIndex := Items.IndexOfObject(TObject(df));
          if ItemIndex >= 0 then  // Should always be true because df is not dfUnknown
            begin
              DiskFormatChange(df);
              Enable_Buttons;
            end;
        end;
    end;
end;

function TfrmVolumeParams.GetAlgorithm: TAlgorithms;
var
  Idx: integer;
begin
  with lbAlgorithm do
    begin
      Idx := ItemIndex;
      if Idx >= 0 then
        result := TAlgorithms(Items.Objects[Idx])
      else
        result := alStandard;
    end;
end;

procedure TfrmVolumeParams.SetAlgorithm(const Value: TAlgorithms);
var
  Idx: integer;
begin
  with lbAlgorithm do
    begin
      idx := Items.IndexOfObject(TObject(Value));
      if Idx >= 0 then
        ItemIndex := Idx;
    end;
end;

end.
