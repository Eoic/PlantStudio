unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Types, Math, psplatform, psplanttext, psplantmodel, psturtle, pssupport;

type
  TPlantStudioMainForm = class(TForm)
    Grow1Button: TButton;
    Grow30Button: TButton;
    Grow5Button: TButton;
    LeftPanel: TPanel;
    PaintBox: TPaintBox;
    PlantList: TListBox;
    ResetAgeButton: TButton;
    RotateLeftButton: TButton;
    RotateRightButton: TButton;
    SidebarTitle: TLabel;
    StartupTimer: TTimer;
    StatusLabel: TLabel;
    ToolbarPanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GrowButtonClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PlantListClick(Sender: TObject);
    procedure RotateButtonClick(Sender: TObject);
    procedure StartupTimerTimer(Sender: TObject);
  private
    FPlantLibrary: TPlantStudioTextLibrary;
    FTurtle: KfTurtle;
    FLoadedFile: string;
    FQuitAfterLoad: Boolean;
    FQuitAfterRender: Boolean;
    FScreenshotPath: string;
    FLoadError: string;
    FRendered: Boolean;
    FRequestedPlantIndex: Integer;
    FRequestedGrowDays: Integer;
    FRequestedRotateY: Integer;
    procedure ParseArgs;
    procedure LoadPlantFile;
    procedure ApplyRequestedState;
    procedure UpdateStatus;
    procedure SaveScreenshot;
    procedure RenderScene(ACanvas: TCanvas; const ARect: TRect);
    function SelectedPlant: PdPlant;
    function SelectedPlantName: string;
    function EffectivePlantIndex: Integer;
  public
  end;

var
  PlantStudioMainForm: TPlantStudioMainForm;

implementation

{$R *.lfm}

procedure TPlantStudioMainForm.ParseArgs;
var
  index: Integer;
  current: string;
begin
  FRequestedPlantIndex := 0;
  FRequestedGrowDays := 0;
  FRequestedRotateY := 0;
  index := 1;
  while index <= ParamCount do
  begin
    current := ParamStr(index);
    if (current = '--file') and (index < ParamCount) then
    begin
      FLoadedFile := ExpandFileName(ParamStr(index + 1));
      Inc(index);
    end
    else if current = '--quit-after-load' then
      FQuitAfterLoad := True
    else if current = '--quit-after-render' then
      FQuitAfterRender := True
    else if (current = '--screenshot') and (index < ParamCount) then
    begin
      FScreenshotPath := ExpandFileName(ParamStr(index + 1));
      Inc(index);
    end
    else if (current = '--plant-index') and (index < ParamCount) then
    begin
      FRequestedPlantIndex := StrToIntDef(ParamStr(index + 1), 0);
      Inc(index);
    end
    else if (current = '--grow') and (index < ParamCount) then
    begin
      FRequestedGrowDays := StrToIntDef(ParamStr(index + 1), 0);
      Inc(index);
    end
    else if (current = '--rotate-y') and (index < ParamCount) then
    begin
      FRequestedRotateY := StrToIntDef(ParamStr(index + 1), 0);
      Inc(index);
    end;
    Inc(index);
  end;
end;

function TPlantStudioMainForm.EffectivePlantIndex: Integer;
begin
  if PlantList.ItemIndex >= 0 then
    Result := PlantList.ItemIndex
  else
    Result := ClampInt(FRequestedPlantIndex, 0, Max(0, PlantList.Count - 1));
end;

function TPlantStudioMainForm.SelectedPlant: PdPlant;
begin
  Result := nil;
  if Assigned(FPlantLibrary) then
    Result := FPlantLibrary.PlantAt(EffectivePlantIndex);
end;

function TPlantStudioMainForm.SelectedPlantName: string;
var
  plant: PdPlant;
begin
  plant := SelectedPlant;
  if plant <> nil then
    Result := plant.Name
  else
    Result := '';
end;

procedure TPlantStudioMainForm.ApplyRequestedState;
var
  plant: PdPlant;
begin
  if PlantList.Count = 0 then
    Exit;
  PlantList.ItemIndex := ClampInt(FRequestedPlantIndex, 0, PlantList.Count - 1);
  plant := SelectedPlant;
  if plant = nil then
    Exit;
  if FRequestedGrowDays <> 0 then
    plant.SetAge(plant.Age + FRequestedGrowDays);
  if FRequestedRotateY <> 0 then
    plant.YRotation := FRequestedRotateY;
end;

procedure TPlantStudioMainForm.UpdateStatus;
var
  plant: PdPlant;
  plantSummary: string;
begin
  if FLoadError <> '' then
  begin
    StatusLabel.Caption := FLoadError;
    Exit;
  end;

  plantSummary := 'No plant library loaded';
  if Assigned(FPlantLibrary) and (FPlantLibrary.Plants.Count > 0) then
    plantSummary := Format(
      '%d plants | scale %.2f | offset %.1f %.1f | orientation %d | config %s',
      [
        FPlantLibrary.Plants.Count,
        FPlantLibrary.Scale,
        FPlantLibrary.OffsetX,
        FPlantLibrary.OffsetY,
        FPlantLibrary.Orientation,
        PlantStudioConfigFile
      ]
    );

  plant := SelectedPlant;
  if plant <> nil then
    StatusLabel.Caption := Format(
      '%s | selected: %s | age: %d | rotate Y: %.0f',
      [plantSummary, plant.Name, plant.Age, plant.YRotation]
    )
  else
    StatusLabel.Caption := plantSummary;
end;

procedure TPlantStudioMainForm.LoadPlantFile;
begin
  PlantList.Items.Clear;
  FLoadError := '';
  FRendered := False;

  if FLoadedFile = '' then
  begin
    UpdateStatus;
    Exit;
  end;

  if not FileExists(FLoadedFile) then
  begin
    FLoadError := 'File not found: ' + FLoadedFile;
    UpdateStatus;
    Exit;
  end;

  if not FPlantLibrary.LoadFromFile(FLoadedFile) then
  begin
    FLoadError := 'Failed to load plant file: ' + FLoadedFile;
    UpdateStatus;
    Exit;
  end;

  PlantList.Items.Assign(FPlantLibrary.PlantNames);
  ApplyRequestedState;
  UpdateStatus;
end;

procedure TPlantStudioMainForm.FormCreate(Sender: TObject);
begin
  FPlantLibrary := TPlantStudioTextLibrary.Create;
  FTurtle := KfTurtle.Create;
  ParseArgs;
  LoadPlantFile;

  if FQuitAfterLoad and (not FQuitAfterRender) and (FScreenshotPath = '') then
    StartupTimer.Enabled := True;
end;

procedure TPlantStudioMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTurtle);
  FreeAndNil(FPlantLibrary);
end;

procedure TPlantStudioMainForm.RenderScene(ACanvas: TCanvas; const ARect: TRect);
var
  plant: PdPlant;
  paintRect: TRect;
  contentRect: TRect;
  scalePixelsPerMm: Single;
  fittedScale: Single;
  basePoint: TPoint;
  finalBasePoint: TPoint;
  sceneBounds: TRect;
  boundsWidth: Integer;
  boundsHeight: Integer;
  deltaX: Integer;
  deltaY: Integer;
  targetCenterX: Integer;
  targetBottomY: Integer;
  function InnerWidth(const ABounds: TRect): Integer;
  begin
    Result := Max(1, ABounds.Right - ABounds.Left);
  end;

  function InnerHeight(const ABounds: TRect): Integer;
  begin
    Result := Max(1, ABounds.Bottom - ABounds.Top);
  end;

  procedure DrawPlantToCanvas(ATargetCanvas: TCanvas; const ABasePoint: TPoint; const AScale: Single);
  begin
    FTurtle.DrawingSurface.Pane := ATargetCanvas;
    FTurtle.DrawOptions.SortPolygons := True;
    FTurtle.DrawOptions.DrawLines := True;
    FTurtle.DrawOptions.DrawStems := True;
    FTurtle.DrawOptions.Draw3DObjects := True;
    FTurtle.DrawOptions.Draw3DObjectsAsRects := False;
    FTurtle.DrawOptions.LineContrastIndex := 10;

    plant.Draw(
      FTurtle,
      ABasePoint,
      AScale,
      FPlantLibrary.Orientation,
      FPlantLibrary.OffsetX,
      FPlantLibrary.OffsetY
    );
  end;
begin
  paintRect := ARect;
  ACanvas.Brush.Color := $F2F0EA;
  ACanvas.FillRect(paintRect);

  plant := SelectedPlant;
  if (plant = nil) or (FLoadError <> '') then
  begin
    ACanvas.Font.Size := 12;
    ACanvas.Font.Color := clBlack;
    if FLoadError <> '' then
      ACanvas.TextOut(24, 24, FLoadError)
    else
      ACanvas.TextOut(24, 24, 'No plant selected');
    Exit;
  end;

  contentRect := Rect(paintRect.Left + 28, paintRect.Top + 28, paintRect.Right - 28, paintRect.Bottom - 28);
  targetCenterX := (contentRect.Left + contentRect.Right) div 2;
  targetBottomY := contentRect.Bottom - 8;
  basePoint := Point(targetCenterX, targetBottomY);

  scalePixelsPerMm := Min(InnerWidth(contentRect) / 180.0, InnerHeight(contentRect) / 240.0);
  scalePixelsPerMm := Max(0.35, scalePixelsPerMm) * Max(0.1, FPlantLibrary.Scale);

  DrawPlantToCanvas(nil, basePoint, scalePixelsPerMm);
  sceneBounds := FTurtle.BoundsRect;
  boundsWidth := InnerWidth(sceneBounds);
  boundsHeight := InnerHeight(sceneBounds);

  fittedScale := scalePixelsPerMm * Min(InnerWidth(contentRect) / boundsWidth, InnerHeight(contentRect) / boundsHeight);
  fittedScale := ClampSingle(fittedScale, 0.08, 24.0);

  DrawPlantToCanvas(nil, basePoint, fittedScale);
  sceneBounds := FTurtle.BoundsRect;
  deltaX := targetCenterX - ((sceneBounds.Left + sceneBounds.Right) div 2);
  deltaY := targetBottomY - sceneBounds.Bottom;
  finalBasePoint := Point(basePoint.X + deltaX, basePoint.Y + deltaY);

  DrawPlantToCanvas(ACanvas, finalBasePoint, fittedScale);

  ACanvas.Brush.Style := bsClear;
  ACanvas.Pen.Color := $B9B2A7;
  ACanvas.Rectangle(paintRect.Left + 12, paintRect.Top + 12, paintRect.Right - 12, paintRect.Bottom - 12);
  ACanvas.Brush.Style := bsSolid;
end;

procedure TPlantStudioMainForm.SaveScreenshot;
var
  bitmap: TBitmap;
  png: TPortableNetworkGraphic;
  screenshotDir: string;
begin
  if FScreenshotPath = '' then
    Exit;

  screenshotDir := ExtractFileDir(FScreenshotPath);
  if screenshotDir <> '' then
    ForceDirectories(screenshotDir);

  bitmap := TBitmap.Create;
  try
    bitmap.SetSize(PaintBox.Width, PaintBox.Height);
    RenderScene(bitmap.Canvas, Rect(0, 0, bitmap.Width, bitmap.Height));
    png := TPortableNetworkGraphic.Create;
    try
      png.Assign(bitmap);
      png.SaveToFile(FScreenshotPath);
    finally
      png.Free;
    end;
  finally
    bitmap.Free;
  end;
end;

procedure TPlantStudioMainForm.PaintBoxPaint(Sender: TObject);
begin
  RenderScene(PaintBox.Canvas, PaintBox.ClientRect);
  if not FRendered then
  begin
    FRendered := True;
    SaveScreenshot;
    if FQuitAfterRender or (FScreenshotPath <> '') then
      StartupTimer.Enabled := True;
  end;
end;

procedure TPlantStudioMainForm.PlantListClick(Sender: TObject);
begin
  FRendered := False;
  UpdateStatus;
  PaintBox.Invalidate;
end;

procedure TPlantStudioMainForm.RotateButtonClick(Sender: TObject);
var
  plant: PdPlant;
begin
  plant := SelectedPlant;
  if (plant = nil) or not (Sender is TButton) then
    Exit;
  plant.YRotation := plant.YRotation + TButton(Sender).Tag;
  FRendered := False;
  UpdateStatus;
  PaintBox.Invalidate;
end;

procedure TPlantStudioMainForm.GrowButtonClick(Sender: TObject);
var
  plant: PdPlant;
begin
  plant := SelectedPlant;
  if (plant = nil) or not (Sender is TButton) then
    Exit;

  if TButton(Sender).Tag < 0 then
    plant.SetAge(0)
  else
    plant.SetAge(plant.Age + TButton(Sender).Tag);

  FRendered := False;
  UpdateStatus;
  PaintBox.Invalidate;
end;

procedure TPlantStudioMainForm.StartupTimerTimer(Sender: TObject);
begin
  StartupTimer.Enabled := False;
  Close;
end;

end.
