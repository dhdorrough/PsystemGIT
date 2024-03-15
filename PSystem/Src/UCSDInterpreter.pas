unit UCSDInterpreter;

interface

uses
  Interp_Common,
  SysUtils, Misc, UCSDGlbu, Interp_Const, Interp_Decl,
  Classes, pSysVolumes, pSysWindow, StdCtrls, LoadVersion
{$IfDef debugging}
  , Watch_Decl
{$EndIf}  ;

type
    {although MTYPES=2 bytes in ucsd for 10 enumerated types and 1 byte in
     turbo, the variable of mtype is used in a packed record and so UCSD
     packs it into 1 byte then}

  MTYPES = (UNDEF,PCODEMOST,PCODELEAST,PDP11,
            M8080,Z80,GA440,M6502,M6800,TI9900);

  TSegNameII = PACKED ARRAY [0..7] OF CHAR;

  {Start of data structure for segment dictionary}

  SDRecordPtr = ^SDRECORD;

  SDRECORD = RECORD

    DiskInfo:   ARRAY [0..MAXSEG] OF
                  RECORD
                    CODEaddr: integer;  {block number on volume}
                    CODEleng: INTEGER;  {length in words}
                  END;

    SegNamesII : ARRAY [0..MAXSEG] OF TAlpha;

    SEGKIND : ARRAY [0..MAXSEG] OF integer;

    TEXTADDR: ARRAY[0..MAXSEG] OF INTEGER;



    SEGINFO: PACKED ARRAY [0..MAXSEG] OF
      PACKED RECORD
//                     seg_num:0..255;           { 8 bits: 0..7 }
//                     m_type:m_types;           { 4 bits: 8..11  }
//                     filler:0..1;              { 1 bit: 12..12 }
//                     major_version:versions;   { 3 bits: 13..15 }
                       SegInfo: word  // everything packed into one word
      END;

    END;
  {End of data structure for segment dictionary}

  TSDUnion = RECORD
    CASE INTEGER OF
      1: (BUF: PACKED ARRAY [0..511] OF 0..255);
      2: (DICT: SDRECORD);
    END;
  
  TSegInfoRec = Record
                 TheREFCOUNT  : Word;
                 TheSEGTOP    : LongWord;  // ^byte PAST end of segment code !! (or is it?)
                 TheSEGNAME   : string[8]; // TAlpha;
                 TheCodeAddr  : integer;  {relative block number within code file}
                 TheCODEleng  : integer;  {in bytes}  { WATCH OUT: V1.5 may not be same as V2.0 }
                 TheNotice    : string;    // Why TheSegTop was changed
                end;

  TSegInfoRecP = ^TSegInfoRec;

  TFSegmentFileList = record
                      TheUnitNr    : word;
                      TheFileName  : string;   { code file name }
                      TheAbsFileStartingBlock : integer;
                      SegInfo      : Array[0..MAXSEG] of TSegInfoRec;  { segments in this code file }
                    end;

  TFilesLoadedList = array of TFSegmentFileList;

  TIILowMem = packed record    // needs to be packed to guarantee p-Code compatability
                  case integer of
                    0: (case integer of
                          0: (SysCom: TIISysComRec);                             // to simplify comparison
//                        1: (Fill0: packed array[0..$23] of byte;             // force same addresses as on hardware
//                            IPCSAV: word;               { $24 }
//                            MPPlus: word;               { $26 }
//                            BASEPLUS: word;             { $28 }
//                            SegB: longword;            { $2A }
//                            xMP: WORD;            // this needs to be here because of p-code direct access (?? is this still true ??)
//                            BASE: word;
//                            CURPROC: integer;
//                            SIBP: word;
//                            SEGTOP: word;         // points to the procedure dictionary
//                            READYQ: word;
//                            EVECp: word;
//                            CURTASK: word;
//                            ERECp: word;
//                            OLDEREC: word;
//                            CPOFFSET: word;
//                            SEXFLAG: word;
//                            EXTEND: word);
                       );
                    end;  { 326 bytes }

  TIIGlobals  = record
                LowMem    : TIILowMem;
//              MemInfo   : TMemInfo_Rec;
//   { 110 }    RootTask  : TTib;
//   { 138 }    MAINMSCW  : TMscw;  // This should be located in low memory
//              MemTop    : longword;
              end;

  TIIGlobalsPtr = ^TIIGlobals;

  TUCSDInterpreter = class(TCustomPsystemInterpreter)
  private
    fSegP            : word;
    procedure SetSegP(const Value: word);
    function GetOpCode: byte;
    procedure LoadDictCopy( UnitNr, FirstBlock: integer;
                            var NrBytes: integer;
                            const Dict: SDRECORD;
                            var DictCopy: SDRECORD);
  protected
    fDumpsMade       : boolean;
    fLatestSegNames  : ARRAY [0..MAXSEG] OF string[8];
    fLogFile         : textfile;
    fLogFileName     : string;
    fLogFileIsOpen   : boolean;

    function CheckForSegDict(aResult: TIORsltWD; UBLK, UNUM: word): TSegInfoRecP;
    procedure DumpDebugInfo(const Notice: string);
    function FindFileFirstBlockOnUnit(const FileName: string;
      UnitNr: integer): integer;
    function FindSegInfoRec(aCodeUnitNr, aDiskAddr: integer): TSegInfoRecP;
    function GetHeapTop: word; virtual; abstract;
    function GetSegInfoRec(SegNum, DiskAddr, UnitNr: word): TSegInfoRecP;
    function GetSegInfoRecPFromSegTbl(SegNum: word): TSegInfoRecP;
    procedure NoteSegTopChange(const Msg, SegName: string; OldSegTop,
                               NewSegTop: longword; ExtraLine: boolean = false);
    procedure SaveSegInfoForFile( UnitNr: word;
                                  FirstBlock: integer;
                                  NrBytes: integer;
                                  const aFileName: string;
                                  const Dict: SDRECORD;
                                  MaxBlock: integer);
    procedure SegInfoRecFromSegTop(SegTop: word;
                                   var SegInfoRecP: TSegInfoRecP; var FileName: string);
    procedure SetHeapTop(const Value: word); virtual; abstract;
    function UpdateSegStuff(      SegNum: integer;
                              var SegIdx: integer;
                              var FileName: string;
                                  NewSegName: TString8;
                                  NewSegTop: longword;
                                  aUnitNr: word;
                                  AbsCodeBlock: word;
                                  SegLen: word): TSegInfoRecP;
    procedure UpdateSegInfo( SegNum: word;
                             NewSegTop, SegBot: longword;
                             SegLen: word;
                             CodeUnit: word;
                             DiskAddr: word;
                             SegName: TString8);
    function ValidDictionary( UnitNr: word;
                              FirstBlock: integer;
                              NrBytes: integer;
                              DICT: SDRECORD;
                              MaxBlock: integer): boolean;
  public
    fFilesLoadedList : TFilesLoadedList;    // should this exist when not IfDef(Debugging)?
{$IfDef debugging}
{$IfDef DashBoard}
    fSegTopListChanges: TStringList;
{$EndIf DashBoard}
{$EndIf debugging}
    Globals     : TIIGlobalsPtr;
    Constructor Create( aOwner: TComponent;
                        VolumesList   : TVolumesList;
                        thePSysWindow : TfrmPSysWindow;
                        Memo: TMemo;
                        TheVersionNr: TVersionNr;
                        TheBootParams: TBootParams); {reintroduce;} override;
    Destructor Destroy; override;
    procedure DumpDebugInfoExt(const aCaption: string);
    function GetEnterIC(JTAB: word): word; virtual; abstract;
//  function GetNextOpCode: byte; virtual;
    function MemRdByte(Addr: word; Offset: integer): byte; virtual; abstract;
    function ProcDataSize(jtab: word): word; virtual;
    function ProcNameFromSegTop(MsProc: word; aSegTop: longword): string;
    function SegIdxFromSegTop(aSegTop: longword): integer;
    function SegNameFromSegTop(aSegTop: longword): string; virtual;
{$Ifdef DashBoard}
    property SegTopListChanges: TStringList
             read fSegTopListChanges;
{$EndIf DashBoard}
{$IfDef Debugging}
    function SegBot0: longword; override;
{$EndIf Debugging}

    property HeapTop     : word        {^top of heap}
             read GetHeapTop
             write SetHeapTop;

    property SEGP        : word            // points to the END{+2?} of the segment
             read fSegP
             write SetSegP;

    property OpCode      : byte
             read GetOpCode;
  end;

implementation

uses MyUtils, pSysExceptions, Windows, PsysUnit,
{$IfDef debugging}
  Debug_Decl, pCodeDebugger_Decl,
{$EndIf debugging}
  FilerSettingsUnit;

const
  MAX_VOLUME_BLOCKS = 16000;   // about 8 Mb

{ TUCSDInterpreter }

// Kludge - see if we just read a segment dictionary. If so, save the segment names.

   function TUCSDInterpreter.CheckForSegDict(aResult: TIORsltWD; UBLK, UNUM: word): TSegInfoRecP;
   var
      Idx, NrEntries: word;
      Dict: SDRECORD;
      MaxBlock: integer;
   begin
     RESULT := NIL;
     with Globals.Lowmem.Syscom do
       begin
         // Look for this block number as the first block of a file in the directory and check if this is a code file.
         // gDirp should have already been verified as <> pNil before we got here.
         with TDIRPtr(@Bytes[gDirp])[0] do
           begin
             NrEntries := DNUMFILES;
             MaxBlock  := DEOVBLK;
           end;

         if NrEntries <= MAXDIR then
           for Idx := 1 to NrEntries do
             with TDIRPtr(@Bytes[gDirp])[Idx] do
               if (UBLK = DFIRSTBLK) and (DFKIND = kCODEFILE) then // we found a matching code file
                 begin  // So the buffer actually contains a segment dictionary
                   Dict := SDRecordPtr(@Bytes[UBUF])^;
                   // The buffer should already have a segment dictionary loaded-- add it to the list of known .code files
                   SaveSegInfoForFile(UNUM, UBLK, ULEN, DTID, Dict, MaxBlock);  // Save the segment names
                   Break;
                 end;
       end;
   end;

  procedure TUCSDInterpreter.DumpDebugInfoExt(const aCaption: string);
  begin
{$IfDef DumpDebugInfo}
    DumpDebugInfo(aCaption);
    if fLogFileIsOpen then
      begin
        CloseFile(fLogFile);  // close it to allow editing
        fLogFileIsOpen := false;
        if YesFmt('View %s', [fLogFileName]) then
          EditTextFile2(FilerSettings.EditorFilePath, fLogFileName);
      end;
{$EndIf DumpDebugInfo}
  end;

  procedure TUCSDInterpreter.DumpDebugInfo(const Notice: string);
{$IfDef DumpDebugInfo}
  var
    fn, Idx, NrFiles, FirstBlock, LastBlock, NrBlocks: INTEGER;
    TempName,
    Msg : string;
{$EndIf DumpDebugInfo}
  begin { DumpDebugInfo }
    if BootParams.IsDebugging then
      begin
{$IfDef DashBoard}
        fSegTopListChanges.Add(Notice);

        with frmPCodeDebugger do
          with DashboardWindowsList do
            RefreshAll;
{$EndIf DashBoard}
{$IfDef DumpDebugInfo}
        if fLogFileIsOpen then
        try
          NrFiles    := Length(fFilesLoadedList);

          WriteLn(fLogFile, Padr('', 80, '-'));
          WriteLn(fLogFile, Notice);
          WriteLn(fLogFile, MemDumpDW(0, wt_DynamicCallStack));
          for fn := 0 to NrFiles-1 do
            with fFilesLoadedList[fn] do
              begin
                fDumpsMade  := true;
                Msg := Format('FN=%2d, UnitNr=%2d, TheAbsFileStartingBlock=%5d, TheFileName=%s',
                              [FN,     TheUnitNr,  TheAbsFileStartingBlock, TheFileName]);
                WriteLN(fLogFile, Msg);
                Msg := '   #      SegName,     TheSegTop,  TheCodeAddr,  TheCodeLeng,     NRBlocks,   FirstBlock,   LastBlock,   TheRefCount';
                WriteLN(fLogFile, Msg);
                for Idx := 0 to MAXSEG do
                  with SegInfo[Idx] do
                    if TheCodeAddr > 0 then
                      begin
                        TempName   := TheSEGNAME;
                        NrBlocks   := (TheCodeLeng + BLOCKSIZE - 1) div BLOCKSIZE;
                        FirstBlock := TheAbsFileStartingBlock + TheCodeAddr;
                        LastBlock  := TheAbsFileStartingBlock + TheCodeAddr + NrBlocks;
                        Msg := Format('%4d  %12s, %12d, %12d, %12d, %12d, %12d, %12d, %12d',
                                       [Idx, TempName, TheSEGTOP, TheCodeAddr, TheCodeLeng, NRBlocks, FirstBlock, LastBlock, TheRefCount]);
                        WriteLN(fLogFile, Msg);
                      end;
              end;
        finally
        end;
{$EndIf DumpDebugInfo}
      end;
  end;  { DumpDebugInfo }

function TUCSDInterpreter.FindFileFirstBlockOnUnit(const FileName: string; UnitNr: integer): integer;
var
  DirIdx: integer;
begin
  with fVolumesList[UnitNr].TheVolume do
    begin
      FindDirectoryEntry(FileName, DirIdx);
      if DirIdx > 0 then
        with Directory[DirIdx] do
          result    := FirstBlk
      else
        raise EInvalidBlockNumber.CreateFmt('Cannot find %s on volume "%s"', [FileName, DOSFileName]);
    end;
end;

// Name:    UpdateSegStuff
// Use:     Given the unit number and block number, returns the SegNumber, FileName & SegName
// Params:
//          SegNum = required segment number
//          NewSegTop = High address of the segment
// Output:
//          SegIdx = 0..15
//          FileName = name of the file containing the segment
//          SegName = the name of the segment
// Result:  assigned if found, not assigned if not
function TUCSDInterpreter.UpdateSegStuff(     SegNum: integer;
                                          var SegIdx: integer;
                                          var FileName: string;
                                              NewSegName: TString8;
                                              NewSegTop: longword;
                                              aUnitNr: word;
                                              AbsCodeBlock: word;
                                              SegLen: word): TSegInfoRecP;
var
  Idx, {FirstBlock,} LastBlock, NrBlocks,
  OldB {OldSegBottom ByteIndexed},
  NewB {NewSegBottom Byteindexed},
  OldT {OldSegTop ByteIndexed},
  NewT {NewSegTop ByteIndexed}: longword;
  b1, b2: boolean;
  NrFiles, fn, FileNumber: integer;
  NewBytesNeeded: integer;
  Msg: string;
begin
  // BE CAREFUL: CODELENG might be using word counts rather than byte counts. I'm not sure but I think that
  //             V4.0 = word counts
  //             V1.4..V2.0 = byte counts.
  result     := nil;
  FileNumber := -1;
  SegIdx     := -1;
  NewT       := ByteIndexed(NewSegTop);   // This points to the byte AFTER the last byte of the segment
  NrFiles    := Length(fFilesLoadedList);
  try
//  with Globals.LowMem.Syscom.SegTbl[SEGNUM] do
      begin
(* Does some other segment already claim this position in memory?
   Is this code irrelevent because of REFCNT? *)
        for fn := 0 to NrFiles-1 do
          with fFilesLoadedList[fn] do
      //    if (Unitnr = TheUnitNr) then
              for Idx := 0 to MAXSEG do
                with SegInfo[Idx] do
                  if (TheSEGTOP > 0) {and (TheRefCount > 0)} then
                    begin
                      NewBytesNeeded := SegLen;       // 7/28/2022
                      NewB           := NewT - NewBytesNeeded;
                      OldB           := ByteIndexed(TheSEGTOP) - TheCODEleng;
                      OldT           := ByteIndexed(TheSEGTOP);
//                    b1 := (OldB <= NewB) and (NewB <= OldT);
                      b1 := (OldB <= NewB) and (NewB < OldT);
                      if b1 then
                        begin
                          Msg := Format('Free segment info %s because of b1: (OldB(%d) <= NewB(%d) < OldT(%d))',
                                             [TheSEGNAME, OldB, NewB, OldT]);
                          DumpDebugInfo(Msg);
                        end;
//                    b2 := (NewB <= OldT) and (OldT <= NewT);
                      b2 := (NewB < OldT) and (OldT <= NewT);
                      if b2 then
                        begin
                          Msg := Format('Free segment info %s because of b2: (NewB(%d) < OldT(%d)) <= NewT(%d))',
                                              [TheSEGNAME, NewB, OldT, NewT]);
                          DumpDebugInfo(Msg);
                        end;
                      if (b1 or b2) then     // the regions overlap and we must not use obsolete info
//                      if TheREFCOUNT <= 0 then
                          begin
                            Msg := Format('UpdateSegStuff. Overlapping segments B1=%s, B2=%s', [TFString(B1), TFString(B2)]);
                            NoteSegTopChange(Msg, TheSEGNAME, TheSEGTOP, 0);
                            TheSEGTOP   := 0;    // free the old segment
                            TheRefCount := 0;
//                          TheSEGNAME  := '';
                            TheNotice   := Format('Overlap: FN=%d, OldMem:%d->%d, NewMem:%d->%d',
                                                  [fn, OldB, OldT, NewB, NewT]);
                          end;
                    end;

        for fn := 0 to NrFiles-1 do
          with fFilesLoadedList[fn] do
            if (aUnitNr = TheUnitNr) and (AbsCodeBlock >= TheAbsFileStartingBlock) then
              begin
//              for Idx := 0 to MAXSEG do
                  with SegInfo[SegNum] do
                    begin
                      NrBlocks   := (TheCodeLeng + BLOCKSIZE - 1) div BLOCKSIZE;
//                    FirstBlock := AbsCodeBlock;
                      LastBlock  := AbsCodeBlock + NrBlocks;
                      if AbsCodeBlock < LastBlock then
                        begin
                          result     := @SegInfo[SegNum];
                          SegIdx     := SegNum;
                          NoteSegTopChange('UpdateSegStuff', TheSEGNAME, TheSEGTOP, NewSegTop);
                          TheNotice  := Format('SegTop %d --> %d', [TheSEGTOP, NewSegTop]);
                          TheSEGTOP  := NewSegTop;
                          TheSEGNAME := NewSegName;
                          FileNumber := fn;
                          break;
                        end;
                    end;
                if SegIdx >= 0 then
                  Break;
              end;

        if SegIdx >= 0 then // we know about this segment
          with fFilesLoadedList[FileNumber] do
            begin
              FileName   := TheFileName;
//            SegName    := SegInfo[SegIdx].TheSegName;
              result     := @SegInfo[SegIdx];
//            OutputDebugStringFmt('Updated SegNum = %d, SegIdx = %d, NewSegTop = %d, FileName = %s, SegName = %s',
//                                 [SegNum, SegIdx, NewSegTop, FileName, NewSegName]);
            end;
      end;
  except
    // Something went wrong but let's just ignore it
  end;
end;

function  TUCSDInterpreter.ProcNameFromSegTop(MsProc: word; aSegTop: longword): string;
var
  SegName: string;
{$IfDef debugging}
  aSegNameIdx : TSegNameIdx;
{$EndIf}
begin
{$IfDef debugging}
  if aSegTop > 0 then
    begin
      SegName    := SegNameFromSegTop(aSegTop);

      with frmPCodeDebugger do
        aSegNameIdx := TheSegNameIdx(aSegTop);

      result := Format('%s.%s', [SegName, ProcNamesF(aSegNameIdx, MsProc)]);
    end
  else
    result := '';
{$else}
  result := Format('Proc # %s', [MsProc]);
{$EndIf}
end;

  function TUCSDInterpreter.ValidDictionary( UnitNr: word;
                                             FirstBlock: integer;
                                             NrBytes: integer;
                                             DICT: SDRECORD;
                                             MaxBlock: integer): boolean;
  var
    SegIdx: integer;
    sk: integer;
    SegName: string;
//  SDUnion: TSDUNION;

    function  IsAlphabetic(aWord: string): boolean;
    var
      i: integer;
    begin { IsAlphabetic }
      result := false;
      aWord := UpperCase(aWord);
      if Length(aWord) > 0 then
        begin
          result := aWord[1] in ALPHA_UPPER;
          if result then
            if Length(aWord) > 1 then
              begin
                for i := 2 to Length(aWord) do
                  if not (aWord[i] in (ALPHA_UPPER+NUMERIC+['_', ' '])) then
                    begin
                      result := false;
                      exit;
                    end;
                result := true;
              end;
        end;
    end;  { IsAlphabetic }

  begin { ValidDictionary }
    result    := false;
    if NrBytes < SizeOf(SDRECORD) then // we demand that to be "valid", it must be long enough
                                       // to contain the segment names
      Exit;
(*
    if NrBytes < SizeOf(SDRECORD) then // The "Dict" that was passed in does not contain the Segment names
      begin // so lets read the entire first block so that we have the segment names
        if Assigned(UNITBL[UnitNr].Driver) then
          begin
            UNITBL[UnitNr].Driver.Dispatcher(INBIT, FirstBlock, SizeOf(SDUnion), SDUnion, control);
            DICT := SDUnion.DICT;
          end;
      end;
*)
    with DICT do
      begin
        for SegIdx := 0 to MAXSEG do
          begin
            if VersionNr > vn_VersionI_4 then
              begin
                sk := ord(SegKind[SegIdx]);
                if (sk < 0) or (sk > ord(skSEPRTSEG)) then
                  exit;
              end;

            with DiskInfo[SegIdx] do
              begin
                if (CodeAddr < 0) or (CodeAddr > MaxBlock {volume size}) then
                  exit;
                if (CodeLeng < 0) or (CodeLeng > 32767) then // Trying to limit .code size to something plausible
                  exit;
              end;

            SegName := Trim(SegNamesII[SegIdx]);
            if (Length(SegName) > 0) {and (SegName<>'')} then
              if not IsAlphabetic(SegName) then
                exit;
          end;
        result := true;
      end;
  end;  { ValidDictionary }

procedure TUCSDInterpreter.LoadDictCopy(UnitNr, FirstBlock: integer; var NrBytes: integer; const Dict: SDRECORD; var DictCopy: SDRECORD);
var
  SDUnion: TSDUnion;
begin
  if NrBytes < SizeOf(SDRECORD) then // The "Dict" that was passed in does not contain the Segment names
    begin // so let's read the entire first block so that we have the segment names
      if Assigned(UNITBL[UnitNr].Driver) then
        begin
          UNITBL[UnitNr].Driver.Dispatcher(INBIT, FirstBlock, SizeOf(SDUnion), SDUnion, 0);
          DictCopy := SDUnion.DICT;
          NrBytes  := SizeOf(SDRECORD);
        end
      else
        raise Exception.CreateFmt('System Error: Invalid UnitNr =%s', [UnitNr]);
    end
  else
    DictCopy := Dict;  // assume that what we have is good enough
end;



// Function: SaveSegInfoForFile
// Parameters
//           UnitNr      : Unit Number of the file containing the segment
//           aFileName   : p-system file name of the code file containing the unit
//           FirstBlock  : The first block of the file (i.e., segment dictionary)
//           Dict        : The segment dictionary
procedure TUCSDInterpreter.SaveSegInfoForFile(  UnitNr: word;
                                                FirstBlock: integer;
                                                NrBytes: integer;
                                                const aFileName: string;
                                                const Dict: SDRECORD;
                                                MaxBlock: integer);
var
  fn, aSegNum, Len, FileIdx: integer;
  FileIsKnown: boolean;
  DictCopy: SDRECORD;
{$If Defined(DumpDebugInfo) or Defined(DashBoard)}
  Msg: string;
{$IfEnd}
begin { SaveSegInfoForFile }
  if Assigned(fVolumesList[UnitNr].TheVolume) then   // is this a disk volume?
    begin
     LoadDictCopy(UnitNr, FirstBlock, NrBytes, Dict, DictCopy);
     if ValidDictionary( UnitNr, FirstBlock, NrBytes, DictCopy, MaxBlock) then
      begin
        Len         := Length(fFilesLoadedList);
        FileIdx     := -1;
        FileIsKnown := false;
        for fn := 0 to Len-1 do
          with fFilesLoadedList[fn] do
            if (UnitNr = TheUnitNr) and
               (FirstBlock = TheAbsFileStartingBlock) then
              begin
                FileIdx     := fn;     // we already know about this file and its segments
                FileIsKnown := true;
                break;
              end;

        if not FileIsKnown then // never seen before
          begin
            FileIdx := Len;               // This is where the referenced item will be
            SetLength(fFilesLoadedList, Len+1);
          end;

        with fFilesLoadedList[FileIdx] do  // Add/update info for this file and its segments
          begin
            TheFileName             := aFileName;
            TheUnitNr               := UnitNr;
            TheAbsFileStartingBlock := FirstBlock;
             // Add info for each of the segments in the code file.
             // Note: the file might have been rewritten (by being re-compiled, for example)
             //       but this would have changed the starting block.
            for aSegNum := 0 to MAXSEG do
              with SegInfo[aSegNum] do
                begin
                  TheRefCount       := 0;
                  NoteSegTopChange('SaveSegInfoForFile', DictCopy.SegNamesII[aSegNum], TheSEGTOP, 0);
                  if not FileIsKnown then
                    begin
                      TheSEGTOP         := 0;
                      TheNotice         := 'Was unknown';
                    end;
                  with DictCopy do
                    begin
                      TheSEGNAME    := SegNamesII[aSegNum];

  //                  if (aSegNum = 1) and (TheSEGNAME = 'USERPROG') then
  //                    TheSEGNAME := ExtractFileBase(aFileName);

                      TheCodeAddr   := DiskInfo[aSegNum].CODEaddr; // Adding even though CODEAddr = 0?
                      TheCodeLeng   := DiskInfo[aSegNum].CODEleng;
                      fLatestSegNames[aSegNum] := UCSDName(TheSEGNAME);
                    end;
  {$If Defined(DumpDebugInfo) or Defined(DashBoard)}
                  if (TheCodeAddr > 0) and (not Empty(TheSegName)) then
                    begin
                      Msg := Format('   ---- Added segment info for %s, code addr = %d',
                                    [TheSEGNAME, TheCodeAddr]);
                      if fLogFileIsOpen then
                        WriteLn(fLogFile, Msg);
                      DumpDebugInfo('SaveSegInfoForFile: '+Msg);
                    end;
  {$IfEnd}
                end;
          end;
      end;
    end;
end;  { SaveSegInfoForFile }


procedure TUCSDInterpreter.SegInfoRecFromSegTop(     SegTop: word;
                                                 var SegInfoRecP: TSegInfoRecP;
                                                 var FileName: string);
var
  fn, Idx: integer;
  NrFound: integer;
  DebugList: string;
{$IfDef DumpDebugInfo}
  Msg: string;
{$EndIf}  
begin { SegInfoRecFromSegTop }
  NrFound     := 0;
  SegInfoRecP := nil;
  DebugList   := '';
  if SegTop > 0 then
    for fn := 0 to Length(fFilesLoadedList)-1 do
      begin
        with fFilesLoadedList[fn] do
          begin
            for Idx := 0 to MAXSEG do
              with SegInfo[Idx] do
                if (SegTop = TheSEGTOP) then
                  begin
                    DebugList   := DebugList + ' ' + TheSEGNAME;
                    SegInfoRecP := @SegInfo[Idx];
                    FileName    := fFilesLoadedList[fn].TheFileName;
                    Inc(NrFound);
                    continue;
                  end;
          end;
      end;
{$If Defined(SegInfoRec) and Defined(DumpDebugInfo)}
 if NrFound > 1 then
    begin
      Msg := Format('%d segments (%s) found matching SegTop=%4.4x', [NrFound, DebugList, SegTop]);
      DumpDebugInfo(Msg);
    end;
{$IfEnd}
end;  { SegInfoRecFromSegTop }


procedure TUCSDInterpreter.UpdateSegInfo( SegNum: word;
                                          NewSegTop, SegBot: longword;
                                          SegLen: word;
                                          CodeUnit: word;
                                          DiskAddr: word;
                                          SegName: TString8);
var
  SegInfoRecP: TSegInfoRecP;
{$Ifdef DashBoard}
  Msg,
{$EndIf DashBoard}
  FileName: string;
  SegIdx: integer;
begin
  If SEGNUM <> Bytes[ByteIndexed(NewSegTop)] then    // segment number is stored in the last word of the segment (I think)
    with frmPSysWindow do
      raise ENOPROC.Create('ERROR...Readseg no proc');

  SegInfoRecP := UpdateSegStuff(SegNum,  { Use SegTbl[SEGNUM] }
                                SegIdx,
                                FileName,
                                SegName,
                                NewSegTop,
                                CodeUnit,
                                DiskAddr,
                                SegLen);

  if not Assigned(SegInfoRecP) then
    with Globals.LowMem.SysCom do
      SegInfoRecP := FindSegInfoRec( CodeUnit, DiskAddr);

  if Assigned(SegInfoRecp) then
    with SegInfoRecp^ do
      if TheSEGTOP <> NewSegTop then
        begin
  {$If Defined(SegInfoRec) or Defined(DashBoard)}
          NoteSegTopChange('UpdateSegInfo', TheSEGNAME, TheSEGTOP, NewSegTop);
  {$IfEnd}
          TheNotice   := Format('SegTop %d --> %d', [TheSEGTOP, NewSegTop]);
          TheSEGTOP   := NewSegTop;  // point to last word of segment
          TheRefCount := 1;
          UpdateSegStuff(SegNum, SegIdx, FileName, SegName, NewSegTop, CodeUnit, DiskAddr, SegLen);  // Why is this getting called twice in this Routine?
        end
      else
  else
    begin
{$Ifdef DashBoard}
      with Globals.Lowmem.SysCom.SEGTBL[SegNum] do
        Msg := Format('Did not find info for SegNum = %2d, @ NewSegTop = %5d, DISKADDR = %5d, CODELENG = %5d, SP = %4.4x',
                      [SegNum, NewSegTop, DiskAddr, CODELENG, SP]);
      DumpDebugInfo(Msg);
{$EndIf DashBoard}
    end;
end;

  procedure TUCSDInterpreter.NoteSegTopChange(const Msg, SegName: string;
                                                         OldSegTop, NewSegTop: longword;
                                                         ExtraLine: boolean = false);
  var
    ChgMsg: string;
  begin
    if (not Empty(SegName)) and (OldSegTop <> NewSegTop) then
      begin
        ChgMsg := Format('%10s: SEGTOP @ %s: changed from %d to %d',
                         [SegName, Msg, OldSegTop, NewSegTop]);
{$IfDef DashBoard}
        with fSegTopListChanges do
          Add(ChgMsg);

        with frmPCodeDebugger do
          with DashboardWindowsList do
            RefreshAll;
{$EndIf}
{$IfDef DumpDebugInfo}
        if fLogFileIsOpen then
          begin
            WriteLn(fLogFile, ChgMsg);
            if ExtraLine then
              WriteLn(fLogFile);
          end;
    //  fDumpsMade := true;
{$EndIf DumpDebugInfo}
      end;
  end;

  // Function Name: FindSegInfoRec
  // Assumes:       that we already know about this segment but we just don't know where it is located in memory
  // Parameters:
  //                aCodeUnitNr: which physical unit the segment is located om
  //                aDiskAddr:   the starting address of the segment on disk.
  function TUCSDInterpreter.FindSegInfoRec(aCodeUnitNr, aDiskAddr: integer): TSegInfoRecP;
  var
    fn, idx, NrFiles, NrBlocks, FirstBlock, LastBlock, SegIdx{, FileNumber}: integer;
  begin
    result     := nil;
    SegIdx     := -1;
    NrFiles    := Length(fFilesLoadedList);
    for fn := 0 to NrFiles-1 do
      with fFilesLoadedList[fn] do
        if (aCodeUnitNr = TheUnitNr) and (aDiskAddr >= TheAbsFileStartingBlock) then
          begin
            for Idx := 0 to MAXSEG do
              with SegInfo[Idx] do
                if TheCodeAddr > 0 then
                  begin
                    NrBlocks   := (TheCodeLeng + BLOCKSIZE - 1) div BLOCKSIZE;
                    FirstBlock := TheAbsFileStartingBlock + TheCodeAddr;
                    LastBlock  := TheAbsFileStartingBlock + TheCodeAddr + NrBlocks;
                    if (aDiskAddr >= FirstBlock) and (aDiskAddr < LastBlock) then
                      begin
                        result     := @SegInfo[Idx];
                        SegIdx     := Idx;
//                      FileNumber := fn;
                        break;
                      end;
                end;
            if SegIdx >= 0 then
              Break;
          end;
  end;

function TUCSDInterpreter.GetSegInfoRec(SegNum: word; DiskAddr: word; UnitNr: word): TSegInfoRecP;
var
  fn: integer;
begin
  result := nil;
  for fn := 0 to Length(fFilesLoadedList)-1 do
    with fFilesLoadedList[fn] do
      if (UnitNr = TheUnitNr) then
        with SegInfo[segNum] do
          if DiskAddr = (TheAbsFileStartingBlock + TheCODEaddr) then
            with fFilesLoadedList[fn] do
              begin
                result := @SegInfo[SegNum];
                Break;
              end;
end;

Constructor TUCSDInterpreter.Create( aOwner: TComponent;
                    VolumesList   : TVolumesList;
                    thePSysWindow : TfrmPSysWindow;
                    Memo: TMemo;
                    TheVersionNr: TVersionNr;
                    TheBootParams: TBootParams);
begin
  inherited;
{$IfDef DashBoard}
  fSegTopListChanges := TStringList.Create;
{$EndIf DashBoard}
{$IfDef DumpDebugInfo}
  fLogFileName := FilerSettings.ReportsPath + 'DumpDebugInfo.txt';
  AssignFile(fLogFile, fLogFileName);
  Rewrite(fLogFile);
  WriteLn(fLogFile, 'Log file created @ ', DateTimeToStr(Now));
  fLogFileIsOpen := true;
  fDumpsMade := false;
{$EndIf DumpDebugInfo}
end;

function TUCSDInterpreter.SegNameFromSegTop(aSegTop: longword {WordIndexed}): string;
var
  fn, Idx: integer;
begin
  if aSegTop <> pNil then
    begin
      for fn := 0 to Length(fFilesLoadedList)-1 do
        begin
          with fFilesLoadedList[fn] do
            begin
              for Idx := 0 to MAXSEG do
                with SegInfo[Idx] do
                  if TheSegTop <> 0 then
                    if TheSEGTOP = aSegTop then
                      begin
                        result := UCSDName(SegInfo[Idx].TheSEGNAME);
                        Exit;
                      end;
            end;
        end;
    end;
  result := Format('Unknown_%d', [aSegTop]);
end;

function TUCSDInterpreter.SegIdxFromSegTop(aSegTop: longword): integer;
var
  fn, SegIdx: integer;
begin
  result  := -1;
//aSegTop := ByteIndexed(aSegTop);
  for fn := 0 to Length(fFilesLoadedList)-1 do
    begin
      with fFilesLoadedList[fn] do
        begin
          for SegIdx := 0 to MAXSEG do
            if SegInfo[SegIdx].TheSEGTOP = aSegTop then
              begin
                result := SegIdx;
                Exit;
              end;
        end;
    end;
end;

function TUCSDInterpreter.GetSegInfoRecPFromSegTbl(SegNum: word): TSegInfoRecP;
begin
  with Globals.LowMem.Syscom.SEGTBL[SegNum] do
    result := GetSegInfoRec(SegNum, DiskAddr, CodeUnit)
end;

destructor TUCSDInterpreter.Destroy;
begin
{$IfDef DumpDebugInfo}
  if fLogFileIsOpen then
    begin
      CloseFile(fLogFile);
      fLogFileIsOpen := false;
      if fDumpsMade then
        EditTextFile2(FilerSettings.EditorFilePath, fLogFileName)
      else
        StatusProc('No DebugDumpInfo dumps were made', true, true);
    end;
{$EndIf DumpDebugInfo}

{$IfDef DashBoard}
  FreeAndNil(fSegTopListChanges);
{$EndIf}
  inherited;
end;

function TUCSDInterpreter.ProcDataSize(jtab: word): word;
begin
  result := 0;
end;

procedure TUCSDInterpreter.SetSegP(const Value: word);
begin
  fSegP := Value;
end;

{$IfDef Debugging}
// Versions < IV
function TUCSDInterpreter.SegBot0: longword;
begin
  result := 0;
end;
{$EndIf}


function TUCSDInterpreter.GetOpCode: byte;
begin
  result := byte(fOpCode);
end;

end.
