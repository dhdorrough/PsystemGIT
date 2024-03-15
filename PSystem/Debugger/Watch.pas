unit Watch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uWatchInfo, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf, ExtCtrls;

type
  TfrmWatch = class(TfrmWatchInfo)
    mmoWatchValue: TMemo;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  protected
    procedure SetWatchValue(Value: string); override;
  public
    { Public declarations }
  end;

var
  frmWatch: TfrmWatch;

implementation

{$R *.dfm}

{ TfrmWatch }

procedure TfrmWatch.SetWatchValue(Value: string);
begin
  inherited;
  mmoWatchValue.Text := Value;
end;

end.
