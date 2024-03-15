unit BreakPointInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf, InterpIV, Debug_Decl,
  ExtCtrls, Watch_Decl, Interp_Decl, Interp_Common, DebuggerSettingsUnit;

type
  integer = SmallInt;
  
  TfrmBreakPointInfo = class(TForm)
    btnOk: TButton;
    Button1: TButton;
    cbDisabled: TCheckBox;
    cbLogMessage: TCheckBox;
    cbDoNotBreak: TCheckBox;
    pnlParam: TPanel;
    ovcParam: TOvcNumericField;
    lblParam: TLabel;
    pnlProcBreak: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    lblProcName: TLabel;
    Label1: TLabel;
    Label6: TLabel;
    cbSegName: TComboBox;
    ovcProcNr: TOvcNumericField;
    cbProcName: TComboBox;
    ovcIPC: TOvcNumericField;
    Label4: TLabel;
    cbBreakKind: TComboBox;
    lePassCount: TLabeledEdit;
    cbLogToAFile: TCheckBox;
    btnSpecifyLogFileName: TButton;
    lblLogFileName: TLabel;
    pnlWatchInfo: TPanel;
    Label8: TLabel;
    cbWatchAddress: TComboBox;
    lblHexVal: TLabel;
    cbIndirect: TCheckBox;
    leNrBytes: TLabeledEdit;
    cbWatchType: TComboBox;
    lblDisplayAs: TLabel;
    Label5: TLabel;
    edtComment: TEdit;
    procedure ovcProcNrAfterExit(Sender: TObject);
    procedure cbProcNameExit(Sender: TObject);
    procedure cbSegNameChange(Sender: TObject);
    procedure cbBreakKindChange(Sender: TObject);
    procedure cbLogMessageClick(Sender: TObject);
    procedure cbSegNameDropDown(Sender: TObject);
    procedure cbWatchTypeChange(Sender: TObject);
    procedure leLowAddrChange(Sender: TObject);
    procedure cbWatchAddressChange(Sender: TObject);
    procedure cbLogToAFileClick(Sender: TObject);
    procedure btnSpecifyLogFileNameClick(Sender: TObject);
    procedure cbDisabledClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    fLogFileName: string;
    procedure RepopulateProcNames(Value: TSegNameIdx);
//  function GetWatchAddr: longword;
    function GetAddrExpr: string;
    procedure SetAddrExpr(const Value: string);
    procedure SetLogFileName(const Value: string);
  private
    fBrkNr: word;
    fInterpreter: TCustomPSystemInterpreter;
    fDEBUGGERSettings: TDEBUGGERSettings;

    function GetBreakKind: TBrk;
    function GetBrkNr: word;
    function GetProcNum: integer;
    function GetSegName: string;
    procedure SetBreakKind(const Value: TBrk);
    procedure SetBrkNr(const Value: word);
    procedure SetSegName(const Value: string);
    procedure SetProcNum(const Value: integer);
    function GetProcName: string;
    procedure SetProcName(const Value: string);
    function GetSegIdx: TSegNameIdx;
    procedure SetSegIdx(const Value: TSegNameIdx);
    function GetIPC: integer;
    procedure SetIPC(const Value: integer);
    function GetCmt: string;
    procedure SetCmt(const Value: string);
    function GetLowAddr: longword;
    function GetNrBytes: word;
    procedure SetNrBytes(const Value: word);
    procedure Enable_Stuff;
    function GetWatchType: TWatchType;
    procedure SetWatchType(const Value: TWatchType);
    function GetPassCount: longint;
    procedure SetPathCount(const Value: longint);
    function GetDisabled: boolean;
    procedure SetDisabled(const Value: boolean);
    function GetLogMessage: boolean;
    procedure SetLogMessage(const Value: boolean);
    function GetDoNotBreak: boolean;
    procedure SetDoNotBreak(const Value: boolean);
    function GetIndirect: boolean;
    procedure SetIndirect(const Value: boolean);
    function GetParam: longword;
    procedure SetParam(const Value: longword);
    function GetLogToAFile: boolean;
    procedure SetLogToAFile(const Value: boolean);
    procedure SetNewProcNum(NewProcNr: integer);
    procedure BuildSegnameList;
    { Private declarations }
  public
    { Public declarations }
    property BrkNr: word
             read GetBrkNr
             write SetBrkNr;
    property SegName: string
             read GetSegName
             write SetSegName;
    property SegIdx: TSegNameIdx
             read GetSegIdx
             write SetSegIdx;
    property ProcNum: integer
             read GetProcNum
             write SetProcNum;
    property ProcName: string
             read GetProcName
             write SetProcName;
    property BreakKind: TBrk
             read GetBreakKind
             write SetBreakKind;
    property TheIPC: integer
             read GetIPC
             write SetIPC;
    property Cmt: string
             read GetCmt
             write SetCmt;
    property LowAddr: longword
             read GetLowAddr{
             write SetLowAddr};
    property NrBytes: word
             read GetNrBytes
             write SetNrBytes;
    property WatchType: TWatchType
             read GetWatchType
             write SetWatchType
             default wt_Unknown;
    property PassCount: longint
             read GetPassCount
             write SetPathCount;
    property Disabled: boolean
             read GetDisabled
             write SetDisabled
             default false;
    property LogMessage: boolean
             read GetLogMessage
             write SetLogMessage;
    property DoNotBreak: boolean
             read GetDoNotBreak
             write SetDoNotBreak;
    property Indirect: boolean
             read GetIndirect
             write SetIndirect;
    property Param: longword
             read GetParam
             write SetParam;
    property LogToAFile: boolean
             read GetLogToAFile
             write SetLogToAFile;
    property AddrExpr: string
             read GetAddrExpr
             write SetAddrExpr;
    property LogFileName: string
             read fLogFileName
             write SetLogFileName;
    Constructor Create(aOwner: TComponent; aInterpreter: TObject; DEBUGGERSettings: TDEBUGGERSettings); reintroduce;
  end;

var
  frmBreakPointInfo: TfrmBreakPointInfo;

implementation

uses pCodeDebugger, Misc, MyUtils, {FilerSettingsUnit,}
  pCodeDebugger_Decl{, DEBUGGERSettingsUnit}, PsysUnit, FileNames;

{$R *.dfm}

{ TfrmBreakPointInfo }

procedure TfrmBreakPointInfo.BuildSegnameList;
var
  SegNameIdx: TSegNameIdx;
begin
  with cbSegName do
    begin
      Items.Clear;
      Items.AddObject('-ANY SEGMENT-', TObject(sn_Unknown));
      if (SegNamesInDB.Count > 0) then
        for SegNameIdx := 0 to SegNamesInDB.Count-1 do
          if SegNamesInDB.Strings[SegNameIdx] <> '' then
            Items.AddObject(SegNamesInDB.Strings[SegNameIdx], TObject(SegNameIdx));
    end;
  cbProcName.Items.Clear;
end;


Constructor TfrmBreakPointInfo.Create(aOwner: TComponent; aInterpreter: TObject; DEBUGGERSettings: TDEBUGGERSettings);
var
  Brk: TBrk;
  wt: TWatchType;
  ic: TIdentCode;
begin
  inherited Create(aOwner);

  fInterpreter      := aInterpreter as TCustomPsystemInterpreter;
  fDEBUGGERSettings := DEBUGGERSettings;

  for Brk := Low(TBrk) to High(TBrk) do
    if BreakKinds[Brk].UserSettable then
      cbBreakKind.Items.AddObject(BreakKinds[Brk].BreakName, TObject(Brk));

  BuildSegnameList;

  with fInterpreter, cbWatchType do
    begin
      Clear;
      for wt := Low(TWatchType) to High(TWatchType) do
        if wt in LEGAL_WATCHTYPES_FOR_INTERPRETER then
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

  Enable_Stuff;
end;

(*
function TfrmBreakPointInfo.GetWatchAddr: longword;
var
  AddrExpr: string;
begin
  result := fLastAddress;

  AddrExpr := cbWatchAddress.Text;
  with frmPCodeDebugger do
    try
      result       := WatchAddrFromExpression(AddrExpr);
      fLastAddress := result;
    except
//    UpdateStatusFmt('Unknown Address Expression: "%s"', [AddrExpr], clYellow);
      MessageFmt('Unknown Address Expression: "%s"', [AddrExpr]);
    end;
end;
*)

function TfrmBreakPointInfo.GetBreakKind: TBrk;
begin
  with cbBreakKind do
    if ItemIndex >= 0 then
      result := TBrk(Items.Objects[ItemIndex])
    else
      result := dbUnknown;
end;

function TfrmBreakPointInfo.GetBrkNr: word;
begin
  result := fBrkNr;
end;

function TfrmBreakPointInfo.GetProcName: string;
begin
  with cbProcName do
    result := Items[ItemIndex];
end;

function TfrmBreakPointInfo.GetProcNum: integer;
begin
  result := ovcProcNr.AsInteger;
end;

function TfrmBreakPointInfo.GetSegName: string;
begin
  result := cbSegName.Text;
end;

procedure TfrmBreakPointInfo.SetBreakKind(const Value: TBrk);
begin
  with cbBreakKind do
    ItemIndex := Items.IndexOfObject(TObject(Value));
  Enable_Stuff;
end;

procedure TfrmBreakPointInfo.SetBrkNr(const Value: word);
begin
  fBrkNr := Value;
  Caption := Format('BreakPoint #%d Info', [Value]);
end;

procedure TfrmBreakPointInfo.SetSegName(const Value: string);
var
  Idx: integer;
begin
  cbSegName.Text := Value;
  with cbSegName do
    begin
      Idx := Items.IndexOf(Value);
      if Idx >= 0 then
        SegIdx := TSegNameIdx(Items.Objects[Idx]);  
    end;
end;

procedure TfrmBreakPointInfo.SetProcName(const Value: string);
begin
  cbProcName.Text := Value;
end;

procedure TfrmBreakPointInfo.SetProcNum(const Value: integer);
begin
  ovcProcNr.AsInteger := Value;
  SetNewProcNum(Value);
end;

function TfrmBreakPointInfo.GetSegIdx: TSegNameIdx;
var
  Idx: integer;
begin
  with cbSegName do
    begin
      Idx := ItemIndex;
      if Idx >= 0 then
        result := TSegNameIdx(Items.Objects[ItemIndex])
      else
        result := sn_Unknown;
    end;
end;

procedure TfrmBreakPointInfo.RepopulateProcNames(Value: TSegNameIdx);
var
  i, sn: integer;
begin
  with cbSegName do
    begin
      if Value > sn_Unknown then
        begin
          ItemIndex := Items.IndexOfObject(TObject(Value));
          with cbProcName do
            begin
              Clear;
              Items.AddObject('-ANY PROC-', TObject(ANYPROC)); // Allow for break on ANY procedure
              Items.AddObject('-ANY UNSEEN PROC-', TObject(ANYUNSEEN)); // Allow for break on ANY procedure

              for i := 1 to MAXPROCNAME do
                if ProcNamesInDB[Value, i] <> '' then
                  Items.AddObject(ProcNamesInDB[Value, i], TObject(i));
            end;
        end
      else
        begin
          with cbProcName do
            begin
              Clear;
              Items.AddObject('-ANY PROC-', TObject(ANYPROC)); // Allow for break on ANY procedure
              Items.AddObject('-ANY UNSEEN PROC-', TObject(ANYUNSEEN)); // Allow for break on ANY procedure
              for sn := 0 { was:Succ(sn_Unknown)} to SegNamesInDB.Count-1 do
                begin
                 for i := 1 to MAXPROCNAME DO
                    if ProcNamesInDB[sn, i] <> '' then
                      Items.AddObject(Format('%s {%s}', [ProcNamesInDB[sn, i],
                                                         SegNamesInDB[sn]]), TObject(i));
                end;
            end;
        end;
    end;
  ovcProcNrAfterExit(nil);  // force the procedure name to be updated
end;


procedure TfrmBreakPointInfo.SetSegIdx(const Value: TSegNameIdx);
begin
  RepopulateProcNames(Value);
end;

procedure TfrmBreakPointInfo.SetNewProcNum(NewProcNr: integer);
var
  Idx : integer;
begin
  with cbProcName do
    begin
      Idx       := NewProcNr;
      ItemIndex := Items.IndexOfObject(TObject(Idx));
    end;
end;


procedure TfrmBreakPointInfo.ovcProcNrAfterExit(Sender: TObject);
begin
  SetNewProcNum(ovcProcNr.AsInteger);
end;

function TfrmBreakPointInfo.GetIPC: integer;
begin
{$R-}
  result := ovcIPC.AsInteger;
{$R+}
end;

procedure TfrmBreakPointInfo.SetIPC(const Value: integer);
begin
  ovcIPC.AsInteger := integer(Value);
end;

procedure TfrmBreakPointInfo.cbProcNameExit(Sender: TObject);
var
  FullProcName: string;
  lb, rb: integer;
  SegIdx: TSegNameIdx;
begin
  with cbProcName do
    begin
      if ItemIndex >= 0 then
        begin
          ovcProcNr.AsInteger := Integer(Items.Objects[ItemIndex]);
          FullProcName        := Items[ItemIndex];
          with cbSegName do
            begin
              if TSegNameIdx(Items.Objects[ItemIndex]) = sn_Unknown then
                begin  // e.g., format is "ProcName {SegName}"
                  lb := Pos('{', FullProcName);
                  if lb > 0 then
                    begin
                      rb := Pos('}', FullProcName);
                      if rb > lb then
                        begin
                          SegName   := Copy(FullProcName, lb+1, rb-lb-1); // just the segment name part
                          with frmPCodeDebugger do
                            SegIdx := SegIdxFromName(SegName);
                          ItemIndex := cbSegName.Items.IndexOfObject(TObject(SegIdx));
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

procedure TfrmBreakPointInfo.cbSegNameChange(Sender: TObject);
begin
  with cbSegName do
    if ItemIndex >= 0 then
      SegIdx := TSegNameIdx(Items.Objects[ItemIndex]);
//  ovcProcNrAfterExit(nil);  // force the procedure name to be updated
end;

function TfrmBreakPointInfo.GetCmt: string;
begin
  result := edtComment.Text;
end;

procedure TfrmBreakPointInfo.SetCmt(const Value: string);
begin
  edtComment.Text := value;
end;

procedure TfrmBreakPointInfo.Enable_Stuff;
var
  HasParam, b, bk, wt: boolean;
begin
  bk               := BreakKinds[BreakKind].HasParam;
  wt               := WatchTypesTable[WatchType].ParamMeaning <> '';
  HasParam         := bk or wt;
  pnlParam.Visible := HasParam;

  leNrBytes.Visible := false;

  case BreakKind of
    dbDbgCnt,
    dbOpcode:
      begin
        cbWatchAddress.Visible := false;
        lblDisplayAs.Visible   := false;
        cbWatchType.Visible    := false;
        pnlProcBreak.Visible   := false;
        pnlWatchInfo.Visible   := false;
        lblParam.Caption       := BreakKinds[BreakKind].BreakName;
        cbIndirect.Visible     := false;
      end;
    dbMemChanged:
      begin
        leNrBytes.Visible      := true;
        pnlProcBreak.Visible   := false;
        pnlWatchInfo.Visible   := true;
      end
    else
      begin
        cbWatchAddress.Visible := true;
        lblDisplayAs.Visible   := true;

        cbWatchType.Visible    := true;
        pnlProcBreak.Visible   := BreakKind <> dbMemChanged;
      end
  end;
  cbLogToAFile.Enabled := cbLogMessage.Checked;

  lblHexVal.Caption := Format('$%4.4x', [LowAddr]);

  if wt then        // ugly-- I know... The ovcParam field is overloaded.
    with WatchTypesTable[WatchType] do
      begin
        lblParam.Caption  := ParamMeaning;
        pnlParam.Hint     := WatchDescription;
        cbWatchType.Hint  := WatchDescription;
      end;

  lblLogFileName.Caption := fLogFileName;

  cbLogToAFile.Visible   := cbLogMessage.Checked;

  b := cbLogMessage.Checked and cbLogToAFile.Checked;
  btnSpecifyLogFileName.Visible := b;
  lblLogFileName.Visible        := b;

  cbDisabled.Color := IIF(cbDisabled.Checked, clYellow, clBtnFace);
end;


procedure TfrmBreakPointInfo.cbBreakKindChange(Sender: TObject);
begin
  if BreakKind in [dbBreakOnCall, dbMemChanged, dbOpcode] then
    begin
      SegName := '';
      ProcNum := 0;
      Param   := 0;
    end;
  Enable_Stuff;
end;

function TfrmBreakPointInfo.GetLowAddr: longword;
begin
  with frmPCodeDebugger do
    result := WatchAddrFromExpression(cbWatchAddress.Text);
end;

function TfrmBreakPointInfo.GetNrBytes: word;
begin
  result := ReadInt(leNrBytes.Text);
end;

(*
procedure TfrmBreakPointInfo.SetLowAddr(const Value: longword);
begin
  cbWatchAddress.Text := '$' + HexWord(Value);
end;
*)

procedure TfrmBreakPointInfo.SetNrBytes(const Value: word);
begin
  leNrBytes.Text := IntToStr(value);
end;

function TfrmBreakPointInfo.GetWatchType: TWatchType;
var
  Idx : integer;
begin
  result := wt_Unknown;
  with cbWatchType do
    begin
      idx := ItemIndex;
      if Idx >= 0 then
        result := TWatchType(Items.Objects[Idx]);
    end;
end;

procedure TfrmBreakPointInfo.SetWatchType(const Value: TWatchType);
begin
  with cbWatchType do
    ItemIndex := Items.IndexOfObject(TObject(Value));
  cbWatchTypeChange(cbWatchType);
end;

function TfrmBreakPointInfo.GetPassCount: longint;
begin
  try
    result := StrToInt(lePassCount.Text);
  except
    AlertFmt('Invalid pass count: %s', [lePassCount.Text]);
    result := 0;
  end;
end;

procedure TfrmBreakPointInfo.SetPathCount(const Value: longint);
begin
  lePassCount.Text := IntTostr(Value);
end;

function TfrmBreakPointInfo.GetDisabled: boolean;
begin
  result := cbDisabled.Checked;
end;

procedure TfrmBreakPointInfo.SetDisabled(const Value: boolean);
begin
  cbDisabled.Checked := value;
end;

function TfrmBreakPointInfo.GetLogMessage: boolean;
begin
  result := cbLogMessage.Checked;
end;

procedure TfrmBreakPointInfo.SetLogMessage(const Value: boolean);
begin
  cbLogMessage.Checked := Value;
end;

procedure TfrmBreakPointInfo.cbLogMessageClick(Sender: TObject);
begin
  Enable_Stuff;
end;

function TfrmBreakPointInfo.GetDoNotBreak: boolean;
begin
  result := cbDoNotBreak.Checked;
end;

procedure TfrmBreakPointInfo.SetDoNotBreak(const Value: boolean);
begin
  cbDoNotBreak.Checked := Value;
end;

function TfrmBreakPointInfo.GetIndirect: boolean;
begin
  result := cbIndirect.Checked;
end;

procedure TfrmBreakPointInfo.SetIndirect(const Value: boolean);
begin
  cbIndirect.Checked := Value;
end;

function TfrmBreakPointInfo.GetParam: longword;
begin
  result := ovcParam.AsVariant;
end;

procedure TfrmBreakPointInfo.SetParam(const Value: longword);
begin
  ovcParam.AsInteger := Value;
end;

function TfrmBreakPointInfo.GetLogToAFile: boolean;
begin
  result := cbLogToAFile.Checked;
end;

procedure TfrmBreakPointInfo.SetLogToAFile(const Value: boolean);
begin
  cbLogToAFile.Checked := Value;
end;

procedure TfrmBreakPointInfo.cbSegNameDropDown(Sender: TObject);
begin
  BuildSegnameList;
end;

procedure TfrmBreakPointInfo.cbWatchTypeChange(Sender: TObject);
begin
  Enable_Stuff;
end;

procedure TfrmBreakPointInfo.leLowAddrChange(Sender: TObject);
begin
  lblHexVal.Caption := Format('$%4.4x', [LowAddr]);
end;

procedure TfrmBreakPointInfo.cbWatchAddressChange(Sender: TObject);
var
  AddrExpr : string;
begin
  AddrExpr := cbWatchAddress.Text;
  with frmPCodeDebugger do
    lblHexVal.Caption := Hexword(WatchAddrFromExpression(AddrExpr));
end;

function TfrmBreakPointInfo.GetAddrExpr: string;
begin
  result := cbWatchAddress.Text;
end;

procedure TfrmBreakPointInfo.SetAddrExpr(const Value: string);
begin
  cbWatchAddress.Text := Value;
end;

procedure TfrmBreakPointInfo.cbLogToAFileClick(Sender: TObject);
begin
  Enable_Stuff;
end;

procedure TfrmBreakPointInfo.btnSpecifyLogFileNameClick(Sender: TObject);
var
  aLogFileName: string;
begin
  aLogFileName := fLogFileName;
  if BrowseForFile('Log File Name', aLogFileName, CSV_EXT) then
    begin
      fLogFileName := aLogFileName;
      Enable_Stuff;
    end;
end;

procedure TfrmBreakPointInfo.SetLogFileName(const Value: string);
begin
  fLogFileName := Value;
  lblLogFileName.Caption := Value;
end;

procedure TfrmBreakPointInfo.cbDisabledClick(Sender: TObject);
begin
  Enable_Stuff;
end;

procedure TfrmBreakPointInfo.btnOkClick(Sender: TObject);
begin
  if (BreakKind = dbMemChanged) and (NrBytes = 0) then
    begin
      Alert('Param may not be 0 for memory changed break');
      SysUtils.Abort;
    end;
end;

end.
