object frmFiler: TfrmFiler
  Left = 378
  Top = 245
  Width = 1137
  Height = 682
  Caption = 'Filer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    1121
    623)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 16
    Top = 600
    Width = 61
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 1121
    Height = 585
    Align = alTop
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    HideSelection = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object btnAbort: TButton
    Left = 1041
    Top = 595
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Abort'
    TabOrder = 1
    Visible = False
    OnClick = btnAbortClick
  end
  object MainMenu1: TMainMenu
    Left = 32
    Top = 48
    object File1: TMenuItem
      Caption = 'File'
      object SetCurrentUnit1: TMenuItem
        Caption = 'Set Current Unit...'
        ShortCut = 16469
        OnClick = SetCurrentUnit1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Directories1: TMenuItem
        Caption = 'Directories'
        object Directory0: TMenuItem
          Caption = 'Detailed &Directory...'
          ShortCut = 16452
          OnClick = Directory0Click
        end
        object BriefDirectory1: TMenuItem
          Caption = '&Brief Directory'
          OnClick = BriefDirectory1Click
        end
        object ListDirectory1: TMenuItem
          Caption = '&List Directory to file...'
          ShortCut = 16460
          OnClick = ListDirectory1Click
        end
        object DirectorytoGrid1: TMenuItem
          Caption = 'Directory to Grid'
          object AlphaSort2: TMenuItem
            Caption = 'Alpha Sort'
            OnClick = AlphaSort2Click
          end
          object DateSort1: TMenuItem
            Caption = 'Date Sort'
            OnClick = DateSort1Click
          end
          object FileSize1: TMenuItem
            Caption = 'File Size'
            OnClick = FileSize1Click
          end
          object Unsorted1: TMenuItem
            Caption = 'Unsorted'
            OnClick = Unsorted1Click
          end
        end
        object SetFilter1: TMenuItem
          Caption = 'Set Filter...'
          OnClick = SetFilter1Click
        end
      end
      object Volumes1: TMenuItem
        Caption = 'Volumes'
        object MountVolume1: TMenuItem
          Caption = '&Mount Volume...'
          ShortCut = 16461
          OnClick = MountVolume1Click
        end
        object MountVolSubsidiaryVolume1: TMenuItem
          Caption = 'Mount Vol+Subsidiary Volume...'
          OnClick = MountSubsidiaryVolume1ClickMountSubsidiaryVolume1Click
        end
        object MountSubVolonCurrent1: TMenuItem
          Caption = 'Mount Sub. Vol on Current...'
          ShortCut = 16467
          OnClick = MountSubVolonCurrent1Click
        end
        object MountNonStandardVolume1: TMenuItem
          Caption = 'Mount non-Standard Volume...'
          OnClick = MountNonStandardVolume1Click
        end
        object MountedVolumes1: TMenuItem
          Caption = 'Mounted &Volumes'
          ShortCut = 113
          OnClick = MountedVolumes1Click
        end
        object SelectedVolumes1: TMenuItem
          Caption = 'Unmount'
          object SelectedVolume1: TMenuItem
            Caption = 'Selected Volume...'
            OnClick = SelectedVolume1Click
          end
          object SelectedVolumes2: TMenuItem
            Caption = 'Selected Volumes...'
            ShortCut = 115
            OnClick = UnmountVolume1Click
          end
          object UnmountAll1: TMenuItem
            Caption = 'All Volumes'
            OnClick = UnmountAll1Click
          end
        end
        object NewVolume1: TMenuItem
          Caption = 'New Volume...'
          ShortCut = 116
          OnClick = NewVolume1Click
        end
        object ZeroVolume1: TMenuItem
          Caption = 'Zero Volume...'
          OnClick = ZeroVolume1Click
        end
        object RecentVolumes1: TMenuItem
          Caption = 'Recent Volumes'
          ShortCut = 117
        end
        object REMountCurrentUnit1: TMenuItem
          Caption = 'RE-Mount Current Unit'
          ShortCut = 118
          OnClick = RefreshCurrentUnit1Click
        end
        object ResizeVolume1: TMenuItem
          Caption = 'Resize Volume...'
          OnClick = ResizeVolume1Click
        end
        object SaveListofMountedVolumes1: TMenuItem
          Caption = 'Save List of Mounted Volumes...'
          OnClick = SaveListofMountedVolumes1Click
        end
        object MountVolumesfromSavedList1: TMenuItem
          Caption = 'Mount Volumes from Saved List...'
          OnClick = MountVolumesfromSavedList1Click
        end
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object CopyfrompSys1: TMenuItem
        Caption = 'Copy from pSys'
        object CopyAllFiles1: TMenuItem
          Caption = 'Copy All Files'
          OnClick = CopyAllFiles1Click
        end
        object CopySingleFile1: TMenuItem
          Caption = 'Copy Single File...'
          ShortCut = 16467
          OnClick = CopySingleFile1Click
        end
        object CopyTextFileasBinary1: TMenuItem
          Caption = 'Copy Text File as Binary...'
          OnClick = CopyTextFileasBinary1Click
        end
        object CopyAllFilesinBinary1: TMenuItem
          Caption = 'Copy All Files in Binary...'
          OnClick = CopyAllFilesinBinary1Click
        end
        object CopyAllTextFiles1: TMenuItem
          Caption = 'Copy All Text Files...'
          OnClick = CopyAllTextFiles1Click
        end
        object CopyallCODEfiles1: TMenuItem
          Caption = 'Copy all CODE files...'
          OnClick = CopyallCODEfiles1Click
        end
        object CopyDataRange1: TMenuItem
          Caption = 'Copy Data Range'
          object miTextFile1: TMenuItem
            Caption = 'To Text File...'
            OnClick = miTextFile1Click
          end
          object miTextFile2: TMenuItem
            Caption = 'To Data File...'
            OnClick = miTextFile2Click
          end
        end
      end
      object CopytopSys1: TMenuItem
        Caption = 'Copy to pSys'
        object CopyTextfilefromDOS1: TMenuItem
          Caption = 'Copy Text file(s) from DOS...'
          OnClick = CopyTextfilefromDOS1Click
        end
        object CopyBinaryfilefromDOS1: TMenuItem
          Caption = 'Copy Binary file(s) from DOS...'
          OnClick = CopyBinaryfilefromDOS1Click
        end
      end
      object CopyfrompSystopSys1: TMenuItem
        Caption = 'Copy from pSys to pSys...'
        OnClick = CopyfrompSystopSys1Click
      end
      object DeleteFile1: TMenuItem
        Caption = 'Delete pSys File...'
        OnClick = DeleteFile1Click
      end
      object RenamepSysFile1: TMenuItem
        Caption = 'Rename pSys File...'
        OnClick = RenamepSysFile1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object SetDOSPath1: TMenuItem
        Caption = 'Set DOS Source &Path...'
        ShortCut = 16464
        OnClick = SetDOSPath1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object SearchManyVolumes1: TMenuItem
        Caption = 'Search Volume(s)...'
        object miSearchMountedVolumes: TMenuItem
          Caption = 'Search Mounted Volumes...'
          OnClick = miSearchMountedVolumesClick
        end
        object SearchVolumes1: TMenuItem
          Caption = 'Search Volume(s)...'
          OnClick = SearchManyVolumes1Click
        end
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object Settings1: TMenuItem
        Caption = 'Filer Settings...'
        OnClick = Settings1Click
      end
      object DebuggerSettings1: TMenuItem
        Caption = 'Debugger Settings...'
        OnClick = DebuggerSettings1Click
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        ShortCut = 32856
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      OnClick = Edit1Click
      object FindStringinWindow1: TMenuItem
        Caption = 'Find String in Window...'
        ShortCut = 16454
        OnClick = FindStringinWindow1Click
      end
      object Find1: TMenuItem
        Caption = 'Find All Occurrences of String in Window...'
        ShortCut = 16449
        OnClick = Find1Click
      end
      object FindAgain1: TMenuItem
        Caption = 'Find Again'
        ShortCut = 114
        OnClick = FindAgain1Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object EditpSystemTextFile1: TMenuItem
        Caption = 'Edit pSystem Text File...'
        ShortCut = 16453
        OnClick = EditpSystemTextFile1Click
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object ClearWindow1: TMenuItem
        Caption = 'Clear Window'
        OnClick = ClearWindow1Click
      end
    end
    object pSystem1: TMenuItem
      Caption = 'p-System'
      OnClick = pSystem1Click
      object RebootLastSystem1: TMenuItem
        Caption = 'Reboot Last System'
        OnClick = RebootLastSystem1Click
      end
      object N5: TMenuItem
        Caption = '-'
        GroupIndex = 2
      end
      object Boot1: TMenuItem
        Caption = 'Boot...'
        GroupIndex = 2
      end
      object Debug1: TMenuItem
        Caption = 'Debug...'
        GroupIndex = 2
      end
      object N10: TMenuItem
        Caption = '-'
        GroupIndex = 2
      end
      object BoorParameters: TMenuItem
        Caption = 'Boot Parameters'
        GroupIndex = 2
        object MaintainBootParameters1: TMenuItem
          Caption = 'Maintain Boot Parameters...'
          OnClick = MaintainBootFilesList1Click
        end
        object PrintBootParameters1: TMenuItem
          Caption = 'Print Boot Parameters'
          OnClick = PrintBootFilesList1Click
        end
      end
      object EnableExternalPool1: TMenuItem
        Caption = 'Enable External Pool'
        Checked = True
        GroupIndex = 2
      end
      object ClosepSystemWindow1: TMenuItem
        Caption = 'Close p-System Window'
        GroupIndex = 2
        OnClick = ClosepSystemWindow1Click
      end
    end
    object Utilities1: TMenuItem
      Caption = 'Utilities'
      object VolumeConversions1: TMenuItem
        Caption = 'Volume Conversions...'
        OnClick = VolumeConversionClick
      end
      object GuessTermType: TMenuItem
        Caption = 'Guess Term Type from SYSTEM.MISCINFO'
        OnClick = GuessTermTypeClick
      end
      object ScanRawVolume1: TMenuItem
        Caption = 'Scan Raw Volume...'
        OnClick = ScanRawVolume1Click
      end
      object ScanRawFile1: TMenuItem
        Caption = 'Scan Raw DOS File...'
        OnClick = ScanRawFile1Click
      end
      object ExtractRawFile1: TMenuItem
        Caption = 'Extract Raw File...'
        OnClick = ExtractRawFile1Click
      end
      object ExtractFilefromRawVolume1: TMenuItem
        Caption = 'Extract File from Raw Volume...'
        OnClick = ExtractFilefromRawVolume1Click
      end
      object Miscellaneous1: TMenuItem
        Caption = 'Miscellaneous'
        object CleanVolumeforprevers41: TMenuItem
          Caption = 'Clean Volume for pre vers 4'
          OnClick = CleanVolumeforprevers41Click
        end
        object GuessVolumeFormat1: TMenuItem
          Caption = 'Guess Volume Format...'
          ShortCut = 16455
          OnClick = GuessVolumeFormat1Click
        end
        object SegmentMapSEGMAP1: TMenuItem
          Caption = 'Segment Map (SEGMAP)...'
          OnClick = SegmentMapSEGMAP1Click
        end
        object CompareVolumes1: TMenuItem
          Caption = 'Compare Volumes...'
          OnClick = CompareVolumes1Click
        end
        object ChangeSyscom1: TMenuItem
          Caption = 'Change Syscom'
          object ConfigureCodePoolInfo1: TMenuItem
            Caption = 'Configure Code Pool Info...'
            OnClick = ConfigureCodePoolInfo1Click
          end
          object ChangeScreenSize1: TMenuItem
            Caption = 'Change Screen Size...'
            OnClick = ChangeScreenSize1Click
          end
        end
        object ChangeFileTypeforFile1: TMenuItem
          Caption = 'Change File Type for File...'
          OnClick = ChangeFileTypeforFile1Click
        end
        object Dumpopcodesfile1: TMenuItem
          Caption = 'Dump *.opcodes file...'
          Enabled = False
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'pSystem Volumes (*.vol,*.svol)|*.vol;*.svol|Heathkit Volume (*.H' +
      '8D)|*.H8d|Any File (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 88
    Top = 24
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    FilterIndex = 0
    Left = 136
    Top = 32
  end
  object SaveDialog2: TSaveDialog
    DefaultExt = 'CSV'
    Filter = 'Comma Separated Variables (*.csv)|*.csv'
    Left = 192
    Top = 24
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = 'CSV'
    Filter = 'Comma delimited (*.csv)|*.csv'
    Left = 240
    Top = 32
  end
  object FindDialog1: TFindDialog
    Options = [frDown, frHideMatchCase, frHideWholeWord, frHideUpDown]
    OnFind = FindDialog1Find
    Left = 40
    Top = 72
  end
  object SaveDialog3: TSaveDialog
    Left = 96
    Top = 80
  end
end
