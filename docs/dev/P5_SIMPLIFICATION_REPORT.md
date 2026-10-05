# P5 — Session simplifiée, carte unique et85/95

> **Correction courante :** [garde anatomique65 % et Condition qualitative](P5_COVERAGE_CARE_REPORT.md), après le retour humain4. Les résultats ci-dessous restent ceux de cette ancienne livraison.

2026-10-05 · `prototype/p5-loop-progression` · [PR #8 DRAFT](https://github.com/ezzerx/archaeology-game/pull/8).

**Livré pour retest ; P5 toujours non validé humainement. Aucun merge ni P6.**

Entrée documentaire : `351cb1f`. Code/tests : **`19b8ec49395e18378af4996788c90807c31af13d`**. La dernière section85/95 du [brief humain](P5_HUMAN_CORRECTION_BRIEF.md) et la demande explicite d'Antoine prévalent sur les anciennes règles à trois objectifs,90/90 ou étoiles par composant. La modification locale préexistante de `project.godot` reste hors commits. Les décisions documentaires de `main@56dad72` (ouverture tactile des caisses et destination musée à concevoir plus tard) sont intégrées à la branche P5 ; conflits documentaires résolus en conservant les deux historiques. Aucun changement de code supplémentaire ni fusion de la PR.

## Parcours livré

Une carte224 px en haut à gauche, dans la marge grise à la vue d'ensemble. Elle montre B-17, « Prepare the specimen », **Reveal skeleton** et **Clean fossil**, avec seulement deux barres. À format plus étroit, même ancrage et fond translucide. Toolbar centrée en bas : Brush / Chisel / Blower / Pick. Aucun dossier droit, composant, Condition ou fragment dans le HUD normal.

- **85/85 global** : état acquis « ✓ Specimen prepared », « Ready to archive. », « Further preparation is optional. ». Archive Specimen et Keep Cleaning apparaissent dans la même carte. Aucun arrêt/modal ; les outils restent actifs.
- **95/95 global** : une seule étoile persistante « ★ Fine Preparation », bref éclat doré et confirmation sonore calme. L'indication « Optional: both bars to95% » n'apparaît qu'après completion. Aucun prérequis de Condition ; aucun bonus supplémentaire à100%.
- **Archive** : seul modal, court et positif. « ✓ Specimen archived », « Museum records updated. », étoile seulement si acquise, puis **Prepare Another Block**. Les outils sont alors bloqués.
- **Another Block / R** : reset de la session, terrain, film, protections, étoiles, signaux visuels/sonores et métriques. Même B-17 déterministe pour P5.

La progression observe les compteurs anatomiques existants et ne recalcule rien au repos. Le ratio de propreté peut baisser en révélant de nouveaux os sales ; completion et étoile restent acquises. Classification interne monotone avec notice transitoire de3,2s ; Condition reste active et consultable en F1. Les snapshots de completion/archive sont distincts et figés. Keep Cleaning enregistre le clic ; une poursuite directe sans clic reste possible et se lit dans les actions supplémentaires. Les actions comptent les impacts/ticks appliqués, pas les clics humains.

L'expérience fragments/Forceps est conservée **dormante**, sans génération de fragments, plateau, outil5 ni coût de vérification dans une partie normale. Seul le test historique active explicitement son champ et ajoute son outil. Aucun redesign de récupération.

## Vérification réalisée

Godot4.7.2 stable / Compatibility OpenGL3.3, RTX5080, Ryzen7 9800X3D, viewport1920×1080. Cap240 FPS / physique60 Hz inchangés.

| Vérification | Résultat |
|---|---:|
| Régressions P0–P4 uniques | 1 895 contrôles, zéro échec |
| P5 actif : limites84,99/85 et94,99/95, événements uniques, reset, archive, film | 83 contrôles, zéro échec |
| Expérience fragments isolée : plafonds, READY, entrée souris, retour/dépôt/reset | 39 contrôles, zéro échec |
| Rendu/UI : clics réels, marge, deux archives, reset,1280×720 et4:3 | 59 contrôles, zéro échec ;12 captures |
| Performance :11 charges ×1×/3×,6s chacune | 22 scénarios /90 contrôles, zéro échec |
| Oracle GPU Bone, zoom1×/2×/3× | 194 955 pixels, textures exactes, zéro échec |

**2 017 contrôles fonctionnels** au total ; répétitions déterministes interprocessus également vertes. Les ressources outils, BoneFilm, FossilState, WorkingSurface, géologie, shaders et caméra P4 ne sont pas modifiés par cette passe.

Performance mesurée : **239,68–239,87 FPS**, minimum sur1s **238,99 FPS**, pire frame **11,035ms**, pire P95 **8,503ms**. Coût maximal observé : session133µs, refreshUI1,061ms (archive). Les scénarios couvrent Soil/Clay/Sandstone/Pick/Blower/film, mises à jour des barres, transitions85/95, Keep Cleaning et entrée d'archive. Les fixtures de préparation sont hors mesure ; les transitions85/95 mesurées sont provoquées par un vrai Brush à60Hz sur un film initialisé près du seuil, vérifié contre un oracle cellule par cellule.

Les pourcentages affichés sont tronqués pour ne jamais annoncer85/95 avant le vrai seuil. Une valeur entièrement nettoyée peut être99,999998% en calcul flottant et afficher99% ; cela n'ajoute aucun objectif ni récompense à100%, et l'autorité du film P4 est conservée.

Commandes reproductibles : `tests/check_p5.ps1 -GodotBin <Godot4.7.2> -Graphical` ; oracle Bone supplémentaire : `--script res://tests/run_p3_benchmark.gd -- --gpu-only`.

Preuves : [fonctionnel](evidence/p5s-tests.json), [expérience historique](evidence/p5-fragment-experiment.json), [UI](evidence/p5s-visual.json), [performance](evidence/p5s-benchmark.json), [oracle GPU](evidence/p5s-bone-gpu.json). Les anciens rapports/captures P5 et P5c restent historiques.

## Captures de contrôle

[Départ](evidence/p5s-01-start.png) · [Prêt à archiver](evidence/p5s-04-ready.png) · [Étoile globale](evidence/p5s-06-fine.png) · [Archive avec étoile](evidence/p5s-07-archive-fine.png) · [Archive sans étoile](evidence/p5s-09-archive.png) · [Format étroit](evidence/p5s-11-narrow.png).

Ces captures utilisent des fixtures de terrain pour vérifier rapidement les états UI ; elles ne constituent pas une session humaine ni une validation du plaisir de jeu.

## Retest humain — lancer et jouer, sans brief ni coordonnées

1. Est-ce que je comprends immédiatement quoi faire ?
2. Le fossile domine-t-il visuellement l'interface ?
3. À85/85, est-il évident que je peux arrêter ?
4. L'étoile95% me donne-t-elle envie de continuer, sans m'y obliger ?
5. Archive est-elle une fin évidente et satisfaisante ?
6. Est-ce que je comprends qu'un autre spécimen vient ensuite ?

**STOP pour ce retest.** La compréhension et l'envie libre de poursuivre restent à valider par Antoine ; les tests automatiques ne franchissent pas ce gate. Aucun musée persistant, nouveau contenu, P6 ou retuning P4.
