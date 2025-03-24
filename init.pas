unit Init;

{$mode ObjFPC}{$H+}



interface

uses
  Classes, SysUtils,raylib,raygui;
type

   // Type pour représenter un hexagone
  THexagon = record
    ID: Integer;          // Identifiant unique
    CenterX: Integer;     // Coordonnée X du centre
    CenterY: Integer;     // Coordonnée Y du centre
    ColorR: Integer;      // Couleur R de l'hexagone
    ColorG: Integer;      // Couleur G de l'hexagone
    ColorB: Integer;      // Couleur B de l'hexagone
    ColorPtR: Integer;    // Couleur R du point central (pour type de terrain)
    ColorPtG: Integer;    // Couleur G du point central
    ColorPtB: Integer;    // Couleur B du point central
    BSelected: Boolean;   // Hexagone sélectionné ?
    Colonne: Integer;     // Numéro de colonne
    Ligne: Integer;       // Numéro de ligne
    Emplacement: string;  // Position sur la carte (CoinHG, BordH, etc.)
    PairImpairLigne: Boolean; // Pour calculer les voisins
    Vertex1X, Vertex1Y: Integer; // Sommet 1
    Vertex2X, Vertex2Y: Integer; // Sommet 2
    Vertex3X, Vertex3Y: Integer; // Sommet 3
    Vertex4X, Vertex4Y: Integer; // Sommet 4
    Vertex5X, Vertex5Y: Integer; // Sommet 5
    Vertex6X, Vertex6Y: Integer; // Sommet 6
    Neighbor1: Integer;   // Voisin nord
    Neighbor2: Integer;   // Voisin nord-est
    Neighbor3: Integer;   // Voisin sud-est
    Neighbor4: Integer;   // Voisin sud
    Neighbor5: Integer;   // Voisin sud-ouest
    Neighbor6: Integer;   // Voisin nord-ouest
    Route: Boolean;       // Présence d'une route (oui/non)
    TerrainType: string;  // Type de terrain (plaine, foret, mer, etc.)
    Objet: Integer;       // Objet spécial (5000 = tour, 10000 = case victoire, 0 = rien)
  end;


   T_App =record
      Id:Integer;
      lenom:PChar;
      intituleTitre: PChar;
      intituleParag1: PChar;
      intituleParag2: PChar;
      intituleParag3: PChar;
      PosIntituleTitre:TVector2;       //ecriture sur titre
      posintituleParag1:TVector2;
      posintituleParag2:TVector2;      // ecriture sur panel1
      posintituleParag3:TVector2;
      panel:TRectangle;   // panel titre
      paneldebugger:TRectangle;   // panel 1
      couleursupportTitre:TColor;
   end;

 const
  MAX_HEXAGONS = 832; // Nombre total d'hexagones dans le CSV
var
 // Taille de la fenêtre
  screenWidth:Integer =1280;
  screenHeight :integer= 1024;
  // Dimensions des bordures
  leftBorderWidth :integer= 0;
  topBorderHeight :integer= 0;
  bottomBorderHeight :integer= 100;
  rightBorderWidth :integer= 250;
  Appli:T_App;

  camera: TCamera2D;
  image: TImage;
  texture: TTexture2D;
  mousePos, mousePositionmvt: TVector2;
  worldPosition: TVector2;
  deltaX, deltaY: Single;
  leftLimit, topLimit, rightLimit, bottomLimit: Single;
  untext,untext2,phrasetext,phrase2text: String;
  Pchartxt:PChar ='resources/Carte1870.png';                 // carte principale
  Pchartxt2:pchar;
  // Tableau pour stocker les hexagones
  Hexagons: array[0..MAX_HEXAGONS-1] of THexagon;
  HexagonCount: Integer; // Nombre d'hexagones chargés
  clickedHexID:integer;


procedure chargeressource;
procedure initialisezCamera2D;
procedure LoadHexagonsFromCSV(const FileName: string);

 implementation
procedure chargeressource;


  begin
       with Appli do                  // objet jeu
       begin
       Id:=1;
      lenom:='Noeud, Direction, A*';


      panel:=RectangleCreate(1250,5,425,60);
      paneldebugger:=RectangleCreate(1250,5,425,60);
      intituleTitre:= 'Noeud, Direction, A*';
      intituleParag1:= 'Mode Fonctionnement';
      intituleParag2:= 'Format Node';
      intituleParag3:='Format Direction';
      couleursupportTitre:=RAYWHITE;
  end;
       LoadHexagonsFromCSV('resources/hexgridplat.csv');
end;

 procedure initialisezCamera2D;
 begin
   // Initialiser la caméra 2D
   camera.target := Vector2Create(texture.width / 2, texture.height / 2); // Centrer sur l'image

   // Ajuster l'offset pour centrer la carte dans la fenêtre, en tenant compte des bordures
   camera.offset := Vector2Create(
     (screenWidth - rightBorderWidth - leftBorderWidth) / 2,
     (screenHeight - bottomBorderHeight - topBorderHeight) / 2
   );

   camera.rotation := 0;
   camera.zoom := 1.0;

   // Définir les limites de défilement pour éviter le hors zone
   // Ajuster les limites pour permettre de voir les bords de la carte
   leftLimit := (screenWidth - rightBorderWidth - leftBorderWidth) / 2 / camera.zoom;
   topLimit := (screenHeight - bottomBorderHeight - topBorderHeight) / 2 / camera.zoom;
   rightLimit := texture.width - (screenWidth - rightBorderWidth - leftBorderWidth) / 2 / camera.zoom;
   bottomLimit := texture.height - (screenHeight - bottomBorderHeight - topBorderHeight) / 2 / camera.zoom;
 end;
 procedure LoadHexagonsFromCSV(const FileName: string);
var
  fileText: TStringList;
  i: Integer;
  line: string;
  values: TStringArray;
  hex: THexagon;
begin
  fileText := TStringList.Create;
  try
    fileText.LoadFromFile(FileName);
    HexagonCount := fileText.Count - 1; // Exclure l'en-tête
    if HexagonCount > MAX_HEXAGONS then
      HexagonCount := MAX_HEXAGONS; // Limiter au maximum

    for i := 1 to HexagonCount do
    begin
      line := fileText[i];
      values := line.Split(';');
      if Length(values) >= 35 then // Vérifier que la ligne a assez de colonnes
      begin
        hex.ID := StrToIntDef(values[0], -1);
        hex.CenterX := StrToIntDef(values[2], 0);
        hex.CenterY := StrToIntDef(values[3], 0);
        hex.ColorR := StrToIntDef(values[4], 0);
        hex.ColorG := StrToIntDef(values[5], 0);
        hex.ColorB := StrToIntDef(values[6], 0);
        hex.ColorPtR := StrToIntDef(values[7], 0);
        hex.ColorPtG := StrToIntDef(values[8], 0);
        hex.ColorPtB := StrToIntDef(values[9], 0);
        hex.BSelected := StrToBoolDef(values[10], False);
        hex.Colonne := StrToIntDef(values[11], 0);
        hex.Ligne := StrToIntDef(values[12], 0);
        hex.Emplacement := values[13];
        hex.PairImpairLigne := StrToBoolDef(values[14], False);
        hex.Vertex1X := StrToIntDef(values[15], 0);
        hex.Vertex1Y := StrToIntDef(values[16], 0);
        hex.Vertex2X := StrToIntDef(values[17], 0);
        hex.Vertex2Y := StrToIntDef(values[18], 0);
        hex.Vertex3X := StrToIntDef(values[19], 0);
        hex.Vertex3Y := StrToIntDef(values[20], 0);
        hex.Vertex4X := StrToIntDef(values[21], 0);
        hex.Vertex4Y := StrToIntDef(values[22], 0);
        hex.Vertex5X := StrToIntDef(values[23], 0);
        hex.Vertex5Y := StrToIntDef(values[24], 0);
        hex.Vertex6X := StrToIntDef(values[25], 0);
        hex.Vertex6Y := StrToIntDef(values[26], 0);
        hex.Neighbor1 := StrToIntDef(values[27], 0);
        hex.Neighbor2 := StrToIntDef(values[28], 0);
        hex.Neighbor3 := StrToIntDef(values[29], 0);
        hex.Neighbor4 := StrToIntDef(values[30], 0);
        hex.Neighbor5 := StrToIntDef(values[31], 0);
        hex.Neighbor6 := StrToIntDef(values[32], 0);
        hex.Route := (values[33] = 'oui');
        hex.TerrainType := values[34];
        hex.Objet := StrToIntDef(values[35], 0);

        Hexagons[i - 1] := hex; // Stocker dans le tableau
      end;
    end;
  finally
    fileText.Free;
  end;
  WriteLn('Chargé ', HexagonCount, ' hexagones');
end;

end.


