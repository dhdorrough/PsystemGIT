unit SegmentProcname;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf, UCSDGlob, Grids, FilerTables,
  Debug_Decl, pCodeDebugger_Decl, DebuggerSettingsUnit;

type
  TfrmSegmentProcName = class(TForm)
    cbSegName: TComboBox;
    Label2: TLabel;
    btnUpdate: TButton;
    btnCancel: TButton;
    sgProcNames: TStringGrid;
    lblSegNameIdx: TLabel;
    btnValidate: TButton;
    lblStatus: TLabel;
    Label1: TLabel;
    edtAccessFileName: TEdit;
    procedure cbSegNameExit(Sender: TObject);
    procedure btnValidateClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtAccessFileNameChange(Sender: TObject);
  private
    { Private declarations }
    fSegNameIdx: TSegNameIdx;
    fpCodesProcTable  : TpCodesProcTable;
    fDebuggerSettings: TDebuggerSettings;
    procedure ShowProcNamesForSegment(SegNameIdx: TSegNameIdx);
    procedure Enable_Buttons(OK: boolean);
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; const FileName: string; DebuggerSettings: TDebuggerSettings); reintroduce;
    Destructor Destroy; override;
  end;

var
  frmSegmentProcName: TfrmSegmentProcName;

implementation

uses MyUtils, FilerSettingsUnit, MyTables_Decl, DB;

{$R *.dfm}

const
  COL_PROCNUM  = 0;
  COL_PROCNAME = 1;
  COL_COMMENT  = 2;

{ TfrmSegmentProcName }

constructor TfrmSegmentProcName.Create(aOwner: TComponent; const FileName: string; DebuggerSettings: TDebuggerSettings);
var
  cb: TComboBox;
begin
  inherited Create(aOwner);
  fDEBUGGERSettings := DebuggerSettings;

  edtAccessFileName.Text := fDebuggerSettings.DatabaseToUse;
  Assert(false, 'TfrmSegmentProcName.Create need to be reimplemented');
//cb := cbAccDbFileNumber;
//with DebuggerSettings do
//  begin
//    for i := 0 to pCodesDatabaseFileNameS.Count-1 do
//      cb.Items.Add(pCodesDatabaseFileNameS[i].FilePath);
//    cb.Items.Assign(pCodesDatabaseFileNameS);
//    cb.ItemIndex := cb.Items.IndexOf(FileName);
//    if cb.ItemIndex < 0 then
//      cb.Items.AddObject(FileName, TObject(0));
//    cbAccDbFileNumberChange(nil);
//  end;
end;

procedure TfrmSegmentProcName.cbSegNameExit(Sender: TObject);
var
  SegName: string;
  Idx: integer;
begin
  SegName := UpperCase(cbSegName.text);
  if SegName <> '' then
    begin
      cbSegName.text := SegName;
      fSegNameIdx    := -1;  // if cannot be found
      with cbSegName do
        begin
          if Items.IndexOf(SegName) < 0 then // not already in the list
            Items.AddObject(SegName, TObject(SegNamesInDB.Count));          // Add to the drop down list
          Idx := Items.IndexOf(SegName);     // get index in the drop down
          if Idx >= 0 then
            fSegNameIdx  := Integer(Items.Objects[Idx]); // and get segment number
        end;
    end;

  lblSegNameIdx.Caption := IntToStr(fSegNameIdx);
  ShowProcNamesForSegment(fSegNameIdx);
end;

procedure TfrmSegmentProcName.ShowProcNamesForSegment(SegNameIdx: TSegNameIdx);
var
  NrProcNames, ColNr, RowNr, ProcNr: integer;
begin
  with sgProcNames do
    begin
      ColCount := 3;

      Cells[COL_PROCNUM , 0]  := 'P#';
      Cells[COL_PROCNAME, 0] := 'Procedure Name';
      Cells[COL_COMMENT , 0]  := 'Comment';

      // Count the number of procnames for this SegNameIdx
      NrProcNames := 0;
      for ProcNr := 1 to MAXPROCNAME do
        if ProcNamesInDB[SegNameIdx, ProcNr] <> '' then
          Inc(NrProcNames);

      if NrProcNames > 0 then
        RowCount := NrProcNames + 1
      else
        begin
          RowCount := 2;  // otherwise we lose the "fixed row" at the top
          for ColNr := 0 to Pred(COL_COMMENT)-1 do
            Cells[ColNr, 1] := '';  // blank out row 1
        end;

      // display the procedure names
      RowNr := 0;
      for ProcNr := 1 to MAXPROCNAME do
        begin
          if ProcNamesInDB[SegNameIdx, ProcNr] <> '' then
            begin
              Inc(RowNr);
              Cells[COL_PROCNUM, RowNr]  := IntToStr(ProcNr);
              Cells[COL_PROCNAME, RowNr] := UpperCase(ProcNamesInDB[SegNameIdx, ProcNr]);
              Cells[COL_COMMENT, RowNr]  := '';
            end;
        end;
    end;
end;


procedure TfrmSegmentProcName.Enable_Buttons(OK: boolean);
begin
  btnUpdate.Enabled := OK;
end;

procedure TfrmSegmentProcName.btnValidateClick(Sender: TObject);
var
  ErrCount, R1, R2, ProcNum: integer;
  SegName, ProcNumStr: string;
  sn: TSegNameIdx;

  procedure ErrLine(R: integer; const Comment: string);
  begin { ErrLine }
    with sgProcNames do
      begin
        Cells[COL_COMMENT, R] := Comment;
        Inc(ErrCount);
      end;
  end;  { ErrLine }

begin { btnValidateClick }
  // validate the segment name
  ErrCount := 0;
  SegName  := cbSegName.Text;

  // Remove any previous validation comments
  with sgProcNames do
    for R1 := 1 to RowCount do
      Cells[COL_COMMENT, R1] := '';

  // Delete empty rows
  with sgProcNames do
    begin
      for R1 := RowCount-1 downto 1 do
        begin
          if Empty(Cells[COL_PROCNAME, r1]) and Empty(Cells[COL_PROCNUM, r1]) then
            DeleteGridRow(sgProcNames, R1);
        end;
    end;

  if not IsIdentifier(SegName) then
    begin
      lblStatus.Caption := 'Invalid segment name';
      Inc(errCount);
    end;

  for sn := 0 to SegNamesInDB.Count-1 do
    if (sn <> fSegNameIdx) and (SameText(SegName, SegNamesInDB.Strings[sn])) then
      begin
        lblstatus.Caption := Format('Segment name "%s" is already in use', [SegName]);
        inc(errCount);
      end;

  with sgProcNames do
    begin
      for R1 := 1 to RowCount-1 do
        begin
          // change all to upper case
          Cells[COL_PROCNAME, R1] := UpperCase(Cells[COL_PROCNAME, R1]);

          // Look for bad identifiers
          if not IsIdentifier(Cells[COL_PROCNAME, R1]) then
            ErrLine(R1, 'Invalid identifier');

          // Look for procedure numbers "out of range"
          ProcNumStr := Cells[COL_PROCNUM, R1];
          if IsPureNumeric(ProcNumStr) then
            begin
              ProcNum := StrToInt(ProcNumStr);
              if (ProcNum < 0) or (ProcNum > MAXPROCNAME) then
                ErrLine(R1, 'Proc Num out of range');
            end
          else
            ErrLine(R1, 'Invlid procedure number')
        end;

      // Look for duplicate procedure names
      for R1 := 1 to RowCount-2 do
        for R2 := R1 + 1 to RowCount-1 do
          begin
            if SameText(Cells[COL_PROCNAME, R1], Cells[COL_PROCNAME, R2]) then // this is a duplicate name
              begin
                ErrLine(R1, Format('Duplicate name %s', [Cells[COL_PROCNAME, R2]]));
                ErrLine(R2, Format('Duplicate name %s', [Cells[COL_PROCNAME, R1]]));
              end;
            if SameText(Cells[COL_PROCNUM, R1], Cells[COL_PROCNUM, R2]) then // this is a duplicate number
              begin
                ErrLine(R1, Format('Duplicate number %s', [Cells[COL_PROCNUM, R2]]));
                ErrLine(R2, Format('Duplicate number %s', [Cells[COL_PROCNUM, R1]]));
              end;
          end;
    end;

  Enable_Buttons(ErrCount = 0);
end;  { btnValidateClick }

procedure TfrmSegmentProcName.btnUpdateClick(Sender: TObject);
var
  R1, ProcNum, Idx, NrUpdated, NrAdded: integer;
  ProcNumStr, ProcName, SegName: string;
  SegNameIdx: TSegNameIdx;
begin
  // Update the "in memory" list
  SegName     := Copy(cbSegName.Text, 1, CHARS_PER_SEG_NAME);

  Idx         := SegNamesInDB.IndexOf(SegName);
  if Idx >= 0 then
    SegNameIdx := Integer(SegNamesInDB.Objects[Idx])
  else              // not in the SegNames list. Add it.
    SegNameIdx := SegNamesInDB.AddObject(
                                      SegName,
                                      TObject(SegNamesInDB.Count));

  with sgProcNames do
    begin
      // clear any previous assignments to this segment
      for ProcNum := 1 to MAXPROCNAME do
        ProcNamesInDB[SegNameIdx, ProcNum] := '';

      // put in the new procedure names/numbers
      for R1 := 1 to RowCount-1 do
        begin
          ProcNumStr := Cells[COL_PROCNUM, R1];
          ProcNum    := StrToInt(ProcNumStr);
          ProcName   := Cells[COL_PROCNAME, R1];
          ProcNamesInDB[SegNameIdx, ProcNum] := ProcName;
        end;
    end;

(*
  // Update the SegmentInfo table
  with fSegmentInfoTable do
    begin
      if not Locate(cSEGMENTNAME, SegName, [loCaseInsensitive]) then
        begin
          Append;
          fldSegmentName.AsString := SegName;
          Post;
        end;
    end;
*)
  // Update the pCodeProcs table
  NrUpdated := 0;
  NrAdded   := 0;
  with fpCodesProcTable do
    begin
      for ProcNum := 1 to MAXPROCNAME do
        begin
          ProcName := ProcNamesInDB[SegNameIdx, ProcNum];
          if ProcName <> '' then
            begin
              if Locate(IndexName_SEGNAME_PROC_NR_NAME_INDEX, VarArrayOf([SegName, ProcNum, ProcName]), [loCaseInsensitive]) then
                begin
                  if ProcNum <> fldProcedureNumber.AsInteger then
                    raise Exception.CreateFmt('Updating: Procedure number does not match for %d:%s.%s',
                                              [ProcNum, SegName, ProcName]);
                  Edit;
                  Inc(NrUpdated);
                end
              else
                begin
                  Append;
                  Inc(NrAdded);
                end;

              fldSegmentName.AsString      := SegName;
              fldProcedureName.AsString    := ProcName;
              fldProcedureNumber.AsInteger := ProcNum;
              Post;
            end;
        end;
    end;
  AlertFmt('%d records updated, %d records added for the Segment named "%s"',
           [NrUpdated, NrAdded, SegName]);
end;

destructor TfrmSegmentProcName.Destroy;
begin
//FreeAndNil(fSegmentInfoTable);
  FreeAndNil(fpCodesProcTable);
  inherited;
end;

procedure TfrmSegmentProcName.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfrmSegmentProcName.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_TAB then
    if ActiveControl = sgProcNames then
      with sgProcNames do
        begin
          if (Col = ColCount - 1) and (Row = RowCount - 1) then
            RowCount := RowCount + 1;
        end;
end;

procedure TfrmSegmentProcName.edtAccessFileNameChange(Sender: TObject);
var
  sn: integer;
begin
  Assert(false, 'Untested');
    begin
      cbSegName.Clear;
      for sn := 0 to SegNamesInDB.Count-1 do // not using sn_Unknown may lose the ability
      if SegNamesInDB.Strings[sn] <> '' then
        cbSegName.Items.AddObject(SegNamesInDB.Strings[sn], TObject(sn));

      if cbSegName.Items.Count > 0 then
        cbSegName.ItemIndex := 0;

      cbSegNameExit(nil);     // display list of procedures in this segment

// start dubious code (Why is this dubious? What was it supposed to do?)
      FreeAndNil(fpCodesProcTable);

      fpCodesProcTable  := TpCodesProcTable.Create( self,
                                                    fDEBUGGERSettings.DatabaseToUse, // was: Items[ItemIndex],
                                                    TableNamePCodeProcs,
                                                    [optLevel12]);
      fpCodesProcTable.Open;
// end dubious code
    end;
end;

end.
