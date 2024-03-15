inherited frmSelectProcedure: TfrmSelectProcedure
  Left = 1496
  Top = 242
  Caption = 'Select Procedure'
  PixelsPerInch = 96
  TextHeight = 13
  inherited Label5: TLabel
    Visible = False
  end
  inherited Label4: TLabel
    Visible = False
  end
  inherited edtComment: TEdit
    Visible = False
  end
  inherited pnlParam: TPanel
    inherited ovcParam: TOvcNumericField
      RangeHigh = {63000000000000000000}
      RangeLow = {00000000000000000000}
    end
  end
  inherited pnlProcBreak: TPanel
    inherited ovcProcNr: TOvcNumericField
      RangeHigh = {FF7F0000000000000000}
      RangeLow = {00000000000000000000}
    end
    inherited ovcIPC: TOvcNumericField
      RangeHigh = {FF7F0000000000000000}
      RangeLow = {00000000000000000000}
    end
  end
  inherited cbBreakKind: TComboBox
    Visible = False
  end
end
