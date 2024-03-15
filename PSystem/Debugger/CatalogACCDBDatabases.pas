unit CatalogACCDBDatabases;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MyDelimitedParser, DebuggerSettingsUnit;

type
  TfrmCatalog = class(TForm)
    leRootFolder: TLabeledEdit;
    btnBrowseRoot: TButton;
    btnBegin: TButton;
    leOutputFileName: TLabeledEdit;
    btnBrowseForOutput: TButton;
    lblStatus: TLabel;
    procedure btnBrowseRootClick(Sender: TObject);
    procedure btnBrowseForOutputClick(Sender: TObject);
    procedure btnBeginClick(Sender: TObject);
  private
    { Private declarations }
    fNrFiles         : integer;
    fRecordsProcessed: integer;
    fRootFolder      : string;
    fDelimited_Info  : TDelimited_Info;
    fOutputCSV       : TextFile;
    fFields           : TFieldArray;
    fLine            : string;
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; DatabaseSettings: TDatabaseSettings); ReIntroduce;
    Destructor Destroy; override;
  end;

TFieldNames = (FLD_FILENR, FLD_FILENAME, FLD_FILEDATE, FLD_NR_SEGMENTS, FLD_NR_PROCEDURES, FLD_LATEST_UPDATE,
               FLD_HAS_SOURCE_CNT, FLD_HAS_PCODE_COUNT, FLD_FILEPATH);

var
  frmCatalog: TfrmCatalog;

implementation

uses MyUtils, FilerSettingsUnit, FilerTables, MyTables, MyTables_Decl,
  pSysDatesAndTimes;

{$R *.dfm}

procedure TfrmCatalog.btnBrowseRootClick(Sender: TObject);
begin
  fRootFolder := leRootFolder.Text;
  if BrowseForFolder('Root Folder', fRootFolder) then
    begin
      leRootFolder.Text := fRootFolder;
    end;
end;

procedure TfrmCatalog.btnBrowseForOutputClick(Sender: TObject);
var
  TempName: string;
begin
  TempName := leOutputFileName.Text;
  if BrowseForFile('OUTPUT CSV file', TempName, 'CSV') then
    leOutputFileName.Text := TempName;
end;

constructor TfrmCatalog.Create(aOwner: TComponent; DatabaseSettings: TDatabaseSettings);
begin
  inherited Create(aOwner);
  fDelimited_Info.Field_Seperator := ',';
  fDelimited_Info.QuoteChar       := '"';

  SetLength(fFields, Ord(FLD_FILEPATH)+1);

  FilerSettings := TFilerSettings.Create(self);
  with FilerSettings do
    LoadFromFile(FilerSettingsFileName);
  leRootFolder.Text     := DatabaseSettings.DebuggerDatabasesFolder;
  leOutputFileName.Text := FilerSettings.ReportsPath + 'Debugger Databases Report.csv';
end;

destructor TfrmCatalog.Destroy;
begin
  FreeAndNil(FilerSettings);
  inherited;
end;



procedure TfrmCatalog.btnBeginClick(Sender: TObject);

  procedure ProcessAccDbFile(const FileName: string);
  var
    pCodesProcTable: TpCodesProcTable;
    NrProcedures: integer;
    LatestProcDate: TDateTime;
    HasSourceCount, HasPCodeCount: integer;
    Line: string;
    SegmentName: string;
    SegmentList: TStringList;
  begin
    Application.ProcessMessages;
    INC(fNrFiles);
    lblStatus.Caption := Format('Now processing %d: %s', [fNrFiles, FileName]);
    pCodesProcTable := TpCodesProcTable.Create(self, FileName, TableNamePCODEPROCS, [optLevel12]);
    NrProcedures   := 0;
    LatestProcDate := BAD_DATE;
    HasSourceCount := 0;
    HasPCodeCount  := 0;
    SegmentList    := TStringList.Create;
    SegmentList.Sorted := true;
    try
      try
        fFields[ord(FLD_FILENR)]        := IntToStr(fNrFiles);
        fFields[ord(FLD_FILEPATH)]      := ExtractFilepath(FileName);
        fFields[ord(FLD_FILENAME)]      := ExtractFileName(FileName);
        fFields[ord(FLD_FILEDATE)]      := DateToStr(FileDateToDateTime(FileAge(FileName)));

        with pCodesProcTable do
          begin
            Active := true;
            while not Eof do
              begin
                if (not fldDateUpdated.IsNull) and (fldDateUpdated.AsDateTime > LatestProcDate) then
                  LatestProcDate := fldDateUpdated.AsDateTime;
                Next;
                inc(NrProcedures);
                inc(fRecordsProcessed);
                if not fldSourceCode.IsNull then
                  inc(HasSourceCount);
                if not fldDecodedPCode.IsNull then
                  inc(HasPCodeCount);
                SegmentName := fldSegmentName.AsString;
                if SegmentList.IndexOf(SegmentName) < 0 then // not already in list
                  SegmentList.Add(SegmentName);              // so add it
              end;
          end;
        fFields[ord(FLD_NR_SEGMENTS)]     := IntToStr(SegmentList.Count);
        fFields[ord(FLD_NR_PROCEDURES)]   := IntToStr(NrProcedures);
        if not (LatestProcDate = BAD_DATE) then
          fFields[ord(FLD_LATEST_UPDATE)] := DateToStr(LatestProcDate);
        fFields[ord(FLD_HAS_SOURCE_CNT)]  := IntToStr(HasSourceCount);
        fFields[ord(FLD_HAS_PCODE_COUNT)] := IntToStr(HasPCodeCount);

        Line := Contruct_Delimited_Line( fFields, fDelimited_Info);
        WriteLn(fOutputCSV, Line);
      except
        on e:Exception do
          begin
            ErrorFmt('Error processing %s [%s]', [FileName, e.Message]);
            FreeAndNil(pCodesProcTable);
          end;
      end;
    finally
      FreeAndNil(SegmentList);
      FreeAndNil(pCodesProcTable);
      if MyConnections.Count > 60 then
        FreeConnections;    // There seems to be a brick wall when we hit 64 connections
    end;
  end;

  procedure ProcessFolder(FolderPathName: string);
  var
    SearchRec: TSearchRec;
    SearchPath: string;
    DosErr: integer;
    FileName: string;
    Ext: string;
  begin
    FolderPathName := ForceBackSlash(FolderPathName);
    SearchPath     := FolderPathName + '*.*';
    DosErr         := FindFirst(SearchPath, faAnyFile, SearchRec);
    try
      while DosErr = 0 do
        begin
          FileName := FolderPathName + SearchRec.Name;
          if (SearchRec.Attr and faDirectory) <> 0	then
            begin
              if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
                ProcessFolder(FileName);
            end
          else
            begin
              Ext := ExtractFileExt(SearchRec.Name);
              if SameText(Ext, ACCDB_EXT_) then // '.ACCDB'
                ProcessAccDbFile(FileName)
            end;

          DosErr := FindNext(SearchRec);
        end;
    finally
      FindClose(SearchRec);
    end;
  end;

begin { TfrmCatalog.btnBeginClick }
  AssignFile(fOutputCSV, leOutputFileName.Text);
  Rewrite(fOutputCSV);

  fFields[ord(FLD_FILENR)]          := 'FILENR';
  fFields[ord(FLD_FILENAME)]        := 'FILENAME';
  fFields[ord(FLD_FILEDATE)]        := 'FILEDATE';
  fFields[ord(FLD_NR_SEGMENTS)]     := 'NR_SEGMENTS';
  fFields[ord(FLD_NR_PROCEDURES)]   := 'NR_PROCS';
  fFields[ord(FLD_LATEST_UPDATE)]   := 'LATEST_UPDATE';
  fFields[ord(FLD_HAS_SOURCE_CNT)]  := 'HAS_SOURCE';
  fFields[ord(FLD_HAS_PCODE_COUNT)] := 'HAS_PCODE';
  fFields[ord(FLD_FILEPATH)]        := 'FILEPATH';

  fLine := Contruct_Delimited_Line( fFields, fDelimited_Info);
  WriteLn(fOutputCSV, fLine);

  fRecordsProcessed := 0;
  fNrFiles          := 0;
  try
    ProcessFolder(leRootFolder.Text);
  finally
    CloseFile(fOutputCSV);
    lblStatus.Caption := Format('Processing complete. %d databases processed. %d records processed',
                                [fNrFiles, fRecordsProcessed]);
    if not ExecAndWait(leOutputFileName.Text, '', true) then
      {};
  end;
end;  { TfrmCatalog.btnBeginClick }

end.
