unit pSysDrivers;

interface

uses
  pSysWindow, Classes, MyUtils, StdCtrls, Forms, Interp_Const;

const
    MAXBUFSIZE = 8192;   // 8 kb

{$I BIOSCONST.INC}

type

  TBytes = packed array[0..65536] of byte;
  TChars = packed array[0..65536] of char;

  TProcCall = procedure {name} of object;

  TDriver = class(TObject)
  private
    fDispatchTo: TProcCall;
    fOwner: TObject;
    procedure UnImplemented(Msg: string; wait: boolean);
  protected
  public
    function Dispatcher(Request, BlockNr, Len: word; var Buffer; Control: word): TIORsltWD; virtual;
    function UnitClear: TIORsltWD; virtual;
    procedure UnitBusy; virtual;
    function UnitRead(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD; overload; virtual;
    function UnitRead(var Buffer; length: word; BlockNumber: word): TIORsltWD; overload; virtual;
    function UnitStatus(var Status_record; control: word): TIORsltWD; virtual;
    procedure UnitWait; virtual;
    function UnitWrite(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD; virtual;
    Constructor Create(aOwner: TObject; DispatchTo: TProcCall); virtual;
    Destructor Destroy; override;
    property DispatchTo: TProcCall
             read fDispatchTo
             write fDispatchTo;
    property Owner: TObject
             read fOwner;
  end;

  TCharacterDriver = class(TDriver)
   private
     fControl : word;
   protected
     ffrmPSysWindow: TfrmPSysWindow;
   public
     function Dispatcher(Request, BlockNr, Len: word; var Buffer; Control: word): TIORsltWD; override;
     function UnitClear: TIORsltWD; override;
     Constructor Create( aOwner: TObject;
                         DispatchTo: TProcCall;
                         aPSysWindow: TfrmPSysWindow;
                         Control: word); reintroduce;
     function UnitWrite(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD; override;
     procedure UnitBusy; override;
     function UnitRead(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD; override;
     function UnitRead(var Buffer; length: word; BlockNumber: word): TIORsltWD; override;
     function UnitStatus(var Status_record; control: word): TIORsltWD; override;
     procedure UnitWait; override;
     procedure WriteLn(const Msg: string);
   end;

  TConsoleDriver = class(TCharacterDriver)
                   public
                     property frmPsysWindow: TfrmPSysWindow
                              read ffrmPSysWindow;
                     function UnitWrite(var Buffer; BufLen: word; BlockNumber: word; flag: word): TIORsltWD; override;
                   end;

  TBuffer        = array[1..MAXBUFSIZE] of char;
  TOutputBuffer  = ^TBuffer;

  TPrinterDriver = class(TCharacterDriver)
  private
    fDLEPending: boolean;
    fFileOpened: boolean;
    fLineCount: longint;
    fOutBuffer: TOutputBuffer;
    fOutIndex: integer;
    fPrinterFile: TFileStream;
    fSaved: string;
    fDefaultFileName: string;
    procedure ClosePrintFile;
    procedure OpenPrintFile;
    function FindAnyOf(const Cset: TSetOfChar; var Buffer: TBuffer; StartIdx, LastIdx: integer): integer;
    procedure CheckSpace(NrNeeded: integer);
  public
    PrinterFileName: string;
    function UnitClear: TIORsltWD; override;
    function UnitWrite(var Buffer; BufLen: word; BlockNumber: word; flag: word): TIORsltWD; override;
    Destructor Destroy; override;
    Constructor Create( aOwner: TObject;
                         DispatchTo: TProcCall;
                         const aDefaultFileName: string;
                         Control: word); reintroduce;
   end;

  TMemoDriver = class(TCharacterDriver)
  private
    fMemo: TMemo;
    fMemoBuf: string;
    procedure WriteBuffer(var Buffer; Len: integer);
    procedure Write(const s: string);
  public
    function UnitWrite(var Buffer; BufLen: word; BlockNumber: word; flag: word): TIORsltWD; override;
    procedure WriteLn(const s: string);
    Constructor Create( aOwner: TObject;
                         DispatchTo: TProcCall;
                         frmPSysWindow: TfrmPSysWindow;
                         aMemo: TMemo); reintroduce;
//  function Dispatcher(Request, BlockNr, Len: word; var Buffer; Control: word): boolean; override;
//  function UnitClear: boolean; override;
    procedure UnitBusy; override;
    function UnitRead(var Buffer; length: word; BlockNumber: word; flag: word): TIORsltWD; overload; override;
    function UnitRead(var Buffer; length: word; BlockNumber: word): TIORsltWD; overload; override;
    function UnitStatus(var Status_record; control: word): TIORsltWD; override;
    procedure UnitWait; override;
    Destructor Destroy; override;
  end;

implementation

uses
  SysUtils, pSysExceptions, StrUtils, FilerSettingsUnit, Interp_Common,
  Misc, FileNames;

{ TDriver }

constructor TDriver.Create(aOwner: TObject; DispatchTo: TProcCall);
begin
  fOwner := aOwner;
end;

destructor TDriver.Destroy;
begin
end;

function TDriver.Dispatcher(Request, BlockNr, Len: word; var Buffer; Control: word): TIORsltWD;
begin
  result := INOUNIT;  // Will be overridden if it exists
end;

procedure TDriver.UnImplemented(Msg: string; wait: boolean);
begin
  if Wait then
    Alert(Msg)
  else
    Message(Msg);;
end;

procedure TDriver.UnitBusy;
begin
  Unimplemented('UnitBusy', true);
end;

function TDriver.UnitClear: TIORsltWD;
begin
  result := IBADUNIT;   // usually overridden
end;

function TDriver.UnitRead(var Buffer; length, BlockNumber: word): TIORsltWD;
begin
  result := IBADUNIT;   // usually overridden
end;

function TDriver.UnitRead(var Buffer; length, BlockNumber, flag: word): TIORsltWD;
begin
  result := IBADUNIT;   // usually overridden
end;

function TDriver.UnitStatus(var Status_record; control: word): TIORsltWD;
begin
  result := IBADUNIT;
end;

procedure TDriver.UnitWait;
begin
  Unimplemented('UnitWait', true);
end;

function TDriver.UnitWrite(var Buffer; length, BlockNumber, flag: word): TIORsltWD;
begin
  result := INOUNIT;  // Illegal I/O request
end;

{ TCharacterDriver }

constructor TCharacterDriver.Create( aOwner: TObject;
                                     DispatchTo: TProcCall;
                                     aPSysWindow: TfrmPSysWindow;
                                     Control: word);
begin
  inherited Create(aOwner, DispatchTo);
  ffrmPSysWindow := aPSysWindow;
  fDispatchTo    := DispatchTo;
  fControl       := Control;
end;

function TCharacterDriver.Dispatcher(Request, BlockNr, Len: word; var Buffer; Control: word): TIORsltWD;
begin
  if (Request and INBIT) <> 0 then
    begin
      result := UnitRead(Buffer, len, BlockNr);
      if (result = INOError) and ((Control and NOECHO) = 0) then      // echo it
        result := UnitWrite(Buffer, len, BlockNr, 0);  // only echo for unit 1
    end else
  if (REQUEST and STATBIT) <> 0 then
    result := INOERROR else
  if (REQUEST AND CLRBIT) <> 0 then
    result := UnitClear() else
  if (REQUEST AND OUTBIT) <> 0 then
    result := UnitWrite(Buffer, len, BlockNr, 0)
  else
    result := IBADMODE;    // for now
end;

procedure TCharacterDriver.UnitBusy;
begin
  inherited;

end;

function TCharacterDriver.UnitClear: TIORsltWD;
begin
//result := inherited UnitClear;
  ffrmPSysWindow.UnitClear;
  result := INOERROR;
end;

function TCharacterDriver.UnitRead(var Buffer; length, BlockNumber: word): TIORsltWD;
begin
  result := UnitRead(Buffer, Length, BlockNumber, 0);
end;

function TCharacterDriver.UnitRead(var Buffer; length, BlockNumber, flag: word): TIORsltWD;
var
  ch: char; len: word;
begin
  len := 0;
  while len < length do
    begin
      ffrmPSysWindow.GetKey(ch, (fControl and NOECHO) <> 0);
      TBytes(Buffer)[len] := ord(ch);
      inc(len);
    end;
  result := INOERROR;
end;

function TCharacterDriver.UnitStatus(var Status_record; control: word): TIORsltWD;
type
  TWordArray = array[0..30] of word;
  TWordArrayPtr = ^TWordArray;
begin
  TWordArrayPtr(Status_Record)^[0] := ffrmPSysWindow.InputBufferAvailable;
  result := INOERROR;
end;

procedure TCharacterDriver.UnitWait;
begin
  inherited;

end;

function TCharacterDriver.UnitWrite(var Buffer; length, BlockNumber, flag: word): TIORsltWD;
var
  Temp: string;
begin
  try
    SetLength(Temp, Length);
    if Length > 0 then
      begin
        Move(pchar(Buffer), temp[1], Length);
        ffrmPSysWindow.Write(Temp);
      end;
    result := INOERROR;  // for now, assume that it always works
  except
    raise;
  end;
end;

procedure TCharacterDriver.WriteLn(const Msg: string);
begin
  ffrmPSysWindow.WriteLn(Msg)
end;

{ TConsoleDriver }

function TConsoleDriver.UnitWrite(var Buffer; BufLen, BlockNumber, flag: word): TIORsltWD;
begin
  result := UnitWrite(Buffer, BufLen, Blocknumber, 0);
end;
{$I-}

{ TPrinterDriver }

destructor TPrinterDriver.Destroy;
begin
  ClosePrintFile;
  inherited;
end;

procedure TPrinterDriver.ClosePrintFile;
begin
  if fFileOpened then
    begin
      if fOutIndex > 1 then
        fPrinterFile.Write(fOutBuffer^, fOutIndex-1);

      FreeAndNil(fPrinterFile);
      fFileOpened := false;
      fLineCount  := 1;
      Dispose(fOutBuffer);
      if Owner is TCustomPsystemInterpreter then
        with Owner as TCustomPsystemInterpreter do
          StatusProc(Format('Printer file %s has been closed', [PrinterFileName]));
      if FilerSettings.AutoEdit then
        ExecAndWait('notepad.exe', PrinterFileName, false);
    end;
end;


procedure TPrinterDriver.OpenPrintFile;
begin
  if not fFileOpened then
    begin
      PrinterFileName := fDefaultFileName;
      if BrowseForFile('Print to what file: ', PrinterFileName, TXT_EXT) then
        begin
          fPrinterFile := TFileStream.Create(PrinterFileName, fmCreate);
          fFileOpened := true;
          fOutBuffer  := New(TOutputBuffer);
          fLineCount  := 1;
          fOutIndex   := 1;
        end
      else
        raise EIOResult.Create('Operator abort');
    end;
end;


function TPrinterDriver.UnitClear: TIORsltWD;
begin
{$I-}
  try
    ClosePrintFile;
//  OpenPrintFile;
    result := INOERROR;
  except
    result := INOTOPEN;
  end
{$I+}
end;

function TPrinterDriver.FindAnyOf(const Cset: TSetOfChar; var Buffer: TBuffer; StartIdx, LastIdx: integer): integer;
var
  i: integer;
  ch: char;
begin
  result := -1;
  for i := StartIdx to LastIdx do
    begin
      ch := Buffer[i];
      if ch in CSet then
        begin
          result := i;
          exit;
        end
    end;
end;

procedure TPrinterDriver.CheckSpace(NrNeeded: integer);
begin
  if (fOutIndex + NrNeeded) >= Pred(MAXBUFSIZE) then
    begin
      try
        fPrinterFile.Write(fOutBuffer^, fOutIndex-1);
        fOutIndex := 1;
      except
        on e:Exception do
          raise EWRITEERR.Create(e.Message);
      end;
    end;
end;

function TPrinterDriver.UnitWrite(var Buffer; BufLen, BlockNumber, flag: word): TIORsltWD;
var
  done: boolean;
  Idx, LastIdx: word;
  NrBlanks, Len, i: integer;
  Nxt: integer;
  ch: char;
begin
{$I-}
  try
    OpenprintFile;

    Idx := 1;
     if BufLen > 0 then
      begin
        if fDLEPending then // left over from last entry
          begin
            NrBlanks := ord(TBuffer(Buffer)[Idx]) - ord(' ');
            if NrBlanks > 0 then
              begin
                CheckSpace(NrBlanks);
                FillChar(fOutBuffer[fOutIndex], NrBlanks, ' ');
                Inc(fOutIndex, NrBlanks);
                Idx := Idx + 1;                 // skip over the DLE
                fDLEPending := false;
              end;
          end;

        if Idx <= BufLen then
        repeat
          LastIdx := Min(BufLen, MAXBUFSIZE);
          Nxt     := FindAnyOf([DLE, CR, #0], TBuffer(Buffer), Idx, LastIdx);  // returns the Idx of the found char
          if Nxt > 0 then
            begin
              // output previous stuff
              Len := Min(Nxt-Idx, BufLen-Idx);
              if Len > 0 then
                begin
                  CheckSpace(Len);
                  Move(TBuffer(Buffer)[Idx], fOutBuffer[fOutIndex], Len);
                  Inc(fOutIndex, Len);
                end;

              // now deal with the special char
              ch  := TBuffer(Buffer)[Nxt];
              case ch of
                DLE:  // need to expand DLE
                  begin
                    if Nxt < BufLen then // make sure that the DLE blank count is already present.
                      begin
                        NrBlanks := ord(TBuffer(Buffer)[Nxt+1]) - ord(' ');
                        if NrBlanks > 0 then
                          begin
                            CheckSpace(NrBlanks);
                            FillChar(fOutBuffer[fOutIndex], NrBlanks, ' ');
                            Inc(fOutIndex, NrBlanks);
                            fDLEPending := false;
                          end;
                        Nxt := Nxt + 2;                 // skip over the DLE
                      end
                    else
                      fDLEPending := true;
                  end;
                CR:
                  begin
                    Len := Length(CRLF);
                    CheckSpace(Len);
                    Move(CRLF, fOutBuffer[fOutIndex], Len);
                    Inc(fOutIndex, Len);
                    Nxt := Nxt + 1;  // skip over the CR
                    inc(fLineCount);
                  end;
                #0: begin    // skip over the #0 bytes
                      Len := Min(MAXBUFSIZE-Nxt, BufLen);
                      for i := Nxt + 1 to Nxt + Len do
                        if TBuffer(Buffer)[i] <> #0 then
                          break;
                      Nxt := i;
                    end;
              end;
            end
          else // NO special characters found
            begin
              Len := Min(MAXBUFSIZE-Idx, BufLen - Idx + 1);  // how much is left in the buffer?
              if Len > 0 then    // there is still something in the buffer
                begin
                  CheckSpace(Len);
                  Move(TBuffer(Buffer)[Idx], fOutBuffer[fOutIndex], Len);
                  Inc(fOutIndex, Len);
                end;
              Nxt := BufLen + 1; // force the exit
            end;

          Idx := Nxt;
            
          done     := Idx >= BufLen;
        until done;
      end;
    result := INOERROR;
  {$I+}
  except
    on e:Exception do
      begin
        Alert(e.message);
        result := INOFILE;   // call it a "File Not Found" error for lack of anything better to use
      end;
  end;
end;

constructor TPrinterDriver.Create(aOwner: TObject; DispatchTo: TProcCall;
  const aDefaultFileName: string; Control: word);
begin
  inherited Create(aOwner, DispatchTo, nil, Control);
  fDefaultFileName := aDefaultFileName;
  fSaved           := '';
end;

{ TMemoDriver }

procedure TMemoDriver.WriteLn(const s: string);
begin
  Write(s);
  fMemo.Lines.Add(fMemoBuf);
  fMemoBuf := '';
  Application.ProcessMessages;
end;

procedure TMemoDriver.Write(const s: string);
begin
  fMemoBuf := fMemoBuf + s;
end;

procedure TMemoDriver.WriteBuffer(var Buffer; Len: integer);
var
  n, LastN : integer;
  Line: string;
begin
  if Len > 0 then
    begin
      n := PosEX(CRLF, TChars(Buffer)[0], 1);
      if n > 0 then
        begin
          LastN := 0;
          while n > 0 do
            begin
              SetLength(Line, n-1);
              Move(Buffer, Line[1], n - LastN);
              Write(Line);
              LastN := n;
              n := PosEX(CRLF, TChars(Buffer)[0], LastN+2);
            end;
          Len := Len - (LastN + 2);
          SetLength(Line, Len);
          Move(Buffer, Line[1], Len);
          Write(Line);
        end
      else
        begin
          if (Len = 1) and (TChars(Buffer)[0] = CR) then  // 1st and only char is a CR
            WriteLn('')
          else
            begin
              SetLength(Line, Len);
              Move(Buffer, Line[1], Len);
              Write(Line);
            end;
        end;
    end;
end;

function TMemoDriver.UnitWrite(var Buffer; BufLen, BlockNumber, flag: word): TIORsltWD;
begin
  try
    WriteBuffer(Buffer, BufLen);
    result := INOERROR;
  except
    result := INOUNIT;  // "volume not found"
  end;
end;

Constructor TMemoDriver.Create( aOwner: TObject;
                                DispatchTo: TProcCall;
                                frmPSysWindow: TfrmPSysWindow;
                                aMemo: TMemo);
begin
  inherited Create(aOwner, DispatchTo, frmPSysWindow, 0);
  fMemo := aMemo;
end;

destructor TMemoDriver.Destroy;
begin
  WriteLn('');
    
  inherited;
end;

procedure TMemoDriver.UnitBusy;
begin
  Unimplemented('TMemoDriver.UnitBusy', true);
end;

function TMemoDriver.UnitRead(var Buffer; length, BlockNumber,
  flag: word): TIORsltWD;
begin
  result := inherited UnitRead(Buffer, Length, BlockNumber, flag);
end;

function TMemoDriver.UnitRead(var Buffer; length, BlockNumber: word): TIORsltWD;
begin
  result := inherited UnitRead(Buffer, Length, BlockNumber);
end;

function TMemoDriver.UnitStatus(var Status_record; control: word): TIORsltWd;
begin
  result := inherited UnitStatus(Status_Record, Control);
  Unimplemented('TMemoDriver.UnitStatus', true);
end;

procedure TMemoDriver.UnitWait;
begin
  inherited;
  Unimplemented('TMemoDriver.UnitWait', true);
end;

end.
