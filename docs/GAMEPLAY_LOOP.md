# Boucle de jeu et sensation de fouille

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
