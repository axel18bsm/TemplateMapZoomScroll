
program moyenage;

{$mode objfpc}{$H+}

uses
  raylib, strings, init, UnitProcFunc;                      // pour chaine de caractères en C - Pchar

var
   index:integer;

begin

  // Charger une image (remplacez "large_image.png" par votre image)
  Pchartxt:='resources/newlacarte.png';

  InitWindow(screenWidth, screenHeight, pchartxt);
  SetTargetFPS(60);

    image := LoadImage(Pchartxt);
    texture := LoadTextureFromImage(image);
    UnloadImage(image); // L'image originale peut être déchargée après la conversion
   // initialisation des ressources
   writeln('ok, j ai la main!');
   chargeressource();
   initialisezCamera2D();
 while not WindowShouldClose() do
begin
  if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
  begin
    mousePos := GetMousePosition();
    worldPosition := GetScreenToWorld2D(mousePos, camera);
    // Détecter l'hexagone cliqué avec la méthode point dans le polygone
    clickedHexID := GetHexagonAtPosition(worldPosition.x, worldPosition.y);
    writeln(clickedHexID);
  end;

  // Déplacement avec les touches fléchées
  MoveCarte2DFleche;
  // Déplacement avec glisser-déposer de la souris
  DragAndDropCarte2D;
  ZoomCarte2D;
  AffichageGuiBas;


    BeginDrawing();
ClearBackground(BLACK); // Fond noir pour éviter la lisière grise
begin
  // Afficher l'image
  BeginMode2D(camera);
  DrawTexture(texture, 0, 0, WHITE); // Dessiner l'image à la position (0, 0)
  EndMode2D();

  // Dessiner les bordures
  DrawRectangle(0, 0, leftBorderWidth, screenHeight, BLACK); // Bordure gauche
  DrawRectangle(0, 0, screenWidth, topBorderHeight, BLACK); // Bordure haute
  DrawRectangle(0, screenHeight - bottomBorderHeight, screenWidth, bottomBorderHeight, BLACK); // Bordure basse
  DrawRectangle(screenWidth - rightBorderWidth, 0, rightBorderWidth, screenHeight, BLACK); // Bordure droite

  // Afficher les informations sur la position du clic
  DrawText('La carte se déplace avec les touches fléchées ou glisser-déposer', leftBorderWidth, screenHeight-90, 20, RED);
  DrawText(Pchartxt, leftBorderWidth, screenHeight-60, 20, RED);
  DrawText(Pchartxt2, leftBorderWidth, screenHeight-30, 20, RED);
end;
EndDrawing();
  end;

  // Libération des ressources
  UnloadTexture(texture);
  CloseWindow();
end.
