unit LoadVersion;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Interp_Const, pSysVolumes,
{$IfDef debugging}
  DebuggerSettingsUnit,
{$EndIf}
  DBCtrls;

const
  mrAdd  = mrYesToAll + 1;
  mrSAVE = mrAdd + 1;

type
  TNavigatePush = TNavigateBtn;
  TBootParams = class;

  TNavigateClickProc = procedure {Name}(ClickType: TNavigatePush) of object;
  TBootInterpreter = procedure {whatever}(RecentBootParams: TBootParams) of object;

  TBootParams = class(TCollectionItem)
  private
    fComment: string;
    fIsDebugging: boolean;
    fLastBootedDateTime: TDateTime;
    fVolumesToMount: string;
    fRefCount: integer;
    fSettingsFileToUse: string;
    fUseCInterp: boolean;
    fUnitNumber: integer;
    fVolumeName: string;
    fVersionNr: TVersionNr;
    fVolumeFileName: string;

    procedure SetVolumeName(const Value: string);
    procedure SetVolumesToMount(const Value: string);
    procedure SetVolumeFileName(const Value: string);
  protected
    // ============================================================================================
    // ============================================================================================
    procedure Clear;
  public
    procedure Assign(Source: TPersistent); override; // TBootParams: REMEMBER TO UPDATE THIS IF CHANGES ARE MADE
    Constructor Create(Collection: TCollection); override;
  published
    function IsClean: boolean;

    property IsDebugging: boolean
             read fIsDebugging
             write fIsDebugging;
    property VolumeName  : string
             read fVolumeName
             write SetVolumeName;
    property VolumeFileName: string
             read fVolumeFileName
             write SetVolumeFileName;
    property UnitNumber: integer
             read fUnitNumber
             write fUnitNumber;
    property VersionNr   :  TVersionNr
             read fVersionNr
             write fVersionNr;
    property UseCInterp  : boolean
             read fUseCInterp
             write fUseCInterp;
    property LastBootedDateTime: TDateTime
             read fLastBootedDateTime
             write fLastBootedDateTime;
    property RefCount: integer
             read fRefCount
             write fRefCount;
    property SettingsFileToUse: string      // no IfDef because absence will cause RTE if non-debugger tries to use debugger .INI
             read fSettingsFileToUse
             write fSettingsFileToUse;
    property Comment: string
             read fComment
             write fComment;
    property VolumesToMount: string
             read fVolumesToMount
             write SetVolumesToMount;
    // end TBootParams: REMEMBER TO CHANGE THE ASSIGN PROCEDURE
  end;

  TRecentBootsList = class(TCollection) { TBootParams }
  private
  public
    function FindBootItem( UnitNumber: integer;
                           const VolumeName, FileName: string;
                           VersionNr: TVersionNr;
                           UseCinterp: Boolean;
                           const SettingsFileToUse: string): integer; overload;
    function FindBootItem( const BootParams: TBootParams): integer; overload;
    function FindBootItemByFileName(const FileName: string): TBootParams;
    function FindLatestBootItem: TBootParams;
    procedure CleanUpList;
    function GetBootItemFromVolumeName(VolumeName: string): TBootParams;
    function IsSame(BootParam1, BootParam2: TBootParams): boolean;
  end;

  TfrmLoadVersion = class(TForm)
    rgDerivation: TRadioGroup;
    rgVersion: TRadioGroup;
    btnBoot: TButton;
    btnCancel: TButton;
    edtFilePath: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblLastBootedDateTime: TLabel;
    Label4: TLabel;
    lblVolumeName: TLabel;
    pnlNavigate: TPanel;
    btnPrev: TButton;
    btnNext: TButton;
    btnAdd: TButton;
    edtSettingsFileToUse: TEdit;
    btnBrowseFilePath: TButton;
    btnDelete: TButton;
    edtComment: TEdit;
    Label5: TLabel;
    cbUnitNumber: TComboBox;
    Label3: TLabel;
    btnSave: TButton;
    btnBrowseSettingsFileToUse: TButton;
    lblSettingsFileToUse: TLabel;
    lblFileDoesNotExist: TLabel;
    btnVolumesToMount: TButton;
    lblVolumesToMount: TLabel;
    cbIsDebugging: TCheckBox;
    procedure rgDerivationClick(Sender: TObject);
    procedure btnBootClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure rgVersionClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnBrowseFilePathClick(Sender: TObject);
    procedure DoOnFieldExit(Sender: TObject);
    procedure cbUnitNumberChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSaveClick(Sender: TObject);
    procedure btnBrowseSettingsFileToUseClick(Sender: TObject);
    procedure btnVolumesToMountClick(Sender: TObject);
  private
    { Private declarations }
{$IfDef debugging}
    fDebuggerSettings      : TDEBUGGERSettings;       // Is this still necessary? I don't think so.
{$EndIf}
    fMaintaining           : boolean;
    fRecentBootParams      : TBootParams;
    fVolumesList           : TVolumesList;
    fOnNavigateClick       : TNavigateClickProc;
    fVersionNr             : TVersionNr;
    fVolumeName            : string;
    fVolumesToMount        : string;
    
    function GetSelectedUseCInterp: boolean;
    function GetSelectedVersionNr: TVersionNr;
    procedure SetSelectedUseCInterp(const Value: boolean);
    procedure SetSelectedVersionNr(const Value: TVersionNr);
    function GetRecentBootParams: TBootParams;
    procedure SetRecentBootParams(const Value: TBootParams);
    function GetVersionNr: TVersionNr;
    procedure SetUseCInterp(const Value: boolean);
    procedure SetVersionNr(const Value: TVersionNr);
    procedure SetVolumeName(const Value: string);
    function GetUseCInterp: boolean;
    function GetUnitNumber: integer;
    procedure SetUnitNumber(const Value: integer);
    procedure SetOnNavigateClick(const Value: TNavigateClickProc);
    procedure SetSettingsFileToUse(const Value: string);
    function GetVolumeFileName: string;
    procedure SetVolumeFileName(const Value: string);
    function GetVolumeName: string;
    function GetComment: string;
    procedure SetComment(const Value: string);
    procedure UpdateRecentBootParams;
{$IfDef debugging}
    procedure LoadDEBUGGERSettingsFile;
{$endIf debugging}
    function GetVolumesToMount: string;
    procedure SetVolumesToMount(const Value: string);
    function GetSettingsFileToUse: string;
    function GetIsDebugging: boolean;
    procedure SetIsDebugging(const Value: boolean);
//  function CSVFilesToLoadFileName(VersionNr: TVersionNr): string;
  public
    { Public declarations }
    RecNo: integer;

    Constructor Create( aOwner: TComponent;
                        VolumesList: TVolumesList); reintroduce;
    Destructor Destroy; override;
    procedure Enable_Buttons;
    procedure InitDropDowns;

    property RecentBootparams: TBootParams
             read GetRecentBootParams
             write SetRecentBootParams;
    property UseCInterp: boolean
             read GetUseCInterp
             write SetUseCInterp;
    property SelectedVersionNr: TVersionNr
             read GetSelectedVersionNr
             write SetSelectedVersionNr;
    property SelectedUseCInterp: boolean
             read GetSelectedUseCInterp
             write SetSelectedUseCInterp;
    property VersionNr: TVersionNr
             read GetVersionNr
             write SetVersionNr;
    property UnitNumber: integer
             read GetUnitNumber
             write SetUnitNumber;
    property VolumeName: string      // 'VOLNAME'
             read GetVolumeName
             write SetVolumeName;
    property VolumeFileName: string  // this should be coming from the DEBUGGER.INI info
             read GetVolumeFileName
             write SetVolumeFileName;
    property Comment: string
             read GetComment
             write SetComment;
    property SettingsFileToUse: string
             read GetSettingsFileToUse
             write SetSettingsFileToUse;
    property OnNavigateClick: TNavigateClickProc
             read fOnNavigateClick
             write SetOnNavigateClick;
    property VolumesToMount: string
             read GetVolumesToMount
             write SetVolumesToMount;
    property IsDebugging: boolean
             read GetIsDebugging
             write SetIsDebugging;
  end;  // TfrmLoadVersion

var
  frmLoadVersion: TfrmLoadVersion;

implementation

uses Interp_Decl, MyUtils, FilerSettingsUnit, MyTables_Decl, PsysUnit,
  pSysVolumesNonStandard,
{$IfDef debugging}
  DebuggerSettingsForm,
{$EndIf}
  pSysDatesAndTimes, FilerMain, VolumesToMount, Misc, pSys_Const,
  FileNames;

{$R *.dfm}

{ TfrmLoadVersion }

procedure TfrmLoadVersion.InitDropDowns;
var
  vNr: TVersionNr;
  u: integer;
  s: string;
begin
  with rgVersion do
    begin
      items.Clear;
      for vNr := Succ(vn_Unknown) to High(TVersionNr) do
        Items.AddObject(VersionNrStrings[vNr].Name, TObject(vNr));
    end;

  with cbUnitNumber do
    begin
      Clear;
      for u := 4 to 13 do
        if u in [4,5,9..13] then
          begin
            s := IntToStr(u);
            cbUnitNumber.AddItem(s, TObject(u));
          end;
    end;

{$IfDef debugging}
  LoadDEBUGGERSettingsFile;
{$else}
  lblSettingsFileToUse.Visible       := false;
  edtSettingsFileToUse.Visible       := false;
  btnBrowseSettingsFileToUse.Visible := false;
{$EndIf}

  Enable_Buttons;
end;

constructor TfrmLoadVersion.Create( aOwner: TComponent;
                                    VolumesList: TVolumesList);
begin
  inherited Create(aOwner);
  fVolumesList := VolumesList;

  InitDropDowns;

  btnSave.ModalResult     := mrSAVE;
{$IfNDef debugging}
  lblFileDoesNotExist.visible := false;
{$endIf}  
end;

procedure TfrmLoadVersion.Enable_Buttons();
const
  lbVersions = [vn_VersionI_4, vn_VersionI_5, vn_VersionIV{, vn_VersionIV_12}]; // vn_VersionIV_12 does not work
  pmVersions = [vn_VersionI_4, vn_VersionI_5, vn_VersionII];
var
  Idx: integer;
  vn: TVersionNr;
begin
  with rgDerivation do
    case ItemIndex of
      0: { Load Laurence Boshell derived version}
        with rgVersion do
          begin
            for vn := Succ(Low(TVersionNr)) to High(TVersionNr) do
              begin
                Idx := Items.IndexOfObject(TObject(vn));
                if Idx >= 0 then
                  Buttons[Idx].Enabled := TVersionNr(Items.Objects[Idx]) in lbVersions;
              end;
          end;
      1: { Load Peter Miller derived version }
        with rgVersion do
          begin
            for vn := Succ(Low(TVersionNr)) to High(TVersionNr) do
              begin
                Idx := Items.IndexOfObject(TObject(vn));
                if Idx >= 0 then
                  Buttons[Idx].Enabled := TVersionNr(Items.Objects[Idx]) in pmVersions;
              end;
          end;
    end;
  btnBoot.Enabled := (SelectedVersionNr <> vn_Unknown) and
                     (not Empty(VolumeFileName)) and
{$IfDef debugging}
                     (not Empty(SettingsFileToUse)) and
{$EndIf}
                     (Assigned(fRecentBootParams));
  btnDelete.Enabled := FilerSettings.RecentBootsList.Count > 0
end;


function TfrmLoadVersion.GetRecentBootParams: TBootParams;
begin
  result                    := fRecentBootParams;

  result.UseCInterp         := UseCInterp;
  result.VolumeName         := VolumeName;
  result.VersionNr          := VersionNr;
  result.UnitNumber         := UnitNumber;
  result.SettingsFileToUse  := SettingsFileToUse;
  result.Comment            := Comment;
  result.VolumesToMount     := VolumesToMount;
  result.LastBootedDateTime := Now();
end;

function TfrmLoadVersion.GetSelectedUseCInterp: boolean;
begin
  result := false;
  with rgDerivation do
    case ItemIndex of
      0: result := false;
      1: result := true;
    end;
end;

function TfrmLoadVersion.GetSelectedVersionNr: TVersionNr;
begin
  with rgVersion do
    begin
      if ItemIndex >= 0 then
        result := TVersionNr(Items.objects[ItemIndex])
      else
        result := vn_Unknown;
    end;
end;

procedure TfrmLoadVersion.rgDerivationClick(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmLoadVersion.SetRecentBootParams(const Value: TBootParams);
begin
  fRecentBootParams  := Value;

  if Assigned(Value) then
    begin
      UseCInterp         := Value.fUseCInterp;
      UnitNumber         := Value.fUnitNumber;
      VolumeName         := Value.fVolumeName;
      VersionNr          := Value.fVersionNr;
      VolumeFileName     := Value.fVolumeFileName;
      SettingsFileToUse  := Value.fSettingsFileToUse;
      Comment            := Value.fComment;
      VolumesToMount     := Value.fVolumesToMount;
      IsDebugging        := Value.IsDebugging;

      lblLastBootedDateTime.Caption := DateTimeToStr(Value.fLastBootedDateTime);
    end
  else
    begin
      UseCInterp         := false;
      VolumeName         := '';
      VolumeFileName     := '';
      SettingsFileToUse  := '';
      Comment            := '';
      IsDebugging        := false;

      lblLastBootedDateTime.Caption := '';
    end;
  Enable_Buttons;
end;

procedure TfrmLoadVersion.SetSelectedUseCInterp(const Value: boolean);
begin
  with rgDerivation do
    case Value of
      false: ItemIndex := 0;
      true:  ItemIndex := 1;
    end;
  Enable_Buttons;
end;

procedure TfrmLoadVersion.SetSelectedVersionNr(const Value: TVersionNr);
var
  Idx: integer;
begin
  with rgVersion do
    begin
      idx := integer(Items.IndexOfObject(TObject(Value)));
      if Idx >= 0 then
        ItemIndex := Idx;
//    cbEnableExternalPool.Enabled := Value in [vn_VersionIV, vn_VersionIV_12];
    end;
  Enable_Buttons;
end;

function TfrmLoadVersion.GetUnitNumber: integer;
begin
  with cbUnitNumber do
    begin
      if ItemIndex >= 0 then
        result := Integer(Items.Objects[ItemIndex])
      else
        result := 4;
    end;
end;

procedure TfrmLoadVersion.SetUnitNumber(const Value: integer);
var
  idx: integer;
begin
  with cbUnitNumber do
    begin
      idx := Items.IndexOfObject(TObject(Value));
      if Idx >= 0 then
        ItemIndex := Idx;
    end;
  Enable_Buttons;
end;

function TfrmLoadVersion.GetVolumeName: string;
begin
  result := fVolumeName;
end;

function TfrmLoadVersion.GetVolumeFileName: string;
begin
  result := edtFilePath.Text;
end;

procedure TfrmLoadVersion.SetVolumeFileName(const Value: string);
var
  TempVolume: TVolume;
begin
  edtFilePath.Text       := Value;

  // We need to know the VolumeName
  TempVolume := CreateVolume( self, Value, VersionNr);
  try
    TempVolume.LoadVolumeInfo(DIRECTORY_BLOCKNR);
    VolumeName := TempVolume.VolumeName;   // update lblVolumeName.Text
  finally
    FreeAndNil(TempVolume);
  end;

  Enable_Buttons;
end;

procedure TfrmLoadVersion.SetOnNavigateClick(
  const Value: TNavigateClickProc);
begin
  fOnNavigateClick    := Value;
  fMaintaining        := Assigned(Value);
  pnlNavigate.Visible := fMaintaining;
  btnSave.Visible     := fMaintaining;
  btnBoot.Visible     := not fMaintaining;
  btnSave.ModalResult := mrSave;
(*
  if fMaintaining then
    begin
      btnOk.Caption       := 'Close';
      btnOk.ModalResult   := mrSave;
    end
  else
    begin
      btnOk.Caption       := 'Boot';
      btnOk.ModalResult   := mrOK;
    end;
*)
end;

destructor TfrmLoadVersion.Destroy;
begin
  frmLoadVersion := nil;
{$IfDef debugging}
  FreeAndNil(fDebuggerSettings); // free the temporary copy
{$endIf debugging}
  inherited;
end;

function TfrmLoadVersion.GetComment: string;
begin
  result := edtComment.Text;
end;

procedure TfrmLoadVersion.SetComment(const Value: string);
begin
  edtComment.Text := Value;
end;

function TfrmLoadVersion.GetVolumesToMount: string;
begin
  result := fVolumesToMount;
end;

procedure TfrmLoadVersion.SetVolumesToMount(const Value: string);
begin
  fVolumesToMount := Value;

  lblVolumesToMount.Caption := fVolumesToMount;
end;

function TfrmLoadVersion.GetSettingsFileToUse: string;
begin
  result := edtSettingsFileToUse.Text;
end;

function TfrmLoadVersion.GetIsDebugging: boolean;
begin
   result := cbIsDebugging.Checked; 
end;

procedure TfrmLoadVersion.SetIsDebugging(const Value: boolean);
begin
  cbIsDebugging.Checked := Value;
end;

{ TBootParams }

function TfrmLoadVersion.GetUseCInterp: boolean;
begin
  result := rgDerivation.buttons[1].Checked;
end;

function TfrmLoadVersion.GetVersionNr: TVersionNr;
begin
  result := GetSelectedVersionNr;
end;

procedure TfrmLoadVersion.SetUseCInterp(const Value: boolean);
begin
  case Value of
    false: rgDerivation.Buttons[0].Checked := true;
    true:  rgDerivation.Buttons[1].Checked := true;
  end;
  Enable_Buttons;
end;

procedure TfrmLoadVersion.SetVersionNr(const Value: TVersionNr);
begin
  if Value <> fVersionNr then
    begin
      SelectedVersionNr := Value;
      fVersionNr        := Value;
      edtSettingsFileToUse.Text := DEBUGGERSettingsFileName(Value);
//    VolumesToMount    := CSVFilesToLoadFileName(Value);
      Enable_Buttons;
    end;
end;

procedure TfrmLoadVersion.SetVolumeName(const Value: string);
begin
  fVolumeName := Value;
  lblVolumeName.Caption      := Format('%s:', [Value]);
end;

procedure TfrmLoadVersion.UpdateRecentBootParams;
var
  Idx: integer;
  NewBootParams: TBootParams;
begin
  fRecentBootParams.UseCInterp         := UseCInterp;
  fRecentBootParams.VolumeName         := VolumeName;
  fRecentBootParams.VersionNr          := VersionNr;

  if UnitNumber > 0 then
    fRecentBootParams.UnitNumber       := UnitNumber
  else
    fRecentBootParams.UnitNumber       := 4;  // was not specified. Assume unit number 4

  fRecentBootParams.VolumeFileName     := VolumeFileName;
  fRecentBootParams.fSettingsFileToUse := SettingsFileToUse;
  fRecentBootParams.Comment            := Comment;
  fRecentBootParams.LastBootedDateTime := Now();

  Idx := FilerSettings.RecentBootsList.FindBootItem(fRecentBootParams);
  if Idx >= 0 then // It already exists and is probably already up to date
    (FilerSettings.RecentBootsList.Items[Idx] as TBootParams).Assign(fRecentBootParams)
  else
    begin
      NewBootParams := FilerSettings.RecentBootsList.Add as TBootParams;
      NewBootParams.Assign(fRecentBootParams);
    end;
end;


procedure TfrmLoadVersion.btnBootClick(Sender: TObject);
begin
  UpdateRecentBootParams;
end;

procedure TfrmLoadVersion.SetSettingsFileToUse(const Value: string);
begin
  edtSettingsFileToUse.Text := Value;
end;

{ TBootParams }

procedure TBootParams.Assign(Source: TPersistent);
var
  Src: TBootParams;
begin
  Src := Source as TBootParams;

  fUseCInterp         := src.fUseCInterp;
  fVolumeName         := src.fVolumeName;
  fVersionNr          := src.fVersionNr;
  fLastBootedDateTime := src.fLastBootedDateTime;
  fUnitNumber         := src.fUnitNumber;
  fVolumeFileName     := src.fVolumeFileName;
  fRefCount           := src.fRefCount;
  fSettingsFileToUse  := src.fSettingsFileToUse;
  fComment            := src.fComment;
  fVolumesToMount     := src.fVolumesToMount;
  fIsDebugging        := src.fIsDebugging;
end;

procedure TfrmLoadVersion.btnPrevClick(Sender: TObject);
begin
  if Assigned(fOnNavigateClick) then
    fOnNavigateClick(nbPrior);
end;

procedure TfrmLoadVersion.btnNextClick(Sender: TObject);
begin
  if Assigned(fOnNavigateClick) then
    fOnNavigateClick(nbNext);
end;

procedure TBootParams.Clear;
begin
  VolumeName           := '';
  VolumeFileName       := '';
  UnitNumber           := 4;
  VersionNr            := vn_Unknown;
  UseCInterp           := false;
  LastBootedDateTime   := BAD_DATE;
  RefCount             := 0;
  fSettingsFileToUse   := '';
  Comment              := '';
end;

Constructor TBootParams.Create(Collection: TCollection);
begin
  inherited;
end;

function TBootParams.IsClean: boolean;
begin
  result := (not Empty(VolumeName)) and
            (not Empty(VolumeFileName)) and
            (IsIdentifier(VolumeName)) and
{$IfDef debugging}
            (not Empty(SettingsFileToUse)) and
            (FileExists(SettingsFileToUse)) and
{$EndIf}
            (UnitNumber in [4, 5, 9..MAX_FILER_UNITNR]) and
            (VersionNr <> vn_Unknown);
end;

procedure TBootParams.SetVolumeFileName(const Value: string);
begin
  fVolumeFileName := Value;
end;

procedure TBootParams.SetVolumeName(const Value: string);
begin
  fVolumeName := Value;
end;

procedure TBootParams.SetVolumesToMount(const Value: string);
begin
  fVolumesToMount := Value;
end;

{ TRecentBootsList }

function TRecentBootsList.IsSame(BootParam1, BootParam2: TBootParams): boolean;
begin
  result := SameText(BootParam1.VolumeName,     BootParam2.VolumeName) and
            SameText(BootParam1.VolumeFileName, BootParam2.VolumeFileName) and
            (BootParam1.UnitNumber     = BootParam2.UnitNumber) and
            (BootParam1.VersionNr      = BootParam2.VersionNr) and
            (BootParam1.VolumesToMount = BootParam2.VolumesToMount) and
{$IfDef Debugging}
            SameText(bootParam1.SettingsFileToUse, BootParam2.SettingsFileToUse) and
{$EndIf Debugging}
            (BootParam1.UseCInterp     = BootParam2.UseCInterp) and
            SameText(BootParam1.Comment, BootParam2.Comment);
end;


function TRecentBootsList.GetBootItemFromVolumeName(VolumeName: string): TBootParams;
var
  i: integer;
begin
  result := nil;
  for i := 0 to Count-1 do
    begin
      if SameText(VolumeName, (Items[i] as TBootParams).VolumeName) then
        begin
          result := Items[i] as TBootParams;
          break;
        end;
    end;
end;

procedure TRecentBootsList.CleanUpList;
type
  TSortInfo = record
                VerNrVal: smallint;
                OrgIndex: smallint;
              end;
var
  i: integer;
  j: integer;
  vn: TVersionNr;
  VersionNrVals: array[0..100] of TSortInfo;
  Temp: TSortInfo;
  TempList: TRecentBootsList;
  anItem: TBootParams;
//UseCInterp1, UseCInterp2: boolean;
begin
  // Get rid of malformed items
  for i := Count-1 downto 0 do
    with Items[i] as TBootParams do
      if not IsClean then
        Delete(i);

  // Sort the collection items by VersionNr 

  FillChar(VersionNrVals, Sizeof(VersionNrVals), 0);

  for i := 0 to Count-1 do
    begin
      vn := TBootParams(Items[i]).VersionNr;
      with VersionNrVals[i] do
        begin
          VerNrVal := VersionNrStrings[vn].xNumVal;
          OrgIndex := i;
        end;
    end;

  // sort based on the numeric value of the VersionNr
  for i := 0 to Count-2 do
    for j := i + 1 to Count-1 do
      begin
//      UseCInterp1 := TBootParams(Items[i]).UseCInterp;
//      UseCInterp2 := TBootParams(Items[j]).UseCInterp;

        if (VersionNrVals[i].VerNrVal > VersionNrVals[j].VerNrVal) {and (UseCInterp1 > UseCInterp2)} then
          begin
            temp             := VersionNrVals[i];
            VersionNrVals[i] := VersionNrVals[j];
            VersionNrVals[j] := temp;
          end;
      end;

  // Get rid of duplicates
  for i := Count-1 DownTo 1 do
    if IsSame(TBootParams(Items[i]), TBootParams(Items[i-1])) then
      Delete(i);

  // create a temporary list that is sorted by VersionNr and Derivation author
  TempList := TRecentBootsList.Create(TBootParams);
  try
    for i := 0 to Count-1 do
      begin
        AnItem := TempList.Add as TBootParams;
        AnItem.Assign(Items[VersionNrVals[i].OrgIndex]);  // Copy to the temporary list
      end;

    self.Assign(TempList);
  finally
    FreeAndNil(TempList);
  end;

end;

procedure TfrmLoadVersion.rgVersionClick(Sender: TObject);
var
  vNr: TVersionNr;
  i: integer;
begin
  with Sender as TRadioGroup do
    begin
      // get rid of previous yellow
      for i := 0 to Items.Count-1 do
        Buttons[i].Color := clBtnFace;

      // just a reminder that this may not be working
      if ItemIndex >= 0 then
        begin
          vNr        := TVersionNr(Items.Objects[ItemIndex]);
          VersionNr  := vNr;
          if vNr = vn_VersionIV_12 then
            with Buttons[ItemIndex] do
              Color := clYellow;
        end;
    end;
{$IfDef debugging}
  LoadDEBUGGERSettingsFile;   // Is this really necessary? I don't think so.
{$endIf debugging}
end;

procedure TfrmLoadVersion.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmLoadVersion.btnDeleteClick(Sender: TObject);
begin
  if Assigned(fOnNavigateClick) then
    fOnNavigateClick(nbDelete);
end;

procedure TfrmLoadVersion.btnBrowseFilePathClick(Sender: TObject);
var
  Lfn: string;
begin
  Lfn := edtFilePath.Text;
  if BrowseForFile('Browse for Volume', Lfn, VOL_EXT, VOLUMEFILTERLIST) then
    begin
//    edtFilePath.Text := Lfn;
      VolumeFileName := Lfn;
      Enable_Buttons;
    end;
end;

function TRecentBootsList.FindBootItem(UnitNumber: integer;
                                       const VolumeName, FileName: string;
                                       VersionNr: TVersionNr;
                                       UseCinterp: Boolean;
                                       const SettingsFileToUse: string): integer;
var
  i: integer;
  bi: TBootParams;
begin
  for i := 0 to Count-1 do
    begin
      bi := Items[i] as TBootParams;
      if (UnitNumber = bi.fUnitNumber) and
         (SameText(VolumeName, bi.fVolumeName)) and
         (SameText(FileName,   bi.fVolumeFileName)) and
         (VersionNr  = bi.VersionNr) and
         UseCInterp  = bi.fUseCInterp and
         SameText(SettingsFileToUse, bi.SettingsFileToUse) then
         begin
           result := i;
           exit;
         end
    end;
  result := -1;
end;

function TRecentBootsList.FindBootItem(
  const BootParams: TBootParams): integer;
var
  i: integer;
  bi: TBootParams;
begin
  for i := 0 to Count-1 do
    begin
      bi := Items[i] as TBootParams;
      if (BootParams.UnitNumber = bi.fUnitNumber) and
         (SameText(BootParams.VolumeName, bi.fVolumeName)) and
         (SameText(BootParams.VolumeFileName,   bi.fVolumeFileName)) and
{$IfDef debugging}
         (SameText(BootParams.SettingsFileToUse, bi.SettingsFileToUse)) and
{$EndIf}
         (BootParams.VersionNr  = bi.VersionNr) and
         (BootParams.UseCInterp = bi.fUseCInterp) then
         begin
           result := i;
           exit;
         end
    end;
  result := -1;
end;

{$IfDef debugging}
procedure TfrmLoadVersion.LoadDEBUGGERSettingsFile();
var
  Lfn: string;
begin
  Lfn := edtSettingsFileToUse.Text;
  FreeAndNil(fDebuggerSettings);
  fDebuggerSettings := TDEBUGGERSettings.Create(self);
  if VersionNr <> vn_Unknown then
    begin
      if Empty(SettingsFileToUse) then
        SettingsFileToUse := DebuggerSettingsFileName(VersionNr);

      if FileExists(SettingsFileToUse) then
        begin
          lblFileDoesNotExist.visible := false;
          fDebuggerSettings.LoadFromFile(SettingsFileToUse);
        end
      else
        lblFileDoesNotExist.visible := true;
    end;
end;
{$endIf debugging}


procedure TfrmLoadVersion.DoOnFieldExit(Sender: TObject);
begin
{$IfDef debugging}
  LoadDEBUGGERSettingsFile;  // Is this still necessary? I don' think so
{$endIf debugging}
  Enable_Buttons;
end;

procedure TfrmLoadVersion.cbUnitNumberChange(Sender: TObject);
var
  u: integer;
begin
  with cbUnitNumber do
    begin
      if ItemIndex >= 0 then
        begin
          u := Integer(Items.Objects[ItemIndex]);
          if Assigned(fVolumesList[u].TheVolume) and (Empty(edtFilePath.Text)) then
            begin
//            edtFilePath.Text      := fVolumesList[u].TheVolume.DOSFileName;
              VolumeFileName        := fVolumesList[u].TheVolume.DOSFileName;
//            VolumeName            := fVolumesList[u].VolumeName;  // automatically changed when VolumeFileName is changed
              lblVolumeName.Caption := VolumeName;
            end;
          Enable_Buttons;
        end;
    end;
end;

procedure TfrmLoadVersion.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if fMaintaining then
    Action := caFree
end;

procedure TfrmLoadVersion.btnSaveClick(Sender: TObject);
begin
  UpdateRecentBootParams;
end;

procedure TfrmLoadVersion.btnBrowseSettingsFileToUseClick(Sender: TObject);
var
  Lfn: string;
begin
  Lfn := edtSettingsFileToUse.Text;
  if BrowseForFile('Browse for Debugger Settings File', Lfn, INI_EXT) then
    begin
      edtSettingsFileToUse.Text := Lfn;
      Enable_Buttons;
    end;
end;

procedure TfrmLoadVersion.btnVolumesToMountClick(Sender: TObject);
var
  frmVolumesToMount: TfrmVolumesToMount;
begin
  frmVolumesToMount := TfrmVolumesToMount.Create(self, fVolumesList);

  try
    frmVolumesToMount.BootVolume              := VolumeFileName;
    frmVolumesToMount.VersionNr               := VersionNr;
    frmVolumesToMount.VolumeName              := VolumeName;
    frmVolumesToMount.UnitNumber              := UnitNumber;
    frmVolumesToMount.CSVListOfVolumesToMount := VolumesToMount; // This loads the grid
    if frmVolumesToMount.ShowModal = mrOk then
      VolumesToMount := frmVolumesToMount.CSVListOfVolumesToMount;
  finally
    FreeAndNil(frmVolumesToMount);
  end;
end;

function TRecentBootsList.FindBootItemByFileName(
  const FileName: string): TBootParams;
var
  i: integer;
begin
  result := nil;
  for i := 0 to Count-1 do
    begin
      if SameText(FileName, (Items[i] as TBootParams).VolumeFileName) then
        begin
          result := Items[i] as TBootParams;
          break;
        end;
    end;
end;

function TRecentBootsList.FindLatestBootItem: TBootParams;
var
  i: integer;
  aBootParams: TBootParams;
  LatestDateTime: TDateTime;
begin
  result := nil;
  LatestDateTime := BAD_DATE;
  for i := 0 to Count-1 do
    begin
      aBootParams := Items[i] as TBootParams;
      if aBootParams.LastBootedDateTime > LatestDateTime then
        begin
          LatestDateTime := aBootParams.LastBootedDateTime;
          result         := aBootParams;
        end;
    end;
end;

end.
