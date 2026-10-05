# P5 — Complete Session Loop / UI & Progression

> **Historique — supersédé pour le parcours actif.** La dernière décision85/95 du [brief humain](P5_HUMAN_CORRECTION_BRIEF.md) et [P5_SIMPLIFICATION_REPORT](P5_SIMPLIFICATION_REPORT.md) font autorité : carte unique, quatre outils, étoile globale facultative ; aucun fragment/dossier droit. Les chiffres et captures ci-dessous décrivent cette ancienne livraison.

**Livré le 2026-10-05 pour test humain.** Branche `prototype/p5-loop-progression` ; [PR #8 DRAFT](https://github.com/ezzerx/archaeology-game/pull/8). Aucun merge ni P6. Source de vérité : [P5_BRIEF](P5_BRIEF.md).

**Mise à jour après test humain : P5 non validé.** Le [rapport correctif courant](P5_CORRECTION_REPORT.md) remplace les descriptions initiales de disposition UI, plateau2D, emplacements des fragments et archive ci-dessous. Les preuves initiales restent conservées comme historique.

Base documentaire : `main@b2a32c8ae97c8fec2c8a583c405ac9274ef566af` ; entrée de branche `eec9569676e0b6a837f418faa492e9232777bea2`. P4 clôturé humainement et mergé via PR #7 (`bae4ee64268dd6270afb9f0011c316c45c57d251`). La modification locale préexistante de `project.godot` est conservée hors commits ; physique60 Hz vérifiée à l'exécution.

Commits de code : **`03f84c1`** (modèle, film agrégé, fragments) puis **`8f34880933e972c182d66c2364f3f1a8e8b7583f`** (interaction, UI, flux et tests). Le commit documentaire suivant conserve ce code et ses preuves.

## Résultat jouable

B-17 arrive au **Museum Preparation Lab** avec trois objectifs et un dossier. Les découvertes font évoluer sa classification. Le joueur prépare le crâne, révèle au moins60 % du squelette et récupère deux fragments avec **Forceps [5]** dans un plateau à deux slots.

La carte **Preparation Complete** affiche les statistiques à l'instant où les trois objectifs sont acquis. **Keep Cleaning** ferme seulement cette carte : le bloc, le film, les protections, les débris et les outils restent disponibles. **Archive Specimen** reste accessible dans le dossier et prend ensuite les statistiques finales. L'archive affiche **Museum records updated.**, les écarts depuis completion et **Prepare Another Block**. Ce dernier réinitialise volontairement le même B-17 déterministe ; plus tard, il conduira à une file de spécimens ou à la sélection de site.

L'ancienne récupération automatique et le bouton principal Restart Specimen des premières spécifications sont remplacés par ce flux. R reste un reset de développement complet.

## Architecture et autorités

| Élément | Responsabilité |
|---|---|
| `FossilState` | Autorité d'exposition anatomique, Condition et protections P4 conservées. |
| `BoneSurfaceFilm` | Film inchangé ; compteurs incrémentaux de cellules exposées et de film restant par composant. |
| `PreparationRules` | Seuils P5 et règles pures, sans logique d'excavation. |
| `PreparationSession` | Observe les signaux existants, regroupe leurs rafales, dérive classification/états/objectifs, snapshots et métriques. |
| `RecoverableFragmentField` / `FragmentState` | Géométrie indépendante déterministe, plafonds, exposition locale, clearance, prise et récupération. |
| `WorkingSurface` | Plafonds structurels combinés ; les cartes anatomiques originales restent inchangées. |
| `ForcepsView` / `ToolController` | Prise et retour sûrs, transfert cinématique, dépôt dans le tray. |
| `PreparationUI` / `FragmentToken` | Arbre Control fixe ; textes, slots et visibilité actualisés sur événement. |

**Exposure ≠ Cleanliness ≠ Condition.** Cleanliness vaut `100 × (1 − film restant / (0,85 × cellules exposées))`, calculée sur les seules cellules anatomiques exposées ; aucune exposition donne0 %. Une cellule déjà propre reste propre quand sa voisine apparaît. Le film récemment découvert peut faire baisser la moyenne ; il ne change ni l'exposition ni la Condition. Les deux fragments sont exclus des ratios du squelette.

La session lit quatre compteurs au refresh, sans rescanner les32 290 cellules osseuses. Le film entretient cinq petits compteurs par tuile4×4 éditée (dont l'ID0 réservé aux fragments ; environ200 KiB supplémentaires). Le rendu des fragments réutilise la texture Bone existante avec IDs5/6 et deux flags de visibilité. Les meshes du transfert et la structure UI sont construits une fois. Seules les transforms du fragment porté suivent la souris chaque frame.

## Seuils P5 centralisés

Tous les seuils sont inclusifs et provisoires ; ils ne retunent pas l'excavation P4.

| Progression | Condition |
|---|---|
| Hidden | Exposition du composant <10 % |
| Detected | Exposition ≥10 % |
| Exposed | Exposition ≥50 % |
| Prepared | Exposition ≥80 % **et** propreté ≥80 % |
| Unknown → Vertebrate remains | Exposition globale ≥5 % **ou** un composant ≥10 % |
| → Possible Theropod | Spine ≥15 % **et** Hind Limb ≥10 % |
| → Likely small theropod | Skull ≥35 %, après acquisition de Possible Theropod |
| Prepare the skull | Skull ≥60 % exposé **et** ≥50 % propre |
| Reveal 60 % of the skeleton | Exposition globale ≥60 % |
| Recover both fragments | Deux fragments déposés dans le tray |
| Fragment READY | Surface exposée ≥90 % **et** clearance locale valide |

Classification et objectifs acquis sont monotones jusqu'au reset ; l'état actuel d'un composant reflète ses ratios courants. Plusieurs conditions atteintes dans une même mutation peuvent faire avancer plusieurs étapes. Les trois objectifs fonctionnent dans les six ordres possibles. Completion se déclenche une fois, sans exiger100 % de préparation.

## Fragments et Forceps

Exactement deux petits fragments indépendants du squelette, placés à l'avance à1024×640 :

| Fragment | Centre de carte | Surface | Couronne | Accès automatisé avec outils natifs |
|---|---|---:|---:|---|
| A | (312,5 ; 384,5), sous le crâne |392 cellules|392 cellules|Brush puis64 impacts Chisel sur la fixture locale|
| B | (756,5 ; 379,5), à droite du bassin |408 cellules|412 cellules|Brush puis15 impacts Chisel sur la fixture locale|

Ces nombres vérifient l'accessibilité, **pas une durée humaine prévue**. Totaux anatomiques conservés : **32 290** cellules, Skull7 756, Spine7 243, Ribs10 771, Hind Limb6 520 ; IDs, silhouette et plafonds du squelette sont exacts.

La clearance exige que toute la couronne de4 texels autour du fragment soit sous son plafond minimum, avec le même epsilon numérique que Bone. Une exposition de90 % ne suffit donc pas s'il reste un pont de matrice dans cette couronne. Seuls les fragments dont la région est touchée sont réévalués : au plus784/820 lectures pour A/B, aucune au repos.

Sur une partie visible du fragment, Forceps affiche **Clear more matrix** ou **Ready to recover** avec un léger highlight. LMB sur READY saisit et porte le fragment au-dessus du bord du bloc ; relâcher sur le plateau le récupère. Relâcher ailleurs, changer d'outil ou perdre le focus le remet en place. Squelette principal, fragment non prêt ou déjà récupéré ne sont pas saisissables. Les événements de récupération ne peuvent pas être doublés.

Forceps est bloqué également à l'entrée du noyau d'excavation : aucune hauteur RF, aucun film, aucun dégât, aucune fracture ni génération de mess. Au dépôt, le plafond indépendant est libéré ; le substrat conserve sa hauteur et peut ensuite être excavé avec les outils normaux. Le transfert est cinématique, sans rigid-body ni nouvelle collision terrain. Proxy et silhouettes restent des placeholders fonctionnels.

## UI, snapshots et métriques

L'écran propose objectifs à gauche, dossier à droite, plateau de deux slots, cinq outils, aide et notifications légères. La file de notices est bornée à cinq, dédoublonnée et temporisée ; aucun toast par variation de pourcentage. F1 masque les panneaux produit pour libérer la place des diagnostics. Layout vérifié à1920×1080 et dans une fenêtre1280×720, via le viewport1080p existant.

Le snapshot de completion est une copie figée. L'archive utilise les valeurs courantes et désactive les outils. Un deuxième bloc remet à zéro terrain, Bone/film, Condition/protections, débris, classification, objectifs, readiness, récupération, Forceps/tray, completion, archive et métriques. R réalise le même reset, y compris pendant une prise ou depuis l'archive.

F1 expose les valeurs demandées :

- `time_after_completion` et `keep_cleaning_chosen` ;
- `exposure_at_completion` / `exposure_at_archive` ;
- `cleanliness_at_completion` / `cleanliness_at_archive` ;
- `condition_at_completion` / `condition_at_archive` ;
- `additional_tool_actions_after_completion`.

Le temps part de completion et s'arrête à archive : **le temps passé sur la carte est inclus**. Une action est un impact appliqué ou un tick d'outil continu à60 Hz, y compris s'il ne retire finalement rien ; ce n'est pas un nombre de clics. Les métriques restent en mémoire et disparaissent au reset. Aucune télémétrie ni sauvegarde musée.

Oracle automatisé Keep Cleaning : exposition90,63→100 %, propreté16,17→100 %, Condition100→97, deux impacts supplémentaires ; l'archive reçoit les valeurs finales, le snapshot initial reste identique. Ces données de fixture prouvent la séparation des snapshots, **pas un comportement humain**.

## Validation technique

| Suite exécutée | Résultat |
|---|---|
| Chaîne historique `check_p4v2.ps1` | **1 895 checks uniques, zéro échec** ; neuf empreintes identiques entre processus et replay V2 identique. |
| `run_p5_tests.gd` | **184 checks, zéro échec**. |
| `run_p5_visual.gd` | **47 checks, zéro échec**, treize captures, vrais boutons et input Forceps. |
| `run_p3_benchmark.gd -- --gpu-only` | **194 955 pixels** à1×/2×/3×, zéro échec. |
| `run_p4_micro_visual.gd` | **25 checks, zéro échec** : Soil, micro-restes, Blower/FX, film. |
| `run_p4v_visual_cleanup_visual.gd` | **38 checks, zéro échec**, interfaces256 725 pixels et contraste. |
| `run_p5_benchmark.gd` | **20 scénarios /64 checks**, zéro échec. |
| Répétition ciblée `--forceps-only` | **Deux scénarios /6 checks**, zéro échec après correction du plan de transfert. |

Les184 checks P5 couvrent les seuils exacts, les quatre états, la monotonie, les six ordres d'objectifs, completion unique, l'agrégat film comparé à un oracle par cellule, les deux fragments/accessibilité/plafonds, le pont bloquant, les interactions Forceps et les resets. Keep Cleaning vérifie conservation d'état et évolution ultérieure ; archive directe et après nettoyage vérifiées. Au repos, aucun refresh de progression/UI supplémentaire. Les tests GPU vérifient aussi la disparition du Bone à la source pendant la prise, sans changer les hauteurs.

Adaptations historiques limitées aux attentes devenues obsolètes : cinq boutons au lieu de quatre, F1 fermé au démarrage, nouvelle notice Bone, carte de rendu incluant les fragments. Les oracles terrain masquent la nouvelle UI pour conserver leur zone de mesure et notifient l'exposition lorsqu'une fixture taille directement la carte. **Aucune tolérance pixel, seuil physique ou baseline d'outil relâché.**

Preuves versionnées : [index](evidence/p5-validation.json), [journal historique](evidence/p5-regression.txt), [fonctionnel](evidence/p5-tests.json), [graphique](evidence/p5-visual.json), [performance](evidence/p5-benchmark.json), [drag final](evidence/p5-forceps-benchmark.json), [GPU Bone](evidence/p5-p3-gpu.json), [micro-passe](evidence/p5-p4-micro-visual.json), [interfaces](evidence/p5-p4v12-visual.json).

Captures de la vraie UI : [départ](evidence/p5-01-start.png), [fragment READY](evidence/p5-03-ready.png), [transfert Forceps](evidence/p5-04-drag.png), [completion](evidence/p5-06-complete.png), [Keep Cleaning](evidence/p5-07-keep-cleaning.png), [archive](evidence/p5-08-archive.png), [nouveau bloc](evidence/p5-09-another-block.png), [F1](evidence/p5-11-debug.png). Les fixtures accélèrent la préparation pour vérifier chaque état ; elles ne constituent pas un playtest humain.

## Performance mesurée

Windows, Godot **4.7.2 stable**, Compatibility/OpenGL, RTX5080 / pilote610.88, Ryzen7 9800X3D. Viewport1920×1080, **cap240 FPS et physique60 Hz**. Dix scénarios de6 s chacun à1× et3× ; préparation des fixtures et captures exclues du chronométrage. Vraie UI visible, mutations et impacts natifs, drag réellement actif pendant360 ticks par scénario. Aucun autre benchmark graphique en parallèle.

| Scénario | FPS moyens1× /3× | P95 frame1× /3× (ms) | Pire frame, deux zooms (ms) |
|---|---|---|---:|
| Brush Soil |239,71 /239,71|8,327 /8,291|9,472|
| Chisel Clay |239,85 /239,85|4,742 /4,728|11,221|
| Chisel Sandstone |239,86 /239,86|4,646 /4,640|10,351|
| Pick Bone |239,86 /239,86|4,640 /4,630|6,861|
| Blower128 miettes →0 |239,86 /239,86|4,437 /4,438|5,449|
| Brush Bone Film |239,72 /239,72|8,462 /8,458|9,749|
| Forceps drag, série initiale |239,88 /239,87|4,333 /4,319|4,876|
| Ouverture completion |239,87 /239,87|4,293 /4,298|6,715|
| Keep Cleaning actif |239,86 /239,86|4,651 /4,653|6,920|
| Dossier en évolution |239,86 /239,86|4,646 /4,635|7,008|

Minimum sur une fenêtre d'une seconde : **238,95 FPS**. Aucune frame de ces mesures ne dépasse16,67 ms ; pire11,221 ms. Coût P5 : session P95≤29 µs ; UI continue P95≤65 µs ; ouverture ponctuelle de carte≤956 µs. Brush Soil/Blower n'actualisent pas inutilement les statistiques osseuses. La répétition après lift au-dessus du bord donne **239,88 /239,87 FPS**, P95 **4,321 /4,326 ms**, maximum4,566 ms et360 ticks de drag à chaque zoom.

Ces mesures valident la machine et les scénarios ci-dessus ; elles ne remplacent ni le test humain continu ni une mesure sur du matériel plus modeste. Les références longues P4 restent historiques, sans prétendre les avoir toutes rejouées graphiquement en P5.

## Reproduire

Depuis la racine, dans PowerShell, avec le chemin local de Godot :

```powershell
./tests/check_p5.ps1 -GodotBin 'C:\chemin\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

La commande importe le projet via la chaîne historique, rejoue toute la régression fonctionnelle, puis P5 fonctionnel/visuel/performance. `-SkipRegression` permet de rejouer uniquement P5 après import. Les logs et captures reproductibles vont dans `work/test-logs/` (ignoré par Git). Pour jouer, lancer `project.godot` avec Godot4.7.2 puis F6/F5 selon la scène ; la scène principale est `scenes/prototype_main.tscn`.

## Une session humaine complète — checklist exacte

Faire une seule session, sans réglage debug de puissance/rayon. [1] Brush : Soil/film ; [2] Chisel : matrice dure ; [3] Blower : mess ; [4] Pick : détails ; [5] Forceps : fragments. Molette : zoom, RMB : pan, Home : vue initiale. Éviter R jusqu'à la fin pour conserver les métriques.

1. **START.** Lire le dossier et les trois objectifs avant de creuser. « Je comprends ce que le musée me demande ? » Noter ce qui nécessite une explication.
2. **DISCOVERY.** Révéler progressivement des os, notamment Spine/Hind Limb puis Skull. « Classification/dossier progressent-ils naturellement sans gêner ? » Vérifier que les notices restent légères.
3. **SKULL.** Préparer le crâne au Pick puis au Brush jusqu'à l'objectif60 % exposé /50 % propre. « Prepare the skull correspond-il à ce que je fais naturellement avec Brush/Pick ? » Ne pas viser100 % par obligation.
4. **FRAGMENT.** Dégager les deux petits fragments et leur pourtour. Essayer Forceps avant READY, puis prendre un READY, relâcher ailleurs une fois et le reprendre pour le déposer dans le plateau. Refaire pour le second. « Récupérer manuellement avec Forceps est-il satisfaisant ? » Les centres A/B ci-dessus servent seulement d'aide si la recherche bloque.
5. **COMPLETION.** Atteindre les trois objectifs, dans l'ordre naturel de cette session. Lire la carte et les valeurs figées. « Je comprends que le travail demandé est terminé ? » Noter si du travail encore intéressant reste visible.
6. **KEEP CLEANING — test principal.** Observer d'abord l'envie spontanée de continuer ou d'archiver, puis choisir Keep Cleaning pour vérifier le flux. Continuer librement, sans durée imposée. Ne pas confondre ce choix demandé avec une preuve d'envie spontanée. Relever à l'archive le temps supplémentaire, ΔExposure, ΔCleanliness, ΔCondition et les actions F1 ; noter si la poursuite venait du plaisir ou de la consigne.
7. **ARCHIVE.** Utiliser Archive Specimen dans le dossier. Vérifier les statistiques finales et leurs écarts, puis l'absence d'action outil. « Archive Specimen donne-t-il une vraie conclusion à la session ? » Relever F1 avant le prochain reset ; le temps inclut l'attente sur la carte de completion.
8. **ANOTHER BLOCK.** Cliquer Prepare Another Block. Retrouver Unknown, objectifs vides, fragments0/2, film/terrain/protections/métriques réinitialisés et Brush sélectionné. « Je comprends qu'un nouveau travail viendrait ensuite dans le vrai jeu ? » Pour P5, le retour au même B-17 est volontaire.

## Limites et arrêt

UI, pinces et fragments restent greybox ; aucune DA finale. Un dépôt laisse le substrat à sa hauteur, puisque Forceps n'excave pas. Les critères de clearance, le placement et les seuils de progression demandent encore un retour humain. Pas de musée navigable, sauvegarde collection, économie, équipement, autre fossile, procgen ni redesign Soil/débris/film. Les quatre ressources P4, géologie, fracture, protections, caméra et audio ne sont pas retunés.

**Technique vérifiée ; agrément et comportement Keep Cleaning non encore validés humainement. STOP pour cette session humaine. PR #8 reste DRAFT ; aucun merge ni P6.**


## Human test 1 — 2026-10-05

**Verdict: NOT YET HUMAN-VALIDATED.** Technical delivery remains sound, but the first end-to-end playtest exposed comprehension and recovery-UX issues that invalidate the current Keep Cleaning behavioral read.

Main findings:
- UI occupies too much of the excavation view;
- required objectives vs dossier/100% quality are ambiguous;
- completed objective child values still visually read unfinished;
- high-quality cleaning lacks a satisfying component-level payoff;
- 98–99% can look visually complete, so exact 100% risks pixel-hunting;
- recoverable fragments feel arbitrary/hard to discover and the UI tray is not tactile enough.

Correction scope and retest protocol: [P5_HUMAN_CORRECTION_BRIEF](P5_HUMAN_CORRECTION_BRIEF.md).

**PR #8 stays DRAFT. Do not merge and do not start P6 before corrected human retest.**
