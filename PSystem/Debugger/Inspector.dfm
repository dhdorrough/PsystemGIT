inherited frmInspect: TfrmInspect
  Left = 1047
  Top = 155
  Width = 392
  Height = 490
  BorderStyle = bsSizeable
  Caption = 'Inspect'
  Position = poDesigned
  Scaled = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Width = 376
    Height = 451
    Align = alClient
    OnResize = Panel1Resize
    inherited lblHexVal: TLabel
      Left = 236
    end
    inherited lblDescription: TLabel
      Width = 198
      WordWrap = True
    end
    object lblStatus: TLabel [9]
      Left = 16
      Top = 434
      Width = 40
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'lblStatus'
    end
    object lblPrefixInfo: TLabel [10]
      Left = 313
      Top = 168
      Width = 54
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'lblPrefixInfo'
    end
    inherited cbWatchType: TComboBox
      Width = 115
      Anchors = [akLeft, akTop, akRight]
    end
    inherited ovcWatchParam: TOvcNumericField
      RangeHigh = {00000100000000000000}
      RangeLow = {FFFFFFFF000000000000}
    end
    inherited edtComment: TEdit
      Width = 244
    end
    inherited edtWatchName: TEdit
      Width = 244
    end
    inherited cbWatchAddress: TComboBox
      Left = 127
      Width = 102
    end
    inherited cbFreeze: TCheckBox
      Left = 315
    end
    inherited cbWatchIndirect: TCheckBox
      Left = 309
      Width = 59
      Anchors = [akTop, akRight]
    end
    object sgValues: TStringGrid
      Left = 16
      Top = 192
      Width = 352
      Height = 240
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 3
      DefaultRowHeight = 18
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      TabOrder = 7
      OnDrawCell = sgValuesDrawCell
      ColWidths = (
        43
        64
        293)
    end
  end
end
