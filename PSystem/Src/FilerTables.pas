unit FilerTables;

interface

uses
  SysUtils, DBTables, DB, Classes, ADODB, MyTables_Decl, MyTables, DBDataBase;

const
  // Field Names
     cProcedureID     = 'ProcedureID';
     cSEGMENTNAME     = 'SegmentName';
     cPROCEDURENUMBER = 'ProcedureNumber';
     cPROCEDURENAME   = 'ProcedureName';
     cProcedureNameFull = 'ProcedureNameFull';
     cDECODEDPCODE    = 'DecodedPCode';
     cSOURCECODE      = 'SourceCode';
     cDATEADDED       = 'DateAdded';
     cDATEUPDATED     = 'DateUpdated';
     cPROCPARAMETERS  = 'ProcParameters';
     cVERSIONNR       = 'VersionNr';
     cPSYSFILENAME    = 'pSysFileName';

  // Table Names
     TableNamePCODEPROCS  = 'pCodeProcs';
     TableNameSEGMENTINFO = 'SegmentInfo';
     TableNameVOLUMEINFO  = 'VOLUMEINFO';
     TableNameCODEFILEINFO = 'CodeFileInfo';

  // Index Names
   IndexName_SEGNAME_PROC_NR_NAME_INDEX = cSEGMENTNAME + ';' + cPROCEDURENUMBER + ';' + cPROCEDURENAME;
   IndexName_SEGMENT_PROC_NUMBER_INDEX = cSEGMENTNAME + ';' + cPROCEDURENUMBER;
   IndexName_SEGNAME_PROCNAME_INDEX = cSEGMENTNAME + ';' + cPROCEDURENAME;
   IndexName_DOSVOLUMEFILENAME = 'DOSVolumeFileName';
   IndexName_PSYSFILENAME      = 'pSysFileName';

type
  TCodeFileInfoTable = class(TMyTable)
  private
  protected
  public
    fldCodeFileID          : TField;
    fldpSysFileName        : TField;
    fldNrSegments          : TField;
    fldVolumeId            : TField;
    fldDateAdded           : TField;
    fldDateUpdated         : TField;

    procedure DoBeforePost; override;
    procedure InitFieldPtrs; override;
  end;

  TVolumeInfoTable = class(TMyTable)
  private
  protected
  public
    fldVolumeID            : TField;
    fldDOSVolumeFileName   : TField;
    fldpSysVolumeName      : TField;
    fldDOSFilePath         : TField;
    fldDateAdded           : TField;
    fldDateUpdated         : TField;
    fldVersionNr           : TField;

    procedure DoBeforePost; override;
    procedure InitFieldPtrs; override;
  end;

  TpCodesProcTable = class(TMyTable)
  private
    function SaveMemosToFiles(MemoField: TMemoField;
      DataBaseInfo: TDataBaseInfo; const Ext: string; var FilesSaved: integer): boolean;
    procedure CopyMemoToFile(MemoField: TMemoField;
      const FilePath: string);
  protected
    procedure DoBeforePost; override;
  public
    fldProcedureID      : TField;
    fldProcedureNumber  : TField;
    fldProcedureName    : TField;
    fldProcedureNameFull: TField;
    fldDecodedPCode     : TField;
    fldSourceCode       : TField;
    fldSegmentName      : TField;
    fldProcParameters   : TField;
    fldDataSize         : TField;
    fldParamSize        : TField;
    fldEnterIC          : TField;
    fldExitIC           : TField;
    fldCodeAddr         : TField;
    fldCodeSize         : TField;
    fldSegmentID        : TField;
    fldVersionNr        : TField;
    fldDateAdded        : TField;
    fldDateUpdated      : TField;

    Constructor Create( aOwner: TComponent;
                        aDBFilePathName, aTableName: string;
                        Options: TPhotoTableOptions); reintroduce;

    Destructor Destroy; override;
    procedure InitFieldPtrs; override;
    procedure UpdateProcInfo(const aSegName: string; aProcNum: integer;
      const aProcName: string);
    function SaveMemoToFile(Field: TField;  DataBaseInfo: TDataBaseInfo; const Ext: string): integer; 
  end;

implementation

uses
  Variants, MyUtils;

procedure TpCodesProcTable.UpdateProcInfo(const aSegName: string;
  aProcNum: integer; const aProcName: string);
begin
  // Assume that we are already positioned on the correct record
  fldSegmentName.AsString      := aSegName;
  fldProcedureNumber.AsInteger := aProcNum;
  fldProcedureName.AsString    := aProcName;
end;


constructor TpCodesProcTable.Create(aOwner: TComponent;
  aDBFilePathName, aTableName: string; Options: TPhotoTableOptions);
begin
  inherited Create(aOwner, aDBFilePathName, aTableName, Options);
end;

destructor TpCodesProcTable.Destroy;
begin
  inherited;
end;

procedure TpCodesProcTable.DoBeforePost;
begin
  inherited;
  if fldDateAdded.IsNull then
    fldDateAdded.AsDateTime := now;

  fldDateUpdated.AsDateTime := now;;
end;

procedure TpCodesProcTable.InitFieldPtrs;
begin
  inherited;

  fldProcedureID     := FindField(cProcedureID);        // Using FindField because field may not exist in old DBs
//fldSegment_ID      := FieldByName(cSegment_ID);
  fldProcedureNumber := FieldByName(cProcedureNumber);
  fldProcedureName   := FieldByName(cProcedureName);
  fldProcedureNameFull := FindField(cProcedureNameFull);
  fldDecodedPCode    := FieldByName(cDecodedPCode);
  fldSourceCode      := FieldByName(cSourceCode);
  fldSegmentName     := FieldByName(cSEGMENTNAME);
  fldDateAdded       := FieldByName(cDATEADDED);
  fldDateUpdated     := FieldByName(cDATEUPDATED);
  fldProcParameters  := FieldByName(cPROCPARAMETERS);
  fldDataSize        := FindField('DataSize');
  fldParamSize       := FindField('ParamSize');
  fldEnterIC         := FindField('EnterIC');
  fldExitIC          := FindField('ExitIC');
  fldCodeAddr        := FindField('CodeAddr');
  fldCodeSize        := FindField('CodeSize');
  fldSegmentID       := FindField('SegmentID');
  fldVersionNr       := FindField(cVERSIONNR);
end;

{ TSegmentInfoTable }

{ TVolumeInfoTable }

procedure TVolumeInfoTable.DoBeforePost;
begin
  inherited;
  if fldDateAdded.IsNull then
    fldDateAdded.AsDateTime := now;

  fldDateUpdated.AsDateTime := now;;
end;

procedure TVolumeInfoTable.InitFieldPtrs;
begin
  inherited;

  fldVolumeID            := FieldByName('VolumeID');
  fldDOSVolumeFileName   := FieldByName('DOSVolumeFileName');
  fldDOSFilePath         := FieldByName('DOSFilePath');
  fldpSysVolumeName      := FieldByName('pSysVolumeName');
  fldDateAdded           := FieldByName(cDATEADDED);
  fldDateUpdated         := FieldByName(cDATEUPDATED);
  fldVersionNr           := FieldByName(cVERSIONNR);
end;

{ TCodeFileInfoTable }

procedure TCodeFileInfoTable.DoBeforePost;
begin
  inherited;
  if fldDateAdded.IsNull then
    fldDateAdded.AsDateTime := now;

  fldDateUpdated.AsDateTime := now;;
end;

procedure TCodeFileInfoTable.InitFieldPtrs;
begin
  inherited;
  fldCodeFileID   := FieldByName('CodeFileID');
  fldpSysFileName := FieldByName('pSysFileName');
  fldNrSegments   := FieldByName('NrSegments');
  fldVolumeId     := FieldByName('VolumeId');
  fldDateAdded    := FieldByName(cDATEADDED);
  fldDateUpdated  := FieldByName(cDATEUPDATED);
end;

procedure TpCodesProcTable.CopyMemoToFile(MemoField: TMemoField; const FilePath: string);
var
  BlobStream: TStream;
  FileStream: TFileStream;
  RenamedName: string;
  NewDateTime: TDateTime;
  f: file;
begin
//if FileExists(FilePath) then
//  begin
//    RenamedName := UniqueFileName(FilePath);
//    AssignFile(f, FilePath);
//    Rename(f, RenamedName);   // ---> FileName (nnn).ext
//  end;
//Update_StatusFmt('Saving to %s', [FilePath]);
  FileStream := TFileStream.Create(FilePath, fmCreate);

  NewDateTime := 0;

  BlobStream := CreateBlobStream(MemoField, bmRead);
  if not fldDateUpdated.IsNULL then
    newDateTime := fldDateUpdated.AsDateTime else
  if not fldDateAdded.IsNull then
    newDateTime := fldDateAdded.AsDateTime;

  try
    FileStream.CopyFrom(BlobStream, BlobStream.Size);
  finally
    BlobStream.Free;
    FileStream.Free;

    if newDateTime <> 0 then
      FileSetDate(FilePath, DateTimeToFileDate(newDateTime));
  end;
end;

function TpCodesProcTable.SaveMemosToFiles(  MemoField: TMemoField;
                                             DataBaseInfo: TDataBaseInfo;
                                             const Ext: string; 
                                             var FilesSaved: integer): boolean;
const
  ONE_HOUR   = 1 / 24;
  ONE_MINUTE = ONE_HOUR / 60;
var
  Count, Skipped: integer;
  FileDateTime: TDateTime;
  FilePathName: string;
begin
  Count := 0;
  Skipped := 0;

  try
    First;
    while not Eof do
      begin
        if (not Empty(fldSegmentName.AsString)) and
           (not Empty(fldProcedureName.AsString)) and
           (MemoField.BlobSize > 0) then
          begin
            if not DirectoryExists(DataBaseInfo.TextBackupRootPath) then
              MkDir(DataBaseInfo.TextBackupRootPath);

            FilePathName := Format( '%s%s_%s.%s',
                                    [DataBaseInfo.TextBackupRootPath,
                                     fldSegmentName.AsString,
                                     fldProcedureName.AsString,
                                     Ext]);
            if FileExists(FilePathName) then
              FileDateTime := FileDateToDateTime(FileAge(FilePathName))
            else
              FileDateTime := 0;

            if (fldDateUpdated.AsDateTime - FileDateTime) > ONE_MINUTE then
              begin
                CopyMemoToFile(MemoField, FilePathName);
                inc(Count);
              end
            else
              inc(Skipped);
          end
        else
          inc(Skipped);
        Next;
      end;
  except
    on e:Exception do
      Alert(e.Message);
  end;
  result     := (Count > 0) or (Skipped > 0);
  FilesSaved := Count;
end;

function TpCodesProcTable.SaveMemoToFile(Field: TField;
  DataBaseInfo: TDataBaseInfo; const Ext: string): integer;
begin
  if (not SaveMemosToFiles( Field as TMemoField,
                            DataBaseInfo,
                            Ext,
                            result)) then
    raise Exception.CreateFmt('Could not save %s to file "%s"',
                                [Ext, DataBaseInfo.FilePath]);
end;

end.

