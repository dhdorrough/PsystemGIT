object frmFileParameters: TfrmFileParameters
  Left = 781
  Top = 660
  Width = 711
  Height = 356
  Caption = 'Debugger Database Utilities'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    695
    317)
  PixelsPerInch = 96
  TextHeight = 13
  object btnBegin: TButton
    Left = 612
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 524
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'OK'
    Enabled = False
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOKClick
  end
  object rgDBOptions: TRadioGroup
    Left = 16
    Top = 232
    Width = 289
    Height = 78
    Caption = 'DB Options'
    ItemIndex = 2
    Items.Strings = (
      'Do not overwrite'
      'OK to overwrite pre-existing records in DB'
      'Ask before overwriting')
    TabOrder = 2
  end
  object rgVersionNr: TRadioGroup
    Left = 604
    Top = 32
    Width = 88
    Height = 137
    Caption = 'Version Nr'
    ItemIndex = 2
    Items.Strings = (
      'Unknown'
      'Version I.4'
      'Version I.5'
      'Version II'
      'Version IV')
    TabOrder = 3
    OnClick = rgVersionNrClick
  end
  object pnlInputListingFile: TPanel
    Left = 8
    Top = 5
    Width = 586
    Height = 41
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      586
      41)
    object leFile1Name: TLabeledEdit
      Left = 3
      Top = 16
      Width = 508
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 76
      EditLabel.Height = 13
      EditLabel.Caption = 'Input Listing File'
      TabOrder = 0
      OnChange = leFile1NameExit
      OnExit = leFile1NameExit
    end
    object BtnBrowse1: TButton
      Left = 520
      Top = 14
      Width = 63
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Browse'
      TabOrder = 1
      OnClick = BtnBrowse1Click
    end
  end
  object pnlDBFile: TPanel
    Left = 8
    Top = 48
    Width = 586
    Height = 41
    BevelOuter = bvNone
    TabOrder = 5
    DesignSize = (
      586
      41)
    object leDBFileName: TLabeledEdit
      Left = 3
      Top = 16
      Width = 505
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 34
      EditLabel.Height = 13
      EditLabel.Caption = 'DB File'
      TabOrder = 0
      OnChange = leDBFileNameExit
      OnExit = leDBFileNameExit
    end
    object btnBrowseDB: TButton
      Left = 520
      Top = 14
      Width = 63
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Browse'
      TabOrder = 1
      OnClick = btnBrowseDBClick
    end
  end
  object pnlReportFileName: TPanel
    Left = 8
    Top = 94
    Width = 586
    Height = 58
    BevelOuter = bvNone
    TabOrder = 6
    DesignSize = (
      586
      58)
    object leOutputFileName: TLabeledEdit
      Left = 3
      Top = 15
      Width = 505
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 82
      EditLabel.Height = 13
      EditLabel.Caption = 'Report File Name'
      TabOrder = 0
      OnChange = leOutputFileNameChange
      OnExit = leOutputFileNameChange
    end
    object btnBrowseOutput: TButton
      Left = 520
      Top = 13
      Width = 63
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Browse'
      TabOrder = 1
      OnClick = btnBrowseOutputClick
    end
    object rbAsCompilerListing: TRadioButton
      Left = 16
      Top = 38
      Width = 113
      Height = 17
      Caption = 'As Compiler Listing'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
    object rbAsCompilerSource: TRadioButton
      Left = 136
      Top = 38
      Width = 113
      Height = 17
      Caption = 'As Compiler Source'
      TabOrder = 3
    end
  end
  object pnlReportsFolder: TPanel
    Left = 8
    Top = 158
    Width = 586
    Height = 65
    BevelOuter = bvNone
    TabOrder = 7
    DesignSize = (
      586
      65)
    object leReportsPath: TLabeledEdit
      Left = 3
      Top = 16
      Width = 505
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Reports Folder'
      TabOrder = 0
      OnChange = leReportsPathChange
    end
    object btnBrowseReportsFolder: TButton
      Left = 520
      Top = 14
      Width = 63
      Height = 25
      Caption = 'Browse'
      TabOrder = 1
      OnClick = btnBrowseReportsFolderClick
    end
    object cbGenerateOutputFiles: TCheckBox
      Left = 24
      Top = 44
      Width = 193
      Height = 17
      Caption = 'Generate .CSV for each version'
      TabOrder = 2
    end
  end
  object cbEraseSourceCodeAndProcedureName: TCheckBox
    Left = 320
    Top = 240
    Width = 121
    Height = 17
    Caption = 'Erase Source Code'
    TabOrder = 8
  end
  object cbErasePCode: TCheckBox
    Left = 320
    Top = 272
    Width = 97
    Height = 17
    Caption = 'Erase P-Code'
    TabOrder = 9
  end
end
