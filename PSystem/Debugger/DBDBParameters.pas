unit DBDBParameters;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, OverWrite_Decl, Interp_Decl, Interp_Const;

type
  TShowWhat = (swListingFileName, swDBFileName, swReportFileName, swVersionNr, swReportsPath,
               swListingFormat, swErasePCode);

  TListingFormat = (lfUnknown, lfAsCompilerListing, lfAsCompilerSource, lfMinimum);

  TShowWhatSet = set of TShowWhat;

  TFunctionType = ( ftNewDB,
                    ftScanCodeFileAndUpdateDB,
                    ftBuildDBFromListing,
                    ftBuildUglySource,
                    ftParseAndList,
                    ftScanFileForVersionNr,
                    ftCleanCompilerListing,
                    ftFixProcNames);

  TfrmFileParameters = class(TForm)
    btnBegin: TButton;
    btnOK: TButton;
    rgDBOptions: TRadioGroup;
    rgVersionNr: TRadioGroup;
    pnlInputListingFile: TPanel;
    leFile1Name: TLabeledEdit;
    BtnBrowse1: TButton;
    pnlDBFile: TPanel;
    leDBFileName: TLabeledEdit;
    btnBrowseDB: TButton;
    pnlReportFileName: TPanel;
    leOutputFileName: TLabeledEdit;
    btnBrowseOutput: TButton;
    pnlReportsFolder: TPanel;
    leReportsPath: TLabeledEdit;
    btnBrowseReportsFolder: TButton;
    cbGenerateOutputFiles: TCheckBox;
    rbAsCompilerListing: TRadioButton;
    rbAsCompilerSource: TRadioButton;
    cbEraseSourceCodeAndProcedureName: TCheckBox;
    cbErasePCode: TCheckBox;
    procedure BtnBrowse1Click(Sender: TObject);
    procedure btnBrowseDBClick(Sender: TObject);
    procedure btnBrowseOutputClick(Sender: TObject);
    procedure rgVersionNrClick(Sender: TObject);
    procedure btnBrowseReportsFolderClick(Sender: TObject);
    procedure leFile1NameExit(Sender: TObject);
    procedure leDBFileNameExit(Sender: TObject);
    procedure leOutputFileNameChange(Sender: TObject);
    procedure leReportsPathChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    fFunctionType: TFunctionType;
    procedure Enable_Buttons;
    function GetDataBaseFileName: string;
    function GetInputListingFileName: string;
    function GetOutputFileName: string;
    procedure SetDataBaseFileName(const Value: string);
    procedure SetInputListingFileName(const Value: string);
    procedure SetOutputFileName(const Value: string);
    procedure SetShowWhat(const Value: TShowWhatSet);
    function GetOverWriteOptions: TOverWriteOptions;
    procedure SetOverWriteOptions(const Value: TOverWriteOptions);
    function GetVersionNr: TVersionNr;
    procedure SetVersionNr(const Value: TVersionNr);
    procedure SetFunctionType(const Value: TFunctionType);
    function GetReportsPath: string;
    procedure SetReportsPath(const Value: string);
    function GetGenerateOutputFiles: boolean;
    procedure SetGenerateOutputFiles(const Value: boolean);
    function GetListingFormat: TListingFormat;
    procedure SetListingFormat(const Value: TListingFormat);
    function GetEraseSourceCodeAndProcName: boolean;
    function GetOutputListingFileName: string;
    procedure SetOutputListingFileName(const Value: string);
    function GetErasePCode: boolean;
    procedure SetErasePCode(const Value: boolean);
    { Private declarations }
  public
    { Public declarations }
//  destructor Destroy; override;
    Constructor Create(aOwner: TComponent); override;
    property InputListingFileName: string
             read GetInputListingFileName
             write SetInputListingFileName;
    property OutputListingFileName: string
             read GetOutputListingFileName
             write SetOutputListingFileName;
    property DataBaseFileName: string
             read GetDataBaseFileName
             write SetDataBaseFileName;
    property OutputFileName: string
             read GetOutputFileName
             write SetOutputFileName;
    property ShowWhat: TShowWhatSet
             write SetShowWhat;
    property OverWriteOptions: TOverWriteOptions
             read GetOverWriteOptions
             write SetOverWriteOptions;
    property VersionNr: TVersionNr
             read GetVersionNr
             write SetVersionNr;
    property FunctionType: TFunctionType
             read fFunctionType
             write SetFunctionType;
    property ReportsPath: string
             read GetReportsPath
             write SetReportsPath;
    property GenerateOutputFiles: boolean
             read GetGenerateOutputFiles
             write SetGenerateOutputFiles;
    property ListingFormat: TListingFormat
             read GetListingFormat
             write SetListingFormat;
    property EraseSourceCodeAndProcName: boolean
             read GetEraseSourceCodeAndProcName;
    property ErasePCode: boolean
             read GetErasePCode
             write SetErasePCode;
  end;

var
  frmFileParameters: TfrmFileParameters;

implementation

uses MyUtils, MyTables_Decl, YesNoDontAskAgain, PsysUnit, FileNames;

{$R *.dfm}


{ TfrmFileParameters }

function TfrmFileParameters.GetDataBaseFileName: string;
begin
  result := leDBFileName.Text;
end;

function TfrmFileParameters.GetInputListingFileName: string;
begin
  result := leFile1Name.Text;
end;

function TfrmFileParameters.GetOutputFileName: string;
begin
  result := leOutputFileName.Text;
end;

procedure TfrmFileParameters.SetDataBaseFileName(const Value: string);
begin
  leDBFileName.Text := Value;
  Enable_Buttons;
end;

procedure TfrmFileParameters.SetInputListingFileName(const Value: string);
begin
  leFile1Name.Text := Value;
  Enable_Buttons;
end;

procedure TfrmFileParameters.SetOutputFileName(const Value: string);
begin
  leOutputFileName.Text := Value;
end;

procedure TfrmFileParameters.SetShowWhat(const Value: TShowWhatSet);
begin
  pnlInputListingFile.Visible := swListingFileName in Value;

  pnlDBFile.Visible           := swDBFileName in Value;

  pnlReportFileName.Visible   := swReportFileName in Value;

  pnlReportsFolder.Visible    := swReportsPath in Value;

  rgVersionNr.Visible         := swVersionNr in Value;
  rgDBOptions.Visible         := swDBFileName in Value;

  rbAsCompilerListing.Visible := swListingFormat in Value;
  rbAsCompilerSource.Visible  := swListingFormat in Value;

  cbErasePCode.Visible        := swErasePCode in Value;
end;

procedure TfrmFileParameters.BtnBrowse1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := leFile1Name.Text;
  if BrowseForFile('Input File (Listing)', FileName, TXT_EXT) then
    begin
      InputListingFileName := FileName;
      if FunctionType = ftBuildUglySource then
        OutputFileName := ForceExtension(InputListingFileName, PAS_EXT);
      Enable_Buttons;
    end;
end;

procedure TfrmFileParameters.btnBrowseDBClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := leDBFileName.Text;
  if BrowseForFile('Database File', FileName, ACCDB_EXT) then
    begin
      leDBFileName.Text := FileName;
      Enable_Buttons;
    end;
end;

procedure TfrmFileParameters.btnBrowseOutputClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := leOutputFileName.Text;
  if BrowseForFile('Output Filename', FileName, TXT_EXT) then
    begin
      leOutputFileName.Text := FileName;
      Enable_Buttons;
    end;
end;

function TfrmFileParameters.GetOverWriteOptions: TOverWriteOptions;
begin
  result := TOverWriteOptions(rgDBOptions.ItemIndex);
end;

procedure TfrmFileParameters.SetOverWriteOptions(
  const Value: TOverWriteOptions);
begin
  rgDBOptions.ItemIndex := Integer(Value);
end;

function TfrmFileParameters.GetVersionNr: TVersionNr;
begin
  result := vn_Unknown;
  with rgVersionNr do
    case ItemIndex of
      1: result := vn_VersionI_4;
      2: result := vn_VersionI_5;
      3: result := vn_VersionII;
      4: result := vn_VersionIV;
    end;
end;

procedure TfrmFileParameters.SetVersionNr(const Value: TVersionNr);
begin
  with rgVersionNr do
    case Value of
      vn_VersionI_4:
        ItemIndex := 1;
      vn_VersionI_5:
        ItemIndex := 2;
      vn_VersionII:
        ItemIndex := 3;
      vn_VersionIV:
        ItemIndex := 4;
    end;
end;

procedure TfrmFileParameters.Enable_Buttons;
begin
  case fFunctionType of
    ftScanFileForVersionNr, ftParseAndList:
      btnOK.Enabled := (VersionNr > vn_Unknown) and FileExists(InputListingFileName);
    ftBuildDBFromListing:
      btnOK.Enabled := (VersionNr > vn_Unknown) and
                       FileExists(InputListingFileName) and
                       FileExists(DataBaseFileName);
    ftBuildUglySource:
      btnOK.Enabled := (VersionNr > vn_Unknown) and
                       FileExists(InputListingFileName);
    ftScanCodeFileAndUpdateDB:
      btnOK.Enabled := (VersionNr > vn_Unknown) and
                       FileExists(DataBaseFileName);
    ftNewDB:
      btnOK.Enabled := true;
  end;
  cbEraseSourceCodeAndProcedureName.Visible := fFunctionType = ftScanCodeFileAndUpdateDB;
end;

procedure TfrmFileParameters.rgVersionNrClick(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmFileParameters.SetFunctionType(const Value: TFunctionType);
begin
  fFunctionType := Value;
  case Value of
    ftParseAndList:
      begin
        ShowWhat    := [swListingFileName, swReportFileName, swVersionNr];
        OutputFileName := ForceExtension(leOutputFileName.Text, CSV_EXT);
        Caption     := 'Parse and List';
      end;
    ftBuildDBFRomListing:
      begin
        ShowWhat    := [swListingFileName, swDBFileName, swReportFileName, swVersionNr, swErasePCode];
        OutputFileName := ForceExtension(OutputFileName, CSV_EXT);
        Caption     := 'Build DB From Listing';
      end;
    ftNewDB:
      begin
        ShowWhat    := [swDBFileName];
        Caption     := 'New DB';
      end;
    ftScanCodeFileAndUpdateDB:
      begin
        ShowWhat    := [swDBFileName, swReportFileName, swVersionNr];
        Caption     := 'Scan Code File and Update DB';
      end;
    ftBuildUglySource:
      begin
        ShowWhat    := [swListingFileName, swReportFileName, swVersionNr];
        OutputFileName := ForceExtension(leOutputFileName.Text, PAS_EXT);
        Caption     := 'Build Ugly Source from Compiler Listing';
      end;
    ftScanFileForVersionNr:
      begin
        ShowWhat := [swListingFileName, swReportsPath];
        Caption     := 'Scan For Version Number';
      end;
    ftCleanCompilerListing:
      begin
        ShowWhat    := [swListingFileName, swReportFileName, swVersionNr, swListingFormat];
        Caption     := 'Cleanup Compiler Listing';
      end;
    ftFixProcNames:
      begin
        ShowWhat    := [swReportFileName];
        Caption     := 'FullProcedureName --> PROCNAME';
      end;
  end;
  Enable_Buttons;
end;

procedure TfrmFileParameters.btnBrowseReportsFolderClick(Sender: TObject);
var
  Temp: string;
begin
  Temp := ReportsPath;
  if BrowseForFolder('Browse for reports folder', Temp) then
    ReportsPath := Temp;
end;

function TfrmFileParameters.GetReportsPath: string;
begin
  result := ForceBackSlash(leReportsPath.Text);
end;

procedure TfrmFileParameters.SetReportsPath(const Value: string);
begin
  leReportsPath.Text := Value;
end;

function TfrmFileParameters.GetGenerateOutputFiles: boolean;
begin
  result := cbGenerateOutputFiles.Checked;
end;

procedure TfrmFileParameters.SetGenerateOutputFiles(const Value: boolean);
begin
  cbGenerateOutputFiles.Checked := Value;
end;

function TfrmFileParameters.GetListingFormat: TListingFormat;
begin
  if rbAsCompilerListing.Checked then
    result := lfAsCompilerListing else
  if self.rbAsCompilerSource.Checked then
    result := lfAsCompilerSource
  else
    result := lfUnknown;
end;

procedure TfrmFileParameters.SetListingFormat(const Value: TListingFormat);
begin
  case Value of
    lfAsCompilerListing:
      rbAsCompilerListing.Checked := true;
    lfAsCompilerSource:
      rbAsCompilerSource.Checked := true;
  end;
end;

function TfrmFileParameters.GetEraseSourceCodeAndProcName: boolean;
begin
  result := cbEraseSourceCodeAndProcedureName.Checked;
end;

function TfrmFileParameters.GetOutputListingFileName: string;
begin
  result := leReportsPath.Text;
end;

procedure TfrmFileParameters.SetOutputListingFileName(const Value: string);
begin
 leReportsPath.Text := Value;
end;

procedure TfrmFileParameters.leFile1NameExit(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmFileParameters.leDBFileNameExit(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmFileParameters.leOutputFileNameChange(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmFileParameters.leReportsPathChange(Sender: TObject);
begin
  Enable_Buttons;
end;

function TfrmFileParameters.GetErasePCode: boolean;
begin
  result := cbErasePCode.Checked;
end;

procedure TfrmFileParameters.btnOKClick(Sender: TObject);
begin
  if (FunctionType = ftBuildDBFromListing) and ErasePCode then
    if not Yes('Do you really want to erase existing p-Code?') then
      ErasePCode := false;
end;

procedure TfrmFileParameters.SetErasePCode(const Value: boolean);
begin
  cbErasePCode.Checked := Value;
end;

(*
destructor TfrmFileParameters.Destroy;
begin

  inherited;
end;
*)

constructor TfrmFileParameters.Create(aOwner: TComponent);
begin
  inherited;

end;

initialization
finalization
end.
