unit psplanttext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, pstdo, psplantmodel;

type
  TPlantStudioTextLibrary = class
  private
    FPlantNames: TStringList;
    FPlants: TObjectList;
    FTdoLibrary: TStringList;
    function ParsePlantName(const ALine: string): string;
    procedure ParseOffset(const ALine: string);
    procedure ClearTdoLibrary;
    procedure LoadTdoLibrary(const APlantFileName: string);
    procedure AddTdoLibraryObject(AObject: KfObject3D);
    function ResolveNamedTdo(const AName: string): KfObject3D;
    function ParsePlant(ALines: TStrings; var AIndex: Integer): PdPlant;
  public
    SourceFile: string;
    OffsetX: Double;
    OffsetY: Double;
    Scale: Double;
    Concentrated: Boolean;
    Orientation: Integer;
    Boxes: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function LoadFromFile(const AFileName: string): Boolean;
    function PlantAt(const AIndex: Integer): PdPlant;
    property PlantNames: TStringList read FPlantNames;
    property Plants: TObjectList read FPlants;
  end;

implementation

uses
  pssupport, usstream;

constructor TPlantStudioTextLibrary.Create;
begin
  inherited Create;
  FPlantNames := TStringList.Create;
  FPlants := TObjectList.Create(True);
  FTdoLibrary := TStringList.Create;
  FTdoLibrary.CaseSensitive := False;
  Clear;
end;

destructor TPlantStudioTextLibrary.Destroy;
begin
  ClearTdoLibrary;
  FTdoLibrary.Free;
  FPlants.Free;
  FPlantNames.Free;
  inherited Destroy;
end;

procedure TPlantStudioTextLibrary.ClearTdoLibrary;
var
  i: Integer;
begin
  for i := 0 to FTdoLibrary.Count - 1 do
    FTdoLibrary.Objects[i].Free;
  FTdoLibrary.Clear;
end;

procedure TPlantStudioTextLibrary.Clear;
begin
  SourceFile := '';
  OffsetX := 0.0;
  OffsetY := 0.0;
  Scale := 1.0;
  Concentrated := False;
  Orientation := 0;
  Boxes := True;
  FPlantNames.Clear;
  FPlants.Clear;
  ClearTdoLibrary;
end;

function TPlantStudioTextLibrary.ParsePlantName(const ALine: string): string;
var
  closeBracket: Integer;
begin
  closeBracket := Pos(']', ALine);
  if closeBracket <= 2 then
    Exit('');
  Result := Trim(Copy(ALine, 2, closeBracket - 2));
end;

procedure TPlantStudioTextLibrary.ParseOffset(const ALine: string);
var
  stream: KfStringStream;
begin
  stream := KfStringStream.CreateFromString(ValueAfterEquals(ALine));
  try
    OffsetX := stream.NextSingle;
    OffsetY := stream.NextSingle;
  finally
    stream.Free;
  end;
end;

procedure TPlantStudioTextLibrary.AddTdoLibraryObject(AObject: KfObject3D);
begin
  if (AObject = nil) or (Trim(AObject.Name) = '') then
  begin
    AObject.Free;
    Exit;
  end;
  FTdoLibrary.AddObject(UpperCase(Trim(AObject.Name)), AObject);
end;

function TPlantStudioTextLibrary.ResolveNamedTdo(const AName: string): KfObject3D;
var
  index: Integer;
begin
  Result := nil;
  index := FTdoLibrary.IndexOf(UpperCase(Trim(AName)));
  if index >= 0 then
    Result := KfObject3D(FTdoLibrary.Objects[index]).Clone;
end;

procedure TPlantStudioTextLibrary.LoadTdoLibrary(const APlantFileName: string);
var
  libraryPath: string;
  lines: TStringList;
  index: Integer;
  object3D: KfObject3D;
begin
  libraryPath := ExpandFileName(ExtractFilePath(APlantFileName) + '3D object library.tdo');
  if not FileExists(libraryPath) then
    Exit;

  lines := TStringList.Create;
  try
    lines.LoadFromFile(libraryPath);
    index := 0;
    while index < lines.Count do
    begin
      if Trim(lines[index]) = '' then
      begin
        Inc(index);
        Continue;
      end;
      object3D := KfObject3D.Create;
      if object3D.ReadFromLines(lines, index, False) then
        AddTdoLibraryObject(object3D)
      else
        object3D.Free;
    end;
  finally
    lines.Free;
  end;
end;

function TPlantStudioTextLibrary.ParsePlant(ALines: TStrings; var AIndex: Integer): PdPlant;
var
  line: string;
  name: string;
  fieldName: string;
  fieldID: string;
  value: string;
  objectIndex: Integer;
  objectName: string;
  object3D: KfObject3D;
begin
  Result := PdPlant.Create;
  Result.Name := ParsePlantName(Trim(ALines[AIndex]));
  Inc(AIndex);
  while AIndex < ALines.Count do
  begin
    line := Trim(ALines[AIndex]);
    if line = '' then
    begin
      Inc(AIndex);
      Continue;
    end;
    if line[1] = ';' then
    begin
      Inc(AIndex);
      Continue;
    end;
    if Pos('end PlantStudio plant', line) > 0 then
    begin
      Inc(AIndex);
      Break;
    end;
    if TryExtractFieldLine(line, fieldName, fieldID, value) then
    begin
      objectName := value;
      if Pos('OBJECT3D', UpperCase(fieldID)) > 0 then
      begin
        objectIndex := AIndex + 1;
        object3D := nil;
        if (objectIndex < ALines.Count) and StartsWithText(kStartTdoString, Trim(ALines[objectIndex])) then
        begin
          object3D := KfObject3D.Create;
          if object3D.ReadFromLines(ALines, objectIndex, True) then
          begin
            Result.AssignTdo(fieldID, object3D);
            AIndex := objectIndex;
            Continue;
          end;
          FreeAndNil(object3D);
        end;
        object3D := ResolveNamedTdo(objectName);
        if object3D <> nil then
          Result.AssignTdo(fieldID, object3D);
      end;
      Result.ApplyField(fieldID, value);
    end;
    Inc(AIndex);
  end;
  Result.RebuildStructure;
end;

function TPlantStudioTextLibrary.LoadFromFile(const AFileName: string): Boolean;
var
  lines: TStringList;
  index: Integer;
  line: string;
  plant: PdPlant;
begin
  Result := False;
  Clear;
  if not FileExists(AFileName) then
    Exit;

  lines := TStringList.Create;
  try
    lines.LoadFromFile(AFileName);
    SourceFile := ExpandFileName(AFileName);
    LoadTdoLibrary(SourceFile);
    index := 0;
    while index < lines.Count do
    begin
      line := Trim(lines[index]);
      if line = '' then
      begin
        Inc(index);
        Continue;
      end;
      if line[1] = ';' then
      begin
        Inc(index);
        Continue;
      end;

      if StartsWithText('offset=', line) then
        ParseOffset(line)
      else if StartsWithText('scale=', line) then
        Scale := ParsePlantSingle(ValueAfterEquals(line), 1.0)
      else if StartsWithText('concentrated=', line) then
        Concentrated := ParsePlantBool(ValueAfterEquals(line), False)
      else if StartsWithText('orientation (top/side)=', line) then
        Orientation := ParsePlantInt(ValueAfterEquals(line), 0)
      else if StartsWithText('boxes=', line) then
        Boxes := ParsePlantBool(ValueAfterEquals(line), True)
      else if (line[1] = '[') and (Pos('start PlantStudio plant', line) > 0) then
      begin
        plant := ParsePlant(lines, index);
        FPlants.Add(plant);
        FPlantNames.Add(plant.Name);
        Continue;
      end;
      Inc(index);
    end;
    Result := FPlants.Count > 0;
  finally
    lines.Free;
  end;
end;

function TPlantStudioTextLibrary.PlantAt(const AIndex: Integer): PdPlant;
begin
  if (AIndex >= 0) and (AIndex < FPlants.Count) then
    Result := PdPlant(FPlants[AIndex])
  else
    Result := nil;
end;

end.
