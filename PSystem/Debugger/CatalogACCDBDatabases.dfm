object frmCatalog: TfrmCatalog
  Left = 663
  Top = 247
  Width = 588
  Height = 199
  Caption = 'Catalog .ACCDB databases'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    572
    160)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 24
    Top = 122
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object leRootFolder: TLabeledEdit
    Left = 24
    Top = 24
    Width = 449
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 55
    EditLabel.Height = 13
    EditLabel.Caption = 'Root Folder'
    TabOrder = 0
  end
  object btnBrowseRoot: TButton
    Left = 488
    Top = 22
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseRootClick
  end
  object btnBegin: TButton
    Left = 488
    Top = 116
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Begin'
    TabOrder = 2
    OnClick = btnBeginClick
  end
  object leOutputFileName: TLabeledEdit
    Left = 24
    Top = 72
    Width = 449
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 82
    EditLabel.Height = 13
    EditLabel.Caption = 'Output File Name'
    TabOrder = 3
  end
  object btnBrowseForOutput: TButton
    Left = 488
    Top = 70
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseForOutputClick
  end
end
