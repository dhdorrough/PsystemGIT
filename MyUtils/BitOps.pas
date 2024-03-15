unit BitOps;

interface

// Bit operations-
function  Bits(aWord: word; var BitNr: byte; NrBits: byte): word;
function  GetBits(aWord: word; BitNr: byte; NrBits: byte): word;
function  Rol(w: word; NrBits: byte): word;
function  Ror(w: word; NrBits: byte): word;
procedure SetBits(var aWord: word; var BitNr: byte; NrBits: byte; value: word);
function  WordToBinaryString(aWord: word; const Form: string = '0000000000000000'): string;

implementation

//*****************************************************************************
//   Function Name     : Bits
//   Useage            : SubFld := Bits(aWord, BitNr, NrBits)
//   Function Purpose  : Extract a sub field from a word
//   Assumptions       : bits are numbered from Right to Left (15..0)
//   Parameters        : BitNr is the right most bit number
//                       BitNr is incremented by NrBits
//                       NrBits is the width to extract in bits
//                       aWord is the source value
//   Return Value      : The extracted sub-field
//*******************************************************************************}

function  Bits(aWord: word; var BitNr: byte; NrBits: byte): word;
var
  mask: word;
begin
  mask   := (1 shl NrBits) - 1;   // this is a mask that is NrBits wide
  result := (aWord shr BitNr) and Mask;
  BitNr  := BitNr + NrBits;
end;

function GetBits(aWord: word; BitNr: byte; NrBits: byte): word;
var
  mask: word;
begin
  mask   := (1 shl NrBits) - 1;   // this is a mask that is NrBits wide
  result := (aWord shr BitNr) and Mask;
end;


function Ror(w: word; NrBits: byte): word;
ASM
  mov ax,w
  mov cl,NrBits
  Ror ax,cl
end;

function Rol(w: word; NrBits: byte): word;
asm
  mov ax,w
  mov cl,NrBits
  rol ax,cl
end;

//*****************************************************************************
//   Function Name     : SetBits
//   Useage            : SetBits(aWord, BitNr, NrBits, NewValue)
//   Function Purpose  : Set a sub field into a word
//   Assumptions       : bits are numbered from Right to Left (15..0)
//   Parameters        : BitNr is the right most bit number
//                       BitNr is incremented by NrBits
//                       NrBits is the width to set in bits
//                       aWord is the source/dest value
//*******************************************************************************}

procedure SetBits(var aWord: word; var BitNr: byte; NrBits: byte; value: word);
var
  mask, notmask, temp: word;
begin
  mask    := (1 shl NrBits) - 1;   // this is a mask that is NrBits wide
  notmask := NOT mask;             // mask for everything else
  Value   := Value and Mask;       // make sure the value will fit
  temp    := Ror(aWord, BitNr);
  temp    := temp and NotMask; // clean out the field area
  temp    := temp or Value;        // put in the new stuff
  aWord   := Rol(temp, BitNr);     // put it back into place
  BitNr   := BitNr + NrBits;
end;

function WordToBinaryString(aWord: word; const Form: string): string;
var
  i, j: byte;
begin
  result := Form;  // 16 bits
  j      := Length(Form);
  for i := 16 downto 1 do
    begin
      if Form[j] = '0' then
        if Odd(aWord) then
          result[j] := '1'
        else
          result[j] := '0';
      Dec(j);
      aWord := aWord shr 1;
    end;
end;

end.
