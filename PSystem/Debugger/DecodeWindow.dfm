object frmDecodeWindow: TfrmDecodeWindow
  Left = 634
  Top = 188
  Width = 904
  Height = 560
  Caption = 'Decode Window'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  DesignSize = (
    888
    501)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 16
    Top = 480
    Width = 50
    Height = 13
    Caption = 'lblStatus'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Memo1: TMemo
    Left = 13
    Top = 40
    Width = 865
    Height = 429
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'Courier New'
    Font.Pitch = fpFixed
    Font.Style = []
    Lines.Strings = (
      '')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object MainMenu1: TMainMenu
    OnChange = MainMenu1Change
    Left = 16
    Top = 8
    object File1: TMenuItem
      Caption = '&File'
      object Print1: TMenuItem
        Caption = 'Print...'
        OnClick = Print1Click
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        ShortCut = 16472
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Find1: TMenuItem
        Caption = 'Find'
        ShortCut = 16454
        OnClick = Find1Click
      end
      object FindAgain1: TMenuItem
        Caption = 'Find Again'
        ShortCut = 114
        OnClick = FindAgain1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ClearWindow1: TMenuItem
        Caption = 'Clear Window'
        OnClick = ClearWindow1Click
      end
    end
    object Utilities1: TMenuItem
      Caption = 'Utilities'
      object DecodeMemory1: TMenuItem
        Caption = '&Decode Specified Memory...'
        ShortCut = 16467
        OnClick = DecodeMemory1Click
      end
      object Decode1: TMenuItem
        Caption = 'Decode Memory @ IPC'
        ShortCut = 16452
        OnClick = Decode1Click
      end
      object SearchforHexBytes1: TMenuItem
        Caption = 'Search for Hex Bytes...'
        ShortCut = 16454
        OnClick = SearchforHexBytes1Click
      end
      object itmDumpSyscom: TMenuItem
        Caption = 'Dump Syscom at addr...'
        OnClick = itmDumpSyscomClick
      end
      object DumpPEDHeader1: TMenuItem
        Caption = 'Dump PED Header...'
        OnClick = DumpPEDHeader1Click
      end
      object DisplayDirectory1: TMenuItem
        Caption = 'Display Directory'
        OnClick = DisplayDirectory1Click
      end
      object DumpMiscInfo1: TMenuItem
        Caption = 'Dump MiscInfo...'
        OnClick = DumpMiscInfo1Click
      end
      object DumpEVECERECSIBS1: TMenuItem
        Caption = 'Dump EVEC, EREC, SIBS..'
        OnClick = DumpEVECERECSIBS1Click
      end
      object MergeSourceCodeintopCode1: TMenuItem
        Caption = 'Merge Source Code into p-Code'
        OnClick = MergeSourceCodeintopCode1Click
      end
    end
  end
end
