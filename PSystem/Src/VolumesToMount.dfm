object frmVolumesToMount: TfrmVolumesToMount
  Left = 964
  Top = 538
  Width = 701
  Height = 365
  Caption = 'Volumes To Mount'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    685
    326)
  PixelsPerInch = 96
  TextHeight = 13
  object leCSVListOfVolumesToMount: TLabeledEdit
    Left = 17
    Top = 20
    Width = 564
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 140
    EditLabel.Height = 13
    EditLabel.Caption = 'CSV List of Volumes to Mount'
    TabOrder = 0
    OnExit = leCSVListOfVolumesToMountExit
  end
  object btnBrowseForCSVListOfVolumesToMount: TButton
    Left = 595
    Top = 18
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseForCSVListOfVolumesToMountClick
  end
  object btnOk: TBitBtn
    Left = 505
    Top = 293
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TBitBtn
    Left = 594
    Top = 293
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 3
  end
  object btnCreateCSVFile: TButton
    Left = 321
    Top = 46
    Width = 252
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Create CSV File from volumes Listed Below'
    TabOrder = 4
    OnClick = btnCreateCSVFileClick
  end
  object btnSetDefaultFileName: TButton
    Left = 19
    Top = 46
    Width = 126
    Height = 25
    Caption = 'Use Default File Name'
    TabOrder = 5
    OnClick = btnSetDefaultFileNameClick
  end
  object StringGrid1: TStringGrid
    Left = 18
    Top = 96
    Width = 608
    Height = 185
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 6
    DefaultRowHeight = 16
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    RowHeights = (
      16
      16)
  end
  object btnAdd: TButton
    Left = 18
    Top = 293
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Add'
    TabOrder = 7
    OnClick = btnAddClick
  end
  object btnDelete: TButton
    Left = 106
    Top = 293
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Delete'
    TabOrder = 8
    OnClick = btnDeleteClick
  end
  object btnUp: TButton
    Left = 637
    Top = 104
    Width = 37
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Up'
    TabOrder = 9
    OnClick = btnUpClick
  end
  object btnDown: TButton
    Left = 637
    Top = 144
    Width = 37
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Down'
    TabOrder = 10
    OnClick = btnDownClick
  end
  object btnUseurrentlyMountedVolumes: TButton
    Left = 192
    Top = 293
    Width = 169
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Use Currently Mounted Volumes'
    TabOrder = 11
    OnClick = btnUseurrentlyMountedVolumesClick
  end
end
