object frmDebuggerSettings: TfrmDebuggerSettings
  Left = 665
  Top = 229
  Width = 639
  Height = 412
  Caption = 'Debugger Settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    631
    381)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 36
    Top = 58
    Width = 141
    Height = 13
    Caption = 'Databases used by Debugger'
  end
  object leLogFileName: TLabeledEdit
    Left = 32
    Top = 24
    Width = 483
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 65
    EditLabel.Height = 13
    EditLabel.Caption = 'Log FileName'
    TabOrder = 0
  end
  object btnCancel: TBitBtn
    Left = 528
    Top = 339
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 2
  end
  object btnOk: TBitBtn
    Left = 440
    Top = 339
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnBrowseLogFileName: TButton
    Left = 530
    Top = 22
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseLogFileNameClick
  end
  object leSourceCodeSavePath: TLabeledEdit
    Left = 32
    Top = 222
    Width = 483
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 115
    EditLabel.Height = 13
    EditLabel.Caption = 'Source Code Save Path'
    TabOrder = 4
  end
  object btnBrowseSourceCodeSavePath: TButton
    Left = 522
    Top = 219
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 5
    OnClick = btnBrowseSourceCodeSavePathClick
  end
  object lepCodeSavePath: TLabeledEdit
    Left = 32
    Top = 262
    Width = 483
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 87
    EditLabel.Height = 13
    EditLabel.Caption = 'p-Code Save Path'
    TabOrder = 6
  end
  object btnBrowsepCodeSavePath: TButton
    Left = 522
    Top = 259
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 7
    OnClick = btnBrowsepCodeSavePathClick
  end
  object leVarListPath: TLabeledEdit
    Left = 32
    Top = 302
    Width = 483
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 94
    EditLabel.Height = 13
    EditLabel.Caption = 'VAR List Save Path'
    TabOrder = 8
  end
  object btnBrowseVarListPath: TButton
    Left = 522
    Top = 299
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 9
    OnClick = btnBrowseVarListPathClick
  end
  object sgDatabases: TStringGrid
    Left = 32
    Top = 80
    Width = 569
    Height = 89
    ColCount = 3
    DefaultRowHeight = 16
    TabOrder = 10
  end
  object btnAdd: TButton
    Left = 64
    Top = 175
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 11
    OnClick = btnAddClick
  end
  object btnDelete: TButton
    Left = 240
    Top = 175
    Width = 75
    Height = 25
    Caption = 'Delete'
    TabOrder = 12
    OnClick = btnDeleteClick
  end
  object btnReplace: TButton
    Left = 152
    Top = 175
    Width = 75
    Height = 25
    Caption = 'Edit'
    TabOrder = 13
    OnClick = btnReplaceClick
  end
end
