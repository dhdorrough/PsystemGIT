unit GetBlockParams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmBlockParams = class(TForm)
    leStartingBlock: TLabeledEdit;
    leNumberOfBlocks: TLabeledEdit;
    leDOSFilePathName: TLabeledEdit;
    btnCancel: TButton;
    btnBegin: TButton;
    btnBrowse: TButton;
    SaveDialog1: TSaveDialog;
    procedure btnBrowseClick(Sender: TObject);
  private
    fDOSFolderName: string;
    { Private declarations }
  public
    { Public declarations }
    property DOSFolderName: string
             read fDOSFolderName
             write fDOSFolderName;
  end;

var
  frmBlockParams: TfrmBlockParams;

implementation

{$R *.dfm}

procedure TfrmBlockParams.btnBrowseClick(Sender: TObject);
begin
  with SaveDialog1 do
    begin
      InitialDir := DOSFolderName;
      if Execute then
        leDOSFilePathName.Text := FileName;
    end;
end;

end.
