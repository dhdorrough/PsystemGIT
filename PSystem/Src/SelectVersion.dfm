object frmSelectVersion: TfrmSelectVersion
  Left = 931
  Top = 283
  Width = 413
  Height = 292
  Caption = 'Select Version'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    405
    261)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 199
    Height = 13
    Caption = 'What p-System version is on unit #'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblUnitNr: TLabel
    Left = 219
    Top = 8
    Width = 50
    Height = 13
    Caption = 'lblUnitNr'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblVolumeName: TLabel
    Left = 22
    Top = 32
    Width = 73
    Height = 13
    Caption = 'lblVolumeName'
  end
  object rgVersion: TRadioGroup
    Left = 16
    Top = 55
    Width = 369
    Height = 154
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Version'
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 230
    Top = 219
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button1: TButton
    Left = 318
    Top = 219
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
