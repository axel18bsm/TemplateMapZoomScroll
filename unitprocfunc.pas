unit UnitProcFunc;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,init,raylib;
procedure MoveCarte2DFleche;
procedure AffichageGuiBas;
procedure DragAndDropCarte2D;
procedure ZoomCarte2D;
function GetHexagonAtPosition(x, y: Single): Integer;

implementation

function GetHexagonAtPosition(x, y: Single): Integer;
var
  i: Integer;
  minDistance, distance: Single;
  closestHex: Integer;
  startIdx, endIdx: Integer;
  mouseScreenPos: TVector2;
begin
  Result := 0; // Retourne 0 par défaut (clic hors de la carte ou aucun hexagone trouvé)

  // Récupérer les coordonnées brutes de la souris (espace de l'écran)
  mouseScreenPos := GetMousePosition();

  // Vérifier si le clic est dans la zone visible (hors des bordures noires)
  // Utiliser directement les coordonnées de l'écran, avant conversion
  if (mouseScreenPos.x < leftBorderWidth) or
     (mouseScreenPos.x > screenWidth - rightBorderWidth) or
     (mouseScreenPos.y < topBorderHeight) or
     (mouseScreenPos.y > screenHeight - bottomBorderHeight) then
  begin
    Exit; // Retourne 0 si le clic est dans les bordures noires
  end;

  // Si le clic est dans la zone visible, chercher l'hexagone
  minDistance := 10000; // Distance initiale très grande
  closestHex := -1;

  // Déterminer le groupe en fonction de y (espace du monde)
  if y <= 565 then
  begin
    startIdx := 0; // Hexagones 1 à 288 (indices 0 à 287)
    endIdx := 287;
  end
  else if y <= 1060 then
  begin
    startIdx := 288; // Hexagones 289 à 576 (indices 288 à 575)
    endIdx := 575;
  end
  else
  begin
    startIdx := 576; // Hexagones 577 à 832 (indices 576 à 831)
    endIdx := HexagonCount - 1;
  end;

  // Parcourir les hexagones du groupe
  for i := startIdx to endIdx do
  begin
    distance := Sqrt(Sqr(x - Hexagons[i].CenterX) + Sqr(y - Hexagons[i].CenterY));
    if distance < minDistance then
    begin
      minDistance := distance;
      closestHex := Hexagons[i].ID;
    end;
  end;

  if closestHex >= 0 then
    Result := closestHex;
end;

procedure MoveCarte2DFleche;
begin
    // Déplacement de la caméra avec les touches fléchées
    deltaX := 0;
    deltaY := 0;
    if IsKeyDown(KEY_RIGHT) then deltaX := 5;
    if IsKeyDown(KEY_LEFT) then deltaX := -5;
    if IsKeyDown(KEY_DOWN) then deltaY := 5;
    if IsKeyDown(KEY_UP) then deltaY := -5;

    // Appliquer les limites au mouvement
    camera.target.x := camera.target.x + deltaX;
    camera.target.y := camera.target.y + deltaY;

    if camera.target.x < leftLimit then camera.target.x := leftLimit;
    if camera.target.x > rightLimit then camera.target.x := rightLimit;

    if camera.target.y < topLimit then camera.target.y := topLimit;
    if camera.target.y > bottomLimit then camera.target.y := bottomLimit;
end;

procedure AffichageGuiBas;
begin
   // Générer le texte des coordonnées acrobatie Pascal sur les chaines caracteres
    // conversion d un nombre en text et ensuite d'un string classique en old string Pascal et C.
      Str(trunc(mousepos.x),untext);  // souris en x single en pascal valeur entiere ou non donc trunc pour conversion str
      Str(trunc(mousepos.y),untext2);  // souris en y
      phrasetext:='position clic souris fenetre principale x : ' + untext +' y : '+untext2;
      Pchartxt :=pchar(phrasetext);

      Str(trunc(worldPosition.x),untext);  // souris en x
      Str(trunc(worldPosition.y),untext2);
      phrase2text:='position clic souris Carte x : ' + untext +' y : '+untext2;
      Pchartxt2 :=pchar(phrase2text);
end;
procedure DragAndDropCarte2D;
var
  deltaX, deltaY: Single;
  currentMousePos: TVector2;
begin
  if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
  begin
    currentMousePos := GetMousePosition();
    deltaX := mousePos.x - currentMousePos.x;
    deltaY := mousePos.y - currentMousePos.y;

    camera.target.x := camera.target.x + deltaX;
    camera.target.y := camera.target.y + deltaY;

    // Utiliser les limites dynamiques
    if camera.target.x < leftLimit then
      camera.target.x := leftLimit;
    if camera.target.x > rightLimit then
      camera.target.x := rightLimit;
    if camera.target.y < topLimit then
      camera.target.y := topLimit;
    if camera.target.y > bottomLimit then
      camera.target.y := bottomLimit;

    mousePos := currentMousePos;
  end;
end;




procedure ZoomCarte2D;
var
  wheelMove: Single;
  mouseWorldPosBefore, mouseWorldPosAfter: TVector2;
  zoomFactor: Single = 0.1; // Sensibilité du zoom
  minZoom: Single = 0.8;   // Zoom minimal (50% de la taille originale)
  maxZoom: Single = 2.0;   // Zoom maximal (200% de la taille originale)
begin
  // Récupérer le mouvement de la molette
  wheelMove := GetMouseWheelMove();

  if wheelMove <> 0 then
  begin
    // Récupérer la position de la souris dans le monde avant le zoom
    mouseWorldPosBefore := GetScreenToWorld2D(GetMousePosition(), camera);

    // Ajuster le zoom
    camera.zoom := camera.zoom + wheelMove * zoomFactor;

    // Limiter le zoom entre minZoom et maxZoom
    if camera.zoom < minZoom then
      camera.zoom := minZoom;
    if camera.zoom > maxZoom then
      camera.zoom := maxZoom;

    // Recalculer la position de la souris dans le monde après le zoom
    mouseWorldPosAfter := GetScreenToWorld2D(GetMousePosition(), camera);

    // Ajuster la position de la caméra pour que le point sous la souris reste le même
    camera.target.x := camera.target.x + (mouseWorldPosBefore.x - mouseWorldPosAfter.x);
    camera.target.y := camera.target.y + (mouseWorldPosBefore.y - mouseWorldPosAfter.y);

    // Recalculer les limites en fonction du zoom
    leftLimit := (screenWidth - rightBorderWidth - leftBorderWidth) / 2 / camera.zoom;
    topLimit := (screenHeight - bottomBorderHeight - topBorderHeight) / 2 / camera.zoom;
    rightLimit := texture.width - (screenWidth - rightBorderWidth - leftBorderWidth) / 2 / camera.zoom;
    bottomLimit := texture.height - (screenHeight - bottomBorderHeight - topBorderHeight) / 2 / camera.zoom;

    // Assurer que la caméra respecte les nouvelles limites
    if camera.target.x < leftLimit then
      camera.target.x := leftLimit;
    if camera.target.x > rightLimit then
      camera.target.x := rightLimit;
    if camera.target.y < topLimit then
      camera.target.y := topLimit;
    if camera.target.y > bottomLimit then
      camera.target.y := bottomLimit;
  end;
end;
end.

