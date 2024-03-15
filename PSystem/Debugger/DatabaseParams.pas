unit DatabaseParams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MyTables_Decl;

type
  TfrmDatabaseParams = class(TForm)
    leFileName: TLabeledEdit;
    btnBrowse: TButton;
    rgDatabaseVersion: TRadioGroup;
    btnCancel: TButton;
    btnOk: TButton;
    procedure btnBrowseClick(Sender: TObject);
  private
    function GetDBFileName: string;
    function GetDBVersion: TDBVersion;
    procedure SetDBFileName(const Value: string);
    procedure SetDBVersion(const Value: TDBVersion);
    { Private declarations }
  public
    { Public declarations }
    property DBFileName: string
             read GetDBFileName
             write SetDBFileName;
    property DBVersion: TDBVersion
             read GetDBVersion
             write SetDBVersion;
  end;

var
  frmDatabaseParams: TfrmDatabaseParams;

implementation

uses MyUtils;

{$R *.dfm}

{ TfrmDatabaseParams }

function TfrmDatabaseParams.GetDBFileName: string;
begin
  result := leFileName.Text;
end;

function TfrmDatabaseParams.GetDBVersion: TDBVersion;
begin
  with rgDatabaseVersion do
    case ItemIndex of
      0: result := dv_Access2000;
      1: result := dv_Access2007;
    else
      result := dv_Unknown;
    end;
end;

procedure TfrmDatabaseParams.SetDBFileName(const Value: string);
begin
  leFileName.Text := value;
end;

procedure TfrmDatabaseParams.SetDBVersion(const Value: TDBVersion);
begin
  with rgDatabaseVersion do
    case Value of
      dv_Access2000:
        ItemIndex := 0;
      dv_Access2007:
        ItemIndex := 1;
    end;
end;

procedure TfrmDatabaseParams.btnBrowseClick(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leFileName.Text;
  if BrowseForFile('Database File Name', FilePath, ACCDB_EXT) then
    begin
      leFileName.Text := FilePath;
    end;
end;

end.
