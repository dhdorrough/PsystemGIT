unit SearchForString;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, pSysUnit, Search_Decl, MyUtils;

type

  TfrmSearchForString = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    leLowDate: TLabeledEdit;
    leHighDate: TLabeledEdit;
    lblStatus: TLabel;
    pnlAsciiSearch: TPanel;
    cbCaseSensitive: TCheckBox;
    cbIgnoreUnderScores: TCheckBox;
    cbOnlySearchFileNames: TCheckBox;
    cbLogMountingErrors: TCheckBox;
    cbKeywordSearch: TCheckBox;
    pnlKeyType: TPanel;
    rbAll: TRadioButton;
    rbAny: TRadioButton;
    lblMode: TLabel;
    edtSearchFor: TEdit;
    rgMode: TRadioGroup;
    cbWildMatch: TCheckBox;
    procedure rbAsciiClick(Sender: TObject);
    procedure rbHexClick(Sender: TObject);
    procedure rbVolumeVersionClick(Sender: TObject);
    procedure cbKeywordSearchClick(Sender: TObject);
    procedure rbReportCrtInfoClick(Sender: TObject);
    procedure rgModeClick(Sender: TObject);
  private
//    fSearchFor: string;
    fNrHexBytes: integer;
    fHexBytes: THexBytes;
    function GetSearchFor: string;
    procedure SetSearchFor(const Value: string);
    function GetLowDate: TDateTime;
    procedure SetLowDate(const Value: TDateTime);
    function GetHighDate: TDateTime;
    procedure SetHighDate(const Value: TDateTime);
    function GetSearchMode: TSearchMode;
    procedure SetSearchMode(const Value: TSearchMode);
    function GetHexBytes: THexBytes;
    procedure SetHexBytes(const Value: THexBytes);
    function HexBytes2ASCII(HexBytes: THexBytes;
      NrHexBytes: integer): string;
    function GetKeyWordSearch: boolean;
    procedure SetKeyWordSearch(const Value: boolean);
    function GetCaseSensitive: boolean;
    procedure SetCaseSensitive(const Value: boolean);
    function GetLogMountingErrors: boolean;
    procedure SetLogMountingErrors(const Value: boolean);
    function GetIgnoreUnderScores: boolean;
    procedure SetIgnoreUnderScores(const Value: boolean);
    function GetOnlySearchFileNames: boolean;
    procedure SetOnlySearchFileNames(const Value: boolean);
    function GetAllKeyWords: boolean;
    function GetAnyKeywords: boolean;
    procedure SetAllKeyWords(const Value: boolean);
    procedure SetAnyKeyWords(const Value: boolean);
    procedure Enable_Buttons;
{$IfDef PoolInfo}
    procedure rbPoolInfoClick(Sender: TObject);
{$EndIf}
{$IfDef ProcInfo}
    procedure rbProcedureClick(Sender: TObject);
{$EndIf ProcInfo}
    procedure rbSegmentClickClck(Sender: TObject);
    function GetWildMatch: boolean;
    procedure SetWildMatch(const Value: boolean);
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
    Destructor Destroy; override;
    property SearchFor: string
             read GetSearchFor
             write SetSearchFor;
    property HexBytes: THexBytes
             read GetHexBytes
             write SetHexBytes;
    property LowDate: TDateTime
            read GetLowDate
            write SetLowDate;
    property HighDate: TDateTime
            read GetHighDate
            write SetHighDate;
    property SearchMode: TSearchMode
             read GetSearchMode
             write SetSearchMode;
    property WildMatch: boolean
             read GetWildMatch
             write SetWildMatch;
    property NrHexBytes: integer
             read fNrHexBytes
             write fNrHexBytes;
    property KeyWordSearch: boolean
             read GetKeyWordSearch
             write SetKeyWordSearch;
    property CaseSensitive: boolean
             read GetCaseSensitive
             write SetCaseSensitive;
    property LogMountingErrors: boolean
             read GetLogMountingErrors
             write SetLogMountingErrors;
    property IgnoreUnderScores: boolean
             read GetIgnoreUnderScores
             write SetIgnoreUnderScores;
    property OnlySearchFileNames: boolean
             read GetOnlySearchFileNames
             write SetOnlySearchFileNames;
    property AllKeyWords: boolean
             read GetAllKeyWords
             write SetAllKeyWords;
    property AnyKeyWords: boolean
             read GetAnyKeywords
             write SetAnyKeyWords;
  end;

var
  frmSearchForString: TfrmSearchForString;

implementation

uses Misc, pSysDatesAndTimes, MiscinfoUnit;

{$R *.dfm}

function TfrmSearchForString.GetHighDate: TDateTime;
begin
  if not Empty(leHighDate.Text) then
    try
      result := StrToDateTime(leHighDate.Text);
    except
      AlertFmt('Invalid high date/time: %s', [leHighDate.Text]);
      result := BAD_DATE;
    end
  else
    result := BAD_DATE;
end;

function TfrmSearchForString.GetLowDate: TDateTime;
begin
  if not Empty(leLowDate.Text) then
    try
      result := StrToDateTime(leLowDate.Text);
    except
      AlertFmt('Invalid low date/time: %s', [leLowDate.Text]);
      result := BAD_DATE;
    end
  else
    result := BAD_DATE;
end;

function TfrmSearchForString.GetSearchMode: TSearchMode;
begin
  with rgMode do
    if ItemIndex >= 0 then
      result := TSearchMode(Items.Objects[ItemIndex])
    else
      result := smUnknown;;
end;

function TfrmSearchForString.GetSearchFor: string;
begin
  result := edtSearchFor.Text;
end;

function TfrmSearchForString.HexBytes2ASCII(HexBytes: THexBytes; NrHexBytes: integer): string;
var
  i: integer;
begin
  result := '';
  for i := 0 to NrHexBytes-1 do
    result := result + HexByte(HexBytes[i]) + ' ';
end;


procedure TfrmSearchForString.rbAsciiClick(Sender: TObject);
var
  s: string;
begin
  pnlAsciiSearch.Visible := true;
  cbOnlySearchFileNames.Enabled := TRUE;

  Caption := 'Search volumes for ASCII string';

  lblMode.Caption := 'ASCII string';

  // try convert the ASCII string to hex

  try
    s := edtSearchFor.Text;
    fNrHexBytes := ConvHexStr(s, fHexBytes);
    edtSearchFor.Text := s;
  except
    on e:Exception do
      lblStatus.Caption := e.Message;
  end;

end;

procedure TfrmSearchForString.rbHexClick(Sender: TObject);
var
  i: integer; s: string;
begin
  lblMode.Caption   := 'HEX string';
  Caption := 'Search volumes for HEX string';

  pnlAsciiSearch.Visible := false;
  cbOnlySearchFileNames.Enabled := FALSE;

  s := edtSearchFor.Text;

  NrHexBytes := Length(s);
  for i := 1 to length(s) do
    fHexBytes[i-1] := ord(s[i]);

  edtSearchFor.text := HexBytes2Ascii(fHexBytes, NrHexBytes);
end;

procedure TfrmSearchForString.SetHighDate(const Value: TDateTime);
begin
  leHighDate.Text := DateTimeToStr(Value);
end;

procedure TfrmSearchForString.SetLowDate(const Value: TDateTime);
begin
  leLowDate.Text := DateTimeToStr(Value);
end;

procedure TfrmSearchForString.SetSearchMode(const Value: TSearchMode);
var
  Idx: integer;
begin
  with rgMode do
    begin
      idx := Items.IndexOfObject(TObject(Value));
      if Idx >= 0 then
        ItemIndex := Idx;
    end;
end;

procedure TfrmSearchForString.SetSearchFor(const Value: string);
begin
  edtSearchFor.Text := value;
end;

function TfrmSearchForString.GetHexBytes: THexBytes;
begin
  fNrHexBytes := ConvHexStr(edtSearchFor.Text, result);
end;

procedure TfrmSearchForString.SetHexBytes(const Value: THexBytes);
begin

end;

function TfrmSearchForString.GetKeyWordSearch: boolean;
begin
  result := cbKeyWordSearch.Checked;
end;

procedure TfrmSearchForString.SetKeyWordSearch(const Value: boolean);
begin
  cbKeyWordSearch.Checked := Value;
end;

function TfrmSearchForString.GetCaseSensitive: boolean;
begin
  result := cbCaseSensitive.Checked;
end;

procedure TfrmSearchForString.SetCaseSensitive(const Value: boolean);
begin
  cbCaseSensitive.Checked := Value;
end;

function TfrmSearchForString.GetLogMountingErrors: boolean;
begin
  result := cbLogMountingErrors.Checked;
end;

procedure TfrmSearchForString.SetLogMountingErrors(const Value: boolean);
begin
  cbLogMountingErrors.Checked := value;
end;

function TfrmSearchForString.GetIgnoreUnderScores: boolean;
begin
  result := cbIgnoreUnderScores.Checked;
end;

procedure TfrmSearchForString.SetIgnoreUnderScores(const Value: boolean);
begin
  cbIgnoreUnderScores.Checked := Value;
end;

procedure TfrmSearchForString.rbVolumeVersionClick(Sender: TObject);
begin
  Caption         := 'Report of Version Nr Info';
  pnlAsciiSearch.Visible := false;
  lblMode.Caption        := 'Code file wild card';
  cbOnlySearchFileNames.Enabled := FALSE;
  edtSearchFor.text := '';
end;

{$IfDef ProcInfo}
procedure TfrmSearchForString.rbProcedureClick(Sender: TObject);
begin
  Caption         := 'Report of procedures in segments';
  pnlAsciiSearch.Visible := false;
  lblMode.Caption        := 'Code file wild card';
  cbOnlySearchFileNames.Enabled := FALSE;
  edtSearchFor.text := '';
end;
{$EndIf ProcInfo}

procedure TfrmSearchForString.rbSegmentClickClck(Sender: TObject);
begin
  Caption         := 'Report of Segments in Code Files';
  pnlAsciiSearch.Visible := false;
  lblMode.Caption        := 'Code file wild card';
  cbOnlySearchFileNames.Enabled := FALSE;
  edtSearchFor.text := '';
end;

{$IfDef PoolInfo}
procedure TfrmSearchForString.rbPoolInfoClick(Sender: TObject);
begin
  Caption                := 'Report of PoolInfo contained in SYSTEM.MISCINFO';
  pnlAsciiSearch.Visible := false;
  lblMode.Caption        := 'MISCINFO wild card';
  edtSearchFor.text      := '*.MISCINFO';
  cbOnlySearchFileNames.Enabled := FALSE;
end;
{$EndIf PoolInfo}


function TfrmSearchForString.GetOnlySearchFileNames: boolean;
begin
  result := cbOnlySearchFileNames.Checked;
end;

procedure TfrmSearchForString.SetOnlySearchFileNames(const Value: boolean);
begin
  cbOnlySearchFileNames.Checked := Value;
end;

procedure TfrmSearchForString.cbKeywordSearchClick(Sender: TObject);
begin
  pnlKeyType.Visible := cbKeywordSearch.Checked;
end;

function TfrmSearchForString.GetAllKeyWords: boolean;
begin
  result := rbAll.Checked;
end;

function TfrmSearchForString.GetAnyKeywords: boolean;
begin
   result := rbAny.Checked;
end;

procedure TfrmSearchForString.SetAllKeyWords(const Value: boolean);
begin
  rbAll.Checked := Value;
end;

procedure TfrmSearchForString.SetAnyKeyWords(const Value: boolean);
begin
  rbAny.Checked := Value;
end;

procedure TfrmSearchForString.rbReportCrtInfoClick(Sender: TObject);
begin
  Caption           := Format('Report %s on selected volumes', [CSYSTEM_MISCINFO]);
  edtSearchFor.text := '*.MISCINFO';
  lblMode.Caption   := 'Filename *.MISCINFO';
  cbOnlySearchFileNames.Enabled := TRUE;
  pnlAsciiSearch.Visible := false;
end;

constructor TfrmSearchForString.Create(aOwner: TComponent);
var
  sm: TSearchMode;
begin
  inherited;
  for sm := Succ(Low(TSearchMode)) to High(TSearchMode) do
    rgMode.Items.AddObject(SearchModeNames[sm]+' Report', TObject(sm))
end;

destructor TfrmSearchForString.Destroy;
begin
  inherited;
end;

procedure TfrmSearchForString.rgModeClick(Sender: TObject);
begin
  case SearchMode of
    smCrtInfo, smKeyInfo:
      rbReportCrtInfoClick(Sender);
    smAscii:
      rbAsciiClick(Sender);
    smHex:
      rbHexClick(Sender);
    smVersionNumber:
      rbVolumeVersionClick(Sender);
{$IfDef SegInfo}
    smSegments:
      rbSegmentClickClck(Sender);
{$endIf SegInfo}
{$IfDef ProcInfo}
    smProcedures:
      rbProcedureClick(Sender);
{$EndIf}
{$IfDef PoolInfo}
    smPoolInfo:
      rbPoolInfoClick(Sender);
{$EndIf PoolInfo}
  end;
  Enable_Buttons;
end;

procedure TfrmSearchForString.Enable_Buttons;
begin
  btnOK.Enabled := SearchMode <> smUnknown;
end;

function TfrmSearchForString.GetWildMatch: boolean;
begin
  result := cbWildMatch.Checked;
end;

procedure TfrmSearchForString.SetWildMatch(const Value: boolean);
begin
  cbWildMatch.Checked := Value;
end;

end.
