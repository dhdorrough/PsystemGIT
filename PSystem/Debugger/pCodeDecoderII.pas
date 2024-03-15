// WARNING: THIS HAS BEEN PARTIALLY RECODED TO PROPERLY HANDLE InterpC.
//          IT PROBABLY WON'T ENTIRELY WORK FOR InterpII.
//          In particular check the code emitted for "jump" opcodes.
unit pCodeDecoderII;

// Based on P-DECODE.TEXT located in PSYSTEMX.VOL F:\NDAS-I\d7\Projects\pSystem\Volumes\PSYSTEMX.VOL
//       or P-DECODE.TEXT located in TESTING.VOL  F:\NDAS-I\d7\Projects\pSystem\Volumes\TESTING.VOL

interface

uses
  Classes, pCodeDecoderUnit, OpsTables, Interp_Const;

type
  integer = smallint;

  string1 = string[2]; // packed array[0..1] of char;

  string3 = string[4]; // packed array[0..3] of char;

  string7 = string[7];

  ptype = (ub {1 unsigned byte},
           sb {1 signed byte},
           db {1 byte},
           b  {GetBig},
           w  {GetWord},
           x0 {CSP},
           x1 {multiple Bytes},
           x2 {XJP},
           x3 {comparisons},
           x4 {multiple words},
           x5 {CXP},
           x6 {various jumps},
           x7 {rnp, rbp},
           xx {NOP});

  oprec = record
            mnemonic: string[7];
                  p1,
                  p2: ptype
          end;

  Tword = packed record
           case integer of
               0: (b: packed array[0..1] of 0..255);
               1: (c: packed array[0..1] of char);
               2: (h: packed array[0..3] of 0..15);
               3: (i: integer);
               4: (p: ^ word)
         end;

  TpCodeDecoderII = class(TpCodeDecoder)
  private
    fWord_Memory : boolean;
    opcode       : array[0..255] of oprec;
    fJTAB         : word;
    fVersionNr    : TVersionNr;
    HEXDIGIT      : packed array[0..15] of char;

    procedure Initialise;
    procedure OneOp;
    function GetJTAB: word;
    procedure SetJTAB(const Value: word);
    function JumpTarget(IPC: longword): string;
    function wordval(loc: integer): integer;
    function WordIndexed(Addr: longword; offset: integer): longword;
//  procedure SetBaseAddress(const Value: word);
  protected
    procedure AddLine(const Line: string); override;
    procedure AddLineSeparator(OpCode: word); override;
//  function GetByteAt(p: longword): word; override;
    procedure InitDebugOpsTable(IncludeAllCSPOps: boolean; VersionNr: TVersionNr); override;
    function GetDebugOpsTable: TCustomOpsTable; override;
  public
    ExitIC: word;
    LastCode: word;
    SegName: string;     // to simplify debugging
    ProcNr: integer;     // to simplify debugging
    procedure Decode( Addr: Longword;
                      Len: word;
                      StopAfterReturn: boolean = true;
                      aDecodeFormat: TDecodeFormat = dfUnknown;
                      aBaseAddr: Longword = 0); override;
    Constructor Create(aOwner: TComponent;
                       InterpreterOpsTable: TCustomOpsTable;
                       aWord_Memory: boolean = false;
                       VersionNr: TVersionNr = vn_VersionII); reintroduce; {override;}
    property JTAB: word
             read GetJTAB
             write SetJTAB;
    property Word_Memory: boolean
             read fWord_Memory
             write fWord_Memory;
(*
    property BaseAddress: word
             read GetBaseAddress
             write SetBaseAddress;
*)
  end;

implementation

uses
  SysUtils, MyUtils, InterpII, Misc;

{ TpCodeDecoderII }

  procedure TpCodeDecoderII.Initialise;

  var   i: integer;
        s: string7;

    procedure init(op: integer; mne: string7; x1, x2: ptype);
    begin
      with opcode[op] do
        begin
          mnemonic := mne;
          p1       := x1;
          p2       := x2
        end
    end;  (* of init *)

    procedure InitOpcodes;
    begin
      init(128,'ABI    ',xx,xx);
      init(129,'ABR    ',xx,xx);
      init(130,'ADI    ',xx,xx);
      init(131,'ADR    ',xx,xx);
      init(132,'AND    ',xx,xx);
      init(133,'DIF    ',xx,xx);
      init(134,'DVI    ',xx,xx);
      init(135,'DVR    ',xx,xx);
      init(136,'CHK    ',xx,xx);
      init(137,'FLO    ',xx,xx);
      init(138,'FLT    ',xx,xx);
      init(139,'INN    ',xx,xx);
      init(140,'INT    ',xx,xx);
      init(141,'IOR    ',xx,xx);
      init(142,'MODI   ',xx,xx);
      init(143,'MPI    ',xx,xx);
      init(144,'MPR    ',xx,xx);
      init(145,'NGI    ',xx,xx);
      init(146,'NGR    ',xx,xx);
      init(147,'NOT    ',xx,xx);
      init(148,'SRS    ',xx,xx);
      init(149,'SBI    ',xx,xx);
      init(150,'SBR    ',xx,xx);
      init(151,'SGS    ',xx,xx);
      init(152,'SQI    ',xx,xx);
      init(153,'SQR    ',xx,xx);
      init(154,'STO    ',xx,xx);
      init(155,'IXS    ',xx,xx);
      init(156,'UNI    ',xx,xx);
      init(157,'S2P    ',xx,xx);
      init(158,'CSP    ',ub,x0);
      init(159,'LDCN   ',xx,xx);
      init(160,'ADJ    ',ub,xx);
      init(161,'FJP    ',sb,x6);
      init(162,'INC    ', b,xx);
      init(163,'IND    ', b,xx);
      init(164,'IXA    ', b,xx);
      init(165,'LAO    ', b,xx);
      init(166,'LCA    ',ub,x1);
      init(167,'LAE    ', b,xx);     // Was LDO
      init(168,'MOV    ', b,xx);
      init(169,'LDO    ', b,xx);     // Was MVB
      init(170,'SAS    ',ub,xx);
      init(171,'SRO    ', b,xx);
      init(172,'XJP    ',xx,x2);
      init(173,'RNP    ',db,x7);
      init(174,'CIP    ',ub,xx);
      init(175,'EQU    ',db,x3);
      init(176,'GEQ    ',db,x3);
      init(177,'GRT    ',db,x3);
      init(178,'LDA    ',db, b);
      init(179,'LDC    ',ub,x4);
      init(180,'LEQ    ',db,x3);
      init(181,'LES    ',db,x3);
      init(182,'LOD    ',db, b);
      init(183,'NEQ    ',db,x3);
      init(184,'STR    ',db, b);
      init(185,'UJP    ',sb,x6);
      init(186,'LDP    ',xx,xx);
      init(187,'STP    ',xx,xx);
      init(188,'LDM    ',ub,xx);
      init(189,'STM    ',ub,xx);
      init(190,'LDB    ',xx,xx);
      init(191,'STB    ',xx,xx);
      init(192,'IXP    ',ub,ub);
      init(193,'RBP    ',db,x7);
      init(194,'CBP    ',ub,xx);
      init(195,'EQUI   ',xx,xx);
      init(196,'GEQI   ',xx,xx);
      init(197,'GRTI   ',xx,xx);
      init(198,'LLA    ', b,xx);
      init(199,'LDCI   ', w,xx);
      init(200,'LEQI   ',xx,xx);
      init(201,'LESI   ',xx,xx);
      init(202,'LDL    ', b,xx);
      init(203,'NEQI   ',xx,xx);
      init(204,'STL    ', b,xx);
      init(205,'CXP    ',ub,x5);
      init(206,'CLP    ',ub,xx);
      init(207,'CGP    ',ub,xx);

      if fVersionNr < vn_VersionII then
        begin
          init(208,'S1P    ',xx,xx);
          init(166,'LCA    ',ub,x1);
          init(167,'LDO    ',ub,xx);
        end
      else
        begin
          init(208,'LPA    ',xx,xx);
          init(166,'LSA    ',ub,x1);
          init(167,'LAE    ',ub,xx);
        end;

      init(209,'IXB    ',xx,xx);
      init(210,'BYT    ',xx,xx);
      init(211,'EFJ    ',sb,x6);
      init(212,'NFJ    ',sb,x6);
      init(213,'BPT    ', b,xx);
      init(214,'XIT    ',xx,xx);
      init(215,'NOP    ',xx,xx);
      init(216,'SLDL1  ',xx,xx);
      init(217,'SLDL2  ',xx,xx);
      init(218,'SLDL3  ',xx,xx);
      init(219,'SLDL4  ',xx,xx);
      init(220,'SLDL5  ',xx,xx);
      init(221,'SLDL6  ',xx,xx);
      init(222,'SLDL7  ',xx,xx);
      init(223,'SLDL8  ',xx,xx);
      init(224,'SLDL9  ',xx,xx);
      init(225,'SLDL10 ',xx,xx);
      init(226,'SLDL11 ',xx,xx);
      init(227,'SLDL12 ',xx,xx);
      init(228,'SLDL13 ',xx,xx);
      init(229,'SLDL14 ',xx,xx);
      init(230,'SLDL15 ',xx,xx);
      init(231,'SLDL16 ',xx,xx);
      init(232,'SLDO1  ',xx,xx);
      init(233,'SLDO2  ',xx,xx);
      init(234,'SLDO3  ',xx,xx);
      init(235,'SLDO4  ',xx,xx);
      init(236,'SLDO5  ',xx,xx);
      init(237,'SLDO6  ',xx,xx);
      init(238,'SLDO7  ',xx,xx);
      init(239,'SLDO8  ',xx,xx);
      init(240,'SLDO9  ',xx,xx);
      init(241,'SLDO10 ',xx,xx);
      init(242,'SLDO11 ',xx,xx);
      init(243,'SLDO12 ',xx,xx);
      init(244,'SLDO13 ',xx,xx);
      init(245,'SLDO14 ',xx,xx);
      init(246,'SLDO15 ',xx,xx);
      init(247,'SLDO16 ',xx,xx);
      init(248,'SIND0  ',xx,xx);
      init(249,'SIND1  ',xx,xx);
      init(250,'SIND2  ',xx,xx);
      init(251,'SIND3  ',xx,xx);
      init(252,'SIND4  ',xx,xx);
      init(253,'SIND5  ',xx,xx);
      init(254,'SIND6  ',xx,xx);
      init(255,'SIND7  ',xx,xx)
    end;


  begin (*initialise*)
    HEXDIGIT := '0123456789ABCDEF';

    for i := 0 to 127 do
      begin
        s := Format('SLDC%-3d', [i]);
        init(i,s,xx,xx)
      end;
    InitOpcodes;
  end; (* initialise *)

constructor TpCodeDecoderII.Create(aOwner: TComponent;
  InterpreterOpsTable: TCustomOpsTable; aWord_Memory: boolean = false; VersionNr: TVersionNr = vn_VersionII);
begin
  inherited Create(aOwner, InterpreterOpsTable, TRUE {DEBUGGING}, VersionNr);
  fWord_Memory := aWord_Memory;
  fVersionNr   := VersionNr;

  Initialise;
end;

procedure TpCodeDecoderII.Decode( Addr: Longword;
                                  Len: word;
                                  StopAfterReturn: boolean = true;
                                  aDecodeFormat: TDecodeFormat = dfUnknown;
                                  aBaseAddr: Longword = 0);
begin
  fIPC          := 0;
  fBaseAddress  := aBaseAddr;
  fDecodeFormat := aDecodeFormat;
  while {StopAfterReturn or} (fIPC < Len) do
    begin
      fOpBase     := fIPC;
      OneOp;
      fIpc        := succ(fIpc);
      if StopAfterReturn and (fOpCode in DebugOpsTable.Return_Ops ) then
        break;
    end
end;

  function TpCodeDecoderII.wordval(loc: integer):integer;

  var  w: Tword;
  begin
    w.b[0]  := ByteAt[loc];
    w.b[1]  := ByteAt[succ(loc)];
    wordval := w.i
  end;

  function TpCodeDecoderII.WordIndexed(Addr: longword; offset: integer): longword;
  begin
  {$R-}
    if fWord_Memory then
      result := Addr + Offset
    else
      result := Addr + (2 * Offset);
  {$R+}
  end;

// WARNING: THIS CODE (JumpTarget) MAY NOT WORK PROPERLY!
// (-- probably for InterpII) anymore.
// In particular the changed meaning of fIpc (was absolute address, now is offset from start) may
// lead to incorrect results.
function TpCodeDecoderII.JumpTarget(IPC: longword): string;
var
  disp: shortint;
//EntryIC: word;
  w: word;
begin
  w    := ByteAt[IPC];
  disp := ShortInt(w);
  if (disp >= 0) then
    result := IntToStr(Ipc + disp + 1)
  else
    begin
      disp := - disp;
    {$R-}
      if fWord_Memory then
        result := IntToStr(WordAt[WordIndexed(JTab, -1)] + 2 - (WordAt[JTab - disp div 2] + disp))
      else
        result := IntToStr(WordAt[WordIndexed(JTab, -1)] + 2 - (WordAt[JTab - disp] + disp));
    {$R+}
    end;
end;

procedure TpCodeDecoderII.OneOp;
var
       i: longint;
       MinIndex,
       MaxIndex: integer;
       DecStr: string;
       Line: string;

  procedure handledb;
  var
    ByteStr: string;
  begin
    fIPC    := succ(fIPC);
    ByteStr := Format('%3d ', [ByteAt[fIPC]]);
    Line    := Line + ByteStr;
   end;  (* of handledb *)

(*
  procedure handlejb;
  var
    disp: shortint;
    TargetIPC: word;
  begin
    fIPC := succ(fIPC);
{$R}
    Disp := ByteAt[fIPC];
{$R-}
    if (Disp < 0) then
      fIPC := succ(fIPC);
  end;
*)
   procedure ignoreb;
   begin
     fIPC := succ(fIPC);
   end;

  procedure handleb;
  var
    Byte1Str: string;
    A: word;
    DE: TUnion;
  begin
    Inc(fIPC);
    A := ByteAt[fIPC];    {get byte from code stream}
    DE.w := A;
    If (A and $80) <> 0 then  // if signed
      begin
        {if here is big}
        DE.H := A and $7f;
        Inc(fIPC);
        DE.L := ByteAt[fIPC];
//      INC(fIPC);
      end;
    Byte1Str := IntToStr(DE.I);
    Line := Line + Byte1Str;
  end; (* of handleb *)

  procedure handlew(cap: string);
  var
    I : integer;
  begin
{$R-}
    I    := ((ByteAt[fIPC+2]) * 256) + ByteAt[fIPC+1];
    Line := Line + Cap + IntToStr(i);
    fIPC := fIPC + 2
{$R+}    
  end; (* of handlew *)

  procedure handlecsp;

  var s:string;

  begin
    s:='';
    case ByteAt[fIPC] of
      0: s:= ' (iocheck)';
      1: s:= ' (new)';
      2: s:= ' (moveleft)';
      3: s:= ' (moveright)';
      4: s:= ' (exit)';
      5: s:= ' (unitread)';
      6: s:= ' (unitwrite)';
      7: s:= ' (idsearch)';
      8: s:= ' (treesearch)';
      9: s:= ' (time)';
     10: s:= ' (fillchar)';
     11: s:= ' (scan)';
     21: s:= ' (load resident segment ?)';
     22: s:= ' (release stack space ?)';
     23: s:= ' (trunc)';
     24: s:= ' (round)';
     25: s:= ' (sine)';
     26: s:= ' (cos)';
     27: s:= ' (log)';
     28: s:= ' (atan)';
     29: s:= ' (ln)';
     30: s:= ' (exp)';
     31: s:= ' (sqt)';
     32: s:= ' (mark)';
     33: s:= ' (release)';
     34: s:= ' (ioresult)';
     35: s:= ' (unitbusy)';
     36: s:= ' (pwroften)';
     37: s:= ' (unitwait)';
     38: s:= ' (unitclear)';
     39: s:= ' (halt)';
     40: s:= ' (memavail)'
    end; (* of case *)
//  write(f,s)
    Line := Line + s;
  end; (* of handlecsp *)

  procedure handlecxp;
  var
    s:string;
  begin
    handledb;
    if ByteAt[pred(fIPC)] = 0 then
    begin
      s:='';
      case ByteAt[fIPC] of
        2: s:= ' (execerror)';
        3: s:= ' (build fib)';
        4: s:= ' (freset)';
        5: s:= ' (fopen)';
        6: s:= ' (close)';
        7: s:= ' (get)';
        8: s:= ' (put)';
        9: s:= ' (xseek)';
       10: s:= ' (eof)';
       11: s:= ' (eoln)';
       12: s:= ' (read integer)';
       13: s:= ' (write integer)';
       14: s:= ' (read real)';
       15: s:= ' (write real)';
       16: s:= ' (read char)';
       17: s:= ' (write char)';
       18: s:= ' (read string)';
       19: s:= ' (write string)';
       20: s:= ' (write array of char)';
       21: s:= ' (readln)';
       22: s:= ' (writeln)';
       23: s:= ' (concat)';
       24: s:= ' (insert)';
       25: s:= ' (copy)';
       26: s:= ' (delete)';
       27: s:= ' (pos)';
       28: s:= ' (block read/write)';
       29: s:= ' (gotoxy)'
      end; (* of case *)
//    write(f,s)
      Line := Line + s;
    end
  end; (* of handlecxp *)

  procedure AddStr(ch: string);
  begin
    line := line + ch;
  end;

begin { OneOp }
  fOpCode := ByteAt[fIPC];
  with opcode[fOpCode] do
    begin
      fOpCodeName := mnemonic;
      Line        := '';
      case p1 of
        sb,
        ub,db: handledb;
               b: handleb;
               w: handlew('');
//      sb: handlejb;  // was trying to better display the jump ops
      end; (* of case *)
      case p2 of
        ub,sb,db: handledb;
               b: handleb;
               w: handlew('');
              x0: handlecsp;
              x1: begin
                    (* lsa, lsp *)
                    Line := Line + ' ''';
                    for i := 1 to ByteAt[fIPC] do
                      begin
                        fIPC := succ(fIPC);
                        if ByteAt[fIPC] > 31 then
                          Line := Line + chr(ByteAt[fIPC])
                        else
                          AddStr('.');
                      end;
                    AddStr('''');
                  end;
              x2: begin
                    (* XJP *)
{
                    if not odd(fIPC) then
                      fIPC := succ(fIPC);

                    handlew('Min='); AddStr(' ');
                    handlew('Max='); AddStr(' ');
                    handlew('?'); AddStr(' ');

                    fIpc := fIPC + 2;
                    Line := Line + 'UJP ' + JumpTarget(fIPC);

                    MinIndex := WordAt[fIPC-5];
                    MaxIndex := WordAt[fIPC-3];

                    for i := MinIndex to MaxIndex do
                      begin
                        handlew(Format('[%d]=', [i])); AddStr(' ');
//                      Hex := HexWord(pred(fIPC)-WordAt[pred(fIPC)]);
//                      Line := Line + '(' + Hex + ') ';
                      end
}
                    if not odd(ipc) then
                      ipc := succ(ipc);
                      
                    handlew('Min='); AddStr(' ');
                    handlew('Max='); AddStr(' ');
//                  handlew('?'); AddStr(' ');     // I don't know what this is.
                    fIpc := fIpc + 2;

                    MinIndex := wordval(ipc-5);
                    MaxIndex := wordval(ipc-3);
                    for i:= MinIndex to MaxIndex do
                      begin
                        handlew(Format('[%d]=', [i])); AddStr(' ');
                      end
                  end;
              x3: begin
                    (* equ etc *)
                    case ByteAt[fIPC] of
                      2: AddStr(' (real)');
                      4: AddStr(' (string)');
                      6: AddStr(' (boolean)');
                      8: AddStr(' (set)');
                     10: begin
                           handleb;
//                         write (f,' (byte array)')
                           AddStr(' (byte array)');
                         end;
                     12: begin
                           handleb;
//                         write (f,' (word)')
                           AddStr(' (word)');
                         end
                    end (* of case *);
                  end;
              x4: begin
                    (* LDC *)
                    MaxIndex := ByteAt[fIPC];
                    if not odd(fIPC) then
                      fIPC := succ(fIPC);
                    for i := 1 to MaxIndex do
                      begin
                        handlew('');
                        AddStr(' ');
                      end;
                  end;
              x5: handlecxp;
              x6: begin
                    (* fjp, ujp, efj, nfj *)
                    DecStr := JumpTarget(fIPC);
                    Line := Line + ' ' + DecStr;
                  end;
              x7: (* rnp, rbp *)
                  if fIPC >= exitic then
                    lastcode := fIPC;
      end; (* of case *)
      GenOpLine(fOpCodeName, Line);
    end;
end;  { OneOp }

procedure TpCodeDecoderII.AddLine(const Line: string);
begin
  if Assigned(fOnAddLine) then
    fOnAddLine(Line)
  else
    raise Exception.Create('AddLine not defined');
end;

procedure TpCodeDecoderII.AddLineSeparator(OpCode: word);
begin
  if Assigned(fOnAddLineSeparatorProc) then
    fOnAddLineSeparatorProc(OpCode)
  else
    raise Exception.Create('AddLineSeparator not defined');
end;

(*
function TpCodeDecoderII.GetByteAt(p: longword): word;
begin
  result := fGetByteFromMemoryBased(BaseAddress, fIPC);
  if Assigned(fOnGetByte3) then
    result := fOnGetByte3(p) else
  if Assigned(fGetBaseAddressFunc) then
  else
    raise Exception.Create('OnGetByteAt not assigned');
end;
*)

procedure TpCodeDecoderII.InitDebugOpsTable;
begin
  { not currently used }
end;

function TpCodeDecoderII.GetDebugOpsTable: TCustomOpsTable;
begin
  if not Assigned(fDebugOpsTable) then
    fDebugOpsTable := TOpsTableII.Create;
  result := fDebugOpsTable;
end;

function TpCodeDecoderII.GetJTAB: word;
begin
  if Assigned(fOnGetJTAB) then
    result := fOnGetJTAB
  else
    if fJTAB <> 0 then
      result := fJTAB
    else
      raise Exception.Create('JTAB not assigned');
end;

procedure TpCodeDecoderII.SetJTAB(const Value: word);
begin
  fJTAB := Value;
end;

end.

