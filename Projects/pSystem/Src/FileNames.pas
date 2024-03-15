unit FileNames;

interface

uses
  Interp_Const;

const

  TXT_EXT       = 'TXT';
  CSV_EXT       = 'CSV';
  INI_EXT       = 'ini';
  VOL_EXT       = 'VOL';
  PAS_EXT       = 'PAS';
  EXE_EXT       = 'EXE';
  ACC_EXT       = 'ACCDB';

  DATABASE_INI  = 'DATABASE.' + INI_EXT;

  CDEBUGGERSETTINGSFILESFOLDERNAME = 'DebuggerSettings';

  function AccDBRootFolder: string;
  function AccessDBBaseFileName(VersionNr: TVersionNr): string;
  function AccessDBFileFileName(VersionNr: TVersionNr): string;
  function CalcTextBackupRootPath(VersionNr: TVersionNr): string;
  function CSVFilesToLoadFileName(VersionNr: TVersionNr): string;
  function DataBaseSettingsFilesFolder: string;
  function DebuggerSettingsFileName(VersionNr: TVersionNr): string;
  function DefaultReportsPath: string;
  function ListingsPath(VersionNr: TVersionNr): string;
  function VersionNrFromDBFileName(const DBFileNAme: string): TVersionNr;

var
  gRootPath: string;

implementation

uses FilerSettingsUnit, SysUtils, Interp_Decl;

function AccDBRootFolder: string;     // 'c:\PSystem\AccDB\'
begin
 result := Format('%sAccDB\', [gRootPath]);
end;


function AccessDBFileFileName(VersionNr: TVersionNr): string; // 'c:\PSystem\AccDB\Version-II.accdb'
begin
  result := Format('%s%s', [AccDBRootFolder, AccessDBBaseFileName(VersionNr)]);
end;

function AccessDBBaseFileName(VersionNr: TVersionNr): string;  // 'Version-II.accdb'
begin
  result := Format('%s.%s', [VersionNrStrings[VersionNr].Name, ACC_EXT]);
end;


function CalcTextBackupRootPath(VersionNr: TVersionNr): string; // 'c:\pSystem\DB Contents\V-1.5'
begin {ok}
  result := Format('%sDB Contents\V-%s', [gRootPath, VersionNrStrings[VersionNr].NumStr]);
end;

function CSVFilesToLoadFileName(VersionNr: TVersionNr): string; // 'c:\psystem\DebuggerSettings\CSVFilesToLoad-CSVFilesToLoad-II.CSV'
begin {ok}
  result := Format('%sCSVFilesToLoad-%s.%s',
                   [DataBaseSettingsFilesFolder, VersionNrStrings[VersionNr].Abbrev, CSV_EXT]);
end;

function DataBaseSettingsFilesFolder: string;   // 'c:\psystem\DebuggerSettings\'
begin {ok}
  result := Format('%s%s\', [gRootPath, CDEBUGGERSETTINGSFILESFOLDERNAME]);
end;

function DebuggerSettingsFileName(VersionNr: TVersionNr): string; // 'c:\psystem\DebuggerSettings\Debugger-IV.2.2.INI'
begin {ok}
  result := Format('%sDebugger-%s.ini',
                   [DataBaseSettingsFilesFolder, VersionNrStrings[VersionNr].Abbrev]);
end;

function ListingsPath(VersionNr: TVersionNr): string; // 'c:\psystem\Listings\V1.5'
begin
  result := Format('%sListings\V%s', [gRootPath, VersionNrStrings[VersionNr].NumStr]);
end;

function DefaultReportsPath: string;  // 'C:\pSystem\Reports\'
begin
  result := Format('%sReports\', [gRootPath]);
end;

function VersionNrFromDBFileName(const DBFileNAme: string): TVersionNr;
var
  vn : TVersionNr;
begin
  for vn := Low(TVersionNr) to High(TVersionNr) do
    if SameText(AccessDBBaseFileName(vn), DBFileName) then
      begin
        result := vn;
        exit;
      end;
  result := vn_Unknown;
end;

end.
