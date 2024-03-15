inherited frmVolConverter: TfrmVolConverter
  Left = 764
  Top = 260
  Height = 554
  Anchors = [akLeft, akTop, akRight]
  Caption = 'Volume Converter'
  DesignSize = (
    705
    515)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Label1: TLabel
    Left = 299
    Top = 78
  end
  inherited Label2: TLabel
    Left = 446
    Top = 78
  end
  inherited lblBytesPerSector: TLabel
    Left = 26
    Top = 78
  end
  inherited Label3: TLabel
    Left = 165
    Top = 78
  end
  inherited lblStatus: TLabel
    Top = 503
  end
  inherited Label7: TLabel
    Left = 25
    Top = 49
    Enabled = False
  end
  object lblNrTracks: TLabel [7]
    Left = 521
    Top = 99
    Width = 54
    Height = 13
    Alignment = taRightJustify
    Caption = 'lblNrTracks'
  end
  object lblNrBlocks: TLabel [8]
    Left = 522
    Top = 115
    Width = 53
    Height = 13
    Alignment = taRightJustify
    Caption = 'lblNrBlocks'
  end
  inherited ovcBaseTrackNumber: TOvcNumericField
    Left = 402
    Top = 74
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  inherited ovcNumberOfTracks: TOvcNumericField
    Left = 540
    Top = 74
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  inherited ovcBytesPerSector: TOvcNumericField
    Left = 104
    Top = 74
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  inherited ovcSectorsPerTrack: TOvcNumericField
    Left = 249
    Top = 74
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  inherited btnCancel: TButton
    Top = 484
  end
  inherited btnOK: TButton
    Top = 484
    Caption = '&Begin'
  end
  inherited cbDiskFormat: TComboBox
    OnChange = RecalcStuff
  end
  inherited lbAlgorithm: TComboBox
    Left = 103
    Top = 47
    Enabled = False
  end
  inherited pnlAlgorithm: TPanel
    Left = 9
    Top = 92
    Width = 400
    Height = 29
    inherited Label4: TLabel
      Left = 17
      Top = 10
    end
    inherited Label5: TLabel
      Left = 145
      Top = 10
    end
    inherited ovcSectorInterleave: TOvcNumericField
      Left = 104
      Top = 6
      RangeHigh = {FFFFFF7F000000000000}
      RangeLow = {00000080000000000000}
    end
    inherited ovcTrackToTrackSkew: TOvcNumericField
      Left = 249
      Top = 7
      RangeHigh = {FFFFFF7F000000000000}
      RangeLow = {00000080000000000000}
    end
  end
  object leInputFileName: TLabeledEdit
    Left = 16
    Top = 141
    Width = 595
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 74
    EditLabel.Height = 13
    EditLabel.Caption = 'Input File Name'
    TabOrder = 10
    Text = 'F:\NDAS-I\d7\Projects\pSystem\Z80EM2010\15SYS1'
    OnExit = ovcBytesPerSectorChange
  end
  object btnBrowseInputFile: TButton
    Left = 618
    Top = 142
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 11
    OnClick = btnBrowseInputFileClick
  end
  object leOutputFileName: TLabeledEdit
    Left = 16
    Top = 181
    Width = 595
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 82
    EditLabel.Height = 13
    EditLabel.Caption = 'Output File Name'
    TabOrder = 12
    Text = 'F:\NDAS-I\d7\Projects\pSystem\Z80EM2010\15SYS1'
    OnExit = ovcBytesPerSectorChange
  end
  object btnBrowseOutputFolder: TButton
    Left = 618
    Top = 179
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 13
    OnClick = btnBrowseOutputFolderClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 211
    Width = 680
    Height = 267
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    TabOrder = 14
  end
  object rbOtherToVol: TRadioButton
    Left = 528
    Top = 18
    Width = 113
    Height = 17
    Caption = 'Other To Vol'
    TabOrder = 15
    OnClick = rbOtherToVolClick
  end
  object rbVolToOther: TRadioButton
    Left = 528
    Top = 41
    Width = 113
    Height = 17
    Caption = 'Vol To Other'
    Checked = True
    TabOrder = 16
    TabStop = True
    OnClick = rbVolToOtherClick
  end
  object cbListTracksSectors: TCheckBox
    Left = 24
    Top = 483
    Width = 121
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'List Tracks Sectors'
    Enabled = False
    TabOrder = 17
  end
  object cbDebugging: TCheckBox
    Left = 160
    Top = 483
    Width = 161
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Debugging - do not write'
    TabOrder = 18
  end
end
