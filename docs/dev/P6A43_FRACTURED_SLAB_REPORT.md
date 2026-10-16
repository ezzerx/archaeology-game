# P6A4.3 — Plaque de grès fracturée

## Brief autorisé

Après le verdict P6A42 (géologies différentes mais même stratégie), Antoine
soutient un essai de plaque fracturée : conserver le feeling des outils,
fissures lisibles et détachement satisfaisant. Un joint accessible au Pick doit
récompenser des attaques espacées, sans ordre de points obligatoire ; le Chisel
continue son érosion native. Une seule plaque, pas de nouveau matériau ni outil.
B-17, occultation, lumière et tactile acceptés restent la référence.

Le candidat repart de P6A41, sans le sélecteur des géologies P6A42. Une forme
façonnée indépendante de Bone porte le grès affleurant et les fissures. Le retrait
reste logique (hauteurs CPU/GPU et picking communs), borné par les plafonds Bone.
La pièce détachée doit venir de la matière réellement restante, sortir du champ
de travail et disparaître au reset. Le test humain décidera si cela crée un vrai
choix, au-delà d’un effet spectaculaire.

## Candidat et geste

Scène `scenes/p6a43_fractured_slab.tscn`, entrée normale `Launch-Game.ps1`.
Le bloc repart de la référence de bords bruts P6A41, avec une seule plaque de
~17 × 11 cm au nord du centre. La couverture Soil et les hauteurs initiales sont
byte-identiques à cette référence. Seule l’interface Clay/Sandstone change sur
19 246 cellules : grès affleurant dans le polygone, transition géologique courte
à l’extérieur. Aucun contour ou placement construit d’après les os.

Brosser si la fissure est couverte, puis attaquer au Pick des endroits espacés du
joint. Les lignes sont irrégulières, ramifiées et localement plus ouvertes après
un vrai contact. Trois attaques distinctes peuvent libérer la plaque ; pas de
points nommés ni d’ordre obligatoire. Refrapper le même trou n’accumule pas le
bonus. Une notice courte accompagne la première ouverture, puis le détachement.
R restaure l’essai. Le sélecteur des trois géologies n’est pas dans cette scène.

Le Chisel conserve l’érosion native. Quand plus de 55 % de la plaque a déjà été
retiré, le restant se libère aussi : pas de bloc indestructible forçant le puzzle.
Cette borne et la règle des trois contacts sont des hypothèses de ce spike,
pas des constantes validées pour la production.

## Retrait et feedback

La surface candidate hérite du noyau et appelle d’abord son impact inchangé.
L’éligibilité du joint est photographiée avant l’impact : toucher une fissure
encore sous Soil ne donne pas de crédit prématuré. Le bonus intervient ensuite,
sans deuxième consommation de cadence ni deuxième décision de dégâts Bone.

Le retrait conséquent est réel : au plus 10 863 cellules de plaque, jusqu’à
12,24 mm sous le sommet, toujours limité à la matière restante. La borne de
sécurité conserve au moins 1,02 mm au-dessus d’un plafond Bone si nécessaire.
Le bonus n’expose donc pas d’os par lui-même ; le Pick peut continuer normalement.
Aucun remplissage de trou, déplacement de plafond ou changement des composants.
Les quantités Soil portée / Stone sont comptées séparément. Le résidu des petits
impacts natifs conserve son fonctionnement. La plaque emporte la matière du bonus
sur l’établi plutôt que de la convertir en milliers de miettes.

La pièce est construite à partir de la matière encore présente, échantillonnée
sur une grille de 3 texels ; les trous complètement retirés sont omis. 5 164
triangles dans le parcours témoin, textures existantes et copie figée des fissures.
Elle se soulève, pivote et tombe en .58 seconde entièrement hors de la fouille,
sans collision de picking. Son ombre provient uniquement de ce morceau visible
réellement retiré. Une seule pièce, libérée immédiatement au reset ; pas de
simulation ou reconstruction au repos. Les cues sonores existants des impacts
sont réutilisés via leur feedback courant, sans nouvel asset ni passe sonore.

## Isolation et réglages

Une petite factory dans `ExcavationBlock` retourne le `WorkingSurface` canonique
par défaut. Seul le bloc P6A43 instancie la sous-classe qui observe les impacts de
la plaque. Les autres scènes continuent à utiliser le noyau précédent.

Aucun outil ou preset n’est édité. Le Chisel accepté en runtime reste rayon 26,
puissance .84, falloff 2.25, cadence héritée ; Pick, Brush, Blower, nettoyage court,
dégâts localisés, F6/F7, éclairage et art B-17 sont conservés. Le premier oracle
comparait le Chisel aux anciens defaults P4 (22/.64) ; il a été corrigé pour
vérifier les réglages runtime acceptés, sans changer le candidat.

## Vérification finale

**548 contrôles, zéro échec** : candidat 150, rendu natif 17, référence P6A41 110,
P1 52, P5 128, miettes P4V2 91. Godot 4.7.2 stable / Compatibility / RTX 5080.
JSON et sept captures dans `docs/dev/evidence/p6a43/`.

- Profils initiaux, quantité de Soil, champ/contacts/plafonds B-17 et réglages des
  outils contrôlés. Transition géologique bornée ; aucun Bone initialement exposé.
- Contacts sur Soil, hors fissure, outil de puissance nulle et répétitions au même
  point ne donnent aucun raccourci. Le Pick ordinaire continue son travail local.
- Trois permutations de trois contacts via le vrai controller/horloge/repicking
  déclenchent une seule libération de 10 863 cellules. Comparaison au dernier
  état natif avant bonus : seuls les texels de la plaque baissent ; aucun texel
  n’augmente, aucune exposition ou Condition Bone ne change pendant le bonus.
- Le parcours Chisel témoin libère par érosion après 31 impacts distribués, sans
  crédit de fissure. Ce nombre n’est ni optimal ni une mesure de durée humaine.
- Pièce créée avec vraie matière restante, trajectoire hors domaine, absence de
  collider, reset exact des états/texture/pièce et zéro upload de fissures au repos.
- Matrice intacte pixel-identique avec/sans source 3D ; après retrait de la plaque,
  crâne, colonne, côte et patte enterrés gardent les mêmes pixels sans le modèle.
  Fissures visibles sur le vrai grès, animation/ombre natives capturées.
- Les contrôles communs conservent exposition complète au Pick et préparation
  100/100 par le fixture de revue hérité (Soil déjà retiré, nettoyage final de
  fixture). Ce n’est pas un nouveau playtest humain complet depuis le bloc intact.

## Limites et revue

La règle de libération est façonnée, sans solveur physique de fracture. La grille
visuelle du morceau est plus grossière que celle du terrain. Le commit et la
création de pièce prennent ~16–17 ms dans le harnais headless : un coût ponctuel,
pas une preuve de maintien à 240 FPS. Cap 240 / physique 60 Hz conservés ; pas de
nouvelle mesure soutenue isolée, les fenêtres de préparation antérieures restant
ouvertes. La génération du morceau au moment du retrait devra être mise en cache ou
optimisée avant une généralisation à des plaques plus nombreuses.

À juger humainement : lisibilité des joints, plaisir du détachement, intérêt de
choisir le Pick avant les os et caractère naturel des attaques espacées. Si cela
ressemble à trois clics imposés ou à un bonus sans lecture de matière, le spike
n’aura pas prouvé le comportement recherché. Pas de déploiement généralisé,
nouveau catalogue ou validation artistique finale déduits des tests.



## Livraison de revue

Source `3d288c6`, branche `codex/p6a43-fractured-slab`,
[PR #17 DRAFT](https://github.com/ezzerx/archaeology-game/pull/17) directement sur main.
#16 est remplacée sans fusion ; ses sources/scènes et son verdict humain sont
conservés. Aucun merge automatique. Les préparations des fenêtres précédentes
sont préservées.

`Launch-Game.ps1` a ouvert « B-17 · Grès fracturé » avec Godot 4.7.2 /
Compatibility, fenêtre répondante et stderr vide. Ce lancement ne constitue pas
un verdict humain sur la nouvelle interaction.


## Retour humain — principe encourageant, intégration à améliorer

Antoine a essayé la plaque : ce n’est pas parfait, mais elle incite à faire autre
chose qu’utiliser uniquement le Chisel. **Le principe de variation des gestes est
encourageant**, à la différence de l’essai de géologies P6A42. Cela ne valide pas
un équilibrage final ni une diversité de sessions sur la durée.

L’intégration visuelle paraît encore imparfaite. La direction appréciée est de
répartir ces situations de manière variable dans les blocs, puis de les combiner
avec d’autres fonctionnalités qui apportent de la variété. Le mélange est une
piste de production ; fréquence, contraintes de placement, autres comportements
et forme finale restent à définir. Les seuils et la plaque façonnée du spike ne
sont pas validés comme standard à dupliquer partout.
