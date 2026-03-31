unit ps3dtypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Graphics, Math;

const
  kFastTrigArraySize = 256;
  kDirectionClockwise = 1;
  kDirectionCounterClockwise = -1;
  kDirectionUnknown = 0;

type
  TRealRect = record
    Top: Single;
    Left: Single;
    Bottom: Single;
    Right: Single;
  end;

  KfPoint3D = record
    X: Single;
    Y: Single;
    Z: Single;
  end;

  KfMatrix = class
  public
    a0, a1, a2: Single;
    b0, b1, b2: Single;
    c0, c1, c2: Single;
    Position: KfPoint3D;
    procedure InitializeAsUnitMatrix;
    procedure Move(const ADistance: Single);
    procedure RotateX(const AAngle: Single);
    procedure RotateY(const AAngle: Single);
    procedure RotateZ(const AAngle: Single);
    procedure Transform(var APoint3D: KfPoint3D);
    function DeepCopy: KfMatrix;
    procedure CopyTo(const AOther: KfMatrix);
  end;

  KfTriangle = class
  public
    ForeColor: TColor;
    BackColor: TColor;
    LineColor: TColor;
    ZForSorting: Single;
    BackFacing: Boolean;
    LineWidth: Single;
    IsLine: Boolean;
    Points: array[0..2] of KfPoint3D;
    PlantPartID: LongInt;
    function VisibleSurfaceColor: TColor;
    function DrawLinesColor(const ALineContrastIndex: SmallInt): TColor;
    procedure ComputeBackFacing;
    procedure ComputeZ;
    procedure UpdateGeometry;
  end;

procedure KfPoint3D_SetXYZ(var APoint: KfPoint3D; const AX, AY, AZ: Single);
procedure KfPoint3D_AddXYZ(var APoint: KfPoint3D; const AX, AY, AZ: Single);
procedure KfPoint3D_Subtract(var APoint: KfPoint3D; const ASubtract: KfPoint3D);
procedure KfPoint3D_ScaleBy(var APoint: KfPoint3D; const AScale: Single);
function KfPoint3D_MatchXYZ(const APointOne, APointTwo: KfPoint3D; const AMatchDistance: Single): Boolean;
procedure KfPoint3D_AddPointToBoundsRect(var ABoundsRect: TRect; const APoint: KfPoint3D);
procedure FastTrigInitialize;
function FastTrigCos(const AAngle: Single): Single;
function FastTrigSin(const AAngle: Single): Single;
function Clockwise(const APoint0, APoint1, APoint2: TPoint): Integer;
function PointInTriangle(const APoint: TPoint; const ATriangle: array of TPoint): Boolean;

implementation

uses
  pssupport;

var
  SinCache: array[0..kFastTrigArraySize - 1] of Single;
  CosCache: array[0..kFastTrigArraySize - 1] of Single;

procedure KfPoint3D_SetXYZ(var APoint: KfPoint3D; const AX, AY, AZ: Single);
begin
  APoint.X := AX;
  APoint.Y := AY;
  APoint.Z := AZ;
end;

procedure KfPoint3D_AddXYZ(var APoint: KfPoint3D; const AX, AY, AZ: Single);
begin
  APoint.X := APoint.X + AX;
  APoint.Y := APoint.Y + AY;
  APoint.Z := APoint.Z + AZ;
end;

procedure KfPoint3D_Subtract(var APoint: KfPoint3D; const ASubtract: KfPoint3D);
begin
  APoint.X := APoint.X - ASubtract.X;
  APoint.Y := APoint.Y - ASubtract.Y;
  APoint.Z := APoint.Z - ASubtract.Z;
end;

procedure KfPoint3D_ScaleBy(var APoint: KfPoint3D; const AScale: Single);
begin
  APoint.X := APoint.X * AScale;
  APoint.Y := APoint.Y * AScale;
  APoint.Z := APoint.Z * AScale;
end;

function KfPoint3D_MatchXYZ(const APointOne, APointTwo: KfPoint3D; const AMatchDistance: Single): Boolean;
begin
  Result := (Abs(APointOne.X - APointTwo.X) <= AMatchDistance)
    and (Abs(APointOne.Y - APointTwo.Y) <= AMatchDistance)
    and (Abs(APointOne.Z - APointTwo.Z) <= AMatchDistance);
end;

procedure KfPoint3D_AddPointToBoundsRect(var ABoundsRect: TRect; const APoint: KfPoint3D);
var
  x: Integer;
  y: Integer;
begin
  try
    x := Round(APoint.X);
  except
    x := 0;
  end;
  try
    y := Round(APoint.Y);
  except
    y := 0;
  end;

  if (ABoundsRect.Left = 0) and (ABoundsRect.Right = 0)
    and (ABoundsRect.Top = 0) and (ABoundsRect.Bottom = 0) then
  begin
    ABoundsRect.Left := x;
    ABoundsRect.Right := x;
    ABoundsRect.Top := y;
    ABoundsRect.Bottom := y;
    Exit;
  end;

  if x < ABoundsRect.Left then
    ABoundsRect.Left := x
  else if x > ABoundsRect.Right then
    ABoundsRect.Right := x;

  if y < ABoundsRect.Top then
    ABoundsRect.Top := y
  else if y > ABoundsRect.Bottom then
    ABoundsRect.Bottom := y;
end;

procedure FastTrigInitialize;
var
  i: Integer;
begin
  for i := 0 to kFastTrigArraySize - 1 do
  begin
    SinCache[i] := Sin(i * 2 * Pi / kFastTrigArraySize);
    CosCache[i] := Cos(i * 2 * Pi / kFastTrigArraySize);
  end;
end;

function FastTrigCos(const AAngle: Single): Single;
var
  boundedAngle: Integer;
begin
  try
    boundedAngle := Round(AAngle) mod kFastTrigArraySize;
  except
    boundedAngle := 0;
  end;
  if boundedAngle < 0 then
    boundedAngle := kFastTrigArraySize + boundedAngle;
  Result := CosCache[boundedAngle];
end;

function FastTrigSin(const AAngle: Single): Single;
var
  boundedAngle: Integer;
begin
  try
    boundedAngle := Round(AAngle) mod kFastTrigArraySize;
  except
    boundedAngle := 0;
  end;
  if boundedAngle < 0 then
    boundedAngle := kFastTrigArraySize + boundedAngle;
  Result := SinCache[boundedAngle];
end;

function Clockwise(const APoint0, APoint1, APoint2: TPoint): Integer;
var
  dx1: Single;
  dy1: Single;
  dx2: Single;
  dy2: Single;
begin
  dx1 := APoint1.X - APoint0.X;
  dy1 := APoint1.Y - APoint0.Y;
  dx2 := APoint2.X - APoint0.X;
  dy2 := APoint2.Y - APoint0.Y;
  if (dx1 * dy2) > (dy1 * dx2) then
    Result := kDirectionClockwise
  else if (dx1 * dy2) < (dy1 * dx2) then
    Result := kDirectionCounterClockwise
  else if ((dx1 * dx2) < 0) or ((dy1 * dy2) < 0) then
    Result := kDirectionCounterClockwise
  else if ((dx1 * dx1) + (dy1 * dy1)) < ((dx2 * dx2) + (dy2 * dy2)) then
    Result := kDirectionClockwise
  else
    Result := kDirectionUnknown;
end;

function PointInTriangle(const APoint: TPoint; const ATriangle: array of TPoint): Boolean;
var
  first: Integer;
  second: Integer;
  third: Integer;
begin
  Result := False;
  if Length(ATriangle) < 3 then
    Exit;
  if (ATriangle[0].X = ATriangle[1].X) and (ATriangle[1].X = ATriangle[2].X)
    and (ATriangle[0].Y = ATriangle[1].Y) and (ATriangle[1].Y = ATriangle[2].Y) then
    Exit;
  first := Clockwise(APoint, ATriangle[0], ATriangle[1]);
  second := Clockwise(APoint, ATriangle[1], ATriangle[2]);
  third := Clockwise(APoint, ATriangle[2], ATriangle[0]);
  Result := (first = second) and (second = third);
end;

procedure KfMatrix.InitializeAsUnitMatrix;
begin
  a0 := 1.0;
  a1 := 0.0;
  a2 := 0.0;
  b0 := 0.0;
  b1 := 1.0;
  b2 := 0.0;
  c0 := 0.0;
  c1 := 0.0;
  c2 := 1.0;
  Position.X := 0.0;
  Position.Y := 0.0;
  Position.Z := 0.0;
end;

procedure KfMatrix.Move(const ADistance: Single);
begin
  Position.X := Position.X + ADistance * a0;
  Position.Y := Position.Y + ADistance * b0;
  Position.Z := Position.Z + ADistance * c0;
end;

procedure KfMatrix.RotateX(const AAngle: Single);
var
  cosAngle: Single;
  sinAngle: Single;
  temp1: Single;
begin
  cosAngle := FastTrigCos(AAngle);
  sinAngle := FastTrigSin(AAngle);
  temp1 := a1 * cosAngle - a2 * sinAngle;
  a2 := a2 * cosAngle + a1 * sinAngle;
  a1 := temp1;
  temp1 := b1 * cosAngle - b2 * sinAngle;
  b2 := b2 * cosAngle + b1 * sinAngle;
  b1 := temp1;
  temp1 := c1 * cosAngle - c2 * sinAngle;
  c2 := c2 * cosAngle + c1 * sinAngle;
  c1 := temp1;
end;

procedure KfMatrix.RotateY(const AAngle: Single);
var
  cosAngle: Single;
  sinAngle: Single;
  temp1: Single;
begin
  cosAngle := FastTrigCos(AAngle);
  sinAngle := FastTrigSin(AAngle);
  temp1 := a0 * cosAngle + a2 * sinAngle;
  a2 := a2 * cosAngle - a0 * sinAngle;
  a0 := temp1;
  temp1 := b0 * cosAngle + b2 * sinAngle;
  b2 := b2 * cosAngle - b0 * sinAngle;
  b0 := temp1;
  temp1 := c0 * cosAngle + c2 * sinAngle;
  c2 := c2 * cosAngle - c0 * sinAngle;
  c0 := temp1;
end;

procedure KfMatrix.RotateZ(const AAngle: Single);
var
  cosAngle: Single;
  sinAngle: Single;
  temp1: Single;
begin
  cosAngle := FastTrigCos(AAngle);
  sinAngle := FastTrigSin(AAngle);
  temp1 := a0 * cosAngle - a1 * sinAngle;
  a1 := a1 * cosAngle + a0 * sinAngle;
  a0 := temp1;
  temp1 := b0 * cosAngle - b1 * sinAngle;
  b1 := b1 * cosAngle + b0 * sinAngle;
  b0 := temp1;
  temp1 := c0 * cosAngle - c1 * sinAngle;
  c1 := c1 * cosAngle + c0 * sinAngle;
  c0 := temp1;
end;

procedure KfMatrix.Transform(var APoint3D: KfPoint3D);
var
  x: Single;
  y: Single;
  z: Single;
begin
  x := APoint3D.X;
  y := APoint3D.Y;
  z := APoint3D.Z;
  APoint3D.X := (x * a0) + (y * a1) + (z * a2) + Position.X;
  APoint3D.Y := (x * b0) + (y * b1) + (z * b2) + Position.Y;
  APoint3D.Z := (x * c0) + (y * c1) + (z * c2) + Position.Z;
end;

function KfMatrix.DeepCopy: KfMatrix;
begin
  Result := KfMatrix.Create;
  CopyTo(Result);
end;

procedure KfMatrix.CopyTo(const AOther: KfMatrix);
begin
  if AOther = nil then
    Exit;
  AOther.Position := Position;
  AOther.a0 := a0;
  AOther.a1 := a1;
  AOther.a2 := a2;
  AOther.b0 := b0;
  AOther.b1 := b1;
  AOther.b2 := b2;
  AOther.c0 := c0;
  AOther.c1 := c1;
  AOther.c2 := c2;
end;

function KfTriangle.VisibleSurfaceColor: TColor;
begin
  if BackFacing then
    Result := BackColor
  else
    Result := ForeColor;
end;

function KfTriangle.DrawLinesColor(const ALineContrastIndex: SmallInt): TColor;
var
  percent: Integer;
begin
  percent := ClampInt(100 - (ALineContrastIndex * 3), 35, 95);
  Result := DarkerColor(VisibleSurfaceColor, percent);
end;

procedure KfTriangle.ComputeBackFacing;
var
  trianglePoints: array[0..2] of TPoint;
begin
  trianglePoints[0] := Point(Round(Points[0].X), Round(Points[0].Y));
  trianglePoints[1] := Point(Round(Points[1].X), Round(Points[1].Y));
  trianglePoints[2] := Point(Round(Points[2].X), Round(Points[2].Y));
  BackFacing := Clockwise(trianglePoints[0], trianglePoints[1], trianglePoints[2]) = kDirectionCounterClockwise;
end;

procedure KfTriangle.ComputeZ;
begin
  if IsLine then
    ZForSorting := (Points[0].Z + Points[1].Z) * 0.5
  else
    ZForSorting := (Points[0].Z + Points[1].Z + Points[2].Z) / 3.0;
end;

procedure KfTriangle.UpdateGeometry;
begin
  ComputeBackFacing;
  ComputeZ;
end;

initialization
  FastTrigInitialize;

end.
