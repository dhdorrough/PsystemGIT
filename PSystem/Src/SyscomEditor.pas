unit SyscomEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf, Buttons, pSysVolumes, UCSDGlob,
  ComCtrls, ExtCtrls;

type
  TSyscomWhat = (sw_Unknown, sw_CodePool, sw_CrtSize);

  TfrmSyscomSettings = class(TForm)
    btnCancel: TBitBtn;
    btnUpdate: TBitBtn;
    lblStatus: TLabel;
    PageControl1: TPageControl;
    tabCodePool: TTabSheet;
    tabCRT: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblHexPoolsize: TLabel;
    lblHexBaseAddress: TLabel;
    lblHexResolution: TLabel;
    lblPoolBase0and1: TLabel;
    cbPoolOutside: TCheckBox;
    ovcPoolSize: TOvcNumericField;
    ovcBaseAddress: TOvcNumericField;
    ovcResolution: TOvcNumericField;
    ovcWidth: TOvcNumericField;
    ovcHeight: TOvcNumericField;
    Label4: TLabel;
    Label5: TLabel;
    procedure btnUpdateClick(Sender: TObject);
    procedure ovcResolutionUserValidation(Sender: TObject;
      var ErrorCode: Word);
    procedure ovcPoolSizeAfterExit(Sender: TObject);
    procedure ovcBaseAddressAfterExit(Sender: TObject);
    procedure ovcResolutionAfterExit(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
    fTheVolume: TVolume;
    fDirIdx: integer;
    fBuffer: record
              case integer of
                1: (blocks: array[0..1] of TBlock);
                2: (SysCom: TIVSysComRec);
            end;
    fSyscomWhat: TSyscomWhat;
    procedure UpdateHexValues;
    procedure UpdateCrtInfo;
  public
    { Public declarations }
    procedure UpdatePoolInfo;
    Constructor Create(aOwner: TComponent; SyscomWhat: TSyscomWhat; TheVolume: TVolume; DirIdx: integer); reintroduce;
  end;


var
  frmSyscomSettings: TfrmSyscomSettings;

implementation

uses MyUtils, Misc;

{$R *.dfm}

procedure TfrmSyscomSettings.UpdatePoolInfo;
begin
  if Assigned(fTheVolume) then
    with fBuffer.SysCom do
      with PoolInfo do
        begin
          PoolOutside     := cbPoolOutSide.Checked;
          PoolSize        := ovcPoolSize.AsInteger;
          Resolution      := ovcResolution.AsInteger;
          PoolBaseAddr    := LongintToFulladdress(ovcBaseAddress.AsVariant);

          lblStatus.Caption := Format('PoolOutside was changed to %s. FileDate NOT changed!', [TF(PoolOutside)]);
        end;
end;

procedure TfrmSyscomSettings.UpdateCrtInfo;
begin
  if Assigned(fTheVolume) then
    with fBuffer.SysCom do
      with CrtInfo do
        begin
          Width := ovcWidth.AsInteger;
          Height:= ovcHeight.AsInteger;
        end;
end;


constructor TfrmSyscomSettings.Create(aOwner: TComponent; SyscomWhat: TSyscomWhat;
  TheVolume: TVolume; DirIdx: integer);
begin
  inherited Create(aOwner);
  fSyscomWhat := SyscomWhat;
  case SyscomWhat of
   sw_CodePool: PageControl1.ActivePage := tabCodePool;
   sw_CrtSize:  PageControl1.ActivePage := tabCRT;
  end;
  fTheVolume   := TheVolume;
  fDirIdx      := DirIdx;
  if Assigned(fTheVolume) then
    with fTheVolume do
      with Directory[fDirIdx] do
        begin
          SeekInVolumeFile(FirstBlk);
          BlockRead(fBuffer, 2);
          lblStatus.Caption := FileNAME;
          with fBuffer.SysCom do
            begin
              case SyscomWhat of
                sw_CodePool:
                  with PoolInfo do
                    begin
                      cbPoolOutSide.Checked    := PoolOutside;
                      ovcPoolSize.AsInteger    := PoolSize;
                      ovcResolution.AsInteger  := Resolution;
                      ovcBaseAddress.AsInteger := FulladdressToLongWord(PoolBaseAddr);
                      UpdateHexValues;
                    end;
                sw_CrtSize:
                  begin
                    ovcWidth.AsInteger  := CrtInfo.width;
                    ovcHeight.AsInteger := CrtInfo.height;
                  end;
              end;
            end;
        end;
end;

procedure TfrmSyscomSettings.btnUpdateClick(Sender: TObject);
begin
  case fSyscomWhat of
   sw_CodePool: UpdatePoolInfo;
   sw_CrtSize:  UpdateCrtInfo;
  end;

  with fTheVolume do
    begin
      SeekInVolumeFile(Directory[fDirIdx].FirstBlk);
      BlockWrite(fBuffer, 2);
    end;
end;

procedure TfrmSyscomSettings.ovcResolutionUserValidation(Sender: TObject;
  var ErrorCode: Word);
begin
  if BitCount(ovcResolution.AsInteger) <> 1 then // not a multiple of 2
    begin
      lblStatus.Caption := 'Resolution must be a power of 2';
      ErrorCode := 1;
    end
  else
    lblStatus.Caption := '';
end;

procedure TfrmSyscomSettings.ovcPoolSizeAfterExit(Sender: TObject);
begin
  UpdateHexValues;
end;

procedure TfrmSyscomSettings.ovcBaseAddressAfterExit(Sender: TObject);
begin
  UpdateHexValues;
end;

procedure TfrmSyscomSettings.ovcResolutionAfterExit(Sender: TObject);
begin
  UpdateHexValues;
end;

procedure TfrmSyscomSettings.UpdateHexValues;
var
  fa: FullAddress;
begin
  lblHexPoolSize.Caption      := Format('%4.4x',       [ovcPoolSize.AsInteger]);
  lblHexResolution.Caption    := Format('%4.4x',       [ovcResolution.AsInteger]);
  lblHexBaseAddress.Caption   := Format('%8.8x',       [ovcBaseAddress.AsInteger]);
  fa := LongintToFulladdress(ovcBaseAddress.AsInteger);
  lblPoolBase0and1.Caption    := Format('[%4.4x %4.4x]', [fa[0], fa[1]]);
end;


procedure TfrmSyscomSettings.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tabCrt then
    fSyscomWhat := sw_CrtSize else
  if PageControl1.ActivePage = tabCodePool then
    fSyscomWhat := sw_CodePool;
end;

end.
