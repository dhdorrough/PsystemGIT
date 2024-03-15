unit SegmenProcname;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf;

type
  TfrmSegmentProcName = class(TForm)
    cbSegName: TComboBox;
    ovcProcNr: TOvcNumericField;
    cbProcName: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    lblProcName: TLabel;
    btnOk: TButton;
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSegmentProcName: TfrmSegmentProcName;

implementation

{$R *.dfm}

end.
