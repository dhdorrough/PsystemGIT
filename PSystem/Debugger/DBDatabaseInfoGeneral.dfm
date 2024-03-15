object frmDatabaseInfoGeneral: TfrmDatabaseInfoGeneral
  Left = 737
  Top = 409
  Width = 390
  Height = 200
  Caption = 'Debugging Database Info for Version'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    374
    161)
  PixelsPerInch = 96
  TextHeight = 13
  object leFilePath: TLabeledEdit
    Left = 16
    Top = 26
    Width = 267
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 137
    EditLabel.Height = 13
    EditLabel.Caption = 'File Path to Debug Database'
    TabOrder = 0
    OnChange = leFilePathChange
    OnExit = leFilePathExit
  end
  object btnBrowseFilePath: TButton
    Left = 290
    Top = 24
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseFilePathClick
  end
  object btnOK: TButton
    Left = 184
    Top = 129
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 280
    Top = 129
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 3
  end
  object RadioGroup1: TRadioGroup
    Left = 16
    Top = 56
    Width = 345
    Height = 65
    Caption = 'p-System Version Nr'
    Columns = 2
    TabOrder = 4
  end
end
