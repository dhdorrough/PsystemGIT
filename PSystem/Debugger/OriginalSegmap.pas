// JCF does NOT work on code snippets. Your code has to be complete and
// syntactically correct. Otherwise, the formatter won't work properly.
// If you insist to format code snippet, you must put `program test;` at
// the first line and your snippet between `begin` and `end.`. Enjoy!

{ SegMap: A quick & dirty segment map utility 17 Apr 83 }

unit OriginalSegmap;

{========================================================================}
{ File    : SegMap            Author: Arley C. Dealey                    }
{ Date    : 14 Dec 82         Time  : 10:00                              }
{------------------------------------------------------------------------}
{ Revision: 0.1f              Author: Arley C. Dealey                    }
{ Date    : 17 Apr 83         Time  : 15:15                              }
{========================================================================}

{ SegMap is a quick and dirty utility to display the information found   }
{ the segment dictionary of a UCSD code file.  It was developed hastily  }
{ when a new and undocumented restriction was added to the system (no    }
{ code segment may be over 8192 words long under IV.1 on the DEC - 11    }
{ systems) in the middle of a major project.  The most important         }
{ information it displays is available via the standard LIBRARY utility, }
{ but in a much less convenient form.                                    }

{ This program was developed hastily and is not terribly well written.   }
{ Several expedient, but questionable, programming practices are         }
{ evident.  As an example, most functions in this program exhibit one or }
{ more side effects, whether they be modifying the value of parameters   }
{ or writing messages to the console.  Global variables have been used   }
{ rather heavily also.  Be forwarned, it may not be the easiest program  }
{ to modify!                                                             }

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

{ Terminal screen control handling is hard-coded in procedure CrtControl }
{ for a TVI-950.  A screen control unit was not used because the program }
{ was developed using a variant of the I.3 compiler which did not support}
{ units. It was hard-coded because the author is lazy, but it should be  }
{ trivial to adapt it to use a generalized unit.                         }

{ This program was inspired by (and, in fact, based on) CodeMap by       }
{ David N. Jones as published in Call-A.P.P.L.E. In Depth #2.            }

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

INTERFACE
USES
  pSysWindow, UCSDGlob ;
  
CONST
   Title        = 'SegMap[' ;
   Rev          = '0.1f' ;
   T0 = '                        Volition Systems'' SegMap utility' ;
   T1 = '                            version 0.1f of 17 Apr 83' ;
   T2 = '          Copyright (C) 1982, Volition Systems.  All rights reserved.';
   MaxSeg       =    63 ; { 15 for most, 31 for Apple ][, 63 for Apple /// }
   MAXDICSEG    =    15 ;
   DEFAULTPATH  = 'F:\NDAS-I\d7\Projects\pSystem\Temp\';

TYPE
   SegRange     = 0..MaxSeg ;
   SegDicRange  = 0..MAXDICSEG ;
   SegmentName  = PACKED ARRAY[0..7] OF CHAR ;

   { I.x, II.x, III.x, VS }
     TOldSegTypes = ( Linked, HostSeg, SegProc, UnitSeg, SeprtSeg,
                      Unlinked_Intrins, Linked_Intrins, DataSeg ) ;
     TMachineTypes = ( UnDefined, PCodeMost, PCodeLeast, PDP11, M8080, Z80,
                       GA440, M6502, M6800, TI990 ) ;
   { IV.x }
     TNewSegTypesOrg     = ( xNoSeg, xProgSeg, xUnitSeg, xProcSeg, xSeprtSeg ) ;
//   Use TSeg_Types instead

// Versions     = ( Unknown, II, II_1, III, IV, V, VI, VII ) ;
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

(*
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
*)
   Block = packed array[0..FBLKSIZE-1] of char;

   SegDicRec    = RECORD
     Flipped    : BOOLEAN ;
     case integer of
       0: (Dict       : TSeg_Dict);
       1: (aBlock     : block)
     END ;

  TOldSegmentFileInfo = record
    VolumeFilePath : string[80];
    VolumeName     : string[8];
    FileName       : string[15];
    MajorVersion   : TVersions;
    SegDic         : SegDicRec;
    SegDictInfo    : array[0..MAXDICSEG] OF
      record
        SegName: string[CHARS_PER_IDENTIFIER];
        Code_Addr     : word;
        Code_Leng     : word;
        Major_version : TVersions;
        MachineType   : TMachineTypes;
        OldSegType    : TOldSegTypes;
        Seg_Text      : integer;
      end;
    IntSegSet     : SegSet;
    IntrinsNeeded : BOOLEAN ;
  end;

   PathName     = STRING ;

{$IfDef FileOfBlock}
   Phyle = File of Block;
{$else}
   Phyle = File;
{$EndIf}

VAR
  f             : PHYLE ;
  o             : TfrmPSysWindow ;
  OutFile       : TextFile;
  CmdSet        : SET OF CHAR ;
  OFileName     : PathName ;
  CFileName     : PathName ;
  Prefix        : STRING ;
  ConsoleOutput : BOOLEAN ;
  BaseName      : string;
  FileIsOpen    : boolean;
//sfi           : TSegmentFileInfo;

FUNCTION OldLoadSegmentFile  (     FileStartBlock: longint;
                               VAR f       : phyle ;
                               var sfi     : TOldSegmentFileInfo): boolean ;
procedure SegMapper(var f: phyle; FileStartBlock: longint);

IMPLEMENTATION

uses MyUtils, SysUtils, BitOps;

function ExtractMajorVersion(SegInfo: word): TVersions;
begin
  result   := TVersions(GetBits(SegInfo, 13, 3));
end;

function ExtractNewSegType(SegMiscRec: word): TNewSegTypesOrg;
var
  Val: word;
begin
   val    := GetBits(SegMiscRec, 0, 3);
   result := TNewSegTypesOrg(Val);
end;

function ExtractOldSegType(SegMiscRec: word): TOldSegTypes;
begin
   Assert(false);
end;

PROCEDURE Initialize ;

BEGIN { Initialize }
  FileIsOpen := false;
(*
  IF InitSCU = FALSE THEN BEGIN
    WRITE( 'Screen control unit failed initialization.' ) ;
    EXIT( SegMap )
    END ;
*)
  O := TfrmPSysWindow.Create(nil, 'SegMap', 50, 50);

  with O do
    begin
      Show;
      IF (ScreenHeight < 24) OR (ScreenWidth < 80) THEN BEGIN
        WRITE( 'Sorry, you must have at least a 24 x 80 terminal.' ) ;
        EXIT{( SegMap )}
        END ;
      GOTOXY( 0, 0 ) ;
      ClearEOP;
      GOTOXY( 0, 8 ) ;
      WRITELN( T0 ) ;  WRITELN ;
      WRITELN( T1 ) ;  WRITELN ;
      WRITELN( T2 ) ;  WRITELN ;
      GOTOXY( 0, 17 ) ;
      WRITE( Padr('',14) ) ;
//    WRITE( 'Using screen control unit version ' ) ;
//    WRITE( SCU_Version, ' of ', SCU_Date, '.'  ) ;
      CmdSet        := [ 'm', 'M', 'o', 'O', 'p', 'P', 'q', 'Q' ] ;
      OFileName     := 'CONSOLE:' ;
      ChDir(DEFAULTPATH);
      CFileName     := DEFAULTPATH + 'System.Pascal' ;
      Prefix        := '' ;
      ConsoleOutput := TRUE ;
//    REWRITE( o, OFileName ) ;

    end;
  END { Initialize } ;


PROCEDURE CleanUp ;

BEGIN { CleanUp }

//CLOSE( o, LOCK ) ;
  FreeAndNil(o);

  END { CleanUp } ;
  
  
PROCEDURE SpaceWait ;

  CONST
    KbdUnit     =  2 ;
    
  VAR
    JunkCh      : CHAR ;

BEGIN { SpaceWait }

  with O do
    begin
      GOTOXY( 0, 0 ) ;
      ClrEOL;
      WRITE( '<space to continue>' ) ;
      UNITCLEAR;
      REPEAT
        JunkCh := ReadKey;
        UNTIL JunkCh = ' ' ;
      GOTOXY( 0, 0 ) ;
      ClearEOP
    end;

  END { SpaceWait } ;
  
  
{ L+}
PROCEDURE Sanitize
  ( VAR FileName : STRING ;
        Prefix   : STRING ;
        Ext      : STRING ) ;
(*
  VAR
    i      : INTEGER ;
    FNLen  : INTEGER ;
    ExtLn  : INTEGER ;
*)
BEGIN { Sanitize }
(*
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
*)
    if Length(Ext) > 0 then
      FileName := ForceExtension(FileName, Ext, true)
  END { Sanitize } ;
  
(*
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
*)
  
FUNCTION Menu
  : BOOLEAN ;

  VAR
    CmdCh       : CHAR ;
    Done        : BOOLEAN ;
    

  PROCEDURE PutPrompt ;
  
  BEGIN { PutPrompt }

    with O do
      begin
        GOTOXY( 0, 23 ) ;
        ClrEol;
        WRITE( ['Output file is ', OFileName] ) ;
        IF (LENGTH( Prefix ) > 0) AND (Prefix <> ':') THEN
          WRITE( [',  prefix volume is ', Prefix] ) ;
        GOTOXY( 0, 0 ) ;
        ClrEol ;
        WRITE( [Title, Rev, ']  '] ) ;
        WRITE( 'M(ap,  O(utput file,  P(refix,  Q(uit ' ) ;
      end;

    END { PutPrompt } ;
    
    
  PROCEDURE SetOutputFile ;
  
    VAR
      OFName    : STRING ;
      
  BEGIN { SetOutputFile }

    with O do
      begin
        GOTOXY( 0, 0 ) ;
        ClrEol ;
        WRITE( ['[', OFileName, '] Enter new output file name: '] ) ;
        READLN( OFName ) ;
        Sanitize( OFName, Prefix, '' ) ;
        IF LENGTH( OFName ) > 0 THEN BEGIN
          {$I-}
            ClrEol ;
//          CLOSE( o, LOCK ) ;
            REWRITE( OutFile, OFName ) ;
            IF IORESULT = 0 THEN BEGIN
              WRITELN( 'Output file opened successfully' ) ;
              OFileName := OFName ;
              END
            ELSE BEGIN
              WRITELN( ['Open error on output file ', OFName] ) ;
              REWRITE( OutFile, OFileName )
            END ;
            {$I+}
          IF (OFName = 'CONSOLE:') OR (OFName = '#1:') THEN
            ConsoleOutput := TRUE
          ELSE
            ConsoleOutput := FALSE
          END ;
      end;

    END { SetOutputFile } ;
    
    
  PROCEDURE SetPrefix ;
  
    VAR
      pf        : STRING ;
      
  BEGIN { SetPrefix }

    with O do
      begin
        GOTOXY( 0, 0 ) ;
        ClrEol ;
        IF LENGTH( Prefix ) > 0 THEN
          WRITE( ['[', Prefix, '] '] ) ;
        WRITE( 'Enter new prefix: ' ) ;
        READLN( pf ) ;
        IF LENGTH( pf ) > 0 THEN
          Prefix := pf ;
        Sanitize( Prefix, '', '' ) ;
        IF LENGTH( Prefix ) > 0 THEN
          IF (Prefix <> '*') AND (Prefix[LENGTH(Prefix)] <> ':') THEN
            Prefix := CONCAT( Prefix, ':' ) ;
      end;

    END { SetPrefix } ;

(*
  FUNCTION OpenCodeFile
    ( VAR CodeFile      : phyle ;
      VAR CFileName     : PathName )
    : BOOLEAN ;
  
  { Note that this returns the open status as a function result.  This     }
  { method of returning the status results in a function with side-effects }
  { on both of its parameters - questionable programming practice at best! }

    VAR
      fn        : STRING ;
      FilePath  : string;
      IO        : INTEGER;
  BEGIN { OpenCodeFile }

    with O do
      begin
        GOTOXY( 0, 0 ) ;
        ClrEol ;
        WRITE( ['Enter name of file to be mapped [', DEFAULTPATH, ': '] ) ;
      { READLN( fn ) ; }
        fn := CFileName;
        if not BrowseForFile('File to Map', fn, 'code') then
          begin
            Result := false;
            Exit;
          end;
        IF LENGTH( fn ) = 0 THEN
          fn  := CFileName ;
        BaseName := ExtractFileName(CFileName);
        FilePath := ExtractFilePath(CFileName);
//      SplitName( CFileName, JunkName, CFileName ) ;
        IF LENGTH( BaseName ) > 0 THEN
          WRITE( ['[', BaseName, '] '] ) ;
        { try it first with no extension }
        Sanitize( fn, Prefix, '' ) ;
        {$I-}
          IF FileIsOpen then
            begin
              CLOSEFile( CodeFile ) ;
              FileIsOpen := false;
            end;
          RESET( CodeFile, CFileName ) ;
          IO := IORESULT;
          IF IO <> 0 THEN BEGIN
            { now try it with code extension }
            Sanitize( fn, '', '.CODE' ) ;
            RESET( CodeFile, fn ) ;
            END ;
          {$I+}
        IF IORESULT = 0 THEN BEGIN
          CFileName := fn ;
          OpenCodeFile := TRUE ;
          FileIsOpen   := TRUE;
          END
        ELSE BEGIN
          ClearEOP ;
          WRITELN( ['Open error on file ', fn] ) ;
          OpenCodeFile := FALSE ;
          END ;
      end;

    END { OpenCodeFile } ;
*)
BEGIN { Menu }
  Menu := false;
  Done := false;

  REPEAT
    PutPrompt ;
    REPEAT
      CmdCH := O.ReadKey;
      UNTIL CmdCh IN CmdSet ;
    O.WRITELN ;
    CASE CmdCh OF
      'm', 'M': BEGIN { M(ap }
//      Done := OpenCodeFile( f, CFileName ) ;
        Done := true;
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

FUNCTION OldLoadSegmentFile  ( FileStartBlock: longint;
                               VAR f       : phyle ;
                               var sfi     : TOldSegmentFileInfo): boolean;
  VAR
    SegDic      : SegDicRec ;
    SegDicNum   : INTEGER ;
    BlockNum    : INTEGER ;
    MajorVersion: TVersions;

  FUNCTION ReadSegDic
    ( VAR f        : phyle ;
          BlockNum : longint ;
      VAR SegDic   : SegDicRec ) : BOOLEAN ;
  var
    NrBlocksRead  : longint;
    IO            : integer;

    FUNCTION ItIsFlipped
      (     SegDic  : TSeg_Dict )
      : BOOLEAN ;
    
    { Note (with some frustration) that we can't use the IV.x Sex byte    }
    { to check for sex even on IV.x code files, because the MajorVersion  }
    { field is in a sex-effected record and so cannot be checked until    }
    { AFTER the sex is already determined!              -acd 17 Dec 82    }

    { The test used is kludgy at best.  We assume that all valid code     }
    { (& library) files must have something beginning at block one.  If   }
    { we find no CodeAddr equal to 1 and no SegText equal to 1 we then    }
    { assume that the file must be of the wrong sex.  If someone can tell }
    { me of a less arbitrary way to test this, I would be very grateful!  }
    {                                                   -acd 18 Dec 82    }

    { We now make the further assumption that if the IV.x sex word seems  }
    { to contain the value <1> in either sex that the file is indeed IV.x }
    { This should be OK, since this word contained the last two bytes of  }
    { the comment in pre-IV.x releases and if you put <ctrl-A><ctrl-@>    }
    { or <ctrl-@><ctrl-A> into your comment you deserve anything you get. }
    { Of course, if your compiler didn't zero these bytes, 1 in every 128 }
    { files you SegMap will be reported erroneously as IV.x files.  Sorry }
    { bout that, maybe someone will write a SegDictFix utility!  All of   }
    { this foolishness is necessary because my kludge test for sex won't  }
    { work on IV.x where the segment that resides at block #1 will often  }
    { be in a later block of the segment dictionary.    -acd 21 Dec 82    }

      CONST
        NotFlipped      =     1 ;
        Flipped         =   256 ;

      VAR
        i   : INTEGER ;
        Temp: BOOLEAN ;

    BEGIN { ItIsFlipped }

      IF (SegDic.Sex = Flipped) or (SegDic.Sex = NotFlipped ) THEN BEGIN
        IF SegDic.Sex = Flipped THEN
          ItIsFlipped := TRUE
        ELSE
          ItIsFlipped := FALSE
        END
      ELSE BEGIN
        Temp := TRUE ; { assume it to be flipped }
        WITH SegDic DO BEGIN
          FOR i := 0 TO MAXDICSEG DO 
            IF ( disk_info[i].code_addr = 1 ) OR
               ( seg_text[i]           = 1 ) THEN
              Temp := FALSE ; { must be ok (we hope) }
          END ; { with }
        ItIsFlipped := Temp
        END ;
        
      END { ItIsFlipped } ;
  
  
    PROCEDURE FlipSegDic
      ( VAR SegDic : SegDicRec ) ;

      VAR
        i       : INTEGER ;
        Transfer: INTEGER ;
        XfrArray: ARRAY [0..3] OF INTEGER ;
        NewSegType: TNewSegTypesOrg;
        
  
      FUNCTION FlipIt
        (     Num     : INTEGER ) 
        : INTEGER ;
      
        VAR
          a, b  : PACKED ARRAY [0..1] OF 0..255 ;
          
      BEGIN { FlipIt }

        MOVE( Num, a[0], 2 ) ;
        b[0] := a[1] ;
        b[1] := a[0] ;
        MOVE( b[0], Num, 2 ) ;
        FlipIt := Num
        
        END { FlipIt } ;
  
  
    BEGIN { FlipSegDic }
      IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
        WITH SegDic, Dict DO BEGIN
          FOR i := 0 TO MAXDICSEG DO BEGIN
            { first the easy part... }
            WITH disk_info[i] DO BEGIN
              code_addr := FlipIt( code_addr ) ;
              code_leng := FlipIt( code_leng )
              END ; { with DiskInfo }
            seg_text[i] := FlipIt( seg_text[i] ) ;
            { and now all the messy junk... }
//          MOVE( SegMisc.SegType[i], Transfer, 2 ) ;
            MOVE(Seg_Misc[i].SegMiscRec, Transfer, 2);
            Transfer := FlipIt( Transfer ) ;
            MOVE( Transfer, Seg_Misc[i].SegMiscRec, 2 ) ;
            MOVE( seg_info[i], Transfer, 2 ) ;
            Transfer := FlipIt( Transfer ) ;
            MOVE( Transfer, seg_info[i], 2 ) ;
            MajorVersion := ExtractMajorVersion(seg_info[i].SegInfo);
            IF MajorVersion > III THEN BEGIN
//            IF seg_misc.xSegMisc[I].SegType IN [ xUnitSeg, ProgSeg ] THEN BEGIN
              NewSegType := ExtractNewSegType(seg_misc[i].SegMiscRec);
              IF NewSegType IN [ xUnitSeg, xProgSeg ] THEN BEGIN
                WITH seg_family[i] DO BEGIN
                  data_size     := FlipIt( data_size ) ;
                  seg_ref_words := FlipIt( seg_ref_words ) ;
                  max_seg_num   := FlipIt( max_seg_num ) ;
                  text_size     := FlipIt( text_size )
                  END ; { with segfamily }
                END ; { if }
              END ; { if }
            END ; { for }
          IF ExtractMajorVersion(seg_info[0].SegInfo) > III THEN BEGIN
            next_dict := FlipIt( next_dict ) ;
            { in an ideal world we'd leave Sex unflipped, but this thing is, }
            { as I said, quick and dirty so we need to go ahead and flip it. }
            Sex := FlipIt( Sex )
            END { if }
          ELSE BEGIN
            MOVE( IntSegSet, XfrArray[0], SIZEOF(IntSegSet) ) ;
            FOR i := 0 TO 3 DO
              XfrArray[i] := FlipIt( XfrArray[i] ) ;
            MOVE( XfrArray[0], IntSegSet, SIZEOF(IntSegSet) ) ;
            END ; { else }
          END ; { with segdic.dict }
        END { if }

      END { FlipSegDic } ;
      
      
  BEGIN { ReadSegDic }
    BlockNum := FileStartBlock;
    {$I-}
    Seek(f, BlockNum);
{$IfDef FileOfBlock}
    Read(f, SegDic.aBlock);
{$else}
    NrBlocksRead := 0;
    BlockREAD(f, SegDic.aBlock, 1, NrBlocksRead);
{$EndIf}
    IO := IOResult;
    IF (NrBlocksRead = 1) AND (IO = 0) THEN BEGIN
    {$I+}
      IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
        SegDic.Flipped := TRUE ;
        FlipSegDic( SegDic )
        END 
      ELSE BEGIN
        SegDic.Flipped := FALSE ;
        END ;
      IF BlockNum = 0 THEN BEGIN { only recheck gender in first seg of dictionary }
        IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
          O.ClearEOP ;
          O.WRITE( ['Unable to determine gender of ', CFileName] ) ;
          ReadSegDic := FALSE
          END
        ELSE BEGIN
          ReadSegDic := TRUE
          END
        END { if block = 0 }
      ELSE
        ReadSegDic := TRUE { because we already know the gender is OK }
      END { if block read successfully }
    ELSE BEGIN
      O.ClearEOP ;
      o.WRITE( ['Error reading segment dictionary of ', CFileName] ) ;
      ReadSegDic := FALSE
      END 
    
    END { ReadSegDic } ;

    function SegNum(SegInfo: word): word;
    begin
      Assert(false);
    end;

    function ExtractMachineType(packed_stuff: word): TMachineTypes;
    var
      Val: word;
    begin
      Val    := GetBits(Packed_Stuff, 8, 5);
      Result := TMachineTypes(Val);
    end;

    function ExtractHasLinkInfo(SegMiscRec: word): boolean;
    begin
      result := Boolean(GetBits(SegMiscRec, 8, 1));
    end;

    function ExtractRelocatable(SegMiscRec: word): boolean;
    begin
      result := Boolean(GetBits(SegMiscRec, 9, 1));
    end;

  PROCEDURE MapUCSD
    (     SegDic : SegDicRec ) ;
    
    VAR
      i                 : INTEGER ;
//    j                 : SegRange ;
//    IntrinsNeeded     : BOOLEAN ;
      NewSegType        : TNewSegTypesOrg;
//    OldSegType        : TOldSegTypes;
      Segname           : string[CHARS_PER_IDENTIFIER];

(*
    function DecodePackedStuff(packed_stuff: word): string;
    var
      seg_num: word;                { local segment number }
      has_link_info : boolean;     { needs to be linked }
      relocatable   : boolean;     { has relocatable code }
      m_type        : TMTypes;     { machine type }
      BitNr         : byte;
    begin
      BitNr         := 0;
      seg_num       := Bits(packed_stuff, BitNr, 8);
      has_link_info := Boolean(Bits(packed_stuff, BitNr, 1));
      relocatable   := Boolean(Bits(packed_stuff, BitNr, 1));
      m_type        := TMTypes(Bits(packed_stuff, BitNr, 4));
      result := Format('seg_num=%d, has_link_info=%s, relocatable=%s, m_type=%s',
                       [seg_num, TFString(has_link_info), TFString(relocatable), processor_types[m_type]]);
    end;

*)
    function MType(SegInfo: word): TMachineTypes;
    begin
      result  := TMachineTypes(GetBits(SegInfo, 0, 4));
    end;

  BEGIN { MapUCSD }
    
//  IntrinsNeeded := FALSE ;

//  with O do
      begin
//      WRITE( '  #  Name      Addr    Len  ' ) ;
//      WRITE( 'Version   Machine  Kind                ' ) ;
//      WRITE( 'Seg   Text' ) ;
//      WRITELN ;

        WITH SegDic, Dict DO BEGIN

          FOR i := 0 TO MAXDICSEG DO BEGIN
            IF SegDic.Dict.Disk_Info[i].Code_Leng <> 0 THEN
//           with SegDic.SegDictInfo[i] do
              BEGIN
              SetLength(SegName, CHARS_PER_IDENTIFIER);
              Move(Seg_Name[i], SegName[1], CHARS_PER_IDENTIFIER);
//            SegDic.Dict.seg_name := SegName;

              WITH Seg_Info[i] DO
                BEGIN
                  sfi.SegDictInfo[i].Major_Version := ExtractMajorVersion(SegInfo);
                IF ExtractMajorVersion(SegInfo) <> Unknown THEN BEGIN
                  sfi.SegDictInfo[i].MachineType := MType(SegInfo);
                  sfi.SegDictInfo[i].OldSegType := ExtractOldSegType(Seg_Misc[i].SegMiscRec);
                  IF sfi.SegDictInfo[i].OldSegType IN
                     [ UnitSeg, Unlinked_Intrins, Linked_Intrins ] THEN
                    sfi.SegDictInfo[i].Seg_Text := Seg_Text[i];
                  END ; { if majorversion <> volition }
                END ; { with Seg_Info }
              END ; { if }
            END ; { for }

          FOR i := 0 TO MaxSeg DO BEGIN
            IF i IN IntSegSet THEN BEGIN
//            IntrinsNeeded := TRUE
              END ; { if }
            END ; { for }
          END ; { with segdic, dict }
      end;
    END { MapUCSD } ;


  PROCEDURE MapSofTech
    ( VAR SegDic    : SegDicRec ;
          SegDicNum : INTEGER ;
          BlockNum  : INTEGER ) ;

    CONST
      { machine types kludge }
      xPsuedo   =  0 ;
      x6809     =  1 ;
      xPDP11    =  2 ;
      x8080     =  3 ;
      xZ80      =  4 ;
      xGA440    =  5 ;
      x6502     =  6 ;
      x6800     =  7 ;
      x9900     =  8 ;
      x8086     =  9 ;
      xZ8000    = 10 ;
      x68000    = 11 ;

    VAR
      i         : INTEGER ;
//    j         : SegRange ;
      BadSegs   : SegSet ;
      TooBig    : BOOLEAN ;
      mtype     : TMachineTypes;
      NewSegType: TNewSegTypesOrg;
      HasLinkInfo: boolean;
      Relocatable: boolean;
      SegName    : string[CHARS_PER_IDENTIFIER];

    PROCEDURE PutFamilyInfo
      (     Index : INTEGER ) ;
    
    { uses SegDic and the file o globally }
    
    BEGIN { PutFamilyInfo }
      
      WITH SegDic, Dict, Seg_Family[Index] DO BEGIN
        CASE ExtractNewSegType(Seg_Misc[Index].SegMiscRec) {Seg_Misc.xSegMisc[Index].SegType} OF
          xUnitSeg, xProgSeg:
           WITH o DO
            BEGIN
            WRITE( ' ' ) ;
            WRITE( PadL(Data_Size,5) ) ;
            WRITE( ' ' ) ;
            WRITE( PadL(seg_ref_words,5) ) ;
            WRITE( ' ' ) ;
            WRITE( PadL(max_seg_num,5) ) ;
            IF ExtractNewSegType(Seg_Misc[index].SegMiscRec) = xUnitSeg THEN BEGIN
              WRITE( ' ' ) ;
              WRITE( PadL(seg_text[Index],5) ) ;
              WRITE( ' ' ) ;
              WRITE( PadL(text_size,5) ) ;
              END
            ELSE
              WRITE( PadR('',12) ) ;
            END ;
          xSeprtSeg, xProcSeg:
            with o do
              BEGIN
              WRITE( ' ' ) ;
              WRITE( PadR('',11) ); Write( host_name ) ;
              END ;
          xNoSeg: BEGIN
            END ;
          END ; { case }
        END

      END { PutFamilyInfo } ;
      
      
    PROCEDURE PutOtherInfo ;
    
    { uses SegDic, output file o globally }

      VAR
        i       : INTEGER ;
        
    BEGIN { PutOtherInfo }

      WITH SegDic, Dict DO
        WITH o DO
        BEGIN
        WRITE( 'pCode version ' ) ;
        CASE ExtractMajorVersion(Seg_Info[0].SegInfo) OF
          Unknown     : WRITE('unknown' ) ;
          II,II_1,III : WRITE('<<bad>>' ) ;
          IV          : WRITE('IV' ) ;
          V,VI,VII    : WRITE('unknown' ) ;
          END ; { case }
        WRITE('.  ' ) ;
        IF Next_Dict = 0 THEN
          WRITELN( 'Last dictionary segment in chain.' )
        ELSE
          WRITELN( ['Next dictionary segment is at block #', Next_Dict, '.'] ) ;
        WRITELN( ['[', copyright, ']'] )
        END ;
      IF TooBig THEN
        BEGIN
        O.WRITE('*** ERROR: The following segments are too large: ' ) ;
        FOR i := 0 TO MAXDICSEG DO
          IF i IN BadSegs THEN
            O.WRITE( [i, ' '] ) ;
        O.WRITELN
        END

      END { PutOtherInfo } ;


  BEGIN { MapSofTech }

    BadSegs := [] ;
    TooBig  := FALSE ;

    WITH O DO      
    IF ReadSegDic( f, FileStartBlock+BlockNum, SegDic ) THEN BEGIN
      WRITE  ( [', segment dictionary record #', SegDicNum] ) ;
      WRITELN( [',  block #', BlockNum] ) ;
      WRITE('Seg Name      Addr    Len  Mach.  Kind    ' ) ;
      WRITE('Lnk Rel ' ) ;
      WRITE(' Data  Refs MxSeg TxAdr TxLen' ) ;
      WRITELN ;
      FOR i := 0 TO MAXDICSEG DO BEGIN
        WRITE( Padl(i,3) ) ;
        IF SegDic.Dict.Disk_Info[i].Code_Leng <> 0 THEN WITH SegDic, Dict DO BEGIN
          SetLength(SegName, CHARS_PER_IDENTIFIER);
          Move(Seg_Name[i], SegName[1], CHARS_PER_IDENTIFIER);
          WRITE([' ', SegName] ) ;
          WITH Disk_Info[i] DO BEGIN
            WRITE( PadL(Code_Addr,6) ) ;
            WRITE( PadL(Code_Leng,7) ) ;
            IF Code_Leng > 8191 THEN BEGIN
              BadSegs := BadSegs + [ i ] ;
              TooBig  := TRUE
              END
            END ;
          WITH Seg_Info[i] DO BEGIN
            WRITE('  ' ) ;
            MType := ExtractMachineType(SegInfo);
            IF ORD(MType) = xPsuedo THEN BEGIN
              WRITE('pCode' ) ;
              IF Flipped THEN
                WRITE('~' )
              ELSE
                WRITE(' ' )
              END
            ELSE CASE ORD(MType) OF
              x6809 : WRITE('6809  ' ) ;
              xPDP11: WRITE('PDP11 ' ) ;
              x8080 : WRITE('8080  ' ) ;
              xZ80  : WRITE('Z80   ' ) ;
              xGA440: WRITE('GA440 ' ) ;
              x6502 : WRITE('6502  ' ) ;
              x6800 : WRITE('6800  ' ) ;
              x9900 : WRITE('9900  ' ) ;
              x8086 : WRITE('8086  ' ) ;
              xZ8000: WRITE('Z8000 ' ) ;
              x68000: WRITE('68000 ' ) ;
              END ; { case }
            WRITE(' ' ) ;
            NewSegType := ExtractNewSegType(seg_misc[i].SegMiscRec);
            CASE NewSegType OF
              xNoSeg     : WRITE('<empty> ' ) ;
              xProgSeg   : WRITE('Program ' ) ;
              xUnitSeg  : WRITE('Unit    ' ) ;
              xProcSeg   : WRITE('Segment ' ) ;
              xSeprtSeg : WRITE('Separate' ) ;
              END ; { case }
            END ; { with Seg_Info }
          WRITE(' ' ) ;
          WITH seg_misc[i] DO BEGIN
            HasLinkInfo := ExtractHasLinkInfo(SegMiscRec);
            IF HasLinkInfo THEN
              WRITE(' T' )
            ELSE
              WRITE(' F' ) ;
            WRITE(' ' ) ;
            Relocatable := ExtractRelocatable(SegMiscRec);
            IF Relocatable THEN
              WRITE('  T' )
            ELSE
              WRITE('  F' ) ;
            END ;
          PutFamilyInfo( i ) ;
          END ; (* if, with segdic *)
        WRITELN ;
        END ; (* for *)
      PutOtherInfo ;
      END
    ELSE BEGIN
      { ReadSegDic has already written err msg, so set NextDict to quit }
      SegDic.Dict.next_dict := 0
      END ;
    
    END { MapSofTech } ;

BEGIN { LoadSegmentFile }

  result    := true;    // unless we fail
  SegDicNum := 0 ;
  BlockNum  := 0 ;

  IF ReadSegDic( f, BlockNum, sfi.SegDic ) THEN BEGIN
    sfi.MajorVersion := ExtractMajorVersion(sfi.SegDic.Dict.Seg_Info[0].SegInfo);
    IF sfi.MajorVersion < IV THEN BEGIN
      sfi.FileName := BaseName;
      MapUCSD( sfi.SegDic )
      END
    ELSE BEGIN
      REPEAT
        MapSofTech( SegDic, SegDicNum, BlockNum ) ;
        BlockNum  := SegDic.Dict.Next_Dict ;
        SegDicNum := SUCC( SegDicNum ) ;
        UNTIL BlockNum = 0
      END
    END
  ELSE BEGIN
    { ReadSegDic has already written error message, so do nothing! }
    END ;

  END { LoadSegmentFile } ;

PROCEDURE Map
  ( VAR f       : phyle;
        FileStartBlock: longint) ;

  VAR
    SegDic      : SegDicRec ;
    SegDicNum   : INTEGER ;
    BlockNum    : INTEGER ;
    MajorVersion: TVersions;
  
  
  FUNCTION ReadSegDic
    ( VAR f        : phyle ;
          BlockNum : longint ;
      VAR SegDic   : SegDicRec ) : BOOLEAN ;
  var
    NrBlocksRead: longint;
    IO: integer;
  
    FUNCTION ItIsFlipped
      (     SegDic  : TSeg_Dict )
      : BOOLEAN ;
    
    { Note (with some frustration) that we can't use the IV.x Sex byte    }
    { to check for sex even on IV.x code files, because the MajorVersion  }
    { field is in a sex-effected record and so cannot be checked until    }
    { AFTER the sex is already determined!              -acd 17 Dec 82    }

    { The test used is kludgy at best.  We assume that all valid code     }
    { (& library) files must have something beginning at block one.  If   }
    { we find no CodeAddr equal to 1 and no SegText equal to 1 we then    }
    { assume that the file must be of the wrong sex.  If someone can tell }
    { me of a less arbitrary way to test this, I would be very grateful!  }
    {                                                   -acd 18 Dec 82    }

    { We now make the further assumption that if the IV.x sex word seems  }
    { to contain the value <1> in either sex that the file is indeed IV.x }
    { This should be OK, since this word contained the last two bytes of  }
    { the comment in pre-IV.x releases and if you put <ctrl-A><ctrl-@>    }
    { or <ctrl-@><ctrl-A> into your comment you deserve anything you get. }
    { Of course, if your compiler didn't zero these bytes, 1 in every 128 }
    { files you SegMap will be reported erroneously as IV.x files.  Sorry }
    { bout that, maybe someone will write a SegDictFix utility!  All of   }
    { this foolishness is necessary because my kludge test for sex won't  }
    { work on IV.x where the segment that resides at block #1 will often  }
    { be in a later block of the segment dictionary.    -acd 21 Dec 82    }

      CONST
        NotFlipped      =     1 ;
        Flipped         =   256 ;
        
      VAR
        i   : INTEGER ;
        Temp: BOOLEAN ;

    BEGIN { ItIsFlipped }

      IF (SegDic.Sex = Flipped) or (SegDic.Sex = NotFlipped ) THEN BEGIN
        IF SegDic.Sex = Flipped THEN
          ItIsFlipped := TRUE
        ELSE
          ItIsFlipped := FALSE
        END
      ELSE BEGIN
        Temp := TRUE ; { assume it to be flipped }
        WITH SegDic DO BEGIN
          FOR i := 0 TO MAXDICSEG DO 
            IF ( disk_info[i].code_addr = 1 ) OR
               ( seg_text[i]           = 1 ) THEN
              Temp := FALSE ; { must be ok (we hope) }
          END ; { with }
        ItIsFlipped := Temp
        END ;
        
      END { ItIsFlipped } ;
  
  
    PROCEDURE FlipSegDic
      ( VAR SegDic : SegDicRec ) ;

      VAR
        i       : INTEGER ;
        Transfer: INTEGER ;
        XfrArray: ARRAY [0..3] OF INTEGER ;
        NewSegType: TNewSegTypesOrg;
        
  
      FUNCTION FlipIt
        (     Num     : INTEGER ) 
        : INTEGER ;
      
        VAR
          a, b  : PACKED ARRAY [0..1] OF 0..255 ;
          
      BEGIN { FlipIt }

        MOVE( Num, a[0], 2 ) ;
        b[0] := a[1] ;
        b[1] := a[0] ;
        MOVE( b[0], Num, 2 ) ;
        FlipIt := Num
        
        END { FlipIt } ;
  
  
    BEGIN { FlipSegDic }
      IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
        WITH SegDic, Dict DO BEGIN
          FOR i := 0 TO MAXDICSEG DO BEGIN
            { first the easy part... }
            WITH disk_info[i] DO BEGIN
              code_addr := FlipIt( code_addr ) ;
              code_leng := FlipIt( code_leng )
              END ; { with DiskInfo }
            seg_text[i] := FlipIt( seg_text[i] ) ;
            { and now all the messy junk... }
//          MOVE( SegMisc.SegType[i], Transfer, 2 ) ;
            MOVE(Seg_Misc[i].SegMiscRec, Transfer, 2);
            Transfer := FlipIt( Transfer ) ;
            MOVE( Transfer, Seg_Misc[i].SegMiscRec, 2 ) ;
            MOVE( seg_info[i], Transfer, 2 ) ;
            Transfer := FlipIt( Transfer ) ;
            MOVE( Transfer, seg_info[i], 2 ) ;
            MajorVersion := ExtractMajorVersion(seg_info[i].SegInfo);
            IF MajorVersion > III THEN BEGIN
//            IF seg_misc.xSegMisc[I].SegType IN [ xUnitSeg, ProgSeg ] THEN BEGIN
              NewSegType := ExtractNewSegType(seg_misc[i].SegMiscRec);
              IF NewSegType IN [ xUnitSeg, xProgSeg ] THEN BEGIN
                WITH seg_family[i] DO BEGIN
                  data_size     := FlipIt( data_size ) ;
                  seg_ref_words := FlipIt( seg_ref_words ) ;
                  max_seg_num   := FlipIt( max_seg_num ) ;
                  text_size     := FlipIt( text_size )
                  END ; { with segfamily }
                END ; { if }
              END ; { if }
            END ; { for }
          IF ExtractMajorVersion(seg_info[0].SegInfo) > III THEN BEGIN
            next_dict := FlipIt( next_dict ) ;
            { in an ideal world we'd leave Sex unflipped, but this thing is, }
            { as I said, quick and dirty so we need to go ahead and flip it. }
            Sex := FlipIt( Sex )
            END { if }
          ELSE BEGIN
            MOVE( IntSegSet, XfrArray[0], SIZEOF(IntSegSet) ) ;
            FOR i := 0 TO 3 DO
              XfrArray[i] := FlipIt( XfrArray[i] ) ;
            MOVE( XfrArray[0], IntSegSet, SIZEOF(IntSegSet) ) ;
            END ; { else }
          END ; { with segdic.dict }
        END { if }

      END { FlipSegDic } ;
      
      
  BEGIN { ReadSegDic }

    {$I-}
    Seek(f, BlockNum);
{$IfDef FileOfBlock}
    Read(f, SegDic.aBlock);
{$else}
    NrBlocksRead := 0;
    BlockREAD(f, SegDic.aBlock, 1, NrBlocksRead);
{$EndIf}
    IO := IOResult;
    IF (NrBlocksRead = 1) AND (IO = 0) THEN BEGIN
    {$I+}
      IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
        SegDic.Flipped := TRUE ;
        FlipSegDic( SegDic )
        END 
      ELSE BEGIN
        SegDic.Flipped := FALSE ;
        END ;
      IF BlockNum = 0 THEN BEGIN { only recheck gender in first seg of dictionary }
        IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
          O.ClearEOP ;
          O.WRITE( ['Unable to determine gender of ', CFileName] ) ;
          ReadSegDic := FALSE
          END
        ELSE BEGIN
          ReadSegDic := TRUE
          END
        END { if block = 0 }
      ELSE
        ReadSegDic := TRUE { because we already know the gender is OK }
      END { if block read successfully }
    ELSE BEGIN
      O.ClearEOP ;
      o.WRITE( ['Error reading segment dictionary of ', CFileName] ) ;
      ReadSegDic := FALSE
      END 
    
    END { ReadSegDic } ;

    function SegNum(SegInfo: word): word;
    begin
      Assert(false);
    end;

    function ExtractMachineType(packed_stuff: word): TMachineTypes;
    var
      Val: word;
    begin
      Val    := GetBits(Packed_Stuff, 8, 5);
      Result := TMachineTypes(Val);
    end;

    function ExtractHasLinkInfo(SegMiscRec: word): boolean;
    begin
      result := Boolean(GetBits(SegMiscRec, 8, 1));
    end;

    function ExtractRelocatable(SegMiscRec: word): boolean;
    begin
      result := Boolean(GetBits(SegMiscRec, 9, 1));
    end;

  PROCEDURE MapUCSD
    (     SegDic : SegDicRec ) ;
    
    VAR
      i                 : INTEGER ;
//    j                 : SegRange ;
      IntrinsNeeded     : BOOLEAN ;
      NewSegType        : TNewSegTypesOrg;
      OldSegType        : TOldSegTypes;
      Segname           : string[CHARS_PER_IDENTIFIER];

(*
    function DecodePackedStuff(packed_stuff: word): string;
    var
      seg_num: word;                { local segment number }
      has_link_info : boolean;     { needs to be linked }
      relocatable   : boolean;     { has relocatable code }
      m_type        : TMTypes;     { machine type }
      BitNr         : byte;
    begin
      BitNr         := 0;
      seg_num       := Bits(packed_stuff, BitNr, 8);
      has_link_info := Boolean(Bits(packed_stuff, BitNr, 1));
      relocatable   := Boolean(Bits(packed_stuff, BitNr, 1));
      m_type        := TMTypes(Bits(packed_stuff, BitNr, 4));
      result := Format('seg_num=%d, has_link_info=%s, relocatable=%s, m_type=%s',
                       [seg_num, TFString(has_link_info), TFString(relocatable), processor_types[m_type]]);
    end;

*)
    function MType(SegInfo: word): TMachineTypes;
    begin
      result  := TMachineTypes(GetBits(SegInfo, 0, 4));
    end;

  BEGIN { MapUCSD }
    
    IntrinsNeeded := FALSE ;

    with O do
      begin
        WRITE( '  #  Name      Addr    Len  ' ) ;
        WRITE( 'Version   Machine  Kind                ' ) ;
        WRITE( 'Seg   Text' ) ;
        WRITELN ;

        WITH SegDic, Dict DO BEGIN

          FOR i := 0 TO MAXDICSEG DO BEGIN
            WRITE( PadL(i,3) ) ;
            IF SegDic.Dict.Disk_Info[i].Code_Leng <> 0 THEN BEGIN
              SetLength(SegName, CHARS_PER_IDENTIFIER);
              Move(Seg_Name[i], SegName[1], CHARS_PER_IDENTIFIER);
              WRITE( ['  ', SegName] ) ;
              WITH Disk_Info[i] DO BEGIN
                WRITE( PadL(Code_Addr, 6) ) ;
                WRITE( PadL(IntToStr(Code_Leng DIV 2), 7 )) ;
                END ;
              WITH Seg_Info[i] DO BEGIN
                WRITE( '  ' ) ;
                CASE ExtractMajorVersion(SegInfo) OF
                  Unknown  : WRITE( 'Volition' ) ;
                  II       : WRITE( 'II.0    ' ) ;
                  II_1     : WRITE( 'II.1    ' ) ;
                  III      : WRITE( 'III.0   ' )
                  END ; { case }
                IF ExtractMajorVersion(SegInfo) <> Unknown THEN BEGIN
                  WRITE( '  ' ) ;
                  CASE MType(SegInfo) OF
                    UnDefined  : WRITE( 'Unknown' ) ;
                    PCodeMost  : WRITE( 'PCode+ ' ) ;
                    PCodeLeast : WRITE( 'PCode- ' ) ;
                    PDP11      : WRITE( 'PDP-11 ' ) ;
                    M8080      : WRITE( '8080   ' ) ;
                    Z80        : WRITE( 'Z80    ' ) ;
                    GA440      : WRITE( 'GA440  ' ) ;
                    M6502      : WRITE( '6502   ' ) ;
                    M6800      : WRITE( '6800   ' ) ;
                    TI990      : WRITE( 'TI990  ' ) ;
                    END ; { case }
                  WRITE( '  ' ) ;
                  OldSegType := ExtractOldSegType(Seg_Misc[i].SegMiscRec);
                  CASE OldSegType OF
                    Linked           : WRITE( 'Linked excutable  ' ) ;
                    HostSeg          : WRITE( 'Unlinked host     ' ) ;
                    SegProc          : WRITE( 'Segment procedure ' ) ;
                    UnitSeg          : WRITE( 'Regular unit      ' ) ;
                    SeprtSeg         : WRITE( 'Separate procedure' ) ;
                    Unlinked_Intrins : WRITE( 'Unlinked intrinsic' ) ;
                    Linked_Intrins   : WRITE( 'Linked intrinsic  ' ) ;
                    DataSeg          : WRITE( 'Data segment      ' ) ;
                    END ; { case }
                  WRITE( '  ' ) ;
                  WRITE( [SegNum(SegInfo), ' '] ) ;
                  WRITE( '  ' ) ;
                  IF OldSegType IN
                     [ UnitSeg, Unlinked_Intrins, Linked_Intrins ] THEN
                    WRITE( [Seg_Text[i]] ) ;
                  END ; { if majorversion <> volition }
                END ; { with Seg_Info }
              END ; { if }
            WRITELN ;
            END ; { for }

          WRITE( 'Intrinsic segments required: ' ) ;

          FOR i := 0 TO MaxSeg DO BEGIN
            IF i IN IntSegSet THEN BEGIN
              WRITE( PadL(i, 3) ) ;
              IntrinsNeeded := TRUE
              END ; { if }
            END ; { for }
          IF IntrinsNeeded = FALSE THEN
            WRITE( ' None' ) ;

          WRITELN

          END ; { with segdic, dict }
      end;

    END { MapUCSD } ;


  PROCEDURE MapSofTech
    ( VAR SegDic    : SegDicRec ;
          SegDicNum : INTEGER ;
          BlockNum  : INTEGER ) ;

    CONST
      { machine types kludge }
      xPsuedo   =  0 ;
      x6809     =  1 ;
      xPDP11    =  2 ;
      x8080     =  3 ;
      xZ80      =  4 ;
      xGA440    =  5 ;
      x6502     =  6 ;
      x6800     =  7 ;
      x9900     =  8 ;
      x8086     =  9 ;
      xZ8000    = 10 ;
      x68000    = 11 ;

    VAR
      i         : INTEGER ;
      j         : SegRange ;
      BadSegs   : SegSet ;
      TooBig    : BOOLEAN ;
      mtype     : TMachineTypes;
      NewSegType: TNewSegTypesOrg;
      HasLinkInfo: boolean;
      Relocatable: boolean;
      SegName    : string[CHARS_PER_IDENTIFIER];

    PROCEDURE PutFamilyInfo
      (     Index : INTEGER ) ;
    
    { uses SegDic and the file o globally }
    
    BEGIN { PutFamilyInfo }
      
      WITH SegDic, Dict, Seg_Family[Index] DO BEGIN
        CASE ExtractNewSegType(Seg_Misc[Index].SegMiscRec) {Seg_Misc.xSegMisc[Index].SegType} OF
          xUnitSeg, xProgSeg:
           WITH o DO
            BEGIN
            WRITE( ' ' ) ;
            WRITE( PadL(Data_Size,5) ) ;
            WRITE( ' ' ) ;
            WRITE( PadL(seg_ref_words,5) ) ;
            WRITE( ' ' ) ;
            WRITE( PadL(max_seg_num,5) ) ;
            IF ExtractNewSegType(Seg_Misc[index].SegMiscRec) = xUnitSeg THEN BEGIN
              WRITE( ' ' ) ;
              WRITE( PadL(seg_text[Index],5) ) ;
              WRITE( ' ' ) ;
              WRITE( PadL(text_size,5) ) ;
              END
            ELSE
              WRITE( PadR('',12) ) ;
            END ;
          xSeprtSeg, xProcSeg:
            with o do
              BEGIN
              WRITE( ' ' ) ;
              WRITE( PadR('',11) ); Write( host_name ) ;
              END ;
          xNoSeg: BEGIN
            END ;
          END ; { case }
        END

      END { PutFamilyInfo } ;
      
      
    PROCEDURE PutOtherInfo ;
    
    { uses SegDic, output file o globally }

      VAR
        i       : INTEGER ;
        
    BEGIN { PutOtherInfo }
      
      WITH SegDic, Dict DO
        WITH o DO
        BEGIN
        WRITE( 'pCode version ' ) ;
        CASE ExtractMajorVersion(Seg_Info[0].SegInfo) OF
          Unknown     : WRITE('unknown' ) ;
          II,II_1,III : WRITE('<<bad>>' ) ;
          IV          : WRITE('IV' ) ;
          V,VI,VII    : WRITE('unknown' ) ;
          END ; { case }
        WRITE('.  ' ) ;
        IF Next_Dict = 0 THEN
          WRITELN( 'Last dictionary segment in chain.' )
        ELSE
          WRITELN( ['Next dictionary segment is at block #', Next_Dict, '.'] ) ;
        WRITELN( ['[', copyright, ']'] )
        END ;
      IF TooBig THEN
        BEGIN
        O.WRITE('*** ERROR: The following segments are too large: ' ) ;
        FOR i := 0 TO MAXDICSEG DO
          IF i IN BadSegs THEN
            O.WRITE( [i, ' '] ) ;
        O.WRITELN
        END

      END { PutOtherInfo } ;


  BEGIN { MapSofTech }

    BadSegs := [] ;
    TooBig  := FALSE ;

    WITH O DO      
    IF ReadSegDic( f, BlockNum, SegDic ) THEN BEGIN
      WRITE  ( [', segment dictionary record #', SegDicNum] ) ;
      WRITELN( [',  block #', BlockNum] ) ;
      WRITE('Seg Name      Addr    Len  Mach.  Kind    ' ) ;
      WRITE('Lnk Rel ' ) ;
      WRITE(' Data  Refs MxSeg TxAdr TxLen' ) ;
      WRITELN ;
      FOR i := 0 TO MAXDICSEG DO BEGIN
        WRITE( Padl(i,3) ) ;
        IF SegDic.Dict.Disk_Info[i].Code_Leng <> 0 THEN WITH SegDic, Dict DO BEGIN
          SetLength(SegName, CHARS_PER_IDENTIFIER);
          Move(Seg_Name[i], SegName[1], CHARS_PER_IDENTIFIER);
          WRITE([' ', SegName] ) ;
          WITH Disk_Info[i] DO BEGIN
            WRITE( PadL(Code_Addr,6) ) ;
            WRITE( PadL(Code_Leng,7) ) ;
            IF Code_Leng > 8191 THEN BEGIN
              BadSegs := BadSegs + [ i ] ;
              TooBig  := TRUE
              END
            END ;
          WITH Seg_Info[i] DO BEGIN
            WRITE('  ' ) ;
            MType := ExtractMachineType(SegInfo);
            IF ORD(MType) = xPsuedo THEN BEGIN
              WRITE('pCode' ) ;
              IF Flipped THEN 
                WRITE('~' )
              ELSE
                WRITE(' ' )
              END
            ELSE CASE ORD(MType) OF
              x6809 : WRITE('6809  ' ) ;
              xPDP11: WRITE('PDP11 ' ) ;
              x8080 : WRITE('8080  ' ) ;
              xZ80  : WRITE('Z80   ' ) ;
              xGA440: WRITE('GA440 ' ) ;
              x6502 : WRITE('6502  ' ) ;
              x6800 : WRITE('6800  ' ) ;
              x9900 : WRITE('9900  ' ) ;
              x8086 : WRITE('8086  ' ) ;
              xZ8000: WRITE('Z8000 ' ) ;
              x68000: WRITE('68000 ' ) ;
              END ; { case }
            WRITE(' ' ) ;
            NewSegType := ExtractNewSegType(seg_misc[i].SegMiscRec);
            CASE NewSegType OF
              xNoSeg     : WRITE('<empty> ' ) ;
              xProgSeg   : WRITE('Program ' ) ;
              xUnitSeg  : WRITE('Unit    ' ) ;
              xProcSeg   : WRITE('Segment ' ) ;
              xSeprtSeg : WRITE('Separate' ) ;
              END ; { case }
            END ; { with Seg_Info }
          WRITE(' ' ) ;
          WITH seg_misc[i] DO BEGIN
            HasLinkInfo := ExtractHasLinkInfo(SegMiscRec);
            IF HasLinkInfo THEN
              WRITE(' T' )
            ELSE
              WRITE(' F' ) ;
            WRITE(' ' ) ;
            Relocatable := ExtractRelocatable(SegMiscRec);
            IF Relocatable THEN
              WRITE('  T' )
            ELSE
              WRITE('  F' ) ;
            END ;
          PutFamilyInfo( i ) ;
          END ; (* if, with segdic *)
        WRITELN ;
        END ; (* for *)
      PutOtherInfo ;
      END
    ELSE BEGIN
      { ReadSegDic has already written err msg, so set NextDict to quit }
      SegDic.Dict.next_dict := 0
      END ;
    
    END { MapSofTech } ;
    

BEGIN { Map }

  SegDicNum := 0 ;
  BlockNum  := 0 ;
  
  IF ReadSegDic( f, FileStartBlock+BlockNum, SegDic ) THEN BEGIN
    MajorVersion := ExtractMajorVersion(SegDic.Dict.Seg_Info[0].SegInfo);
    IF MajorVersion < IV THEN BEGIN
      IF ConsoleOutput THEN
        O.ClearEOP {
      ELSE
        Page( OutFile )} ;
      O.WRITELN;
      O.WRITELN( ['File: ', BaseName] ) ;
      MapUCSD( SegDic )
      END
    ELSE BEGIN
      REPEAT
        IF ConsoleOutput THEN
          o.ClearEOP {
        ELSE
          Page( o )} ;
        O.WRITELN ;
        O.WRITE(['File: ', BaseName] ) ;
        MapSofTech( SegDic, SegDicNum, FileStartBlock+BlockNum ) ;
        BlockNum  := SegDic.Dict.Next_Dict ;
        SegDicNum := SUCC( SegDicNum ) ;
        IF (OFileName = 'CONSOLE:') AND (BlockNum <> 0) THEN
          SpaceWait ;
        UNTIL BlockNum = 0
      END
    END
  ELSE BEGIN
    { ReadSegDic has already written error message, so do nothing! }
    END ;

  END { Map } ;

  procedure SegMapper(var f: phyle; FileStartBlock: longint);
  begin
   Initialize ;
   WHILE Menu = TRUE DO
     Map( f, FileStartBlock ) ;
   CleanUp
  end;

  
END.
