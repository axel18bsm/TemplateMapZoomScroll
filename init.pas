unit Init;

{$mode ObjFPC}{$H+}



interface

uses
  Classes, SysUtils,raylib,raygui;
type




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

   t_button = record
      Id: Integer;
      Fileimage:pchar;        // chemin de mon dessin normal
      latexture:TTexture2D;   // le dessin est stocké
      limage:TImage;          //nomdufichier normal
      position :tvector2;      //position bouton
      afficher:Boolean;       // est il affiché ?
   end;

var
 // Taille de la fenêtre
  screenWidth:Integer =1280;
  screenHeight :integer= 800;
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



procedure chargeressource;
procedure initialisezCamera2D;

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

end.


