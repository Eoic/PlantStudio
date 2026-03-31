unit psplatform;

{$mode objfpc}{$H+}

interface

function PlantStudioConfigDir: string;
function PlantStudioConfigFile: string;

implementation

uses
  SysUtils;

function UserHomeDir: string;
begin
  Result := GetEnvironmentVariable('HOME');
  if Result = '' then
    Result := GetCurrentDir;
end;

function PlantStudioConfigDir: string;
var
  xdgConfigHome: string;
begin
  xdgConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if xdgConfigHome = '' then
    xdgConfigHome := IncludeTrailingPathDelimiter(UserHomeDir) + '.config';
  Result := IncludeTrailingPathDelimiter(xdgConfigHome) + 'plantstudio';
end;

function PlantStudioConfigFile: string;
begin
  Result := IncludeTrailingPathDelimiter(PlantStudioConfigDir) + 'PlantStudio2.ini';
end;

end.
