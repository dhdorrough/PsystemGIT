unit DebuggerSettingsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, DBDatabase, DebuggerSettingsUnit,
  Misc, FileNames;

type
  TfrmDebuggerSettings = class(TForm)
    leLogFileName: TLabeledEdit;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    btnBrowseLogFileName: TButton;
    leReportsPath: TLabeledEdit;
    btnBrowseForReportsPath: TButton;
    leDatabaseUsedByDebugger: TLabeledEdit;
    btnBrowseForDatabaseUsedByDebugger: TButton;
    lblStatus: TLabel;
    lblFileDoesNotExist: TLabel;
    cbVersionNumbers: TComboBox;
    procedure btnBrowseLogFileNameClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnBrowseForReportsPathClick(Sender: TObject);
    procedure leDatabaseUsedByDebuggerChange(Sender: TObject);
    procedure btnBrowseForDatabaseUsedByDebuggerClick(Sender: TObject);
    procedure cbVersionNumbersClick(Sender: TObject);
  private
    { Private declarations }
    fDEBUGGERSettings: TDEBUGGERSettings;
    procedure Browse4Folder(const aCaption: string; le: TLabeledEdit);
    procedure Browse4FileName(const aCaption: string; le: TLabeledEdit; Ext: string = TXT_EXT);
    procedure Enable_Buttons;
    function GetLogFilePath: string;
    function GetReportsPath: string;
    procedure SetLogFilePath(const Value: string);
    procedure SetReportsPath(const Value: string);
    function GetDatabaseToUse: string;
    procedure SetDatabaseToUse(const Value: string);
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; DEBUGGERSettings: TDEBUGGERSettings); reintroduce;
    property ReportsPath: string
             read GetReportsPath
             write SetReportsPath;
    property LogFilePath: string
             read GetLogFilePath
             write SetLogFilePath;
    property DatabaseToUse: string
             read GetDatabaseToUse
             write SetDatabaseToUse;
  end;

var
  frmDEBUGGERSettings: TfrmDEBUGGERSettings;

implementation

uses MyUtils, FilerSettingsUnit, uGetString, MyTables_Decl, Interp_Decl,
  DBDatabaseInfo, Interp_Common, pCodeDebugger,
  pCodeDebugger_Decl, Interp_Const;

{$R *.dfm}

procedure TfrmDEBUGGERSettings.Browse4Folder(const aCaption: string; le: TLabeledEdit);
var
  Lfn: string;
begin
  lfn := le.Text;
  if BrowseForFolder(aCaption + ' folder', Lfn) then
    le.Text := Lfn;
end;

procedure TfrmDEBUGGERSettings.Browse4FileName( const aCaption: string;
                                                le: TLabeledEdit;
                                                Ext : string = TXT_EXT);
var
  Lfn: string;
begin
  Lfn := le.Text;
  if BrowseForFile(aCaption, Lfn, Ext) then
    le.Text := Lfn;
end;

procedure TfrmDEBUGGERSettings.btnBrowseLogFileNameClick(Sender: TObject);
begin
  Browse4FileName('Log file used for this version', leLogFileName, TXT_EXT);
end;

function TfrmDEBUGGERSettings.GetDatabaseToUse: string;
begin
  result := leDatabaseUsedByDebugger.Text;
end;

procedure TfrmDEBUGGERSettings.SetDatabaseToUse(const Value: string);
begin
  leDatabaseUsedByDebugger.Text := Value;
end;



procedure TfrmDEBUGGERSettings.Enable_Buttons;
var
  nb: boolean;
begin
  with fDEBUGGERSettings do
    begin
      nb := not FileExists(DatabaseToUse);
      lblFileDoesNotExist.visible := nb;
      if nb then
        lblFileDoesNotExist.Caption := Format('File "%s" does not exist', [DatabaseToUse]);
    end;
end;

constructor TfrmDEBUGGERSettings.Create(aOwner: TComponent; DEBUGGERSettings: TDEBUGGERSettings);
var
  vn: TVersionNr;
  idx: integer;
  VersionNrStr: string;
begin
  inherited Create(aOwner);
  fDEBUGGERSettings := DEBUGGERSettings;
  with fDEBUGGERSettings do
    begin
      VersionNrStr         := VersionNrStrings[VersionNr].Abbrev;
      Caption              := Format('Debugger Settings for Version %s', [VersionNrStr]);
      Enable_Buttons;
      leDatabaseUsedByDebugger.Text := DatabaseToUse;
      leLogFileName.Text            := LogFilePath;
      leReportsPath.Text            := ReportsPath;

      with cbVersionNumbers do
        begin
          for vn := vn_VersionI_4 to High(TVersionNr) do
            if not (vn in BADVERSIONS) then
              Items.AddObject(VersionNrStrings[vn].Name, TObject(vn));

          idx := Items.IndexOfObject(TObject(VersionNr));
          if Idx >= 0 then
            ItemIndex := Idx;
        end;
    end;

end;

procedure TfrmDEBUGGERSettings.btnOkClick(Sender: TObject);
var
  Idx: integer;
begin
  with fDEBUGGERSettings do
    begin
      LogFilePath        := leLogFileName.Text;
      ReportsPath        := leReportsPath.Text;
      DatabaseToUse      := leDatabaseUsedByDebugger.Text;

      with cbVersionNumbers do
        begin
          Idx := ItemIndex;
          if Idx >= 0 then
            with fDEBUGGERSettings do  // DO update the Settings file here
              VersionNr := TVersionNr(Items.Objects[ItemIndex]);
        end;
    end;
end;

procedure TfrmDEBUGGERSettings.btnBrowseForReportsPathClick(
  Sender: TObject);
begin
  Browse4Folder('Debugger reports path', leReportsPath);
end;

function TfrmDEBUGGERSettings.GetLogFilePath: string;
begin
  result := leLogFileName.Text;
end;

function TfrmDEBUGGERSettings.GetReportsPath: string;
begin
  result := leReportsPath.Text;
end;

procedure TfrmDEBUGGERSettings.SetLogFilePath(const Value: string);
begin
  leLogFileName.Text := Value;
end;

procedure TfrmDEBUGGERSettings.SetReportsPath(const Value: string);
begin
  leReportsPath.Text := Value;
end;

procedure TfrmDEBUGGERSettings.leDatabaseUsedByDebuggerChange(
  Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDEBUGGERSettings.btnBrowseForDatabaseUsedByDebuggerClick(Sender: TObject);
begin
  Browse4FileName('Database used for this version', leDatabaseUsedByDebugger, ACCDB_EXT);
  Enable_Buttons;
end;

procedure TfrmDEBUGGERSettings.cbVersionNumbersClick(Sender: TObject);
var
  Idx: integer;
  VersionNrStr: string;
  VersionNr: TVersionNr;
begin
  with cbVersionNumbers do
    begin
      Idx := ItemIndex;
      if Idx > 0 then
//      with fDEBUGGERSettings do  // DON'T update the Settings file here
          begin
            VersionNr     := TVersionNr(Items.Objects[ItemIndex]);
            VersionNrStr  := VersionNrStrings[VersionNr].Name;
            Caption       := Format('Debugger Settings for Version %s', [VersionNrStr]);
          end;
    end;
end;

end.

