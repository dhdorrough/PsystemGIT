object frmBuildDBDBMain: TfrmBuildDBDBMain
  Left = 626
  Top = 310
  Width = 784
  Height = 469
  Caption = 'Build Debug DB'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  DesignSize = (
    768
    410)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 8
    Top = 391
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object Memo1: TMemo
    Left = 8
    Top = 16
    Width = 761
    Height = 368
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object MainMenu1: TMainMenu
    Left = 72
    object File1: TMenuItem
      Caption = '&File'
      object miNewDatabase: TMenuItem
        Caption = '&New Database...'
        OnClick = miNewDatabaseClick
      end
      object Open1: TMenuItem
        Caption = '&Open Database...'
        OnClick = Open1Click
      end
      object Save1: TMenuItem
        Caption = '&Save'
        Enabled = False
      end
      object SaveAs1: TMenuItem
        Caption = 'Save Database &As...'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Print1: TMenuItem
        Caption = '&Print...'
        Enabled = False
      end
      object PrintSetup1: TMenuItem
        Caption = 'P&rint Setup...'
        Enabled = False
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Functions1: TMenuItem
      Caption = 'Functions'
      object ParseandList1: TMenuItem
        Caption = 'Parse and List Summary...'
        OnClick = ParseandList1Click
      end
      object BuildDatabasefromListing1: TMenuItem
        Caption = 'Build Database from Listing...'
        OnClick = BuildDatabasefromListing1Click
      end
      object BuildUglySourceFromListing1: TMenuItem
        Caption = 'File Parsed From Listing...'
        OnClick = BuildUglySourceFromListing1Click
      end
      object MapSegmentsinCodeFile1: TMenuItem
        Caption = 'Map Segments in Code File...'
        OnClick = MapSegmentsinCodeFile1Click
      end
      object ScanListingforVersionNumber1: TMenuItem
        Caption = 'Scan Listing for Version Number...'
        OnClick = ScanListingforVersionNumber1Click
      end
      object CleanupcompilerlistingsenttoCONSOLE1: TMenuItem
        Caption = 'Clean up compiler listing sent to CONSOLE: ...'
        OnClick = CleanupcompilerlistingsenttoCONSOLE1Click
      end
      object QDCleanupofProcedureNames1: TMenuItem
        Caption = 'Q&&D Clean up of Procedure Names'
        OnClick = QDCleanupofProcedureNames1Click
      end
    end
  end
  object ADOConnection1: TADOConnection
    Left = 256
    Top = 8
  end
end
