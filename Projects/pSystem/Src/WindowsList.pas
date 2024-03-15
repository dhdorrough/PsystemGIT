unit WindowsList;

interface

uses
  Classes, Forms;

const
  cPSYSTEM_WINDOW_NAME = 'p-System';
  cFILER_WINDOW_NAME = 'Filer';

type
  integer = SmallInt;

  TWindowsTypes = (wtUnknown, wtLocal, wtGlobal, wtIntermediateLocal, wtIntermediateGlobal,
                   wtPSysWindow, wtFiler, wtDashBoard, wtKeyShortCuts, wtDatabaseList,
                   wtForcedAddress);

  TWindowInfo = class(TCollectionItem)
  private
    fHeight: integer;
    fLeft: integer;
    fTop: integer;
    fWidth: integer;
    fName: string;
    fMonitorNum: integer;
    fLastDateTime: TDateTime;
    fSplitterPos: word;
  public
    procedure Assign(Source: TPersistent); override; // REMEMBER TO UPDATE THIS IF CHANGES ARE MADE
  published
    Destructor Destroy; override;
    property Top: integer
             read fTop
             write fTop;
    property Left: integer
             read fLeft
             write fLeft;
    property Height: integer
             read fHeight
             write fHeight;
    property Width: integer
             read fWidth
             write fWidth;
    property Name: string
             read fName
             write fName;
    property MonitorNum: integer
             read fMonitorNum
             write fMonitorNum
             default 0;
    property LastUpdate: TDateTime
             read fLastDateTime
             write fLastDateTime;
    property SplitterPos: word
             read fSplitterPos
             write fSplitterPos
             default 0;

    // REMEMBER TO UPDATE ASSIGN() IF CHANGES ARE MADE
  end;

  TWindowsList = class(TCollection)
  public
    procedure AddWindow(Form: TForm; const aName: string; aSplitterPos: integer);
    function  FindNamedWindow(aName: string): TWindowInfo;
    procedure LoadWindowInfo(Form: TForm; const aName: string; var SplitterPos: integer);
    procedure DeleteUnusedWindows;
    Destructor Destroy; override;
  end;

var

  {, , , ,
                   , , , }
  WindowsType: array [TWindowsTypes] of string = (
    {wtUnknown}            'Unknown',
    {wtLocal}              'LOCAL VARIABLES',
    {wtGlobal}             'GLOBAL VARIABLES',
    {wtIntermediateLocal}  'INTERMEDIATE LOCAL VARIABLES',
    {wtIntermediateGlobal} 'INTERMEDIATE GLOBAL VARIABLES',
    {wtPSysWindow}         cPSYSTEM_WINDOW_NAME,
    {wtFiler}              cFILER_WINDOW_NAME,
    {wt_DashBoard}         'DASH BOARD',
    {wtKeyShortCuts}       'KEY SHORT CUTS',
    {wtDatabaseList}       'Database List',
    {wtForcedAddress}      'Forced Base Address'
  );


implementation

uses
  SysUtils;

{ TWindowsList }

function TWindowsList.FindNamedWindow(aName: string): TWindowInfo;
var
  i: integer;
  aWindowInfo: TWindowInfo;
begin
  for i := 0 to Count-1 do
    begin
      aWindowInfo := Items[i] as TWindowInfo;
      if SameText(aWindowInfo.Name, aName) then
        begin
          result := Items[i] as TWindowInfo;
          exit;
        end;
    end;
  result := nil;
end;


procedure TWindowsList.AddWindow(Form: TForm; const aName: string; aSplitterPos: integer);
var
  aWindowInfo: TWindowInfo;
begin
  aWindowInfo := FindNamedWindow(aName);
  if not Assigned(aWindowInfo) then
    aWindowInfo := Add as TWindowInfo;

  with aWindowInfo do
    begin
      fHeight       := Form.Height;
      fLeft         := Form.Left;
      fTop          := Form.Top;
      fWidth        := Form.Width;
      fName         := aName;
      fSplitterPos  := aSplitterPos;
      fLastDateTime := Now;
      fMonitorNum   := Form.Monitor.MonitorNum;
    end;
end;

procedure TWindowsList.LoadWindowInfo(Form: TForm; const aName: string; var SplitterPos: integer);
var
  aWindowInfo: TWindowInfo;
begin
  aWindowInfo := FindNamedWindow(aName);           // Have we seen a window with this name before?
  if Assigned(aWindowInfo) then
    begin // Would be nice to give it a slightly different position if we already have one visible...
      Form.Height     := aWindowInfo.Height;
      Form.Width      := aWindowInfo.Width;
      Form.Left       := aWindowInfo.Left;
      Form.Top        := aWindowInfo.Top;
      SplitterPos     := aWindowInfo.SplitterPos;
      
      if Screen.MonitorCount > aWindowInfo.fMonitorNum then
        Form.MakeFullyVisible(Screen.Monitors[aWindowInfo.fMonitorNum])
      else
        Form.MakeFullyVisible(Screen.Monitors[0]);
    end;
end;

procedure TWindowsList.DeleteUnusedWindows;
const
  ONEMONTH = 30;
var
  i: integer;
begin
  for i := Count-1 downto 0 do
    with Items[i] as TWindowInfo do
      if (Now - fLastDateTime) > ONEMONTH then
        Delete(i);
end;

destructor TWindowsList.Destroy;
begin

  inherited;
end;

{ TWindowInfo }

procedure TWindowInfo.Assign(Source: TPersistent);
var
  Src: TWindowInfo;
begin
  Src           := Source as TWindowInfo;

  fHeight       := Src.fHeight;
  fLeft         := Src.fLeft;
  fTop          := Src.fTop;
  fWidth        := Src.fWidth;
  fName         := Src.fName;
  fMonitorNum   := Src.fMonitorNum;
  fSplitterPos  := Src.fSplitterPos;
  fLastDateTime := Src.fLastDateTime;
end;


destructor TWindowInfo.Destroy;
begin

  inherited;
end;

end.
