unit RawFileParams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmRawParameters = class(TForm)
    Button1: TButton;
    leRawInputFileName: TLabeledEdit;
    leRawOutputFileName: TLabeledEdit;
    btnBegin: TButton;
    leStringToSearchFor: TLabeledEdit;
    leStartingBlockNr: TLabeledEdit;
    leNrBlocksToCopy: TLabeledEdit;
  private
    function GetInFileName: string;
    procedure SetInFileName(const Value: string);
    function GetStartingBlockNr: longint;
    procedure SetStartingBlockNr(const Value: longint);
    function GetOutFileName: string;
    procedure SetOutFileName(const Value: string);
    function GetNrBlocks: longint;
    procedure SetNrBlocks(const Value: longint);
    function GetSearchFor: string;
    procedure SetSearchFor(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    property InFileName: string
             read GetInFileName
             write SetInFileName;
    property OutFileName: string
             read GetOutFileName
             write SetOutFileName;
    property StartingBlockNr: longint
             read GetStartingBlockNr
             write SetStartingBlockNr;
    property NrBlocks: longint
             read GetNrBlocks
             write SetNrBlocks;
    property SearchFor: string
             read GetSearchFor
             write SetSearchFor;
  end;

var
  frmRawParameters: TfrmRawParameters;

implementation

{$R *.dfm}

{ TfrmRawParameters }

function TfrmRawParameters.GetInFileName: string;
begin
  result := leRawInputFileName.Text;
end;

function TfrmRawParameters.GetNrBlocks: longint;
begin
  result := StrToInt(leNrBlocksToCopy.Text);
end;

function TfrmRawParameters.GetOutFileName: string;
begin
  result := leRawOutputFileName.Text;
end;

function TfrmRawParameters.GetSearchFor: string;
begin
  result := leStringToSearchFor.Text;
end;

function TfrmRawParameters.GetStartingBlockNr: longint;
begin
  result := StrToInt(leStartingBlockNr.Text);
end;

procedure TfrmRawParameters.SetInFileName(const Value: string);
begin
  leRawInputFileName.Text := Value;
end;

procedure TfrmRawParameters.SetNrBlocks(const Value: longint);
begin
  leNrBlocksToCopy.Text := IntToStr(Value);
end;

procedure TfrmRawParameters.SetOutFileName(const Value: string);
begin
  leRawOutputFileName.Text := Value;
end;

procedure TfrmRawParameters.SetSearchFor(const Value: string);
begin
  leStringToSearchFor.Text := Value;
end;

procedure TfrmRawParameters.SetStartingBlockNr(const Value: longint);
begin
  leStartingBlockNr.Text := IntToStr(Value);
end;

end.
