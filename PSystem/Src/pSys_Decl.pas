unit pSys_Decl;

interface

uses
  Classes, Graphics, Messages;

type
  String8 = string[8];
  String20 = string[20];

  TStatusProc      = procedure {StatusProc} ( const Msg: string;
                                              DoLog: boolean = true;
                                              DoStatus: boolean = true;
                                              Color: TColor = clBtnFace) of object;
//TStatusColorProc = procedure {Update_Status}(const aCaption: string; aColor: TColor = clBtnFace) of object;

  TWriteCall       = procedure {Write}(const s: string) of object;
  TWriteLnCall     = procedure {WriteLn}(const s: string) of object;

  TWriteCallLen    = procedure {Write}(const s: string; Len: integer) of object;
  TWriteLnCallLen  = procedure {WriteLn}(const s: string; Len: integer) of object;

  TWriteBufCall    = procedure {WriteBuf}(var Buffer; Len: integer) of object;

var
  MessageBuffer: string[255];


implementation

end.
