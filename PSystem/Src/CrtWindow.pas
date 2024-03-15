{$Define LogCalls}
// REMINDER: The unsucessful attempt to clean this code up is saved in
//           F:\NDAS-I\d7\Projects\pSystem\Src\Saved\PSysWindow.pas-20211211.pas
unit CrtWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, {UCSDGlob,} MyUtils, CRTUnit, Menus{, Interp_Const};

const
  BUFFER_LEN = 255;
  CR         = #13;
  BS         = #8;
  BELL       = #7;
  ESCAPE     = #27;
  DC1        = #17;
  DELETE_KEY = #127;
  DLE        = #16;

  DEFMAXCOLS = 80;
  DEFMAXROWS = 25;
  MAXMAXROWS = 200;

  MASK_BITS    = 4;
  BUFFERLEN    = 1 SHL MASK_BITS;       // 16 bytes
  MOD_MASK     = (1 SHL MASK_BITS) - 1; // $F;

type
  TOnKeyDown  = procedure {OnKeyDown}(Sender: TObject; var Key: Word; Shift: TShiftState) of object;
  TOnKeyPress = procedure {OnKeyPress}(Sender: TObject; var Key: Char) of object;
  TOnKeyUp    = procedure {OnKeyUp}(Sender: TObject; var Key: Word; Shift: TShiftState) of object;
//TWindowStatusProc = procedure {OnWindowChanged}() of object;
  TBreakKeyPressedEvent = procedure {OnBreakKeyPressed} () of object;

  EBREAKKEY       = class(Exception);

  TfrmCrtWindow = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    QuickPrint1: TMenuItem;
    procedure FormPaint(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Print1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//  procedure DebugLogFile1Click(Sender: TObject);
    procedure QuickPrint1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    fDebugEnabled: boolean;
    fEscapeString: string[10];

    fInputCount, fOutPutCount: longint;
    fCircularBuffer: Packed array[0..BUFFERLEN-1] of char;

    fLastKey     : char;
    fIdx         : integer;
    fOnKeyDown   : TOnKeyDown;
    fOnKeyPress  : TOnKeyPress;
    fOnKeyUp     : TOnKeyUp;
    fLineBuffer  : packed array[1..BUFFER_LEN] of char;
//  fOnWindowChanged: TWindowStatusProc;
    fCheckBreak  : boolean;
    fOnBreakKeyPressed: TBreakKeyPressedEvent;

    function GetCol: word;
    function GetRow: word;
    function GetMaxCols: integer;
    function GetMaxRows: word;
    function GetFontSize: integer;
    procedure SetFontSize(const Value: integer);
    function GetFontName: string;
    procedure SetFontName(const Value: string);
    function GetWinHeight: integer;
    function GetWinWidth: integer;
    procedure SetWinHeight(const Value: integer);
    procedure SetWinWidth(const Value: integer);
    procedure GetCurrentXY(var x, y: integer);
    procedure Unimplemented;
    procedure DelLine;
    function GetScreenHeight: integer;
    procedure SetScreenHeight(const Value: integer);
    function GetScreenWidth: integer;
    procedure SetScreenWidth(const Value: integer);
    function ReadKey0: char;
    procedure Wait;
    function PutIntoBuffer(TheCh: char): boolean;
    function TakeFromBuffer(var ch: char): boolean;
    procedure InsertLine(aRow: integer);
    procedure WriteBare(const Msg: string);
    function GetCRTInfo: TCRTInfo;
    function GetKeyInfo: TCRTInfo;
    function GetDebugEnabled: boolean;
    procedure SetDebugEnabled(const Value: boolean);
  protected
    fCRTInfo     : TCRTInfo;
    fKeyInfo     : TCRTInfo;
    fCol         : word;   // 0..fMaxCols-1
    fRow         : word;   // 0..fMaxRows-1
    fScreenBuf   : array {0..MAXROWS-1} of string;
    fTimer       : THandle;
    fTimerOpen   : boolean;
    fOnSaveSettings: TNotifyEvent;

    procedure SetOnSaveSettings(const Value: TNotifyEvent); virtual;
    function GetOnSaveSettings: TNotifyEvent; virtual;
    function DefaultCRTInfo: TCrtInfo; virtual;
    function DefaultKeyInfo: TCrtInfo; virtual;

    procedure PutPrefixedKey(var Key: word; CrtFuncs: TCrtFuncs); virtual;
    procedure PutSimple(ch: char); overload; virtual;
    procedure PrintWindow(EditIt: boolean); virtual;
    procedure SetCol(const Value: word); virtual;
    procedure SetRow(const Value: word); virtual;
    procedure SetMaxCols(const Value: integer); virtual;
    procedure SetMaxRows(const Value: word); virtual;
    procedure WMGetDlgCode(Var M: TWMGetDlgCode); message wm_getdlgcode;
//  procedure SetFunctionPrefixes(var CrtInfo: TCrtInfo; LeadIn, Low, High: TCRTFuncs); virtual;
  public
    { Public declarations }

{$IfDef LogCalls}
    fDebugFile   : text;
    fLogFilePath : string;
    fCallNumber  : integer;
    fDo32        : boolean;
{$endIf}
    procedure CancelTimer; virtual;
    function  CanCloseTheWindow: boolean;
    procedure ClrLine(aRow: integer); virtual;
    procedure CRTInfoChanged(var CRTInfo: TCrtInfo); virtual;
    procedure KeyInfoChanged(var CRTInfo: TCrtInfo); virtual;
    procedure PressAnyKey; virtual;
    procedure PutPrefixed(CRTFunct: TCRTFuncs); virtual;
    procedure WriteLn(Msg: string); overload; virtual;
    procedure WriteLn(N: integer);  overload; virtual;
    procedure WriteLn(Args: array of const); overload; virtual;
    procedure WriteLn; overload; virtual;

    function ReadKey: char;

    procedure Write(Msg: string); overload; virtual;
    procedure Write(Args: array of const); overload; virtual;
    procedure Write(ch: char); overload; virtual;

    procedure GoToXy(aCol, aRow: word); virtual;
    procedure ClrScreen; virtual;
    procedure ScrollPage(Lines: word); virtual;

    Constructor Create( aOwner: TComponent;
                        Heading: string;
                        aTop: integer;
                        aLeft: integer;
//                      aVersionNr: TVersionNr = vn_Unknown;
                        aMaxRows: integer = DEFMAXROWS;
                        aMaxCols: integer = DEFMAXCOLS); reintroduce;
    Destructor Destroy; override;
    Procedure ReadLn; overload;
    Procedure ReadLn(var Line: string); overload;

    procedure ClrEol;
    procedure ClrScr; virtual;
    function  WhereX: integer;
    function  WhereY: integer;
    Procedure CursorHome;
    Procedure ClearEOL;
    Procedure ClearEOP;
    Procedure CursorLeft;
    Procedure CursorDown;
    Procedure CursorUp;
    Procedure CursorRight;
    Procedure GetKey(var ch:char; NoEcho: boolean);
    function InputBufferAvailable: integer;
    procedure page(var f);
    procedure UcsdGotoXY(x,y:integer);
    function  KeyPressed: boolean;
    procedure UnitClear;

    property DebugEnabled : boolean
             read GetDebugEnabled
             write SetDebugEnabled;
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
    property Col: word
             read GetCol
             write SetCol;
    property Row: word
             read GetRow
             write SetRow;
    property MaxCols: integer
             read GetMaxCols
             write SetMaxCols;
    property MaxRows: word
             read GetMaxRows
             write SetMaxRows;
    property FontSize: integer
             read GetFontSize
             Write SetFontSize;
    property FontName: string
             read GetFontName
             write SetFontName;
    property WinWidth: integer
             read GetWinWidth
             write SetWinWidth;
    property WinHeight: integer
             read GetWinHeight
             write SetWinHeight;
    property CheckBreak: boolean
             read fCheckBreak
             write fCheckBreak;
    property ScreenHeight: integer
             read GetScreenHeight
             write SetScreenHeight;
    property ScreenWidth: integer
             read GetScreenWidth
             write SetScreenWidth;
    property CRTInfo: TCRTInfo
             read GetCRTInfo
             write fCRTInfo;
    property KeyInfo: TCRTInfo
             read GetKeyInfo
             write fKeyInfo;
    property OnSaveSettings: TNotifyEvent
             read GetOnSaveSettings
             write SetOnSaveSettings;
  end;

implementation

{$R *.dfm}

uses
  Math, FilerSettingsUnit, WindowsList, {pSysExceptions,}StStrL, ClipBrd,
  Misc, FileNames;

procedure TfrmCrtWindow.PressAnyKey;
var
  OldRow, OldCol: integer;
begin
  WriteLn;
  OldRow := Row; OldCol := Col;
  Write('Press any key to continue');
  ReadKey;
  GotoXY(OldCol, OldRow);
end;

procedure TfrmCrtWindow.Write(Args: array of const);
var
  i: integer;
  Temp: string;
begin
  Temp := '';
  for i := 0 to Length(Args)-1 do
    with Args[i] do
      case vtype of
        vtInteger:    temp := temp + IntToStr(VInteger);
        vtBoolean:    temp := temp + BoolToStr(VBoolean);
        vtChar:       temp := temp + VChar;
        vtExtended:   temp := temp + FloatToStr(VExtended^);

        vtString:     temp := temp + VString^;
        vtPChar:      temp := temp + VPChar;
        vtObject:     temp := temp + VObject.ClassName;
        vtClass:      temp := temp + VClass.ClassName;
        vtAnsiString: temp := temp + string(VAnsiString);
        vtCurrency:   temp := temp + CurrToStr(VCurrency^);
        vtVariant:    temp := temp + string(VVariant^);
        vtInt64:      temp := temp + IntToStr(VInt64^);
    end;
  Write(temp);
end;

{ TfrmPSysWindow }

constructor TfrmCrtWindow.Create( aOwner: TComponent;
                                    Heading: string;
                                    aTop: integer;
                                    aLeft: integer;
                                    aMaxRows: integer = DEFMAXROWS;
                                    aMaxCols: integer = DEFMAXCOLS);
begin
  inherited Create(aOwner);
//fCrtInfo    := DefaultCrtInfo;
//fKeyInfo    := DefaultKeyInfo;

  Caption     := Heading;
  fIdx        := 0;
  Top         := aTop;
  Left        := aLeft;
  MaxCols     := aMaxCols;
  MaxRows     := aMaxRows;
  fCol        := 0;
  fRow        := 0;
  SetLength(fEscapeString, 0);
end;

(*
procedure TfrmCrtWindow.SetFunctionPrefixes(var CrtInfo: TCrtInfo; LeadIn, Low, High: TCRTFuncs);
  var
    cf: TCrtFuncs;

  procedure AddPrefix(cf: TCRTFuncs);
  begin { AddPrefix }
    with CRTInfo, CRTFuncInfo[cf] do
      if ch <> #0 then
        FunctionPrefixes := FunctionPrefixes + [ch];
  end;  { AddPrefix }

begin { SetFunctionPrefixes }
  with CRTInfo do
    begin
      PrefixChar := CRTFuncInfo[LeadIn].ch;
      FunctionPrefixes := [];
      AddPrefix(LeadIn);
      for cf := Low to High do
        if (PrefixChar <> CHR(0)) and
           (cf in [cf_EraseToEndOfScreen, cf_EraseToEndOfLine, cf_MoveCursorUp, cf_MoveCursorRight,
                   cf_MoveCursorDown, cf_MoveCursorLeft, cf_EraseScreen, cf_EraseLine, cf_MoveCursorHome,
                   cf_GotoXY]) and
           (CrtFuncInfo[cf].ch >= ' ') then
          begin
            CrtFuncInfo[cf].Pfxed := true;
          end;

      AddPrefix(cf_GotoXY);
    end;
end; { SetFunctionPrefixes }
*)


procedure TfrmCrtWindow.Write(ch: char);
var
  Msg: string;
begin
  Msg := ch;
  Write(Msg);
end;

procedure TfrmCrtWindow.GetCurrentXY(var x, y: integer);
var
  w, H: integer;
begin
  W  := Canvas.TextWidth('W');
  H  := Canvas.TextHeight('W');
  x  := Col * W;
  y  := Row * H;
end;

// Name:    WriteBare
// Purpose: Bare bones write:
//          No ctrl char permiitted
//          No escape char permitted
//          No positioning permitted (Col, Row must be set before)
//          Does not update Col, Row
procedure TfrmCrtWindow.WriteBare(Const Msg: string);
var
  i, Len: integer;
  X, Y: integer;
begin
  Len := Min(Length(Msg), MaxCols - fCol);
  for i := 1 to Len do fScreenBuf[Row, Col+i] := Msg[i];   // Save screen for possible refresh

  with Canvas do
    begin
      GetCurrentXY(X, Y);

      ExtTextOut(
        Handle,                 // handle of device context
        x,                      // x-coordinate of reference point
        y,                      // y-coordinate of reference point
        ETO_CLIPPED+ETO_OPAQUE, // text-output options
        nil,                    // optional clipping and/or opaqueing rectangle
        pchar(Msg),              // points to string
        Len,       	            // number of characters to display
        nil                     // address of array of intercharacter spacing values
      );
    end;

  Application.ProcessMessages;  // 7/6/2019
end;


procedure TfrmCrtWindow.Write(Msg: string);
var
  S2: string;
  cp: integer;
  x, y: integer;
  Len: integer;
  CRPending, WasHandled, WasFound: boolean;
  FuncCode: TCrtFuncs;

  // NAME:    HandleGotoXY
  // Entry:   CP should index the flag character
  procedure HandleGoToXY;

    procedure CheckFor(ch: char);
    begin
      if Msg[CP] <> ch then
        raise Exception.CreateFmt('Unexpected character in GOTOXY string "%s"', [ch]);
    end;

    function GetVal: integer;
    begin
      result := 0;
      while Msg[CP] in DIGITS do
        begin
          result := (result * 10) + ord(Msg[CP]) - ord('0');
          CP := CP + 1;
        end;
    end;

  begin { HandleGoToXY }
//  with KeyInfo do
      begin
        with TermTypes[CrtInfo.TermType] do
          begin
            if Length(Msg) >= Minc then
              begin
                case CrtInfo.TermType of
                  tt_VT52, tt_H19:
                    begin
                      Y  := Ord(Msg[CP+1]) - ord(' ');
                      X  := Ord(Msg[CP+2]) - ord(' ');
                      GotoXY(x, y);
                      CP  := CP + 2;
                    end;
                  tt_PeterMiller:
                    begin
                      X  := Ord(Msg[CP+1]) - ord(' ');
                      Y  := Ord(Msg[CP+2]) - ord(' ');
                      GotoXY(x, y);
                      CP  := CP + 2;
                    end;
                  tt_Soroc:
                    begin
                      X  := Ord(Msg[CP+1]) - ord(' ');
                      Y  := Ord(Msg[CP+2]) - ord(' ');
                      GotoXY(x, y);
                      CP  := CP + 2;
                    end;
                  tt_Hazeltine:
                    begin
                      CP       := CP + 1;  // index to the ^Q
                      CheckFor(#17 {^Q});
                      X        := Ord(Msg[CP+1]) - ord(' ');
                      Y        := Ord(Msg[CP+2]) - ord(' ');
                      GotoXY(x, y);
                      CP  := CP + 2;
                    end;
                  tt_ADM:
                    begin
                      CP := CP + 1;
                      CheckFor(#61);             // check for the "="
                      X        := Ord(Msg[CP+1]) - ord(' ');
                      Y        := Ord(Msg[CP+2]) - ord(' ');
                    end;
                  tt_VT100, tt_ANSI:
                    begin
                      y := GetVal + 1;  // read the Y coordinate
                      CheckFor(';');
                      CP := CP + 1;     // skip over the ";"
                      x := GetVal + 1;  // read the X coordinate
                      CheckFor('H');
                      CP := CP + 1;
                    end;
                  else
                    begin
                      raise Exception.CreateFmt('Unimplemented GOTOXY for %s terminal = %s', [Name, Msg]);
                    end;
                end;  { case }
{$IfDef LogCalls}
                if DebugEnabled then
                  System.Write(fDebugFile, 'GotoXY(', X, ',', Y, ')');
{$endIf}
              end
            else
              begin
                fEscapeString := fEscapeString + Msg;  // save what we have so far
                Msg           := ''; // nothing left to process this time
              end
          end;
      end;
  end;  { HandleGoToXY }

  // Name     : HandleCrtFunc
  // Purpose  : perform the function indicated by FuncCode
  // On entry : CP should index the flag character
  // On exit  : CP should index the last character of the sequence (might not have changed from entry)
  procedure HandleCRTFunc(FuncCode: TCRTFuncs{; ch: char});
  begin
{$IfDef LogCalls}
        if DebugEnabled then
          begin
            System.WriteLn(fDebugFile);
            case FuncCode of
              cf_MoveCursorHome: { home }
                System.Write(fDebugFile, '<home>');
              cf_EraseToEndOfScreen: { erase_to_eos }
                System.Write(fDebugFile, '<ClearEOP>');
              cf_EraseToEndOfLine: { erase to eol }
                System.Write(fDebugFile, '<ClearEOL>');
              cf_EraseLine: { clear line }
                System.Write(fDebugFile, '<ClrLine(', Row, ')>');
              cf_EraseScreen: { clear screen }
                System.Write(fDebugFile, '<ClrScreen>');
              cf_MoveCursorUp: { up 1 line }
                System.Write(fDebugFile, '<Row := Row - 1>');
              cf_MoveCursorDown: { down 1 line }
                System.Write(fDebugFile, '<Row := Row + 1>');
              cf_MoveCursorRight: { move right 1 char }
                System.Write(fDebugFile, '<Col := Col + 1>');
              cf_MoveCursorLeft: { move left 1 char }
                System.Write(fDebugFile, '<Col := Col - 1>');
              cf_InsertLine: { Insert Line }
                System.Write(fDebugFile, '<InertLine(', Row, ')>');
(*
              kf_BackSpace: { backspace }
                System.Write(fDebugFile, '<BackSpace>');
*)
(*
              else
                System.Write(fDebugFile, 'Unknown escape code #', Ord(FuncCode));
*)
            end;
          end;
{$EndIf}
    if FuncCode <> cf_Unknown then
      case FuncCode of
        cf_MoveCursorHome: { home }
          GotoXY(0, 0);

        cf_EraseToEndOfScreen: { erase_to_eos }
          ClearEOP;

        cf_EraseToEndOfLine: { erase to eol }
          ClearEOL;

        cf_EraseLine: { clear line }
          ClrLine(Row);

        cf_EraseScreen: { clear screen }
          ClrScreen;

        cf_MoveCursorUp: { up 1 line }
          Row := Row - 1;

        cf_MoveCursorDown: { down 1 line }
          Row := Row + 1;

        cf_MoveCursorLeft: { move left 1 char }
          Col := Col - 1;

        cf_InsertLine: { Insert Line }
          InsertLine(Row);

//      kf_BackSpace: { backspace }
//        begin
//          Col := Col - 1;
//          Write(' ');
//          Col := Col - 1;
//        end;

        cf_MoveCursorRight: { right cursor }
          Col := Col + 1;

        cf_GotoXY: { GotoXY }
          HandleGoToXY;

        else
          begin
            Write(CrtInfo.CRTFuncInfo[FuncCode].ch);  // Just write the char
          end;
      end;
  end;

  // Assumes that CP has the index of the actual function char
  // and that we have already determined what the function code is.

  // At exit, CP should index the character AFTER the sequence and
  // fEscapeSequence should contain everything up to and including the character
  procedure HandleEscapeSequence(FuncCode: TCrtFuncs);
  begin { HandleEscapeSequence }
    // Is a prefix character required?
    if FuncCode <> cf_GotoXY then
      HandleCrtFunc(FuncCode)    // assume that we have all that is needed
    else
      if Length(Msg) >= TermTypes[CRTInfo.TermType].MinC then  // It MUST be a GOTOXY. Further processing is required.
        begin
          HandleCrtFunc(cf_GotoXY);     // handle the GOTOXY
        end
      else  // We don't yet have the whole sequence. Come back later.
        begin
//        fEscapeString := Copy(Msg, 1, CP);
          CP := CP + 1;
          fEscapeString := Msg;
        end;
    Msg := Copy(Msg, CP+1, MAXINT); // everything after the escape sequence
  end;  { HandleEscapeSequence }

  function CopyTail(const Msg: string): string;
  begin
    if cp <= Length(Msg) then
      result    := Copy(Msg, CP, MAXINT) // everything after the CR
    else
      result    := '';
  end;

  procedure HandleBefore;
  begin
    S2 := Copy(Msg, 1, CP-1);  // everything preceding the char
    if Length(S2) > 0 then
      Write(S2)
  end;

  function IsStartOfEscapeSequence: TCrtFuncs;
  var
    OK: boolean;
  begin { IsStartOfEscapeSequence }
    result := cf_Unknown;
    with CrtInfo do
      begin
        OK := Msg[CP] in FunctionPrefixes;
        if OK then
          begin
            if Msg[CP] = PrefixChar then
              begin
                if (Length(Msg) >= 2) then
                  begin
                    CP := CP + 1;    // index to the flag character
                    result := CharToCRTFunc(Msg[CP]);
                  end
                else
                  begin
                    fEscapeString := fEscapeString + Msg;  // save what we have so far
                    Msg           := ''; // nothing left to process this time
                  end;
              end
            else
              result := CharToCRTFunc(Msg[CP]);
          end
        else
          if Msg[CP] in CRTInfo.GoToXYPrefixChar then
            result := cf_GotoXY;
      end
  end;  { IsStartOfEscapeSequence }

{$IfDef LogCalls}
  procedure WriteDebugInfo(const Msg: string);
  var
    i: integer;
  begin { WriteDebugInfo }
    inc(fCallNumber);
    System.Write(fDebugFile, 'Call number ', fCallNumber, ': ');
    for i := 1 to length(Msg) do
      if Msg[i] = ' ' then
        if fDo32 then
          System.Write(fDebugFile, '#32 ')
        else
          System.Write(fDebugFile, ' ')
      else
        if (Msg[i] < ' ') or (Msg[i] > '~') then
          System.Write(fDebugFile, '#', ord(Msg[i]), ' ')
        else
          System.Write(fDebugFile, Msg[i]);
    System.Writeln(fDebugFile);
  end;  { WriteDebugInfo }
{$EndIf}

begin { TfrmPSysWindow.Write }
  with Canvas do
    begin
      Font.Size := FontSize;

      repeat
        CRPending := false;
        if fRow >= MaxRows then
          begin
            ScrollPage(1);
            fRow := MaxRows - 1;
          end;
                        
        if Length(fEscapeString) > 0 then  // we are already in an escape sequence.
                                           // insert the saved characters at the front
          begin
            Insert(fEscapeString, Msg, 1);
            fEscapeString := '';
          end;

        CP      := FindAnyOf(Msg, [CR, LF, FF, BELL, DLE, BS, #0] +
                             CrtInfo.FunctionPrefixes +
                             CrtInfo.GoToXYPrefixChar); // look for special characters

        WasFound := (CP > 0) and (cp <= (MaxCols - fCol));

        WasHandled  := false;

        if WasFound then                         // We found a special character
          begin
            FuncCode := IsStartOfEscapeSequence;
            if FuncCode <> cf_Unknown then      // and it is one of the MiscInfo special characters
              begin
                HandleEscapeSequence(FuncCode);
                WasHandled := true;
              end
            else
              if Length(Msg) >= 1 then
                WasFound  := Msg[CP] in [CR, LF, FF, BELL, DLE, BS, #0]   // This might have been a false positive
              else
                WasFound  := false;
          end;

        if WasFound and (not WasHandled) then   // We found a special character
          begin
            case Msg[CP] of
              CR:
                if (CP <= (MaxCols - fCol)) then
                  begin
                    S2     := Copy(Msg, 1, CP-1);  // everything preceding the CR
                    CRPending := true;
                    CP     := CP + 1;
                    Msg    := CopyTail(Msg);
                  end;
              LF:
                begin
                  S2     := Copy(Msg, 1, CP-1);  // everything preceding the LF
                  Row    := Row + 1;
                  CP     := CP + 1;
                  Msg    := CopyTail(Msg);
                end;
              BELL:
                begin
                  S2     := Copy(Msg, 1, CP-1);    // everything preceding the bell
                  CP     := CP + 1;
                  Msg    := CopyTail(Msg);
//                SysUtils.Beep;   // This gets to be very annoying
                end;
              DLE:
                begin
                  if Length(Msg) >= 2 then
                    begin
                      Len    := ord(Msg[CP+1]) - Ord(' ');
                      S2     := Copy(Msg, 1, CP-1) + PADR('', Len);  // everything preceding the DLE plus fill
                      CP     := CP + 2;
                      Msg    := CopyTail(Msg);
                    end
                  else // Don't have enough char to process a DLE right now
                    begin
                      S2            := '';
                      fEscapeString := Msg;
                      Msg           := '';
                    end;
                end;
              BS:  // backspace
                begin
                  HandleBefore;
                  Msg := Copy(Msg, CP+1, MAXINT); // handle stuff after the BS
                  S2  := Msg;
                  if Col > 0 then        // there is already something on this line
                    begin
                      Col := Col - 1;
                      Write (' ');       // blank out the previous char
                      Col := Col - 1;
                      S2  := '';         // force next loop
                    end
                end;
              FF:  // form feed
                begin
                  S2     := Copy(Msg, 1, CP-1);    // everything preceding the form feed
                  CP     := CP + 1;
                  Msg    := CopyTail(Msg);
                  ClrScreen;   // treat it as a clear screen
                end;
              #0: // null
                begin
                  HandleBefore;
                  Msg := Copy(Msg, CP+1, MAXINT); // handle stuff after the #0
                  while (Length(Msg) > 0) and (Msg[1] = #0) do
                    Delete(Msg, 1, 1);      // ignore the nulls
                end;
              else
                begin  // prefixed items
                  Assert(false);  // I don't think that this branch should ever be taken.
                                  // If it is. Further thought is required.
                end
            end
          end
        else
          begin
            Len := Min(Length(Msg), MaxCols - fCol);
            if Len > (MaxCols - fCol) then
              begin
                S2  := Copy(Msg, 1, Len);
                Msg := Copy(Msg, Len+1, MAXINT);
              end
            else
              begin
                S2  := Msg;
                Msg := '';
              end;
          end;

        if Length(S2) > 0 then
          begin
{$IfDef LogCalls}
            if DebugEnabled then
              System.Write(fDebugFile, S2);
{$EndIf}
            WriteBare(S2);

            Col := Col + Length(S2);
            if Col >= MaxCols then  // was Col > fMaxCols
              CRPending := true;
          end;

        if CRPending then
          begin
            fRow := fRow + 1;
            Col := 0;
          end;
      until Msg = '';
    end;
end;  { TfrmPSysWindow.Write }

procedure TfrmCrtWindow.WriteLn;
begin
  Row := Row + 1;
  Col := 0;
end;

procedure TfrmCrtWindow.WriteLn(Msg: string);
begin
  Write(Msg);
  WriteLn;
end;

procedure TfrmCrtWindow.WriteLn(N: integer);
begin
  WriteLn(IntToStr(N));
end;

procedure TfrmCrtWindow.WriteLn(Args: array of const);
begin
  Write(Args);
  WriteLn;
end;

function TfrmCrtWindow.ReadKey: char;
begin
  if not TakeFromBuffer(result) then
    result := ReadKey0;
end;

procedure TfrmCrtWindow.Wait;
var
  Ret: DWORD;
  WaitTime: TLargeInteger;
begin
  fTimer   := CreateWaitableTimer(nil, TRUE, nil);
  fTimerOpen := true;
  // sleep for 0.1 seconds without freezing
  WaitTime := -1000000; // 0.1 seconds
  SetWaitableTimer(fTimer, WaitTime, 0, nil, nil, FALSE);
  repeat
    // (WAIT_OBJECT_0+0) is returned when the timer is signaled.
    // (WAIT_OBJECT_0+1) is returned when a message is in the queue.
    Ret := MsgWaitForMultipleObjects(1, fTimer, FALSE, INFINITE, QS_KEY {QS_ALLINPUT});
    if (Ret <> (WAIT_OBJECT_0+1)) and (fLastKey <> #0) then
      Break;
    Application.ProcessMessages;
  until False;
  if Ret <> WAIT_OBJECT_0 then
    CancelWaitableTimer(fTimer);
  fTimerOpen := false;
end;


function TfrmCrtWindow.ReadKey0: char;
var
  X, Y: integer;
begin
  Application.ProcessMessages;  // finish anything already in progress
  fLastKey := #0;
  CreateCaret(Handle, 0, 2, 15);
  GetCurrentXY(X, Y);
  SetCaretPos(X, Y);
  ShowCaret(Handle);

  Wait;

  DestroyCaret;
  TakeFromBuffer(result);
  fLastKey := #0;
end;

procedure TfrmCrtWindow.ReadLn;
var
  Line: string;
begin
  ReadLn(Line);
end;

procedure TfrmCrtWindow.ReadLn(var Line: string);
var
  ch: char;
begin
  repeat
    ch := ReadKey;
    if ch <> BS then
      begin
        Write(ch);
        Inc(fIdx);
        fLineBuffer[fIdx] := ch;
      end
    else if fIdx > 0 then
      begin
        GotoXY(col-1, Row);
        Write(' ');
        GotoXY(Col-1, Row);
        Dec(fIdx);
      end;
  until ch = CR;
  Line := Copy(fLineBuffer, 1, fIdx-1);
  fIdx := 0;
end;

function TfrmCrtWindow.GetCol: word;
begin
  result := fcol;
end;

function TfrmCrtWindow.GetRow: word;
begin
  result := fRow;
end;

procedure TfrmCrtWindow.SetCol(const Value: word);
begin
  fCol := Value;
end;

procedure TfrmCrtWindow.SetRow(const Value: word);
begin
  if Value >= MaxRows then
    begin
      ScrollPage(1);
      fRow := MaxRows - 1;
    end
  else
    fRow := Value;
end;
                                                 
function TfrmCrtWindow.GetMaxCols: integer;
begin
  result := CrtInfo.TheMaxCols;
end;

function TfrmCrtWindow.GetMaxRows: word;
begin
  result := fCrtInfo.TheMaxRows;
end;

procedure TfrmCrtWindow.ClrLine(aRow: integer);
begin
  FillChar(fScreenBuf[aRow][1], MaxCols, ' ');
  GotoXY(0, aRow);
  WriteBare(fScreenBuf[aRow]);
end;


procedure TfrmCrtWindow.SetMaxCols(const Value: integer);
var
  r, c: integer;
  OldMaxCols: integer;
begin
  if Value <> CRTInfo.TheMaxCols then
    begin
      ClientWidth        := Canvas.TextWidth('W') * Value;
      OldMaxCols         := MaxCols;
      CRTInfo.TheMaxCols := Value;
      SetLength(fScreenBuf, CRTInfo.TheMaxRows);
      for r := 0 to MaxRows-1 do
        begin
          SetLength(fScreenBuf[r], CrtInfo.TheMaxCols);
          for c := OldMaxCols+1 to CRTInfo.TheMaxCols do
            fScreenBuf[r, c] := ' ';
        end;
    end;
end;

procedure TfrmCrtWindow.SetMaxRows(const Value: word);
var
  r: integer;
  OldMaxRows: integer;
  SaveCol, SaveRow: word;
begin
  if (Value <> Length(fScreenBuf)) and (Value <= MAXMAXROWS) then
    begin
      SaveCol := Col;
      SaveRow := Row;
      ClientHeight{Height}     := Canvas.TextHeight('W') * Value;
      OldMaxRows := Length(fScreenBuf);
      CrtInfo.TheMaxRows    := Value;
      SetLength(fScreenBuf, MaxRows);

      for r := 0 to MaxRows-1 do SetLength(fScreenBuf[r], MaxCols);

      for r := OldMaxRows to MaxRows-1 do ClrLine(r);
      if SaveCol > MaxCols then
        SaveCol := MaxCols;
      if SaveRow > MaxRows then
        SaveRow := MaxRows;
      GotoXY(SaveCol, SaveRow);
    end;
end;

procedure TfrmCrtWindow.GoToXY(aCol, aRow: word);
begin
  Col := aCol;
  Row := aRow;
end;

function TfrmCrtWindow.GetFontSize: integer;
begin
  result := Canvas.Font.Size;
end;

procedure TfrmCrtWindow.SetFontSize(const Value: integer);
begin
  Canvas.Font.Size := Value;
end;

function TfrmCrtWindow.GetFontName: string;
begin
  Result := Canvas.Font.Name;
end;

procedure TfrmCrtWindow.SetFontName(const Value: string);
begin
  Canvas.Font.Name := Value;
end;

function TfrmCrtWindow.GetWinHeight: integer;
begin
  result := Height;
end;

function TfrmCrtWindow.GetWinWidth: integer;
begin
  result := Width;
end;

procedure TfrmCrtWindow.SetWinHeight(const Value: integer);
begin
  Height := Value;
end;

procedure TfrmCrtWindow.SetWinWidth(const Value: integer);
begin
  Width := Value;
end;

procedure TfrmCrtWindow.ClrScreen;
var
  r: integer;
begin
  for r := MaxRows-1 downto 0 do
    ClrLine(r);
  Row := 0;
  Col := 0;
end;

procedure TfrmCrtWindow.InsertLine(aRow: integer);
var
  r: integer;
//SaveCol, SaveRow: integer;
begin
//SaveRow := Row;
//SaveCol := Col;

  for r := MaxRows-2 downto aRow-1 do
    fScreenBuf[r+1] := fScreenBuf[r];

  ClrLine(aRow);

  for r := aRow to MaxRows-1 do
    begin
      Row := r;
      Col := 0;
      WriteBare(fScreenBuf[r]);
    end;

//if SaveRow > 0 then
//  GotoXY(SaveCol, SaveRow-1);
end;

procedure TfrmCrtWindow.ScrollPage(Lines: word);
var
  r: integer;
  SaveRow, SaveCol: word;
begin
//fRepainting := true;
//try
    SaveRow := Row;
    SaveCol := Col;

    for r := Lines to MaxRows-Lines do fScreenBuf[r-Lines] := fScreenBuf[r];

    for r := MaxRows-Lines to MaxRows-1 do ClrLine(r);

    for r := 0 to MaxRows-1 do
      begin
        Row := r;
        Col := 0;
        WriteBare(fScreenBuf[r]);
      end;

    if SaveRow >= Lines then
      SaveRow := SaveRow - Lines
    else
      SaveRow := 0;

    GotoXY(SaveCol, SaveRow);
//finally
//  fRepainting := false;
//end;
end;

function TfrmCrtWindow.InputBufferAvailable: integer;
begin
  result := fInputCount - fOutputCount;
end;


function TfrmCrtWindow.TakeFromBuffer(var ch: char): boolean;
var
  OutputIdx: integer;
begin
  result := false;
  // Is there anything in the buffer?
  if (fInputCount > fOutputCount) then
    begin
      OutputIdx := fOutputCount and MOD_MASK;    // effectively: fOutputCount mod BUFFERLEN
      ch        := fCircularBuffer[OutputIdx];
      Inc(fOutputCount);
      result := true;
    end;
end;

function TfrmCrtWindow.PutIntoBuffer(TheCh: char): boolean;
var
  InputIdx: integer;
  ch: char;
begin
  result := false;
  ch     := KeyInfo.CRTFuncInfo[kf_KeyForBreak].Ch;
  if (TheCh = ch) and (Ch <> #0) then


    raise EBREAKKEY.Create('Break Key');

  // Is there room to put something into the buffer?
  if (fInputCount >= fOutputCount) and ((fInputCount - fOutputCount) < BUFFERLEN) then
    begin
      InputIdx := fInputCount and MOD_MASK;    // Effectively: fInputCount MOD BUFFERLEN
      fCircularBuffer[InputIdx] := TheCh;
      Inc(fInputCount);
      result := true;  // succeeded
    end;
end;

procedure TfrmCrtWindow.Unimplemented;
begin
  raise Exception.Create('Unimplemented');
end;

procedure TfrmCrtWindow.ClearEOL;
begin
  ClrEOL;
end;

procedure TfrmCrtWindow.ClearEOP;
var i, x,y:integer;
begin
  x := Col;
  y := Row;
  ClrEOL;
  for i := y+1 to MaxRows-1 do
    begin
      GotoXY(0,i);
      ClrEOL;
    end;
  GotoXY(x,y);
end;

procedure TfrmCrtWindow.ClrEol;
var
//SavedCol, SavedRow: integer;
  Temp: string;
begin
//SavedCol := Col;
//SavedRow := Row;
  Temp := Padr('', MAXCOLS-Col, ' ');
  WriteBare(Temp);
//GotoXY(SavedCol, SavedRow);
//Application.ProcessMessages;
end;

procedure TfrmCrtWindow.DelLine;
begin
  UnImplemented;
end;


procedure TfrmCrtWindow.CursorDown;
var x,y:integer;
begin
  x := WhereX; y:= WhereY;
  if y < ScreenHeight{25} then gotoxy(x,y+1);
  IF Y = ScreenHeight{25} then begin
    gotoxy(1,2); Delline;{force a scroll} {2=protect top line}
    gotoxy(x,y);
    end;
  Unimplemented;
end;

procedure TfrmCrtWindow.CursorHome;
begin
  gotoxy(0,0);
end;

procedure TfrmCrtWindow.CursorLeft;
var x,y:integer;
begin
  x := WhereX; y:= WhereY;
  if x > 1 then gotoxy(x-1,y)
  else begin
    if y > 1 then gotoxy(80,y-1); {should check terminal width}
    end;
  Unimplemented;
end;

procedure TfrmCrtWindow.CursorRight;
var x,y:integer;
begin
  x := WhereX; y:= WhereY;
  if x < 80 then gotoxy(x+1,y)
  else if y <ScreenHeight{25} then gotoxy(1,y+1);
  Unimplemented;
end;

procedure TfrmCrtWindow.CursorUp;
var x,y:integer;
begin
  x := WhereX; y:= WhereY;
  if y >1 then gotoxy(x,y-1);
  Unimplemented;
end;

procedure TfrmCrtWindow.GetKey(var ch: char; NoEcho: boolean); // NoEcho is currently ignored
begin
  ch := Readkey;
  if ch = #0 then
    ch := Readkey;
end;

function TfrmCrtWindow.KeyPressed: boolean;
begin
  Unimplemented;
  result := false;
end;

procedure TfrmCrtWindow.page(var f);
begin
  ClrScreen;
end;

function TfrmCrtWindow.GetScreenHeight: integer;
begin
  result := MaxRows;
end;

procedure TfrmCrtWindow.ucsdgotoxy(x, y: integer);
begin
  gotoxy(x,y);
end;

function TfrmCrtWindow.WhereX: integer;
begin
  result := Col;
end;

function TfrmCrtWindow.WhereY: integer;
begin
  result := row;
end;

procedure TfrmCrtWindow.ClrScr;
begin
  ClrScreen;
end;

procedure TfrmCrtWindow.SetScreenHeight(const Value: integer);
begin
  MaxRows := Value;
end;

function TfrmCrtWindow.GetScreenWidth: integer;
begin
  result := MaxCols;
end;

procedure TfrmCrtWindow.SetScreenWidth(const Value: integer);
begin
  MaxCols := Value;
end;

procedure TfrmCrtWindow.FormPaint(Sender: TObject);
var
  r: integer;
  SaveRow, SaveCol: word;
begin
  SaveRow := Row;
  SaveCol := Col;
  for r := 0 to MAXROWS-1 do
    begin
      GotoXY(0, r);
      WriteBare(fScreenBuf[r]);
    end;
  GotoXY(SaveCol, SaveRow);
end;

destructor TfrmCrtWindow.Destroy;
begin
  if Assigned(fCRTInfo) and Assigned(fOnSaveSettings) then
    fOnSaveSettings(self);

  FreeAndNil(fCRTInfo);
  FreeAndNil(fKeyInfo);
  inherited;
end;

procedure TfrmCrtWindow.CancelTimer;
begin
  try
//  if fTimerOpen then
    if fTimerOpen or (fTimer <> 0) then
      begin
        CancelWaitableTimer(fTimer);
//      CloseHandle(fTimer);
        fTimerOpen := false;
        fLastKey   := #$FF;   // try to break out of the Wait loop
      end;
  except
//  fTimer := 0;  { 6/18/2021 Does this even exist after the CloseHandle ? }
  end;
end;

procedure TfrmCrtWindow.PutSimple(ch: char);
begin
  if not PutIntoBuffer(ch) then
    SysUtils.Beep
  else
    fLastKey := ch;
end;

procedure TfrmCrtWindow.PutPrefixed(CRTFunct: TCRTFuncs);
var
  b1, b2: boolean;
begin
  with KeyInfo.CRTFuncInfo[CrtFunct] do
    begin
      b1 := true;
      if Pfxed then
        b1 := PutIntoBuffer(KeyInfo.PrefixChar);

      b2 := PutIntoBuffer(ch);
      if not (b1 and b2) then
        SysUtils.Beep;
    end;
end;

procedure TfrmCrtWindow.PutPrefixedKey(var Key: word; CrtFuncs: TCrtFuncs);
begin
  PutPrefixed(CrtFuncs);
  fLastKey := Chr(Key);
  Key      := 0;
end;

procedure TfrmCrtWindow.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  CH: CHAR;

  procedure PutSimpleKey(ch: char);
  begin
    PutSimple(ch);
    fLastKey := ch;
    Key := 0;
  end;

  procedure PutCtrlKey(ch: char);
  begin
//  Assert(ch in ['A'..'Z', 'a'..'z'])
    if ch in ['A'..'Z'] then
      PutSimpleKey(chr(ord(ch) - ord('A') + 1))
    else
      PutSimpleKey(chr(ord(ch) - ord('a') + 1))
  end;


begin { TfrmPSysWindow.FormKeyUp }
  try      // 5/3/2023
    case Key of
(*
      vk_Up:
        PutPrefixedKey(key, kf_KeyToMoveCursorUp);
      vk_Down:
        PutPrefixedKey(key, kf_KeyToMoveCursorDown);
      vk_Left:
        PutPrefixedKey(key, kf_KeyToMoveCursorLeft);
      vk_Right:
        PutPrefixedKey(key, kf_KeyToMoveCursorRight);
*)
      VK_BACK:
        {PutPrefixedKey(kf_Backspace);}
        Key := 0;  // THIS IS A KLUDGE! TRYING TO PREVENT DOUBLE PROCESSING ON BACKSPACE.
                   // Maybe rewrite everything to use WM_CHAR
      VK_ESCAPE:
        PutPrefixedKey(Key, kf_EditorEscapeKey);

      VK_DELETE:
        PutPrefixedKey(Key, kf_KeyToDeleteCharacter);
//      Key := 0;

      VK_TAB:
  //    PutSimple(TAB);  // 5/2/2023: commented out because TAB was getting duplicated.
        Key := 0;        //           added to be like VK_BACK?

      vk_Prior:
//      PutPrefixedKey(Key, kf_PageUp);
        Key := 0;

      vk_Next:
//      PutPrefixedKey(Key, kf_PageDown);
        Key := 0;

      else
        begin
          CH := chr(Key);
          if CH <= MAXKEY then
            begin
              if (ssCtrl in shift) and (ch in ['A'..'Z', 'a'..'z']) then
                PutCtrlKey(CH)
            end{
          else
            OutputDebugString(pchar(Format('Unknown virtual key code = %d (%4.4x)', [Key, Key])))};
        end;
    end;
  except
    if Assigned(fOnBreakKeyPressed) then
      fOnBreakKeyPressed();
  end;
end;  { TfrmPSysWindow.FormKeyUp }


procedure TfrmCrtWindow.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if not PutIntoBuffer(Key) then
    SysUtils.Beep
  else
    begin
      fLastKey := Key;
      Key := #0;
    end;
end;

procedure TfrmCrtWindow.UnitClear;
begin
  fInputCount  := 0;
  fOutputCount := 0;
end;

procedure TfrmCrtWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  CancelTimer;  // 12/22/2023
  Action := caFree;
end;

function TfrmCrtWindow.DefaultCRTInfo: TCrtInfo;
begin
  if not Assigned(fCrtInfo) then
    begin
      fCRTInfo := TCRTInfo.Create(LOW_CRT_FUNC, HIGH_CRT_FUNC);
      with CRTInfo do
        begin
          OnInfoChanged    := CrtInfoChanged;
//        StatusProc := TheStatusProc;  // Cannot write because we may already be in write

          Reset('pSysWindow defaults');

          TermType := tt_Unknown;
          LookForUnusedFuncs;
        end;
    end;
  result := fCrtInfo;
end;

function TfrmCrtWindow.DefaultKeyInfo: TCrtInfo;
begin
  if not Assigned(fKeyInfo) then  // default to VT52 key codes
    begin
      fKeyInfo := TCrtInfo.Create(LOW_KEY_FUNC, HIGH_KEY_FUNC{, fVersionNr});
      with fKeyInfo do
        begin
//        OnInfoChanged := KeyInfoChanged;

          with CRTFuncInfo[kf_LeadInFromKeyBoard] do
            begin ch := #27; Pfxed := false end;
          with CRTFuncInfo[kf_EditorEscapeKey] do
            begin ch := #24; Pfxed := true end;
          with CRTFuncInfo[kf_KeyToMoveCursorUp] do
            begin ch := 'A'; Pfxed := true end;
          with CRTFuncInfo[kf_KeyToMoveCursorDown] do
            begin ch := 'B'; Pfxed := true end;
          with CRTFuncInfo[kf_KeyToMoveCursorRight] do
            begin ch := 'C'; Pfxed := true end;
          with CRTFuncInfo[kf_KeyToMoveCursorLeft] do
            begin ch := 'D'; Pfxed := true end;
          with CRTFuncInfo[kf_EditorAcceptKey] do
            begin ch := #6 {^F}; Pfxed := true end;
        end;
    end;
  result := fKeyInfo;
end;

procedure TfrmCrtWindow.CrtInfoChanged(var CRTInfo: TCrtInfo);
begin
  with CRTInfo do
    if MaxRows <= MAXMAXROWS then
      MaxRows := TheMaxRows;
end;

procedure TfrmCrtWindow.PrintWindow(EditIt: boolean);
var
  r: integer;
  FilePath: string;
  f: TextFile;
begin
  FilePath := FilerSettings.PrinterLfn;
  if BrowseForFile('Print Screen', FilePath, TXT_EXT) then
    begin
      AssignFile(f, FilePath);
      Rewrite(f);
      try
        for r := 0 to  MAXROWS-1 DO
          system.Writeln(f, TrimRight(fScreenBuf[r]));
      finally
        CloseFile(f);
        if EditIt then
          EditTextFile(FilePath);
      end;
    end;
end;


procedure TfrmCrtWindow.Print1Click(Sender: TObject);
begin
  PrintWindow(true);
end;

procedure TfrmCrtWindow.Exit1Click(Sender: TObject);
begin
  Close;
end;

function TfrmCrtWindow.CanCloseTheWindow: boolean;
begin
  result := (not fTimerOpen);
end;


procedure TfrmCrtWindow.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := CanCloseTheWindow;
  if CanClose then
    begin
      if Assigned(fOnSaveSettings) then
        fOnSaveSettings(self);
    end
  else
    begin
      SysUtils.Beep;   // require Halt before allowing window to close
//    CanClose := Yes('System is still running. Halt anyway?'); // disapears immediately
    end;
end;

{ key codes }
procedure TfrmCrtWindow.WMGetDlgCode(var M :TWMGetDlgCode);
begin
	M.Result := DLGC_WantArrows or DLGC_WantChars or DLGC_WantAllKeys or DLGC_WantTab; 
end;



procedure TfrmCrtWindow.QuickPrint1Click(Sender: TObject);
var
  r: integer;
  FilePath: string;
  f: TextFile;
  FirstLine, FirstWord: string;
  WC, LineNr: integer;
begin
  LineNr := 0;
  WC     := 0;

  // Find the first non-blank line
  while WC = 0 do
    begin
      FirstLine := TrimRight(fScreenBuf[LineNr]);
      WC := WordCountL(FirstLine, DELIMS);
      if WC > 0 then
        FirstWord := ExtractWordL(1, FirstLine, DELIMS)
      else
        begin
          LineNr    := LineNr + 1;
          if LineNr >= MAXROWS then
            begin
              SysUtils.Beep;
              Exit;
            end;
        end;
    end;
  FilePath  := UniqueFileName(Format('%sQuickPrint-%s.txt', [FilerSettings.ReportsPath, FirstWord]));

  AssignFile(f, FilePath);
  Rewrite(f);
  try
    for r := 0 to  MAXROWS-1 DO
      system.Writeln(f, TrimRight(fScreenBuf[r]));
  finally
    CloseFile(f);
    Clipboard.AsText := FilePath;
    MessageFmt('Screen quick printed to %s (now in Clipboard)', [FilePath]);
  end;
end;

procedure TfrmCrtWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
(*  What, if anything, should this do for a CRT? *)
  if Key in [vk_Up, vk_Down, vk_Left, vk_Right, vk_Delete, vk_Prior, vk_Next] then
    begin
      case Key of
        vk_Up:
          PutPrefixedKey(Key, kf_KeyToMoveCursorUp);

        vk_Down:
          PutPrefixedKey(Key, kf_KeyToMoveCursorDown);

        vk_Left:
          PutPrefixedKey(Key, kf_KeyToMoveCursorLeft);

        vk_Right:
          begin
            if shift = [ssCtrl] then
              PutPrefixedKey(Key, kf_KeyToMoveToNextWord)
            else
              PutPrefixedKey(Key, kf_KeyToMoveCursorRight);
          end;

        vk_Delete:
          PutPrefixedKey(Key, kf_KeyToDeleteCharacter);

        vk_Prior:
          PutPrefixedKey(Key, kf_PageUp);

        vk_Next:
          PutPrefixedKey(Key, kf_PageDown);

        else
          Key := Key{nice place for a break};
      end;
    end;
end;

function TfrmCrtWindow.GetOnSaveSettings: TNotifyEvent;
begin
  result := fOnSaveSettings;
end;

procedure TfrmCrtWindow.SetOnSaveSettings(const Value: TNotifyEvent);
begin
  fOnSaveSettings := Value;
end;

function TfrmCrtWindow.GetCRTInfo: TCRTInfo;
begin
  if not Assigned(fCrtInfo) then
    fCrtInfo := DefaultCrtInfo;
  Result := fCRTInfo
end;

function TfrmCrtWindow.GetKeyInfo: TCRTInfo;
begin
  if not Assigned(fKeyInfo) then
    fKeyInfo := DefaultKeyInfo;
  result := fKeyInfo;
end;

procedure TfrmCrtWindow.KeyInfoChanged(var CRTInfo: TCrtInfo);
begin

end;

function TfrmCrtWindow.GetDebugEnabled: boolean;
begin
  result := fDebugEnabled;
end;

procedure TfrmCrtWindow.SetDebugEnabled(const Value: boolean);
begin
  case Value of
    true:
      if not fDebugEnabled then
        begin
          fLogFilePath := 'C:\Temp\pSysWindow.log';
          if BrowseForFile('Write debug log to', fLogFilePath, 'log') then
            begin
              AssignFile(fDebugFile, fLogFilePath);
              Rewrite(fDebugFile);
              fDebugEnabled := true;
              fCallNumber  := 0;
            end;
        end;
    false:
      if fDebugEnabled then
        begin
          CloseFile(fDebugFile);
          fDebugEnabled := false;
          EditTextFile(fLogFilePath);
        end;
  end;
end;

initialization
end.
