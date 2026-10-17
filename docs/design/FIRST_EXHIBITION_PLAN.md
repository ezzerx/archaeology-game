# Première exposition — plan de discussion

## Intention
La préparation dispose de trois rythmes validés et le suivi d'outil est accepté.
Le prochain levier proposé est de donner une continuité à ce plaisir :
un arrivage intrigue, la préparation révèle une pièce, l'exposition conserve
visiblement le travail et suscite l'envie de revenir.

Antoine souhaite explorer cette boucle, améliorer l'UI, enrichir le décor 3D,
préparer les sons la semaine prochaine avec Claude et ajouter de la musique.
Il demande des tickets distincts et une vision approfondie avant chaque réalisation.
La surprise de découverte reste prioritaire ; la collection soutient la durée.

## Première discussion recommandée
Décrire une session complète et le retour vers une nouvelle préparation, puis
choisir ce qui apparaît dans l'exposition. Pièce dans sa matrice, spécimen extrait
ou autre présentation sont encore des options : ce choix détermine le coût des
assets, les transitions et la nature du souvenir du joueur.

Proposition de périmètre : éprouver cette boucle avec B–17, M–08 et les familles
de préparation existantes avant de produire une collection complète. Le nombre
de pièces, le format de l'exposition et la distribution des préparations restent
à décider. Pas de nouvelle mécanique d'extraction ni de musée explorable implicites.

Le scénario doit préciser ce que le joueur sait au départ, ce qu'il décide,
quand il reconnaît la pièce, comment il choisit de terminer, ce qu'il conserve
et ce qui lui donne envie de choisir la suite. La mise en valeur du 100 % peut
s'appuyer sur les distinctions existantes, sans en faire une obligation.

## Backlog et dépendances
| Ticket | Résultat à définir | Dépendance principale |
|---|---|---|
| [#45 Première exposition](https://github.com/ezzerx/archaeology-game/issues/45) | Scénario complet, format exposé, périmètre et découpage | Discussion de départ |
| [#28 Collection](https://github.com/ezzerx/archaeology-game/issues/28) | Destination visible et personnelle du travail | Choix du format dans #45 |
| [#27 Arrivages](https://github.com/ezzerx/archaeology-game/issues/27) | Anticipation, indices de provenance et arrivée du bloc | Articulation avec #45 / #28 |
| [#46 UI](https://github.com/ezzerx/archaeology-game/issues/46) | Présentation aboutie, lisible et cohérente | Parcours et rôles définis |
| [#47 Décor 3D](https://github.com/ezzerx/archaeology-game/issues/47) | Bureau habité, chaleureux et lisible | Composition et espace de travail |
| [#48 Sons](https://github.com/ezzerx/archaeology-game/issues/48) | Retour tactile des outils et matières | Palette avec Claude la semaine prochaine |
| [#49 Musique](https://github.com/ezzerx/archaeology-game/issues/49) | Identité calme, agréable sur la durée | Coordination avec le mix des effets |
| [#50 Performance](https://github.com/ezzerx/archaeology-game/issues/50) | Réduire les ralentissements au souffle dense | Diagnostic mesuré avant optimisation |

L'ordre recommandé consiste à définir d'abord la destination et la session,
puis à accorder arrivages et collection ; UI et décor servent cette composition.
Sons et musique se cadrent ensemble pour conserver la lisibilité tactile.
Le suivi FPS demeure un sujet distinct, non bloquant pour le cadrage de la boucle.

## Qualité et périmètre
Les caisses précédentes ont été rejetées ; leur implémentation archivée ne devient
pas la base artistique par défaut. Une nouvelle proposition doit montrer matériaux,
lumière, proportions et gestes, pas seulement des rectangles de placement.
Les accessoires ne doivent pas reproduire l'occlusion du bloc par la lampe.

Conserver outils, matières, temps de réponse, qualité des fossiles, sauvegardes,
photos et distinctions. Éviter que l'arrivée ou la collection révèle l'espèce avant
la fouille. Ne pas remplir les transitions d'interactions répétitives sans intérêt.

Pour chaque sujet : problème joueur, exemple de parcours, direction visuelle ou
sonore, exclusions, dépendances et essai humain. Un sujet trop large se découpe
avant réalisation ; le raccordement final de la boucle aura sa mission dédiée
une fois la vision choisie. Les autorisations courantes restent dans
[le statut canonique](../brain/status.md).
