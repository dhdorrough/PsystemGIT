unit Inspector;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uWatchInfo, StdCtrls, ovcsf, ovcbase, ovcef, ovcpb, ovcnf, Mask,
  FilerTables, ExtCtrls, Grids, MyUtils, UCSDGlob, pCodeDebugger;

type
  TfrmInspect = class(TfrmWatchInfo)
    sgValues: TStringGrid;
    lblStatus: TLabel;
    lblPrefixInfo: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure sgValuesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure Panel1Resize(Sender: TObject);

  private
    { Private declarations }
    fChangedValues: TChangedRows;
    fInterpreter: TObject;
    fDebugger: TfrmPCodeDebugger;

  protected
    procedure UpdateStatus(const aCaption: string; aColor: TColor); override;
    procedure SetWatchValue(Value: string); override;

  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; Interpreter: TObject; Debugger: TObject); reintroduce;
    Destructor Destroy; override;
  end;

var
  frmInspect: TfrmInspect;

implementation

uses InterpIV, Debug_Decl, DebuggerSettingsUnit, MyTables_Decl{, pCodeDebugger}, MyDelimitedParser,
  pCodeDebugger_Decl;

{$R *.dfm}

var
  Delimited_Info: TDelimited_Info;

procedure TfrmInspect.Button1Click(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmInspect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Action := caFree; 
end;

constructor TfrmInspect.Create(aOwner: TComponent; Interpreter: TObject; Debugger: TObject);
begin
  inherited Create(aOwner, Interpreter, Debugger);

  fInterpreter := Interpreter;
  fDebugger    := Debugger as TfrmPCodeDebugger;
//Assert(aOwner is TfrmPCodeDebuggerCustom, 'Code needs to be fixed');
  SendMessage(fDebugger.Handle, MSG_INSPECTOR_ADDED, LongInt(self), 0);
end;

destructor TfrmInspect.Destroy;
begin
  fDebugger.DebuggerSettings.WindowsList.AddWindow(self, edtWatchName.Text, 0);
  inherited;
end;

procedure TfrmInspect.FormShow(Sender: TObject);
var
  SplitterPos: integer;
begin
  inherited;
  with fDebugger.DebuggerSettings.WindowsList do
    LoadWindowInfo(self, edtWatchName.Text, SplitterPos);
end;

procedure TfrmInspect.SetWatchValue(Value: string);
const
  COL_ADDR = 0;
  COL_NAME = 1;
  COL_VALUE = 2;
var
  PrefixInfo, aField, NewValue: string;
  Fields: TFieldArray;
  CP, R: integer;
  Count: system.integer;
  ItemNr: word;
begin
  inherited;
  cp := Pos(':', Value);
  PrefixInfo            := Copy(Value, 1, cp-1);
  lblPrefixInfo.Caption := PrefixInfo;
  Value                 := Copy(Value, cp+1, MAXINT); // Get the tail which follows the ':'
  Parse_Delimited_Line (Value, Fields, count, Delimited_Info);

  sgValues.RowCount := Count + 1;
  with sgValues do
    begin
      Cells[COL_ADDR, 0]  := '#';
      Cells[COL_NAME, 0]  := 'Name';
      Cells[COL_VALUE, 0] := 'Value';

      ItemNr := 0;
      for R := 1 to Count do
        begin
          Cells[COL_ADDR, R] := IntToStr(ItemNr);
          aField := Fields[r-1];
          cp := Pos('=', aField);
          if cp > 0 then
            begin
              Cells[COL_NAME, R]  := Copy(aField, 1, cp-1);
              NewValue            := Copy(aField, cp+1, MAXINT);
              fChangedValues[R]   := NewValue <> Cells[COL_VALUE, R];
              Cells[COL_VALUE, R] := NewValue;
            end
          else
            begin
              Cells[COL_VALUE, R] := aField;
            end;

          Inc(ItemNr, 1);
        end;
      AdjustColumnWidths(sgValues);
    end;
end;

procedure TfrmInspect.UpdateStatus(const aCaption: string; aColor: TColor);
begin
  inherited;
  lblStatus.Caption := aCaption;
  lblStatus.Color   := aColor;
end;

procedure TfrmInspect.sgValuesDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  GridDrawCell(sgValues, fChangedValues, ACol, ARow, Rect);
end;

procedure TfrmInspect.Panel1Resize(Sender: TObject);
begin
  inherited;
  AdjustColumnWidths(sgValues);
end;

initialization
  Delimited_Info.QuoteChar := '''';
  Delimited_Info.Field_Seperator := ',';
end.
