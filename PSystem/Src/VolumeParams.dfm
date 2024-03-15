object frmVolumeParams: TfrmVolumeParams
  Left = 558
  Top = 266
  Width = 721
  Height = 231
  Caption = 'Volume Params'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    713
    200)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 315
    Top = 66
    Width = 95
    Height = 13
    Caption = 'Base Track Number'
  end
  object Label2: TLabel
    Left = 462
    Top = 66
    Width = 85
    Height = 13
    Caption = 'Number of Tracks'
  end
  object lblBytesPerSector: TLabel
    Left = 42
    Top = 66
    Width = 68
    Height = 13
    Caption = 'Bytes / Sector'
  end
  object Label3: TLabel
    Left = 181
    Top = 66
    Width = 75
    Height = 13
    Caption = 'Sectors / Track'
  end
  object Label6: TLabel
    Left = 25
    Top = 5
    Width = 56
    Height = 13
    Caption = 'Disk Format'
  end
  object lblStatus: TLabel
    Left = 24
    Top = 169
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object Label7: TLabel
    Left = 34
    Top = 144
    Width = 43
    Height = 13
    Caption = 'Algorithm'
  end
  object ovcBaseTrackNumber: TOvcNumericField
    Left = 418
    Top = 62
    Width = 33
    Height = 21
    Cursor = crIBeam
    DataType = nftLongInt
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = 'ii'
    TabOrder = 4
    AfterExit = ovcBytesPerSectorChange
    OnChange = ovcBytesPerSectorChange
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000000000000000000}
  end
  object ovcNumberOfTracks: TOvcNumericField
    Left = 556
    Top = 62
    Width = 33
    Height = 21
    Cursor = crIBeam
    DataType = nftLongInt
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = 'iii'
    TabOrder = 5
    AfterExit = ovcBytesPerSectorChange
    OnChange = ovcBytesPerSectorChange
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000000000000000000}
  end
  object ovcBytesPerSector: TOvcNumericField
    Left = 120
    Top = 62
    Width = 33
    Height = 21
    Cursor = crIBeam
    DataType = nftLongInt
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = 'iii'
    TabOrder = 2
    AfterExit = ovcBytesPerSectorChange
    OnChange = ovcBytesPerSectorChange
    RangeHigh = {00080000000000000000}
    RangeLow = {00000000000000000000}
  end
  object ovcSectorsPerTrack: TOvcNumericField
    Left = 265
    Top = 62
    Width = 33
    Height = 21
    Cursor = crIBeam
    DataType = nftLongInt
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = 'iii'
    TabOrder = 3
    AfterExit = ovcBytesPerSectorChange
    OnChange = ovcBytesPerSectorChange
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000000000000000000}
  end
  object btnCancel: TButton
    Left = 616
    Top = 161
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 6
  end
  object btnOK: TButton
    Left = 520
    Top = 161
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Enabled = False
    ModalResult = 1
    TabOrder = 7
    OnClick = btnOKClick
  end
  object cbDiskFormat: TComboBox
    Left = 24
    Top = 24
    Width = 353
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    OnClick = cbDiskFormatClick
  end
  object leFileNameExtension: TLabeledEdit
    Left = 400
    Top = 24
    Width = 49
    Height = 21
    EditLabel.Width = 96
    EditLabel.Height = 13
    EditLabel.Caption = 'File Name Extension'
    TabOrder = 1
  end
  object lbAlgorithm: TComboBox
    Left = 120
    Top = 140
    Width = 117
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 8
    Text = 'Standard'
    Items.Strings = (
      'Standard'
      'Apple II')
  end
  object pnlAlgorithm: TPanel
    Left = 25
    Top = 88
    Width = 361
    Height = 41
    BevelOuter = bvNone
    TabOrder = 9
    object Label4: TLabel
      Left = 16
      Top = 12
      Width = 81
      Height = 13
      Caption = 'Sector Interleave'
    end
    object Label5: TLabel
      Left = 147
      Top = 12
      Width = 95
      Height = 13
      Caption = 'Track-to-track skew'
    end
    object ovcSectorInterleave: TOvcNumericField
      Left = 103
      Top = 8
      Width = 33
      Height = 21
      Cursor = crIBeam
      DataType = nftLongInt
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = 'iii'
      TabOrder = 0
      RangeHigh = {FFFFFF7F000000000000}
      RangeLow = {00000080000000000000}
    end
    object ovcTrackToTrackSkew: TOvcNumericField
      Left = 248
      Top = 9
      Width = 33
      Height = 21
      Cursor = crIBeam
      DataType = nftLongInt
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = 'iii'
      TabOrder = 1
      RangeHigh = {FFFFFF7F000000000000}
      RangeLow = {00000080000000000000}
    end
  end
end
