unit pSysDebugWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UCSDGlob, PSysWindow, Menus, Debug_Decl, Interp_Const, Watch_Decl,
  CrtWindow, pCodeDebugger;

type
  TRegsList = record
    aCaption : string[80];
    TIB      : WORD;
    CURTASK  : Word;
    CURPROC  : Word;
    IORSLT   : Word;
    ERECp    : Word;
    BASE     : Word;
    EVECp    : Word;
    BASEPLUS : Word;
    SIBp     : Word;
    SEGb     : Word;
    CPOFFSET : Word;
    MPPlus   : Word;
    SP       : Word;
    MP       : Word;
//  MSCW     : Word;
    AX       : Word;
    BP       : Word;
    BX       : Word;
    DX       : Word;
    SEXFLAG  : Word;
    SEGTOP   : Word;
    DS       : Word;
    ES       : Word;
    POOLDESC : Word;
    SI       : Word;
    PROCCODE : Word;
  end;
  
  TMotionHandling = (mhNone, mhAlignLeft, mhGotoXY, mhTopLeft);

  TfrmPSysDebugWindow = class(TfrmCrtWindow)
    Control1: TMenuItem;
    Functions1: TMenuItem;
    EnableStackWatch1: TMenuItem;
    Debugon1: TMenuItem;
    ClearScreen1: TMenuItem;
    N3: TMenuItem;
    NextPage1: TMenuItem;
    PrevPage1: TMenuItem;
    ChoosePage1: TMenuItem;
    Dashboard1: TMenuItem;
    DisplayConstantPool1: TMenuItem;
    MemoryDump1: TMenuItem;
    DisplayInternalPMachineValues1: TMenuItem;
    FromTIB1: TMenuItem;
    DisplayEVECChain1: TMenuItem;
    DisplayEVECfromAddr1: TMenuItem;
    DisplayLoadedSegments1: TMenuItem;
    DisplaySegmentLoads1: TMenuItem;
    RepaintScreen1: TMenuItem;
    procedure EVECdump1Click(Sender: TObject);
    procedure Dashboard1Click(Sender: TObject);
    procedure DisplayConstantPool1Click(Sender: TObject);
    procedure MemoryDump1Click(Sender: TObject);
    procedure DisplayInternalPMachineValues1Click(Sender: TObject);
    procedure FromTIB1Click(Sender: TObject);
    procedure DisplayEVECChain1Click(Sender: TObject);
    procedure EnableStackWatch1Click(Sender: TObject);
    procedure Debugon1Click(Sender: TObject);
    procedure ClearScreen1Click(Sender: TObject);
    procedure NextPage1Click(Sender: TObject);
    procedure PrevPage1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DisplayLoadedSegments1Click(Sender: TObject);
    procedure ChoosePage1Click(Sender: TObject);
    procedure DisplaySegmentLoads1Click(Sender: TObject);
    procedure RepaintScreen1Click(Sender: TObject);
  private
    { Private declarations }
    R0, C0: integer;
    fDebugger    : TfrmPCodeDebugger;
    fInterpreter : TObject;
    fLastLoc     : longword;
    fLastNrBytes : word;
    fLastNumberOfProcedures: integer;
    fLastItemsPerRow: word;
    fShowPAddr   : boolean;
    fLastCaption : string;
    fForms       : string;
    fLastVectLen : integer;
    fDumpAddr    : longword;
    fUseDecimalOffsets: boolean;
    fDisplayAsAddress: boolean;
    fTheFormsToUse: string;

    fLastSEGB    : longword;
    fLastCurTask : longword;
    fLastERECp   : longword;
    fLastEVECp   : longword;
    fLastSIBp    : longword;
    fERECList    : TList;
    fEVECList    : TList;

    function GetWordAt(P: word): word;
    procedure DisplayReg(RegName: string; RegVal: longword; OtherInfo: string = ''); overload;
    procedure DisplayReg(RegName: string; OtherInfo: string = ''); overload;
    procedure SetDebugOn(const Value: boolean);
//  procedure DisplayEvec2(Addr: word);
    function GetDebugOn: boolean;
    function GetAddress( aCaption: string;
                         var Addr: longword;
                         var DoDisplayAsAddress: boolean;
                         var DoUseDecimalOffsets: boolean;
                         var TheFormsToUse: string;
                         ShowCheckBox: boolean = false;
                         ShowFormsToUse: boolean = false): boolean;
    procedure RepaintDisplay(const Notice: string = '');
    function CheckForClrScreenNeeded: boolean;
    function MemDumpDW( Addr: longword;
                        WatchType: TWatchType;
                        Param: word = 0;
                        const Msg: string = ''): string;
    function MemDumpDF( Addr: longword;
                        Form: string = 'W';
                        Param: word = 0;
                        const Msg: string = ''): string;
    procedure DoEvecDump(EVECAddr: word);
    procedure PrintERECList(List: TList);
    procedure DumpChain(EvecAddr: word; EVECList, ERECList: TList);
    procedure ProcessERECChain(EVECStartAddr: word; EVECList, ERECList: TList);
    procedure PrintEVECList(List: TList);
    procedure DisplayEvec2(Addr: word);
    procedure DisplayLoadedSegments;
    procedure DisplaySegmentLoads;
  protected
    procedure WriteLine(aCaption: string; CaptionWidth: word; aValue: longword); overload; virtual;
    procedure WriteLine(aCaption: string; CaptionWidth: word; aValue: string = ''); overload; virtual;
  public
    { Public declarations }
    function ConstantPoolAddress(Addr: longword): longword;

    procedure DisplayConstantPool(addr: longword; maxbytes: word = 0);
    procedure DisplayErec(addr: longword); virtual;
    procedure DisplayEvec(Addr: longword; aCaption: string = ''); virtual;
    procedure DisplayInternalPMachineValues;
    procedure DisplayMSCW(addr: longword;
                          aCaption: string = ''); virtual;
    procedure DisplayRegs;
    procedure DisplayTIB(Addr: longword; UseGotoXY: boolean = true); virtual;
    procedure DisplaySIB( Addr: longword); virtual;
    procedure DumpCodeSeg(Addr: longword; DumpProcPtrs: boolean = false); virtual;
    procedure DumpMem( aCaption: string;
                       Forms: string;
                       loc: longword;
                       nrBytes, ItemsPerRow: word;
                       ShowPAddr: boolean = false;
                       UseDecimalOffsets: boolean = false);
    procedure DumpSegDict(Addr: word); virtual;
{$IfDef DumpSegDict2}
    procedure DumpSegDict2(OffSet0: word; ShowPAddr: boolean = false);
{$EndIf}
    procedure ProcCodeForProcedureNumber(Addr: word;
                                         ProcNumber: word); virtual;
    procedure ShowStack(address: word);
    procedure UpdateDebugWindow(aCaption: string = '');
    procedure UpdateDebugWindow2( const RegisterSources: TRegsList);
    Constructor Create( aOwner: TComponent;
                        Heading: string;
                        aTop: integer;
                        aLeft: integer;
                        aMaxRows: integer = DEFMAXROWS;
                        aMaxCols: integer = DEFMAXCOLS;
                        aInterpreter: TObject = nil;
                        Debugger: TfrmPCodeDebugger = nil); reintroduce;
    Destructor Destroy; override;
    property DebugOn: boolean
             read GetDebugOn
             write SetDebugOn;
    property WordAt[P: word]: word
             read GetWordAt;
  end;

(*
var
  frmDebugWindow : TfrmPSysDebugWindow;
*)

implementation

uses {CodeSpace,} InterpIV, MyUtils, uGetString, Misc, BitOps,
  DecodeWindow, FilerSettingsUnit, WindowsList, pSys_Const, Interp_Common,
  Interp_Decl, GetStartingAddress, MiscinfoUnit, DebuggerSettingsUnit,
  FileNames, UCSDInterpreter;

{$R *.dfm}

const
  GROUP1_COL = 1;
  GROUP2_COL = 50;
  GROUP3_COL = 100;

  MSCW_COL   = GROUP2_COL;
  MSCW_ROW   = 30;

  SIB_ROW    =  39;
  SIB_COL    =  GROUP2_COL;

  TIB_ROW    = 8;
  TIB_COL    = GROUP1_COL;

  EVEC_ROW   = 26;
  EVEC_COL   = GROUP1_COL;

  REGISTERS_COL = GROUP2_COL;
  REGISTERS_ROW = 10;

  INTERNALVALS_ROW = 1;

  STACK_LINES = 7;
  STACK_ROW   = 0;
  STACK_COL   = GROUP2_COL;

type
  EInvalidNrProcs = class(Exception);

{ TfrmPSysDebugWindow }

//*****************************************************************************
//   Function Name     : DumpMem
//   Useage            : DumpMem( 'Caption', 'AB', $500, 100, 16, true);
//   Function Purpose  :
//   Assumptions       :
//   Parameters        : Caption = caption to display
//                       Forms string where:
//                                    B = Bytes
//                                    F = flipped
//                                    W = Hex Words
//                                    D = Decimal
//                                    A = Ascii
//                                    C = Clear Screen
//   Return Value      :
//*******************************************************************************}

procedure TfrmPSysDebugWindow.DumpMem( aCaption: string;
                                       Forms: string;
                                       loc: longword;
                                       nrBytes, ItemsPerRow: word;
                                       ShowPAddr: boolean = false;
                                       UseDecimalOffsets: boolean = false);
var
  p: longword;     // byte indexed

  I, OffSet, Wrd: word;
  int: integer;
  S1: string;
  Temp: string;
  Temp4: string;

begin { DumpMem }
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      Forms := UpperCase(Forms);
      GoToXY(0, 0);
      Temp := Format('Dump of $%4.4x, ItemsPerRow: %d, TotalBytes: %d',
        [Loc, ItemsPerRow, NrBytes]);
      Write(Temp);
      WriteLn;

      p := ByteIndexed(Loc); OffSet := 0;
      repeat
        if ShowPAddr then  // show p-System address
          if UseDecimalOffsets then
            temp4 := Format('%5d', [Offset+Loc])
          else
            temp4 := Format('$%4.4x', [Offset+Loc])
        else               // just just show the offset
          if UseDecimalOffsets then
            temp4 := Format('%5d', [Offset])
          else
            temp4 := Format('$%4.4x', [Offset]);

        Write(temp4); Write(': ');

        if Pos('B', Forms) > 0 then // show as bytes
          begin
            i := 0;
            while i < ItemsPerRow do
              begin
                S1 := HexBYTE(Bytes^[p+Offset+i]);
                Write(S1); Write(' ');
                inc(i);
              end;
            Write('  ');
          end;

        if Pos('W', Forms) > 0 then // show as hex words
          begin
            i := 0;
            p := Loc;
            while I < ItemsPerRow do
              begin
                wrd := WordAt[p+Offset+I]; // ((Bytes^[p+Offset+i+1]) shl 8) + (Bytes^[p+Offset+i]);
                if pos('F', Forms) > 0 then
                  wrd := FlipSex(wrd);
                temp4 := HexWord(Wrd);
                Write(temp4); Write(' ');
                i := WordIndexed(i, 1);
              end;
            Write('  ');
          end;

        if Pos('A', Forms) > 0 then // show as Ascii
          begin
            temp := '';
            p    := ByteIndexed(Loc);
            for i := 0 to ItemsPerRow-1 do
              temp := temp + chr(Bytes^[p+Offset+i]);
            Temp := Printable(temp);
            Write(temp);
          end;

        if Pos('D', Forms) > 0 then // show as decimal words
          begin
            i := 0;
            while i < ItemsPerRow do
              begin
    {$R-}
                if pos('F', Forms) > 0 then
                  int := ((Bytes^[p+Offset+i]) shl 8) + (Bytes^[p+Offset+i+1])
                else
                  int := ((Bytes^[p+Offset+i+1]) shl 8) + (Bytes^[p+Offset+i]);
    {$R+}
                Write(PadL(int, 6)); Write(' ');
                i := WordIndexed(i, 1);
              end;
            Write('  ');
          end;

        Offset := OffSet + ItemsPerRow;
        WriteLn;
      until Offset >= NrBytes;
      fLastLoc         := Loc;
      fLastNrBytes     := NrBytes;
      fLastItemsPerRow := ItemsPerRow;
      fShowPAddr       := ShowPAddr;
      fLastCaption     := aCaption;
      fForms           := Forms;
    end;
end;  { DumpMem }


procedure TfrmPSysDebugWindow.DumpSegDict(Addr: word);
var
  i, j: integer;
  major_version, m_type, seg_num, BitNr: byte;
  aSegType: TSeg_Types;
  Vers, Seg: string[4];
  Typ: string[6];
  relocatable: boolean;
  pn: byte;
  SegmentDictionary: TSeg_Dict;
begin
  with fInterpreter as TIVPsystemInterpreter do
    begin
      Move(Bytes^[Addr], SegmentDictionary, Sizeof(TSeg_Dict));
      WriteLn;
      WriteLn(Format('Segment Dictionary: [Addr: %s]', [HexWord(Addr)]));
      with SegmentDictionary do
        begin
          WriteLn(
    'INX  NAME    START   SIZE  VERSION    M_TYPE SG#  SEG_TYPE RL FMY_NAME or');
          WriteLn(
    '               BLK (WORDS)                                    DSIZE  SGRF   HSG    TS');
          for i := 0 to MaxSeg do
            begin
              Write([PadL(I, 2), ': ']);
              Write(PadR(Seg_Name[i], 8));

              with Disk_Info[i] do
                Write([Padl(Code_Addr, 6),
                       Padl(Code_Leng, 7),
                       ' ']);
              with Seg_Info[i] do
                begin
                  BitNr         := 0;
                  seg_num       := Bits(SegInfo, Bitnr, 4);
                  m_type        := Bits(SegInfo, BitNr, 4);
                  BitNr         := 13;
                  major_version := Bits(SegInfo, BitNr, 4);

                  case TVersions(major_version) of
                    unknown: Vers := 'Unk';
                    ii:      Vers := 'II  ';
                    ii_1:    Vers := 'II.1';
                    iii:     Vers := 'III ';
                    iv:      Vers := 'IV  ';
                    v:       Vers := 'V   ';
                    vi:      Vers := 'VI  ';
                    vii:     Vers := 'V   ';
                  end;
                  Typ := MachTypeToStr(TMTypes(m_type));
                  Seg := PadL(Seg_Num, 4);
                  Write(['      ', Vers, '  ', Typ, Seg]);
                end;

              with Seg_Misc[i] do
                begin
                  Write('  ');
    //            aSegType      := Seg_Types(SegMiscRec and $F);
                  BitNr         := 0;      
                  aSegType      := TSeg_Types(Bits(SegMiscRec, BitNr, 3));
                                   Bits(SegMiscRec, BitNr, 5); // filler
    //            has_link_info := Boolean(Bits(SegMiscRec, BitNr, 1));
                  relocatable   := Boolean(Bits(SegMiscRec, BitNr, 1));

                  case aSegType of
                    proc_seg:  Write('PROC_SEG');
                    unit_seg:  Write('UNIT_SEG');
                    prog_seg:  Write('PROG_SEG');
                    seprt_seg: Write('SEPR_SEG');
                    no_seg:    Write('NO_SEG  ');
                  end;

                  case relocatable of
                    true:  Write(' R ');
                    false: Write(' N ');
                  end;

                  with seg_family[i] do
                    if aSegType = proc_seg then
                      Write('''' + PadL(seg_family[i].host_name, 8) + '''')
                    else
                      Write([
                        PadL(data_size, 6),
                        PadL(seg_ref_words, 6),
                        PadL(max_seg_num, 6),
                        PadL(text_size, 6)
                        ]);
                end;
              WriteLn;
            end;
          WriteLn('SGRF=Seg_Ref_Words, HSG=Max_Seg_Num, TS=Text_Size');
          WriteLn(['ped_block: ', ped_block]);
          WriteLn(['ped_blk_count: ', ped_blk_count]);
          Write('Parts: ');
          BitNr := 0;
          for j := 0 to 7 do
            begin
              pn := Bits(part_number[j div 4], BitNr, 4);
              if BitNr >= 16 then
                BitNr := 0;
              Write([pn, ' ']);
            end;
          WriteLn;
          WriteLn(['Copyright: ', CopyRight]);
          Write(['SEX: ', Sex, '[']);
          if Sex = 1 then
            Write('LEAST')
          else
            Write('MOST');
          Write(' significant byte first]');
          WriteLn(['  NEXT PAGE: ', Next_Dict]);
        end;
      WriteLn(Format('Segment Dictionary: [Addr: %s]', [BothWays(Addr)]));
    end;
end;

{$IfDef DumpSegDict2}
procedure TfrmPSysDebugWindow.DumpSegDict2(OffSet0: word; ShowPAddr: boolean);
var
  OffSet: word;
//Seg_Dict: TSeg_Dict;
begin { DumpSegDict2 }
  OffSet := Offset0;
  DumpMem( 'Segment Dictionary Code Stuff', 'WB', Offset,
           SizeOf(TDiskInfoArray),
           SizeOf(TSeg_code_rec) * 4,
           ShowPAddr);
  Offset := Offset + SizeOf(TDiskInfoArray);
                                                                                                                        
  DumpMem('Seg_Name', 'BA', OffSet,
          SizeOf(TSegNameArray),
          SizeOf(TSegment_name),
          ShowPaddr);
  offSet := Offset + SizeOf(TSegNameArray);
(*
  DumpMem('Seg_Misc', 'BWA', OffSet,
          SizeOf(TSegMiscArray),  // total number of bytes
          SizeOf(seg_misc_rec),   // bytes per element
          ShowPaddr);
*)
  offset := offset + SizeOf(TSegMiscArray);
(*
  DumpMem('Seg_Text', 'BWH', OffSet,
          SizeOf(TSegTextArray),  // total number of bytes
          SizeOf(integer)*8,       // items per row
          ShowPaddr);
*)
  offset := offset + SizeOf(TSegTextArray);

  DumpMem('Seg_Info', 'BWH', OffSet,
          SizeOf(TSegInfoArray),  // total number of bytes
          16,                      // items per row
          ShowPaddr);    
  offset := offset + SizeOf(TSegInfoArray);
(*
  DumpMem('Family_Info. Size='+IntToStr(SizeOf(TSegFamilyArray)), 'BWHA', OffSet,
          SizeOf(TSegFamilyArray),  // total number of bytes
          8,                        // items per row
          ShowPaddr);
*)
  offset := offset + SizeOf(TSegFamilyArray);
(*
  DumpMem('Misc', 'BWDA', Offset,
          SizeOf(integer)*6,
          6,
          ShowPaddr);
*)
  offset := offset + (SizeOf(integer) * 6);

  DumpMem('Part_Number', 'BWA', Offset,
          SizeOf(Seg_Dict.part_number),   // total number of bytes
          4,
          ShowPaddr);
  offset := offset + (SizeOf(Seg_Dict.part_number));
(*
  DumpMem('CopyRight', 'BA', OffSet,
          SizeOf(Seg_Dict.CopyRight),  // total number of bytes
          32,
          ShowPaddr);
*)
//offset := offset + (SizeOf(Seg_Dict.CopyRight));
(*
  DumpMem('Sex', 'BWD', OffSet,
          SizeOf(Integer),
          SizeOf(Integer),
          ShowPaddr); // only a single item
*)
//OffSet := OffSet + SizeOf(Integer);

(*
  WriteLn(['Offset=', OffSet-Offset0]);
  WriteLn(['SizeOf(Seg_dict)=', SizeOf(Seg_Dict)]);
  WriteLn(Format('Segment Dictionary: [Addr: %s]', [HexWord(Offset0)]));
  WriteLN;
*)
end;  { DumpSegDict2 }
{$EndIf DumpSegDict2}

function TfrmPSysDebugWindow.GetWordAt(P: word): word;
begin
  with fInterpreter as TIVPsystemInterpreter do
    if not Odd(p) then
      result := Words^[p div 2]
    else
      raise Exception.CreateFmt('GetWordAt passed an ODD address: %d', [p]);
end;


Procedure TfrmPSysDebugWindow.ShowStack(address: word);  {only for debugging}
var i,j: word;
    hex: string;
    lc : word;
    SaveRow, SaveCol: word;
    Wd: TUnion;
    Temp: string[2];

  function FixChars(s: Str2): string;
  var
    i: integer;
  begin
    result := 'xx';
    for i := 0 to 1 do
      if (s[i] >= ' ') and (s[i] <= #127) then
        result[i+1] := s[i]
      else
        result[i+1] := '.';
  end;

Begin { ShowStack }
  if {EnableStackWatch1.Checked or} DebugOn then
    begin
      SaveRow := Row;
      SaveCol := Col;
      i       := 0;
      j       := 0;
      if odd(address) then
        dec(address);

      if (address + (STACK_LINES*2)) <= $FFFF then
        lc := address + (STACK_LINES*2) {lowest address is 14 bytes below TOS}
      else
        lc := $FFFF;

      GoToXY(STACK_COL, STACK_ROW);
      Write('STACK:');
      try
        while (j <= STACK_LINES) and (lc >= i) {dhd} do   {we now assume stack addresses are even and inc by 2}
          Begin
            GotoXY(STACK_COL, STACK_ROW + STACK_LINES - j+1);
            Hex     := HexWord(lc-i);
            Wd.W    := WordAt[lc-i];
            Temp    := FixChars(WD.s);
            Write([Padl(Hex,4), ' : ',
                   ThreeWays(Wd.W),
                   ' "', temp, '"']);
            if (lc-i) = address then
              write('  << TOS')  {is this correct as TOS?}
            else
              write('        ');
            inc(i,2);
            inc(j,1);
          end;
      except
        on e:Exception do
          Write(['Exception: ', e.Message]);
      end;
      GotoXY(SaveCol, SaveRow);
    end;
end;  { ShowStack }

procedure TfrmPSysDebugWindow.DisplayReg(RegName: string; RegVal: longword; OtherInfo: string = '');
begin
  GotoXY(C0, R0);
  Write([PadR(RegName + ': ', 10), BothWays(RegVal), ' ', OtherInfo]);
  R0 := R0 + 1;
end;

procedure TfrmPSysDebugWindow.DisplayReg(RegName: string; OtherInfo: string = '');
begin
  GotoXY(C0, R0);
  Write([PadR(RegName + ': ', 10), OtherInfo]);
  R0 := R0 + 1;
end;

procedure TfrmPSysDebugWindow.DisplayRegs;
(*
const
  TOPROW  = 14;
*)
begin { DisplayRegs }
  if DebugOn then
    begin
      if fInterpreter is TIVPsystemInterpreter then
        with fInterpreter as TIVPsystemInterpreter, Globals.LowMem do
          begin
            C0  := REGISTERS_COL;
            R0  := REGISTERS_ROW;
            DisplayReg('REGISTERS');
            DisplayReg('SP', SP);
            DisplayReg('AX', AX);
            DisplayReg('BP', BP);
            DisplayReg('LocalVar', LocalVar, 'MP Plus Reg');
            DisplayReg('GlobVar',  GlobVar,  'Base Plus Reg');
            DisplayReg('SI', SI, 'IPC Reg');
            DisplayReg('MP', MP, 'MP Reg');
            DisplayReg('CurTask', CurTask);
            DisplayReg('EVEC', EVECp);
            DisplayReg('EREC', ERECp);
            DisplayReg('SEGB', SEGB);
            DisplayReg('ES', ES);
            DisplayReg('DS', DS);
            DisplayReg('CURPROC', CURPROC);
            DisplayReg('SEXFLAG', SEXFLAG);
            DisplayReg('SEGTOP', SEGTOP);
            DisplayReg('CPOffset', CPOffset);
            DisplayReg('ProcBase', ProcBase);
          end;
    end;
end;  { DisplayRegs }


procedure TfrmPSysDebugWindow.DisplayTIB(Addr: longword; UseGotoXY: boolean = true);
//const
//TOPROW = 35;
//LEFTCOL = LEFTOFFSET + 50;
//LEFTCOL = GROUP1_COL;
var
  TIB: TTib;

  procedure WriteLine(aCaption: string; aValue: string);
  begin
    GotoXY(C0, R0);
    Write(aCaption); Write(aValue);
    R0 := R0 + 1;
  end;

begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        Move(Bytes^[Addr], TIB, SizeOf(TIB));
        R0 := TIB_ROW;
        C0 := TIB_COL;
        WriteLine('TIB @ ', BothWays(Addr));
        with TIB do
          begin
            with Regs do
              begin
                WriteLine('wait_q    [ 0] = ', BothWays(wait_q));
                WriteLine('prior     [ 2] = ', BothWays(prior));
                WriteLine('flags     [ 3] = ', BothWays(flags));
                WriteLine('sp_low    [ 4] = ', BothWays(sp_low));
                WriteLine('sp_upr    [ 6] = ', BothWays(sp_upr));
                WriteLine('sp        [ 8] = ', BothWays(sp));
                WriteLine('mp        [10] = ', BothWays(mp));
                WriteLine('task_link [12] = ', BothWays(task_link));
                WriteLine('ipc       [14] = ', BothWays(ipc));
                WriteLine('env       [16] = ', BothWays(env));
                WriteLine('ProcNum   [18] = ', IntToStr(procnum));
                WriteLine('TibIoResult[19]= ', IntToStr(tibioresult));
                WriteLine('hang_p    [20] = ', BothWays(hang_p));
                WriteLine('m_depend  [22] = ', IntToStr(m_depend));
              end;

            WriteLine(    'main_task      = ', IntToStr(Ord(task_stuff and 1)));   // bit 0: right-most bit
            WriteLine(    'system_task    = ', IntToStr(Ord((task_stuff shr 1) and 1))); // bit 1:
            WriteLine(    'start_mscw     = ', Bothways(Start_MSCW));
            WriteLine (    '', '');
          end;
      end;
end;

function TfrmPSysDebugWindow.GetAddress( aCaption: string;
                                         var Addr: longword;
                                         var DoDisplayAsAddress: boolean;
                                         var DoUseDecimalOffsets: boolean;
                                         var TheFormsToUse: string;
                                         ShowCheckBox: boolean = false;
                                         ShowFormsToUse: boolean= false): boolean;
var
  AddrStr: string;
  OK: boolean;
  mr: integer;
begin
  frmGetStartingAddress := TfrmGetStartingAddress.Create(self);
  try
    AddrStr := '$' + HexWord(Addr);
    with frmGetStartingAddress do
      begin
        cbUseDecimalOffsets.Visible := ShowCheckBox;
        leFormsToUse.Visible        := ShowFormsToUse;
        DisplayAsAddress            := DoDisplayAsAddress;
        UseDecimalOffsets           := DoUseDecimalOffsets;
        StartIngAddress             := Addr;
        FormsToUse                  := TheFormsToUse;
        repeat
          mr := ShowModal;
          if mr = mrOk then
            begin
              Addr                := StartingAddress;
              DoUseDecimalOffsets := UseDecimalOffsets;
              DoDisplayAsAddress  := DisplayAsAddress;
              TheFormsToUse       := FormsToUse;
              OK                  := true;
              if fInterpreter is TCustomPsystemInterpreter then
                with fInterpreter as TCustomPsystemInterpreter do
                  if not Word_Memory then
                    OK := not Odd(Addr);
              if not OK then
                Alert('Must be an even address');
            end
          else
            begin
              OK := false;
              Exit;
            end;
        until OK;
        result := true;
      end;
  finally
    FreeAndNil(frmGetStartingAddress);
  end;
end;



procedure TfrmPSysDebugWindow.DisplaySIB( Addr: longword);
const
//LEFTCOL = GROUP1_COL;
  CAPTIONWIDTH = 10;
//  COLWIDTH = 35;
var
  SIB: TSib;
(*
  TSib        = record
{ 0}             seg_pool:  TShortPtr; // poolptr;        {0 SIBPOOL: pointer to code pool descrptr}
{ 2}             seg_base:  TShortPtr; // mem_ptr;        {1 SIBBASE: Base memory location}
{ 4}             seg_refs:  integer;                      {2 SIBREFS: number of active calls}
{ 6}             timestamp: integer;                      {3 SIBTIME: Memory swap priority}
{ 8}             seg_pieces: TShortPtr; // ^c_file_struct; {4 SIBPIECE: describes code file structure}
{10}             residency: p_locked..Mmaxint;             {5           memory residency status}
{12}             seg_name:  alpha;                         {6 SIBNAME: Segment name}
{20}             seg_leng:  integer;                       {10 SIBRES: number of words in segment}
                 { If seg_pieces is NIL, seg_addr is a disk address and the
                   segment is contiguous, otherwise it is a relative block
                   number within the code file and seg_pieces points to a
                   structure describing its extents. }
{22}             seg_addr:  integer;        {11 Disk address of segment}
{24}             vol_info:  TShortPtr; // vip;            {12 Disk unit and vol id of segment}
{26}             data_size: integer;        {13 Number of words in data segment}
{28}             res_sibs:  record          {Code Pool management record}
{30}                          next_sib,         {15 Pointer to next sib}
{28}                          prev_sib: TShortPtr; // sib_p;  {14 Pointer to previous sib}
                                case boolean of {Scratch area}
{32}                              true:  (next_sort: TShortPtr {sib_p});   {16}
{32}                              false: (new_loc: TShortPtr {mem_ptr});   {16}
                              end {res_sibs};
{34}              mtype:     integer;        {17 Machine type of segment}
{36}           end {sib};
*)
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
begin { DisplaySIB }
{$R-}
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        R0 := SIB_ROW;
        C0 := SIB_COL;
        WriteLine('SIB @ addr', CAPTIONWIDTH, BothWays(Addr));
        Move(Bytes^[Addr], SIB, SizeOf(SIB));
        with SIB do
          begin
            WriteLine('seg_pool', CAPTIONWIDTH, BothWays(seg_pool));
            WriteLine('seg_base', CAPTIONWIDTH, BothWays(seg_base));
            WriteLine('seg_refs', CAPTIONWIDTH, seg_refs);
            WriteLine('timestamp', CAPTIONWIDTH, timestamp);
            WriteLine('seg_pieces', CAPTIONWIDTH, seg_pieces);
            WriteLine('residency', CAPTIONWIDTH, residency);
            WriteLine('seg_name', CAPTIONWIDTH, seg_name);
            WriteLine('seg_leng', CAPTIONWIDTH, seg_leng);
            WriteLine('seg_addr', CAPTIONWIDTH, seg_addr);
            WriteLine('vol_info', CAPTIONWIDTH, ThreeWays(vol_info));
            WriteLine('data_size', CAPTIONWIDTH, data_size);
            with res_sibs do
              begin
                WriteLine('next_sib', CAPTIONWIDTH, HexWord(next_sib));
                WriteLine('prev_sib', CAPTIONWIDTH, HexWord(prev_sib));
              end;
            WriteLine('mtype', CAPTIONWIDTH, mtype);
          end;
      {$R+}
      end;
end; { DisplaySIB }


procedure TfrmPSysDebugWindow.ProcCodeForProcedureNumber(Addr: word;
                                                         ProcNumber: word);
var
  ProcPtrOffset, AddrOfNumberProcedures, NumberOfProcedures, ProcPtrAddr,
//SegTop,
  ProcOffset, ProcCode : word;
  SegName: string[8];
  Msg: string;
begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        ClrScr;
        SetLength(Segname, 8);
        Move(Bytes^[Addr+4], SegName[1], 8);
        WriteLn(['Segment ', SegName, ' located at: ', HexWord(Addr)]);

        ProcPtrOffset               := WordAt[Addr] * 2;    // * 2 (convert word offset to byte offset)
        Write('Proc Dict Pointer Offset= '); WriteLn(HexWord(ProcPtrOffset));

        AddrOfNumberProcedures      := Addr+ProcPtrOffset;

        Write('Addr of number of procs = '); WriteLn(HexWord(AddrOfNumberProcedures));

        NumberOfProcedures          := WordAt[AddrOfNumberProcedures];
        Write('Number of Procedures    = '); WriteLn(NumberOfProcedures);

        ProcPtrAddr                 := AddrOfNumberProcedures - (ProcNumber*2);
        Write(Format('Proc # %2d pointer = ', [ProcNumber]));
                                             WriteLn(HexWord(ProcPtrAddr));

        ProcOffset                    := WordAt[ProcPtrAddr];
        Write(Format('# %2d byte offset  = ', [ProcNumber]));
                                             WriteLn(HexWord(ProcOffset));

        ProcOffset                    := ProcOffset * 2;
        Write(Format('# %2d word offset  = ', [ProcNumber]));
                                             WriteLn(HexWord(ProcOffset));

        ProcCode                    := Addr + ProcOffset;
        Write(Format('Proc # %2d code    = ', [ProcNumber]));
                                             WriteLn(HexWord(ProcCode));
      end;
  (*
    with Interpreter as TPSystemInterpreter do
      ProcCode := StartingIPCofProcNumber(SegB, BP);   // <======= DEBUG =====
    Write(Format('PROC # %2d code    = ', [ProcNumber]));
                                         WriteLn(HexWord(ProcCode));
    Msg := Format('Proc #%d code starting at address %s',
                  [ProcNumber, HexWord(ProcCode)]);
  *)
    DumpMem(Msg, 'bwa', ProcCode, 256, 16, true);

end;

procedure TfrmPSysDebugWindow.DumpCodeSeg( Addr: longword;
                                           DumpProcPtrs: boolean = false);
const
//LEFTCOL = LEFTOFFSET + 50;
//LEFTCOL = GROUP3_COL;
  TOPROW  = 0;
  CAPTIONWIDTH = 20;
  PROCNAMESROW = 15;
  COLWIDTH = 35;
var
  ProcPtrOffset,
  RelocListOffset,
  ByteSex: word;
  
  ConstPoolOffset,
  AddrOfNumberOfRealConstants,
  AddrOfNumberProcedures,
  ConstPoolPtrAddr,
  ProcPtrAddr: longword;

  NumberOfProcedures,
  RealSubPoolOffset,
  RealSize,
  NumberOfRealConstants,
  SizeOfConstantPool,
  RealSizeOffset: word;

  SegName: string[8];
  TheProcName: string;
  i: word;

  procedure SetRowCol;
  begin
    if R0 >= (MaxRows-1) then
      begin
        R0 := TOPROW;
        C0 := C0 + COLWIDTH;
      end;
  end;

  procedure WriteLine( Addr: longword;
                       const Cap: string;
                       CaptionWidth: integer;
                       Value: longint;
                       NoAddr: boolean = false); overload;
  var
    Line: string;
  begin
    GotoXY(C0, R0);

    if not NoAddr then
      Line := Format('%4.4x: %-*s %d', [Addr, CaptionWidth, Cap, Value])
    else
      Line := Format('      %-*s %d', [CaptionWidth, Cap, Value]);

    WriteLn(Line);

    R0 := R0 + 1;
  end;

  procedure WriteLine( Addr: longword;
                       const Cap: string;
                       CaptionWidth: integer;
                       const Value: string;
                       NoAddr: boolean = false); overload;
  var
    Line: string;
  begin
    GotoXY(C0, R0);

    if Addr > 0 then
      Line := Format('%4.4x: %-*s %s', [Addr, CaptionWidth, Cap, Value])
    else
      Line := Format('      %-*s %s', [CaptionWidth, Cap, Value]);

    WriteLn(Line);

    R0 := R0 + 1;
  end;


begin { TfrmPSysDebugWindow.DumpCodeSeg }
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
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

        C0 := GROUP3_COL;
        R0 := TOPROW;

        try
          if NumberOfProcedures > 255 then
            raise EInvalidNrProcs.CreateFmt('Invalid number of procedures: %d', [NumberOfProcedures]);
          SizeOfConstantPool          := ProcPtrOffset - ConstPoolOffset - (NumberOfProcedures * 2);
        except
          on e2:EInvalidNrProcs do
            begin
              GoToXY(C0, 18);
              WriteLn(e2.Message);
              NumberOfProcedures          := 0;
              SizeOfConstantPool          := 0;        // keep the compiler happy
            end;
        end;
      (*
        ConstantPoolAddrBAD         := Addr + ConstPoolOffset;
        with Interpreter as TPSystemInterpreter do
          Assert(CpOffset = ConstPoolOffset);

        Assert(ConstantPoolAddress(Addr) = ConstantPoolAddr,
          Format('Constant Pool Addr Validity Failure %s <> %s',
                  [HexWord(ConstantPoolAddress(Addr)), HexWord(ConstantPoolAddr)]));
      *)
      //WriteLine('Code Segment loc',  Addr);
        WriteLine(0,      'CODE SEGMENT @',   CAPTIONWIDTH, BothWays(Addr), true);

        // alternate way of displaying it just for comparison
  //    WriteLn(MemDumpDW(Addr, wt_SegBaseInfo));
  //    R0 := R0 + 1;

        WriteLine(Addr,    'ProcDict Offset',  CAPTIONWIDTH, BothWays(ProcPtrOffset));
        WriteLine(Addr+2,  'Reloc List Offs',  CAPTIONWIDTH, RelocListOffset);
        WriteLine(Addr+4,  'Segment Name',     CAPTIONWIDTH, SegName);
        WriteLine(Addr+12, 'Byte Sex',         CAPTIONWIDTH, ByteSex);
        WriteLine(ConstPoolPtrAddr,
                           'Const Pool Offs',  CAPTIONWIDTH, BothWays(ConstPoolOffset));
        WriteLine(0,      'Const Pool Addr',  CAPTIONWIDTH, BothWays(ConstantPoolAddress(Addr)), true);
        WriteLine(0,      'Size Const Pool',  CAPTIONWIDTH, SizeOfConstantPool, true);
        WriteLine(AddrOfNumberOfRealConstants,
                           'Nr of Real const', CAPTIONWIDTH, NumberOfRealConstants);
        WriteLine(Addr+RealSizeOffset,    'Real Size',        CAPTIONWIDTH, RealSize);
        WriteLine(0,      'Real Subp Offs',   CAPTIONWIDTH, Bothways(RealSubPoolOffset), true);
        WriteLine(AddrOfNumberProcedures,
                           'Number of Proc',   CAPTIONWIDTH, NumberOfProcedures);

        if DumpProcPtrs then
          begin
            TheProcName    := PadL('#', 2) + ': ' + 'Addr [DAddr]';

  //        R0 := PROCNAMESROW;
            R0 := R0 + 1;

            WriteLine(0, TheProcName, CAPTIONWIDTH, ' Offset to Proc Code', true);
            for i := 1 to NumberOfProcedures do
              begin
                SetRowCol;
                ProcPtrAddr := AddrOfNumberProcedures - ((i-1)*2)-2;  // +2: 3/14/2023 - just testing
                TheProcName    := PadL(i, 2) + ': ' + BothWays(ProcPtrAddr);

                WriteLine(0, TheProcName, CAPTIONWIDTH, BothWays(WordAt[ProcPtrAddr]), true);
              end;
            for i := NumberOfProcedures + 1 to fLastNumberOfProcedures do
              begin
                SetRowCol;
                WriteLine(0, '', CAPTIONWIDTH, Padr('', 12), true);
              end;
            fLastNumberOfProcedures := NumberOfProcedures;
          end;
      end;
  Application.ProcessMessages;
end;  { TfrmPSysDebugWindow.DumpCodeSeg }

function TfrmPSysDebugWindow.ConstantPoolAddress(Addr: longword): longword;
begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      result            := Addr + Globals.Lowmem.CpOffset;
end;

procedure TfrmPSysDebugWindow.DisplayConstantPool(addr: longword; maxbytes: word = 0);
var
  ProcPtrOffset,
  ConstPoolOffset, NumberOfProcedures,
  SizeOfConstantPool: word;

  ConstantPoolAddr,
  AddrOfNumberProcedures,
  ConstPoolPtrAddr: longword;

  SegName: string[8];
begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        ProcPtrOffset               := WordAt[Addr] * 2;    // * 2 (convert word offset to byte offset)
        SetLength(Segname, 8);
        Move(Bytes^[Addr+4], SegName[1], 8);
        ConstPoolPtrAddr            := Addr + SEGCONST_;
        // (proc dict ptr) + (reloc list ptr) + (name of segment) + (byte sex indicator)
        ConstPoolOffset             := WordAt[ConstPoolPtrAddr] * 2;
        AddrOfNumberProcedures      := Addr+ProcPtrOffset;
        try
          NumberOfProcedures          := WordAt[AddrOfNumberProcedures];
        except
          NumberOfProcedures          := 0;
        end;
        SizeOfConstantPool          := ProcPtrOffset - ConstPoolOffset - (NumberOfProcedures * 2);
        ConstantPoolAddr            := Addr + Globals.Lowmem.CpOffset;

        ClrScreen;
        WriteLn(['Code Segment located at ', HexWord(Addr)]);

        Write('Proc Dict Pointer Offset= '); WriteLn(BothWays(ProcPtrOffset));

        Write('Segment Name            = '); WriteLn(SegName);

        Write('Const Pool Offset       = '); WriteLn(BothWays(ConstPoolOffset));

        Write('Size of Constant Pool   = '); WriteLn(BothWays(SizeOfConstantPool));
        if MaxBytes > 0 then
          if SizeOfConstantPool > MaxBytes then
            SizeOfConstantPool := MaxBytes;
        DumpMem('Main Constant SubPool', 'WBA', ConstantPoolAddr, SizeOfConstantPool, 16, TRUE);
      end;
end;


procedure TfrmPSysDebugWindow.WriteLine(aCaption: string; CaptionWidth: word; aValue: longword);
begin
  GotoXY(C0, R0);
  Write([Padr(aCaption, CAPTIONWIDTH), ': ', BothWays(aValue)]);
  R0 := R0 + 1;
end;

procedure TfrmPSysDebugWindow.WriteLine(aCaption: string; CaptionWidth: word; aValue: string = '');
begin
  GotoXY(C0, R0);
  Write([Padr(aCaption, CAPTIONWIDTH), ': ', aValue]);
  R0 := R0 + 1;
end;

procedure TfrmPSysDebugWindow.DisplayErec( addr: longword);
const
  CAPTIONWIDTH = 11;
//LEFTCOL = GROUP1_COL;
  TOPROW    = 1;
var
(*
      TErec      = record     {Environment record}
{ 0}                 env_data: mem_ptr;     {Pointer to base data segment}
{ 2}                 env_vect: e_vec_p;     {Pointer to environment vector}
{ 4}                 env_sib:  sib_p;       {Pointer to associated segment}
                     case boolean of        {Outer block information}
{ 6}                     true: (link_count: integer;
                                next_rec: e_rec_p);
{ 8}               end; {e_rec}
*)
  Erec: TErec;
begin
{$R-}
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        move(Bytes^[addr], EREC, sizeOf(TErec));
        R0 := TOPROW;
        C0 := GROUP1_COL;
        WriteLine('EREC @', CAPTIONWIDTH, BothWays(Addr));
        with EREC do
          begin
            WriteLine('env_data',   CAPTIONWIDTH, BothWays(env_data));
            WriteLine('env_vect',   CAPTIONWIDTH, BothWays(env_vect));
            WriteLine('env_sib',    CAPTIONWIDTH, BothWays(env_sib));
            WriteLine('link_count', CAPTIONWIDTH, BothWays(link_count));
            WriteLine('next_rec',   CAPTIONWIDTH, BothWays(next_rec));
            Application.ProcessMessages;
          end;
      end;
{$R+}
end;

procedure TfrmPSysDebugWindow.DisplayEvec(Addr: longword; aCaption: string = '');
var
  Evec: TEvec;
  i: integer;
  temp: string;
(*
TEvec      = record     {Environment vector}
{ 0}                 VECT_LENGTH: integer;
{ 2}                 map: array[1..1] of e_rec_p;   {Accessed $R-}
                   end {e_vec};begin
*)
begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        GotoXY(EVEC_COL, EVEC_ROW);
        move(Bytes^[Addr], Evec, SizeOf(TEvec));
        if aCaption <> '' then
          WriteLn(['Called from: ', Padr(aCaption, 20)]);
        GotoXY(EVEC_COL, EVEC_ROW+1);
        WriteLn(['EVEC is located at addr ', Bothways(Addr)]);
        with Evec do
          begin
            GoToXY(EVEC_COL, EVEC_ROW+2);
            WriteLn(['VECT_LENGTH  = ', VECT_LENGTH]);
      {$R-}
            for i := 1 to VECT_LENGTH do
              begin
                temp := Format('%4.4x: Map[%2d] = %4.4x', [Addr+(2*i), i, WordAt[Addr+(2*i)]]);
                GotoXY(EVEC_COL, EVEC_ROW+2+I);
                WriteLn(temp);
              end;
            temp := Padr('', GROUP2_COL - GROUP1_COL);
            for i := VECT_LENGTH+1 to fLastVectLen do
              begin
                GotoXY(EVEC_COL, EVEC_ROW+2+I);
                WriteLn(temp);
              end;
            fLastVectLen := VECT_LENGTH;
      {$R+}
          end;
      end;
end;

procedure TfrmPSysDebugWindow.DisplayEvec2(Addr: word);
const
  TOPROW = 3;
//LEFTCOL = GROUP3_COL;
var
  Evec: TEvec;
  i: integer;
  temp: string;
  R: INTEGER;
(*
TEvec      = record     {Environment vector}
{ 0}                 VECT_LENGTH: integer;
{ 2}                 map: array[1..1] of e_rec_p;   {Accessed $R-}
                   end {e_vec};begin
*)
begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        R := EVEC_ROW;
  //    C := EVEC_COL;
        move(Bytes^[Addr], Evec, SizeOf(TEvec));   // this only copies the 1st 2 words
        GotoXY(EVEC_COL, R); inc(R);
        Write(['EVEC is located at addr ', HexWord(Addr)]);
        with Evec do
          begin
            GoToXy(EVEC_COL, R); inc(R);
            Write(['VECT_LENGTH  = ', VECT_LENGTH]);
      {$R-}
            for i := 1 to VECT_LENGTH do
              begin
                GoToXy(EVEC_COL, R);
                temp := Format('Map[%2d] = %x', [i, WordAt[Addr+(2*i)]]);
                Write(temp);
                inc(R);
              end;
      {$R+}
          end;
      end;
end;

procedure TfrmPSysDebugWindow.DisplayMSCW( addr: longword;
                                           aCaption: string = '');
var
  MSCW: TMscw;

  procedure WriteLine(anAddr: word; aCaption: string; aValue: word);
  begin
    GotoXY(C0, R0);
    Write([HexWord(anAddr),  ': ', Padr(aCaption, 10), ' = ', BothWays(aValue)]);
    R0 := R0 + 1;
  end;

begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        move(Bytes^[addr], MSCW, SizeOf(TMSCW));

        GotoXY(MSCW_COL, MSCW_ROW);
        if aCaption <> '' then
          Write(aCaption)
        else
          Write('??? NO CAPTION');
        GotoXY(MSCW_COL, MSCW_ROW+1);
        Write(['MSCW is located at addr ', BothWays(Addr)]);
        C0       := MSCW_COL;
        R0       := MSCW_ROW+2;
        with MSCW do
          begin
            WriteLine(Addr+0, 'StatLink', STATLINK);
            WriteLine(Addr+2, 'DynLink',  DYNLINK);
            WriteLine(Addr+4, 'MSIPC',    MSIPC);
            WriteLine(Addr+6, 'MSENV',    MSENV);
            WriteLine(Addr+8, 'MSPROC',   MSPROC);
          end;
      end;
end;


(*
procedure TfrmPSysDebugWindow.SIBClick(Sender: TObject);
var
  Addr: longword;
begin
  inherited;
  if GetAddress('SIB address', Addr, fDisplayAsAddress, fUseDecimalOffsets) then
    DisplaySIB(Addr);
end;
*)

(*
procedure TfrmPSysDebugWindow.DumpProcedure1Click(Sender: TObject);
var
  Addr: longword;
begin
  inherited;
  if GetAddress('Code Segment Address', Addr, fDisplayAsAddress, fUseDecimalOffsets) then
    DumpCodeSeg(Addr);
end;
*)

(*
procedure TfrmPSysDebugWindow.PrinttoFile1Click(Sender: TObject);
var
  i: integer;
  FilePath: string;
  OutFile: TextFile;
begin
  inherited;
  FilePath := 'DebugWindow.txt';
  if BrowseForFile('Output File Name', FilePath, EXTENSION_TXT) then
    begin
      AssignFile(OutFile, FilePath);
      rewrite(OutFile);
      for i := 0 to MaxRows-1 do
        System.WriteLn(OutFile, TrimRight(fScreenBuf[i]));
      CloseFile(OutFile);
      if YesFmt('Open "%s"?', [FilePath]) then
        if not ExecAndWait(FilePath, '', false) then
          AlertFmt('Cannot open "%s', [FilePath]);
    end;
end;
*)

procedure TfrmPSysDebugWindow.Dashboard1Click(Sender: TObject);
begin
  inherited;
  Dashboard1.Checked := true;
  ClrScreen;
  RepaintDisplay;
end;

procedure TfrmPSysDebugWindow.DisplayConstantPool1Click(Sender: TObject);
begin
  inherited;
  DisplayConstantPool1.Checked := true;
  ClrScreen;
  RepaintDisplay;
end;

procedure TfrmPSysDebugWindow.MemoryDump1Click(Sender: TObject);
begin
  inherited;
  MemoryDump1.Checked := true;
  fTheFormsToUse      := 'BWA';
  if GetAddress('Starting address', fDumpAddr, fDisplayAsAddress, fUseDecimalOffsets, fTheFormsToUse, true, true) then
    begin
      ClrScr;
      RepaintDisplay;
    end;
end;

procedure TfrmPSysDebugWindow.DisplayInternalPMachineValues1Click(
  Sender: TObject);
begin
  inherited;
  DisplayInternalPMachineValues1.Checked := true;
  ClrScreen;
  RepaintDisplay;
end;

procedure TfrmPSysDebugWindow.FromTIB1Click(Sender: TObject);
begin
  inherited;
  FromTIB1.Checked := true;
  ClrScreen;
  RepaintDisplay;
end;

procedure TfrmPSysDebugWindow.DisplayEVECChain1Click(Sender: TObject);
begin
  inherited;
  if fInterpreter is TIVPsystemInterpreter then
    begin
      with fInterpreter as TIVPsystemInterpreter do
        fDumpAddr := Globals.Lowmem.EVECp;

      fEVECList := TLIst.Create;
      fERECList := TList.Create;
      if GetAddress('EVEC root address', fDumpAddr, fDisplayAsAddress, fUseDecimalOffsets, fTheFormsToUse) then
        try
          ClrScr;
          DumpChain(fDumpAddr, fEVECList, fERECList);
          PrintEVECList(fEvecList);
        finally
          FreeAndNil(fERECList);
          FreeAndNil(fEVECList);
        end;
    end;
end;

procedure TfrmPSysDebugWindow.EnableStackWatch1Click(Sender: TObject);
begin
  inherited;
  EnableStackWatch1.Checked := not EnableStackWatch1.Checked;
end;

procedure TfrmPSysDebugWindow.Debugon1Click(Sender: TObject);
begin
  inherited;
  DebugOn1.Checked := not DebugOn1.Checked;
end;

procedure TfrmPSysDebugWindow.ClearScreen1Click(Sender: TObject);
begin
  inherited;
  ClrScr;
end;

procedure TfrmPSysDebugWindow.NextPage1Click(Sender: TObject);
begin
  inherited;
  if fDumpAddr > 0 then
    begin
      fDumpAddr := fDumpAddr + BLOCKSIZE;
      ClrScreen;
      RepaintDisplay;
    end
  else
    SysUtils.Beep;
end;

procedure TfrmPSysDebugWindow.PrevPage1Click(Sender: TObject);
begin
  inherited;
  if fDumpAddr > 0 then
    begin
      fDumpAddr := fDumpAddr - BLOCKSIZE;
      ClrScreen;
      RepaintDisplay;
    end
  else
    SysUtils.Beep;
end;

procedure TfrmPSysDebugWindow.EVECdump1Click(Sender: TObject);
begin
  inherited;
  if GetAddress('EVEC address', fDumpAddr, fDisplayAsAddress, fUseDecimalOffsets, fTheFormsToUse) then
    begin
      ClrScr;
      DoEvecDump(fDumpAddr);
    end;
end;

procedure TfrmPSysDebugWindow.SetDebugOn(const Value: boolean);
begin
  DebugOn1.Checked := Value;
  ClrScr;
end;


function TfrmPSysDebugWindow.CheckForClrScreenNeeded(): boolean;
begin
  result := false;
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter, Globals.Lowmem do
      begin
        if SEGB <> fLastSEGB then
          result := true else
        if CurTask <> fLastCurTask then
          result := true else
        if ERECp <> fLastERECp then
          result := true else
        if EVECp <> fLastEVECp then
          result := true else
        if SIBp <> fLastSIBp then
          result := true;

        fLastSEGB    := SEGB;
        fLastCurTask := CurTask;
        fLastERECp   := ERECp;
        fLastEVECp   := EVECp;
        fLastSIBp    := sibP;
      end else
  if fInterpreter is TUCSDInterpreter then
    begin
      if DisplayLoadedSegments1.Checked then
        result := true;
      if DisplaySegmentLoads1.Checked then
        result := true;
    end;
end;

constructor TfrmPSysDebugWindow.Create( aOwner: TComponent;
                                        Heading: string;
                                        aTop, aLeft: integer;
                                        aMaxRows, aMaxCols: integer;
                                        aInterpreter: TObject;
                                        Debugger: TfrmPCodeDebugger);
begin
  inherited Create(aOwner, Heading, aTop, aLeft, aMaxRows, aMaxCols);
  fInterpreter := aInterpreter;
  fDebugger    := Debugger;
  fDisplayAsAddress := true;
  // force the linker to include MemDump
  MemDumpDW(0, wt_Unknown);
  MemDumpDF(0, '');
end;

destructor TfrmPSysDebugWindow.Destroy;
begin
  fDebugger.DebuggerSettings.WindowsList.AddWindow(self, self.Caption, 0);
  inherited;
end;

procedure TfrmPSysDebugWindow.DisplayInternalPMachineValues;
begin
  if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter, Globals.LowMem do
      begin
        ClrScreen;
        GoToXY(GROUP1_COL, INTERNALVALS_ROW);
        WriteLn('Internal p-Machine values');
  // LOCATIONS TO MAKE PERMANENT THINGS STORED IN REGISTERS

        Write(' IPCSAV     = ');     WriteLn(BothWays(IPCSAV));    // PLACE TO SAVE IPC     SI Reg
        Write(' MPPLUS     = ');     WriteLn(BothWays(MPPLUS));    // MP+MSCWDISP           BX Reg
        Write(' BASEPLUS   = ');     WriteLn(BothWays(BASEPLUS));  // BASE+MSCWDISP         DX Reg
        Write(' SEGB       = ');     WriteLn(BothWays(SegB));      // Segment Base          DS Reg
  //    Write(' NIPSAV     = ');     WriteLn(ThreeWays(NIPSAVE));    // NAT IP save location

  // TO HOLD WELL KNOWN P-MACHINE VALUES

        Write(' MP         = ');     WriteLn(BothWays(MP      )); // FOR CURRENT ACTIVATION RECORD
        Write(' BASE       = ');     WriteLn(BothWays(BASE    )); // of global activation record
        Write(' CURPROC    = ');     WriteLn(CURPROC ); // current procedure number
        Write(' SIBp       = ');     WriteLn(BothWays(SIBp    )); // ^Sib for current segment
        Write(' SEGTOP     = ');     WriteLn(BothWays(SEGTOP  )); // byte offset from ES: of Proc Dict
        Write(' READYQ     = ');     WriteLn(BothWays(READYQ  )); // (-3) READY QUEUE POINTER
        Write(' EVECp      = ');     WriteLn(BothWays(EVECp   )); // (-2) Pointer to Global EVec Vector
        Write(' CURTASK    = ');     WriteLn(BothWays(CURTASK )); // (-1) Current Tib Pointer

  // to hold less well known p-machine values

        Write(' ERECp      = ');   WriteLn(BothWays(ERECp   )); // ^currentEnvironmentRecord
        Write(' OLDEREC    = ');   WriteLn(BothWays(OLDEREC )); // used during environment switch
        Write(' CPOFFSET   = ');   WriteLn(BothWays(CPOFFSET)); // Constant Pool Byte Offset from ES
        Write(' SEXFLAG    = ');   WriteLn(BothWays(SEXFLAG )); // Sex of Cur Seg (1-same, 0-different)
        Write(' EXTEND     = ');   WriteLn(BothWays(EXTEND  )); // Amount of Stack needed on Fault
        Write(' PROCBASE   = ');   WriteLn(BothWays(ProcBase)); // procedure base
        Write(' IgnoreStackOverFlow = ');   WriteLn(TFString(IgnoreStackOverFlow)); // STACK OVERFLOW OK IN BLKFRM & CPF
  //    Write(' LONGADR[0] = ');   WriteLn(ThreeWays(LONGADR[0])); // LONG ADDRESS USED DURING LOW-LEVEL
  //    Write(' LONGADR[1] = ');   WriteLn(ThreeWays(LONGADR[1])); //   CALL (BOTH USER & NATIVE)
  //    Write(' SegDictP   = ');   WriteLn(ThreeWays(SegDictP  ));
  //    Write(' RootTaskP  = ');   WriteLn(ThreeWays(RootTaskP )); // pointer to RootTask TIB
  //    Write(' MainMSCWP  = ');   WriteLn(ThreeWays(MainMSCWP )); // pointer to MainMSCW
        WriteLn;

  //    Write('CurProc    = ');   WriteLn(ThreeWays(CURPROC)); // current procedure number
  //    Write('ProcCode   = ');   WriteLn(ThreeWays(ProcCode)); // pointer to ProcCode
        WriteLN;
      end;
end;

procedure TfrmPSysDebugWindow.DoEvecDump(EVECAddr: word);
var
  SegNr: word;
  Line, MapStr: string;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    with TEvecPtr(@Bytes[EVECAddr])^ do
      begin
        WriteLn(['EVEC Address: ', BothWays(EVECAddr)]);
        WriteLn(['VECT_Length:  ', BothWays(Vect_Length)]);
        if Vect_Length > 32 then
          WriteLn(['Invalid vector length: ', Vect_Length])
        else
  {$R-}
          for SegNr := 1 to Vect_Length do
            if Map[SegNr] <> 0 then
              begin
                MapStr := Format('Map[%d]: ', [SegNr]);
                Line := MemDumpDW(Map[SegNr], wt_ERECp, 0, MapStr); // The EREC
                Writeln(Line);
                Line := MemDumpDW(Map[SegNr], wt_ERECp, 1, MapStr); // The SIB
                WriteLn(Line);
//              Line := MemDumpDW(Map[SegNr], wt_ERECp, 2, MapStr); // The SegBase
//              WriteLn(Line);
              end;
  {$R+}
      end;
end;

procedure TfrmPSysDebugWindow.DumpChain(EvecAddr: word; EVECList,
  ERECList: TList);
begin
  ProcessERECChain(EvecAddr, EVECList, ERECList);
end;

function TfrmPSysDebugWindow.GetDebugOn: boolean;
begin
  result := DebugOn1.Checked;
end;

function TfrmPSysDebugWindow.MemDumpDF(Addr: longword; Form: string;
  Param: word; const Msg: string): string;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := MemDumpDF(Addr, Form, Param, Msg);
end;

function TfrmPSysDebugWindow.MemDumpDW(Addr: longword;
  WatchType: TWatchType; Param: word; const Msg: string): string;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    result := MemDumpDW(Addr, WatchType, Param, Msg);
end;

function Compare(Item1, Item2: pointer): longint;
begin
  result := word(Item1) - word(Item2);
end;

procedure TfrmPSysDebugWindow.PrintERECList(List: TList);
var
  i: integer;
  ERECADdr: word;
  Line, FilePath, Msg: string;
  OutFile: TextFile;
  OutFileName: string;
begin
  if fInterpreter is TIVPsystemInterpreter then
    begin
      List.Sort(Compare);   // sort the ERECs by address
      OutFileName := Format('%sERECList-%4.4x.txt', [FilerSettings.ReportsPath, fDumpAddr]);
      FilePath := Format(OutFileName, [fDumpAddr]);
      if YesFmt('Do you want to print to a file?', [FilePath]) then
        begin
          if BrowseForFile('ERECList FilePath', FilePath, '.txt') then
            try
              AssignFile(OutFile, FilePath);
              ReWrite(OutFile);
              system.Writeln(OutFile, 'EREC List as of ', DateTimeToStr(Now));
              with fInterpreter as TIVPsystemInterpreter do
                begin
                  for i := 0 to List.Count-1 do
                    begin
                      Msg      := Format('EREC %d: ', [i+1]);
                      ERECAddr := word(List[i]);
                      Line     := MemDumpDW(ERECAddr, wt_ERECp, 0, Msg);  // dump the EREC
                      System.WriteLn(OutFile, Line);
                      Line     := MemDumpDW(ERECAddr, wt_ERECp, 1, Msg);  // dump its SIB
                      System.WriteLn(OutFile, Line);
                      System.Writeln(OutFile);
                    end;
                end;
            finally
              CloseFile(OutFile);
              if YesFmt('Do you want to open %s', [FilePath]) then
                EditTextFile(FilePath);
            end;
        end
      else
        begin
          with fInterpreter as TIVPsystemInterpreter do
            begin
              for i := 0 to List.Count-1 do
                begin
                  ERECAddr := word(List[i]);
                  Line     := MemDumpDW(ERECAddr, wt_ERECp, 0);  // dump the EREC
                  WriteLn(Line);
                  Line     := MemDumpDW(ERECAddr, wt_ERECp, 1);  // dump its SIB
                  WriteLn(Line);
                end;
            end;
        end;
    end;
end;

procedure TfrmPSysDebugWindow.PrintEVECList(List: TList);
var
  i: integer;
  EVECAddr: word;
  Line: string;
  OutFile: TextFile;
  OutfileName: string;
begin
  if fInterpreter is TIVPsystemInterpreter then
    begin
      List.Sort(Compare);
      if Yes('Do you want to print to a file?') then
        begin
          if BrowseForFile('Output file name', OutfileName, TXT_EXT) then
            begin
              AssignFile(Outfile, OutfileName);
              rewrite(OutFile);
              system.Writeln(OutFile, 'EVEC List as of ', DateTimeToStr(Now));
              try
                with fInterpreter as TIVPsystemInterpreter do
                  begin
                    for i := 0 to List.Count-1 do
                      begin
                        EVECAddr := word(List[i]);
                        if EVECAddr <> 0 then
                          begin
                            Line     := MemDumpDW(EVECAddr, wt_EVECp, 1);  // dump the EVEC
                            System.WriteLn(OutFile, Line);
                          end;
                      end;
                  end;
              finally
                CloseFile(OutFile);
                if YesFmt('Do you want to edit %s?', [OutFileName]) then
                  EditTextFile(OutFileName);
              end;
            end;
        end
      else
        begin
          with fInterpreter as TIVPsystemInterpreter do
            begin
              for i := 0 to List.Count-1 do
                begin
                  EVECAddr := word(List[i]);
                  if EVECAddr <> 0 then
                    begin
                      Line     := MemDumpDW(EVECAddr, wt_EVECp, 1);  // dump the EVEC
                      WriteLn(Line);
                    end;
                end;
            end;
        end;
    end;
end;

procedure TfrmPSysDebugWindow.ProcessERECChain(EVECStartAddr: word; EVECList, ERECList: TList);
const
  MAXGROUPS = 20;
var
  I, Idx: integer;
  ERECAddr, EVECAddr: word;
begin
// Algorithm:
// ProcessEVEC(EVECAddress):
//   Start with EVECAddress
//     for each EREC in the vector
//       add EREC to ERECList
//       if EREC.Env_Vect <> nil then
//         ProcessEVEC(EREC.Env_Vect)  // recursively descend
//
//  PrintEVECList:
//    for ERECp in ERECList
//      PrintEREC(ERECp)
  try
   if fInterpreter is TIVPsystemInterpreter then
    with fInterpreter as TIVPsystemInterpreter do
      begin
        EVECAddr := EVECStartAddr;
        if fEVECList.IndexOf(Pointer(EVECAddr)) < 0 then  // hasn't already been processed
          begin
            EVECList.Add(pointer(EVECStartAddr));        // add it to the list of EVECs that have been processed
            with TEvecPtr(@Bytes[EVECAddr])^ do
              begin
                for i := 1 to Vect_Length do
                  begin
    {$R-}
                    ERECAddr := Map[i];
                    if ERECAddr <> pNil then
                      begin
                        idx   := fERECLIst.IndexOf(Pointer(ERECAddr));
                        if idx < 0 then   // not already in the list
                          ERECList.Add(pointer(ERECAddr));  // so add it to the list
                        with TERECPtr(@Bytes[ERECAddr])^ do
                          if env_vect <> pNil then
                            ProcessERECChain(Env_Vect, EVECList, ERECList);
                      end
    {$R+}
                  end;
              end;
          end;
      end;
  except
    on e:Exception do
      WriteLn(['Exception: ', e.message]);
  end;
end;

procedure TfrmPSysDebugWindow.RepaintDisplay(const Notice: string);
begin { RepaintDisplay}
  if CheckForClrScreenNeeded then
    ClrScreen;

  if Dashboard1.Checked then
    begin
      DisplayRegs;
      if fInterpreter is TIVPsystemInterpreter then
        with fInterpreter as TIVPsystemInterpreter, Globals.Lowmem do
          begin  // comment everything out to look for the 3/15/2023 problem with Delphi
            if SP <> 0 then
              ShowStack(SP);
            if MP <> 0 then
              DisplayMSCW(MP, 'Current Stack Frame');
            if SEGB <> 0 then
              DumpCodeSeg(SegB, TRUE);
            if CurTask <> 0 then
              DisplayTIB(CurTask);
            if ERECp <> 0 then
              DisplayErec(ERECp);
            if EVECp <> 0 then
              DisplayEvec(EVECp);
            if SIBp <> 0 then
              DisplaySIB(SIBp);
          end;
    end;

  if DisplayConstantPool1.Checked then
    begin
      if fInterpreter is TIVPsystemInterpreter then
        with fInterpreter as TIVPsystemInterpreter, Globals.LowMem do
          if SEGB <> 0 then
            DisplayConstantPool(SegB)
          else
            Write('SEGB is NIL');
    end;

  if MemoryDump1.Checked then
    DumpMem('Memory Dump', fTheFormsToUse, fDumpAddr, BLOCKSIZE, 16, fDisplayAsAddress, fUseDecimalOffsets);

  if DisplayInternalPMachineValues1.Checked then
    DisplayInternalPMachineValues;

  if FromTib1.Checked then
    if fInterpreter is TIVPsystemInterpreter then
      with fInterpreter as TIVPsystemInterpreter, Globals.LowMem do
        if CURTASK <> 0 then
          begin
            with TTIBPtr(@Bytes[CurTask])^ do
              begin
                with TERECPtr(@Bytes[Regs.env])^ do
                  DisplayEVEC(Env_Vect, 'From TIB');
              end;
          end;

  if DisplayLoadedSegments1.Checked then
    DisplayLoadedSegments;

  if DisplaySegmentLoads1.Checked then
    DisplaySegmentLoads;
end;  { RepaintDisplay }

procedure TfrmPSysDebugWindow.DisplaySegmentLoads;
var
  i: integer;
begin
  with fInterpreter as TUCSDInterpreter do
    begin
      for i := 0 to SegTopListChanges.Count-1 do
        WriteLn(SegTopListChanges[i]);
    end;
end;


procedure TfrmPSysDebugWindow.DisplayLoadedSegments;
var
  fn, NrFiles, Idx, NrBlocks, FirstBlock, LastBlock: integer;
  msg, TempName: string;
begin
  if fInterpreter is TUCSDInterpreter then
    with fInterpreter as TUCSDInterpreter do
      begin
        NrFiles    := Length(fFilesLoadedList);
        for fn := 0 to NrFiles-1 do
          with fFilesLoadedList[fn] do
            begin
              Msg := Format('FN=%2d, UnitNr=%2d, TheFileName=%s,  TheAbsFileStartingBlock=%5d',
                            [FN,     TheUnitNr,  TheFileName,     TheAbsFileStartingBlock]);
              WriteLN(Msg);
              Msg := '   #      SegName,  SegTop,   Addr,   Leng,   Blks,   1stB,  LastB,   Refs, Notice';
              WriteLN(Msg);

              for Idx := 0 to MAXSEG do
                with SegInfo[Idx] do
                  if TheCodeAddr > 0 then
                    begin
                      TempName   := TheSEGNAME;
                      NrBlocks   := (TheCodeLeng + BLOCKSIZE - 1) div BLOCKSIZE;
                      FirstBlock := TheAbsFileStartingBlock + TheCodeAddr;
                      LastBlock  := TheAbsFileStartingBlock + TheCodeAddr + NrBlocks;
                      Msg := Format('%4d  %12s, %6d, %6d, %6d, %6d, %6d, %6d, %6d, %s',
                                     [Idx, TempName, TheSEGTOP, TheCodeAddr, TheCodeLeng, NRBlocks, FirstBlock, LastBlock, TheRefCount, TheNotice]);
                      WriteLN(Msg);
                    end;
              WriteLN;
            end;
       end;
end;


procedure TfrmPSysDebugWindow.UpdateDebugWindow(aCaption: string);
begin
  if DebugOn then
    RepaintDisplay;
end;

procedure TfrmPSysDebugWindow.UpdateDebugWindow2(
  const RegisterSources: TRegsList);
begin
  with RegisterSources do
    begin
      if aCaption <> '' then
        begin
          GotoXY(80, 0);
          Write(aCaption);
        end;

      DisplayRegs;

      if SP <> 0 then
        ShowStack(SP);
      if MP <> 0 then
        DisplayMSCW(MP, 'Current Stack Frame');
      if SEGb <> 0 then
        DumpCodeSeg(SegB, false);
      if CurTask <> 0 then
        DisplayTIB(CurTask);
      if ERECp <> 0 then
        DisplayErec(ERECp);
      if SIBp <> 0 then
        DisplaySIB(SIBp);
      if EVECp <> 0 then
        DisplayEvec2(EVECp);
    end;
end;

procedure TfrmPSysDebugWindow.FormShow(Sender: TObject);
var
  dummy: integer;
begin
  inherited;
  with fDebugger.DebuggerSettings.WindowsList do
    LoadWindowInfo(self, Caption, Dummy);
end;

procedure TfrmPSysDebugWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

procedure TfrmPSysDebugWindow.DisplayLoadedSegments1Click(Sender: TObject);
begin
  inherited;
  DisplayLoadedSegments1.Checked := true;
  ClrScreen;
  RepaintDisplay;
end;

procedure TfrmPSysDebugWindow.ChoosePage1Click(Sender: TObject);
begin
  inherited;
  with fInterpreter as TCustomPsystemInterpreter do
    case VersionNr of
      vn_VersionI_4,
      vn_VersionI_5,
      vn_VersionII:
        begin
          DisplayConstantPool1.Enabled           := false;
          DisplayInternalPMachineValues1.Enabled := false;
          FromTIB1.Enabled                       := false;
          DisplayEVECChain1.Enabled              := false;
          DisplayEVECfromAddr1.Enabled           := false;
          DisplayLoadedSegments1.Enabled         := true;
          DisplaySegmentLoads1.Enabled           := true;
        end;

      vn_VersionIV:
        begin
          DisplayConstantPool1.Enabled           := true;
          DisplayInternalPMachineValues1.Enabled := true;
          FromTIB1.Enabled                       := false;
          DisplayEVECChain1.Enabled              := true;
          DisplayEVECfromAddr1.Enabled           := true;
          DisplayLoadedSegments1.Enabled         := false;
          DisplaySegmentLoads1.Enabled           := false;
        end;
//    vn_VersionIV_12:
//      { not implemented };
    end;
end;

procedure TfrmPSysDebugWindow.DisplaySegmentLoads1Click(Sender: TObject);
begin
  inherited;
  DisplaySegmentLoads1.Checked := true;
  ClrScreen;
  RepaintDisplay;
end;

procedure TfrmPSysDebugWindow.RepaintScreen1Click(Sender: TObject);
begin
  inherited;
  ClrScreen;
  RepaintDisplay;
end;

end.
