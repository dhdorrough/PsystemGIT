unit DBDatabase;

interface

uses
  Classes, Interp_Decl, Interp_Const;

type

  TDataBaseInfo = class(TCollectionItem)
  private
    fFilePath: string;
    fTextBackupRootPath: string;
    fVersionNr: TVersionNr;
    function GetTextBackupRootPath: string;
  public
    // ============================================================================================
    procedure Assign(Source: TPersistent); override; // REMEMBER TO UPDATE THIS IF CHANGES ARE MADE
    // ============================================================================================
  published
    property FilePath: string
             read fFilePath
             write fFilePath;
    property VersionNr: TVersionNr            // Version that this database is intended for
             read fVersionNr
             write fVersionNr;
    property TextBackupRootPath: string
             read GetTextBackupRootPath
             write fTextBackupRootPath;
  end;

  TDataBaseList = class(TCollection) { of TDataBaseInfo }
  private
    function GetItem(Index: Integer): TDataBaseInfo;
    procedure SetItem(Index: Integer; Value: TDataBaseInfo);
    function GetpCodesDatabaseFileNameS: TStringList;
  protected
    fpCodesDatabaseFileNameS: TStringList;
  public
    procedure ConstructStringListForVersion(aVersionNr: TVersionNr);
    function GetAccDbFileNumber(const DBFileName: string): integer;
    function GetDataBaseInfoByVersionNr(VersionNr: TVersionNr): TDatabaseInfo;
    Destructor Destroy; override;
    property Items[Index: Integer]: TDataBaseInfo
      read GetItem
      write SetItem; default;
    property XpCodesDatabaseFileNameS: TStringList
             read GetpCodesDatabaseFileNameS;
  end;


implementation

uses MyUtils, SysUtils;

{ TDataBaseInfo }

procedure TDataBaseInfo.Assign(Source: TPersistent);
var
  Src: TDataBaseInfo;
begin
  Src                 := Source as TDataBaseInfo;

  fFilePath           := Src.fFilePath;
//fVersionNumbers     := Src.fVersionNumbers;
  fVersionNr          := Src.fVersionNr;
  fTextBackupRootPath := Src.fTextBackupRootPath;
//fIsActive           := Src.fIsActive;
end;

function TDataBaseInfo.GetTextBackupRootPath: string;
begin
  Result := ForceBackSlash(fTextBackupRootPath);
end;

{ TDataBaseList }

function TDataBaseList.GetAccDbFileNumber(
  const DBFileName: string): integer;
begin
  for result := 0 to fpCodesDatabaseFileNameS.Count - 1 do
    if Sametext(DBFileName, fpCodesDatabaseFileNameS[result]) then
      Exit;
  result := -1;  // default to -1
end;

function TDataBaseList.GetpCodesDatabaseFileNameS: TStringList;
begin
  if not Assigned(fpCodesDatabaseFileNameS) then
    fpCodesDatabaseFileNameS := TStringList.Create;
  result := fpCodesDatabaseFileNameS;
end;

procedure TDatabaseList.ConstructStringListForVersion(aVersionNr: TVersionNr);
var
  i: integer;
//NrFound: integer;
begin
  FreeAndNil(fpCodesDatabaseFileNameS);
  fpCodesDatabaseFileNameS := TStringList.Create;
//NrFound := 0;

  if Count > 0 then
    begin
//    for i := 0 to Count - 1 do
//      with Items[i] do
//        if IsActive and (aVersionNr = VersionNr) then
//          begin
//            fpCodesDatabaseFileNameS.AddObject(FilePath, TObject(fpCodesDatabaseFileNameS.Count));
//            Inc(NrFound);
//          end;

//    if NrFound = 0 then
        for i := 0 to Count - 1 do
          with Items[i] do
            if aVersionNr = VersionNr then  // skip the active test
              begin
                fpCodesDatabaseFileNameS.AddObject(FilePath, TObject(fpCodesDatabaseFileNameS.Count));
//              Inc(NrFound);
              end;
    end;

//if NrFound < 0 then         // We found at least one DB that had correct VersionNr (and which was possibly) active.
//  raise Exception.CreateFmt('No active databases were found for Version %s. Activate a DB for %s in the debugger settings.',
//                            [VersionNrStrings[aVersionNr].Abbrev]);
end;

destructor TDataBaseList.Destroy;
begin
  FreeAndNil(fpCodesDatabaseFileNameS);
  inherited;
end;

function TDataBaseList.GetDataBaseInfoByVersionNr(
  VersionNr: TVersionNr): TDatabaseInfo;
var
  i: integer;
begin
  result := nil;
  for i := 0 to Count-1 do
    if VersionNr = Items[i].fVersionNr then
      begin
        result := Items[i];
        Exit;
      end;
end;

function TDataBaseList.GetItem(Index: Integer): TDataBaseInfo;
begin
  Result := TDataBaseInfo(inherited GetItem(Index));
end;

procedure TDataBaseList.SetItem(Index: Integer; Value: TDataBaseInfo);
begin
  inherited SetItem(Index, Value);
end;

end.
