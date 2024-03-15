
unit OpsTables;

interface

uses
  Classes;

const
  CSP_RLOCSEG = 4;  // treating SCXG1 RLOCSEG as a kludge (see CXGIMMED in InterpIV)

type
  String8 = string[8];
  String6 = string[6];
  String10 = string[10];
  TOpRange = set of byte;

  TProcCall = procedure {name} of object;

  TOpInfo = record
              Name: string[7];
              ProcCall: TProcCall;
{$IfDef Pocahontas}
              PHITS: LongInt;
{$EndIf}
            end;

  TCspInfo = record
               Name: string;
               ProcCall: TProcCall;
{$IfDef Pocahontas}
               PHITS: LongInt;
{$EndIf}
             end;

  TCustomOpsTable = class(TObject)
  private
{$IfDef Pocahontas}
    PHits          : integer;
{$EndIf}

  protected
  public
    CSPEnd         : integer;
    HighPCode      : integer;
    Store_OPS      : set of 0..255;
    Jump_OPS       : set of 0..255;
    Call_OPS       : set of 0..255;
    Return_Ops     : set of 0..255;

    Ops            : array {[0..HIGHPCODE]} of TOpInfo;
    CSPTABLE       : array {[0..CSPEND]} of TCspInfo;

    procedure AddCspOp(OpName: string; Idx: Byte; aProcCall: TProcCall = nil);
    procedure AddOp(OpName: string6; OpRange: TOpRange; aProcCall: TProcCall = nil; Ofs: integer = 0);
    Destructor Destroy; override;
    Constructor Create; virtual;
  end;

{ TOpsTableIV }

  TOpsTableIV = class(TCustomOpsTable)
  public
    Constructor Create; override;
  end;

  TOpsTableIV_12 = class(TOpsTableIV)
  public
    Constructor Create; override;
  end;

  TOpsTableII = class(TCustomOpsTable)
  public
    Constructor Create; override;
  end;

  TOpsTableClass = class of TCustomOpsTable;

implementation

uses

  SysUtils, Misc;

  procedure TCustomOpsTable.AddOp(OpName: string6; OpRange: TOpRange; aProcCall: TProcCall = nil; Ofs: integer = 0);
  var
    i: integer;
    LoBit: integer;

    function Card(OpRange: TOpRange): integer;
    var
      j: byte;
    begin { Card }
      result := 0;
      for j := 0 to HIGHPCODE do
        if j in OpRange then
          inc(result);
    end;  { card }

  begin { AddOp }
//  Inc(NrOpSets);
    LoBit := -1;
    for i := 0 to HIGHPCODE do
      if i in OpRange then
        begin
          with Ops[i] do
            begin
              if Name <> '' then   // trying to assign to something already assigned to
                raise Exception.CreateFmt('System error! Opcode = %d: Attempting to assign %s to %s (which is already assigned)',
                                          [i, OpName, Name]);
              Name  := OpName;
              if LoBit = -1 then
                LoBit := i;

              if Card(OpRange) > 1 then
                Name := Name + IntToStr(i-LoBit-Ofs);

              ProcCall := aProcCall;
            end;
        end;
  end; { AddOp }

  procedure TCustomOpsTable.AddCspOp(OpName: string; Idx: Byte; aProcCall: TProcCall = nil);
  begin
    if OpName <> '' then  // if we don't handle it, ignore it
      if (IDX <= CSPEND) then
        with CspTable[Idx] do
          begin
            if Name <> '' then
              raise Exception.CreateFmt('Duplicate op codes @ ', [Idx]);
            Name     := UpperCase(OpName);
            ProcCall := aProcCall;
          end
      {else
        raise exception.CreateFmt('Invalid CSP opcode: %d', [idx])}
             ;
  end;


destructor TCustomOpsTable.Destroy;
begin
  inherited;
end;

constructor TCustomOpsTable.Create;
begin
end;

{ TVersionIIOpstable }

constructor TOpsTableII.Create;
begin
  inherited;
  HighPCode := 255;
  SetLength(Ops,      HIGHPCODE+1);

  CSPEnd    := 65;
  SetLength(CSPTABLE, CSPEND+1);

  // Mainly used when disassembling for format purposes
  Store_OPS := [171{SRO}, 187{STP}, 189{STM}, 191{STB}, 204{STL}, 170{SAS}, 154{STO}, 184{STR}];
  Jump_OPS  := [161{FJP}, 172{XJP}, 185{UJP}, 211{EFJ}, 212{NFJ}];
  Call_OPS  := [205{CXP}, 206{CLP}, 207{CGP}, 174{CIP}, 158{CSP}, 194{CBP}];
  Return_Ops := [173{RNP}, 193{RBP}, 214{XIT}];
end;

{ TVersionIVOpsTable }

constructor TOpsTableIV.Create;
begin
  inherited;
  HIGHPCODE := 255;  // highest p-Code
  SetLength(Ops,      HIGHPCODE+1);

  CSPEND    := 50;   // # ENTRIES IN CSPTABLE - 1
  SetLength(CSPTABLE, CSPEND+1);

  Store_OPS  := [200 {STB}, 202 {STP}, 209 {SPR}, 104..111 {SSTL}, 164 {STL}, 165 {SRO}, 166 {STR},
                 217 {STE}, 196 {STO}, 142 {STM}, 244 {STRL}, 200 {STB}, 202 {STP}, 209 {SPR}, 235 {ASTR}, 172 {CSP}];
  Jump_OPS   := [138 {UJP}, 212 {FJP}, 241 {TJP}, 210 {EFJ}, 211 {NFJ}, 139 {JPL}, 213 {FJPL}, 214 {XJP}];
  Call_OPS   := [112..119 {SCGX}, 144 {CPL}, 145 {CPG}, 148 {CXG}, 149 {CXI}, 151 {CFP}, 239..240 {SCPI}, 146..147 {CPI..CXL}];
  Return_Ops := [150];
end;

constructor TOpsTableIV_12.Create;
begin
  inherited;
//HIGHPCODE := 255;  // highest p-Code
//SetLength(Ops,      HIGHPCODE+1);

//CSPEND    := 38;   // # ENTRIES IN CSPTABLE - 1 (Version 4.12 ends here}
  CSPEND    := 40;   // # ENTRIES IN CSPTABLE - 1 (Version 4.12 ends here}
  SetLength(CSPTABLE, CSPEND+1);

//Store_OPS  := [200 {STB}, 202 {STP}, 209 {SPR}, 104..111 {SSTL}, 164 {STL}, 165 {SRO}, 166 {STR},
//               217 {STE}, 196 {STO}, 142 {STM}, 244 {STRL}, 200 {STB}, 202 {STP}, 209 {SPR}, 235 {ASTR}, 172 {CSP}];
//Jump_OPS   := [138 {UJP}, 212 {FJP}, 241 {TJP}, 210 {EFJ}, 211 {NFJ}, 139 {JPL}, 213 {FJPL}, 214 {XJP}];
//Call_OPS   := [112..119 {SCGX}, 144 {CPL}, 145 {CPG}, 148 {CXG}, 149 {CXI}, 151 {CFP}, 239..240 {SCPI}, 146..147 {CPI..CXL}];
//Return_Ops := [150];
end;

end.
