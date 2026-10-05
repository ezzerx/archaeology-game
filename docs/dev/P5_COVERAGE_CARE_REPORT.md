# P5 — Couverture anatomique et qualité du soin

2026-10-05 · `prototype/p5-loop-progression` · PR #8 **DRAFT**. Entrée : `ef0ee5a1ba5d8f5199953e66909385066cb8a4db`. Code et tests : `77fd61b`.

**Livraison pour retest, pas validation humaine. Aucun merge ni P6.** Le [brief humain4](P5_HUMAN_CORRECTION_BRIEF.md#human-test-4--final-p5-target-8595--coverage-guard--condition-tiers--2026-10-05) et la demande actuelle prévalent sur les anciennes itérations. `project.godot` préexistant reste hors commits.

## Changements exacts

- `preparation_rules.gd` centralise la garde anatomique et les quatre paliers de Condition, avec les seuils85/95 déjà présents.
- `preparation_session.gd` recalcule la garde sur les quatre compteurs existants uniquement après changement d'exposition (signaux regroupés). Completion exige désormais cette garde. Le premier passage descendant dans chaque palier de Condition émet un signal/une notice ; aucun nouvel événement au sein du même palier. Reset réarme le tout. Snapshots conservent aussi garde et palier.
- `preparation_ui.gd` montre Museum standard85 % dès0 %, deux barres et Condition qualitative. À85/85 bloqué, une ligne « Major section still covered » ; à readiness, « ✓ Ready to archive / Further preparation is optional ». Le95 % n'apparaît qu'ensuite. L'archive ajoute uniquement le palier final de Condition. Une notice de soin dure3,2s et ne se fait pas effacer immédiatement par une découverte simultanée.
- `prototype_main.gd` expose garde et compteur de vérifications dans F1. Les tests couvrent le nouveau parcours, les limites exactes, les clics réels et les charges graphiques de couverture/soin.

Aucun changement aux ressources outils, BoneFilm, FossilState, WorkingSurface, fracture/débris, géologie, shaders, caméra, picking ni protections P4. Fragments/Forceps/plateau restent dormants ; aucun nouvel objet ou masque visuel en jeu.

## Seuils finaux centralisés

| Règle | Seuil |
|---|---|
| Musée | Exposure global≥85 % ET Cleanliness global≥85 % ET garde valide |
| Garde | Skull, Spine, Ribs et Hind Limb : **chacun≥65 % exposé** |
| Fine Preparation | Exposure global≥95 % ET Cleanliness global≥95 %, une étoile par reset |
| Excellent | Condition≥95 % |
| Good | 85 %≤Condition<95 % |
| Fair | 70 %≤Condition<85 % |
| Damaged | Condition<70 % |

Condition n'intervient ni dans completion ni dans Fine Preparation. Le nettoyage ne répare pas les dégâts. Completion/étoile restent acquises ; seule Archive bloque les outils. Un saut de plusieurs paliers notifie uniquement le palier atteint, sans rafale de messages.100 % ne donne aucun bonus.

## Pourquoi65 % plutôt que50 %

La première hypothèse50 % bloque la patte presque entière cachée, mais la comparaison sur B-17 montre qu'elle laisse encore tout le bas de la patte couvert. Des fixtures identiques à score global constant ont comparé50/60/65/70 %. **65 % est retenu pour ce prototype** : le genou et une partie du bas de patte sont lisibles, sans exiger une préparation presque complète de chaque composant. C'est une appréciation de la capture, à confirmer humainement, pas une validation définitive du seuil.

Cas reproductible à **85,865593 % global**, propreté≈100 % :

| Cas | Skull | Spine | Ribs | Hind Limb | Résultat |
|---|---:|---:|---:|---:|---|
| Patte majoritairement cachée | 7 756 | 7 243 | 10 771 | 1 956 (30 %) | Archive bloquée |
| Même total, mieux réparti | 5 474 | 7 243 | 10 771 | 4 238 (65 %) | Archive permise |

Les valeurs sont des cellules exposées, sur32 290 au total. Le transfert exact de2 282 cellules conserve le score global. La limite native4 237/4 238 cellules de patte est aussi testée ; les autres composants ont leur frontière64,99/65 testée. Un Pick réel franchit cette garde dans le benchmark.

La garde lit **quatre valeurs**, sans analyse de connexité, sans scan des32k cellules et sans parcours par frame. Un nettoyage ou un dégât sans nouvelle exposition ne relance pas la garde. Le60Hz/240FPS reste inchangé.

## Vérification

- **2 055 contrôles fonctionnels, zéro échec** : 1 895 P0–P4, 121 parcours P5 courant, 39 expérience fragments dormante. Régression complète passée, puis les 121 contrôles actifs rejoués après calibration finale à65 %.
- **77 contrôles graphiques, zéro échec**, 15 captures : démarrage, garde bloquée/passante à score identique, readiness, étoile unique, Condition, archives, reset, 1280×720, fenêtre étroite et F1.
- **26 scénarios graphiques /104 contrôles perf, zéro échec**, outils réellement appliqués à1×/3× :239,707–239,869 FPS moyens, minimum sur1s238,847 FPS, pire frame11,406ms. Cap240 FPS et physique60Hz confirmés. Pick franchit la garde ; Chisel traverse Good/Fair/Damaged une fois chacun, sans recalcul de garde ni perte de l'étoile.
- Godot4.7.2 stable, Compatibility/OpenGL3.3, RTX5080 / Ryzen7 9800X3D. Mesures locales, pas garantie pour d'autres machines.

Preuves : [fonctionnel](evidence/p5g-tests.json), [graphique](evidence/p5g-visual.json), [performance](evidence/p5g-benchmark.json). Captures : [départ](evidence/p5g-01-start.png), [garde bloquée](evidence/p5g-02a-coverage-blocked.png), [garde passante](evidence/p5g-02b-coverage-pass.png), [Condition Good](evidence/p5g-06a-condition-good.png), [archive étoilée](evidence/p5g-07-archive-fine.png), [archive simple](evidence/p5g-09-archive.png).

Reproduction : `tests/check_p5.ps1 -GodotBin <chemin-console-Godot> -Graphical` avec Godot4.7.2. Les fixtures et mesures ne constituent pas une validation humaine.

Les captures anatomiques sont des fixtures de test : elles dégagent la matrice voisine tout en conservant une enveloppe au-dessus des cellules osseuses non exposées. Elles ne modifient aucune géométrie de production, ne révèlent aucun os caché et ne constituent pas un playtest humain.

## Limites connues

La garde porte sur les quatre **composants** de B-17, pas sur chaque os ni chaque amas contigu restant. Des sous-parties peuvent donc rester enfouies après readiness ; le retest doit confirmer que le spécimen paraît suffisamment révélé. Elle devra être reconsidérée pour une autre anatomie. Aucun seuil100 %, checklist anatomique ou surbrillance cachée n'a été ajouté pour compenser cette limite.

Les mesures restent locales/F1 et ne prouvent pas la compréhension ni le plaisir. Keep Cleaning peut être choisi explicitement ou simplement poursuivi avec les outils actifs ; les actions supplémentaires permettent de distinguer les deux. La propreté affichée est tronquée pour éviter d'annoncer un seuil prématurément ; un résultat flottant99,999998 peut afficher99 %.

## Retest humain — lancer depuis reset, jouer sans brief

1. À0 %, est-ce que je comprends ce que le musée attend ?
2. Est-ce que85 % est clairement le standard demandé ?
3. Le résultat permis évite-t-il une grande partie du corps encore enfouie ?
4. Si une section manque, le message est-il simple et sans révélation cachée ?
5. « Ready to archive » veut-il clairement dire que le travail est terminé ?
6. Le95 % donne-t-il envie de continuer, sans obligation ?
7. Condition encourage-t-elle le soin sans ressembler à une barre à remplir ?
8. Archive est-elle une conclusion claire et satisfaisante ?
9. L'interface laisse-t-elle la priorité au fossile ?

**STOP. P5 reste non validé humainement ; PR #8 DRAFT, aucun merge/P6 avant accord explicite.**
