# Profils pour une conversation de game design

Ces deux fichiers ont été fournis par Antoine et conservés à l’identique :

- [Game Designer](game-designer.md) : piliers, boucles, systèmes, progression,
  spécifications et hypothèses à tester.
- [Level Designer](level-designer.md) : composition des blocs de préparation,
  ordre des découvertes, rythme, apprentissage, lisibilité et narration spatiale
  de l’atelier et du musée.

Ce sont des profils de travail à lire explicitement dans une conversation dédiée.
Leur présence dans le dépôt ne crée pas d’agents exécutables et ne lance aucune
mission. Un même assistant peut mobiliser les deux regards ; la délégation à des
sous-agents nécessite une demande explicite d’Antoine.

## Contexte à charger

Suivre [AGENTS.md](../../AGENTS.md) et
[la politique documentaire](../DOCUMENTATION_POLICY.md) :

1. [Statut canonique](../brain/status.md), puis
   [handoff produit](../ORCHESTRATION_HANDOFF.md).
2. Brief et rapport actifs indiqués par le statut ; vérifier les PR concernées
   et les autres travaux ouverts avant de qualifier une fonctionnalité de validée.
3. [Décisions](../brain/decisions.md) et documents produit utiles au périmètre :
   [concept](../CONCEPT.md), [boucle](../GAMEPLAY_LOOP.md),
   [musée](../MUSEUM_SYSTEM.md), [systèmes futurs](../FUTURE_SYSTEMS.md).
4. Les deux profils ci-dessus.

L’ordre de priorité défini par le dépôt reste applicable : dernière instruction
explicite d’Antoine, statut, brief actif, décisions, puis documentation durable.
Les profils apportent des méthodes et des exemples ; ils ne remplacent pas ces
sources. Signaler les écarts entre statut et PR vivantes sans supposer une
validation humaine.

## Adapter les profils au projet

Partir du plaisir de préparer un spécimen, de la découverte scientifique et de
la mémoire visible du travail dans le musée. Conserver la présentation sur établi
et distinguer dégagement, nettoyage et état de conservation.

Les exemples de combat, avatar, monde ouvert, économie monétisée ou rétention
dans les profils ne sont pas des exigences du jeu. Le regard Level Designer
s’applique notamment aux matières, zones, révélations et séquences de préparation,
ainsi qu’à la composition des écrans et des espaces fixes.

Séparer les faits validés, les hypothèses, les alternatives et les décisions
attendues d’Antoine. Marquer les nouvelles valeurs non éprouvées
`[PLACEHOLDER]` ; ne pas requalifier les réglages existants validés.

## Lancer la conversation dédiée

Ouvrir une conversation avec accès au dépôt contenant ces fichiers, puis copier
ce prompt :

```text
Je lance une mission de planification du game design d’ArchaeologyGame.

Lis AGENTS.md, puis suis docs/agents/README.md pour charger le contexte canonique
et les profils docs/agents/game-designer.md et docs/agents/level-designer.md.
Vérifie les PR actives et distingue les éléments validés des travaux en revue.

Mobilise les deux regards en les adaptant au jeu de préparation de fossiles.
Commence par une synthèse concise de l’existant et des décisions ouvertes.
Pose-moi ensuite les questions structurantes nécessaires au cadrage.

Construisons un plan de game design couvrant l’expérience visée, les piliers,
les boucles, la progression, la variété et le rythme des préparations,
l’apprentissage et le lien avec le musée. Distingue acquis, propositions,
hypothèses à tester et décisions à valider ; explique les compromis.

Le résultat attendu est un plan priorisé, avec dépendances, limites et critères
de playtest. Reste en conception : aucun changement de code, production d’assets,
fusion de PR ni lancement de développement. Attends mon accord sur le plan
avant de le transformer en missions exécutables.
```

Les décisions retenues et leur éventuel découpage suivront
[le workflow du dépôt](../DEVELOPMENT_WORKFLOW.md). Ce guide prépare la
conversation ; il ne préjuge pas du contenu du futur plan.
