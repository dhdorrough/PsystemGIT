object frmDumpAddr: TfrmDumpAddr
  Left = 779
  Top = 207
  Width = 268
  Height = 148
  Caption = 'Params'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    260
    117)
  PixelsPerInch = 96
  TextHeight = 13
  object lblAddressX: TLabel
    Left = 13
    Top = 28
    Width = 46
    Height = 13
    Caption = 'Address'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblHexVal: TLabel
    Left = 176
    Top = 27
    Width = 65
    Height = 13
    Caption = 'Use $ for Hex'
  end
  object lblHex: TLabel
    Left = 64
    Top = 48
    Width = 29
    Height = 13
    Caption = 'lblHex'
  end
  object cbWatchAddress: TEdit
    Left = 64
    Top = 23
    Width = 104
    Height = 21
    TabOrder = 0
    Text = '0'
    OnChange = cbWatchAddressChange
  end
  object btnOK: TButton
    Left = 152
    Top = 80
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Cancel: TButton
    Left = 56
    Top = 79
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
