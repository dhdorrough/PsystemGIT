inherited frmPSysWindow: TfrmPSysWindow
  Caption = 'p-System Window'
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  inherited MainMenu1: TMainMenu
    object Options1: TMenuItem
      Caption = 'Options'
      object miTerminal: TMenuItem
        Caption = 'Terminal'
      end
      object DebugLogFile1: TMenuItem
        Caption = 'Debug Log File'
        OnClick = DebugLogFile1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object DisplayShortCutKeys1: TMenuItem
        Caption = 'Display Short Cut Keys...'
        OnClick = DisplayShortCutKeys1Click
      end
    end
  end
end
