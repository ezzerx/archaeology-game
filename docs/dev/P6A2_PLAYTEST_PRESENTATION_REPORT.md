# P6A2 — Soil & Playtest Presentation

2026-10-07. Livraison pour **revue humaine**, pas validation artistique automatique. [Statut canonique](../brain/status.md), [brief et précisions humaines](P6A2_PLAYTEST_PRESENTATION_BRIEF.md), [captures et mesures](evidence/p6a2-playtest/README.md).

## Résultat et périmètre

Le Hero reçoit de vrais dépôts Soil fragmentés, une UI papier/musée jusque dans l’archive, le rendu à résolution native avec bascule plein écran, une lampe visible et deux accessoires. Clay v02, Sandstone, Bone, éclairage local et géométrie B restent ceux du Hero corrigé `d535c31`. Jacket et emprise intérieure ne changent pas. P4/P5, physique 60 Hz et cap 240 FPS sont conservés.

Point de départ : branche synchronisée avec origin, sans avance distante au lancement. Les changements locaux préexistants dans `project.godot`, l’import du plâtre et l’UID `tests/export_p6a_evidence.gd.uid` ont été conservés et exclus du commit. Le retrait local de la déclaration explicite 60 Hz laisse la valeur par défaut 60 Hz, vérifiée au runtime. Les rapports précédents ne sont pas réécrits.

## Architecture et Soil

Scène conservée : `scenes/p6a2_hero_patch.tscn`, héritée du lab P6A1.6. `hero_patch.gd` choisit toujours B. Le profil local `playtest_soil_profile.gd` étend `NaturalMatrixProfile`, garde ses couches/substrats et remplace seulement le cache de hauteur Soil initial de B. Le moteur d’excavation n’est ni copié ni retuné ; le témoin technique P6A1.6 reste inchangé.

Ancien profil : seuil de bruit large, avec de grandes régions reliées. Nouveau profil : 720 propositions déterministes de dépôts, rejet des centres trop proches, rayons de trois familles (4–10, 12–25, 27–39 mm), ovales orientés à lobes inégaux, encoche locale et bords cassés. Les collisions entre dépôts utilisent le maximum, jamais une accumulation d’épaisseur. Les trous sont de vraies cellules sans Soil. La hauteur s’ajoute au substrat local, sans remplir les creux jusqu’à un niveau commun ; aucune lecture du fossile. Pas de préférence artificielle pour les creux dans cette version : l’option n’était pas nécessaire pour obtenir une fragmentation bornée.

Le grain coloré est **la source Soil ImageGen v02 déjà sélectionnée**, à son échelle 24 cm. Son albedo et son gain `.68` n’ont pas été éclaircis. Aucun retour à l’ancien atlas. La seule adaptation shader Soil est un fondu vers le substrat dans la frange réellement mince (0,025–0,32 mm), à l’intérieur du masque Soil existant. Ce substrat reprend aussi la patine existante pour éviter un liseré orange artificiel. Aucun déplacement GPU supplémentaire, aucun masque de picking distinct, aucun grain persistant simulé.

La patine reste un système séparé, son code et son défaut ON sont inchangés. Les comparaisons ON/OFF démontrent que les amas excavables et les salissures résiduelles ne sont pas la même chose. Le relief, l’albedo et le traitement de Clay hors Soil sont inchangés.

### Morphologie mesurée sur le vrai heightfield

Seuil de mesure 0,01 mm ; composantes à **8 voisins**, donc les ponts diagonaux comptent aussi. Les détails granulaires produisent beaucoup de petites composantes ; leur nombre seul n’est pas un critère de réussite.

| Mesure | Ancien Soil | Nouveau Soil |
|---|---:|---:|
| Couverture | 55,60 % | 18,32 % |
| Plus grande composante / aire du bloc | 46,13 % | 0,467 % |
| Plus grande composante / Soil restant | 82,97 % | 2,55 % |
| Plus grande diagonale de boîte englobante | 1 304 mm | 117 mm |
| Composantes (y compris petits grains de bord) | 9 | 1 786 |
| Aire médiane / P95 en cellules | 218 / 302 318 | 2 / 363 |
| Épaisseur maximale | 2,00 mm | 1,64 mm |
| Épaisseur moyenne sur tout le bloc | 0,719 mm | 0,151 mm |

La quantité totale de Soil baisse d’environ **79 %** ; ce n’est pas présenté comme une durée totale de brossage équivalente. Le Brush est strictement inchangé et une passe native de deux secondes nettoie le trajet de contrôle sans entamer Clay. L’effort structurel Clay/Sandstone reste inchangé. La quantité et le plaisir de nettoyer sont à juger humainement ; une bonne statistique de fragmentation ne suffit pas.

## UI : véritable restyle, règles communes

`playtest_preparation_ui.gd` hérite de `PreparationUI`. Il remplace sa présentation dans le Hero tout en conservant l’unique `PreparationSession`, ses signaux, ses snapshots et ses actions. Les autres scènes gardent leur UI historique.

Palette crème/papier, encre brune, progression vert olive, accent ocre, fine bordure et ombre discrète. Titres Georgia et texte Segoe UI via `SystemFont` Windows, avec replis Times New Roman/Arial : aucun fichier de police propriétaire redistribué. Cartouche « Natural History / Preparation Record », titre B-17 et règle de séparation ; Reveal, Clean et Condition restent distincts et directement lisibles. Même langage pour les quatre boutons d’outil, les choix Archive / Keep Cleaning et la fiche d’archive.

85/85, garde-fou des parties cachées, palier facultatif 95/95, arrondi inférieur des pourcentages, Condition, maintien des outils après completion et verrouillage après Archive sont conservés. L’UI n’ajoute ni score, ni récompense, ni nouvel objectif. Le diagnostic reste disponible avec F1/H et masqué au démarrage.

L’exemple UI papier/musée mentionné dans le GO n’a pas été retrouvé parmi les fichiers locaux accessibles. La direction textuelle précise d’Antoine a été appliquée ; cette livraison ne prétend pas reproduire une image non inspectée.

## Affichage et accessoires

`playtest_display.gd` configure seulement le Hero : canvas logique 1920×1080, mode `CANVAS_ITEMS` pour dessiner la 3D à la résolution de sortie, fenêtre initiale 1600×900 bornée à l’écran disponible. Alt+Entrée ou bouton : plein écran sans bordure ; Échap : retour fenêtre. Mode et taille fenêtrée capturée à la bascule sont enregistrés dans `user://p6a2_display.cfg`. Le mode QA n’écrit pas cette préférence.

Le cadrage 16:9 est conservé : une fenêtre 16:10 utilise des bandes au lieu de couper l’aire de jeu. Zoom/pan restent ceux de `PrecisionZoom`. Les changements de taille et pertes de focus annulent les strokes via les mécanismes existants. Tests de focus par notifications moteur ; aucune prétention à un essai manuel d’Alt-Tab sur plusieurs PC.

Lampe statique articulée, émail vert/laiton ; ouverture de la tête sur l’axe du Spot accepté, 4 cm en retrait de son origine pour ne pas masquer la matrice. L’éclairage Spot/Omni/directionnel/ambiant n’est pas retuné. La lampe ne projette pas d’ombre sur sa propre source ; les deux accessoires reçoivent et projettent des ombres : **un pot avec trois pinceaux** et **un carnet avec crayon**. Aucun autre prop ajouté.

Chaîne Blender 5.2.2 LTS → `.blend` → GLB → Godot. Sources/exports : `art/source/p6a2/meshes/preparation_desk.blend`, `assets/p6a2/static/preparation_desk.glb`. Générateur original : `tools/p6a2/build_playtest_desk.py`. Export du `.blend` rouvert possible avec `tools/preflight/export_static.py`. Unités et axes du preflight inchangés. Trois meshes, **2 772 triangles**, GLB **98 436 octets**, `.blend` **139 999 octets**. Jacket existant 6 400 triangles : total statique 9 172 triangles. Aucun collider. Aucun rayon obstrué parmi 345 points de la matrice au niveau du fond, avec la direction de caméra commune aux zooms.

## Comparaison visuelle

Les [A/B Soil](evidence/p6a2-playtest/README.md) conservent caméra, UI, lumière et accessoires. La version précédente avait des nappes reliées traversant le bloc ; le candidat offre des amas séparés, des contours friables et des passages Clay. À 3×, le grain v02 reste visible et la frange moins abrupte. Le brossage partiel enlève réellement ces amas et retrouve le substrat patiné.

Face à [01 gameplay](../visual-references/p6a2/01-gameplay-target.jpg) et [02 matière](../visual-references/p6a2/02-material-closeup.jpg), cela se rapproche de dépôts superficiels distincts, mais reste moins volumétrique et artisanal que le concept. La vue d’ensemble conserve un bloc rectangulaire et la patine reste très présente : ce chantier ne les dissimule pas. Les [captures de progression et UI](evidence/p6a2-playtest/README.md) séparent presets de fouille natifs et fixtures de fin de session.

## Performance

Godot 4.7.2 / Compatibility OpenGL 3.3, RTX 5080, Ryzen 7 9800X3D. Cap 240 FPS, physique 60 Hz. Mesure native des outils pendant 120 ticks par cas, après chauffe. Série finale exécutée seule, sans Blender/export/régressions concurrentes.

Comparaison contrôlée 1080p : **ancien Soil + accessoires masqués** contre **nouveau Soil + accessoires visibles**, avec le même restyle UI et les mêmes shaders/matières/lumières Hero. Ce n’est pas une mesure isolée du coût du restyle par rapport à l’ancien HUD. Caméras/trajectoires identiques ; les hauteurs Soil diffèrent volontairement. Le shader témoin désactive la frange nouvelle.

| Cas final | Zoom | Frame P95 ms | GPU moyen ms | CPU édition P95 ms |
|---|---:|---:|---:|---:|
| Reset | 1× | 4,33 | 2,29 | 0 |
| Reset | 3× | 4,34 | 1,13 | 0 |
| Brush Soil | 1× | 8,58 | 2,36 | 4,28 |
| Chisel | 1× | 4,61 | 1,98 | 5,00 |
| Pick près de Bone | 3× | 6,77 | 1,12 | 0,65 |
| Blower / débris | 1× | 7,49 | 1,96 | 0,51 |
| Nettoyage Bone Film | 3× | 10,55 | 1,12 | 4,02 |

Reset 1× : GPU 1,93 → 2,29 ms (**+0,36 ms**) ; draw calls 75 → 105, soit +30 avec les surfaces/matériaux des accessoires et leurs ombres. À 3×, les accessoires sortent du champ ; 75 draw calls au reset. Aucun nouvel albedo/normalmap : les cinq sources 1024² restent la bibliothèque matière. Le moniteur texture global vaut environ 48,3 MiB en 1080p ; ressources préchargées dans les deux variantes, donc ce nombre ne mesure pas un delta d’asset.

Plein écran **2560×1440 réel** : reset 1× GPU **2,85 ms**, frame P95 **4,33 ms** ; reset 3× GPU **1,52 ms**, P95 **4,33 ms** ; Brush GPU **3,50 ms**, P95 **8,67 ms**, CPU édition P95 **4,35 ms**. Texture globale environ 61,6 MiB avec les buffers plus grands. Aucun benchmark 4K ni GPU plus faible revendiqué. Le cap 240 FPS ne signifie pas 240 FPS constants pendant l’édition.

## Tests et export Windows

- **42 contrôles fonctionnels** : morphologie, couche mince, Brush, patine séparée, comparaisons natives héritées, plafonds Bone, états Film/progression, 48 rayons picking, UI et actions, props sans autorité, reset.
- **128 régressions P5** : règles, seuils, snapshots et garde-fou conservés.
- **12 captures de comparaison/progression/UI, 13 contrôles**, et **20 contrôles/captures d’affichage** : 1280×720, 1920×1080, 2560×1440, 1600×1000, plein écran natif ; picking 1×/3× et actions fenêtre sans changement d’état. Pose A/B identique explicitement vérifiée à 3×.
- **14 mesures contrôlées 1080p + 3 natives 1440p** : 21 contrôles 1080p, dont les 7 poses A/B, et 3 natifs. Logs finaux sans erreur script/shader/import.
- Défaut trouvé puis corrigé dans le comparateur Hero : un Brush/Blower pouvait supprimer un débris avant le rafraîchissement de sa liste graphique. La recoloration vérifie maintenant l’existence de la cellule, sans toucher au système de débris. Régression ciblée après Blower et nouvelle série performance sans erreur.

Export via `tools/p6a2/Export-Playtest.ps1` dans un **projet de staging neuf** ignoré par Git. Le `project.godot` actif n’est pas réécrit ; seule la copie choisit le Hero comme scène principale. ZIP contenant `.exe`, `.pck`, `LISEZ-MOI.txt` et licences, environ **56,3 Mo**. Ni Godot éditeur ni Blender requis chez les amis. Pas de sources DCC, rapports ou caches d’éditeur distribués.

Templates de la [distribution officielle Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/), préparés sans UAC sous `%LOCALAPPDATA%/Programs/ArchaeologyGameTools/godot-4.7.2-export/`. SHA512 de l’archive comparé au [manifeste officiel](https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/SHA512-SUMS.txt) : `ca4d71c4d7b81dfc15d1a98baa07534aa95b03fdda78a0075b06672e1648d2e5f40980c9adc28d23e1b92e732ee7bf3461997aa804af74ec2fcd7a93ccb84079`. Seuls les templates Windows et leur version ont été extraits. Le template release désactive `--path` ; lancer l’exécutable avec son PCK adjacent, pas avec cette option.

Le contrôle autonome `-- --qa --export-smoke` rend une capture, exerce les quatre outils natifs et vérifie le reset et 240/60, puis quitte. Il n’est pas actif en lancement normal. Le package final est testé après décompression dans un nouveau dossier ; preuves et empreintes dans `export-package.json` à côté des autres résultats.

### Reproduire

```powershell
.\Launch-P6A2-Hero-Patch.ps1
.\tools\p6a2\Export-Playtest.ps1
# Blender : régénérer seulement la lampe et les deux accessoires
$blender = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe'
& $blender --background --factory-startup --python-exit-code 1 --python tools/p6a2/build_playtest_desk.py
# QA : tests (headless), visual, display, benchmark, benchmark-native (graphiques)
$godot = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path . --script tests/run_p6a2_playtest.gd -- tests --qa
& $godot --path . --script tests/run_p6a2_playtest.gd -- visual --qa
```

## Retest humain et limites

1. Ouvrir `builds/P6A2-Playtest/ArchaeologyGame.exe`, ou décompresser le ZIP sur un autre PC Windows. Essayer Alt+Entrée, zoom 1×–3× et retour fenêtre.
2. Brosser librement le Soil avant de creuser. Juger les amas, leur échelle et le geste, pas uniquement la luminosité.
3. Pour isoler la correction : F10 compare ancien/nouveau Soil **avec reset de session**, caméra conservée. H ouvre le panneau ; patine ON/OFF ne réinitialise pas. F8 reste le témoin de rendu B ; F11 compare la lampe, sans retuner l’outil.
4. Jouer vers Bone avec les quatre outils. Observer Reveal / Clean / Condition, puis Archive ou Keep Cleaning et Another Block.
5. Répondre : **« Cette terre meuble apporte-t-elle une vraie couche de matière plaisante à nettoyer ? »** Puis : la fiche fait-elle partie de l’univers, l’objectif/fin sont-ils clairs, et le grand écran est-il confortable ? Verdict : accepter la direction / correction ciblée / rejeter.

Limites assumées : Soil moins abondant, durée totale de brossage plus courte ; dépôts encore issus d’une construction déterministe ; certaines limites du maillage peuvent se lire à 3×. Patine inchangée encore visible entre les amas. Jacket/intérieur rectangulaires non corrigés. Lampe partiellement hors champ et accessoires simples, non interactifs. Un B-17, pas de sauvegarde de session, pas de menu/atelier complet. Typographie dépendante des polices Windows avec replis. Tests sur le PC de référence uniquement ; 4K non testé. Seules les captures de tailles de fenêtre précèdent l’ajout textuel « Left click · work » au pied ; les comparaisons Soil et le ZIP final incluent ce rappel.

**Recommandation : soumettre ce candidat au retest Soil et présentation.** La fragmentation est objectivement distincte du simple éclaircissement ; son agrément et sa qualité artistique restent le verdict d’Antoine. Aucun GO P6B ni correction jacket implicite.
