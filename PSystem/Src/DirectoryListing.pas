unit DirectoryListing;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, Menus;

const
    COL_NR = 0;
    COL_DTID = 1;
    COL_USED = 2;
    COL_DATE = 3;
    COL_TIME = 4;
    COL_1STBLK = 5;
    COL_BYTES = 6;
    COL_FILETYPE = 7;

type
  TDirectorySort   = (dsUnsorted, dsAlphaSort, dsDateSort, dsFileSize);

  TfrmDirectoryListing = class(TForm)
    Label1: TLabel;
    lblVolumeName: TLabel;
    Label2: TLabel;
    lblDOSFiileName: TLabel;
    sgDirectory: TStringGrid;
    leNrFiles: TLabeledEdit;
    leBlocksUsed: TLabeledEdit;
    leUnused: TLabeledEdit;
    leInLargestArea: TLabeledEdit;
    btnClose: TButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    Sort1: TMenuItem;
    Alpha1: TMenuItem;
    Date1: TMenuItem;
    Size1: TMenuItem;
    Unsorted1: TMenuItem;
    Label3: TLabel;
    LblLastWrite: TLabel;
    procedure Exit1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Alpha1Click(Sender: TObject);
    procedure Date1Click(Sender: TObject);
    procedure Size1Click(Sender: TObject);
    procedure Unsorted1Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    procedure SortBy(DirectorySort: TDirectorySort);
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frmDirectoryListing: TfrmDirectoryListing;

implementation

uses MyUtils, FilerSettingsUnit;

{$R *.dfm}

procedure TfrmDirectoryListing.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmDirectoryListing.Print1Click(Sender: TObject);
var
  OutFileName: string;
begin
  OutFileName := UniqueFileName(FilerSettings.ReportsPath + 'DirectoryListing.txt');
  PrintStringGrid('Directory Listing', '', sgDirectory, OutFileName);
  EditTextFile(OutFileName);
end;

procedure TfrmDirectoryListing.SortBy(DirectorySort: TDirectorySort);
begin
  case DirectorySort of
    dsUnsorted:
      begin
        Unsorted1.Checked := true;
        SortGridNumeric(sgDirectory, COL_NR);
      end;

    dsAlphaSort:
      begin
        Alpha1.Checked := true;
        Sortgrid(sgDirectory, COL_DTID);
      end;

    dsDateSort:
      begin
        Date1.Checked := true;
        Sortgrid(sgDirectory, COL_DATE);
      end;

    dsFileSize:
      begin
        Size1.Checked := true;
        SortGridNumeric(sgDirectory, COL_USED);
      end;
  end;
end;


procedure TfrmDirectoryListing.Alpha1Click(Sender: TObject);
begin
  SortBy(dsAlphaSort);
end;

procedure TfrmDirectoryListing.Date1Click(Sender: TObject);
begin
  SortBy(dsDateSort);
end;

procedure TfrmDirectoryListing.Size1Click(Sender: TObject);
begin
  SortBy(dsFileSize);
end;

procedure TfrmDirectoryListing.Unsorted1Click(Sender: TObject);
begin
  SortBy(dsUnsorted);
end;

procedure TfrmDirectoryListing.btnCloseClick(Sender: TObject);
begin
  Close;
end;

constructor TfrmDirectoryListing.Create(aOwner: TComponent);
begin
  inherited;
  Unsorted1.Checked := true;
end;

end.
