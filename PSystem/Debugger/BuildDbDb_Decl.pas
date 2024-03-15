unit BuildDbDb_Decl;

interface

uses
  Classes, ListingUtils, Watch_Decl;

type
  integer = SmallInt;
  
  TAlpha8 = string[8];

  TProcedureInfoList = class(TStringList)
  end;

  TSegmentInfo = class(TObject)
    SegmentNumber: integer;
    SegmentType: TType_of_Symbol;
    Procedures: TProcedureInfoList;
  public
    constructor Create;
    Destructor Destroy; override;
  end;

  TProcedureInfo = class(TObject)
  public
    ProcedureNumber: integer;
    xSegmentName: TAlpha8;
    ProcedureName: TAlpha8;

    SegmentNumber: integer;
    SegmentNameFull: string;
    ProcedureNameFull: string;

    VarList: string;
    ParamList: string;
    ProcedureBody: TStringList;
    ResultTypeName: TAlpha8;
    ResultTypeType: TWatchType;
    SegmentType: TType_of_Symbol;
    Constructor Create;
    Destructor Destroy; override;
  end;

  TSegmentInfoList = class(TStringList)
  public
    function GetIndexOfSegmentNumber(SegNum: integer): integer;
    Destructor Destroy; override;
  end;

implementation

uses
  SysUtils, FileNames;

{ TSegmentInfo }

constructor TSegmentInfo.Create;
begin
  inherited;
  Procedures := TProcedureInfoList.Create;
end;

destructor TSegmentInfo.Destroy;
begin
  FreeAndNil(Procedures);
  inherited;
end;

{ TProcedureInfo }

constructor TProcedureInfo.Create;
begin
  ProcedureBody := TStringList.Create;
end;

destructor TProcedureInfo.Destroy;
begin
  FreeAndNil(ProcedureBody);
  inherited;
end;

{ TSegmentInfoList }

destructor TSegmentInfoList.Destroy;
var
  sn, pn: integer;
  SegmentInfo: TSegmentInfo;
  ProcedureInfo: TProcedureInfo;
begin
  if Count > 0 then
    begin
      for sn := 0 to Count-1 do
        begin
          SegmentInfo := Objects[sn] as TSegmentInfo;
          with SegmentInfo do
            for pn := 0 to Procedures.Count-1 do
              begin
                ProcedureInfo := TProcedureInfo(Procedures.Objects[pn]);
                FreeAndNil(ProcedureInfo);
              end;
          FreeAndNil(SegmentInfo);
        end;
    end;

  inherited;
end;

function TSegmentInfoList.GetIndexOfSegmentNumber(SegNum: integer): integer;
var
  sn: integer;
  SegmentInfo: TSegmentInfo;
begin
  result := -1;
  for sn := 0 to Count-1 do
    begin
      SegmentInfo   := Objects[sn] as TSegmentInfo;
      if SegmentInfo.SegmentNumber = SegNum then
        begin
          result := sn;
          exit
        end
    end;
end;

initialization
  gRootPath := ExtractFilePath(ParamStr(0));
end.
