unit FilerSettingsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids;

type
  TfrmFilerSettings = class(TForm)
    leSearchFolder: TLabeledEdit;
    leVolumesFolder: TLabeledEdit;
    leLogFileName: TLabeledEdit;
    lePrinterLfn: TLabeledEdit;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    btnBrowseSearchFolder: TButton;
    btnBrowseVolumesFolder: TButton;
    btnBrowseLogFileName: TButton;
    btnBrowsePrinterLfn: TButton;
    leReportsPath: TLabeledEdit;
    btnReportsPath: TButton;
    leEditorFilePathName: TLabeledEdit;
    btnEditorFilePathName: TButton;
    cbAutoEdit: TCheckBox;
    procedure btnBrowseSearchFolderClick(Sender: TObject);
    procedure btnBrowseLogFileNameClick(Sender: TObject);
    procedure btnBrowsePrinterLfnClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnReportsPathClick(Sender: TObject);
    procedure btnEditorFilePathNameClick(Sender: TObject);
    procedure btnBrowseVolumesFolderClick(Sender: TObject);
    procedure lePrinterLfnChange(Sender: TObject);
  private
    procedure Browse4Folder(const aCaption: string; le: TLabeledEdit);
    procedure Browse4FileName(const aCaption: string; le: TLabeledEdit; const Ext: string);
    procedure Enable_Buttons;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frmFilerSettings: TfrmFilerSettings;

implementation

uses MyUtils, FilerSettingsUnit, uGetString, MyTables_Decl, Interp_Decl,
  Interp_Common, FileNames;

{$R *.dfm}

procedure TfrmFilerSettings.Browse4Folder(const aCaption: string; le: TLabeledEdit);
var
  Lfn: string;
begin
  lfn := le.Text;
  if BrowseForFolder(aCaption + ' folder', Lfn) then
    le.Text := Lfn;
end;

procedure TfrmFilerSettings.Browse4FileName(const aCaption: string; le: TLabeledEdit; const Ext: string);
var
  Lfn: string;
begin
  Lfn := le.Text;
  if BrowseForFile(aCaption, Lfn, Ext) then
    le.Text := Lfn;
end;


(*
procedure TfrmFilerSettings.btnBrowseSourceCodeSavePathClick(Sender: TObject);
begin
  Browse4Folder('Source Code Save', leSourceCodeSavePath);
end;

procedure TfrmFilerSettings.btnBrowsepCodeSavePathClick(Sender: TObject);
begin
  Browse4Folder('p-Code Save', lepCodeSavePath);
end;

procedure TfrmFilerSettings.btnBrowseVarListPathClick(Sender: TObject);
begin
  Browse4Folder('VAR List Save', leVarListPath);
end;
*)

procedure TfrmFilerSettings.btnBrowseSearchFolderClick(Sender: TObject);
begin
  Browse4Folder('Search List' ,  leSearchFolder);
end;

(*
procedure TfrmFilerSettings.btnBrowseVolumesFolderClick(Sender: TObject);
begin
  Browse4Folder('Debugger Databases', leDebuggerDatabases);
end;
*)

procedure TfrmFilerSettings.btnBrowseLogFileNameClick(Sender: TObject);
begin
  Browse4FileName('Log File', leLogFileName, TXT_EXT);
end;

procedure TfrmFilerSettings.btnBrowsePrinterLfnClick(Sender: TObject);
begin
  Browse4FileName('Printer', lePrinterLfn, TXT_EXT);
end;

procedure TfrmFilerSettings.Enable_Buttons;
begin
  cbAutoEdit.Enabled := not Empty(lePrinterLfn.text);
end;

constructor TfrmFilerSettings.Create(aOwner: TComponent);
begin
  inherited;
  with FilerSettings do
    begin
      Enable_Buttons;
      leSearchFolder.Text       := SearchFolder;
      leVolumesFolder.Text      := VolumesFolder;
      leLogFileName.Text        := LogFileName;
      leReportsPath.Text        := ReportsPath;
      leEditorFilePathName.Text := EditorFilePath;
      lePrinterLfn.text         := PrinterLfn;
      AutoEdit                  := cbAutoEdit.Checked;
    end;
end;

procedure TfrmFilerSettings.btnOkClick(Sender: TObject);
begin
  with FilerSettings do
    begin
      SearchFolder       := leSearchFolder.Text;
      VolumesFolder      := leVolumesFolder.Text;
      LogFileName        := leLogFileName.Text;
      PrinterLfn         := lePrinterLfn.text;
      ReportsPath        := leReportsPath.Text;
      EditorFilePath     := leEditorFilePathName.Text;
      cbAutoEdit.Checked := AutoEdit;
    end;
end;

procedure TfrmFilerSettings.btnReportsPathClick(Sender: TObject);
begin
  Browse4Folder('Reports', leReportsPath);
end;

procedure TfrmFilerSettings.btnEditorFilePathNameClick(Sender: TObject);
begin
  Browse4FileName('Editor FileName/Path', leEditorFilePathName, EXE_EXT);
end;


procedure TfrmFilerSettings.btnBrowseVolumesFolderClick(Sender: TObject);
begin
  Browse4Folder('Volumes', leVolumesFolder);
end;

procedure TfrmFilerSettings.lePrinterLfnChange(Sender: TObject);
begin
  Enable_Buttons;
end;

end.
