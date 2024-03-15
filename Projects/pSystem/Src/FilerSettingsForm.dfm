object frmFilerSettings: TfrmFilerSettings
  Left = 744
  Top = 522
  Width = 643
  Height = 386
  Caption = 'Filer Settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    627
    347)
  PixelsPerInch = 96
  TextHeight = 13
  object leSearchFolder: TLabeledEdit
    Left = 32
    Top = 58
    Width = 487
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = 'Search Folder'
    TabOrder = 2
  end
  object leVolumesFolder: TLabeledEdit
    Left = 32
    Top = 98
    Width = 487
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = 'Volumes Folder'
    TabOrder = 4
  end
  object leLogFileName: TLabeledEdit
    Left = 32
    Top = 175
    Width = 487
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 65
    EditLabel.Height = 13
    EditLabel.Caption = 'Log FileName'
    TabOrder = 6
  end
  object lePrinterLfn: TLabeledEdit
    Left = 32
    Top = 215
    Width = 487
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 75
    EditLabel.Height = 13
    EditLabel.Caption = 'Printer Filename'
    TabOrder = 8
    OnChange = lePrinterLfnChange
  end
  object btnCancel: TBitBtn
    Left = 534
    Top = 313
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 13
  end
  object btnOk: TBitBtn
    Left = 446
    Top = 313
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 14
    OnClick = btnOkClick
  end
  object btnBrowseSearchFolder: TButton
    Left = 534
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 3
    OnClick = btnBrowseSearchFolderClick
  end
  object btnBrowseVolumesFolder: TButton
    Left = 534
    Top = 96
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 5
    OnClick = btnBrowseVolumesFolderClick
  end
  object btnBrowseLogFileName: TButton
    Left = 534
    Top = 173
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 7
    OnClick = btnBrowseLogFileNameClick
  end
  object btnBrowsePrinterLfn: TButton
    Left = 534
    Top = 213
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 10
    OnClick = btnBrowsePrinterLfnClick
  end
  object leReportsPath: TLabeledEdit
    Left = 32
    Top = 18
    Width = 487
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 62
    EditLabel.Height = 13
    EditLabel.Caption = 'Reports Path'
    TabOrder = 0
  end
  object btnReportsPath: TButton
    Left = 534
    Top = 16
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnReportsPathClick
  end
  object leEditorFilePathName: TLabeledEdit
    Left = 32
    Top = 283
    Width = 487
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 101
    EditLabel.Height = 13
    EditLabel.Caption = 'Editor FilePath/Name'
    TabOrder = 11
  end
  object btnEditorFilePathName: TButton
    Left = 534
    Top = 281
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 12
    OnClick = btnEditorFilePathNameClick
  end
  object cbAutoEdit: TCheckBox
    Left = 56
    Top = 245
    Width = 257
    Height = 17
    Caption = 'Automatically Edit Printer File After It Is Closed'
    TabOrder = 9
  end
end
