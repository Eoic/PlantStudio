unit psdrawingsurface;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Graphics, Contnrs, ps3dtypes;

const
  kInitialDrawingSurfaceTriangles = 1024;

type
  KfDrawingSurface = class
  private
    procedure SortTriangles(const ALeft, ARight: Integer);
  public
    Pane: TCanvas;
    LineContrastIndex: SmallInt;
    DrawingLines: Boolean;
    FillingTriangles: Boolean;
    CirclingPoints: Boolean;
    ForeColor: TColor;
    BackColor: TColor;
    LineColor: TColor;
    CircleColor: TColor;
    NumTrianglesUsed: LongInt;
    Triangles: TObjectList;
    Recording: Boolean;
    LineWidth: Single;
    CirclePointRadius: SmallInt;
    constructor Create;
    destructor Destroy; override;
    procedure Initialize;
    procedure ClearTriangles;
    function AllocateTriangle: KfTriangle;
    function DrawLineFromTo(const AStartPoint, AEndPoint: KfPoint3D): KfTriangle;
    procedure DrawLastTriangle;
    procedure SortTrianglesByDepth;
    procedure TrianglesDraw;
    procedure RecordingStart;
    procedure RecordingStop;
    procedure RecordingDraw;
    function PlantPartIDForPoint(const APoint: TPoint): LongInt;
    procedure BasicDrawLineFromTo(const AStartPoint, AEndPoint: KfPoint3D);
    procedure BasicDrawTriangle(const ATriangle: KfTriangle);
  end;

implementation

constructor KfDrawingSurface.Create;
var
  i: LongInt;
begin
  inherited Create;
  Triangles := TObjectList.Create(True);
  NumTrianglesUsed := 0;
  FillingTriangles := True;
  DrawingLines := True;
  ForeColor := clSilver;
  BackColor := clGray;
  LineColor := clBlack;
  CircleColor := clRed;
  CirclePointRadius := 3;
  for i := 0 to kInitialDrawingSurfaceTriangles do
    Triangles.Add(KfTriangle.Create);
  Initialize;
end;

destructor KfDrawingSurface.Destroy;
begin
  Triangles.Free;
  inherited Destroy;
end;

procedure KfDrawingSurface.Initialize;
begin
  LineWidth := 1.0;
  Recording := False;
  ClearTriangles;
  if Pane <> nil then
  begin
    if FillingTriangles then
      Pane.Brush.Style := bsSolid
    else
      Pane.Brush.Style := bsClear;
  end;
end;

procedure KfDrawingSurface.ClearTriangles;
begin
  NumTrianglesUsed := 0;
end;

function KfDrawingSurface.AllocateTriangle: KfTriangle;
begin
  if NumTrianglesUsed < Triangles.Count then
    Result := KfTriangle(Triangles[NumTrianglesUsed])
  else
  begin
    Result := KfTriangle.Create;
    Triangles.Add(Result);
  end;
  Inc(NumTrianglesUsed);
  Result.IsLine := False;
  Result.PlantPartID := -1;
end;

function KfDrawingSurface.DrawLineFromTo(const AStartPoint, AEndPoint: KfPoint3D): KfTriangle;
begin
  Result := nil;
  if Recording then
  begin
    Result := AllocateTriangle;
    Result.Points[0] := AStartPoint;
    Result.Points[1] := AEndPoint;
    Result.IsLine := True;
    Result.ForeColor := ForeColor;
    Result.BackColor := BackColor;
    Result.LineColor := LineColor;
    Result.LineWidth := LineWidth;
    Result.ComputeZ;
  end
  else
    BasicDrawLineFromTo(AStartPoint, AEndPoint);
end;

procedure KfDrawingSurface.DrawLastTriangle;
var
  triangle: KfTriangle;
begin
  triangle := KfTriangle(Triangles[NumTrianglesUsed - 1]);
  triangle.IsLine := False;
  triangle.UpdateGeometry;
  triangle.LineWidth := LineWidth;
  triangle.LineColor := LineColor;
  triangle.ForeColor := ForeColor;
  triangle.BackColor := BackColor;
  if not Recording then
  begin
    BasicDrawTriangle(triangle);
    Dec(NumTrianglesUsed);
  end;
end;

procedure KfDrawingSurface.SortTriangles(const ALeft, ARight: Integer);
var
  i: Integer;
  j: Integer;
  pivot: Single;
begin
  if ARight <= ALeft then
    Exit;
  pivot := KfTriangle(Triangles[ARight]).ZForSorting;
  i := ALeft - 1;
  j := ARight;
  while True do
  begin
    repeat
      Inc(i);
    until not (KfTriangle(Triangles[i]).ZForSorting < pivot);
    repeat
      Dec(j);
    until (j < i) or not (KfTriangle(Triangles[j]).ZForSorting > pivot);
    if i >= j then
      Break;
    Triangles.Exchange(i, j);
  end;
  Triangles.Exchange(i, ARight);
  SortTriangles(ALeft, j);
  SortTriangles(i + 1, ARight);
end;

procedure KfDrawingSurface.SortTrianglesByDepth;
begin
  if NumTrianglesUsed > 1 then
    SortTriangles(0, NumTrianglesUsed - 1);
end;

procedure KfDrawingSurface.TrianglesDraw;
var
  i: Integer;
begin
  for i := 0 to NumTrianglesUsed - 1 do
    BasicDrawTriangle(KfTriangle(Triangles[i]));
end;

procedure KfDrawingSurface.RecordingStart;
begin
  ClearTriangles;
  Recording := True;
end;

procedure KfDrawingSurface.RecordingStop;
begin
  Recording := False;
end;

procedure KfDrawingSurface.RecordingDraw;
begin
  SortTrianglesByDepth;
  TrianglesDraw;
end;

function KfDrawingSurface.PlantPartIDForPoint(const APoint: TPoint): LongInt;
var
  i: Integer;
  triangle: KfTriangle;
  trianglePoints: array[0..2] of TPoint;
  centerX: Single;
  centerY: Single;
  distance: Single;
  closestDistance: Single;
  closestID: LongInt;
begin
  Result := -1;
  closestDistance := 0;
  closestID := -1;
  for i := 0 to NumTrianglesUsed - 1 do
  begin
    triangle := KfTriangle(Triangles[i]);
    if triangle.IsLine then
    begin
      centerX := (triangle.Points[0].X + triangle.Points[1].X) * 0.5;
      centerY := (triangle.Points[0].Y + triangle.Points[1].Y) * 0.5;
      distance := Sqr(centerX - APoint.X) + Sqr(centerY - APoint.Y);
      if (closestID = -1) or (distance < closestDistance) then
      begin
        closestDistance := distance;
        closestID := triangle.PlantPartID;
      end;
      Continue;
    end;

    trianglePoints[0] := Point(Round(triangle.Points[0].X), Round(triangle.Points[0].Y));
    trianglePoints[1] := Point(Round(triangle.Points[1].X), Round(triangle.Points[1].Y));
    trianglePoints[2] := Point(Round(triangle.Points[2].X), Round(triangle.Points[2].Y));
    if PointInTriangle(APoint, trianglePoints) then
      Exit(triangle.PlantPartID);
  end;
  Result := closestID;
end;

procedure KfDrawingSurface.BasicDrawLineFromTo(const AStartPoint, AEndPoint: KfPoint3D);
begin
  if Pane = nil then
    Exit;
  try
    Pane.Pen.Width := Round(LineWidth);
    Pane.Pen.Color := LineColor;
    Pane.Pen.Style := psSolid;
    Pane.MoveTo(Round(AStartPoint.X), Round(AStartPoint.Y));
    Pane.LineTo(Round(AEndPoint.X), Round(AEndPoint.Y));
  except
    // Ignore invalid drawing coordinates.
  end;
end;

procedure KfDrawingSurface.BasicDrawTriangle(const ATriangle: KfTriangle);
var
  pointArray: array[0..3] of TPoint;
  i: Integer;
  currentPoint: KfPoint3D;
begin
  if Pane = nil then
    Exit;

  if ATriangle.IsLine then
  begin
    Pane.Pen.Width := Round(ATriangle.LineWidth);
    Pane.Pen.Color := ATriangle.LineColor;
    Pane.Pen.Style := psSolid;
    Pane.MoveTo(Round(ATriangle.Points[0].X), Round(ATriangle.Points[0].Y));
    Pane.LineTo(Round(ATriangle.Points[1].X), Round(ATriangle.Points[1].Y));
    Exit;
  end;

  for i := 0 to 3 do
  begin
    if i < 3 then
      currentPoint := ATriangle.Points[i]
    else
      currentPoint := ATriangle.Points[0];
    pointArray[i] := Point(Round(currentPoint.X), Round(currentPoint.Y));
  end;

  Pane.Pen.Style := psSolid;
  Pane.Brush.Color := ATriangle.VisibleSurfaceColor;
  if DrawingLines then
  begin
    if FillingTriangles then
      Pane.Pen.Color := ATriangle.DrawLinesColor(LineContrastIndex)
    else
      Pane.Pen.Color := ATriangle.VisibleSurfaceColor;
  end
  else
    Pane.Pen.Color := ATriangle.VisibleSurfaceColor;
  Pane.Pen.Width := 1;

  if FillingTriangles then
    Pane.Polygon(pointArray)
  else
    Pane.Polyline(pointArray);

  if CirclingPoints then
  begin
    Pane.Pen.Color := CircleColor;
    Pane.Brush.Color := CircleColor;
    for i := 0 to 2 do
      Pane.Ellipse(
        pointArray[i].X - CirclePointRadius,
        pointArray[i].Y - CirclePointRadius,
        pointArray[i].X + CirclePointRadius,
        pointArray[i].Y + CirclePointRadius
      );
  end;
end;

end.
