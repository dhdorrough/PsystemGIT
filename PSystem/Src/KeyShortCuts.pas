unit KeyShortCuts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids;

type
  TfrmKeyShortCuts = class(TForm)
    KeyInfoGrid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmKeyShortCuts: TfrmKeyShortCuts;

implementation

uses FilerSettingsUnit, WindowsList;

{$R *.dfm}

procedure TfrmKeyShortCuts.FormShow(Sender: TObject);
var
  Dummy: integer;
begin
  with FilerSettings.WindowsList do
    LoadWindowInfo(self, WindowsType[wtKeyShortCuts], Dummy);
end;

procedure TfrmKeyShortCuts.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  FilerSettings.WindowsList.AddWindow(self, WindowsType[wtKeyShortCuts], 0);
  CanClose := true;
end;

procedure TfrmKeyShortCuts.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
