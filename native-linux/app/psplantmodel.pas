unit psplantmodel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Graphics, Contnrs, pstdo, psturtle;

const
  kCompoundLeafPinnate = 0;
  kCompoundLeafPalmate = 1;

type
  TTdoParams = record
    Object3D: KfObject3D;
    ScaleAtFullSize: Single;
    XRotationBeforeDraw: Single;
    YRotationBeforeDraw: Single;
    ZRotationBeforeDraw: Single;
    FaceColor: TColor;
    BackfaceColor: TColor;
    Repetitions: Integer;
    RadiallyArranged: Boolean;
    PullBackAngle: Single;
  end;

  TGeneralParams = record
    RandomSway: Single;
    StartingSeed: Integer;
    NumApicalInflors: Integer;
    NumAxillaryInflors: Integer;
    LineDivisions: Integer;
    IsDicot: Boolean;
    MaleFlowersAreSeparate: Boolean;
    AgeAtMaturity: Integer;
    AgeAtWhichFloweringStarts: Integer;
    PhyllotacticRotationAngle: Single;
  end;

  TMeristemParams = record
    BranchingAngle: Single;
    BranchingIndex: Single;
    BranchingDistance: Single;
    SecondaryBranchingIsAllowed: Boolean;
    BranchingIsSympodial: Boolean;
    BudTdoParams: TTdoParams;
  end;

  TInternodeParams = record
    FaceColor: TColor;
    CurvingIndex: Single;
    FirstInternodeCurvingIndex: Single;
    LengthAtOptimalFinalBiomassAndExpansion_mm: Single;
    WidthAtOptimalFinalBiomassAndExpansion_mm: Single;
    MinDaysToCreateInternode: Integer;
    MaxDaysToCreateInternodeIfOverMinFraction: Integer;
    MinDaysToAccumulateBiomass: Integer;
    MaxDaysToAccumulateBiomass: Integer;
  end;

  TLeafParams = record
    LeafTdoParams: TTdoParams;
    StipuleTdoParams: TTdoParams;
    PetioleColor: TColor;
    PetioleAngle: Single;
    CompoundNumLeaflets: Integer;
    CompoundPinnateOrPalmate: Integer;
    CompoundRachisToPetioleRatio: Single;
    CompoundCurveAngleAtStart: Single;
    CompoundCurveAngleAtFullSize: Single;
    PetioleLengthAtOptimalBiomass_mm: Single;
    PetioleWidthAtOptimalBiomass_mm: Single;
    PetioleTaperIndex: Integer;
  end;

  TSeedlingLeafParams = record
    LeafTdoParams: TTdoParams;
    NodesOnStemWhenFallsOff: Integer;
  end;

  TFlowerParams = record
    PetalTdoParams: TTdoParams;
    NumPetals: Integer;
  end;

  TInflorescenceParams = record
    NumFlowersOnMainBranch: Integer;
    NumFlowersPerBranch: Integer;
    NumBranches: Integer;
    StalkColor: TColor;
    PedicelColor: TColor;
    BranchAngle: Single;
    InternodeAngle: Single;
    PedicelAngle: Single;
    PeduncleAngle: Single;
    TerminalStalkLength_mm: Single;
    PeduncleLength_mm: Single;
    InternodeLength_mm: Single;
    PedicelLength_mm: Single;
    InternodeWidth_mm: Single;
    BractTdoParams: TTdoParams;
  end;

  TRootParams = record
    TdoParams: TTdoParams;
    ShowsAboveGround: Boolean;
  end;

  TPlantNode = class
  public
    NodeIndex: Integer;
    Depth: Integer;
    GrowthFactor: Single;
    LengthMM: Single;
    WidthMM: Single;
    CurveZDegrees: Single;
    CurveYDegrees: Single;
    HasLeftLeaf: Boolean;
    HasRightLeaf: Boolean;
    HasSeedlingLeaves: Boolean;
    InflorescenceCount: Integer;
    Branches: TObjectList;
    NextNode: TPlantNode;
    constructor Create;
    destructor Destroy; override;
  end;

  PdPlant = class;

  PdTraverser = class
  private
    FPlant: PdPlant;
    FTurtle: KfTurtle;
    procedure TraverseNode(ANode: TPlantNode);
    procedure DrawLeaf(const ANode: TPlantNode; const ASide: Integer; const ASeedling: Boolean);
    procedure DrawSingleLeafObject(const AParams: TLeafParams; const ATdoParams: TTdoParams;
      const AScaleFactor: Single; const ALeafletRotationDegrees: Single);
    procedure DrawCompoundLeaf(const AParams: TLeafParams; const AScaleFactor: Single; const ASide: Integer);
    procedure DrawFlowerRing(const ATdoParams: TTdoParams; const ACount: Integer; const AScaleFactor: Single);
    procedure DrawInflorescence(const ANode: TPlantNode);
    procedure ApplyTdoDraw(const ATdoParams: TTdoParams; const AScaleFactor: Single; const APartID: LongInt);
  public
    constructor Create(APlant: PdPlant; ATurtle: KfTurtle);
    procedure TraverseWholePlant;
  end;

  PdPlant = class
  private
    FRootNode: TPlantNode;
    procedure FreeTdoParams(var ATdoParams: TTdoParams);
    procedure InitTdoParams(var ATdoParams: TTdoParams; const ADefaultFace, ADefaultBack: TColor; const AScale: Single);
    function DefaultObject3D(const AHint: string): KfObject3D;
    function CreateLeafObject: KfObject3D;
    function CreatePetalObject: KfObject3D;
    function CreateBudObject: KfObject3D;
    function BuildStem(const ADepth: Integer; const AScaleFactor: Single; const ASeedOffset: Integer): TPlantNode;
    function BranchShouldSpawn(const ADepth, ANodeIndex, ASeedOffset: Integer): Boolean;
    function MatureFraction: Single;
    function FloweringFraction: Single;
  public
    Name: string;
    Age: Integer;
    XRotation: Single;
    YRotation: Single;
    ZRotation: Single;
    pGeneral: TGeneralParams;
    pMeristem: TMeristemParams;
    pInternode: TInternodeParams;
    pLeaf: TLeafParams;
    pSeedlingLeaf: TSeedlingLeafParams;
    pFlower: TFlowerParams;
    pInflorescence: TInflorescenceParams;
    pRoot: TRootParams;
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure SetAge(const ANewAge: Integer);
    procedure NextDay;
    procedure Draw(ATurtle: KfTurtle; const ABasePoint: TPoint; const AScalePixelsPerMm: Single;
      const AOrientation: Integer; const AOffsetX, AOffsetY: Single);
    procedure RebuildStructure;
    procedure AssignTdo(const AFieldID: string; AObject: KfObject3D);
    procedure ApplyField(const AFieldID, AValue: string);
    property RootNode: TPlantNode read FRootNode;
  end;

implementation

uses
  Math, pssupport, ps3dtypes;

constructor TPlantNode.Create;
begin
  inherited Create;
  Branches := TObjectList.Create(True);
end;

destructor TPlantNode.Destroy;
begin
  NextNode.Free;
  Branches.Free;
  inherited Destroy;
end;

constructor PdTraverser.Create(APlant: PdPlant; ATurtle: KfTurtle);
begin
  inherited Create;
  FPlant := APlant;
  FTurtle := ATurtle;
end;

procedure PdTraverser.ApplyTdoDraw(const ATdoParams: TTdoParams; const AScaleFactor: Single; const APartID: LongInt);
var
  objectScale: Single;
begin
  if (ATdoParams.Object3D = nil) or (FTurtle = nil) then
    Exit;
  objectScale := AScaleFactor * (ATdoParams.ScaleAtFullSize / 100.0);
  if objectScale <= 0.0 then
    Exit;
  FTurtle.Push;
  FTurtle.RotateX(DegreesToTurtleAngle(ATdoParams.XRotationBeforeDraw));
  FTurtle.RotateY(DegreesToTurtleAngle(ATdoParams.YRotationBeforeDraw));
  FTurtle.RotateZ(DegreesToTurtleAngle(ATdoParams.ZRotationBeforeDraw));
  FTurtle.SetForeColorBackColor(ATdoParams.FaceColor, ATdoParams.BackfaceColor);
  FTurtle.SetLineColor(DarkerColor(ATdoParams.FaceColor));
  FTurtle.SetLineWidth(1.0);
  ATdoParams.Object3D.Draw(FTurtle, objectScale, APartID);
  FTurtle.Pop;
end;

procedure PdTraverser.DrawSingleLeafObject(const AParams: TLeafParams; const ATdoParams: TTdoParams;
  const AScaleFactor: Single; const ALeafletRotationDegrees: Single);
begin
  FTurtle.Push;
  FTurtle.RotateZ(DegreesToTurtleAngle(ALeafletRotationDegrees));
  FTurtle.RotateY(DegreesToTurtleAngle(ATdoParams.PullBackAngle));
  ApplyTdoDraw(ATdoParams, AScaleFactor, 300);
  FTurtle.Pop;
end;

procedure PdTraverser.DrawCompoundLeaf(const AParams: TLeafParams; const AScaleFactor: Single; const ASide: Integer);
var
  i: Integer;
  leafletCount: Integer;
  leafletScale: Single;
  spreadDegrees: Single;
  segmentLength: Single;
  angleDirection: Integer;
begin
  leafletCount := ClampInt(AParams.CompoundNumLeaflets, 2, 12);
  leafletScale := AScaleFactor * 0.55;
  segmentLength := ClampSingle(AParams.PetioleLengthAtOptimalBiomass_mm / Max(leafletCount, 1), 4.0, 35.0);
  spreadDegrees := ClampSingle(AParams.CompoundRachisToPetioleRatio * 0.5, 12.0, 70.0);
  angleDirection := ASide;
  for i := 0 to leafletCount - 1 do
  begin
    FTurtle.Push;
    FTurtle.MoveInMillimeters(segmentLength * (i + 0.6));
    if (AParams.CompoundPinnateOrPalmate = kCompoundLeafPalmate) then
      FTurtle.RotateZ(DegreesToTurtleAngle(angleDirection * spreadDegrees))
    else
      FTurtle.RotateZ(DegreesToTurtleAngle(angleDirection * (spreadDegrees * 0.45)));
    FTurtle.RotateY(DegreesToTurtleAngle(AParams.CompoundCurveAngleAtFullSize));
    DrawSingleLeafObject(AParams, AParams.LeafTdoParams, leafletScale, angleDirection * 12.0);
    FTurtle.Pop;
    angleDirection := -angleDirection;
  end;
end;

procedure PdTraverser.DrawLeaf(const ANode: TPlantNode; const ASide: Integer; const ASeedling: Boolean);
var
  petioleLength: Single;
  petioleWidth: Single;
  leafScale: Single;
  drawSeedling: Boolean;
  leafParams: TLeafParams;
  tdoParams: TTdoParams;
begin
  drawSeedling := ASeedling;
  leafParams := FPlant.pLeaf;
  tdoParams := FPlant.pLeaf.LeafTdoParams;
  if drawSeedling then
  begin
    tdoParams := FPlant.pSeedlingLeaf.LeafTdoParams;
    petioleLength := Max(12.0, FPlant.pLeaf.PetioleLengthAtOptimalBiomass_mm * 0.22);
    petioleWidth := Max(0.3, FPlant.pLeaf.PetioleWidthAtOptimalBiomass_mm * 0.8);
    leafScale := 0.32 + (ANode.GrowthFactor * 0.22);
  end
  else
  begin
    petioleLength := Max(6.0, FPlant.pLeaf.PetioleLengthAtOptimalBiomass_mm * (0.32 + (ANode.GrowthFactor * 0.68)));
    petioleWidth := Max(0.25, FPlant.pLeaf.PetioleWidthAtOptimalBiomass_mm * (0.45 + (ANode.GrowthFactor * 0.65)));
    leafScale := 0.25 + (ANode.GrowthFactor * 0.75);
  end;

  FTurtle.Push;
  FTurtle.RotateZ(DegreesToTurtleAngle(ASide * Max(18.0, FPlant.pLeaf.PetioleAngle)));
  FTurtle.RotateY(DegreesToTurtleAngle(ASide * (8.0 + FPlant.pGeneral.RandomSway * 0.3)));
  FTurtle.SetLineColor(FPlant.pLeaf.PetioleColor);
  FTurtle.SetLineWidth(petioleWidth);
  FTurtle.DrawInMillimeters(petioleLength, 200 + ASide);
  if (not drawSeedling) and (FPlant.pLeaf.CompoundNumLeaflets > 1) then
    DrawCompoundLeaf(leafParams, leafScale, ASide)
  else
    DrawSingleLeafObject(leafParams, tdoParams, leafScale, ASide * 10.0);
  FTurtle.Pop;
end;

procedure PdTraverser.DrawFlowerRing(const ATdoParams: TTdoParams; const ACount: Integer; const AScaleFactor: Single);
var
  i: Integer;
  petalCount: Integer;
  angleStep: Single;
begin
  petalCount := Max(1, ACount);
  angleStep := 256.0 / petalCount;
  for i := 0 to petalCount - 1 do
  begin
    FTurtle.Push;
    if petalCount > 1 then
      FTurtle.RotateX(i * angleStep);
    FTurtle.RotateZ(DegreesToTurtleAngle(ATdoParams.PullBackAngle));
    ApplyTdoDraw(ATdoParams, AScaleFactor, 500 + i);
    FTurtle.Pop;
  end;
end;

procedure PdTraverser.DrawInflorescence(const ANode: TPlantNode);
var
  i: Integer;
  flowerGroups: Integer;
  stalkLength: Single;
begin
  stalkLength := Max(10.0, FPlant.pInflorescence.PeduncleLength_mm);
  flowerGroups := Max(1, ANode.InflorescenceCount);
  FTurtle.Push;
  FTurtle.RotateZ(DegreesToTurtleAngle(FPlant.pInflorescence.PeduncleAngle));
  FTurtle.SetLineColor(FPlant.pInflorescence.StalkColor);
  FTurtle.SetLineWidth(Max(0.25, FPlant.pInflorescence.InternodeWidth_mm));
  FTurtle.DrawInMillimeters(stalkLength, 400);
  for i := 0 to flowerGroups - 1 do
  begin
    FTurtle.Push;
    FTurtle.MoveInMillimeters(Max(5.0, FPlant.pInflorescence.InternodeLength_mm) * (i * 0.7));
    FTurtle.RotateZ(DegreesToTurtleAngle((i - (flowerGroups div 2)) * FPlant.pInflorescence.InternodeAngle));
    FTurtle.SetLineColor(FPlant.pInflorescence.PedicelColor);
    FTurtle.SetLineWidth(Max(0.2, FPlant.pInflorescence.InternodeWidth_mm * 0.65));
    FTurtle.DrawInMillimeters(Max(4.0, FPlant.pInflorescence.PedicelLength_mm), 410 + i);
    DrawFlowerRing(FPlant.pFlower.PetalTdoParams, Max(1, FPlant.pFlower.NumPetals), 0.3 + (FPlant.FloweringFraction * 0.7));
    FTurtle.Pop;
  end;
  FTurtle.Pop;
end;

procedure PdTraverser.TraverseNode(ANode: TPlantNode);
var
  i: Integer;
  branchAngle: Single;
begin
  if (ANode = nil) or (FTurtle = nil) then
    Exit;

  FTurtle.SetLineColor(FPlant.pInternode.FaceColor);
  FTurtle.SetLineWidth(Max(0.2, ANode.WidthMM));
  FTurtle.RotateY(DegreesToTurtleAngle(ANode.CurveYDegrees));
  FTurtle.RotateZ(DegreesToTurtleAngle(ANode.CurveZDegrees));
  FTurtle.DrawInMillimeters(ANode.LengthMM, 100 + ANode.NodeIndex);

  if ANode.HasSeedlingLeaves then
  begin
    DrawLeaf(ANode, -1, True);
    if FPlant.pGeneral.IsDicot then
      DrawLeaf(ANode, 1, True);
  end;

  if ANode.HasLeftLeaf then
    DrawLeaf(ANode, -1, False);
  if ANode.HasRightLeaf then
    DrawLeaf(ANode, 1, False);
  if ANode.InflorescenceCount > 0 then
    DrawInflorescence(ANode);

  branchAngle := Max(8.0, FPlant.pMeristem.BranchingAngle);
  for i := 0 to ANode.Branches.Count - 1 do
  begin
    FTurtle.Push;
    if Odd(i) then
      FTurtle.RotateZ(DegreesToTurtleAngle(branchAngle))
    else
      FTurtle.RotateZ(DegreesToTurtleAngle(-branchAngle));
    FTurtle.RotateY(DegreesToTurtleAngle(10 + (i * 4)));
    TraverseNode(TPlantNode(ANode.Branches[i]));
    FTurtle.Pop;
  end;

  if ANode.NextNode <> nil then
  begin
    FTurtle.RotateX(DegreesToTurtleAngle(FPlant.pGeneral.PhyllotacticRotationAngle));
    TraverseNode(ANode.NextNode);
  end;
end;

procedure PdTraverser.TraverseWholePlant;
begin
  TraverseNode(FPlant.RootNode);
end;

constructor PdPlant.Create;
begin
  inherited Create;
  pGeneral.RandomSway := 10.0;
  pGeneral.StartingSeed := 280;
  pGeneral.NumApicalInflors := 2;
  pGeneral.NumAxillaryInflors := 2;
  pGeneral.LineDivisions := 5;
  pGeneral.IsDicot := True;
  pGeneral.AgeAtMaturity := 100;
  pGeneral.AgeAtWhichFloweringStarts := 60;
  pGeneral.PhyllotacticRotationAngle := 137.5;

  pMeristem.BranchingAngle := 20.0;
  pMeristem.BranchingIndex := 20.0;
  pMeristem.BranchingDistance := 3.0;
  pMeristem.SecondaryBranchingIsAllowed := False;
  pMeristem.BranchingIsSympodial := False;

  pInternode.FaceColor := RGBToColor(48, 132, 62);
  pInternode.CurvingIndex := 8.0;
  pInternode.FirstInternodeCurvingIndex := 5.0;
  pInternode.LengthAtOptimalFinalBiomassAndExpansion_mm := 34.0;
  pInternode.WidthAtOptimalFinalBiomassAndExpansion_mm := 0.8;
  pInternode.MinDaysToCreateInternode := 3;
  pInternode.MaxDaysToCreateInternodeIfOverMinFraction := 10;
  pInternode.MinDaysToAccumulateBiomass := 3;
  pInternode.MaxDaysToAccumulateBiomass := 10;

  InitTdoParams(pLeaf.LeafTdoParams, RGBToColor(58, 180, 72), RGBToColor(48, 132, 62), 30.0);
  InitTdoParams(pLeaf.StipuleTdoParams, RGBToColor(58, 180, 72), RGBToColor(48, 132, 62), 10.0);
  pLeaf.PetioleColor := RGBToColor(48, 132, 62);
  pLeaf.PetioleAngle := 18.0;
  pLeaf.CompoundNumLeaflets := 1;
  pLeaf.CompoundPinnateOrPalmate := kCompoundLeafPinnate;
  pLeaf.CompoundRachisToPetioleRatio := 20.0;
  pLeaf.CompoundCurveAngleAtStart := 0.0;
  pLeaf.CompoundCurveAngleAtFullSize := 4.0;
  pLeaf.PetioleLengthAtOptimalBiomass_mm := 26.0;
  pLeaf.PetioleWidthAtOptimalBiomass_mm := 0.4;
  pLeaf.PetioleTaperIndex := 100;

  InitTdoParams(pSeedlingLeaf.LeafTdoParams, RGBToColor(92, 168, 74), RGBToColor(72, 128, 62), 20.0);
  pSeedlingLeaf.NodesOnStemWhenFallsOff := 3;

  InitTdoParams(pFlower.PetalTdoParams, RGBToColor(232, 216, 102), RGBToColor(186, 150, 62), 10.0);
  pFlower.NumPetals := 5;

  pInflorescence.NumFlowersOnMainBranch := 4;
  pInflorescence.NumFlowersPerBranch := 3;
  pInflorescence.NumBranches := 2;
  pInflorescence.StalkColor := RGBToColor(104, 142, 60);
  pInflorescence.PedicelColor := RGBToColor(132, 152, 72);
  pInflorescence.BranchAngle := 12.0;
  pInflorescence.InternodeAngle := 8.0;
  pInflorescence.PedicelAngle := 10.0;
  pInflorescence.PeduncleAngle := 0.0;
  pInflorescence.TerminalStalkLength_mm := 32.0;
  pInflorescence.PeduncleLength_mm := 18.0;
  pInflorescence.InternodeLength_mm := 8.0;
  pInflorescence.PedicelLength_mm := 12.0;
  pInflorescence.InternodeWidth_mm := 0.4;
  InitTdoParams(pInflorescence.BractTdoParams, RGBToColor(76, 150, 72), RGBToColor(64, 110, 60), 12.0);

  InitTdoParams(pMeristem.BudTdoParams, RGBToColor(72, 124, 64), RGBToColor(56, 94, 48), 10.0);
  InitTdoParams(pRoot.TdoParams, RGBToColor(126, 98, 74), RGBToColor(84, 62, 42), 10.0);
  pRoot.ShowsAboveGround := False;

  pLeaf.LeafTdoParams.Object3D := CreateLeafObject;
  pSeedlingLeaf.LeafTdoParams.Object3D := CreateLeafObject;
  pFlower.PetalTdoParams.Object3D := CreatePetalObject;
  pMeristem.BudTdoParams.Object3D := CreateBudObject;

  Age := 0;
  XRotation := 0.0;
  YRotation := 0.0;
  ZRotation := 0.0;
end;

destructor PdPlant.Destroy;
begin
  FRootNode.Free;
  FreeTdoParams(pLeaf.LeafTdoParams);
  FreeTdoParams(pLeaf.StipuleTdoParams);
  FreeTdoParams(pSeedlingLeaf.LeafTdoParams);
  FreeTdoParams(pFlower.PetalTdoParams);
  FreeTdoParams(pInflorescence.BractTdoParams);
  FreeTdoParams(pMeristem.BudTdoParams);
  FreeTdoParams(pRoot.TdoParams);
  inherited Destroy;
end;

procedure PdPlant.FreeTdoParams(var ATdoParams: TTdoParams);
begin
  FreeAndNil(ATdoParams.Object3D);
end;

procedure PdPlant.InitTdoParams(var ATdoParams: TTdoParams; const ADefaultFace, ADefaultBack: TColor; const AScale: Single);
begin
  FillChar(ATdoParams, SizeOf(ATdoParams), 0);
  ATdoParams.FaceColor := ADefaultFace;
  ATdoParams.BackfaceColor := ADefaultBack;
  ATdoParams.ScaleAtFullSize := AScale;
  ATdoParams.Repetitions := 1;
end;

function PdPlant.CreateLeafObject: KfObject3D;
var
  point3D: KfPoint3D;
begin
  Result := KfObject3D.Create;
  Result.Name := 'Default native leaf';
  KfPoint3D_SetXYZ(point3D, 0, 0, 0); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, -10, -75, 8); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, 0, -118, 3); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, 10, -75, 8); Result.AddPoint(point3D);
  Result.AddTriangle(KfIndexTriangle.CreateABC(1, 2, 3));
  Result.AddTriangle(KfIndexTriangle.CreateABC(1, 3, 4));
  Result.AdjustForOrigin;
end;

function PdPlant.CreatePetalObject: KfObject3D;
var
  point3D: KfPoint3D;
begin
  Result := KfObject3D.Create;
  Result.Name := 'Default native petal';
  KfPoint3D_SetXYZ(point3D, 0, 0, 0); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, -14, -48, 4); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, 0, -86, -2); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, 12, -48, 4); Result.AddPoint(point3D);
  Result.AddTriangle(KfIndexTriangle.CreateABC(1, 2, 3));
  Result.AddTriangle(KfIndexTriangle.CreateABC(1, 3, 4));
  Result.AdjustForOrigin;
end;

function PdPlant.CreateBudObject: KfObject3D;
var
  point3D: KfPoint3D;
begin
  Result := KfObject3D.Create;
  Result.Name := 'Default native bud';
  KfPoint3D_SetXYZ(point3D, 0, 0, 0); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, -8, -26, -6); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, 0, -44, 4); Result.AddPoint(point3D);
  KfPoint3D_SetXYZ(point3D, 9, -25, -6); Result.AddPoint(point3D);
  Result.AddTriangle(KfIndexTriangle.CreateABC(1, 2, 3));
  Result.AddTriangle(KfIndexTriangle.CreateABC(1, 3, 4));
  Result.AdjustForOrigin;
end;

function PdPlant.DefaultObject3D(const AHint: string): KfObject3D;
begin
  if Pos('PETAL', UpperCase(AHint)) > 0 then
    Result := CreatePetalObject
  else if Pos('FLOWER', UpperCase(AHint)) > 0 then
    Result := CreatePetalObject
  else if Pos('BUD', UpperCase(AHint)) > 0 then
    Result := CreateBudObject
  else
    Result := CreateLeafObject;
end;

function PdPlant.MatureFraction: Single;
begin
  Result := ClampSingle(Age / Max(1.0, pGeneral.AgeAtMaturity), 0.0, 1.0);
end;

function PdPlant.FloweringFraction: Single;
begin
  if Age <= pGeneral.AgeAtWhichFloweringStarts then
    Exit(0.0);
  Result := ClampSingle(
    (Age - pGeneral.AgeAtWhichFloweringStarts) /
    Max(1.0, pGeneral.AgeAtMaturity - pGeneral.AgeAtWhichFloweringStarts),
    0.0,
    1.0
  );
end;

function PdPlant.BranchShouldSpawn(const ADepth, ANodeIndex, ASeedOffset: Integer): Boolean;
var
  branchEvery: Integer;
  branchStart: Integer;
begin
  branchEvery := ClampInt(14 - Round(pMeristem.BranchingIndex / 9.0), 2, 12);
  branchStart := ClampInt(Round(pMeristem.BranchingDistance), 1, 6);
  Result := (ANodeIndex >= branchStart)
    and (((ANodeIndex + ASeedOffset + ADepth + pGeneral.StartingSeed) mod branchEvery) = 0);
end;

function PdPlant.BuildStem(const ADepth: Integer; const AScaleFactor: Single; const ASeedOffset: Integer): TPlantNode;
var
  baseNodeCount: Integer;
  nodeCount: Integer;
  i: Integer;
  stageAge: Single;
  growthFactor: Single;
  node: TPlantNode;
  branchScale: Single;
begin
  Result := nil;
  nodeCount := Max(1, Round((2 + MatureFraction * (7 + pGeneral.NumApicalInflors + (pGeneral.NumAxillaryInflors * 0.5))) * AScaleFactor));
  if nodeCount <= 0 then
    Exit;

  for i := nodeCount - 1 downto 0 do
  begin
    stageAge := Age - (i * Max(2, pInternode.MinDaysToCreateInternode - ADepth));
    growthFactor := ClampSingle(stageAge / Max(1, pInternode.MinDaysToAccumulateBiomass + ADepth), 0.0, 1.0);
    if (stageAge <= 0) and (i <> 0) then
      Continue;

    node := TPlantNode.Create;
    node.NodeIndex := i;
    node.Depth := ADepth;
    node.GrowthFactor := growthFactor;
    node.LengthMM := Max(3.0, pInternode.LengthAtOptimalFinalBiomassAndExpansion_mm * AScaleFactor * (0.25 + growthFactor * 0.9));
    node.WidthMM := Max(0.15, pInternode.WidthAtOptimalFinalBiomassAndExpansion_mm * AScaleFactor * (0.4 + growthFactor * 0.6));
    if i = 0 then
      node.CurveZDegrees := (Sin((pGeneral.StartingSeed + ASeedOffset) * 0.1) * pInternode.FirstInternodeCurvingIndex)
    else
      node.CurveZDegrees := (Sin((i + ASeedOffset) * 0.7) * pInternode.CurvingIndex * (0.35 + AScaleFactor * 0.2));
    node.CurveYDegrees := Cos((i + ASeedOffset) * 0.55) * (pGeneral.RandomSway * 0.22);
    node.HasSeedlingLeaves := (ADepth = 0) and (i = 0) and (Age <= Max(8, pSeedlingLeaf.NodesOnStemWhenFallsOff * 3));
    node.HasLeftLeaf := growthFactor > 0.25;
    node.HasRightLeaf := growthFactor > 0.25;
    if not pGeneral.IsDicot then
      node.HasRightLeaf := False;
    if FloweringFraction > 0.0 then
    begin
      if (i >= nodeCount - Max(1, pGeneral.NumApicalInflors)) then
        node.InflorescenceCount := Max(1, Round(1 + FloweringFraction * pInflorescence.NumFlowersOnMainBranch))
      else if (pGeneral.NumAxillaryInflors > 0) and (i mod Max(2, 5 - Min(pGeneral.NumAxillaryInflors, 3)) = 0) and (i > 0) then
        node.InflorescenceCount := Max(0, Round(FloweringFraction * Min(3, pGeneral.NumAxillaryInflors)));
    end;

    if (ADepth < 2) and (growthFactor > 0.45) and BranchShouldSpawn(ADepth, i, ASeedOffset) then
    begin
      if (ADepth = 0) or pMeristem.SecondaryBranchingIsAllowed then
      begin
        if ADepth = 0 then
          branchScale := AScaleFactor * 0.62
        else
          branchScale := AScaleFactor * 0.48;
        node.Branches.Add(BuildStem(ADepth + 1, branchScale, ASeedOffset + (i * 11)));
      end;
    end;

    node.NextNode := Result;
    Result := node;
  end;
end;

procedure PdPlant.Reset;
begin
  Age := 0;
  RebuildStructure;
end;

procedure PdPlant.SetAge(const ANewAge: Integer);
begin
  Age := ClampInt(ANewAge, 0, Max(1, pGeneral.AgeAtMaturity));
  RebuildStructure;
end;

procedure PdPlant.NextDay;
begin
  SetAge(Age + 1);
end;

procedure PdPlant.RebuildStructure;
begin
  FreeAndNil(FRootNode);
  FRootNode := BuildStem(0, 1.0, 0);
end;

procedure PdPlant.Draw(ATurtle: KfTurtle; const ABasePoint: TPoint; const AScalePixelsPerMm: Single;
  const AOrientation: Integer; const AOffsetX, AOffsetY: Single);
var
  traverser: PdTraverser;
begin
  if ATurtle = nil then
    Exit;
  if FRootNode = nil then
    RebuildStructure;

  ATurtle.Reset;
  ATurtle.ResetBoundsRect(ABasePoint);
  ATurtle.SetScale_pixelsPerMm(AScalePixelsPerMm);
  ATurtle.DrawingSurface.RecordingStart;
  ATurtle.XYZ(ABasePoint.X + AOffsetX * AScalePixelsPerMm, ABasePoint.Y + AOffsetY * AScalePixelsPerMm, 0);
  ATurtle.RotateZ(64);
  if AOrientation <> 0 then
    ATurtle.RotateX(-64);
  ATurtle.RotateX(DegreesToTurtleAngle(XRotation));
  ATurtle.RotateY(DegreesToTurtleAngle(YRotation));
  ATurtle.RotateZ(DegreesToTurtleAngle(ZRotation));
  traverser := PdTraverser.Create(Self, ATurtle);
  try
    traverser.TraverseWholePlant;
  finally
    traverser.Free;
  end;
  ATurtle.DrawingSurface.RecordingStop;
  if ATurtle.DrawOptions.SortPolygons then
    ATurtle.DrawingSurface.RecordingDraw
  else
    ATurtle.DrawingSurface.TrianglesDraw;
end;

procedure PdPlant.AssignTdo(const AFieldID: string; AObject: KfObject3D);
var
  normalized: string;
begin
  normalized := UpperCase(AFieldID);
  if AObject = nil then
    Exit;
  if normalized = 'KLEAFOBJECT3D' then
  begin
    FreeAndNil(pLeaf.LeafTdoParams.Object3D);
    pLeaf.LeafTdoParams.Object3D := AObject;
  end
  else if normalized = 'KSTIPULEOBJECT3D' then
  begin
    FreeAndNil(pLeaf.StipuleTdoParams.Object3D);
    pLeaf.StipuleTdoParams.Object3D := AObject;
  end
  else if normalized = 'KSEEDLINGLEAFOBJECT3D' then
  begin
    FreeAndNil(pSeedlingLeaf.LeafTdoParams.Object3D);
    pSeedlingLeaf.LeafTdoParams.Object3D := AObject;
  end
  else if (normalized = 'KFLOWERFEMALEOBJECT3D') or (normalized = 'KFLOWERMALEOBJECT3D') then
  begin
    FreeAndNil(pFlower.PetalTdoParams.Object3D);
    pFlower.PetalTdoParams.Object3D := AObject;
  end
  else if normalized = 'KINFLORESCENCEFEMALEBRACTOBJECT3D' then
  begin
    FreeAndNil(pInflorescence.BractTdoParams.Object3D);
    pInflorescence.BractTdoParams.Object3D := AObject;
  end
  else if normalized = 'KAXILLARYBUDOBJECT3D' then
  begin
    FreeAndNil(pMeristem.BudTdoParams.Object3D);
    pMeristem.BudTdoParams.Object3D := AObject;
  end
  else
    AObject.Free;
end;

procedure PdPlant.ApplyField(const AFieldID, AValue: string);
var
  fieldID: string;
begin
  fieldID := UpperCase(AFieldID);
  if fieldID = 'KGENERALLINEDIVISIONS' then
    pGeneral.LineDivisions := ParsePlantInt(AValue, pGeneral.LineDivisions)
  else if fieldID = 'KGENERALRANDOMSWAY' then
    pGeneral.RandomSway := ParsePlantSingle(AValue, pGeneral.RandomSway)
  else if fieldID = 'KGENERALAGEATMATURITY' then
    pGeneral.AgeAtMaturity := ParsePlantInt(AValue, pGeneral.AgeAtMaturity)
  else if fieldID = 'KGENERALAGEATWHICHFLOWERINGSTARTS' then
    pGeneral.AgeAtWhichFloweringStarts := ParsePlantInt(AValue, pGeneral.AgeAtWhichFloweringStarts)
  else if fieldID = 'KGENERALISDICOT' then
    pGeneral.IsDicot := ParsePlantBool(AValue, pGeneral.IsDicot)
  else if fieldID = 'KGENERALMALEFLOWERSARESEPARATE' then
    pGeneral.MaleFlowersAreSeparate := ParsePlantBool(AValue, pGeneral.MaleFlowersAreSeparate)
  else if fieldID = 'KGENERALNUMAPICALINFLORS' then
    pGeneral.NumApicalInflors := ParsePlantInt(AValue, pGeneral.NumApicalInflors)
  else if fieldID = 'KGENERALNUMAXILLARYINFLORS' then
    pGeneral.NumAxillaryInflors := ParsePlantInt(AValue, pGeneral.NumAxillaryInflors)
  else if fieldID = 'KGENERALPHYLLACTICROTATIONANGLE' then
    pGeneral.PhyllotacticRotationAngle := ParsePlantSingle(AValue, pGeneral.PhyllotacticRotationAngle)
  else if fieldID = 'KGENERALPHYLLOTACTICROTATIONANGLE' then
    pGeneral.PhyllotacticRotationAngle := ParsePlantSingle(AValue, pGeneral.PhyllotacticRotationAngle)
  else if fieldID = 'KGENERALSTARTINGSEEDFORRANDOMNUMBERGENERATOR' then
    pGeneral.StartingSeed := ParsePlantInt(AValue, pGeneral.StartingSeed)

  else if fieldID = 'KMERISTEMBRANCHINGANGLE' then
    pMeristem.BranchingAngle := ParsePlantSingle(AValue, pMeristem.BranchingAngle)
  else if fieldID = 'KMERISTEMBRANCHINGINDEX' then
    pMeristem.BranchingIndex := ParsePlantSingle(AValue, pMeristem.BranchingIndex)
  else if fieldID = 'KMERISTEMBRANCHINGDISTANCE' then
    pMeristem.BranchingDistance := ParsePlantSingle(AValue, pMeristem.BranchingDistance)
  else if fieldID = 'KMERISTEMSECONDARYBRANCHINGISALLOWED' then
    pMeristem.SecondaryBranchingIsAllowed := ParsePlantBool(AValue, pMeristem.SecondaryBranchingIsAllowed)
  else if fieldID = 'KMERISTEMBRANCHINGISSYMPODIAL' then
    pMeristem.BranchingIsSympodial := ParsePlantBool(AValue, pMeristem.BranchingIsSympodial)

  else if fieldID = 'KINTERNODEFACECOLOR' then
    pInternode.FaceColor := ParsePlantColor(AValue, pInternode.FaceColor)
  else if fieldID = 'KINTERNODECURVINGINDEX' then
    pInternode.CurvingIndex := ParsePlantSingle(AValue, pInternode.CurvingIndex)
  else if fieldID = 'KINTERNODEFIRSTINTERNODECURVINGINDEX' then
    pInternode.FirstInternodeCurvingIndex := ParsePlantSingle(AValue, pInternode.FirstInternodeCurvingIndex)
  else if fieldID = 'KINTERNODELENGTHATOPTIMALFINALBIOMASSANDEXPANSION_MM' then
    pInternode.LengthAtOptimalFinalBiomassAndExpansion_mm := ParsePlantSingle(AValue, pInternode.LengthAtOptimalFinalBiomassAndExpansion_mm)
  else if fieldID = 'KINTERNODEWIDTHATOPTIMALFINALBIOMASSANDEXPANSION_MM' then
    pInternode.WidthAtOptimalFinalBiomassAndExpansion_mm := ParsePlantSingle(AValue, pInternode.WidthAtOptimalFinalBiomassAndExpansion_mm)
  else if fieldID = 'KINTERNODEMINDAYSTOCREATEINTERNODE' then
    pInternode.MinDaysToCreateInternode := ParsePlantInt(AValue, pInternode.MinDaysToCreateInternode)
  else if fieldID = 'KINTERNODEMAXDAYSTOCREATEINTERNODEIFOVERMINFRACTION' then
    pInternode.MaxDaysToCreateInternodeIfOverMinFraction := ParsePlantInt(AValue, pInternode.MaxDaysToCreateInternodeIfOverMinFraction)
  else if fieldID = 'KINTERNODEMINDAYSTOACCUMULATEBIOMASS' then
    pInternode.MinDaysToAccumulateBiomass := ParsePlantInt(AValue, pInternode.MinDaysToAccumulateBiomass)
  else if fieldID = 'KINTERNODEMAXDAYSTOACCUMULATEBIOMASS' then
    pInternode.MaxDaysToAccumulateBiomass := ParsePlantInt(AValue, pInternode.MaxDaysToAccumulateBiomass)

  else if fieldID = 'KLEAFSCALEATOPTIMALBIOMASS' then
    pLeaf.LeafTdoParams.ScaleAtFullSize := ParsePlantSingle(AValue, pLeaf.LeafTdoParams.ScaleAtFullSize)
  else if fieldID = 'KLEAFOBJECT3DXROTATIONBEFOREDRAW' then
    pLeaf.LeafTdoParams.XRotationBeforeDraw := ParsePlantSingle(AValue, pLeaf.LeafTdoParams.XRotationBeforeDraw)
  else if fieldID = 'KLEAFOBJECT3DYROTATIONBEFOREDRAW' then
    pLeaf.LeafTdoParams.YRotationBeforeDraw := ParsePlantSingle(AValue, pLeaf.LeafTdoParams.YRotationBeforeDraw)
  else if fieldID = 'KLEAFOBJECT3DZROTATIONBEFOREDRAW' then
    pLeaf.LeafTdoParams.ZRotationBeforeDraw := ParsePlantSingle(AValue, pLeaf.LeafTdoParams.ZRotationBeforeDraw)
  else if fieldID = 'KLEAFFACECOLOR' then
    pLeaf.LeafTdoParams.FaceColor := ParsePlantColor(AValue, pLeaf.LeafTdoParams.FaceColor)
  else if fieldID = 'KLEAFBACKFACECOLOR' then
    pLeaf.LeafTdoParams.BackfaceColor := ParsePlantColor(AValue, pLeaf.LeafTdoParams.BackfaceColor)
  else if fieldID = 'KLEAFPETIOLECOLOR' then
    pLeaf.PetioleColor := ParsePlantColor(AValue, pLeaf.PetioleColor)
  else if fieldID = 'KLEAFPETIOLEANGLE' then
    pLeaf.PetioleAngle := ParsePlantSingle(AValue, pLeaf.PetioleAngle)
  else if fieldID = 'KLEAFCOMPOUNDNUMLEAFLETS' then
    pLeaf.CompoundNumLeaflets := ParsePlantInt(AValue, pLeaf.CompoundNumLeaflets)
  else if fieldID = 'KLEAFCOMPOUNDPINNATEORPALMATE' then
    pLeaf.CompoundPinnateOrPalmate := ParsePlantInt(AValue, pLeaf.CompoundPinnateOrPalmate)
  else if fieldID = 'KLEAFCOMPOUNDRACHISTOPETIOLERATIO' then
    pLeaf.CompoundRachisToPetioleRatio := ParsePlantSingle(AValue, pLeaf.CompoundRachisToPetioleRatio)
  else if fieldID = 'KLEAFCOMPOUNDBENDANGLEATSTART' then
    pLeaf.CompoundCurveAngleAtStart := ParsePlantSingle(AValue, pLeaf.CompoundCurveAngleAtStart)
  else if fieldID = 'KLEAFCOMPOUNDBENDANGLEATFULLSIZE' then
    pLeaf.CompoundCurveAngleAtFullSize := ParsePlantSingle(AValue, pLeaf.CompoundCurveAngleAtFullSize)
  else if fieldID = 'KLEAFPETIOLELENGTHATOPTIMALBIOMASS_MM' then
    pLeaf.PetioleLengthAtOptimalBiomass_mm := ParsePlantSingle(AValue, pLeaf.PetioleLengthAtOptimalBiomass_mm)
  else if fieldID = 'KLEAFPETIOLEWIDTHATOPTIMALBIOMASS_MM' then
    pLeaf.PetioleWidthAtOptimalBiomass_mm := ParsePlantSingle(AValue, pLeaf.PetioleWidthAtOptimalBiomass_mm)
  else if fieldID = 'KLEAFPETIOLETAPERINDEX' then
    pLeaf.PetioleTaperIndex := ParsePlantInt(AValue, pLeaf.PetioleTaperIndex)

  else if fieldID = 'KSEEDLINGLEAFSCALE' then
    pSeedlingLeaf.LeafTdoParams.ScaleAtFullSize := ParsePlantSingle(AValue, pSeedlingLeaf.LeafTdoParams.ScaleAtFullSize)
  else if fieldID = 'KSEEDLINGLEAFOBJECT3DXROTATIONBEFOREDRAW' then
    pSeedlingLeaf.LeafTdoParams.XRotationBeforeDraw := ParsePlantSingle(AValue, pSeedlingLeaf.LeafTdoParams.XRotationBeforeDraw)
  else if fieldID = 'KSEEDLINGLEAFOBJECT3DYROTATIONBEFOREDRAW' then
    pSeedlingLeaf.LeafTdoParams.YRotationBeforeDraw := ParsePlantSingle(AValue, pSeedlingLeaf.LeafTdoParams.YRotationBeforeDraw)
  else if fieldID = 'KSEEDLINGLEAFOBJECT3DZROTATIONBEFOREDRAW' then
    pSeedlingLeaf.LeafTdoParams.ZRotationBeforeDraw := ParsePlantSingle(AValue, pSeedlingLeaf.LeafTdoParams.ZRotationBeforeDraw)
  else if fieldID = 'KSEEDLINGLEAFFACECOLOR' then
    pSeedlingLeaf.LeafTdoParams.FaceColor := ParsePlantColor(AValue, pSeedlingLeaf.LeafTdoParams.FaceColor)
  else if fieldID = 'KSEEDLINGLEAFBACKFACECOLOR' then
    pSeedlingLeaf.LeafTdoParams.BackfaceColor := ParsePlantColor(AValue, pSeedlingLeaf.LeafTdoParams.BackfaceColor)
  else if fieldID = 'KSEEDLINGLEAFNODESONSTEMWHENFALLSOFF' then
    pSeedlingLeaf.NodesOnStemWhenFallsOff := ParsePlantInt(AValue, pSeedlingLeaf.NodesOnStemWhenFallsOff)

  else if (fieldID = 'KFLOWERSCALEATFULLSIZEFEMALE') or (fieldID = 'KFLOWERSCALEATFULLSIZEMALE') then
    pFlower.PetalTdoParams.ScaleAtFullSize := ParsePlantSingle(AValue, pFlower.PetalTdoParams.ScaleAtFullSize)
  else if (fieldID = 'KFLOWERFEMALEOBJECT3DXROTATIONBEFOREDRAW') or (fieldID = 'KFLOWERMALEOBJECT3DXROTATIONBEFOREDRAW') then
    pFlower.PetalTdoParams.XRotationBeforeDraw := ParsePlantSingle(AValue, pFlower.PetalTdoParams.XRotationBeforeDraw)
  else if (fieldID = 'KFLOWERFEMALEOBJECT3DYROTATIONBEFOREDRAW') or (fieldID = 'KFLOWERMALEOBJECT3DYROTATIONBEFOREDRAW') then
    pFlower.PetalTdoParams.YRotationBeforeDraw := ParsePlantSingle(AValue, pFlower.PetalTdoParams.YRotationBeforeDraw)
  else if (fieldID = 'KFLOWERFEMALEOBJECT3DZROTATIONBEFOREDRAW') or (fieldID = 'KFLOWERMALEOBJECT3DZROTATIONBEFOREDRAW') then
    pFlower.PetalTdoParams.ZRotationBeforeDraw := ParsePlantSingle(AValue, pFlower.PetalTdoParams.ZRotationBeforeDraw)
  else if (fieldID = 'KFLOWERFEMALEFACECOLOR') or (fieldID = 'KFLOWERMALEFACECOLOR') then
    pFlower.PetalTdoParams.FaceColor := ParsePlantColor(AValue, pFlower.PetalTdoParams.FaceColor)
  else if (fieldID = 'KFLOWERFEMALEBACKFACECOLOR') or (fieldID = 'KFLOWERMALEBACKFACECOLOR') then
    pFlower.PetalTdoParams.BackfaceColor := ParsePlantColor(AValue, pFlower.PetalTdoParams.BackfaceColor)
  else if (fieldID = 'KFLOWERNUMPETALSFEMALE') or (fieldID = 'KFLOWERNUMPETALSMALE') then
    pFlower.NumPetals := ParsePlantInt(AValue, pFlower.NumPetals)
  else if (fieldID = 'KFLOWERFEMALEOBJECT3DPULLBACKANGLE') or (fieldID = 'KFLOWERMALEOBJECT3DPULLBACKANGLE') then
    pFlower.PetalTdoParams.PullBackAngle := ParsePlantSingle(AValue, pFlower.PetalTdoParams.PullBackAngle)

  else if fieldID = 'KINFLORESCENCENUMFLOWERSONMAINBRANCHFEMALE' then
    pInflorescence.NumFlowersOnMainBranch := ParsePlantInt(AValue, pInflorescence.NumFlowersOnMainBranch)
  else if fieldID = 'KINFLORESCENCENUMFLOWERSPERBRANCHFEMALE' then
    pInflorescence.NumFlowersPerBranch := ParsePlantInt(AValue, pInflorescence.NumFlowersPerBranch)
  else if fieldID = 'KINFLORESCENCENUMBRANCHESFEMALE' then
    pInflorescence.NumBranches := ParsePlantInt(AValue, pInflorescence.NumBranches)
  else if fieldID = 'KINFLORESCENCEFEMALESTALKCOLOR' then
    pInflorescence.StalkColor := ParsePlantColor(AValue, pInflorescence.StalkColor)
  else if fieldID = 'KINFLORESCENCEFEMALEPEDICELCOLOR' then
    pInflorescence.PedicelColor := ParsePlantColor(AValue, pInflorescence.PedicelColor)
  else if fieldID = 'KINFLORESCENCEBRANCHANGLEFEMALE' then
    pInflorescence.BranchAngle := ParsePlantSingle(AValue, pInflorescence.BranchAngle)
  else if fieldID = 'KINFLORESCENCEINTERNODEANGLEFEMALE' then
    pInflorescence.InternodeAngle := ParsePlantSingle(AValue, pInflorescence.InternodeAngle)
  else if fieldID = 'KINFLORESCENCEPEDICELANGLEFEMALE' then
    pInflorescence.PedicelAngle := ParsePlantSingle(AValue, pInflorescence.PedicelAngle)
  else if fieldID = 'KINFLORESCENCEPEDUNCLEANGLEFROMVEGETATIVESTEMFEMALE' then
    pInflorescence.PeduncleAngle := ParsePlantSingle(AValue, pInflorescence.PeduncleAngle)
  else if fieldID = 'KINFLORESCENCETERMINALSTALKLENGTHFEMALE' then
    pInflorescence.TerminalStalkLength_mm := ParsePlantSingle(AValue, pInflorescence.TerminalStalkLength_mm)
  else if fieldID = 'KINFLORESCENCEPEDUNCLELENGTHFEMALE' then
    pInflorescence.PeduncleLength_mm := ParsePlantSingle(AValue, pInflorescence.PeduncleLength_mm)
  else if fieldID = 'KINFLORESCENCEINTERNODELENGTHFEMALE' then
    pInflorescence.InternodeLength_mm := ParsePlantSingle(AValue, pInflorescence.InternodeLength_mm)
  else if fieldID = 'KINFLORESCENCEPEDICELLENGTHFEMALE' then
    pInflorescence.PedicelLength_mm := ParsePlantSingle(AValue, pInflorescence.PedicelLength_mm)
  else if fieldID = 'KINFLORESCENCEINTERNODEWIDTHFEMALE' then
    pInflorescence.InternodeWidth_mm := ParsePlantSingle(AValue, pInflorescence.InternodeWidth_mm);
end;

end.
