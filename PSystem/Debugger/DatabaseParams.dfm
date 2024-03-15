object frmDatabaseParams: TfrmDatabaseParams
  Left = 659
  Top = 303
  Width = 451
  Height = 182
  Caption = 'Create New Debugger Database...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    435
    143)
  PixelsPerInch = 96
  TextHeight = 13
  object leFileName: TLabeledEdit
    Left = 24
    Top = 24
    Width = 326
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 47
    EditLabel.Height = 13
    EditLabel.Caption = 'File Name'
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 361
    Top = 22
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object rgDatabaseVersion: TRadioGroup
    Left = 24
    Top = 56
    Width = 185
    Height = 73
    Caption = 'Database Version'
    Items.Strings = (
      'Access 2000'
      'Access 2007')
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 349
    Top = 112
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 245
    Top = 112
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
end
