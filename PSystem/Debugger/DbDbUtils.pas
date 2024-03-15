unit DbDbUtils;

interface

uses
  ADOX_TLB, ADODB, MyTables_Decl;

procedure CreateDebugDatabase(var FileName: string; DBVersion: TDBVersion);

implementation

uses
  Sysutils, MyUtils, MyTables;

procedure CreateDebugDatabase(var FileName: string; DBVersion: TDBVersion);
var
  ConnectionString, cs: string;
  Connection: TADOConnection;
  ADOXCatalog1: TADOXCatalog;
  ADOCommand1: TADOCommand;
begin { TfrmMediaCatalog.CreateDebugDatabase }
  ADOXCatalog1 := TADOXCatalog.Create(nil);
  ADOCommand1  := TADOCommand.Create(nil);
    try
      case DBVersion of
        dv_Access2000:
          begin
            FileName         := ForceExtension(FileName, MDB_EXT);
            ConnectionString := Format(ACCESS_2000_CONNECTION_STRING, [ACCESS_2000_PROVIDER, FileName]);
          end;
        dv_Access2007:
          begin
            FileName         := ForceExtension(FileName, ACCDB_EXT);
            ConnectionString := Format(ACCESS_2007_CONNECTION_STRING, [ACCESS_2007_PROVIDER, FileName]);
          end;
        dv_Access2019:  // untested
          begin
            FileName         := ForceExtension(FileName, ACCDB_EXT);
            ConnectionString := Format(ACCESS_2019_CONNECTION_STRING, [ACCESS_2019_PROVIDER, FileName]);
          end;
      end;

      ADOXCatalog1.Create1(ConnectionString);
      Connection := MyConnection(FileName);
      ADOCommand1.Connection := Connection;
  
    //  ADOConnection1.ConnectionString := ConnectionString;
    //  ADOConnection1.LoginPrompt      := false;
    //  ADOCommand1.Connection          := ADOConnection1;
    //  ADOConnection1.connection := Connection;

      cs := 'CREATE TABLE pCodeProcs (' +
             'ProcedureID COUNTER,' +
             'SegmentName TEXT(8),' +
             'ProcedureNumber INT,' +
             'ProcedureName TEXT(20),' +
             'ProcedureNameFull TEXT(30),' +
             'DecodedPCode MEMO,' +
             'ProcParameters MEMO,' +
             'SourceCode MEMO,' +
             'SegmentID INT,' +
             'DataSize INT,' +
             'ExitIC INT,' +
             'CodeAddr INT,' +
             'CodeSize INT,' +
             'DateAdded DATETIME,' +
             'DateUpdated DATETIME)';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE INDEX PrimaryKey ' +
            'ON pCodeProcs (ProcedureID) WITH PRIMARY';

      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE INDEX ProcedureName ' +
            'ON pCodeProcs (ProcedureName)';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE INDEX ProcedureNumber ' +
            'ON pCodeProcs (ProcedureNumber)';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE INDEX ProcIndex ' +
            'ON pCodeProcs (SegmentName,ProcedureNumber,ProcedureName)';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE INDEX SegmentName ' +
            'ON pCodeProcs (SegmentName)';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      (* SegmentInfo Table  *)

      cs := 'CREATE TABLE SegmentInfo (' +
             'SegmentID COUNTER,' +
             'SegmentName TEXT(8),' +
             'CodeFileID INT,' +
             'MajorVersion TEXT(10),' +
             'SegmentType TEXT(10),' +
             'Seg_Text INT,' +
             'Code_Addr INT,' +
             'Code_Leng INT,' +
             'Data_Size INT,' +
             'Seg_Ref_Words INT,' +
             'Host_Name TEXT(8),' +
             'DateAdded DATETIME,' +
             'DateUpdated DATETIME)';

      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE TABLE VolumeInfo (' +
            'VolumeID COUNTER,' +
            'DOSVolumeFileName TEXT(255),' +
            'pSysVolumeName TEXT(8),' +
            'DateAdded DATETIME,' +
            'DateUpdated DATETIME,' +
            'LocationID INT,' +
            'DOSFilePath MEMO)';

      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE TABLE CodeFileInfo (' +
            'CodeFileID COUNTER,' +
            'pSysFileName TEXT(15),' +
            'NrSegments INT,' +
            'VolumeID INT,' +
            'DateAdded DATETIME,' +
            'DateUpdated DATETIME)';

      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE INDEX PrimaryKey ' +
            'ON SegmentInfo (SegmentID) WITH PRIMARY';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

      CS := 'CREATE INDEX SegmentName ' +
            'ON SegmentInfo (SegmentName)';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;

    (*
      CS := 'CREATE INDEX UnitID ' +
            'ON SegmentInfo (UnitID)';
      ADOCommand1.CommandText := cs;
      ADOCommand1.Execute;
    *)
      Connection.Close;
    finally
      FreeAndNil(ADOCommand1);
      FreeAndNil(ADOXCatalog1);
    end;
end;  { TfrmMediaCatalog.CreateDebugDatabase }

end.
