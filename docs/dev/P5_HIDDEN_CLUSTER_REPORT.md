# P5 — Garde des amas osseux cachés

2026-10-05 · branche `prototype/p5-loop-progression` · PR #8 DRAFT. Code et tests : `d8fad43`. Base de correction : `378336a`.

La décision Human test5 remplace la garde65 % par composant. Ce rapport devient la source courante ; les seuils musée85/85, Fine Preparation95/95, Condition et toute l’interface restent inchangés. Aucun merge/P6 ; validation humaine encore attendue.

## Changements exacts

- Nouveau `scripts/hidden_bone_coverage.gd` : ensemble caché incrémental et parcours des régions.
- `scripts/preparation_rules.gd` : suppression du minimum65 % ; ratio centralisé et arrondi du seuil.
- `scripts/preparation_session.gd` : garde cachée différée/cachée, maximum dans les snapshots et reset.
- `scripts/prototype_main.gd` : maximum caché en F1 uniquement.
- Fixtures/tests/harness P5 : topologie, frontières, fragments exclus, cas humain et mesures graphiques.

Les ressources outils, shaders, terrain, géologie, FossilState, BoneFilm, débris, classification, UI et Condition ne changent pas. La modification locale préexistante de `project.godot` reste hors commits.

## Algorithme exact

`HiddenBoneCoverage` construit une fois la liste des cellules du `FossilField` principal dont `component_ids != NONE`. Les fragments expérimentaux ne font pas partie de ce champ. Une liste dense et un tableau de positions permettent de retirer chaque cellule au signal `bone_cell_exposed`, en temps constant par échange avec le dernier élément. Aucune modification de terrain, film ou exposition.

Après une action d’exposition, `PreparationSession` regroupe les signaux existants. Seulement à partir de85 % d’exposition globale, une garde sale est recalculée : parcours en largeur déterministe de chaque région cachée, connexité **8 voisins immédiats**, limites x/y explicites, aucun pont/dilatation. La taille maximum est mesurée exactement, sans additionner les régions disjointes. File et marques de visite sont préallouées ; aucune récursion.

Le calcul parcourt au maximum4 843 cellules cachées au premier seuil85 % (chacune au plus une fois, au plus8 voisins), puis moins au fil des révélations. Les marques préallouées de la grille sont remises à zéro en bloc ; aucune recherche dans les32 290 cellules osseuses à chaque frame. Initialisation/reset reconstruisent la liste complète, hors fouille. Nettoyage, Condition, caméra et repos ne relancent aucun parcours. En dessous de85 %, le maximum est inconnu (`-1` en debug), la garde reste non acquise. Reset rétablit exactement cet état.

Readiness exige85/85 ET maximum caché strictement inférieur au seuil. La completion reste acquise : révéler ne peut qu’enlever/diviser un amas, jamais en créer un plus grand. Fine Preparation est acquise indépendamment à95/95, même si un amas bloque encore l’archive ; sa présentation reste celle de l’interface précédente. Aucune modification de `preparation_ui.gd`.

## Géométrie et calibration

Le masque natif B-17 comporte19 régions connectées, qui ne coïncident pas avec les quatre noms anatomiques. Le bas de jambe forme un amas indépendant de1 983 cellules (rectangle586,420–674,500) ; le pied, un autre de1 328 cellules (590,503–678,547). Les lacunes naturelles restent intactes. La connexité8 simple suffit pour détecter le pied humainement manquant à95,887272 % global ; aucune tolérance spatiale ajoutée.

Seuil final centralisé dans `PreparationRules.HIDDEN_CLUSTER_BLOCKING_RATIO = 0.02` : **ceil(32 290 ×0,02) =646 cellules**, soit **2,000619 %** après arrondi. **645 passe ;646 et647 bloquent.** Le ratio2 % s’applique au total du squelette principal, sans fragments.

La comparaison des limites3 % (969 cellules),2,5 % (808) et2 % (646) conserve les mêmes résultats A/B/C/D. Le choix2 % est plus prudent pour le pied :969 permettrait de laisser968/1 328, soit72,9 % de cet ensemble encore enfoui ;646 exige d’en avoir retiré plus de la moitié avant passage. Les captures limites ont confirmé que3 % conservait encore une grande partie du pied cachée.2 % sépare le pied manquant des petits restes sans imposer100 % global. C’est un réglage prototype à confirmer humainement, pas une mesure perceptuelle universelle.

| Fixture native | Exposition | Plus grand amas caché | Attendu/résultat |
|---|---:|---:|---|
| A — pied entier encore enfoui |95,887272 %|1 328|Bloqué, message contextuel ; étoile indépendante acquise|
| B — même nombre total caché, petites taches séparées |95,887272 %|49|Archive permise|
| C — patte entière encore cachée |79,808764 %|au moins1 983|Bloqué|
| D — exposition répartie, petits restes |85,001548 %|49|Archive permise sans étoile|

Les taches B/D occupent des carrés de7×7 maximum espacés dans une grille16×16. Le total caché n’est jamais traité comme un seul amas. Les fixtures ne changent aucun asset ni géométrie de production. Les captures dégagent la matrice voisine en conservant un tampon sur les cellules encore cachées ; elles ne sont pas un playtest humain.

## Validation

- **2 062 contrôles fonctionnels, zéro échec** :1 895 régressions P0–P4,128 P5 actifs,39 expérience fragments dormante. Replays déterministes historiques identiques.
- **77 contrôles graphiques, zéro échec**,15 captures. Deux captures ciblées : [pied caché bloquant](evidence/p5h-02a-coverage-blocked.png), [après révélation partielle](evidence/p5h-02b-coverage-pass.png).
- Frontières natives645/646/647, diagonales et bord de grille, fragmentation d’un amas par exposition, cache/reset, indépendance film/Condition/Fine Preparation, archive85/85 et exclusion des fragments couverts.

**26 scénarios /104 contrôles perf, zéro échec**, à1×/3× :238,504–239,871 FPS moyens ; minimum sur1s231,929 FPS. Coût de session maximum3,732ms dans la poursuite de fouille avec plusieurs milliers de petits restes ; déblocage au Pick≤0,635ms. Film et dégâts seuls : zéro recalcul de couverture.

**Limite de mesure :** pire frame33,730ms pendant le nettoyage du film, sans calcul de garde ; un autre pic26,501ms a été observé au scénario de déblocage. Les critères soutenus du banc passent, mais une garantie absolue≥60 FPS pour chaque frame n’est pas démontrée par cette série. Rejeu ciblé des trois scénarios Brush/coverage/Condition à3× :**10 contrôles supplémentaires, zéro échec**,239,709–239,850 FPS, pire frame9,563ms ; le pic ne s’est pas reproduit. Les résultats initiaux sont conservés, leur cause n’est pas attribuée sans preuve.

Le banc attend désormais la fin de lecture audio avant fermeture : le premier arrêt immédiat laissait deux objets WAV/playback vivants ; le rejeu termine sans avertissement de fuite. Cela ne modifie aucun audio de production. [Mesures du rejeu](evidence/p5h-benchmark-recheck.json). Reproduction ciblée : `Godot --path . --script res://tests/run_p5_benchmark.gd -- targeted`.

Preuves : [tests](evidence/p5h-tests.json), [graphique](evidence/p5h-visual.json), [performance](evidence/p5h-benchmark.json). Reproduction : `tests/check_p5.ps1 -GodotBin <Godot-console> -Graphical`.

Godot4.7.2 stable, renderer Compatibility/OpenGL3.3, RTX5080 / Ryzen7 9800X3D. Cap240 FPS et physique60Hz inchangés.

## Limites

La taille est un proxy de masse visible, pas une compréhension de la silhouette : plusieurs os naturellement séparés sous le seuil peuvent encore constituer une région visuellement notable sans bloquer. Un trait étroit déjà révélé peut scinder un amas caché. Aucun regroupement par nom anatomique ni pont artificiel n’est ajouté. Le seuil est calibré pour B-17 ; une autre anatomie devra être testée. Les fixtures reproduisent la configuration décrite, pas une sauvegarde exacte de la partie humaine.

La garde exige une nouvelle révélation pour recalculer ; l’exposition P4 est monotone entre deux resets, ce qui rend ce cache valide. Les performances mesurées concernent la machine locale. Les contrôles techniques ne valident ni la perception ni P5 humainement.

## Retest humain unique

1. Jouer normalement depuis reset.
2. Atteindre85/85 en laissant volontairement une grande section enfouie.
3. Vérifier que l’archive reste bloquée avec « Major section still covered ».
4. Révéler naturellement cette section.
5. Vérifier « Ready to archive » sans devoir atteindre100 % au pixel près.
6. Vérifier que Fine Preparation95/95 fonctionne toujours.
7. Confirmer que le reste de l’interface et de la fouille semble inchangé.

**STOP : PR #8 DRAFT, aucun merge/P6 sans accord explicite.**
