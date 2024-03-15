object frmDebuggerSettings: TfrmDebuggerSettings
  Left = 1029
  Top = 164
  Width = 639
  Height = 293
  Caption = 'DEBUGGER Settings for Version xx'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    623
    254)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 32
    Top = 216
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object lblFileDoesNotExist: TLabel
    Left = 32
    Top = 73
    Width = 89
    Height = 13
    Alignment = taCenter
    Caption = 'File Does Not Exist'
    Color = clYellow
    ParentColor = False
  end
  object leLogFileName: TLabeledEdit
    Left = 32
    Top = 149
    Width = 483
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 65
    EditLabel.Height = 13
    EditLabel.Caption = 'Log FileName'
    TabOrder = 1
  end
  object btnCancel: TBitBtn
    Left = 529
    Top = 212
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 5
  end
  object btnOk: TBitBtn
    Left = 440
    Top = 212
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 6
    OnClick = btnOkClick
  end
  object btnBrowseLogFileName: TButton
    Left = 529
    Top = 147
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseLogFileNameClick
  end
  object leReportsPath: TLabeledEdit
    Left = 32
    Top = 107
    Width = 483
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 62
    EditLabel.Height = 13
    EditLabel.Caption = 'Reports Path'
    TabOrder = 0
  end
  object btnBrowseForReportsPath: TButton
    Left = 529
    Top = 105
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 3
    OnClick = btnBrowseForReportsPathClick
  end
  object leDatabaseUsedByDebugger: TLabeledEdit
    Left = 32
    Top = 54
    Width = 483
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 136
    EditLabel.Height = 13
    EditLabel.Caption = 'Database used by Debugger'
    TabOrder = 2
    OnChange = leDatabaseUsedByDebuggerChange
  end
  object btnBrowseForDatabaseUsedByDebugger: TButton
    Left = 530
    Top = 52
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 7
    OnClick = btnBrowseForDatabaseUsedByDebuggerClick
  end
  object cbVersionNumbers: TComboBox
    Left = 32
    Top = 8
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 8
    Text = 'cbVersionNumbers'
    OnClick = cbVersionNumbersClick
  end
end
