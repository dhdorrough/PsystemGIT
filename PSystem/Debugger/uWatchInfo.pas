unit uWatchInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Debug_Decl, ovcbase, ovcef, ovcpb, ovcnf, ovcsf, Mask,
  ExtCtrls, Watch_Decl, DumpAddr;

type
  TfrmWatchInfo = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblWatchCode: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblHexVal: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblDescription: TLabel;
    cbWatchType: TComboBox;
    ovcWatchParam: TOvcNumericField;
    edtComment: TEdit;
    edtWatchName: TEdit;
    cbWatchAddress: TComboBox;
    cbFreeze: TCheckBox;
    cbWatchIndirect: TCheckBox;
    Label7: TLabel;
    procedure cbWatchTypeChange(Sender: TObject);
    procedure ovcWatchAddrChange(Sender: TObject);
    procedure edtCommentChange(Sender: TObject);
    procedure edtWatchAddrChange(Sender: TObject);
    procedure ovcWatchParamChange(Sender: TObject);
    procedure cbFreezeClick(Sender: TObject);
    procedure cbWatchIndirectClick(Sender: TObject);
  private
   { Private declarations }
    fInterpreter: TObject;
    fDebugger: TObject;
    fLastAddress: longword;
    fWatchName: string;
    fWatchValue: string;

    function GetWatchCode: TWatchCode;
    function GetWatchName: string;
    function GetWatchParam: longint;
    function GetWatchType: TWatchType;
    procedure SetWatchAddr(const Value: longword);
    procedure SetWatchCode(const Value: TWatchCode);
    procedure SetWATCHNAME(const Value: string);
    procedure SetWatchParam(const Value: longint);
    procedure SetWatchType(const Value: TWatchType);
    function GetWatchComment: string;
    procedure SetWatchComment(const Value: string);
    function GetWatchAddrExpr: string;
    procedure SetWatchAddrExpr(const Value: string);
    function GetWatchIndirect: boolean;
    procedure SetWatchIndirect(const Value: boolean);

  protected
    procedure UpdateStatusFmt(const aCaption: string;
      Args: array of const; aColor: TColor = clBtnFace);
    procedure UpdateStatus(const aCaption: string; aColor: TColor); virtual;
    procedure SetWatchValue(Value: string); virtual;
    function GetWatchValue: string; virtual;

  public
    { Public declarations }

    function GetWatchAddr: longword; virtual;
    procedure UpdateWatchNameAndValue; virtual;
    function WatchValue(Interpreter: TObject): string;

    Constructor Create(aOwner: TComponent; Interpreter: TObject; Debugger: TObject); reintroduce;

    property WatchType: TWatchType
             read GetWatchType
             write SetWatchType;
    property WatchCode: TWatchCode
             read GetWatchCode
             write SetWatchCode;
    property WatchName: string
             read GetWatchName
             write SetWatchName;
    property WatchAddr: longword
             read GetWatchAddr
             write SetWatchAddr;
    property WatchAddrExpr: string
             read GetWatchAddrExpr
             write SetWatchAddrExpr;
    property WatchParam: longint
             read GetWatchParam
             write SetWatchParam;
    property WatchComment: string
             read GetWatchComment
             write SetWatchComment;
    property WatchIndirect: boolean
             read GetWatchIndirect
             write SetWatchIndirect;
    property mmoWatchValue: string
             read GetWatchValue
             write SetWatchValue;
  end;

var
  frmWatchInfo: TfrmWatchInfo;

//function MemDumpParams(aOwner: TObject): TfrmDumpAddr;

implementation

uses
  MyUtils, Misc, InterpIV, pCodeDebugger,
  Interp_Decl, pCodeDebugger_Decl, Interp_Common, DebuggerSettingsUnit;

{$R *.dfm}

{ TfrmWatchInfo }

constructor TfrmWatchInfo.Create(aOwner: TComponent; Interpreter: TObject; Debugger: TObject);
var
  wt: TWatchType;
  ic: TIdentCode;
  LegalWatchTypes: TWatchTypesSet;
begin
  inherited Create(aOwner);
  fInterpreter := Interpreter;
  fDebugger    := Debugger;
  with fInterpreter as TCustomPsystemInterpreter, cbWatchType do
    begin
      LegalWatchTypes := GetLegalWatchTypes;
      for wt := Low(TWatchType) to High(TWatchType) do
        if wt in LegalWatchTypes then
          with WatchTypesTable[wt] do
            if WatchName <> '' then
              Items.AddObject(WatchName, TObject(wt));
    end;

  with cbWatchAddress do
    begin
      for ic := Low(TIdentCode) to High(TIdentCode) do
        with IdentCodeInfo[ic] do
          if Ident <> '' then
            Items.AddObject(Ident, TObject(ic));
    end;
end;

function TfrmWatchInfo.GetWatchAddr: longword;
var
  AddrExpr: string;
begin
  result := fLastAddress;

  if not cbFreeze.Checked then
    begin
      AddrExpr := cbWatchAddress.Text;
      try
        with frmPCodeDebugger do
          result       := WatchAddrFromExpression(AddrExpr);
        fLastAddress := result;
      except
        UpdateStatusFmt('Unknown Address Expression: "%s"', [AddrExpr], clYellow);
      end;
    end;
end;

function TfrmWatchInfo.GetWATCHCODE: TWatchCode;
begin
  result := WatchTypesTable[WatchType].WatchCode;
end;

function TfrmWatchInfo.GetWATCHNAME: string;
begin
  result := fWatchName;
end;

function TfrmWatchInfo.GetWatchParam: longint;
begin
  result := ovcWatchParam.AsInteger;
end;

function TfrmWatchInfo.GetWatchType: TWatchType;
begin
  result := wt_Unknown;
  with cbWatchType do
    begin
      if ItemIndex >= 0 then
        result := TWatchType(Items.Objects[ItemIndex])
//    else
//      SysUtils.Beep;
    end;
end;

procedure TfrmWatchInfo.SetWatchAddr(const Value: longword);
begin
  cbWatchAddress.Text := IntToStr(Value);
  lblHexVal.Caption := '$' + HexWord(Value);
end;

procedure TfrmWatchInfo.SetWatchCode(const Value: TWatchCode);
begin
//  with fDebugger as TfrmPCodeDebugger do
    WatchType := WatchTypeFromWatchCode(Value);
end;

procedure TfrmWatchInfo.SetWatchName(const Value: string);
begin
  fWatchName := Value;
end;

procedure TfrmWatchInfo.SetWatchParam(const Value: longint);
begin
  ovcWatchParam.AsInteger := Value;
end;

procedure TfrmWatchInfo.SetWatchType(const Value: TWatchType);
begin
  with cbWatchType do
    ItemIndex := Items.IndexOfObject(TObject(Value));
  cbWatchTypeChange(cbWatchType);
end;

procedure TfrmWatchInfo.UpdateWatchNameAndValue;
begin
  with fDebugger as TfrmPCodeDebugger do
    fWatchName              := Format('MemDumpDF(%s, ''%s'', %d)',
                                    [WatchAddrExpr,
                                     WatchCodeFromWatchType(WatchType),
                                     WatchParam]);
  edtWatchName.Text       := fWatchName;
  lblHexVal.Caption       := '$' + HexWord(WatchAddr);
  mmoWatchValue           := WatchValue(fInterpreter);
end;

procedure TfrmWatchInfo.cbWatchTypeChange(Sender: TObject);
begin
  with WatchTypesTable[WatchType] do
    begin
      lblWatchCode.Caption    := WatchCode;

//    if lblDescription.Caption = '' then
        lblDescription.Caption  := ParamMeaning;

      if edtComment.Text = '' then
        edtComment.Text         := WatchDescription;

      cbWatchType.Hint          := WatchDescription;
      lblDescription.Hint       := WatchDescription;
    end;
  UpdateWatchNameAndValue;
end;

function TfrmWatchInfo.GetWatchComment: string;
begin
  result := edtComment.Text;
end;

procedure TfrmWatchInfo.SetWatchComment(const Value: string);
begin
  edtComment.Text := Value;
end;

procedure TfrmWatchInfo.ovcWatchAddrChange(Sender: TObject);
begin
  lblHexVal.Caption     := '$' + HexWord(WatchAddr);
end;

procedure TfrmWatchInfo.edtCommentChange(Sender: TObject);
begin
//  UpdateWatchNameAndValue
end;

procedure TfrmWatchInfo.edtWatchAddrChange(Sender: TObject);
begin
  UpdateWatchNameAndValue;
end;

procedure TfrmWatchInfo.ovcWatchParamChange(Sender: TObject);
begin
  UpdateWatchNameAndValue;
end;

function TfrmWatchInfo.WatchValue(Interpreter: TObject): string;
begin
{$IfDef Debugging} { I do not know why this unit is getting compiled }
  with Interpreter as TCustomPsystemInterpreter do
    if cbWatchIndirect.Checked then
      result := MemDumpDW(WordAt[WatchAddr], WatchType, WatchParam)
    else
      result := MemDumpDW(WatchAddr, WatchType, WatchParam);
{$Else}
  result := '';
{$EndIf}
end;

function TfrmWatchInfo.GetWatchAddrExpr: string;
begin
  result := cbWatchAddress.Text;
end;

procedure TfrmWatchInfo.SetWatchAddrExpr(const Value: string);
begin
  cbWatchAddress.Text := Value;
end;

procedure TfrmWatchInfo.cbFreezeClick(Sender: TObject);
begin
  cbFreeze.Color := IIF(cbFreeze.Checked, clYellow, clBtnFace);
end;

(*
procedure TfrmWatchInfo.UpdateStatus(const aCaption: string; aColor: TColor);
begin
  lblStatus.Text := aCaption;
  lblStatus.Color   := aColor;
  Application.ProcessMessages;
end;
*)

procedure TfrmWatchInfo.UpdateStatusFmt(const aCaption: string;  Args: array of const; aColor: TColor);
begin
  UpdateStatus(Format(aCaption, Args), aColor);
end;

function TfrmWatchInfo.GetWatchIndirect: boolean;
begin
  result := cbWatchIndirect.Checked;
end;

procedure TfrmWatchInfo.SetWatchIndirect(const Value: boolean);
begin
  cbWatchIndirect.Checked := value;
end;

procedure TfrmWatchInfo.cbWatchIndirectClick(Sender: TObject);
begin
  mmoWatchValue := WatchValue(fInterpreter);
end;

function TfrmWatchInfo.GetWatchValue: string;
begin
  result := fWatchValue;
end;

procedure TfrmWatchInfo.SetWatchValue(Value: string);
begin
  fWatchValue := Value;
end;

procedure TfrmWatchInfo.UpdateStatus(const aCaption: string;
  aColor: TColor);
begin
  Label7.Caption := aCaption;
end;

end.
