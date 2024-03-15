object frmDecodeRange: TfrmDecodeRange
  Left = 632
  Top = 249
  Width = 337
  Height = 220
  Caption = 'Decode Range'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object leStartingAddress: TLabeledEdit
    Left = 16
    Top = 32
    Width = 121
    Height = 21
    EditLabel.Width = 142
    EditLabel.Height = 13
    EditLabel.Caption = 'Starting Address ($hex or dec)'
    TabOrder = 0
  end
  object leNrBytes: TLabeledEdit
    Left = 16
    Top = 112
    Width = 121
    Height = 21
    EditLabel.Width = 105
    EditLabel.Height = 13
    EditLabel.Caption = 'Nr Bytes ($hex or dec)'
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 216
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object cbStopAfterRPU: TCheckBox
    Left = 16
    Top = 72
    Width = 97
    Height = 17
    Caption = 'Stop after RPU'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object cbExitAfterDecode: TCheckBox
    Left = 144
    Top = 72
    Width = 113
    Height = 17
    Caption = 'Exit After Decode'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
end
