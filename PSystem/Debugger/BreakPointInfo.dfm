object frmBreakPointInfo: TfrmBreakPointInfo
  Left = 1466
  Top = 360
  BorderStyle = bsDialog
  Caption = 'Breakpoint Info'
  ClientHeight = 377
  ClientWidth = 373
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    373
    377)
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 16
    Top = 12
    Width = 52
    Height = 13
    Caption = 'Break Kind'
  end
  object lblLogFileName: TLabel
    Left = 24
    Top = 291
    Width = 72
    Height = 13
    Caption = 'lblLogFileName'
  end
  object Label5: TLabel
    Left = 16
    Top = 312
    Width = 44
    Height = 13
    Caption = 'Comment'
  end
  object btnOk: TButton
    Left = 190
    Top = 342
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object Button1: TButton
    Left = 278
    Top = 342
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object cbDisabled: TCheckBox
    Left = 25
    Top = 346
    Width = 73
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Disabled'
    TabOrder = 7
    OnClick = cbDisabledClick
  end
  object cbLogMessage: TCheckBox
    Left = 24
    Top = 224
    Width = 97
    Height = 14
    Caption = 'Log Message'
    TabOrder = 5
    OnClick = cbLogMessageClick
  end
  object cbDoNotBreak: TCheckBox
    Left = 160
    Top = 221
    Width = 97
    Height = 17
    Caption = 'Do Not Break'
    TabOrder = 6
  end
  object pnlParam: TPanel
    Left = 181
    Top = 184
    Width = 181
    Height = 32
    BevelOuter = bvNone
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    DesignSize = (
      181
      32)
    object lblParam: TLabel
      Left = 91
      Top = 11
      Width = 30
      Height = 13
      Alignment = taRightJustify
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Param'
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object ovcParam: TOvcNumericField
      Left = 125
      Top = 8
      Width = 45
      Height = 21
      Cursor = crIBeam
      DataType = nftLongInt
      Anchors = [akLeft, akTop, akRight]
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = [efoArrowIncDec]
      PictureMask = '9999999'
      TabOrder = 0
      RangeHigh = {7F969800000000000000}
      RangeLow = {00000000000000000000}
    end
  end
  object pnlProcBreak: TPanel
    Left = 0
    Top = 40
    Width = 370
    Height = 84
    BevelOuter = bvNone
    TabOrder = 1
    object Label2: TLabel
      Left = 17
      Top = 6
      Width = 47
      Height = 13
      Caption = 'SegName'
    end
    object Label3: TLabel
      Left = 17
      Top = 34
      Width = 32
      Height = 13
      Caption = 'Proc #'
    end
    object lblProcName: TLabel
      Left = 17
      Top = 62
      Width = 50
      Height = 13
      Caption = 'ProcName'
    end
    object Label1: TLabel
      Left = 174
      Top = 34
      Width = 17
      Height = 13
      Caption = 'IPC'
    end
    object Label6: TLabel
      Left = 241
      Top = 34
      Width = 60
      Height = 13
      Caption = 'ANYIPC = -4'
    end
    object cbSegName: TComboBox
      Left = 88
      Top = 2
      Width = 145
      Height = 21
      DropDownCount = 20
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
      Text = 'SEGNAME'
      OnChange = cbSegNameChange
      OnDropDown = cbSegNameDropDown
    end
    object ovcProcNr: TOvcNumericField
      Left = 88
      Top = 30
      Width = 33
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
      PictureMask = 'iiii'
      TabOrder = 1
      AfterExit = ovcProcNrAfterExit
      RangeHigh = {FFFF0000000000000000}
      RangeLow = {F6FFFFFF000000000000}
    end
    object cbProcName: TComboBox
      Left = 88
      Top = 58
      Width = 200
      Height = 21
      Constraints.MaxWidth = 200
      DropDownCount = 20
      ItemHeight = 13
      Sorted = True
      TabOrder = 3
      Text = 'PROCNAME'
      OnChange = cbProcNameExit
    end
    object ovcIPC: TOvcNumericField
      Left = 197
      Top = 30
      Width = 33
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
      PictureMask = 'iiii'
      TabOrder = 2
      RangeHigh = {FF7F0000000000000000}
      RangeLow = {F6FFFFFF000000000000}
    end
  end
  object cbBreakKind: TComboBox
    Left = 88
    Top = 8
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    OnChange = cbBreakKindChange
  end
  object lePassCount: TLabeledEdit
    Left = 90
    Top = 190
    Width = 87
    Height = 21
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'Pass Count'
    LabelPosition = lpLeft
    LabelSpacing = 20
    TabOrder = 2
  end
  object cbLogToAFile: TCheckBox
    Left = 44
    Top = 240
    Width = 97
    Height = 17
    Caption = 'Log To A File'
    TabOrder = 9
    OnClick = cbLogToAFileClick
  end
  object btnSpecifyLogFileName: TButton
    Left = 64
    Top = 259
    Width = 137
    Height = 25
    Caption = 'Specify Log File Name'
    TabOrder = 10
    OnClick = btnSpecifyLogFileNameClick
  end
  object pnlWatchInfo: TPanel
    Left = 4
    Top = 123
    Width = 353
    Height = 65
    BevelOuter = bvNone
    TabOrder = 11
    object Label8: TLabel
      Left = 13
      Top = 8
      Width = 61
      Height = 13
      Caption = 'Low Address'
    end
    object lblHexVal: TLabel
      Left = 194
      Top = 8
      Width = 65
      Height = 13
      Caption = 'Use $ for Hex'
    end
    object lblDisplayAs: TLabel
      Left = 13
      Top = 41
      Width = 49
      Height = 13
      Caption = 'Display As'
    end
    object cbWatchAddress: TComboBox
      Left = 85
      Top = 4
      Width = 102
      Height = 21
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
    end
    object cbIndirect: TCheckBox
      Left = 270
      Top = 7
      Width = 54
      Height = 17
      Caption = 'Indirect'
      TabOrder = 1
    end
    object leNrBytes: TLabeledEdit
      Left = 285
      Top = 36
      Width = 65
      Height = 21
      EditLabel.Width = 40
      EditLabel.Height = 13
      EditLabel.Caption = 'Nr Bytes'
      LabelPosition = lpLeft
      LabelSpacing = 7
      TabOrder = 2
    end
    object cbWatchType: TComboBox
      Left = 85
      Top = 36
      Width = 151
      Height = 21
      DropDownCount = 20
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      Sorted = True
      TabOrder = 3
    end
  end
  object edtComment: TEdit
    Left = 88
    Top = 312
    Width = 265
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 12
    Text = 'edtComment'
  end
end
