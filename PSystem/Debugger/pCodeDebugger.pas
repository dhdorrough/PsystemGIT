// You may need to install the 32-bit AccessDatabaseEngine:
//  https://download.microsoft.com/download/2/4/3/24375141-E08D-4803-AB0E-10F2E3A07AAA/AccessDatabaseEngine.exe
unit pCodeDebugger;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Menus, StdCtrls, Grids, UCSDGlob, Buttons, ExtCtrls, UCSDglbu,
  FilerTables, Debug_Decl, pSys_Decl, DB, LocalVariables,
  MyUtils, Watch_Decl, pSysWindow, pCodeDecoderUnit,
  pSysVolumes, pCodeDebugger_Decl, Interp_Decl, WindowsList, Interp_Const,
  LoadVersion, DebuggerSettingsUnit, DebuggerSettingsForm;

type
  TSetOfIdentCode = set of TIdentCode;

  TOffsetsList = array of integer;  // Tempting to make this "array of word" (to prevent signed/unsigned comparisons)
                                    // but this will cause the line cursor to be
                                    // mis-positioned on empty lines

  TfrmPCodeDebugger = class(TfrmPCodeDebuggerCustom)
    MainMenu1: TMainMenu;
    Edit1: TMenuItem;
    GoTo1: TMenuItem;
    Replace1: TMenuItem;
    Find1: TMenuItem;
    N2: TMenuItem;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    N3: TMenuItem;
    Undo1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    HowtoUseHelp1: TMenuItem;
    SearchforHelpOn1: TMenuItem;
    Contents1: TMenuItem;
    File1: TMenuItem;
    Exit1: TMenuItem;         
    N7: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N8: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Run1: TMenuItem;
    Breakpoints1: TMenuItem;
    RuntoCursor1: TMenuItem;
    Stepinto1: TMenuItem;
    StepOver1: TMenuItem;
    Toggle1: TMenuItem;
    Deleteall1: TMenuItem;
    Changedmemoryglobal1: TMenuItem;
    Expressiontrueglobal1: TMenuItem;
    N1: TMenuItem;
    DisplayBreakpoints1: TMenuItem;
    EditBreakpoint1: TMenuItem;
    DeleteBreakpoint1: TMenuItem;
    AddBreakpoint1: TMenuItem;
    pumBreakPoints: TPopupMenu;
    EditBreakPoint2: TMenuItem;
    DeleteBreakPoint2: TMenuItem;
    AddBreakpoint2: TMenuItem;
    Run3: TMenuItem;
    pumPCode1: TPopupMenu;
    ToggleBreakpoint1: TMenuItem;
    RuntoHere1: TMenuItem;
    N4: TMenuItem;
    PasteExternalpCode1: TMenuItem;
    N5: TMenuItem;
    Copy2: TMenuItem;
    Paste2: TMenuItem;
    Cut2: TMenuItem;
    SaveUpdatedpCode1: TMenuItem;
    N6: TMenuItem;
    PasteExternalpCode2: TMenuItem;
    ToggleEnabled1: TMenuItem;
    UpdateCursor1: TMenuItem;
    N9: TMenuItem;
    pumSourceCode: TPopupMenu;
    miToggleBreakPoint: TMenuItem;
    miRunToHere: TMenuItem;
    MenuItem3: TMenuItem;
    miPasteExternalSourceCode: TMenuItem;
    miSaveUpdatedSourceCode: TMenuItem;
    MenuItem6: TMenuItem;
    miMemo3Copy: TMenuItem;
    miMemo3Paste: TMenuItem;
    miMemo3Cut: TMenuItem;
    PageControl1: TPageControl;
    tabPCode: TTabSheet;
    tabBreakPoints: TTabSheet;
    sgBreakPoints: TStringGrid;
    RunUntilReturn1: TMenuItem;
    N10: TMenuItem;
    EnableMemoEditing1: TMenuItem;
    N11: TMenuItem;
    FindinMemo1: TMenuItem;
    FindDialog1: TFindDialog;
    SelectAll1: TMenuItem;
    SelectAll2: TMenuItem;
    ProgramReset1: TMenuItem;
    ExternalDecoderWindow1: TMenuItem;
    tabSysCom: TTabSheet;
    memoSyscom: TMemo;
    FindAgain1: TMenuItem;
    FindAgain2: TMenuItem;
    N12: TMenuItem;
    FindinMemo2: TMenuItem;
    FindAgain3: TMenuItem;
    Undo2: TMenuItem;
    Undo3: TMenuItem;
    tabHistory: TTabSheet;
    sgHistory: TStringGrid;
    leMaxHistory: TLabeledEdit;
    N13: TMenuItem;
    miSearchAll: TMenuItem;
    sgPHITS: TStringGrid;
    lblOpsPHITS: TLabel;
    lblPHITS: TLabel;
    lblDbgCnt: TLabel;
    Panel1: TPanel;
    sgRegisters: TStringGrid;
    Panel2: TPanel;
    Memo1: TMemo;
    Memo3: TMemo;
    Splitter1: TSplitter;
    N14: TMenuItem;
    SaveSettings1: TMenuItem;
    DeleteAllBreakpoints1: TMenuItem;
    sgCSPPhits: TStringGrid;
    lbpCSPPHITS: TLabel;
    lblCSPPHITS: TLabel;
    Panel3: TPanel;
    sgWatchList: TStringGrid;
    pumWatchList: TPopupMenu;
    AddWatchItem1: TMenuItem;
    DeleteWatchItem1: TMenuItem;
    EditWatchItem1: TMenuItem;
    Panel4: TPanel;
    sgStatic: TStringGrid;
    sgPStack: TStringGrid;
    N15: TMenuItem;
    miInspect: TMenuItem;
    N16: TMenuItem;
    CopyWatchName1: TMenuItem;
    CopyWatchValue1: TMenuItem;
    N17: TMenuItem;
    SaveSettings2: TMenuItem;
    DeleteAllWatches1: TMenuItem;
    lblStatus: TLabel;
    cbCallHistoryOnly: TCheckBox;
    lblRowCol: TLabel;
    Watches1: TMenuItem;
    miLocalVariables: TMenuItem;
    miGlobalVariables: TMenuItem;
    btnMoveUp: TBitBtn;
    btnMoveDown: TBitBtn;
    lblEditMode: TLabel;
    SaveDBInfoToTextFiles: TMenuItem;
    pumCallStack: TPopupMenu;
    LoadProcedure1: TMenuItem;
    ViewMSCW1: TMenuItem;
    DisplayLocalVariables1: TMenuItem;
    DisplayGlobalVariables1: TMenuItem;
    tabMessages: TTabSheet;
    sgMessages: TStringGrid;
    PrintcurrentpCode1: TMenuItem;
    PrintcurrentSourceCode1: TMenuItem;
    PrintWatchList1: TMenuItem;
    PrintBreakpointList1: TMenuItem;
    PrintSyscom1: TMenuItem;
    PrintMessages1: TMenuItem;
    CreateInspector1: TMenuItem;
    N19: TMenuItem;
    cbOffsetInHex: TCheckBox;
    cbAddrInHex: TCheckBox;
    N20: TMenuItem;
    CreateInspector2: TMenuItem;
    btnResetOpsPhits: TButton;
    btnResetCspPhits: TButton;
    DisableAllWatches1: TMenuItem;
    DisableAllBreakpoints1: TMenuItem;
    ToggleAllBreakpoints1: TMenuItem;
    pumPHITS: TPopupMenu;
    Sort1: TMenuItem;
    Alphabetically1: TMenuItem;
    BYphits1: TMenuItem;
    byOPCode1: TMenuItem;
    ExitFaultHandler1: TMenuItem;
    tabProfile: TTabSheet;
    sgProfile: TStringGrid;
    pumProfile: TPopupMenu;
    SortbyCount1: TMenuItem;
    SortbyProcName1: TMenuItem;
    SortbySegName1: TMenuItem;
    lblTotal: TLabel;
    Label3: TLabel;
    btnReset: TButton;
    btnRefresh: TButton;
    tabDirectory: TTabSheet;
    sgDirectory: TStringGrid;
    lblDirectory: TLabel;
    PrintGlobalDirectory1: TMenuItem;
    Utilities1: TMenuItem;
    SegnamesProcnames1: TMenuItem;
    VerifySegnamesProcNames1: TMenuItem;
    SaveSegnamesProcnamestoDB1: TMenuItem;
    ReloadSegNamesProcnames1: TMenuItem;
    ListProcNames1: TMenuItem;
    AddProcName1: TMenuItem;
    PrintSegmentProcNames1: TMenuItem;
    PrintSegmentProcNames3: TMenuItem;
    PrintHistory1: TMenuItem;
    PrintOpsPHITS1: TMenuItem;
    PrintCSPPhits1: TMenuItem;
    PrintDynamicCallStack1: TMenuItem;
    PrintStaticCallStack1: TMenuItem;
    PrintStack1: TMenuItem;
    leSyscomAddr: TLabeledEdit;
    N23: TMenuItem;
    lblReminder: TLabel;
    Label1: TLabel;
    N24: TMenuItem;
    FindStringinMemory1: TMenuItem;
    FindDialog2: TFindDialog;
    RefreshDisplay1: TMenuItem;
    Label2: TLabel;
    PrintRegisters1: TMenuItem;
    CloseBreakpointLogfile1: TMenuItem;
    TabCrtKeyInfo: TTabSheet;
    MemoCrtKeyInfo: TMemo;
    DisplayaSYSCOMMISCINFO1: TMenuItem;
    pCodeProcsTableforUpdate1: TMenuItem;
    Load1: TMenuItem;
    miLoadFromLast: TMenuItem;
    lblAccDb: TLabel;
    BreakonpHits0: TMenuItem;
    DashBoard1: TMenuItem;
    DumpDebugInfo1: TMenuItem;
    DebuggerDatabases1: TMenuItem;
    CatalogDebuggerDatabases1: TMenuItem;
    DebuggerSettings1: TMenuItem;
    sgCallStack: TStringGrid;
    ListingUtilities1: TMenuItem;
    CatalogDebuggerDatabases2: TMenuItem;
    ListFileUtilities1: TMenuItem;
    NewDatabase1: TMenuItem;
    ScanCodeFilesandUpdateDB1: TMenuItem;
    procedure DisplayBreakpoints1Click(Sender: TObject);
    procedure EditBreakpoint1Click(Sender: TObject);
    procedure AddBreakpoint2Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DeleteBreakPoint2Click(Sender: TObject);
    procedure Run3Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Stepinto1Click(Sender: TObject);
    procedure StepOver1Click(Sender: TObject);
    procedure RuntoCursorClick(Sender: TObject);
    procedure ToggleBreakpoint1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PasteExternalpCode1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Paste2Click(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure Cut2Click(Sender: TObject);
    procedure SaveUpdatedpCode1Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure ToggleEnabled1Click(Sender: TObject);
    procedure UpdateCursor1Click(Sender: TObject);
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure miMemo3CopyClick(Sender: TObject);
    procedure miMemo3PasteClick(Sender: TObject);
    procedure miMemo3CutClick(Sender: TObject);
    procedure MemoClick(Sender: TObject);
    procedure RunUntilReturn1Click(Sender: TObject);
    procedure miRunToHereClick(Sender: TObject);
    procedure RuntoHere1Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure EnableMemoEditing1Click(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FindInMemoClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure pumPopup(Sender: TObject);
    procedure ProgramReset1Click(Sender: TObject);
    procedure Memo3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RuntoCursor1Click(Sender: TObject);
    procedure ExternalDecoderWindow1Click(Sender: TObject);
    procedure FindAgainClick(Sender: TObject);
    procedure UndoClick(Sender: TObject);
    procedure leMaxHistoryChange(Sender: TObject);
    procedure SaveSettings1Click(Sender: TObject);
    procedure DeleteAllBreakpoints1Click(Sender: TObject);
    procedure AddWatchItem1Click(Sender: TObject);
    procedure EditWatchItem1Click(Sender: TObject);
    procedure DeleteWatchItem1Click(Sender: TObject);
    procedure sgWatchListDblClick(Sender: TObject);
    procedure miInspectClick(Sender: TObject);
    procedure CopyWatchName1Click(Sender: TObject);
    procedure CopyWatchValue1Click(Sender: TObject);
    procedure DeleteAllWatches1Click(Sender: TObject);
    procedure DeleteBreakpoint1Click(Sender: TObject);
    procedure sgCallStackDblClick(Sender: TObject);
    procedure cbCallHistoryOnlyClick(Sender: TObject);
    procedure sgHistoryDblClick(Sender: TObject);
    procedure miSearchAllClick(Sender: TObject);
    procedure sgStaticDblClick(Sender: TObject);
    procedure miLocalVariablesClick(Sender: TObject);
    procedure miGlobalVariablesClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lblStatusDblClick(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure SaveDBToTextFiles(Sender: TObject);
    procedure LoadProcedure1Click(Sender: TObject);
    procedure sgCallStackClick(Sender: TObject);
    procedure ViewMSCW1Click(Sender: TObject);
    procedure miDisplayLocalIntermediate(Sender: TObject);
    procedure PrintMessages1Click(Sender: TObject);
    procedure PrintcurrentpCode1Click(Sender: TObject);
    procedure PrintcurrentSourceCode1Click(Sender: TObject);
    procedure PrintSyscom1Click(Sender: TObject);
    procedure PrintWatchList1Click(Sender: TObject);
    procedure PrintBreakpointList1Click(Sender: TObject);
    procedure CreateInspector1Click(Sender: TObject);
    procedure miDisplayGlobalIntermediate(Sender: TObject);
    procedure cbOffsetInHexClick(Sender: TObject);
    procedure cbAddrInHexClick(Sender: TObject);
    procedure CreateInspector2Click(Sender: TObject);
    procedure sgWatchListDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnResetOpsPhitsClick(Sender: TObject);
    procedure btnResetCspPhitsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DisableAllBreakpoints1Click(Sender: TObject);
    procedure ToggleAllBreakpoints1Click(Sender: TObject);
    procedure Alphabetically1Click(Sender: TObject);
    procedure BYphits1Click(Sender: TObject);
    procedure byOPCode1Click(Sender: TObject);
    procedure sgCallStackDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgStaticDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ExitFaultHandler1Click(Sender: TObject);
    procedure SortbyCount1Click(Sender: TObject);
    procedure SortbyProcName1Click(Sender: TObject);
    procedure SortbySegName1Click(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure PrintGlobalDirectory1Click(Sender: TObject);
    procedure VerifySegnamesProcNames1Click(Sender: TObject);
    procedure ReloadSegNamesProcnames1Click(Sender: TObject);
    procedure ListProcNames1Click(Sender: TObject);
    procedure AddProcName1Click(Sender: TObject);
    procedure PrintSegmentProcNames1Click(Sender: TObject);
    procedure PrintHistory1Click(Sender: TObject);
    procedure PrintOpsPHITS1Click(Sender: TObject);
    procedure PrintCSPPhits1Click(Sender: TObject);
    procedure PrintDynamicCallStack1Click(Sender: TObject);
    procedure PrintStaticCallStack1Click(Sender: TObject);
    procedure PrintStack1Click(Sender: TObject);
    procedure leSyscomAddrExit(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure FindStringinMemory1Click(Sender: TObject);
    procedure FindDialog2Find(Sender: TObject);
    procedure RefreshDisplay1Click(Sender: TObject);
    procedure PrintRegisters1Click(Sender: TObject);
    procedure CloseBreakpointLogfile1Click(Sender: TObject);
    procedure Breakpoints1Click(Sender: TObject);
    procedure PasteExternalpCode2Click(Sender: TObject);
    procedure miPasteExternalSourceCodeClick(Sender: TObject);
    procedure sgDirectoryDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DisplayaSYSCOMMISCINFO1Click(Sender: TObject);
    procedure DumpDebugInfo1Click(Sender: TObject);
    procedure miLoadClick(Sender: TObject);
    procedure miLoadFromLastClick(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure BreakonpHits0Click(Sender: TObject);
    procedure DashBoard1Click(Sender: TObject);
    procedure sgBreakPointsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DebuggerDatabases1Click(Sender: TObject);
    procedure DebuggerSettings1Click(Sender: TObject);
    procedure CatalogDebuggerDatabasesClick(Sender: TObject);
    procedure ListingUtilities1Click(Sender: TObject);
    procedure ScanCodeFilesandUpdateDB1Click(Sender: TObject);
  private
    { Private declarations }
    fBlobStream      : TStream;
    fBrk             : TBrk;
    fCSGrid          : TStringGrid;
    fChangedWatches  : TChangedRows;
    fExitingProcsDyn : TChangedRows;
    fExitingProcsStat: TChangedRows;
    fFrmDebuggerDatabasesList: TObject;
    fBadDates        : TChangedRows;
    fDisabledBreaks  : TChangedRows;
    fFindIdx         : longint;
    fInspectorList   : TInspectorList;
    fKeyDownRow      : word;
    fKeyDownCol      : word;
    fLastSegBase     : longword;
    fLoadedSegName   : string;
    fLoadedProcName  : string;

    fNumberOfMessages: integer;
    fpCodeDecoder    : TpCodeDecoder;
    fVariableWatchersList   : TFormsList;

    fPCodeOffsets    : TOffsetsList;
    fSearchFor       : string;
    fSourceCodeOffsets: TOffsetsList;
    fProcessingMemoLoad: boolean;
    fSavingPcode     : boolean;
    fSegNameIdx      : TSegNameIdx;
    fSelectedMemo    : TMemo;
    fUserOpenedProcIsLoaded: boolean;
    fUserOpenedIPC   : word;
    fLegalIdentCodes : TSetOfIdentCode;

    procedure DisplayBreakPoints;
{$IfDef Pocahontas}
    procedure DisplayPHITS;
{$EndIf}
    procedure EditBreakPointInfo(Idx: Integer);
    procedure DisplayMemoField(Memo: TMemo; MemoField: TMemoField;
                               SetFocus: boolean);
    procedure SetIPCOffsets(Memo: TMemo; var Offsets: TOffsetsList);
    procedure SelectMemoLine(Memo: TMemo; LineNr: word);
    procedure SetBrk(const Value: TBrk);
    function LineNrFromIPC(aIPC: word; Offsets: TOffsetsList): integer;
    function MemDumpDW( Addr: longword;
                        WatchType: TWatchType;
                        Param: word = 0;
                        const Msg: string = ''): string;
    function MemDumpDF( Addr: longword;
                        Form: string = 'W';
                        Param: word = 0;
                        const Msg: string = ''): string;
    procedure DisplayRegisters; virtual;
    function  RunToLineNumber(LineNo: integer; Offsets: TOffsetsList): TBrk;
    procedure CleanUpPostedPCode(Memo: TMemo);
    function CleanUpLine(Line: string): string;
    procedure SaveUpdatedPCode(DontAsk: boolean = false);
    procedure VCLMemoToFileMemo(Memo: TMemo; MemoField: TMemoField);
    procedure BeforeScroll(DataSet: TDataSet);
    procedure GetRowCol(Memo: TMemo; var Row, Col: word);
    procedure DisplayCursorPos(Memo: TMemo);
    procedure DisplayPCodeToPage;
    procedure SetIPCOffSetsToPage(Memo: TMemo = nil);
    procedure VCLMemoToFileMemoFromPage;
    procedure CleanUpPastedSource(Memo: TMemo; VersionNr: TVersionNr);
    procedure PasteToMemo(Memo: TMemo);
    function GetModified: boolean;
    function GetRelIPC: word; virtual;
    procedure SelectCurrentLine(Memo: TMemo; anIPC: word);
    function CodeOffset(Memo: TMemo): word;
    function CurrentMemo(Memo: TMemo= nil): TMemo;
    function GetSegNameIdx: TSegNameIdx; virtual;
    function SourceCode_Step: TBrk;
    function GetWordAt(P: word): word; virtual;
    procedure ClearDebuggerDisplay;
    procedure DisplaySyscom;
//  procedure CopyMemoToFile(MemoField: TMemoField; FilePath: string);
    procedure FindStringInMemo(Memo: TMemo; const SearchFor: string);
    procedure UndoMemoChange(Memo: TMemo);
    procedure DisplayHistory(HowMany: integer);
    procedure DisplayWatches;
    procedure UpdateSgWatchListRow(RowNr: integer;
                              const TypeVal, CodeVal, NameVal, AddrVal, ValueVal, CommentVal: string);
    procedure CallStackDblClick(Grid: TStringGrid; CSType: TMSCWFieldNr); virtual;
    function OpenProc(SegIdx: TSegNameIdx;
                      aProcNum: integer;
                      aProcName: string;
                      anIPC: word): boolean;
    procedure wmInspectorAdded(var Message: TMessage); message MSG_INSPECTOR_ADDED;
    procedure UnImplemented(const Msg: string); 
    property Brk: TBrk
             read fBrk
             write SetBrk;
    procedure ShowEditMode;
    procedure ViewMSCW(Grid: TStringGrid{; CSType: TMSCWFieldNr});
    function IPCWithinProcStr(anIPC, ErecAddr: word; ProcNr: integer): string;
    procedure InitMessagePage;
    procedure PrintMemo(Memo: TMemo; const OutFileName: string);
    procedure DisplayCspPHITS;
    procedure BackupSettings(const SettingsFileName: string);
    procedure SaveSettings(const FileName: string);
    procedure SortAlphabetically(Grid: TStringGrid);
    procedure SortOnOpCode(Grid: TStringGrid);
    procedure SortOnPHITS(Grid: TStringGrid);
    function GetGrid(Sender: TObject): TStringGrid;
    function GetProcBase: word;
    procedure Update_Status(const aCaption: string; aColor: TColor = clBtnFace);
    procedure Update_StatusFmt(const aCaption: string;
      Args: array of const; aColor: TColor = clBtnFace);
    procedure DisplayProfile;
    procedure ResetProfile;
    procedure DisplayIntermediate(Grid: TStringGrid; WindowsType: TWindowsTypes);
    procedure SetSegNameIdx(const Value: TSegNameIdx);
    procedure CloseOpenEdits;
    procedure AddProcCall(Grid: TStringGrid; MSCWAddr: word; const aLongName, anIpc: string);
    procedure DisplayVars(WindowsTypes: TWindowsTypes);
    function FindStringInMemory(const SearchFor: string): longint;
    procedure SetRowCol(Memo: TMemo; var Row, Col: word);
    procedure PasteFromListingClick(Sender: TObject);
    procedure PasteExternalSourceCode(VersionNr: TVersionNr);
    procedure DisplayCrtKeyInfo;
    procedure CrtKeyInfoStatusProc( const Msg: string;
                                    DoLog: boolean = true;
                                    DoStatus: boolean = true;
                                    Color: TColor = clBtnFace);
    function BackupDBToTextFiles(Version: TVersionNr): integer;
    procedure GetMemoLists(var pCodeList, SrcCodeList: TStringList);
    procedure ShowStatusMessage(Msg: string; Args: array of const);
    procedure LoadForm;
  protected
    procedure AddLine(const Line: string);
    procedure AddLineSeperator(anOpCode: word);
    function Caller(     Calls: integer;
                     Var aProcNum: integer;
                     var aSegIdx: TSegNameIdx): boolean; virtual;
    procedure DisplayCallStack(Grid: TStringGrid; CSType: TMSCWFieldNr; var fExitingProcs: TChangedRows); virtual;
    procedure DisplayGlobalDirectoryCommon(gDirpAddr: word);
    procedure DisplayGlobalDirectory; virtual;
    procedure DisplayPStack; virtual;
    function GetCallHistoryOnly: boolean; override;
    procedure SetCallHistoryOnly(const Value: boolean); override;
    function GetCurProc: integer; virtual;
//  function GetNextOpCode: word; virtual;
    function GetSegBase(MSCWAddr: word): longword; virtual;
    function GetSPReg: word; virtual;
    function IdentifierValue(IC: TIdentCode): longword; override;
    function IPCWithinProc(anIPC, ErecAddr: word; ProcNr: integer): word; virtual;
    function IsUserProg: boolean; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function ReformLine(var Line: string): string; virtual;
    function SegNameFromBase(SegBase: longword): string;
    function SegBase: Longword; virtual;
    function UpdatePCode(aProcName: string; MemoField: TMemoField): boolean; virtual;
    property VersionNr;
  public
    { Public declarations }

    procedure AddMessage( WatchIndex:integer;
                          SegNameIdx: TSegNameIdx;
                          ProcNum: word;
                          anIPC: word;
                          const Value: string = ''); override;
    function AddProcInfo( aSegNameIdx: TSegNameIdx;
                             const aSegName: string;
                             aProcNum: word;
                             aProcName: string;
                             DoAppend: boolean): boolean;
    function BreakonpHitsZero: boolean;
    property CurProc: integer
             read GetCurProc;
    Constructor Create( aOwner: TComponent;
                        aInterpreter: TObject;
                        VolumesList: TVolumesList;
                        anOnUpdateStatusProc: TStatusProc;
                        BootParams: TBootParams); override;
    Destructor Destroy; override;
    procedure DumpHistory;
    function FetchProcInfo(  aSegNameIdx: TSegNameIdx;
                             aProcNum: integer;
                             aProcName: string;
                             anIPC: word;
                             NoAdd: boolean): boolean;
    function TheSegNameIdx(SegBase: longword): TSegNameIdx; override;
    function LoggingToAFile: boolean;
    function ProcNameFromErec(MSProc: integer; ErecAddr: word): string; virtual;

    property ProcBase: word
             read GetProcBase;
    property RelIPC: word
             read GetRelIPC;

    property Modified: boolean
             read GetModified;
//  property NextOpCode: word
//           read GetNextOpCode;
    property SPReg: word
             read GetSPReg;
    property SegNameIdx: TSegNameIdx
             read GetSegNameIdx
             write SetSegNameIdx;
//  property AccDbFileNumber: integer   // Is this really the same thing as SelectedAccDbIndex?
//           read GetAccDbFileNumber
//           write SetAccDbFileNumber;
    procedure Enable_Run(value: boolean); override;
    procedure UpdateDebuggerDisplay; override;
    property WordAt[P: word]: word
             read GetWordAt;
  end;

  TfrmPCodeDebuggerII = class(TfrmPCodeDebugger)
  private
    fLastSegNum: integer;
    function GetRelIPC: word; override;
    procedure CallStackDblClick(Grid: TStringGrid; CSType: TMSCWFieldNr); override;
  protected
    function Caller(     Calls: integer;
                     Var aProcNum: integer;
                     var aSegIdx: TSegNameIdx): boolean; override;
    procedure DisplayCallStack(Grid: TStringGrid; CSType: TMSCWFieldNr; var fExitingProcs: TChangedRows); override;
    procedure DisplayGlobalDirectory; override;
    procedure DisplayPStack; override;
    procedure DisplayRegisters; override;
    function GetCurProc: integer; override;
//  function GetNextOpCode: word; override;
    function GetSegBase(MSCWAddr: word): longword; override;
    function GetSegNameIdx: TSegNameIdx; override;
    function GetSegTop(p: TMSCWPtr2): longword;
    function GetSPReg: word; override;
    function GetWordAt(P: word): word; override;
    function IdentifierValue(IC: TIdentCode): longword; override;
    procedure InitProcNames; override;
    function IsUserProg: boolean; override;
    procedure LoadProcedureNames; override;
    function ReformLine(var Line: string): string; override;
    function SegBase: Longword; override;
//  function UpdatePCode(aProcName: string; MemoField: TMemoField): boolean; override;
    property VersionNr;
  public
    function ProcNameFromErec(MSProc: integer; ErecAddr: word): string; override;
    Constructor Create( aOwner: TComponent;
                        aInterpreter: TObject;
                        VolumesList: TVolumesList;
                        anOnUpdateStatusProc: TStatusProc;
                        BootParams: TBootParams); override;
  end;

  TfrmPCodeDebuggerC = class(TfrmPCodeDebuggerII)
  private
  protected
    procedure DisplayCallStack(Grid: TStringGrid; CSType: TMSCWFieldNr; var fExitingProcs: TChangedRows); override;
    procedure DisplayGlobalDirectory; override;
    function IdentifierValue(IC: TIdentCode): longword; override;
  public
    Constructor Create( aOwner: TComponent;
                        aInterpreter: TObject;
                        VolumesList: TVolumesList;
                        anOnUpdateStatusProc: TStatusProc;
                        BootParams: TBootParams); override;
  end;

implementation

uses
  InterpIV, InterpII, InterpC, BreakPointInfo, MyTables,
  MyTables_Decl, DBTables, SelectProcedure,
  uGetString, Misc, DecodeWindow, Watch, Inspector,
  ClipBrd, uWatchInfo, PsysUnit, {SegmentProcname,}
  BitOps, pSysDatesAndTimes, DatabaseParams, DbDbUtils,
  pSysExceptions, Interp_Common, {DEBUGGERSettingsUnit,}
  {DEBUGGERSettingsForm,} FilerSettingsUnit, pCodeDecoderII, ListingUtils,
  OpsTables, CRTUnit, MiscinfoUnit, DBDatabase,
{$IfDef DashBoard}
  pSysDebugWindow,
{$EndIf}
  UCSDInterpreter, SegmentProcname, CatalogACCDBDatabases, FileNames,
  DebuggerDatabasesList, BuildDebugDB;

{$R *.dfm}

const
  TRANSLITERATE = true;

  { sgBreakPoints }
  COL_NR        = 0;
  COL_SEGNAME   = 1;
  COL_PROCNR    = 2;
  COL_PNAME     = 3;
  COL_BREAKKIND = 4;
  COL_IPC       = 5;
  COL_COMMENT   = 6;
  COL_DISABLED  = 7;
  COL_INFO      = 8;

  NRCOLS        = 9;

  { sgRegisters }
  ROW_CAPTION  = 0;
  ROW_SEGNAME  = 1;
  ROW_PROCNUM  = 2;
  ROW_PROCNAME = 3;
  ROW_RELIPC   = 4;
  ROW_ABSIPC   = 5;
  ROW_DBGCNT   = 6;
  ROW_OPCODE   = 7;
  ROW_OPNAME   = 8;
  ROW_REGS     = 9;

  { sgPStack }
  COL_ADDR   = 0;
  COL_HEXVAL = 1;
  COL_DECVAL = 2;
  COL_NIBVAL = 3;
  COL_ASCVAL = 4;

  { sgHistory }
  COL_HISTNR   = 0;
  COL_SEGNAME2 = 1;
  COL_PROCNR2  = 2;
  COL_PROCNAME = 3;
  COL_RELIPC   = 4;
  COL_OPCODENAME = 5;

  { sgWatchList }
  COL_WATCHTYPE = 0;
  COL_WATCHCODE = 1;
  COL_COMMENTVAL = 2;
  COL_WATCHADDR = 3;
  COL_WATCHVAL  = 4;
//COL_WATCHPARAM = 5;
//COL_WATCHNAME  = 6;

  { sgCallStack / sgStatic }
  COL_CsNr       = 0;
  COL_CsProcName = 1;
  COL_CsIpc      = 2;

  { sgMessages }
  MGCOL_DBGCNT     = 0;
  MGCOL_BREAKKIND  = 1;
  MGCOL_SEGNAME    = 2;
  MGCOL_PROCNAME   = 3;
  MGCOL_IPC        = 4;
  MGCOL_VALUE      = 5;

  PSTACK_NR_ROWS = 10;

  { PHITS }
  COL_PCODE   = 0;
  COL_PCODEX  = 1;
  COL_OPNAME  = 2;
  COL_PHITS   = 3;
  COL_PCT     = 4;

  COL_SEGNUMBER        = 1;
  COL_PROFILE_SEGNAME  = 2;
  COL_PROCNUMBER       = 3;
  COL_PROFILE_PROCNAME = 4;
  COL_PROFILE_COUNT    = 5;

type
  TStringGridHack = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
  end;

procedure TfrmPCodeDebugger.DisplayBreakPoints;
var
  idx, RowNr: integer;
  TargetIPC, Note: string;
  BreakInfo: TBreakInfo;
//LowAddr: word;

  procedure AddPhrase(const Phrase: string);
  begin
    if note = '' then
      Note := Phrase
    else
      Note := Note + ', ' + Phrase;
  end;

begin { TfrmPCodeDebugger.DisplayBreakPoints }
  with sgBreakPoints do
    begin
      RowCount := 2;
      ColCount := NRCOLS;
      Cells[COL_NR, 0]        := '#';
      Cells[COL_SEGNAME, 0]   := 'SegName';
      Cells[COL_PROCNR, 0]    := 'P #';
      Cells[COL_PNAME, 0]     := 'ProcName';
      Cells[COL_BREAKKIND, 0] := 'Break Kind';
      Cells[COL_IPC, 0]       := 'IPC';
      Cells[COL_COMMENT, 0]   := 'Comment';
      Cells[COL_DISABLED, 0]  := 'Enabled?';
      Cells[COL_INFO, 0]      := 'Note';

      with fInterpreter as TCustomPsystemInterpreter, DEBUGGERSettings do
        begin
          RowCount := Brks.Count + 1;
          if RowCount > 1 then
            FixedRows := 1;
          for idx := 0 to Brks.Count-1 do
            begin
              RowNr := idx + 1;
              BreakInfo := Brks.Items[idx] as TBreakInfo;
              with BreakInfo do
                begin
                  Cells[COL_NR, RowNr] := IntToStr(RowNr);
//                LowAddr              := WatchAddrFromExpression(AddrExpr);
                  case Brk of
                    dbMemChanged:
                      begin
                        Cells[COL_SEGNAME, RowNr]   := '';
                        Cells[COL_PROCNR, RowNr]    := '';
                        Cells[COL_PNAME, RowNr]     := Format('MemChanged: %d->%d ($%4x->$%4x)',
                                                              [LowAddr, LowAddr+NrBytes-1, LowAddr, LowAddr+NrBytes-1]);
                        Cells[COL_IPC, RowNr]       := '';
                      end;
                    dbDbgCnt, dbOpcode:
                      begin
                        Cells[COL_SEGNAME, RowNr]   := '';
                        Cells[COL_PROCNR, RowNr]    := '';
                        case Brk of
                          dbDbgCnt:
                            Cells[COL_PNAME, RowNr]     := Format('Break on DbgCnt = %6.0n', [Param*1.0]);
                          dbOpCode:
                            Cells[COL_PNAME, RowNr]     := Format('Break on OpCode = %d (%s)', [Param, OpsTable.Ops[Param].Name]);
                        end;
                        Cells[COL_IPC, RowNr]       := '';
                      end;
                    else
                      begin
                        Cells[COL_SEGNAME, RowNr]   := SegName;
                        Cells[COL_PROCNR, RowNr]    := IntToStr(TgtProc);

                        if TgtProc = ANYPROC then
                          Cells[COL_PNAME, RowNr]   := CANYPROC
                        else
                        if TgtProc = ANYUNSEEN then
                          Cells[COL_PNAME, RowNr]   := CANYUNSEEN
                        else
                          Cells[COL_PNAME, RowNr]   := ProcNamesF(SegNameIdx, TgtProc);

                        if Integer(TgtIPC) = ANYIPC then
                          TargetIPC := CANYIPC
                        else
                          TargetIPC := IntToStr(TgtIPC);
                        Cells[COL_IPC, RowNr]       := TargetIPC;
                      end
                  end;
                  Cells[COL_BREAKKIND, RowNr] := BreakKinds[Brk].BreakName;
                  Cells[COL_COMMENT, RowNr]   := Comment;

                  if Disabled then
                    Cells[COL_DISABLED, RowNr] := 'DISABLED'
                  else
                    Cells[COL_DISABLED, RowNr] := '';
                    
                  fDisabledBreaks[RowNr]     := Disabled;

                  Note := '';
                  if (PassCount > 0) or (nPassCount > 0) then
                    AddPhrase(Format('PassCount = %d/%d', [nPassCount, PassCount]));

                  if WatchType <> wt_Unknown then
                    AddPhrase(Format('WatchType = %s', [WatchTypesTable[WatchType].WatchName]));

                  if DoNotBreak then
                    AddPhrase('DoNotBreak');

                  if Indirect then
                    AddPhrase('Indirect');

                  if Brk = dbOpCode then
                    AddPhrase(Format('OpCode = %d ($%4.4x) :%s', [Param, Param, Opstable.Ops[Param].Name]))
                  else
                    if Param <> 0 then
                      AddPhrase(Format('Param = %6.0n', [Param*1.0]));

                  if LogMessage and LogToAFile then
                    with Collection as TBreakList do
                      AddPhrase(Format('Logging to file "%s"', [LogFileName])) else
                  if LogMessage then
                    AddPhrase('LogMessage');

                  Cells[COL_INFO, RowNr] := Note;
                end;
            end;
        end;
      AdjustColumnWidths(sgBreakPoints);
    end;
end;  { TfrmPCodeDebugger.DisplayBreakPoints }

procedure TfrmPCodeDebugger.DisplayBreakpoints1Click(Sender: TObject);
begin
  inherited;
  PageControl1.ActivePage := tabBreakPoints;
  DisplayBreakPoints;
end;

procedure TfrmPCodeDebugger.EditBreakPointInfo(Idx: integer);
var
  BrkItem: TBreakInfo;
  aLogFileName: String;
  frm: TfrmBreakPointInfo;
begin
  with DEBUGGERSettings do
    if Idx < 0 then  // creating a new breakpoint
      begin
        BrkItem := Brks.Add as TBreakInfo;
        with BrkItem do
          begin
            Idx      := Brks.Count - 1;
            with Brks.Items[idx] do
            with fInterpreter as TCustomPsystemInterpreter do
              begin
                SegName     := SegNameFromBase(SegBase);
                TgtProc     := {Globals.LowMem.}CurProc;
                TgtIpc      := RelIPC;
                Brk         := dbBREAK;
              end;
          end;
      end
    else
      BrkItem := Brks.Items[idx] as TBreakInfo;

  frm     := frmBreakPointInfo;
  with frm do
    begin
      frm.BrkNr           := Idx+1;
      frm.TheIPC          := BrkItem.TgtIPC;
      frm.BreakKind       := BrkItem.Brk;
      frm.Cmt             := BrkItem.Comment;
      frm.WatchType       := BrkItem.WatchType;
      frm.PassCount       := BrkItem.PassCount;
      frm.Disabled        := BrkItem.Disabled;
      frm.LogMessage      := BrkItem.LogMessage;
      frm.DoNotBreak      := BrkItem.DoNotBreak;
      frm.Indirect        := BrkItem.Indirect;
      frm.Param           := BrkItem.Param;

      // The order of the following two items (LogFileName, LogToAFile) is important
      frm.LogFileName     := DEBUGGERSettings.Brks.LogFileName;
      frm.LogToAFile      := BrkItem.LogToAFile;

      // The order of the following two items (SegName, ProcNum) may be important
      frm.SegName         := BrkItem.SegName; // [BrkItem.SegNameIdx, BrkItem.TgtProc];
      frm.ProcNum         := BrkItem.TgtProc;

      frm.AddrExpr        := BrkItem.AddrExpr;

      NrBytes   := BrkItem.NrBytes;

      if ShowModal = mrOk then
        begin
          BrkItem.Brk             := frm.BreakKind;
          BrkItem.TgtIPC          := frm.TheIPC;
          BrkItem.Comment         := frm.Cmt;
          BrkItem.AddrExpr        := frm.AddrExpr;
          BrkItem.NrBytes         := frm.NrBytes;
          BrkItem.WatchType       := frm.WatchType;
          BrkItem.PassCount       := frm.PassCount;
          BrkItem.Disabled        := frm.Disabled;
          BrkItem.LogMessage      := frm.LogMessage;
          BrkItem.DoNotBreak      := frm.DoNotBreak;
          BrkItem.Indirect        := frm.Indirect;
          BrkItem.Param           := frm.Param;

          BrkItem.SegName         := frm.SegName;
          BrkItem.TgtProc         := frm.ProcNum;
          DEBUGGERSettings.Brks.LogFileName := frm.LogFileName;

          if BrkItem.LogMessage then
            with BrkItem do
              begin
                if LogToAFile <> frm.LogToAFile then // it was changed
                  if LogToAFile then
                    OpenLogFile
                  else
                    CloseLogFile;
                LogToAFile      := frm.LogToAFile;
              end;

          if BreakKind = dbMemChanged then
            with fInterpreter as TCustomPsystemInterpreter do
              BrkItem.CheckSum      := BrkItem.CalcCheckSum(Bytes);

          DisplayBreakPoints;
          sgBreakPoints.Row := Idx + 1;   // Highlight the row we just edited

          if BrkItem.LogMessage and
             BrkItem.LogToAFile and       // we want to do it
             (not BrkItem.LoggingToAFile) then  // and we are not currently doing it
            if Yes('Do you want to log to a file?') then
              aLogFileName := DEBUGGERSettings.Brks.LogFileName
            else
              BrkItem.LogToAFile := false;
          SaveSettings(DEBUGGERSettingsFileName(VersionNr));
        end;
    end;
end;


procedure TfrmPCodeDebugger.EditBreakpoint1Click(Sender: TObject);
begin
  inherited;
  EditBreakPointInfo(sgBreakPoints.Row-1);
end;

procedure TfrmPCodeDebugger.BeforeScroll(DataSet: TDataSet);
begin
  if Modified then
    if (not fSavingPcode) then
      SaveUpdatedPCode(false)
end;

constructor TfrmPCodeDebugger.Create( aOwner: TComponent;
                                      aInterpreter: TObject;
                                      VolumesList: TVolumesList;
                                      anOnUpdateStatusProc: TStatusProc;
                                      BootParams: TBootParams);
var
  aMenuItem: TMenuItem;
  vn: TVersionNr;
  ErrorCount: integer;
  Msg: string;
begin { TfrmPCodeDebugger.Create }
  inherited Create(aOwner, aInterpreter, VolumesList, anOnUpdateStatusProc, BootParams);
  fOnStatusUpdate   := anOnUpdateStatusProc;

  fInterpreter      := aInterpreter;

  with fInterpreter as TCustomPsystemInterpreter do
    Caption         := Format('Version %s interpreter/debugger', [VersionNrStrings[VersionNr].Abbrev]);

  // Open ALL of the p-Code procedure tables
  with DEBUGGERSettings do
    begin
      if Assigned(fOnStatusUpdate) then
        fOnStatusUpdate('Loading debugging database', false, true, clYellow);

      ErrorCount := 0;

      fpCodesProcTable  := TpCodesProcTable.Create( self,
                                                    DatabaseToUse,
                                                    TableNamePCODEPROCS,
                                                    [optLevel12]);
      try
        fpCodesProcTable.Active := true;
        fpCodesProcTable.IndexFieldNames := IndexName_SEGNAME_PROC_NR_NAME_INDEX;
        fpCodesProcTable.BeforeScroll    := BeforeScroll;

        fpCodesProcTables.AddObject(DatabaseToUse, fpCodesProcTable);
        LoadProcedureNames;
      except
        on e:Exception do
          if Assigned(fOnStatusUpdate) then
            begin
              fOnStatusUpdate(e.Message, true, true, clYellow);
              SysUtils.Beep;
              Inc(ErrorCount);
            end;
          end;


      if Assigned(fOnStatusUpdate) then
        if ErrorCount = 0 then
          fOnStatusUpdate('Procedure Names loading complete', false, true)
        else
          begin
            Msg := Format('Unable to open %d table(s) (see listing on Filer Screen)',
                          [ErrorCount]);
            fOnStatusUpdate(Msg, true, true, clYellow);
            raise EFileNotFound.Create(Msg);
          end;

    end;
  frmBreakPointInfo := TfrmBreakPointInfo.Create(self, fInterpreter, DEBUGGERSettings);
  DisplayBreakPoints;
  DisplayWatches;
  PageControl1.ActivePageIndex := 0;
  Enable_Run(false);
  fMAXHIST        := DEBUGGERSettings.MaxHistoryItems;
  fInspectorList  := TInspectorList.Create;
  InitMessagePage;
  with aInterpreter as TCustomPsystemInterpreter do
    begin
//    EnableExternalPool1.Checked := EnableExternalPool;
      Caption     := Format('Version %s interpreter/debugger', [VersionNrStrings[VersionNr].Abbrev]);

      case VersionNr of
        vn_VersionI_4,
        vn_VersionI_5,
        vn_VersionII:
          fpCodeDecoder := TpCodeDecoderII.Create(self, OpsTable, VersionNr = vn_VersionII, VersionNr);

        vn_VersionIV{, vn_VersionIV_12}:
          fpCodeDecoder := TpCodeDecoder.Create(self, OpsTable, TRUE {DEBUGGING}, VersionNr);

        else
          raise EUnknownVersion.Create('Unknown VersionNr');
      end;

      with fpCodeDecoder do
        begin
          OnAddLine          := AddLine;
          OnAddLineSeparator := AddLineSeperator;
          OnGetByte3         := GetByteFromMemory;
          OnGetWord3         := GetWordFromMemory;
          OnGetJTAB          := GetJTAB;
          OnGetBaseAddress   := GetBaseAddress;
          OnGetCPOffset      := GetCPOffset;
          OnGetSegmentBase   := GetSegmentBaseAddress;
        end;
    end;

  fLegalIdentCodes := [ic_SP_LOW..ic_MemInfo];

  for vn := Succ(Low(TVersionNr)) to High(TVersionNr) do
    begin
      aMenuItem := TMenuItem.Create(miPasteExternalSourceCode);
      with aMenuItem do
        begin
          Caption := VersionNrStrings[vn].Abbrev + ' Listing';
          OnClick := PasteFromListingClick;
          Tag     := integer(vn);
        end;
      miPasteExternalSourceCode.Add(aMenuItem);
    end;

  // force the linker to include MemDump
  MemDumpDW(0, wt_Unknown);
  MemDumpDF(0, '');
end;  { TfrmPCodeDebugger.Create }

procedure TfrmPCodeDebugger.PasteFromListingClick(Sender: TObject);
var
  VersionNr: TVersionNr;
begin
  with Sender as TMenuItem do
    begin
      VersionNr := TVersionNr(Tag);
      PasteExternalSourceCode(VersionNr)
    end;
end;


destructor TfrmPCodeDebugger.Destroy;
var
  i: integer;
begin
  FreeAndNil(fInspectorList);
  FreeAndNil(fVariableWatchersList);

  FreeAndNil(frmBreakPointInfo);

  if Assigned(fpCodesProcTableS) then
    begin
      for i := 0 to fpCodesProcTableS.Count-1 do
        TpCodesProcTable(fpCodesProcTableS.Objects[i]).Free;
      FreeAndNil(fpCodesProcTableS);
    end;

  FreeAndNil(frmSelectProcedure);

  FreeAndNil(fpCodeDecoder);

  with DEBUGGERSettings do
    SaveSettings(DEBUGGERSettingsFileName(VersionNr));

  // Don't try do things referring to an interpreter which may no longer exist
  for i := 0 to MAX_FILER_UNITNR do
    with fVolumesList[i] do
      if Assigned(TheVolume) then
        with TheVolume do
          begin
            OnPutIOResult := nil;
            OnStatusProc  := nil;
            OnSearchFoundProc := nil;
          end;

  inherited;
end;

procedure TfrmPCodeDebugger.AddBreakpoint2Click(Sender: TObject);
begin
  inherited;
  EditBreakPointInfo(-1);
end;

procedure TfrmPCodeDebugger.Exit1Click(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmPCodeDebugger.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;
  BeforeScroll(fpCodesProcTable);   // check for modified p-Code
  CanClose := true;                 // make an assumption
  if Assigned(fInterpreter) then
    with fInterpreter as TCustomPsystemInterpreter do
      if Assigned(frmPSysWindow) then
        with frmPSysWindow do
          begin
            CanClose := CanCloseTheWindow;
            if CanClose then
              FreeAndNil(frmPSysWindow)
            else
              Alert('Halt the interpreter first');
          end;
end;

procedure TfrmPCodeDebugger.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  DEBUGGERSettings.MaxHistoryItems := fMAXHIST;
  DEBUGGERSettings.WindowsList.AddWindow(self, self.Name, Memo1.Height);
  DEBUGGERSettings.BreakList.CloseLogFile;
end;

procedure TfrmPCodeDebugger.DeleteBreakPoint2Click(Sender: TObject);
var
  r: integer;
begin
  inherited;
  with sgBreakPoints do
    with Selection do
      begin
        for r := Bottom downto Top do
          begin
            DEBUGGERSettings.Brks.Delete(r-1);
            if r > 1 then
              if (r < Pred(RowCount)) then
                Row := r + 1
              else
                Row := r - 1;
          end;
      end;
  DisplayBreakPoints;
end;

function TfrmPCodeDebugger.UpdatePCode(aProcName: string; MemoField: TMemoField): boolean;
var
  Ok: boolean;

  procedure ErrAbort(VersionNr: TVersionNr; const Msg2: string);
  begin
    raise Exception.CreateFmt('Decode for %s %s not implemented', [VersionNrStrings[VersionNr].Name, Msg2])
  end;

begin { UpdatePCode }
  result := false;
  if not Empty(aProcName) then
    begin
      Ok := true;       // debugging
      if Ok then
        begin
          with fpCodesProcTable do
            begin
              MemoField.Transliterate := TRANSLITERATE;
              fBlobStream := CreateBlobStream(MemoField, bmWrite);
              fBlobStream.Seek(0, soFromBeginning);
            end;

          try
            case VersionNr of
              vn_VersionI_4, vn_VersionI_5, vn_VersionII:
                begin
                  if fInterpreter is TCPsystemInterpreter then // the Peter Miller Version
                    begin
                      with fInterpreter as TCPsystemInterpreter do
                        if not Word_Memory then
                          fpCodeDecoder.Decode( 0, 0, true, dfMemoFormat, IpcBase)
                        else
                          {ErrAbort(VersionNr, 'word addressed memory')}
                          Update_Status('Decode not implemented yet for Word_Memory');
                    end
                  else
                    if fInterpreter is TIIPsystemInterpreter then // the Peter Miller Version
                      with fInterpreter as TIIPsystemInterpreter do
                        begin
                          fpCodeDecoder.Decode( 0, 0, true, dfMemoFormat, ProcBase)   // this is untested
                        end;
                end;

              vn_VersionIV:
                with fInterpreter as TIVPsystemInterpreter do
                  fpCodeDecoder.Decode( 0, 0, true, dfMemoFormat, SegBase+ProcBase);     // this puts the p-Code lines into the memo using the AddLine method

              else
                ErrAbort(VersionNr, 'Unknown');     // this puts the p-Code lines into the memo using the AddLine method
            end;
          finally
            FreeAndNil(fBlobStream);
            result := true;
          end;

        end;
    end;
end;  { UpdatePCode }

procedure TfrmPCodeDebugger.AddLine(const Line: string);
var
  aLine: string;
begin
  inherited;
  aLine := TrimRight(Line) + CRLF;
  fBlobStream.WriteBuffer(pchar(aLine)^, Length(aLine));      // write the string
end;

function TfrmPCodeDebugger.AddProcInfo( aSegNameIdx: TSegNameIdx;
                                         const aSegName: string;
                                         aProcNum: word;
                                         aProcName: string;
                                         DoAppend: boolean): boolean;
var
  DefaultName: string;
  Msg: string;
begin { AddProcInfo }
  with fpCodesProcTable do
    if aProcName <> '' then
      begin
        if DoAppend then
          Append
        else
          Edit;

//      if not ((aSegName=fLoadedSegName) and (aProcName=fLoadedProcName)) then
//        AlertFmt('System error. File cursor has changed from %s.%s to %s.%s',
//              [fLoadedSegName, fLoadedProcName, fLoadedSegName, aSegName]);
        UpdateProcInfo(aSegName, aProcNum, aProcName);
        result := UpdatePCode(aProcName, fldDecodedPCode as TMemoField);
        if result then
          begin
            Post;
            Update_StatusFmt('%s   procedure #%d:%s.%s',
                             [IIF(DoAppend, 'Adding', 'Updating'),
                              aProcNum, aSegName, aProcName]);
          end
        else
          Cancel;
      end
    else
      begin
        DefaultName := Format('%d:%s.Proc #%d', [aProcNum, aSegName, aProcNum]);
        Msg := Format('Procedure %s does not have a name and was not loaded',
                        [DefaultName]);
        Memo1.Clear;
        Memo3.Clear;
        Message(Msg);
        self.Update_Status(Msg);
        result := UpdatePCode(aProcName, fldDecodedPCode as TMemoField);
      end;
end;  { AddProcInfo }

procedure TfrmPCodeDebugger.DisplayMemoField(Memo: TMemo; MemoField: TMemoField;
                                             SetFocus: boolean);
var
  Bufp: pchar;
begin
  with fpCodesProcTable do
    begin
      MemoField.Transliterate := TRANSLITERATE;
      fBlobStream := CreateBlobStream(MemoField, bmRead);
      try
        if fBlobStream.Size > 0 then
          begin
            Bufp := AllocMem(fBlobStream.size+1);
            try
              fBlobStream.ReadBuffer(Bufp^, fBlobStream.Size);
              Memo.SetTextBuf(Bufp);      {Display the buffer's contents.}
              if SetFocus then
                Memo.SetFocus;
            finally
              Memo.Modified := false;
              FreeMem(Bufp);
            end;
          end
        else
          begin
            Memo.Clear;
            Memo.Modified := false;
          end;
      finally
        FreeAndNil(fBlobStream);
      end;
    end;
end;

procedure TfrmPCodeDebugger.SetIPCOffsets(Memo: TMemo; var Offsets: TOffsetsList);
var
  LineNr, IPC: integer;
  cp: word;
  Line, NumStr: string;
begin
  SetLength(Offsets, Memo.Lines.Count);
  for LineNr := 0 to Memo.Lines.Count-1 do
    begin
      Offsets[LineNr] := -1;    // default to "no source code here"
      Line := Memo.Lines[LineNr];
      cp   := Pos(':', Line);
      if cp > 0 then
        begin
          NumStr := Trim(Copy(Line, 1, cp-1));
          if IsPureNumeric(NumStr) then
            begin
              IPC    := StrToInt(NumStr);
              if (IPC >= 0) and (IPC < High(Smallint)) then  // Ignore garbage
                Offsets[LineNr] := IPC;
            end;
        end;
    end;
end;

Procedure TfrmPCodeDebugger.DisplayPStack;
var RowNr: word;
    hex: string;
    Addr : word;
    Wd: TUnion;
Begin { DisplayPStack }
  Addr := SPReg;

  sgPStack.Cells[COL_ADDR, 0]   := 'Addr';
  sgPStack.Cells[COL_HEXVAL, 0] := 'Hex';
  sgPStack.Cells[COL_DECVAL, 0] := 'Dec';
  sgPStack.Cells[COL_NIBVAL, 0] := 'Nib';
  sgPStack.Cells[COL_ASCVAL, 0] := 'Asc';

  RowNr := 1;
  while (RowNr <= PSTACK_NR_ROWS) and (Addr < $FFFE) do
    Begin
      with fInterpreter as TCustomPsystemInterpreter do
        begin
          Hex     := HexWord(Addr);
          Wd.W    := WordAt[Addr];

          sgPStack.Cells[COL_ADDR, RowNr]   := Hex;
          sgPStack.Cells[COL_HEXVAL, RowNr] := HexWord(WD.W);
          sgPStack.Cells[COL_DECVAL, RowNr] := IntToStr(WD.I);
          sgPStack.Cells[COL_NIBVAL, RowNr] := HexByte(Wd.l) + ' ' + HexByte(WD.h);
          sgPStack.Cells[COL_ASCVAL, RowNr] := Printable(wd.s);

//        inc(Addr, ByteIndexed(+1));
          Addr := WordIndexed(Addr, +1);
        end;


      inc(RowNr,1);
    end;
  AdjustColumnWidths(sgPStack);
  sgPStack.Row := 1;
end;  { DisplayPStack }

function TfrmPCodeDebugger.GetSegBase(MSCWAddr: word): longword;
var
  SIBAddr: word;
  p: TMSCWPtr;
begin { GetSegBase }
  with fInterpreter as TIVPsystemInterpreter do
    begin
      p := TMSCWPtr(@Bytes[MSCWAddr]);
      SIBAddr  := TERECPtr(@Bytes[p^.MSENV])^.ENV_SIB;  // link from the MSCW-->SIB-->

      with TSIBPtr(@Bytes[SIBAddr])^ do
        result   := PoolBase(Seg_Pool) + Seg_Base;
    end;
end;  { GetSegBase }

function TfrmPCodeDebugger.IPCWithinProc(anIPC, ErecAddr: word; ProcNr: integer): word;
var
  Erec  : TErec;
//SIB   : TSib;
  Seg   : longword;
  aProcBase: word;
begin
{$R-}
  with fInterpreter as TIVPsystemInterpreter do
    begin
      Erec := TErecPtr(@Bytes[ErecAddr])^;
      with TSibPtr(@Bytes[Erec.env_sib])^ do
        Seg := PoolBase(Seg_Pool) + Seg_Base;
      aProcBase := CalcProcBase(Seg, Abs(ProcNr));
    end;

  result := anIPC - aProcBase;
{$R+}
end;


function TfrmPCodeDebugger.IPCWithinProcStr(anIPC, ErecAddr: word; ProcNr: integer): string;
begin { IPCWithinProcStr }
  result := IntToStr(IPCWithinProc(anIPC, ErecAddr, Abs(ProcNr)));  // ProcNr in MSCW may be negative during S_EXIT
end;  { IPCWithinProcStr }

  procedure TfrmPCodeDebugger.AddProcCall(Grid: TStringGrid; MSCWAddr: word; const aLongName, anIpc: string);
  var
    RowNum: word;
  begin { AddProcCall }
    with Grid do
      begin
        RowNum   := RowCount;

        RowCount := RowCount + 1;
        if MSCWAddr <> 0 then
          Cells[COL_CsNr, RowNum]       := Format('%4x', [MSCWAddr])
        else
          Cells[COL_CsNr, RowNum]       := '';  // current procedure does not have an MSCW
          
        Cells[COL_CsProcName, RowNum] := aLongName;
        Cells[COL_CsIPC, RowNum]      := anIpc;
        Objects[0, RowNum]            := TObject(MSCWAddr);
      end;
  end;  { AddProcCall }

procedure TfrmPCodeDebugger.DisplayCallStack(Grid: TStringGrid; CSType: TMSCWFieldNr; var fExitingProcs: TChangedRows);
const
  MAXROWS = 20;
var
  MscwAddr: word;
  p: TMscwPtr;
  SavedRowNr: integer;
  aLongName: string;
  NrRows: integer;

begin { DisplayCallStack }
  with Grid do
    begin
      SavedRowNr                := Row;    // remember which row was being saved
      RowCount                  := 1;
      Cells[COL_CsNr, 0]        := 'MSCW';
      Cells[COL_CsProcName, 0]  := 'Proc';
      Cells[COL_CsIpc, 0]       := '@IPC';
    end;

  with fInterpreter as TIVPsystemInterpreter do
    begin
      MscwAddr := MP;
      p        := TMscwPtr(@Bytes[MscwAddr]);

      AddProcCall(Grid, MscwAddr, ProcName(CURPROC, DS){LongName}, IntToStr(RelIPC));  // First the current procedure

      try
        NrRows := 0;
        if (p^.MSPROC <> 0) then
          begin
            while (MscwAddr <> 0) and (MscwAddr <> MSCWField(MscwAddr, CSType)) and (p^.MSProc <> 0) do  // 12/26/2020: Changed to prevent infinite loop when breaking in SEARCH.TEXT
              begin
                if p^.MSProc <> 0 then
                  begin
{$R-}               // MSPROC may be negative
                    aLongName := ProcNameFromErec(p^.MSPROC, p^.MSENV);
                    MscwAddr  := MSCWField(MscwAddr, CSType);
                    fExitingProcs[Grid.RowCount] := Integer(p^.MSPROC) < 0;     // highlight MSCW being exited
                    AddProcCall(Grid, MscwAddr, aLongName, IPCWithinProcStr(p^.MSIPC, p^.MSENV, p^.MSPROC));
{$R+}
                    p         := TMscwPtr(@Bytes[MscwAddr]);
                    Inc(NrRows);
                    if NrRows > MAXROWS then // prevent infinite loop on call stack
                      break;
                  end;
              end;
            if SavedRowNr < Grid.RowCount then
              Grid.Row := SavedRowNr;  // restore to what user had previously highlighted

            AdjustColumnWidths(Grid);
          end;
      except
        on ex:Exception do
          AddProcCall(Grid, MscwAddr, ex.Message, aLongName);
      end;
    end;
end;   { DisplayCallStack }


procedure TfrmPCodeDebugger.DisplayRegisters;
var
  aSegName: string;
  aProcName: string;
  anOpCode: word;
  IC: TIdentCode;
  RowNr, SavedRowNr: integer;
begin
  with sgRegisters do
    begin
      SavedRowNr := Row;   // remember what is currently selected
      RowCount := 1 + ROW_OPNAME + (Ord(High(TIdentCode)) - ord(Low(TidentCode)));
      Cells[0, ROW_CAPTION]  := 'NAME';
      Cells[0, ROW_SEGNAME]  := 'SegName';
      Cells[0, ROW_PROCNUM]  := 'ProcNum';
      Cells[0, ROW_PROCNAME] := 'ProcName';
      Cells[0, ROW_RELIPC]   := 'RelIPC';
      Cells[0, ROW_ABSIPC]   := 'AbsIPC';
      Cells[0, ROW_DBGCNT]   := 'DbgCnt';
      Cells[0, ROW_OPCODE]   := 'OpCode';
      Cells[0, ROW_OPNAME]   := 'OpName';

      for IC := Succ(ic_Unknown) to High(TIdentCode) do
        if IC in fLegalIdentCodes then
          begin
            RowNr := ROW_REGS + ord(IC) - 1;
            Cells[0, RowNr] := IdentCodeInfo[IC].Ident;
            Cells[1, RowNr] := HexWord(IdentifierValue(IC));
          end;

      with fInterpreter as TIVPsystemInterpreter do
        begin
          if (SegNameIdx >= 0) then
            begin
              aSegName   := SegNamesInDB[SegNameIdx];
              aProcName  := ProcNamesInDB[SegNameIdx, CurProc];
            end
          else
            begin
              aSegName  := 'Unknown';
              aProcName := 'Unknown';
            end;

//        TheIPC     := SI-ProcBase;

          anOpCode   := Bytes[DS+SI];

          Cells[1, ROW_CAPTION]  := 'VALUE';
          Cells[1, ROW_SEGNAME]  := aSegName;
          Cells[1, ROW_PROCNUM]  := IntToStr(CurProc);
          Cells[1, ROW_PROCNAME] := aProcName;
          Cells[1, ROW_RELIPC]   := IntToStr(RelIPC);
          Cells[1, ROW_ABSIPC]   := Format('$%4.4x', [AbsIPC]);
          Cells[1, ROW_DBGCNT]   := Format('%0.n', [DbgCnt*1.0]);
          Cells[1, ROW_OPCODE]   := IntToStr(anOpCode);
          Cells[1, ROW_OPNAME]   := Opstable.Ops[anOpCode].Name;
        end;
      sgRegisters.Row := SavedRowNr;
    end;
end;

procedure TfrmPCodeDebugger.DisplayPCodeToPage;
var
  b: boolean;
//MemoField: TMemoField;

  procedure DisplayMemo(Memo: TMemo; MemoField: TMemoField);
  begin { DisplayMemo }
    if MemoField.BlobSize > 0 then
      DisplayMemoField(Memo, MemoField, b)
    else
      Memo.Clear;
  end;  { DisplayMemo }

begin { DisplayPCodeToPage }
  with fpCodesProcTable do
    begin
      b := PageControl1.ActivePage = tabPCode;

      DisplayMemo(Memo1, fldDecodedPCode as TMemoField);
      DisplayMemo(Memo3, fldSourceCode as TMemoField);

      if b and ((fSelectedMemo = Memo1) or (fSelectedMemo = Memo3)) then
        fSelectedMemo.SetFocus;
    end;
end;  { DisplayPCodeToPage }

function TfrmPCodeDebugger.FetchProcInfo(  aSegNameIdx: TSegNameIdx;
                                           aProcNum: integer;
                                           aProcName: string;
                                           anIPC: word;
                                           NoAdd: boolean): boolean;
var
  aSegName: string;
  OK, b1, b2: boolean;
  Msg: string;
  DecodedPCodeField: TMemoField;
begin
  result    := false;
  if not IsUserProg then
    aSegName  := SegNamesF(aSegNameIdx)
  else
    with fInterpreter as TCustomPsystemInterpreter do
      aSegName  := CurrentSegName;  // Version I.5, II require special handling for the USERPROG segment name

  with fpCodesProcTable do
    begin
      if Empty(aProcName) then
        begin
          Msg := Format('Procedure %s.Proc #%d does not have a name', [aSegName, aProcNum]);
          Update_Status(Msg);
          aProcName := '';
          if GetString(Msg, 'Procedure Name', aProcName, 30, ecUpperCase) then
            begin
              with fpCodesProcTable do
                begin
                  if (State in [dsEdit, dsInsert]) then
                    raise Exception.CreateFmt('Already in edit/insert mode for %s.%s',
                                              [fldSegmentName.AsString, fldProcedureName.AsString]);
                end;
              ProcNamesInDB[aSegNameIdx, aProcNum] := aProcName;  // for the call stack
            end
          else
            Exit;
        end;

        aProcName := UCSDName(aProcName);  // truncate to field size
        OK        := Locate(IndexName_SEGNAME_PROC_NR_NAME_INDEX, VarArrayOf([aSegName, aProcNum, aProcName]), [loCaseInsensitive]);
        if not OK then // Try again                                but ignore the procedure number
          OK      := Locate(IndexName_SEGNAME_PROCNAME_INDEX, VarArrayOf([aSegName, aProcName]), [loCaseInsensitive]);
        if (not OK) and NoAdd then
          begin
            AlertFmt('Procedure %s.%s could not be loaded', [aSegName, aProcName]);
            result := false;
            Exit;
          end;

        if (not OK) and (not NoAdd)  then
          OK := AddProcInfo( aSegNameIdx, aSegName, CURPROC, aProcName, true)  // record does not exist. Add it.
        else
          begin
            DecodedPCodeField := fldDecodedPCode as TMemoField; // simplify debugging
            if (anIPC = 0) and (DecodedPCodeField.BlobSize = 0) then // If the IPC = 0, and we haven't already saved this p-code, then
                                                             // this is a good time to decode and store the procedure info.
              OK := AddProcInfo( aSegNameIdx, aSegName, CURPROC, aProcName, false);  // record exists but p-Code is empty
          end;

        if OK then
          begin
            b1 := SameText(aSegName, UCSDName(fldSegmentName.AsString));
            b2 := SameText(aProcName, UCSDName(fldProcedureName.AsString));
            Assert(b1 and b2, 'System error in SaveUpdatedCode');
            fLoadedSegName  := aSegName;
            fLoadedProcName := aProcName;

            DisplayPCodeToPage;
            SetIPCOffsetsToPage;
            SelectCurrentLine(CurrentMemo(), anIPC);

            Update_Status(Format('Display  procedure #%s.%s', [aSegName, aProcName]));
            result := true;
          end;

        fCurrentProcName     := aProcName;
        fLastSegmentIdx      := aSegNameIdx;
        fLastProcNr          := aProcNum;
      end;
end;


Procedure TfrmPCodeDebugger.SelectMemoLine(Memo : TMemo; LineNr: word) ;
Begin
  Memo.SelStart := Memo.Perform(EM_LINEINDEX, LineNr, 0);
  Memo.SelLength := Length(Memo.Lines[LineNr]) ;
  SendMessage(Memo.Handle, EM_SCROLLCARET, 0, 0);
  DisplayCursorPos(Memo);
End;

function TfrmPCodeDebugger.CurrentMemo(Memo: TMemo): TMemo;
begin
  if Assigned(Memo) then
    result := Memo
  else
    if (Screen.ActiveControl is TMemo) then
      result := Screen.ActiveControl as TMemo
    else
      result := fSelectedMemo;
end;


procedure TfrmPCodeDebugger.SetIPCOffSetsToPage(Memo: TMemo = nil);
begin
  Memo := CurrentMemo(Memo);

  if Memo <> nil then
    begin
      if Memo = Memo1 then
        SetIPCOffsets(Memo, fPCodeOffsets) else
      if Memo = Memo3 then
        SetIPCOffsets(Memo, fSourceCodeOffsets);
    end;
end;

function TfrmPCodeDebugger.LineNrFromIPC(aIPC: word; Offsets: TOffsetsList): integer;
var
  i : integer;
  LastLineNr: integer;
begin
  // I want the nearest offset that is not negative but which is <= aIPC
  LastLineNr := 0;
  for i := 0 to Length(Offsets)-1 do
    if (Offsets[i] >= 0) then
      begin
        if aIPC >= Offsets[i] then
          LastLineNr := i else
        if aIPC < Offsets[i] then
          break;
      end;
  result := LastLineNr;
end;

procedure TfrmPCodeDebugger.ClearDebuggerDisplay;
var
  Row, Col: integer;
begin
  // ClearRegisters
  for Row := 0 to sgRegisters.RowCount-1 do
    sgRegisters.Cells[1, Row] := '';

  // ClearCallStack
  with sgCallStack do
    begin
      RowCount := 1;
      Cells[0, COL_CsNr]       := '#';
      Cells[1, COL_CsProcName] := 'Proc';
      Cells[2, COL_CsIpc]      := 'IPC';
    end;

  // ClearPStack
  for Row := 1 to PSTACK_NR_ROWS do
    for Col := COL_ADDR to COL_ASCVAL do
      begin
        sgPStack.Cells[Col, Row] := '';
        sgPStack.Cells[Col, Row] := '';
        sgPStack.Cells[Col, Row] := '';
        sgPStack.Cells[Col, Row] := '';
      end;

  Memo1.Clear;
  Memo3.Clear;
  memoSyscom.Clear;
end;

procedure TfrmPCodeDebugger.DisplayCspPHITS;
const
  COL_PCODE   = 0;
  COL_PCODEX  = 1;
  COL_OPNAME  = 2;
  COL_PHITS   = 3;
  COL_PCT     = 4;
var
  I, NrRows, RowNr: integer;
  TotalPHITS: longint;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      TotalPHITS := 0;
      NrRows     := 0;
{$IfDef pocahontas}
      for I := 0 TO OpsTable.CSPEnd do
        with OpsTable.CSPTABLE[i] do
          if Name <> '' then
            begin
              TotalPHITS := TotalPHITS+PHITS;
              Inc(NrRows);
            end;
{$EndIf}

      with sgCSPPhits do
        begin
          RowCount := NrRows + 1;
          if RowCount > 1 then
            FixedRows := 1;
          ColCount := 5;

          Cells[COL_PCODE, 0]  := 'CSP #';
          Cells[COL_PCODEX, 0] := 'Hex';
          Cells[COL_OPNAME, 0] := 'Name';
          Cells[COL_PHITS, 0]  := 'PHITS';
          Cells[COL_PCT, 0]    := '%';

          RowNr := 1;
          for I := 0 TO Length(OpsTable.CSPTABLE)-1 DO
            with OpsTable.CSPTABLE[I] do
              if Name <> '' then
                begin
                  Cells[COL_PCODE, RowNr]  := IntToStr(i);
                  Cells[COL_PCODEX, RowNr] := Hexword(i);
                  Cells[COL_OPNAME, RowNr] := Name;
{$ifDef Pocahontas}
                  Cells[COL_PHITS, RowNr]  := IntToStr(Phits);
                  if TotalPHITS > 0 then
                    Cells[COL_PCT, RowNr]  := Format('%7.2f', [PHITS/TotalPHITS * 100])
                  else
                    Cells[COL_PCT, RowNr]  := '';
{$endIf}
                  Inc(RowNr);
                end;
        end;
      lblCSPPHITS.Caption := Format('Total PHITS: %d', [TotalPHITS]);
    end;
end;


{$IfDef Pocahontas}
procedure TfrmPCodeDebugger.DisplayPHITS;
var
  I, NrRows, RowNr: integer;
  TotalPHITS: longint;
  DebugInfo: TOpInfo;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      TotalPHITS    := 0;
      NrRows        := 0;
      for I := 0 TO 255 do
        with OpsTable.Ops[i] do
          if Name <> '' then
            begin
              DebugInfo  := OpsTable.Ops[i];
              TotalPHITS := TotalPHITS+PHITS;
              Inc(NrRows);
            end;

      with sgPHITS do
        begin
          RowCount := NrRows + 1;
          if RowCount > 1 then
            FixedRows := 1;
          ColCount := 5;

          Cells[COL_PCODE, 0]  := 'p-Code';
          Cells[COL_PCODEX, 0] := 'Hex';
          Cells[COL_OPNAME, 0] := 'Name';
          Cells[COL_PHITS, 0]  := 'PHITS';
          Cells[COL_PCT, 0]    := '%';

          RowNr := 1;
          for I := 0 TO 255 DO
            with OpsTable.Ops[I] do
              if Name <> '' then
                begin
                  Cells[COL_PCODE, RowNr]  := IntToStr(i);
                  Cells[COL_PCODEX, RowNr] := Hexword(i);
                  Cells[COL_OPNAME, RowNr] := Name;
                  Cells[COL_PHITS, RowNr]  := IntToStr(Phits);
                  if TotalPHITS > 0 then
                    Cells[COL_PCT, RowNr]   := Format('%7.2f', [PHITS/TotalPHITS * 100])
                  else
                    Cells[COL_PCT, RowNr]   := '';
                  Inc(RowNr);
                end;
        end;
      lblPHITS.Caption := Format('Total PHITS: %d', [TotalPHITS]);
    end;
end;
{$EndIf}

procedure TfrmPCodeDebugger.UpdateSgWatchListRow(RowNr: integer;
                              const TypeVal, CodeVal, NameVal, AddrVal, ValueVal, CommentVal: string);
begin
  with sgWatchList do
    begin
      Cells[COL_WATCHTYPE, RowNr]  := TypeVal;
      Cells[COL_WATCHCODE, RowNr]  := CodeVal;
      Cells[COL_WATCHADDR, RowNr]  := AddrVal;

      fChangedWatches[RowNr] := Cells[COL_WATCHVAL,  RowNr] <> ValueVal;
      Cells[COL_WATCHVAL,  RowNr]  := ValueVal;

      Cells[COL_COMMENTVAL, RowNr] := CommentVal;
//    Cells[COL_WATCHNAME, RowNr]  := NameVal;
    end;
end;


procedure TfrmPCodeDebugger.DisplayWatches;
var
  I, NrWatches, RowNr: integer;
  Addr: longword;
  WatchItem: TWatchItem;
  IC: TIdentCode;
begin { DisplayWatches }
  // for this to work, the sgWatchList MUST always exactly parallel the gWatchList
  with sgWatchList do
    begin
      UpdateSgWatchListRow(0, 'Type', 'Code', 'Name', 'Addr', 'Value', 'Comment');

      NrWatches := DEBUGGERSettings.WatchList.Count;
      RowCount  := NrWatches + 1;
      if RowCount > 1 then
        FixedRows := 1;
      for I := 0 to NrWatches-1 do
        begin
          WatchItem := DEBUGGERSettings.WatchList.Items[i] as TWatchItem;
          with WatchItem do
            begin
              RowNr := I + 1;

              try
                IC   := IdentCode(WatchAddrExpr);
                if IC <> ic_Unknown then
                  Addr := IdentifierValue(IC)
                else
                  try
                    Addr := ReadInt(WatchAddrExpr);
                  except
                    Addr := WatchAddr;             // really ought to get rid of WatchAddr completely
                  end;

                if WatchIndirect then
                  Addr := WordAt[Addr];

                UpdateSgWatchListRow( RowNr,
                                      WatchTypesTable[WatchType].WatchName {Type},
                                      WatchTypesTable[WatchType].WatchCode,
                                      WatchName,
                                      HexWord(Addr) {Addr},
                                      MemDumpDW(Addr, WatchType, WatchParam),
                                      WatchComment {Value});
              except
                on e:EUnknownID do
                  UpdateSgWatchListRow( RowNr,
                                        WatchTypesTable[WatchType].WatchName {Type},
                                        WatchTypesTable[WatchType].WatchCode,
                                        'Invalid',{Name}
                                        'Invalid' {Addr},
                                        'Invalid',{param}
                                        e.Message {value});
              end;
            end;
        end;
      AdjustColumnWidths(sgWatchList, 20);
    end;
end;  { DisplayWatches }


procedure TfrmPCodeDebugger.DumpHistory;
const
  HOWMANY = 200;
var
  j: integer;
  aProcName: string;
  OutFile: TextFile;
  OutFileName: string;
begin
//OutFileName := UniqueFileName(DEBUGGERSettings.ReportsPath + 'History.csv');
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'History.csv');
  Rewrite(OutFile, OutFileName);
  try
//  with fInterpreter as TCustomPsystemInterpreter do
//    WriteLn(OutFile, 'History @ ', DateTimeToStr(Now), '  Debug Count = ', DbgCnt);
    WriteLn(OutFile,
               '"#","DB#",Segment,"P:#",Procedure,IPC,Opcode');
    for j := Max(fMAXHIST-HowMany, 0) to fHistIdx-1 do  // is fHistIdx-1 the last one used ?
      with fHistory[j] do
        begin
          aProcName := ProcNamesInDB[SegNameIdx, ProcNr];

          WriteLn( OutFile,
                     HistNr, ',',
                     SegNamesInDB[SegNameIdx], ',',
                     ProcNr, ',',
                     aProcName, ',',
                     RelIPC, ',',
                     Name);
        end;
  finally
    CloseFile(OutFile);
    ExecAndWait(OutFileName, '', false);
  end;
end;


procedure TfrmPCodeDebugger.DisplayHistory(HowMany: integer);
var
  j, RowNr: integer;
  aProcName: string;
begin
  leMaxHistory.Text := IntToStr(fMaxHist);
  cbCallHistoryOnly.Checked := DEBUGGERSettings.CallHistoryOnly;
  with sgHistory do
    begin
      RowCount := (fHistIdx-1) - (fMaxHist - HowMany) + 2;
      if RowCount > 1 then
        FixedRows := 1;
      ColCount := 7;

      Cells[COL_HISTNR,   0] := '#';
      Cells[COL_SEGNAME2, 0] := 'Segment';
      Cells[COL_PROCNR2,  0] := 'P:#';
      Cells[COL_PROCNAME, 0] := 'Procedure';
      Cells[COL_RELIPC,   0] := 'IPC';
      Cells[COL_OPCODENAME, 0] := 'Opcode';

      RowNr := 1;
      for j := Max(fMAXHIST-HowMany, 0) to fHistIdx{-1} do  // is fHistIdx-1 the last one used ?
        with fHistory[j] do
            begin
              aProcName := ProcNamesInDB[SegNameIdx, ProcNr];

              Cells[COL_HISTNR,   RowNr]   := IntToStr(HistNr);
              Cells[COL_SEGNAME2, RowNr]   := SegNamesInDB[SegNameIdx];
              Cells[COL_PROCNR2,  RowNr]   := IntToStr(ProcNr);
              Cells[COL_PROCNAME, RowNr]   := aProcName;
              Cells[COL_RELIPC,   RowNr]   := IntToStr(RelIPC);
              Cells[COL_OPCODENAME, RowNr]   := Name;

              Inc(RowNr);
            end;

      AdjustColumnWidths(sgHistory);

      if fHistIdx > 2 then
        Row := fHistIdx{-1};
    end;
  with fInterpreter as TCustomPsystemInterpreter do
    lblDbgCnt.Caption := Format('DbgCnt = %d', [DbgCnt]);
end;


procedure TfrmPCodeDebugger.DisplayGlobalDirectoryCommon(gDirpAddr: word);
const
  COL_DIR_FN = 0;
  COL_DIR_DTID = 1;
  COL_DIR_USED = 2;
  COL_DIR_DATE = 3;
  COL_DIR_TIME = 4;
  COL_DIR_1STBLK = 5;
  COL_DIR_BYTES = 6;
  COL_DIR_FILETYPE = 7;
var
  Idx: integer;
  DateAccessed, FileDateTime: TDateTime;
  VolInfo, aDirEntry: UCSDGlob.DirEntry;
  RowNr: integer;
  Year, Month, Day, Minutes, Hour, Y: word;
  aDateTime: TDateTime;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      if gDirpAddr <> 0 then
        begin
          VolInfo := TDirectoryPtr(@Bytes[gDirpAddr])^[0];
          with VolInfo do
            begin
              DateAccessed := DAccessToTDateTime(DLASTBOOT, DFKIND);
              lblDirectory.Caption := Format('Volume Name=%s, EOV=%d, NrFiles=%d, LastDate=%s, gDirP=%s',
                                             [DVID, DEOVBLK, DNUMFILES, DateToStr(DateAccessed), BothWays(gDirpAddr)]);
            end;

          if VolInfo.DNUMFILES <= MAXDIR then
            with sgDirectory do
              begin
                Cells[COL_DIR_FN, 0]       := '#';
                Cells[COL_DIR_DTID, 0]     := 'DTID';
                Cells[COL_DIR_USED, 0]     := 'Used';
                Cells[COL_DIR_DATE, 0]     := 'Date';
                Cells[COL_DIR_TIME, 0]     := 'Time';
                Cells[COL_DIR_1STBLK, 0]   := '1st Blk';
                Cells[COL_DIR_BYTES, 0]    := 'Nr Bytes';
                Cells[COL_DIR_FILETYPE, 0] := 'File Type';

                RowCount := VolInfo.DNUMFILES + 2;
                if RowCount > 1 then
                  FixedRows := 1;
                ColCount := Succ(COL_DIR_FILETYPE);
                RowNr    := 1;

                for Idx := 0 to VolInfo.DNUMFILES do
                  begin
                    aDirEntry := TDirectoryPtr(@Bytes[gDirpAddr])^[idx];
                    with aDirEntry do
                      begin
                        try
                          if idx = 0 then
                            begin
                              aDateTime := DAccessToTDateTime(DLASTBOOT, DFKIND);
                              Y         := DLASTBOOT shr 9;  // get the raw year value
                            end
                          else
                            begin
                              aDateTime := DAccessToTDateTime(DACCESS, DFKIND);
                              Y         := DACCESS shr 9;
                            end;
                          DecodeDate(aDateTime, Year, Month, Day);
                        except
                          aDateTime := BAD_DATE;
                          Y         := FLAGYEAR;
                        end;

                        fBadDates[RowNr] := (Y >= FLAGYEAR) or (aDateTime = BAD_DATE);

                        if (Month >= 1) and (Month <= 12) then
                          begin
                            Cells[COL_DIR_FN, RowNr] := IntToStr(Idx);
                            case DFKIND and $F of  // higher bits are used to store the time
                              kSECUREDIR,
                              kUNTYPEDFILE:
                                begin
                                  Cells[COL_DIR_DTID, RowNr]   := DVID;
                                  Cells[COL_DIR_DATE, RowNr]   := DateToPsysStr(aDateTime);
                                  Cells[COL_DIR_USED, RowNr]   := Format('%5d', [DLASTBLK-DFIRSTBLK]);
                                  Cells[COL_DIR_1STBLK, RowNr] := Format('%5d', [DFIRSTBLK]);
                                  Cells[COL_DIR_FILETYPE, RowNr] := PSysFileType(DFKIND);
                                  Inc(RowNr);
                                end;
                              kXDSKFILE,kCODEFILE,kTEXTFILE,kINFOFILE,
                              kDATAFILE,kGRAFFILE,kFOTOFILE,kSUBSVOL:
                                begin
                                  Cells[COL_DIR_DTID, RowNr]   := DTID;
                                  Cells[COL_DIR_USED, RowNr]   := Format('%5d', [DLASTBLK-DFIRSTBLK]);
                                  Cells[COL_DIR_BYTES, RowNr]  := IntToStr(DLASTBYTE);
                                  FileDateTime := aDateTime; // DAccessToTDateTime(DACCESS, DFKIND);
                                  Cells[COL_DIR_DATE, RowNr]   := DateToPsysStr(FileDateTime);
                                  if Frac(FileDateTime) > 0 then
                                    begin
                                      Minutes      := MinutesOf(DFKIND);
                                      Hour         := HourOf(DFKIND);
                                      Cells[COL_DIR_TIME, RowNr] := Format('%2d:%2d',
                                                                           [Hour, Minutes]);
                                    end
                                  else
                                    Cells[COL_DIR_TIME, RowNr] := '';

                                  Cells[COL_DIR_1STBLK, RowNr] := Format('%5d', [DFIRSTBLK]);
                                  Cells[COL_DIR_FILETYPE, RowNr] := PSysFileType(DFKIND);
                                  Inc(RowNr);
                                end;
                              else
                                begin
                                  Cells[COL_DIR_DTID, RowNr]   := DTID;
                                  Cells[COL_DIR_FILETYPE, RowNr] := Format('Invalid file kind: %d', [DFKIND]);
                                end;
                            end;
                          end;
                      end;
                  end;
                RowCount := RowNr;
                if RowCount > 1 then
                  FixedRows := 1;
                AdjustColumnWidths(sgDirectory, 20);
                lblDirectory.Color   := clBtnFace;
              end
            else
              begin
                lblDirectory.Caption := Format('gdirp points to invalid directory: %4.4x. %d files?',
                                               [gDirpAddr, VolInfo.DNUMFILES]);
                lblDirectory.Color   := clYellow;
                sgDirectory.RowCount := 1;
              end;
        end
      else
        begin
          lblDirectory.Caption := 'No directory loaded';
          lblDirectory.Color   := clYellow;
          sgDirectory.RowCount := 1;
        end;
    end;
end;

(*
procedure TfrmPCodeDebugger.DisplayPoolsAndSegments;
const
  ADDROFCODEPOOLPTR = 6146;
type
  TPoolCol = (COL_POOLNR, COL_ADDR, COL_BASEADDRESS, COL_POOLSIZE, COL_MINOFFSET, COL_MAXOFFSET,
              COL_RESOLUTION, COL_POOLHEAD, COL_PERMSIB, COL_EXTENDED, COL_NEXTPOOL,
              COL_MUSTCOMPACT);
var
  CodePoolAddr, PoolStartAddr: LongWord;
  CodePoolPtr: TPoolDescInfoPtr;
  CurSibAddr: LongWord;
  RowNr: integer;
begin
  with sgPoolsSegments do
    begin
      ColCount := Integer(High(TPoolCol)) + 2; // include header and last col
      RowCount := 1;
      Cells[ord(COL_POOLNR), 0]      := 'PoolNr';
      Cells[ord(COL_ADDR), 0]        := 'PoolDescAddr';
      Cells[ord(COL_BASEADDRESS), 0] := 'BaseAddress';
      Cells[ord(COL_POOLSIZE), 0]    := 'PoolSize';
      Cells[ord(COL_MINOFFSET), 0]   := 'MinOffset';
      Cells[ord(COL_MAXOFFSET), 0]   := 'MaxOffset';
      Cells[ord(COL_RESOLUTION), 0]  := 'Resolution';
      Cells[ord(COL_POOLHEAD), 0]    := 'PoolHead';
      Cells[ord(COL_PERMSIB), 0]     := 'PermSIB';
      Cells[ord(COL_EXTENDED), 0]    := 'Extended';
      Cells[ord(COL_NEXTPOOL), 0]    := 'NextPool';
      Cells[ord(COL_MUSTCOMPACT), 0] := 'MustCompact';
      FixedCols := 1;
    end;

  CodePoolAddr  := ADDROFCODEPOOLPTR;  // Major league kludge

  PoolStartAddr := CodePoolAddr;
  RowNr         := 1;
  while (CodePoolAddr <> pNil) do
    begin
      CodePoolPtr  := TPoolDescInfoPtr(@Bytes[CodePoolAddr]);
      with sgPoolsSegments, CodePoolPtr^ do
        begin
          Cells[ord(COL_POOLNR), RowNr]      := IntToStr(RowNr);
          Cells[ord(COL_ADDR), RowNr]        := HexWord(CodePoolAddr);
          Cells[ord(COL_BASEADDRESS), RowNr] := HexWord(FullAddressToLongInt(PoolBaseAddr));
          Cells[ord(COL_POOLSIZE), RowNr]    := HexWord(PoolSize);
          Cells[ord(COL_MINOFFSET), RowNr]   := HexWord(MINOFFSET);
          Cells[ord(COL_MAXOFFSET), RowNr]   := HexWord(MAXOFFSET);
          Cells[ord(COL_RESOLUTION), RowNr]  := HexWord(RESOLUTION);
          Cells[ord(COL_POOLHEAD), RowNr]    := HexWord(POOLHEAD);
          Cells[ord(COL_PERMSIB), RowNr]     := HexWord(PERMSIB);
          Cells[ord(COL_EXTENDED), RowNr]    := TFString(EXTENDED);
          Cells[ord(COL_NEXTPOOL), RowNr]    := HexWord(NEXTPOOL);
          Cells[ord(COL_MUSTCOMPACT), RowNr] := TFString(MUSTCOMPACT);
          Objects[ord(COL_PERMSIB), RowNr]   := TObject(PermSIB);
          inc(RowNr);
          RowCount := RowNr;
          CurSibAddr      := CodePoolPtr^.poolhead;
          CodePoolAddr    := TPoolDescInfoPtr(@Bytes[CodePoolAddr])^.NextPool;
          if CodePoolAddr = PoolStartAddr then
            break;
          CodePoolPtr  := TPoolDescInfoPtr(@Bytes[CodePoolAddr]);
        end;
    end;
  sgPoolsSegments.FixedRows := 1;
  AdjustColumnWidths(sgPoolsSegments);
end;
*)


procedure TfrmPCodeDebugger.UpdateDebuggerDisplay;
var
  Memo: TMemo;
  Msg: string;
  aColor: TColor;
  aProcName: string;
  aSegNameIdx: TSegNameIdx;
begin
  if not Showing then
    Show;  // the debugger

  Memo := CurrentMemo(fSelectedMemo);

  aSegNameIdx := TheSegNameIdx(SegBase);

  SegNameIdx      := aSegNameIdx;

  aProcName := ProcNamesF(SegNameIdx, CurProc);

  if (fLastSegmentIdx      <> SegNameIdx) or
     (fCurrentProcName     <> aProcName) then
    if not FetchProcInfo(SegNameIdx, CurProc, aProcName, RelIPC, false) then
      begin
        Update_Status(Format('Could not find p-Code for procedure %s.%s',
                             [SegNamesInDB[SegNameIdx], aProcName]), clYellow);

        if Assigned(Memo) then
          Memo.Clear;
      end;

  fUserOpenedProcIsLoaded := false;

  DisplayRegisters;
  DisplayCallStack(sgCallStack, csDynamic, fExitingProcsDyn);
  DisplayCallStack(sgStatic,    csStatic,  fExitingProcsStat);

  DisplayPStack;

  if Assigned(Memo) then
    SelectCurrentLine(Memo, RelIPC);

  DisplayWatches;

  if PageControl1.ActivePage = tabSysCom then
    DisplaySyscom else
  if PageControl1.ActivePage = tabHistory then
    begin
      DisplayHistory(fMAXHIST);
{$IfDef Pocahontas}
      DisplayPHITS;
      DisplayCspPhits;
{$EndIf}
    end else
  if PageControl1.ActivePage = tabBreakPoints then
    begin
      AdjustColumnWidths(sgBreakPoints);
      DisplayBreakPoints;
    end else
  if PageControl1.ActivePage = tabMessages then
    AdjustColumnWidths(sgMessages) else
  if PageControl1.ActivePage = tabDirectory then
    DisplayGlobalDirectory
  else
  if PageControl1.ActivePage = tabProfile then
    DisplayProfile else
  if PageControl1.ActivePage = TabCrtKeyInfo then
    DisplayCrtKeyInfo;

  if Assigned(fInspectorList) then
    fInspectorList.RefreshAll;

  if Assigned(fVariableWatchersList) then
    fVariableWatchersList.RefreshAll;

{$IfDef DashBoard}
  if Assigned(fDashboardWindowsList) then
    fDashboardWindowsList.RefreshAll;
{$endIf DashBoard}

  aColor := clBtnFace;
//if Brk = dbSYSTEM_HALT then
//  Update_Status('SYSTEM HALT', clYellow)
//else
    begin
      if Brk = dbException then
        begin
          Msg    := fExceptionMessage;
          aColor := clYellow;
          SysUtils.Beep;
        end
      else if Brk = dbMemChanged then
        begin
          with DEBUGGERSettings do
            begin
              with Brks.Items[ChangedMemBreak] as TBreakInfo do
                begin
//                LowAddr := WatchAddrFromExpression(AddrExpr);
                  if WatchType = wt_Unknown then
                    Msg := Format('MemChanged @ %4x to: %s',
                                  [LowAddr, MemDumpDW(LowAddr, wt_HexBytes, NrBytes)])
                  else
                    Msg := Format('MemChanged @ %4x to: %s',
                                  [LowAddr, MemDumpDW(LowAddr, WatchType)]);
                  aColor := clFuchsia
                end
            end
        end
      else if Brk <> dbUnknown then
        begin
          Msg    := BreakKinds[Brk].BreakName;
          aColor := clFuchsia;
        end
      else
        Msg := '';

      if fInterpreter is TCustomPsystemInterpreter then
        with fInterpreter as TCustomPsystemInterpreter do
          Update_Status(Format('%d: %s at #%s, Ofs:%d',
                               [BreakPtNr+2,
                                Msg,
                                ProcName(CurProc, SegBase),
                                RelIPC]), aColor);
    end;
end;

function TfrmPCodeDebugger.MemDumpDW( Addr: longword;
                                      WatchType: TWatchType;
                                      Param: word = 0;
                                      const Msg: string = ''): string;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := MemDumpDW(Addr, WatchType, Param, Msg);
end;

function TfrmPCodeDebugger.MemDumpDF( Addr: longword;
                                      Form: string = 'W';
                                      Param: word = 0;
                                      const Msg: string = ''): string;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := MemDumpDF(Addr, Form, Param, Msg);
end;


procedure TfrmPCodeDebugger.Enable_Run(value: boolean);
begin
  RuntoCursor1.Enabled   := value;
  StepInto1.Enabled      := value;
  Stepover1.Enabled      := value;
  Run3.Enabled           := value;
  ProgramReset1.Enabled  := value;
  
  miLoadFromLast.Enabled   := not Value;
end;

(*
procedure TfrmPCodeDebugger.DebuggerLoadFromUnit(aVersionNr: TVersionNr; Boot_Unit: integer);
begin
  with DEBUGGERSettings do
    begin
      LastBootedVersionNr   := aVersionNr;
      LastBootedUnitNr      := Boot_Unit;
      LastBootedFileName    := fVolumesList[Boot_Unit].TheVolume.DOSFileName;
//    DefaultPSystemVersion := aVersionNr;
    end;

  with fInterpreter as TCustomPsystemInterpreter do
    begin
      Load_PSystem(Boot_Unit);
      Enable_Run(true);

      UpdateDebuggerDisplay;
     end;

  Update_StatusFmt('Volume #%d:%s has been loaded and is ready to run',
                    [BOOT_UNIT, fVolumesList[BOOT_UNIT].VolumeName], clLime);
end;
*)

procedure TfrmPCodeDebugger.CloseOpenEdits;
var
  i    : integer;
  memo : TMemo;
begin
  if EnableMemoEditing1.Checked then
    begin
      Memo := CurrentMemo();

      EnableMemoEditing1.Checked := false;
      SelectCurrentLine(Memo, RelIPC);
      SaveUpdatedPCode(true);

      ShowEditMode;
    end;

  if Assigned(fVariableWatchersList) then
    with fVariableWatchersList do
      for i := 0 to Count-1 do
        with TfrmLocalVariables(Items[i]) do
          SaveChanges;
end;


procedure TfrmPCodeDebugger.Run3Click(Sender: TObject);   {F9}
begin
  inherited;

  CloseOpenEdits;
  with fInterpreter as TCustomPsystemInterpreter do
    DEBUGGERSettings.Brks.InitBreaks(Bytes);

  Update_Status('');

  with fInterpreter as TCustomPsystemInterpreter do
    begin
      try
        if Brk <> dbUnknown then  // we are already sitting on a breakpoint- skip over it
          Single_Step;
        Brk := Run_PSystem;
        UpdateDebuggerDisplay;
      except
        on e1:ESYSTEMHALT do
          begin
            Brk := dbSystem_Halt;
            Alert(e1.Message);
          end;
      end;
    end;
end;

function TfrmPCodeDebugger.OpenProc( SegIdx: TSegNameIdx;
                                     aProcNum: integer;
                                     aProcName: string;
                                     anIPC: word): boolean;
begin
  result := FetchProcInfo(SegIdx, aProcNum, aProcName, anIPC, true);
  if result then
    begin
      fUserOpenedProcIsLoaded := true;
      fUserOpenedIPC          := anIPC;
      Update_StatusFmt('Loaded %s.%s', [SegNamesInDB[SegIdx], aProcName], clYellow);
    end;
end;


procedure TfrmPCodeDebugger.Open1Click(Sender: TObject);
var
  mr: integer;
begin
  inherited;
// Open specified procedure
  if not Assigned(frmSelectProcedure) then
    frmSelectProcedure := TfrmSelectProcedure.Create(self, fInterpreter, DEBUGGERSettings);

  mr := frmSelectProcedure.ShowModal;
  if mr = mrOk then
    with frmSelectProcedure do
      begin
        if OpenProc(SegIdx, ProcNum, ProcName, 0) then
          ;
      end;
end;

function TfrmPCodeDebugger.SourceCode_Step: TBrk;
var
  StartLineNr, CurProc0: integer;
  Was_RPU: boolean;
begin
  if Memo3.Lines.Count > 0 then
    begin
      StartLineNr  := LineNrFromIPC(RelIPC, fSourceCodeOffsets);
      CurProc0     := CurProc;
      repeat
        with fInterpreter as TCustomPsystemInterpreter do
          begin
            Was_RPU := (NextOpCode in OpsTable.Return_Ops) and (CurProc = CurProc0);
            result  := Single_Step;
          end;
      until (StartLineNr <> LineNrFromIPC(RelIPC, fSourceCodeOffsets))
             or (CurProc <> CurProc0)
             or Was_RPU
             or (result <> dbUNKNOWN);
    end
  else
    begin
      SysUtils.Beep;
      Alert('No Source Code Available for stepping');
      result            := dbException;
    end;
end;


procedure TfrmPCodeDebugger.Stepinto1Click(Sender: TObject); {F7}
begin
  inherited;
  Update_Status('');

  CloseOpenEdits;
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      DEBUGGERSettings.Brks.InitBreaks(Bytes);

      if CurrentMemo = Memo3 then
        Brk := SourceCode_Step
      else
        Brk := Single_Step;

      UpdateDebuggerDisplay;
    end;
end;

// Method Name: StepOver1Click
// Note:        This should exit when stepping out of the procedure that we started with

procedure TfrmPCodeDebugger.StepOver1Click(Sender: TObject);  {F8}
var
  CurProc0: integer;
  SegIdx0, SegIdx: TSegNameIdx;
  Was_RPU: boolean;
  StartLineNr, CurrentLineNr: integer;

  function SameProcedure: boolean;
  begin { SameProcedure }
    result := (SegIdx = SegIdx0) and (CURPROC = CurProc0);
  end;  { SameProcedure }

begin { StepOver1Click }
  inherited;

  Update_Status('');

  CloseOpenEdits;
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      DEBUGGERSettings.Brks.InitBreaks(Bytes);
      Brk := dbUnknown;
      SegIdx0         := TheSegNameIdx(SegBase);
      SegIdx          := SegIdx0;

      CurProc0        := CURPROC;
      StartLineNr     := LineNrFromIPC(RelIPC, fSourceCodeOffsets);

      if CurrentMemo = Memo3 then // source code stepping
        begin
          repeat
            // Next line allows us to step back to the procedure that originally called this one.
            Was_RPU := (NextOpCode in OpsTable.Return_Ops) and SameProcedure();
            Brk     := SourceCode_Step;
            SegIdx  := TheSegNameIdx(SegBase);
            CurrentLineNr := LineNrFromIPC(RelIPC, fSourceCodeOffsets);
          until (SameProcedure() and (CurrentLineNr <> StartLineNr)) or Was_RPU or (Brk = dbException);
        end
      else { if CurrentMemo = Memo1 then p-Code stepping }
        begin
          repeat
            Was_RPU := (NextOpCode in OpsTable.Return_Ops) and SameProcedure();
            Brk     := Single_Step;
            SegIdx  := TheSegNameIdx(SegBase);
          until SameProcedure() or Was_RPU or (Brk = dbException);
        end;

      UpdateDebuggerDisplay;
    end;
end;  { StepOver1Click }

function TfrmPCodeDebugger.RunToLineNumber(LineNo: integer; Offsets: TOffsetsList): TBrk;  {F4}
var
  SegIdx, SegIdx0: TSegNameIdx;
  CurProc0: integer;
begin
  if (LineNo > 0) and (LineNo < Length(Offsets)) then
    begin
      with fInterpreter as TCustomPsystemInterpreter do
        begin
          SegIdx0  := TheSegNameIdx(SegBase);
          CurProc0 := CURPROC;
          repeat
            result := SourceCode_Step;
            if result <> dbUnknown then
              Exit;
            SegIdx := TheSegNameIdx(SegBase);
          until (SegIdx = SegIdx0) and
                (CURPROC = CurProc0)
                and (LineNo = LineNrFromIPC(RelIPC, Offsets));
        end;
    end
  else
    raise Exception.Create('LineNumber Out of range in RunToLineNumber');
end;


procedure TfrmPCodeDebugger.RuntoCursorClick(Sender: TObject);
var
  Memo: TMemo;
begin
  inherited;

  CloseOpenEdits;
  Brk := dbUnknown;
  with fInterpreter as TCustomPsystemInterpreter do
    DEBUGGERSettings.Brks.InitBreaks(Bytes);
    
  Update_Status('');

  Memo   := Sender as TMemo;
  if Memo = Memo1 then
    Brk := RunToLineNumber(fKeyDownRow, fPCodeOffsets) else
  if Memo = Memo3 then
    Brk := RunToLineNumber(fKeyDownRow, fSourceCodeOffsets);
  UpdateDebuggerDisplay;
end;

procedure TfrmPCodeDebugger.GetRowCol(Memo: TMemo; var Row, Col: word);
begin
  Row := Memo.Perform(EM_LINEFROMCHAR, -1, 0);
  Col := (Memo.SelStart - SendMessage(Memo.Handle, EM_LINEINDEX, Row, -1 {0}));
end;

procedure TfrmPCodeDebugger.SetRowCol(Memo: TMemo; var Row, Col: word);
begin
  with Memo do
    begin
      SelStart := Perform(EM_LINEINDEX, Row, 0) + Col;
      SelLength := 0;
      Perform(EM_SCROLLCARET, 0, 0);
      SetFocus;
    end;
end;

function TfrmPCodeDebugger.CodeOffset(Memo: TMemo): word;
var
  LineNo: integer;
begin
  LineNo   := Memo.Perform(EM_LINEFROMCHAR, -1, 0);

  if Memo = Memo1 then
    result := fPCodeOffsets[LineNo] else
  if Memo = Memo3 then
    result := fSourceCodeOffsets[LineNo]
  else
    result := 0;
end;


procedure TfrmPCodeDebugger.ToggleBreakpoint1Click(Sender: TObject);
var
  idx: integer;
  SegIdx0: TSegNameIdx;
  CurProc0: word;
  anIPC: word;
begin
  inherited;
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      SegIdx0  := TheSegNameIdx(SegBase);

      CurProc0 := CURPROC;

      anIPC    := CodeOffset(fSelectedMemo);

      with DEBUGGERSettings do
        begin
          idx      := Brks.IndexOf(CurProc0, anIPC, dbBreak,  SegIdx0);
          if idx >= 0 then              // there is already a break here
            Brks.Delete(idx)            // delete it
          else                          // otherwise, add one here
            Brks.AddBreak(CurProc0, anIPC, dbBreak, SegIdx0)
        end;
    end;
   DisplayBreakPoints;
end;

procedure TfrmPCodeDebugger.PageControl1Change(Sender: TObject);
begin
  inherited;
  SetIPCOffsetsToPage;
  SelectCurrentLine(CurrentMemo(), RelIPC);

//DisplayWatches;

  if PageControl1.ActivePage = tabSysCom then
    DisplaySyscom else
  if PageControl1.ActivePage = tabHistory then
    begin
{$IfDef History}
      DisplayHistory(fMAXHIST);
{$else}
      sgHistory.Visible := false;      
{$EndIf}
{$IfDef Pocahontas}
      DisplayPHITS;
      DisplayCspPhits;
      lblReminder.Visible := false;
{$else}
      sgPHITS.Visible     := false;
      lblOpsPHITS.Visible := false;
      lblPHITS.Visible    := false;
      btnResetOpsPhits.Visible := false;

      sgCSPPHITs.Visible  := false;
      lblCSPPHITS.Visible := false;
      lbpCSPPHITS.Visible := false;
      btnResetCspPhits.Visible := false;
      lblReminder.Visible := true;
{$EndIf}
    end else
  if PageControl1.ActivePage = tabBreakPoints then
    begin
      DisplayBreakPoints;
      AdjustColumnWidths(sgBreakPoints);
    end else
  if PageControl1.ActivePage = tabMessages then
    AdjustColumnWidths(sgMessages) else
  if PageControl1.ActivePage = tabDirectory then
    DisplayGlobalDirectory else
  if PageControl1.ActivePage = tabProfile then
    DisplayProfile else
  if PageControl1.ActivePage = TabCrtKeyInfo then
    DisplayCrtKeyInfo;
end;

function TfrmPCodeDebugger.ReformLine(var Line: string): string;
var
  NumStr, Prefix, HexStr: string;
  lp, rp,        // parens   ()
  lb, rb,        // brackets []
  cp,            // start of comment
  cs: word;      // pcode start
  PrefixVal,
  HexVal: word;
  handled: boolean;

//  Has to handle several formats:
//
//  first:
//        D79F (  23): SLDO1                      // if syscom^.gdirp^[entry].dtid=filename
//  second:
//        E56A (   4): [173] SLOD1         6      // small_size:=poolblks div n_pools;
//  third:
//        10(00A):   FJP        134            D47A           //

begin { ReformLine }
  result := Line;                  // default if we cannot fix it
  lp     := Pos('(', Line);        // look for opening delimiter
  rp     := Pos(')', Line);        // and closing delimiter
  cp     := Pos('//', Line);          // and start of comment
  if cp = 0 then                      // if any
    cp := Length(Line) + 1;           // if not, entire line is game

  if (lp > 0)         // found opening paren
     and (rp > lp)    // and a closing paren after it
     and (rp < cp) then  // and both precede eol or comment start
    begin
      Prefix := Trim(Copy(Line, 1, lp-1));
      HexStr := Trim(Copy(Line, lp+1, rp-lp-1));
      NumStr := HexStr;

      handled := false;
      if IsPureNumeric(Prefix) and IsPureHex(HexStr) then // this may be the third format
        begin
          PrefixVal := StrToInt(Prefix);
          HexVal    := HexStrToWord(HexStr);
          if (PrefixVal = HexVal) and (Pos(':', Line) > 0) then        // then all seems well
            begin
              result   := Padl(Prefix, 4) + ':' + Trim(Copy(Line, 16, MAXINT));    // copy just the meat
              handled  := true;
            end
          else
            NumStr := HexStr;      // perhaps this is the decimal string
        end;

      if (not handled) and IsPureNumeric(NumStr) then
        begin
          lb      := Pos('[', Line); // look for a '[' as a opening bracket
          rb      := Pos(']', Line); // and ']' as a closing bracket

          if (lp < lb) and (lb < rb) and (rb < cp) then
            cs := rb+2   // then we have the (nnn) [nnn] format
          else
            cs := rp+2;  // otherwise, we have the  (nnn) format

          result := Padl(NumStr, 4) + ':' + Copy(Trim(Line), cs, MAXINT)
        end;
    end
end;  { ReformLine }

function TfrmPCodeDebugger.CleanUpLine(Line: string): string;
var
  Temp: string;

begin { TfrmPCodeDebugger.CleanUpLine }
  Temp   := Trim(Line);
  result := Line;                     // default to no change
  if not ((Length(temp) >= 2) and (Temp[1] = '/') and (temp[2] = '/')) then // if it starts with "//", then it is a comment-- just copy it
    result := ReformLine(Line);
end;  { TfrmPCodeDebugger.CleanUpLine }

procedure TfrmPCodeDebugger.CleanUpPostedPCode(Memo: TMemo);
var
  LineNr: integer;
begin
  with Memo do
    begin
      for LineNr := Lines.Count-1 downto 0 do
        Lines[LineNr] := CleanUpLine(Lines[LineNr]);
      Modified      := true;
    end;
end;

procedure TfrmPCodeDebugger.PasteToMemo(Memo: TMemo);
begin
  fProcessingMemoLoad := true;
  try
    Memo.Clear;
    Memo.PasteFromClipboard;

    CleanUpPostedPCode(Memo);
    SetIPCOffsetsToPage;
    SelectCurrentLine(Memo, RelIPC);
//  Save1.Enabled := true;
    Memo.Modified := true;
  finally
    fProcessingMemoLoad := false;
  end;
end;

procedure TfrmPCodeDebugger.PasteExternalpCode1Click(Sender: TObject);
begin
  inherited;
  if PageControl1.ActivePage = tabPCode then
    PasteToMemo(Memo1);
end;

procedure TfrmPCodeDebugger.VCLMemoToFileMemo(Memo: TMemo; MemoField: TMemoField);
var
  BlobStream: TStream;
  i: integer;
  Line: string;
begin
  with fpCodesProcTable do
    begin
      MemoField.Transliterate := TRANSLITERATE;
      BlobStream := CreateBlobStream(MemoField, bmWrite);

      try
        BlobStream.Seek(0, soFromBeginning);

        for i := 0 to Memo.Lines.Count - 1 do
          begin
            Line := TrimRight(Memo.Lines[i]) + CRLF;
            BlobStream.WriteBuffer(pchar(Line)^, Length(Line));      // write the string
          end;
          
      finally
        Memo.Modified := false;
        FreeAndNil(BlobStream);
      end;
    end;
end;


procedure TfrmPCodeDebugger.SaveUpdatedPCode(DontAsk: boolean);
var
  aSegName, aProcName: string;
  OK: boolean;
begin
  aSegName    := SegNamesInDB[fLastSegmentIdx];
  aProcName   := fCurrentProcName; // ProcNamesInDB[fLastSegmentIdx, gLastProcNr];

  if DontAsk or YesFmt('Has not been saved. Are you sure that you want to overwrite %s.%s?',
                       [aSegName, aProcName]) then
    begin
      fSavingPcode := true;
      try
        with fpCodesProcTable do
          begin
            if not (SameText(aSegName,      fldSegmentName.AsString) and
                    SameText(fCurrentProcName, fldProcedureName.AsString)) then
              begin
                OK := Locate(IndexName_SEGNAME_PROC_NR_NAME_INDEX, VarArrayOf([aSegName, fLastProcNr, fCurrentProcName]), [loCaseInsensitive]);
                if not OK then
                  begin
                    if not AddProcInfo(fLastSegmentIdx, aSegName, fLastProcNr, fCurrentProcName, true) then
                      AlertFmt('System error in SaveUpdatedCode. Record %s.%s was missing and could not be added',
                               [aSegName, fCurrentProcName]);
                  end
                else
                  Edit;
              end
            else
              Edit;

            VCLMemoToFileMemoFromPage;
            Post;
            Update_StatusFmt('Updated %s.%s', [aSegName, aProcName], clLime);
          end;
      finally
        fSavingPcode := false;
      end;
    end;
end;

procedure TfrmPCodeDebugger.VCLMemoToFileMemoFromPage;
begin
  with fpCodesProcTable do
    begin
      if Memo1.Modified then
        VCLMemoToFileMemo(Memo1, fldDecodedPCode as TMemoField);
      if Memo3.Modified then
        VCLMemoToFileMemo(Memo3, fldSourceCode as TMemoField);
    end;
end;


procedure TfrmPCodeDebugger.Save1Click(Sender: TObject);
begin
  inherited;
  SaveUpdatedPCode(true);
end;

procedure TfrmPCodeDebugger.Paste2Click(Sender: TObject);
begin
  inherited;
  Memo1.PasteFromClipboard;
end;

procedure TfrmPCodeDebugger.Copy2Click(Sender: TObject);
begin
  inherited;
  Memo1.CopyToClipBoard;
end;

procedure TfrmPCodeDebugger.Cut2Click(Sender: TObject);
begin
  inherited;
  Memo1.CutToClipBoard;
end;

procedure TfrmPCodeDebugger.SaveUpdatedpCode1Click(Sender: TObject);
begin
  inherited;
  SaveUpdatedPCode;
end;

procedure TfrmPCodeDebugger.DisplayCursorPos(Memo: TMemo);
var
  Row, Col: word;
begin
  GetRowCol(Memo, Row, Col);
  lblRowCol.Caption := Format('Row=%d, Col=%d', [Row+1, Col+1]);
end;


procedure TfrmPCodeDebugger.Memo1Change(Sender: TObject);
var
  Memo: TMemo;
begin
  inherited;
  Memo := Sender as TMemo;
  if not fProcessingMemoLoad then
    if Memo = Memo1 then
      SetIPCOffsets(Memo, fPCodeOffsets) else    // line number offsets may have changed
    if Memo = Memo3 then
      SetIPCOffsets(Memo, fSourceCodeOffsets)
end;

procedure TfrmPCodeDebugger.ToggleEnabled1Click(Sender: TObject);
var
  r: integer;
begin
  inherited;
  with sgBreakPoints do
    with Selection do
      begin
        for r := Top to Bottom do
          with DEBUGGERSettings.Brks.Items[R-1] as TBreakInfo do
            begin
              Disabled := not Disabled;
              if Disabled then
                Cells[COL_DISABLED, R] := 'DISABLED'
              else
                Cells[COL_DISABLED, R] := '';
            end;
        SaveSettings(DEBUGGERSettingsFileName(VersionNr));
      end;
end;

procedure TfrmPCodeDebugger.SelectCurrentLine(Memo: TMemo; anIPC: word);
var
  LineNr: word;
begin
  if Assigned(Memo) then
    begin
      LineNr := 0;
      
      if Memo = Memo1 then
        LineNr := LineNrFromIPC(anIPC, fPCodeOffsets) else // may need to re-find the current line
      if Memo = Memo3 then
        LineNr := LineNrFromIPC(anIPC, fSourceCodeOffsets);

      SelectMemoLine(Memo, LineNr);
    end
end;


procedure TfrmPCodeDebugger.UpdateCursor1Click(Sender: TObject);
begin
  inherited;

  SelectCurrentLine(Sender as TMemo, RelIPC);
end;

procedure TfrmPCodeDebugger.MemoKeyPress(Sender: TObject; var Key: Char);
const
  TABWIDTH = 8;
var
  Row, Col, NrBlanks: word;
  Blanks: string;
  Memo: TMemo;
begin
  inherited;
  if EnableMemoEditing1.Checked then
    begin
      Memo := Sender as TMemo;
      case ord(Key) of
        VK_TAB:
          begin
            GetRowCol(Memo, Row, Col);
            NrBlanks := TABWIDTH - (Col MOD TABWIDTH);
            Blanks   := Padr('', NrBlanks);
            (Sender as TMemo).SelText := Blanks;
            Key := #0;
          end;
      end;
      SetIPCOffSetsToPage(Memo);
      DisplayCursorPos(Memo);
    end
  else
    begin
      SysUtils.Beep;
      Key := #0;
    end;
end;

procedure TfrmPCodeDebugger.Memo1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  DisplayCursorPos(Sender as TMemo);
end;

procedure TfrmPCodeDebugger.CleanUpPastedSource(Memo: TMemo; VersionNr: TVersionNr);
var
  LineNr: integer;
  Line: string;
  OK: boolean;

  function CleanUpSourceLine(Line: string; var OK: boolean): string;
  var
    IsData: boolean;
    LineNrStr: string;
    SegNrStr: string;
    ProcNrStr: string;
    OffsetStr: string;
    SourceLine: string;
    LevelStr: string;
  begin
    Line       := TabsToSpaces(Line);
    with ListingInfo[VersionNr] do
      begin
        LineNrStr  := Trim(Copy(Line, LNB, LNW));
        SegNrStr   := Trim(Copy(Line, SNB, SNW));
        ProcNrStr  := Trim(Copy(Line, PNB, PNW));
        LevelStr   := Trim(Copy(Line, NLB, NLW));
        OffsetStr  := Trim(Copy(Line, OB, OW));
        SourceLine := TrimRight(Copy(Line, SCB, SCW));
      end;

    OK         := IsPureNumeric(LineNrStr) and
                  IsPureNumeric(SegNrStr) and
                  IsPureNumeric(ProcNrStr) and
                  IsPureNumeric(OffsetStr);
    IsData     := LevelStr = 'd';
    if OK and (not IsData) then
      result := Padl(OffsetStr,4) + ': ' + SourceLine
    else if IsData then
      result := Padl('', 4+2) + SourceLine
    else
      result := Line;
  end;

begin { CleanUpPastedSource }
  with Memo do
    begin
      for LineNr := Lines.Count-1 downto 0 do
        begin
          Line := CleanUpSourceLine(Lines[LineNr], OK);
          if OK then
            Lines[LineNr] := Line
          else
            Lines.Delete(LineNr);
        end;
      Modified := true;
    end;
end;  { CleanUpPastedSource }


procedure TfrmPCodeDebugger.PasteExternalSourceCode(VersionNr: TVersionNr);
begin
  fProcessingMemoLoad := true;
  try
    Memo3.Clear;
    Memo3.PasteFromClipboard;

    CleanUpPastedSource(Memo3, VersionNr);

    SetIPCOffsetsToPage(Memo3);

    SelectCurrentLine(Memo3, RelIPC);

//  Save1.Enabled := true;
    Memo3.Modified := true;
  finally
    fProcessingMemoLoad := false;
  end;
end;

procedure TfrmPCodeDebugger.miMemo3CopyClick(Sender: TObject);
begin
  inherited;
  Memo3.CopyToClipboard;
end;

procedure TfrmPCodeDebugger.miMemo3PasteClick(Sender: TObject);
begin
  inherited;
  Memo3.PasteFromClipboard;
end;

procedure TfrmPCodeDebugger.miMemo3CutClick(Sender: TObject);
begin
  inherited;
  Memo3.CutToClipboard;
end;

function TfrmPCodeDebugger.GetModified: boolean;
begin
  result := Memo1.Modified or Memo3.Modified;
end;

procedure TfrmPCodeDebugger.MemoClick(Sender: TObject);
begin
  inherited;
  fSelectedMemo := Sender as TMemo;

  SetIPCOffSetsToPage(fSelectedMemo);

  if not EnableMemoEditing1.Checked then
    SelectCurrentLine(fSelectedMemo, RelIPC);

  GetRowCol(fSelectedMemo, fKeyDownRow, fKeyDownCol);
  DisplayCursorPos(fSelectedMemo);

  ShowEditMode;
end;

procedure TfrmPCodeDebugger.ShowEditMode;
begin
  with lblEditMode do
    if EnableMemoEditing1.Checked then
      begin
        Caption := 'Editing';
        Color   := clYellow;
      end
    else
      begin
        Caption := '';
        Color   := clBtnFace;
      end
end;


function TfrmPCodeDebugger.GetRelIPC: word;
var
  I: TCustomPsystemInterpreter;
begin
  if fUserOpenedProcIsLoaded then
    result := fUserOpenedIPC
  else
    begin
      I := fInterpreter as TCustomPsystemInterpreter;
      result := I.RelIPC;
    end;
//  with fInterpreter as TIVPsystemInterpreter do
//    result := SI-ProcBase;
end;

function TfrmPCodeDebugger.GetCurProc: integer;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := CurProc;
end;

function TfrmPCodeDebugger.GetSegNameIdx: TSegNameIdx;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    if SegBase <> fLastSegBase then
      begin
        fSegNameIdx  := TheSegNameIdx(SegBase);
        fLastSegBase := SegBase;
      end;
    result := fSegNameIdx;
end;

function TfrmPCodeDebugger.Caller(     Calls: integer;
                                   Var aProcNum: integer;
                                   var aSegIdx: TSegNameIdx): boolean;
var
  MSCWAddr: word;
//p: TMscwPtr;
begin
  with fInterpreter as TIVPsystemInterpreter do
    begin
      MSCWAddr := MP;
      result := MSCWField(MSCWAddr, csProc) <> 0;
      if result then
        begin
          if Calls = 0 then
            begin
              aProcNum := CURPROC;
              aSegIdx := TheSegNameIdx(DS);
            end
          else
            begin
              repeat
                MSCWAddr := MSCWField(MSCWAddr, csDynamic);
                Calls  := Calls - 1;
              until calls = 0;
              aProcNum := MSCWField(MSCWAddr, csProc);
              aSegIdx := TheSegNameIdx(GetSegBase(MSCWAddr));
            end;
        end;
    end;
end;


procedure TfrmPCodeDebugger.RunUntilReturn1Click(Sender: TObject);  {[shift]F8}
Var
  CurProc0: integer;
  SegIdx0, SegIdx: TSegNameIdx;
begin
  inherited;

  Brk := dbUnknown;
  Update_Status('');

  CloseOpenEdits;
// Need to determine what the immediate calling procedure was,
// and then run until it is the current procedure
  with fInterpreter as TCustomPsystemInterpreter, DEBUGGERSettings do
    begin
      Brks.InitBreaks(Bytes);
      if Caller(1, CurProc0, SegIdx0) then
        begin
          repeat
            Single_Step;
            SegIdx := TheSegNameIdx(SegBase)
          until (SegIdx = SegIdx0) and
                (CURPROC = CurProc0);
          UpdateDebuggerDisplay;
        end;
    end;
end;

procedure TfrmPCodeDebugger.miRunToHereClick(Sender: TObject);
begin
  inherited;
  RuntoCursorClick(Memo3);
end;

procedure TfrmPCodeDebugger.RuntoHere1Click(Sender: TObject);
begin
  inherited;
  RuntoCursorClick(Memo1);
end;

procedure TfrmPCodeDebugger.MenuItem5Click(Sender: TObject);
begin
  inherited;
  RuntoCursorClick(Memo3);
end;

function TfrmPCodeDebugger.GetWordAt(P: word): word;
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

procedure TfrmPCodeDebugger.EnableMemoEditing1Click(Sender: TObject);
var
  Memo: TMemo;
begin
  inherited;

  EnableMemoEditing1.Checked := not EnableMemoEditing1.Checked;

  Memo := CurrentMemo();

  if not EnableMemoEditing1.Checked then
    begin
      SelectCurrentLine(Memo, RelIPC);
      SaveUpdatedPCode(true);
    end;

  ShowEditMode;
end;

procedure TfrmPCodeDebugger.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Memo: TMemo;
  Line: string;
  NrBlanks, I: integer;
  Row, Col: word;
begin
  inherited;
  if Sender is TMemo then
    Memo := Sender as TMemo
  else
    Memo := Memo3; // debugging

  case Key of
    Ord('T'), Ord('t'):
      begin
        if ssCtrl in Shift then // ^T
          begin
            // count the number of blanks to be deleted
            GetRowCol(Memo, Row, Col);
            Line := Memo.Lines[Row];

            i := Col+1; NrBlanks := 0;
            if Line[i] = ' ' then
              begin
                repeat
                  i := i + 1;
                  Inc(NrBlanks);
                until (i > length(Line)) or (Line[i] <> ' ');
                Delete(Line, Col+1, NrBlanks);
                Memo.Lines[row] := Line;
                SetRowCol(Memo, Row, Col);
              end;
            Key := 0;
          end;
      end;
    VK_DELETE:
      begin
        if Memo.SelLength = 0 then
          begin
            Memo.SelLength := 1;
            Memo.SelText   := '';
          end
        else
          Memo.SelText := '';
        Key := 0;
      end;

    VK_ESCAPE:
      begin
        if EnableMemoEditing1.Checked and Yes('Cancel Edit changes?') then // Cancel any edit changes already made
          begin
            Memo.Modified := false;
            if FetchProcInfo(fLastSegmentIdx, fLastProcNr, fCurrentProcName, RelIPC, true) then
              begin
                ShowEditMode;
                Update_Status('Edit Cancelled. Reloaded', clYellow);
              end;
          end;
      end;
  end;
  GetRowCol(Memo, fKeyDownRow, fKeyDownCol);
  SetIPCOffSetsToPage(Memo);
  DisplayCursorPos(Memo);
end;

procedure TfrmPCodeDebugger.FindInMemoClick(Sender: TObject);
begin
  inherited;
  FindDialog1.Execute;
end;

procedure TfrmPCodeDebugger.FindStringInMemo(Memo: TMemo; const SearchFor: string);
var
  StartPos, ToEnd, FoundAt: integer;

  function FindText(const SearchFor: string; StartPos, Len: word; IgnoreCase: boolean): integer;
  var
    p1, p2: pchar;
  begin { FindText }
    p1 := Pchar(Memo.Text);
    p2 := MyStrPos(p1+ StartPos, pchar(SearchFor),  Len, true);
    if p2 <> nil then
      result := p2 - p1
    else
      result := -1;;
  end;  { FindText }

begin { FindStringInMemo }
  with Memo do
    begin
      { begin the search after the current selection if there is one }
      { otherwise, begin at the start of the text }
//    if SelLength <> 0 then
//      StartPos := SelStart + SelLength
//    else
//      StartPos := 0;

      StartPos := SelStart + SelLength;  // 20230320 - F3 was always starting at the top

      { ToEnd is the length from StartPos to the end of the text in the rich edit control }

      ToEnd := Length(Text) - StartPos;

      FoundAt := FindText(SearchFor, StartPos, ToEnd, true);
      if FoundAt <> -1 then
        begin
//        if PageControl1.ActivePage <> tabPCode then
//          PageControl1.ActivePage := tabPCode;
//        SetFocus;
          SelStart  := FoundAt;
          SelLength := Length(SearchFor);
        end
      else
        Update_Status(Format('String "%s" not found', [SearchFor]), clYellow)
    end;
end;  { FindStringInMemo }

procedure TfrmPCodeDebugger.SelectAllClick(Sender: TObject);
begin
  inherited;
  if Assigned(fSelectedMemo) then
    with fSelectedMemo do
      begin
        SelStart  := 0;
        SelLength := Length(Text);
      end;
end;

procedure TfrmPCodeDebugger.pumPopup(Sender: TObject);
begin
  inherited;
  if Sender is TPopupMenu then
    fSelectedMemo := (Sender as TPopupMenu).PopupComponent as TMemo
  else
    fSelectedMemo := nil;
end;

procedure TfrmPCodeDebugger.ProgramReset1Click(Sender: TObject);
begin
  inherited;
  if Yes('Do you really want to reset the OS?') then
    begin
      Update_Status('Memory Cleared', clYellow);
      ClearDebuggerDisplay;
    //  FreeAndNil(gInterpreter);
      Enable_Run(false);
    end;
end;

procedure TfrmPCodeDebugger.Memo3MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Memo: TMemo;
  Pt: DWORD;
  CharLineIndex: DWORD;
begin
  inherited;

  Memo := Sender as TMemo;

  Pt := (X and $FFFF) or ((Y and $FFFF) shl 16);// Combine X and Y values

  with Memo do
    begin
      CharLineIndex := SendMessage(Memo.Handle,EM_CHARFROMPOS, 0, Pt);
      fKeyDownRow   := (CharLineIndex shr 16) and $FFFF;
    end;

  SetIPCOffSetsToPage(Memo);
end;

procedure TfrmPCodeDebugger.RuntoCursor1Click(Sender: TObject);  {F4}
begin
  inherited;
  RuntoCursorClick(CurrentMemo());
end;

(*
function TfrmPCodeDebugger.GetNextOpCode: word;
begin
  with fInterpreter as TIVPsystemInterpreter do
    result   := Bytes[DS+SI];
end;
*)

procedure TfrmPCodeDebugger.GetMemoLists(var pCodeList, SrcCodeList: TStringList);
begin
  if not Assigned(pCodeList) then
    pCodeList := TStringList.Create;

  pCodeList.Assign(Memo1.Lines);

  if not Assigned(SrcCodeList) then
    SrcCodeList := TStringList.Create;

  SrcCodeList.Assign(Memo3.Lines);
end;


procedure TfrmPCodeDebugger.ExternalDecoderWindow1Click(Sender: TObject);
var
  W: TFrmDecodeWindow;
  I: TCustomPsystemInterpreter;
begin
  inherited;

  I := fInterpreter as TCustomPsystemInterpreter;                

  if not Assigned(frmDecodeWindow) then
    frmDecodeWindow := TfrmDecodeWindow.Create(self, fInterpreter);

  W := frmDecodeWindow;

  W.ProcNumber := I.CurProc;  // I.Globals.LowMem.CURPROC;
  W.AbsIPC     := I.AbsIPC;   // actual memory address within Bytes[]
  W.OnGetMemoLists := GetMemoLists;
  W.Show;
end;

procedure TfrmPCodeDebugger.AddLineSeperator(anOpCode: word);
begin
  with fInterpreter as TCustomPsystemInterpreter do
    with OpsTable do
      if anOpCode in (Store_OPS + Jump_OPS + Call_OPS) then
        AddLine('');
end;

procedure TfrmPCodeDebugger.DisplaySyscom;
type
  TPre_crt_info = (p_right, p_left, p_up, p_down, p_badch, p_stop,
                   p_break, p_flush, p_eof, p_altmode, p_linedel,
                   p_chardel, p_etx, p_alpha_lock, p_insert, p_delete);
var
  temp      : string;
  LineNr    : integer;
  SyscomBase: pchar;
  GlobalsBase: pchar; // Pchar(Globals)

  function PrefixName(pre: TPre_crt_info): string;
  begin
    case pre of
      p_right:   result := 'right';
      p_left:    result := 'left';
      p_up:      result := 'up';
      p_down:    result := 'down';
      p_badch:   result := 'badch';
      p_stop:    result := 'stop';
      p_break:   result := 'break';
      p_flush:   result := 'flush';
      p_eof:     result := 'eof';
      p_altmode: result := 'altmode';
      p_linedel: result := 'linedel';
      p_chardel: result := 'chardel';
      p_etx:     result := 'etx';
      p_alpha_lock: result := 'alpha_lock';
      p_insert:  result := 'insert';
      p_delete:  result := 'delete';
    end;
  end;

  procedure Heading(const Cap: string = '');
  begin
    if LineNr >= MemoSysCom.Lines.Count then
      MemoSysCom.Lines.Add(Cap)
    else
      MemoSysCom.Lines[LineNr] := Cap;

    Inc(LineNr);
  end;

  procedure ReplaceLine(const s: string; Field: pchar);
  var
    OffsetS: integer;
    OffsetM: word;
    Temp, Prefix, AdrStr, OfsStr: string;
  begin
    try
      if Field <> nil then
       with fInterpreter as TCustomPsystemInterpreter do
        begin
{$R-}
          OffsetS := Field - SyscomBase;      // relative to SysCom
          if Word_Memory then
            OffsetS := OffsetS shr 1;         // to get a word offset

          OffsetM := WordIndexed(SysComAddr, 0) + OffsetS;   // calculate actual address

          if cbAddrInHex.Checked then
            AdrStr := Format('%5.5x', [OffsetM])
          else
            AdrStr := Format('%5d', [OffsetM]);

{$R+}
          if cbOffsetInHex.Checked then
            OfsStr := Format('%4.4x', [OffsetS])
          else
            OfsStr := Format('%4d', [OffsetS]);

          Prefix := Format('%s:%s: ', [OfsStr, AdrStr]);
        end
      else
        Prefix := Padr('', 11);

      Temp := Prefix + s;
    except
      on e1:Exception do
        Temp := Format('%s: %s', [s, e1.Message]);
    end;

    if LineNr >= MemoSysCom.Lines.Count then
      MemoSysCom.Lines.Add(Temp)
    else
      MemoSysCom.Lines[LineNr] := Temp;

    Inc(LineNr);
  end;

  procedure ReplaceLineFmt(const s: string; Args: array of const; Offset: pointer);
  var
    temp: string;
  begin
    temp := Format(s, Args);
    ReplaceLine(temp, Offset);
  end;

  procedure WriteSem(SemName: string; var sem: Tsemaphore);
  begin
    ReplaceLine(SemName, Pointer(@sem));
    with sem do
      begin
        ReplaceLineFmt('  sem_count   = %d', [sem_count],  Pointer(@sem_count));
        ReplaceLineFmt('  sem_wait_q  = %d', [sem_wait_q], Pointer(@sem_wait_q));
      end;
  end;

  procedure WriteFaultMessage(var Fault_message: TFault_message);
  var
    Line: string;
  begin
(*
{0}    {18}         fault_tib: tib_p;        // points to the Task Information Block (TIB) of the faulting task.
{2}    {20}         fault_e_rec: e_rec_p;    // points to the Environment record of the current segment or of the missing segment (for segment faults).
{4}    {22}         fault_words: integer;    // is the number of words needed (e.g. for stack faults). It's 0 for segment faults.
//{6}               fault_type: seg_fault..pool_fault;
{6}    {24}         fault_type: integer;     // indicates the type of fault ($80=segment, $81=stack, heap, pool, etc).
*)
    with Fault_Message, fInterpreter as TCustomPsystemInterpreter do
      begin
{$R-}
        Line := Format('fault_tib   = %s', [BothWays(fault_tib)]);
        if Fault_TIB <> 0 then
          Line := Line + '; ' + MemDumpDW(fault_tib, wt_TIBp);
        ReplaceLine(Line, Pointer(@fault_tib));

        Line := Format('fault_e_rec = %s', [BothWays(fault_e_rec)]);
        if fault_e_rec <> 0 then
          Line := Line + MemDumpDW(fault_e_rec, wt_ERECp);
        ReplaceLine(Line, Pointer(@fault_e_rec));

        ReplaceLineFmt('fault_words = %s', [BothWays(fault_words)], Pointer(@fault_words));
        ReplaceLineFmt('fault_type  = %s {%s}', [BothWays(fault_type), FaultTypeStr(fault_type)], Pointer(@fault_type));
{$R+}
      end;
  end;

  function ToChar(ch: char): string;
  begin
    if (ch >= ' ') and (ch <= #126) then
      result := '''' + ch + ''''
    else
      result := '#' + IntToStr(ord(ch));
  end;

  function SocketPoolInfo2(SocketPoolInfo: TSocketPoolInfo): string;
  (*
  TSocketPoolInfo = record
                      Base: FullAddress; {4} {address of area}
                      Size: word;        {2} {size units vary see above}
                    end;
  *)
  begin
    with SocketPoolInfo do
      result := Format('$%8.8x, Size:%d', [FulladdressToLongWord(Base), Size]);
  end;

  procedure DisplayUnitTable(Addr: word);
  type
    TUnion = record
              case integer of
                0: (UTablEntry: TUTablEntry);
                1: (byt: packed array[0..Sizeof(TUTablEntry)] of byte);
                2: (wrd: packed array[0..SizeOf(TUTablEntry) div 2] of word);
              end;
  var
    i: integer;
    aLine: string;
    aRec: TUnion;
    aUVID, aUPVID: string;   // Strings stuffed into pSystem records don’t always have a trailing zero byte
                             // which may cause problems (i.e. "Empty()")
                             // so I copy them to local variables to fix.
  begin { DisplayUnitTable }
    if fInterpreter is TIVPsystemInterpreter then
      with fInterpreter as TIVPsystemInterpreter do
        with SyscomPtr^.UnitDivision do
          for i := 1 to SerialMax+SubsidMax do
            begin
              aRec.UTablEntry := TUTablEntryPtr(@Bytes[Addr])^;
              with aRec.UTablEntry do
                begin
                  aUVID  := UVID;
                  aUPVID := UPVID;
                  if not (Empty(aUVID) and Empty(aUPVID)) then
                    begin
                      aLine := copy(Format('Utable[%3d]: %s', [i-1, MemDumpDW(Addr, wt_UnitTabEntry)]), 1, 255 { truncate if too long });
                      ReplaceLine(aLine, nil);
                    end;
                end;
              Addr  := Addr + SizeOf(TUTablEntry);
            end
    else
      ReplaceLine('Version II DisplayUnitTable', nil);
  end;  { DisplayUnitTable }

  procedure DisplayIVSyscom;
  var
    SysComP   : TSysComPtr;

    function ListOfPrefixedValues: string;
    var
      Pre: TPre_crt_info;

      function OnePrefixValue(Pre: TPre_crt_info): string;
      var
        BitNr: byte;
      begin
        BitNr := ord(Pre);
        with SyscomP^.CrtCtrl do
          if Bits(Prefixed, BitNr, 1) = 1 then
            result := PrefixName(Pre)
          else
            result := '';
      end;

    begin { ListOfPrefixedValues }
      result := '';
      for pre := Low(TPre_crt_info) to High(TPre_crt_info) do
        begin
          Temp := OnePrefixValue(pre);
          if Temp <> '' then
            result := result + ' ' + Temp;
        end;
    end;  { ListOfPrefixedValues }

  begin { DisplayIVSyscom }
    with fInterpreter as TIVPsystemInterpreter do
      begin
        SysComP           := TSysComPtr(@Bytes[SysComAddr]);
        SyscomBase        := pchar(SyscomP);
        GlobalsBase       := Pchar(Globals);
        leSyscomAddr.Text := Format('$%4.4x', [SysComAddr]);
      end;

    with MemoSysCom.Lines, SyscomP^ do
      begin
        LineNr := 0;
        ReplaceLineFmt('SYSCOM @ %s',           [DateTimeToStr(Now)],   nil);
        ReplaceLineFmt('SizeOf(TIVSysComRec)=%d', [SizeOf(TIVSysComRec)],   nil);
        ReplaceLineFmt('SizeOf(TMiscInfo) =%d', [SizeOf(TMiscInfo)],    nil);
        ReplaceLineFmt('SizeOf(TLowMem)   =%d', [SizeOf(TIVLowMem)],      nil);
        Heading;

        Heading(' Ofs:  Abs:');
        ReplaceLineFmt('IOrslt      = %d',      [ORD(iorslt)],        Pointer(@iorslt));
        ReplaceLineFmt('APoolSize   = %d',      [APoolSize],          Pointer(@APoolSize));
        ReplaceLineFmt('SysUnit     = %d',      [sysunit],            Pointer(@sysunit));
        ReplaceLineFmt('Max_IO_Bufs = %d',      [max_io_bufs],        Pointer(@max_io_bufs));
        ReplaceLineFmt('gdirp       = %s',      [BothWays(gDirP)],    Pointer(@gDirP));
        with fault_sem do
          begin
            WriteSem('REAL_SEM',    real_sem);
            WriteSem('MESSAGE_SEM', message_sem);
            WriteFaultMessage(Fault_Message);
          end;
        ReplaceLineFmt('SubsidStart = %d', [subsidstart],           Pointer(@subsidstart));
        ReplaceLineFmt('AliasMax    = %d', [AliasMax],              Pointer(@AliasMax));
        ReplaceLineFmt('Spool_Avail = %s', [TFString(spool_avail)], Pointer(@spool_avail));

        with poolinfo do
          begin
  {$R-}
            ReplaceLineFmt('  PoolOutside = %s', [TFString(pooloutside)], Pointer(@pooloutside));
            ReplaceLineFmt('  PoolSize    = %s', [BothWays(poolsize)],    Pointer(@poolsize));
            ReplaceLineFmt('  PoolBase    = %8.8x', [FulladdressToLongWord(PoolBaseAddr)], Pointer(@PoolBaseAddr));
            ReplaceLineFmt('  Resolution  = %d', [resolution],            Pointer(@resolution));
  {$R+}
          end;

        ReplaceLineFmt(    'TimeStamp   = %d', [TimeStamp], Pointer(@TimeStamp));

        ReplaceLineFmt('UnitTable   = $%4.4x', [UnitTable], Pointer(@UnitTable));
        if UnitTable <> pNIL then
          DisplayUnitTable(UnitTable);

        ReplaceLine('UnitDivision', pointer(@UnitDivision));
        with UnitDivision do
          begin
            ReplaceLineFmt('  SerialMax   = %d', [serialmax], Pointer(@serialmax));
            ReplaceLineFmt('  SubsidMax   = %d', [subsidmax], Pointer(@subsidmax));
          end;

        with expaninfo do
          begin
            ReplaceLineFmt('InsertChar  = #%d', [ord(insertchar)], Pointer(@insertchar));
            ReplaceLineFmt('DeletChar   = #%d', [ord(deletchar)],  Pointer(@deletchar));
          end;

        if processor <= m_80187 then
          temp := Processor_Types[processor]
        else
          temp := 'Unknown';

        ReplaceLineFmt('Processor   = %s', [temp], Pointer(@processor));

        ReplaceLineFmt('Mem_Info    = %d', [Mem_Info], Pointer(@Mem_Info));

        temp := pMachineVersions[pmachver];
        ReplaceLineFmt('PmachineVers= %s', [temp], Pointer(@pmachver));

        ReplaceLineFmt('RealSize     = %d', [realsize], Pointer(@realsize));

        ReplaceLineFmt('miscinfo.flags=$%-4x nobreak[bit6],stupid[5],slowterm[4],hasxycrt[3],haslccrt[2],has8510a[1],hasclock[0]'+
                           'userkind: (normal[6,7], aquiz[8,9], booker[10,11],pquiz', [miscinfo.FLAGS], Pointer(@miscinfo.FLAGS));

        Heading;
        ReplaceLine('CRT_CTRL', pointer(@CrtCtrl));
        with CrtCtrl do
          begin
            ReplaceLineFmt('escape      = %s', [ToChar(escape)],     Pointer(@escape));
            ReplaceLineFmt('home        = %s', [ToChar(home)],       Pointer(@home));
            ReplaceLineFmt('eraseeos    = %s', [ToChar(eraseeos)],   Pointer(@eraseeos));
            ReplaceLineFmt('eraseeol    = %s', [ToChar(eraseeol)],   Pointer(@eraseeol));
            ReplaceLineFmt('ndfs        = %s', [ToChar(ndfs)],       Pointer(@ndfs));
            ReplaceLineFmt('rlf         = %s', [ToChar(rlf)],        Pointer(@rlf));
            ReplaceLineFmt('backspace   = %s', [ToChar(backspace)],  Pointer(@backspace));
            ReplaceLineFmt('fillcount   = %d', [fillcount],          Pointer(@fillcount));
            ReplaceLineFmt('clearline   = %s', [ToChar(clearline)],  Pointer(@clearline));
            ReplaceLineFmt('clearscreen = %s', [ToChar(clearscreen)], Pointer(@clearscreen));
  (*
            pre_crt_info = (p_right, p_left, p_up, p_down, p_badch, p_stop,
                            p_break, p_flush, p_eof, p_altmode, p_linedel,
                            p_chardel, p_etx, p_alpha_lock, p_insert, p_delete);
  *)
            ReplaceLineFmt('prefixed chars = %s', [ListOfPrefixedValues], Pointer(@Prefixed));       {packed array[0..15] of boolean;}
          end;

        Heading;
        ReplaceLine('CRT_INFO', pointer(@CrtInfo));
        with CrtInfo do
          begin
            ReplaceLineFmt('width       = %d', [width],             Pointer(@width));
            ReplaceLineFmt('height      = %d', [height],            Pointer(@height));
            ReplaceLineFmt('right       = %s', [ToChar(right)],     Pointer(@right));
            ReplaceLineFmt('left        = %s', [ToChar(left)],      Pointer(@left));
            ReplaceLineFmt('down        = %s', [ToChar(down)],      Pointer(@down));
            ReplaceLineFmt('up          = %s', [ToChar(up)],        Pointer(@up));
            ReplaceLineFmt('badch       = %s', [ToChar(badch)],     Pointer(@badch));
            ReplaceLineFmt('chardel     = %s', [ToChar(chardel)],   Pointer(@chardel));
            ReplaceLineFmt('stop        = %s', [ToChar(stop)],      Pointer(@stop));
            ReplaceLineFmt('break       = %s', [ToChar(break)],     Pointer(@break));
            ReplaceLineFmt('flush       = %s', [ToChar(flush)],     Pointer(@flush));
            ReplaceLineFmt('eof         = %s', [ToChar(eof)],       Pointer(@eof));
            ReplaceLineFmt('altmode     = %s', [ToChar(altmode)],   Pointer(@altmode));
            ReplaceLineFmt('linedel     = %s', [ToChar(linedel)],   Pointer(@linedel));
            ReplaceLineFmt('alphalok    = %s', [ToChar(alphalok)],  Pointer(@alphalok));
            ReplaceLineFmt('char_mask   = %s', [ToChar(char_mask)], Pointer(@char_mask));
            ReplaceLineFmt('etx         = %s', [ToChar(etx)],       Pointer(@etx));
            ReplaceLineFmt('prefix      = %s', [ToChar(prefix)],    Pointer(@prefix));
          end;

  (*
    MemInfo_Rec = record
  { 0}             NWords:integer;  {2} {size of meminfo_rec, currently 6}
  { 2}             FreeSpaceInfo,   {size units are 512 bytes}
                   SocketPoolInfo: TSocketPoolInfo; {6}
  {14}           end {meminfo_rec};
  *)
        Heading;
  //    if fInterpreter is TIVPsystemInterpreter then
          with fInterpreter as TIVPsystemInterpreter do
            begin
              ReplaceLine('MEM_INFO', Pointer(@Globals.MemInfo));  // referring to the record -- not to the pointer
              with Globals.MemInfo do
                begin
                  ReplaceLineFmt('  NWords         = %d', [NWords],            Pointer(@NWords));

                  temp := SocketPoolInfo2(SocketPoolInfo);
                  ReplaceLineFmt('  SocketPoolInfo = %s', [temp], Pointer(@SocketPoolInfo));

                  temp := SocketPoolInfo2(FreeSpaceInfo);
                  ReplaceLineFmt('  FreeSpaceInfo  = %s', [temp], Pointer(@FreeSpaceInfo));

                end;

              Heading;

              with Globals^ do
                begin
        //        ReplaceLineFmt('RootTask    => %s', [MemDumpD(RootTaskP, wt_TIBp)],  Pointer(@RootTask));
                  Heading;
                  ReplaceLineFmt('MainMscw    => %s', [MemDumpDW(MainMscwP, wt_MSCWp)], Pointer(@MainMscw));
                  Heading;
                  ReplaceLineFmt('MemTop      = $%4x', [MemTop], Pointer(@MemTop));
                end;
            end
  //    else
  //      ReplaceLine('Unimplemented Version II MemInfo', nil);

      end;
  end;  { DisplayIVSyscom }

  procedure DisplayIISyscom;
  var
    SysComP   : TSyscomIIPtr;
    SegTblAddr: word;
  begin { DisplayIISyscom }
    with fInterpreter as TUCSDInterpreter do
      begin
        SysComP           := TSyscomIIPtr(@Bytes[ByteIndexed(SysComAddr)]);
        SyscomBase        := pchar(SyscomP);
        GlobalsBase       := pchar(SyscomP); // Pchar(Globals);
        leSyscomAddr.Text := Format('$%4.4x', [SysComAddr]);
      end;

    with MemoSysCom.Lines, SyscomP^ do
      begin
        LineNr := 0;
        ReplaceLineFmt('SYSCOM @ %s',             [DateTimeToStr(Now)],   nil);
        ReplaceLineFmt('SizeOf(TIISysComRec)=%d', [SYSCOM_SIZE], nil);
        ReplaceLineFmt('SizeOf(TMiscInfo) =%d',   [SizeOf(TMiscInfo)],    nil);
        ReplaceLineFmt('SizeOf(TLowMem)   =%d',   [SizeOf(TIILowMem)],    nil);
        Heading;

        Heading(' Sys:  Abs:');
        ReplaceLineFmt('IOrslt      = %s',      [IOResultString(IORSLT)], Pointer(@IORSLT));
        ReplaceLineFmt('SysUnit     = %d',      [sysunit],                Pointer(@sysunit));
        ReplaceLineFmt('gdirp       = %s',      [BothWays(gDirP)],        Pointer(@gDirP));

        ReplaceLineFmt('STKBASE     = %4.4x',   [STKBASE],   Pointer(@STKBASE));
        ReplaceLineFmt('LASTMP      = %4.4x',   [LASTMP],    Pointer(@LASTMP));
        ReplaceLineFmt('JTAB        = %4.4x',   [JTAB],      Pointer(@JTAB));
//      ReplaceLineFmt('SEG         = %4.4x',   [SEG],       Pointer(@SEG));
        ReplaceLineFmt('MEMTOP      = %4.4x',   [MEMTOP],    Pointer(@MEMTOP));
        ReplaceLineFmt('BOMBIPC     = %4.4x',   [BOMBIPC],   Pointer(@BOMBIPC));
        ReplaceLineFmt('HLTLINE     = %4.4x',   [HLTLINE],   Pointer(@HLTLINE));
        ReplaceLineFmt('BRKPTS[0]   = %d',      [BRKPTS[0]], Pointer(@BRKPTS));
        ReplaceLineFmt('RETRIES     = %d',      [RETRIES],   Pointer(@RETRIES));
        ReplaceLineFmt('EXPANSION   = %d',      [EXPANSION[0]], Pointer(@EXPANSION));
        ReplaceLineFmt('LOTIME      = %4.4x',   [LOTIME],    Pointer(@LOTIME));
        ReplaceLineFmt('HITIME      = %4.4x',   [HITIME],    Pointer(@HITIME));

        ReplaceLineFmt('miscinfo=$%-4.4x nobreak[bit6],stupid[5],slowterm[4],hasxycrt[3],haslccrt[2],has8510a[1],hasclock[0],'+
                           'userkind:(normal[6,7],aquiz[8,9],booker[10,11],pquiz', [miscinfo], Pointer(@miscinfo));

        Heading;
        ReplaceLine('CRT_CTRL', pointer(@CrtCtrl));
        with CrtCtrl do
          begin
            ReplaceLineFmt('escape      = %s', [ToChar(escape)],     Pointer(@escape));
            ReplaceLineFmt('home        = %s', [ToChar(home)],       Pointer(@home));
            ReplaceLineFmt('eraseeos    = %s', [ToChar(eraseeos)],   Pointer(@eraseeos));
            ReplaceLineFmt('eraseeol    = %s', [ToChar(eraseeol)],   Pointer(@eraseeol));
            ReplaceLineFmt('ndfs        = %s', [ToChar(ndfs)],       Pointer(@ndfs));
            ReplaceLineFmt('rlf         = %s', [ToChar(rlf)],        Pointer(@rlf));
            ReplaceLineFmt('backspace   = %s', [ToChar(backspace)],  Pointer(@backspace));
            ReplaceLineFmt('fillcount   = %d', [fillcount],          Pointer(@fillcount));
          end;

        Heading;
        ReplaceLine('CRT_INFO', pointer(@CrtInfo));
        with CrtInfo do
          begin
            ReplaceLineFmt('width       = %d', [width],             Pointer(@width));
            ReplaceLineFmt('height      = %d', [height],            Pointer(@height));
            ReplaceLineFmt('right       = %s', [ToChar(right)],     Pointer(@right));
            ReplaceLineFmt('left        = %s', [ToChar(left)],      Pointer(@left));
            ReplaceLineFmt('down        = %s', [ToChar(down)],      Pointer(@down));
            ReplaceLineFmt('up          = %s', [ToChar(up)],        Pointer(@up));
            ReplaceLineFmt('badch       = %s', [ToChar(badch)],     Pointer(@badch));
            ReplaceLineFmt('chardel     = %s', [ToChar(chardel)],   Pointer(@chardel));
            ReplaceLineFmt('stop        = %s', [ToChar(stop)],      Pointer(@stop));
            ReplaceLineFmt('break       = %s', [ToChar(break)],     Pointer(@break));
            ReplaceLineFmt('flush       = %s', [ToChar(flush)],     Pointer(@flush));
            ReplaceLineFmt('eof         = %s', [ToChar(eof)],       Pointer(@eof));
            ReplaceLineFmt('altmode     = %s', [ToChar(altmode)],   Pointer(@altmode));
            ReplaceLineFmt('linedel     = %s', [ToChar(linedel)],   Pointer(@linedel));
          end;

        Heading;
        ReplaceLine('SEGTBL', pointer(@SEGTBL));
        SegTblAddr := INTEGER(@TIISysComRec(NIL^).SEGTBL);
        ReplaceLine(MemDumpDW(SegTblAddr, wt_SegTable), pointer(@SEGTBL));
//      result := '';
//      with SyscomP^ do
//        for sn := 0 to MAXSEG do
//          with SegTbl[sn] do
//            if CODEUNIT <> 0 then
//              begin
//                if result <> '' then
//                  result := result + ', ';
//                result := result + Format('[%d]=%d/%d/%d', [sn, CODEUNIT, DISKADDR, CODELENG])
//              end;
//      ReplaceLine('UNIT/DISK/LENG = '+Result, pointer(@SEGTBL));

        with fInterpreter as TUCSDInterpreter do
//        with Globals^ do
            ReplaceLineFmt('MemTop      = $%4x', [MemTop], Pointer(@MemTop));
      end;
  end;  { DisplayIISyscom }

begin { DisplaySyscom }
  fSelectedMemo := MemoSysCom;
  SendMessage(MemoSyscom.Handle, WM_SETREDRAW, WPARAM(False), 0); // disable updates until we're ready
  case VersionNr of
    vn_VersionIV:    DisplayIVSyscom;
//  vn_VersionIV_12: DisplayIVSyscom;

    vn_VersionI_4,
    vn_VersionI_5,
    vn_VersionII: DisplayIISyscom;

    else
      raise EUnknownVersion.Create('Unknown VersionNr');
  end;
  SendMessage(MemoSyscom.Handle, WM_SETREDRAW, WPARAM(TRUE), 0); // now, update the display
end;  { DisplaySyscom }


procedure TfrmPCodeDebugger.FindAgainClick(Sender: TObject);
begin
  inherited;
  
  fSelectedMemo := CurrentMemo(fSelectedMemo);
  if Assigned(fSelectedMemo) then
    FindStringInMemo(fSelectedMemo, fSearchFor)
  else
    SysUtils.Beep;
end;

procedure TfrmPCodeDebugger.UndoMemoChange(Memo: TMemo);
begin
  Memo.Undo;
end;

procedure TfrmPCodeDebugger.UndoClick(Sender: TObject);
begin
  inherited;
  fSelectedMemo := CurrentMemo(fSelectedMemo);
  UndoMemoChange(fSelectedMemo);
end;

procedure TfrmPCodeDebugger.leMaxHistoryChange(Sender: TObject);
begin
  inherited;
  try
    fMAXHIST := StrToInt(leMaxHistory.text);
    DEBUGGERSettings.MaxHistoryItems := fMAXHIST;
    SetLength(fHistory, fMAXHIST+1);
  except
    SysUtils.Beep;
  end;
end;

procedure TfrmPCodeDebugger.BackupSettings(const SettingsFileName: string);
var
  BackupFileName: string;
begin
  if not Empty(SettingsFileName) then
    BackupFileName := SettingsFileName
  else
    BackupFileName := DEBUGGERSettingsFileName(VersionNr);

  BackupFileName := FileNameByDate(BackupFileName);
  DEBUGGERSettings.SaveToFile(BackupFileName);
  MessageFmt('Previous settings saved to "%s"', [BackupFileName]);
end;

procedure TfrmPCodeDebugger.SaveSettings(const FileName: string);
begin
  DEBUGGERSettings.SaveToFile(FileName);
  Update_StatusFmt('Saved to Settings File: %s', [DEBUGGERSettingsFileName(VersionNr)], clLime);
end;



procedure TfrmPCodeDebugger.SaveSettings1Click(Sender: TObject);
begin
  inherited;
  with DEBUGGERSettings do
    begin
      if Assigned(WindowsList) then
        WindowsList.DeleteUnusedWindows;  // forget any windows more than a month old
      SaveSettings(DEBUGGERSettingsFileName(VersionNr));
    end;
end;

procedure TfrmPCodeDebugger.DeleteAllBreakpoints1Click(Sender: TObject);
var
  I : integer;
  SettingsFileName: string;
begin
  inherited;
  if Yes('Are you sure that you want to delete all of the breakpoints?') then
    begin
      SettingsFileName := DEBUGGERSettingsFileName(VersionNr);
      if GetString('Save all settings', 'Settings File Name', SettingsFileName) then
        begin
          BackupSettings(SettingsFileName);
          with sgBreakPoints, DEBUGGERSettings do
            for I := Brks.Count-1 downto 0 do
              Brks.Delete(I);
          DisplayBreakPoints;
        end;
    end;
end;

procedure TfrmPCodeDebugger.AddWatchItem1Click(Sender: TObject);
begin
  inherited;
  if not Assigned(frmWatch) then
    frmWatch := TfrmWatch.Create(self, fInterpreter, self);
  if frmWatch.ShowModal = mrOK then
    begin
      with DEBUGGERSettings.WatchList.Add as TWatchItem do
        begin
          WatchType     := frmWatch.WatchType;
//        WatchAddr     := frmWatch.WatchAddr;
          WatchAddrExpr := frmWatch.WatchAddrExpr;
          WatchName     := frmWatch.WatchName;
          WatchParam    := frmWatch.WatchParam;
          WatchComment  := frmWatch.WatchComment;
          WatchIndirect := frmWatch.WatchIndirect;
          DisplayWatches;
        end;
      SaveSettings(DEBUGGERSettingsFileName(VersionNr));
    end;
end;

procedure TfrmPCodeDebugger.EditWatchItem1Click(Sender: TObject);
var
  ItemNr: integer;
  frm: TfrmWatch;
  WatchItem: TWatchItem;
begin
  inherited;
//  if not Assigned(frmWatch) then
  frm := TfrmWatch.Create(self, fInterpreter, self);

  // for this to work, the sgWatchList MUST always exactly parallel the gWatchList
  with sgWatchList do
    begin
      ItemNr    := Row - 1;
      WatchItem := DEBUGGERSettings.WatchList.Items[ItemNr] as TWatchItem;
      with WatchItem do
        begin
          frm.WatchType     := WatchItem.WatchType;
          frm.WatchAddrExpr := WatchItem.WatchAddrExpr;
          frm.WatchName     := WatchItem.WatchName;
          frm.WatchComment  := WatchItem.WatchComment;
          frm.WatchParam    := WatchItem.WatchParam;
          frm.WatchIndirect  := WatchItem.WatchIndirect;
          if frm.ShowModal = mrOk then
            begin
              WatchItem.WatchType     := frm.WatchType;
              WatchItem.WatchAddrExpr := frm.WatchAddrExpr;
              WatchItem.WatchName     := frm.WatchName;
              WatchItem.WatchComment  := frm.WatchComment;
              WatchItem.WatchParam    := frm.WatchParam;
              WatchItem.WatchIndirect := frm.WatchIndirect;
              
              UpdateSgWatchListRow( Row,
                                    WatchTypesTable[WatchType].WatchName  { Type },
                                    WatchTypesTable[WatchType].WatchCode, { CodeVal }
                                    WatchName,                       { NameVal }
                                    HexWord(WatchAddr) {Addr},       { AddrVal }
                                    WatchValue(fInterpreter),
                                    WatchComment {Value}            { CommentVal });
              SaveSettings(DEBUGGERSettingsFileName(VersionNr));
            end;
        end;
    end;
end;

procedure TfrmPCodeDebugger.DeleteWatchItem1Click(Sender: TObject);
var
  ItemNr: integer;
begin
  inherited;
  with sgWatchList do
    begin
      ItemNr := Row - 1;
      DEBUGGERSettings.WatchList.Delete(ItemNr);
      DisplayWatches;
    end;
end;

procedure TfrmPCodeDebugger.sgWatchListDblClick(Sender: TObject);
begin
  inherited;
  EditWatchItem1Click(sgWatchList);
end;

procedure TfrmPCodeDebugger.miInspectClick(Sender: TObject);
var
  ItemNr: integer;
  frm: TfrmInspect;
  WatchItem: TWatchItem;
begin
  inherited;

  frm := TfrmInspect.Create(self, fInterpreter, self);    // We can create as many of these as we want
  frm.FreeNotification(self);

  // for this to work, the sgWatchList MUST always exactly parallel the gWatchList
  with sgWatchList do
    begin
      ItemNr := Row - 1;
      if ItemNr >= 0 then
        begin
          WatchItem := DEBUGGERSettings.WatchList.Items[ItemNr] as TWatchItem;
          with WatchItem do
            begin
              frm.WatchType     := WatchItem.WatchType;
              frm.WatchAddrExpr := WatchItem.WatchAddrExpr;
//            frm.WatchAddr     := WatchItem.WatchAddr;
              frm.WatchName     := WatchItem.WatchName;
              frm.WatchComment  := WatchItem.WatchComment;
              frm.WatchParam    := WatchItem.WatchParam;
              frm.WatchIndirect := WatchItem.WatchIndirect;
            end;
        end;
      frm.UpdateWatchNameAndValue;
      frm.Show;
    end;
end;

procedure TfrmPCodeDebugger.CopyWatchName1Click(Sender: TObject);
var
  WatchItem: TWatchItem;
  ItemNr: integer;
begin
  inherited;
  // for this to work, the sgWatchList MUST always exactly parallel the gWatchList
  with sgWatchList do
    begin
      ItemNr := Row - 1;
      WatchItem := DEBUGGERSettings.WatchList.Items[ItemNr] as TWatchItem;
      ClipBoard.AsText := WatchItem.WatchName;
    end;
end;

procedure TfrmPCodeDebugger.CopyWatchValue1Click(Sender: TObject);
var
  WatchItem: TWatchItem;
  ItemNr: integer;
begin
  inherited;
  with sgWatchList do
    begin
      ItemNr := Row - 1;
      WatchItem := DEBUGGERSettings.WatchList.Items[ItemNr] as TWatchItem;
      ClipBoard.AsText := WatchItem.WatchValue(fInterpreter);
    end;
end;

procedure TfrmPCodeDebugger.DeleteAllWatches1Click(Sender: TObject);
var
  ItemNr: integer;
  SettingsFileName: string;
begin
  inherited;

  if Yes('Do you really want to delete ALL watches') then
    begin
      SettingsFileName := DEBUGGERSettingsFileName(VersionNr);
      if GetString('Save all settings', 'Settings File Name', SettingsFileName) then
        begin
          BackupSettings(SettingsFileName);
          for ItemNr := DEBUGGERSettings.WatchList.Count - 1 downto 0 do
            DEBUGGERSettings.WatchList.Delete(ItemNr);
          DisplayWatches;
        end;
    end;
end;

procedure TfrmPCodeDebugger.DeleteBreakpoint1Click(Sender: TObject);
var
  R: integer;
begin
  inherited;
  with sgBreakPoints do
    with Selection do
      begin
        for r := Bottom downto Top do
          DEBUGGERSettings.Brks.Delete(r);
      end;
  SaveSettings(DEBUGGERSettingsFileName(VersionNr));
  DisplayBreakPoints;
end;

procedure TfrmPCodeDebugger.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  Idx: integer;
begin
  inherited;
  if (Operation = opRemove) then
    begin
      if Assigned(fInspectorList) then
        begin
          Idx := fInspectorList.IndexOf(aComponent);
          if Idx >= 0 then
            fInspectorList.Delete(idx);
        end;

      if Assigned(fVariableWatchersList) then
        begin
          Idx := fVariableWatchersList.IndexOf(aComponent);
          if Idx >= 0 then
            fVariableWatchersList.Delete(idx);
        end;

      if Assigned(fInterpreter) then
        if fInterpreter is TCustomPsystemInterpreter then
          with fInterpreter as TCustomPsystemInterpreter do
            if aComponent = frmPsysWindow then
              frmPSysWindow := nil; // The interpreter needs to know that the p-Sys Window no longer exists

{$IfDef DashBoard}
      if Assigned(fDashboardWindowsList) then
        begin
          idx := fDashboardWindowsList.IndexOf(aComponent);
          if Idx >= 0 then
            fDashboardWindowsList.Delete(Idx);
        end;
{$endIf DashBoard}
    end;
end;

procedure TfrmPCodeDebugger.CallStackDblClick(Grid: TStringGrid; CSType: TMSCWFieldNr);
var
  MSCWAddr: word;
  SegIdx: TSegNameIdx;
begin { CallStackDblClick }
  if Assigned(Grid) then
    with Grid do
      begin                         // one object per row
        MSCWAddr    := Word(Objects[0, Row]);
        with fInterpreter as TCustomPsystemInterpreter do
          begin
            SegIdx := TheSegNameIdx(GetSegBase(MSCWAddr));
            if OpenProc(SegIdx,
                        MSPROC,
                        ProcNamesInDB[SegIdx, MSPROC],
                        MSIPC) then
              SelectCurrentLine(CurrentMemo(fSelectedMemo), IPCWithinProc(MSIPC, MSENV, MSPROC));
          end;
      end;
end;  { CallStackDblClick }


procedure TfrmPCodeDebugger.cbCallHistoryOnlyClick(Sender: TObject);
begin
  inherited;
  DEBUGGERSettings.CallHistoryOnly := cbCallHistoryOnly.Checked;
end;

procedure TfrmPCodeDebugger.sgHistoryDblClick(Sender: TObject);
var
  SegName, ProcName, ProcNrStr, IPCStr: string;
  anIPC, ProcNr: word;
  SegIdx: TSegNameIdx;
begin
  inherited;
  with sgHistory do
    begin
      try
        SegName   := Cells[COL_SEGNAME2, Row];
        SegIdx    := SegIdxFromName(SegName);
        ProcNrStr := Cells[COL_PROCNR2,  Row];
        ProcNr    := StrToInt(ProcNrStr);
        ProcName  := Cells[COL_PROCNAME, Row];
        IPCStr    := Cells[COL_RELIPC,   Row];
        anIPC     := StrToInt(IPCStr);
        if OpenProc(SegIdx, ProcNr, ProcName, anIPC) then
          ;
      except
        SysUtils.Beep;
      end;
    end;
end;

procedure TfrmPCodeDebugger.miSearchAllClick(
  Sender: TObject);
var
  pCodesProcTable : TpCodesProcTable;
  NrFound: integer;

  function FoundIn(const FieldText: string; const FieldType: string; Memo: TMemo): boolean;
  var
    p1, p2: pchar;
    SegIdx: TSegNameIdx;
  begin
    result := false;
    p1     := Pchar(FieldText);
    p2     := MyStrPos(p1, pchar(fSearchFor),  Length(FieldText), true);
    if P2 <> NIL then
      with pCodesProcTable do
        begin
          Inc(NrFound);
          if YesFmt('String "%s" was found in the %s for %d:%s_%s. Open it?',
                    [fSearchFor,
                     FieldType,
                     fldProcedureNumber.AsInteger,
                     fldSegmentName.AsString,
                     fldProcedureName.AsString]) then
            begin
              SegIdx := SegIdxFromName(fldSegmentName.AsString);
              if OpenProc(SegIdx, fldProcedureNumber.AsInteger, fldProcedureName.AsString, 0) then
                begin
                  EnableMemoEditing1.Checked := true;  // enable editing to prevent cursor mis-position
                  ShowEditMode;
                  FindStringInMemo(Memo, fSearchFor);
                  result := true;
                  exit;
                end;
            end;
        end;
  end;

begin { miSearchAllClick }
  inherited;
  if GetString('Search All', 'String', fSearchFor) then
    begin
      with DEBUGGERSettings do
        begin
          // It used to search through ALL of the known procedure databases
          pCodesProcTable  := TpCodesProcTable.Create( self,
                                                       DatabaseToUse,
                                                       TableNamePCodeProcs,
                                                       [optLevel12]);
          try
            with pCodesProcTable do
              begin
                Active := true;
                NrFound := 0;
                First;
                while not Eof do
                  begin
                    if FoundIn(fldDecodedPCode.AsString, 'p-Code', Memo1) then
                      Break;
                    if FoundIn(fldSourceCode.AsString, 'Source Code', Memo3) then
                      Break;

                    Next;
                  end;
              end;
              MessageFmt('%d occurrences of ''%s'' were found', [NrFound, fSearchFor]);
          finally
            FreeAndNil(pCodesProcTable);
          end;
        end;
    end;

end;  { miSearchAllClick }

procedure TfrmPCodeDebugger.sgStaticDblClick(Sender: TObject);
begin
  inherited;
  CallStackDblClick(sgStatic, csStatic);
end;

procedure TfrmPCodeDebugger.DisplayVars(WindowsTypes: TWindowsTypes);
begin
  inherited;

  if not Assigned(fVariableWatchersList) then
    fVariableWatchersList := TVarsList.Create(self);

  frmLocalVariables := TfrmLocalVariables.Create( self,
                                                  fInterpreter,
                                                  WindowsTypes,
                                                  0);
  frmLocalVariables.FreeNotification(self);

  fVariableWatchersList.Add(frmLocalVariables);

  with frmLocalVariables do
    begin
      UpdateDisplay( SegNamesInDB[fLastSegmentIdx],
                     self.fCurrentProcName,
                     self.fLastProcNr);
      Show;
      self.SetFocus;
    end;
end;

procedure TfrmPCodeDebugger.miLocalVariablesClick(Sender: TObject);
begin
  DisplayVars(wtLocal);
end;

procedure TfrmPCodeDebugger.miGlobalVariablesClick(Sender: TObject);
begin
  DisplayVars(wtGlobal);
end;

procedure TfrmPCodeDebugger.wmInspectorAdded(var Message: TMessage);
var
  frm: TfrmInspect;
begin
  with fInspectorList do
    begin
      frm := TfrmInspect(Message.Wparam);
      if IndexOf(frm) < 0 then
        begin
          Add(TfrmInspect(frm));         // OK. We know that you have been created.
          frm.FreeNotification(self);    //     Let us know when you get destroyed.
        end;
    end;
end;

procedure TfrmPCodeDebugger.SetBrk(const Value: TBrk);
begin
  if fBrk <> Value then
    fBrk := Value;
end;

// THIS DOES NOT WORK
(*
procedure TfrmPCodeDebugger.btnMoveUpClick(Sender: TObject);
var
  SrcNo: integer;
  Temp: TWatchItem;
begin
  inherited;

  with TStringGridHack(sgWatchList) do
    if Row > 0 then
      begin
        MoveRow(Row, Row-1);        // on the string grid

        SrcNo := Row - 1;           // the underlying data structure
        with gWatchList do
          begin
{
            Temp := Items[SrcNo-1] as TWatchItem;
            Items[SrcNo-1] := Items[SrcNo];
            Items[SrcNo] := Temp;
}
            Temp := TWatchItem.Create(nil);

            try
              Temp.Assign(Items[SrcNo-1] as TWatchItem);
              Items[SrcNo-1].Assign(Items[SrcNo] as TWatchItem);
              Items[SrcNo].Assign(Temp as TWatchItem);
            finally
              FreeAndNil(Temp);
            end;

          end;
      end;
end;

procedure TfrmPCodeDebugger.btnMoveDownClick(Sender: TObject);
var
  SrcNo: integer;
begin
  inherited;
  with TStringGridHack(sgWatchList) do
    if Row < Pred(RowCount) then
      begin
        SrcNo := Row - 1;
        MoveRow(Row, Row+1);
      end;
  with gWatchList.Items[SrcNo] do
    Index := Index + 1;         // This does not work. I do not know why.
end;
*)

{ TStringGridHack }

procedure TStringGridHack.MoveColumn(FromIndex, ToIndex: Longint);
begin
  inherited;
end;

procedure TStringGridHack.MoveRow(FromIndex, ToIndex: Longint);
begin
  inherited;
end;

procedure TfrmPCodeDebugger.FormResize(Sender: TObject);
begin
  inherited;
  AdjustColumnWidths(sgWatchList);
  AdjustColumnWidths(sgBreakPoints);
  AdjustColumnWidths(sgMessages);
end;

procedure TfrmPCodeDebugger.lblStatusDblClick(Sender: TObject);
begin
  inherited;
  Clipboard.SetTextBuf(PCHAR(lblStatus.Caption));
end;

procedure TfrmPCodeDebugger.FindDialog1Find(Sender: TObject);
begin
  inherited;

  fSearchFor    := FindDialog1.FindText;
  fSelectedMemo := CurrentMemo(fSelectedMemo);
  if Assigned(fSelectedMemo) then
    FindStringInMemo(fSelectedMemo, fSearchFor)
  else
    SysUtils.Beep;
end;

procedure TfrmPCodeDebugger.ShowStatusMessage(Msg: string; Args: array of const);
begin { ShowStatusMessage }
  Msg := Format(Msg, Args);
  lblStatus.Caption := Msg;
  if Assigned(fOnStatusUpdate) then
    fOnStatusUpdate(Msg, true, true);
end;  { ShowStatusMessage }

function TfrmPCodeDebugger.BackupDBToTextFiles(Version: TVersionNr): integer;
var
  NrPas, NrPCode, NrVar: integer;
  DataBaseInfo: TDataBaseInfo;
  DBN: integer;
  pCodesProcTable: TpCodesProcTable;

begin { BackupDBToTextFiles }
  result := 0;
  for DBN := 0 to DATABASESettings.DataBaseList.Count-1 do
    begin
      DatabaseInfo := DATABASESettings.DataBaseList.Items[DBN] as TDataBaseInfo;
      with DataBaseInfo do
      if Version = DatabaseInfo.VersionNr then
        begin
          DatabaseInfo := DATABASESettings.DataBaseList.Items[DBN] as TDataBaseInfo;    // THIS IS REDUNDANT
          with DataBaseInfo do
            if Version = DatabaseInfo.VersionNr then
              if not Empty(TextBackupRootPath) then
                begin
                  if FileExists(FilePath) then
                    begin
                      pCodesProcTable := TpCodesProcTable.Create(self, FilePath, TableNamePCODEPROCS, [optLevel12]);
                      try
                        pCodesProcTable.Active := true;

                        with pCodesProcTable do
                          begin
                            NrPas    := SaveMemoToFile(fldSourceCode,     DatabaseInfo, 'PAS');

                            NrPcode  := SaveMemoToFile(fldDecodedPCode,   DatabaseInfo, 'pCode');

                            NrVar    := SaveMemoToFile(fldProcParameters, DatabaseInfo, 'varlist');
                          end;
                        result := NrPas + NrPCode + NrVar;

                        if result > 0 then
                          ShowStatusMessage('%-6s: %3d .pas, %3d .pcode, %3d .VarList files were copied to %s',
                                      [VersionNrStrings[Version].Abbrev, NrPas, NrPCode, NrVar, DataBaseInfo.TextBackupRootPath]);
                      finally
                        FreeAndNil(pCodesProcTable);
                      end;
                    end
                  else
                    ShowStatusMessage('Could not find database: %s', [FilePath]);
                end
              else
                ShowStatusMessage('No backup path for version %s', [VersionNrToAbbrev(VersionNr)]);
        end;
    end;
end;  { BackupDBToTextFiles }




procedure TfrmPCodeDebugger.SaveDBToTextFiles(Sender: TObject);
var
  Version: TVersionNr;
  NrFilesCopied: integer;
begin
  inherited;
  NrFilesCopied := 0;
  for Version := Succ(Low(TVersionNr)) to High(TVersionNr) do
    NrFilesCopied := NrFilesCopied + BackupDBToTextFiles(Version);
  ShowStatusMessage('', []);
  ShowStatusMessage('%d files were backed up', [NrFilesCopied]);
end;

procedure TfrmPCodeDebugger.sgCallStackDblClick(Sender: TObject);
begin
  inherited;

  CallStackDblClick(sgCallStack, csDynamic);
end;

procedure TfrmPCodeDebugger.LoadProcedure1Click(Sender: TObject);
begin
  inherited;
  CallStackDblClick(fCSGrid, TMSCWFieldNr(fCSGrid.Tag));
end;

procedure TfrmPCodeDebugger.ViewMSCW(Grid: TStringGrid{; CSType: TMSCWFieldNr});
var
  MSCWAddr, aSegBase: word;
  ItemNr: integer;
  frm: TfrmInspect;
  aProcName: string;
  aProcNr: integer;
begin
  inherited;
  if Assigned(Grid) then
    with Grid do
      begin                         // one object per row
        if Row > 1 then
          with fInterpreter as TCustomPsystemInterpreter do
            begin
//            MSCWAddr    := Word(Objects[0, Row]);
              MSCWAddr    := Word(Objects[0, Row-1]);   //debugging 2/17/2023
//            MSCWAddr    := MSCWField(MSCWAddr, TMSCWFieldNr(Grid.Tag));
              aSegBase    := GetSegBase(MSCWAddr);
              aProcNr     := MSCWField(MSCWAddr, CSProc);
              aProcName   := ProcName(aProcNr, aSegBase);

              frm         := TfrmInspect.Create(self, fInterpreter, self);    // We can create as many of these as we want
              frm.FreeNotification(self);

              with Grid do
                begin
                  ItemNr := Row - 1;
                  if ItemNr >= 0 then
                    begin
                      frm.WatchType     := wt_MSCWp;
                      frm.WatchAddrExpr := IntToStr(MSCWAddr);
                      frm.WatchAddr     := MSCWAddr;
                      frm.WatchComment  := aProcName;
                      frm.WatchParam    := 0;
                      frm.WatchIndirect := false;
                    end;
                  frm.UpdateWatchNameAndValue;
                  frm.Show;
                end;
            end
          else
            SysUtils.Beep;
      end
    else
      SysUtils.Beep;
end;

procedure TfrmPCodeDebugger.sgCallStackClick(Sender: TObject);
begin
  inherited;
  fCSGrid := Sender as TStringGrid;
end;

procedure TfrmPCodeDebugger.ViewMSCW1Click(Sender: TObject);
begin
  inherited;
  ViewMSCW(fCSGrid);
end;

procedure TfrmPCodeDebugger.AddMessage(WatchIndex: integer;
  SegNameIdx: TSegNameIdx; ProcNum, anIPC: word; const Value: string);
var
  RowNr: integer;
  BreakInfo: TBreakInfo;
  BreakList: TBreakList;
  anOpCode: word;
begin
  if LoggingToAFile then
    begin
      BreakList := DEBUGGERSettings.Brks;
      with fInterpreter as TCustomPsystemInterpreter do
        begin
          anOpCode   := Bytes[AbsIPC];
          WriteLn(BreakList.LogFile, DbgCnt, ',',                { DbgCnt }
                            RelIPC, ',',                         { IPC }
                            SegNamesInDB[SegNameIdx], ',',       { SegName }
                            ProcNum, ',',                        { ProcNum }
                            ProcNamesInDB[SegNameIdx, ProcNum], ',',
                            anOpCode, ',',
                            OpsTable.Ops[anOpCode].Name, ',',
                            Value);
        end
    end
  else
    with sgMessages do
      begin
        RowNr := fNumberOfMessages + 1;

        BreakInfo := DEBUGGERSettings.Brks.Items[WatchIndex] as TBreakInfo;

        with fInterpreter as TCustomPsystemInterpreter do
          Cells[MGCOL_DBGCNT, RowNr]     := Format('%6.0n', [DbgCnt * 1.0]);
        Cells[MGCOL_BREAKKIND, RowNr]  := Format('%2d: %s', [WatchIndex, BreakKinds[BreakInfo.Brk].BreakName]);
        Cells[MGCOL_SEGNAME, RowNr]    := SegNamesInDB[SegNameIdx];
        Cells[MGCOL_PROCNAME, RowNr]   := ProcNamesInDB[SegNameIdx, ProcNum];
        Cells[MGCOL_IPC, RowNr]        := Format('%5d', [RelIPC]);
        Cells[MGCOL_VALUE, RowNr]      := Value;

        Inc(fNumberOfMessages);

        if fNumberOfMessages > 1 then
          RowCount := fNumberOfMessages + 1;

        AdjustColumnWidths(sgMessages);
      end;
end;

procedure TfrmPCodeDebugger.InitMessagePage;
begin
  fNumberOfMessages := 0;
  with sgMessages do
    begin
      RowCount := 2;

      Cells[MGCOL_DBGCNT, 0]     := 'DbgCnt';
      Cells[MGCOL_BREAKKIND, 0]  := 'Kind';
      Cells[MGCOL_SEGNAME, 0]    := 'Segment';
      Cells[MGCOL_PROCNAME, 0]   := 'ProcName';
      Cells[MGCOL_IPC, 0]        := 'IPC';
      Cells[MGCOL_VALUE, 0]      := 'Value';
    end;
end;

procedure TfrmPCodeDebugger.PrintMessages1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
  inherited;
//OutFileName := UniqueFileName(DEBUGGERSettings.ReportsPath + 'Messages.txt');
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'Messages.txt');
  try
    with fInterpreter as TUCSDInterpreter do
      SubTitle    := TheVersionName;
    PrintStringGrid('Messages', SubTitle, sgMessages, OutFileName, true);
  except
    on e:Exception do
      AlertFmt('%s [%s]', [e.Message, OutFileName]);
  end;
end;

procedure TfrmPCodeDebugger.PrintMemo(Memo: TMemo; const OutFileName: string);
var
  i: integer;
  Outfile: TextFile;
begin
  AssignFile(OutFile, OutFileName);
  Rewrite(OutFile);
  try
    with Memo do
      begin
        for i := 0 to Lines.Count - 1 do
          WriteLn(OutFile, Lines[i]);
      end;
  finally
    CloseFile(OutFile);
  end;
end;

procedure TfrmPCodeDebugger.PrintcurrentpCode1Click(Sender: TObject);
var
  OutFileName : string;
begin
  inherited;
//OutFileName := UniqueFileName(DEBUGGERSettings.ReportsPath + 'CurrentPCode.txt');
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'CurrentPCode.txt');
  PrintMemo(Memo1, OutFileName);
  EditTextFile2(FilerSettings.EditorFilePath, OutFileName);
end;

procedure TfrmPCodeDebugger.PrintcurrentSourceCode1Click(Sender: TObject);
var
  OutFileName : string;
begin
  inherited;                                      
//OutFileName := UniqueFileName(DEBUGGERSettings.ReportsPath + 'CurrentSrcCode.txt');
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'CurrentSrcCode.txt');
  PrintMemo(Memo3, OutFileName);
  EditTextFile2(FilerSettings.EditorFilePath, OutFileName);
end;

procedure TfrmPCodeDebugger.PrintSyscom1Click(Sender: TObject);
var
  OutFileName : string;
begin
  inherited;
//OutFileName := UniqueFileName(DEBUGGERSettings.ReportsPath + 'SysCom.txt');
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'SysCom.txt');
  PrintMemo(memoSyscom, OutFileName);
  EditTextFile(OutFileName);
end;

procedure TfrmPCodeDebugger.PrintWatchList1Click(Sender: TObject);
var
  OutFileName, SubTitle : string;
begin
  inherited;

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  OutFileName :=FileNameByDate(DEBUGGERSettings.ReportsPath + 'WatchList.txt');
  PrintStringGrid('Watches', SubTitle, sgWatchList, OutFileName, true);
end;

procedure TfrmPCodeDebugger.PrintBreakpointList1Click(Sender: TObject);
var
  OutFileName, SubTitle : string;
begin
  inherited;
  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'BreakPointList.txt');
  PrintStringGrid('BreakPoints', SubTitle, sgBreakPoints, OutFileName, true);
end;

procedure TfrmPCodeDebugger.CreateInspector1Click(Sender: TObject);
var
  frm: TfrmInspect;
begin
  inherited;

  frm := TfrmInspect.Create(self, fInterpreter, self);    // We can create as many of these as we want
  frm.FreeNotification(self);                      // Let us know if it is freed
  frm.UpdateWatchNameAndValue;
  frm.Show;
end;

procedure TfrmPCodeDebugger.DisplayIntermediate(Grid: TStringGrid; WindowsType: TWindowsTypes);
var
  aSegBase    : word;
  MSCWAddr   : word;
  aProcName  : string;
  aSegName   : string;
  IntMedVars : word;
  MySegNr    : TSegNameIdx;
  aProcNr    : word;
begin
  if Assigned(Grid) then
    with Grid do
      begin                         // one object per row
        if Row > 0 then
        with fInterpreter as TCustomPsystemInterpreter do
          begin
            if Row = 1 then  // this is the current procedure
              miLocalVariablesClick(nil)
            else
              begin
                MSCWAddr    := Word(Objects[0, Row-1]);
                aSegBase    := GetSegBase(MSCWAddr);
                MySegNr     := TheSegNameIdx(aSegBase);
                aProcNr     := MSCWField(MSCWAddr, csProc);     // MSPROC may be negative during EXIT processing
                aProcName   := ProcNamesInDB[MySegNr, aProcNr];
                aSegName    := SegNameFromBase(aSegBase);

                if VersionNr < vn_VersionIV then               
                  IntMedVars  := MSCWField(MSCWAddr, csSeg) + 12
                else
                  IntMedVars  := MSCWField(MSCWAddr, csStatic) + MSCWDisp;  // kludge? that may not work all of the time

                frmLocalVariables := TfrmLocalVariables.Create( self,
                                                                fInterpreter,
                                                                WindowsType,
                                                                IntMedVars,
                                                                aSegName,
                                                                aProcName,
                                                                aProcNr);
                frmLocalVariables.FreeNotification(self);

                if not Assigned(fVariableWatchersList) then
                  fVariableWatchersList := TVarsList.Create(self);
                fVariableWatchersList.Add(frmLocalVariables);

                with frmLocalVariables do
                  begin
                    UpdateDisplay(aSegName, aProcName, aProcNr);
                    Show;
                    self.SetFocus;
                  end;
              end;
          end
        else
          SysUtils.Beep;
      end
    else
      SysUtils.Beep;
end;


procedure TfrmPCodeDebugger.miDisplayLocalIntermediate(Sender: TObject);
begin
  inherited;
  with fInterpreter as TCustomPsystemInterpreter do
    DisplayIntermediate(fCSGrid, wtIntermediateLocal)
end;

procedure TfrmPCodeDebugger.miDisplayGlobalIntermediate(Sender: TObject);
begin
  inherited;
  with fInterpreter as TCustomPsystemInterpreter do
    DisplayIntermediate(fCSGrid, wtIntermediateGlobal)
end;

procedure TfrmPCodeDebugger.cbOffsetInHexClick(Sender: TObject);
begin
  inherited;
  DisplaySysCom;
end;

procedure TfrmPCodeDebugger.cbAddrInHexClick(Sender: TObject);
begin
  inherited;
  DisplaySysCom;
end;

procedure TfrmPCodeDebugger.CreateInspector2Click(Sender: TObject);
var
  BrkItem: TBreakInfo;
  frm: TfrmInspect;
  idx: integer;
begin
  inherited;

  Idx := sgBreakPoints.Row-1;
  if Idx >= 0 then
    begin
      BrkItem := DEBUGGERSettings.Brks.Items[idx] as TBreakInfo;
      frm     := TfrmInspect.Create(self, fInterpreter, self);    // We can create as many of these as we want
      frm.FreeNotification(self);                          // Let us know if it is freed
      with frm do
        begin
          WatchType     := BrkItem.WatchType;
//        WatchAddr     := BrkItem.LowAddr;
          WatchAddrExpr := BrkItem.AddrExpr;
          WatchName     := BrkItem.Comment;
          WatchComment  := BrkItem.Comment;
          UpdateWatchNameAndValue;
          Show;
        end;
    end;
end;

procedure TfrmPCodeDebugger.sgWatchListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  GridDrawCell(sgWatchList, fChangedWatches, ACol, ARow, Rect);
end;

procedure TfrmPCodeDebugger.btnResetOpsPhitsClick(Sender: TObject);
{$IfDef Pocahontas}
var
  I: integer;
{$EndIf}
begin
  inherited;
{$IfDef Pocahontas}
  with fInterpreter as TCustomPsystemInterpreter do
    for I := 0 TO OpsTable.HighPCode do
      with OpsTable.Ops[I] do
        PHits := 0;
  DisplayPHITS;
{$EndIf}
end;

procedure TfrmPCodeDebugger.btnResetCspPhitsClick(Sender: TObject);
{$IfDef Pocahontas}
var
  I: integer;
{$EndIf}
begin
  inherited;
  with fInterpreter as TCustomPsystemInterpreter do
{$IfDef Pocahontas}
    for I := 0 TO OpsTable.CSPEnd DO
      begin
        with OpsTable.CSPTABLE[I] do
          PHits := 0;
      end;
  DisplayCspPHITS;
{$EndIf}
end;

procedure TfrmPCodeDebugger.FormShow(Sender: TObject);
var
  SplitterPos: integer;
begin
  inherited;
  DEBUGGERSettings.WindowsList.LoadWindowInfo(self, self.Name, SplitterPos);
  if SplitterPos > 0 then
    Memo1.Height := SplitterPos;
end;

procedure TfrmPCodeDebugger.DisableAllBreakpoints1Click(Sender: TObject);
var
  I: integer;
begin
  inherited;
  with DEBUGGERSettings do
    for I := Brks.Count-1 downto 0 do
      with Brks.Items[I] as TBreakInfo do
        Disabled := true;
  DisplayBreakPoints;
end;

procedure TfrmPCodeDebugger.ToggleAllBreakpoints1Click(Sender: TObject);
var
  I: integer;
begin
  inherited;
  with DEBUGGERSettings do
    for I := Brks.Count-1 downto 0 do
      with Brks.Items[I] as TBreakInfo do
        Disabled := not Disabled;
  DisplayBreakPoints;
end;

procedure TfrmPCodeDebugger.SortOnPHITS(Grid: TStringGrid);
begin
  SortGridNumeric(Grid, COL_PHITS);
end;

procedure TfrmPCodeDebugger.SortAlphabetically(Grid: TStringGrid);
begin
  SortGrid(Grid, COL_OPNAME);
end;

procedure TfrmPCodeDebugger.SortOnOpCode(Grid: TStringGrid);
begin
  SortGrid(Grid, COL_PCODEX);
end;

function TfrmPCodeDebugger.GetGrid(Sender: TObject): TStringGrid;
var
  Menu: TPopupMenu;
begin
  Menu      := (Sender as TMenuItem).GetParentMenu() as TPopupMenu;
  result    := Menu.PopupComponent as TStringGrid;
end;


procedure TfrmPCodeDebugger.Alphabetically1Click(Sender: TObject);
begin
  inherited;
  SortAlphaBetically(GetGrid(Sender));
end;

procedure TfrmPCodeDebugger.BYphits1Click(Sender: TObject);
begin
  inherited;
  SortOnPhits(GetGrid(Sender));
end;

procedure TfrmPCodeDebugger.byOPCode1Click(Sender: TObject);
begin
  inherited;
  SortOnOpCode(GetGrid(Sender));
end;

procedure TfrmPCodeDebugger.sgCallStackDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  GridDrawCell(sgCallStack, fExitingProcsDyn, ACol, ARow, Rect);
end;

procedure TfrmPCodeDebugger.sgStaticDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  GridDrawCell(sgCallStack, fExitingProcsStat, ACol, ARow, Rect);
end;

procedure TfrmPCodeDebugger.ExitFaultHandler1Click(Sender: TObject);
const
  FAULTHAN = 48;
begin
  inherited;
  while CURPROC = FAULTHAN do
    with fInterpreter as TCustomPsystemInterpreter do
      Single_Step;
end;

function TfrmPCodeDebugger.GetProcBase: word;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := ProcBase;
end;

procedure TfrmPCodeDebugger.DisplayProfile;
var
  sn: TSegNameIdx;
  p: word;
  RowNum: word;
  TotalCount: longint;

  function SegmentCounts(sn: TSegNameIdx): longint;
  var
    p: word;
  begin { SegmentCounts }
    result := 0;
    for p := 0 to MAXPROCNAME do
      with Profile[sn, p] do
        if Count > 0 then
          result := result + Count;
  end;  { SegmentCounts }

begin { DisplayProfile }
  with sgProfile do
    begin
      Cells[COL_SEGNUMBER, 0]          := 'Seg Number';
      Cells[COL_PROFILE_SEGNAME, 0]    := 'Seg Name';
      Cells[COL_PROCNUMBER, 0]         := 'ProcNumber';
      Cells[COL_PROFILE_PROCNAME, 0]   := 'Proc Name';
      Cells[COL_PROFILE_COUNT, 0]      := 'Instructions Executed';
    end;
  RowNum := 1; TotalCount := 0;

  for sn := 0 to SegNamesInDB.Count-1 do
    if SegmentCounts(sn) > 0 then
      begin
        for p := 1 to MAXPROCNAME do
          with Profile[sn, p] do
            if Count > 0 then
              with sgProfile do
                begin
                  Cells[COL_SEGNUMBER, RowNum]          := IntToStr(sn);
                  Cells[COL_PROFILE_SEGNAME, RowNum]    := SegNamesInDB[sn];
                  Cells[COL_PROCNUMBER, RowNum]         := IntToStr(p);
                  Cells[COL_PROFILE_PROCNAME, RowNum]   := ProcNamesInDB[sn, p];
                  Cells[COL_PROFILE_COUNT, RowNum]      := IntToStr(Count);
                  if RowNum >= RowCount then
                    RowCount := RowCount + 1;
                  Inc(RowNum);
                  Inc(TotalCount, Count);
                end;
        AdjustColumnWidths(sgProfile, 20);
        lblTotal.Caption := Format('%0.n', [TotalCount*1.0]);
      end;
end;

procedure TfrmPCodeDebugger.ResetProfile;
var
  sn: TSegNameIdx;
  p: word;
begin
  for sn := sn_Unknown to SegNamesInDB.Count-1 do
    begin
      for p := 1 to MAXPROCNAME do
        with Profile[sn, p] do
          Count := 0;
    end;
  with sgProfile do
    begin
      RowCount := 2;
      Cells[COL_SEGNUMBER, 1]        := '';
      Cells[COL_PROFILE_SEGNAME, 1]  := '';
      Cells[COL_PROCNUMBER, 1]       := '';
      Cells[COL_PROFILE_PROCNAME, 1] := '';
      Cells[COL_PROFILE_COUNT, 1]    := '';
    end;
  DisplayProfile;
end;

procedure TfrmPCodeDebugger.SortbyCount1Click(Sender: TObject);
begin
  inherited;
  SortGridNumeric(sgProfile, COL_PROFILE_COUNT);
end;

procedure TfrmPCodeDebugger.SortbyProcName1Click(Sender: TObject);
begin
  inherited;
  SortGrid(sgProfile, COL_PROFILE_PROCNAME);
end;

procedure TfrmPCodeDebugger.SortbySegName1Click(Sender: TObject);
begin
  inherited;
  SortGrid(sgProfile, COL_PROFILE_SEGNAME);
end;

procedure TfrmPCodeDebugger.btnResetClick(Sender: TObject);
begin
  inherited;
  ResetProfile;
end;

procedure TfrmPCodeDebugger.btnRefreshClick(Sender: TObject);
begin
  inherited;
  DisplayProfile;
end;

procedure TfrmPCodeDebugger.PrintGlobalDirectory1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
  inherited;
  OutFileName := UniqueFileName(DEBUGGERSettings.ReportsPath + 'GlobalDirectory.txt');

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  PrintStringGrid('Directory', SubTitle, sgDirectory, OutFileName, true);
end;

procedure TfrmPCodeDebugger.VerifySegnamesProcNames1Click;
begin
  VerifySegnamesProcNames;
end;

procedure TfrmPCodeDebugger.ReloadSegNamesProcnames1Click(Sender: TObject);
begin
  inherited;

  LoadProcedureNames;
end;

procedure TfrmPCodeDebugger.Update_Status(const aCaption: string; aColor: TColor);
begin  
  lblStatus.Caption := aCaption;
  lblStatus.Color   := aColor;
  Application.ProcessMessages;
end;

procedure TfrmPCodeDebugger.Update_StatusFmt(const aCaption: string;
  Args: array of const; aColor: TColor);
begin
  Update_Status(Format(aCaption, Args), aColor);
end;

procedure TfrmPCodeDebugger.ListProcNames1Click(Sender: TObject);
var
  SegNameIdx, ProcNr: integer;
  Line: string;
  OutFile: textfile;
  OutFileName: string;
  ProcName: string;
//AccDbFileNumber: integer;
begin
  inherited;
  OutFileName  := UniqueFileName(DEBUGGERSettings.ReportsPath + 'ProcNames.txt');
  AssignFile(OutFile, OutFileName);
  ReWrite(OutFile);
  try
      begin
        WriteLn(OutFile);
        for SegNameIdx := 0 {was:sn_Unknown} to SegNamesInDB.Count-1 do
          begin
            Line := Format('SegNames[%2d]  := ''%s'';',
                           [SegNameIdx, SegNamesInDB[SegNameIdx]]);
            WriteLn(OutFile, Line);
            for ProcNr := 1 to MAXPROCNAME do
              begin
                ProcName := ProcNamesInDB[SegNameIdx, ProcNr];
                if ProcName <> '' then
                  begin
                    Line := Format('    ProcNames[%2d, %2d] := ''%s'';',
                                   [SegNameIdx, ProcNr, ProcName]);
                    WriteLn(OutFile, Line);
                  end;
              end;
            WriteLn(OutFile);
          end;
        WriteLn(OutFile, Padr('', 80, '-'));
        Writeln(OutFile);
      end;
  finally
    CloseFile(OutFile);
    EditTextFile(OutFileName);
  end;
end;

procedure TfrmPCodeDebugger.AddProcName1Click(Sender: TObject);
begin
  inherited;
  if not Assigned(frmSegmentProcName) then
    frmSegmentProcName := TfrmSegmentProcName.Create(self, fpCodesProcTableName, DEBUGGERSettings);

  with frmSegmentProcName do
    ShowModal;
end;

procedure TfrmPCodeDebugger.PrintSegmentProcNames1Click(Sender: TObject);
var
  OutFileName: string;
begin
  inherited;
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'SegmentNames.txt');
  PrintSegmentProcNames(OutFileName);
end;

procedure TfrmPCodeDebugger.PrintHistory1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
  inherited;
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'History.txt');

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  PrintStringGrid('History', SubTitle, sgHistory, OutFileName, true);
end;

procedure TfrmPCodeDebugger.PrintOpsPHITS1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
  inherited;
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'OpsPHITS.txt');

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  PrintStringGrid('OPS PHITS', SubTitle, sgPHITS, OutFileName, true);
end;

procedure TfrmPCodeDebugger.PrintCSPPhits1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
  inherited;
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'CSPPHITS.txt');

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  PrintStringGrid('CSP PHITS', SubTitle, sgCSPPHITS, OutFileName, true);
end;

procedure TfrmPCodeDebugger.PrintDynamicCallStack1Click(Sender: TObject);
var
  OutFileName,SubTitle: string;
begin
  inherited;

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'Dynamic Call Stack.txt');
  PrintStringGrid('Dynamic Call Stack', SubTitle, sgCallStack, OutFileName, true);
end;

procedure TfrmPCodeDebugger.PrintStaticCallStack1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
  inherited;
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'Static Call Stack.txt');

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  PrintStringGrid('Static Call Stack', SubTitle, sgStatic, OutFileName, true);
end;

procedure TfrmPCodeDebugger.PrintStack1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
  inherited;
  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'PME Stack.txt');
  PrintStringGrid('PME Stack', SubTitle, sgPStack, OutFileName, true);
end;

procedure TfrmPCodeDebugger.leSyscomAddrExit(Sender: TObject);
begin
  inherited;
  cbOffsetInHex.Checked := TRUE;
  DisplaySyscom;
end;


procedure TfrmPCodeDebugger.DEBUGGERSettings1Click(Sender: TObject);
var
  FrmDEBUGGERSettings: TfrmDEBUGGERSettings;
begin
  FrmDEBUGGERSettings := TfrmDEBUGGERSettings.Create(self, DEBUGGERSettings);

  try
    if FrmDEBUGGERSettings.ShowModal = mrOK then
      begin
        InitProcNames;    // needs to be re-initialized
        with fInterpreter as TCustomPsystemInterpreter, DEBUGGERSettings do
          Brks.InitBreaks(Bytes);     // as do these

        try
          with DEBUGGERSettings do
            SaveToFile(DEBUGGERSettingsFileName(VersionNr));

          Update_StatusFmt('Settings saved to "%s"', [DEBUGGERSettingsFileName(VersionNr)]);
        except
          on e:Exception do
            Alertfmt('Could not save settings file "%s" [%s]', [DEBUGGERSettingsFileName(VersionNr), e.message]);
        end;
      end;
  finally
    FreeAndNil(FrmDEBUGGERSettings);
  end;
end;

(*
function TfrmPCodeDebugger.GetAccDbFileNumber: integer;
begin
  result := SelectedAccDbIndex;
end;

procedure TfrmPCodeDebugger.cbProfileAccDbFileNumberChange(
  Sender: TObject);
begin
  fAccDbFileNumber := FileNumberFrom(cbProfileAccDbFileNumber);
end;

function TfrmPCodeDebugger.FileNumberFrom(cb: TComboBox): integer;
begin
  with cb do
    if ItemIndex >= 0 then
      result := ItemIndex
    else
      result := 0;
end;

procedure TfrmPCodeDebugger.SetAccDbFileNumber(const Value: integer);
begin
  if {(Value >= 0) and} (Value < fpCodesProcTableS.Count) then
    begin
      SelectedAccDbIndex := Value;
      if Value >= 0 then
        begin
          fpCodesProcTableName  := fpCodesProcTableS[Value];
          lblAccDb.Caption      := fpCodesProcTableName;
          fpCodesProcTable      := TpCodesProcTable(fpCodesProcTableS.Objects[Value]);
        end;
    end;
end;
*)

procedure TfrmPCodeDebugger.SetSegNameIdx(const Value: TSegNameIdx);
begin
  fSegNameIdx := Value;
end;

function TfrmPCodeDebugger.SegBase: Longword;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := SegBase;
end;

procedure TfrmPCodeDebugger.New1Click(Sender: TObject);
var
  aFileName: string;
begin
  frmDatabaseParams := TfrmDatabaseParams.Create(self);
  try
    with frmDatabaseParams do
      begin
        DBFileName := DebuggerSettings.DatabaseToUse;

        DBVersion := dv_Access2007;

        if ShowModal = mrOK then
          begin
            try
              if FileExists(DBFileName) then
                if YesFmt('Database "%s" already exists. Overwrite?', [DBFileName]) then
                  DeleteFile(DBFileName)
                else
                  exit;

              aFileName  := DBFileName;
              CreateDebugDatabase(aFileName, DBVersion);
              DBFileName := aFileName;
              AlertFmt('Created Database "%s"', [aFileName]);
            except
              on e:Exception do
               ErrorFmt('Could not create Database "%s" [%s]', [ aFileName,
                                   ConnectionVersion[DBVersion].ConnectionTypeName]);
            end;
          end;
      end;
  finally
    FreeAndNil(frmDatabaseParams);
  end;
end;

function TfrmPCodeDebugger.TheSegNameIdx(SegBase: longword): TSegNameIdx ;
var
  SegName: string;
begin
  result := sn_Unknown;
  with fInterpreter as TCustomPsystemInterpreter do
//  with TErecPtr(@Bytes[SegBase])^ do // This only exists in Version IV
      begin
        SegName  := SegNameFromBase(SegBase);
        result   := SegIdxFromName(SegName);
      end;
end;

  function TfrmPCodeDebugger.SegNameFromBase(SegBase: longword): string;
  begin
    if SegBase <> 0 then
      begin
        SetLength(Result, CHARS_PER_SEG_NAME);
        with fInterpreter as TCustomPsystemInterpreter do
          Move(Bytes[SegBase+SEGNAME_], Result[1], CHARS_PER_SEG_NAME);
        result := UCSDName(result);
      end;
  end;

function TfrmPCodeDebugger.ProcNameFromErec(MSProc: integer; ErecAddr: word): string;
var
  aSegNameIdx: TSegNameIdx;
  aSegName: string;
  ProcNr: integer;
  ProcNrStr: string;
  AbsProcNr: integer;
  TheSegBase: LongWord;
begin
{$R-}
  ProcNr    := MSProc;   // procedure number is negative during "Exit" processing
{$R+}
  AbsProcNr := Abs(ProcNr);
  ProcNrStr := ProcNumStr(ProcNr);

  if InAltSegNames(ErecAddr, aSegNameIdx, aSegName) then
    aSegName  := SegNamesInDB[aSegNameIdx]
  else
    with fInterpreter as TIVPsystemInterpreter do
      begin
        with TErecPtr(@Bytes[ErecAddr])^ do
          begin
            with TSibPtr(@Bytes[env_sib])^ do
              begin
                with fInterpreter as TCustomPsystemInterpreter do
                  TheSegBase := PoolBase(Seg_Pool) + Seg_Base;
                TheSegBase := TheSegNameIdx(TheSegBase);         // This looks very dubious
              end;
            aSegName  := SegNamesInDB[aSegNameIdx];
          end;
        AddAltSegName(ErecAddr, aSegNameIdx, aSegName);
      end;

  result    := Format('%s: %s.%s', [ProcNrStr, aSegName, ProcNamesInDB[aSegNameIdx, AbsProcNr]])
end;

  function TfrmPCodeDebugger.IdentifierValue(IC: TIdentCode): longword;
  var
    ERecAddr: word;
  begin { IdentifierValue }
    with fInterpreter as TIVPsystemInterpreter do
      begin
        case IC of
          ic_BX: result := LocalVar;
          ic_SP: result := SP;
          ic_SP_LOW:
            with TTibPtr(@Bytes[Globals.LowMem.CURTASK])^.regs do
                            result := Sp_Low;
          ic_SP_UPR:
            with TTibPtr(@Bytes[Globals.LowMem.CURTASK])^.regs do
              result := Sp_Upr;
          ic_GlobVar:       result := GlobVar;
          ic_DS:            result := DS;
          ic_MP:            result := MP;
          ic_DSpIPC:        result := DS+SI;
          ic_DSpProcBase:   result := DS+ProcBase+1;
{$R-}
          ic_RelIPC:  result := RelIPC;
{$R+}
          ic_AbsIPC:  result := AbsIPC;
          ic_CURTASK: result := Globals.Lowmem.CURTASK;
          ic_READYQ:  result := Globals.LowMem.READYQ;
          ic_EVECp:   result := Globals.LowMem.EVECP;
          ic_ERECp:   result := Globals.LowMem.ERECp;
          ic_SegB:    result := Globals.LowMem.SEGb;
          ic_SEXFLAG: result := Globals.LowMem.SexFlag;
          ic_SEGTOP:  result := Globals.LowMem.SEGTOP;
          ic_CPOffset: result := Globals.LowMem.CPOffset;
          ic_LocalVar: result := LocalVar; // Globals.LowMem.BASE;
          ic_TOS:      result := TOS;
          ic_TOS2:     result := WordAt[SP+2];
          ic_EnterIC:  result := ProcBase;
          ic_FaultTib: result := SyscomPtr^.fault_sem.Fault_Message.fault_tib;
          ic_FaultErec:result := SyscomPtr^.fault_sem.Fault_Message.fault_e_rec;

          ic_FaultSIB: begin
                         ERecAddr := SyscomPtr^.fault_sem.Fault_Message.fault_e_rec;
                         result   := TErecPtr(@Bytes[ErecAddr])^.env_sib;
                       end;
          ic_Task_Link:
            with TTibPtr(@Bytes[Globals.LowMem.CURPROC])^.Regs do
              result := Task_Link;
          ic_DataSize:
            result := WordAt[DS+ProcBase-2] * 2;
          ic_MemInfo:
            result := SyscomPtr^.Mem_Info;
          ic_SegNum:
            result := SegNum;
          else
            raise Exception.CreateFmt('Unknown ID: %s', [IdentCodeInfo[IC].Ident]);
        end;
    end
  end;  { IdentifierValue }

{ TfrmPCodeDebuggerII }

function TfrmPCodeDebuggerII.Caller(Calls: integer; var aProcNum: integer; var aSegIdx: TSegNameIdx): boolean;
begin
  Unimplemented('TfrmPCodeDebuggerII.Caller');
end;

Constructor TfrmPCodeDebuggerII.Create( aOwner: TComponent;
                    aInterpreter: TObject;
                    VolumesList: TVolumesList;
                    anOnUpdateStatusProc: TStatusProc;
                    BootParams: TBootParams);
begin
  inherited Create(aOwner, aInterpreter, VolumesList, anOnUpdateStatusProc, BootParams);

{$IfDef DumpDebugInfo}
  DumpDebugInfo1.Enabled := true;
{$else DumpDebugInfo}
  DumpDebugInfo1.Enabled := false;
{$EndIf DumpDebugInfo}

  fLegalIdentCodes := fLegalIdentCodes + [ic_JTAB, ic_SegNum, ic_EnterIC];
end;

procedure TfrmPCodeDebuggerII.DisplayCallStack(Grid: TStringGrid;
  CSType: TMSCWFieldNr; var fExitingProcs: TChangedRows);
const
  MAXROWS = 20;
var
  MscwAddr: word;
  p: TMscwPtr2;
  aJTAB: word;
  aProcNr: word;
  aProcName: string;
  aRelIPC, aEnterIC: word;
  NrRows: integer;
  SavedRowNr: integer;
begin { DisplayCallStack }
  with Grid do
    begin
      SavedRowNr                := Row;    // remember which row was selected
      RowCount                  := 1;
      Cells[COL_CsNr, 0]        := 'MSCW';
      Cells[COL_CsProcName, 0]  := 'Proc';
      Cells[COL_CsIpc, 0]       := '@IPC';
    end;
  NrRows := 1;

  with fInterpreter as TUCSDInterpreter do
    begin
      aProcNr  := Bytes[JTAB];
      AddProcCall(Grid, 0, ProcNameFromSegTop(aProcNr, SEGP), IntToStr(RelIPC));  // First the current procedure

      MscwAddr := Globals.Lowmem.Syscom.LASTMP;
      p        := TMSCWPtr2(@Bytes[MscwAddr]);

      if (aProcNr <> 0) then
        while (MscwAddr <> 0) and
              (MscwAddr <> MSCWField(MSCWAddr, CSType) {next MSCW addr}) and
              (aProcNr <> 0) and
              (MSCWField(MSCWAddr, csStatic) <> 0) do
          begin  // then all the other procedures on the call stack
            aJTAB        := MSCWField(MSCWAddr, csJTAB);
            aProcNr      := Bytes[aJTAB];
            aProcName    := ProcNameFromSegTop(aProcNr, MSCWField(MSCWAddr, csSeg));

            aRelIPC   := 0;
            try
              aEnterIC  := aJTAB-2 - WordAt[aJTAB-2];
              if MSCWField(MSCWAddr, csIPC) >= aEnterIC then
                aRelIPC   := MSCWField(MSCWAddr, csIPC) - aEnterIC;
            except
              on ERangeError do
                aRelIPC   := 0;
            end;

            AddProcCall(Grid, MscwAddr, aProcName, IntToStr(aRelIPC));

            MscwAddr  := MSCWField(MSCWAddr, CSType);   // link to previous MSCW

            Inc(NrRows);
            if NrRows > MAXROWS then // prevent infinite loop on call stack
              break;
          end;
      if SavedRowNr < Grid.RowCount then
        Grid.Row := SavedRowNr;  // restore to what user had previously highlighted
    end;
end;  { DisplayCallStack }

procedure TfrmPCodeDebuggerII.DisplayGlobalDirectory;
var
  SysComPtr: TSyscomPtr;
  gDirpAddr: word;
begin
  with fInterpreter as TUCSDInterpreter do
    begin
      SyscomPtr := @Globals.Lowmem.Syscom;
      gDirpAddr := Globals.Lowmem.Syscom.gdirp;
      DisplayGlobalDirectoryCommon(gDirpAddr);
    end;
end;

procedure TfrmPCodeDebuggerC.DisplayGlobalDirectory;
var
  SyscomIIPtr: TSyscomIIPtr;
  gDirpAddr: word;
begin
  with fInterpreter as TCPsystemInterpreter do
    begin
      SyscomIIPtr := TSysComIIPtr(@Bytes[ByteIndexed(SyscomAddr)]);
      with SyscomIIPtr^ do
        begin
          gDirpAddr := ByteIndexed(gdirp);
          DisplayGlobalDirectoryCommon(gDirpAddr);
        end;
    end;
end;


procedure TfrmPCodeDebugger.DisplayGlobalDirectory;
var
//SysComPtr: TSyscomPtr;
  gDirpAddr: word;
begin
  with fInterpreter as TIVPsystemInterpreter do
    begin
//    SyscomPtr := @Globals.Lowmem.Syscom;
      gDirpAddr := SyscomPtr^.gdirp;
      DisplayGlobalDirectoryCommon(gDirpAddr);
    end;
end;

procedure TfrmPCodeDebuggerII.DisplayRegisters;
const
  VERSION_II_REGISTERS =
                [ic_SP_LOW, ic_SP_UPR, ic_SP, ic_MP, ic_GlobVar,
                 ic_LocalVar, ic_TOS, ic_TOS2, ic_DataSize, ic_SEGTOP,
                 ic_JTAB, ic_SegNum, ic_EnterIC];
type
  TIdentCodeSet = set of TIdentCode;
var
  aSegName: string;
  aProcName: string;
  anOpCode: word;
  IC: TIdentCode;
  RowNr, SavedRowNr: integer;

  function Cardinality(IdentCodes: TIdentCodeSet): integer;
  var
    ic: TIdentCode;
  begin
    result := 0;
    for ic := Low(TIdentCode) to High(TIDentCode) do
      if ic in IdentCodes then
        inc(result);
  end;

begin { TfrmPCodeDebuggerII.DisplayRegisters }
  with sgRegisters do
    begin
      SavedRowNr := Row;   // remember what is currently selected
      RowCount := Cardinality(VERSION_II_REGISTERS) + ROW_REGS {registers};
      Cells[0, ROW_CAPTION]  := 'NAME';        // 8 registers
      Cells[0, ROW_SEGNAME]  := 'SegName';
      Cells[0, ROW_PROCNUM]  := 'ProcNum';
      Cells[0, ROW_PROCNAME] := 'ProcName';
      Cells[0, ROW_RELIPC]   := 'RelIPC';
      Cells[0, ROW_ABSIPC]   := 'AbsIPC';
      Cells[0, ROW_DBGCNT]   := 'DbgCnt';
      Cells[0, ROW_OPCODE]   := 'OpCode';
      Cells[0, ROW_OPNAME]   := 'OpName';

      RowNr := ROW_REGS;
      for IC := Succ(ic_Unknown) to High(TIdentCode) do
        if IC in VERSION_II_REGISTERS then
          begin
            Cells[0, RowNr] := IdentCodeInfo[IC].Ident;
            Cells[1, RowNr] := HexWord(IdentifierValue(IC));
            RowNr := RowNr + 1;
          end;

      with fInterpreter as TUCSDInterpreter do
        begin
          aSegName   := SegNamesInDB[SegNameIdx];
          aProcName  := ProcNamesInDB[SegNameIdx, CurProc];

          if fInterpreter is TCPsystemInterpreter then
            with fInterpreter as TCPsystemInterpreter do
              anOpCode := MemRdByte(IpcBase, IPC)
          else // if fInterpreter is TIIPsystemInterpreter then
            anOpCode   := Bytes[AbsIPC];

          Cells[1, ROW_CAPTION]  := 'VALUE';
          Cells[1, ROW_SEGNAME]  := aSegName;
          Cells[1, ROW_PROCNUM]  := IntToStr(CurProc);
          Cells[1, ROW_PROCNAME] := aProcName;
          Cells[1, ROW_RELIPC]   := IntToStr(RelIPC);
          Cells[1, ROW_ABSIPC]   := Format('%-4.4x:%x', [ProcBase, RelIPC]);
          Cells[1, ROW_DBGCNT]   := Format('%0.n', [DbgCnt*1.0]);
          Cells[1, ROW_OPCODE]   := IntToStr(anOpCode);
          Cells[1, ROW_OPNAME]   := Opstable.Ops[anOpCode].Name;
        end;
      sgRegisters.Row := SavedRowNr;
    end;
end;  { TfrmPCodeDebuggerII.DisplayRegisters }

function TfrmPCodeDebuggerII.GetCurProc: integer;
begin
  with fInterpreter as TUCSDInterpreter do
    result := CurProc;
end;

function TfrmPCodeDebuggerII.GetRelIPC: word;
begin
{$R-}
  try
    with fInterpreter as TUCSDInterpreter do
      result := RelIPC;
  except
    result := 0;
  end;
{$R+}
end;

(*
function TfrmPCodeDebuggerII.GetNextOpCode: word;
begin
  if fInterpreter is TCPsystemInterpreter then
    with fInterpreter as TCPsystemInterpreter do
      result   := GetNextOpCode
  else
    begin
      Assert(false, 'InterpII has not been tested');
    end;
end;
*)

function TfrmPCodeDebuggerII.GetSegTop(p: TMSCWPtr2): longword;
begin
  result := p^.MSSEG;
end;

function TfrmPCodeDebuggerII.GetSegNameIdx: TSegNameIdx;
var
  SegNameIdx: TSegNameIdx;
begin
  with fInterpreter as TUCSDInterpreter do
//  if SegNum <> fLastSegNum then   // commented out because it wasn't getting updated properly
      begin
        SegNameIdx  := TheSegNameIdx(SegBase);
        fLastSegNum := SegNum;
      end;
    result := SegNameIdx;
end;

function TfrmPCodeDebuggerII.GetSPReg: word;
begin
  with fInterpreter as TUCSDInterpreter do
    result := SP;
end;

function TfrmPCodeDebuggerII.IdentifierValue(IC: TIdentCode): longword;
begin
  result := 0;
  with fInterpreter as TUCSDInterpreter do
    begin
      case IC of
        ic_SP:
          result := SP;
        ic_SP_LOW:
          result := HeapTop;       // dhd - assume that lowest stack is the highest heap 4/8/2021
        ic_SP_UPR:
          result := Globals.Lowmem.Syscom.MEMTOP;  // dhd - assumed SP_UPR
        ic_GlobVar:
          result := GlobVar;  // GlobVar
        ic_LocalVar:
          result := LocalVar;    // LocalVar
        ic_MP:
          result := HeapTop;
        ic_RelIPC:
          result := RelIPC;
        ic_AbsIPC:
          result := AbsIPC;
        ic_TOS:
          result := WordAt[SP];
        ic_TOS2:
          result := WordAt[WordIndexed(SP, +1)];
        ic_EnterIC:
          result := ProcBase;
        ic_DataSize:
          result := ProcDataSize(JTab);
        ic_JTAB:
          result := JTAB;
      end;
  end
end;

procedure TfrmPCodeDebuggerII.InitProcNames;
begin
  inherited;
// Temporary to initialize the basic segment/procedure names

end;

procedure TfrmPCodeDebuggerII.LoadProcedureNames;
begin
  inherited;

end;

function TfrmPCodeDebuggerII.ProcNameFromErec(MSProc: integer; ErecAddr: word): string;
begin
  Unimplemented('TfrmPCodeDebuggerII.ProcNameFromErec');
end;

function TfrmPCodeDebuggerII.ReformLine(var Line: string): string;
//var
//OK: boolean;

  function DisAsm15: string;
  var
    SegNrStr, ProcNrStr, pCodeStr2, OffsetStr, pCodeStr, OpCode: string;
//  SegNr, ProcNr, OffSet: word;
  begin { DisAsm15 }
    // Try the version I.5 DisAsm format
    SegNrStr  := Copy(Line, 1, 7);
    ProcNrStr := Copy(Line, 8, 5);
    OffsetStr := Copy(Line, 13, 6);
    pCodeStr  := Copy(Line, 25, 35);
    pCodeStr2 := Copy(Line, 25, 255);  // some opcodes are different ('LCA')
    try
//    SegNr   := StrToInt(SegNrStr);
//    ProcNr  := StrToInt(ProcNrStr);
//    OffSet  := StrToInt(OffsetStr);
      OpCode  := Trim(pCodeStr);
      OpCode  := Trim(Copy(OpCode, 1, 6));
      if not SameText(OpCode, 'LCA') then
        result  := OffsetStr + ': ' + Trim(pCodeStr)
      else
        result  := OffsetStr + ': ' + Trim(pCodeStr2);
    except
      if Trim(Line) = 'SEGMENT PROC     OFFSET#                                   HEX CODE' then
        result := 'OFFSET  P-CODE'
      else
        result := line;   // if it didn't work, just return the whole line
    end;
  end;  { DisAsm15 }

  function DisAsmMine: string;
  begin { DisAsmMine }

  end;  { DisAsmMine }

begin
//DisasmMine;
  result := DisAsm15;
end;

function TfrmPCodeDebuggerII.SegBase: Longword;
begin
  with fInterpreter as TUCSDInterpreter do
    result := SEGP; // V1.5, V2 relates everything to the segment TOP
end;

(*
function TfrmPCodeDebuggerII.UpdatePCode(aProcName: string;
  MemoField: TMemoField): boolean;
var
  Ok: boolean;
begin
  result := false;
  if not Empty(aProcName) then
    begin
      Ok := true;       // debugging
      if Ok then
        begin
          with fpCodesProcTable do
            begin
              MemoField.Transliterate := TRANSLITERATE;
              fBlobStream := CreateBlobStream(MemoField, bmWrite);
              fBlobStream.Seek(0, soFromBeginning);
            end;

          try
            with fInterpreter as TCustomPsystemInterpreter do
              fpCodeDecoder.Decode( AbsIPC, 0, true, dfMemoFormat);     // this puts the p-Code lines into the memo using the AddLine method
          finally
            FreeAndNil(fBlobStream);
            result := true;
          end;
        end;
    end;
end;
*)

procedure TfrmPCodeDebugger.UnImplemented(const Msg: string);
begin
  Update_Status(Msg);
end;

function TfrmPCodeDebugger.GetSPReg: word;
begin
  with fInterpreter as TIVPsystemInterpreter do
    result := SP;
end;

procedure TfrmPCodeDebuggerII.CallStackDblClick(Grid: TStringGrid;
  CSType: TMSCWFieldNr);
var
//MSCWPtr: TMSCWPtr2;
  MSCWAddr: word;
  SegIdx: TSegNameIdx;
  aProcNr, anEnterIC, aJTab, aIPC, aRelIPC, aEnv: word;
begin
  if Assigned(Grid) then
    with Grid do
      begin                         // one object per row
        MSCWAddr    := Word(Objects[0, Row]); // The Object field holds the MSCWAddr
        with fInterpreter as TUCSDInterpreter do
          begin
//          MSCWPtr    := TMSCWPtr2(@Bytes[MSCWAddr]);

            aJtab      := MSCWField(MSCWAddr, csJTAB);
            aEnv       := MSCWField(MSCWAddr, csSEG);
            aProcNr    := Bytes[aJTab];
            anEnterIC  := GetEnterIC(aJTab); // aJTab - 2 - WordAt[aJTab-2];
            aIPC       := MSCWField(MSCWAddr, csIPC);
{$R-}
            aRelIPC    := aIPC - ((anEnterIC - 2) - WordAt[anEnterIC - 2]);
{$R+}
            SegIdx     := TheSegNameIdx(aEnv);
            if OpenProc(SegIdx,
                        aProcNr,
                        ProcNamesInDB[SegIdx, aProcNr],
                        aRelIPC) then
              SelectCurrentLine(CurrentMemo(fSelectedMemo), aRelIPC);
          end;
      end;
end;

function TfrmPCodeDebuggerII.GetSegBase(MSCWAddr: word): longword;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := MSCWField(MSCWAddr, csSEG);
end;

function TfrmPCodeDebugger.IsUserProg: boolean;
begin
  result := false;
end;

function TfrmPCodeDebuggerII.IsUserProg: boolean;
var
  Idx: integer;
begin
  with fInterpreter as TUCSDInterpreter  do
    Idx    := SegIdxFromSegTop(SEGP);
  result := Idx = 1;
end;

procedure TfrmPCodeDebugger.FindStringinMemory1Click(Sender: TObject);
begin
  fFindIdx := 0;
  with FindDialog2 do
    begin
      FindText := fSearchFor;
      Execute;
    end;
end;

function TfrmPCodeDebugger.FindStringInMemory(const SearchFor: string): longint;
var
  i: integer;
  mode1, mode2: TSearch_Type; // (SEARCHING, SEARCH_FOUND, NOT_FOUND);
  cs: boolean; c1, c2: char;
  hexbytes: THexBytes;
  NrBytes: integer;
  Len: integer;

  function DoHexSearch(const HexBytes: THexBytes; NrBytes: integer): longint;
  var
    mode1, mode2: TSearch_Type; // (SEARCHING, SEARCH_FOUND, NOT_FOUND);
    c1, c2: byte;

  begin { DoHexSearch }
    with fInterpreter as TCustomPsystemInterpreter do
      begin
        result := -1;
        mode1  := SEARCHING;
        repeat
          if fFindIdx >= InterpHIMEM-NrBytes-1 then
            mode1 := NOT_FOUND
          else
            begin
              mode2 := SEARCHING;
              i     := 0;
              repeat
                if i >= NrBytes then
                  mode2 := SEARCH_FOUND
                else
                  begin
                    c1 := Bytes[fFindIdx+i];
                    c2 := HexBytes[i];

                    if c1 <> c2  then
                      mode2 := NOT_FOUND
                    else
                      Inc(i);
                  end;
              until mode2 <> SEARCHING;
              if mode2 = SEARCH_FOUND then
                mode1 := SEARCH_FOUND
              else
                Inc(fFindIdx);
            end;
        until mode1 <> SEARCHING;
        if mode1 = SEARCH_FOUND then
          result := fFindIdx;
      end
  end;  { DoHexSearch }

  function DoAsciiSearch(const SearchFor: string): longint;
  begin { DoAsciiSearch}
    with fInterpreter as TCustomPsystemInterpreter do
      begin
        mode1  := SEARCHING;
        repeat
          if fFindIdx >= InterpHIMEM-(Length(SearchFor))-1 then
            mode1 := NOT_FOUND
          else
            begin
              mode2 := SEARCHING;
              i     := 0;
              repeat
                if i >= Length(SearchFor) then
                  mode2 := SEARCH_FOUND
                else
                  begin
                    c1 := chr(Bytes[fFindIdx+i]);
                    if not cs then
                      c1 := UpCase(c1);

                    c2 := SearchFor[i+1];

  //                if not cs then  // already handled in caller
  //                  c2 := UpCase(c2);

                    if c1 <> c2  then
                      mode2 := NOT_FOUND
                    else
                      Inc(i);
                  end;
              until mode2 <> SEARCHING;
              if mode2 = SEARCH_FOUND then
                mode1 := SEARCH_FOUND
              else
                Inc(fFindIdx);
            end;
        until mode1 <> SEARCHING;
        if mode1 = SEARCH_FOUND then
          result := fFindIdx;
      end
  end;  { DoAsciiSearch }

begin
  cs     := frMatchCase in FindDialog2.Options;    // case sensitive?
  Len    := Length(SearchFor);
  if (Len>1) and (SearchFor[1] = '$') then // do a binary search
    begin
      FillChar(HexBytes, MAX_DIFF_LEN, 0);
      NrBytes := ConvHexStr(Copy(SearchFor, 2, Len-1), HexBytes);
      result  := DoHexSearch(HexBytes, NrBytes);
    end
  else
    result := DoAsciiSearch(SearchFor);
end;


procedure TfrmPCodeDebugger.FindDialog2Find(Sender: TObject);
var
  Addr: longint;
  Msg: string;
begin
  if not (frMatchCase in FindDialog2.Options) then  // not case sensitive
    fSearchFor := UpperCase(FindDialog2.FindText)
  else
    fSearchFor := FindDialog2.FindText;

  Addr          := FindStringInMemory(fSearchFor);
  if Addr >= 0 then
    begin
      Msg := Format('String "%s" found at address %-8.8x', [fSearchFor, Addr]);
      Update_Status(Msg, clLime);
      
      fOnStatusUpdate(Msg, true, true, clLime);

      Inc(fFindIdx);   // Don't want to find it again
    end
  else
    begin
      Msg := Format('String "%s" could not be found in memory', [fSearchFor]);
      fOnStatusUpdate(Msg, true, true, clYellow);
      Update_Status(Msg, clYellow);
      fFindIdx := 0;  // start the search over
      SysUtils.Beep;
    end;
end;

procedure TfrmPCodeDebugger.RefreshDisplay1Click(Sender: TObject); // F5
begin
  UpdateDebuggerDisplay
end;

procedure TfrmPCodeDebugger.PrintRegisters1Click(Sender: TObject);
var
  OutFileName, SubTitle: string;
begin
//OutFileName := UniqueFileName(DEBUGGERSettings.ReportsPath + 'Registers.txt');
  OutFileName := FileNameByDate(DEBUGGERSettings.ReportsPath + 'Registers.txt');

  with fInterpreter as TUCSDInterpreter do
    SubTitle := TheVersionName;

  PrintStringGrid('Registers', SubTitle, sgRegisters, OutFileName, true);
end;

function TfrmPCodeDebugger.LoggingToAFile: boolean;
var
  bn: integer;
begin
  result := false;
  with DEBUGGERSettings do
    begin
      for bn := 0 to Brks.Count-1 do
        with Brks.Items[bn] as TBreakInfo do
          begin
            if LogMessage and LogToAFile then
              begin
                result := true;
                break;
              end;
          end;
    end;
end;

procedure TfrmPCodeDebugger.CloseBreakpointLogfile1Click(Sender: TObject);
begin
  if LoggingToAFile then
    with DEBUGGERSettings do
      begin
        Brks.LogFileRefCount := 0;
        Brks.CloseLogFile;
      end;
end;

procedure TfrmPCodeDebugger.Breakpoints1Click(Sender: TObject);
begin
  CloseBreakpointLogfile1.Enabled := LoggingToAFile;
end;

procedure TfrmPCodeDebugger.PasteExternalpCode2Click(Sender: TObject);
begin
  if PageControl1.ActivePage = tabPCode then
    PasteToMemo(Memo1);
end;

procedure TfrmPCodeDebugger.miPasteExternalSourceCodeClick(
  Sender: TObject);
begin
  if PageControl1.ActivePage = tabPCode then
    PasteExternalSourceCode(VersionNr);
end;

procedure TfrmPCodeDebugger.sgDirectoryDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  InflateRect(Rect, -1);
  GridDrawCell(sgDirectory, fBadDates, ACol, ARow, Rect);
end;

procedure TfrmPCodeDebugger.CrtKeyInfoStatusProc( const Msg: string;
                                                  DoLog: boolean = true;
                                                  DoStatus: boolean = true;
                                                  Color: TColor = clBtnFace);
begin
  MemoCrtKeyInfo.Lines.Add(Msg)
end;


procedure TfrmPCodeDebugger.DisplayCrtKeyInfo;
var
  SysComPtr: TInBufPtr;
  Msg: string;
  CrtInfo: TCrtInfo;
  KeyInfo: TCrtInfo;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      MemoCrtKeyInfo.Clear;
      SysComPtr := @Bytes[ByteIndexed(SysComAddr)];

      with DEBUGGERSettings do
        Msg := Format('Current CRT/Key info from memory (probably loaded from %s) @ %s',
                      [fVolumesList[LastBootedUnitNr].VolumeName, DateTimeToStr(Now)]);
      CrtKeyInfoStatusProc(Msg);

      try
        CrtInfo := TCrtInfo.Create(LOW_CRT_FUNC, HIGH_CRT_FUNC);
        CrtInfo.OnInfoChanged := frmPSysWindow.CrtInfoChanged;

        KeyInfo := TCrtInfo.Create(LOW_KEY_FUNC, HIGH_KEY_FUNC);

        LoadCrtKeyInfo(SysComPtr, CrtInfo, KeyInfo, VersionNr, CrtKeyInfoStatusProc)
      finally
        FreeAndNil(KeyInfo);
        FreeAndNil(CrtInfo);
      end;
    end;
end;

procedure TfrmPCodeDebugger.DisplayaSYSCOMMISCINFO1Click(Sender: TObject);
var
  Inbuf: TInBuf;
  VolNr: integer;
  VolNrString: string;
  DirIdx: integer;
//Done: boolean;
  DirEntry: PDirEntry;
  FileName: string;
  BlocksRead: longint;
  CrtInfo, KeyInfo: TCrtInfo;
  InBufPtr: TInBufPtr;
  Msg: string;
begin
  with DEBUGGERSettings do
    VolNrString := IntToStr(LastBootedUnitNr);

  if GetString( 'Get Volume Number', 'VolumeNumber', VolNrString, 4) then
    begin
      VolNr := StrToInt(VolNrString);

      with fVolumesList[VolNr].TheVolume do
        begin
          FileName := CSYSTEM_MISCINFO;
          if GetString('.MISCINFO file name', 'File Name', FileName, TIDLENG) then
            begin
              DirEntry := FindDirectoryEntry(FileName, DirIdx);
              if Assigned(DirEntry) then
                with DirEntry^ do
                  begin
                    SeekInVolumeFile(FirstBlk);
                    BlocksRead := BlockRead(InBuf, 1);
                    if BlocksRead = 1 then
                      begin
                        InBufPtr := @InBuf;
                        CrtInfo := TCrtInfo.Create(LOW_CRT_FUNC, HIGH_CRT_FUNC);
                        KeyInfo := TCrtInfo.Create(LOW_KEY_FUNC, HIGH_KEY_FUNC);
                        try
                          PageControl1.ActivePage := TabCrtKeyInfo;
                          with fInterpreter as TCustomPsystemInterpreter do
                            begin
                              MemoCrtKeyInfo.Clear;
                              CrtKeyInfoStatusProc(Padr('', 80, '='));
                              Msg := Format('MiscInfo settings in from file "%s" in volume %s',
                                            [FileName, VolumeName]);
                              CrtKeyInfoStatusProc(Msg);

                              Msg := Format('(%s) @ %s', [DOSFileName, DateTimeToStr(Now)]);
                              CrtKeyInfoStatusProc(Msg);

                              LoadCrtKeyInfo(InBufPtr, CrtInfo, KeyInfo, VersionNr, CrtKeyInfoStatusProc);
                            end;
                        finally
                          FreeAndNil(KeyInfo);
                          FreeAndNil(CrtInfo);
                        end;
                      end
                    else
                      raise Exception.CreateFmt('Unable to read %s.%s', [VolumeName, FileName]);
                  end
              else
                MessageFmt('File "%s" could not be found', [FileName]);
            end;
        end;
    end;
end;

{$IfDef DumpDebugInfo}
procedure TfrmPCodeDebugger.DumpDebugInfo1Click(Sender: TObject);
var
  aCaption: string;
begin
  if GetString('Debug info caption', 'Caption', aCaption) then
    with fInterpreter as TUCSDInterpreter do
      DumpDebugInfoExt(aCaption);
end;
{$Else}
procedure TfrmPCodeDebugger.DumpDebugInfo1Click(Sender: TObject);
begin
end;
{$EndIf DumpDebugInfo}

procedure TfrmPCodeDebugger.miLoadClick(Sender: TObject);
var
  f: TfrmLoadVersion;
  mr: integer;
begin
  f := TfrmLoadVersion.Create(self, fVolumesList);
  f.OnNavigateClick := nil;    // enable the correct buttons
  try
    with f do
      begin
        mr := ShowModal;
        case mr of
          mrOK  : DebuggerLoadFromUnit(VersionNr, f.RecentBootparams.UnitNumber);
          mrSave: { save }
          { begin
              (FilerSettings.RecentBootsList.Items[RecNo] as TBootParams).Assign(RecentBootParams); // save the changed values
            end };
        end;
      end;
  finally
    FreeAndNil(f);
  end;
end;

function TfrmPCodeDebuggerII.GetWordAt(P: word): word;
begin
  with fInterpreter as TUCSDInterpreter do
    if Word_Memory then
      result := Words[P*2]
    else
      result := Words[P];
end;

procedure TfrmPCodeDebuggerII.DisplayPStack;
var RowNr: word;
    hex: string;
    Addr : longword;
    Wd: TUnion;
Begin { DisplayPStack }
  sgPStack.Cells[COL_ADDR, 0]   := 'Addr';
  sgPStack.Cells[COL_HEXVAL, 0] := 'Hex';
  sgPStack.Cells[COL_DECVAL, 0] := 'Dec';
  sgPStack.Cells[COL_NIBVAL, 0] := 'Nib';
  sgPStack.Cells[COL_ASCVAL, 0] := 'Asc';

  with fInterpreter as TUCSDInterpreter do
    begin
      Addr  := SP;
      RowNr := 1;
      while (RowNr <= PSTACK_NR_ROWS) and (Addr < InterpHIMEM) do
        Begin
          Hex     := HexWord(Addr);
          Wd.W    := WordAt[Addr];

          sgPStack.Cells[COL_ADDR, RowNr]   := Hex;
          sgPStack.Cells[COL_HEXVAL, RowNr] := HexWord(WD.W);
          sgPStack.Cells[COL_DECVAL, RowNr] := IntToStr(WD.I);
          sgPStack.Cells[COL_NIBVAL, RowNr] := HexByte(Wd.l) + ' ' + HexByte(WD.h);
          sgPStack.Cells[COL_ASCVAL, RowNr] := Printable(wd.s);

          Addr := WordIndexed(Addr, +1);

          inc(RowNr,1);
        end;
    end;
  AdjustColumnWidths(sgPStack);
  sgPStack.Row := 1;
end;  { DisplayPStack }

{ TfrmPCodeDebuggerC }

Constructor TfrmPCodeDebuggerC.Create(aOwner: TComponent;
  aInterpreter: TObject; VolumesList: TVolumesList;
  anOnUpdateStatusProc: TStatusProc;
  BootParams: TBootParams);
begin
  inherited Create(aOwner, aInterpreter, VolumesList, anOnUpdateStatusProc, BootParams);

//Caption := 'p-Code Debugger for Peter Miller derived interpreter';
//EnableExternalPool1.Visible := false;
  fLegalIdentCodes := fLegalIdentCodes + [ic_JTAB, ic_SegNum, ic_EnterIC];
end;

function TfrmPCodeDebuggerC.IdentifierValue(IC: TIdentCode): longword;
begin
  with fInterpreter as TCPsystemInterpreter do
    begin
      case IC of
        ic_SP:
          result := SP;
        ic_SP_LOW:
          result := HeapTop;       // dhd - assume that lowest stack is the highest heap 4/8/2021
        ic_SP_UPR:
          result := Globals.Lowmem.Syscom.MEMTOP;  // dhd - assumed SP_UPR
        ic_GlobVar:
          result := GlobVar;  // GlobVar
        ic_LocalVar:
          result := LocalVar;    // LocalVar
        ic_MP:
          result := HeapTop;
        ic_RelIPC:
          result := RelIPC;
        ic_AbsIPC:
          result := AbsIPC;
//        ic_SegB:
//          result := HL;
        ic_TOS:
          result := WordAt[SP];
        ic_TOS2:
          result := WordAt[WordIndexed(SP,1)];
//        ic_ProcBase:
//          result := ProcBase;
        ic_DataSize:
          result := CurrentDataSize; // unimplemented so far
        ic_SEGTOP:
          result := NewSegTop;
        ic_JTAB:
          result := JTAB;
        ic_SegNum:
          result := GetSegNum;
        ic_EnterIC:
          result := ProcBase;
        else
          raise EUnknownID.CreateFmt('Unknown ID: %s', [IdentCodeInfo[IC].Ident]);
      end;
  end
end;

procedure TfrmPCodeDebugger.miLoadFromLastClick(Sender: TObject);
begin
  with DEBUGGERSettings do
    DebuggerLoadFromUnit(VersionNr, LastBootedUnitNr);
end;

procedure TfrmPCodeDebugger.Load1Click(Sender: TObject);
begin
  DebuggerLoadFromUnit(VersionNr, 4)
end;

procedure TfrmPCodeDebuggerC.DisplayCallStack(Grid: TStringGrid;
  CSType: TMSCWFieldNr; var fExitingProcs: TChangedRows);
const
  MAXROWS = 20;
var
  MscwAddr: word;
//p: TMscwPtr2;
  aJTAB: word;
  aProcNr: word;
  aProcName: string;
  aRelIPC{, aEnterIC}: word;
  NrRows: integer;
  SavedRowNr: integer;
begin
  with Grid do
    begin
      SavedRowNr                := Row;    // remember which row was selected
      RowCount                  := 1;
      Cells[COL_CsNr, 0]        := 'MSCW';
      Cells[COL_CsProcName, 0]  := 'Proc';
      Cells[COL_CsIpc, 0]       := '@IPC';
    end;
  NrRows := 1;

  with fInterpreter as TCPsystemInterpreter do
    begin
      aProcNr  := ProcNumber(JTab);
      AddProcCall(Grid, 0, ProcNameFromSegTop(aProcNr, SEGP), IntToStr(RelIPC));  // First the current procedure

      MscwAddr := MP;

      if (aProcNr <> 0) then
        while (MscwAddr <> 0) and
              (MscwAddr <> MSCWField(MSCWAddr, CSType) {next MSCW addr}) and
              (aProcNr <> 0) and
              (MSCWField(MscwAddr, csJTab) <> 0) do
          begin  // then all the other procedures on the call stack
            aJTAB        := MSCWField(MscwAddr, csJTAB);
            aProcNr      := ProcNumber(aJTAB);
            aProcName    := ProcNameFromSegTop(aProcNr, MSCWField(MSCWAddr, csSeg));

            aRelIPC   := MSCWField(MSCWAddr, csIPC);

            AddProcCall(Grid, MscwAddr, aProcName, IntToStr(aRelIPC));

            MscwAddr  := MSCWField(MSCWAddr, CSType);   // link to previous MSCW

            Inc(NrRows);
            if NrRows > MAXROWS then // prevent infinite loop on call stack
              break;
          end;
      if SavedRowNr < Grid.RowCount then
        Grid.Row := SavedRowNr;  // restore to what user had previously highlighted
    end;
end;

function TfrmPCodeDebugger.BreakonpHitsZero: boolean;
begin
  result := BreakonpHits0.Checked;
end;

procedure TfrmPCodeDebugger.BreakonpHits0Click(Sender: TObject);
begin
  BreakonpHits0.Checked := not BreakonpHits0.Checked;
end;

(*
procedure TfrmPCodeDebugger.Logging1Click(Sender: TObject);
begin
  Logging1.Checked := not Logging1.Checked;
  if Logging1.Checked then
    begin
      fLogFileName := 'c:\temp\pocahontas.txt';
      AssignFile(fLogFile, fLogFileName);
      Rewrite(fLogFile);
      WriteLn(fLogFile, 'IPC':6, ',',                    { IPC }
                        'ProcNum':4, ',',                { ProcNum }
                        'ProcName':16, ',',
                        'Op':6, ',',
                        'OpName':16, ',',
                        'SP':10,
                        'DbgCnt':6);
      MessageFmt('Opened %s', [fLogFileName]);
    end
  else
    begin
      CloseLogFile;
      MessageFmt('Closed %s', [fLogFileName]);
      fLogFileName := '';
    end;
end;
*)

{$IfDef DashBoard}
procedure TfrmPCodeDebugger.DashBoard1Click(Sender: TObject);
var
  frmDebugWindow: TfrmPSysDebugWindow;
  Title: string;
begin
  if not Assigned(fDashboardWindowsList) then
    fDashboardWindowsList := TDashBoardsList.Create;

  Title := Format('p-Code debugger Dashboard %4d', [fDashboardWindowsList.Count]);
  frmDebugWindow := TfrmPSysDebugWindow.Create(
                      self,
                      Title,
                      0, 0, {VersionNr,} 200, 200,
                      fInterpreter,
                      self);
  frmDebugWindow.FreeNotification(self);
  fDashboardWindowsList.Add(frmDebugWindow);

  with frmDebugWindow do
    begin
      Show;
      UpdateDebugWindow('');
    end;
end;
{$else}
procedure TfrmPCodeDebugger.DashBoard1Click(Sender: TObject);
begin
end;
{$EndIf DashBoard}

procedure TfrmPCodeDebugger.sgBreakPointsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  GridDrawCell(sgBreakPoints, fDisabledBreaks, ACol, ARow, Rect);
end;


procedure TfrmPCodeDebugger.DebuggerDatabases1Click(Sender: TObject);
begin
  FreeAndNil(fFrmDebuggerDatabasesList);
  fFrmDebuggerDatabasesList := TfrmDebuggerDatabasesList.Create(self, self);
  try
    with fFrmDebuggerDatabasesList as TfrmDebuggerDatabasesList do
      begin
        if ShowModal = mrOK then
          begin
            fDatabaseSettings.SaveToFile(fDataBaseSettingsFileName);
            Update_StatusFmt('DatabaseSettings File %s was saved', [fDataBaseSettingsFileName], clYellow);
          end;
      end;
  finally
    FreeAndNil(fFrmDebuggerDatabasesList);
  end;
end;


function TfrmPCodeDebugger.GetCallHistoryOnly: boolean;
begin
  result := cbCallHistoryOnly.Checked;
end;

procedure TfrmPCodeDebugger.SetCallHistoryOnly(const Value: boolean);
begin
  cbCallHistoryOnly.Checked := Value;
end;

procedure TfrmPCodeDebugger.CatalogDebuggerDatabasesClick(Sender: TObject);
begin
   if not Assigned(frmCatalog) then
     frmCatalog := TfrmCatalog.Create(self, DATABASESettings);
   frmCatalog.Show;
end;

procedure TfrmPCodeDebugger.LoadForm;
begin
  if not Assigned(frmBuildDebugDB) then
    frmBuildDebugDB := TfrmBuildDebugDB.Create(self, DEBUGGERSettings);
end;


procedure TfrmPCodeDebugger.ListingUtilities1Click(Sender: TObject);
begin
  LoadForm;
  frmBuildDebugDB.ShowModal;
end;

procedure TfrmPCodeDebugger.ScanCodeFilesandUpdateDB1Click(Sender: TObject);
begin
  FreeAndNil(frmBuildDebugDB);
  frmBuildDebugDB := TfrmBuildDebugDB.Create2(self, DEBUGGERSettings);
  frmBuildDebugDB.ScanCodeFileandUpdateDB;
  FreeAndNil(frmBuildDebugDB);
end;

end.


