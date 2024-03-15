unit pSysExceptions;

interface

uses
  SysUtils;

type
  ESEGBACK  = class(Exception);
  ESEGFAULT = class(Exception);
  ESTKFAULT = class(Exception);
  ES2LONG   = class(Exception);
  ESYSTEMHALT = class(Exception);
  ESTKBACK  = class(Exception);
  ESSTKBACK = class(Exception);
  EOddAddress = class(Exception);
  EOVRFLO     = class(Exception);
//EXEQERR     = class(Exception)
//                ErrCode : integer;
//                Constructor Create(const Msg: string; Args: array of const; AnErrCode: integer); reintroduce;
//              end;
  EXEQERR     = class(Exception);
  EREADERR    = class(Exception);
  EWRITEERR   = class(Exception);
  ENOTIMPLEMENTED = class(Exception);
  EBADFLIP        = class(Exception);

  // Version I.4, I.5, 2.0
  ENOEXIT     = class(Exception);
  EADJFAILURE = class(Exception);
  ENOPROC     = class(Exception);

  EAlreadyExists       = class(Exception);
  EInvalidFileNameType = class(Exception);
  EBadFile             = class(Exception);
  EInvalidDate         = class(Exception);
  EInvalidDirectory    = class(Exception);
  EInvalidBlockNumber  = class(Exception);
  EIOResult            = class(Exception);
  EUnhandledFlip       = class(Exception);
  EFileNotFound        = class(Exception);
  ENilPointer          = class(Exception);
  EUnknownVersion      = class(Exception);
  EUnknownID           = class(Exception);

  ESystemError         = class(Exception);


implementation

{ EXEQERR }

(*
constructor EXEQERR.Create(const Msg: string; Args: array of const; AnErrCode: integer);
begin
  inherited CreateFmt(Msg, Args);
  ErrCode := AnErrCode;
end;
*)

end.
