// DECOPS: 64 ($40)
// WARNING: This is NOT an official p-Code!
//          This requires that the LONGOPS.CODE unit be libraried into the
//          system of USERLIBed in.
//          Furthermore, it will NOT work on long integer values > 64 bits.
//          ALl of the OpCodes have NOT been implemented!
//
// NOTE:    Delphi stores long words this way:   0, 1, 2, 3  (least significant -> most significant)
//          p-System stores long words this way: 3, 2, 1, 0


procedure TPsystemInterpreter.DECOPS;
const
  WORDSTOSAVE = 5;
  WORDS_PER_INT64 = 4; // Sizeof(Int64) div 2
  MAXUNIONS = 3;
  MAXWORDS = 12;  // MAXUNIONS * (SizeOF(INT64) div 2)

type
  TInt64Words = array[0..WORDS_PER_INT64-1] of word;

  TUnion = record
             case integer of
               1: (int: array[0..MAXUNIONS-1] of Int64);
               2: (arr: array[0..MAXWORDS-1] of word);
             end;
var
  OpCode  : TDecops;
  OpType  : word;
  i       : integer;
  MaxChars    : integer;
  Op1Len, Op2Len, OpResultLen  : integer;
  SavedMSCW: array[0..WORDSTOSAVE-1] of word;
  Operand1, Operand2, OpResult: Tunion;
  NewSize, Addr: word;
  b: boolean;
  Temp: string[255];

  procedure FillHighWords(var Operand: TUnion; LowWordCount: word);
  var
    i: integer;
    GoNegative: boolean;
  begin { FillHighWords }
    if LowWordCount > 0 then
      GoNegative := Operand.arr[LowWordCount-1] = $FFFF  // this is very kludgey
    else
      GoNegative := false;

    for i := LowWordCount to MAXWORDS-1 do
      if GoNegative then
        Operand.arr[i] := $ffff
      else
        Operand.arr[i] := 0;
  end;  { FillHighWords }

  function PopL(nwords: integer): TUnion;
  var
    i: integer;
  begin
    for i := 0 to nwords-1 do
      result.arr[i] := Pop();

    FillHighWords(result, nwords);
  end;

  procedure PushL(nwords: integer; Value: TUnion);
  var
    i: integer;
  begin
    for i := nwords-1 downto 0 do
      push(Value.arr[i]);
  end;

  procedure CheckLen(OpLen: integer);
  begin { CheckLen }
    if OpLen > MAXWORDS then
       begin
         BP := INTOVRC;
         raise EXEQERR.CreateFmt('DECOPS: integer overflow. OpLen = %d words', [OpLen]);
       end;
  end;  { CheckLen }

  function GetOperandLength(Operand: TUnion): integer;
  var
    n: integer;
  begin { GetOperandLength }
    result := 0;
    for n := MAXWORDS-1 downto 0 do
      if Operand.arr[n] <> 0 then
        begin
          result := n + 1;
          exit;
        end;
  end;  { GetOperandLength }

  function LongAdd(const Operand1, Operand2: TUnion): TUnion;
  begin { LongAdd }
    result.Int[0] := Operand1.int[0] + Operand2.int[0];
  end;  { LongAdd }

  function LongSubtract(const Operand1, Operand2: TUnion): TUnion;
  begin { LongSubtract }
    FillHighWords(result, 0);
    result.Int[0] := Operand2.int[0] - Operand1.int[0];
  end;  { LongSubtract }

  function LongMultiply(const Operand1, Operand2: TUnion): TUnion;
  begin { LongMultiply }
    FillHighWords(result, 0);
    result.Int[0] := Operand1.int[0] * Operand2.int[0];
  end;  { LongMultiply }

  function LongDiv(const Operand1, Operand2: TUnion): TUnion;
  begin { LongDiv }
    FillHighWords(result, 0);
    result.Int[0] := Operand1.int[0] div Operand2.int[0];
  end;  { LongDiv }

  procedure GetOperands;
  begin
    Op1Len        := Pop();
    CheckLen(Op1Len);

    Operand1      := PopL(Op1Len);
    Op2Len        := Pop();
    CheckLen(Op2Len);

    Operand2      := PopL(Op2Len);

    FillHighWords(OpResult, 0);
  end;

begin
  Operand1.int[0] := $300020001;  // just testing

  for i := 0 to WORDSTOSAVE-1 do  // save the MSCW from TOS
    SavedMSCW[i] := Pop();

  OpCode := TDecops(POP());

  try
    case OpCode of
      dop_Adjust {0}:
        begin
          NewSize  := Pop();
          CheckLen(NewSize);
          Op1Len   := Pop();
          Operand1 := PopL(Op1Len);
          FillHighWords( Operand1, Op1Len);
          PushL(NewSize, Operand1);
        end;

      dop_Add {2}, dop_Subtract{4}, dop_Multiply{8}, dop_divide{10}:
        begin
          GetOperands;

          case Opcode of
            dop_Add:
              OpResult := LongAdd(Operand1, Operand2);

            dop_Subtract:
              OpResult := LongSubtract(Operand1, Operand2);

            dop_Multiply:
              OpResult := LongMultiply(Operand1, Operand2);

            dop_Divide:
              OpResult := LongDiv(Operand2, Operand1);
          end;

          OpResultLen   := GetOperandLength(OpResult);
          FillHighWords( OpResult, OpResultLen);

          PushL(OpResultLen, OpResult);
          Push(OpResultLen);
        end;

      dop_Compare:
        begin
          OpType := Pop();

          GetOperands;

          OpResult      := LongSubtract(Operand1, Operand2);

          b := false;
          case OpType of
            8: { returns LINT1 < LINT2 }
               b := OpResult.int[0] < 0;

            9: { returns LINT1 <= LINT2 }
               b := OpResult.int[0] <= 0;

            10: { returns LINT1 >= LINT2 }
               b := OpResult.int[0] >=0;

            11: { returns LINT1 > LINT2 }
               b := OpResult.int[0] > 0;

            12: { returns LINT1 <> LINT2 }
               b := OpResult.int[0] <> 0;

            13: { returns LINT1 = LINT2 }
               b := OpResult.int[0] = 0;
          end;

          Push(b);
        end;

      dop_Negate {6}:
        begin 
          Op1Len        := Pop();
          CheckLen(Op1Len);

          Operand1      := PopL(Op1Len);

          Operand1.int[0] := - Operand1.int[0];   // REMINDER: This code won't handle more than 64 bits
          Op1Len        := GetOperandLength(Operand1);

          PushL(Op1Len, Operand1);
          push(Op1Len);
        end;

      dop_LongToString{12}:
        begin
          MaxChars := Pop();        // max length in chars
          Addr     := Pop();        // address to store to
          Op1Len   := Pop();        // nr words in the long integer
          Operand1 := PopL(Op1Len); // get the long integer
          System.Str(Operand1.int[0], Temp);    // convert to a string
          if Length(Temp) > 0 then
            if Length(Temp) <= MaxChars then
              Move(Temp[0], Bytes[Addr], Length(Temp)+1)
            else
              begin
                BP := S2LONGC;
                raise EXEQERR.CreateFmt('DECOPS: string overflow. Needed = %d, Max words = %d', [Length(Temp), MaxChars]);
              end;
        end;

      dop_TosM1ToLong{14}:
        begin
          Op1Len        := Pop();
          CheckLen(Op1Len);

          Operand1        := PopL(Op1Len);

          FillHighWords(Operand2, 0);
          Operand2.int[0] := Pop();
          
          PushL(1, Operand2);      // Push Operand2
          Push(1);                 // and its length

          PushL(Op1Len, Operand1); // Restore Operand1 to TOS
          Push(Op1Len);            // and its length
        end;

      dop_IntToLong{18}:
        push(1);      // set length of integer already on the stack

      dop_longToInt{20}:
        begin
          Untested('Decops_LongToInt');
        end;
    end;

  finally
    // move the MSCW to new location

    for i := WORDSTOSAVE-1 downto 0 do  // restore stuff to TOS
      Push(SavedMSCW[i]);

    MP := SP;
  end;

end;

