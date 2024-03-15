object frmDatabaseInfo: TfrmDatabaseInfo
  Left = 1152
  Top = 446
  Width = 651
  Height = 180
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
    635
    141)
  PixelsPerInch = 96
  TextHeight = 13
  object leFilePath: TLabeledEdit
    Left = 16
    Top = 26
    Width = 517
    Height = 21
    EditLabel.Width = 137
    EditLabel.Height = 13
    EditLabel.Caption = 'File Path to Debug Database'
    TabOrder = 0
    OnChange = leFilePathChange
    OnExit = leFilePathExit
  end
  object btnBrowseFilePath: TButton
    Left = 540
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseFilePathClick
  end
  object btnOK: TButton
    Left = 445
    Top = 109
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 541
    Top = 109
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 3
  end
end
