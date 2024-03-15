unit CRT_Decl;

interface

const
  MAXKEY = #255;

type
  TCRTFuncs = ({0}cf_Unknown,
               { screen items }
               {01}cf_LeadInToScreen,

               {02}cf_MaxRows,
               {03}cf_MaxCols,
               {04}cf_EraseToEndOfScreen,
               {05}cf_EraseToEndOfLine,
               {06}cf_MoveCursorUp,
               {07}cf_MoveCursorRight,
               {08}cf_MoveCursorDown,
               {09}cf_MoveCursorLeft,
//                 cf_DeleteChar,
               {10}cf_EraseScreen,
               {11}cf_EraseLine,
               {12}cf_MoveCursorHome,
               {13}cf_InsertLine,
               {14}cf_GotoXY,
//             cf_NonPrintingCharacter,    // if present, it becomes an escape character which causes problems


               { keyboard items }
               kf_LeadInFromKeyBoard,

               kf_BackSpace, kf_KeyForStop, kf_KeyForBreak,
               kf_KeyForFlush, kf_KeyToEndFile, kf_EditorEscapeKey,
//             kf_KeyToDeleteLine,
               kf_EditorAcceptKey,
               kf_KeyToDeleteCharacter, kf_KeyToMoveCursorLeft,
               kf_KeyToMoveCursorRight, kf_KeyToMoveCursorUp, kf_KeyToMoveCursorDown,
               kf_KeyToMoveToNextWord,  
               kf_PageDown,             kf_PageUp      
               );

  TCrtInfo = class
  public
    TheMaxCols: integer;
    TheMaxRows: integer;
    constructor Create; 
  end;

  TKeyInfo = class
  public
    Constructor Create;
  end;


implementation

{ TCrtInfo }

constructor TCrtInfo.Create;
begin
  TheMaxCols := 80;
  TheMaxRows := 25;
end;

Constructor TKeyInfo.Create;
begin
end;

end.
