unit GetHexAddress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmGetHexAddress = class(TForm)
    leStartingAddress: TLabeledEdit;
    btnOK: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGetHexAddress: TfrmGetHexAddress;

implementation

{$R *.dfm}

end.
