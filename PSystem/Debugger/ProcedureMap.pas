unit ProcedureMap;

interface

implementation

procedure TfrmPSysDebugWindow.DumpCodeSeg( Addr: word);
const
  LEFTCOL = LEFTOFFSET + 50;
  TOPROW  = 0;
  CAPTIONWIDTH = 16;
  PROCNAMESROW = 15;
  COLWIDTH = 35;
var
  ProcPtrOffset,
  RelocListOffset,
  ByteSex,
  ConstPoolOffset, NumberOfProcedures,
  RealSubPoolOffset,
  RealSize,
  NumberOfRealConstants,
  AddrOfNumberOfRealConstants,
  AddrOfNumberProcedures, ConstPoolPtrAddr,
  SizeOfConstantPool, ProcPtrAddr,
  RealSizeOffset: word;
  ConstantPoolAddrBAD: word;
//MainSubPoolAddr: word;
  SegName: string[8];
  ProcName: string;
  i: word;
//BreakRow: word;
(*
  procedure WriteLine(aCaption: string; aValue: word); overload;
  begin
    GotoXY(C, R);
    Write([Padr(aCaption, CAPTIONWIDTH), ': ', BothWays(aValue)]);
    R := R + 1;
  end;

  procedure WriteLine(aCaption: string; aValue: string = ''); overload;
  begin
    GotoXY(C, R);
    Write([Padr(aCaption, CAPTIONWIDTH), ': ', aValue]);
    R := R + 1;
  end;
*)

  procedure SetRowCol;
  begin
    if R >= (MaxRows-1) then
      begin
        R := TOPROW;
        C := C + COLWIDTH;
      end;
  end;

begin { TfrmPSysDebugWindow.DumpCodeSeg }
  ProcPtrOffset               := WordAt[Addr] * 2;    // * 2 (convert word offset to byte offset)
  RelocListOffset             := WordAt[Addr+2] * 2;
  SetLength(Segname, 8);
  Move(Bytes^[Addr+4], SegName[1], 8);
  ByteSex                     := WordAt[Addr+4+8];
  ConstPoolPtrAddr            := Addr+SEGCONST_; // (proc dict ptr) + (reloc list ptr) + (name of segment) + (byte sex indicator)
  ConstPoolOffset             := WordAt[ConstPoolPtrAddr] * 2;
  RealSubPoolOffset           := WordAt[Addr+ConstPoolOffset] * 2;
  AddrOfNumberOfRealConstants := Addr+RealSubPoolOffset;
  NumberOfRealConstants       := WordAt[AddrOfNumberOfRealConstants];
//MainSubPoolAddr             := AddrOfNumberOfRealConstants + NumberOfRealConstants + 2;
  RealSizeOffset              := 4+8+2+2;
  RealSize                    := WordAt[Addr+RealSizeOffset];
  AddrOfNumberProcedures      := Addr+ProcPtrOffset;
  NumberOfProcedures          := WordAt[AddrOfNumberProcedures];
  SizeOfConstantPool          := ProcPtrOffset - ConstPoolOffset - (NumberOfProcedures * 2);
  ConstantPoolAddrBAD         := Addr + ConstPoolOffset;
(*
  with Interpreter as TPSystemInterpreter do
    Assert(CpOffset = ConstPoolOffset);

  Assert(ConstantPoolAddress(Addr) = ConstantPoolAddr,
    Format('Constant Pool Addr Validity Failure %s <> %s',
            [HexWord(ConstantPoolAddress(Addr)), HexWord(ConstantPoolAddr)]));
*)
  case MotionHandling of
    mhAlignLeft:
      begin
        ClrScr;
        C := 0;
        R := TOPROW;
      end;
    mhGotoXY:
      begin C := LeftCol; R := TOPROW; end;
    mhTopLeft:
      begin C := 0; R := 0 end;
  end;

//WriteLine('Code Segment loc',  Addr);
  WriteLine('CODE SEGMENT @',   CAPTIONWIDTH, Addr);
  WriteLine('ProcDict Offset',  CAPTIONWIDTH, ProcPtrOffset);
  WriteLine('Reloc List Offs',  CAPTIONWIDTH, RelocListOffset);
  WriteLine('Segment Name',     CAPTIONWIDTH, SegName);
  WriteLine('Byte Sex',         CAPTIONWIDTH, ByteSex);
  WriteLine('Const Pool Offs',  CAPTIONWIDTH, ConstPoolOffset);
  WriteLine('Const Pool Addr',  CAPTIONWIDTH, ConstantPoolAddress(Addr));
  WriteLine('CONST POOL ADDR',  CAPTIONWIDTH, ConstantPoolAddrBAD);
  WriteLine('Nr of Real const', CAPTIONWIDTH, NumberOfRealConstants);
  WriteLine('Real Size',        CAPTIONWIDTH, RealSize);
  WriteLine('Real Subp Offs',   CAPTIONWIDTH, RealSubPoolOffset);
  WriteLine('Number of Proc',   CAPTIONWIDTH, NumberOfProcedures);
  WriteLine('Size Const Pool',  CAPTIONWIDTH, SizeOfConstantPool);
  with Interpreter as TPSystemInterpreter do
    WriteLine('SEGTOP',         CAPTIONWIDTH, Globals.Lowmem.SEGTOP);
//BreakRow := R;

  if DumpProcPtrs then
    begin
      ProcName    := PadL('#', 2) + ': ' + 'Addr [DAddr]';

//    r := PROCNAMESROW;
      case MotionHandling of
        mhAlignLeft:
          begin R := TOPROW; C := COLWIDTH end;
        mhGotoXY:
          R := PROCNAMESROW;
      end;
  
      WriteLine(ProcName, CAPTIONWIDTH, ' Offset to Proc Code');
      for i := 1 to NumberOfProcedures do
        begin
          SetRowCol;
          ProcPtrAddr := AddrOfNumberProcedures - (i*2);
          ProcName    := PadL(i, 2) + ': ' + BothWays(ProcPtrAddr);

          WriteLine(ProcName, CAPTIONWIDTH, WordAt[ProcPtrAddr]);
        end;
      for i := NumberOfProcedures + 1 to fLastNumberOfProcedures do
        begin
          SetRowCol;
          WriteLine('', CAPTIONWIDTH, Padr('', 12));
        end;
      fLastNumberOfProcedures := NumberOfProcedures;
    end;
  Application.ProcessMessages;
  if Wait then
    begin
      GoToXY(0, MaxRows-2);
      PressAnyKey;
    end;
end;  { TfrmPSysDebugWindow.DumpCodeSeg }

end.
