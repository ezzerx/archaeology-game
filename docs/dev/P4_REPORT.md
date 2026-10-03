# Rapport P4 — Game Feel / Material Reactions

**2026-10-03 · deuxième passe corrective · `prototype/p4-game-feel` · Godot 4.7.2 stable / Compatibility.**

[PR #5](https://github.com/ezzerx/archaeology-game/pull/5) **en brouillon, non mergée**. Cette passe attend un nouveau test humain explicite. **P5 interdit.** Le [brief initial](P4_BRIEF.md) est complété par les autorisations correctives, décrites dans [l’architecture](P4_MATERIAL_REACTION_DECISION.md).

## Retour humain confirmé

Chisel très fun, fracture Clay/Sandstone, profondeur, lisibilité Bone/matrice, condition moins punitive, zoom/pan validés. Les sons découverte osseuse et hit direct sont jugés parfaits ; le Brush audio suffit pour P4. Antoine a encore joué environ 15 minutes de plus que prévu. Ces acquis sont conservés.

Restait à corriger : accumulation de gros débris autour des côtes, alternance trop fréquente Chisel/Blower, poussière fine masquée par les cubes, petits restes **structurels attachés** impossibles à finir au Brush. Cette passe réduit l’encombrement et ajoute uniquement le quatrième outil explicitement autorisé : Precision Pick.

## Livraison

| Catégorie | Comportement |
|---|---|
| **Transient Chunks** | Éclats Clay/Stone de 3–6 mm, envol et rebond visuels, durée **1,275–1,725 s**. Deux pools de 48 éclats maximum ; 192 particules maximum avec Soil/Air. Sans collider ni autorité sur matière, poussière ou condition. |
| **Loose Debris** | Petites miettes persistantes arrondies/aplaties, largeur **≤1,6 mm**, hauteur **≤0,352 mm**. **Deux miettes maximum par zone 24×24 texels**, toutes matières confondues ; au plus **2 322** sur le bloc entier. |
| **Fine Dust** | Trace persistante principale : carte R8 256×160, accumulation float CPU, grains irréguliers et rugosité locale du shader existant. Aucune expiration. Au plus 8 % du retrait alimente les miettes ; le reste rejoint la poussière, en plus du dépôt historique. Pas de voile orange uniforme. |

Le budget local et la capacité par miette limitent **nombre et taille**. Une zone saturée renvoie son excédent à Fine Dust. Le nettoyage libère les places ; R vide aussi cette occupation. Mise à jour des seules cases touchées, aucune simulation des miettes au repos et aucun scan global idle. Paramètres de présentation isolés dans `config/debris_profile.tres`.

**Blower** conserve sa direction liée au geste, le transport puis l’éjection des miettes et son nettoyage fort de la poussière. Quantités regroupées en paquets locaux, événement `debris_ejected(world_position, direction, amount, material_type)` conservé. Zéro retrait structurel et zéro dégât. Le budget réduit le besoin de le sortir constamment ; le caractère satisfaisant de cette cadence reste à confirmer en jeu. Aucune table salissable.

**[4] Precision Pick** : touche 4 ou pavé numérique 4, bouton dédié, proxy fin visible et petit son de grattage discret. **Maintenir LMB et bouger** ; immobile, aucun forage. Retrait continu local de Soil/Clay/Sandstone, sans stress ni gros morceaux de Chisel.

| Paramètre initial du Pick | Valeur prototype |
|---|---:|
| Mode | SCRAPE |
| Rayon | 3 texels, environ 3,2 mm |
| Puissance | 0,16 unité de travail/s |
| Falloff | 1,5 |
| Efficacité Soil / Clay / Sandstone | 0,30 / 0,60 / 0,45 |
| Vitesse de référence | 100 texels/s ; mouvement plus lent réduit le travail |
| Retrait maximal par texel et passage | 0,004 profondeur normalisée, environ 0,408 mm |
| Dépôt de poussière / nettoyage | 1,25 / 0 |
| Dégât osseux | 0, **provisoire pour P4** |

Au centre, à vitesse suffisante : 0,048 / 0,032 / 0,009 profondeur/s avant plafonds. Le Pick s’arrête à l’interface initiale et au bone ceiling ; les derniers résidus attachés peuvent être retirés sans reprendre le Chisel. Il reste beaucoup plus lent pour le volume. Rôles : **Chisel = volume/fracture → Pick = détails attachés → Brush = miettes détachées → Blower = poussière et nettoyage large**. Le Brush conserve sa faible efficacité structurelle Clay historique, et aucune sur Sandstone.

Fracture, ressources des trois outils existants, résistances, taux de nettoyage, réaction Chisel, caméra et règles de Bone Condition inchangés. Premier contact protégé ; centre Chisel déjà exposé = −3 points maximum une fois par impact. Aucun auto-stop Chisel, marge osseuse ou bonus Brush. Les 28 variantes audio existantes sont conservées à l’octet ; seul le son Pick est ajouté. Home restaure zoom/pan, R restaure aussi le spécimen. Cap 240 FPS, physique 60 Hz ; modificateurs debug et F6/F7 conservés.

## Vérifications

**642 checks fonctionnels, zéro échec** : P0 45, P1 52, P2 97, P3 85, zoom/input 160, P4 61, pan 43, audio 18, saleté 27, budget débris 16, Pick 38. Les anciens cas et tolérances sont conservés ; seul l’indice invalide du test à trois outils a été adapté au quatrième slot.

- Dépôts multi-matières répétés : budget partagé, capacité bornée, excédent entièrement retourné avant saturation de la carte de poussière ; nettoyage et reset libèrent les places.
- Gros éclats bornés, encore visibles à 0,9 s, absents après 2 s ; aucune modification de géométrie, poussière, miettes ou condition par ces effets.
- Persistance des deux saletés, déterminisme, Brush sûr sur miettes de grès ; Blower enlève la poussière, pousse puis éjecte les miettes avec des quantités cohérentes.
- Pick : immobilité sans forage, capsule étroite, trois matières, débit de volume inférieur au Chisel, interfaces, plafond de profondeur, véritables petits restes de grès sur **crâne et côtes** finis exactement au plafond osseux, zéro dégât après passages répétés.
- Slot 4 : clavier/pavé numérique, clic réel sur le bouton, changements 1–4 avec annulation du geste tenu, focus/resize, proxy et route audio. R restaure structure, poussière, budget, spécimen et FX.
- SHA-256 des **28 WAV validés** comparés à la capture de référence du commit `c25b44f`. Leurs échantillons sont identiques ; les anciens tests de boucle Brush et de sémantique des sons osseux passent.
- Picking : **4 432 rayons zoom**, **387 rayons pan**, **225 roundtrips de fracture**. Oracle GPU P3 : **194 955 pixels**, cartes CPU/GPU exactes, erreur hauteur maximale **0,004825** (<0,01), matière corrigée **0,010883** (<0,02). Huit cas frontière dans la tolérance historique de 0,01 texel.

Commande complète :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

La sonde Chisel attentive reste identique : **1 004 impacts**, 4 105 cellules exposées, **49,87 % du crâne à 100 %** ; dix hits directs → 70 %. Elle suppose une reconnaissance parfaite des centres visibles et ne remplace pas un test humain.

## Performances et captures

RTX 5080 / Ryzen 7 9800X3D, 1920×1080, Compatibility, **cap 240 FPS / physique 60 Hz**. Quatorze scénarios de six secondes à 1×/3×, FX actifs, mixer réel avec bus muet. Préparation, warmup et readbacks exclus du timing.

| Scénario | FPS 1× / 3× | Frame P95 1× / 3×, ms | CPU édition active moyen 1× / 3×, ms |
|---|---:|---:|---:|
| Brush / Soil | 232,61 / 222,30 | 12,516 / 13,243 | 7,844 / 8,348 |
| Chisel / Clay | 239,87 / 239,87 | 4,317 / 4,326 | 1,364 / 1,342 |
| Chisel / Sandstone | 239,87 / 239,87 | 4,302 / 4,319 | 1,112 / 1,145 |
| Chisel près de l’os | 239,87 / 239,87 | 4,292 / 4,319 | 1,026 / 1,044 |
| Blower massif | 240,01 / 240,01 | 4,627 / 4,625 | 0,239 / 0,239 |
| Bloc sale au repos | 239,87 / 239,87 | 4,263 / 4,282 | 0,000 / 0,000 |
| Precision Pick / os | 239,84 / 239,85 | 4,944 / 4,907 | 0,400 / 0,398 |

**222,30–240,01 FPS**, P95 maximal **13,243 ms**, frame maximale **17,892 ms**, zéro échec graphique. La petite excursion moyenne au-dessus de 240 tient à la fenêtre de mesure ; le cap configuré est toujours 240. Le Brush reste le poste le plus coûteux. Bloc entièrement sali au repos : **2 322 miettes, aucun upload height ni travail d’édition**. Blower massif : zéro upload height ; 81 paquets encore en vol à la fin de chaque scénario. Pick : 48 cellules osseuses nouvellement exposées, condition 100 %, zéro fracture.

Deux sessions contrôlées sans nettoyage de **270 impacts = 60 secondes simulées** : Clay **29 miettes / 15 zones**, Sandstone **27 / 14**, poussière présente. Quatre secondes simulées de Blower ramènent les miettes de la zone à zéro, à géométrie identique. Ces fixtures démarrent sur une couche pré-exposée, pas sur le bloc initial ; elles ne mesurent pas la cadence humaine.

Preuves : [benchmark](evidence/p4-fix2-benchmark.json), [oracle GPU](evidence/p4-fix2-gpu.json). Logs complets locaux dans `work/test-logs/`.

Captures du vrai renderer inspectées :

- Clay après 60 s : [sale](evidence/p4-fix2-clay-60s-dirty.png) → [nettoyé](evidence/p4-fix2-clay-60s-clean.png).
- Sandstone après 60 s : [sale](evidence/p4-fix2-stone-60s-dirty.png) → [nettoyé](evidence/p4-fix2-stone-60s-clean.png).
- Crâne, cavité contrôlée : [sale](evidence/p4-fix2-bone-dirty.png) → [nettoyé](evidence/p4-fix2-bone-clean.png), os et hauteurs inchangés.
- [Precision Pick et quatrième bouton à 3×](evidence/p4-fix2-pick-3x.png).

## Limites

Les grains et sons restent des placeholders. Poussière stockée à résolution réduite, quantités visuelles normalisées et saturées, pas conservation de masse physique. Les miettes se déplacent au-dessus du relief sans collisions fines. La sécurité du Pick est une **décision de prototype P4**, pas l’équilibrage final. Le réglage initial du Pick et l’intervalle agréable entre nettoyages demandent le retest humain ; aucun verdict de plaisir n’est déduit des benchmarks.

Les performances dépendent du matériel/cache ; pas de garantie sur un autre GPU ni de test humain autonome de 15 minutes. Pas de Forceps, main, table salissable, nouvel objectif, progression, Art Pass ou tuning final P7.

La modification locale préexistante de `project.godot` (suppression de la valeur explicite 60 Hz, égale au défaut Godot) est conservée et **exclue des commits**. Le runtime mesuré reste à 60 Hz.

## Retest humain — 10 à 15 minutes

Ouvrir `project.godot` dans Godot 4.7.2, **F5**, masquer les panneaux avec **F1**. Partir du bloc intact et garder les réglages par défaut. [1] Brush, [2] Chisel, [3] Blower, **[4] Precision Pick** ; après changement d’outil, un nouveau clic commence le geste.

1. **CHISEL** — Vérifier que le Chisel est toujours aussi fun qu’avant.
2. **DEBRIS DENSITY** — Creuser Clay/Sandstone pendant **30–60 secondes**. Est-ce que la scène reste lisible sans sortir le Blower constamment ?
3. **DUST** — Vérifier que la saleté persistante est surtout fine/granuleuse et non une pile de cubes.
4. **BLOWER** — Laisser volontairement une zone devenir sale, puis nettoyer. Est-ce que l’avant/après reste très satisfaisant ?
5. **PRECISION PICK** — Révéler une côte / le crâne. Avec **4, LMB maintenu + mouvement**, enlever les petits restes structurels qui obligeaient à reprendre le Chisel. Objectif : finir proprement le contour.
6. **CLEANUP LOOP** — Faire **Chisel → Precision Pick → Brush → Blower**. Chaque outil a-t-il une fonction évidente et non redondante ?
7. **BONE CONDITION** — Faire une excavation attentive. Vérifier qu’on n’est plus structurellement obligé de risquer l’os juste pour enlever les derniers détails.
8. **LONG PLAY** — Jouer **10–15 minutes**. « Est-ce que j’ai envie de rendre les os parfaitement propres alors que personne ne m’y oblige ? »

**STOP après cette passe. Nouvelle validation humaine explicite attendue ; aucun merge et aucun P5.**
