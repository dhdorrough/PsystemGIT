unit MiscinfoUnit;

interface

uses
  CrtUnit, pSysVolumes, UCSDGLBU, UCSDGlob, pSys_Decl, Interp_Const;

const
  CSYSTEM_MISCINFO = 'SYSTEM.MISCINFO';

type
  TInbuf = record
             case integer of
               0: (BufB: packed array[0..BLOCKSIZE] of byte);
               1: (BufW: array [0..BLOCKSIZE div 2] of word);
               2: (sysII: TIISysComRec);
               3: (sysIV: TIVSysComRec)
           end;

  TInBufPtr = ^TInBuf;

  Procedure LoadCrtKeyInfo(var Buffer; CrtInfo, KeyInfo: TCrtInfo;
                               VersionNr: TVersionNr;
                               aStatusProc: TStatusProc = nil);
  procedure LoadMiscInfo(Volume: TVolume; const FileName: string; var InBuf: TinBuf);

implementation

uses
  BitOps, MyUtils, SysUtils, pSysExceptions, Windows;


Procedure LoadCrtKeyInfo( var Buffer;
                              CrtInfo, KeyInfo: TCrtInfo;
                              VersionNr: TVersionNr;
                              aStatusProc: TStatusProc = nil);
{read SYSTEM.MISCINFO and apply screen control codes}
CONST
  STARTINDEX = 29 * 2;   {@MiscInfo - taken from SETUP.TEXT, they were words}
  ENDINDEX   = 47 * 2 ;  {          --> Expansion }

  procedure Enter(  Info       : TCrtInfo;
                    cf         : TCRTFuncs;
                    PfxdWordNo : integer;
                    PfxdBitNo  : integer;
                    DataWordNo : integer;
                    DataBitNo  : word;
                    vk_        : word = 0);
  var
    wrd,  val: word;
    Prefixed: boolean;
    ch: char;
    aByte: Byte;
  begin { Enter }
    with Info do
      with TInBufPtr(Buffer)^ do
        begin
          Prefixed := false;
          if VersionNr > vn_VersionI_4 then // Version I.4 doesn't store prefixes
            begin
              if (PfxdWordNo >= 0) then
                begin
                  wrd      := BufW[PfxdWordNo];
                  val      := GetBits(wrd, PfxdBitNo, 1);
                  Prefixed := boolean(val);
                end;
            end;
          wrd      := BufW[DataWordNo];
          aByte    := GetBits(wrd, DataBitNo, 8);
          ch       := chr(aByte);   // always a character?
          AddFunc(cf, Prefixed, ch, vk_);
        end;
  end;  { Enter }

  procedure LoadCrtInfo(CrtInfo: TCrtInfo; VersionNr: TVersionNr);
  var
    InBufPtr: TInBufPtr;
  begin { LoadCrtInfo }
    with CRTInfo do
      begin
        if Assigned(aStatusProc) then
          CRTInfo.StatusProc := aStatusProc;

        Reset('CRT Info');

        InBufPtr := TInBufPtr(Buffer);
        
        with InBufPtr^ do
          begin
            TheMaxRows   := sysII.CRTINFO.Height;     Show('Height', TheMaxRows);
            TheMaxCols   := sysII.CRTINFO.Width;      Show('Width',  TheMaxCols);

            CRTType   := sysII.CRTTYPE;            Show('CRTType', CRTType); // is this ever actually used?

    // The following is adapted from SETUP.CODE -- easier than painstakingly adapting from SYSCOM.CRTINFO :(

          {                                                     Pfxd  Pfxd Data Data
          {                                                     Word  Bit  Word Bit }

//          ENTER(CrtInfo,  cf_DeleteChar,                      36,   5,   47,  12);
            ENTER(CrtInfo,  cf_LeadInToScreen,                 -1,   -1,   31,  0);
            ENTER(CrtInfo,  cf_EraseScreen,                     36,   6,   35,  8);
            ENTER(CrtInfo,  cf_EraseLine,                       36,   7,   35,  0);
            ENTER(CrtInfo,  cf_EraseToEndOfLine,                36,   2,   32,  8);
            ENTER(CrtInfo,  cf_EraseToEndOfScreen,              36,   3,   32,  0);
            ENTER(CrtInfo,  cf_MoveCursorLeft,                  36,   5,   34,  0{,   vk_Left});
            ENTER(CrtInfo,  cf_MoveCursorRight,                 36,   1,   33,  0{,   vk_Right});
            ENTER(CrtInfo,  cf_MoveCursorUp,                    36,   0,   33,  8{,   vk_Up});

            ENTER(CrtInfo,  cf_MoveCursorHome,                  36,   4,   31,  8);
//          ENTER(CrtInfo,  cf_NonPrintingCharacter,            47,   4,   43,  8);

            // The following items do not appear in SYSTEM.MISCINFO
            AddFunc(cf_MoveCursorDown, false, LF, vk_Down);
            AddFunc(cf_InsertLine,     true,  'I');  // default to VT-52 "Insert Line" sequence
//          AddFunc(cf_GotoXY,         false, 'Y',    'GOTOXY', true);   // Default to a VT-52 GOTOXY sequence

            CrtInfo.SetFunctionPrefixes(cf_LeadInToScreen, LOW_CRT_FUNC, HIGH_CRT_FUNC, VersionNr);
            LookForUnusedFuncs;
          end;
      end
  end;   { LoadCrtInfo }

  procedure LoadKeyInfo(KeyInfo: TCrtInfo; VersionNr: TVersionNr);
  begin { LoadKeyInfo }
    with KeyInfo do
      begin
        if Assigned(aStatusProc) then
          KeyInfo.StatusProc := aStatusProc;

        Reset('Key Info');

// The following is adapted from SETUP.CODE (easier than painstakingly adapting from SYSCOM.CRTINFO :(}

      {                                                         Pfxd  Pfxd Data Data
      {                                                         Word  Bit  Word Bit }
        ENTER(KeyInfo,                  kf_BackSpace,           -1,   -1,  34,  0);
        ENTER(KeyInfo,                  kf_EditorAcceptKey,     47,   13,  45,  8);
        ENTER(KeyInfo,                  kf_EditorEscapeKey,     47,   10,  44,  8,  vk_Escape);
        ENTER(KeyInfo,                  kf_KeyToMoveCursorDown, 47,   3,   39,  8,  vk_Down);
        ENTER(KeyInfo,                  kf_KeyToMoveCursorLeft, 47,   1,   40,  0,  vk_Left);
        ENTER(KeyInfo,                  kf_KeyToMoveCursorRight,47,   0,   40,  8,  vk_Right);
        ENTER(KeyInfo,                  kf_KeyToMoveCursorUp,   47,   2,   39,  0,  vk_Up);
        ENTER(KeyInfo,                  kf_KeyForBreak,         47,   7,   42,  0);
        ENTER(KeyInfo,                  kf_KeyForFlush,         47,   8,   41,  8);
        ENTER(KeyInfo,                  kf_KeyForStop,          47,   6,   42,  8);
        ENTER(KeyInfo,                  kf_KeyToDeleteCharacter,47,   12,  46,  0,  vk_Delete);
//      ENTER(KeyInfo,                  kf_KeyToDeleteLine,     47,   11,  44,  0);
        ENTER(KeyInfo,                  kf_KeyToEndFile,        47,   9,   41,  0);
        ENTER(KeyInfo,                  kf_LeadInFromKeyBoard,  -1,   -1,  45,  0);

        LookForUnusedFuncs;

        AddFunc(kf_KeyToMoveToNextWord, true, 'W');
        AddFunc(kf_PageUp,              true, 'O', vk_Prior);
        AddFunc(kf_PageDown,            true, 'P', vk_Next);

        SetFunctionPrefixes(kf_LeadInFromKeyBoard, LOW_KEY_FUNC, HIGH_KEY_FUNC, VersionNr);
      end
  end;  { LoadKeyInfo }

Begin { LoadCrtKeyInfo }
  LoadCrtInfo(CrtInfo, VersionNr);
  CrtInfo.InfoChanged;

  LoadKeyInfo(KeyInfo, VersionNr);
  KeyInfo.InfoChanged;
end;  { LoadCrtKeyInfo }


procedure LoadMiscInfo(Volume: TVolume; const FileName: string; var InBuf: TinBuf);
CONST
  STARTINDEX = 28 * 2;   {@MiscInfo - taken from SETUP.TEXT, they were words}
  ENDINDEX   = 47 * 2 ;  {          --> Expansion }
var
  DirIdx: integer;
  BlocksRead: integer;
  TempInBuf: TInBuf;  // We don't want to overwrite all of syscom-- only the realsize & CRT info
begin
  with Volume do
    begin
      FindDirectoryEntry(FileName, DirIdx);
      if DirIdx > 0 then
        begin
          with Directory[DirIdx] do   // FirstBlk
            BlocksRead := UCSDBlockReadRel(TempInBuf, 1, FirstBlk);

          if BlocksRead = 1 then
            // for now, just copy the MiscInfo stuff into the passed buffer (low memory-- SYSCOM)
            Move(TempInBuf.BufB[STARTINDEX], Inbuf.BufB[STARTINDEX], ENDINDEX-STARTINDEX+1);
        end
      else
        raise EFileNotFound.CreateFmt('%s could not be found on volume "%s:"', [FileName, VolumeName]);
    end;
end;

end.
