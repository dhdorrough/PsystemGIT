unit CompilerSymbolsIV;

interface

uses
  Interp_Const, Interp_Decl, Classes;

type
// BASIC COMPILER SYMBOLS, MUST MATCH ORDER IN COMPILER

   TOperator = (
               MUL      {0},
               RDIV     {1},
               ANDOP    {2},
               IDIV     {3},
               IMOD     {4},
               PLUS     {5},
               MINUS    {6},
               OROP     {7},
               LTOP     {8},
               LEOP     {9},
               GEOP     {10},
               GTOP     {11},
               NEOP     {12},
               EQOP     {13},
               INOP     {14},
               NOOP     {15}
   );

   TSYMBOLtypeIV =  (
              IDENT             {0},
              COMMA             {1},
              COLON             {2},
              SEMICOLON         {3},
              LPARENT           {4},
              RPARENT           {5},
              DOSY              {6},
              TOSY              {7},
              DOWNTOSY          {8},
              ENDSY             {9},
              UNTILSY           {10},
              OFSY              {11},
              THENSY            {12},
              ELSESY            {13},
              BECOMES           {14},
              LBRACK            {15},
              RBRACK            {16},
              ARROW             {17},
              PERIOD            {18},
              BEGINSY           {19},
              IFSY              {20},
              CASESY            {21},
              REPEATSY          {22},
              WHILESY           {23},
              FORSY             {24},
              WITHSY            {25},
              GOTOSY            {26},
              LABELSY           {27},
              CONSTSY           {28},
              TYPESY            {29},
              VARSY             {30},
              PROCSY            {31},
              FUNCSY            {32},
              PROGSY            {33},
              FORWARDSY         {34},
              INTCONST          {35},
              REALCONST         {36},
              STRINGCONST       {37},
              NOTSY             {38},
              MULOP             {39},
              ADDOP             {40},
              RELOP             {41},
              SETSY             {42},
              PACKEDSY          {43},
              ARRAYSY           {44},
              RECORDSY          {45},
              FILESY            {46},
              OTHERSY           {47},
              LONGCONST         {48},
              USESSY            {49},
              UNITSY            {50},
              INTERSY           {51},
              IMPLESY           {52},
              EXTERNLSY         {53},
              SEPARATSY         {54}
              );

    TSymbolUnion = packed record
               case integer of
                 0: (O: Pointer);
                 1: (sy: TSYMBOLtypeIV; op: TOperator);
               end;

//  TAlpha    = packed array[0..7] of char;

    TRetnInfo = record
     SYMCUR      : WORD;            { CURSRANGE }
     SY          : TSYMBOLtypeIV;     { needs to be on a word boundary }
     fill0       : byte;
     OP          : TOperator;       { needs to be on a word boundary }
     fill1       : byte;
     RETTOK      : TAlpha;           { needs to be on a word boundary }
    end;

    TRetnInfoPtr = ^TRetnInfo;

    TIDListIV = class(TIDList)
    public
      procedure InitIDs; override;
    end;

implementation

{ TIDListIV }

procedure TIDListIV.InitIDs;

  procedure AddId(const TokenName: string; SymbolType: TSYMBOLtypeIV; OpType: TOperator);
  var
    aObject: TSymbolUnion;
  begin
    aObject.sy := SymbolType;
    aObject.op := OpType;
    AddObject(TokenName, aObject.O);
  end;

begin
  inherited;

  Assert(SizeOf(TSymbolUnion) = 4);

//  AddId('ABSOLUTE',   absolutsy, ttNOOP);   // OK
  AddId('AND     ',   MULOP,      ANDop);  // OK
  AddId('ARRAY   ',   ARRAYSY,    NOOP);   // OK
  AddId('BEGIN   ',   BEGINSY,    NOOP);   // OK
  AddId('CASE    ',   CASESY,     NOOP);   // OK
  AddId('CONST   ',   CONSTSY,    NOOP);   // OK
  AddId('DIV     ',   MULOP,      IDIV);   // OK
  AddId('DO      ',   DOSY,       NOOP);   // OK
  AddId('DOWNTO  ',   DOWNTOSY,   NOOP);   // OK
  AddId('ELSE    ',   ELSESY,     NOOP);   // OK
  AddId('END     ',   ENDSY,      NOOP);   // OK
  AddId('EXTERNAL',   EXTERNLSY,  NOOP);   // OK
  AddId('FILE    ',   FILESY,     NOOP);   // OK
  AddId('FOR     ',   FORSY,      NOOP);   // OK
  AddId('FORWARD ',   FORWARDSY,  NOOP);   // OK
  AddId('FUNCTION',   FUNCSY,     NOOP);   // OK

  AddId('GOTO    ',   GOTOSY,     NOOP);   // OK
  AddId('IF      ',   IFSY,       NOOP);   // OK
  AddId('IMPLEMEN',   IMPLESY,    NOOP);   // OK
  AddId('IN      ',   RELOP,      INOP);   // OK
  AddId('INTERFAC',   INTERSY,    NOOP);   // OK
  AddId('LABEL   ',   LABELSY,    NOOP);   // OK

  AddId('MOD     ',   MULOP,      IMOD);   // OK
  AddId('NOT     ',   NOTSY,      MUL);    // OK
  AddId('OF      ',   OFSY,       NOOP);   // OK
  AddId('OR      ',   ADDOP,      OROP);   // OK

  AddId('PACKED  ',   PACKEDSY,   NOOP);   // OK
  AddId('PROCEDUR',   PROCSY,     NOOP);   // OK
//  AddId('PROCESS ',   PROCESS,    NOOP);
  AddId('PROGRAM ',   PROGSY,     NOOP);   // OK
  AddId('RECORD  ',   RECORDSY,   NOOP);   // OK

  AddId('REPEAT  ',   REPEATSY,   NOOP);   // OK
  AddId('SEGMENT ',   PROGSY,     NOOP);   // OK
  AddId('SEPARATE',   SEPARATSY,  NOOP);   // OK
  AddId('SET     ',   SETSY,      NOOP);   // OK
//  AddId('SHL     ',   mulop,      shlop);
//  AddId('SHR     ',   mulop,      shrop);

  AddId('THEN    ',   THENSY,     NOOP);   // OK
  AddId('TO      ',   TOSY,       NOOP);   // OK
  AddId('TYPE    ',   TYPESY,     NOOP);   // OK
  AddId('UNIT    ',   UNITSY,     NOOP);   // OK

  AddId('UNTIL   ',   UNTILSY,    NOOP);   // OK
  AddId('USES    ',   USESSY,     NOOP);   // OK
  AddId('VAR     ',   VARSY,      NOOP);   // OK
  AddId('WHILE   ',   WHILESY,    NOOP);   // OK

  AddId('WITH    ',   WITHSY,     NOOP);   // OK
//  AddId('XOR     ',   addop,      XOROP);
  Sorted := true;

end;

end.
