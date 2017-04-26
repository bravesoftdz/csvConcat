program csvConcat;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ucsvConcat in 'ucsvConcat.pas';

var MycsvConcat: IcsvConcat;

begin
  try
    if ParamCount < 1 then
      MycsvConcat := NewCsvConcat
    else
      MycsvConcat := NewCsvConcat(paramstr(1));
    MycsvConcat.LoadInputFiles;
    MycsvConcat.WriteOutputFile;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
