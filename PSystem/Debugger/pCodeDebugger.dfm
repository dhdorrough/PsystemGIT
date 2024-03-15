object frmPCodeDebugger: TfrmPCodeDebugger
  Left = 456
  Top = 256
  Width = 1100
  Height = 758
  Caption = 'p-Code Debugger IV'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = True
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1067
    Height = 425
    ActivePage = tabPCode
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = PageControl1Change
    object tabPCode: TTabSheet
      Caption = 'p-Code/Source'
      object Panel1: TPanel
        Left = 629
        Top = 0
        Width = 430
        Height = 397
        Align = alRight
        Caption = 'Panel1'
        TabOrder = 0
        DesignSize = (
          430
          397)
        object sgRegisters: TStringGrid
          Left = 261
          Top = 0
          Width = 168
          Height = 397
          Hint = 'Registers'
          Anchors = [akTop, akRight, akBottom]
          ColCount = 2
          DefaultRowHeight = 18
          FixedCols = 0
          RowCount = 20
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          ColWidths = (
            66
            109)
        end
        object Panel4: TPanel
          Left = 1
          Top = 1
          Width = 257
          Height = 395
          Align = alLeft
          BevelOuter = bvNone
          Caption = 'PanelStacks'
          TabOrder = 1
          object sgStatic: TStringGrid
            Left = 0
            Top = 137
            Width = 257
            Height = 132
            Hint = 'Static Call Stack'
            Align = alClient
            ColCount = 3
            DefaultRowHeight = 18
            FixedCols = 0
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
            ParentShowHint = False
            PopupMenu = pumCallStack
            ShowHint = True
            TabOrder = 0
            OnClick = sgCallStackClick
            OnDblClick = sgStaticDblClick
            OnDrawCell = sgStaticDrawCell
            ColWidths = (
              36
              178
              64)
          end
          object sgPStack: TStringGrid
            Tag = 1
            Left = 0
            Top = 269
            Width = 257
            Height = 126
            Hint = 'Parameter Call Stack'
            Align = alBottom
            DefaultRowHeight = 16
            FixedCols = 0
            RowCount = 11
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Courier New'
            Font.Style = []
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
            ParentFont = False
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            ColWidths = (
              34
              40
              39
              45
              78)
          end
          object sgCallStack: TStringGrid
            Left = 0
            Top = 0
            Width = 257
            Height = 137
            Hint = 'Dynamic Call Stack'
            Align = alTop
            ColCount = 3
            DefaultRowHeight = 18
            FixedCols = 0
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
            ParentShowHint = False
            PopupMenu = pumCallStack
            ShowHint = True
            TabOrder = 2
            OnClick = sgCallStackClick
            OnDblClick = sgCallStackDblClick
            OnDrawCell = sgCallStackDrawCell
            ColWidths = (
              33
              183
              64)
          end
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 629
        Height = 397
        Align = alClient
        Caption = 'Panel2'
        TabOrder = 1
        object Splitter1: TSplitter
          Left = 1
          Top = 155
          Width = 627
          Height = 3
          Cursor = crVSplit
          Align = alTop
        end
        object Memo1: TMemo
          Left = 1
          Top = 1
          Width = 627
          Height = 154
          Align = alTop
          BevelEdges = []
          BevelInner = bvNone
          BevelOuter = bvNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          Lines.Strings = (
            '')
          ParentFont = False
          ParentShowHint = False
          PopupMenu = pumPCode1
          ScrollBars = ssBoth
          ShowHint = False
          TabOrder = 0
          WantTabs = True
          WordWrap = False
          OnChange = Memo1Change
          OnClick = MemoClick
          OnKeyDown = MemoKeyDown
          OnKeyPress = MemoKeyPress
          OnMouseDown = Memo1MouseDown
        end
        object Memo3: TMemo
          Left = 1
          Top = 158
          Width = 627
          Height = 238
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          Lines.Strings = (
            'Memo3')
          ParentFont = False
          ParentShowHint = False
          PopupMenu = pumSourceCode
          ScrollBars = ssBoth
          ShowHint = False
          TabOrder = 1
          WantTabs = True
          WordWrap = False
          OnClick = MemoClick
          OnKeyDown = MemoKeyDown
          OnKeyPress = MemoKeyPress
          OnMouseDown = Memo1MouseDown
        end
      end
    end
    object tabBreakPoints: TTabSheet
      Caption = 'Breakpoint List'
      ImageIndex = 1
      object sgBreakPoints: TStringGrid
        Left = 0
        Top = 0
        Width = 1102
        Height = 397
        Align = alClient
        ColCount = 7
        DefaultRowHeight = 18
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        PopupMenu = pumBreakPoints
        TabOrder = 0
        OnDblClick = EditBreakpoint1Click
        OnDrawCell = sgBreakPointsDrawCell
        ColWidths = (
          64
          83
          36
          222
          112
          60
          372)
      end
    end
    object tabSysCom: TTabSheet
      Caption = 'SysCom'
      ImageIndex = 2
      DesignSize = (
        1059
        397)
      object memoSyscom: TMemo
        Left = 0
        Top = 0
        Width = 1059
        Height = 369
        Align = alTop
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'memoSyscom')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
      object cbOffsetInHex: TCheckBox
        Left = 6
        Top = 376
        Width = 97
        Height = 17
        Anchors = [akLeft, akBottom]
        Caption = 'Addr in Hex'
        TabOrder = 1
        OnClick = cbOffsetInHexClick
      end
      object cbAddrInHex: TCheckBox
        Left = 103
        Top = 376
        Width = 97
        Height = 17
        Anchors = [akLeft, akBottom]
        Caption = 'Offset In Hex'
        TabOrder = 2
        OnClick = cbAddrInHexClick
      end
      object leSyscomAddr: TLabeledEdit
        Left = 301
        Top = 373
        Width = 87
        Height = 21
        Anchors = [akLeft, akBottom]
        EditLabel.Width = 78
        EditLabel.Height = 13
        EditLabel.Caption = 'Syscom Address'
        LabelPosition = lpLeft
        LabelSpacing = 10
        TabOrder = 3
        OnExit = leSyscomAddrExit
      end
    end
    object TabCrtKeyInfo: TTabSheet
      Caption = 'CRT/Key Info'
      ImageIndex = 7
      object MemoCrtKeyInfo: TMemo
        Left = 0
        Top = 0
        Width = 1059
        Height = 397
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'MemoCrtKeyInfo')
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object tabHistory: TTabSheet
      Caption = 'History'
      ImageIndex = 3
      DesignSize = (
        1059
        397)
      object lblOpsPHITS: TLabel
        Left = 448
        Top = 8
        Width = 64
        Height = 13
        Caption = 'Ops PHITS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblPHITS: TLabel
        Left = 448
        Top = 376
        Width = 32
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'PHITS'
      end
      object lblDbgCnt: TLabel
        Left = 4
        Top = 378
        Width = 36
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'DbgCnt'
      end
      object lbpCSPPHITS: TLabel
        Left = 776
        Top = 8
        Width = 66
        Height = 13
        Caption = 'CSP PHITS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCSPPHITS: TLabel
        Left = 784
        Top = 376
        Width = 56
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'CSP PHITS'
      end
      object lblReminder: TLabel
        Left = 432
        Top = 232
        Width = 379
        Height = 29
        Caption = 'POCAHONTAS is not $DEFINEd'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -23
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label1: TLabel
        Left = 40
        Top = 208
        Width = 258
        Height = 29
        Caption = 'History is not $DEFINEd'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -23
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object sgHistory: TStringGrid
        Left = 8
        Top = 32
        Width = 425
        Height = 338
        Anchors = [akLeft, akTop, akBottom]
        ColCount = 7
        DefaultRowHeight = 18
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnDblClick = sgHistoryDblClick
        ColWidths = (
          49
          77
          36
          106
          133
          49
          64)
      end
      object leMaxHistory: TLabeledEdit
        Left = 114
        Top = 5
        Width = 53
        Height = 21
        EditLabel.Width = 101
        EditLabel.Height = 13
        EditLabel.Caption = 'Max History Items'
        EditLabel.Font.Charset = DEFAULT_CHARSET
        EditLabel.Font.Color = clWindowText
        EditLabel.Font.Height = -11
        EditLabel.Font.Name = 'MS Sans Serif'
        EditLabel.Font.Style = [fsBold]
        EditLabel.ParentFont = False
        LabelPosition = lpLeft
        LabelSpacing = 10
        TabOrder = 1
        OnChange = leMaxHistoryChange
      end
      object sgPHITS: TStringGrid
        Left = 440
        Top = 32
        Width = 321
        Height = 337
        Anchors = [akLeft, akTop, akBottom]
        DefaultRowHeight = 18
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ParentFont = False
        PopupMenu = pumPHITS
        ScrollBars = ssVertical
        TabOrder = 2
        ColWidths = (
          49
          54
          90
          52
          66)
      end
      object sgCSPPhits: TStringGrid
        Left = 776
        Top = 32
        Width = 321
        Height = 337
        Anchors = [akLeft, akTop, akBottom]
        DefaultRowHeight = 18
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ParentFont = False
        PopupMenu = pumPHITS
        ScrollBars = ssVertical
        TabOrder = 3
        ColWidths = (
          49
          54
          90
          52
          66)
      end
      object cbCallHistoryOnly: TCheckBox
        Left = 184
        Top = 8
        Width = 97
        Height = 17
        Caption = 'Call History Only'
        TabOrder = 4
        OnClick = cbCallHistoryOnlyClick
      end
      object btnResetOpsPhits: TButton
        Left = 681
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Reset'
        TabOrder = 5
        OnClick = btnResetOpsPhitsClick
      end
      object btnResetCspPhits: TButton
        Left = 1016
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Reset'
        TabOrder = 6
        OnClick = btnResetCspPhitsClick
      end
    end
    object tabMessages: TTabSheet
      Caption = 'Messages'
      ImageIndex = 4
      object sgMessages: TStringGrid
        Left = 0
        Top = 0
        Width = 925
        Height = 360
        Align = alClient
        ColCount = 6
        DefaultRowHeight = 18
        FixedCols = 0
        RowCount = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ParentFont = False
        TabOrder = 0
        ColWidths = (
          57
          106
          58
          95
          44
          293)
        RowHeights = (
          18
          18)
      end
    end
    object tabProfile: TTabSheet
      Caption = 'Profile'
      ImageIndex = 5
      DesignSize = (
        1059
        397)
      object lblTotal: TLabel
        Left = 600
        Top = 62
        Width = 34
        Height = 13
        Caption = 'lblTotal'
      end
      object Label3: TLabel
        Left = 456
        Top = 62
        Width = 129
        Height = 13
        Caption = 'Total Instructions Executed'
      end
      object Label2: TLabel
        Left = 464
        Top = 96
        Width = 486
        Height = 13
        Caption = 
          'Counts indicate the number of instructions that were executed wi' +
          'thin the specified Segment/Procedure '
        Color = clYellow
        ParentColor = False
      end
      object sgProfile: TStringGrid
        Left = 0
        Top = 32
        Width = 449
        Height = 363
        Anchors = [akLeft, akTop, akBottom]
        ColCount = 6
        DefaultRowHeight = 18
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
        PopupMenu = pumProfile
        TabOrder = 0
        ColWidths = (
          64
          150
          141
          64
          64
          64)
      end
      object btnReset: TButton
        Left = 456
        Top = 32
        Width = 75
        Height = 25
        Caption = 'Reset'
        TabOrder = 1
        OnClick = btnResetClick
      end
      object btnRefresh: TButton
        Left = 552
        Top = 32
        Width = 75
        Height = 25
        Caption = 'Refresh'
        TabOrder = 2
        OnClick = btnRefreshClick
      end
    end
    object tabDirectory: TTabSheet
      Caption = 'Global Directory'
      ImageIndex = 6
      object lblDirectory: TLabel
        Left = 8
        Top = 8
        Width = 65
        Height = 13
        Caption = 'lblDirectory'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object sgDirectory: TStringGrid
        Left = 0
        Top = 28
        Width = 925
        Height = 332
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        DefaultRowHeight = 16
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = sgDirectoryDrawCell
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 425
    Width = 1067
    Height = 282
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel3'
    TabOrder = 1
    DesignSize = (
      1067
      282)
    object lblStatus: TLabel
      Left = 82
      Top = 259
      Width = 40
      Height = 13
      Caption = 'lblStatus'
      OnDblClick = lblStatusDblClick
    end
    object lblRowCol: TLabel
      Left = 1038
      Top = 259
      Width = 43
      Height = 13
      Alignment = taRightJustify
      Anchors = [akRight, akBottom]
      Caption = 'Row, Col'
    end
    object lblEditMode: TLabel
      Left = 16
      Top = 259
      Width = 55
      Height = 13
      Caption = 'lblEditMode'
    end
    object lblAccDb: TLabel
      Left = 960
      Top = 259
      Width = 43
      Height = 13
      Alignment = taRightJustify
      Anchors = [akRight, akBottom]
      Caption = 'lblAccDb'
    end
    object sgWatchList: TStringGrid
      Left = 13
      Top = 16
      Width = 1074
      Height = 233
      Anchors = [akLeft, akTop, akRight]
      DefaultRowHeight = 15
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
      ParentFont = False
      ParentShowHint = False
      PopupMenu = pumWatchList
      ShowHint = False
      TabOrder = 0
      OnDblClick = sgWatchListDblClick
      OnDrawCell = sgWatchListDrawCell
      ColWidths = (
        64
        40
        72
        50
        943)
    end
    object btnMoveUp: TBitBtn
      Left = 1096
      Top = 32
      Width = 25
      Height = 49
      Anchors = [akRight, akBottom]
      TabOrder = 1
      Visible = False
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000333
        3333333333777F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333FF7F7FFFF333333000090000
        3333333777737777F333333099999990333333373F3333373333333309999903
        333333337F33337F33333333099999033333333373F333733333333330999033
        3333333337F337F3333333333099903333333333373F37333333333333090333
        33333333337F7F33333333333309033333333333337373333333333333303333
        333333333337F333333333333330333333333333333733333333}
      NumGlyphs = 2
    end
    object btnMoveDown: TBitBtn
      Left = 1096
      Top = 96
      Width = 25
      Height = 49
      Anchors = [akRight, akBottom]
      TabOrder = 2
      Visible = False
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
        333333333337F33333333333333033333333333333373F333333333333090333
        33333333337F7F33333333333309033333333333337373F33333333330999033
        3333333337F337F33333333330999033333333333733373F3333333309999903
        333333337F33337F33333333099999033333333373333373F333333099999990
        33333337FFFF3FF7F33333300009000033333337777F77773333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333300033333333333337773333333}
      NumGlyphs = 2
    end
  end
  object MainMenu1: TMainMenu
    Left = 336
    Top = 16
    object File1: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Caption = '&New Debug Database....'
        OnClick = New1Click
      end
      object Open1: TMenuItem
        Caption = '&Load p-Code...'
        OnClick = Open1Click
      end
      object PasteExternalpCode1: TMenuItem
        Caption = 'Paste External p-Code'
        OnClick = PasteExternalpCode1Click
      end
      object SaveDBInfoToTextFiles: TMenuItem
        Caption = 'Backup DB Info to Text Files...'
        OnClick = SaveDBToTextFiles
      end
      object N13: TMenuItem
        Caption = '-'
      end
      object miSearchAll: TMenuItem
        Caption = 'Search ALL for String...'
        OnClick = miSearchAllClick
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object Print1: TMenuItem
        Caption = '&Print...'
        object PrintcurrentpCode1: TMenuItem
          Caption = 'Print Current p-Code'
          OnClick = PrintcurrentpCode1Click
        end
        object PrintcurrentSourceCode1: TMenuItem
          Caption = 'Print Current Source Code'
          OnClick = PrintcurrentSourceCode1Click
        end
        object PrintWatchList1: TMenuItem
          Caption = 'Print Watch List'
          OnClick = PrintWatchList1Click
        end
        object PrintBreakpointList1: TMenuItem
          Caption = 'Print Breakpoint List'
          OnClick = PrintBreakpointList1Click
        end
        object PrintSyscom1: TMenuItem
          Caption = 'Print Syscom'
          OnClick = PrintSyscom1Click
        end
        object PrintMessages1: TMenuItem
          Caption = 'Print Messages'
          OnClick = PrintMessages1Click
        end
        object PrintGlobalDirectory1: TMenuItem
          Caption = 'Print Global Directory'
          OnClick = PrintGlobalDirectory1Click
        end
        object PrintSegmentProcNames1: TMenuItem
          Caption = 'Print Segment/ProcNames'
          OnClick = PrintSegmentProcNames1Click
        end
        object PrintHistory1: TMenuItem
          Caption = 'Print History'
          OnClick = PrintHistory1Click
        end
        object PrintOpsPHITS1: TMenuItem
          Caption = 'Print Ops PHITS'
          OnClick = PrintOpsPHITS1Click
        end
        object PrintCSPPhits1: TMenuItem
          Caption = 'Print CSP Phits'
          OnClick = PrintCSPPhits1Click
        end
        object PrintDynamicCallStack1: TMenuItem
          Caption = 'Print Dynamic Call Stack'
          OnClick = PrintDynamicCallStack1Click
        end
        object PrintStaticCallStack1: TMenuItem
          Caption = 'Print Static Call Stack'
          OnClick = PrintStaticCallStack1Click
        end
        object PrintStack1: TMenuItem
          Caption = 'Print Stack'
          OnClick = PrintStack1Click
        end
        object PrintRegisters1: TMenuItem
          Caption = 'Print Registers'
          OnClick = PrintRegisters1Click
        end
      end
      object PrintSetup1: TMenuItem
        Caption = 'P&rint Setup...'
        Enabled = False
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object DebuggerSettings1: TMenuItem
        Caption = 'Debugger Settings...'
        OnClick = DebuggerSettings1Click
      end
      object DebuggerDatabases1: TMenuItem
        Caption = 'Database Settings...'
        OnClick = DebuggerDatabases1Click
      end
      object CatalogDebuggerDatabases1: TMenuItem
        Caption = 'Catalog Debugger Databases...'
      end
      object pCodeProcsTableforUpdate1: TMenuItem
        Caption = 'pCodeProcs Table for Update...'
      end
      object N23: TMenuItem
        Caption = '-'
      end
      object DashBoard1: TMenuItem
        Caption = 'New DashBoard...'
        ShortCut = 16450
        OnClick = DashBoard1Click
      end
      object ExternalDecoderWindow1: TMenuItem
        Caption = 'External Decoder Window...'
        OnClick = ExternalDecoderWindow1Click
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object UpdateCursor1: TMenuItem
        Caption = 'Update Cursor'
        OnClick = UpdateCursor1Click
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object Undo1: TMenuItem
        Caption = '&Undo'
        ShortCut = 16474
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Cut1: TMenuItem
        Caption = 'Cu&t'
        ShortCut = 16472
      end
      object Copy1: TMenuItem
        Caption = '&Copy'
        ShortCut = 16451
      end
      object Paste1: TMenuItem
        Caption = '&Paste'
        ShortCut = 16470
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Find1: TMenuItem
        Caption = '&Find...'
        ShortCut = 16454
        OnClick = FindInMemoClick
      end
      object FindAgain1: TMenuItem
        Caption = 'Entry'
        ShortCut = 114
        OnClick = FindAgainClick
      end
      object Replace1: TMenuItem
        Caption = 'R&eplace...'
        Enabled = False
      end
      object GoTo1: TMenuItem
        Caption = '&Go To...'
      end
      object N24: TMenuItem
        Caption = '-'
      end
      object FindStringinMemory1: TMenuItem
        Caption = 'Find String in Memory...'
        OnClick = FindStringinMemory1Click
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object EnableMemoEditing1: TMenuItem
        Caption = 'Enable Memo Editing'
        ShortCut = 16453
        OnClick = EnableMemoEditing1Click
      end
    end
    object Run1: TMenuItem
      Caption = 'Run'
      object RuntoCursor1: TMenuItem
        Caption = 'Run to Cursor'
        ShortCut = 115
        OnClick = RuntoCursor1Click
      end
      object Stepinto1: TMenuItem
        Caption = 'Step Into'
        ShortCut = 118
        OnClick = Stepinto1Click
      end
      object StepOver1: TMenuItem
        Caption = '&Step Over'
        ShortCut = 119
        OnClick = StepOver1Click
      end
      object Run3: TMenuItem
        Caption = 'Run'
        ShortCut = 120
        OnClick = Run3Click
      end
      object RunUntilReturn1: TMenuItem
        Caption = 'Run Until Return'
        ShortCut = 8311
        OnClick = RunUntilReturn1Click
      end
      object RefreshDisplay1: TMenuItem
        Caption = 'Refresh Display'
        ShortCut = 116
        OnClick = RefreshDisplay1Click
      end
      object ExitFaultHandler1: TMenuItem
        Caption = 'Exit Fault Handler'
        OnClick = ExitFaultHandler1Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Load1: TMenuItem
        Caption = 'Load'
        OnClick = Load1Click
      end
      object miLoadFromLast: TMenuItem
        Caption = 'Load from Last'
        ShortCut = 121
        OnClick = miLoadFromLastClick
      end
      object ProgramReset1: TMenuItem
        Caption = 'Program Reset'
        ShortCut = 16497
        OnClick = ProgramReset1Click
      end
    end
    object Breakpoints1: TMenuItem
      Caption = 'Breakpoints'
      OnClick = Breakpoints1Click
      object Toggle1: TMenuItem
        Caption = 'Toggle Selected'
        ShortCut = 113
        OnClick = ToggleBreakpoint1Click
      end
      object Changedmemoryglobal1: TMenuItem
        Caption = '&Changed memory global'
        Enabled = False
      end
      object Expressiontrueglobal1: TMenuItem
        Caption = '&Expression true global'
        Enabled = False
      end
      object Deleteall1: TMenuItem
        Caption = '&Delete all...'
        OnClick = DeleteAllWatches1Click
      end
      object BreakonpHits0: TMenuItem
        Caption = 'Break on p-Hits = 0'
        Enabled = False
        OnClick = BreakonpHits0Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object AddBreakpoint1: TMenuItem
        Caption = 'Add Breakpoint'
        ShortCut = 16449
        OnClick = AddBreakpoint2Click
      end
      object EditBreakpoint1: TMenuItem
        Caption = 'Edit Breakpoint'
        ShortCut = 16453
        OnClick = EditBreakpoint1Click
      end
      object DisplayBreakpoints1: TMenuItem
        Caption = 'Display Breakpoints'
        ShortCut = 16452
        OnClick = DisplayBreakpoints1Click
      end
      object DeleteBreakpoint1: TMenuItem
        Caption = 'Delete Selected'
        OnClick = DeleteBreakpoint1Click
      end
      object CloseBreakpointLogfile1: TMenuItem
        Caption = 'Close Breakpoint Logfile...'
        OnClick = CloseBreakpointLogfile1Click
      end
    end
    object Watches1: TMenuItem
      Caption = 'Watches'
      object CreateInspector1: TMenuItem
        Caption = 'Create Inspector...'
        ShortCut = 16457
        OnClick = CreateInspector1Click
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object miLocalVariables: TMenuItem
        Caption = 'Local Variables...'
        ShortCut = 16460
        OnClick = miLocalVariablesClick
      end
      object miGlobalVariables: TMenuItem
        Caption = 'Global Variables...'
        ShortCut = 16455
        OnClick = miGlobalVariablesClick
      end
    end
    object Utilities1: TMenuItem
      Caption = 'Utilities'
      object SegnamesProcnames1: TMenuItem
        Caption = 'Segnames/Procnames'
        object VerifySegnamesProcNames1: TMenuItem
          Caption = 'Verify'
          OnClick = VerifySegnamesProcNames1Click
        end
        object ReloadSegNamesProcnames1: TMenuItem
          Caption = 'Reload'
          OnClick = ReloadSegNamesProcnames1Click
        end
        object ListProcNames1: TMenuItem
          Caption = 'List SegNames/ProcNames'
          OnClick = ListProcNames1Click
        end
        object AddProcName1: TMenuItem
          Caption = 'Edit/Add Proc Names...'
          OnClick = AddProcName1Click
        end
        object PrintSegmentProcNames3: TMenuItem
          Caption = 'Print Segment/ProcNames'
          OnClick = PrintSegmentProcNames1Click
        end
        object SaveSegnamesProcnamestoDB1: TMenuItem
          Caption = 'Save to DB'
          Enabled = False
        end
      end
      object DisplayaSYSCOMMISCINFO1: TMenuItem
        Caption = 'Display Crt/Key Info from SYSCOM.MISCINFO'
        OnClick = DisplayaSYSCOMMISCINFO1Click
      end
      object DumpDebugInfo1: TMenuItem
        Caption = 'Dump Debug Info...'
        OnClick = DumpDebugInfo1Click
      end
      object ListingUtilities1: TMenuItem
        Caption = 'Debugger Database Utilities...'
        object CatalogDebuggerDatabases2: TMenuItem
          Caption = 'Catalog Debugger Databases...'
          OnClick = CatalogDebuggerDatabasesClick
        end
        object ListFileUtilities1: TMenuItem
          Caption = 'Compiler Listing Utilities...'
          OnClick = ListingUtilities1Click
        end
        object ScanCodeFilesandUpdateDB1: TMenuItem
          Caption = 'Scan Code File(s) and Update DB...'
          OnClick = ScanCodeFilesandUpdateDB1Click
        end
        object NewDatabase1: TMenuItem
          Caption = 'New Database...'
          Enabled = False
        end
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      Enabled = False
      object Contents1: TMenuItem
        Caption = '&Contents'
      end
      object SearchforHelpOn1: TMenuItem
        Caption = '&Search for Help On...'
      end
      object HowtoUseHelp1: TMenuItem
        Caption = '&How to Use Help'
      end
      object About1: TMenuItem
        Caption = '&About...'
      end
    end
  end
  object pumBreakPoints: TPopupMenu
    Left = 476
    object AddBreakpoint2: TMenuItem
      Caption = 'Add Breakpoint...'
      ShortCut = 16449
      OnClick = AddBreakpoint2Click
    end
    object EditBreakPoint2: TMenuItem
      Caption = 'Edit Break Point...'
      ShortCut = 16453
      OnClick = EditBreakpoint1Click
    end
    object DeleteBreakPoint2: TMenuItem
      Caption = 'Delete Selected'
      ShortCut = 16452
      OnClick = DeleteBreakPoint2Click
    end
    object ToggleEnabled1: TMenuItem
      Caption = 'Toggle Selected'
      ShortCut = 16468
      OnClick = ToggleEnabled1Click
    end
    object DisableAllBreakpoints1: TMenuItem
      Caption = 'Disable All Breakpoints'
      OnClick = DisableAllBreakpoints1Click
    end
    object ToggleAllBreakpoints1: TMenuItem
      Caption = 'Toggle All Breakpoints'
      OnClick = ToggleAllBreakpoints1Click
    end
    object DeleteAllBreakpoints1: TMenuItem
      Caption = 'Delete All Breakpoints...'
      OnClick = DeleteAllBreakpoints1Click
    end
    object N20: TMenuItem
      Caption = '-'
    end
    object CreateInspector2: TMenuItem
      Caption = 'Create Inspector...'
      ShortCut = 16457
      OnClick = CreateInspector2Click
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object SaveSettings1: TMenuItem
      Caption = 'Save Settings'
      ShortCut = 16467
      OnClick = SaveSettings1Click
    end
  end
  object pumPCode1: TPopupMenu
    OnPopup = pumPopup
    Left = 236
    Top = 88
    object ToggleBreakpoint1: TMenuItem
      Caption = 'Toggle Breakpoint'
      ShortCut = 16468
      OnClick = ToggleBreakpoint1Click
    end
    object RuntoHere1: TMenuItem
      Caption = 'Run to Here'
      OnClick = RuntoHere1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object PasteExternalpCode2: TMenuItem
      Caption = 'Paste External p-Code'
      OnClick = PasteExternalpCode2Click
    end
    object SaveUpdatedpCode1: TMenuItem
      Caption = 'Save Updated p-Code...'
      OnClick = SaveUpdatedpCode1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Copy2: TMenuItem
      Caption = 'Copy'
      ShortCut = 16451
      OnClick = Copy2Click
    end
    object Paste2: TMenuItem
      Caption = 'Paste'
      ShortCut = 16470
      OnClick = Paste2Click
    end
    object Cut2: TMenuItem
      Caption = 'Cut'
      ShortCut = 16472
      OnClick = Cut2Click
    end
    object Undo2: TMenuItem
      Caption = 'Undo'
      ShortCut = 16474
      OnClick = UndoClick
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAllClick
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object FindinMemo2: TMenuItem
      Caption = 'Find in Memo...'
      ShortCut = 16454
      OnClick = FindInMemoClick
    end
    object FindAgain3: TMenuItem
      Caption = 'Find Again'
      ShortCut = 114
      OnClick = FindAgainClick
    end
  end
  object pumSourceCode: TPopupMenu
    OnPopup = pumPopup
    Left = 268
    Top = 280
    object miToggleBreakPoint: TMenuItem
      Caption = 'Toggle Breakpoint'
      ShortCut = 113
      OnClick = ToggleBreakpoint1Click
    end
    object miRunToHere: TMenuItem
      Caption = 'Run to Here'
      ShortCut = 115
      OnClick = miRunToHereClick
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object miPasteExternalSourceCode: TMenuItem
      Caption = 'Paste External Source Code from'
    end
    object miSaveUpdatedSourceCode: TMenuItem
      Caption = 'Save Updated Source Code...'
      OnClick = SaveUpdatedpCode1Click
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object miMemo3Copy: TMenuItem
      Caption = 'Copy'
      ShortCut = 16451
      OnClick = miMemo3CopyClick
    end
    object miMemo3Paste: TMenuItem
      Caption = 'Paste'
      ShortCut = 16470
      OnClick = miMemo3PasteClick
    end
    object miMemo3Cut: TMenuItem
      Caption = 'Cut'
      ShortCut = 16472
      OnClick = miMemo3CutClick
    end
    object Undo3: TMenuItem
      Caption = 'Undo'
      ShortCut = 16474
      OnClick = UndoClick
    end
    object SelectAll2: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAllClick
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object FindinMemo1: TMenuItem
      Caption = 'Find in Memo...'
      ShortCut = 16454
      OnClick = FindInMemoClick
    end
    object FindAgain2: TMenuItem
      Caption = 'Find Again'
      ShortCut = 114
    end
  end
  object FindDialog1: TFindDialog
    Options = [frDown, frHideMatchCase, frHideWholeWord, frHideUpDown]
    OnFind = FindDialog1Find
    Left = 528
  end
  object pumWatchList: TPopupMenu
    Left = 413
    Top = 632
    object AddWatchItem1: TMenuItem
      Caption = 'Add Watch Item...'
      ShortCut = 16500
      OnClick = AddWatchItem1Click
    end
    object EditWatchItem1: TMenuItem
      Caption = 'Edit Watch Item...'
      OnClick = EditWatchItem1Click
    end
    object DeleteWatchItem1: TMenuItem
      Caption = 'Delete Watch Item...'
      OnClick = DeleteWatchItem1Click
    end
    object DeleteAllWatches1: TMenuItem
      Caption = 'Delete All Watches...'
      OnClick = DeleteAllWatches1Click
    end
    object DisableAllWatches1: TMenuItem
      Caption = 'Disable All Watches'
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object miInspect: TMenuItem
      Caption = 'Inspect...'
      ShortCut = 16457
      OnClick = miInspectClick
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object CopyWatchName1: TMenuItem
      Caption = 'Copy Watch Name'
      OnClick = CopyWatchName1Click
    end
    object CopyWatchValue1: TMenuItem
      Caption = 'Copy Watch Value'
      OnClick = CopyWatchValue1Click
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object SaveSettings2: TMenuItem
      Caption = 'Save Settings'
      OnClick = SaveSettings1Click
    end
  end
  object pumCallStack: TPopupMenu
    Left = 914
    Top = 73
    object LoadProcedure1: TMenuItem
      Caption = 'Load Procedure...'
      OnClick = LoadProcedure1Click
    end
    object ViewMSCW1: TMenuItem
      Caption = 'View MSCW'
      OnClick = ViewMSCW1Click
    end
    object DisplayLocalVariables1: TMenuItem
      Caption = 'Display Local Variables...'
      OnClick = miDisplayLocalIntermediate
    end
    object DisplayGlobalVariables1: TMenuItem
      Caption = 'Display Global Variables...'
      OnClick = miDisplayGlobalIntermediate
    end
  end
  object pumPHITS: TPopupMenu
    Left = 524
    Top = 224
    object Sort1: TMenuItem
      Caption = 'Sort'
      object Alphabetically1: TMenuItem
        Caption = 'Alphabetically'
        OnClick = Alphabetically1Click
      end
      object BYphits1: TMenuItem
        Caption = 'by PHITS'
        OnClick = BYphits1Click
      end
      object byOPCode1: TMenuItem
        Caption = 'by OPCode'
        OnClick = byOPCode1Click
      end
    end
  end
  object pumProfile: TPopupMenu
    Left = 340
    Top = 280
    object SortbyCount1: TMenuItem
      Caption = 'Sort by Count'
      OnClick = SortbyCount1Click
    end
    object SortbyProcName1: TMenuItem
      Caption = 'Sort by ProcName'
      OnClick = SortbyProcName1Click
    end
    object SortbySegName1: TMenuItem
      Caption = 'Sort by SegName'
      OnClick = SortbySegName1Click
    end
  end
  object FindDialog2: TFindDialog
    Options = [frDown, frHideWholeWord, frHideUpDown]
    OnFind = FindDialog2Find
    Left = 544
    Top = 400
  end
end
