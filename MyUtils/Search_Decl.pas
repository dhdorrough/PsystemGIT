unit Search_Decl;

interface

uses
  MyUtils;

type
  TSearchMode = (smUnknown, smASCII, smHex, smVersionNumber, smCRTInfo, smKeyInfo
{$IfDef SegInfo}
                 , smSegments
{$endIf SegInfo}
{$IfDef ProcInfo}
                , smProcedures
{$endIf}
{$IfDef PoolInfo}
                 , smPoolInfo
{$EndIf PoolInfo}
  );

  TSearchInfo = record
                  SearchMode: TSearchMode;
                  NrHexBytes: integer;
                  SearchString: string[79];
                  LowDate: TDateTime;
                  HighDate: TDateTime;
                  DOSTextFilesSearched: integer;
                  pSystemTextFilesSearched: integer;
                  MatchesFound: integer;
                  FoldersSearched: integer;
                  VolumesSearched: integer;
                  NumberOfErrors: integer;
                  KeyWordSearch: boolean;
                  WildCardSearch: boolean;
                  Case_Sensitive: boolean;
                  IgnoreUnderScores: boolean;
                  HexBytes: THexBytes;
                  LogMountingErrors: boolean;
                  OnlySearchFileNames: boolean;
                  AllKeyWords: boolean;
                  AnyKeyWords: boolean;
                  Abort: boolean;
                end;

  TSearchInfoPtr = ^TSearchInfo;

var
  SearchModeNames: array[TSearchMode] of string =
    (
    {smUnknown}       'Unknown',
    {smASCII}         'ASCII strings',
    {smHex}           'Hex strings',
    {smVersionNumber} 'Version Number',
    {smCRTInfo}       'CRT Info',
    {smKeyInfo}       'KEY Info'
{$IfDef SegInfo}
    {smSegments}      , 'Segment'
{$endIf}
{$IfDEf ProcInfo}
    {smProcInfo}      , 'Procedure'
{$EndIf ProcInfo}
{$IfDef PoolInfo}
    {smPoolInfo}      ,'Pool Info'
{$endIf PoolInfo}
    );

function LineContainsTarget(const SearchInfo: TSearchInfo; SearchLine: string): boolean;

implementation

uses SysUtils;

function LineContainsTarget(const SearchInfo: TSearchInfo; SearchLine: string): boolean;
var
  i: integer;
begin
  with SearchInfo do
    begin
      if SearchInfo.IgnoreUnderScores and (Pos('_', SearchLine) > 0) then
        begin
          i := Length(SearchLine);
          while i > 0 do
            begin
              if SearchLine[i] = '_' then
                Delete(SearchLine, i, 1);
              i := i - 1;
            end;
        end;

      if SearchInfo.KeyWordSearch then
        result := ContainsWords( SearchInfo.SearchString,
                                 SearchLine,
                                 true,      // MatchWholeWordsOnly: boolean
                                 SearchInfo.AllKeyWords,      // MustContainAll: boolean
                                 SearchInfo.Case_Sensitive) else
      if SearchInfo.WildCardSearch then
        result := Wild_Match(    pchar(SearchLine),
                                 @SearchInfo.SearchString[1],
                                 '*', '?',
                                 SearchInfo.Case_Sensitive)
      else
        begin
          if not SearchInfo.Case_Sensitive then
            SearchLine := UpperCase(SearchLine);
          result := pos(SearchInfo.SearchString, SearchLine) > 0;
        end;
    end;
end;

end.
