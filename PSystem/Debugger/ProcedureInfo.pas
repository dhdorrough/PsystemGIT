unit ProcedureInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, BuildDbDb, BuildDbDb_Decl;

type
  TfrmProcedureInfo = class(TForm)
    leSegmentName: TLabeledEdit;
    leProcedureName: TLabeledEdit;
    leProcedureNumber: TLabeledEdit;
    btnOK: TButton;
    btnCancel: TButton;
    leFullProcedureName: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure leFullProcedureNameChange(Sender: TObject);
  private
    fProcedureInfo : TProcedureInfo;
    function GetProcedureInfo: TProcedureInfo;
    procedure SetProcedureInfo(const Value: TProcedureInfo);
    { Private declarations }
  public
    { Public declarations }
    property ProcedureInfo: TProcedureInfo
             read GetProcedureInfo
             write SetProcedureInfo;
    Destructor Destroy; override;
  end;

var
  frmProcedureInfo: TfrmProcedureInfo;

implementation

uses PsysUnit;

{$R *.dfm}

{ TfrmProcedureInfo }

destructor TfrmProcedureInfo.Destroy;
begin
  inherited;
end;

function TfrmProcedureInfo.GetProcedureInfo: TProcedureInfo;
begin
  result := fProcedureInfo;
end;

procedure TfrmProcedureInfo.SetProcedureInfo(const Value: TProcedureInfo);
begin
  fProcedureInfo := Value;
end;

procedure TfrmProcedureInfo.FormShow(Sender: TObject);
begin
  leSegmentName.Text       := fProcedureInfo.xSegmentName;
  leProcedureNumber.Text   := IntTostr(fProcedureInfo.ProcedureNumber);
  leFullProcedureName.Text := fProcedureInfo.ProcedureNameFull;  // MUST precede ProcedureName
  leProcedureName.Text     := fProcedureInfo.ProcedureName;
end;

procedure TfrmProcedureInfo.btnOKClick(Sender: TObject);
begin
  fProcedureInfo.xSegmentName     :=   leSegmentName.Text;
  fProcedureInfo.ProcedureNumber  :=   StrToInt(leProcedureNumber.Text);
  fProcedureInfo.ProcedureNameFull :=  leFullProcedureName.Text;        
  fProcedureInfo.ProcedureName    :=   leProcedureName.Text;
end;

procedure TfrmProcedureInfo.leFullProcedureNameChange(Sender: TObject);
begin
  leProcedureName.Text := UCSDName(leFullProcedureName.Text);
end;

end.
