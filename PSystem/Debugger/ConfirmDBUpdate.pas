unit ConfirmDBUpdate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, YesNoDontAskAgain, StdCtrls, ExtCtrls, OverWrite_Decl, BuildDbDb,
  BuildDbDb_Decl;

type
  TfrmUpdateConfirm = class(TfrmYesNoDontAskAgain)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    MemoPCode: TMemo;
    MemoSrcCode: TMemo;
    btnEnterProcedureInfo: TButton;
    procedure btnEnterProcedureInfoClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    fSegName: string;
    fProcedureInfo: TProcedureInfo;
    { Private declarations }
  public
    { Public declarations }
    function OkToOverWriteWhat(const What: string;
                                     OverWriteOptions: TOverWriteOptions;
                               const pCode, SrcCode: string;
                                   RecordFound: boolean;
                               ProcedureInfo: TProcedureInfo): boolean;
    property SegName: string
             read fSegName
             write fSegName;
  end;

var
  frmUpdateConfirm: TfrmUpdateConfirm;

implementation

uses MyUtils, uGetString, ProcedureInfo;

{$R *.dfm}

{ TfrmUpdateConfirm }

function TfrmUpdateConfirm.OkToOverWriteWhat(const What: string;
                                                   OverWriteOptions: TOverWriteOptions;
                                             const pCode, SrcCode: string;
                                             RecordFound: boolean;
                                             ProcedureInfo: TProcedureInfo): boolean;

  procedure ScrollToLastLine(Memo: TMemo);
  begin
    SendMessage(Memo.Handle, EM_LINESCROLL, 0,Memo.Lines.Count);
  end;

begin
  fProcedureInfo := ProcedureInfo;
  MemoPCode.Text := pCode;
  ScrollToLastLine(MemoPCode);
  MemoSrcCode.Text := SrcCode;
  ScrollToLastLine(MemoSrcCode);
  btnNoAndDontAskAgain.Caption  := Format('No to all procedures in segment %s?', [SegName]);
  btnYesAndDontAskAgain.Caption := Format('Yes to all procedures in segment %s?', [SegName]);
  result     := OkToOverWrite(What, OverWriteOptions);
end;

procedure TfrmUpdateConfirm.btnEnterProcedureInfoClick(Sender: TObject);
begin
  inherited;
  frmProcedureInfo.ProcedureInfo := fProcedureInfo;
  if frmProcedureInfo.ShowModal = mrOk then
    fProcedureInfo := frmProcedureInfo.ProcedureInfo;
end;

procedure TfrmUpdateConfirm.FormResize(Sender: TObject);
begin
  inherited;
  Panel2.Width := Panel1.Width div 2;
end;

end.
