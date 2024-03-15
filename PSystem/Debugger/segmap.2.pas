  
(* included from segmap.1.text*)
  
PROCEDURE Map
  ( VAR f       : Phyle ) ;

  VAR
    SegDic      : SegDicRec ;
    SegDicNum   : INTEGER ;
    BlockNum    : INTEGER ;
  
  
  FUNCTION ReadSegDic
    ( VAR f     : PHYLE ;
          Block : INTEGER ;
      VAR SegDic: SegDicRec ) 
    : BOOLEAN ;

  
    FUNCTION ItIsFlipped
      (     SegDic  : SegDict )
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
      
      IF SegDic.Sex IN [ Flipped, NotFlipped ] THEN BEGIN
        IF SegDic.Sex = Flipped THEN 
          ItIsFlipped := TRUE
        ELSE
          ItIsFlipped := FALSE
        END
      ELSE BEGIN
        Temp := TRUE ; { assume it to be flipped }
        WITH SegDic DO BEGIN
          FOR i := 0 TO MaxDicSeg DO 
            IF ( DiskInfo[i].CodeAddr = 1 ) OR
               ( SegText[i]           = 1 ) THEN
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
        
  
      FUNCTION FlipIt
        (     Num     : INTEGER ) 
        : INTEGER ;
      
        VAR
          a, b  : PACKED ARRAY [0..1] OF 0..255 ;
          
      BEGIN { FlipIt }
        
        MOVELEFT( Num, a[0], 2 ) ;
        b[0] := a[1] ;
        b[1] := a[0] ;
        MOVELEFT( b[0], Num, 2 ) ;
        FlipIt := Num
        
        END { FlipIt } ;
  
  
    BEGIN { FlipSegDic }
      
      IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
        WITH SegDic, Dict DO BEGIN
          FOR i := 0 TO MaxDicSeg DO BEGIN
            { first the easy part... }
            WITH DiskInfo[i] DO BEGIN
              CodeAddr := FlipIt( CodeAddr ) ;
              CodeLeng := FlipIt( CodeLeng ) 
              END ; { with DiskInfo }
            SegText[i] := FlipIt( SegText[i] ) ;
            { and now all the messy junk... }
            MOVELEFT( SegMisc.SegType[i], Transfer, 2 ) ;
            Transfer := FlipIt( Transfer ) ;
            MOVELEFT( Transfer, SegMisc.SegType[i], 2 ) ;
            MOVELEFT( SegInfo[i], Transfer, 2 ) ;
            Transfer := FlipIt( Transfer ) ;
            MOVELEFT( Transfer, SegInfo[i], 2 ) ;
            IF SegInfo[i].MajorVersion > III THEN BEGIN
              IF SegMisc.xSegMisc[I].SegType IN [ xUnitSeg, ProgSeg ] THEN BEGIN
                WITH SegFamily[i] DO BEGIN
                  DataSize  := FlipIt( DataSize ) ;
                  SegRefs   := FlipIt( SegRefs ) ;
                  MaxSegNum := FlipIt( MaxSegNum ) ;
                  TextSize  := FlipIt( TextSize ) 
                  END ; { with segfamily }

                END ; { if }
              END ; { if }
            END ; { for }
          IF SegInfo[0].MajorVersion > III THEN BEGIN
            NextDict := FlipIt( NextDict ) ;
            { in an ideal world we'd leave Sex unflipped, but this thing is, }
            { as I said, quick and dirty so we need to go ahead and flip it. }
            Sex := FlipIt( Sex )
            END { if }
          ELSE BEGIN
            MOVELEFT( IntSegSet, XfrArray[0], SIZEOF(IntSegSet) ) ;
            FOR i := 0 TO 3 DO
              XfrArray[i] := FlipIt( XfrArray[i] ) ;
            MOVELEFT( XfrArray[0], IntSegSet, SIZEOF(IntSegSet) ) ;
            END ; { else }
          END ; { with segdic.dict }
        END { if }
      
      END { FlipSegDic } ;
      
      
  BEGIN { ReadSegDic }

    {$I-}
    IF (BLOCKREAD(f, SegDic.Dict, 1, Block) = 1) AND (IORESULT = 0) THEN BEGIN
    {$I+}
      IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
        SegDic.Flipped := TRUE ;
        FlipSegDic( SegDic )
        END 
      ELSE BEGIN
        SegDic.Flipped := FALSE ;
        END ;
      IF Block = 0 THEN BEGIN { only recheck gender in first seg of dictionary }
        IF ItIsFlipped( SegDic.Dict ) THEN BEGIN
          CrtControl( ClrToEoS ) ;
          WRITE( 'Unable to determine gender of ', CFileName ) ;
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
      CrtControl( ClrToEoS ) ;
      WRITE( 'Error reading segment dictionary of ', CFileName ) ;
      ReadSegDic := FALSE
      END 
    
    END { ReadSegDic } ;
    
    
  PROCEDURE MapUCSD 
    (     SegDic : SegDicRec ) ;
    
    VAR
      i                 : INTEGER ;
      j                 : SegRange ;
      IntrinsNeeded     : BOOLEAN ;
  
  BEGIN { MapUCSD }
    
    IntrinsNeeded := FALSE ;
    
    WRITE( o, '  #  Name      Addr    Len  ' ) ;
    WRITE( o, 'Version   Machine  Kind                ' ) ;
    WRITE( o, 'Seg   Text' ) ;
    WRITELN( o ) ;
    
    WITH SegDic, Dict DO BEGIN
      
      FOR i := 0 TO MaxDicSeg DO BEGIN
        WRITE( o, i:3 ) ;
        IF SegDic.Dict.DiskInfo[i].CodeLeng <> 0 THEN BEGIN
          WRITE( o, '  ', SegName[i] ) ;
          WITH DiskInfo[i] DO BEGIN
            WRITE( o, CodeAddr:6 ) ;
            WRITE( o, CodeLeng DIV 2:7 ) ;
            END ;
          WITH SegInfo[i] DO BEGIN
            WRITE( o, '  ' ) ;
            CASE MajorVersion OF 
              Unknown  : WRITE( o, 'Volition' ) ;
              II       : WRITE( o, 'II.0    ' ) ;
              II_1     : WRITE( o, 'II.1    ' ) ;
              III      : WRITE( o, 'III.0   ' )
              END ; { case }
            IF MajorVersion <> Unknown THEN BEGIN
              WRITE( o, '  ' ) ;
              CASE MType OF
                UnDefined  : WRITE( o, 'Unknown' ) ;
                PCodeMost  : WRITE( o, 'PCode+ ' ) ;
                PCodeLeast : WRITE( o, 'PCode- ' ) ;
                PDP11      : WRITE( o, 'PDP-11 ' ) ;
                M8080      : WRITE( o, '8080   ' ) ;
                Z80        : WRITE( o, 'Z80    ' ) ;
                GA440      : WRITE( o, 'GA440  ' ) ;
                M6502      : WRITE( o, '6502   ' ) ;
                M6800      : WRITE( o, '6800   ' ) ;
                TI990      : WRITE( o, 'TI990  ' ) ;
                END ; { case }
              WRITE( o, '  ' ) ;
              CASE SegMisc.SegType[i] OF
                Linked           : WRITE( o, 'Linked excutable  ' ) ;
                HostSeg          : WRITE( o, 'Unlinked host     ' ) ;
                SegProc          : WRITE( o, 'Segment procedure ' ) ;
                UnitSeg          : WRITE( o, 'Regular unit      ' ) ;
                SeprtSeg         : WRITE( o, 'Separate procedure' ) ;
                Unlinked_Intrins : WRITE( o, 'Unlinked intrinsic' ) ;
                Linked_Intrinsic : WRITE( o, 'Linked intrinsic  ' ) ;
                DataSeg          : WRITE( o, 'Data segment      ' ) ;
                END ; { case }
              WRITE( o, '  ' ) ;
              WRITE( o, SegNum:3, ' ' ) ;
              WRITE( o, '  ' ) ;
              IF SegMisc.SegType[i] IN
                 [ UnitSeg, UnLinkedIntrins, LinkedIntrins ] THEN
                WRITE( o, SegText[i]:4 ) ;
              END ; { if majorversion <> volition }
            END ; { with seginfo }
          END ; { if }
        WRITELN( o ) ;
        END ; { for }
      
      WRITE( o, 'Intrinsic segments required: ' ) ;
      FOR i := 0 TO MaxSeg DO BEGIN
        IF i IN IntSegSet THEN BEGIN
          WRITE( o, i:3 ) ;
          IntrinsNeeded := TRUE
          END ; { if }
        END ; { for }
      IF IntrinsNeeded = FALSE THEN
        WRITE( o, ' None' ) ;
      WRITELN( o ) 
      
      END ; { with segdic, dict }
      
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

  
    PROCEDURE PutFamilyInfo 
      (     Index : INTEGER ) ;
    
    { uses SegDic and the file o globally }
    
    BEGIN { PutFamilyInfo }
      
      WITH SegDic, Dict, SegFamily[Index] DO BEGIN
        CASE SegMisc.xSegMisc[Index].SegType OF
          xUnitSeg, ProgSeg: BEGIN
            WRITE( o, ' ' ) ;
            WRITE( o, DataSize:5 ) ;
            WRITE( o, ' ' ) ;
            WRITE( o, SegRefs:5 ) ;
            WRITE( o, ' ' ) ;
            WRITE( o, MaxSegNum:5 ) ;
            IF SegMisc.xSegMisc[Index].SegType = xUnitSeg THEN BEGIN
              WRITE( o, ' ' ) ;
              WRITE( o, SegText[Index]:5 ) ;
              WRITE( o, ' ' ) ;
              WRITE( o, TextSize:5 ) ;
              END
            ELSE
              WRITE( o, '':12 ) ;
            END ;
          xSeprtSeg, ProcSeg: BEGIN
            WRITE( o, ' ' ) ;
            WRITE( o, '':11, ProgName ) ;
            END ;
          NoSeg: BEGIN
            END ;
          END ; { case }
        END

      END { PutFamilyInfo } ;
      
      
    PROCEDURE PutOtherInfo ;
    
    { uses SegDic, output file o globally }
    
      VAR
        i       : INTEGER ;
        
    BEGIN { PutOtherInfo }
      
      WITH SegDic, Dict DO BEGIN
        WRITE( o, 'pCode version ' ) ;
        CASE SegInfo[0].MajorVersion OF 
          Unknown     : WRITE( o, 'unknown' ) ;
          II,II_1,III : WRITE( o, '<<bad>>' ) ;
          IV          : WRITE( o, 'IV' ) ;
          V,VI,VII    : WRITE( o, 'unknown' ) ;
          END ; { case }
        WRITE( o, '.  ' ) ;
        IF NextDict = 0 THEN
          WRITELN( o, 'Last dictionary segment in chain.' ) 
        ELSE
          WRITELN( o, 'Next dictionary segment is at block #', NextDict, '.' ) ;
        WRITELN( o, '[', CopyNote, ']' ) 
        END ;
      IF TooBig THEN BEGIN
        WRITE( o, '*** ERROR: The following segments are too large: ' ) ;
        FOR i := 0 TO MaxDicSeg DO 
          IF i IN BadSegs THEN
            WRITE( o, i, ' ' ) ;
        WRITELN( o )
        END 
      
      END { PutOtherInfo } ;
      
      
  BEGIN { MapSofTech }
    
    BadSegs := [] ;
    TooBig  := FALSE ;
      
    IF ReadSegDic( f, BlockNum, SegDic ) THEN BEGIN
      WRITE  ( o, ', segment dictionary record #', SegDicNum ) ;
      WRITELN( o, ',  block #', BlockNum ) ;
      WRITE( o, 'Seg Name      Addr    Len  Mach.  Kind    ' ) ;
      WRITE( o, 'Lnk Rel ' ) ;
      WRITE( o, ' Data  Refs MxSeg TxAdr TxLen' ) ;
      WRITELN( o ) ;
      FOR i := 0 TO MaxDicSeg DO BEGIN
        WRITE( o, i:3 ) ;
        IF SegDic.Dict.DiskInfo[i].CodeLeng <> 0 THEN WITH SegDic, Dict DO BEGIN
          WRITE( o, ' ', SegName[i] ) ;
          WITH DiskInfo[i] DO BEGIN
            WRITE( o, CodeAddr:6 ) ; 
            WRITE( o, CodeLeng:7 ) ;
            IF CodeLeng > 8191 THEN BEGIN
              BadSegs := BadSegs + [ i ] ;
              TooBig  := TRUE
              END
            END ;
          WITH SegInfo[i] DO BEGIN
            WRITE( o, '  ' ) ;
            IF ORD(MType) = xPsuedo THEN BEGIN
              WRITE( o, 'pCode' ) ;
              IF Flipped THEN 
                WRITE( o, '~' )
              ELSE
                WRITE( o, ' ' )
              END
            ELSE CASE ORD(MType) OF
              x6809 : WRITE( o, '6809  ' ) ;
              xPDP11: WRITE( o, 'PDP11 ' ) ;
              x8080 : WRITE( o, '8080  ' ) ;
              xZ80  : WRITE( o, 'Z80   ' ) ;
              xGA440: WRITE( o, 'GA440 ' ) ;
              x6502 : WRITE( o, '6502  ' ) ;
              x6800 : WRITE( o, '6800  ' ) ;
              x9900 : WRITE( o, '9900  ' ) ;
              x8086 : WRITE( o, '8086  ' ) ;
              xZ8000: WRITE( o, 'Z8000 ' ) ;
              x68000: WRITE( o, '68000 ' ) ;
              END ; { case }
            WRITE( o, ' ' ) ;
            CASE SegMisc.xSegMisc[i].SegType OF
              NoSeg     : WRITE( o, '<empty> ' ) ;
              ProgSeg   : WRITE( o, 'Program ' ) ;
              xUnitSeg  : WRITE( o, 'Unit    ' ) ;
              ProcSeg   : WRITE( o, 'Segment ' ) ;
              xSeprtSeg : WRITE( o, 'Separate' ) ;
              END ; { case }
            END ; { with seginfo }
          WRITE( o, ' ' ) ;
          WITH SegMisc, xSegMisc[i] DO BEGIN
            IF HasLinkInfo THEN
              WRITE( o, ' T' )
            ELSE
              WRITE( o, ' F' ) ;
            WRITE( o, ' ' ) ;
            IF Relocatable THEN
              WRITE( o, '  T' )
            ELSE
              WRITE( o, '  F' ) ;
            END ;
          PutFamilyInfo( i ) ;
          END ; (* if, with segdic *)
        WRITELN( o ) ;
        END ; (* for *)
      PutOtherInfo ;
      END
    ELSE BEGIN
      { ReadSegDic has already written err msg, so set NextDict to quit }
      SegDic.Dict.NextDict := 0
      END ;
    
    END { MapSofTech } ;
    

BEGIN { Map }

  SegDicNum := 0 ;
  BlockNum  := 0 ;
  
  IF ReadSegDic( f, BlockNum, SegDic ) THEN BEGIN
    IF SegDic.Dict.SegInfo[0].MajorVersion < IV THEN BEGIN
      IF ConsoleOutput THEN
        CrtControl( ClrToEoS ) 
      ELSE
        Page( o ) ;
      WRITELN( o ) ;
      WRITELN( o, 'File: ', CFileName ) ;
      MapUCSD( SegDic )
      END 
    ELSE BEGIN
      REPEAT
        IF ConsoleOutput THEN
          CrtControl( ClrToEoS ) 
        ELSE 
          Page( o ) ;
        WRITELN( o ) ;
        WRITE( o, 'File: ', CFileName ) ;
        MapSofTech( SegDic, SegDicNum, BlockNum ) ;
        BlockNum  := SegDic.Dict.NextDict ;
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
 
 
 BEGIN
   
   Initialize ;
   WHILE Menu = TRUE DO 
     Map( f ) ;
   CleanUp
 
   END.
