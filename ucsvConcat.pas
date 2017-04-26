unit ucsvConcat;

interface

type
  IcsvConcat = interface(IInvokable)
  ['{FB5401CF-69AD-41D0-8840-7A7E1F9BC7A6}']
    function LoadInputFiles: Boolean;
    function WriteOutputFile: Boolean;
  end;

  function NewCsvConcat(aFilename: string='Filename.csv'): IcsvConcat;

implementation
uses System.SysUtils, System.Classes, Spring.Collections;

type
  TcsvConcat = class(TInterfacedObject, IcsvConcat)
  private
    fInputFiles: IList<TStringList>;
    fOutputFile: TStringlist;
    fOutputFilename: string;
    fCurrentDir: string;
    procedure removeUnneededItems;
  public
    constructor Create(aoutFilename: string);
    destructor Destroy; override;
    function LoadInputFiles: Boolean;
    function WriteOutputFile: Boolean;
  end;

function NewCsvConcat(aFilename: string='Filename.csv'): IcsvConcat;
begin
  result := TcsvConcat.Create(aFilename);
end;

constructor TcsvConcat.Create(aoutFilename: string);
begin
  inherited Create;
  fOutputFilename := aoutFilename;
  fOutputFile := TStringlist.Create;
  fInputFiles := TCollections.CreateList<TStringList>;
  fCurrentDir := GetCurrentDir;
  if fCurrentDir.EndsWith('\') then
    fCurrentDir := fCurrentDir.Remove(length(fCurrentDir));
end;

destructor TcsvConcat.Destroy;
var i: integer;
begin
  FOutputFile.DisposeOf;
  for i := 0 to fInputFiles.Count - 1 do
    fInputFiles[i].DisposeOf;
  fInputFiles.Clear;
  inherited Destroy;
end;

function TcsvConcat.LoadInputFiles: Boolean;
var sr: TSearchRec;
    errCode: integer;
    matchFound: boolean;
begin
  matchFound := false;
  result := false;
  try
    errCode := FindFirst(fCurrentDir + '\*.csv',faAnyFile,sr);
    matchFound := errCode = 0;
    if matchFound then
    begin
      while errCode = 0 do
      begin
        fInputFiles.Add(TStringlist.Create);
        fInputFiles[fInputFiles.Count - 1].LoadFromFile(fCurrentDir + '\' + sr.Name);
        errCode := FindNext(sr);
      end;
    end
    else
      raise Exception.CreateFmt('Error loading input files from folder %s',[fCurrentDir]);
  finally
    FindClose(sr);
    result := matchFound;
  end;
end;

procedure TcsvConcat.removeUnneededItems;
var
    wrkStr: string;
    splitStr: TArray<string>;
    rowTestNumber,
    rowTestDate: string;
begin
  fOutputFile.Delete(2);
  fOutputFile.Delete(2);

  wrkStr := fOutputFile[0];
  splitStr := wrkStr.Split([',']);
  rowTestNumber := format('%s,%s',[splitStr[0], splitStr[1]]);

  wrkStr := fOutputFile[1];
  splitStr := wrkStr.Split([',']);
  rowTestDate := format('%s,%s',[splitStr[0], splitStr[1]]);

  fOutputFile.Delete(0);
  fOutputFile.Delete(0);
  fOutputFile.Insert(0, rowTestDate);
  fOutputFile.Insert(0, rowTestNumber);
end;

function TcsvConcat.WriteOutputFile;

  function excludeRedundantInfo(aInString: string): string;
  var
    wrkStr: string;
    splitStr: TArray<string>;
  begin
    result := '';
    wrkStr := aInString;
    splitStr := wrkStr.Split([',']);
    if length(splitStr) > 1 then
      result := format(',%s',[splitStr[1]]);
  end;

var
    wrkStr: string;
    newRow: string;
    row: integer;
    rowDataDescriptions: string;
    InputFile: TStringList;

  procedure finalizeNewRow(aNewRow: string);
  begin
    if aNewRow.Contains('Description') then
      rowDataDescriptions := aNewRow
    else
    begin
      if aNewRow.IsEmpty then
      begin
        aNewRow := rowDataDescriptions;
        rowDataDescriptions := '';
      end;
      fOutputFile.Add(aNewRow);
    end;
  end;

begin
  result := false;
  if fInputFiles.IsEmpty then
    raise Exception.Create('No input files to process!');
  try
    rowDataDescriptions := '';
    for row := 0 to fInputFiles[0].Count - 1 do
    begin
      newRow := '';
      for InputFile in fInputFiles do
      begin
        if newRow.IsEmpty then
          newRow := InputFile[Row]
        else
          newRow := newRow + excludeRedundantInfo(InputFile[Row]);
      end;
      finalizeNewRow(newRow);
    end;
    removeUnneededItems;
    result := true;
  finally
    if fOutputFile.Count > 0 then
      fOutputFile.SaveToFile(fCurrentDir + '\' + fOutputFilename);
  end;
end;

end.
