# Musée et collection

## Rôle

Le musée est la méta-progression principale : une sorte de **Pokédex physique** où les découvertes prennent une forme visible. La motivation vient des fragments qui complètent progressivement des expositions, puis donnent une raison de retourner fouiller.

Ce système appartient à une étape après la validation du nettoyage. La v0.1 ne comporte pas de musée complet.

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
