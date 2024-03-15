inherited frmUpdateConfirm: TfrmUpdateConfirm
  Left = 527
  Top = 272
  Width = 921
  Height = 685
  BorderStyle = bsSizeable
  Caption = 'Confirm Update'
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  inherited lblPrompt: TLabel
    Left = 33
    Top = 597
    Width = 863
    Height = 17
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
  end
  inherited btnYes: TButton
    Left = 659
    Top = 620
    Anchors = [akRight, akBottom]
  end
  inherited btnNo: TButton
    Left = 743
    Top = 620
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 826
    Top = 620
    Anchors = [akRight, akBottom]
  end
  inherited btnNoAndDontAskAgain: TButton
    Left = 433
    Top = 620
    Width = 215
    Anchors = [akRight, akBottom]
  end
  inherited btnYesAndDontAskAgain: TButton
    Left = 224
    Top = 620
    Width = 200
    Anchors = [akRight, akBottom]
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 912
    Height = 593
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 5
    object Splitter1: TSplitter
      Left = 449
      Top = 1
      Width = 4
      Height = 591
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 448
      Height = 591
      Align = alLeft
      Caption = 'Panel2'
      TabOrder = 0
      DesignSize = (
        448
        591)
      object MemoPCode: TMemo
        Left = 16
        Top = 8
        Width = 426
        Height = 569
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'MemoPCode'
          '')
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object Panel3: TPanel
      Left = 453
      Top = 1
      Width = 458
      Height = 591
      Align = alClient
      Caption = 'Panel3'
      TabOrder = 1
      DesignSize = (
        458
        591)
      object MemoSrcCode: TMemo
        Left = 0
        Top = 7
        Width = 448
        Height = 569
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'MemoSrcCode')
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object btnEnterProcedureInfo: TButton
    Left = 17
    Top = 620
    Width = 139
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Enter Procedure Info'
    TabOrder = 6
    OnClick = btnEnterProcedureInfoClick
  end
end
