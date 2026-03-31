unit pssupport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, StrUtils;

function ClampSingle(const AValue, AMin, AMax: Single): Single;
function ClampInt(const AValue, AMin, AMax: Integer): Integer;
function DarkerColor(const AColor: TColor; const APercent: Integer = 70): TColor;
function ValueAfterEquals(const ALine: string): string;
function StartsWithText(const APrefix, ALine: string): Boolean;
function ParsePlantBool(const AValue: string; const ADefault: Boolean): Boolean;
function ParsePlantInt(const AValue: string; const ADefault: Integer): Integer;
function ParsePlantSingle(const AValue: string; const ADefault: Single): Single;
function ParsePlantColor(const AValue: string; const ADefault: TColor): TColor;
function TryExtractFieldLine(const ALine: string; out AName, AFieldID, AValue: string): Boolean;
function DegreesToTurtleAngle(const ADegrees: Single): Single;

implementation

function ClampSingle(const AValue, AMin, AMax: Single): Single;
begin
  Result := AValue;
  if Result < AMin then
    Result := AMin
  else if Result > AMax then
    Result := AMax;
end;

function ClampInt(const AValue, AMin, AMax: Integer): Integer;
begin
  Result := AValue;
  if Result < AMin then
    Result := AMin
  else if Result > AMax then
    Result := AMax;
end;

function DarkerColor(const AColor: TColor; const APercent: Integer): TColor;
var
  rgb: LongInt;
  r: Integer;
  g: Integer;
  b: Integer;
  factor: Single;
begin
  factor := ClampSingle(APercent / 100.0, 0.0, 1.0);
  rgb := ColorToRGB(AColor);
  r := Round((rgb and $FF) * factor);
  g := Round(((rgb shr 8) and $FF) * factor);
  b := Round(((rgb shr 16) and $FF) * factor);
  Result := RGBToColor(r, g, b);
end;

function ValueAfterEquals(const ALine: string): string;
var
  separatorPos: Integer;
begin
  separatorPos := Pos('=', ALine);
  if separatorPos > 0 then
    Result := Trim(Copy(ALine, separatorPos + 1, MaxInt))
  else
    Result := '';
end;

function StartsWithText(const APrefix, ALine: string): Boolean;
begin
  Result := AnsiStartsText(APrefix, Trim(ALine));
end;

function ParsePlantBool(const AValue: string; const ADefault: Boolean): Boolean;
begin
  if SameText(Trim(AValue), 'true') then
    Exit(True);
  if SameText(Trim(AValue), 'false') then
    Exit(False);
  Result := ADefault;
end;

function ParsePlantInt(const AValue: string; const ADefault: Integer): Integer;
begin
  Result := StrToIntDef(Trim(AValue), ADefault);
end;

function ParsePlantSingle(const AValue: string; const ADefault: Single): Single;
var
  normalized: string;
begin
  normalized := StringReplace(Trim(AValue), ',', '.', [rfReplaceAll]);
  Result := StrToFloatDef(normalized, ADefault);
end;

function ParsePlantColor(const AValue: string; const ADefault: TColor): TColor;
var
  parts: TStringList;
  rgbValue: LongInt;
  defaultRgb: LongInt;
begin
  if Pos(' ', Trim(AValue)) = 0 then
    Exit(TColor(StrToIntDef(Trim(AValue), Integer(ADefault))));

  parts := TStringList.Create;
  try
    defaultRgb := ColorToRGB(ADefault);
    ExtractStrings([' '], [], PChar(Trim(AValue)), parts);
    if parts.Count >= 3 then
    begin
      rgbValue := RGBToColor(
        ClampInt(StrToIntDef(parts[0], defaultRgb and $FF), 0, 255),
        ClampInt(StrToIntDef(parts[1], (defaultRgb shr 8) and $FF), 0, 255),
        ClampInt(StrToIntDef(parts[2], (defaultRgb shr 16) and $FF), 0, 255)
      );
      Result := TColor(rgbValue);
    end
    else
      Result := ADefault;
  finally
    parts.Free;
  end;
end;

function TryExtractFieldLine(const ALine: string; out AName, AFieldID, AValue: string): Boolean;
var
  openBracket: Integer;
  closeBracket: Integer;
  equalsPos: Integer;
begin
  AName := '';
  AFieldID := '';
  AValue := '';
  openBracket := Pos('[', ALine);
  closeBracket := Pos(']', ALine);
  equalsPos := Pos('=', ALine);
  Result := (openBracket > 0) and (closeBracket > openBracket) and (equalsPos > closeBracket);
  if not Result then
    Exit;

  AName := Trim(Copy(ALine, 1, openBracket - 1));
  AFieldID := Trim(Copy(ALine, openBracket + 1, closeBracket - openBracket - 1));
  AValue := Trim(Copy(ALine, equalsPos + 1, MaxInt));
end;

function DegreesToTurtleAngle(const ADegrees: Single): Single;
begin
  Result := ADegrees * 256.0 / 360.0;
end;

end.
