object frmProcedureInfo: TfrmProcedureInfo
  Left = 567
  Top = 328
  Width = 335
  Height = 220
  Caption = 'Procedure Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  DesignSize = (
    327
    189)
  PixelsPerInch = 96
  TextHeight = 13
  object leSegmentName: TLabeledEdit
    Left = 24
    Top = 24
    Width = 121
    Height = 21
    EditLabel.Width = 73
    EditLabel.Height = 13
    EditLabel.Caption = 'Segment Name'
    TabOrder = 2
  end
  object leProcedureName: TLabeledEdit
    Left = 126
    Top = 104
    Width = 121
    Height = 21
    EditLabel.Width = 80
    EditLabel.Height = 13
    EditLabel.Caption = 'Procedure Name'
    TabOrder = 1
  end
  object leProcedureNumber: TLabeledEdit
    Left = 24
    Top = 64
    Width = 50
    Height = 21
    EditLabel.Width = 89
    EditLabel.Height = 13
    EditLabel.Caption = 'Procedure Number'
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 144
    Top = 147
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 227
    Top = 147
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object leFullProcedureName: TLabeledEdit
    Left = 126
    Top = 64
    Width = 179
    Height = 21
    EditLabel.Width = 99
    EditLabel.Height = 13
    EditLabel.Caption = 'Full Procedure Name'
    TabOrder = 0
    OnChange = leFullProcedureNameChange
  end
end
