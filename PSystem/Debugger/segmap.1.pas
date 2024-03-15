{ SegMap: A quick & dirty segment map utility 17 Apr 83 }

{ L PRINTER: }{$L-}
{$S++} { enable as much swapping as you need }
{$V-}  { turn off var string length verification on Apples }

PROGRAM SegMap ;

{========================================================================}
{ File    : SegMap            Author: Arley C. Dealey                    }
{ Date    : 14 Dec 82         Time  : 10:00                              }
{------------------------------------------------------------------------}
{ Revision: 0.1f              Author: Arley C. Dealey                    }
{ Date    : 17 Apr 83         Time  : 15:15                              }
{========================================================================}
{                                                                        }
{ SegMap is a quick and dirty utility to display the information found   }
{ the segment dictionary of a UCSD code file.  It was developed hastily  }
{ when a new and undocumented restriction was added to the system (no    }
{ code segment may be over 8192 words long under IV.1 on the DEC - 11    }
{ systems) in the middle of a major project.  The most important         }
{ information it displays is available via the standard LIBRARY utility, }
{ but in a much less convenient form.                                    }
{                                                                        }
{ This program was developed hastily and is not terribly well written.   }
{ Several expedient, but questionable, programming practices are         }
{ evident.  As an example, most functions in this program exhibit one or }
{ more side effects, whether they be modifying the value of parameters   }
{ or writing messages to the console.  Global variables have been used   }
{ rather heavily also.  Be forwarned, it may not be the easiest program  }
{ to modify!                                                             }
{                                                                        }
{ The segment dictionary is, of necessity, kludged together to deal with }
{ all known varieties of the UCSD system.  The program has been compiled }
{ and tested under the II.0 and II.1 compilers and will work with all    }
{ code files (yes, Virginia, even IV.x extended segment dictionaries).   }
{ It is believed that some versions of the II.0 compiler may not have    }
{ zeroed unused fields in the segment dictionary record.  This will lead }
{ to erroneous reports of required intrinsics.  If you are using a II.0  }
{ compiler and experience this, you should probably remove the intrinsic }
{ report code all together (they were not supported under II.0 anyway).  }
{ Apple /// code files have not been tested and may act strangely        }
{ because Apple chose to redefine the MajorVersion field to mean         }
{ AppleVersion.  This also causes Apple ][ release 1.0 segments to be    }
{ reported as II.0 rather than II.1                                      }
{                                                                        }
{ Terminal screen control handling is hard-coded in procedure CrtControl }
{ for a TVI-950.  A screen control unit was not used because the program }
{ was developed using a variant of the I.3 compiler which did not support}
{ units. It was hard-coded because the author is lazy, but it should be  }
{ trivial to adapt it to use a generalized unit.                         }
{                                                                        }
{ This program was inspired by (and, in fact, based on) CodeMap by       }
{ David N. Jones as published in Call-A.P.P.L.E. In Depth #2.            }
{                                                                        }
{========================================================================}
{$C Copyright (C) 1982, Volition Systems.  All rights reserved.          }
{========================================================================}

{=== change log =============================================================
16 Apr 83 gws  broke it into two files for the benefit of non-ASE users
12 Feb 83 [acd] Fixed failure to clear screen reported by Schreyer/Willner 
28 Dec 82 [acd] Added display of screen control unit version & date
28 Dec 82 [acd] SetOutput now clears line before putting status message
28 Dec 82 [acd] Fixed bug in SetPrefix that could bomb if null response
23 Dec 82 [acd] Converted to use One Damn More Screen Control Unit
22 Dec 82 [acd] Flips IntSegSet
21 Dec 82 [acd] Split procedure MapSofTech
21 Dec 82 [acd] Redefined ItIsFlipped (yet again) & hope it works correctly
20 Dec 82 [acd] Added further info to IV.= map
17 Dec 82 [acd] Paranoid double check of file gender & attendant restructuring
16 Dec 82 [acd] New test for ItIsFlipped.  There must be a better way!
15 Dec 82 [acd] Added default capability to code file name prompt
15 Dec 82 [acd] New FlipIt.  Should work correctly now.
15 Dec 82 [acd] Restructured sex-change stuff
14 Dec 82 [acd] Don't write any fields if seg length is zero
14 Dec 82 [acd] Major user interface & code restructuring
14 Dec 82 [acd] Added code to deal with IV.x linked segdicts
14 Dec 82 [acd] Turns off iochecking locally where needed instead of globally
14 Dec 82 [acd] Added code to flip integers if necessary
14 Dec 82 [acd] Added UCSD/SofTech dichotomy stuff
{============================================================================}

{--- profile ----------
|xstjm$d0|nx|f8|ejm$d1|nx|f8|ejm$d2|nx|f8|ejt|n|*|f1|.

|"New Rev"
stjm$r0|n
dg |!
|*c|f7
jm$r1|n
x|f7|e
jm$r2|n
x|f7|e
jt|.
{--- end of profile ---}

USES
  {$U odmscu.code}
  ScreenUnit ;
  
CONST
   Title        = 'SegMap[' ;
   Rev          = '0.1f' ;
   T0 = '                        Volition Systems'' SegMap utility' ;
   T1 = '                            version 0.1f of 17 Apr 83' ;
   T2 = '          Copyright (C) 1982, Volition Systems.  All rights reserved.';
   MaxSeg       =    63 ; { 15 for most, 31 for Apple ][, 63 for Apple /// }
   MaxDicSeg    =    15 ;

TYPE
   SegRange     = 0..MaxSeg ;
   SegDicRange  = 0..MaxDicSeg ;
   SegmentName  = PACKED ARRAY[0..7] OF CHAR ;
   
   { I.x, II.x, III.x, VS }
     SegmentTypes = ( Linked, HostSeg, SegProc, UnitSeg, SeprtSeg,
                      Unlinked_Intrins, Linked_Intrins, DataSeg ) ;
     MachineTypes = ( UnDefined, PCodeMost, PCodeLeast, PDP11, M8080, Z80,
                      GA440, M6502, M6800, TI990 ) ;
   { IV.x }
     SegTypes     = ( NoSeg, ProgSeg, xUnitSeg, ProcSeg, xSeprtSeg ) ;
   
   Versions     = ( Unknown, II, II_1, III, IV, V, VI, VII ) ;
   { note on apples:                                                        }
   {   Versions = ( Unknown, A2_10, A2_11, A3_10, A3_11, Bad1, Bad2, Bad3 ) }
   { therefore                                                              }
   {   II   implies Apple ][ 1.0                                            }
   {   II_1 implies Apple ][ 1.1                                            }
   {   III  implies Apple /// 1.0                                           }
   {   IV   implies Apple /// 1.1                                           }
   { thanks a lot, you guys! sure would have been nice if you had used one  }
   { of the unused words at the end of the record for the Apple version #.  }
   
   SegSet       = SET OF SegRange ;

   SegDict = RECORD
     DiskInfo  : ARRAY[SegDicRange] OF RECORD
                   CodeAddr : INTEGER ;
                   CodeLeng : INTEGER
                   END ;
     SegName   : ARRAY[SegDicRange] OF SegmentName ;
     SegMisc   : PACKED RECORD
                   CASE BOOLEAN OF
                     TRUE  : { UCSD, Apple, WD, VS }
                       ( SegType   : ARRAY[SegDicRange] OF SegmentTypes ) ;
                     FALSE : { SofTech }
                       ( xSegMisc  : ARRAY[SegDicRange] OF PACKED RECORD
                                       SegType     : SegTypes ;
                                       Filler      : 0..31 ;
                                       HasLinkInfo : BOOLEAN ;
                                       Relocatable : BOOLEAN
                                       END ) ;
                   END ;
     SegText   : ARRAY[SegDicRange] OF INTEGER ;
     SegInfo   : ARRAY[SegDicRange] OF PACKED RECORD
                   SegNum        : 0..255 ;
                   MType         : MachineTypes ;       { UCSD }
                   Filler        : 0..1 ;
                   MajorVersion  : Versions ;
                   END ;
     CASE BOOLEAN OF
       TRUE  : { UCSD, Apple, WD, VS }
         ( IntSegSet : SegSet ; { 1 word on most, 2 on A][, 4 on A/// }
           IntChkSum : PACKED ARRAY [0..MaxSeg] OF 0..255 ; {valid on A/// only}
           Filler2   : ARRAY[0..35] OF INTEGER ;
           Comment   : PACKED ARRAY[0..79] OF CHAR 
           ) ;
       FALSE : { SofTech }
         ( SegFamily : ARRAY[SegDicRange] OF RECORD
                         CASE SegTypes OF
                           xUnitSeg, ProgSeg:
                             ( DataSize : INTEGER ;
                               SegRefs  : INTEGER ;
                               MaxSegNum: INTEGER ;
                               TextSize : INTEGER ) ;
                           xSeprtSeg, ProcSeg:
                             ( ProgName : SegmentName ) ;
                         END ;
           NextDict  : INTEGER ;
           Filler    : ARRAY[0..6] OF INTEGER ;
           CopyNote  : STRING[77] ;
           Sex       : INTEGER ) ;
     END ; { SegDict }
     
   SegDicRec    = RECORD
     Flipped    : BOOLEAN ;
     Dict       : SegDict
     END ;

   PathName     = STRING[23] ;
   

VAR
  f             : Phyle ;
  o             : INTERACTIVE ;
  CmdSet        : SET OF CHAR ;
  OFileName     : PathName ;
  CFileName     : PathName ;
  Prefix        : STRING[8] ;
  ConsoleOutput : BOOLEAN ;


PROCEDURE Initialize ;

BEGIN { Initialize }
  
  IF InitSCU = FALSE THEN BEGIN
    WRITE( 'Screen control unit failed initialization.' ) ;
    EXIT( SegMap ) 
    END ;
  IF (ScrHeight < 24) OR (ScrWidth < 80) THEN BEGIN
    WRITE( 'Sorry, you must have at least a 24 x 80 terminal.' ) ;
    EXIT( SegMap )
    END ;
  GOTOXY( 0, 0 ) ;
  CrtControl( ClrToEoS ) ;
  GOTOXY( 0, 8 ) ;
  WRITELN( T0 ) ;  WRITELN ;
  WRITELN( T1 ) ;  WRITELN ;
  WRITELN( T2 ) ;  WRITELN ;
  GOTOXY( 0, 17 ) ;
  WRITE( '':14 ) ;
  WRITE( 'Using screen control unit version ' ) ;
  WRITE( SCU_Version, ' of ', SCU_Date, '.'  ) ;
  CmdSet        := [ 'm', 'M', 'o', 'O', 'p', 'P', 'q', 'Q' ] ;
  OFileName     := 'CONSOLE:' ;
  CFileName     := 'SYSTEM.WRK' ;
  Prefix        := '' ;
  ConsoleOutput := TRUE ;
  REWRITE( o, OFileName ) ;
  
  END { Initialize } ;
  
  
PROCEDURE CleanUp ;

BEGIN { CleanUp }
  
  CLOSE( o, LOCK ) ;
  
  END { CleanUp } ;
  
  
PROCEDURE SpaceWait ;

  CONST
    KbdUnit     =  2 ;
    
  VAR
    JunkCh      : CHAR ;

BEGIN { SpaceWait }
  
  GOTOXY( 0, 0 ) ;
  CrtControl( ClrToEoL ) ;
  WRITE( '<space to continue>' ) ;
  UNITCLEAR( KbdUnit ) ;
  REPEAT
    READ( KEYBOARD, JunkCh )
    UNTIL JunkCh = ' ' ;
  GOTOXY( 0, 0 ) ;
  CrtControl( ClrToEoL ) 
  
  END { SpaceWait } ;
  
  
{ L+}
PROCEDURE Sanitize
  ( VAR FileName : STRING ;
        Prefix   : STRING ;
        Ext      : STRING ) ;

  VAR
    i      : INTEGER ;
    FNLen  : INTEGER ;
    ExtLn  : INTEGER ;
    
BEGIN { Sanitize }
  
  ExtLn := LENGTH( Ext ) ;
  
  FOR i := LENGTH( FileName ) DOWNTO 1 DO 
    IF FileName[i] IN [CHR(0)..CHR(31), ' '] THEN
      DELETE( FileName, i, 1 ) 
    ELSE IF FileName[i] IN ['a'..'z'] THEN
      FileName[i] := CHR(ORD(FileName[i])-32) ;
  
  IF LENGTH( FileName ) > 0 THEN BEGIN
    
    IF (POS( ':', FileName ) = 0) AND
       (FileName[1] <> '*'      )  THEN
      FileName := CONCAT( Prefix, FileName ) ;
  
    FNLen := LENGTH( FileName ) ;
    IF FileName[FNLen] = '.' THEN
      DELETE( FileName, FNLen, 1 )
    ELSE IF COPY( FileName, SUCC(FNLen-ExtLn), ExtLn ) <> Ext THEN
      FileName := CONCAT( FileName, Ext ) ;
    IF LENGTH(FileName) > 23 THEN
      FileName := COPY( FileName, 1, 23 ) ;
    
    END { fnlen > 0 }
  
  END { Sanitize } ;
  
  
PROCEDURE SplitName
  (     Name    : STRING ;
    VAR VolName : STRING ;
    VAR FileName: STRING ) ;

  VAR
    ColonPos    : INTEGER ;

BEGIN { SplitPathName }
  
  IF LENGTH( Name ) > 0 THEN BEGIN
    ColonPos := POS( ':', Name ) ;
    IF ColonPos > 0 THEN BEGIN
      VolName := COPY( Name, 1, ColonPos ) ;
      FileName:= COPY( name, SUCC(ColonPos), LENGTH(name)-ColonPos ) ;
      END
    ELSE IF Name[1] = '*' THEN BEGIN
      VolName := '*' ;
      IF LENGTH( Name ) > 1 THEN
        FileName := COPY( Name, 2, LENGTH(Name)-1 ) 
      ELSE
        FileName := '' ;
      END
    ELSE BEGIN
      VolName := '' ;
      FileName:= Name
      END
    END
  ELSE BEGIN
    VolName := '' ;
    FileName:= '' ;
    END ;
    
  END { SplitPathName } ;
{ L-}
  
FUNCTION Menu
  : BOOLEAN ;

  VAR
    CmdCh       : CHAR ;
    Done        : BOOLEAN ;
    

  PROCEDURE PutPrompt ;
  
  BEGIN { PutPrompt }
    
    GOTOXY( 0, 23 ) ;
    CrtControl( ClrToEoL ) ;
    WRITE( 'Output file is ', OFileName ) ;
    IF (LENGTH( Prefix ) > 0) AND (Prefix <> ':') THEN
      WRITE( ',  prefix volume is ', Prefix ) ;
    GOTOXY( 0, 0 ) ;
    CrtControl( ClrToEoL ) ;
    WRITE( Title, Rev, ']  ' ) ;
    WRITE( 'M(ap,  O(utput file,  P(refix,  Q(uit ' ) ;
    
    END { PutPrompt } ;
    
    
  PROCEDURE SetOutputFile ;
  
    VAR
      OFName    : STRING ;
      
  BEGIN { SetOutputFile }
    
    GOTOXY( 0, 0 ) ;
    CrtControl( ClrToEoL ) ;
    WRITE( '[', OFileName, '] Enter new output file name: ' ) ;
    READLN( OFName ) ;
    Sanitize( OFName, Prefix, '' ) ;
    IF LENGTH( OFName ) > 0 THEN BEGIN
      {$I-}
        CrtControl( ClrToEoL ) ;
        CLOSE( o, LOCK ) ;
        REWRITE( o, OFName ) ;
        IF IORESULT = 0 THEN BEGIN
          WRITELN( 'Output file opened successfully' ) ;
          OFileName := OFName ;
          END
        ELSE BEGIN
          WRITELN( 'Open error on output file ', OFName ) ;
          REWRITE( o, OFileName ) 
        END ;
        {$I+}
      IF (OFName = 'CONSOLE:') OR (OFName = '#1:') THEN
        ConsoleOutput := TRUE
      ELSE
        ConsoleOutput := FALSE
      END ;
    
    END { SetOutputFile } ;
    
    
  PROCEDURE SetPrefix ;
  
    VAR
      pf        : STRING ;
      
  BEGIN { SetPrefix }
    
    GOTOXY( 0, 0 ) ;
    CrtControl( ClrToEoL ) ;
    IF LENGTH( Prefix ) > 0 THEN
      WRITE( '[', Prefix, '] ' ) ;
    WRITE( 'Enter new prefix: ' ) ;
    READLN( pf ) ;
    IF LENGTH( pf ) > 0 THEN
      Prefix := pf ;
    Sanitize( Prefix, '', '' ) ;
    IF LENGTH( Prefix ) > 0 THEN
      IF (Prefix <> '*') AND (Prefix[LENGTH(Prefix)] <> ':') THEN 
        Prefix := CONCAT( Prefix, ':' ) ;
    
    END { SetPrefix } ;
    
    
  FUNCTION OpenCodeFile
    ( VAR CodeFile      : Phyle ;
      VAR CFileName     : PathName )
    : BOOLEAN ;
  
  { Note that this returns the open status as a function result.  This     }
  { method of returning the status results in a function with side-effects }
  { on both of its parameters - questionable programming practice at best! }
    
    VAR
      fn        : STRING ;
      JunkName  : STRING ;
      
  BEGIN { OpenCodeFile }
    
    GOTOXY( 0, 0 ) ;
    CrtControl( ClrToEoL ) ;
    SplitName( CFileName, JunkName, CFileName ) ;
    IF LENGTH( CFileName ) > 0 THEN
      WRITE( '[', CFileName, '] ' ) ;
    WRITE( 'Enter name of file to be mapped: ' ) ;
    READLN( fn ) ;
    IF LENGTH( fn ) = 0 THEN 
      fn  := CFileName ;
    { try it first with no extension }
    Sanitize( fn, Prefix, '' ) ;
    {$I-}
      CLOSE( CodeFile ) ;
      RESET( CodeFile, fn ) ;
      IF IORESULT <> 0 THEN BEGIN
        { now try it with code extension }
        Sanitize( fn, '', '.CODE' ) ;
        RESET( CodeFile, fn ) ;
        END ;
      {$I+}
    IF IORESULT = 0 THEN BEGIN
      CFileName := fn ;
      OpenCodeFile := TRUE ;
      END
    ELSE BEGIN
      CrtControl( ClrToEoS ) ;
      WRITELN( 'Open error on file ', fn ) ;
      OpenCodeFile := FALSE ;
      END ;
    
    END { OpenCodeFile } ;
    
    
    
BEGIN { Menu }
  
  REPEAT
    PutPrompt ;
    REPEAT
      READ( KEYBOARD, CmdCh ) 
      UNTIL CmdCh IN CmdSet ;
    WRITELN ;
    CASE CmdCh OF
      'm', 'M': BEGIN { M(ap }
        Done := OpenCodeFile( f, CFileName ) ;
        Menu := TRUE 
        END ; { M(ap }
      'o', 'O': BEGIN { O(utput }
        Done := FALSE ;
        SetOutputFile 
        END ; { O(utput }
      'p', 'P': BEGIN { P(refix }
        Done := FALSE ;
        SetPrefix
        END ; { P(refix }
      'q', 'Q': BEGIN { Q(uit }
        Done := TRUE ;
        Menu := FALSE 
        END ; { Q(uit }
      END ; { case }
    UNTIL Done
  
  END { Menu } ;

(*$I segmap.2.text*)

