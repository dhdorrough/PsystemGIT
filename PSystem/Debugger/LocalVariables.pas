// It would be nice to be able to select either word indexing or byte indexing (radio group, maybe) for how
// offsets and sizes are calculated.
unit LocalVariables;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, FilerTables, Debug_Decl, ovcbase, ovcef, ovcpb,
  ovcnf, ExtCtrls, Menus, DB, MyUtils, UCSDGlob, ListingUtils, Watch_Decl,
  WindowsList;

// 1/11/2021 dhd Got rid of the global variable gInterpreter and replaced
//               many occurrences with fInterpreter- The intent is to permit
//               multiple interpreters to be simultaneously created.   
type

  TfrmLocalVariables = class(TForm)
    Panel1: TPanel;
    Label3: TLabel;
    mmoVariable: TMemo;
    Label2: TLabel;
    Label1: TLabel;
    lblProcName: TLabel;
    cbSegName: TComboBox;
    ovcProcNr: TOvcNumericField;
    cbProcName: TComboBox;
    Splitter1: TSplitter;
    pumVariable: TPopupMenu;
    Panel2: TPanel;
    sgLocalVariables: TStringGrid;
    lblStatus: TLabel;
    pumLocalVariables: TPopupMenu;
    Inspect1: TMenuItem;
    Undo1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    EnableEditing1: TMenuItem;
    SaveChanges1: TMenuItem;
    cbFreeze: TCheckBox;
    lblVarBase: TLabel;
    miPasteVariablesList: TMenuItem;
    lblErrMessage: TLabel;
    N2: TMenuItem;
//  Globalvariables1: TMenuItem;
    PasteParametersListfromCompilerListing1: TMenuItem;
    Print1: TMenuItem;
    lblAccessDbFileName: TLabel;
    Label4: TLabel;
    CopyWatchName1: TMenuItem;
    CopyWatchValue1: TMenuItem;
    N3: TMenuItem;
    EnterBaseAddress1: TMenuItem;
    procedure Paste1Click(Sender: TObject);
    procedure mmoVariableChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Inspect1Click(Sender: TObject);
    procedure mmoVariableKeyPress(Sender: TObject; var Key: Char);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure EnableEditing1Click(Sender: TObject);
    procedure SaveChanges1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure cbFreezeClick(Sender: TObject);
    procedure mmoVariableMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure sgLocalVariablesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure miPasteVariablesListClick(Sender: TObject);
//  procedure Globalvariables1Click(Sender: TObject);
    procedure PasteParametersListfromCompilerListing1Click(
      Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure CopyWatchName1Click(Sender: TObject);
    procedure CopyWatchValue1Click(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure EnterBaseAddress1Click(Sender: TObject);
  private
    fDatabaseFileName : string;
    fDataSize          : word;
    fSavingVariables   : boolean;
    fIntermediateVars  : word;
    fDebugger          : TObject;
    fJustOpened        : Boolean;
    fForcedBase        : word;
    
    function BaseRegister: word;
    function GetWordAt(P: word): word;
    function MemDumpDW(Addr: word; WatchType: TWatchType; Param: word = 0): string;
    function MemDumpDF(Addr: word; Form: string = 'W'; Param: word = 0): string;
    procedure ShowEditMode;
    function CleanUpLine(Line: string): string;
    function CleanUpText(const Original: string): string;
    function GetAccDbFileNumber: integer;
  protected
    fItemsSelected: TChangedRows;
    fLocalParameters: TLocalParameters;
    fPointerSize: word;
    fWord_Memory: boolean;
    procedure DisplayLocalParameters(const LocalParameters: TLocalParameters; DataSize: word);
  private
    { Private declarations }
    fAccDbFileNumber: integer;
    fInterpreter: TObject;
    fWindowType: TWindowsTypes;
    fRequestedWindowType: TWindowsTypes;
    fProcName: string;
    fSegName: string;
    fProcNum: integer;
    fSavedMSCWPtr: word;
    procedure SetProcName(const Value: string);
    procedure SetSegName(const Value: string);
    function SameRecord({aAccDbFileNumber: integer;} const aSegName, aProcName: string): boolean;
    procedure SetProcNum(const Value: integer);
    procedure GetRowCol(Memo: TMemo; var Row, Col: word);
    procedure Update_Status(const Msg: string; Color: TColor = clBtnFace);
    procedure Update_ErrStatus(const Msg: string; Color: TColor = clYellow);
  public
    { Public declarations }
    fLastSegName     : string;
    fLastProcName    : string;
    fLastProcNum     : integer;
//  fLastAccDbFileNumber: integer;
    fpCodesProcTable : TpCodesProcTable;

    Constructor Create( aOwner: TComponent;
                        Interpreter: TObject;
                        aWindowType: TWindowsTypes;
                        IntermediateVars: word = 0;
                        aSegName: string = '';
                        aProcName: string = '';
                        aProcNum: integer = 0); reintroduce;
    procedure SaveChanges;
    procedure UpdateDisplay( aSegName: string;
                             aProcName: string;
                             aProcNum: integer); {virtual;}
    procedure UpdateProcParameters(DataSet: TDataSet);

    Destructor Destroy; override;

    property WordAt[P: word]: word
             read GetWordAt;

    property SegName: string
             read fSegName
             write SetSegName;
    property ProcName: string
             read fProcName
             write SetProcName;
    property ProcNum: integer
             read fProcNum
             write SetProcNum;
  end;

var
  frmLocalVariables: TfrmLocalVariables;
  frmGlobalVariables: TfrmLocalVariables;

implementation

uses MyTables_Decl, Misc,
  Inspector, Interp_Decl, pCodeDebugger, Clipbrd, Interp_Common,
  DebuggerSettingsUnit, pCodeDebugger_Decl, DumpAddr, Interp_Const,
  UCSDInterpreter, InterpC, DecodeRange, GetHexAddress, InterpII;


{$R *.dfm}

const
  COL_ADDR     = 0;
  COL_WDOFFSET = 1;
  COL_NAME     = 2;
  COL_TYPE     = 3;
  COL_SIZE     = 4;
  COL_VALUE    = 5;
  COL_REFERENCE = 6;
  COL_COMMENT  = 7;

type
  TTypeInfo = record
                Name: string;
                Size: word;
//              DoIndirect: boolean;
              end;

{ TfrmLocalVariables }



constructor TfrmLocalVariables.Create( aOwner: TComponent;
                                      Interpreter: TObject;
                                      aWindowType: TWindowsTypes;
                                      IntermediateVars: word = 0;
                                      aSegName: string = '';
                                      aProcName: string = '';
                                      aProcNum: integer = 0);
begin
  inherited Create(aOwner);

  if (aProcNum = 1) and (aWindowType = wtLocal) and (SameText(aSegName, aProcName)) then
    aWindowType := wtGlobal;

  fIntermediateVars := IntermediateVars;
  fDebugger         := aOwner;

  fAccDbFileNumber  := -1;  // force DB to be opened later

  fWindowType          := aWindowType;
  fRequestedWindowType := aWindowType;

  case fWindowType of
    wtLocal:
      Panel1.Color := clMoneyGreen;

    wtGlobal:
      Panel1.Color := clGray;

    wtIntermediateLocal:
      begin
        Panel1.Color := clTeal;
        fSegName     := aSegName;  // These do not change
        fProcName    := aProcName;
        fProcNum     := aProcNum;
      end;

    wtIntermediateGlobal, wtForcedAddress:       // These do not change
      begin
        if fWindowType = wtForcedAddress then
          Panel1.Color := clRed
        else
          Panel1.Color := clYellow;
        fSegName     := aSegName;  // These do not change
        fProcName    := aProcName;
        fProcNum     := aProcNum;
      end;
  end;
  Caption           := WindowsType[aWindowType];

  fInterpreter := Interpreter;
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      fWord_Memory := Word_Memory;
      fPointerSize := IIF(fWord_Memory, 1, 2);
    end;

  if fDebugger is TfrmPCodeDebuggerCustom then
    with fDebugger as TfrmPCodeDebuggerCustom do
      fDatabaseFileName := DEBUGGERSEttings.DatabaseToUse;

  lblVarBase.Caption := BothWays(BaseRegister);

  GetWordAt(0); // force the linker to include this function
end;

destructor TfrmLocalVariables.Destroy;
begin
  mmoVariable.OnChange := nil;
  FreeAndNil(fpCodesProcTable);
  gDebuggerSettings.WindowsList.AddWindow(self, WindowsType[fWindowType], Panel1.Height);

  inherited;
end;

procedure TfrmLocalVariables.SetProcName(const Value: string);
begin
  fProcName       := Value;
  cbProcName.Text := Value;
end;

procedure TfrmLocalVariables.SetSegName(const Value: string);
begin
  fSegName       := Value;
  cbSegName.Text := Value;
end;

procedure TfrmLocalVariables.DisplayLocalParameters(const LocalParameters: TLocalParameters; DataSize: word);
var
  i, RowNr, Offset, ErrCnt: integer;
  ValueReferenced, Temp, ErrMsg: string;
  AliasType: TWatchType;
  WatchIsAPointer: boolean;
  T1, T2: string;

  procedure BadAddress(Idx: integer; const Msg: string);
  begin
    with LocalParameters[idx] do
      ErrMsg   := Format('Invalid address: $%4x for parameter %s (%s)', [ParamAddr, ParamName, Msg]);
    Update_ErrStatus(ErrMsg, clYellow);
  end;

begin { DisplayLocalParameters }
  with sgLocalVariables, fInterpreter as TCustomPsystemInterpreter do
    begin
      Color := clBtnFace;
      RowCount := Length(LocalParameters) + 1;
      if RowCount > 1 then
        FixedRows := 1;
      Cells[COL_ADDR, 0]       := 'Addr';
      Cells[COL_WDOFFSET, 0]   := 'Wd#';
      Cells[COL_NAME, 0]       := 'Name';
      Cells[COL_TYPE, 0]       := 'Type';

      if Word_Memory then
        Cells[COL_SIZE, 0]     := 'Words'
      else
        Cells[COL_SIZE, 0]     := 'Bytes';

      Cells[COL_VALUE, 0]      := 'Value';
      Cells[COL_REFERENCE, 0]  := 'Value Referenced';
      Cells[COL_COMMENT, 0]    := 'Comment';
//    OffSet := 2;
      OffSet := WordIndexed(0, +1);
      ErrCnt := 0;
      for i := 0 to Length(LocalParameters)-1 do
        with LocalParameters[i] do
          begin
            RowNr     := i + 1;
            try
              if ParamOffset > 0 then
                Offset := IIF(fWord_Memory,
                              ParamOffset div 2,   // because it is always specified as a byte offset in @Addr
                              ParamOffset);

              if cbFreeze.Checked then
                ParamAddr := Offset + fSavedMSCWPtr
              else
                ParamAddr := Offset + BaseRegister;

              WatchIsAPointer := WatchTypesTable[ParamType].WatchIsPointer;

              if ParamIsAPointer or ParamIsAVar or WatchIsAPointer then
                RefdAddr := WordAt[ParamAddr]
              else
                RefdAddr := ParamAddr;

              Cells[COL_ADDR, RowNr]     := HexWord(ParamAddr);  // This is just a test

              if fWord_Memory then
                begin
//                Cells[COL_ADDR, RowNr]     := HexWord(ParamAddr);
                  Cells[COL_WDOFFSET, RowNr] := IntToStr(Offset);
                end
              else
                begin
//                Cells[COL_ADDR, RowNr]     := HexWord(ParamAddr div 2);
                  Cells[COL_WDOFFSET, RowNr] := IntToStr(Offset div 2);
                end;
              Cells[COL_NAME, RowNr]     := ParamName;

              if ParamType <> wt_Unknown then
                temp := WatchTypesTable[ParamType].WatchName
              else  // unknown type
                begin
                  ParamType := wt_HexWords;   // convert to a hexdump
                  temp      := ParamTypeName
                end;

              if ParamIsAPointer or ParamIsAVar then
                begin
                  Temp      := '^' + Temp;
//                ParamSize := WordIndexed(0, fPointerSize); // 2/18/2023: fPointerSize already takes into account Word_Memory
                  UnitSize := fPointerSize;
                end else
              if ParamType = wt_real then
                UnitSize := (fInterpreter as TCustomPsystemInterpreter).CREALSIZE * 2;  // Nr Bytes: NEEDS TO USE WORD_MEMORY

              Cells[COL_TYPE, RowNr]     := temp;
              Cells[COL_SIZE, RowNr]     := IntToStr(UnitSize);
              AliasType                  := WatchTypesTable[ParamType].Alias;

              case AliasType of
                wt_Ascii:
                  ValueReferenced := MemDumpDW(RefdAddr, wt_Ascii, ByteStreamLen); // WARNING: this is ignoring Word_Memory

                wt_Char:
                  ValueReferenced := MemDumpDW(RefdAddr, wt_Char, ByteStreamLen);

                wt_DecimalInteger:
                  ValueReferenced := MemDumpDW(RefdAddr, wt_DecimalInteger, UnitSize);

                wt_MultiWordSet:
                  ValueReferenced := MemDumpDW(RefdAddr, wt_MultiWordSet, UnitSize);

                wt_SetOfChar:
                  begin
                    if UnitSize = 0 then
                      UnitSize := 16;  // If not specified, assume 16 words (256 bits)
                    ValueReferenced := MemDumpDW(RefdAddr, wt_SetOfChar, UnitSize);
                  end;

                wt_LongInteger:
                  begin
                    ValueReferenced := MemDumpDW(RefDAddr, wt_LongInteger, UnitSize);
                  end;

                wt_HexBytes, wt_HexWords:
                  ValueReferenced := MemDumpDW(RefdAddr, AliasType, ByteStreamLen)
                else
                  ValueReferenced := MemDumpDW(RefdAddr, AliasType);
              end;

              Cells[COL_VALUE, RowNr]      := BothWays(WordAt[ParamAddr]);

              T1 := Cells[COL_REFERENCE, RowNr];
              T2 := ValueReferenced;
(*
              if T1 <> t2 then
                Compare(T1, T2);
*)
              // highlight the rows that have changed
              fItemsSelected[RowNr]        := not SameText(T1, T2);
              Cells[COL_REFERENCE, RowNr]  := T2;

              Cells[COL_COMMENT, RowNr]    := ParamComment;

              if ParamIsAPointer or ParamIsAVar or WatchIsAPointer then
                OffSet := Offset + fPointerSize  // 2 bytes or 1 word
              else
                Offset := OffSet + UnitSize;

              if odd(Offset) and (not Word_Memory) then    // force to a word address
                Offset := Offset + 1;
            except
              on E0:Exception do   // compiler dosen't like "on E:ERANGEERROR do" for some unknown reason
                begin
                  Color    := clRed;
                  RefdAddr := 0;
                  BadAddress(i, E0.Message);
                  Cells[COL_ADDR, RowNr]     := HexWord(ParamAddr);
                  Cells[COL_WDOFFSET, RowNr] := IntToStr(Offset div 2);
                  Cells[COL_TYPE, RowNr]     := temp;
                  Cells[COL_SIZE, RowNr]     := IntToStr(UnitSize);
                  Cells[COL_NAME, RowNr]     := ParamName;
                  Cells[COL_REFERENCE, RowNr] := E0.Message;
                  lblStatus.Caption           := E0.Message;
                  Inc(ErrCnt);
                end;
            end;
          end;
        if ErrCnt > 1 then
          Update_ErrStatus(Format('%d errors occurred when trying to display the variables', [ErrCnt]), clYellow)
        else
          Update_ErrStatus('', clBtnFace);
      AdjustColumnWidths(sgLocalVariables);
    end;
end;  { DisplayLocalParameters }

procedure TfrmLocalVariables.UpdateProcParameters(DataSet: TDataSet);
begin
  if not fSavingVariables then
    if mmoVariable.Modified then
      with fpCodesProcTable do
        begin
          try
            fSavingVariables := true;
            try
              if not SameRecord(fLastSegName, fLastProcName) then
                begin     // Are we still in edit mode?
                  if YesFmt('TfrmLocalVariables.UpdateProcParameters- record was changed: %s/%s, %s/%s. Attempt to locate and update %s.%s?',
                     [fLastSegName, fldSegmentName.AsString,
                      fLastProcName, fldProcedureName.AsString,
                      fLastSegName, fLastProcName]) then
                    if not Locate(IndexName_SEGNAME_PROC_NR_NAME_INDEX, VarArrayOf([fLastSegName, fLastProcNum, fLastProcName]), [loCaseInsensitive]) then
                      raise Exception.CreateFmt('Locate failure: #%d:%s.%s', [fLastProcNum, fLastSegName, fLastProcName]);
                end;
              Edit;
              fldProcParameters.AsString := mmoVariable.Text;
              Post;
              mmoVariable.Modified := false;
              Update_Status('Record updated', clAqua);
            finally
              fSavingVariables := false;
            end;
          except
            on e:Exception do
              Update_ErrStatus(Format('Save failed. %s', [e.Message]), clYellow);
          end;
        end
    else
      ShowEditMode;
end;

function TfrmLocalVariables.SameRecord({aAccDbFileNumber: integer;} const aSegName, aProcName: string): boolean;
begin
  with fpCodesProcTable do
    result :=  SameText(fldSegmentName.AsString, aSegName) and
               SameText(fldProcedureName.AsString, aProcName);
end;

procedure TfrmLocalVariables.UpdateDisplay( aSegName: string;
                                            aProcName: string;
                                            aProcNum: integer);
begin { UpdateDisplay }
  fWindowType := fRequestedWindowType;

  case fWindowType of
    wtLocal:
      begin
        fLastSegName  := aSegName;
        fLastProcName := aProcName;
        fLastProcNum  := aProcNum;
      end;

    wtGlobal:
      begin
        aProcName     := aSegName;     // Assumes that SEGNAME.SEGNAME always contains the Global information
        aProcNum      := 1;
        fLastSegName  := aSegName;
        fLastProcName := aProcName;
        fLastProcNum  := aProcNum;
      end;

    wtIntermediateLocal, wtIntermediateGlobal, wtForcedAddress:
      begin  // Segment.Procedure does not change.
             // Must ignore aSegName, aProcName after creation.
        aSegName      := fSegName;
        aProcName     := fProcName;
        aProcNum      := fProcNum;
      end;
  end;

  if not cbFreeze.Checked then
    begin
      SegName  := aSegName;
      ProcNum  := aProcNum;

      // 5/7/2021: V2 needs SEGTOP but V4 needs SEGBASE
//    with fInterpreter as TCustomPsystemInterpreter do
//      begin
//        aProcBase := CalcProcBase(SegBase, Abs(aProcNum));
//        lblDataSize.Caption := Format('(incorrect) Datasize = %d words (@%4.4x)',
//                                      [WordAt[SegBase + aProcBase - 2], SegBase + aProcNum]);
//      end;

      fJustOpened := false;
      if (not Empty(aSegName)) and (not Empty(aProcName)) then
        begin
          // 1. Open a local copy of the TpCodesProcTable
          if not Assigned(fpCodesProcTable) then
            begin
              fpCodesProcTable  := TpCodesProcTable.Create( self,
                                                            fDatabaseFileName, TableNamePCodeProcs,
                                                            [optLevel12]);
              fpCodesProcTable.BeforeScroll := UpdateProcParameters;
              fpCodesProcTable.Active := true;
              fJustOpened             := true;
            end;

          with fpCodesProcTable do
            begin
              ProcName := Copy(aProcName, 1, fldProcedureName.Size);  // truncate to field size
              // 2. Fetch the fldProcParameters field
              if (not SameRecord(SegName, ProcName)) or fJustOpened then  // the current record has been changed
                begin
                  if Locate(IndexName_SEGNAME_PROC_NR_NAME_INDEX, VarArrayOf([SegName, ProcNum, ProcName]), [loCaseInsensitive]) then
                    Edit
                  else
                    Append;

                  if fldProcParameters.IsNull then  { record does not exist. Create it }
                    begin
                      fldSegmentName.AsString      := SegName;
                      fldProcedureName.AsString    := ProcName;
                      fldProcedureNumber.AsInteger := aProcNum;
                      with fInterpreter as TCustomPsystemInterpreter do
                        Case VersionNr of
                          vn_VersionIV{, vn_VersionIV_12}:
                            fldProcParameters.AsString   := '{ LOCAL VARIABLES }' + CRLF +
                                                            '{ TEMPORARY VARIABLES }' + CRLF +
                                                            '{ PARAMETERS }' + CRLF +
                                                            '{ RESULT }'
                          else
                            fldProcParameters.AsString   := '{ FUNCTION RESULT }' + CRLF +
                                                            '{ PARAMETERS }' + CRLF +
                                                            '{ LOCAL VARIABLES }' + CRLF +
                                                            '{ TEMPORARY VARIABLES }'
                        end;

                      // Assume that we are already positioned on the correct record
//                    fldSegment_ID.AsInteger      := SegmentID;
                      Post;
                    end;
                  mmoVariable.Text := fldProcParameters.AsString;
                  if fWord_Memory then
                    mmoVariable.Hint := 'Note that @Addr and [len] MUST be expressed in bytes';

                  fLastSegName         := SegName;
                  fLastProcName        := ProcName;
                  fLastProcNum         := ProcNum;
//                fLastAccDbFileNumber := AccDbFileNumber;
                end
            end;
        end;
    end;
  with fInterpreter as TCustomPsystemInterpreter do
    DisplayLocalParameters(fLocalParameters, fDataSize);
end;  { UpdateDisplay }

procedure TfrmLocalVariables.Paste1Click(Sender: TObject);
begin
  mmoVariable.PasteFromClipboard;
end;

procedure TfrmLocalVariables.mmoVariableChange(Sender: TObject);
begin
  try
    fDataSize := 0;
    with fInterpreter as TCustomPsystemInterpreter do
      if Assigned(fpCodesProcTable) and (not EnableEditing1.Checked) then
        if ParseParameterNames(mmoVariable.Text, fLocalParameters, fDataSize, false, false, Word_Memory) then
          DisplayLocalParameters(fLocalParameters, fDataSize);
  except
    on e:ESyntaxError do
      begin
        mmoVariable.SelStart  := 1;
        mmoVariable.SelLength := e.ErrIdx;
        Update_ErrStatus(e.Message, clYellow);
      end;
    on e:Exception do
      Update_ErrStatus(e.Message, clYellow);
  end;
end;

procedure TfrmLocalVariables.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(fpCodesProcTable) then
    UpdateProcParameters(fpCodesProcTable);   // update the DB
  Action := caFree;
end;

procedure TfrmLocalVariables.SetProcNum(const Value: integer);
begin
  fProcNum := Value;
  ovcProcNr.AsInteger := Value;
end;

procedure TfrmLocalVariables.Inspect1Click(Sender: TObject);
var
  frm: TfrmInspect;
  Idx: integer;
begin
  frm := TfrmInspect.Create(Parent, fInterpreter, fDebugger);
  Idx := sgLocalVariables.Row - 1;
  with fLocalParameters[idx] do
    begin
      Frm.WatchType    := WatchTypesTable[ParamType].Alias;
      Frm.WatchName    := ParamName;
      Frm.WatchAddr    := RefdAddr;
      Frm.WatchComment := ParamName;
    end;
  frm.UpdateWatchNameAndValue;
  frm.Show;
end;

procedure TfrmLocalVariables.GetRowCol(Memo: TMemo; var Row, Col: word);
begin
  Row := Memo.Perform(EM_LINEFROMCHAR, -1, 0);
  Col := (Memo.SelStart - SendMessage(Memo.Handle, EM_LINEINDEX, Row, -1 {0}));
end;

procedure TfrmLocalVariables.mmoVariableKeyPress(Sender: TObject;
  var Key: Char);
const
  TABWIDTH = 8;
var
  Row, Col, NrBlanks: word;
  Blanks: string;
  Memo: TMemo;
begin
  if EnableEditing1.Checked then
    begin
      Memo := Sender as TMemo;
      case ord(Key) of
        VK_TAB:
          begin
            GetRowCol(Memo, Row, Col);
            NrBlanks := TABWIDTH - (Col MOD TABWIDTH);
            Blanks   := Padr('', NrBlanks);
            Memo.SelText := Blanks;
            Key := #0;
          end;
      end;
    end
  else
    begin
      ShowEditMode;
      SysUtils.Beep;
      Key := #0;
    end;
end;

procedure TfrmLocalVariables.ShowEditMode;
begin
  if EnableEditing1.Checked then
    Update_Status('EDITING', clYellow)
  else
    Update_Status('');
end;


procedure TfrmLocalVariables.Cut1Click(Sender: TObject);
begin
  mmoVariable.CutToClipBoard;
end;

procedure TfrmLocalVariables.Copy1Click(Sender: TObject);
begin
  mmoVariable.CopyToClipBoard;
end;

procedure TfrmLocalVariables.EnableEditing1Click(Sender: TObject);
begin
  EnableEditing1.Checked := not EnableEditing1.Checked;
  if EnableEditing1.Checked then
    Update_Status('EDITING', clYellow)
  else
    begin
      try
        mmoVariableChange(nil);
        UpdateProcParameters(fpCodesProcTable);
      except
        on e:ESyntaxError do
          begin
            Update_ErrStatus(e.Message, clYellow);
            mmoVariable.SelStart  := 0;
            mmoVariable.Sellength := e.ErrIdx;
          end;
      end;
    end;
end;

procedure TfrmLocalVariables.Update_Status(const Msg: string; Color: TColor = clBtnFace);
begin
  lblStatus.Caption := Msg;
  lblStatus.Color   := Color;
end;

procedure TfrmLocalVariables.SaveChanges;
begin
  UpdateProcParameters(fpCodesProcTable);
end;


procedure TfrmLocalVariables.SaveChanges1Click(Sender: TObject);
begin
  SaveChanges;
end;

function TfrmLocalVariables.GetWordAt(P: word): word;
var
  Msg: string;
begin
  if not Odd(p) then
    with fInterpreter as TCustomPsystemInterpreter do
      result := Words[p shr 1]
  else
    begin
      Msg := Format('GetWordAt passed an ODD address: %d', [p]);
      raise Exception.Create(Msg);
    end;
end;

function TfrmLocalVariables.MemDumpDW(Addr: word; WatchType: TWatchType; Param: word = 0): string;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := MemDumpDW(Addr, WatchType, Param);
end;

function TfrmLocalVariables.MemDumpDF(Addr: word; Form: string = 'W'; Param: word = 0): string;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := MemDumpDF(Addr, Form, Param);
end;

procedure TfrmLocalVariables.Undo1Click(Sender: TObject);
begin
  mmoVariable.Undo;
end;

procedure TfrmLocalVariables.cbFreezeClick(Sender: TObject);
begin
  if cbFreeze.Checked then
    begin
      cbFreeze.Color := clYellow;
      with fInterpreter as TCustomPsystemInterpreter do
        fSavedMSCWPtr := BaseRegister
    end
  else
    cbFreeze.Color := clBtnFace;
end;

procedure TfrmLocalVariables.mmoVariableMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShowEditMode;
end;

procedure TfrmLocalVariables.FormShow(Sender: TObject);
var
  SplitterPos: integer;
begin
  with gDebuggerSettings.WindowsList do
    LoadWindowInfo(self, WindowsType[fWindowType], SplitterPos);
  if SplitterPos > 0 then
    Panel1.Height := SplitterPos;
end;

function TfrmLocalVariables.BaseRegister: word;
//var
//i: TUCSDInterpreter;
//ParamSize: word;
//DataSize: word;
begin
  result := 0;
  with fInterpreter as TCustomPsystemInterpreter do
    case fWindowType of
      wtGlobal:
        case VersionNr of
          vn_VersionIV {,vn_VersionIV_12}:
            result := GlobVar {DX};
          vn_VersionI_4, vn_VersionI_5, vn_VersionII:
            if fInterpreter is TCPsystemInterpreter then
              with fInterpreter as TCPsystemInterpreter do
                begin
//                result    := WordIndexed(GlobVar, MS_VARW+2 {+2 reserves 2 words for something? I'm not sure what.});
//                ParamSize := ProcParamSize(JTab);  // debugging
//                DataSize  := CurrentDataSize;      // debugging - can I substitute something else for +2 below?
//                result    := WordIndexed(GlobVar, MS_VARW+ParamSize {+2 reserves 2 words for something? I'm not sure what.
//                                                             Function results maybe?});
                  result    := GlobalAddr(0);
                end else
            if fInterpreter is TIIPsystemInterpreter then
              result := GlobVar{
            else
              Assert(false, 'InterpII not yet implemented')};
        end;

      wtLocal:
        result := LocalVar {BX}; // This probably needs to use WordIndexed also!

      wtIntermediateLocal,
      wtIntermediateGlobal:
        result := fIntermediateVars;

      wtForcedAddress:
        result := fForcedBase;
    end;
end;

procedure TfrmLocalVariables.sgLocalVariablesDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  GridDrawCell(sgLocalVariables, fItemsSelected, ACol, ARow, Rect);
end;

function TfrmLocalVariables.CleanUpLine(Line: string): string;
var
  OffsetStr, Tail, Comment: string;
  Off: word;
  lb, rb: integer;
begin
  Line := Trim(Line);
  if (Length(Line) > 0) and not ((Line[1] = '{') and (Line[Length(Line)] = '}')) then
    begin
      OffsetStr := Trim(Copy(Line, 17, 5));
      if IsPureNumeric(OffSetStr) then
        begin
          Off    := StrToInt(OffsetStr);
          Tail   := Copy(Line, 22, MAXINT);
          lb     := Pos('{', Tail);
          rb     := Pos('}', Tail);
          if (rb > lb) and (lb > 0) then // there is a comment
            begin
              Comment := Copy(Tail, lb+1, rb-lb-1);  // save the comment
              Tail    := Copy(Tail, 1, lb-1);        // save stuff before the comment
            end
          else // there is no comment
            Comment := '';

          result := Format('%-48s  { %3d: %s }',
                           [Tail, Off, Comment]);
        end;
    end
  else
    result := line;   // just copy comment lines
end;

function TfrmLocalVariables.CleanUpText(const Original: string): string;
var
  LineNr: integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Original;
    for LineNr := Lines.Count-1 downto 0 do
      Lines[LineNr] := Trim(CleanUpLine(Lines[LineNr]));
    result := Lines.Text;
  finally
    FreeAndNil(Lines);
  end;
end;


procedure TfrmLocalVariables.miPasteVariablesListClick(Sender: TObject);
begin
  mmoVariable.SelText    := CleanUpText(Clipboard.AsText);

  mmoVariable.Modified   := true;
  EnableEditing1.Checked := true;
  Update_Status('EDITING', clYellow)
end;

procedure TfrmLocalVariables.Update_ErrStatus(const Msg: string;
  Color: TColor);
begin
  lblErrMessage.Caption := Msg;
  lblErrMessage.Color   := Color;
end;

(*
procedure TfrmLocalVariables.Globalvariables1Click(Sender: TObject);
begin
  Globalvariables1.Checked := not Globalvariables1.Checked;
  DisplayLocalParameters(fLocalParameters, fDataSize);
end;
*)

(*
  TLocalParameter = packed record
    ParamAddr      : word;
    ParamOffset    : word;
    ParamName      : string;
    ParamType      : TWatchType;
    ParamSize      : word;
    ParamTypeName  : string[DEF_TYPENAME_LEN];
    RefdAddr       : word;
    ParamComment   : string;
    ParamIsAVar    : boolean;
    ParamIsAPointer: boolean;
  end;
*)
procedure TfrmLocalVariables.PasteParametersListfromCompilerListing1Click(
  Sender: TObject);
var
  vln: word;
  Line, NewLine, Comment, TypeName: string;
  LocalParameters: TLocalParameters;
  List: TStringList;
begin
  List    := TStringList.Create;

  try
    NewLine := '';
    with fInterpreter as TCustomPsystemInterpreter do
    if ParseParameterNames(Clipboard.AsText, LocalParameters, fDataSize, TRUE, false, Word_Memory) then
      begin
        for vln := Length(LocalParameters)-1 downto 0 do
          with LocalParameters[vln] do
            begin
              if ParamComment <> '' then
                Comment := Format('     {%s}', [ParamComment])
              else
                Comment := '';

              if ParamIsAVar then
                TypeName := '^' + ParamTypeName
              else
                TypeName := ParamTypeName;
                
              Line := Format('%-16s: %-10s;', [ParamName, TypeName, Comment]);
              if NewLine = '' then
                NewLine := Line
              else
                NewLine := NewLine + CRLF + Line;
            end;
      end;
  finally
    mmoVariable.SelText  := NewLine;
    mmoVariable.Modified := true;
    List.Free;
  end;

end;

procedure TfrmLocalVariables.Print1Click(Sender: TObject);
var
  OutFileName, Title, SubTitle: string;
begin
  OutFileName := UniqueFileName(gDebuggerSettings.ReportsPath + 'LocalVariables.txt');
  Title := Format('Variables for %s.%s', [fSegName, fProcName]);

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  PrintStringGrid(Title, SubTitle, sgLocalVariables, OutFileName, true, 40 { MaxCols });
end;

function TfrmLocalVariables.GetAccDbFileNumber: integer;
begin
  result := fAccDbFileNumber;
end;

procedure TfrmLocalVariables.Panel1DblClick(Sender: TObject);
begin
  with TfrmDumpAddr.Create(self) do
    begin
      WatchAddr := BaseRegister;
      if ShowModal = mrOK then
        begin
          fIntermediateVars := WatchAddr;
          DisplayLocalParameters(fLocalParameters, fDataSize);
          lblStatus.Caption := Format('%-4.4x', [fIntermediateVars]);
        end;
    end;
end;

procedure TfrmLocalVariables.CopyWatchName1Click(Sender: TObject);
var
  Idx: integer;
begin
  Idx := sgLocalVariables.Row - 1;
  with fLocalParameters[idx] do
    ClipBoard.AsText := ParamName;
end;

procedure TfrmLocalVariables.CopyWatchValue1Click(Sender: TObject);
(*
var
  Idx: integer;
*)
begin
(*
  Idx := sgLocalVariables.Row - 1;
//with fInterpreter as TCustomPsystemInterpreter do   // commented out to force the use of local MemDumpDW proc
    with fLocalParameters[idx] do
      if ParamIsAPointer or ParamIsAVar then
        ClipBoard.AsText := MemDumpDW(WordAt[ParamAddr], ParamType, ParamSize)
      else
        ClipBoard.AsText := MemDumpDW(ParamAddr, ParamType, ParamSize);
*)
  with sgLocalVariables do
    ClipBoard.AsText := Cells[COL_REFERENCE, Row];
end;

procedure TfrmLocalVariables.Panel1Resize(Sender: TObject);
begin
  AdjustColumnWidths(sgLocalVariables);
end;

procedure TfrmLocalVariables.EnterBaseAddress1Click(Sender: TObject);
var
  frmGetHexAddress: TfrmGetHexAddress;
begin
  frmGetHexAddress := TfrmGetHexAddress.Create(self);
  try
     with frmGetHexAddress do
       begin
         leStartingAddress.Text := '$' + HexWord(BaseRegister);
         if ShowModal = mrOK then
           begin
             fRequestedWindowType := wtForcedAddress;
             fForcedBase          := ReadInt(leStartingAddress.Text);
             lblVarBase.Caption   := BothWays(BaseRegister);
             UpdateDisplay(fSegName, fProcName, fProcNum);
           end;
       end;
  finally
    FreeAndNil(frmGetHexAddress);
  end;
end;

end.
