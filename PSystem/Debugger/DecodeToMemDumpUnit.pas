unit DecodeToMemDumpUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pCodeDecoderUnit, Interp_Common;

type
  TDecodeToMemDump = class(TObject)
  private
    fOnGetByte2    : TGetByteFunc;
    fGetBaseAddressFunc : TGetBaseAddressFunc;
    fBaseAddress   : LongWord;
    fErrors        : integer;
    fResult        : string;
    fpCodeDecoder  : TpCodeDecoder;
    fInterpreter   : TCustomPsystemInterpreter;
    fOnGetWord2    : TGetWordFunc;
    fOnGetJTAB     : TGetOneWordFunc;
    fGetByteFromMemoryBased: TGetByteFromMemoryBased;
    procedure AddLineSeperator(OpCode: word);
    procedure SetOnGetByte2(const Value: TGetByteFunc);
    procedure SetOnGetWord2(const Value: TGetWordFunc);
    function GetbaseAddress: longword;
    procedure SetBaseAddress(const Value: longword);
  protected
    procedure AddLine(const Line: string);
//  function GetByteBased: TGetByteFunc;
    { Private declarations }
  public
    { Public declarations }
    function DecodedRange(addr: longword; nrBytes: word; aBaseAddr: longword): string;
    Constructor Create( Interpreter: TCustomPsystemInterpreter;
                        pCodeDecoder: TpCodeDecoder;
                        aBaseAddr: Longword);
    Destructor Destroy; override;
    property BaseAddress: longword
             read GetbaseAddress
             write SetBaseAddress;
    property OnGetByte2: TGetByteFunc
             read fOnGetByte2
             write SetOnGetByte2;
    property OnGetWord2: TGetWordFunc
             read fOnGetWord2
             write SetOnGetWord2;
    property OnGetJtab: TGetOneWordFunc
             read fOnGetJTAB
             write fOnGetJTAB;
    property OnGetBaseAddress: TGetBaseAddressFunc
             read fGetBaseAddressFunc
             write fGetBaseAddressFunc;
    property OnGetByteBased: TGetByteFromMemoryBased
             read fGetByteFromMemoryBased
             write fGetByteFromMemoryBased;

  end;

implementation

uses MyUtils;

procedure TDecodeToMemDump.AddLine(const Line: string);
var
  temp: string;
begin
  temp := Trim(Line);
  if not Empty(fResult) then
    fResult := fResult + ', ' + temp
  else
    fResult := temp;
end;

procedure TDecodeToMemDump.AddLineSeperator(OpCode: word);
begin
  // no op
end;

constructor TDecodeToMemDump.Create( Interpreter: TCustomPsystemInterpreter;
                                     pCodeDecoder: TpCodeDecoder;
                                     aBaseAddr: Longword);
begin
  fpCodeDecoder := pCodeDecoder;
  fInterpreter  := Interpreter;

  with fpCodeDecoder do
    begin
      OnAddLine          := AddLine;
      OnAddLineSeparator := AddLineSeperator;
      BaseAddress        := aBaseAddr;
      // Cannot assign any of these here because the self.* stuff is not yet assigned
//    OnGetByte3         := self.fOnGetByte2;
//    OnGetWord3         := self.fOnGetWord2;
//    OnGetBaseAddress   := self.fGetBaseAddressFunc;
//    OnGetByteBased     := self.fGetByteFromMemoryBased;
    end;
end;

function TDecodeToMemDump.DecodedRange(addr: longword; nrBytes: word; aBaseAddr: longword): string;
begin
  fResult := '';
  fErrors := 0;
  fpCodeDecoder.OnGetByteBased       := self.fGetByteFromMemoryBased;
  fpCodeDecoder.OnGetBaseAddress     := self.fGetBaseAddressFunc;
  fpCodeDecoder.Decode( Addr, nrBytes, false, dfShortFormat, aBaseAddr);
  if fErrors > 0 then
    AddLine(Format('%d errors', [fErrors]));
  result := fResult;
end;

destructor TDecodeToMemDump.Destroy;
begin
  FreeAndNil(fpCodeDecoder);
  inherited;
end;

function TDecodeToMemDump.GetbaseAddress: longword;
begin
  if fBaseAddress = 0 then
    if Assigned(fGetBaseAddressFunc) then
      fBaseAddress := fGetBaseAddressFunc;
  result := fBaseAddress;
end;

procedure TDecodeToMemDump.SetBaseAddress(const Value: longword);
begin
  fBaseAddress := Value;
end;

procedure TDecodeToMemDump.SetOnGetByte2(const Value: TGetByteFunc);
begin
  fOnGetByte2 := Value;
  fpCodeDecoder.OnGetByte3 := Value;
end;

procedure TDecodeToMemDump.SetOnGetWord2(const Value: TGetWordFunc);
begin
  fOnGetWord2 := Value;
  fpCodeDecoder.OnGetWord3 := Value;
end;

initialization
finalization
end.
