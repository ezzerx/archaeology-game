**HISTORIQUE — version 8f703ae à 2,2 mm rejetée humainement. Voir [le rapport courant](P4V2_REPORT.md).**

# P4-V2 — Physical Persistent Crumbs

2026-10-04 · `prototype/p4v2-debris-physics` · [PR #7](https://github.com/ezzerx/archaeology-game/pull/7), **DRAFT, aucun merge**. Implémentation : **`03803e5`** ; tests : **`4d71405`**. Baseline P4/V1 validée : `main@ce014d0c2dd311ed2fbac0f37e0001be707a74a7`. [Brief corrigé](P4V2_BRIEF.md).

## Verdict humain et correction de cible

**SIMPLIFY**, confirmé par Antoine sur la première V2 `d8224ec`. Le mot « debris » avait été interprété comme les gros éclats transitoires du Chisel. La cible voulue est la petite saleté persistante laissée après excavation.

> Debris physics target = persistent crumbs, not transient Chisel chunks.

La correction conserve le noyau technique utile, le rattache aux miettes et restaure les gros éclats P4-V1. Le verdict humain sur cette nouvelle composition reste **KEEP / SIMPLIFY / DROP à donner** ; aucun gain de fun n'est déduit des tests.

## Architecture avant / après

| Famille | Première V2 | Correction actuelle |
|---|---|---|
| Gros éclats Chisel | Pool physique 48, contact relief, sommeil puis fade | Chemin **P4-V1 exact** dans les deux modes, effet transitoire seulement |
| Petites miettes | `LooseDebris` sparse, placement/vol 2D | `LooseDebris` possède quantité/budget et le noyau physique XYZ ; sommeil sans expiration |
| Fine Dust | État et shader persistants séparés | Conservés ; excédent des budgets reçu par le chemin existant |
| Rendu persistant | Vue des miettes + vue physique des gros éclats | **Une seule `LooseDebrisView`, MultiMesh fixe 128** ; ancienne `TerrainDebrisView` retirée |

`TerrainDebris` reste le nom du noyau de mouvement, désormais exclusivement créé par `LooseDebris`. Ses **128 enregistrements sont préalloués**, sans RigidBody, Node par miette, collider dynamique, nouvelle carte, parcours du heightfield ou reconstruction de mesh. La physique avance depuis le tick existant du `ToolController` via `LooseDebris.advance` : aucune seconde boucle physique de feedback.

### Transient Chisel chunks

Les fonctions de génération `_emit` et d'animation `_process` de `MaterialFeedback` sont revenues **à l'identique de la baseline P4-V1**. Même RNG, nombre **1–5 par plaque**, largeur **3–6 mm**, proportions Clay **0,24** / Stone **0,7**, vitesse outward **0,09–0,14 m/s**, couleurs/contraste et durée **0,51–0,69 s**. Ils disparaissent rapidement, ne reçoivent aucune impulsion Blower et n'ont ni quantité persistante ni enregistrement `TerrainDebris`. Aucun doublon de gros morceau.

### Quantité, naissance et position

- `cells[source_key]` reste l'autorité de quantité normalisée (pas une masse SI). Rétention **0,08**, capacité **0,02**, deux places partagées entre matériaux par zone de **24×24 texels**.
- **Budget local de naissance** : la miette garde sa clé/bucket en roulant. Pas d'occupation recalculée à destination ; plusieurs miettes peuvent s'y rejoindre. Sortie/Brush/reset libèrent le bucket d'origine.
- **Cap global 128**, incluant miettes Soil, Clay, Stone, au repos, physiques ou en vol 2D historique. Jamais d'éviction d'un déchet visible. Le dépôt refusé retourne intégralement à Fine Dust.
- Un dépôt proche peut compléter une miette existante jusqu'à sa capacité. Une miette physique partie à plus de huit texels de son point de naissance n'absorbe plus de matière distante ; ce supplément retourne à Dust.
- `physical_slots[source_key]` associe chaque miette dure ON à un seul enregistrement. **XYZ courant** donne sa position de rendu, sa coordonnée map pour Brush/Blower et sa sortie du bloc. Les petits montants nettoyés sont retirés progressivement, comme auparavant.
- Le renderer met seulement à jour les clés sales/mobiles ; les miettes endormies gardent leur transform GPU. Aucune croissance de MultiMesh.

Les miettes dures utilisent l'écaille asymétrique à six côtés et le contraste de faces P4-V1, avec **2,2 mm maximum**, épaisseur nominale **0,704 mm maximum**, profondeur **75 % de la largeur**. La taille suit la quantité par racine carrée. Ces dimensions sont communes ON/OFF : l'A/B isole le mouvement, pas une différence de taille. Les miettes Soil gardent leur géométrie **1,4 mm / 0,14 d'épaisseur** et leur mouvement historique.

## Physique et persistance

Deux sous-pas à **60 Hz**. X/Z → UV utilise `SurfaceMapping.local_to_uv`, puis `relief.height_at` à la position courante, sur les triangles du relief. Le dessous est une enveloppe orientée conservatrice de l'écaille. Un contact corrige Y, amortit la vitesse et autorise un petit rebond. Quatre sondes supplémentaires ±X/±Z à 2 mm estiment une pente downhill bornée.

| Paramètre (`config/debris_physics_profile.tres`) | Valeur provisoire |
|---|---:|
| Gravité | **0,65 m/s²** |
| Restitution Clay / Stone | **0,12 / 0,22** |
| Freinage tangent Clay / Stone | **14 / 9 s⁻¹**, exponentiel |
| Amortissement angulaire | **12 s⁻¹** |
| Petit saut initial : latéral / vertical | **0,035 / 0,025 m/s** |
| Échantillonnage pente / seuil | **±2 mm / gradient 0,08** (~4,6°) |
| Glissement : vitesse / durée de contact | **0,06 m/s / 0,65 s** |
| Accélération downhill | `−gradient × 0,65 / (1 + gradient²)` |
| Sommeil | vitesse <**0,008 m/s**, rotation <**0,4 rad/s**, pendant **0,15 s** |
| Minimum de rebond secondaire / marge de contact | **0,018 m/s / 0,15 mm** |
| `crumb_blower_impulse` / `crumb_blower_lift` | **5,0 / 1,8 m/s par seconde de souffle** |
| Plafonds Blower latéral / Y | **0,80 / 0,22 m/s** |

**Aucun timer d'expiration, fade ou recyclage d'un endormi.** Le cycle est petit saut → chute/contact → sommeil → reste là. Le support d'un endormi est échantillonné une fois par tick ; creuser dessous le réveille. Maximum théorique **11 sondes par miette/tick**, soit **1 408**, lorsque le réveil se combine à deux contacts. Les sondes ne parcourent pas la carte.

Cavité de test : plan haut **95 mm**, fond **25 mm** ; centre final **26,23 mm**, soit **68,77 mm sous le plan de naissance**. Dessous à **25,15 mm**, marge comprise. Tests de sommeil sans mouvement/disparition sur **30 s au cap** et **100 s sur le plat** ; capture GPU après 30 s avec les mêmes huit miettes. Les grandes coupes et alignements des captures sont des préparations synthétiques, pas des gestes humains.

[Éclats en vol](evidence/p4v2-crumbs-chisel-flight.png) · [après la casse](evidence/p4v2-crumbs-aftermath.png) · [chute](evidence/p4v2-crumbs-cavity-fall.png) · [repos](evidence/p4v2-crumbs-cavity-sleep.png) · [30 s plus tard](evidence/p4v2-crumbs-cavity-30s.png).

## Blower, Brush et sorties

Le Blower applique l'impulsion pondérée par la capsule et `WorkingSurface.weight`, à la **position actuelle**, en intégrant la durée réelle. Le corps de l'outil reste **60 / 0 / 1,0 / residue_clear 2,5**. Un endormi est réveillé ; le même état persistant se déplace avec toute sa quantité. **Aucune suppression directe, aucun paquet 2D supplémentaire pour la même miette dure ON.** Un test à 60 Hz vérifie le véritable décollage, en plus de l'invariance à 30/60/120 appels/s.

Brush retire progressivement la quantité au point réel, sans physique de balayage ajoutée. Un Brush passé uniquement au point de naissance ne touche pas une miette éloignée. Les captures et tests GPU contrôlent la correspondance exacte entre rendu et position physique.

À la sortie X/Z, le noyau intersecte le bord, libère son slot, puis `LooseDebris` retire l'état et libère le budget de naissance **avant** la notification publique. `block.debris_ejected` reçoit XYZ réel, direction, matériau et **quantité restante réelle**, une seule fois. Aucun déchet sur la table P6.

OFF conserve le transport 2D historique, Soil aussi. Ces paquets participent au cap global ; au cap, une scission partielle attend une place libre au lieu de perdre une quantité ou de dépasser la limite. Le départ d'une miette entière transfère sa place au paquet. Le nettoyage Dust, les sources audio et le signal de souffle existant restent conservés.

[Réveil Blower](evidence/p4v2-crumbs-cavity-blower.png) · [Brush au point déplacé](evidence/p4v2-crumbs-cavity-brush.png).

## A/B et invariants

- **ON au lancement** ; **F3** compare désormais **Crumb Physics OFF / ON**. Le spectacle Chisel est toujours P4-V1.
- Un toggle conserve quantités et X/Z actuels ; OFF arrête la physique et repose la miette sur le relief selon le rendu historique. Un paquet 2D déjà lancé finit sa sortie. **R reste la frontière recommandée pour une comparaison propre.**
- **R** vide les trois familles, reset état/RNG/budgets et conserve le mode choisi.
- **F1** affiche persistent crumbs /128, Moving, Sleeping, sondes dernière frame/dernier tick, CPU du noyau et MultiMesh. [Capture](evidence/p4v2-crumbs-debug.png).

Le RF, les hauteurs packed, géologie, IDs/silhouette Bone, stress/fracture, exposition, protections et Bone Condition sont strictement identiques ON/OFF sur **15 checkpoints intermédiaires et un état final**. Les quantités de saleté nettoyées peuvent différer selon la position des miettes et la saturation ; l'algorithme et le shader Fine Dust ne sont pas modifiés. Ne plus revendiquer une identité de l'état des miettes ON/OFF, qui serait contradictoire avec le but du correctif.

Les sources des outils, résistances, géologie, fracture, Bone, relief, Dust, proxies, contrôleur et audio ont été comparées à la baseline Git : inchangées. Bone conserve **tik/100 → DING/97 → tik/97 → DING/94**, quatre protections par reset. `project.godot` conserve sa modification locale préexistante, hors commits ; physique effective **60 Hz** inchangée.

## Validation et performance

- **1 780 contrôles fonctionnels uniques verts** : 1 691 historiques +89 miettes. Rejeux interprocessus exacts, sans doubler leur compte ; neuf empreintes géologiques identiques.
- **128 contrôles visuels historiques verts** : feedback 16, final feel 28, matériaux 46, interfaces/contraste 38. Oracles GPU Bone P3 et géologie/Bone V1 à 1×/2×/3× passent avec leurs tolérances historiques et textures exactes.
- **202 assertions sur les 36 scénarios V2**, plus **8 contrôles GPU dédiés** : taille/XYZ réel, chute, sommeil persistant, réveil, nettoyage et F1. Zéro échec dans ces exécutions finales.
- **60 scénarios de performance historiques couverts** : Brush 12, P4 28, verticalité 20. Provenance des rejeux ciblés et limites des mesures ci-dessous.

[Synthèse de validation et provenance](evidence/p4v2-crumbs-validation-summary.json).

Seules deux attentes historiques sont actualisées pour la demande explicite : l'oracle visuel de taille des miettes passe de 4,5 à **2,2 mm** ; le stress idle passe de 2 322 bins non bornés au **cap global 128**. Les tests de trajectoire 2D/contraste historique sélectionnent OFF. Aucun seuil structurel, Bone, géologique ou de performance n'est assoupli. Les nouveaux tests ON couvrent l'autorité physique et sa persistance.

Deux préparations de test sont adaptées : l'idle pose effectivement ses miettes avant de mesurer, sans leur saut initial au bord ; le contraste utilise deux vraies petites fractures et attend la disparition des effets transitoires. À 1×, l'ancienne fixture Stone n'échantillonnait que **8 pixels** avec les petites miettes ; la nouvelle en échantillonne **13**, ratio **1,291**. Seuils **>8 pixels** et **ratio >1,03** conservés, les 38 contrôles rejoués. Le premier résultat reste archivé, sans le présenter comme vert.

Machine : **Godot 4.7.2, Compatibility, RTX 5080 / Ryzen 7 9800X3D**, 1920×1080, cap240/physique60. L'éditeur et une autre instance du prototype étaient ouverts pendant les mesures ; ils sont restés intacts. Les temps mesurés sont ceux de ce contexte local, pas d'une machine isolée.

**36 scénarios** : neuf cas × ON/OFF × 1×/3× ; 360 ticks (~6 s) chacun. Cas : 0/32/64/128 miettes, chute en cavité au cap, Blower sur 128 endormies, Brush sur cap, Chisel Clay, Chisel Stone. Les sources respectent le budget local ; les fixtures de nettoyage regroupent ensuite les positions dans le rayon pour exercer le cas extrême de 128 miettes arrivées au même endroit. Les préparations/readbacks sont exclus du chronométrage.

| Sur les 18 cas de chaque mode | OFF | ON |
|---|---:|---:|
| FPS moyens, plage | 239,80–239,87 | **239,80–239,87** |
| Minimum sur une seconde | 238,63 | **238,74** |
| Pire P95 frame | 6,209 ms | **6,342 ms** |
| Frame maximale | 11,839 ms | **11,446 ms** |
| Noyau physique, pire P95 / max | 0 /0 µs | **1 072 /4 137 µs** |
| Impulsion Blower, pire P95 / max | — | **13 /192 µs** |
| MultiMesh, pire P95 / max | 210 /763 µs | **15 /231 µs** |
| Sondes max par tick / frame | 0 /0 | **1 280 /1 280** |
| Persistent crumbs max | 128 | **128** |

Tous les cas finaux passent **≥60 FPS et P95 <16,67 ms** ; aucune frame dédiée ne dépasse 16,67 ms. Le noyau physique coûte au pire P95 **1 /215 /390 /622 µs** pour **0 /32 /64 /128** miettes sur plat ; **1 072 µs** en cavité au cap. Ces temps isolent `TerrainDebris.advance` ; le bookkeeping de `LooseDebris`, outils et rendu sont aussi inclus dans le FPS complet, pas dans ce compteur de noyau.

Le Blower réveille **128 endormies**, puis éjecte **128/128 à chaque zoom**, conservant exactement les **2,56 unités normalisées** de la fixture. Brush nettoie également les 128. Les cas Chisel utilisent **27 impacts en six secondes**, et laissent **20 miettes Clay /16 Stone** après cette séquence, dans les deux modes. Quantité totale éventuellement différente, car une miette physique éloignée cesse d'absorber de la matière à son ancien emplacement.

[Résumé des mesures](evidence/p4v2-crumbs-performance-summary.json). Le premier passage contenait des cas vers **145 FPS** aussi bien ON qu'OFF, avant la stabilisation observée au passage final ; aucune cause certaine attribuée. Les 36 mesures de ce passage interrompu sont conservées séparément, sans les présenter comme une exécution de tests terminée.

| Régressions historiques | Cas | FPS moyens | Pire P95 frame | Frame max |
|---|---:|---:|---:|---:|
| Brush, proxy ON/OFF | 12 | 194,47–213,17 | 15,302 ms | 20,831 ms |
| P4, outils/proxies/idle | 28 | 206,96–239,89 | 14,115 ms | 19,822 ms |
| Verticalité A/C, cinq outils/cas | 20 | 194,88–239,87 | 15,256 ms | 19,332 ms |

Ces scénarios passent leurs seuils historiques ; les frames maximales >16,67 ms sont conservées, sans promettre un minimum instantané de 60 FPS. Le premier passage Brush avait échoué au ratio proxy de `stationary_3x` avec une frame **180,983 ms**. **Les douze cas ont été rejoués**, sans changement de production ni de seuil ; max final **20,831 ms**, ratio conforme. Cause de l'écart initial non établie. [Premier passage](evidence/p4v2-crumbs-brush-first-failure.json) · [rejeu complet](evidence/p4v2-crumbs-brush-regression.json).

P4 : **26 cas verts du passage complet +2 rejeux ciblés idle corrigés**. Le fichier du passage complet conserve honnêtement ses deux échecs de préparation au repos ; seuls ces deux cas sont rejoués après stabilisation de la fixture, avec **128 miettes**, zéro modification structurelle et zéro échec. [Passage initial](evidence/p4v2-crumbs-p4-before-idle-fix.json) · [idle corrigé](evidence/p4v2-crumbs-p4-idle-regression.json) · [verticalité](evidence/p4v2-crumbs-verticality-regression.json).

Le premier passage V2 a achevé ses 36 mesures puis attendu indéfiniment la capture GPU finale. Ses données brutes sont conservées comme passage interrompu ; le harnais final enregistre chaque scénario et sépare les captures du profiling. La validation V2 finale utilise les exécutions complètes séparées. Les captures ne représentent pas les phases chronométrées.

Reproduction :

```powershell
& tests/check_p4v2.ps1 -GodotBin '<chemin Godot 4.7.2 console>' -Graphical
```

`-SkipRegression` cible les tests de miettes et leurs benchmarks/captures. [Preuves fonctionnelles](evidence/p4v2-crumbs-tests.json) · [journal complet](evidence/p4v2-crumbs-functional-validation.txt) · [benchmark](evidence/p4v2-crumbs-benchmark.json) · [captures et assertions GPU](evidence/p4v2-crumbs-visual.json).

## Limites et retour humain attendu

- Heightfield sous le centre et enveloppe orientée conservatrice : aucune collision latérale volumique ou entre miettes. Une paroi haute peut provoquer une projection verticale simplifiée ; pas d'occlusion aérodynamique du jet.
- Le cap inclut Soil. Une zone très sale peut refuser toute nouvelle miette dure jusqu'au nettoyage ; l'excédent va alors à Dust. Aucune promesse de miette à chaque coup.
- Budget de naissance : une miette éloignée garde sa place d'origine jusqu'au nettoyage. Les destinations peuvent concentrer davantage de deux miettes.
- Les petits montants donnent des miettes plus petites que 2,2 mm ; leur lisibilité, le déplacement rapide du Blower et le clutter restent à juger humainement.
- Aucun nouveau chantier Dust/arêtes : état et shader conservés, watchpoint P6/P7 à surveiller pendant le test humain.
- Les preuves `p4v2-*` **sans `crumbs`** et les premiers commits de cette PR documentent l'ancien spike à gros éclats, désormais **SIMPLIFY**. Elles ne valident pas cette nouvelle composition.

## Checklist humaine exacte

Lancer F5, masquer F1 pour juger le ressenti. Refaire **OFF → R → zone**, puis **ON → R → même zone**, à 1× et 3×.

1. **A — CHISEL.** Casser Clay/Sandstone. « Est-ce que j'ai retrouvé le punch P4-V1 des gros morceaux qui explosent ? » Cible : **OUI**.
2. **B — AFTERMATH.** Attendre la fin des gros chunks transitoires. « Est-ce qu'il reste uniquement quelques petites saletés crédibles ? » Cible : **OUI**.
3. **C — CAVITY.** Observer une petite miette générée au bord d'un trou. « Est-ce qu'elle tombe/se pose naturellement dans le relief ? » Cible : **OUI**.
4. **D — BLOWER.** Souffler plusieurs petites miettes. « Est-ce que j'ai vraiment l'impression de chasser les déchets hors du trou ? » Cible : **OUI**.
5. **E — PERSISTENCE.** Ne pas nettoyer et attendre plusieurs secondes. « Les petites miettes restent-elles en place jusqu'à ce que je décide de nettoyer ? » Cible : **OUI**.
6. **F — A/B.** Crumb Physics OFF → R → même zone ; Crumb Physics ON → R. « La physique des PETITES miettes améliore-t-elle clairement le nettoyage ? » Cible KEEP : **OUI**.

**STOP après livraison. PR #7 DRAFT, aucun merge, aucune étape P5.** Décision suivante : KEEP / SIMPLIFY / DROP par Antoine.
