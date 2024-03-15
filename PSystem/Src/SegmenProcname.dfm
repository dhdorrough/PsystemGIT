object frmSegmentProcName: TfrmSegmentProcName
  Left = 624
  Top = 293
  Width = 327
  Height = 186
  Caption = 'Segment/Procedure Name'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    319
    155)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 17
    Width = 47
    Height = 13
    Caption = 'SegName'
  end
  object Label3: TLabel
    Left = 16
    Top = 45
    Width = 32
    Height = 13
    Caption = 'Proc #'
  end
  object lblProcName: TLabel
    Left = 16
    Top = 73
    Width = 50
    Height = 13
    Caption = 'ProcName'
  end
  object cbSegName: TComboBox
    Left = 87
    Top = 13
    Width = 145
    Height = 21
    DropDownCount = 20
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    Text = 'SEGNAME'
  end
  object ovcProcNr: TOvcNumericField
    Left = 87
    Top = 41
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
    RangeHigh = {FFFF0000000000000000}
    RangeLow = {F6FFFFFF000000000000}
  end
  object cbProcName: TComboBox
    Left = 87
    Top = 69
    Width = 200
    Height = 21
    Constraints.MaxWidth = 200
    DropDownCount = 20
    ItemHeight = 13
    Sorted = True
    TabOrder = 2
    Text = 'PROCNAME'
  end
  object btnOk: TButton
    Left = 141
    Top = 114
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object Button1: TButton
    Left = 229
    Top = 114
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
