Unit UCSDGlob;     {descended from (similar to) include file ucsdglob.pas LB}

INTERFACE

uses
  SysUtils, Interp_Const;
  
CONST
     MMAXINT  = 32767;	(*MAXIMUM INTEGER VALUE*)
     MAXUNIT  = 12;	    (*MAXIMUM PHYSICAL UNIT # FOR UREAD*)
     MAXDIR   = 77;	    (*MAX NUMBER OF ENTRIES IN A DIRECTORY*)
     VIDLENG  = 7;	    (*NUMBER OF CHARS IN A VOLUME ID*)
     TIDLENG  = 15;	    (*NUMBER OF CHARS IN TITLE ID*)
     MAXSEG   = 15;	    (*MAX CODE SEGMENT NUMBER*) { 15 for most, 31 for Apple ][, 63 for Apple /// }
     FBLKSIZE = 512;	  (*STANDARD DISK BLOCK LENGTH*)
//   DIRBLK   = 2;	    (*DISK ADDR OF DIRECTORY*)
     AGELIMIT = 300;	  (*MAX AGE FOR GDIRP...IN TICKS*)
     EOL      = 13;	    (*END-OF-LINE...ASCII CR*)
     DLE      = 16;	    (*BLANK COMPRESSION CODE*)
     BS       = 8;      (*BACKSPACE CHAR*)
     MAXPOT   = 308;    (* MAX POWER OF TEN *)

     {patch for CMDSTATE}
     HALTINIT  =  0;
     DEBUGCALL =  1;
     UPROGNOU  =  2;
     UPROGUOK  =  3;
     SYSPROG   =  4;
     COMPONLY  =  5;
     COMPANDGO =  6;
     COMPDEBUG =  7;
     LINKANDGO =  8;
     LINKDEBUG =  9;

     {patch for FILEKIND}
     
//   kUNTYPEDFILE= 0;
//   kXDSKFILE  =  1;
//   kCODEFILE  =  2;
//   kTEXTFILE  =  3;
//   kINFOFILE  =  4;
//   kDATAFILE  =  5;
//   kGRAFFILE  =  6;
//   kFOTOFILE  =  7;
//   kSECUREDIR =  8;
//   kSUBSVOL   =  9;

const
     USERPROGNR   = 15; { Slot number of USERPROG in segment dictionary }
     KERNELPROGNR = 0;  { Slot number if KERNEL in segment dictionary }

     p_locked   = -1;        { position locked segment status}

     CHARS_PER_IDENTIFIER = 8;

     ped_unused_words = 5;
                                {Number of unused words at end of
                                 ped_header record.}
MAX_STANDARD_UNIT = 74;   // for now


type
     integer  = SmallInt;    // dhd - 1/10/2018 must use 16 bit integers
     string80 = string[80];  // dhd - 1/10/2018

 (*
     IORSLTWD = integer;
                 (INOERROR,IBADBLOCK,IBADUNIT,IBADMODE,ITIMEOUT,
		 ILOSTUNIT,ILOSTFILE,IBADTITLE,INOROOM,INOUNIT,
		 INOFILE,IDUPFILE,INOTCLOSED,INOTOPEN,IBADFORMAT,
		 ISTRGOVFL); *)

     (*COMMAND STATES...SEE GETCMD*)

     CMDSTATE = integer; (*
                 (HALTINIT,DEBUGCALL,
		 UPROGNOU,UPROGUOK,SYSPROG,
		 COMPONLY,COMPANDGO,COMPDEBUG,
		 LINKANDGO,LINKDEBUG); *)

     (*ARCHIVAL INFO...THE DATE*)

     DATEREC = WORD;
                {
                PACKED RECORD
		 MONTH: 0..12;		(*0 IMPLIES DATE NOT MEANINGFUL*)
		 DAY: 0..31;		(*DAY OF MONTH*)
		 YEAR: 0..100		(*100 IS TEMP DISK FLAG*)
		END (*DATEREC*) ;
                }

     TIMEREC = WORD;
             { packed record
                        min:   0..59;
                        hour:  0..24;       // 24 means that the time is not set
               end; }

					(*VOLUME TABLES*)
     UNITNUM = WORD; {0..MAXUNIT;}
     TVID = STRING[VIDLENG];

					(*DISK DIRECTORIES*)
     DIRRANGE = WORD; {0..MAXDIR;}
     TID      = STRING[TIDLENG];

     FILEKIND = WORD; (*
                 (UNTYPEDFILE,XDSKFILE,CODEFILE,TEXTFILE,
		 INFOFILE,DATAFILE,GRAFFILE,FOTOFILE,SECUREDIR); *)

     DirEntry = RECORD
{ 0 }             DFIRSTBLK: INTEGER;	(*FIRST PHYSICAL DISK ADDR*)
{ 2 }		          DLASTBLK: INTEGER;	(*POINTS AT BLOCK FOLLOWING*)
{ 4 }		          CASE DFKIND: FILEKIND OF
     		            kSECUREDIR,
                    kUNTYPEDFILE: (*ONLY IN DIR[0]...VOLUME INFO*)
{ 6 }                   (DVID: TVID;		(*NAME OF DISK VOLUME*)
{ 14 }                   DEOVBLK: INTEGER;	(*LASTBLK OF VOLUME*)
{ 16 }			             DNUMFILES: DIRRANGE;	(*NUM FILES IN DIR*)
{ 18 }			             DLOADTIME: word;	(*TIME OF LAST ACCESS*)
{ 20 }			             DLASTBOOT: DATEREC);	(*MOST RECENT DATE SETTING*)
                    kXDSKFILE,kCODEFILE,kTEXTFILE,kINFOFILE,
		                kDATAFILE,kGRAFFILE,kFOTOFILE,kSUBSVOL:
{ 6 }			            (DTID: TID;		(*TITLE OF FILE*)
{ 22 }			           DLASTBYTE: 1..FBLKSIZE;	(*NUM BYTES IN LAST BLOCK*)
{ 24 }			           DACCESS: DATEREC)	(*LAST MODIFICATION DATE*)
{ 26 }		END (*DIRENTRY*) ;

     TDirectory = ARRAY [0..MAXDIR{DIRRANGE}] OF DirEntry;

     TDirectoryPtr = ^TDirectory;

      tib_p         = TShortPtr; // dhd
      mscw_p        = TShortPtr; // dhd
      int_p         = TShortPtr; // dhd
      e_rec_p       = TShortPtr; // dhd
        erecp         = TShortPtr; //    alternate spelling to e_rec_p
      p_meminfo_rec = TShortPtr; // dhd
      e_vec_p       = TShortPtr; // dhd
      poolptr       = TShortPtr; // dhd
      dirp          = TShortPtr; // dhd
      sem_p         = TShortPtr; // dhd
      sib_p         = TShortPtr; // dhd
      windowp       = TShortPtr; // dhd
      fib_p         = TShortPtr; // dhd

					(*FILE INFORMATION*)

     CLOSETYPE= (CNORMAL,CLOCK,CPURGE,CCRUNCH);

     WINDOW   = PACKED ARRAY [0..0] OF CHAR;

  TSemaphore = packed record     {semaphore format}
                 sem_count: integer;        {0. Number outstanding signals}
                 sem_wait_q: tib_p          {2. List of tasks waiting on sem}
               end {sem};

  TSemaPhorePtr = ^TSemaPhore;

  TreeId     = packed array[0..3] of byte;    {tree identification -
                                               accession number}
  TDiskAddress= packed
                 record
                   case integer of
                     0: (v1: array[0..2] of byte);    // [2] Is LSB, [1] is MSB, [0] always 0 (for now)
                     1: (v2: array[0..1] of integer)
                   end;

  FileOrganization = ( FOrg_Reserved, FOrg_KS, FOrg_DS, FOrg_IXO );

  TFIBPtr   = ^TFib;
  
  TFib = packed record
          FWindow:  windowp;    {byte 0: user window...f^, used by get and put}

//        {bit 0} FEoln,
//        {1}     FEof:     boolean;
//        {2-3}   FState:   (FJandW, FNeedChar, FGotChar);
//        {7}     FBufChngd,
//        {6}     FModified,            {new date must be set by close}
//        {5}     FIsBlkd,              {file is on blocked device}
//        {4}     FIsOpen:  boolean;
//        {8-15}  FReptCnt: byte;       {blank expansion repetition count}
          Stuff:    word;       {2: all of the above stuff packs into a single word}
          FRecSize: integer;    {4: logical record length in bytes}
          FLock:    TSemaphore; {6:}
          FVid:     TVID;        {10: volume on which file is located}
          FDirRoot: TDiskAddress; {18: root address of directory containing
                                       this file}
          { THE FOLLOWING ITEMS ARE PACKED IN USCD BUT NOT IN DELPHI-
            HENCE, ACCESSING THEM IN DELPHI WILL LEAD TO INCORRECT RESULTS }
          FUnit:    byte;       {unit number where file is located}
          FKeyCompType: 0..2;   {key comparison type: 0-char,1-int,2-user}
          FReadAfterWrite: boolean; {follow each write with a read to
                                     insure write was successful. }
          FTempFile: boolean;   {true if file is a temp disk file}
          FExclusive: boolean;  {true if we have exclusive access}
          FPackingFactor: ( pf_50, pf_63, pf_75, pf_88, pf_100 ); {% packed}
          FKDataLen: byte;      {key data length}
          FKeyLen:  byte;       {key maximum length}
          FType:    byte;       {file type}

          { index attribute flags }
          FReadOnly,            {no write or update permitted}
          FKeyVarLen,           {key is variable length}
          FRecVarLen,           {records are variable length}
          FBlocked,             {records are blocked (KS only)}
          FSpan,                {records can span extents (DS only)}
          FDupKeysAllowed,      {duplicate keys are allowed}
          FKeyEmbedded: boolean; {keys are embedded in the records}

          FSoftBuf: boolean;    {512 byte buffer available following fib}
          FRootAdr: TDiskAddress; {root node disk address}
          FTreeId:  TreeID;     {accession number for the file}
          FCurPos:  record      {current position within leaf node}
                      LeafAdr: TDiskAddress; {leaf node disk address}
                      KeyStart: integer;    {offset in leaf node to
                                             index element}
                      RecStart: integer;    {offset in leaf node to
                                             current record}
                    end;
          case FOrg: FileOrganization of
            FOrg_DS:
              ( FLastByte: 0..512; {last byte of last block}
                FMaxBlk,   {maximum relative block accessed.  For
                            existing files this is initially the
                            size of the file.}
                FNxtBlk: integer; {next relative block to access}
                FMaxByte,
                FNxtByte: 0..512; {next byte in buffer to access}
                
                        {foreign file system support}
                FAppendLF,         {append LF to line after CR}
                FForeign: boolean; {true if file on a foreign file system}
                
                case boolean of
                  true:
                    ( {AFS fields not used by SFS}
                      FExtntAdr:  TDiskAddress;  {current extent start address}
                      FPriAlloc:  byte;         {primary allocation size}
                      FSecAlloc:  byte;         {secondary allocation size}
                      FExtntLen:  integer;      {current extent size in blocks}
                      FFirstRelBlk: integer;    {rbn of 1st blk in cur extent}
                      FDataSize:  integer;      {total data blocks allocated}
                      FNodeSize:  integer       {total node blocks allocated}
                    );
                  false:
                    (  {SFS fields not used by AFS}
                      FHeader: DirEntry;        {file directory entry}
                      {must be last field in record but is common
                       to both AFS and SFS.  only present if FSoftBuf
                       is true.  }
                      case {FSoftBuf:} boolean of
                        true: ( FBuffer: packed array[0..FBlkSize] of char )
                    )
              );
            FOrg_KS,
            FOrg_IXO:
              ( FLastOp: (FLastRead, FLastWrite, FLastSeek, FLastDelete);
                {descriptor of function for key comparison}
                FKeyCmpEREC: E_Rec_P;
                FKeyCmpStaticLink: mscw_p;
                FKeyCmpProcNo: byte;
                FExtntAlloc: byte;   { desired KS extent size }
                FKeyOffset: integer; { only valid if FKeysEmbedded=true }
                FReserved: array[27..31] of integer;
                { the next two fields have the same offset as FFileSize and
                  FNodeSize, they represent the same fields and either may be
                  used for DS,KS,IXO (not applicable to SFS) }
                FDataCount: integer; { total data blocks allocated (0 for IXO) }
                FNodeCount: integer  { total node blocks allocated }
              );
  end {fib}; { Delphi:SizeOf(TFib) = 607;
               p-Sys: SizeOf(Fib)  = 594 }

  (*
     FIB = RECORD     // needs to be packed on Delphi
	     {00} FWINDOW: WINDOWP;	{USER WINDOW...F^, USED BY GET-PUT}
//     FEOF,FEOLN: BOOLEAN;       { 1 bit each }
//     FSTATE: (FJANDW,FNEEDCHAR,FGOTCHAR);     { 2 bits }
       {01} Stuff: word;
	     {02} FRECSIZE: INTEGER;	{IN BYTES...0=>BLOCKFILE, 1=>CHARFILE}
	     CASE {03} FISOPEN: BOOLEAN OF
		TRUE: (FISBLKD: BOOLEAN;  {FILE IS ON BLOCK DEVICE}
			FUNIT: UNITNUM;	  {PHYSICAL UNIT #}
			FVID: VID;	  {VOLUME NAME}
			FREPTCNT,	  { # TIMES F^ VALID W/O GET}
			FNXTBLK,	  {NEXT REL BLOCK TO IO}
			FMAXBLK: INTEGER; {MAX REL BLOCK ACCESSED}
			FMODIFIED:BOOLEAN;{PLEASE SET NEW DATE IN CLOSE}
			FHEADER: DIRENTRY;{COPY OF DISK DIR ENTRY}
			CASE FSOFTBUF: BOOLEAN OF {DISK GET-PUT STUFF}
			TRUE: (FNXTBYTE,FMAXBYTE: INTEGER;
				  FBUFCHNGD: BOOLEAN;
				  FBUFFER: PACKED ARRAY [0..FBLKSIZE] OF CHAR))
	   END {FIB} ;
*)
					(*USER WORKFILE STUFF*)

     INFOREC = RECORD
		 CODEFIBP: FIB_P;	(*WORKFILES FOR SCRATCH*)
		 SYMFIBP : FIB_P;
                 ERRNUM  : INTEGER;	(*ERROR STUFF IN EDIT*)
		 ERRBLK  : integer;
                 ERRSYM  : integer;
                 STUPID  : BOOLEAN;	(*STUDENT PROGRAMMER ID!!*)
		 SLOWTERM: Boolean;
                 ALTMODE : CHAR;	(*WASHOUT CHAR FOR COMPILER*)
		 GOTCODE : BOOLEAN;	(*TITLES ARE MEANINGFUL*)
		 GOTSYM  : Boolean;
                 CODEVID : TVID;	        (*PERM&CUR WORKFILE VOLUMES*)
		 SYMVID  : TVID;
                 WORKVID : TVID;
                 CODETID : TID;	        (*PERM&CUR WORKFILES TITLE*)
                 SYTID   : Tid;
                 Worktid : Tid;
		END (*INFOREC*) ;

					(*CODE SEGMENT LAYOUTS*)

     SEGRANGE = 0..MAXSEG;
     SEGDESC = RECORD
		 DISKADDR: INTEGER;	(*REL BLK IN CODE...ABS IN SYSCOM^*)
		 CODELENG: INTEGER	(*# BYTES TO READ IN*)
		END (*SEGDESC*) ;

					(*DEBUGGER STUFF*)

     TRICKARRAY = ARRAY [0..0] OF WORD; (* FOR MEMORY DIDDLING*)

      TVinfo      = record
                     SegUnit: integer;  {0}
                     SegVid: TVID;      {2}
                   end {of vinfo};      {10}

      TVinfoPtr = ^TVinfo;

  TSibPtr    = ^TSib;
  
  TSib        = record
{ 0}             Seg_Pool:  TShortPtr; // poolptr;         {0 SIBPOOL: pointer to code pool descriptor}
{ 2}             Seg_Base:  TShortPtr; // mem_ptr;         {1 SIBBASE: Base memory location of dictionary}
{ 4}             Seg_Refs:  word;                          {2 SIBREFS: number of active calls}
{ 6}             timestamp: integer;                       {3 SIBTIME: Memory swap priority}
{ 8}             seg_pieces: TShortPtr; // ^c_file_struct; {4 SIBPIECE: describes code file structure}
{10}             residency: p_locked..Mmaxint;             {5           memory residency status}
{12}             seg_name:  Talpha;                         {6 SIBNAME: Segment name}
{20}             Seg_Leng:  word;                          {10 SIBRES: number of words in segment}
                 { If seg_pieces is NIL, seg_addr is a disk address and the
                   segment is contiguous, otherwise it is a relative block
                   number within the code file and seg_pieces points to a
                   structure describing its extents. }
{22}             Seg_Addr:  word;                          {11 Disk address of segment}
{24}             vol_info:  TShortPtr; // TVip;            {12 Disk unit and vol id of segment}
{26}             data_size: word;                          {13 Number of words in data segment}
{28}             res_sibs:  record          {Code Pool management record}
//{30}                          next_sib,                  {15 Pointer to next sib}
//{28}                          prev_sib: TShortPtr; // sib_p;  {14 Pointer to previous sib}
{30}                          prev_sib,                    {15 Pointer to next sib}
{28}                          next_sib: TShortPtr; // sib_p;  {14 Pointer to previous sib} (RE-ORDERED FOR DELPHI)
                                case boolean of {Scratch area}
{32}                              true:  (next_sort: TShortPtr {sib_p});   {16}
{32}                              false: (new_loc: TShortPtr {mem_ptr});   {16}
                              end {res_sibs};
{34}              mtype:     integer;        {17 Machine type of segment}
{36}           end {sib};

      TEvecPtr   = ^TEvec;
      
      TEvec      = record     {Environment vector}
{ 0}                 vect_length: integer;
{ 2}                 map: array[1..1] of e_rec_p;   {Accessed $R-}
                   end {e_vec};

      TErecPtr   = ^TErec;

(*
      TErec      = record     {Environment record}
{ 0}                 env_data: mem_ptr;     {Pointer to base data segment}
{ 2}                 env_vect: e_vec_p;     {Pointer to environment vector}  // <-- are these two reversed?
{ 4}                 env_sib:  sib_p;       {Pointer to associated segment}  // <-- are these two reversed?
                     case boolean of        {Outer block information}
{ 6}                     true: (Link_Count: integer;
                                next_rec: e_rec_p);
{
{ 6}                     true: (next_rec: e_rec_p;  // order changed for delphi
                                link_count: integer);
}
{ 8}               end; {e_rec}
*)

      TErec      = record     {Environment record}  { for some reason Delphi, does not see "Link_Count" properly in the above definition }
{ 0}                 Env_Data: TShortPtr;     {Pointer to global data segment}
{ 2}                 Env_Vect: e_vec_p;     {Pointer to environment vector}  // <-- are these two reversed?
{ 4}                 Env_Sib:  sib_p;       {Pointer to associated segment}  // <-- are these two reversed?
{ 6}                 Link_Count: integer;
{ 8}                 Next_Rec: e_rec_p;
{10}               end; {e_rec}

     TMscwPtr = ^ TMscw;
     
     TMscw = RECORD
{ 0}   STATLINK : word; {MSSTAT}(*POINTER TO PARENT MSCW*)
{ 2}   DYNLINK  : word; {MSDYNL}(*POINTER TO CALLER'S MSCW*)
{ 4}   MSIPC    : word;         (*Caller's IPC*)
{ 6}   MSENV    : word;         (*ERECp: Caller's environment*)
{ 8}   MSPROC   : word; {MSPROC}(*Procedure Number of Caller*)
{10}   LOCALDATA: TRICKARRAY    (*FOR the global data area, this will contain the address of SYSCOM*)
{12} END (*MSCW*) ;

  TTibPtr = ^TTib;

  TTib        = packed record     {task information block (14 words)}
                 regs: packed record        {WORD offset & description}
{ 0} {TIBLINK}           wait_q: tib_p;     { 0 Queue link for semaphores}
{ 2} {TIBPRI}            prior: byte;       { 1 Task's cpu priority}
{ 3}                     flags: byte;       { 1 State flags...not defined yet}
{ 4} {TIBSPLO/TIBLSPL}   sp_low: TShortPtr;   { 2 Lower stack pointer limit}
                                            {   Same as SP_Low for an internal pool.}
{ 6} {TIBSPHI/TIBUSPL}   sp_upr: TShortPtr;   { 3 Upper limit on stack}
{ 8} {TIBSP}             sp: TShortPtr;       { 4 Actual top of stack pointer}
{10} {TIBMP}             mp: mscw_p;        { 5 Active procedure MSCW ptr}
{12}                     task_link: tib_p;  { 6 links all tasks in system (unused?)}
{14} {TIBIPC}            ipc: word;         { 7 byte ptr in current code seg}
{16} {TIBEREC}           env: e_rec_p;      { 8 Ptr to current environment}
{18} {TIBPROC}           ProcNum: byte;     { 9 procedure currently executing}
                         TibIOResult: byte; { 9 current ioresult}
{20} {TIBHANG}           hang_p: sem_p;     {10 Which task is waiting on}
{22} {TIBMDEP}           m_depend: integer; {11 Reserved for interpreter}
                                            {   initted to 0 when process started}
                       end {regs};
{24} {TIBMNTSK}  task_stuff: word;          // packed as shown below
//               main_task: boolean;        {12 [bit 0] indicates operating system main task}
//               system_task: boolean;      {12 [bit 1] indicates system tasks}
//               reserved: 0..16383;        {12 future use}
                 start_mscw: mscw_p;        {13 mp at bottom of task stack}
{28}            end; {tib}


//  semaphore = array[0..1] of integer;  { dhd - 2 words, 4 bytes }

  TParmDesc = record
                Erec_Addr: word;
                Parm_Addr: word;
              end;
  TParmDescPtr = ^TParmDesc;
  
  FullAddress = array[0..1] of word;     {32 bits}

  TSocketPoolInfo = packed record
                      Base: FullAddress; {4 bytes: 2..5} {address of area}
                      Size: word;        {2 bytes: 0..1} {size units vary see above}
                    end;

  TMemInfoPtr = ^TMemInfo_Rec;
(* original
  MemInfo_Rec = record
{ 0}             NWords:integer;  {2} {size of meminfo_rec, currently 6}
{ 2}             FreeSpaceInfo,   {size units are 512 bytes}
                 SocketPoolInfo: TSocketPoolInfo; {6}
{14}           end {meminfo_rec};
*)
  TMemInfo_Rec = packed record  // reversing SocketPoolInfo and FreeSpaceInfo for Delphi
{ 0}             NWords:integer;  {2 bytes @ 0} {size of meminfo_rec, currently 6}
{ 8}             SocketPoolInfo   {6 bytes @ 8; size @ 8, Base[0] @ 10, Base[2] @ 12},
{ 2}             FreeSpaceInfo    {6 bytes @ 2; size @ 2, Base[0] @ 4,  Base[1] @ 6} {size units are 512 bytes}
                               : TSocketPoolInfo;
{14}           end {meminfo_rec};

  TMTypes    = ( { 0} m_pseudo, m_6809, m_pdp_11, m_8080,
                 { 4} m_z_80, m_ga_440, m_6502, m_6800,
                 { 8} m_9900, m_8086, m_z_8000, m_68000,
                 {12} m_hp_87, m_16000, m_80186, m_80187 );

 AliasRec   = record
                 Name: TVID;
                 Index: integer;  {index in AliasPool^ of file specifications}
               end {aliasrec};

  AliasTable = array[1..1] of AliasRec; {accessed $r-}
// AliasTab_p = ^AliasTable;
  AliasTab_p  = TShortPtr;

  FileSysLevel = (SFS,AFS);       {possible file system configurations}

(*
Faults can be signaled either by the PME or by the OS itself.
The PME detects only stack and segment faults, which have been described in more details in the relevant chapter.

The OS routes all faults through the EXECERROR routine.
It can issue a segment fault in only one occasion: when you try to use MEMLOCK
to lock a segment that's not in memory.
It can also issue heap faults, when you are using MARK, NEW, VARNEW or PERMNEW
and there isn't enough memory on the heap.

As discussed above, FaultHandler then tries to move around segments in the
code pool, and free some memory. When doing this, it must of course make sure
that the current segment will not be swapped out of memory!
In case of a stack fault created by calling a routine in a different segment,
both segments must be locked in memory.
*)
  TFault_message = record
{0}    {18}         fault_tib: tib_p;        // FLTTIB:  points to the Task Information Block (TIB) of the faulting task.
{2}    {20}         fault_e_rec: e_rec_p;    // FLTEREC: points to the Environment record of the current segment or of the missing segment (for segment faults).
{4}    {22}         fault_words: word;       // FLTNWDS: is the number of words needed (e.g. for stack faults). It's 0 for segment faults.
//{6}               fault_type: seg_fault..pool_fault;
{6}    {24}         fault_type: integer;     // FLTNUM:  indicates the type of fault ($80=segment, $81=stack, $82=heap, $83=pool, etc).
{8}    {26}       end {TFault_message};

  TFault_messagePtr = ^TFault_message;

  TPoolInfo = record
            {32} {0}         pooloutside: boolean;
            {34} {2}         poolsize: integer;     // is the size in words of the code pool. Set by the SETUP utility.
            {36} {4}         PoolBaseAddr: fulladdress; //  is a 32-bits address that points at the base of the code pool.
            {40} {8}         resolution: integer;   // is the offset in bytes for segment alignment,
                                                    // set in SYSTEM.MISCINFO.
                                                    // Segments always start at an address which is a
                                                    // multiple of this number.
            end {poolinfo};   {size = 10d}

  TPoolInfoPtr = ^TPoolInfo;

  TPoolDescInfo = record
    { 0} PoolBaseAddr: fulladdress;
    { 4} poolsize: integer;
    { 6} minoffset: TShortPtr;
    { 8} maxoffset: TShortPtr;              {MaxOffset is the upper boundary of the code pool.}
    {10} resolution: integer; {in bytes}  {Resolution is smallest allocatable code area}
    {12} poolhead: sib_p;
    {14} permsib: sib_p;
    {16} extended: boolean;
    {18} nextpool: poolptr;  {circular list of code pool descriptors}
    {20} mustcompact : boolean;
  end {TPoolDescInfo}; {size = 22d}

  TPoolDescInfoPtr = ^TPoolDescInfo;

  TSysComPtr = ^TIVSysComRec;

  TPMachineVersion = (pre_iv_1, iv_1, iv_2, version_Unknown);

  { SYSTEM COMMUNICATION AREA - SYSCOMFILE OF  }
  { See interpreters...note that we assume backward field allocation is
    done by the compiler.  Word offsets indicated to left of fields, only
    first field in a word is marked, only first word of field is listed. }
  TIVSysComRec  = record           {modified for IV.1}
            {00} iorslt: TIORsltWD;          {result of last I/O call}
            {02} APoolSize: integer;        {alias pool size}
            {04} sysunit: integer; {unitnum} {physical unit of bootload}
            {06} max_io_bufs: byte;         {number of I/O buffers allocated}
            {08} gdirp: dirp;               {global dirp, SFS only}
            // THIS IS THE WAY TO DECLARE IT (FAULT_SEM) IN DELPHI TO SEE THE SAME THINGS
            // (message_sem & real_sem are reversed in p-System)
            {10} fault_sem: record
            {10}              message_sem,           { message_sem and real_sem HAVE BEEN REVERSED FOR DELPHI }
//                    {10}                           sem_count: integer;        {Number outstanding signals}
//                    {12}                           sem_wait_q: tib_p          {List of tasks waiting on sem}
            {14}              real_sem: Tsemaphore; { 4 bytes - semaphore to start the faulthandler}
//                    {14}                           sem_count: integer;        {Number outstanding signals}
//                    {16}                           sem_wait_q: tib_p          {List of tasks waiting on sem}

            {18}              Fault_Message: TFault_message; { 8 bytes }
(*
                              TFault_message = record
                            {18}         fault_tib: tib_p;        // points to the Task Information Block (TIB) of the faulting task.
                            {20}         fault_e_rec: e_rec_p;    // points to the Environment record of the current segment or of the missing segment (for segment faults).
                            {22}         fault_words: integer;    // is the number of words needed (e.g. for stack faults). It's 0 for segment faults.
                            {24}         fault_type: integer;     // indicates the type of fault ($80=segment, $81=stack, heap, pool, etc).
                            {26}       end {TFault_message};
*)
                            end {fault_sem};
                 {starting unit number for subsidiary volumes}
            {26} SubsidStart: integer; // was: unitnum;
            {28} AliasMax: integer; {byte;} {max number of aliases}
            {30} Spool_Avail: boolean;      {print spooler enabled}
            {32} PoolInfo: TPoolInfo;
            {42} TimeStamp: integer;     // this can overflow !
            {44} UnitTable: TShortPtr;
            {  } UnitDivision: packed record
            {46}                 SerialMax: byte;  {number of serial units}
            {47}                 SubsidMax: byte;  {max number of subsid vols}
                               end {unitdivision};
            {48} ExpanInfo: packed record
            {  }              InsertChar,
            {  }              DeletChar: char;
                            end {expaninfo};
            {50} Processor: TMTypes;               {actual processor type}
            {52} Mem_Info: p_meminfo_rec;
            {54} pmachver: TPmachineVersion;
            {56} realsize: integer;
            {58} miscinfo: packed record
//          {  }             nobreak[bit6],stupid[5],slowterm[4],
//                           hasxycrt[3],haslccrt[2],has8510a[1],hasclock[0]: boolean;
//                           userkind: (normal[6,7], aquiz[8,9], booker[10,11],
//                           pquiz);
            {58}             FLAGS: integer;
                           end {miscinfo};
            {60} crttype: integer;
(*          ORIGINAL VERSION
            {  } crtctrl: packed record
            {62}            rlf,ndfs,eraseeol,eraseeos,home,escape: char;
            {  }            backspace: char;
                            fillcount: 0..255;
            {70}            clearscreen,clearline: char;
            {72}            prefixed: integer; {packed array[0..8] of boolean;}
                          end {crtctrl};
*)          // RE-ORDERED FOR DELPHI COMPATABILITY:
            {  } crtctrl: packed record
            {62}            escape,home,eraseeos,eraseeol,ndfs,rlf: char;
            {  }            backspace: char;
                            fillcount: 0..255;
            {70}            clearline,clearscreen: char;
            {72}            prefixed: integer; {packed array[0..15] of boolean;}
                          end {crtctrl};
(*          ORIGINAL VERSION
            {74}  crtinfo: packed record
            {74}            width,
            {76}            height: integer;
            {78}            right,left,down,up: char;
            {82}            badch,chardel,stop,break,flush,eof: char;

            {88}            altmode,linedel: char;
            {90}            alphalok,char_mask,etx,prefix: char;
//                          prefixed: packed array[0..15] of boolean;
            {94}            prefixed: integer;
*)
             // RE-ORDERED FOR DELPHI COMPATABILITY:
            {74}  crtinfo: packed record
            {74}            height,            // width,
            {76}            width: integer;    // height: integer;
            {78}            up,down,left,right: char;
            {82}            eof,flush,break,stop,chardel,badch: char;
            {88}            linedel,altmode: char;
            {90}            prefix,etx,char_mask,alphalok: char;
//                          prefixed: packed array[0..15] of boolean;
            {94}            prefixed: integer;
            {96}         end {crtinfo};
end {syscom};

     sc_chset = set of char;

     TMiscInfoPtr = ^TMiscInfo;
     
     TMiscInfo = record
{ 0 }                   s : TIVSysComRec;
{ 48 }                  c : sc_chset;  (* printable chars *)
{ 64 }                  FaultHandlerStack : INTEGER;
                        Pnet_Pool : RECORD
{ 65 }                                PoolOutside : BOOLEAN;
{ 66 }                                PoolSize    : INTEGER;
{ 67 }                                PoolBase    : FullAddress;
                                     END;
                        Events    : PACKED RECORD
{ 70 }                                Tick,
{ 69 }                                Asynch_Char : BOOLEAN;
                                    END;
//                      OtherStuff: PACKED ARRAY [0..511] OF CHAR;
{ 140 }          end;

//      TSegment_Name = PACKED ARRAY [0..CHARS_PER_IDENTIFIER-1] OF CHAR; {segment name}
        TSegment_Name = TAlpha;

//      TSeg_Types    =  ({0} no_seg,
//                        {1} prog_seg,
//                        {2} unit_seg,
//                        {3} proc_seg,
//                        {4} seprt_seg);

//      TVersions      =  (unknown, ii, ii_1, iii, iv, v, vi, vii);

        TSeg_code_rec=record
{0}                    code_addr: word; {2} { starting block number within file }
{2}                    code_leng: word; {2} { number of words for V4- (other versions might be bytes) in segment }
{4}                  end {seg_code_rec};

        TSeg_misc_rec=packed record
//                     seg_type:seg_types;    { 3 bits: 0..2}
//                     filler:0..31;          { 5 bits: 3..7}
//                     has_link_info:boolean; { 1 bit: 8..8}
//                     relocatable:boolean;   { 1 bit: 9..9 }
                       SegMiscRec: word;  // everything packed into a single word
                     end {seg_misc_rec};

        TSeg_info_rec=packed record
//                     seg_num:0..255;           { 8 bits: 0..7 - local seg number }
//                     m_type:m_types;           { 4 bits: 8..11 - machine types }
//                     filler:0..1;              { 1 bit: 12..12 }
//                     major_version:versions;   { 3 bits: 13..15 - p-machine version}
                       SegInfo: word  // everything packed into one word
                     end {seg_info_rec};

        TSeg_Famly_Rec = record
                      case TSeg_types of
                        unit_seg,                            { offset in bytes }
                        prog_seg:( data_size     : word;     { 0: data size }
                                   seg_ref_words : word;     { 2: number of segments in compilation unit }
                                   max_seg_num   : word;     { 4: number of segments in file }
                                   text_size     : word );   { 6: # of blks interface text }
                        proc_seg:( host_name     : TSegment_Name ); { 0 outer program/unit name }
                      end {seg_famly_rec};      { total size = 8 bytes }

        TDiskInfoArray = array[SEGRANGE] of TSeg_code_rec;
        TSegNameArray  = array[SEGRANGE] of TSegment_name;
        TSegMiscArray  = array[SEGRANGE] of TSeg_Misc_Rec;
        TSegTextArray  = array[SEGRANGE] of word;            { start blk of interface text }
        TSegInfoArray  = array[SEGRANGE] of TSeg_Info_Rec;
        TSegFamilyArray= array[SEGRANGE] of TSeg_Famly_Rec;

        TSeg_DictPtr = ^TSeg_Dict;

        SegSet       = SET OF SegRange ;

        TSeg_Dict = record
{0}                disk_info: TDiskInfoArray; {64}
{64}               seg_name:  TSegNameArray;  {128}
{192}              seg_misc:  TSegMiscArray;  {32}
{224}              seg_text:  TSegTextArray;  {32}
{256}              seg_info:  TSegInfoArray;  {32}
                   case boolean of
                     false:  { SofTech }
{288}                  (
                         seg_family:TSegFamilyArray;  {128}
      {416}              next_dict: word;        {2}
      {418}              filler:    array[0..1] of integer; {4}
      {422}              checksum:  integer;        {2}
      {424}              ped_block: integer;        {2}
      {426}              ped_blk_count:integer;     {2}
      //                 part_number:packed array[0..7] of 0..15;
                           // this is only 4 bytes on the p-system but would take 8 in Delphi
      {428}              part_number: packed array[0..1] of word; {4}
      {432}              copyright:  string[77];    {78}
      {510}              sex:        word;       {2}
                       );
                     true: { UCSD, Apple, WD, VS }
                       ( IntSegSet : SegSet ; { 1 word on most, 2 on A][, 4 on A/// }
                         IntChkSum : PACKED ARRAY [0..MaxSeg] OF 0..255 ; {valid on A/// only}
                         Filler2   : ARRAY[0..35] OF INTEGER ;
                         Comment   : PACKED ARRAY[0..79] OF CHAR
                         ) { 111 words };
{512}            end {seg_dict};

//      seg_recp=^seg_rec;
        seg_recp = TShortPtr;

        TSegRecPtr = ^TSegRec;

        TSegRec = packed record
                  seg_name     : Talpha;        { segment name }
                  right_link   : seg_recp;     { right link in tree }
                  left_link    : seg_recp;     { left link in tree }
                  seg_proc     : seg_recp;     { list of segment procedures }
                  seg_erec     : erecp;        { erec of this segment }
                  code_leng    : integer;      { code segment length (WORDS) }
                  code_addr    : integer;      { block on disk or in file }
                  vol_info     : TShortPtr; // vip;   { code file volume info }
//                {$b small-}
                  file_structure: TShortPtr; // ^c_file_struct;{ code file structure }
//                {$e small-}
//                seg_num       : 0..255;      { local segment number }
//                has_link_info : boolean;     { 6: needs to be linked }
//                relocatable   : boolean;     { 5: has relocatable code }
//                m_type        : m_types;     { 0..4: machine type }
                  packed_stuff  : word;          { The above 4 fields are packed in p-Code }
                  case seg_type : Tseg_types of
                    unit_seg,
                    prog_seg:( data_size     : integer;   { global data space }
                               seg_ref_words : integer;   { seg ref list words }
                               max_seg_num   : integer ); { evec size }
                    proc_seg:( host_name     : Talpha );   { host prog/unit name }
                end {seg_rec};


  TParameterDescriptor = record
                         addr_of_ERec: word;
                         source_offset: word;
                       end;

  TParameterDescriptorPtr = ^TParameterDescriptor;

  THeap_info  = record               {stuff for heap management}
                 lock: TSemaphore;
                 heap_top,          { fields interchanged for Delphi }
                 top_mark: TShortPtr;
               end {  heap_info};

  THeap_infoPtr = ^THeap_info;

  TTask_info  = record               { stuff for task management }
                 task_done,         { fields interchanged for Delphi }
                 lock: TSemaphore;
                 n_tasks: integer;
               end {  task_info};

  TTask_InfoPtr = ^TTask_Info;

  TPedSseudoSibPtr = ^TPedSseudoSib;
  
  TPedSseudoSib =          {PED Pseudo SIB Structure.}
    record
      PsSegName: Talpha;     {Name of segment.}

      PsSegLeng: integer;   {Length of segment.}

      PsSegAddr: integer;   {Relative block address of segment in library file.}

      PsSegDataSize: integer; {Size of segment data area.}

      PsSegLibNum: integer; {Index into sequence of library code file descriptors.}

      PsSegAttributes:
           packed
           record
             Attributes: word; // replaces bit stuff below
//           {bit 0}ps_relocatable: boolean;  {Relocatable indicator from segment dictionary.}

//           {bit 1-4}ps_mach_type: m_types;  {Type of code in segment.}
//           ps_filler: 0..2047;              {11 bits of filler to round out to one word.}
          end;
    end;

    TSegStruct = record
                   ProcDictOffset: word;      // byte offset of procedure dictionary
                   RelocListOffset: word;     // byte offset of relocation list
                   SegName: TSegment_Name;    // ascii name
                   SegSex: word;              // byte offset byte sex
                   SegConst: word;            // byte offset of constant pool
                 end;

    TSegStructPtr = ^TSegStruct;

    TPed_headerPtr = ^TPed_Header;

    TPed_header =              {PED Header Record.}
        record
          ped_byte_sex: integer;
                              {PED Byte sex indicator.}

          ped_format_level: integer;
                              {PED structures version indicator.}

          ped_library_count: integer;
                              {Number of library file descriptors.}

          ped_principal_segment_count: integer;
                              {Number of principal segments described.}

          ped_subsidiary_segment_count: integer;
                              {Number of subsidiary segments described.}

          ped_total_evec_words: integer;
                              {Size of EVEC templates.}

          ped_last_system_segment: integer;
                              {Last global segment number assigned to identify system units.}

          ped_start_unit: integer;
                              {Global segment number of principal segment where execution should begin.}

          ped_uses_realops_unit: boolean;
                              {TRUE if REALOPS unit required.}

          {The following portion of the ped_header varies
           depending on the format level. The structure will
           be defined in terms of format level 3. Minor 
           adjustments to ped_header size will have to be made
           to run programs with formats 1 and 2. Format 1 is
           produced by systems before IV.2. Format 2 and 3 are
           produced by IV.2 and above.}
            
            
          { FORMAT 1 HEADER ends with
          ped_expansion_area:
               array[1..ped_unused_words] of 0..0;
            
          }
            
          { FORMAT 2 HEADER ends with
          ped_level_2: array[0..1] of integer;
          ped_expansion_area:
               array[1..ped_unused_words-2] of 0..0;
            
          }
            
          { FORMAT 3 HEADER ends with}
          ped_level_3: array[0..5] of integer;
          ped_expansion_area:
               array[1..ped_unused_words] of 0..0;
                              {Reserved for
                               future use.}
        end;

  TUTablEntry = packed record
                 uvid: Tvid;                 { 00 } {volume id for unit}

                 packed_stuff: word;
                 ueovblk: integer;           {0 for an unmounted svol}
                 case boolean of
                   true:  {networked unit}
                     ( u_server_addr:
                         record
                           netnum: integer;
                           nodenum: array[0..2] of integer;
                           socketnum: integer;
                         end );
                   false: {subsidiary volume}
                     ( uPhysVol: integer;   {physical unit}
                       uBlkOff: integer;    { 07 } {start block}
                       upvid: Tvid );        {volume id of physical unit}
               end {TUTablEntry};  { This must be 24 bytes long }

     TUTablEntryPtr = ^TUTablEntry;

     TUTable = array[0..MAX_STANDARD_UNIT] of TUTablEntry;

     TUTablePtr = ^TUTable;


var
  processor_types: array[TMTypes] of string = (
    { 0} 'm_pseudo',
    { 1} 'm_6809',
    { 2} 'm_pdp_11',
    { 3} 'm_8080',
    { 4} 'm_z_80',
    { 5} 'm_ga_440',
    { 6} 'm_6502',
    { 7} 'm_6800',
    { 8} 'm_9900',
    { 9} 'm_8086',
    {10} 'm_z_8000',
    {11} 'm_68000',
    {12} 'm_hp_87',
    {13} 'm_16000',
    {14} 'm_80186',
    {15} 'm_80187');

  pMachineVersions: array[TPmachineVersion] of string = (
    'pre_iv_1',
    'iv_1',
    'iv_2',
    'Unknown');

IMPLEMENTATION

{$Include BiosConst.inc}

initialization
end.



