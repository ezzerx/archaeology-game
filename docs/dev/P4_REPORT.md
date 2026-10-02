# Rapport P4 — Game Feel / Material Reactions

**2026-10-02 · `prototype/p4-game-feel` · Godot 4.7.2 stable / Compatibility.**

[PR #5](https://github.com/ezzerx/archaeology-game/pull/5) conservée **en brouillon, non mergée**. Passe corrective issue du test humain ; P4 attend un nouveau verdict explicite. **P5 interdit.** Le [brief initial](P4_BRIEF.md) est complété par les décisions de cette passe, détaillées dans [l'architecture](P4_MATERIAL_REACTION_DECISION.md).

## Retour humain à préserver

Antoine devait arrêter de jouer mais a continué environ **15 minutes** : la fouille est devenue addictive et le **Chisel très fun**. Fracture Clay/Sandstone, profondeur, distinction os/matière, zoom et picking constituent le socle à préserver. La condition paraît beaucoup moins catastrophique. Ce retour positif ne vaut pas validation finale de P4.

Les problèmes restants concernaient la saleté qui semblait disparaître, l'utilité du Blower, la finition des os, le Brush audio artificiel, le son ambigu découverte/dégât et le cadrage à fort zoom. Cette passe corrige ces six points sans retoucher les seuils de fracture, puissances, rayons, falloffs, cadences, résistances, taux historiques de nettoyage ou dégâts. Le tuning final reste P7.

## Livraison corrective

| Sujet | Comportement livré |
|---|---|
| Fine Dust | Carte R8 256×160 existante, accumulation CPU précise, aucune expiration. Grains et taches stables, positions/taille irrégulières, rugosité variable ; recouvre partiellement fissures et os, sans voile orange uniforme. |
| Loose Debris | Cases sparse 8×8 par matière, créées par le retrait réel Soil/Clay/Sandstone ; miettes instanciées persistantes, indépendantes du heightfield et du picking. |
| Polish | Brush enlève les miettes déjà détachées et une partie de la poussière, sans dégâts. Il ne creuse toujours pas le grès ; sa faible efficacité Clay historique reste inchangée. |
| Blower | Enlève fortement la poussière, entraîne les miettes selon le mouvement du geste puis les expulse hors du bloc. Aucune hauteur ni condition modifiée. Hook monde `debris_ejected`, aucune table salissable. |
| Brush audio | Deux textures continues bouclées/croisées, attaque et relâchement doux ; intensité surtout liée au mouvement, puis au travail réel. Immobile presque silencieux, aucun grain sonore redéclenché en série. |
| Bone audio | `bone_revealed` = tik léger de découverte ; `direct_bone_hit` = clack distinct d'erreur, prioritaire si le même impact révèle aussi du voisinage. |
| Caméra | RMB maintenu + drag = pan direct et borné, toujours orthographique à 84°. Zoom 1–3× au curseur intact après pan. Home restaure la vue ; R restaure aussi le spécimen. |

Les trois proxies et les quatre pools transitoires historiques (192 éléments maximum) restent présents. Les miettes persistantes utilisent un MultiMesh séparé ; les cases au repos ne sont pas parcourues chaque frame. Les paquets soufflés sont regroupés localement, puis avancés à 60 Hz jusqu'à la frontière. Reset vide poussière, miettes, paquets, stress, effets et audio. F2 reste une vue de données sans effets.

La notification `Bone detected / Delicate material underneath` reste une fois par reset. Premier contact protégé ; centre Chisel déjà exposé = −3 points, au maximum une pénalité par impact. Ni marge de 2 mm ni bonus Brush près des os. Un reste dur encore attaché reste structurel : le nettoyage sûr concerne la matière réellement détachée.

Les réglages debug sont conservés : Shift+molette puissance, Ctrl+molette falloff, Alt+molette rayon, F6/F7 et modificateurs en secours. RMB ne creuse pas ; LMB pendant un pan n'arme pas de stroke. Focus perdu, sortie de fenêtre et resize terminent le pan.

## Vérifications

**585 checks fonctionnels, zéro échec** : P0 45, P1 52, P2 97, P3 85, zoom/input 160, P4 initial 58 (sept banques audio), pan 43, audio 18, saleté 27. Les seuils des suites historiques restent inchangés.

- Persistance après dix secondes et après expiration des particules ; déterminisme et reset exact ; Brush sûr sur miettes de grès sans retrait structurel.
- Blower : hauteur bit-identique, zéro upload height, nettoyage effectif, déplacement orienté, sorties en coordonnées monde et conservation des quantités agrégées.
- Audio : boucle complète/raccord, modulation vitesse/travail, attaque/release, une seule mise en route sur trois secondes, silence au repos ; révélation adjacente sans dégâts et son distinct du hit direct ; notification unique.
- Pan : centre/bords/os/cavité, mouvement direct à 3×, zoom après pan, clics concurrents, limites diagonales, Home/R, focus/resize. **387 rayons**, erreur maximale **0,00000048 m**. Les **4 432 rayons** du zoom historique et **225 rayons** de fracture passent également.
- Oracle GPU P3 : **194 955 pixels**, cartes CPU/GPU identiques ; erreur de hauteur maximale **0,004826** (<0,01), erreur matière corrigée **0,010883** (<0,02), huit frontières selon la tolérance historique de 0,01 texel.

Commande :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

La sonde de condition reste identique : **1 004 impacts**, 4 105 cellules révélées, **49,87 % du crâne à 100 %**, puis dix coups directs → 70 %. Elle reconnaît parfaitement les centres visibles : preuve de faisabilité, pas preuve d'équité humaine. Le maintien volontaire près de l'os sans précaution termine toujours à 25 % après 27 impacts.

## Performances et preuves

RTX 5080 / Ryzen 7 9800X3D, 1920×1080, Compatibility, **cap 240 FPS / physique 60 Hz**. Dix scénarios de six secondes, effets persistants/transitoires actifs ; mixer réel avec bus muet pendant les mesures. Préparation, warmup et captures exclus du timing.

| Scénario | FPS 1× / 3× | Frame P95 1× / 3×, ms | CPU édition active moyen 1× / 3×, ms |
|---|---:|---:|---:|
| soil | 239,13 / 239,19 | 11,190 / 11,173 | 6,629 / 6,592 |
| clay | 239,87 / 239,87 | 4,292 / 4,292 | 1,311 / 1,294 |
| stone | 239,87 / 239,87 | 4,306 / 4,298 | 1,125 / 1,107 |
| bone | 239,87 / 239,87 | 4,303 / 4,296 | 1,026 / 1,009 |
| blower | 240,00 / 239,98 | 4,942 / 4,951 | 0,299 / 0,297 |

Passage final : **239,13–240,00 FPS**, P95 maximal **11,190 ms**, frame maximale **13,602 ms**, zéro échec graphique. Blower : zéro upload de hauteur. Brush : une seule mise en route de sa texture par scénario. Clay : 28 plaques / 27 impacts ; Sandstone : 9 fragments / 27 impacts, comme avant la correction.

La première version du souffle créait 4 760 paquets en mouvement et dépassait le P95 historique de 20 ms. Le regroupement local conserve les quantités et ramène ce cas à 740 paquets ; il ne modifie ni nettoyage ni outils. Le terrain dense n'a pas été refondu. Le coût CPU actif du Brush augmente avec le dépôt sparse, tout en restant dans le budget mesuré.

Preuves : [benchmark correctif](evidence/p4-fix-benchmark.json), [oracle GPU](evidence/p4-fix-gpu.json), [pan](evidence/p4-fix-pan.json). Logs complets locaux dans `work/test-logs/`.

Comparaison contrôlée à 3× : [os sale](evidence/p4-fix-bone-dirty.png) → [même os après souffle](evidence/p4-fix-bone-clean.png). La fixture force une cavité pour isoler le nettoyage ; ce n'est pas le bloc initial du joueur. Les bords non parcourus restent sales, ce qui montre la persistance. Hauteurs et condition sont identiques avant/après.

## Limites

Audio et géométrie restent des placeholders ; l'écoute agréable et l'envie de nettoyer demandent le retest humain. Les grains persistants agrègent 8×8 texels, pas chaque fragment réel ; le souffle glisse au-dessus du relief sans collisions entre miettes. Quantités visuelles normalisées, pas masses physiques. Les mesures portent sur des zones de travail locales, pas sur un bloc entièrement saturé après une longue session. L'Art Pass est P6 ; le tuning est P7.

Les résultats de performance dépendent du matériel et du cache graphique. Le premier démarrage initial P4 avait montré un pic de compilation ; la préchauffe des effets existe, sans garantie sur un pilote/cache neuf. Aucun nouvel asset externe, outil de précision, objectif, fragment récupérable ou progression ajouté.

La modification locale préexistante de `project.godot` (suppression de la valeur explicite 60 Hz, égale au défaut Godot) est conservée séparément et non incluse dans les commits correctifs. Les tests vérifient le runtime à 60 Hz.

## Retest humain — 10 à 15 minutes

Ouvrir `project.godot`, F5, masquer les panneaux avec F1. Partir du bloc intact. Les réglages debug permettent d'accélérer une exploration, mais aucun tuning par défaut n'a changé.

1. **Soil — 30–60 s** : brosser en bougeant lentement puis vite, puis arrêter. Vérifier que poussière et grains restent, et que le son est continu, doux et presque silencieux à l'arrêt.
2. **Blower** : souffler sur la zone sale en déplaçant le geste. Juger l'avant/après immédiat, la direction des miettes et l'envie d'utiliser cet outil.
3. **Chisel** : attaquer Clay puis Sandstone. Vérifier que marques → fissures → morceaux et le plaisir de frappe sont toujours là.
4. **Bone sound** : révéler un os en frappant la matrice voisine → tik de découverte sans perte. Frapper volontairement un centre déjà exposé → son direct différent et −3 points de condition.
5. **Polish** : dégager une portion de crâne/côte, puis nettoyer miettes et poussière avec Brush/Blower. Essayer de rendre cette portion propre sans chiseler l'os ; distinguer les miettes de la matrice encore attachée.
6. **Caméra** : à 3×, RMB drag autour d'une côte et du crâne, vers un bord puis une cavité. Zoomer/dézoomer après pan, vérifier le curseur. Essayer Home, resize, Alt+Tab ; R doit remettre aussi le spécimen à zéro.
7. **Verdict** : le Blower a-t-il une vraie raison d'exister ? Nettoyer l'os donne-t-il envie d'aller jusqu'à propre ? Le Brush est-il plus agréable, son audio acceptable ? Distingues-tu découverte et erreur sur os à l'oreille ? Le pan évite-t-il le détour dézoomer/rezoomer ? Le Chisel est-il toujours aussi fun ? Après 10–15 minutes, as-tu envie de continuer ?

**Attendre cette nouvelle validation humaine explicite. Aucun merge automatique, aucune étape P5.**
