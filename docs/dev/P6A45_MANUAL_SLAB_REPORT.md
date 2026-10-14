# P6A4.5 — Lumière, fractures brutes et levier manuel

## Brief autorisé

GO explicite d’Antoine : lumière plus uniforme, fissures plus brutes et retrait
manuel au Pick avec un petit geste de levier. Conserver les outils, interactions
validées, B-17, l’ambiance chaude et la protection des os encore enterrés.

Le retour P6A44 signale une amélioration visuelle partielle, des joints encore
lisses et un retrait automatique peu satisfaisant. L’incitation à changer d’outil
reste encourageante ; elle ne valide ni l’art final ni l’extraction automatique.

## Candidat jouable

Scène `scenes/p6a45_manual_slab.tscn`, entrée normale `Launch-Game.ps1`.
Les scènes historiques P6A43/P6A44 restent accessibles sans changement.

1. Dégager et travailler des joints au Precision Pick (4).
2. La plaque prend du jeu, les joints travaillés s’ouvrent ; une consigne signale
   le moment où une prise devient possible.
3. Maintenir le clic gauche sur un joint ouvert ou un bord accessible, puis faire
   un petit glissé vers le bas de l’écran. La pointe reste dans le joint et le
   manche bascule ; la plaque se soulève progressivement.
4. Un geste complet décolle le morceau, puis une courte animation le dépose hors
   du bloc. Relâcher avant la fin repose la plaque sans retirer de matière.

Le seuil du geste est 4 % de la hauteur du viewport (~29 pixels dans une fenêtre
haute de 720 pixels), indépendant du zoom. Ce seuil reste un réglage de prototype.
Le clic immobile ne retire rien ; le mouvement inverse réduit le soulèvement.
La même pression ne produit aucun impact natif supplémentaire pendant le levier.
Changement d’outil, perte de focus/sortie, caméra, UI, resize, reset ou session
bloquée annulent la capture. La réussite consomme le geste, sans coup résiduel.

## Lumière répartie

La source reste fixe, centrée, et la lampe décorative reste hors du bloc. Le Spot
chaud est élargi de 50° à 70°, son énergie passe de 1.2 à .28 et les atténuations
angulaire/distance à .15/.5. La lumière directionnelle existante passe de .2 à .65 ;
le rebond passe de .3 à .1. Températures, ambiante et pose restent conservées.
La même répartition est réappliquée après un comparatif de look ou de lampe.
Aucune source mobile ni nouvelle interaction de lampe.

Le contrôle vise désormais le centre et les bords : neuf patches mats à hauteur
du bloc, x = -.42 / 0 / .42 m, z = -.24 / 0 / .24 m, 25 pixels par patch.
L’étendue relative (max-min)/max passe de **34.76 % à 10.19 %**. Le centre passe de
.3400 à .2607 de luminance écran ; les extrémités les plus sombres restent lisibles.
Ce témoin isole l’éclairage de la texture et des faces inclinées ; il ne promet
pas une luminosité identique sur tous les reliefs. 4 633 pixels du témoin B-17
préparé sont encore assombris de plus de .025 par les seules ombres Bone exposées.

## Fractures plus brutes

Les courbes lissées sont remplacées par des segments anguleux à plusieurs échelles,
avec ramifications courtes, largeur variable (~.7–1.95 texel) et profondeur
variable (.65–1.25 mm). Le tracé utilisé pour le relief, l’atlas et les prises reste
commun ; les repères de travail existants sont préservés. La coloration du joint
varie et ses lèvres suivent le relief réel plutôt qu’un trait uniforme.

Le contour et les langues d’argile de P6A44 restent conservés : 10 860 cellules,
4 571 couvertes et 6 289 affleurantes ; 792 portent un sillon significatif. Le Clay
remplit toujours les fissures cachées. La quantité de Soil et les limites locales
sont contrôlées ; aucune forme ne consulte la position des os.

## Extraction et état de préparation

Un acteur et un controller propres à P6A45 ajoutent l’état « mobile ». Trois
contacts Pick réellement exposés et distribués rendent la plaque mobile, sans
la retirer. L’érosion au Chisel reste possible et peut aussi rendre le restant
mobile ; elle ne lance plus automatiquement une plaque. Le retrait final exige
une prise au Pick sur du grès déjà accessible, jamais à travers Clay/Soil.

Avant le décollement, le soulèvement est une prévisualisation positive sur la
matrice existante, jusqu’à ~4.7 mm : pas de doublon de mesh, de matière supprimée
ou de Bone déplacé. Le picker reste natif et aucune fouille ne s’exécute pendant
cette capture. L’annulation ramène la présentation au repos sans écriture d’état.

Au seuil manuel, la matrice réellement restante est retirée une seule fois avec
les plafonds de protection existants. Le mesh continu P6A44, ses trous, couches,
textures, réception/projection d’ombres et cache sont conservés. La dépose assistée
reste de .58 s ; elle suit la décision manuelle de décoller. L’événement de retrait
est une action distincte, sans réutiliser le volume du dernier coup natif.

## Vérification

**671 contrôles, zéro échec** : candidat 202, natif 32, référence P6A44 166,
P1 52, P5 128 et miettes P4V2 91. Quinze captures natives générées ; neuf
comparaisons et étapes représentatives sont conservées dans les preuves du dépôt.

Les commandes utilisent Godot **4.7.2 stable**, Compatibility / RTX 5080 pour le
rendu natif. Cap 240 FPS / physique 60 Hz conservés. Les preuves et captures retenues
sont dans `docs/dev/evidence/p6a45/` ; les sorties complètes sont générées sous
`work/test-logs/p6a45/` par `tests/run_p6a45_manual_slab.gd` (`tests` / `visual`).

Les contrôles comprennent : invariants hérités de B-17, occultation/source/contacts,
Brush courte et dégâts localisés, couverture Clay réelle, volumes retirés, normales,
pose hors domaine et reset ; entrée souris via le viewport, états intermédiaires,
annulations réellement capturées, absence de répétition d’impact et commit unique.
La prévisualisation du levier et le retrait sont également comparés avec/sans
source Bone au renderer natif ; le joint sous argile ne se révèle pas via l’atlas.

Deux oracles ont été corrigés pendant le travail : un proxy de Brush polluait un
patch du témoin neutre, et un panneau UI de test libéré en fin de frame interceptait
les clics des scénarios suivants. Les captures de lumière masquent explicitement
les proxies ; le panneau éphémère est retiré avant le scénario suivant, qui doit
prouver qu’il capture réellement un geste avant de tester son annulation.

## Limites et revue humaine

Une plaque façonnée, pas de solveur de fracture ni de placement aléatoire. La prise
reste un geste guidé et la dépose finale assistée. La prévisualisation attachée est
un déplacement visuel borné, pas une simulation rigide ou une nouvelle surface CPU.
La géométrie du morceau reste à la résolution P6A44. Commit ponctuel ~20–21 ms dans
le harnais headless, sans nouvelle mesure soutenue isolée de 240 FPS.

À juger humainement : lumière assez homogène tout en gardant le relief, fractures
assez naturelles et lisibles, prise au Pick facile à découvrir et agréable, petit
geste suffisamment direct. Les contrôles ne valident pas ces qualités artistiques
ou tactiles. Aucun merge automatique, nouveau catalogue ou Sound Design.


## Livraison native

`Launch-Game.ps1` ouvre « ArchaeologyGame — B-17 · Levier au Pick » avec Godot
4.7.2 / Compatibility. Fenêtre répondante, stderr vide au lancement. Les deux
préparations précédentes restent ouvertes ; aucun reset ou arrêt de leur état.
Le lancement ne constitue pas la validation humaine du geste ou de l’art.
