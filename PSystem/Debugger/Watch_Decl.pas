unit Watch_Decl;

interface

uses
  UCSDGlob, UCSDGlbu;

const
  POINTERSIZE     = 2;       // bytes
  
type
  TWatchCode = string[3];

  TWatchType = (wt_Unknown, wt_Ascii, wt_HexBytes, wt_HexWords, wt_DecimalInteger, wt_SemaphoreP, wt_ERECp, wt_TIBp, wt_SIBp, wt_MSCWp,
                wt_EVECp, wt_Poolinfo, wt_PoolDescInfo, wt_FIBp, wt_FaultMessage, wt_ProcedureName, wt_OpCodesDecoded,
                wt_DynamicCallStack, wt_StaticCallStack, wt_DirectoryEntryP, wt_MultiWordSet, wt_MultiWordCharSet,
                wt_VolInfo, wt_RegDumpHex, wt_RegDumpDec, wt_SegBaseInfo, wt_V_VectorMap,
                wt_W_ErecFromVectorMapN, wt_X_SibFromVectorMapN, wt_Y_SegBaseFromVectorMapN, wt_MemInfo,
                wt_String, wt_Integer, wt_MemPtr, wt_Boolean, wt_TID, wt_Alpha, wt_Word,
                wt_VID, wt_ParamDescrP, wt_HeapInfo, wt_TaskInfo, wt_Char, wt_PoolPtr,
                wt_Ped_Pseudo_Sibp, wt_SegDict, wt_PedHeader, wt_SegRecP, wt_SegRec, wt_Semaphore, wt_Diskaddress,
                wt_UnitTableP, wt_UnitTabEntry, wt_FIB, wt_ParamDescr, wt_EREC, wt_SegDictP, wt_stringp, wt_RealP, wt_Real, wt_DirectoryEntry,
                wt_SetOfChar, wt_Text, wt_File, wt_FullAddress, wt_ProcedureInfo, wt_JTAB, wt_DateRec,
                wt_DiskInfo, wt_SegNames, wt_SegKinds, wt_SegTable, wt_History, wt_Tree, wt_Linker_lientry, wt_Linker_workrec,
                wt_Linker_Symbol, wt_Linker_FileInfo, wt_LongInteger, wt_IOResult);

  TWatchTypeInfo = record
                 Alias: TWatchType;      // allows multiple names for a single type
                 WatchCode: TWatchCode;  // There are duplicate values which need to be cleaned up
                 WatchName: string;      // should not include "_" chars
                 WatchSize: word;        // This gets defaulted to 2 in the 'initialization' code.
                                         // In the table it is in bytes.
                                         // The GetWatchType function converts to the appropriate number of units for
                                         // the current Word_Memory mode.
                 WatchIsPointer: boolean;
                 BytesInString: byte;
                 ParamMeaning: string;
                 WatchDescription: string;
               end;

  TWatchTypes = array[TWatchType] of TWatchTypeInfo;

  TWatchTypesSet = set of TWatchType;
                
var
  WatchTypesTable: TWatchTypes {array[TWatchType] of TWatchTypeInfo} = (
  (Alias: wt_Unknown;        WatchSize : 2),
  (Alias: wt_Ascii;          WatchCode : 'A';   WatchName : 'Ascii';            BytesInString: 64;   ParamMeaning: 'NrBytes'),
  (Alias: wt_HexBytes;       WatchCode : 'B';   WatchName : 'HexBytes';         BytesInString: 64;    ParamMeaning: 'NrBytes'),
  (Alias: wt_HexWords;       WatchCode : 'W';   WatchName : 'HexWords';         ParamMeaning: 'NrBytes'),
  (Alias: wt_DecimalInteger; WatchCode : 'I';   WatchName : 'Decimal';          ParamMeaning: 'NrBytes'),
  (Alias: wt_SemaphoreP;     WatchCode : 'SP';  WatchName : 'SemaphoreP'),
  (Alias: wt_ERECp;          WatchCode : 'E';   WatchName : 'ERECp';            WatchIsPointer: true; ParamMeaning : '0=EREC; 1=EREC->SIB; 2=EREC->SIB->SegBase;3=EREC->EVEC;4=EREC->SIB->VolInfo'), // 0=EREC;
  (Alias: wt_TIBp;           WatchCode : 'T';   WatchName : 'TIBp';             WatchIsPointer: true; ParamMeaning : '0=TIB, 1=TIB->EREC, 2=TIB->EREC->SIB; 3=TIB->EREC->SIB->SegInfo'),
  (Alias: wt_SIBp;           WatchCode : 's';   WatchName : 'SIBp';             WatchIsPointer: true; ParamMeaning : 'Format#'; WatchDescription : 'Segment Information Block'),
  (Alias: wt_MSCWp;          WatchCode : 'M';   WatchName : 'MSCWp';            WatchIsPointer: true; WatchDescription : 'Mark Stack Control Word'),
  (Alias: wt_EVECp;          WatchCode : 'e';   WatchName : 'EVECp';            WatchIsPointer: true; WatchDescription : 'Environment Vectors'),
  (Alias: wt_Poolinfo;       WatchCode : 'P';   WatchName : 'PoolInfo';         WatchIsPointer: true; ),
  (Alias: wt_PoolDescInfo;   WatchCode : 'p';   WatchName : 'PoolDescInfoP';    WatchIsPointer: true; ),
  (Alias: wt_FIBp;           WatchCode : 'f';   WatchName : 'FIBp';             WatchIsPointer: true; WatchDescription : 'File Information Block';),
  (Alias: wt_FaultMessage;   WatchCode : 'F';   WatchName : 'FaultMessage';     WatchIsPointer: true; ParamMeaning : '0=SemiColons; 1=CRLF'),
  (Alias: wt_ProcedureName;  WatchCode : 'N';   WatchName : 'ProcedureName'),
  (Alias: wt_OpCodesDecoded; WatchCode : 'O';   WatchName : 'OpCodesDecoded';   WatchDescription : 'Opcodes Decoded'),
  (Alias: wt_DynamicCallStack;
                             WatchCode : 'C';   WatchName : 'DynamicCallStack'; WatchDescription : 'Dynamic Call Stack'),
  (Alias: wt_StaticCallStack; WatchCode : 'c';  WatchName : 'StaticCallStack';  WatchDescription : 'Static Call Stack'),
  (Alias: wt_DirectoryEntry; WatchCode : 'DEP'; WatchName : 'DirP';             WatchIsPointer: true; WatchDescription: 'Directory Entry Pointer'),
  (Alias: wt_MultiWordSet;   WatchCode : 'U';   WatchName : 'Set';              ParamMeaning : 'NrWords'; WatchDescription : 'display as numbered bits'),
  (Alias: wt_MultiWordCharSet;
                             WatchCode : 'u';   WatchName : 'CharSet';          ParamMeaning : 'NrWords'; WatchDescription : 'display as set of char'),
  (Alias: wt_VolInfo;        WatchCode : 'V';   WatchName : 'VIP';              WatchIsPointer: true; WatchDescription : 'Volume Info'),
  (Alias: wt_RegDumpHex;     WatchCode : 'R';   WatchName : 'RegDumpHex'),
  (Alias: wt_RegDumpDec;     WatchCode : 'r';   WatchName : 'RegDumpDec'),
  (Alias: wt_SegBaseInfo;    WatchCode : 'b';   WatchName : 'SegBaseInfo'),
  (Alias: wt_V_VectorMap;    WatchCode : 'v';   WatchName : 'VectorLength'),
  (Alias: wt_W_ErecFromVectorMapN;
                             WatchCode : 'EVM'; WatchName : 'ErecFromVectorMapN'),
  (Alias: wt_X_SibFromVectorMapN;
                             WatchCode : 'x';   WatchName : 'SibFromVectorMapN'),
  (Alias: wt_Y_SegBaseFromVectorMapN;
                             WatchCode : 'y';   WatchName : 'SegBaseFromVectorMapN'),
  (Alias: wt_MemInfo;        WatchCode : 'm';   WatchName : 'MemInfoP';         WatchIsPointer: true; ),
  (Alias: wt_string;         WatchCode : 'S0';  WatchName : 'String';           WatchSize: 80; BytesInString: 80),
  (Alias: wt_Integer;        WatchCode : 'DI';  WatchName : 'Integer';          WatchSize: 2),
  (Alias: wt_HexWords;       WatchCode : 'MP';  WatchName : 'MemPtr';           WatchIsPointer: true; ),
  (Alias: wt_Boolean;        WatchCode : '?';   WatchName : 'Boolean';          WatchSize: 2),
  (Alias: wt_String;         WatchCode : 'A';   WatchName : 'Tid';              WatchSize: TIDLENG+1),
  (Alias: wt_Ascii;          WatchCode : 'A';   WatchName : 'Alpha';            WatchSize: CHARS_PER_IDENTIFIER; BytesInString: CHARS_PER_IDENTIFIER),
  (Alias: wt_Word;           WatchCode : 'W';   WatchName : 'Word';             WatchSize: 2),
  (Alias: wt_String;         WatchCode : 'A';   WatchName : 'VID';              WatchSize: VIDLENG+1;         BytesInString: VIDLENG+1),  // should this have WatchIsPointer: true
  (Alias: wt_ParamDescrP;    WatchCode : 'PD';  WatchName : 'ParmDscrP';        WatchSize: 2;                 WatchDescription: 'Parameter Descriptor'),
  (Alias: wt_HeapInfo;       WatchCode : 'HI';  WatchName : 'HeapInfoP';        WatchIsPointer: true),
  (Alias: wt_TaskInfo;       WatchCode : 'TI';  WatchName : 'TaskInfoP';        WatchIsPointer: true),
  (Alias: wt_Char;           WatchCode : 'CH';  WatchName : 'Char';             WatchSize: 1;                 BytesInString: 1),
  (Alias: wt_PoolDescInfo;   WatchCode : 'p';   WatchName : 'PoolPtr';          WatchIsPointer: true),
  (Alias: wt_Ped_Pseudo_Sibp;WatchCode : 'PS';  WatchName : 'PedPseudoSib';     WatchIsPointer: true),
  (Alias: wt_SegDict;        WatchCode : 'SD';  WatchName : 'SegDict';          WatchSize: FBLKSIZE;          WatchDescription: 'Seg#'),
  (Alias: wt_PedHeader;      WatchCode : 'PH';  WatchName : 'PedHeader';        WatchSize: SizeOf(TPed_header)),
  (Alias: wt_SegRecP;        WatchCode : 'GP';  WatchName : 'SegRecP';          WatchIsPointer: true),
  (Alias: wt_SegRecP;        WatchCode : 'G';   WatchName : 'SegRec';           WatchSize: sizeof(TSegRec)),
  (Alias: wt_Semaphore;      WatchCode : 'S';   WatchName : 'Semaphore';        WatchSize: sizeof(TSemaPhore)),
  (Alias: wt_DiskAddress;    WatchCode : 'DA';  WatchName : 'DiskAddress';      WatchSize: SizeOf(TDiskAddress)),
  (Alias: wt_UnitTableP;     WatchCode : 'UT';  WatchName : 'UnitTableP';       WatchIsPointer: true;          WatchDescription: 'Unit TABLE'),
  (Alias: wt_UnitTabEntry;   WatchCode : 'UE';  WatchName : 'UnitTabEntry';     WatchIsPointer: true;          WatchDescription: 'Unit Table ENTRY'),
  (Alias: wt_FIBp;           WatchCode : 'f';   WatchName : 'FIB';              WatchSize: 594 {SizeOf(TFib)}; WatchDescription : 'File Information Block'),
  (Alias: wt_ParamDescrP;    WatchCode : 'PD';  WatchName : 'ParamDescr';       WatchSize: SizeOf(wt_ParamDescr); WatchDescription: 'Parameter Descriptor'),
  (Alias: wt_ERECp;          WatchCode : 'ER';  WatchName : 'EREC';             WatchSize: SizeOf(TErec);      WatchDescription: 'Environmental Record'),
  (Alias: wt_SegDictP;       WatchCode : 'SD';  WatchName : 'SegDictP';         WatchIsPointer: true;          ParamMeaning: 'Seg#'),
  (Alias: wt_stringp;        WatchCode : 'SP';  WatchName : 'StringP';                                         WatchDescription: 'Pointer to string descriptor'),
  (Alias: wt_real;           WatchCode : 'RP';  WatchName : 'RealP';            WatchIsPointer: true),
  (Alias: wt_real;           WatchCode : 'R4';  WatchName : 'Real';             WatchSize: SizeOf(Double)), // NOTE: WatchSize MAY BE CHANGED BY THE INTERPRETER!
  (Alias: wt_DirectoryEntry; WatchCode : 'Dir'; WatchName : 'DirEntry';         WatchSize: SizeOf(DirEntry);   WatchDescription: 'Directory Entry'),
  (Alias: wt_SetOfChar;      WatchCode : 'SC';  WatchName : 'SetOfChar';        WatchSize: 32 {bytes}),
  (Alias: wt_FIBp;           WatchCode : 'TF';  WatchName : 'Text';             WatchSize: 604 {bytes, = 301 words}; WatchDescription: 'Text File'),
  (Alias: wt_HexBytes;       WatchCode : 'Fil'; WatchName : 'File';             WatchSize: 80 {bytes}; WatchDescription: 'Generic File'),
  (Alias: wt_FullAddress;    WatchCode : 'FA';  WatchName : 'Fulladdress';      WatchSize: 4; WatchDescription: 'Full Address'),
  (Alias: wt_ProcedureInfo;  WatchCode : 'PI';  WatchName : 'Procedure Info';   WatchIsPointer: true;           WatchDescription: 'Proc#'),
  (Alias: wt_JTAB ;          WatchCode : 'JT';  WatchName : 'JTAB';             WatchSize: 12; ParamMeaning: 'param <> 0 for abs'; WatchDescription: 'V2 Jump Table'),
  (Alias: wt_DateRec;        WatchCode : 'Dat'; WatchName : 'DateRec';          WatchSize: 2;  WatchDescription: 'UCSD Date'),
  (Alias: wt_DiskInfo;       WatchCode : 'DI';  WatchName : 'DiskInfo';         WatchSize: SizeOf(TDiskInfo);   WatchDescription: 'ARRAY [SEGRANGE] OF SEGDESC'),
  (Alias: wt_SegNames;       WatchCode : 'SN';  WatchName : 'SegNames';         WatchSize: SizeOf(TSegNames);   WatchDescription: 'ARRAY [SEGRANGE] OF SEGNAME'),
  (Alias: wt_SegKinds;       WatchCode : 'SK';  WatchName : 'SegKinds';         WatchSize: SizeOf(TSegKinds);   WatchDescription: 'ARRAY [SEGRANGE] OF SEGKIND'),
  (Alias: wt_SegTable;       WatchCode : 'ST';  WatchName : 'SegTable';         WatchSize: SizeOf(TSegTbl);     WatchDescription: 'Ver II Segment Table'),
  (Alias: wt_History;        WatchCode : 'H';   WatchName : 'History';          WatchDescription: 'Recent History'),
  (Alias: wt_Tree;           WatchCode : 'TP';  WatchName : 'TreeP';            WatchIsPointer: true;           WatchDescription: 'Ver II Tree Structure'),
  (Alias: wt_Linker_lientry; WatchCode : 'LIE'; WatchName : 'lientry';          WatchDescription: 'format of link info records'),
  (Alias: wt_Linker_workrec; WatchCode : 'LW';  WatchName : 'workrec';          WatchDescription: 'Linker workrec'),
  (Alias: wt_Linker_Symbol;  WatchCode : 'LS';  WatchName : 'symp';             WatchIsPointer: true; WatchDescription: 'Linker Symbol'),
  (Alias: wt_Linker_FileInfo;WatchCode : 'LF';  WatchName : 'finfop';           WatchIsPointer: true; WatchDescription: 'Linker FileInfo'),
  (Alias: wt_LongInteger;    WatchCode : 'LI';  WatchName : 'LongInteger';      WatchDescription: 'Long Integer'),
  (Alias: wt_IOResult;       WatchCode : 'IO';  WatchName : 'IOResult';         WatchDescription: 'IO Result')
  );

procedure GetWatchTypeSize( wt: TWatchType;
                            Word_Memory: boolean;
                            var Varsize: word;
                            var ByteStreamCount: word);
function GetWatchType(wt: TWatchType; Word_Memory: boolean): TWatchTypeInfo;


implementation

function GetWatchType(wt: TWatchType; Word_Memory: boolean): TWatchTypeInfo;
begin { GetWatchType }
  result := WatchTypesTable[wt];
  if Word_Memory then
    with result do
      begin
        if Word_Memory then
          WatchSize := WatchSize shr 1 // div 2
      end;
end;  { GetWatchType }

procedure GetWatchTypeSize(wt: TWatchType; Word_Memory: boolean; var Varsize: word; var ByteStreamCount: word);
begin
  with WatchTypesTable[wt] do
    begin
      if Word_Memory then
        VarSize := WatchSize shr 1 // if Word_Memory then calc number of words needed
      else
        VarSize := WatchSize;
        
      if BytesInString <> 0 then
        ByteStreamCount := BytesInString  // for types like TAlpha so we know how long the string must be
      else
        ByteStreamCount := WatchSize;
    end;
end;

var
  wt: TWatchType;

initialization
  // Assume that if not otherwise indicated, it is a pointer
  for wt := Low(TWatchType) to High(TWatchType) do
    with WatchTypesTable[wt] do
      if WatchSize = 0 then
        WatchSize := POINTERSIZE;
end.
