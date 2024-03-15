unit SysCommon;

interface

uses
  Interp_Const, Interp_Decl, UCSDGlbu, UCSDGlob;

type  
  TInbuf = record
             case integer of
               0: (BufB: packed array[0..BLOCKSIZE] of byte);
               1: (BufW: array [0..BLOCKSIZE div 2] of word);
               2: (sysII: TIISysComRec);
           end;

  TInBufPtr = ^TInBuf;

implementation

end.
 