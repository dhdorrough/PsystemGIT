object frmCrtWindow: TfrmCrtWindow
  Left = 770
  Top = 317
  Width = 660
  Height = 468
  Caption = 'CRT Window'
  Color = clBlack
  Font.Charset = OEM_CHARSET
  Font.Color = clWhite
  Font.Height = -13
  Font.Name = 'Courier New'
  Font.Pitch = fpFixed
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  ShowHint = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 16
  object MainMenu1: TMainMenu
    Left = 88
    Top = 32
    object File1: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Caption = '&New'
        Enabled = False
      end
      object Open1: TMenuItem
        Caption = '&Open...'
        Enabled = False
      end
      object Save1: TMenuItem
        Caption = '&Save'
        Enabled = False
      end
      object SaveAs1: TMenuItem
        Caption = 'Save &As...'
        Enabled = False
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Print1: TMenuItem
        Caption = '&Print...'
        OnClick = Print1Click
      end
      object PrintSetup1: TMenuItem
        Caption = 'P&rint Setup...'
      end
      object QuickPrint1: TMenuItem
        Caption = 'Quick Print'
        ShortCut = 16465
        OnClick = QuickPrint1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
  end
end
