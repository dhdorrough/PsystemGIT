object frmCompareVolumes: TfrmCompareVolumes
  Left = 644
  Top = 276
  Width = 711
  Height = 483
  Caption = 'Compare Volumes'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    703
    452)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 44
    Height = 13
    Caption = 'Volume 1'
  end
  object Label2: TLabel
    Left = 336
    Top = 8
    Width = 44
    Height = 13
    Caption = 'Volume 2'
  end
  object btnBegin: TButton
    Left = 608
    Top = 416
    Width = 75
    Height = 25
    Caption = 'Begin'
    TabOrder = 0
    OnClick = btnBeginClick
  end
  object PageControl1: TPageControl
    Left = 24
    Top = 104
    Width = 657
    Height = 305
    ActivePage = tabFileDates
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object tabFileDates: TTabSheet
      Caption = 'File Dates'
      object StringGrid1: TStringGrid
        Left = 0
        Top = 0
        Width = 649
        Height = 277
        Align = alClient
        ColCount = 6
        RowCount = 2
        FixedRows = 0
        TabOrder = 0
      end
    end
  end
  object ComboBox1: TComboBox
    Left = 25
    Top = 24
    Width = 297
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    Items.Strings = (
      '4'
      '5'
      '9'
      '10'
      '11'
      '12'
      '13')
  end
  object ComboBox2: TComboBox
    Left = 337
    Top = 24
    Width = 297
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      '4'
      '5'
      '9'
      '10'
      '11'
      '12'
      '13')
  end
  object cbOnlyMismatched: TCheckBox
    Left = 24
    Top = 424
    Width = 193
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Only Show Mis-matched Entries'
    TabOrder = 4
  end
  object Button1: TButton
    Left = 296
    Top = 56
    Width = 75
    Height = 25
    Caption = '<==>'
    TabOrder = 5
    OnClick = Button1Click
  end
end
