object frmGetHexAddress: TfrmGetHexAddress
  Left = 907
  Top = 169
  Width = 337
  Height = 220
  Caption = 'Get Address'
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
    EditLabel.Width = 38
    EditLabel.Height = 13
    EditLabel.Caption = 'Address'
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 216
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
