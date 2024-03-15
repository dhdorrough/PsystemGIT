program BuildDebugDatabase;

uses
  Forms,
  BuildDBDB in 'BuildDBDB.pas' {frmBuildDBDBMain},
  MyUtils in '..\..\MyUtils\MyUtils.pas',
  FilerTables in '..\Src\FilerTables.pas',
  ListingUtils in 'ListingUtils.pas',
  UCSDGlob in '..\Src\UCSDGlob.pas',
  Watch_Decl in 'Watch_Decl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmBuildDBDBMain, frmBuildDBDBMain);
  Application.Run;
end.
