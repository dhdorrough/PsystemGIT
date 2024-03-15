unit pSys_Const;

interface

const       
  CSVOL = '.SVOL';
  CVOL  = '.VOL';
  CTXT  = '.TXT';
  CPAS  = '.PAS';
  CLIS  = '.LIS';
  CEXT  = '.C';
  HEXT  = '.H';

  VIDLENG         = 7;  {NUMBER OF CHARS IN A VOLUME ID}
  TIDLENG         = 15; {NUMBER OR CHARS IN A TITLE ID}
  MAXDIR          = 77;  {MAX NUMBER OF ENTRIES IN A Directory}
  BLOCKSIZE       = 512;
  DIRECTORYBLOCKS = 4;
  DIRECTORYBYTES  = DIRECTORYBLOCKS * BLOCKSIZE;
  DIRECTORY_BLOCKNR = 2;
  BACKUP_DIRECTORY_BLOCKNR = 6;
  PAGE_SIZE       = 2;  // TEXT files always have a two block header area
  PAGE_BYTES      = BLOCKSIZE * PAGE_SIZE;
  TEXT_HEADER_BLOCKS = PAGE_SIZE;
  BUFSIZ          = 1024;
  LINEMAX         = 255;

  kUNTYPEDFILE = 0;
  kXDSKFILE = 1;
  kCODEFILE = 2;
  kTEXTFILE = 3;
  kINFOFILE = 4;
  kDATAFILE = 5;
  kGRAFFILE = 6;
  kFOTOFILE = 7;
  kSECUREDIR = 8;
  kSVOLFILE  = 9;

implementation

end.
