program plantstudio_native;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  SysUtils,
  mainform;

begin
  RequireDerivedFormResource := True;
  Application.Title := 'PlantStudio Native';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TPlantStudioMainForm, PlantStudioMainForm);
  Application.Run;
end.
