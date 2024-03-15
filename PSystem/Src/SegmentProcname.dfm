object frmSegmentProcName: TfrmSegmentProcName
  Left = 741
  Top = 229
  Width = 377
  Height = 522
  Caption = 'Segment/Procedure Name'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  DesignSize = (
    361
    483)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 40
    Width = 47
    Height = 13
    Caption = 'SegName'
  end
  object lblSegNameIdx: TLabel
    Left = 265
    Top = 39
    Width = 61
    Height = 13
    Caption = 'SegNameIdx'
  end
  object lblStatus: TLabel
    Left = 16
    Top = 424
    Width = 30
    Height = 13
    Caption = 'Status'
  end
  object Label1: TLabel
    Left = 16
    Top = 14
    Width = 85
    Height = 13
    Caption = 'Access File Name'
  end
  object cbSegName: TComboBox
    Left = 112
    Top = 36
    Width = 145
    Height = 21
    DropDownCount = 20
    ItemHeight = 13
    Sorted = True
    TabOrder = 1
    Text = 'SEGNAME'
    OnExit = cbSegNameExit
  end
  object btnUpdate: TButton
    Left = 192
    Top = 450
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Update'
    Enabled = False
    ModalResult = 1
    TabOrder = 2
    OnClick = btnUpdateClick
  end
  object btnCancel: TButton
    Left = 279
    Top = 450
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object sgProcNames: TStringGrid
    Left = 16
    Top = 72
    Width = 331
    Height = 341
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 3
    DefaultRowHeight = 18
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs, goAlwaysShowEditor]
    TabOrder = 4
    ColWidths = (
      34
      141
      150)
    RowHeights = (
      18
      18)
  end
  object btnValidate: TButton
    Left = 106
    Top = 450
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Validate'
    Default = True
    TabOrder = 5
    OnClick = btnValidateClick
  end
  object edtAccessFileName: TEdit
    Left = 112
    Top = 10
    Width = 232
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = edtAccessFileNameChange
    OnExit = edtAccessFileNameChange
  end
end
