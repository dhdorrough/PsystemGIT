object frmSyscomSettings: TfrmSyscomSettings
  Left = 1071
  Top = 450
  Width = 483
  Height = 275
  Caption = 'Syscom Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    467
    236)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 32
    Top = 208
    Width = 40
    Height = 13
    Caption = 'lblStatus'
  end
  object btnCancel: TBitBtn
    Left = 385
    Top = 204
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object btnUpdate: TBitBtn
    Left = 297
    Top = 204
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Update'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnUpdateClick
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 468
    Height = 193
    ActivePage = tabCRT
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnChange = PageControl1Change
    object tabCodePool: TTabSheet
      Caption = 'Code Pool'
      object Label1: TLabel
        Left = 24
        Top = 44
        Width = 44
        Height = 13
        Caption = 'Pool Size'
      end
      object Label2: TLabel
        Left = 24
        Top = 69
        Width = 89
        Height = 13
        Caption = 'Pool Base Address'
      end
      object Label3: TLabel
        Left = 24
        Top = 94
        Width = 50
        Height = 13
        Caption = 'Resolution'
      end
      object lblHexPoolsize: TLabel
        Left = 192
        Top = 43
        Width = 24
        Height = 13
        Caption = '0000'
      end
      object lblHexBaseAddress: TLabel
        Left = 192
        Top = 68
        Width = 48
        Height = 13
        Caption = '00000000'
      end
      object lblHexResolution: TLabel
        Left = 192
        Top = 93
        Width = 12
        Height = 13
        Caption = '99'
      end
      object lblPoolBase0and1: TLabel
        Left = 252
        Top = 68
        Width = 57
        Height = 13
        Caption = '[0000 0000]'
      end
      object cbPoolOutside: TCheckBox
        Left = 24
        Top = 16
        Width = 97
        Height = 17
        Caption = 'Pool Outside'
        TabOrder = 0
      end
      object ovcPoolSize: TOvcNumericField
        Left = 118
        Top = 39
        Width = 60
        Height = 21
        Cursor = crIBeam
        DataType = nftLongInt
        AutoSize = False
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '999999'
        TabOrder = 1
        AfterExit = ovcPoolSizeAfterExit
        RangeHigh = {00000200000000000000}
        RangeLow = {00000000000000000000}
      end
      object ovcBaseAddress: TOvcNumericField
        Left = 118
        Top = 64
        Width = 60
        Height = 21
        Cursor = crIBeam
        DataType = nftLongInt
        AutoSize = False
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '9999999'
        TabOrder = 2
        AfterExit = ovcBaseAddressAfterExit
        RangeHigh = {00000200000000000000}
        RangeLow = {00000000000000000000}
      end
      object ovcResolution: TOvcNumericField
        Left = 118
        Top = 89
        Width = 60
        Height = 21
        Cursor = crIBeam
        DataType = nftLongInt
        AutoSize = False
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '999'
        TabOrder = 3
        AfterExit = ovcResolutionAfterExit
        OnUserValidation = ovcResolutionUserValidation
        RangeHigh = {00020000000000000000}
        RangeLow = {00000000000000000000}
      end
    end
    object tabCRT: TTabSheet
      Caption = 'CRT'
      ImageIndex = 1
      object Label4: TLabel
        Left = 24
        Top = 28
        Width = 34
        Height = 13
        Caption = 'Width'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label5: TLabel
        Left = 24
        Top = 72
        Width = 38
        Height = 13
        Caption = 'Height'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ovcWidth: TOvcNumericField
        Left = 78
        Top = 25
        Width = 56
        Height = 21
        Cursor = crIBeam
        DataType = nftByte
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '999'
        TabOrder = 0
        RangeHigh = {FF000000000000000000}
        RangeLow = {00000000000000000000}
      end
      object ovcHeight: TOvcNumericField
        Left = 78
        Top = 68
        Width = 56
        Height = 21
        Cursor = crIBeam
        DataType = nftByte
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '999'
        TabOrder = 1
        RangeHigh = {FF000000000000000000}
        RangeLow = {00000000000000000000}
      end
    end
  end
end
