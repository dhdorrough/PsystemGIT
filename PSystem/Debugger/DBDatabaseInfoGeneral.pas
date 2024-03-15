unit DBDatabaseInfoGeneral;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Interp_Decl, Interp_Const, ComCtrls;

type
  TfrmDatabaseInfoGeneral = class(TForm)
    leFilePath: TLabeledEdit;
    btnBrowseFilePath: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    RadioGroup1: TRadioGroup;
    procedure btnBrowseFilePathClick(Sender: TObject);
    procedure leFilePathExit(Sender: TObject);
    procedure leTextBackupRootPathChange(Sender: TObject);
    procedure leTextBackupRootPathExit(Sender: TObject);
    procedure leFilePathChange(Sender: TObject);
  private
    function GetVersionNumbers: TVersionNumbers;
    function GetFilePath: string;
    procedure SetFilePath(const Value: string);
    procedure Enable_Buttons;
    function GetVersionNr: TVersionNr;
    procedure SetVersionNr(const Value: TVersionNr);
    { Private declarations }
  public
    { Public declarations }
    property FilePath: string
             read GetFilePath
             write SetFilePath;
    property VersionNr: TVersionNr
             read GetVersionNr
             write SetVersionNr;
    Constructor Create(aOwner: TComponent); reintroduce;
  end;

var
  frmDatabaseInfoGeneral: TfrmDatabaseInfoGeneral;

implementation

uses MyUtils, MyTables_Decl
{$IfDef debugging}
     , DebuggerSettingsUnit
{$EndIf debugging}
     ;

{$R *.dfm}

function TfrmDatabaseInfoGeneral.GetFilePath: string;
begin
  result := leFilePath.Text;
end;

function TfrmDatabaseInfoGeneral.GetVersionNumbers: TVersionNumbers;
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

procedure TfrmDatabaseInfoGeneral.SetFilePath(const Value: string);
begin
  leFilePath.Text := Value;
end;

procedure TfrmDatabaseInfoGeneral.btnBrowseFilePathClick(Sender: TObject);
var
  Lfn: string;
begin
  Lfn := leFilePath.Text;
  if BrowseForFile('Path to debugging database', Lfn, ACCDB_EXT) then
    leFilePath.Text := Lfn;
end;

constructor TfrmDatabaseInfoGeneral.Create(aOwner: TComponent);
var
  VersionNrStr: string;
  ListItem: TListItem;
  vn: TVersionNr;
begin
  inherited Create(aOwner);
  for vn := Succ(Low(TVersionNr)) to High(TVersionNr) do
    if not (vn in BADVERSIONS) then
      RadioGroup1.Items.AddObject(VersionNrStrings[vn].Name, TObject(vn));
(*
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
*)
end;

procedure TfrmDatabaseInfoGeneral.leFilePathExit(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDatabaseInfoGeneral.leTextBackupRootPathChange(Sender: TObject);
begin
  Enable_Buttons
end;

procedure TfrmDatabaseInfoGeneral.leTextBackupRootPathExit(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDatabaseInfoGeneral.leFilePathChange(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmDatabaseInfoGeneral.Enable_Buttons;
begin
  btnOK.Enabled := FileExists(leFilePath.Text) {and FileExists(RemoveTrailingBackSlash(leTextBackupRootPath.Text))}
end;

function TfrmDatabaseInfoGeneral.GetVersionNr: TVersionNr;
begin
  with RadioGroup1 do
    if ItemIndex >= 0 then
      result := TVersionNr(Items.Objects[ItemIndex])
    else
      result := vn_Unknown;
end;

procedure TfrmDatabaseInfoGeneral.SetVersionNr(const Value: TVersionNr);
var
  Idx: integer;
begin
  Caption := Format('Debugging Database Info for Version %s', [VersionNrStrings[Value].Abbrev]);
  with RadioGroup1 do
    begin
      idx := Items.IndexOfObject(TObject(Value));
      if Idx >= 0 then
        ItemIndex := Idx
      else
        ItemIndex := 0;
    end;
end;

end.
