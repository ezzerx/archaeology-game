# Boucle de jeu et sensation de fouille

> Ce document décrit le **game design**, pas le statut de développement.
> Pour la phase active et la prochaine action autorisée, lire `docs/brain/status.md`.

## Boucle prototype validée

Le joueur est préparateur/restaurateur dans un musée d'histoire naturelle.

Boucle actuelle :

> **bloc confié → excavation / révélation → nettoyage → standard musée atteint → Keep Cleaning ou Archive Specimen → prochain bloc**

Grammaire outils actuelle :

- **Soft Brush** : Soil / saleté de surface, Bone Surface Film et mess brushable ;
- **Chisel** : excavation bulk Clay/Sandstone et fracture ;
- **Air Blower** : évacuation du mess libre ;
- **Precision Pick** : finition structurelle précise près des os.

Trois concepts Bone restent séparés :

> **Exposure ≠ Cleanliness ≠ Condition**

Le prototype utilise un standard musée global et une maîtrise optionnelle, mais ces seuils sont des valeurs de prototype. Les détails de phase et d'implémentation vivent dans les briefs/reports actifs.

### Soil — thin overburden direction accepted

Le test humain P6A1.5 préfère désormais :

> **fine couche de saleté / overburden à brosser → matrice Clay/Sandstone patinée → excavation structurelle**

Le Soil suit le relief de la matrice au lieu de créer un plafond plat indépendant. Les valeurs exactes d'épaisseur/couverture restent provisoires.

La prochaine question de fond n'est plus le Soil lui-même mais la **géométrie initiale de la matrice**, encore trop plane. P6A1.6 doit tester un relief naturel déterministe avant le lookdev P6A2.

## Boucle macro cible

Après validation de la V0.1, la boucle complète visée devient :

> **choisir une caisse de spécimen → lire son étiquette / anticiper → ouvrir la caisse → préparer le bloc → classifier / récupérer → archiver → voir le musée évoluer → choisir la prochaine caisse**

La sélection par caisse et la galerie vivante sont des directions macro-game-design canonisées, pas du scope P5 actuel.

## Boucle principale

| Étape | Action et retour attendu |
|---|---|
| Fouille / nettoyage | Choisir un outil et travailler les couches visibles du bloc |
| Découverte | Révéler une nouvelle forme osseuse avec un retour audio / visuel |
| Identification / classification | Faire évoluer le dossier du spécimen à partir des indices révélés |
| Récupération | Dégager puis enregistrer les fragments récupérables |
| Collection | Mettre à jour les pièces acquises et la complétion du spécimen |
| Musée | Ajouter les pièces trouvées à l’exposition visuellement incomplète |
| Nouvelle fouille | Revenir à un nouveau bloc pour poursuivre la collection |

La découverte, l’identification et la récupération sont distinctes : voir un os ne signifie pas avoir déjà récupéré toute la pièce. Les règles exactes de récupération seront testées après le cœur de nettoyage.

## Matériaux et couches

Séquence conceptuelle : **terre meuble → argile compacte → grès / roche tendre → roche dure → fossile**. Le fossile est la cible à dégager et préserver, pas une couche à effacer. La composition d’un bloc pourra varier ; le MVP n’en utilise que trois matériaux.

| Matériau | Résistance et réaction recherchées | Retours sensoriels | Outils candidats |
|---|---|---|---|
| Terre meuble | Faible résistance, retrait progressif en grains | Frottement doux, poussière légère | Soft brush, air bulb / blower pour les résidus |
| Argile compacte | Raclage, morceaux qui se détachent | Frottement dense, petits arrachements | Scraper, chisel ; water mister à tester |
| Grès / roche tendre | Usure, fissuration puis petits éclats | Tics et craquements distincts | Chisel, dental pick près des os |
| Roche dure | Forte résistance, rupture localisée | Impacts nets, éclats plus lourds | Pick, chisel |
| Fossile exposé | Contact identifiable, conservation éventuelle | Son différent et signal local lisible | Fine brush, dental pick, stabilizer resin |

Ces associations sont des hypothèses de réglage, pas une simulation scientifique validée.

### Progression de la matière

Chaque zone conserve une profondeur ou résistance résiduelle. Les états visuels suivent : **intact → abîmé → fissuré → presque cassé → retiré**. Les manifestations s’adaptent au matériau : la terre s’amincit et se désagrège, la roche montre des fractures.

Un passage d’outil produit un effet proportionnel à sa compatibilité et à la résistance locale. Une zone retirée dévoile la couche suivante à cet endroit. Des masks / textures peuvent représenter cette progression ; une grille invisible est une piste pour préserver des contours pixel art intentionnels.

## Outils envisagés

| Outil | Usage envisagé | Arbitrage à explorer |
|---|---|---|
| Soft brush | Retirer la terre et nettoyer une zone large | Geste doux, peu efficace sur roche |
| Fine brush | Nettoyer précisément près des os | Précis mais plus lent |
| Air bulb / blower | Évacuer poussière et résidus | Rapide sur résidus, inefficace sur roche intacte |
| Chisel | Entamer et fragmenter roche tendre / couches compactes | Efficace, risque éventuel sur os exposé |
| Pick | Casser la roche dure | Rapide, risque élevé près des os |
| Dental pick | Dégager de petites zones autour des fragments | Contrôle fin, retrait lent |
| Scraper | Racler les couches compactes | Surface de travail et précision à régler |
| Water mister | Humidifier ou préparer une surface | Effet sur résistance et lisibilité à tester |
| Micro vacuum | Aspirer localement grains et poussière | Précision et complémentarité avec le blower à tester |
| Stabilizer resin | Stabiliser / préserver les pièces fragiles | Système de condition encore optionnel |

Aucun rayon, niveau de dommage ou temps de traitement n’est fixé. La v0.1 ne retient que trois outils ; le reste constitue un catalogue de pistes.

## Game feel : priorité absolue

Le geste doit déclencher une réaction immédiate et lisible : animation de l’outil, usure locale, particules, poussière, petits éclats et son propre au matériau. La résistance se ressent par le rythme des transformations, sans demander une interface technique au joueur.

Le contact avec un os produit un retour différent. La révélation d’un nouveau fragment reçoit une récompense discrète, distincte du bruit de travail répétitif. Éviter que les particules cachent les premiers indices ou que chaque passage rejoue la notification de découverte.

Scénario de référence : **brossage → minuscule courbe blanche → nouveaux passages → forme osseuse reconnaissable → retour de découverte → envie de poursuivre**.

Les retours de caméra, s’ils sont testés, restent légers et compatibles avec la vue strictement du dessus. L’atmosphère doit soutenir la concentration ; les sons de matière restent utiles et audibles.

## Mystère, condition et progression

Un dossier peut passer de `Unknown` à `Possible classification: Theropod`, puis à une identification précise. Il ne faut pas obligatoirement afficher le fossile complet ou son nom avant la fouille. Le seuil de classification et la forme de l’interaction restent à définir.

La fragilité est une option à prototyper : un outil agressif pourrait endommager un os exposé ; les outils fins et la résine pourraient préserver sa condition. Ne pas transformer cette piste en pénalité permanente avant de vérifier son effet sur le plaisir.

Séparer la jauge de nettoyage du bloc, la récupération effective de fragments et le pourcentage de complétion au musée. Leurs valeurs ne mesurent pas la même chose.
