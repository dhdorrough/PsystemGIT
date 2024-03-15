unit DebuggerDatabasesList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, DBDatabase, pCodeDebugger;

type
  integer = SmallInt;

  TfrmDebuggerDatabasesList = class(TForm)
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    lblStatus: TLabel;
    leDebuggerDatabasesFolder: TLabeledEdit;
    btnBrowseDebuggerDatabasesFolder: TButton;
    leDatabaseReportsPath: TLabeledEdit;
    btnBrowseForDebuggerDatabaasesPath: TButton;
    leDebuggingSettingsFolder: TLabeledEdit;
    btnDebuggingSettingsFolder: TButton;
    leRootDBTextBackup: TLabeledEdit;
    btnRootDBTextBackup: TButton;
    sgDatabases: TStringGrid;
    BuildDatabasesList: TButton;
    btnAdd: TButton;
    btnDelete: TButton;
    btnReplace: TButton;
    btnBackup: TButton;
(*
    procedure btnDeleteClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
*)
    procedure btnOkClick(Sender: TObject);
    procedure btnBrowseForReportsPathClick(Sender: TObject);
(*
    procedure FormResize(Sender: TObject);
    procedure sgDatabasesDblClick(Sender: TObject);
    procedure sgDatabasesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
*)
    procedure btnBrowseDebuggerDatabasesFolderClick(Sender: TObject);
    procedure btnBrowseForDebuggerDatabaasesPathClick(Sender: TObject);
    procedure btnDebuggingSettingsFolderClick(Sender: TObject);
    procedure FileChanged(Sender: TObject);
    procedure BuildDatabasesListClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  private
    fActiveCol       : integer;
    fActiveRow       : integer;
    fCodeDebugger    : TfrmPCodeDebugger;
    fTempDataBaseList: TDataBaseList;

    procedure Browse4Folder(const aCaption: string; le: TLabeledEdit);
    procedure Browse4FileName(const aCaption: string; le: TLabeledEdit);
    procedure Enable_Buttons;
    procedure DisplayDataBaseList;
    function EditDatabaseInfo(DatabaseInfo: TDataBaseInfo): boolean;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; aCodeDebugger: TfrmPCodeDebugger); reintroduce;
    Destructor Destroy; override;
  end;

implementation

uses MyUtils, FilerSettingsUnit, uGetString, MyTables_Decl, Interp_Decl,
  DBDatabaseInfo, Interp_Common, DebuggerSettingsUnit, {pCodeDebugger,}
  pCodeDebugger_Decl, Interp_Const, DBDatabaseInfoGeneral, FileNames,
  WindowsList;

{$R *.dfm}

procedure TfrmDebuggerDatabasesList.Browse4Folder(const aCaption: string; le: TLabeledEdit);
var
  Lfn: string;
begin
  lfn := le.Text;
  if BrowseForFolder(aCaption + ' folder', Lfn) then
    le.Text := Lfn;
end;

procedure TfrmDebuggerDatabasesList.Browse4FileName(const aCaption: string; le: TLabeledEdit);
var
  Lfn: string;
begin
  Lfn := le.Text;
  if BrowseForFile(aCaption, Lfn, '.TXT') then
    le.Text := Lfn;
end;

procedure TfrmDebuggerDatabasesList.Enable_Buttons;
var
  b, b1, b2, b3: boolean;

  function CheckFor(fn: string; Msg: string): boolean;
  begin
    fn     := RemoveTrailingBackSlash(fn);
    result := FileExists(fn);
    with lblStatus do
      if not result then
        begin
          Caption := Format('%s (%s) does not exist', [Msg, fn]);
          Color   := clYellow;
          SysUtils.Beep;
        end;
  end;

begin { Enable_Buttons }
  lblStatus.Caption := '';
  lblStatus.Color   := clBtnFace;
  
  b := fCodeDebugger.DataBaseSettings.DataBaseList.Count > 0;
(*
  btnDelete.Enabled  := b;
  btnReplace.Enabled := b;
*)
  lblstatus.Caption  := '';
  b1 := CheckFor(leDebuggerDatabasesFolder.Text, 'Debugger databases');
  b2 := CheckFor(leDatabaseReportsPath.Text,     'Reports Path');
  b3 := CheckFor(leRootDBTextBackup.Text,        'Text Backup');
  b  := b1 and b2 and b3;
  BtnOk.Enabled := b;
end;  { Enable_Buttons }

procedure TfrmDebuggerDatabasesList.DisplayDataBaseList;
const
  COL_NR = 0;
  COL_FILEPATH = 1;
  COL_VERSIONNR = 2;
  COL_TEXT_BACKUP_ROOT_PATH = 3;
var
  I: integer;
begin
  with sgDataBases do
    begin
      RowCount := fTempDataBaseList.Count+1;
      ColCount := 4;
      Cells[COL_NR, 0]        := '#';
      Cells[COL_FILEPATH, 0]  := 'FilePath';
      Cells[COL_VERSIONNR, 0] := 'Version';
      CELLS[COL_TEXT_BACKUP_ROOT_PATH, 0] := 'Text Backup Root Path';
      with fCodeDebugger.DatabaseSettings do
        for i := 0 to fTempDataBaseList.Count-1 do
          with fTempDataBaseList[i] do
            begin
              Cells[COL_NR, I+1]                    := IntToStr(I+1);
              Cells[COL_FILEPATH, I+1]              := FilePath;
              Cells[COL_VERSIONNR, I+1]             := VersionNrStrings[VersionNr].Abbrev;
              Cells[COL_TEXT_BACKUP_ROOT_PATH, I+1] := TextBackupRootPath;
            end;
    end;
  AdjustColumnWidths(sgDataBases);
end;

constructor TfrmDebuggerDatabasesList.Create( aOwner: TComponent;
                                              aCodeDebugger: TfrmPCodeDebugger);
begin
  inherited Create(aOwner);

  fCodeDebugger := aCodeDebugger;
  fTempDataBaseList := TDataBaseList.Create(TDataBaseInfo);
  fTempDataBaseList.Assign(fCodeDebugger.DATABASESettings.DataBaseList);

  with fCodeDebugger.DatabaseSettings do
    begin
      leDebuggerDatabasesFolder.Text  := DebuggerDatabasesFolder;
      leDebuggingSettingsFolder.Text  := DataBaseSettingsFilesFolder;
      leDatabaseReportsPath.Text      := DatabaseReportsPath;
      leRootDBTextBackup.Text         := RootDBTextBackup;

      DisplayDataBaseList;

      Enable_Buttons;
    end;
end;

procedure TfrmDebuggerDatabasesList.btnOkClick(Sender: TObject);
begin
  with fCodeDebugger.DatabaseSettings do
    begin
      DebuggerDatabasesFolder := leDebuggerDatabasesFolder.Text;
      DatabaseReportsPath     := leDatabaseReportsPath.Text;
      RootDBTextBackup        := leRootDBTextBackup.Text;
      DataBaseList.Assign(fTempDatabaseList);
    end;
end;

function TfrmDebuggerDatabasesList.EditDatabaseInfo(DatabaseInfo: TDataBaseInfo): boolean;
begin
  frmDatabaseInfoGeneral := TfrmDatabaseInfoGeneral.Create(self);
  try
    with frmDatabaseInfoGeneral do
      begin
        FilePath           := DataBaseInfo.FilePath;
        VersionNr          := DatabaseInfo.VersionNr;

        result   := ShowModal = mrOk;
        if result then
          begin
            DataBaseInfo.FilePath       := FilePath;
            DataBaseInfo.VersionNr      := VersionNr;
          end;
      end;
  finally
    FreeAndNil(frmDatabaseInfoGeneral);
  end;
end;


procedure TfrmDebuggerDatabasesList.btnBrowseForReportsPathClick(
  Sender: TObject);
begin
  Browse4Folder('Debugger reports path', leDatabaseReportsPath);
end;

(*
procedure TfrmDebuggerDatabasesList.FormResize(Sender: TObject);
begin
  AdjustColumnWidths(sgDataBases);
end;

procedure TfrmDebuggerDatabasesList.sgDatabasesDblClick(Sender: TObject);
begin
  lblStatus.Caption := Format('x=%d, y=%d', [fActiveCol, fActiveRow]);
  btnReplaceClick(nil);
end;

procedure TfrmDebuggerDatabasesList.sgDatabasesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  fActiveCol := aCol;
  fActiveRow := aRow;
end;
*)

procedure TfrmDebuggerDatabasesList.btnBrowseDebuggerDatabasesFolderClick(Sender: TObject);
begin
  Browse4Folder('Debugger database folder path', leDebuggerDatabasesFolder);
end;

procedure TfrmDebuggerDatabasesList.btnBrowseForDebuggerDatabaasesPathClick(
  Sender: TObject);
begin
  Browse4Folder('Debugger database reports path', leDatabaseReportsPath);
end;

procedure TfrmDebuggerDatabasesList.btnDebuggingSettingsFolderClick(Sender: TObject);
begin
  Browse4Folder('Debugger settings folder', leRootDBTextBackup);
end;

procedure TfrmDebuggerDatabasesList.FileChanged(
  Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDebuggerDatabasesList.BuildDatabasesListClick(Sender: TObject);
var
  DBFileName, FilePath, WildPath, RenamedName: string;
  DosErr: integer;
  SearchRec: TSearchRec;
  f: file;
  DatabaseInfo: TDatabaseInfo;
  vn: TVersionNr;
begin
  FilePath := DataBaseSettingsFilesFolder + DATABASE_INI; // = c:\psystem\DebuggerSettings\Database.ini

// make a backup copy
// save the current DatabasesList under a unique file name
  if FileExists(FilePath) then
    begin
      RenamedName := UniqueFileName(FilePath);
      AssignFile(f, FilePath);
      Rename(f, RenamedName);   // ---> FileName (nnn).ext
    end;

  // wipe out the current temporary DataBaseList
  fTempDataBaseList.Clear;

  // now scan each of the files in the ACCDB folder and guess what version it is
  WildPath      := Format('%s*.%s', [AccDBRootFolder, ACC_EXT]);   // c:\psystem\ACCDB\*.accdb
  DosErr        := FindFirst(WildPath, faAnyFile, SearchRec);
  try
    while DosErr = 0 do
      begin
        DBFileName := SearchRec.Name;
        vn         := VersionNrFromDBFileName(DBFileName);
        if vn <> vn_Unknown then
          begin
            DatabaseInfo  := TDatabaseInfo.Create(fTempDataBaseList);
            DatabaseInfo.VersionNr := vn;
            DatabaseInfo.FilePath  := AccessDBFileFileName(vn);
            DatabaseInfo.TextBackupRootPath := CalcTextBackupRootPath(vn);
          end;
        DosErr     := FindNext(SearchRec);
      end;
  finally
    FindClose(SearchRec);
    DisplayDataBaseList;
  end;
end;

destructor TfrmDebuggerDatabasesList.Destroy;
begin
  fCodeDebugger.DEBUGGERSettings.WindowsList.AddWindow(self, WindowsType[wtDatabaseList], 0);
  FreeAndNil(fTempDataBaseList);
  inherited;
end;

procedure TfrmDebuggerDatabasesList.FormShow(Sender: TObject);
var
  dummy: integer;
begin
  with fCodeDebugger.DEBUGGERSettings.WindowsList do
    LoadWindowInfo(self, WindowsType[wtDatabaseList], dummy);
end;

procedure TfrmDebuggerDatabasesList.btnAddClick(Sender: TObject);
var
  DatabaseInfo: TDataBaseInfo;
begin
 DatabaseInfo := fTempDataBaseList.Add as TDataBaseInfo;
 DatabaseInfo.VersionNr := fCodeDebugger.DEBUGGERSettings.VersionNr;
 DatabaseInfo.FilePath  := AccDBRootFolder + '*.' + ACC_EXT;
 DatabaseInfo.TextBackupRootPath := CalcTextBackupRootPath(fCodeDebugger.DEBUGGERSettings.VersionNr);
 if EditDatabaseInfo(DatabaseInfo) then
   begin
     with sgDatabases do
       begin
         fTempDataBaseList[RowCount-1] := DatabaseInfo;
         RowCount := RowCount + 1;
       end;
     DisplayDataBaseList;
   end;
end;

procedure TfrmDebuggerDatabasesList.btnReplaceClick(Sender: TObject);
var
  DatabaseInfo: TDataBaseInfo;
begin
  with sgDatabases do
    begin
      DatabaseInfo := fTempDataBaseList[Row-1];
      if EditDatabaseInfo(DataBaseInfo) then
        begin
          fTempDataBaseList[Row-1] := DatabaseInfo;
          DisplayDataBaseList;
        end;
    end;
end;

procedure TfrmDebuggerDatabasesList.btnDeleteClick(Sender: TObject);
begin
  with sgDatabases do
    if Row > 0 then
      begin
        fTempDataBaseList.Delete(Row-1);
        DisplayDataBaseList;
      end
    else
      SysUtils.Beep;
end;

initialization
finalization
end.

