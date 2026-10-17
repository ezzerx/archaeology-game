# Musée et collection

## Cadre diégétique

Le musée n'est plus seulement une méta-progression abstraite : il constitue la **baseline narrative actuelle** du jeu.

Le joueur travaille dans les coulisses d'un musée d'histoire naturelle comme préparateur / restaurateur de spécimens. Les blocs/spécimens arrivent dans l'atelier, sont préparés sur la table de travail, puis rejoignent les réserves, la collection ou une exposition lorsque leur préparation le permet.

Le jeu conserve une structure sans avatar contrôlable : la façade, l'atelier, les dossiers et la galerie suffisent à faire exister le lieu.

Transition de mise en scène envisagée : **façade du musée au menu principal → atelier intérieur au lancement → galerie/collection comme destination visible du travail**.

## Arrivages — vision à redéfinir

Le choix du prochain travail doit soutenir l’anticipation et l’identité du musée,
sans révéler le contenu encore enfoui ni ralentir l’accès à la préparation.

La piste historique de caisses physiques et d’une cérémonie d’ouverture n’est
plus une prescription : Antoine a rejeté l’essai réalisé et demande de cadrer
une nouvelle vision lors d’une passe dédiée. Caisses, dossiers, desserte ou autre
présentation restent des options à comparer, sans réalisation automatique.
Les écrans actuels servent d’accès provisoire aux deux blocs jouables.

Les propositions de collection ci-dessous décrivent des intentions de long terme ;
elles ne fixent pas l’ordre des missions ni une autorisation de développement.
Le cadrage global doit préciser leur première traduction jouable.

## Rôle

Le musée est à la fois le cadre narratif et la méta-progression principale : une sorte de **Pokédex physique** où le travail du joueur prend une forme visible. La motivation vient de la transformation durable des expositions/collections, puis donne une raison de retourner préparer de nouveaux spécimens.

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

## Vision de travail acceptée — 17 octobre 2026
Antoine valide provisoirement la proposition, pour des essais suivis d'ajustements.

- Une petite galerie de musée en 3D, sans avatar, parcourue par des vues composées et un déplacement horizontal.
- B–17 et M–08 présentés dans leur matrice, sur des supports inclinés adaptés ; bois patiné, fonds sombres, cartels ivoire et lumière chaude lisible.
- Inspection rapprochée et variation d'angle limitée, compatible avec les assets de préparation ; pas d'inspection à 360° implicite.
- À terme, conserver réellement le travail du joueur : matière restante, nettoyage et dégâts, avec distinction discrète pour la finition intégrale.
- Emplacements conçus pour les pièces ; éventuel choix entre supports compatibles, sans système de placement libre de mobilier.
- Parcours visé : arrivage avec indices larges → préparation → fin choisie → installation → admiration → nouvel arrivage.
- Première expérience fondée sur les deux spécimens et les trois familles existantes ; extraction et squelette monté restent des pistes ultérieures.

L'accord porte sur une direction à éprouver, pas sur une qualité artistique finale.

Catégories possibles à long terme : Dinosaur Hall, Marine Fossils, Plants & Insects, Ice Age Mammals, Ancient Cultures, Archives. Cette liste n’engage pas de nouveaux contenus pour le premier essai.

## Pistes d’assemblage ultérieures

Les fragments et armatures ci-dessous sont des possibilités de long terme. La première exposition retient les spécimens dans leur matrice, sans extraction ni montage.

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


## Destination du spécimen — question macro encore ouverte

Le prototype P5 n'a pas tranché le modèle final de récupération.

Le futur Macro Game Design doit comparer :
- **in-matrix** : le bloc/slab préparé devient l'objet muséal ;
- **extraction** : certaines pièces sont retirées de la matrice ;
- **mounted skeleton** : des éléments récupérés complètent progressivement une armature ;
- **hybride** : la destination dépend du type de spécimen.

Une courte phase de conservation/finition/mounting reste une piste forte pour relier atelier et galerie, mais elle ne doit pas devenir une seconde session longue après chaque préparation.

Les anciennes mécaniques Forceps/fragments de P5 sont historiques et ne définissent pas le modèle musée final.
