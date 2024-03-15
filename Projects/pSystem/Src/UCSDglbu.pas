
{ UCSD Globals from I.5 patched for turbo.  Designed for the interpreter    }
{ written in pascal.  Taken from globals of OS for I.5, a few hacks to make }
{ turbo occupy same memory sizes, but no other changes.                   LB}

unit UCSDglbu;     {descended from (similar to) include file ucsdglob.pas LB}

INTERFACE
(**************************************************)
(*						                                    *)
(*    UCSD PASCAL OPERATING SYSTEM		            *)
(*						                                    *)
(*    RELEASE LEVEL:  I.3   AUGUST, 1977	        *)
(*                    I.4   JANUARY, 1978	        *)
(*		      I.5   SEPTEMBER, 1978	                *)
(*						                                    *)
(*    WRITTEN BY ROGER T. SUMNER		              *)
(*    WINTER 1977				                          *)
(*						                                    *)
(*    INSTITUTE FOR INFORMATION SYSTEMS		        *)
(*    UC SAN DIEGO, LA JOLLA, CA		              *)
(*						                                    *)
(*    KENNETH L. BOWLES, DIRECTOR		              *)
(*						                                    *)
(**************************************************)

uses
  Interp_Const;
  
CONST
     MMAXINT  = 32767;	(*MAXIMUM INTEGER VALUE*)
     MAXUNIT  = 12;	    (*MAXIMUM PHYSICAL UNIT # FOR UREAD*)
     MAXDIR   = 77;	    (*MAX NUMBER OF ENTRIES IN A DIRECTORY*)
     VIDLENG  = 7;	    (*NUMBER OF CHARS IN A VOLUME ID*)
     TIDLENG  = 15;	    (*NUMBER OF CHARS IN TITLE ID*)

     SEG_DICT_SIZE = 16;(*MAX NUMBER OF SEGMENTS IN A CODE FILE*)
     SEG_DICT_SIZE2= 32;(*MAX NUMBER OF SEGMENTS IN A VERSION II_1 CODE FILE*)

     MAXSEG   = SEG_DICT_SIZE - 1;	(*MAX CODE SEGMENT NUMBER (15)*)
     MAXSEG2  = SEG_DICT_SIZE2 - 1; (*MAX CODE SEGMENT NUMBER IN VERSION II_1 (31)*)
     FBLKSIZE = 512;	  (*STANDARD DISK BLOCK LENGTH*)
     AGELIMIT = 300;	  (*MAX AGE FOR GDIRP...IN TICKS*)
     EOL      = 13;	    (*END-OF-LINE...ASCII CR*)
     DLE      = 16;	    (*BLANK COMPRESSION CODE*)

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


{interp 1.5 (Z80) constants}
     Nill      =  0;  {1 on z80/68000, 0 on apple}
     MSCWSIZE  = 12;  {size of mark stack control word}
     DISP0     = 10;  {offset from MSSTAT of variable w/ offset 0}

     SYSCOM_SIZE = 256;

TYPE

     integer = SmallInt;  // dhd - 1/10/2018 must use 16 bit integers

     (*COMMAND STATES...SEE GETCMD*)

     CMDSTATE = integer; (*
                 (HALTINIT,DEBUGCALL,
		 UPROGNOU,UPROGUOK,SYSPROG,
		 COMPONLY,COMPANDGO,COMPDEBUG,
		 LINKANDGO,LINKDEBUG); *)

     (*ARCHIVAL INFO...THE DATE*)

     DATEREC = integer;
                {
                PACKED RECORD
		 MONTH: 0..12;		(*0 IMPLIES DATE NOT MEANINGFUL*)
		 DAY: 0..31;		(*DAY OF MONTH*)
		 YEAR: 0..100		(*100 IS TEMP DISK FLAG*)
		END (*DATEREC*) ;
                }

					(*VOLUME TABLES*)
     UNITNUM = integer; {0..MAXUNIT;}
     VID     = STRING[VIDLENG];

					(*DISK DIRECTORIES*)
     DIRRANGE = integer; {0..MAXDIR;}
     TID      = STRING[TIDLENG];

     FILEKIND = integer; (*
                 (0:UNTYPEDFILE,1:XDSKFILE,2:CODEFILE,3:TEXTFILE,
		 4:INFOFILE,5:DATAFILE,6:GRAFFILE,7:FOTOFILE,8:SECUREDIR); *)

     DIRENTRY = RECORD
		  DFIRSTBLK: INTEGER;	(*FIRST PHYSICAL DISK ADDR*)
		  DLASTBLK: INTEGER;	(*POINTS AT BLOCK FOLLOWING*)
		  CASE DFKIND: FILEKIND OF
		    kSECUREDIR,
		    kUNTYPEDFILE: (*ONLY IN DIR[0]...VOLUME INFO*)
			 (DVID: VID;		(*NAME OF DISK VOLUME*)
			DEOVBLK: INTEGER;	(*LASTBLK OF VOLUME*)
//  	DNUMFILES: DIRRANGE;	(*NUM FILES IN DIR*)
      DNUMFILES: WORD;     (* Using DIRRANGE will only use 1 byte which leave the number
                              open to misintrepetation in some code *)
			DLOADTIME: INTEGER;	(*TIME OF LAST ACCESS*)
			DLASTBOOT: DATEREC);	(*MOST RECENT DATE SETTING*)
		    kXDSKFILE,kCODEFILE,kTEXTFILE,kINFOFILE,
		    kDATAFILE,kGRAFFILE,kFOTOFILE:
			 (DTID: TID;		(*TITLE OF FILE*)
			DLASTBYTE: 1..FBLKSIZE;	(*NUM BYTES IN LAST BLOCK*)
			DACCESS: DATEREC)	(*LAST MODIFICATION DATE*)
		END (*DIRENTRY*) ;

     TDIRPtr    = ^DIRECTORY;

     DIRECTORY = ARRAY [0..maxdir{DIRRANGE}] OF DIRENTRY;

					(*FILE INFORMATION*)

     CLOSETYPE= (CNORMAL,CLOCK,CPURGE,CCRUNCH);
     WINDOWP  = word;  // ^WINDOW; must be 2 bytes
     WINDOW   = PACKED ARRAY [0..0] OF CHAR;
     TFIB2Ptr  = ^TFIB2;

     FIBP = word;  // otherwise it would take up 4 bytes

(*  ORIGINAL:

   FIB = RECORD
    FWINDOW: WINDOWP; { USER WINDOW...F^, USED BY GET-PUT }
    FEOF,FEOLN: BOOLEAN;
    FSTATE: (FJANDW,FNEEDCHAR,FGOTCHAR);
    FRECSIZE: INTEGER; { IN BYTES...0=>BLOCKFILE, 1=>CHARFILE }
    CASE FISOPEN: BOOLEAN OF
      TRUE: (FISBLKD: BOOLEAN; { FILE IS ON BLOCK DEVICE }
      FUNIT: UNITNUM; { PHYSICAL UNIT # }
      FVID: VID; { VOLUME NAME }
      FREPTCNT,  { # TIMES F^ VALID W/O GET }
      FNXTBLK,  { NEXT REL BLOCK TO IO }
      FMAXBLK: INTEGER; { MAX REL BLOCK ACCESSED }
      FMODIFIED:BOOLEAN;{ PLEASE SET NEW DATE IN CLOSE }
      FHEADER: DIRENTRY;{ COPY OF DISK DIR ENTRY }
      CASE FSOFTBUF: BOOLEAN OF { DISK GET-PUT STUFF }
        TRUE: (FNXTBYTE,FMAXBYTE: INTEGER;
               FBUFCHNGD: BOOLEAN;
               FBUFFER: PACKED ARRAY [0..FBLKSIZE] OF CHAR))
  END { FIB } ;
*)

{$A2} // Try to force fields to be aligned on word boundaries (but it doesn't work}

    TSoftBufInfo = record
                     CASE FSOFTBUF: BOOLEAN OF (*DISK GET-PUT STUFF*) //
                       TRUE: (FMAXBYTE: INTEGER;
                              FNXTBYTE: INTEGER;
                              FBUFCHNGD: BOOLEAN;
                              FBUFFER: PACKED ARRAY [0..FBLKSIZE] OF CHAR)
                     END;

    TSoftBufInfoPtr = ^TSoftBufInfo;

    TFIB2 = RECORD // Changed for Delphi word alignment compatability
	     {0} FWINDOW: WINDOWP;	    (*USER WINDOW...F^, USED BY GET-PUT*)
       {2} FEOLN: WORD;
	     {4} FEOF: WORD;
	     {6} FSTATE: WORD; // (0=FJANDW,1=FNEEDCHAR,1=FGOTCHAR);
	     {8} FRECSIZE: INTEGER;	    (*IN BYTES...0=>BLOCKFILE, 1=>CHARFILE*)
      {10} FISOPEN: WORD;
      {12} FISBLKD: WORD;         (*FILE IS ON BLOCK DEVICE*)
      {14} FUNIT: UNITNUM;	      (*PHYSICAL UNIT #*)
      {16} FVID: VID;	            (*VOLUME NAME*)
      {24} FMAXBLK: INTEGER;      (*MAX REL BLOCK ACCESSED*)    // reordered for Delphi
      {26} FNXTBLK: INTEGER;	    (*NEXT REL BLOCK TO IO*)      // reordered for Delphi
      {28} FREPTCNT: INTEGER;     (* # TIMES F^ VALID W/O GET*) // reordered for Delphi
      {30} FMODIFIED:WORD;        (*PLEASE SET NEW DATE IN CLOSE*)
      {32} FHEADER: DIRENTRY;     (*COPY OF DISK DIR ENTRY*)
      {??} SoftBufInfo: TSoftBufInfo;
         END (*FIB*) ;

     (*USER WORKFILE STUFF*)

    INFOREC = RECORD
       CODEFIBP: FIBP;	(*WORKFILES FOR SCRATCH*)
       SYMFIBP : FIBP;
       ERRNUM  : INTEGER;	(*ERROR STUFF IN EDIT*)
       ERRBLK  : integer;
       ERRSYM  : integer;
       STUPID  : BOOLEAN;	(*STUDENT PROGRAMMER ID!!*)
       SLOWTERM: Boolean;
       ALTMODE : CHAR;			(*WASHOUT CHAR FOR COMPILER*)
       GOTCODE : BOOLEAN;	(*TITLES ARE MEANINGFUL*)
       GOTSYM  : Boolean;
       CODEVID : VID;	(*PERM&CUR WORKFILE VOLUMES*)
       SYMVID  : Vid;
       WORKVID : Vid;
       CODETID : TID;	(*PERM&CUR WORKFILES TITLE*)
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

     BYTERANGE = 0..255;
     TRICKARRAY = ARRAY [0..0] OF WORD; (* FOR MEMORY DIDDLING*)


     TMSCWPtr2 = ^ MSCW2;		(*MARK STACK RECORD POINTER*)

     TShortPtr = word;

     MSCW2 = RECORD
	      STATLINK : TShortPtr; {MSCWP;}(*POINTER TO PARENT MSCW*)
	      DYNLINK  : TShortPtr; {MSCWP;}(*POINTER TO CALLER'S MSCW*)
	      MSJTAB   : TShortPtr; {^TRICKARRAY;}
	      MSSEG    : TShortPtr; {^TRICKARRAY;}
        MSIPC    : TShortPtr;
	      LOCALDATA: TRICKARRAY
	    END (*MSCW*) ;

					(*SYSTEM COMMUNICATION AREA*)
					(*SEE INTERPRETERS...NOTE	*)
					(*THAT WE ASSUME BACKWARD	*)

					(*FIELD ALLOCATION IS DONE *)

      TCodeDesc = Record
                    CODEUNIT : Word; { UNIT number }
                    DISKADDR : Word; { REL BLK IN CODE...ABS IN SYSCOM^ }
                    CODELENG : Word; { Length in words (or is it bytes?)}
                  end;

      TSegTbl = array[0..MAXSEG] of
                    TCodeDesc;

      TSegTbl2 = array[0..MAXSEG2] of
                    TCodeDesc;

      TSegTblPtr = ^TSegTbl;

{now syscom stuff}
     TIISysComRec = RECORD
{ 0}   IORSLT  : TIORsltWD; (* 0=RESULT OF LAST IO CALL*)
{ 2}   XEQERR  : word;      (* 1=REASON FOR EXECERROR CALL*)
{ 4}   SYSUNIT : integer;   (* 2=PHYSICAL UNIT OF BOOTLOAD*)
{ 6}   BUGSTATE: INTEGER;   (* 3=DEBUGGER INFO*)
{ 8}   GDIRP   : TShortPtr; (* 4=GLOBAL DIR POINTER,SEE VOLSEARCH*)
{10}   BOMBP   : word;      (* 5=NUMBER OF PROCEDURE THAT WAS EXECUTING WHEN CRASH OCCURRED*)
{12}   STKBASE : TShortPtr;
{14}   LASTMP  : TShortPtr;
{16}   JTAB    : TShortPtr;
{18}   SEG     : word;     (* Segment top? *)
{20}   MEMTOP  : word;
{22}   BOMBIPC : word;    (*WHERE XEQERR BLOWUP WAS*)
{24}   HLTLINE : word;    (*MORE DEBUGGER STUFF*)
{26}   BRKPTS  : ARRAY [0..3] OF word   ;
{34}	 RETRIES : INTEGER; (*DRIVERS PUT RETRY COUNTS*)
{36}	 EXPANSION:ARRAY [0..8] OF INTEGER;
{54}	 LOTIME  : integer;
{56}   HITIME  : integer;
{58}	 MISCINFO: integer;
      {
       nobreak[bit6],stupid[5],slowterm[4],
       hasxycrt[3],haslccrt[2],has8510a[1],hasclock[0]: boolean;
       userkind: (normal[6,7], aquiz[8,9], booker[10,11],
       pquiz);
      }
{60}	 CRTTYPE: INTEGER;  // See: TGotoXYFormat in CRTInfo for possible use
{62}	 CRTCTRL: PACKED RECORD           { word # }
{62}	            ESCAPE  : CHAR;       { 31 }
{63}              HOME    : char;
{64}              ERASEEOS: char;       { 32 }
{65}              ERASEEOL: char;
{66}              NDFS    : char;       { 33 }
{67}              RLF     : char;
{68}              BACKSPACE: CHAR;      { 34 }
{69}	            FILLCOUNT: 0..255;
{70}	            EXPANSION: PACKED ARRAY [0..3] OF CHAR  // [70]=EraseScreen, [71]=EraseLine, [72]=prefixed bits (0..7)
		            END;

{74}		   CRTINFO: PACKED RECORD
{74}				 HEIGHT : INTEGER;          { 37 }
{76}         WIDTH  : INTEGER;          { 38 }
{78}				 UP     : CHAR;             { 39 }
{79}         DOWN   : char;
{80}         LEFT   : char;             { 40 }
{81}         RIGHT  : char;
{82}         EOF    : CHAR;             { 41 }
{83}         FLUSH  : char;
{84}         BREAK  : char;             { 42 }
{85}         STOP   : char;
{86}         CHARDEL: char;             { 43 }
{87}         BADCH  : char;
{88}				 LINEDEL: CHAR;             { 44 }
{89}         ALTMODE: char;
{90}				 EXPANSION: PACKED ARRAY [0..5] OF CHAR
			    END;  { syscom }

{96}     SEGTBL : TSegTbl2;
{256?}
	END; (* TIISysComRec *)

  TSyscomIIPtr = ^TIISysComRec;

  TUTablEntryII =
              RECORD
                UVID: VID; { VOLUME ID FOR UNIT }
                CASE UISBLKD: word OF   // was BYTE - changed to word to try to get offsets correct
                  1: (UEOVBLK: INTEGER)
              END { UNITABLE };

  TUTableII = array[0..MAXUNIT] of TUTablEntryII;

  TUTablePtrII = ^TUTableII;

  TSEGDESC = RECORD
               DISKADDR: INTEGER; { REL BLK IN CODE...ABS IN SYSCOM^ }
               CODELENG: INTEGER  { # BYTES TO READ IN }
             END { SEGDESC } ;

  TDiskInfo = array[SEGRANGE] of TSegDesc;

  TDiskInfoPtr = ^TDiskInfo;

  TSegNames = array[SEGRANGE] of TAlpha;

  TSegNamesPtr = ^TSegNames;

  TSegKind =(skLINKED, skHOSTSEG, skSEGPROC, skUNITSEG, skSEPRTSEG);

  TSegKinds = array[SEGRANGE] of TSegKind;

  TSegKindsPtr = ^TSegKinds;

IMPLEMENTATION
Begin
end.