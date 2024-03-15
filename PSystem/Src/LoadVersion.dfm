object frmLoadVersion: TfrmLoadVersion
  Left = 591
  Top = 281
  Width = 747
  Height = 463
  Caption = 'Load Version'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  DesignSize = (
    731
    424)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 33
    Top = 227
    Width = 132
    Height = 13
    Caption = 'Boot Volume File Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 32
    Top = 357
    Width = 133
    Height = 13
    Caption = 'Last Booted Date/Time'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblLastBootedDateTime: TLabel
    Left = 173
    Top = 357
    Width = 110
    Height = 13
    Caption = 'lblLastBootedDateTime'
  end
  object Label4: TLabel
    Left = 32
    Top = 293
    Width = 74
    Height = 13
    Caption = 'VolumeName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblVolumeName: TLabel
    Left = 138
    Top = 293
    Width = 87
    Height = 13
    Caption = 'lblVolumeName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblSettingsFileToUse: TLabel
    Left = 33
    Top = 255
    Width = 151
    Height = 13
    Caption = 'Debug Settings File to use'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 32
    Top = 322
    Width = 52
    Height = 13
    Caption = 'Comment'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 32
    Top = 199
    Width = 101
    Height = 13
    Caption = 'Boot Unit Number'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblFileDoesNotExist: TLabel
    Left = 400
    Top = 275
    Width = 89
    Height = 13
    Alignment = taCenter
    Caption = 'File Does Not Exist'
    Color = clYellow
    ParentColor = False
  end
  object lblVolumesToMount: TLabel
    Left = 339
    Top = 185
    Width = 384
    Height = 37
    AutoSize = False
    Caption = 'lblVolumesToMount'
    WordWrap = True
  end
  object rgDerivation: TRadioGroup
    Left = 32
    Top = 8
    Width = 679
    Height = 65
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Derivation'
    Items.Strings = (
      'Load Laurence Boshell derived version'
      'Load Peter Miller derived version')
    TabOrder = 0
    OnClick = rgDerivationClick
  end
  object rgVersion: TRadioGroup
    Left = 32
    Top = 80
    Width = 557
    Height = 103
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Version'
    Columns = 2
    TabOrder = 1
    OnClick = rgVersionClick
    OnExit = DoOnFieldExit
  end
  object btnBoot: TButton
    Left = 548
    Top = 393
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Boot'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnBootClick
  end
  object btnCancel: TButton
    Left = 636
    Top = 393
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object edtFilePath: TEdit
    Left = 170
    Top = 225
    Width = 468
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    OnExit = DoOnFieldExit
  end
  object pnlNavigate: TPanel
    Left = 29
    Top = 380
    Width = 260
    Height = 36
    Anchors = [akLeft, akBottom]
    BevelOuter = bvNone
    TabOrder = 7
    Visible = False
    object btnPrev: TButton
      Left = 5
      Top = 5
      Width = 53
      Height = 25
      Caption = 'Prev'
      TabOrder = 0
      OnClick = btnPrevClick
    end
    object btnNext: TButton
      Left = 68
      Top = 5
      Width = 53
      Height = 25
      Caption = 'Next'
      TabOrder = 1
      OnClick = btnNextClick
    end
    object btnAdd: TButton
      Left = 131
      Top = 5
      Width = 53
      Height = 25
      Caption = 'Add'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnDelete: TButton
      Left = 197
      Top = 5
      Width = 53
      Height = 25
      Caption = 'Delete'
      TabOrder = 3
      OnClick = btnDeleteClick
    end
  end
  object edtSettingsFileToUse: TEdit
    Left = 197
    Top = 254
    Width = 441
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
    OnExit = DoOnFieldExit
  end
  object btnBrowseFilePath: TButton
    Left = 647
    Top = 222
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 6
    OnClick = btnBrowseFilePathClick
  end
  object edtComment: TEdit
    Left = 138
    Top = 318
    Width = 391
    Height = 21
    TabOrder = 9
  end
  object cbUnitNumber: TComboBox
    Left = 138
    Top = 196
    Width = 71
    Height = 21
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ItemHeight = 13
    ParentFont = False
    TabOrder = 2
    OnChange = cbUnitNumberChange
    OnExit = DoOnFieldExit
  end
  object btnSave: TButton
    Left = 460
    Top = 393
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Save'
    ModalResult = -1
    TabOrder = 10
    OnClick = btnSaveClick
  end
  object btnBrowseSettingsFileToUse: TButton
    Left = 648
    Top = 252
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 11
    OnClick = btnBrowseSettingsFileToUseClick
  end
  object btnVolumesToMount: TButton
    Left = 217
    Top = 194
    Width = 113
    Height = 25
    Caption = 'Volumes to Mount'
    TabOrder = 12
    OnClick = btnVolumesToMountClick
  end
  object cbIsDebugging: TCheckBox
    Left = 600
    Top = 96
    Width = 97
    Height = 17
    Caption = 'Is Debugging'
    TabOrder = 13
  end
end
