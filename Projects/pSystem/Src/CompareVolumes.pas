unit CompareVolumes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls, pSysVolumes;

type
  TfrmCompareVolumes = class(TForm)
    btnBegin: TButton;
    PageControl1: TPageControl;
    tabFileDates: TTabSheet;
    StringGrid1: TStringGrid;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox2: TComboBox;
    cbOnlyMismatched: TCheckBox;
    Button1: TButton;
    procedure btnBeginClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    fVolumesList: TVolumesList;
    fNrRows: integer;
    procedure InitListBox(ComboBox: TComboBox);
    procedure CompareTheVolumes(const Lfn1, Lfn2: string);
    procedure AddLine(DirIdx: integer; const FileName1: string;
      Date1: TDateTime; const FileName2: string; Date2: TDateTime;
      const Comment: string);
    procedure InitGrid;
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; VolumesList: TVolumesList); reintroduce;
  end;

var
  frmCompareVolumes: TfrmCompareVolumes;

implementation

uses pSys_Const, MyUtils;

{$R *.dfm}

const
  COL_DIRIDX = 0;
  COL_FNAME1 = 1;
  COL_FDATE1 = 2;
  COL_FNAME2 = 3;
  COL_FDATE2 = 4;
  COL_COMMENT = 5;

  BAD_DATE    = 0;

{ TfrmCompareVolumes }

procedure TfrmCompareVolumes.InitGrid;
begin
  with StringGrid1 do
    begin
      RowCount := 2;
      fNrRows   := 0;
      Cells[COL_DIRIDX, 0] := '#';
      Cells[COL_FNAME1, 0] := 'File 1';
      Cells[COL_FDATE1, 0] := 'Date 1';
      Cells[COL_FNAME2, 0] := 'File 2';
      Cells[COL_FDATE2, 0] := 'Date 2';
      Cells[COL_COMMENT, 0] := 'Comment';

      Cells[COL_DIRIDX, 1] := '';
      Cells[COL_FNAME1, 1] := '';
      Cells[COL_FDATE1, 1] := '';
      Cells[COL_FNAME2, 1] := '';
      Cells[COL_FDATE2, 1] := '';
      Cells[COL_COMMENT, 1] := '';
    end;
end;


procedure TfrmCompareVolumes.InitListBox(ComboBox: TComboBox);
var
  u: integer;
  Lfn: string;
begin
  with ComboBox do
    begin
      Clear;
      for u := 0 to MAX_FILER_UNITNR-1 do
        if Assigned(fVolumesList[u].TheVolume) then
          begin
            Lfn := Format('#%d: %s', [u, fVolumesList[u].VolumeName]);
            items.AddObject(Lfn, TObject(u));
          end;
      if Items.Count > 0 then
        ItemIndex := 0;
    end;
end;


constructor TfrmCompareVolumes.Create(aOwner: TComponent;
  VolumesList: TVolumesList);
begin
  inherited Create(aOwner);
  fVolumesList := VolumesList;
  InitListBox(ComboBox1);
  InitListBox(ComboBox2);
  InitGrid;
end;

procedure TfrmCompareVolumes.AddLine( DirIdx: integer;
                   const FileName1: string; Date1: TDateTime;
                   const FileName2: string; Date2: TDateTime;
                   const Comment: string);
var
  RowN: integer;
begin
  with StringGrid1 do
    begin
      if fNrRows = 0 then
        RowN := 1
      else
        RowN := fNrRows + 1;

      Cells[COL_DIRIDX, RowN] := IntToStr(DirIdx);
      Cells[COL_FNAME1, RowN] := FileName1;
      Cells[COL_FDATE1, RowN] := DateToStr(Date1);
      if Date2 <> BAD_DATE then
        begin
          Cells[COL_FNAME2, RowN] := FileName2;
          Cells[COL_FDATE2, RowN] := DateToStr(Date2);
        end;
      Cells[COL_COMMENT, RowN] := Comment;

      fNrRows := fNrRows + 1;
      if fNrRows > 1 then
        RowCount := fNrRows - 1;
    end;
end;


procedure TfrmCompareVolumes.CompareTheVolumes(const Lfn1, Lfn2: string);
var
  Volume1, Volume2: TVolume;
  NumFiles1: integer;
  FileName1, FileName2: string;
  DirIdx1, DirIdx2: integer;
  Date1, Date2: TDateTime;
begin
  if not SameText(Lfn1, Lfn2) then
    begin
      Volume1 := CreateVolume(self, Lfn1);
      Volume1.LoadVolumeInfo(DIRECTORY_BLOCKNR);

      Volume2 := CreateVolume(self, Lfn2);
      Volume2.LoadVolumeInfo(DIRECTORY_BLOCKNR);
      try
        Numfiles1 := Volume1.NumFiles;
        for DirIdx1 := 1 to NumFiles1 do
          begin
            FileName1 := Volume1.Directory[DirIdx1].FileNAME;
            DirIdx2   := Volume2.DirIdxFromString(FileName1);
            Date1     := Trunc(Volume1.Directory[DirIdx1].DateAccessed);

            if DirIdx2 < 0 then  // Not found
              AddLine(DirIdx1, FileName1, Date1, '', BAD_DATE, 'Missing File')
            else
              begin
                FileName2 := Volume2.Directory[DirIdx2].FileNAME;
                Date2     := Trunc(Volume2.Directory[DirIdx2].DateAccessed);

                if Date1 = Date2 then // ignoring the "time" portion of the field
                  if not cbOnlyMismatched.Checked then
                    AddLine(DirIdx1, FileName1, Date1, FileName2, Date2, 'Matched')
                  else
                else
                  AddLine(DirIdx1, FileName1, Date1, FileName2, Date2, 'Date Changed');
              end;
          end;
      finally
        FreeAndNil(Volume2);
        FreeAndNil(Volume1);
      end;
    end
  else
    AlertFmt('Volume1 = Volume2 (%s)', [Lfn1]);
end;


procedure TfrmCompareVolumes.btnBeginClick(Sender: TObject);
var
  Lfn1, Lfn2: string;
begin
  InitGrid;

  with ComboBox1 do
    Lfn1 := fVolumesList[Integer(Items.Objects[ItemIndex])].TheVolume.DOSFileName;

  with ComboBox2 do
    Lfn2 := fVolumesList[Integer(Items.Objects[ItemIndex])].TheVolume.DOSFileName;

  CompareTheVolumes(Lfn1, Lfn2);
  AdjustColumnWidths(StringGrid1, 10);
end;

procedure TfrmCompareVolumes.Button1Click(Sender: TObject);
var
  Temp1, Temp2: string;
begin
  Temp1 := ComboBox1.Text;
  Temp2 := ComboBox2.Text;
  
  with ComboBox1 do
    ItemIndex := Items.IndexOf(Temp2);

  with ComboBox2 do
    ItemIndex := Items.IndexOf(Temp1);
end;

end.
