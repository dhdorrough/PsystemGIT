object frmBlockParams: TfrmBlockParams
  Left = 716
  Top = 329
  Width = 589
  Height = 259
  Caption = 'Copy Block Range to Text File'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    573
    220)
  PixelsPerInch = 96
  TextHeight = 13
  object leStartingBlock: TLabeledEdit
    Left = 32
    Top = 32
    Width = 105
    Height = 21
    EditLabel.Width = 76
    EditLabel.Height = 13
    EditLabel.Caption = 'Starting Block #'
    TabOrder = 0
  end
  object leNumberOfBlocks: TLabeledEdit
    Left = 32
    Top = 72
    Width = 121
    Height = 21
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = 'Number of Blocks'
    TabOrder = 1
  end
  object leDOSFilePathName: TLabeledEdit
    Left = 32
    Top = 112
    Width = 449
    Height = 21
    EditLabel.Width = 100
    EditLabel.Height = 13
    EditLabel.Caption = 'DOS Path\File Name'
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 464
    Top = 174
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 3
  end
  object btnBegin: TButton
    Left = 368
    Top = 174
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Begin'
    ModalResult = 1
    TabOrder = 4
  end
  object btnBrowse: TButton
    Left = 488
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 5
    OnClick = btnBrowseClick
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Left = 512
    Top = 72
  end
end
