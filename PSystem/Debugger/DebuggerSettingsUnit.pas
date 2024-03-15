unit DebuggerSettingsUnit;

interface

uses SettingsFiles, Classes, Forms,
     Debug_Decl,
     DBDatabase, Interp_Decl, WindowsList, Interp_Const, pSys_Decl;

type
  TDATABASESettings = class(TSettingsFile)
  private
    fDataBaseList          : TDataBaseList;
    fDebuggerDatabasesFolder: string;
    fDataBaseReportsPath: string;
    fRootDBTextBackup: string;
    function GetDataBaseList: TDataBaseList;
    procedure SetDataBaseList(const Value: TDataBaseList);
  public
    Destructor Destroy; override;
    Constructor Create(aOwner: TComponent); override;
  published
    property DebuggerDatabasesFolder: string
             read fDebuggerDatabasesFolder
             write fDebuggerDatabasesFolder;
    property DataBaseReportsPath: string
             read fDataBaseReportsPath
             write fDataBaseReportsPath;
    property RootDBTextBackup: string
             read fRootDBTextBackup
             write fRootDBTextBackup;
    property DataBaseList: TDataBaseList  // reminder: this is in DATABASESettings (not DEBUGGERSettings)
             read GetDataBaseList
             write SetDataBaseList;
  end;

  TDEBUGGERSettings = class(TSettingsFile)
  private
    fBrks                  : TBreakList;
    fCallHistOnly          : boolean;
    fChangedMemBreak       : integer;
    fLastBootedFileName    : string;
    fVersionNr             : TVersionNr;
    fLastBootedUnitNr      : integer;
    fMaxHistoryItems       : integer;
    fReportsPath           : string;
    fWindowsList           : TWindowsList;
    fWatchList             : TWatchList;
    fDatabaseToUse         : string;
    fLogFileName           : string;
    fListingsPath          : string;

    function GetBreakList: TBreakList;
    procedure SetBreakList(const Value: TBreakList);
    procedure SetWatchList(const Value: TWatchList);
    function GetMaxHistoryItems: integer;
    function GetCallHistOnly: boolean;
    procedure SetCallHistOnly(const Value: boolean);
    function GetWatchList: TWatchList;
    function GetWindowsList: TWindowsList;
    procedure SetWindowsList(const Value: TWindowsList);
    function GetReportsPath: string;
    procedure SetDatabaseToUse(const Value: string);
    function GetLogFileName: string;
    function GetListingsPath: string;
  protected
  public
    RootPath: string;

    Destructor Destroy; override;
    Constructor Create(aOwner: TComponent); reintroduce;
    procedure SaveToFile(const FileName: string); override;

    property Brks: TBreakList
             read GetBreakList
             write SetBreakList;
    property ChangedMemBreak: integer
             read fChangedMemBreak
             write fChangedMemBreak;
//  property WindowsList: TWindowsList
//           read fWindowsList
//           write fWindowsList;
  published
    property VersionNr: TVersionNr
             read fVersionNr
             write fVersionNr;
    property DatabaseToUse: string
             read fDatabaseToUse
             write SetDatabaseToUse;
    property ReportsPath: string
             read GetReportsPath
             write fReportsPath;
    property ListingsPath: string
             read GetListingsPath
             write fListingsPath;
    property LogFileName: string
             read GetLogFileName
             write fLogFileName;

    property LastBootedFileName: string
             read fLastBootedFileName
             write fLastBootedFileName;
    property LastBootedUnitNr: integer
             read fLastBootedUnitNr
             write fLastBootedUnitNr;
    property CallHistoryOnly: boolean
             read GetCallHistOnly
             write SetCallHistOnly;
    property MaxHistoryItems: integer
             read GetMaxHistoryItems
             write fMaxHistoryItems;
    property BreakList: TBreakList
             read GetBreakList
             write SetBreakList;
    property WatchList: TWatchList
             read GetWatchList
             write SetWatchList;
    property WindowsList: TWindowsList
             read GetWindowsList
             write SetWindowsList;
  end;

var
  gDebuggerSettings: TDEBUGGERSettings;

implementation

uses MyUtils, SysUtils, FilerSettingsUnit, MyTables_Decl, Misc, FileNames;

{ TDEBUGGERSettings }

destructor TDEBUGGERSettings.Destroy;
begin
  FreeAndNil(fWindowsList);
  FreeAndNil(fBrks);
  FreeAndNil(fWatchList);
  gDebuggerSettings := nil;
  inherited;
end;

function TDEBUGGERSettings.GetBreakList: TBreakList;
begin
  if not Assigned(fBrks) then
    fBrks := TBreakList.Create(self);
  result := fBrks;
end;

procedure TDEBUGGERSettings.SetBreakList(const Value: TBreakList);
begin
  fBrks := Value;
end;

function TDEBUGGERSettings.GetMaxHistoryItems: integer;
begin
  if (fMaxHistoryItems > MAXHIST) then
    Result := fMaxHistoryItems
  else
    Result := MAXHIST;
end;

function TDEBUGGERSettings.GetWatchList: TWatchList;
begin
  if not Assigned(fWatchList) then
    fWatchList := TWatchList.Create(self);
  result := fWatchList;
end;

function TDEBUGGERSettings.GetCallHistOnly: boolean;
begin
  result := fCallHistOnly;
end;

procedure TDEBUGGERSettings.SetCallHistOnly(const Value: boolean);
begin
  fCallHistOnly := Value;
end;

function TDEBUGGERSettings.GetWindowsList: TWindowsList;
begin
  if not Assigned(fWindowsList) then
    fWindowsList := TWindowsList.Create(TWindowInfo);
  result := fWindowsList;
end;

procedure TDEBUGGERSettings.SetWindowsList(const Value: TWindowsList);
begin
  fWindowsList := Value;
end;



function TDATABASESettings.GetDataBaseList: TDataBaseList;
begin
  result := fDataBaseList;
end;

procedure TDATABASESettings.SetDataBaseList(const Value: TDataBaseList);
begin
  Message('SetDataBaseList');
end;

function TDEBUGGERSettings.GetReportsPath: string;
begin
  if not Empty(fReportsPath) then
    Result := fReportsPath
  else
    Result := gRootPath + 'Reports\';
end;

constructor TDEBUGGERSettings.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  RootPath   := ExtractFilePath(ParamStr(0));
  gDebuggerSettings := self;   // needed for OldDebugger
end;


procedure TDEBUGGERSettings.SetWatchList(const Value: TWatchList);
begin
  fWatchList := Value;
end;


procedure TDEBUGGERSettings.SaveToFile(const FileName: string);
begin
  inherited;

end;

procedure TDEBUGGERSettings.SetDatabaseToUse(const Value: string);
begin
  fDatabaseToUse := Value;
end;

function TDEBUGGERSettings.GetLogFileName: string;
begin
  if Empty(fLogFileName) then
    fLogFileName := Format('%sLogFile-%s.%s',
               [ReportsPath, VersionNrStrings[VersionNr].Abbrev, TXT_EXT]);
  result := fLogFileName;
end;

function TDEBUGGERSettings.GetListingsPath: string;
begin
  if Empty(fListingsPath) then
    fListingsPath := gRootPath + 'Listings\CompilerListing.txt';
  result := fListingsPath;
end;

{ TDATABASESettings }

destructor TDATABASESettings.Destroy;
begin
  FreeAndNil(fDatabaseList);
  inherited;
end;

constructor TDATABASESettings.Create(aOwner: TComponent);
begin
  inherited;
  fDatabaseList := TDatabaseList.Create(TDatabaseInfo);
end;

initialization
finalization
end.

