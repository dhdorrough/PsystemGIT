unit SelectVersion;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Interp_Const, Interp_Decl;

type
  TfrmSelectVersion = class(TForm)
    rgVersion: TRadioGroup;
    Label1: TLabel;
    btnOk: TButton;
    Button1: TButton;
    lblUnitNr: TLabel;
    lblVolumeName: TLabel;
  private
    function GetVersionNr: TVersionNr;
    procedure SetVersionNr(const Value: TVersionNr);
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
    property VersionNr: TVersionNr
             read GetVersionNr
             write SetVersionNr;
  end;

var
  frmSelectVersion: TfrmSelectVersion;

implementation

{$R *.dfm}

{ TfrmSelectVersion }

constructor TfrmSelectVersion.Create(aOwner: TComponent);
var
  vNr: TVersionNr;
begin
  inherited;

  with rgVersion do
    begin
      items.Clear;
      for vNr := Succ(vn_Unknown) to High(TVersionNr) do
        Items.AddObject(VersionNrStrings[vNr].Name, TObject(vNr));
    end;
end;

function TfrmSelectVersion.GetVersionNr: TVersionNr;
begin
  with rgVersion do
    begin
      if ItemIndex >= 0 then
        result := TVersionNr(Items.Objects[ItemIndex])
      else
        result := vn_Unknown;
    end;
end;

procedure TfrmSelectVersion.SetVersionNr(const Value: TVersionNr);
var
  idx: integer;
begin
  with rgVersion do
    begin
      Idx := Items.IndexOfObject(TObject(Value));
      if Idx >= 0 then
        ItemIndex := Idx;
    end;
end;

end.
