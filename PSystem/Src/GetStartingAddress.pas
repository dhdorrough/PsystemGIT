unit GetStartingAddress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmGetStartingAddress = class(TForm)
    leStartingAddress: TLabeledEdit;
    cbUseDecimalOffsets: TCheckBox;
    btnOk: TButton;
    btnCancel: TButton;
    rbAsAddress: TRadioButton;
    rbAsOffset: TRadioButton;
    leFormsToUse: TLabeledEdit;
  private
    function GetDisplayAsAddress: boolean;
    procedure SetDisplayAsAddress(const Value: boolean);
    function GetUseDecimalOffsets: boolean;
    procedure SetUseDecimalOffsets(const Value: boolean);
    function GetStartIngAddress: longword;
    procedure SetStartIngAddress(const Value: longword);
    function GetFormsToUse: string;
    procedure SetFormsToUse(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    property DisplayAsAddress: boolean
             read GetDisplayAsAddress
             write SetDisplayAsAddress;
    property UseDecimalOffsets: boolean
             read GetUseDecimalOffsets
             write SetUseDecimalOffsets;
    property StartIngAddress: longword
             read GetStartIngAddress
             write SetStartIngAddress;
    property FormsToUse: string
             read GetFormsToUse
             write SetFormsToUse;
  end;

var
  frmGetStartingAddress: TfrmGetStartingAddress;

implementation

uses Misc;

{$R *.dfm}

{ TfrmGetStartingAddress }

function TfrmGetStartingAddress.GetDisplayAsAddress: boolean;
begin
  result := rbAsAddress.Checked;
end;

function TfrmGetStartingAddress.GetFormsToUse: string;
begin
  result := leFormsToUse.Text;
end;

function TfrmGetStartingAddress.GetStartIngAddress: longword;
begin
  result := ReadInt(leStartingAddress.Text);
end;

function TfrmGetStartingAddress.GetUseDecimalOffsets: boolean;
begin
  result := cbUseDecimalOffsets.Checked;
end;

procedure TfrmGetStartingAddress.SetDisplayAsAddress(const Value: boolean);
begin
  rbAsAddress.Checked := value;
end;

procedure TfrmGetStartingAddress.SetFormsToUse(const Value: string);
begin
  leFormsToUse.text := Value;
end;

procedure TfrmGetStartingAddress.SetStartIngAddress(const Value: longword);
begin
  if UseDecimalOffsets then
    leStartIngAddress.text := IntToStr(Value)
  else
    leStartingAddress.Text := Format('$%4.4x', [Value]);
end;

procedure TfrmGetStartingAddress.SetUseDecimalOffsets(
  const Value: boolean);
begin
  cbUseDecimalOffsets.Checked := Value;
end;

end.
