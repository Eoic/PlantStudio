unit pstdo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Contnrs, Graphics, usstream, ps3dtypes, psturtle;

const
  kStartTdoString = 'start 3D object';
  kEndTdoString = 'end 3D object';

type
  KfIndexTriangle = class
  public
    PointIndexes: array[0..2] of LongInt;
    constructor CreateABC(const A, B, C: LongInt);
  end;

  KfObject3D = class
  private
    FPoints: array of KfPoint3D;
    function GetPoint(const AIndex: Integer): KfPoint3D;
    procedure SetPoint(const AIndex: Integer; const AValue: KfPoint3D);
  public
    PointsInUse: LongInt;
    OriginPointIndex: LongInt;
    Triangles: TObjectList;
    Name: string;
    BoundsRect: TRect;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure EnsureEnoughSpaceForNewPointData(const ATotalNumberOfPointsToBeUsed: LongInt);
    property Points[const AIndex: Integer]: KfPoint3D read GetPoint write SetPoint;
    function AddPoint(const APoint: KfPoint3D): SmallInt;
    function AddPointIfNoMatch(const APoint: KfPoint3D; const AMatchDistance: Single): SmallInt;
    procedure AddTriangle(const ATriangle: KfIndexTriangle);
    function TriangleForIndex(const AIndex: LongInt): KfIndexTriangle;
    procedure AdjustForOrigin;
    procedure SetOriginPointIndex(const ANewOriginPointIndex: Integer);
    procedure AddPointString(const AStream: KfStringStream);
    procedure AddTriangleString(const AStream: KfStringStream);
    function ReadFromLines(ALines: TStrings; var AIndex: Integer; const AEmbeddedInPlant: Boolean): Boolean;
    function Draw(ATurtle: KfTurtle; const AScale: Single; const APartID: LongInt): TRect;
    function Clone: KfObject3D;
  end;

implementation

uses
  pssupport;

constructor KfIndexTriangle.CreateABC(const A, B, C: LongInt);
begin
  inherited Create;
  PointIndexes[0] := A;
  PointIndexes[1] := B;
  PointIndexes[2] := C;
end;

constructor KfObject3D.Create;
begin
  inherited Create;
  Triangles := TObjectList.Create(True);
  Clear;
end;

destructor KfObject3D.Destroy;
begin
  Triangles.Free;
  inherited Destroy;
end;

procedure KfObject3D.Clear;
begin
  SetLength(FPoints, 0);
  PointsInUse := 0;
  OriginPointIndex := 0;
  Name := '';
  Triangles.Clear;
  BoundsRect := Rect(0, 0, 0, 0);
end;

procedure KfObject3D.EnsureEnoughSpaceForNewPointData(const ATotalNumberOfPointsToBeUsed: LongInt);
var
  newSize: LongInt;
begin
  if Length(FPoints) >= ATotalNumberOfPointsToBeUsed then
    Exit;
  newSize := Length(FPoints);
  if newSize = 0 then
    newSize := 16;
  while newSize < ATotalNumberOfPointsToBeUsed do
    newSize := newSize * 2;
  SetLength(FPoints, newSize);
end;

function KfObject3D.GetPoint(const AIndex: Integer): KfPoint3D;
begin
  Result := FPoints[AIndex];
end;

procedure KfObject3D.SetPoint(const AIndex: Integer; const AValue: KfPoint3D);
begin
  FPoints[AIndex] := AValue;
end;

function KfObject3D.AddPoint(const APoint: KfPoint3D): SmallInt;
begin
  EnsureEnoughSpaceForNewPointData(PointsInUse + 1);
  FPoints[PointsInUse] := APoint;
  Inc(PointsInUse);
  Result := PointsInUse;
end;

function KfObject3D.AddPointIfNoMatch(const APoint: KfPoint3D; const AMatchDistance: Single): SmallInt;
var
  i: SmallInt;
begin
  for i := 0 to PointsInUse - 1 do
    if KfPoint3D_MatchXYZ(APoint, FPoints[i], AMatchDistance) then
      Exit(i + 1);
  Result := AddPoint(APoint);
end;

procedure KfObject3D.AddTriangle(const ATriangle: KfIndexTriangle);
begin
  Triangles.Add(ATriangle);
end;

function KfObject3D.TriangleForIndex(const AIndex: LongInt): KfIndexTriangle;
begin
  Result := KfIndexTriangle(Triangles[AIndex - 1]);
end;

procedure KfObject3D.AdjustForOrigin;
var
  i: LongInt;
  tempPoint: KfPoint3D;
begin
  if PointsInUse < 1 then
    Exit;
  if OriginPointIndex < 0 then
    OriginPointIndex := 0;
  if OriginPointIndex > PointsInUse - 1 then
    OriginPointIndex := PointsInUse - 1;
  for i := 0 to PointsInUse - 1 do
    if i <> OriginPointIndex then
    begin
      tempPoint := FPoints[i];
      KfPoint3D_Subtract(tempPoint, FPoints[OriginPointIndex]);
      FPoints[i] := tempPoint;
    end;
  KfPoint3D_SetXYZ(tempPoint, 0.0, 0.0, 0.0);
  FPoints[OriginPointIndex] := tempPoint;
end;

procedure KfObject3D.SetOriginPointIndex(const ANewOriginPointIndex: Integer);
begin
  OriginPointIndex := ANewOriginPointIndex;
  AdjustForOrigin;
end;

procedure KfObject3D.AddPointString(const AStream: KfStringStream);
var
  point3D: KfPoint3D;
begin
  KfPoint3D_SetXYZ(point3D, AStream.NextInteger, AStream.NextInteger, AStream.NextInteger);
  AddPoint(point3D);
end;

procedure KfObject3D.AddTriangleString(const AStream: KfStringStream);
var
  p1: Integer;
  p2: Integer;
  p3: Integer;
begin
  p1 := AStream.NextInteger;
  p2 := AStream.NextInteger;
  p3 := AStream.NextInteger;
  if (p1 <= 0) or (p2 <= 0) or (p3 <= 0) or (p1 > PointsInUse) or (p2 > PointsInUse) or (p3 > PointsInUse) then
    Exit;
  AddTriangle(KfIndexTriangle.CreateABC(p1, p2, p3));
end;

function KfObject3D.ReadFromLines(ALines: TStrings; var AIndex: Integer; const AEmbeddedInPlant: Boolean): Boolean;
var
  line: string;
  fieldType: string;
  stream: KfStringStream;
  startSeen: Boolean;
begin
  Result := False;
  Clear;
  if AEmbeddedInPlant then
  begin
    while AIndex < ALines.Count do
    begin
      line := Trim(ALines[AIndex]);
      if line = '' then
      begin
        Inc(AIndex);
        Continue;
      end;
      if StartsWithText(kStartTdoString, line) then
      begin
        Inc(AIndex);
        Break;
      end;
      Exit(False);
    end;
  end
  else if (AIndex < ALines.Count) and (Trim(ALines[AIndex]) = '[Three-dimensional object]') then
    Inc(AIndex);

  startSeen := False;
  stream := KfStringStream.Create;
  try
    while AIndex < ALines.Count do
    begin
      line := Trim(ALines[AIndex]);
      if (line = '') and (not AEmbeddedInPlant) and startSeen then
      begin
        Inc(AIndex);
        Break;
      end;
      if line = '' then
      begin
        Inc(AIndex);
        Continue;
      end;
      if (line[1] = ';') and (Pos('ORIGIN', UpperCase(line)) <= 0) then
      begin
        Inc(AIndex);
        Continue;
      end;
      if StartsWithText(kEndTdoString, line) then
      begin
        Inc(AIndex);
        Break;
      end;
      if (not AEmbeddedInPlant) and (line[1] = '[') then
      begin
        Inc(AIndex);
        Continue;
      end;

      stream.OnStringSeparator(line, '=');
      fieldType := UpperCase(stream.NextToken);
      stream.SpaceSeparator;
      startSeen := True;
      if Pos('POINT', fieldType) > 0 then
        AddPointString(stream)
      else if Pos('ORIGIN', fieldType) > 0 then
        OriginPointIndex := StrToIntDef(Trim(stream.Remainder), 0)
      else if Pos('TRIANGLE', fieldType) > 0 then
        AddTriangleString(stream)
      else if Pos('NAME', fieldType) > 0 then
        Name := Trim(stream.Remainder)
      else if (not AEmbeddedInPlant) and (Pos('[', line) = 1) then
        // Ignore old header lines.
      else if AEmbeddedInPlant then
        Break
      else if startSeen then
        Break;
      Inc(AIndex);
    end;
    AdjustForOrigin;
    Result := (PointsInUse > 0) and (Triangles.Count > 0);
  finally
    stream.Free;
  end;
end;

function KfObject3D.Draw(ATurtle: KfTurtle; const AScale: Single; const APartID: LongInt): TRect;
var
  i: LongInt;
  triangle: KfIndexTriangle;
begin
  Result := Rect(0, 0, 0, 0);
  BoundsRect := Rect(0, 0, 0, 0);
  if ATurtle = nil then
    Exit;
  ATurtle.ClearRecording;
  for i := 0 to PointsInUse - 1 do
    KfPoint3D_AddPointToBoundsRect(BoundsRect, ATurtle.TransformAndRecord(FPoints[i], AScale));
  Result := BoundsRect;
  if not ATurtle.DrawOptions.Draw3DObjects then
    Exit;
  if ATurtle.DrawOptions.Draw3DObjectsAsRects then
  begin
    ATurtle.DrawTrianglesFromBoundsRect(BoundsRect);
    Exit;
  end;
  for i := 1 to Triangles.Count do
  begin
    triangle := TriangleForIndex(i);
    ATurtle.DrawTriangleFromIndexes(
      triangle.PointIndexes[0],
      triangle.PointIndexes[1],
      triangle.PointIndexes[2],
      APartID
    );
  end;
end;

function KfObject3D.Clone: KfObject3D;
var
  i: Integer;
  triangle: KfIndexTriangle;
begin
  Result := KfObject3D.Create;
  Result.Name := Name;
  Result.OriginPointIndex := OriginPointIndex;
  Result.EnsureEnoughSpaceForNewPointData(PointsInUse);
  for i := 0 to PointsInUse - 1 do
    Result.FPoints[i] := FPoints[i];
  Result.PointsInUse := PointsInUse;
  for i := 0 to Triangles.Count - 1 do
  begin
    triangle := KfIndexTriangle(Triangles[i]);
    Result.AddTriangle(KfIndexTriangle.CreateABC(
      triangle.PointIndexes[0],
      triangle.PointIndexes[1],
      triangle.PointIndexes[2]
    ));
  end;
end;

end.
