// DECOPS: 64 ($40)
// WARNING: This is NOT an official p-Code!
//          This requires that the LONGOPS.CODE unit be libraried into the
//          system or USERLIBed in.
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
  SIGNSPACE = 1;  // Add an extra word for the sign

type
  TLongInt = record
//           OpIsNegative: boolean;  // This would be nice but causes compiler to do mysterious things
             case integer of
               1: (int: array[0..MAXUNIONS-1] of Int64);
               2: (arr: array[0..MAXWORDS-1] of word);
               3: (intwords: array[0..MAXWORDS-1] of integer);
             end;
var
  OpCode  : TDecops;
  OpType  : word;
  i       : integer;
  MaxChars    : integer;
  Op1Len, Op2Len, OpResultLen  : integer;
  Op1IsNegative, Op2IsNegative, OpResultIsNegative: boolean;
  SavedMSCW: array[0..WORDSTOSAVE-1] of word;
  Operand1, Operand2, OpResult: TLongInt;
  NewSize, Addr: word;
  b: boolean;
  Temp: string[255];

  procedure ZeroHighWords(var Operand: TLongInt; LowWordCount: word);
  var
    i: integer;
  begin { ZeroHighWords }
    for i := LowWordCount to MAXWORDS-1 do
      Operand.arr[i] := 0;
  end;  { ZeroHighWords }

  procedure ZeroOperand(var Operand: TLongInt; var OpIsNegative: boolean);
  var
    i: integer;
  begin
    OpIsNegative := false;
    for i := 0 to MAXUNIONS-1 do
      Operand.int[i] := 0;
  end;

  function PopL(nwords: integer; var OpIsNegative: boolean): TLongInt;
  var
    i: integer;
  begin
    ZeroOperand(result, OpIsNegative);

    OpIsNegative := Boolean(Pop());     // OpIsNegative always precedes
    nWords := nWords - SIGNSPACE;       // One word is used to store the sign

    for i := 0 to nwords-1 do
      result.arr[i] := Pop();

//  ZeroHighWords(result, nwords);

    if OpIsNegative then         // this is actually negative number
      begin
        result.int[0] := - result.int[0];  // convert to a real negative number
        OpIsNegative := false;
      end;
  end;

  procedure PushL(nwords: integer; Value: TLongInt; OpIsNegative: boolean);
  var
    i: integer;
  begin
    if Value.int[0] < 0 then
      begin
        Value.int[0] := - Value.int[0]; // convert to positive for store
        OpIsNegative := true;  // but mark it as a negative number
      end;

    for i := nwords-1 downto 0 do
      push(Value.arr[i]);

    push(OpIsNegative);    // remember what sign it is
    push(NWords+SIGNSPACE);        // and set the length in words (including sign)
  end;

  procedure CheckLen(OpLen: integer);
  begin { CheckLen }
    if OpLen > MAXWORDS then
       begin
         BP := INTOVRC;
         raise EXEQERR.CreateFmt('DECOPS: integer overflow. OpLen = %d words', [OpLen]);
       end;
  end;  { CheckLen }

  function GetOperandLength(Operand: TLongInt): integer;
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

  function LongAdd(const Operand1, Operand2: TLongInt): TLongInt;
  begin { LongAdd }
    ZeroHighWords(result, 0);
    result.Int[0] := Operand1.int[0] + Operand2.int[0];
  end;  { LongAdd }

  function LongSubtract(const Operand1, Operand2: TLongInt): TLongInt;
  begin { LongSubtract }
    ZeroHighWords(result, 0);
    result.Int[0] := Operand2.int[0] - Operand1.int[0];
  end;  { LongSubtract }

  function LongMultiply(const Operand1, Operand2: TLongInt): TLongInt;
  begin { LongMultiply }
    ZeroHighWords(result, 0);
    result.Int[0] := Operand1.int[0] * Operand2.int[0];
  end;  { LongMultiply }

  function LongDiv(const Operand1, Operand2: TLongInt): TLongInt;
  begin { LongDiv }
    ZeroHighWords(result, 0);
    result.Int[0] := Operand1.int[0] div Operand2.int[0];
  end;  { LongDiv }

  procedure GetOperands;
  begin
    Op1Len        := Pop();
    CheckLen(Op1Len);

    Operand1      := PopL(Op1Len, Op1IsNegative);
    Op2Len        := Pop();
    CheckLen(Op2Len);

    Operand2      := PopL(Op2Len, Op2IsNegative);

    ZeroHighWords(OpResult, 0);   // default result to 0
  end;

begin
  Operand1.int[0] := $0004000300020001;  // just testing
  Operand1.int[1] := $0008000700060005;
  Operand1.int[2] := $000C000B000A0009;

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
          Operand1 := PopL(Op1Len, Op1IsNegative);
//        ZeroHighWords( Operand1, Op1Len);
          PushL(NewSize, Operand1, Op1IsNegative);
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

          OpResultLen        := GetOperandLength(OpResult);
          OpResultIsNegative := Opresult.int[0] < 0;

          PushL(OpResultLen, OpResult, OpResultIsNegative);
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

          Operand1      := PopL(Op1Len, Op1IsNegative);

          Op1Len        := GetOperandLength(Operand1);

          PushL(Op1Len, Operand1, not Op1IsNegative);  // put it back with opposite sign
        end;

      dop_LongToString{12}:
        begin
          MaxChars := Pop();        // max length in chars
          Addr     := Pop();        // address to store to
          Op1Len   := Pop();        // nr words in the long integer
          Operand1 := PopL(Op1Len, Op1IsNegative); // get the long integer
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

          Operand1        := PopL(Op1Len, Op1IsNegative);

          ZeroHighWords(Operand2, 0);
          Operand2.int[0] := Pop();
          
          PushL(1, Operand2, Op2IsNegative);      // Push Operand2
          PushL(Op1Len, Operand1, Op1IsNegative); // Restore Operand1 to TOS
        end;

      dop_IntToLong{18}:    // get the parameters
        begin
          ZeroOperand(Operand1, Op1IsNegative);

          Pop(i);          // get the number as 16 bit int
          Operand1.int[0] := i;    // convert to a 64 bit integer
          Op1IsNegative := Operand1.int[0] < 0;  // save the sign
          PushL(1, Operand1, Op1IsNegative); // put it back as a longint
        end;

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

