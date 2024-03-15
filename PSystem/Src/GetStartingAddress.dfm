object frmGetStartingAddress: TfrmGetStartingAddress
  Left = 752
  Top = 415
  BorderStyle = bsDialog
  Caption = 'Get Starting Address'
  ClientHeight = 192
  ClientWidth = 295
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object leStartingAddress: TLabeledEdit
    Left = 24
    Top = 24
    Width = 121
    Height = 21
    EditLabel.Width = 175
    EditLabel.Height = 13
    EditLabel.Caption = 'Starting Address ($XXXX or NNNNN)'
    TabOrder = 0
  end
  object cbUseDecimalOffsets: TCheckBox
    Left = 24
    Top = 81
    Width = 123
    Height = 17
    Caption = 'Use Decimal Offsets'
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 124
    Top = 156
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 210
    Top = 156
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object rbAsAddress: TRadioButton
    Left = 24
    Top = 56
    Width = 89
    Height = 17
    Caption = 'As Address'
    Checked = True
    TabOrder = 4
    TabStop = True
  end
  object rbAsOffset: TRadioButton
    Left = 112
    Top = 56
    Width = 89
    Height = 17
    Caption = 'As Offset'
    TabOrder = 5
  end
  object leFormsToUse: TLabeledEdit
    Left = 24
    Top = 120
    Width = 121
    Height = 21
    EditLabel.Width = 185
    EditLabel.Height = 13
    EditLabel.Caption = 'Forms to use (A(scii,B(ytes,W(ords,F(lip)'
    TabOrder = 6
  end
end
