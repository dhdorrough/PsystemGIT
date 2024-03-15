unit GuessOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, pSys_Decl, Buttons;

type
  integer = smallint;

  TGuessOptions = record
                    RequireValidTextFiles: boolean;
                    RequireValidCodeFiles: boolean;
                    FileName: string;
                  end;

  TfrmGuessOptions = class(TForm)
    leVolumeToTest: TLabeledEdit;
    btnBrowse: TButton;
    GroupBox1: TGroupBox;
    cbRequireValidTextFiles: TCheckBox;
    cbRequireValidCodeFiles: TCheckBox;
    btnCancel: TBitBtn;
    btnBegin: TBitBtn;
    procedure btnCancelClick(Sender: TObject);
    procedure btnBeginClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure leVolumeToTestChange(Sender: TObject);
  private
    { Private declarations }
    fGuessOptions: TGuessOptions;
    fStatusProc: TStatusProc;
    procedure Enable_Buttons;
  public
    { Public declarations }
    function GuessVolFormat(TheStatusProc: TStatusProc; GuessOptions: TGuessOptions): integer;
    constructor Create(aOwner: TComponent; aStatusProc: TStatusProc); reintroduce;
  end;

var
  frmGuessOptions: TfrmGuessOptions;

implementation

{$R *.dfm}

uses
  Types, DiskFormatUtils, pSysVolumesNonStandard, SegMap, MyUtils,
  pSys_Const, pSysExceptions, pSysVolumes, FilerSettingsUnit;

procedure InitArray(var Ary: TIntegerDynArray; Args: array of integer);
var
  i: integer;
begin
  SetLength(Ary, Length(Args));
  for i := 0 to Length(Args)-1 do
    Ary[i] := Args[i]
end;

function TfrmGuessOptions.GuessVolFormat(TheStatusProc: TStatusProc; GuessOptions: TGuessOptions): integer;
const
  MAXSKEW = 6;
var
  BPSs: TIntegerDynArray;
  SPTs: TIntegerDynArray;
  DiskFormat: TDiskFormat;
  iBPS,
  iSPT,
  iSkew, iTrk0, Int,
  TheFileSize,
  VolumeFormatsChecked, GoodEntriesCount: longint;
  Volume: TNonStandardVolume;
  Msg: string;
  sfi: TSegmentFileInfo;

(*        Legal Possibilities according to Wikipedia
          SPT      : 5, 8, 9, 10, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 26, 29, 38
          BPS      : 128, 256, 512, 1024
          Trk0     : 0, 1, 2
          Skew     : < SPT
*)
  function CheckforValidDirectory(): boolean;
  const
    ILLEGAL_TEXT: TSetOfChar = [#0..#31]-[DLE, CR, LF];
  var
    fn, Kind, pn, NrBlocks: integer;
    Buffer: packed array[0..PAGE_BYTES-1] of char;
    TextInPage: string;

    function ValidFileName(ID: string; MaxLen: integer): boolean;
    var
      i: integer;
    begin { ValidFileName }
      result := Length(ID) <= MaxLen;
      if result then
        for i := 1 to Length(ID) do
          if not (ID[i] in (ALPHA_UPPER + NUMERIC + [#0 {is #0 a possibility?}, ' ', '_', '.'])) then
            begin
              result := false;
              Exit;
            end;
    end;  { ValidFileName }

  begin { CheckforValidDirectory }
    try
      with Volume.DI.RECTORY[0] do
        begin
          if not ((DFirstBlk = 0) and (DLastBlk in [6,10])) then
            raise EInvalidDirectory.Create('Bad FirstBlk');

          if DNUMFILES > MAXDIR then
            raise EInvalidDirectory.Create('Invalid DNUMFiles');

          if not ValidFileName(DVID, VIDLENG) then
            raise EInvalidDirectory.Create('Bad DVID');

          Kind := FixDFKind(DFKIND);

          if not Kind in [kUNTYPEDFILE, kSVOLFILE] then
            raise EInvalidDirectory.Create('Bad DFKIND');

          for fn := 1 to DNUMFILES do
            with Volume.DI.RECTORY[fn] do
              begin
                if not ValidFileName(DTID, TIDLENG) then
                  raise EInvalidDirectory.Create('Bad DTID');

                if DLASTBYTE > BLOCKSIZE then
                  raise EInvalidDirectory.Create('Bad DLASTBYTE');

                if DFIRSTBLK > Volume.Directory[0].DEOVBLK then
                  raise EInvalidDirectory.Create('Bad FirstBlock');

                if DLASTBLK > Volume.Directory[0].DEOVBLK then
                  raise EInvalidDirectory.Create('Bad LastBlock');

                Kind := FixDFKind(DFKIND);

                // Even though the text/code files might be bad,
                // we're only using the directory to examine for validity of the format.
                if GuessOptions.RequireValidTextFiles and (Kind = kTEXTFILE) then  // If it a text file, examine the text pages and see if they are legal text
                  begin
                    pn       := PAGE_SIZE;
                    NrBlocks := DLASTBLK - DFIRSTBLK;
                    repeat
                      Volume.SeekInVolumeFile(DFIRSTBLK + PN);
                      Volume.BlockRead(Buffer, PAGE_SIZE);
                      TextInPage := Copy(Buffer, 1, PAGE_BYTES);

                      if Length(TextInPage) = 0 then
                        raise EInvalidDirectory.Create('No text in text file');

                      if ContainsAny(TextInPage, ILLEGAL_TEXT) then
                        raise EInvalidDirectory.Create('Invalid text file');

                      pn := pn + PAGE_SIZE;
                    until pn >= NrBlocks;
                  end;
                if GuessOptions.RequireValidCodeFiles and (kind = kCODEFILE) then  // well, let's see if we can successfully process a .code file
                  begin
                    if LoadSegmentFile(DFIRSTBLK,
                                       Volume.VolStartBlockInParent,
                                       Volume,
                                       sfi,
                                       GuessOptions.FileName) then
                  end;
              end;
        end;
      result := true;
    except
      on e:Exception do
        result := false;
    end;
  end; { CheckforValidDirectory }

  procedure ShowParams();
  begin
    TheStatusProc(DiskFormatString(DiskFormat), true, true);
  end;

  procedure CheckVolume();
  begin
    try
      Volume.LoadVolumeInfo(DIRECTORY_BLOCKNR);        // try the primary directory
      Volume.ResetVolumeFile;
    except
      Volume.LoadVolumeInfo(BACKUP_DIRECTORY_BLOCKNR); // if that didn't work, try to load the backup directory
      Volume.ResetVolumeFile;
    end;

    // if we got this far, do another check on the directory
    if CheckforValidDirectory then
      begin
        with DiskFormat do
          TPD := TheFileSize div (BPS * SPT); // Just for completeness...
        ShowParams;
        Inc(GoodEntriesCount);
      end;
  end;

begin { GuessVolFormat }
  Assert(Assigned(TheStatusProc), 'StatusProc not assigned');

  TheStatusProc(Format('Scanning %s @ %s', [GuessOptions.FileName, DateTimeToStr(Now)]), true, true);
  FillChar(DiskFormat, SizeOf(DiskFormat), 0);
  DiskFormat.Ext := FixExt(ExtractFileExt(GuessOptions.FileName));
  InitArray(BPSs, [128, 256, 512, 1024]);
  InitArray(SPTs, [5, 8, 9, 10, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 26, 29, 38]);
  Volume := TNonStandardVolume.Create(nil, GuessOptions.FileName);
  Volume.OnStatusProc  := TheStatusProc; // nil;
  VolumeFormatsChecked := 0;
  GoodEntriesCount     := 0;
  try
    // 1. Get the FileSize
    TheFileSize := FileSize32(GuessOptions.FileName);

    for iBPS := Low(BPSs) to High(BPSs) do
      begin
        TheStatusProc(Format('Testing %d BPS',[BPSs[iBPS]]), TRUE, TRUE);
        for iSPT := Low(SPTs) to High(SPTs) do
          begin
            for Int := 1 to SPTs[iSPT]-1 do
              for iTrk0 := 0 to 2 do
                for iSkew := 0 to MAXSKEW {SPTs[iSPT]} do
                  begin
                    Inc(VolumeFormatsChecked);
                    DiskFormat.BPS := BPSs[iBPS];
                    Diskformat.SPT := SPTs[iSPT];
                    Diskformat.Int := Int;
                    DiskFormat.Trk := iTrk0;
                    DiskFormat.Skew := iSkew;
                    Volume.DiskFormatUtil.DiskFormat := DiskFormat;
                    try
                      CheckVolume;
                    except
                      // Keep on truckin!
                    end;
                  end;
          end;
        end;

  finally
    if GoodEntriesCount = 0 then
      begin  // Try the Apple format
        FreeAndNil(Volume);
        Volume := TMiscVolume.Create(self, GuessOptions.FileName);
        TheStatusProc('Testing Apple Format');
        Volume.DiskFormat := dfMisc;
        DiskFormat        := DiskFormatInfo[dfMisc];
        Inc(VolumeFormatsChecked);
        try
          CheckVolume;
        except
        end;
      end;

     Volume.Free;

     Msg := Format('Scanned %s @ %s', [GuessOptions.FileName, DateTimeToStr(Now)]);
     TheStatusProc(Msg, true, true);

     TheStatusProc('', true, false);

     if GoodEntriesCount = 1 then
       begin
         TheStatusProc('COMPLETE: The only plausible format found was:', true, true);
         TheStatusProc(DiskFormatString(DiskFormat), true, true);
       end else
     if GoodEntriesCount > 1 then
       begin
         Msg := Format('%d/%d (%0.4n%%) directory entries were passed. ',
                    [GoodEntriesCount, VolumeFormatsChecked,
                     GoodEntriesCount/VolumeFormatsChecked*100]);
         TheStatusProc(Msg, true, true);

         TheStatusProc('COMPLETE: Multiple possible formats were found', true, true);
       end
     else
       TheStatusProc('COMPLETE: No plausible disk formats were found', true, true);

     result := GoodEntriesCount;
  end;
end;

procedure TfrmGuessOptions.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGuessOptions.btnBeginClick(Sender: TObject);
var
  PlausibleFormats: integer;
begin
  with fGuessOptions do
    begin
      RequireValidTextFiles := cbRequireValidTextFiles.Checked;
      RequireValidCodeFiles := cbRequireValidCodeFiles.Checked;
      FileName              := leVolumeToTest.Text;
    end;
  PlausibleFormats := GuessVolFormat(fStatusProc, fGuessOptions);
  MessageFmt('Found %d plausible formats', [PlausibleFormats]);
end;

constructor TfrmGuessOptions.Create(aOwner: TComponent; aStatusProc: TStatusProc);
begin
  inherited Create(aOwner);

  leVolumeToTest.Text := FilerSettings.VolumesFolder;
  btnBegin.Enabled    := false;
  fStatusProc         := aStatusProc;
end;

procedure TfrmGuessOptions.btnBrowseClick(Sender: TObject);
var
  FilePath: string;
begin
  FilePath :=  leVolumeToTest.Text + '*.*';
  if BrowseForFile('Volume to process', FilePath, VOLUMEFILTERLIST) then
    leVolumeToTest.Text := FilePath;
  Enable_Buttons;
end;

procedure TfrmGuessOptions.leVolumeToTestChange(Sender: TObject);
begin
  Enable_Buttons;
end;

procedure TfrmGuessOptions.Enable_Buttons;
begin
  btnBegin.Enabled := FileExists(leVolumeToTest.Text);
end;

end.
