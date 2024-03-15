inherited frmWatch: TfrmWatch
  Left = 974
  Top = 312
  Caption = 'Watch'
  ClientHeight = 384
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    inherited lblDescription: TLabel
      WordWrap = True
    end
    inherited ovcWatchParam: TOvcNumericField
      RangeHigh = {00000100000000000000}
      RangeLow = {FFFFFFFF000000000000}
    end
    inherited cbWatchAddress: TComboBox
      OnChange = ovcWatchAddrChange
    end
    inherited cbFreeze: TCheckBox
      TabOrder = 6
    end
    inherited cbWatchIndirect: TCheckBox
      TabOrder = 7
    end
    object mmoWatchValue: TMemo
      Left = 15
      Top = 184
      Width = 382
      Height = 62
      Anchors = [akLeft, akTop, akRight, akBottom]
      Lines.Strings = (
        'mmoWatchValue')
      TabOrder = 5
    end
  end
  object Button1: TButton
    Left = 328
    Top = 352
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object Button2: TButton
    Left = 240
    Top = 352
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end
