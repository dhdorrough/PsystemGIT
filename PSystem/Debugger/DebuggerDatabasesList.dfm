object frmDebuggerDatabasesList: TfrmDebuggerDatabasesList
  Left = 645
  Top = 264
  Width = 834
  Height = 431
  Caption = 'DATABASE Settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    818
    392)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 32
    Top = 370
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object btnCancel: TBitBtn
    Left = 723
    Top = 354
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 5
  end
  object btnOk: TBitBtn
    Left = 635
    Top = 354
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 6
    OnClick = btnOkClick
  end
  object leDebuggerDatabasesFolder: TLabeledEdit
    Left = 32
    Top = 23
    Width = 678
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 299
    EditLabel.Height = 13
    EditLabel.Caption = 'Debugger Databases Folder (where the ACCDB files are stored)'
    TabOrder = 0
    OnChange = FileChanged
  end
  object btnBrowseDebuggerDatabasesFolder: TButton
    Left = 725
    Top = 21
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseDebuggerDatabasesFolderClick
  end
  object leDatabaseReportsPath: TLabeledEdit
    Left = 32
    Top = 66
    Width = 678
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 257
    EditLabel.Height = 13
    EditLabel.Caption = 'Debugger Reports Path (where reports are generated) '
    TabOrder = 1
    OnChange = FileChanged
  end
  object btnBrowseForDebuggerDatabaasesPath: TButton
    Left = 725
    Top = 64
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 7
    OnClick = btnBrowseForDebuggerDatabaasesPathClick
  end
  object leDebuggingSettingsFolder: TLabeledEdit
    Left = 32
    Top = 110
    Width = 678
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 338
    EditLabel.Height = 13
    EditLabel.Caption = 
      'Debugging Settings Folder (where debugger settings INI files are' +
      ' stored)'
    Enabled = False
    TabOrder = 2
  end
  object btnDebuggingSettingsFolder: TButton
    Left = 725
    Top = 108
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    Enabled = False
    TabOrder = 8
    OnClick = btnDebuggingSettingsFolderClick
  end
  object leRootDBTextBackup: TLabeledEdit
    Left = 32
    Top = 158
    Width = 678
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 169
    EditLabel.Height = 13
    EditLabel.Caption = 'Root folder for DB Text backup files'
    TabOrder = 3
    OnChange = FileChanged
  end
  object btnRootDBTextBackup: TButton
    Left = 725
    Top = 156
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 9
    OnClick = btnDebuggingSettingsFolderClick
  end
  object sgDatabases: TStringGrid
    Left = 32
    Top = 232
    Width = 769
    Height = 121
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 4
    DefaultRowHeight = 18
    TabOrder = 10
  end
  object BuildDatabasesList: TButton
    Left = 32
    Top = 196
    Width = 121
    Height = 25
    Caption = 'Build Databases List'
    TabOrder = 11
    OnClick = BuildDatabasesListClick
  end
  object btnAdd: TButton
    Left = 104
    Top = 361
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Add'
    TabOrder = 12
    OnClick = btnAddClick
  end
  object btnDelete: TButton
    Left = 280
    Top = 361
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Delete'
    TabOrder = 13
    OnClick = btnDeleteClick
  end
  object btnReplace: TButton
    Left = 192
    Top = 361
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Edit'
    TabOrder = 14
    OnClick = btnReplaceClick
  end
  object btnBackup: TButton
    Left = 368
    Top = 361
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Backup'
    Enabled = False
    TabOrder = 15
  end
end
