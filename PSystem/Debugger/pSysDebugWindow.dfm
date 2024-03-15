inherited frmPSysDebugWindow: TfrmPSysDebugWindow
  Caption = 'frmPSysDebugWindow'
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  inherited MainMenu1: TMainMenu
    object Control1: TMenuItem
      Caption = 'Control'
      object EnableStackWatch1: TMenuItem
        Caption = 'Enable Stack Watch'
        OnClick = EnableStackWatch1Click
      end
      object Debugon1: TMenuItem
        Caption = 'Debug On'
        Checked = True
        OnClick = Debugon1Click
      end
      object ClearScreen1: TMenuItem
        Caption = 'Clear Screen'
        OnClick = ClearScreen1Click
      end
      object RepaintScreen1: TMenuItem
        Caption = 'Repaint Screen'
        ShortCut = 116
        OnClick = RepaintScreen1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object NextPage1: TMenuItem
        Caption = 'Next Page'
        ShortCut = 34
        OnClick = NextPage1Click
      end
      object PrevPage1: TMenuItem
        Caption = 'Prev Page'
        ShortCut = 33
        OnClick = PrevPage1Click
      end
    end
    object Functions1: TMenuItem
      Caption = 'Functions'
      object ChoosePage1: TMenuItem
        Caption = 'Choose Page'
        OnClick = ChoosePage1Click
        object Dashboard1: TMenuItem
          Caption = 'Dashboard'
          Checked = True
          RadioItem = True
          OnClick = Dashboard1Click
        end
        object DisplayConstantPool1: TMenuItem
          Caption = 'Display Constant Pool'
          RadioItem = True
          OnClick = DisplayConstantPool1Click
        end
        object MemoryDump1: TMenuItem
          Caption = 'Memory Dump...'
          RadioItem = True
          OnClick = MemoryDump1Click
        end
        object DisplayInternalPMachineValues1: TMenuItem
          Caption = 'Display Internal PMachine Values'
          RadioItem = True
          OnClick = DisplayInternalPMachineValues1Click
        end
        object FromTIB1: TMenuItem
          Caption = 'Display EVEC From TIB'
          Enabled = False
          RadioItem = True
          OnClick = FromTIB1Click
        end
        object DisplayEVECChain1: TMenuItem
          Caption = 'Display EVEC Chain...'
          RadioItem = True
          OnClick = DisplayEVECChain1Click
        end
        object DisplayEVECfromAddr1: TMenuItem
          Caption = 'Display EVEC from Addr...'
          OnClick = EVECdump1Click
        end
        object DisplayLoadedSegments1: TMenuItem
          Caption = 'Display Loaded Segments'
          OnClick = DisplayLoadedSegments1Click
        end
        object DisplaySegmentLoads1: TMenuItem
          Caption = 'Display Segment Loads'
          OnClick = DisplaySegmentLoads1Click
        end
      end
    end
  end
end
