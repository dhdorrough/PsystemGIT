UNIT UGLOBALS;

INTERFACE

  const
    maxdir     = 77;        { max number of entries in a directory }
    vidleng    = 7;         { number of chars in a volume id }
    tidleng    = 15;        { number of chars in title id }
    wrkleng    = 71;        { workfile name max length }
    maxseg     = 15;        { max code segment number }
    fblksize   = 512;       { standard disk block length }
    dirblk     = 2;         { disk addr of directory (sfs) }
    agelimit   = 300;       { max age for gdirp...in ticks }
    eol        = 13;        { end of line...ascii cr }
    dle        = 16;        { blank compression code }
    name_leng  = 23;        { number of characters in a full file name}
    swapping   = 0;         { swapping segment status}
    p_locked   = -1;        { position locked segment status}
    stack_slop = 40;        { number of words of temp for procedure stack}
    mem_link_size = 4;      { number of bytes in heap record}

    LPR        = 157;
    
    TIB_QUEUE  = -3;
    EVEC_REG   = -2;
    TIB_REG    = -1;

  type
    byte       = 0..255;

    TIntP      = ^integer;
    TTibP      = ^TTib;

    TSibP      = ^TSib;
    TErecP    = ^TErec;
    TEvecP    = ^TEvec;
    TSemP      = ^TSemaphore;
    TMscwP      = ^Tmscw;
    TMemChnkP = ^TMemChunk;
    vip        = ^TVinfo;

    TEvec      = record     {Environment vector}
                   vect_length: integer;
                   map: array[1..1] of TErecP;   {Accessed $R-}
                 end {e_vec};

    poolptr    = ^pooldes;

    TMemChunk  = array[0..0] of integer;          {accessed $r-}
    alpha      = packed array[0..7] of char;      {identifier name}
    
    fulladdress = array[0..1] of integer;     {32 bits}
    
    bytearray  = packed array[0..0] of byte;

    TMemLinkP  = ^TMemLink;

    MemPtr    = record case integer of
                   0: (m: TMemLinkP);
                   1: (i: TIntP);
                   2: (c: TMemChnkP);
                   3: (t: integer);
                   4: (b: ^bytearray);
                 end {MemPtr};
    
    TMemLink   = record
                   avail_list: MemPtr;
                   n_words: integer;
                   case boolean of
                     true: ( last_avail,
                             prev_mark : MemPtr
                           );
               end {mem_link};

    pooldes    = record
                   poolbase: fulladdress;
                   poolsize: integer;
                   minoffset: memptr;
                   maxoffset: memptr;
                   resolution: integer; {in bytes}
                   poolhead: Tsibp;
                   permsib: Tsibp;
                   extended: boolean;
                   nextpool: poolptr;  {circular list of code pool descriptors}
                   mustcompact : boolean;
                 end {pooldes};
    
    TErec      = record     {Environment record}
                   env_data: MemPtr;     {Pointer to base data segment}
                   env_vect: TEvecP;     {Pointer to environment vector}
                   env_sib:  TSibP;       {Pointer to associated segment}
                   case boolean of        {Outer block information}
                     true: (link_count: integer;
                            next_rec: TErecP);
                 end; {TErec}

    { volumes and directories }
    unitnum    = 0..127;            { valid system device numbers }
    vid        = string[vidleng];   { volume id }
    tid        = string[tidleng];   { title id }
    dirrange   = 0..maxdir;
    FileSpec   = string[255];       {complete file specification}
    filekind   = ( untypedfile, xdskfile, codefile, textfile, infofile,
                  datafile, graffile, fotofile, securedir, subsvol );
    
    TVinfo      = record
                   segunit: integer;
                   segvid: vid;
                 end {of TVinfo};
    
    TLPR_Reg     = (LPR_WAIT_Q, LPR_PRIOR_FLAGS, LPR_SP_LOW, LPR_SP_HIGH,
                    LPR_SP, LPR_MP, LPR_TASK_LINK, LPR_IPC, LPR_EREC, 
                    LPR_PROCNUM);

  Tmscw       = record     {Mark stack control}
                 ms_stat: TMscwP;       {Lexical parent pointer}
                 ms_dynl: TMscwP;       {Ptr to caller's mscw}
                 ms_ipc:  integer;      {byte inx in retrn code seg}
                 ms_env:  TErecP;      {Environment of caller code}
                 ms_proc: integer;      {Proc # of caller}
               end {mscw};

  TTib        = packed record     {task information block}
                 regs: packed record        {word offset & description}
                         wait_q: TTibP;     { 0 Queue link for semaphores}
                         prior: byte;       { 1 Task's cpu priority}
                         flags: byte;       { 1 State flags...not defined yet}
                         sp_low: MemPtr;   { 2 Lower stack pointer limit}
                         sp_upr: MemPtr;   { 3 Upper limit on stack}
                         sp: MemPtr;       { 4 Actual top of stack pointer}
                         mp: TMscw;        { 5 Active procedure MSCW ptr}
                         task_link: TTibP;  { 6 links all tasks in system}
                         ipc: integer;      { 7 byte ptr in current code seg}
                         env: TErecP;      { 8 Ptr to current environment}
                         procnum: byte;     { 9 procedure currently executing}
                         tibioresult: byte; { 9 current ioresult}
                         hang_p: TSemP;     {10 Which task is waiting on}
                         m_depend: integer; {11 Reserved for interpreter}
                                            {   initted to 0 when process started}
                       end {regs};
                 main_task: boolean;        {12 indicates operating system task}
                 system_task: boolean;      {12 indicates system tasks}
                 reserved: 0..16383;        {12 future use}
                 start_mscw: TMscw;        {13 mp at bottom of task stack}
               end {TTib};
  
  TSem        = record     {semaphore format}
                 sem_count: integer;        {Number outstanding signals}
                 sem_wait_q: TTibP          {List of tasks waiting on sem}
               end {sem};

  TSib        = record
                 seg_pool:  poolptr;        {0 pointer to code pool descrptr}
                 seg_base:  MemPtr;        {1 Base memory location}
                 seg_refs:  integer;        {2 number of active calls}
                 timestamp: integer;        {3 Memory swap priority}
                 seg_pieces: word; // ^c_file_struct; {4 describes code file structure}
                 residency: p_locked..maxint; {5 memory residency status}
                 seg_name:  alpha;          {6 Segment name}
                 seg_leng:  integer;        {10 number of words in segment}
                 { If seg_pieces is NIL, seg_addr is a disk address and the
                   segment is contiguous, otherwise it is a relative block
                   number within the code file and seg_pieces points to a
                   structure describing its extents. }
                 seg_addr:  integer;        {11 Disk address of segment}
                 vol_info:  vip;            {12 Disk unit and vol id of segment}
                 data_size: integer;        {13 Number of words in data segment}
                 res_sibs:  record          {Code Pool management record}
                              next_sib,         {15 Pointer to next sib}
                              prev_sib: TSibP;  {14 Pointer to previous sib}
                                case boolean of {Scratch area}
                                  true:  (next_sort: TSibP);   {16}
                                  false: (new_loc: MemPtr);   {16}
                              end {res_sibs};
                 mtype:     integer;        {17 Machine type of segment}
               end {TSibf};

  TSemaphore = record     {semaphore format}
                 sem_count: integer;        {Number outstanding signals}
                 sem_wait_q: TTibP          {List of tasks waiting on sem}
               end {sem};
IMPLEMENTATION

BEGIN

END.




