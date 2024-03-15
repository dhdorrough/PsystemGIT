object frmBinaryOps: TfrmBinaryOps
  Left = 769
  Top = 242
  Width = 697
  Height = 512
  Caption = 'Binary Operations'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    689
    481)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 32
    Top = 440
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object Label2: TLabel
    Left = 120
    Top = 368
    Width = 84
    Height = 13
    Caption = 'NEEDED PATCH'
    Color = clYellow
    ParentColor = False
  end
  object leFile1Name: TLabeledEdit
    Left = 32
    Top = 88
    Width = 545
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 56
    EditLabel.Height = 13
    EditLabel.Caption = 'File 1 Name'
    TabOrder = 0
    Text = '\\hplaptop\psys\OTHER\SYSTEM.PME.86'
    OnChange = leFile1NameChange
  end
  object leFile2Name: TLabeledEdit
    Left = 32
    Top = 144
    Width = 545
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 56
    EditLabel.Height = 13
    EditLabel.Caption = 'File 2 Name'
    TabOrder = 1
    Text = '\\hplaptop\psys\psystemY.vol'
  end
  object btnBegin: TButton
    Left = 576
    Top = 440
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Begin'
    Default = True
    TabOrder = 2
    OnClick = btnBeginClick
  end
  object leOutputFileName: TLabeledEdit
    Left = 32
    Top = 200
    Width = 545
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 82
    EditLabel.Height = 13
    EditLabel.Caption = 'Report File Name'
    TabOrder = 3
    Text = 'C:\TEMP\JUNK.TXT'
  end
  object BtnBrowse1: TButton
    Left = 592
    Top = 88
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 4
    OnClick = BtnBrowse1Click
  end
  object btnBrowse2: TButton
    Left = 592
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 5
    OnClick = btnBrowse2Click
  end
  object btnBrowseOutput: TButton
    Left = 592
    Top = 200
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 6
    OnClick = btnBrowseOutputClick
  end
  object rbCompareBinaryFiles: TRadioButton
    Left = 40
    Top = 32
    Width = 121
    Height = 17
    Caption = 'Compare Binary Files'
    Checked = True
    TabOrder = 7
    TabStop = True
    OnClick = rbCompareBinaryFilesClick
  end
  object rbPatchBinaryFile: TRadioButton
    Left = 320
    Top = 32
    Width = 113
    Height = 17
    Caption = 'Patch Binary File'
    TabOrder = 9
    OnClick = rbPatchBinaryFileClick
  end
  object pnlData: TPanel
    Left = 32
    Top = 248
    Width = 633
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    BevelInner = bvLowered
    TabOrder = 10
    Visible = False
    DesignSize = (
      633
      105)
    object leSourceBytes: TLabeledEdit
      Left = 16
      Top = 24
      Width = 601
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 63
      EditLabel.Height = 13
      EditLabel.Caption = 'Search Bytes'
      TabOrder = 0
      Text = 'EA 10 02 C1 5B'
      OnChange = leSourceBytesChange
    end
    object leReplacementBytes: TLabeledEdit
      Left = 16
      Top = 64
      Width = 601
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 92
      EditLabel.Height = 13
      EditLabel.Caption = 'Replacement Bytes'
      TabOrder = 1
      Text = 'EA 10 02 C1 5B'
    end
  end
  object rbScanForSourceBytes: TRadioButton
    Left = 168
    Top = 32
    Width = 137
    Height = 17
    Caption = 'Scan for Source Bytes'
    TabOrder = 8
    OnClick = rbScanForSourceBytesClick
  end
  object Memo1: TMemo
    Left = 216
    Top = 360
    Width = 185
    Height = 57
    Color = clYellow
    Lines.Strings = (
      '0221: mov bp,ss:[0032]'
      '0226: call 5bc1:108F'
      '0229: JMP 0210')
    TabOrder = 11
  end
end
