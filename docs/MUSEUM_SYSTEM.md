# Musée et collection

## Cadre diégétique

Le musée n'est plus seulement une méta-progression abstraite : il constitue la **baseline narrative actuelle** du jeu.

Le joueur travaille dans les coulisses d'un musée d'histoire naturelle comme préparateur / restaurateur de spécimens. Les blocs et fragments arrivent dans l'atelier, sont préparés sur la table de travail, puis rejoignent les réserves, la collection ou une exposition lorsque leur préparation le permet.

Le jeu conserve une structure sans avatar contrôlable : la façade, l'atelier, les dossiers et la galerie suffisent à faire exister le lieu.

Transition de mise en scène envisagée : **façade du musée au menu principal → atelier intérieur au lancement → galerie/collection comme destination visible du travail**.

## Specimen Intake — caisses de préparation

La sélection du prochain travail doit être **diégétique et tactile** plutôt qu'un simple menu de niveaux : le joueur choisit une **caisse de spécimen** reçue par le musée.

Chaque caisse possède une étiquette scientifique/logistique qui donne des informations utiles sans révéler exactement ce qu'elle contient :

- site / origine géologique ;
- formation ou région ;
- période estimée ;
- type de matrice attendu ;
- difficulté / besoins de préparation ;
- note du conservateur / provenance ;
- indice de rareté ou de caractère exceptionnel lorsque pertinent.

Le contenu précis reste partiellement inconnu afin de préserver l'anticipation. Le système doit permettre le feeling : **« cette caisse a quelque chose de spécial, j'ai envie de l'ouvrir maintenant »**, sans devenir une lootbox monétisée ni bloquer la progression principale derrière du hasard punitif.

Avant la préparation, une **courte phase d'ouverture de caisse** est une direction canonique à prototyper : enlever sangles/scellés/protections, ouvrir le couvercle, découvrir le bloc et son dossier, puis transition vers la table de préparation. La cérémonie doit rester courte et satisfaisante ; les caisses exceptionnelles peuvent recevoir une mise en scène légèrement plus marquée.

La caisse montrée dans les concepts de façade/musée est une bonne grammaire visuelle pour ce système futur.

## Rôle

Le musée est à la fois le cadre narratif et la méta-progression principale : une sorte de **Pokédex physique** où les découvertes prennent une forme visible. La motivation vient des fragments qui complètent progressivement des expositions, puis donnent une raison de retourner fouiller.

Ce système appartient à une étape après la validation du nettoyage. La v0.1 ne comporte pas de musée complet.

## Musée comme mémoire physique du travail

Le musée doit être une **récompense visuelle permanente** et la mémoire physique du travail du joueur, dans l'esprit de la satisfaction de donation/complétion d'un musée à la *Animal Crossing* : chaque nouvelle préparation réussie doit pouvoir modifier ce que le joueur voit dans la galerie.

Règles de design :

- une pièce acquise apparaît réellement dans l'exposition correspondante ;
- les squelettes restent visiblement incomplets tant que des parties manquent ;
- les emplacements manquants créent naturellement l'envie de compléter sans transformer la galerie en simple barre d'XP ;
- la progression doit être **visible avant d'être chiffrée** ;
- le joueur doit pouvoir regarder le musée après plusieurs heures et reconnaître physiquement le résultat de ses sessions de préparation.

Le musée peut commencer partiellement rempli par des acquisitions historiques afin de donner immédiatement le sentiment d'un lieu existant avant le joueur et de créer des collections déjà entamées. Le degré exact de remplissage sera défini lors du macro game design.

## Navigation confirmée

Une galerie scrollable horizontalement, sans personnage à déplacer. Une grande carte / un panneau central montre l’exposition sélectionnée ; les expositions voisines restent partiellement visibles. Des flèches et / ou une scrollbar permettent de parcourir la collection.

Chaque panneau présente le squelette dans son état réel, l’identité connue du spécimen, les pièces acquises et les **Missing Fossil Parts** avec compteurs.

Catégories possibles, encore non engagées : **Dinosaur Hall, Marine Fossils, Plants & Insects, Ice Age Mammals, Ancient Cultures, Archives**. Ancient Cultures représenterait une extension de contenu ; elle n’étend pas le prototype initial aux artefacts.

## Pièces et assemblage

Chaque squelette est constitué de parties / collectibles réels définis pour le spécimen : **Skull, Teeth / Frill, Ribs, Forelimbs, Hindlimbs / Leg Bones, Vertebrae, Tail**, etc. Les catégories et quantités dépendent du contenu créé ; elles ne forment pas une anatomie universelle.

| Partie | Exemple de compteur de collection |
|---|---|
| Skull | 1 / 1 |
| Teeth | 7 / 8 |
| Ribs | 4 / 6 |
| Forelimbs | 2 / 2 |
| Hindlimbs | 1 / 2 |
| Vertebrae | 6 / 8 |
| Tail | 0 / 1 |

Ces nombres sont illustratifs, pas des quantités anatomiques ni un contenu validé. Un fragment récupéré possède une association au spécimen et à une partie à compléter. La granularité entre fragment et pièce assemblée reste à définir.

Un squelette incomplet doit rester visuellement incomplet. Trouver une nouvelle pièce remplit son emplacement dans l’exposition et actualise les compteurs. Le modèle complet ne doit pas apparaître comme acquis lorsque des pièces manquent. Une éventuelle silhouette de référence devra être clairement distinguée des pièces possédées.

## Parcours d’une nouvelle pièce

1. Révéler et dégager le fragment dans le bloc.
2. Récupérer la pièce et associer son identité / classification au dossier du spécimen.
3. Actualiser la collection sans compter deux fois une même pièce acquise.
4. Montrer l’ajout physique dans le squelette exposé.
5. Actualiser les Missing Fossil Parts et la complétion de l’exposition.

La présentation d’un spécimen encore `Unknown` ou classifié seulement de façon probable devra préserver le mystère. La politique de doublons, le traitement d’une pièce endommagée et le regroupement de plusieurs fragments restent ouverts.

## Indicateurs possibles

- **Collection Progress** : progression de la collection / des pièces possédées.
- **Exhibit Prestige** : qualité ou valeur de présentation d’une exposition, formule à définir.
- **Visitor Rating** : retour éventuel lié au musée, sans engager une simulation de visiteurs.

Seule la collection est aujourd’hui le pilier confirmé. Prestige et rating restent des pistes, sans économie ou simulation imposée.

## Première validation après la v0.1

Relier quelques fouilles à une exposition partielle. Vérifier qu’une nouvelle pièce apparaît au bon endroit, qu’une pièce manquante reste absente et que le joueur comprend ce qu’il peut encore chercher. Valider la motivation avant d’ajouter catégories et statistiques.
