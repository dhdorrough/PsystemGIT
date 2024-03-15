unit FilerSettingsUnit;

interface

uses SettingsFiles, Classes, Forms,
     Interp_Decl, WindowsList, CrtUnit, Interp_Const, LoadVersion;

type

  TFilerSettings = class(TSettingsFile)
  private
    fAutoEdit                : boolean;
    fCSVListOfVolumesToMount : string;
    fDefaultPSystemVersion   : TVersionNr;
    fEditorFilePath          : string;
    fLogFileName             : string;
    fPrinterLfn              : string;
    fRecentBootsList         : TRecentBootsList;
    fRecentVolumes           : TStringList;
    fReportsPath             : string;
    fSearchFolder            : string;
    fTermType                : TTermType;
    fVolumesFolder           : string;
    fWindowsList             : TWindowsList;

    function GetLogFileName: string;
    function GetRecentVolumes: TStringList;
    function GetWindowsList: TWindowsList;
    procedure SetWindowsList(const Value: TWindowsList);
    function GetReportsPath: string;
    function GetEditorFilePath: string;
    function GetDefaultPSystemVersion: TVersionNr;
    procedure SetDefaultPSystemVersion(const Value: TVersionNr);
    procedure SetTermType(const Value: TTermType);
    function GetPrinterLfn: string;
    function GetRecentBootsList: TRecentBootsList;
    procedure SetRecentBootsList(const Value: TRecentBootsList);
    function GetLogRunsFileName: string;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure SaveSettings(const SettingsFileName: string); override;
  public
    Destructor Destroy; override;
  published
    property SearchFolder: string
             read fSearchFolder
             write fSearchFolder;
    property VolumesFolder: string
             read fVolumesFolder
             write fVolumesFolder;
    property LogFileName: string
             read GetLogFileName
             write fLogFileName;
    property RecentVolumes: TStringList
             read GetRecentVolumes
             write fRecentVolumes;
    property WindowsList: TWindowsList
             read GetWindowsList
             write SetWindowsList;
    property PrinterLfn: string
             read GetPrinterLfn
             write fPrinterLfn;
    property ReportsPath: string
             read GetReportsPath
             write fReportsPath;
    property EditorFilePath: string
             read GetEditorFilePath
             write fEditorFilePath;
    property DefaultPSystemVersion: TVersionNr
             read GetDefaultPSystemVersion
             write SetDefaultPSystemVersion
             default vn_Unknown;
    property TermType: TTermType
             read fTermType
             write SetTermType;
    property RecentBootsList: TRecentBootsList
             read GetRecentBootsList
             write SetRecentBootsList;
    property AutoEdit: boolean
             read fAutoEdit
             write fAutoEdit;
    property LogRunsFileName: string
             read GetLogRunsFileName;
    property CSVListOfVolumesToMount: string
             read fCSVListOfVolumesToMount
             write fCSVListOfVolumesToMount;
  end;

var
  FilerSettings: TFilerSettings;
  gRootPath: string;                  // always has a trailing '\'
  FilerSettingsFileName: string;

implementation

uses MyUtils, SysUtils{, FilerSettingsForm};

{ TFilerSettings }

destructor TFilerSettings.Destroy;
begin
  FreeAndNil(fRecentVolumes);
  FreeAndNil(fWindowsList);
  FreeAndNil(fRecentBootsList);

  inherited;
end;

function TFilerSettings.GetRecentVolumes: TStringList;
begin
  if not Assigned(fRecentVolumes) then
    fRecentVolumes := TStringList.Create;
  result := fRecentVolumes;
end;

function TFilerSettings.GetWindowsList: TWindowsList;
begin
  if not Assigned(fWindowsList) then
    fWindowsList := TWindowsList.Create(TWindowInfo);
  result := fWindowsList;
end;

procedure TFilerSettings.SetWindowsList(const Value: TWindowsList);
begin
  fWindowsList := Value;
end;

function TFilerSettings.GetLogFileName: string;
begin
  if fLogFileName <> ''  then
    Result := fLogFileName
  else
    result := FileNameByDate(ReportsPath + 'LOGFILE.LOG');
end;

function TFilerSettings.GetReportsPath: string;
begin
  if fReportsPath <> '' then
    Result := fReportsPath
  else
    Result := gRootPath + 'Reports\';
end;

function TFilerSettings.GetEditorFilePath: string;
begin
  if fEditorFilePath <> '' then
    Result := fEditorFilePath
  else
    Result := 'NotePad.exe';;
end;

function TFilerSettings.GetDefaultPSystemVersion: TVersionNr;
begin
  if fDefaultPSystemVersion = vn_Unknown then
    fDefaultPSystemVersion := vn_VersionIV;
  Result := fDefaultPSystemVersion;
end;

procedure TFilerSettings.DefineProperties(Filer: TFiler);
begin
  inherited;

end;

procedure TFilerSettings.SetDefaultPSystemVersion(const Value: TVersionNr);
begin
  if Value <> fDefaultPSystemVersion then
    fDefaultPSystemVersion := Value;
end;

procedure TFilerSettings.SetTermType(const Value: TTermType);
begin
  fTermType := Value;
end;

function TFilerSettings.GetPrinterLfn: string;
begin
  if Empty(fPrinterLfn) then
    fPrinterLfn := fReportsPath + 'Printer.txt';

  Result := fPrinterLfn;
end;


function TFilerSettings.GetRecentBootsList: TRecentBootsList;
begin
  if not Assigned(fRecentBootsList) then
    fRecentBootsList := TRecentBootsList.Create(TBootParams);
  result := fRecentBootsList;
end;

procedure TFilerSettings.SetRecentBootsList(
  const Value: TRecentBootsList);
begin
  fRecentBootsList := Value;
end;


procedure TFilerSettings.SaveSettings(const SettingsFileName: string);
begin
  fRecentBootsList.CleanUpList;

  inherited;
end;

function TFilerSettings.GetLogRunsFileName: string;
begin
  result := ReportsPath + 'LogRuns.csv';
end;

initialization
  gRootPath             := ExtractFilePath(ParamStr(0));
  FilerSettingsFileName := gRootPath + 'Filer.ini';
end.

