unit BinaryOps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

const
  OUT_DIFF_NAME = 'Differences';
  OUT_PATCH_NAME = 'PatchesMade';
  OUT_SCAN_NAME  = 'MatchesFound';

type
  TfrmBinaryOps = class(TForm)
    leFile1Name: TLabeledEdit;
    leFile2Name: TLabeledEdit;
    btnBegin: TButton;
    leOutputFileName: TLabeledEdit;
    lblStatus: TLabel;
    BtnBrowse1: TButton;
    btnBrowse2: TButton;
    btnBrowseOutput: TButton;
    rbCompareBinaryFiles: TRadioButton;
    rbPatchBinaryFile: TRadioButton;
    pnlData: TPanel;
    leSourceBytes: TLabeledEdit;
    leReplacementBytes: TLabeledEdit;
    rbScanForSourceBytes: TRadioButton;
    Memo1: TMemo;
    Label2: TLabel;
    procedure BtnBrowse1Click(Sender: TObject);
    procedure btnBrowse2Click(Sender: TObject);
    procedure btnBrowseOutputClick(Sender: TObject);
    procedure rbCompareBinaryFilesClick(Sender: TObject);
    procedure rbPatchBinaryFileClick(Sender: TObject);
    procedure btnBeginClick(Sender: TObject);
    procedure rbScanForSourceBytesClick(Sender: TObject);
    procedure leFile1NameChange(Sender: TObject);
    procedure leSourceBytesChange(Sender: TObject);
  private
    fInfile1, fInFile2: file;
    fOutFile: TextFile;
    fOutputFileName: string;
    procedure ModeChanged;
    procedure FindBinaryDifferences;
    procedure PatchBinaryFile(DoPatch: boolean);
    procedure Log_Status(const Msg: string);
    function OpenOutputFile(const OutputFileName: string): boolean;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frmBinaryOps: TfrmBinaryOps;

implementation

uses MyUtils, Misc, OverwriteOrAppend;

{$R *.dfm}

type
  TDifference = record
                  DiffLen: integer;
                  File1Bytes: THexBytes;
                  File2Bytes: THexBytes;
                end;

procedure TfrmBinaryOps.ModeChanged;
begin
  if rbCompareBinaryFiles.Checked then
    begin
      leFile1Name.EditLabel.Caption := 'Src File 1';
      leFile2Name.EditLabel.Caption := 'Src File 2';
      leOutputFileName.Text := ExtractFilePath(ParamStr(0)) + OUT_DIFF_NAME + '.txt';
      leFile2Name.Text := UniqueFileName(leFile1Name.Text);
      pnlData.Visible := false;
    end else
  if rbPatchBinaryFile.Checked then
    begin
      leFile1Name.EditLabel.Caption := 'Input File';
      leFile2Name.EditLabel.Caption := 'Output File';
      leOutputFileName.Text := ExtractFilePath(ParamStr(0)) + OUT_PATCH_NAME + '.txt';
      leReplacementBytes.Visible := true;
      pnlData.Visible := true;
    end else
  if rbScanForSourceBytes.Checked then
    begin
      leFile1Name.EditLabel.Caption := 'Input File';
      leOutputFileName.Text := ExtractFilePath(ParamStr(0)) + OUT_SCAN_NAME + '.txt';
      leReplacementBytes.Visible := false;
      pnlData.Visible := true;
    end;
end;



procedure TfrmBinaryOps.FindBinaryDifferences;
  type
    TBigBuf = array[0..MAXINT-1] of byte;
  var
    FileSize1, FileSize2, FileSize, i: integer;
    Buf1, Buf2: ^TBigBuf;
    idx, DiffStart, DiffEnd, DiffLen, NrDifferences: integer;
    aDifference: TDifference;
    OK: boolean;
    Temp: string;

    function NextDiff(StartIdx: integer): integer;
    var
      mode: TSearch_Type; // = (SEARCHING, SEARCH_FOUND, NOT_FOUND);
      idx: integer;
    begin { NextDiff }
      result := - 1;
      mode := SEARCHING;
      Idx  := StartIdx;
      repeat
        if idx >= FileSize then
          mode := NOT_FOUND
        else
          if Buf1[Idx] <> Buf2[idx] then
            begin
              mode := SEARCH_FOUND;
              result := idx
            end
          else
            inc(idx);
      until mode <> SEARCHING;
    end;  { NextDiff }

    function NextSame(StartIdx: integer): integer;
    var
      mode: TSearch_Type; // = (SEARCHING, SEARCH_FOUND, NOT_FOUND);
    begin { NextSame }
      result := -1;
      idx := StartIdx;
      mode := SEARCHING;
      repeat
        if idx >= FileSize then
          mode := NOT_FOUND
        else
          if (Buf1[Idx] = Buf2[idx]) and  // require 2 bytes to be the same
             (Buf1[Idx+1] = Buf2[Idx+1]) then
            begin
              mode := SEARCH_FOUND;
              result := idx
            end
          else
            inc(idx);
      until mode <> SEARCHING;
    end;  { NextSame }

    function HexBytes(NrBytes: integer; HexBytes: THexBytes): string;
    var
      i: integer;
    begin { HexBytes }
      result := '';
      for i := 0 to NrBytes-1 do
        result := result + ' ' + HexByte(HexBytes[i]);
    end;  { HexBytes }

  begin { FindBinaryDifferences }
    FileSize1 := FileSize32(leFile1Name.Text);
    FileSize2 := FileSize32(leFile2Name.Text);
    OK := FileSize1 = FileSize2;
    if not OK then
      OK := YesFmt('FileSize1 (%d) <> FileSize2 (%d). Proceed anyway?', [FileSize1, FileSize2]);

    if OK then
        begin
          FileSize := Min(FileSize1, FileSize2);

          AssignFile(fInFile1, leFile1Name.Text);
          Reset(fInFile1, FileSize);

          AssignFile(fInFile2, leFile2Name.Text);
          Reset(fInFile2, FileSize);

          if not OpenOutputFile(leOutputFileName.Text) then
            exit;

          WriteLn(fOutFile, 'BINARY FILE DIFFERENCES @ ', DateTimeToStr(Now));
          WriteLn(fOutFile, 'File #1: ', leFile1Name.Text);
          WriteLn(fOutFile, 'File #2: ', leFile2Name.Text);
          WriteLn(fOutFile);
          WriteLn(fOutFile, '  #.     Addr:  Bytes      ');
          WriteLn(fOutFile, '---.     ----:  -----      ');

          idx := 0;  NrDifferences := 0;
          try
            GetMem(Buf1, FileSize);
            GetMem(Buf2, FileSize);

            BlockRead(fInFile1, Buf1^, 1);
            BlockRead(fInFile2, Buf2^, 1);

            try
              repeat
                DiffStart := NextDiff(Idx);
                if DiffStart >= 0 then
                  begin
                    DiffEnd   := NextSame(DiffStart);
                    if DiffEnd >= 0 then
                      begin
                        DiffLen := DiffEnd - DiffStart;
                        if DiffLen > 0 then
                          begin
                            if DiffLen > MAX_DIFF_LEN then
                              DiffLen := MAX_DIFF_LEN;
                            aDifference.DiffLen := DiffLen;
                            for i := 0 to DiffLen-1 do
                              begin
                                aDifference.File1Bytes[i] := Buf1[DiffStart+i];
                                aDifference.File2Bytes[i] := Buf2[DiffStart+i];
                              end;
                          end;
                        inc(NrDifferences);
                        lblStatus.Caption := Format('%4d: %6d/%6d',
                                                    [NrDifferences+1, DiffStart, FileSize]);
                        Application.ProcessMessages;
                        with aDifference do
                          begin
                            temp := Format('%8x', [DiffStart]);
                            WriteLn(fOutFile, Format('%3d. %8s: %s', [NrDifferences, Temp,
                                                                     HexBytes(DiffLen, File1Bytes)]));
                            WriteLn(fOutFile, Format('%3s  %8s: %s', ['', '',
                                                                     HexBytes(DiffLen, File2Bytes)]));
                            WriteLn(fOutFile);
                          end;
                        idx := idx + DiffLen;
                      end;
                  end
              until (idx >= FileSize) or (DiffStart < 0);
              lblStatus.Caption := Format('%d differences were found', [NrDifferences]);
              AlertFmt('%d differences were found', [NrDifferences]);
            finally
              FreeMem(Buf2);
              FreeMem(Buf1);
            end;
          finally
            CloseFile(fOutFile);
            CloseFile(fInFile2);
            CloseFile(fInFile1);
            if not ExecAndWait('notepad.exe', fOutputFileName, false) then
              AlertFmt('Could not edit "%s"', [fOutputFileName]);
          end;
        end;
  end;  { FindBinaryDifferences }

constructor TfrmBinaryOps.Create(aOwner: TComponent);
begin
  inherited;

end;

procedure TfrmBinaryOps.BtnBrowse1Click(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leFile1Name.Text;
  if BrowseForFile('File 1', FilePath, '*') then
    leFile1Name.Text := FilePath;
end;

procedure TfrmBinaryOps.btnBrowse2Click(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leFile2Name.Text;
  if BrowseForFile('File 2', FilePath, '*') then
    leFile2Name.Text := FilePath;
end;

procedure TfrmBinaryOps.btnBrowseOutputClick(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leOutputFileName.Text;
  if BrowseForFile('Output File', FilePath, '*') then
    leOutputFileName.Text := FilePath;
end;

procedure TfrmBinaryOps.rbCompareBinaryFilesClick(Sender: TObject);
begin
  ModeChanged;
end;

procedure TfrmBinaryOps.rbPatchBinaryFileClick(Sender: TObject);
begin
  ModeChanged;
end;

function TfrmBinaryOps.OpenOutputFile(const OutputFileName: string): boolean;
var
  mr: integer;
begin
  fOutputFileName := OutputFileName;
  AssignFile(fOutFile, OutputFileName);
  if FileExists(OutputFileName) then
    begin
      mr := OverwriteItOrAppend(Format('Overwrite or append %s', [OutputFileName]));
      case mr of
        ooaOverwrite: begin ReWrite(fOutFile); result := true end;
        ooaAppend:    begin Append(fOutFile); result := true end;
        ooaCancel:    begin result := false; exit; end;
      end;
    end
  else
    begin result := TRUE; Rewrite(fOutFile) end;
end;

procedure TfrmBinaryOps.Log_Status(const Msg: string);
begin
  lblStatus.Caption := Msg;
  Application.ProcessMessages;
  WriteLn(fOutFile, Msg);
end;


procedure TfrmBinaryOps.PatchBinaryFile(DoPatch: boolean);
type
  TBigBuf = array[0..MAXINT-1] of byte;
var
  FileSize: integer;
  Buffer: ^TBigBuf;
  PatchFromTo: TDifference;
  MatchesFound, BlocksWritten, PatchesMade: integer;
  BC1, BC2: word;
  Indx, NextIndx, Ix: integer;

  function MatchesSearch(indx: system.integer): boolean;
  var
    i: integer;
  begin { MatchesSearch }
    for i := 0 to PatchFromTo.DiffLen-1 do
      begin
        if Buffer^[indx+i] <> PatchFromTo.File1Bytes[i] then
          begin
            result := false;
            exit;
          end;
      end;
    result := true;
  end;  { MatchesSearch }

  function FindMatchingBytes(StartIndx: integer): integer;
  var
    I: system.integer;
  begin { FindMatching Bytes }
    result := -1;
    try
      for I := StartIndx to FileSize-PatchFromTo.DiffLen-1 do
        begin
          if MatchesSearch(I) then
            begin
              inc(MatchesFound);
              result := I;
              exit;
            end;
        end;
    except
      on e:Exception do
        AlertFmt('%s (while processing %s)', [e.Message, leFile1Name.Text]);
    end;
  end;  { FindMatchingBytes }

begin { TfrmBinaryOps.PatchBinaryFile }
  FileSize := FileSize32(leFile1Name.Text);

  AssignFile(fInFile1, leFile1Name.Text);
  Reset(fInfile1, FileSize);

  if not OpenOutputFile(leOutputFileName.Text) then
    exit;

  GetMem(Buffer, FileSize);
  try
    Log_Status(Format('Loading %s into memory @ %s',
                      [leFile1Name.Text, DateTimeToStr(Now)]));
    BlockRead(fInFile1, Buffer^, 1);   // load the whole thing into memory
    BC1 := ConvHexStr(leSourceBytes.Text,      PatchFromTo.File1Bytes);
    PatchFromTo.DiffLen := BC1;

    BC2 := ConvHexStr(leReplacementBytes.Text, PatchFromTo.File2Bytes);
    Log_Status('Patching:');
    Log_Status('   ' + leSourceBytes.Text);
    Log_Status('   ' + leReplacementBytes.Text);
    MatchesFound := 0; PatchesMade := 0;
    if (not DoPatch) or (BC1 = BC2) then
      begin
        Indx := 0;
        repeat
          NextIndx := FindMatchingBytes(Indx);
          if NextIndx >= 0 then
            begin
              Log_Status(Format('=====>  Hex string found @ offset %s',
                                [BothWays(NextIndx)]));
              if DoPatch then
                begin
                  for ix := 0 to PatchFromTo.DiffLen-1 do
                    Buffer^[NextIndx+Ix] := PatchFromTo.File2Bytes[Ix];
                  Inc(PatchesMade);
                end;
              Indx := NextIndx + PatchFromTo.DiffLen;
            end;
        until NextIndx < 0;
        if DoPatch then // PatchesMade
          Log_Status(Format('%d/%d strings were patched in %s',
                            [PatchesMade, MatchesFound, leFile1Name.Text]))
        else
          Log_Status(Format('%d matching strings were found in %s',
                            [MatchesFound, leFile1Name.Text]));
      end
    else
      AlertFmt('Number of bytes must be the same: %d <> %d', [BC1, BC2]);

  finally
    CloseFile(fInFile1);
    CloseFile(fOutFile);
    if MatchesFound > 0 then
      begin
        if not ExecAndWait('notepad.exe', fOutputFileName, false) then
          AlertFmt('Could not edit "%s"', [fOutputFileName])
        else
          if DoPatch then
            if YesFmt('Update the patched file "%s"?', [leFile2Name.Text]) then
              begin
                AssignFile(fInFile2, leFile2Name.Text);
                ReWrite(fInFile2, FileSize);
                BlockWrite(fInFile2, Buffer^, 1, BlocksWritten);
                if BlocksWritten = 1 then
                  MessageFmt('The file "%s" was updated', [leFile2Name.Text])
                else
                  AlertFmt('The file "%s" could not be updated', [leFile2Name.Text]);
              end
      end;
    FreeMem(Buffer);
  end;
end;  { TfrmBinaryOps.PatchBinaryFile }


procedure TfrmBinaryOps.btnBeginClick(Sender: TObject);
begin
  if rbCompareBinaryFiles.Checked then
    FindBinaryDifferences else
  if rbScanForSourceBytes.Checked then
    PatchBinaryFile(false) else
  if rbPatchBinaryFile.Checked then
    PatchBinaryFile(true);
end;

procedure TfrmBinaryOps.rbScanForSourceBytesClick(Sender: TObject);
begin
  ModeChanged;
end;

procedure TfrmBinaryOps.leFile1NameChange(Sender: TObject);
begin
  leFile2Name.Text := UniqueFileName(leFile1Name.Text);
end;

procedure TfrmBinaryOps.leSourceBytesChange(Sender: TObject);
var
  BC1: integer;
  BC2: integer;
  PatchFromTo: TDifference;
begin
  if rbScanForSourceBytes.Checked then
    begin
      BC1 := ConvHexStr(leSourceBytes.Text,      PatchFromTo.File1Bytes);
      btnBegin.Enabled := BC1 > 0;
    end else
  if rbPatchBinaryFile.Checked then
    begin
      BC1 := ConvHexStr(leSourceBytes.Text,      PatchFromTo.File1Bytes);
      BC2 := ConvHexStr(leReplacementBytes.Text, PatchFromTo.File2Bytes);
      btnBegin.Enabled := (BC1 > 0) and (BC1 = BC2);
    end else
  if rbCompareBinaryFiles.Checked then
    btnBegin.Enabled := true;
end;

end.
