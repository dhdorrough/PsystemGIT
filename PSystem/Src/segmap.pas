// JCF does NOT work on code snippets. Your code has to be complete and
// syntactically correct. Otherwise, the formatter won't work properly.
// If you insist to format code snippet, you must put `program test;` at
// the first line and your snippet between `begin` and `end.`. Enjoy!

{ SegMap: A quick & dirty segment map utility 17 Apr 83 }

unit SegMap;

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
  pSysWindow, UCSDGlob, pSysVolumes, Interp_Decl, Interp_Const, SysUtils ;

CONST
   Title        = 'SegMap[' ;
   Rev          = '0.1f' ;
   T0 = '                        Volition Systems'' SegMap utility' ;
   T1 = '                            version 0.1f of 17 Apr 83' ;
   T2 = '          Copyright (C) 1982, Volition Systems.  All rights reserved.';
   MAXSEG       =    63 ; { 15 for most, 31 for Apple ][, 63 for Apple /// }
   MAXDICSEG    =    15 ;
   CHARS_PER_IDENTIFIER = 8;

TYPE
   SegRange     = 0..MaxSeg ;
   SegDicRange  = 0..MAXDICSEG ;
   SegmentName  = PACKED ARRAY[0..7] OF CHAR ;

   { I.x, II.x, III.x, VS }
     TOldSegTypes = ( Linked, HostSeg, SegProc, UnitSeg, SeprtSeg,
                      Unlinked_Intrins, Linked_Intrins, DataSeg ) ;
     TMachineTypes    = ( UnDefined, PCodeMost, PCodeLeast, PDP11, M8080, Z80,
                          GA440, M6502, M6800, TI990 ) ;
     TMachTypesKludge = (xPseudo, x6809, xPDP11, x8080, xZ80, xGA440, x6502, x6800,
                         x9900, x8086, xZ8000, x68000, xPCodeMost, xPCodeLeast);

   { IV.x }
     TNewSegTypes     = ( {0}NoSeg, {1}ProgSeg, {2}xUnitSeg, {3}ProcSeg, {4}xSeprtSeg ) ;
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

   Block = packed array[0..FBLKSIZE-1] of char;

   TSegDicRec    = RECORD
     Flipped    : BOOLEAN ;
     case integer of
       0: (Dict       : TSeg_Dict);
       1: (aBlock     : block)
     END ;

  TSegDicRecPtr = ^TSegDicRec;

  TVersionSplit = (vsUnknown, vsUCSD, vsSoftech);

  TSegmentFileInfo = record
    VersionSplit   : TVersionSplit;
    VolumeFilePath : string[80];
    VolumeName     : string[8];
    FileName       : string[15];
    MajorVersion   : TVersions;
    NrSegsInFile   : integer;
    SegDictInfo    : array[0..MaxSeg] OF
      record
        SegName       : string[CHARS_PER_IDENTIFIER];
        Code_Addr     : word;
        Code_Leng     : word;               // Nr BYTES in segment (V1.4, 1.5), Nr Words (in Segment V2.0, V4.0)
        Major_version : TVersions;
        MachineType   : TMachTypesKludge;
        OldSegType    : TOldSegTypes;
        Seg_Text      : word;
        text_size     : word;
        Flipped       : boolean;
        NewSegType    : TNewSegTypes;
        HasLinkInfo   : boolean;
        Relocatable   : boolean;
        Seg_Ref_Words : word;
        Data_Size     : word;
        max_seg_num   : word;
        host_name     : TSegment_Name;
      end;
    IntSegSet     : SegSet;
    IntrinsNeeded : BOOLEAN ;
  end;

   PathName     = STRING ;

   TErrorMessageProc = procedure {name} (const Message: string; Args: array of Const) of object;

{$IfDef FileOfBlock}
   Phyle = File of Block;
{$else}
   Phyle = File;
{$EndIf}

  EUnknownGender = class(Exception);
  
VAR
  MachTypes:  array[TMachineTypes] of string =
              ({UnDefined}  'Undefined',
               {PCodeMost}  'PCodeMost',
               {PCodeLeast} 'PCodeLeast',
               {PDP11}      'PDP11',
               {M8080}      'M8080',
               {Z80}        'Z80',
               {GA440}      'GA440',
               {M6502}      'M6502',
               {M6800}      'M6800',
               {TI990}      'TI990'
              );
  MachTypesK: array[TMachTypesKludge] of string =
             ({xPseudo} 'Pseudo',
              {x6809}   '6809',
              {xPDP11}  'PDP11',
              {x8080}   '8080',
              {xZ80}    'Z80',
              {xGA440}  'GA440',
              {x6502}   '6502',
              {x6800}   '6800',
              {x9900}   '9900',
              {x8086}   '8086',
              {xZ8000}  'Z8000',
              {x68000}  '68000',
              {xPCodeMost} 'PCodeMost',
              {xPCodeLeast} 'PCodeLeast'
             );

  SegTypeNames: array[TNewSegTypes] of string =
    ( '<empty>', 'Program', 'Unit', 'ProcSeg', 'Separate' ) ;

  OldSegTypeNames: array[TOldSegTypes] of string =
    ('Linked',
     'HostSeg',
     'SegProc',
     'UnitSeg',
     'SeprtSeg',
     'Unlinked_Intrins',
     'Linked_Intrins',
     'DataSeg');

  MajorVersionNames: array[TVersions] of string =
    ({Unknown} 'Unknown',
     {ii}      'V2.0',
     {ii_1}    'V2.1',
     {iii}     'V3.0',
     {iv}      'V4.0',
     {v}       'Unknown',
     {vi}      'Unknown',
     {vii}     'Unknown'
     );

function ConvertMType(bits: word{TMachineTypes}; IsUCSD: boolean): TMachTypesKludge;
function ExtractMajorVersion(SegInfo: word): TVersions;
function ExtractNewSegType(SegMiscRec: word): TNewSegTypes;
FUNCTION FlipIt( Num: word ): word ;
PROCEDURE FlipSegDic( VAR SegDic : TSegDicRec; var MajorVersion: TVersions ) ;
FUNCTION ItIsFlipped(SegDic  : TSeg_Dict ): BOOLEAN ;
FUNCTION LoadSegmentFile  (     FileStartBlock: longint;
                                SVOLBlockOffset: longint;
                                f       : TVolume ;
                            var sfi     : TSegmentFileInfo;
                                CFileName     : PathName;
                                ErrorMessageProc: TErrorMessageProc = nil): boolean ;
IMPLEMENTATION

uses MyUtils, BitOps, pSysExceptions;

function ConvertMType(bits: word{TMachineTypes}; IsUCSD: boolean): TMachTypesKludge;
begin
  result := xPseudo;  // default

  if IsUCSD then
    case TMachineTypes(bits) of
      UnDefined:  result := xPseudo;
      PCodeMost:  result := xPCodeMost;
      PCodeLeast: result := xPCodeLeast;
      PDP11:      result := xPDP11;
      M8080:      result := x8086;
      Z80:        result := xZ80;
      GA440:      result := xGA440;
      M6502:      result := x6502;
      M6800:      result := x6800;
      TI990:      result := x9900;
    end
  else
    result := TMachTypesKludge(Bits);
end;

FUNCTION ItIsFlipped(     SegDic  : TSeg_Dict ): BOOLEAN ;

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

  IF (SegDic.Sex = Flipped) or (SegDic.Sex = NotFlipped ) THEN
    IF SegDic.Sex = Flipped THEN
      ItIsFlipped := TRUE
    ELSE
      ItIsFlipped := FALSE
  ELSE
    BEGIN
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

  FUNCTION FlipIt
    (     Num     : word ): word ;

    VAR
      a, b  : PACKED ARRAY [0..1] OF 0..255 ;

  BEGIN { FlipIt }

    MOVE( Num, a[0], 2 ) ;
    b[0] := a[1] ;
    b[1] := a[0] ;
    MOVE( b[0], Num, 2 ) ;
    FlipIt := Num

    END { FlipIt } ;

    PROCEDURE FlipSegDic( VAR SegDic : TSegDicRec; var MajorVersion: TVersions ) ;

      VAR
        i       : INTEGER ;
        Transfer: word ;
        XfrArray: ARRAY [0..3] OF word ;
        NewSegType: TNewSegTypes;

    BEGIN { FlipSegDic }
      IF ItIsFlipped( SegDic.Dict ) THEN
        BEGIN
          WITH SegDic, Dict DO
            BEGIN
              FOR i := 0 TO MAXDICSEG DO
                BEGIN
                  { first the easy part... }
                  WITH disk_info[i] DO
                    BEGIN
                      code_addr := FlipIt( code_addr ) ;
                      code_leng := FlipIt( code_leng )
                    END ; { with DiskInfo }
                  seg_text[i] := FlipIt( seg_text[i] ) ;
               { and now all the messy junk... }
                  MOVE(Seg_Misc[i].SegMiscRec, Transfer, 2);
                  Transfer := FlipIt( Transfer ) ;
                  MOVE( Transfer, Seg_Misc[i].SegMiscRec, 2 ) ;

                  MOVE( seg_info[i], Transfer, 2 ) ;
                  Transfer := FlipIt( Transfer ) ;
                  MOVE( Transfer, seg_info[i], 2 ) ;

                  MajorVersion := ExtractMajorVersion(seg_info[i].SegInfo);

                  IF MajorVersion > III THEN
                    BEGIN
                      NewSegType := ExtractNewSegType(seg_misc[i].SegMiscRec);
                      IF NewSegType IN [ xUnitSeg, ProgSeg ] THEN
                        WITH seg_family[i] DO
                          BEGIN
                            data_size     := FlipIt( data_size ) ;
                            seg_ref_words := FlipIt( seg_ref_words ) ;
                            max_seg_num   := FlipIt( max_seg_num ) ;
                            text_size     := FlipIt( text_size )
                          END ; { with segfamily }
                    END ; { if }
                END ; { for }

              IF ExtractMajorVersion(SegDic.Dict.seg_info[0].SegInfo) > III THEN
                BEGIN
                  SegDic.Dict.next_dict := FlipIt( SegDic.Dict.next_dict ) ;
                  { in an ideal world we'd leave Sex unflipped, but this thing is, }
                  { as I said, quick and dirty so we need to go ahead and flip it. }
                  SegDic.Dict.Sex := FlipIt( SegDic.Dict.Sex )
                END { if }
              ELSE
                BEGIN
                  MOVE( SegDic.Dict.IntSegSet, XfrArray[0], SIZEOF(SegDic.Dict.IntSegSet) ) ;
                  FOR i := 0 TO 3 DO
                    XfrArray[i] := FlipIt( XfrArray[i] ) ;
                  MOVE( XfrArray[0], SegDic.Dict.IntSegSet, SIZEOF(SegDic.Dict.IntSegSet) ) ;
                END ; { else }
            END ; { with segdic.dict }
        END; { if }

      END { FlipSegDic } ;

function ExtractMajorVersion(SegInfo: word): TVersions;
begin
  result   := TVersions(GetBits(SegInfo, 13, 3)); // bits 13, 14, 15
end;

function ExtractNewSegType(SegMiscRec: word): TNewSegTypes;
var
  Val: word;
begin
  val    := GetBits(SegMiscRec, 0, 3);
  result := TNewSegTypes(Val);
end;

function ExtractOldSegType(SegMiscRec: word): TOldSegTypes;
var
  Val: word;
begin
  val    := GetBits(SegMiscRec, 0, 3); // This may be totally wrong! dhd 1/27/2021
  result := TOldSegTypes(Val);
end;


FUNCTION LoadSegmentFile  (     FileStartBlock: longint;
                                SVOLBlockOffset: longint;
                                f       : TVolume ;
                            var sfi     : TSegmentFileInfo;
                                CFileName     : PathName;
                                ErrorMessageProc: TErrorMessageProc = nil): boolean;
  VAR
    SegDic      : TSegDicRec ;
    SegDicNum   : INTEGER ;
    BlockNum    : INTEGER ;
    SegIdx      : word;
//  MajorVersion: TVersions;

  procedure ErrorMessage(const Msg: string; Args: array of const);
  begin
    if Assigned(ErrorMessageProc) then
      ErrorMessageProc(Msg, Args);
  end;

  FUNCTION ReadSegDic
    ( {VAR} f             : TVolume ;
            BlockNum      : longint;
      VAR SegDic          : TSegDicRec ) : BOOLEAN ;
  var
    NrBlocksRead  : longint;
//  IO            : integer;
    MajorVersion  : TVersions;

  BEGIN { ReadSegDic }

    {$I-}
//  Seek(f, SVOLBlockOffset+FileStartBlock+BlockNum);
    f.SeekInVolumeFile(FileStartBlock+BlockNum);
//  BlockREAD(f, SegDic.aBlock, 1, NrBlocksRead);
    NrBlocksRead := f.BlockRead(SegDic.aBlock, 1);
//  IO := IOResult;
    IF (NrBlocksRead = 1) {AND (IO = 0)} THEN BEGIN
    {$I+}
      IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
        SegDic.Flipped := TRUE ;
        FlipSegDic( SegDic, MajorVersion );
        sfi.MajorVersion := MajorVersion;
        END 
      ELSE BEGIN
        SegDic.Flipped := FALSE ;
        END ;
        
      IF BlockNum = 0 THEN BEGIN { only recheck gender in first seg of dictionary }
        IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
          raise EUnknownGender.CreateFmt( 'Unable to determine gender of %s', [CFileName] ) ;
//        ReadSegDic := FALSE
          END
        ELSE BEGIN
          ReadSegDic := TRUE
          END
        END { if block = 0 }
      ELSE
        ReadSegDic := TRUE { because we already know the gender is OK }
      END { if block read successfully }
    ELSE BEGIN
      ErrorMessage('Error reading segment dictionary of %s. (Could not load file)', [CFileName] ) ;
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

    function MType(SegInfo: word): TMachineTypes;
    begin
      result  := TMachineTypes(GetBits(SegInfo, 0, 4));
    end;

    function ExtractHasLinkInfo(SegMiscRec: word): boolean;
    begin
      result := Boolean(GetBits(SegMiscRec, 8, 1));
    end;

    function ExtractRelocatable(SegMiscRec: word): boolean;
    begin
      result := Boolean(GetBits(SegMiscRec, 9, 1));
    end;

    function ExtractMTypeBits(SegInfo: word): word;
    VAR
      bits: word;
    begin
      bits := GetBits(SegInfo, 8, 4);
      result := bits;
    end;

  PROCEDURE MapUCSD
    (     SegDic : TSegDicRec ) ;
    
    VAR
      i                 : INTEGER ;
//    j                 : SegRange ;
//    IntrinsNeeded     : BOOLEAN ;
//    NewSegType        : TNewSegTypes;
//    OldSegType        : TOldSegTypes;
//    Segname           : string[CHARS_PER_IDENTIFIER];

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
  BEGIN { MapUCSD }
    // I think that this needs to deal with byte sex issues
    try
      sfi.IntrinsNeeded := FALSE ;
      sfi.VersionSplit  := vsUCSD;

      WITH SegDic, Dict DO BEGIN

        FOR i := 0 TO MAXDICSEG DO BEGIN
          IF SegDic.Dict.Disk_Info[i].Code_Leng <> 0 THEN
            BEGIN
              sfi.NrSegsInFile := sfi.NrSegsInFile +  1;
              SetLength(sfi.SegDictInfo[i].SegName, CHARS_PER_IDENTIFIER);
              Move(Seg_Name[i], sfi.SegDictInfo[i].SegName[1], CHARS_PER_IDENTIFIER);

              WITH Seg_Info[i] DO
                BEGIN
                  sfi.SegDictInfo[i].Major_Version := ExtractMajorVersion(SegInfo);
                  sfi.SegDictInfo[i].Code_Leng     := SegDic.Dict.Disk_Info[i].Code_Leng; // version II stored as bytes but version IV stores as words?
                  sfi.SegDictInfo[i].Code_Addr     := SegDic.Dict.Disk_Info[i].Code_Addr;
                  IF ExtractMajorVersion(SegInfo) <> Unknown THEN
                    BEGIN
                      sfi.SegDictInfo[i].MachineType := ConvertMType(ExtractMTypeBits(SegInfo), TRUE);
                      sfi.SegDictInfo[i].OldSegType  := ExtractOldSegType(Seg_Misc[i].SegMiscRec);
                      IF sfi.SegDictInfo[i].OldSegType IN
                         [ UnitSeg, Unlinked_Intrins, Linked_Intrins ] THEN
                        sfi.SegDictInfo[i].Seg_Text := Seg_Text[i];
                    END ; { if majorversion <> volition }
                END ; { with Seg_Info }
            END ; { if }
          END ; { for }

        FOR i := 0 TO MaxSeg DO
          IF i IN IntSegSet THEN
            sfi.IntrinsNeeded := TRUE
        END ; { with segdic, dict }
    except
      on e:Exception do
        raise EBadFile.CreateFmt('%s while processing %s', [e.message, sfi.FileName]);
    end;
  END { MapUCSD } ;

  PROCEDURE MapSofTech
    ( VAR SegDic    : TSegDicRec ;
          SegDicNum : word ;
          BlockNum  : INTEGER ) ;

    VAR
      i         : INTEGER ;
      BadSegs   : SegSet ;
      aMType    : TMachTypesKludge;

    procedure PutFamilyInfo(Index: integer);
    var
      SegIdx: integer;
    begin
      SegIdx  := (SegDicNum * (MAXDICSEG+1)) + i; // 0..63
      WITH SegDic, Dict, Seg_Family[Index] DO BEGIN
        CASE ExtractNewSegType(Seg_Misc[Index].SegMiscRec) {Seg_Misc.xSegMisc[Index].SegType} OF
          xUnitSeg, ProgSeg:
            BEGIN
            sfi.SegDictInfo[SegIdx].Data_Size := Data_Size;
            sfi.SegDictInfo[SegIdx].Seg_Ref_Words := Seg_Ref_Words;
            sfi.SegDictInfo[SegIdx].Max_Seg_Num := Max_Seg_Num;
            IF ExtractNewSegType(Seg_Misc[index].SegMiscRec) = xUnitSeg THEN
              BEGIN
                sfi.SegDictInfo[SegIdx].Seg_Text := Seg_Text[Index];
                sfi.SegDictInfo[SegIdx].text_size := Text_Size;
              END
            END ;
          xSeprtSeg, ProcSeg:
            sfi.SegDictInfo[SegIdx].host_name := host_name;
          END ; { case }
        END
    end;


  BEGIN { MapSofTech }
    // WARNING: THIS CODE MAY BE BROKEN. Try, for example: F:\NDAS-I\d7\Projects\pSystem\Volumes\SYSTEM4.VOL
    BadSegs := [] ;
    sfi.VersionSplit := vsSoftech;

    IF ReadSegDic( f, BlockNum, SegDic ) THEN
      BEGIN
        FOR i := 0 TO MAXDICSEG DO
          BEGIN
            if SegDicNum > 4095 then
              Exit;
            SegIdx  := (SegDicNum * (MAXDICSEG+1)) + i; // 0..63
            if SegIdx >= MAXSEG then
              Exit;
            IF SegDic.Dict.Disk_Info[i].Code_Leng <> 0 THEN
              WITH SegDic, Dict DO
                BEGIN
                  sfi.NrSegsInFile := sfi.NrSegsInFile + 1;
                  SetLength(sfi.SegDictInfo[SegIdx].SegName, CHARS_PER_IDENTIFIER);
                  Move(Seg_Name[i], sfi.SegDictInfo[SegIdx].SegName[1], CHARS_PER_IDENTIFIER);
                  WITH Disk_Info[i] DO
                    BEGIN
                      sfi.SegDictInfo[SegIdx].Code_Addr := Code_Addr;
                      sfi.SegDictInfo[SegIdx].Code_Leng := Code_Leng;  // version IV stores as words?
                      IF Code_Leng > 8191 THEN
                        BadSegs := BadSegs + [ i ] ;
                    END ;

                  WITH Seg_Info[i] DO
                    BEGIN
                      aMType           := ConvertMType(ExtractMTypeBits(SegInfo), false);
                      sfi.SegDictInfo[i].Major_Version := ExtractMajorVersion(SegInfo);
                      IF aMType = xPseudo THEN
                        begin
                          sfi.SegDictInfo[SegIdx].Flipped := Flipped;
                          if Flipped then
                            aMType := xPCodeMost
                          else
                            aMType := xPCodeLeast;
                          sfi.SegDictInfo[SegIdx].MachineType := aMType;
                        end
                      ELSE
                        sfi.SegDictInfo[SegIdx].MachineType := aMType;

                      sfi.SegDictInfo[SegIdx].NewSegType := ExtractNewSegType(seg_misc[i].SegMiscRec);

                      WITH sfi.SegDictInfo[SegIdx], seg_misc[i] DO
                        BEGIN
                          HasLinkInfo := ExtractHasLinkInfo(SegMiscRec);
                          Relocatable := ExtractRelocatable(SegMiscRec);
                        END ;
                      PutFamilyInfo(i);
                    END ; { with Seg_Info[i] }
                end; { with SegDic }
          END ; (* for *)
      END
    ELSE
      { ReadSegDic has already written err msg, so set NextDict to quit }
      SegDic.Dict.next_dict := 0;

  END { MapSofTech } ;

BEGIN { LoadSegmentFile }

  result    := true;    // unless we fail
  SegDicNum := 0 ;
  BlockNum  := 0 ;
  FillChar(sfi, SizeOf(SFI), 0);

  IF ReadSegDic( f, BlockNum, SegDic ) THEN
    BEGIN
      // Look at first segment in file to determine version
      sfi.MajorVersion := ExtractMajorVersion(SegDic.Dict.Seg_Info[0].SegInfo);
      sfi.FileName     := CFILENAME;
      if sfi.MajorVersion = IV then
        BEGIN
          REPEAT
            MapSofTech( SegDic, SegDicNum, BlockNum ) ;
            BlockNum  := SegDic.Dict.Next_Dict ;
            SegDicNum := SUCC( SegDicNum ) ;
          UNTIL BlockNum = 0
        END
      else // if sfi.MajorVersion in [ii, ii_1, iii] then // not SofTech
        MapUCSD( SegDic )
//    else
//      ErrorMessage('Invalid CODE file version {%s} %s.%s', [f.DOSFileName, f.VolumeName, CFileName])
    END ;

  END { LoadSegmentFile } ;

END.
