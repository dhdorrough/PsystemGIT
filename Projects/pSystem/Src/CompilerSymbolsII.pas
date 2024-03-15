unit CompilerSymbolsII;

interface

uses
  Interp_Const, Interp_Decl;

type
// BASIC COMPILER SYMBOLS, MUST MATCH ORDER IN COMPILER

   TSYMBOLTypeII = ({00}IDENT,    {01}COMMA,   {02}COLON,    {03}SEMICOLON,{04}LPARENT,  {05}RPARENT,    {06}DOSY,    {07}TOSY,
                    {08}DOWNTOSY, {09}ENDSY,   {10}UNTILSY,  {11}OFSY,     {12}THENSY,   {13}ELSESY,     {14}BECOMES, {15}LBRACK,
                    {16}RBRACK,   {17}ARROW,   {18}PERIOD,   {19}BEGINSY,  {20}IFSY,     {21}CASESY,     {22}REPEATSY,{23}WHILESY,
                    {24}FORSY,    {25}WITHSY,  {26}GOTOSY,   {27}LABELSY,  {28}CONSTSY,  {29}TYPESY,     {30}VARSY,   {31}PROCSY,
                    {32}FUNCSY,   {33}PROGSY,  {34}FORWARDSY,{35}INTCONST, {36}REALCONST,{37}STRINGCONST,{38}NOTSY,   {39}MULOP,
                    {40}ADDOP,    {41}RELOP,   {42}SETSY,    {43}PACKEDSY, {44}ARRAYSY,  {45}RECORDSY,   {46}FILESY,  {47}OTHERSY,
                    {48}LONGCONST,{49}USESSY,  {50}UNITSY,   {51}INTERFCESY,{52}IMPLESY, {53}EXTERNLSY,  {54}SEPARATSY);

  TOPERATOR = ({00}MUL,
               {01}RDIV,
               {02}ANDOP,
               {03}IDIV,
               {04}IMOD,
               {05}PLUS,
               {06}MINUS,
               {07}OROP,
               {08}LTOP,
               {09}LEOP,
               {10}GEOP,
               {11}GTOP,
               {12}NEOP,
               {13}EQOP,
               {14}INOP,
               {15}NOOP,
               {16}shlop,
               {17}shrop,
               {18}xorop); {/pc157d}


    TSymbolUnion = packed record
               case integer of
                 0: (O: Pointer);
                 1: (sy: TSYMBOLTypeII; op: TOperator);
               end;

(*
    TRetnInfo = record
     SYMCUR      : integer;            { CURSRANGE }
     SY          : TSYMBOLTypeII;      { @ 3 needs to be on a word boundary }
     fill0       : byte;
     OP          : TOperator;          { @ 4 needs to be on a word boundary }
     fill1       : byte;
     RETTOK      : TAlpha;             { @ 5 needs to be on a word boundary }
    end;
*)

    TRetnInfo = record
     SYMCUR      : integer;            { CURSRANGE }
     SY          : word;     { needs to be on a word boundary }
     OP          : word;       { needs to be on a word boundary }
     RETTOK      : TAlpha;           { needs to be on a word boundary }
    end;

    TRetnInfoPtr = ^TRetnInfo;

    TIDListII = class(TIDList)
    public
      procedure InitIDs; override;
    end;

implementation

{ TIDListII }

procedure TIDListII.InitIds;

  procedure AddId(const TokenName: string; SymbolType: TSYMBOLTypeII; OpType: TOperator);
  var
    aObject: TSymbolUnion;
  begin
    aObject.sy := SymbolType;
    aObject.op := OpType;
    AddObject(TokenName, aObject.O);
  end;

begin
  AddID('AND     ',  MULOP,       ANDop);
  AddID('ARRAY   ',  ARRAYSY,     NOOP);
  AddID('BEGIN   ',  BEGINSY,     NOOP);
  AddID('CASE    ',  CASESY,      NOOP);
  AddID('CONST   ',  CONSTSY,     NOOP);
  AddID('DIV     ',  MULOP,       IDIV);
  AddID('DO      ',  DOSY,        NOOP);
  AddID('DOWNTO  ',  DOWNTOSY,    NOOP);
  AddID('ELSE    ',  ELSESY,      NOOP);
  AddID('END     ',  ENDSY,       NOOP);
  AddID('EXTERNAL',  EXTERNLSY,    NOOP);
  AddID('FILE    ',  FILESY,       NOOP);
  AddID('FOR     ',  FORSY,        NOOP);
  AddID('FORWARD ',  FORWARDSY,    NOOP);
  AddID('FUNCTION',  FUNCSY,       NOOP);

  AddID('GOTO    ',  GOTOSY,       NOOP);
  AddID('IF      ',  IFSY,         NOOP);
  AddID('IMPLEMEN',  IMPLESY,      NOOP);
  AddID('IN      ',  RELOP,        INOP);
  AddID('INTERFAC',  INTERFCESY,   NOOP);
  AddID('LABEL   ',  LABELSY,      NOOP);

  AddID('MOD     ',  MULOP,        IMOD);
  AddID('NOT     ',  NOTSY,        MUL);
  AddID('OF      ',  OFSY,         NOOP);
  AddID('OR      ',  ADDOP,        OROP);

  AddID('PACKED  ',  PACKEDSY,     NOOP);
  AddID('PROCEDUR',  PROCSY,       NOOP);
  AddID('PROGRAM ',  PROGSY,       NOOP);
  AddID('RECORD  ',  RECORDSY,     NOOP);

  AddID('REPEAT  ',  REPEATSY,     NOOP);
  AddID('SEGMENT ',  PROGSY,       NOOP);
  AddID('SEPARATE',  SEPARATSY,    NOOP);
  AddID('SET     ',  SETSY,        NOOP);
  AddID('SHL     ',  mulop,        shlop);{/pc157d}
  AddID('SHR     ',  mulop,        shrop);{/pc157d}

  AddID('THEN    ',  THENSY,       NOOP);
  AddID('TO      ',  TOSY,         NOOP);
  AddID('TYPE    ',  TYPESY,       NOOP);
  AddID('UNIT    ',  UNITSY,       NOOP);

  AddID('UNTIL   ',  UNTILSY,      NOOP);
  AddID('USES    ',  USESSY,       NOOP);
  AddID('VAR     ',  VARSY,        NOOP);
  AddID('WHILE   ',  WHILESY,      NOOP);

  AddID('WITH    ',  WITHSY,       NOOP);
  AddID('XOR     ',  addop,        xorop);

  Sorted := true;
end;

end.
