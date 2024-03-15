unit DecodeRange;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmDecodeRange = class(TForm)
    leStartingAddress: TLabeledEdit;
    leNrBytes: TLabeledEdit;
    btnOK: TButton;
    cbStopAfterRPU: TCheckBox;
    cbExitAfterDecode: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDecodeRange: TfrmDecodeRange;

implementation

{$R *.dfm}

end.
