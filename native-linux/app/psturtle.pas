unit psturtle;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Graphics, Contnrs, ps3dtypes, psdrawingsurface;

const
  kInitialTurtleMatrixStackDepth = 256;
  kMaximumRecordedPoints = 10000;

type
  PlantDrawOptionsStructure = record
    SortPolygons: Boolean;
    DrawLines: Boolean;
    LineContrastIndex: SmallInt;
    WireFrame: Boolean;
    StraightLinesOnly: Boolean;
    DrawStems: Boolean;
    Draw3DObjects: Boolean;
    Draw3DObjectsAsRects: Boolean;
    CirclePoints: Boolean;
    CirclePointRadius: SmallInt;
    SortTdosAsOneItem: Boolean;
  end;

  KfTurtle = class
  private
    FRecordedPoints: array of KfPoint3D;
    procedure EnsureRecordingCapacity(const ARequired: Integer);
  public
    MatrixStack: TObjectList;
    NumMatrixesUsed: LongInt;
    CurrentMatrix: KfMatrix;
    RecordedPointsInUse: LongInt;
    Scale_pixelsPerMm: Single;
    DrawingSurface: KfDrawingSurface;
    RealBoundsRect: TRealRect;
    DrawOptions: PlantDrawOptionsStructure;
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure ResetBoundsRect(const ABasePoint: TPoint);
    procedure AddToRealBoundsRect(const APoint: KfPoint3D);
    function BoundsRect: TRect;
    procedure SetScale_pixelsPerMm(const ANewScale: Single);
    function MillimetersToPixels(const AMm: Single): Single;
    procedure SetForeColorBackColor(const AFrontColor, ABackColor: TColor);
    procedure SetLineColor(const AColor: TColor);
    procedure SetLineWidth(const AWidth: Single);
    procedure XYZ(const AX, AY, AZ: Single);
    procedure Push;
    procedure Pop;
    procedure RotateX(const AAngle: Single);
    procedure RotateY(const AAngle: Single);
    procedure RotateZ(const AAngle: Single);
    procedure ClearRecording;
    procedure StartRecording;
    procedure RecordPosition;
    procedure RecordPositionPoint(const APoint: KfPoint3D);
    function TransformAndRecord(const AOriginalPoint3D: KfPoint3D; const AScale_pixelsPerMm: Single): KfPoint3D;
    procedure MoveAndRecordScale(const AOriginalPoint3D: KfPoint3D; const AScale_pixelsPerMm: Single);
    procedure MoveInMillimeters(const AMm: Single);
    procedure MoveInPixels(const APixels: Single);
    function DrawInMillimeters(const AMm: Single; const APartID: LongInt): KfTriangle;
    function DrawTriangleFromIndexes(const APointIndex, BPointIndex, CPointIndex: LongInt; const APartID: LongInt): KfTriangle;
    procedure DrawTrianglesFromBoundsRect(const ABoundsRect: TRect);
  end;

implementation

constructor KfTurtle.Create;
var
  i: Integer;
begin
  inherited Create;
  MatrixStack := TObjectList.Create(True);
  for i := 0 to kInitialTurtleMatrixStackDepth do
    MatrixStack.Add(KfMatrix.Create);
  CurrentMatrix := KfMatrix(MatrixStack[0]);
  CurrentMatrix.InitializeAsUnitMatrix;
  NumMatrixesUsed := 1;
  RecordedPointsInUse := 0;
  SetLength(FRecordedPoints, 512);
  DrawingSurface := KfDrawingSurface.Create;
  Scale_pixelsPerMm := 1.0;
  DrawOptions.SortPolygons := True;
  DrawOptions.DrawLines := True;
  DrawOptions.LineContrastIndex := 9;
  DrawOptions.WireFrame := False;
  DrawOptions.StraightLinesOnly := False;
  DrawOptions.DrawStems := True;
  DrawOptions.Draw3DObjects := True;
  DrawOptions.Draw3DObjectsAsRects := False;
  DrawOptions.CirclePoints := False;
  DrawOptions.CirclePointRadius := 3;
  DrawOptions.SortTdosAsOneItem := False;
end;

destructor KfTurtle.Destroy;
begin
  DrawingSurface.Free;
  MatrixStack.Free;
  inherited Destroy;
end;

procedure KfTurtle.EnsureRecordingCapacity(const ARequired: Integer);
var
  newSize: Integer;
begin
  if ARequired <= Length(FRecordedPoints) then
    Exit;
  newSize := Length(FRecordedPoints);
  if newSize = 0 then
    newSize := 256;
  while newSize < ARequired do
    newSize := newSize * 2;
  if newSize > kMaximumRecordedPoints then
    newSize := kMaximumRecordedPoints;
  SetLength(FRecordedPoints, newSize);
end;

procedure KfTurtle.Reset;
begin
  NumMatrixesUsed := 1;
  CurrentMatrix := KfMatrix(MatrixStack[0]);
  CurrentMatrix.InitializeAsUnitMatrix;
  RecordedPointsInUse := 0;
  Scale_pixelsPerMm := 1.0;
  DrawingSurface.FillingTriangles := not DrawOptions.WireFrame;
  DrawingSurface.DrawingLines := DrawOptions.DrawLines;
  DrawingSurface.CirclingPoints := DrawOptions.CirclePoints;
  DrawingSurface.LineContrastIndex := DrawOptions.LineContrastIndex;
  DrawingSurface.CirclePointRadius := DrawOptions.CirclePointRadius;
  DrawingSurface.Initialize;
end;

procedure KfTurtle.ResetBoundsRect(const ABasePoint: TPoint);
begin
  RealBoundsRect.Left := ABasePoint.X;
  RealBoundsRect.Right := ABasePoint.X;
  RealBoundsRect.Top := ABasePoint.Y;
  RealBoundsRect.Bottom := ABasePoint.Y;
end;

procedure KfTurtle.AddToRealBoundsRect(const APoint: KfPoint3D);
begin
  if APoint.X < RealBoundsRect.Left then
    RealBoundsRect.Left := APoint.X
  else if APoint.X > RealBoundsRect.Right then
    RealBoundsRect.Right := APoint.X;
  if APoint.Y < RealBoundsRect.Top then
    RealBoundsRect.Top := APoint.Y
  else if APoint.Y > RealBoundsRect.Bottom then
    RealBoundsRect.Bottom := APoint.Y;
end;

function KfTurtle.BoundsRect: TRect;
begin
  Result := Rect(
    Round(RealBoundsRect.Left),
    Round(RealBoundsRect.Top),
    Round(RealBoundsRect.Right),
    Round(RealBoundsRect.Bottom)
  );
end;

procedure KfTurtle.SetScale_pixelsPerMm(const ANewScale: Single);
begin
  Scale_pixelsPerMm := ANewScale;
end;

function KfTurtle.MillimetersToPixels(const AMm: Single): Single;
begin
  Result := AMm * Scale_pixelsPerMm;
end;

procedure KfTurtle.SetForeColorBackColor(const AFrontColor, ABackColor: TColor);
begin
  DrawingSurface.ForeColor := AFrontColor;
  DrawingSurface.BackColor := ABackColor;
end;

procedure KfTurtle.SetLineColor(const AColor: TColor);
begin
  DrawingSurface.LineColor := AColor;
end;

procedure KfTurtle.SetLineWidth(const AWidth: Single);
begin
  DrawingSurface.LineWidth := AWidth * Scale_pixelsPerMm;
  if DrawingSurface.LineWidth > 16000 then
    DrawingSurface.LineWidth := 16000;
end;

procedure KfTurtle.XYZ(const AX, AY, AZ: Single);
begin
  CurrentMatrix.Position.X := AX;
  CurrentMatrix.Position.Y := AY;
  CurrentMatrix.Position.Z := AZ;
end;

procedure KfTurtle.Push;
var
  nextMatrix: KfMatrix;
begin
  if NumMatrixesUsed >= MatrixStack.Count then
    MatrixStack.Add(CurrentMatrix.DeepCopy)
  else
  begin
    nextMatrix := KfMatrix(MatrixStack[NumMatrixesUsed]);
    CurrentMatrix.CopyTo(nextMatrix);
  end;
  Inc(NumMatrixesUsed);
  CurrentMatrix := KfMatrix(MatrixStack[NumMatrixesUsed - 1]);
end;

procedure KfTurtle.Pop;
begin
  if NumMatrixesUsed <= 1 then
    Exit;
  Dec(NumMatrixesUsed);
  CurrentMatrix := KfMatrix(MatrixStack[NumMatrixesUsed - 1]);
end;

procedure KfTurtle.RotateX(const AAngle: Single);
begin
  CurrentMatrix.RotateX(AAngle);
end;

procedure KfTurtle.RotateY(const AAngle: Single);
begin
  CurrentMatrix.RotateY(AAngle);
end;

procedure KfTurtle.RotateZ(const AAngle: Single);
begin
  CurrentMatrix.RotateZ(AAngle);
end;

procedure KfTurtle.ClearRecording;
begin
  RecordedPointsInUse := 0;
end;

procedure KfTurtle.StartRecording;
begin
  RecordedPointsInUse := 0;
  RecordPosition;
end;

procedure KfTurtle.RecordPosition;
begin
  EnsureRecordingCapacity(RecordedPointsInUse + 1);
  if RecordedPointsInUse >= kMaximumRecordedPoints then
    Exit;
  FRecordedPoints[RecordedPointsInUse] := CurrentMatrix.Position;
  Inc(RecordedPointsInUse);
  AddToRealBoundsRect(CurrentMatrix.Position);
end;

procedure KfTurtle.RecordPositionPoint(const APoint: KfPoint3D);
begin
  EnsureRecordingCapacity(RecordedPointsInUse + 1);
  if RecordedPointsInUse >= kMaximumRecordedPoints then
    Exit;
  FRecordedPoints[RecordedPointsInUse] := APoint;
  Inc(RecordedPointsInUse);
  AddToRealBoundsRect(APoint);
end;

function KfTurtle.TransformAndRecord(const AOriginalPoint3D: KfPoint3D; const AScale_pixelsPerMm: Single): KfPoint3D;
begin
  Result := AOriginalPoint3D;
  KfPoint3D_ScaleBy(Result, AScale_pixelsPerMm * Scale_pixelsPerMm);
  CurrentMatrix.Transform(Result);
  RecordPositionPoint(Result);
end;

procedure KfTurtle.MoveAndRecordScale(const AOriginalPoint3D: KfPoint3D; const AScale_pixelsPerMm: Single);
var
  point3D: KfPoint3D;
begin
  point3D := AOriginalPoint3D;
  KfPoint3D_ScaleBy(point3D, AScale_pixelsPerMm * Scale_pixelsPerMm);
  CurrentMatrix.Transform(point3D);
  CurrentMatrix.Position := point3D;
  RecordPositionPoint(point3D);
end;

procedure KfTurtle.MoveInMillimeters(const AMm: Single);
begin
  CurrentMatrix.Move(MillimetersToPixels(AMm));
end;

procedure KfTurtle.MoveInPixels(const APixels: Single);
begin
  CurrentMatrix.Move(APixels);
end;

function KfTurtle.DrawInMillimeters(const AMm: Single; const APartID: LongInt): KfTriangle;
var
  oldPosition: KfPoint3D;
  newPosition: KfPoint3D;
begin
  Result := nil;
  oldPosition := CurrentMatrix.Position;
  CurrentMatrix.Move(MillimetersToPixels(AMm));
  newPosition := CurrentMatrix.Position;
  if DrawOptions.DrawStems then
  begin
    Result := DrawingSurface.DrawLineFromTo(oldPosition, newPosition);
    if Result <> nil then
      Result.PlantPartID := APartID;
  end;
  AddToRealBoundsRect(newPosition);
end;

function KfTurtle.DrawTriangleFromIndexes(const APointIndex, BPointIndex, CPointIndex: LongInt; const APartID: LongInt): KfTriangle;
begin
  Result := DrawingSurface.AllocateTriangle;
  DrawingSurface.LineWidth := 1.0;
  Result.Points[0] := FRecordedPoints[APointIndex - 1];
  Result.Points[1] := FRecordedPoints[BPointIndex - 1];
  Result.Points[2] := FRecordedPoints[CPointIndex - 1];
  Result.PlantPartID := APartID;
  DrawingSurface.DrawLastTriangle;
end;

procedure KfTurtle.DrawTrianglesFromBoundsRect(const ABoundsRect: TRect);
var
  triangle: KfTriangle;
begin
  DrawingSurface.LineWidth := 1.0;
  triangle := DrawingSurface.AllocateTriangle;
  triangle.Points[0].X := ABoundsRect.Left;
  triangle.Points[0].Y := ABoundsRect.Top;
  triangle.Points[1].X := ABoundsRect.Right;
  triangle.Points[1].Y := ABoundsRect.Top;
  triangle.Points[2].X := ABoundsRect.Left;
  triangle.Points[2].Y := ABoundsRect.Bottom;
  DrawingSurface.DrawLastTriangle;

  triangle := DrawingSurface.AllocateTriangle;
  triangle.Points[0].X := ABoundsRect.Left;
  triangle.Points[0].Y := ABoundsRect.Bottom;
  triangle.Points[1].X := ABoundsRect.Right;
  triangle.Points[1].Y := ABoundsRect.Top;
  triangle.Points[2].X := ABoundsRect.Right;
  triangle.Points[2].Y := ABoundsRect.Bottom;
  DrawingSurface.DrawLastTriangle;
end;

end.
