unit RenameFile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmRenameFile = class(TForm)
    leOldFileName: TLabeledEdit;
    leNewFileName: TLabeledEdit;
    btnCancel: TButton;
    btnOk: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRenameFile: TfrmRenameFile;

implementation

{$R *.dfm}

end.
