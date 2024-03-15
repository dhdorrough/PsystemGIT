object frmWatchInfo: TfrmWatchInfo
  Left = 898
  Top = 266
  BorderStyle = bsDialog
  Caption = 'Watch Info'
  ClientHeight = 342
  ClientWidth = 413
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 16
    Top = 320
    Width = 40
    Height = 13
    Caption = 'lblStatus'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 413
    Height = 252
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      413
      252)
    object Label1: TLabel
      Left = 13
      Top = 16
      Width = 70
      Height = 13
      Caption = 'Watch Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 13
      Top = 109
      Width = 87
      Height = 13
      Caption = 'Watch Address'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblWatchCode: TLabel
      Left = 88
      Top = 16
      Width = 30
      Height = 13
      Caption = 'Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 13
      Top = 140
      Width = 99
      Height = 13
      Caption = 'Watch Parameter'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 13
      Top = 78
      Width = 52
      Height = 13
      Caption = 'Comment'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblHexVal: TLabel
      Left = 242
      Top = 108
      Width = 65
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Use $ for Hex'
    end
    object Label5: TLabel
      Left = 13
      Top = 47
      Width = 74
      Height = 13
      Caption = 'Watch Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 13
      Top = 168
      Width = 74
      Height = 13
      Caption = 'Watch Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDescription: TLabel
      Left = 168
      Top = 139
      Width = 229
      Height = 46
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lblDescription'
      ParentShowHint = False
      ShowHint = True
    end
    object cbWatchType: TComboBox
      Left = 126
      Top = 12
      Width = 199
      Height = 21
      DropDownCount = 20
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      Sorted = True
      TabOrder = 0
      OnChange = cbWatchTypeChange
    end
    object ovcWatchParam: TOvcNumericField
      Left = 126
      Top = 136
      Width = 37
      Height = 21
      Cursor = crIBeam
      DataType = nftLongInt
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = 'iiiii'
      TabOrder = 4
      OnChange = ovcWatchParamChange
      RangeHigh = {00000100000000000000}
      RangeLow = {00000000000000000000}
    end
    object edtComment: TEdit
      Left = 126
      Top = 74
      Width = 269
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      OnChange = edtCommentChange
    end
    object edtWatchName: TEdit
      Left = 126
      Top = 43
      Width = 269
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 1
      Text = 'edtWatchName'
    end
    object cbWatchAddress: TComboBox
      Left = 126
      Top = 104
      Width = 115
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      Sorted = True
      TabOrder = 3
      OnExit = edtWatchAddrChange
    end
    object cbFreeze: TCheckBox
      Left = 340
      Top = 16
      Width = 57
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Freeze'
      TabOrder = 5
      OnClick = cbFreezeClick
    end
    object cbWatchIndirect: TCheckBox
      Left = 316
      Top = 106
      Width = 97
      Height = 17
      Caption = 'Indirect'
      TabOrder = 6
      OnClick = cbWatchIndirectClick
    end
  end
end
