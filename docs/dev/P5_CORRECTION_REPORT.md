# P5 — Correction après le premier test humain

> **Correction courante :** [garde anatomique65 % et Condition qualitative](P5_COVERAGE_CARE_REPORT.md), après le retour humain4. Les résultats ci-dessous restent ceux de cette ancienne livraison.

> **Historique — supersédé pour le parcours actif.** La dernière décision85/95 du [brief humain](P5_HUMAN_CORRECTION_BRIEF.md) et [P5_SIMPLIFICATION_REPORT](P5_SIMPLIFICATION_REPORT.md) font autorité : carte unique, quatre outils, étoile globale facultative ; aucun fragment/dossier droit. Les chiffres et captures ci-dessous décrivent cette ancienne livraison.

2026-10-05 · `prototype/p5-loop-progression` · PR #8 **DRAFT** · aucun merge ni P6.

Entrée : `87e3a4cd92dff7aa6ebc45d314353a04c167dd3b`, après récupération des décisions documentaires distantes. Sources : [brief correctif](P5_HUMAN_CORRECTION_BRIEF.md), [premier verdict humain](P5_REPORT.md#human-test-1--2026-10-05) et préférence explicite d'Antoine : l'archive doit conclure agréablement un travail pour le musée, avec un message court et positif.

Code et tests : **`27550255d4010163f8765c344781b167c553b164`**. La modification locale préexistante de `project.godot` reste hors commits ; les quatre ressources d'outils et la géologie P4 sont inchangées.

**Le premier test n'a pas validé P5.** Son comportement Keep Cleaning ne constitue pas un signal produit exploitable : l'ambiguïté entre mission et 100 % pouvait motiver la poursuite. Cette correction prépare un nouveau test libre.

## Changements livrés

### Une seule demande obligatoire

Le panneau **Museum Request / Required work** reste l'unique autorité de fin. Les trois objectifs et leurs seuils sont inchangés. Une coche colore aussi les sous-lignes ; les seuils satisfaits laissent place à un résumé court des valeurs acquises.

Après completion, l'état persistant indique **Request complete / Ready to archive / Further work: optional**. Le bouton Archive Specimen se trouve dans ce panneau, à côté de la confirmation de fin. Le dossier de droite est explicitement **Preparation Record / Information, not requirements**, puis **Optional refinement**. Aucune exigence de 100 %.

Les panneaux font 224 pixels de large dans le viewport 1920×1080 : gauche x16–240, droite x1680–1904. À la vue d'ensemble, ils restent hors du bloc projeté x261–1659. Le plateau physique et son compteur sont également dégagés, y compris quand le bouton Archive est visible. La caméra et le comportement d'excavation P4 restent inchangés ; au zoom, le bloc peut naturellement s'étendre derrière les marges latérales.

### Préparation fine optionnelle

`PreparationRules.fine_preparation` exige **exposition ≥95 % ET propreté ≥95 %**, indépendamment de Prepared (80/80), des objectifs et de la Condition. `PreparationSession` attribue une étoile persistante par composant, une seule fois par reset.

À l'acquisition, la ligne du composant reçoit un bref éclat doré de 0,85 s et une notice discrète. L'étoile reste à côté de son état ; aucun scan supplémentaire de la carte, aucun nouveau pouvoir gameplay. Les snapshots mémorisent les étoiles séparément. Zéro étoile permet completion et archive ; quatre étoiles ne remplacent jamais la récupération obligatoire.

**98–99 % :** les pourcentages exacts restent informatifs. L'oracle automatisé révèle/nettoie toute l'anatomie et atteint 100 % d'exposition et ~99,999999 % de propreté (affiché 100,0 %) : aucun plafond numérique systématique à 98–99 % n'est observé. Le reliquat exact du test humain n'a pas été sauvegardé, donc sa cause géométrique n'est pas établie. À titre d'échelle, 1–2 % globaux représentent environ 323–646 cellules ; aucune réécriture du relief ni règle de nettoyage artificiel dans cette passe. Le succès optionnel à 95/95 évite de faire de ces derniers pixels un objectif principal.

### Découverte et récupération des fragments

Les deux fragments se trouvent désormais près de la mâchoire inférieure et du bassin, sur le parcours de préparation anatomique. Centres de développement : **(274,5 ; 295,5)** et **(652,5 ; 344,5)**. Ces coordonnées ne sont pas une instruction joueur. Leurs centres sont à **20,65 /25,35 texels** des cellules anatomiques les plus proches ; surfaces et couronnes restent entièrement disjointes du squelette.

À la première exposition réelle d'au moins **10 %**, un signal unique indique **Loose fragment detected — clear its edges, then use [5] Forceps**. Rien n'apparaît à travers la matrice intacte. READY conserve exactement **90 % + couronne locale dégagée**. Deux fragments, mêmes totaux anatomiques, aucune nouvelle graine ou contenu.

Le réceptacle 2D est remplacé par `FragmentTray3D` : fond, rebords, séparation et labels 3D, posé sur le bureau à gauche du bloc. Le dépôt utilise l'intersection du rayon caméra avec **le fond intérieur réel** ; le rectangle projeté du contrôle n'est pas une cible. Les rebords, les panneaux UI et le bloc ne valident pas un dépôt. Les meshes récupérés restent physiquement dans les deux compartiments, avec compteur0/2→2/2.

Le plateau reste fixé à la table : il peut sortir du cadre lors d'un gros zoom/pan. Forceps affiche alors **Home: show the desk tray before picking up a fragment**. Home restaure la vue d'ensemble ; si un fragment est déjà tenu, il revient d'abord en place, comme avec les autres mouvements caméra P4. Ce choix conserve le cadrage et l'ancrage du zoom existants ; il faut retester le confort de ce retour à la vue d'ensemble. Aucun plateau attaché au curseur ni déplacement automatique de caméra.

Prise/dépôt/retour conservent les hauteurs RF, le film et la Condition. Le plateau ne crée ni rigid-body ni collision de terrain. Aux nouveaux emplacements, le test natif Brush→Chisel atteint READY après **36 /22 impacts** dans sa fixture locale ; cela démontre l'accessibilité et ne prédit pas une durée humaine.

### Une conclusion courte pour le musée

L'archive présente une carte centrée avec confirmation visuelle, léger fondu/déplacement de 0,3 s et son doux de 0,4 s généré localement. Elle affiche :

- **Specimen archived ✓ / Museum records updated.** ;
- B-17 et sa classification ;
- travail requis terminé, fragments récupérés et Condition finale ;
- les composants étoilés, explicitement optionnels ;
- **Thank you for bringing B-17 to light.** ;
- un seul bouton : **Prepare Another Block**.

Sans étoile, le texte confirme que le standard demandé par le musée est atteint ; il n'affiche pas un nouveau compteur0/4 à remplir. Les différences chiffrées détaillées restent dans F1 via les snapshots et métriques existants. L'archive utilise toujours l'état final ; la completion garde sa copie initiale. Ni la confirmation ni le son ne se rejouent au refresh. Reset stoppe sons/tweens et réarme les étoiles.

## Validation et preuves

Les résultats finaux et captures de cette passe sont consignés dans `docs/dev/evidence/p5c-*`. Les preuves `p5-*` de la livraison initiale restent historiques et ne sont pas écrasées.

| Vérification exécutée | Résultat |
|---|---|
| Chaîne historique complète | 1 895 checks uniques, zéro échec ; neuf empreintes interprocessus et replay V2 inchangés |
| P5 fonctionnel |184 checks, zéro échec|
| Correction P5 |38 nouveaux checks, zéro échec|
| Rendu / vraie UI / vrais boutons |79 checks, zéro échec ;15 captures|
| Performance |22 scénarios de6 s à1×/3×,70 checks, zéro échec|

**2 117 contrôles fonctionnels**, dont les resets et les anciens invariants P4. Après la dernière formulation de l'archive, les222 checks P5/correctifs et les79 graphiques ont été rejoués ; la suite historique complète avait déjà passé. Reproduction : `tests/check_p5.ps1 -GodotBin <chemin-Godot> -Graphical`.

Godot4.7.2 / Compatibility / RTX5080 / pilote610.88 / Ryzen7 9800X3D, viewport1920×1080. Cap240 FPS / physique60 Hz. FPS moyens **239,70–239,88**, minimum sur une seconde **239,01 FPS**, pire P95 **8,574 ms**, pire frame **11,426 ms**. L'archive et son animation sont comprises :239,87 FPS aux deux zooms, maximum6,325 ms. Aucun benchmark concurrent ni capture dans la fenêtre mesurée. Coût session maximal136 µs ; UI maximale1,080 ms, ouverture de carte comprise. Le drag effectue360 ticks réels à chaque zoom, sans retrait de terrain.

Preuves : [régression](evidence/p5c-regression.txt), [fonctionnel P5](evidence/p5c-p5-tests.json), [correction](evidence/p5c-tests.json), [graphique](evidence/p5c-visual.json), [performance](evidence/p5c-benchmark.json). Captures : [départ](evidence/p5c-01-start.png), [plateau physique](evidence/p5c-05-tray-one.png), [étoiles optionnelles](evidence/p5c-07a-quality.png), [archive après préparation fine](evidence/p5c-08-archive.png), [archive sans étoile](evidence/p5c-12-archive-request-only.png). Les fixtures accélèrent la vérification technique ; elles ne démontrent pas le plaisir humain.

Vérifications ciblées déjà réalisées : seuils exacts95/95, étoile unique/persistante/reset, aucune autorité sur Condition/terrain/mission, archive avec zéro étoile, quatre étoiles insuffisantes sans fragments, signal de découverte10 % une fois, aucune révélation sous matrice intacte, proximité anatomique et dépôt sur le fond réel du plateau. Rendu : marges, sous-objectifs satisfaits, étoiles, archive après animation, plateau contenant ses deux meshes et UI1280×720.

## Retest humain — garder le choix libre

1. **Clarté au départ.** Sans explication préalable des seuils, identifier ce que le musée demande et ce qui est optionnel. Le dossier évoque-t-il encore une seconde mission ? La surface reste-t-elle assez dégagée ?
2. **Objectifs satisfaits.** Préparer normalement le crâne et le squelette. Une coche et ses sous-lignes donnent-elles ensemble l'impression que cet objectif est terminé ? Ne pas rechercher100 % par obligation.
3. **Découverte naturelle.** Chercher les fragments en suivant les os, sans coordonnées. La notice arrive-t-elle au bon moment et permet-elle de comprendre qu'il s'agit d'un objet séparé ? Leur présence paraît-elle liée au spécimen ?
4. **Plateau physique.** Essayer un retour hors plateau puis un vrai dépôt. Les rebords et le fond sont-ils lisibles ? Voir le fragment posé est-il satisfaisant ? Tester aussi le retour Home depuis le zoom avant la récupération ; noter si cela casse le geste.
5. **Qualité optionnelle.** Si un composant atteint l'étoile, remarquer son éclat et comprendre son sens. Est-elle désirable sans devenir une nouvelle obligation ? Ne pas imposer de gagner les quatre étoiles pour terminer ce test.
6. **Choix après completion — point principal.** Lire la confirmation de demande terminée, puis laisser le joueur choisir spontanément **Archive** ou **Keep Cleaning**. Ne pas lui demander de continuer pour réussir le test. Si poursuite : relever temps, écarts E/C/Q et actions F1 avant reset ; noter plaisir/maîtrise optionnelle ou confusion/comportement de complétion forcée. Le temps inclut toujours la carte, les actions sont des impacts/ticks et non des clics.
7. **Archive et suite.** La carte donne-t-elle une conclusion courte, positive et satisfaisante au travail pour le musée ? Le son reste-t-il discret ? Les valeurs finales sont-elles cohérentes sans donner l'impression d'un rapport administratif ? Prepare Another Block doit ramener le même B-17 vierge ; ce retour est volontaire pour P5.

**STOP pour ce retest. P5 reste non validé humainement ; PR #8 DRAFT. Aucun merge, P6, crate intake, galerie, refonte Soil ou retuning P4.**


## Livraison Human test4 — 2026-10-05

Code et tests : `77fd61b`. Garde minimale65 % sur les quatre composants ajoutée au85/85 global ; Condition qualitative et notices de dégradation ; étoile95/95 indépendante.2 055 contrôles fonctionnels,77 graphiques,104 contrôles perf sur26 scénarios : zéro échec.239,707–239,869 FPS. Détails, limites et neuf questions dans le [rapport courant](P5_COVERAGE_CARE_REPORT.md). STOP pour retest ; aucun merge/P6.
