unit VolumesToMount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, Grids, StdCtrls, ExtCtrls, Misc, Interp_Const, pSysVolumes,
  FileNames;

type
  TfrmVolumesToMount = class(TForm)
    leCSVListOfVolumesToMount: TLabeledEdit;
    btnBrowseForCSVListOfVolumesToMount: TButton;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnCreateCSVFile: TButton;
    btnSetDefaultFileName: TButton;
    StringGrid1: TStringGrid;
    btnAdd: TButton;
    btnDelete: TButton;
    btnUp: TButton;
    btnDown: TButton;
    btnUseurrentlyMountedVolumes: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure btnBrowseForCSVListOfVolumesToMountClick(Sender: TObject);
    procedure leCSVListOfVolumesToMountExit(Sender: TObject);
    procedure btnCreateCSVFileClick(
      Sender: TObject);
    procedure btnSetDefaultFileNameClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnUseurrentlyMountedVolumesClick(Sender: TObject);
  private
    fBootVolume: string;
    fCurrentlyMountedVolumes: TVolumesList;
    fUsedUnits: set of 0..MAX_FILER_UNITNR;
    fVersionNr: TVersionNr;
    fVolumeName: string;
    fUnitNumber: integer;
    function GetCSVListOfVolumesToMount: string;
    procedure SetCSVListOfVolumesToMount(const Value: string);
    procedure LoadCSVGrid;
    procedure Browse4FileName(const aCaption: string; le: TLabeledEdit;
      Ext: string = TXT_EXT);
    procedure Enable_Buttons;
    procedure SaveListOfMountedVolumes(FileName: string);
    function CSVFilesToLoadFileName(VersionNr: TVersionNr): string;
    function GetBootVolume: string;
    procedure SetBootVolume(const Value: string);
    procedure AddRow(const UnitNr, VolumeName, DOSFilePath, ParentUnitNr,
      ParentBlock, nonStandard: string;
      IsHeader: boolean = false);
    procedure AddHeaderRow;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; CurrentlyMountedVolumes: TVolumesList); reintroduce;
    property BootVolume: string
             read GetBootVolume
             write SetBootVolume;
    property CSVListOfVolumesToMount: string
             read GetCSVListOfVolumesToMount
             write SetCSVListOfVolumesToMount;
    property UnitNumber: integer
             read fUnitNumber
             write fUnitNumber;
    property VersionNr: TVersionNr
             read fVersionNr
             write fVersionNr;
    property VolumeName: string
             read fVolumeName
             write fVolumeName;
  end;

(*
var
  frmVolumesToMount: TfrmVolumesToMount;
*)

implementation

uses MyDelimitedParser, MyUtils, FilerMain, pSys_Decl, MyMessages,
{$IfDef debugging}
  DebuggerSettingsUnit,
{$EndIf}
  pSysVolumesNonStandard, pSys_Const, Interp_Decl, DiskFormatUtils,
  CSVStuff;

{$R *.dfm}

const
  GRID_COLCOUNT = 6;

  COL_UNITNUMBER = 0;
  COL_VOLUMENAME = 1;
  COL_DOSFILEPATH = 2;
  COL_PARENTUNITNUMBER = 4;      // note that order is different from the CSV file
  COL_VOLSTARTBLOCKINPARENT = 5;
  COL_NONSTANDARDFORMAT = 3;
  
(* moved to CSVStuff
  FN_UNITNUMBER = 0;
  FN_VOLUMENAME = 1;
  FN_DOSFILEPATH = 2;
  FN_PARENTUNITNUMBER = 3;
  FN_VOLSTARTBLOCKINPARENT = 4;
  FN_NONSTANDARDVOLUME = 5;
*)  

  LEGAL_UNIT_NUMBERS = [4, 5, 9..MAX_FILER_UNITNR];
  ILLEGAL_UNIT_NUMBERS = [0, 1, 2, 3, 6, 7, 8];

type
  TStringGridHack = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
  end;  


constructor TfrmVolumesToMount.Create(aOwner: TComponent; CurrentlyMountedVolumes: TVolumesList);
begin
  inherited Create(aOwner);
  AddHeaderRow;
  AdjustColumnWidths(StringGrid1);
  Enable_Buttons;

  fCurrentlyMountedVolumes       := CurrentlyMountedVolumes;
  leCSVListOfVolumesToMount.Text := CSVListOfVolumesToMount;
end;

function TfrmVolumesToMount.GetCSVListOfVolumesToMount: string;
begin
  result := leCSVListOfVolumesToMount.Text;
end;

procedure TfrmVolumesToMount.SetCSVListOfVolumesToMount(
  const Value: string);
begin
  leCSVListOfVolumesToMount.Text := Value;
  LoadCSVGrid;
end;

procedure TfrmVolumesToMount.AddRow(const UnitNr, VolumeName, DOSFilePath, ParentUnitNr, ParentBlock, nonStandard: string;
                                    IsHeader: boolean = false);
var
  RowNr: integer;
begin
  with StringGrid1 do
    begin
      // Have to deal with TStringGrid demands of using FixedRows
      if IsHeader then
        RowNr := 0
      else
        if RowCount > 2 then
          RowNr    := RowCount - 1
        else { RowCount = 2, i.e., the 1st data row }
          RowNr    := 1;

      Cells[COL_UNITNUMBER, RowNr]            := UnitNr;
      Cells[COL_VOLUMENAME, RowNr]            := VolumeName;
      Cells[COL_DOSFILEPATH, RowNr]           := DOSFilePath;
      Cells[COL_PARENTUNITNUMBER, RowNr]      := ParentUnitNr;
      Cells[COL_VOLSTARTBLOCKINPARENT, RowNr] := ParentBlock;
      Cells[COL_NONSTANDARDFORMAT, RowNr]     := nonStandard;
      if not IsHeader then
        RowCount := RowCount + 1;
    end;
end;

procedure TfrmVolumesToMount.AddHeaderRow;
begin
  with StringGrid1 do
    begin
      ColCount := GRID_COLCOUNT;
      RowCount := 2;     // always a header row
    end;
  AddRow('Unit#', 'Volume', 'DOS Path Name', 'Parent Unit#', 'Parent Block', 'Non-Standard', true);
  fUsedUnits := ILLEGAL_UNIT_NUMBERS;
end;

procedure TfrmVolumesToMount.LoadCSVGrid;
var
  FileName: string;
  Line: string;
  CSVFile: TextFile;
  CSVInfo: TDelimited_Info;
  Fields: TFieldArray;
  Count: longint;
  UnitNr: integer;
  NonStandard: string;
  df: TDiskFormats;
  Ext: string;

  function FieldVal(fn: integer; BlankIfZero: boolean = false): string;
  begin
    if fn < Count then
      begin
        result := Fields[fn];
        if (Trim(result) = '0') and BlankIfZero then
          result := ''
      end
    else
      result := '';
  end;

  function NumberOfLinesInTheFile(const FileName: string): integer;
  begin
    Reset(CSVFile);
    // Count the number of lines in the file
    result := 0;
    while not Eof(CSVFile) do
      begin
        ReadLn(CSVFile, Line);
        Parse_Delimited_Line( Line, Fields, count, CSVInfo);
        if StrToIntSafe(Fields[FN_UNITNUMBER]) <> UnitNumber then // if this file is already used don't count it
          Inc(result);
      end;
  end;

begin { TfrmVolumesToMount.LoadCSVGrid }
  FileName := leCSVListOfVolumesToMount.Text;
  if FileExists(FileName) then
    begin
      AssignFile(CSVFile, FileName);

      CSVInfo.Field_Seperator := ',';
      CSVInfo.QuoteChar       := '"';

      with StringGrid1 do
        begin
          RowCount := 1;  // there is always a header row
          ColCount := GRID_COLCOUNT;
        end;

      AddHeaderRow;

      // BootVolume comes first
      if FileExists(BootVolume) then
        begin
          Ext         := ExtractFileExt(BootVolume);
          if StandardVolumeFormat(Ext) then
            NonStandard := ''
          else
            begin
              df          := DiskFormatFromExt(Ext);
              NonStandard := DiskFormatInfo[df].Desc;
            end;
          AddRow(IntToStr(UnitNumber), VolumeName, BootVolume, '', '', NonStandard); // BootVolume passed in from LoadVersion
          fUsedUnits := fUsedUnits + [UnitNumber];
        end;

      if FileExists(FileName) then
        begin
          try
            Reset(CSVFile); ReadLn(CSVFile, Line);  // ignore the header line

            while not Eof(CSVFile) do
              begin
                ReadLn(CSVFile, Line);

                Parse_Delimited_Line( Line, Fields, count, CSVInfo);

                if StrToIntSafe(Fields[FN_UNITNUMBER]) = UnitNumber then // this unitnumber is already used- skip it
                  begin
                    ReadLn(CsVFile, Line);
                    Parse_Delimited_Line( Line, Fields, count, CSVInfo);
                  end;

                AddRow( FieldVal(FN_UNITNUMBER),
                        FieldVal(FN_VOLUMENAME),
                        FieldVal(FN_DOSFILEPATH),
                        FieldVal(FN_PARENTUNITNUMBER, true),
                        FieldVal(FN_VOLSTARTBLOCKINPARENT, true),
                        FieldVal(FN_NONSTANDARDVOLUME, true));

                UnitNr := StrToIntSafe(Fields[FN_UNITNUMBER]);
                if UnitNr in LEGAL_UNIT_NUMBERS then
                  fUsedUnits := fUsedUnits + [UnitNr]
              end;
          finally
            CloseFile(CSVFile);
          end;
        end;
      SortGridNumeric(StringGrid1, COL_UNITNUMBER);
      AdjustColumnWidths(StringGrid1);
      Enable_Buttons;
    end;
end;  { TfrmVolumesToMount.LoadCSVGrid }

procedure TfrmVolumesToMount.btnOkClick(Sender: TObject);
begin
  SaveListOfMountedVolumes(leCSVListOfVolumesToMount.Text);
end;

procedure TfrmVolumesToMount.btnBrowseForCSVListOfVolumesToMountClick(
  Sender: TObject);
begin
  Browse4FileName('CSV List of Volumes to Mount', leCSVListOfVolumesToMount, CSV_EXT);
  LoadCSVGrid;
end;

procedure TfrmVolumesToMount.leCSVListOfVolumesToMountExit(
  Sender: TObject);
begin
  LoadCSVGrid;
end;

procedure TfrmVolumesToMount.Browse4FileName( const aCaption: string;
                                                le: TLabeledEdit;
                                                Ext : string = TXT_EXT);
var
  Lfn: string;
begin
  Lfn := le.Text;
  if BrowseForFile(aCaption, Lfn, Ext) then
    le.Text := Lfn;
end;

procedure TfrmVolumesToMount.btnCreateCSVFileClick(
  Sender: TObject);
var
  OK: boolean;
  Lfn: string;
begin
  OK  := true;
  Lfn := leCSVListOfVolumesToMount.Text;
  if FileExists(Lfn) then
    OK := YesFmt('File %s already exists. OverWrite it?', [Lfn]);

  if OK then
    SaveListOfMountedVolumes(Lfn);
end;

procedure TfrmVolumesToMount.SaveListOfMountedVolumes(FileName: string);
var
  CSVFile: TextFile;
  Line: string;
  UnitNr, R: integer;
  NrLines: integer;
begin { SaveListOfMountedVolumes }
  if FileName <> '' then
    begin
      AssignFile(CSVFile, FileName);
      NrLines := 0;
      try
        ReWrite(CSVFile);
        System.Writeln(CSVFile, 'UnitNumber,VolumeName,DOSPathName,ParentUnitNumber,VolStartBlockInParent,NonStandardFormat');
        try
          with StringGrid1 do
            for R := 1 to RowCount-1 do
              begin
                UnitNr := StrToIntSafe(Cells[COL_UNITNUMBER, R]);
                if UnitNr in LEGAL_UNIT_NUMBERS then
                  begin
                    Line := Format('%s,"%s","%s",%s,%s,"%s"',
                                   [Cells[COL_UNITNUMBER, R],
                                    Cells[COL_VOLUMENAME, R],
                                    Cells[COL_DOSFILEPATH, R],
                                    Cells[COL_PARENTUNITNUMBER, R],
                                    Cells[COL_VOLSTARTBLOCKINPARENT, R],
                                    Cells[COL_NONSTANDARDFORMAT, R]]);
                    System.Writeln( CSVFile, Line);
                    Inc(NrLines);
                  end;
              end;
        finally
          CloseFile(CSVFile);
          AlertFmt('%d lines written to file "%s"', [NrLines, FileName]);
        end;
      except
        SysUtils.Beep;
      end;
    end;
end;  { SaveListOfMountedVolumes }

function TfrmVolumesToMount.CSVFilesToLoadFileName(VersionNr: TVersionNr): string;
begin
  result := Format('%sCSVFilesToLoad-%s.%s',
                   [DataBaseSettingsFilesFolder, VersionNrStrings[VersionNr].Abbrev, CSV_EXT]);
end;

procedure TfrmVolumesToMount.btnSetDefaultFileNameClick(Sender: TObject);
begin
  leCSVListOfVolumesToMount.Text := CSVFilesToLoadFileName(VersionNr);
  if FileExists(leCSVListOfVolumesToMount.Text) then
    LoadCSVGrid;
end;

procedure TfrmVolumesToMount.btnAddClick(Sender: TObject);
var
  FilePath: string;
  TempVolume: TVolume;
  VolumeName: string;
  DosFilePath: string;
  NonStandardFormat: string;
  RowNr: integer;
  UnitNr: integer;

  procedure SetUnitNumbers;
  var
    Nr : integer;
  begin { SetUnitNumbers }
    RowNr     := 1;
    with StringGrid1 do
      begin
        Nr := 4;
        while RowNr < RowCount do
          begin
            while Nr < MAX_FILER_UNITNR do
              begin
                if (Nr in LEGAL_UNIT_NUMBERS) and (not (Nr in fUsedUnits)) then
                  begin
                    fUsedUnits := fUsedUnits + [Nr];
                    break;
                  end;
                Nr := Nr + 1;
              end;
            Cells[COL_UNITNUMBER, RowNr] := IntToStr(Nr);
            RowNr := RowNr + 1;
          end;
      end;
  end;  { SetUnitNumbers }

  function NextAvailableUnitNr: integer;
  var
    UnitNr: integer;
  begin { NextAvailableUnitNr }
    result := 4;   // keep the compiler happy
    for UnitNr := 4 to MAX_FILER_UNITNR do
      if (UnitNr in LEGAL_UNIT_NUMBERS) and (not (UnitNr in fUsedUnits)) then
        begin
          result := UnitNr;
          Exit;
        end;
  end;  { NextAvailableUnitNr }

begin { TfrmVolumesToMount.btnAddClick }
  if BrowseForFile('Volume to add', FilePath, 'VOL', VOLUMEFILTERLIST) then
    begin
      TempVolume := CreateVolume( self, FilePath, VersionNr);
      try
        TempVolume.LoadVolumeInfo(DIRECTORY_BLOCKNR);
        VolumeName   := TempVolume.VolumeName;
        DosFilePath  := TempVolume.DOSFileName;

        if TempVolume is TNonStandardVolume then
          NonStandardFormat := (TempVolume as TNonStandardVolume).DiskFormatUtil.DiskFormat.Desc
        else
          NonStandardFormat := '';

        Unitnr := NextAvailableUnitNr;
        with StringGrid1 do
          AddRow( IntToStr(UnitNr),
                  VolumeName,
                  DOSFilePath,
                  '' {parent unit #},
                  '' {vol start block in parent},
                  NonStandardFormat);

        fUsedUnits := fUsedUnits + [UnitNr];

        AdjustColumnWidths(StringGrid1);
        Enable_Buttons;
      finally
        FreeAndNil(TempVolume);
      end;
    end;
end;  { TfrmVolumesToMount.btnAddClick }

procedure TfrmVolumesToMount.Enable_Buttons;
var
  b: boolean;
begin
  b                        := StringGrid1.RowCount > 1;
  btnCreateCSVFile.Enabled := b;
  btnDelete.Enabled        := b;
  btnOk.Enabled             := b;
end;


procedure TfrmVolumesToMount.btnDeleteClick(Sender: TObject);
begin
  with StringGrid1 do
    if Row > 0 then
      begin
        if Row > 0 then
          StringGridDeleteRow(StringGrid1, Row);
      end
    else
      SysUtils.Beep;
end;

procedure TfrmVolumesToMount.btnUpClick(Sender: TObject);

begin
  with TStringGridHack(StringGrid1) do
    if Row >= 2 then
      MoveRow(Row, Row-1);
end;

procedure TfrmVolumesToMount.btnDownClick(Sender: TObject);
begin
  with TStringGridHack(StringGrid1) do
    if Row < RowCount-2 then
      MoveRow(Row, Row+1);
end;

{ TStringGridHack }

procedure TStringGridHack.MoveColumn(FromIndex, ToIndex: LongInt);
begin
  inherited;
end;

procedure TStringGridHack.MoveRow(FromIndex, ToIndex: Longint);
begin
  inherited;
end;

function TfrmVolumesToMount.GetBootVolume: string;
begin
  result := fBootVolume;
end;

procedure TfrmVolumesToMount.SetBootVolume(const Value: string);
begin
  fBootVolume := Value;
end;

procedure TfrmVolumesToMount.btnUseurrentlyMountedVolumesClick(Sender: TObject);
var
  UnitNr: integer;
  FileName, Ext: string;
  df: TDiskFormats;
  FormatStr: string;
begin
  StringGrid1.RowCount := 0;

  AddHeaderRow;

  for UnitNr := 0 to MAX_FILER_UNITNR do
    if UnitNr in LEGAL_UNIT_NUMBERS then
      if Assigned(fCurrentlyMountedVolumes[UnitNr].TheVolume) then
        with fCurrentlyMountedVolumes[UnitNr] do
          begin
            FileName := TheVolume.DOSFileName;
            Ext      := ExtractFileExt(FileName);
            if not StandardVolumeFormat(Ext) then
              begin
                df := DiskFormatFromExt(Ext);
                FormatStr := DiskFormatInfo[df].Desc;
              end
            else
              FormatStr := '';

            AddRow( IntToStr(UnitNr),
                    VolumeName,
                    FileName,
                    IntToStr(ParentUnitNumber),
                    IntToStr(TheVolume.VolStartBlockInParent),
                    FormatStr);
          end;
  AdjustColumnWidths(StringGrid1);
  Enable_Buttons;
end;


end.
