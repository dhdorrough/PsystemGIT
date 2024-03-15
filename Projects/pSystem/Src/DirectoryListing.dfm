object frmDirectoryListing: TfrmDirectoryListing
  Left = 1009
  Top = 405
  Width = 783
  Height = 473
  Caption = 'Directory Listing'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    767
    414)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 66
    Height = 13
    Caption = 'Volume Name'
  end
  object lblVolumeName: TLabel
    Left = 96
    Top = 8
    Width = 87
    Height = 13
    Caption = 'lblVolumeName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 17
    Top = 26
    Width = 73
    Height = 13
    Caption = 'DOS File Name'
  end
  object lblDOSFiileName: TLabel
    Left = 97
    Top = 26
    Width = 95
    Height = 13
    Caption = 'lblDOSFiileName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 626
    Top = 8
    Width = 51
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Last Write:'
  end
  object LblLastWrite: TLabel
    Left = 682
    Top = 8
    Width = 72
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'LblLastWrite'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object sgDirectory: TStringGrid
    Left = 16
    Top = 48
    Width = 737
    Height = 325
    Anchors = [akLeft, akTop, akRight, akBottom]
    DefaultRowHeight = 18
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentFont = False
    TabOrder = 0
  end
  object leNrFiles: TLabeledEdit
    Left = 56
    Top = 384
    Width = 37
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 31
    EditLabel.Height = 13
    EditLabel.Caption = '# Files'
    LabelPosition = lpLeft
    LabelSpacing = 10
    ReadOnly = True
    TabOrder = 1
  end
  object leBlocksUsed: TLabeledEdit
    Left = 175
    Top = 384
    Width = 37
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = 'Blocks Used'
    LabelPosition = lpLeft
    LabelSpacing = 10
    ReadOnly = True
    TabOrder = 2
  end
  object leUnused: TLabeledEdit
    Left = 266
    Top = 384
    Width = 37
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 37
    EditLabel.Height = 13
    EditLabel.Caption = 'Unused'
    LabelPosition = lpLeft
    LabelSpacing = 10
    ReadOnly = True
    TabOrder = 3
  end
  object leInLargestArea: TLabeledEdit
    Left = 400
    Top = 384
    Width = 37
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = 'In Largest Area'
    LabelPosition = lpLeft
    LabelSpacing = 10
    ReadOnly = True
    TabOrder = 4
  end
  object btnClose: TButton
    Left = 656
    Top = 382
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 5
    OnClick = btnCloseClick
  end
  object MainMenu1: TMainMenu
    Left = 248
    object File1: TMenuItem
      Caption = '&File'
      object Print1: TMenuItem
        Caption = '&Print...'
        OnClick = Print1Click
      end
      object PrintSetup1: TMenuItem
        Caption = 'P&rint Setup...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Sort1: TMenuItem
      Caption = 'Sort'
      object Alpha1: TMenuItem
        Caption = 'Alpha'
        RadioItem = True
        OnClick = Alpha1Click
      end
      object Date1: TMenuItem
        Caption = 'Date'
        RadioItem = True
        OnClick = Date1Click
      end
      object Size1: TMenuItem
        Caption = 'Size'
        RadioItem = True
        OnClick = Size1Click
      end
      object Unsorted1: TMenuItem
        Caption = 'Unsorted'
        RadioItem = True
        OnClick = Unsorted1Click
      end
    end
  end
end
