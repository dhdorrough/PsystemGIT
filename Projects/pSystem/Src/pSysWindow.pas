{$Define LogCalls}
unit pSysWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, UCSDGlob, MyUtils, CRTUnit, Menus, Interp_Const,
  CrtWindow;

type
  TOnKeyDown  = procedure {OnKeyDown}(Sender: TObject; var Key: Word; Shift: TShiftState) of object;
  TOnKeyPress = procedure {OnKeyPress}(Sender: TObject; var Key: Char) of object;
  TOnKeyUp    = procedure {OnKeyUp}(Sender: TObject; var Key: Word; Shift: TShiftState) of object;
//TWindowStatusProc = procedure {OnWindowChanged}() of object;
  TBreakKeyPressedEvent = procedure {OnBreakKeyPressed} () of object;

  TfrmPSysWindow = class(TfrmCrtWindow)
    Options1: TMenuItem;
    miTerminal: TMenuItem;
    DebugLogFile1: TMenuItem;
    N3: TMenuItem;
    DisplayShortCutKeys1: TMenuItem;
    procedure DebugLogFile1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure DisplayShortCutKeys1Click(Sender: TObject);
  private
    { Private declarations }

    fInputCount, fOutPutCount: longint;

    fOnKeyDown   : TOnKeyDown;
    fOnKeyPress  : TOnKeyPress;
    fOnKeyUp     : TOnKeyUp;
    fCheckBreak  : boolean;
    fVersionNr   : TVersionNr;
    fOnBreakKeyPressed: TBreakKeyPressedEvent;

    procedure SetTermType(Sender: TObject);
    procedure GuessTerminalType(Sender: TObject);
  protected
    fScreenBuf: array {0..MAXROWS-1} of string;
    procedure WMGetDlgCode(Var M: TWMGetDlgCode); message wm_getdlgcode;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }

    Constructor Create( aOwner: TComponent;
                        Heading: string;
                        aTop: integer;
                        aLeft: integer;
                        aVersionNr: TVersionNr = vn_Unknown;
                        aMaxRows: integer = DEFMAXROWS;
                        aMaxCols: integer = DEFMAXCOLS); reintroduce;
    procedure CrtInfoChanged(var TheCRTInfo: TCRTInfo); override;
    Destructor Destroy; override;
    procedure UcsdGotoXY(x,y:integer);
    procedure UnitClear;

    property OnBreakKeyPressed: TBreakKeyPressedEvent
             read fOnBreakKeyPressed
             write fOnBreakKeyPressed;
    property OnKeyDown: TOnKeyDown
             read fOnKeyDown
             write fOnKeyDown;
    property OnKeyUp: TOnKeyUp
             read fOnKeyUp
             write fOnKeyUp;
    property OnKeyPress: TOnKeyPress
             read fOnKeyPress
             write fOnKeyPress;
//  property OnWindowChanged: TWindowStatusProc
//           read fOnWindowChanged
//           write fOnWindowChanged;
    property CheckBreak: boolean
             read fCheckBreak
             write fCheckBreak;
  end;

implementation

{$R *.dfm}

uses
  Math, FilerSettingsUnit, WindowsList, pSysExceptions, StStrL, ClipBrd,
  KeyShortCuts;

{ TfrmPSysWindow }

constructor TfrmPSysWindow.Create( aOwner: TComponent;
                                    Heading: string;
                                    aTop: integer;
                                    aLeft: integer;
                                    aVersionNr: TVersionNr = vn_Unknown;
                                    aMaxRows: integer = DEFMAXROWS;
                                    aMaxCols: integer = DEFMAXCOLS);
var
  tt: TTermType;
  aMenuItem: TMenuItem;
begin
  inherited Create(aOwner, Heading, aTop, aLeft, aMaxRows, aMaxCols);
  fVersionNr  := aVersionNr;
  with miTerminal do
    begin
      aMenuItem := TMenuItem.Create(miTerminal);
      with aMenuItem do
        begin
          Caption    := 'Guess Terminal Type';
          OnClick    := GuessTerminalType;
          Default    := true;
        end;
      miTerminal.Add(aMenuItem);

      for tt := Succ(Low(TTermType)) to High(TTermType) do
        begin
          aMenuItem := TMenuItem.Create(miTerminal);
          with aMenuItem do
            begin
              Caption    := TermTypes[tt].Name;
              OnClick    := SetTermType;
              RadioItem  := true;
              Tag        := ord(tt);
            end;
          Add(aMenuItem);
        end;
      SortMenuItems(miTerminal, 1);
    end;
  fCrtInfo := DefaultCrtInfo;
  fKeyInfo := DefaultKeyInfo;
end;

procedure TfrmPSysWindow.SetTermType(Sender: TObject);
begin
  with Sender as TMenuItem do
    begin
      CrtInfo.TermType := TTermType(Tag);
      Checked := true;
    end;
end;

procedure TfrmPSysWindow.ucsdgotoxy(x, y: integer);
begin
  gotoxy(x,y);
end;

destructor TfrmPSysWindow.Destroy;
begin
  if Assigned(fCRTInfo) and Assigned(fOnSaveSettings) then
    fOnSaveSettings(self);
(* if present, I get calls to a freed object
  if Assigned(frmKeyShortCuts) then
    FreeAndNil(frmKeyShortCuts);
*)
  inherited;
end;

procedure TfrmPSysWindow.UnitClear;
begin
  fInputCount  := 0;
  fOutputCount := 0;
end;

(* Having these visible, even if disabled, can cause problems with key handling..
procedure TfrmPSysWindow.UpdateMenus;
var
  MenuItem: TMenuItem;
  ch: char;
  cf: TCrtFuncs;
begin
  FunctionKeys1.Clear;
  with KeyInfo do
    begin
      for ch := Low(Index) to High(Index) do
        begin
          cf    := Index[ch];
          if not (cf in [cf_Unknown, kf_LeadInFromKeyBoard]) then
            begin
              with CrtFuncInfo[cf] do
                begin
                  MenuItem := TMenuItem.Create(FunctionKeys1);
                  if ch = #27 then
                    MenuItem.ShortCut   := ShortCut(VK_ESCAPE, []) else
                  if ch in [#0..#31] then
                    MenuItem.ShortCut   := ShortCut(Word(ord(ch) + ord('A') - 1), [ssCtrl]) else
                  if ch = #127 then
                    MenuItem.ShortCut := ShortCut(vk_Delete, []) {else
                  if vk <> 0 then
                    MenuItem.ShortCut := ShortCut(vk, [])};

                  MenuItem.Caption    := FuncNames[cf].SN;
                  MenuItem.OnClick    := HandleFunctionKey;
                  MenuItem.Tag        := integer(cf);
                  MenuItem.Enabled    := false;
                  FunctionKeys1.Add(MenuItem);
                end;
            end;
        end;
    end;
end;
*)

(*
procedure TfrmPSysWindow.HandleFunctionKey(Sender: TObject);
begin
  with Sender as TMenuItem do
    begin
      PutPrefixed(TCRTFuncs(Tag));
    end;
end;
*)


procedure TfrmPSysWindow.CrtInfoChanged(var TheCRTInfo: TCRTInfo);
var
  Idx: integer;
begin
  with TheCRTInfo do
    begin
      if TheMaxRows <= MAXMAXROWS then
        MaxRows := TheMaxRows;

      for Idx := 0 to miTerminal.Count-1 do
        if miTerminal.Items[idx].Tag = ord(TermType) then
          begin
            miTerminal.Items[idx].Checked := true;
            break;
          end;
    end;
end;

procedure TfrmPSysWindow.GuessTerminalType(Sender: TObject);
begin
  CrtInfo.TermType := CrtInfo.GuessTerminalType;
  MessageFmt('Best guess is that the terminal expected is a %s', [TermTypes[CrtInfo.TermType].Name]);
  CrtInfoChanged(FCRTInfo);
end;

procedure TfrmPSysWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

procedure TfrmPSysWindow.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := CanCloseTheWindow;
  if CanClose then
    begin
      if Assigned(fOnSaveSettings) then
        fOnSaveSettings(self);
      FilerSettings.WindowsList.AddWindow(self, WindowsType[wtPSysWindow], 0);
    end
  else
    begin
      SysUtils.Beep;   // require Halt before allowing window to close
      Message('HALT the system first');
    end;
end;

procedure TfrmPSysWindow.FormShow(Sender: TObject);
var
  Dummy: integer;
begin
  inherited;
  with FilerSettings.WindowsList do
    LoadWindowInfo(self, WindowsType[wtPSysWindow], Dummy);
end;

procedure TfrmPSysWindow.Exit1Click(Sender: TObject);
begin
  inherited;
  Close;
end;


{ key codes }
procedure TfrmPSysWindow.WMGetDlgCode(var M: TWMGetDlgCode);
begin
	M.Result := DLGC_WantArrows or DLGC_WantChars or DLGC_WantAllKeys or DLGC_WantTab;
end;

procedure TfrmPSysWindow.DisplayShortCutKeys1Click(Sender: TObject);
const
  COL_CH       = 0;
  COL_FUNCNAME = 1;
  COL_SHORTCUT = 2;
var
  ShortCutName: string;
  ch: char;
  cf: TCrtFuncs;
  aShortCut: TShortCut;
  RowNum: integer;
  aChar: string;
  PossibleFuncs: set of TCrtFuncs;
(*
kf_LeadInFromKeyBoard, kf_BackSpace,       kf_KeyForStop,      kf_KeyForBreak,     kf_KeyForFlush,
kf_KeyToEndFile,       kf_EditorEscapeKey, kf_KeyToDeleteLine, kf_EditorAcceptKey, kf_KeyToDeleteCharacter,
kf_KeyToMoveCursorLeft, kf_KeyToMoveCursorRight, kf_KeyToMoveCursorUp, kf_KeyToMoveCursorDown,
kf_KeyToMoveToNextWord, kf_PageDown,    kf_PageUp  *)
begin
  inherited;
  if not Assigned(frmKeyShortCuts) then
    begin
      frmKeyShortCuts := TfrmKeyShortCuts.Create(self);
      frmKeyShortCuts.FreeNotification(self);
    end;

  case fVersionNr of  // PossibleFuncs really depends on the editor being used --
                      // not on the OS Version.
    vn_VersionI_4:
      PossibleFuncs := [kf_LeadInFromKeyBoard, kf_KeyForStop, kf_KeyForBreak, kf_KeyForFlush, kf_KeyToEndFile,
                        kf_EditorEscapeKey, kf_EditorAcceptKey, kf_KeyToMoveCursorLeft, kf_KeyToMoveCursorRight,
                        kf_KeyToMoveCursorUp, kf_KeyToMoveCursorDown, kf_PageDown,    kf_PageUp];
//  vn_VersionI_5:
//  vn_VersionII:
//  vn_VersionIV:
//  vn_VersionIV_12:
    else
      with KeyInfo do
        PossibleFuncs := [The_Low_Func .. The_High_Func];
  end;

  try
    frmKeyShortCuts.Show;
  finally
    with frmKeyShortCuts do
      with KeyInfo do
        begin
          RowNum := 0;
          with KeyInfoGrid do
            begin
              ColCount := 3;
              RowCount := 16;
              Cells[COL_CH,       RowNum] := 'Char';
              Cells[COL_FUNCNAME, RowNum] := 'FuncName';
              Cells[COL_SHORTCUT, RowNum] := 'ShortCut';
            end;

          for ch := Low(Index) to High(Index) do
            begin
              cf    := Index[ch];
              if (cf in PossibleFuncs) and (not (cf in [cf_Unknown, kf_LeadInFromKeyBoard])) then
                begin
                  with CrtFuncInfo[cf] do
                    begin
                      aShortCut := 0;
                      
                      if ch = #27 then
                        aShortCut   := ShortCut(VK_ESCAPE, []) else
                      if ch in [#0..#31] then
                        aShortCut   := ShortCut(Word(ord(ch) + ord('A') - 1), [ssCtrl]) else
//                    if ch = #127 then
//                      aShortCut := ShortCut(vk_Delete, []) else
                      if vk <> 0 then
                        aShortCut := ShortCut(vk, []);

                      ShortCutName := ShortCutToText(aShortCut);

                      if Pfxed then
                        aChar := Format('<#%d>%s', [ord(CRTFuncInfo[kf_LeadInFromKeyBoard].ch), CharName(ord(ch))])
                      else
                        aChar := CharName(ord(ch));

                      RowNum := RowNum + 1;
                      with KeyInfoGrid do
                        begin
                          Cells[COL_CH, RowNum]       := aChar;
                          Cells[COL_FUNCNAME, RowNum] := FuncNames[cf].SN;
                          Cells[COL_SHORTCUT, RowNum] := ShortCutName;
                        end;
                    end;
                end;
            end;
        end;

      with frmKeyShortCuts do
        AdjustColumnWidths(KeyInfoGrid, 30);
  end;
end;

procedure TfrmPSysWindow.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (aComponent = frmKeyShortCuts) then
    frmKeyShortCuts := nil;
end;

procedure TfrmPSysWindow.DebugLogFile1Click(Sender: TObject);
begin
  with DebugLogFile1 do
    begin
      Checked      := not Checked;
      DebugEnabled := Checked;
    end;
end;

initialization
end.
