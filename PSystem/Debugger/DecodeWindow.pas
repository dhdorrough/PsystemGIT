unit DecodeWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, OpsTables, Misc, UCSDGlob, Ped_defs,
  DumpAddr, pCodeDecoderUnit;

type

  TGetMemoLists = procedure {Name} (var pCodeList, SrcCodeList: TStringList) of object;

  TfrmDecodeWindow = class(TForm)
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Utilities1: TMenuItem;
    DecodeMemory1: TMenuItem;
    Print1: TMenuItem;
    Decode1: TMenuItem;
    SearchforHexBytes1: TMenuItem;
    itmDumpSyscom: TMenuItem;
    DisplayDirectory1: TMenuItem;
    DumpMiscInfo1: TMenuItem;
    DumpPEDHeader1: TMenuItem;
    Edit1: TMenuItem;
    Find1: TMenuItem;
    lblStatus: TLabel;
    FindAgain1: TMenuItem;
    DumpEVECERECSIBS1: TMenuItem;
    N1: TMenuItem;
    ClearWindow1: TMenuItem;
    MergeSourceCodeintopCode1: TMenuItem;
    procedure DecodeMemory1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Decode1Click(Sender: TObject);
    procedure SearchforHexBytes1Click(Sender: TObject);
    procedure ClearWindow1Click(Sender: TObject);
    procedure itmDumpSyscomClick(Sender: TObject);
    procedure DisplayDirectory1Click(Sender: TObject);
    procedure DumpMiscInfo1Click(Sender: TObject);
    procedure DumpPEDHeader1Click(Sender: TObject);
    procedure MainMenu1Change(Sender: TObject; Source: TMenuItem;
      Rebuild: Boolean);
    procedure Find1Click(Sender: TObject);
    procedure FindAgain1Click(Sender: TObject);
    procedure DumpEVECERECSIBS1Click(Sender: TObject);
    procedure MergeSourceCodeintopCode1Click(Sender: TObject);
  private
    { Private declarations }
    fdirp         : word;
    fFindStart    : pchar;
    fHexStr       : string;
    fInterpreter  : TObject;
    fLastFindText : string;
    fProcNumber   : word;
//  fRelIPC       : longword;
    fAbsIPC       : longword;
    XfpCodeDecoder : TpCodeDecoder;
    fProcName     : string;
    fGetMemoLists : TGetMemoLists;
    fpCodeList, fSrcCodeList, fResultList: TStringList;

    procedure DumpSyscom(SysComP: TSysComPtr);
    procedure DumpMiscInfo(MiscInfo: TMiscInfo);
    procedure DumpPedHeader(Ped_HeaderP: TPed_HeaderPtr);
    function GetDumpaddr: TfrmDumpAddr;
    procedure SetAbsIPC(const Value: longword);
    procedure SetProcNumber(const Value: word);

    procedure AddLine(const Line: string); virtual;
    procedure AddLineSeparator(anOpCode: word); virtual;
    function SearchFor(const LookFor: string): pchar;
    function AdjustForWordMemory(Addr: longword): longword;
  public
    { Public declarations }
    property AbsIPC: longword
             read fAbsIPC
             write SetAbsIPC;
    property ProcNumber: word
             read fProcNumber
             write SetProcNumber;
    property ProcName: string
             read fProcName
             write fProcName;
    Constructor Create( aOwner: TComponent;
                        aInterpreter: TObject); reintroduce;
    Destructor Destroy; override;
    procedure MergePCodeWithSourceCode(pCodeList, SrcCodeList: TStringList);
    property OnGetMemoLists: TGetMemoLists
             read fGetMemoLists
             write fGetMemoLists;
  end;

function DecoderWindow( aOwner: TComponent;
                        aInterpreter: TComponent): TfrmDecodeWindow;

var
  frmDecodeWindow: TfrmDecodeWindow;

implementation

uses DecodeRange, MyUtils, uGetString, StStrL,
     uWatchInfo,  Interp_Decl, PsysUnit, Debug_Decl,
     pSysDatesAndTimes, pSysVolumes, Interp_Common, pCodeDecoderII,
     Interp_Const, FilerSettingsUnit, pSysExceptions, InterpIV, Watch_Decl,
     FastMM4, FileNames;

{$R *.dfm}

const
  DEF_BYTECOUNT = 1000;

function DecoderWindow( aOwner: TComponent;
                        aInterpreter: TComponent): TfrmDecodeWindow;
begin
  if not Assigned(frmDecodeWindow) then
    frmDecodeWindow := TfrmDecodeWindow.Create(aOwner, aInterpreter);
  result := frmDecodeWindow;
end;

procedure TfrmDecodeWindow.AddLine(const Line: string);
begin
  Memo1.Lines.Add(Line);
end;

function TfrmDecodeWindow.AdjustForWordMemory(Addr: longword): longword;
begin
  Result := Addr;
  if XfpCodeDecoder is TpCodeDecoderII then
    with XfpCodeDecoder as TpCodeDecoderII do
      if Word_Memory then
        result := Addr * 2;
end;


//  Decode Specified Memory 
procedure TfrmDecodeWindow.DecodeMemory1Click(Sender: TObject);
var
  Addr, Len: longword;
begin { TfrmDecodeWindow.DecodeMemory1Click }
  if not Assigned(frmDecodeRange) then
    frmDecodeRange := TfrmDecodeRange.Create(self);
  with frmDecodeRange do
    begin
      Caption := Format('Current Procedure: %d', [fProcNumber]);
      with fInterpreter as TCustomPsystemInterpreter do
        leStartingAddress.Text := '$' + HexWord(SegBot0+ProcBase);
      leNrBytes.Text         := IntToStr(DEF_BYTECOUNT);
      cbExitAfterDecode.Checked := false;
      if ShowModal = mrOk then
        begin
          Addr := ReadInt(leStartingAddress.Text);
          Len  := ReadInt(leNrBytes.Text);

          Memo1.Lines.Add(Format('Procedure #%d', [fProcNumber]));
          with XfpCodeDecoder do
            begin
              Decode(0, Len, cbStopAfterRPU.Checked, dfMemoFormat, AdjustForWordMemory(Addr));
//            GenOpline(Format('END OF DATA RANGE (Proc = %d); NrBytes = %d', [fProcNumber, fIpc-Addr]));
              if ErrorCount > 0 then
                GenOpline('Error Count = ', IntToStr(ErrorCount));
            end;
          if cbExitAfterDecode.Checked {and (fOpCode = OPCODE_RPU)} then
            Close;
        end;
    end;
end;  { TfrmDecodeWindow.DecodeMemory1Click }

constructor TfrmDecodeWindow.Create( aOwner: TComponent;
                                     aInterpreter: TObject);
begin
  inherited Create(aOwner);
  fInterpreter  := aInterpreter;
  with fInterpreter as TCustomPsystemInterpreter do
    begin
      self.AbsIPC {in the DecoderWindow} := AbsIPC {from the interpreter};
      case VersionNr of  // TpCodeDecoderII
        vn_VersionIV{, vn_VersionIV_12}:
          XfpCodeDecoder := TpCodeDecoder.Create(self, OpsTable, TRUE, VersionNr);
        vn_VersionI_4, vn_VersionI_5, vn_VersionII:
          XfpCodeDecoder := TpCodeDecoderII.Create( self,
                                                    OpsTable,
                                                    word_memory,
                                                    VersionNr);
        else
          raise EUnknownVersion.Create('Unknown version');  // version Nr not implemented
      end;
      with XfpCodeDecoder do
        begin
          OnAddLine          := AddLine;
          OnAddLineSeparator := AddLineSeparator;
          OnGetByte3         := GetByteFromMemory;
          OnGetWord3         := GetWordFromMemory;
          OnGetBaseAddress   := GetBaseAddress;
          OnGetJTAB          := GetJTAB;
          OnGetCPOffset      := GetCPOffset;
          OnGetSegmentBase   := GetSegmentBaseAddress;
        end;
    end;
end;

procedure TfrmDecodeWindow.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmDecodeWindow.Print1Click(Sender: TObject);
var
  FileName: string;
begin
  if BrowseForFile('Print to file', FileName, TXT_EXT) then
    Memo1.Lines.SaveToFile(FileName);
end;

// Decode Memory @ IPC
procedure TfrmDecodeWindow.Decode1Click(Sender: TObject);
var
  aProcName: string;
  BaseAddr: longword;
begin
  with XfpCodeDecoder do
    begin
      ErrorCount := 0;

      with fInterpreter as TCustomPsystemInterpreter do
        begin
          aProcName := ProcName(fProcNumber, SegBase);
          AddLine(Format('Procedure (%d): %s', [fProcNumber, aProcName]));
          BaseAddr := GetBaseAddress;
        end;

      AddLine('Addr (Ofs ): [opc] Op Name   Params');

      Decode(0{IPC}, DEF_BYTECOUNT, true, dfMemoFormat, AdjustForWordMemory(BaseAddr));

      if ErrorCount > 0 then
        AddLine('Error Count = ' + IntToStr(ErrorCount));
    end;
end;

procedure TfrmDecodeWindow.SearchforHexBytes1Click(Sender: TObject);
var
  wc, i, idx: cardinal;
  aWord: string;
  SearchFor: string;
  aByte: byte;
  MatchCount: integer;

  procedure CheckForMatch(idx: longword);
  var
    i, j: longword;
    aLine: string;
  begin { CheckForMatch }
    with fInterpreter as TCustomPsystemInterpreter do
      begin
        for i := 0 to length(SearchFor)-1 do
          if SearchFor[i+1] <> chr(Bytes^[Idx+i]) then
            exit;
        // found a match
        aLine := Format('%s: ', [BothWays(Idx-4)]);
        for j := Idx-4 to Idx-1 do
          aLine := aLine + HexByte(Byte(Bytes^[j])) + ' ';
        Memo1.Lines.Add(aLine);
        aLine := '';

        aLine := Format('%s: ', [BothWays(Idx)]);
        for j := 0 to Max(Length(SearchFor)-1, 20) do
          aLine := aLine + HexByte(Byte(Bytes^[Idx+j])) + ' ';
        Memo1.Lines.Add(aLine);
        aLine := '';
    (*
        aLine := Format('%s: ', [BothWays(Idx)]);
        for j := 0 to 3 do
          aLine := aLine + HexByte(Byte(Bytes^[Idx+Length(SearchFor)+j])) + ' ';
        Memo1.Lines.Add(aLine);
    *)
        inc(MatchCount);
      end;
  end;  { CheckForMatch }

begin
  if GetString('Search for Hex string', 'Hex Bytes', fHexStr) then
    begin
      wc := WordCountL(fHexStr, DELIMS);
      SetLength(SearchFor, wc);
      for i := 1 to wc do
        begin
          aWord := ExtractWordL(i, fHexStr, DELIMS);
          aByte := HexStrToWord(aWord);
          SearchFor[i] := chr(aByte);
        end;
      idx := 0; MatchCount := 0;
      while (idx + wc) < HIMEM do
        begin
          CheckForMatch(idx);
          inc(idx);
        end;
      Memo1.Lines.Add(Format('%d matches to the string (%s) were found', [MatchCount, fHexStr]))
    end;
end;

procedure TfrmDecodeWindow.ClearWindow1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TfrmDecodeWindow.DumpSyscom(SysComP: TSysComPtr);
var
  temp: string;

  procedure WriteSem(SemName: string; sem: Tsemaphore);
  begin
    Memo1.Lines.Add(SemName);
    with sem do
      begin
        Memo1.Lines.Add(Format('  sem_count   = %d', [sem_count]));
        Memo1.Lines.Add(Format('  sem_wait_q  = %d', [sem_wait_q]));
      end;
  end;

  procedure WriteFaultMessage(Fault_message: TFault_message);
  begin
(*
{0}    {18}         fault_tib: tib_p;        // points to the Task Information Block (TIB) of the faulting task.
{2}    {20}         fault_e_rec: e_rec_p;    // points to the Environment record of the current segment or of the missing segment (for segment faults).
{4}    {22}         fault_words: integer;    // is the number of words needed (e.g. for stack faults). It's 0 for segment faults.
//{6}               fault_type: seg_fault..pool_fault;
{6}    {24}         fault_type: integer;     // indicates the type of fault ($80=segment, $81=stack, heap, pool, etc).
*)
    with Fault_Message do
      begin
{$R-}
        Memo1.Lines.Add(Format('fault_tib   = %s', [BothWays(fault_tib)]));
        Memo1.Lines.Add(Format('fault_e_rec = %s', [BothWays(fault_e_rec)]));
        Memo1.Lines.Add(Format('fault_words = %s', [BothWays(fault_words)]));
        Memo1.Lines.Add(Format('fault_type  = %s', [BothWays(fault_type)]));
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

begin { DumpSyscom }
  with Memo1.Lines, SyscomP^ do
    begin
      Add(Format('SYSCOM @ %s', [DateTimeToStr(Now)]));
      Add(Format('SizeOf(TSysComRec)=%d', [SizeOf(TIVSysComRec)]));
      Add(Format('SizeOf(TMiscInfo)=%d', [SizeOf(TMiscInfo)]));
      Add(Format('IOrslt      = %d', [ORD(iorslt)]));
      Add(Format('APoolSize   = %s', [BothWays(LongWord(APoolSize))]));
      Add(Format('SysUnit     = %d', [sysunit]));
      Add(Format('Max_IO_Bufs = %d', [max_io_bufs]));
      Add(Format('gdirp       = %s', [BothWays(gdirp)]));
      fdirp := gdirp;
      with fault_sem do
        begin
          WriteSem('REAL_SEM', real_sem);
          WriteSem('MESSAGE_SEM', message_sem);
          WriteFaultMessage(Fault_Message);
        end;
      Add(Format('SubSidStart = %d', [subsidstart]));
      Add(Format('AliasMax    = %d', [AliasMax]));
      Add(Format('spool_avail = %s', [TFString(spool_avail)]));

      with poolinfo do
        begin
{$R-}
          Add(Format('pooloutside = %s', [TFString(pooloutside)]));
          Add(Format('poolsize    = %s', [BothWays(poolsize)]));
          Add(Format('poolbase    = %8.8x', [FulladdressToLongWord(PoolBaseAddr)])); // [PoolBaseAddr[0], PoolBaseAddr[1]]));
          Add(Format('resolution  = %d', [resolution]));
{$R+}
        end;

      with unitdivision do
        begin
          Add(Format('unitdivision= %d', [serialmax]));
          Add(Format('subsidmax   = %d', [subsidmax]));
        end;

      with expaninfo do
        begin
          Add(Format('insertchar  = #%d', [ord(insertchar)]));
          Add(Format('deletchar   = #%d', [ord(deletchar)]));
        end;

      if processor <= m_80187 then
        temp := processor_types[processor]
      else
        temp := 'Unknown';

//    Add(Format('[%d] processor   = %s', [Integer(@TSysComRec(nil^).processor), temp]));
      Add(Format('processor   = %s', [temp]));

      if pmachver in [pre_iv_1, iv_1, iv_2, version_Unknown] then
        temp := pMachineVersions[pmachver]
      else
        temp := 'Unknown2';

      Add(Format('pmachinevers= %s', [temp]));

      Add(Format('realsize     = %d', [realsize]));

      ADD('CRT_CTRL');
      with CrtCtrl do
        begin
          Add(Format('escape      = %s', [ToChar(escape)]));
          Add(Format('home        = %s', [ToChar(home)]));
          Add(Format('eraseeos    = %s', [ToChar(eraseeos)]));
          Add(Format('eraseeol    = %s', [ToChar(eraseeol)]));
          Add(Format('ndfs        = %s', [ToChar(ndfs)]));
          Add(Format('rlf         = %s', [ToChar(rlf)]));
          Add(Format('backspace   = %s', [ToChar(backspace)]));
          Add(Format('fillcount   = %d', [fillcount]));
          Add(Format('clearline   = %s', [ToChar(clearline)]));
          Add(Format('clearscreen = %s', [ToChar(clearscreen)]));
//        prefixed: integer; {packed array[0..8] of boolean;}
        end;

      Add('CRT_INFO');
      with CrtInfo do
        begin
          Add(Format('width       = %d', [width]));
          Add(Format('height      = %d', [height]));
          Add(Format('right       = %s', [ToChar(right)]));
          Add(Format('left        = %s', [ToChar(left)]));
          Add(Format('down        = %s', [ToChar(down)]));
          Add(Format('up          = %s', [ToChar(up)]));
          Add(Format('badch       = %s', [ToChar(badch)]));
          Add(Format('chardel     = %s', [ToChar(chardel)]));
          Add(Format('stop        = %s', [ToChar(stop)]));
          Add(Format('break       = %s', [ToChar(break)]));
          Add(Format('flush       = %s', [ToChar(flush)]));
          Add(Format('eof         = %s', [ToChar(eof)]));
          Add(Format('altmode     = %s', [ToChar(altmode)]));
          Add(Format('linedel     = %s', [ToChar(linedel)]));
          Add(Format('alphalok    = %s', [ToChar(alphalok)]));
          Add(Format('char_mask   = %s', [ToChar(char_mask)]));
          Add(Format('etx         = %s', [ToChar(etx)]));
          Add(Format('prefix      = %s', [ToChar(prefix)]));
        end;
    end;
end;  { DumpSyscom }


procedure TfrmDecodeWindow.itmDumpSyscomClick(Sender: TObject);
var
  SysComCopy: TIVSysComRec;
  Addr: word;
begin
  with GetDumpAddr do
    begin
      ShowModal;
      if ModalResult = mrOK then
        with fInterpreter as TCustomPsystemInterpreter do
          begin
            Addr := WatchAddr;
            Move(Bytes^[Addr], SysComCopy, SizeOf(TIVSysComRec));
            DumpSyscom(@SysComCopy);
          end;
    end;
end;


procedure TfrmDecodeWindow.DisplayDirectory1Click(Sender: TObject);
type
  TDirectory =
          RECORD CASE integer OF
            0: (RECTORY: ARRAY [0..MaxDIR] OF DIRENTRY);
            2: (CBLOCK: ARRAY[0..4*FBLKSIZE] OF CHAR);
          END;
var
  ADir: TDirectory;
  StartAddr: word;
  ByteCount, i: word;
begin
  with GetDumpAddr do
    begin
//    leStartingAddress.Text := IntToStr(WatchAddr);
      ShowModal;
      if ModalResult = mrOk then
      with fInterpreter as TCustomPsystemInterpreter do
        begin
          StartAddr := WatchAddr;
          ByteCount := 0;
          while ByteCount < SizeOf(ADir.RECTORY) do
            begin
              ADir.CBLOCK[ByteCount] := chr(Bytes^[StartAddr+ByteCount]);
              inc(ByteCount);
            end;
          with ADir.RECTORY[0] do
            Memo1.Lines.Add(Format('Volume name: %s, FirstBlk=%d, LastBlk=%d',
                                   [DVID, DFIRSTBLK, DLASTBLK]));
          Memo1.Lines.Add(Format('%4s. %-15s %10s %9s %9s %9s', ['#', 'File Name', 'Date', 'FirstBlk', 'LastBlk', 'LastByte']));
          for i := 1 to ADir.Rectory[0].DNUMFILES do
            with ADir.RECTORY[i] do
              Memo1.Lines.Add(Format('%4d. %-15s %10s %9d %9d %9d',
                                     [I, DTID, DateToStr(DAccessToTDateTime(DACCESS, DFKIND)), DFIRSTBLK, DLASTBLK, DLASTBYTE]));
        end;
    end;
end;

procedure TfrmDecodeWindow.DumpMiscInfo(MiscInfo: TMiscInfo); // Addr: word);
begin
//  Move(Bytes^[Addr], MiscInfo, SizeOf(MiscInfo));
  with MiscInfo do
    begin
      DumpSyscom(@S);
(*
      Line := 'sc_chset: ';
      for ch := #0 to #255 do
        if ch in c then
          Line := Line + ch;
      Memo1.Lines.Add(Line);
*)
      Memo1.Lines.Add(Format('FaultHandlerStack=', [FaultHandlerStack]));
      with Pnet_Pool do
        begin
          Memo1.Lines.Add(Format('PoolOutside= %s',     [TFString(PoolOutside)]));
          Memo1.Lines.Add(Format('PoolSize=    %d   ',  [PoolSize]));
          Memo1.Lines.Add(Format('PoolBase=    %d:%d',  [PoolBase[0], PoolBase[1]]));
          Memo1.Lines.Add(Format('PoolBase=    %d',     [FulladdressToLongWord(PoolBase)]));
        end;
      with Events do
        begin
          Memo1.Lines.Add(Format('Tick=        %s',     [TFString(Tick)]));
          Memo1.Lines.Add(Format('Asynch_Char= %s',     [TFString(Asynch_Char)]));
        end;
    end;
end;

procedure TfrmDecodeWindow.DumpMiscInfo1Click(Sender: TObject);
var
  FileName, Temp: string;
  MiscInfo: TMiscInfo;
  BlockNr: word;
  VolumeFile: file of TBlock;
  TempBuf: record
             case integer of
               0: (blk: array[0..1] of TBlock);
               1: (msc: TMiscInfo)
             end;
begin
  if Yes('Dump from memory?') then
    begin
      with GetDumpAddr do
        begin
          ShowModal;
          if ModalResult = mrOk then
          with fInterpreter as TCustomPsystemInterpreter do
            begin
//            Addr := Value(leStartingAddress.Text);
              Move(Bytes^[WatchAddr], MiscInfo, SizeOf(MiscInfo));
              DumpMiscInfo(MiscInfo);
            end;
        end;
    end
  else
    begin
      FileName := FilerSettings.VolumesFolder + 'SYSTEM4.vol';
      if BrowseForFile('File Name: ', FileName, 'vol') then
        begin
          Temp := '';
          if GetString('MiscInfo block number', 'Starting block: ', Temp) then
            begin
              BlockNr := ReadInt(Temp);
              AssignFile(VolumeFile, FileName);
              Reset(VolumeFile);
              try
                Seek(VolumeFile, BlockNr);
                Read(VolumeFile, TempBuf.Blk[0]);
                Read(VolumeFile, TempBuf.Blk[1]);
                DumpMiscInfo(TempBuf.msc);
              finally
                CloseFile(VolumeFile)
              End;
            end;
        end;
    end;
end;

procedure TfrmDecodeWindow.DumpPedHeader(Ped_HeaderP: TPed_HeaderPtr);
begin
  with Ped_HeaderP^ do
    begin
      Memo1.Lines.Add(Format('ped_byte_sex=%d', [ped_byte_sex]));
                     {PED Byte sex indicator.}

      Memo1.Lines.Add(Format('ped_format_level=%d', [ped_format_level]));
                     {PED structures version indicator.}

      Memo1.Lines.Add(Format('ped_library_count=%d', [ped_library_count]));
                     {Number of library file descriptors.}

      Memo1.Lines.Add(Format('ped_principal_segment_count=%d', [ped_principal_segment_count]));
                     {Number of principal segments described.}

      Memo1.Lines.Add(Format('ped_subsidiary_segment_count=%d', [ped_subsidiary_segment_count]));
                     {subsidiary segments described.}

      Memo1.Lines.Add(Format('ped_total_evec_words=%d', [ped_total_evec_words]));
                     {Size of EVEC templates.}

      Memo1.Lines.Add(Format('ped_last_system_segment=%d', [ped_last_system_segment]));
                     {Last global segment number assigned to identify system units.}

      Memo1.Lines.Add(Format('ped_start_unit=%d', [ped_start_unit]));
                     {Global segment number of principal segment where execution
                                 should begin.}

      Memo1.Lines.Add(Format('ped_uses_realops_unit=%s', [TFString(ped_uses_realops_unit)]));
                     {TRUE if REALOPS unit required.}
    end;
end;

function TfrmDecodeWindow.GetDumpaddr: TfrmDumpAddr;
begin
  if not Assigned(frmDumpAddr) then
    frmDumpAddr := TfrmDumpAddr.Create(self);
  result := frmDumpAddr;
end;

procedure TfrmDecodeWindow.DumpPEDHeader1Click(Sender: TObject);
var
  Ped_header: TPed_header;
begin
  with GetDumpAddr do
    begin
      ShowModal;
      if ModalResult = mrOK then
      with fInterpreter as TCustomPsystemInterpreter do
        begin
//        Addr := Value(leStartingAddress.Text);
          Move(Bytes^[WatchAddr], Ped_header, SizeOf(TPed_header));
          DumpPedHeader(@Ped_header);
        end;
    end;
end;

destructor TfrmDecodeWindow.Destroy;
begin
  FreeAndNil(fpCodeList);
  FreeAndNil(fSrcCodeList);
  FreeAndNil(fResultList);
  FreeAndNil(XfpCodeDecoder);
  inherited;
end;

procedure TfrmDecodeWindow.MainMenu1Change(Sender: TObject;
  Source: TMenuItem; Rebuild: Boolean);
begin
  if Assigned(fInterpreter) then
    with fInterpreter as TCustomPsystemInterpreter do
      Decode1.Caption := Format('Decode (%d): %s', [fProcNumber, ProcName(fProcNumber, SegBase)]);
end;

procedure TfrmDecodeWindow.AddLineSeparator(anOpCode: word);
var
  AddLineOps: set of 0..255;
begin
  with fInterpreter as TCustomPsystemInterpreter do
    with OpsTable do
      begin
        AddLineOps := Store_OPS + Jump_OPS + Call_OPS;
        if anOpCode in AddLineOPs then
          AddLine('');
      end;
end;

procedure TfrmDecodeWindow.SetAbsIPC(const Value: longword);
begin
  fAbsIPC := Value;
end;

procedure TfrmDecodeWindow.SetProcNumber(const Value: word);
begin
  fProcNumber := Value;
end;

function TfrmDecodeWindow.SearchFor(const LookFor: string): pchar;
var
  Buf: pchar;
begin
  lblStatus.Caption := '';
  Buf           := pchar(Memo1.Text);

  fFindStart    := Buf + Memo1.SelStart + Memo1.SelLength;
  if fFindStart >= (Buf+Length(Memo1.Text)) then
    fFindStart := pchar(Memo1.text);
  result   := MyStrPos(fFindStart, pchar(LookFor), Length(Memo1.Text), true);
end;


procedure TfrmDecodeWindow.Find1Click(Sender: TObject);
var
  LookFor: string;
  buf, p: pchar;
  b: boolean;
begin
  b := GetString('Target string', 'String', LookFor);
  if b and (not Empty(LookFor)) then
    begin
      fLastFindText := UpperCase(LookFor);
      p := SearchFor(fLastFindText);
      if Assigned(p) then
        begin
          Buf := pchar(Memo1.Text);
          Memo1.SelStart  := p - Buf;
          Memo1.SelLength := Length(fLastFindText);
        end
      else
        lblStatus.Caption := Format('String "%s" could not be found', [fLastFindText]);
    end;
end;

procedure TfrmDecodeWindow.FindAgain1Click(Sender: TObject);
var
  p, Buf: pchar;
begin
  p   := SearchFor(fLastFindText);
  if Assigned(p) then
    begin
      Buf := pchar(Memo1.Text);
      Memo1.SelStart  := p - Buf;
      Memo1.SelLength := Length(fLastFindText);
    end
  else
    lblStatus.Caption := Format('String "%s" could not be found', [fLastFindText]);
end;

procedure TfrmDecodeWindow.DumpEVECERECSIBS1Click(Sender: TObject);
var
  AddrStr   : string;
  EVECAddr  : word;
  ERECAddr  : word;
  SegNr     : word;
  EVECPtr   : TEVECPtr;
  ERECPtr   : TERECPtr;
  ERECStr   : string;
  EVECStr   : string;
  SIBStr    : string;
begin
  with fInterpreter as TIVPsystemInterpreter do
    begin
      EVECAddr := Globals.LowMem.EVECp;
      AddrStr  := WordToHex(EVECAddr);
      if GetString('Dump EVEC, EREC, SIBs', 'Addr of EVEC $', AddrStr, 6) then
        begin
          EVECAddr      := HexStrToWord(AddrStr);
          EVECPtr       := TEVECPtr(@Bytes[EVECAddr]);

          EVECStr       := MemDumpDW(EvecAddr, wt_EVECp);
          AddLine(EVECStr);
          AddLine('');

          with EVECPtr^ do
            begin
              // vect_Length
              for SegNr := 1 to Vect_Length do
                begin
{$R-}
                  ERECAddr := Map[SegNr];
                  if ERECADDR <> 0 then
                    begin
                      ERECPtr  := TERECPtr(@Bytes[ERECADdr]);

                      ERECSTR  := MemDumpDW(ERECAddr, wt_ERECp);
                      AddLine(ERECStr);
                      AddLine('');

                      with ERECPtr^ do
                        begin
                          SIBStr := MemDumpDW(Env_SIB, wt_Sibp);
                          AddLine(SIBStr);
                        end;
                      AddLine('');
                      AddLine('');
                    end;
{$R+}
                end;
            end;
        end;
    end;

end;

procedure TfrmDecodeWindow.MergePCodeWithSourceCode(pCodeList,
  SrcCodeList: TStringList);
var
  pCodeLineNr   : integer;
  SrcCodeLineNr : integer;

  pCodeLine     : string;
  SrcCodeLine   : string;

  pCodeIpc      : word;
  pCodeIPCStr   : string;
  pCodeLineText : string;

  SrcCodeIPC      : word;
  SrcCodeIPCStr   : string;
  SrcCodeLineText : string;

  LastLineOutput  : string;   // purely for debugging

  procedure ParseLine(const Line: string; var IPCVal: word; var IPCStr, TextStr: string);
  var
    cp: integer;
  begin
    IPCVal := 0;
    cp := Pos(':', Line);
    if cp > 0 then
      begin
        IPCStr  := Trim(Copy(Line, 1, cp-1));
        TextStr := Trim(Copy(Line, cp+1, MAXINT));
        if IsPureNumeric(IPCStr) then
          IPCVal  := StrToInt(IPCStr);
      end
    else
      begin
        IPCStr  := '';
        TextStr := Line;
      end;
  end;


  function RemoveComments(const Line: string): string;
  var
    lb : integer;
  begin
    lb := Pos('//', Line);
    if lb > 0 then
      result := TrimRight(Copy(Line, 1, lb-1))
    else
      result := Line;
  end;

  function IsNumeric(const s: string): boolean;
  begin
    result := (s <> '') and IsPureNumeric(Trim(s))
  end;

  procedure AddPCodeLine;
  begin
    AddLine(pCodeLine);
    LastLineOutput := pCodeLine;
    if pCodeLineNr < pCodeList.Count then
      begin
        pCodeLine := pCodeList[pCodeLineNr];
        inc(pCodeLineNr);
        ParseLine(pCodeLine, pCodeIpc, pCodeIPCStr, pCodeLineText);
      end;
  end;

  procedure AddSrcCodeLine;
  var
    Line: string;
  begin
//  Line := Padr('', 24) + '// ' + SrcCodeLineText;
    Line := Format('%24s // %3d: %s', ['', SrcCodeIpc, SrcCodeLineText]);
    AddLine(Line);
    LastLineOutput := SrcCodeLine;
    if SrcCodeLineNr < SrcCodeList.Count then
      begin
        SrcCodeLine := SrcCodeList[SrcCodeLineNr];
        inc(SrcCodeLineNr);
        ParseLine(SrcCodeLine, SrcCodeIpc, SrcCodeIPCStr, SrcCodeLineText);
      end;
  end;

begin { MergePCodeWithSourceCode }
  Memo1.Lines.Clear;

  // First we need to remove all comments from the pCodeList

  pCodeLineNr := pCodeList.Count - 1;
  while pCodeLineNr >= 0 do
    begin
      pCodeLine := pCodeList[pCodeLineNr];
      pCodeLine := RemoveComments(pCodeLine);
      pCodeList[pCodeLineNr] := pCodeLine;
      Dec(pCodeLineNr);
    end;

  // Now, merge the two lists
  pCodeLineNr   := 0;
  SrcCodeLineNr := 0;

  pCodeLine := pCodeList[pCodeLineNr];
  inc(pCodeLineNr);
  ParseLine(pCodeLine, pCodeIpc, pCodeIPCStr, pCodeLineText);

  SrcCodeLine := SrcCodeList[SrcCodeLineNr];
  inc(SrcCodeLineNr);
  ParseLine(SrcCodeLine, SrcCodeIPC, SrcCodeIPCStr, SrcCodeLineText);

  while (pCodeLineNr < pCodeList.Count) and (SrcCodeLineNr < SrcCodeList.Count) do
    begin
      // add initial lines from the source code
      repeat
        AddSrcCodeLine;
      until IsNumeric(SrcCodeIPCStr)
            or (SrcCodeLineNr >= SrcCodeList.Count);

      // add initial lines from pcode
      repeat
        if (not IsNumeric(pCodeIPCStr)) then  // must be filler, just add it to the output listing
          AddPCodeLine;
      until IsNumeric(pCodeIPCStr)
            or (pCodeLineNr >= pCodeList.Count);

      // assert that we have now read the first line in both pCode and SrcCode with an actual IPC

      // This source code line should precede the following p-code lines
      while (SrcCodeIPC <= pCodeIPC) and (SrcCodeLineNr < SrcCodeList.Count) do
        AddSrcCodeLine;

      // add pCode lines that must precede the next source code line
      while (pCodeIPC < SrcCodeIPC) and (pCodeLineNr < pCodeList.Count) do
        AddPCodeLine;

    end;

  while SrcCodeLineNr < SrcCodeList.Count do
    AddSrcCodeLine;

  while pCodeLineNr < pCodeList.Count do
    AddPCodeLine;

  // Add the last lines
  if SrcCodeLine <> '' then
    AddSrcCodeLine;

  if pCodeLine <> '' then
    AddPCodeLine;
end;  { MergePCodeWithSourceCode }

procedure TfrmDecodeWindow.MergeSourceCodeintopCode1Click(Sender: TObject);
begin
  if Assigned(fGetMemoLists) then
    begin
      fGetMemoLists(fpCodeList, fSrcCodeList);
      MergePCodeWithSourceCode(fpCodeList, fSrcCodeList);
    end
  else
    Error('GetMemoLists is not assigned');
end;

initialization
finalization
  frmDecodeWindow := nil;
end.
