object frmGuessOptions: TfrmGuessOptions
  Left = 1269
  Top = 273
  Width = 432
  Height = 259
  Caption = 'Guess Options'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    424
    228)
  PixelsPerInch = 96
  TextHeight = 13
  object leVolumeToTest: TLabeledEdit
    Left = 16
    Top = 24
    Width = 317
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 71
    EditLabel.Height = 13
    EditLabel.Caption = 'Volume to Test'
    TabOrder = 0
    OnChange = leVolumeToTestChange
  end
  object btnBrowse: TButton
    Left = 341
    Top = 22
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object GroupBox1: TGroupBox
    Left = 24
    Top = 64
    Width = 377
    Height = 105
    Caption = 'Options'
    TabOrder = 2
    object cbRequireValidTextFiles: TCheckBox
      Left = 16
      Top = 24
      Width = 137
      Height = 17
      Caption = 'Require Valid Text Files'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbRequireValidCodeFiles: TCheckBox
      Left = 16
      Top = 48
      Width = 169
      Height = 17
      Caption = 'Require Valid Code Files'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object btnCancel: TBitBtn
    Left = 328
    Top = 187
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    TabOrder = 3
    OnClick = btnCancelClick
    Kind = bkCancel
  end
  object btnBegin: TBitBtn
    Left = 240
    Top = 187
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Begin'
    TabOrder = 4
    OnClick = btnBeginClick
    Kind = bkOK
  end
end
