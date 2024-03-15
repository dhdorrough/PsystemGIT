object frmRawParameters: TfrmRawParameters
  Left = 611
  Top = 347
  Width = 830
  Height = 310
  Caption = 'Raw File Parameters'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    822
    279)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 731
    Top = 238
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object leRawInputFileName: TLabeledEdit
    Left = 32
    Top = 24
    Width = 665
    Height = 21
    EditLabel.Width = 68
    EditLabel.Height = 13
    EditLabel.Caption = 'Raw Input File'
    TabOrder = 1
  end
  object leRawOutputFileName: TLabeledEdit
    Left = 32
    Top = 64
    Width = 665
    Height = 21
    EditLabel.Width = 76
    EditLabel.Height = 13
    EditLabel.Caption = 'Raw Output File'
    TabOrder = 2
  end
  object btnBegin: TButton
    Left = 640
    Top = 238
    Width = 75
    Height = 25
    Caption = 'Begin'
    ModalResult = 1
    TabOrder = 3
  end
  object leStringToSearchFor: TLabeledEdit
    Left = 32
    Top = 104
    Width = 665
    Height = 21
    EditLabel.Width = 91
    EditLabel.Height = 13
    EditLabel.Caption = 'String to Search for'
    TabOrder = 4
  end
  object leStartingBlockNr: TLabeledEdit
    Left = 32
    Top = 144
    Width = 121
    Height = 21
    EditLabel.Width = 63
    EditLabel.Height = 13
    EditLabel.Caption = 'StartingBlock'
    TabOrder = 5
  end
  object leNrBlocksToCopy: TLabeledEdit
    Left = 176
    Top = 144
    Width = 121
    Height = 21
    EditLabel.Width = 85
    EditLabel.Height = 13
    EditLabel.Caption = 'Nr Blocks to Copy'
    TabOrder = 6
  end
end
