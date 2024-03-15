object frmRenameFile: TfrmRenameFile
  Left = 653
  Top = 287
  BorderStyle = bsDialog
  Caption = 'Rename pSystem File'
  ClientHeight = 170
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    418
    170)
  PixelsPerInch = 96
  TextHeight = 13
  object leOldFileName: TLabeledEdit
    Left = 24
    Top = 24
    Width = 361
    Height = 21
    CharCase = ecUpperCase
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = 'Old File Name'
    MaxLength = 23
    TabOrder = 0
  end
  object leNewFileName: TLabeledEdit
    Left = 24
    Top = 80
    Width = 361
    Height = 21
    CharCase = ecUpperCase
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = 'New File Name'
    MaxLength = 23
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 312
    Top = 126
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 208
    Top = 126
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
end
