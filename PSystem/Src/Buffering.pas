unit Buffering;

interface

const
  BUFFERLEN = 16;   // Must be a multiple of 2

var
  Buffer: Packed array[0..BUFFERLEN-1] of char;

  InputIdx, OutputIdx: integer;
  InputCount, OutPutCount: longint;

procedure ClearBuffer;
function PutIntoBuffer(ch: char): boolean;
function TakeFromBuffer(var ch: char): boolean;

implementation

procedure ClearBuffer;
begin
  InputCount := 0;
  OutputCount := 0;
end;


function PutIntoBuffer(ch: char): boolean;
begin
  result := false;
  // Is there room to put something into the buffer?
  if (InputCount >= OutputCount) and ((InputCount - OutputCount) < BUFFERLEN) then
    begin
      InputIdx := InputCount and $F;    // Effectively: InputCount MOD BUFFERLEN
      Buffer[InputIdx] := ch;
      Inc(InputCount);
      result := true;  // succeeded
    end;
end;

function TakeFromBuffer(var ch: char): boolean;
begin
  result := false;
  // IOs there anything in the buffer?
  if (InputCount > OutputCount) then
    begin
      OutputIdx := OutputCount and $F;    // effectively: OutputCount mod BUFFERLEN
      ch        := Buffer[OutputIdx];
      Inc(OutputCount);
      result := true;
    end;
end;

end.
