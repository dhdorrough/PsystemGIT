unit DBDatabaseInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Interp_Decl, Interp_Const, ComCtrls;

type
  TfrmDatabaseInfo = class(TForm)
    leFilePath: TLabeledEdit;
    btnBrowseFilePath: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnBrowseFilePathClick(Sender: TObject);
//  procedure ButtonBrowseTextBackupRootPathClick(Sender: TObject);
    procedure leFilePathExit(Sender: TObject);
    procedure leTextBackupRootPathChange(Sender: TObject);
    procedure leTextBackupRootPathExit(Sender: TObject);
    procedure leFilePathChange(Sender: TObject);
  private
    function GetVersionNumbers: TVersionNumbers;
    procedure SetVersionNumbers(const Value: TVersionNumbers);
    function GetFilePath: string;                                         
    procedure SetFilePath(const Value: string);
//  function GetTextBackupRootPath: string;
//  procedure SetTextBackupRootPath(const Value: string);
//  function GetActive: boolean;
//  procedure SetActive(const Value: boolean);
//  procedure DoOnChange(Sender: TObject; ListItem: TListItem;
//    Change: TItemChange);
    procedure Enable_Buttons;
//  function GetVersionNr: TVersionNr;
//  procedure SetVersionNr(const Value: TVersionNr);
    { Private declarations }
  public
    { Public declarations }
    property FilePath: string
             read GetFilePath
             write SetFilePath;
    property TheVersionNumbers: TVersionNumbers  // Versions that his DB should work for
             read GetVersionNumbers
             write SetVersionNumbers;
//  property Active: boolean
//           read GetActive
//           write SetActive;
//  property TextBackupRootPath: string
//           read GetTextBackupRootPath
//           write SetTextBackupRootPath;
//  property VersionNr: TVersionNr
//           read GetVersionNr
//           write SetVersionNr;
    Constructor Create(aOwner: TComponent; VersionNr: TVersionNr); reintroduce;
  end;

var
  frmDatabaseInfo: TfrmDatabaseInfo;

implementation

uses MyUtils, MyTables_Decl
{$IfDef debugging}
     , DebuggerSettingsUnit
{$EndIf debugging}
     ;

{$R *.dfm}

function TfrmDatabaseInfo.GetFilePath: string;
begin
  result := leFilePath.Text;
end;

function TfrmDatabaseInfo.GetVersionNumbers: TVersionNumbers;
var
  vn: TVersionNr;
  i: integer;
  ListItem : TListItem;
begin
  result := [];
(*
  result := [VersionNr];
  with lvVersions do
    for i := 0 to Items.Count-1 do
      begin
        ListItem := Items[i];
        vn       := TVersionNr(ListItem.Data);     // 0=Succ(Low(TversionNr)), etc
        if ListItem.Checked then
          result := result + [vn];
      end;
*)
end;

procedure TfrmDatabaseInfo.SetFilePath(const Value: string);
begin
  leFilePath.Text := Value;
end;

procedure TfrmDatabaseInfo.SetVersionNumbers(const Value: TVersionNumbers);
(*
var
  vn: TVersionNr;
  i: integer;
  ListItem: TListItem;
*)
begin
  Assert(false, 'No longer implemented');
(*
  with lvVersions do
    begin
      // Make sure the list contains the number of items that we expect
      Assert(Items.Count = ord(High(TVersionNr)) - ord(Low(TVersionNr)));
      for i := 0 to Items.Count-1 do
        begin
          ListItem      := Items[i];
          vn            := TVersionNr(ListItem.Data);
          ListItem.Checked := vn in Value;
        end;
    end;
*)
end;

procedure TfrmDatabaseInfo.btnBrowseFilePathClick(Sender: TObject);
var
  Lfn: string;
begin
  Lfn := leFilePath.Text;
  if BrowseForFile('Path to debugging database', Lfn, ACCDB_EXT) then
    leFilePath.Text := Lfn;
end;

(*
procedure TfrmDatabaseInfo.DoOnChange(Sender: TObject; ListItem: TListItem; Change: TItemChange);
begin
  lblVersionNumbers.Caption := 'Use for versions: ' + VersionNumbersString(TheVersionNumbers);
end;
*)

constructor TfrmDatabaseInfo.Create(aOwner: TComponent; VersionNr: TVersionNr);
var
  VersionNrStr: string;
  ListItem: TListItem;
begin
  inherited Create(aOwner);
  VersionNrStr         := VersionNrStrings[VersionNr].Abbrev;
  Caption := Format('Debugging Database Info for Version %s', [VersionNrStr]);
//with lvVersions do
//  begin
//    OnChange := DoOnChange;
//    for vn := Succ(Low(TVersionNr)) to High(TVersionNr) do
//      begin
//        ListItem := Items.Add;
//        ListItem.Caption := VersionNrStrings[vn].Abbrev;
//        ListItem.SubItems.Add(VersionNrStrings[vn].Name);
//        ListItem.Data    := pointer(vn);  // store the version number
//      end;
//  end;
end;

(*
procedure TfrmDatabaseInfo.ButtonBrowseTextBackupRootPathClick(Sender: TObject);
var
  Folder: string;
begin
  Folder := leTextBackupRootPath.Text;
  if BrowseForFolder('Path to text file backup root path', Folder) then
    leTextBackupRootPath.Text := Folder;
end;


function TfrmDatabaseInfo.GetTextBackupRootPath: string;
begin
  result := leRootDBTextBackup.Text;
end;

procedure TfrmDatabaseInfo.SetTextBackupRootPath(const Value: string);
begin
  leRootDBTextBackup.Text := Value;
end;


function TfrmDatabaseInfo.GetActive: boolean;
begin
  result := cbActive.Checked;
end;

procedure TfrmDatabaseInfo.SetActive(const Value: boolean);
begin
  cbActive.Checked := Value;
end;
*)

procedure TfrmDatabaseInfo.leFilePathExit(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDatabaseInfo.leTextBackupRootPathChange(Sender: TObject);
begin
  Enable_Buttons
end;

procedure TfrmDatabaseInfo.leTextBackupRootPathExit(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDatabaseInfo.leFilePathChange(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDatabaseInfo.Enable_Buttons;
begin
  btnOK.Enabled := FileExists(leFilePath.Text) {and FileExists(RemoveTrailingBackSlash(leTextBackupRootPath.Text))}
end;

(*
function TfrmDatabaseInfo.GetVersionNr: TVersionNr;
begin

end;

procedure TfrmDatabaseInfo.SetVersionNr(const Value: TVersionNr);
begin
  Caption := Format('Debugging Database Info for Version %s', []);
  leFilePath.EditLabel.Caption := Format('File Path to Debug Database for Version %s', []);
  leTextBackupRootPath.EditLabel.Caption := Format('Text Backup Root Path for Version', []);
end;
*)

end.
