unit DumpAddr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmDumpAddr = class(TForm)
    lblAddressX: TLabel;
    cbWatchAddress: TEdit;
    lblHexVal: TLabel;
    btnOK: TButton;
    Cancel: TButton;
    lblHex: TLabel;
    procedure cbWatchAddressChange(Sender: TObject);
  private
    function GetWatchAddr: longword;
    procedure SetWatchAddr(const Value: longword);
    function WatchAddrFromExpression(AddrExpr: string): longword;
    { Private declarations }
  public
    { Public declarations }
    property WatchAddr: longword
             read GetWatchAddr
             write SetWatchAddr;
  end;

var
  frmDumpAddr: TfrmDumpAddr;

implementation

uses Misc, MyUtils;

{$R *.dfm}

{ TfrmDumpAddr }

function TfrmDumpAddr.WatchAddrFromExpression(AddrExpr: string): longword;
begin
  result := 0;
  if Length(AddrExpr) > 0 then
    if AddrExpr[1] = '$' then
      result := ReadInt(AddrExpr) else
    if IsPureNumeric(AddrExpr) then
      result := StrToInt(AddrExpr) else
end;

function TfrmDumpAddr.GetWatchAddr: longword;
begin
  result := WatchAddrFromExpression(cbWatchAddress.Text);
end;

procedure TfrmDumpAddr.SetWatchAddr(const Value: longword);
begin
  cbWatchAddress.Text := IntToStr(Value);
end;

procedure TfrmDumpAddr.cbWatchAddressChange(Sender: TObject);
begin
  lblHex.Caption := Format('$%-4.4x', [WatchAddr]);
end;

end.
