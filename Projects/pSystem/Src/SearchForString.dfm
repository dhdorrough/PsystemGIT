object frmSearchForString: TfrmSearchForString
  Left = 1127
  Top = 566
  BorderStyle = bsDialog
  Caption = 'Search for String'
  ClientHeight = 319
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    536
    319)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 32
    Top = 289
    Width = 40
    Height = 13
    Caption = 'lblStatus'
  end
  object lblMode: TLabel
    Left = 39
    Top = 168
    Width = 68
    Height = 13
    Caption = 'ASCII string'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnCancel: TButton
    Left = 440
    Top = 271
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 344
    Top = 271
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 4
  end
  object leLowDate: TLabeledEdit
    Left = 36
    Top = 128
    Width = 89
    Height = 21
    EditLabel.Width = 55
    EditLabel.Height = 13
    EditLabel.Caption = 'Low Date'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'MS Sans Serif'
    EditLabel.Font.Style = [fsBold]
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object leHighDate: TLabeledEdit
    Left = 156
    Top = 128
    Width = 89
    Height = 21
    EditLabel.Width = 58
    EditLabel.Height = 13
    EditLabel.Caption = 'High Date'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'MS Sans Serif'
    EditLabel.Font.Style = [fsBold]
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object pnlAsciiSearch: TPanel
    Left = 32
    Top = 201
    Width = 489
    Height = 57
    TabOrder = 5
    object cbCaseSensitive: TCheckBox
      Left = 156
      Top = 30
      Width = 97
      Height = 17
      Caption = 'Case Sensitive'
      TabOrder = 3
    end
    object cbIgnoreUnderScores: TCheckBox
      Left = 16
      Top = 6
      Width = 129
      Height = 17
      Caption = 'Ignore Under_Scores'
      TabOrder = 2
    end
    object cbOnlySearchFileNames: TCheckBox
      Left = 16
      Top = 31
      Width = 132
      Height = 17
      Caption = 'Only Search File Names'
      TabOrder = 0
    end
    object cbKeywordSearch: TCheckBox
      Left = 156
      Top = 6
      Width = 113
      Height = 17
      Caption = 'Key Word Search'
      TabOrder = 1
      OnClick = cbKeywordSearchClick
    end
    object pnlKeyType: TPanel
      Left = 296
      Top = 3
      Width = 115
      Height = 23
      BevelOuter = bvNone
      TabOrder = 4
      Visible = False
      object rbAll: TRadioButton
        Left = 25
        Top = 2
        Width = 38
        Height = 17
        Caption = 'All'
        TabOrder = 0
      end
      object rbAny: TRadioButton
        Left = 73
        Top = 2
        Width = 38
        Height = 17
        Caption = 'Any'
        TabOrder = 1
      end
    end
    object cbWildMatch: TCheckBox
      Left = 272
      Top = 30
      Width = 103
      Height = 17
      Caption = 'Wild Match (*, ?)'
      TabOrder = 5
    end
  end
  object cbLogMountingErrors: TCheckBox
    Left = 272
    Top = 129
    Width = 121
    Height = 17
    Caption = 'Log Mounting Errors'
    TabOrder = 6
  end
  object edtSearchFor: TEdit
    Left = 165
    Top = 164
    Width = 354
    Height = 21
    TabOrder = 0
  end
  object rgMode: TRadioGroup
    Left = 32
    Top = 8
    Width = 489
    Height = 97
    Caption = 'Search For'
    Columns = 2
    TabOrder = 7
    OnClick = rgModeClick
  end
end
