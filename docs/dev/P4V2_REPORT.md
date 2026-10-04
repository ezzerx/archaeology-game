# P4-V2 — Terrain-aware debris physics

2026-10-04 · `prototype/p4v2-debris-physics` · [PR #7](https://github.com/ezzerx/archaeology-game/pull/7), **DRAFT, aucun merge**. Base validée : `main@ce014d0c2dd311ed2fbac0f37e0001be707a74a7` ; préparation : `d587f208350e9b49c75824abbaccac53d38f609d` ; implémentation : **`38cc404`**. Source de vérité : [P4V2_BRIEF](P4V2_BRIEF.md).

**Spike expérimental : KEEP / SIMPLIFY / DROP restent une décision humaine.** Il vérifie la chute dans les cavités et le plaisir Chisel + Blower ; aucune décision de conserver cette physique n'est prise par les tests.

Harnais/tests : **`b63ab45`**. [Synthèse de validation](evidence/p4v2-validation-summary.json) · [journal fonctionnel complet](evidence/p4v2-functional-validation.txt). Livraison prête pour A/B ; le commit de documentation ajoute les preuves sans changer l'implémentation testée.

## Architecture et périmètre

`TerrainDebris`, consommateur en lecture seule de `ReliefSurface`, préalloue **48 enregistrements** réutilisables. Ils contiennent position locale, vitesse, rotation/vitesse angulaire, taille, matériau, âge et état AIRBORNE / CONTACT / SLEEPING. Un seul `TerrainDebrisView` possède un **MultiMesh fixe de 48 instances**, partageant le mesh dur et ses couleurs de faces P4-V1. Aucun nœud par impact, RigidBody, collider dynamique, reconstruction de mesh ou parcours de carte.

`MaterialFeedback._emit` dirige chaque éclat Clay/Sandstone vers **une seule** trajectoire : V2 lorsque ON, P4-V1 lorsque OFF. Largeur **3–6 mm**, proportions Clay **0,24 × largeur** / Stone **0,7 × largeur**, couleurs, mesh, vitesse initiale et calcul **1–5 par plaque** sont conservés. La limite globale 48 peut réduire les nouvelles émissions sous saturation : on recycle d'abord le plus vieux fragment endormi, ou on refuse le nouvel effet si tous bougent. Un éclat en vol n'est jamais sacrifié pour libérer une place.

Soil grains, Fine Dust, LooseDebris, son Chisel, fracture, ressources outils et géologie restent inchangés. Les miettes persistantes gardent leurs deux places par zone 24×24, rétention 8 %, capacité 0,02. Les nouveaux fragments ne sont pas convertis en saleté persistante et ne comptent dans aucun objectif.

## Contact avec le relief

À **60 Hz**, deux sous-pas intègrent gravité et mouvement. X/Z → UV utilise `SurfaceMapping.local_to_uv`, puis `relief.height_at(uv)` lit la **hauteur courante à cette position**, interpolée sur les triangles du rendu. Le bas du fragment tient compte de son orientation ; il est corrigé au-dessus du terrain. La rotation reçoit de l'amortissement au contact.

En contact, quatre sondes supplémentaires ±X/±Z à **2 mm** estiment le gradient. L'accélération ajoutée pointe uniquement downhill ; elle est bornée et s'arrête après un court budget de contact. Un fragment endormi conserve une sonde par tick : creuser sous lui le réveille immédiatement. Maximum théorique **11 appels height_at par fragment/tick**, soit **528 pour 48** lorsqu'un endormi se réveille ; deux contacts ordinaires utilisent au plus 480. Un appel height_at lit quatre sommets, chacun issu de quatre texels RF. Aucun appel ne parcourt le champ entier.

La fixture haute **95 mm** / cavité **25 mm** produit un centre posé vers **28,7 mm**, soit une chute d'environ **66,3 mm** sous le plan de naissance. Le dessous repose à **25,15 mm**, marge de contact comprise. Aucun plan permanent à la hauteur d'impact. Les captures du harnais montrent le lancement, la chute, le repos et le réveil par le Blower ; les grandes coupes rectangulaires sont des préparations de test, pas un geste humain.

[Lancement](evidence/p4v2-cavity-launch.png) · [chute](evidence/p4v2-cavity-fall.png) · [repos](evidence/p4v2-cavity-sleep.png) · [Blower](evidence/p4v2-cavity-blower.png) · [F1](evidence/p4v2-debug.png).

## Paramètres provisoires

Tous résident dans `config/debris_physics_profile.tres`, indépendamment des ToolDefinition.

| Paramètre | Valeur |
|---|---:|
| Cap global | **48** Clay + Sandstone |
| Gravité | **0,65 m/s²** |
| Restitution Clay / Sandstone | **0,12 / 0,22** |
| Freinage tangent Clay / Sandstone | **14 / 9 s⁻¹**, multiplicateur `exp(-friction × dt)` |
| Amortissement angulaire | **12 s⁻¹** au contact |
| Pente minimale | gradient **0,08** (~4,6°) |
| Accélération de glissement | `−gradient × 0,65 / (1 + gradient²)` m/s² |
| Vitesse / durée de glissement | **0,06 m/s / 0,65 s** de contact |
| Sommeil | vitesse <**0,008 m/s**, rotation <**0,4 rad/s**, pendant **0,15 s** |
| Rebond secondaire minimal | **0,018 m/s** après restitution |
| Marge de contact | **0,15 mm** |
| Maintien endormi / disparition | **1,65 s / 0,40 s** |
| Blower impulse / lift | **1,8 / 1,1 m/s par seconde** de souffle, pondérés par distance |
| Plafonds Blower latéral / vertical | **0,45 / 0,30 m/s** |

Le cycle usuel dure environ 2–3,5 s. La durée est gouvernée par le repos, sans timer d'expiration en vol. La disparition réduit la taille vers le point de contact, comme le feedback opaque précédent ; elle ne crée pas de matériau transparent. Le Blower réveille, remet le maintien à zéro et restitue la taille entière si le fragment commençait à disparaître.

## Blower et événements

Un signal secondaire `WorkingSurface.air_jet_applied` transmet le segment du geste, le rayon/falloff courants, la durée réelle et la direction existante du jet. Il est émis **même sur une surface propre**, sans fabriquer d'événement `material_action` ni modifier son contenu. Les fragments reçoivent l'impulsion selon la même capsule et `WorkingSurface.weight`. Intégration par durée : pas de multiplication involontaire de la puissance avec le FPS.

Un test à **60 Hz** vérifie explicitement le décollage depuis le repos. La marge est déjà incluse dans la hauteur de contact : l'appliquer une seconde fois aurait absorbé les petites impulsions positives du souffle. La ressource Air Blower reste **60 / 0 / 1,0 / clear 2,5**.

Une sortie X/Z intersecte le bord puis libère le slot **avant** notification. `block.debris_ejected` reçoit une seule fois la position mondiale et la direction réelle. **amount = 0** pour ces fragments visuels : ils ne représentent aucune quantité de LooseDebris. Les éjections historiques des miettes conservent leur quantité normalisée. Aucun dépôt de table P6.

## A/B disponible

- **ON au lancement** ; **F3** (debug) choisit la trajectoire des **nouveaux** éclats. Ceux déjà actifs finissent leur cycle, sans disparition artificielle au toggle.
- **F1** : ON/OFF, fragments /48, endormis, sondes par dernière frame et dernier tick, CPU de simulation et soumission MultiMesh en µs.
- **R** : vide tous les fragments, compteurs et pools, réinitialise le RNG existant ; **conserve le mode ON/OFF choisi**.
- **OFF → R → test**, puis **ON → R → même test**. OFF garde le rebond sur hauteur de naissance et la durée P4-V1 **0,51–0,69 s**.

## Validation automatisée

**1 750 contrôles fonctionnels verts** : 1 691 P0–P4-V1 conservés + **59 V2**. Les neuf empreintes géologiques V1 et la trajectoire V2 sont rejouées dans des processus distincts. **128 contrôles graphiques historiques**, oracles GPU P3/V1, puis **121 assertions V2** (dont cinq de capture/debug) : zéro échec dans les séries finales. Aucun seuil historique assoupli. La séquence Bone est toujours **tik/100 → DING/97 → tik/97 → DING/94**, quatre protections maximum et reset exact.

Les tests V2 couvrent : gravité, dessous orienté sans pénétration, rebond/settle Clay et Stone, cavité, rebord, retrait de support sous un endormi, pentes opposées, réveil Blower à 60 Hz, distance et hors rayon, invariance de l'impulsion à 30/60/120 appels/s, vitesse bornée, sortie unique, saturation/réutilisation des slots, reset, aucune expiration en vol, répétition déterministe, F3/F1/R, aucun double spawn, dimensions/mesh préservés, nœuds/pool fixes et connexion du Blower sur terrain propre.

La même séquence des quatre outils compare les SHA-256 de RF et données packed, couches, carte/IDs Bone, stress/fractures, exposition, protections, Fine Dust et miettes ; Bone Condition est comparée exactement. **Quinze états intermédiaires**, puis l'état final, doivent correspondre ON/OFF : une saturation finale ne peut pas cacher une divergence antérieure.

Les anciens oracles dédiés à la durée et au rendu exacts P4-V1 sélectionnent explicitement **OFF**, sans changer leurs assertions. Les autres régressions de gameplay, relief, protection, caméra, rendu des matériaux et performance utilisent le lancement **ON**.

[59 contrôles V2 et empreintes ON/OFF](evidence/p4v2-tests.json). Sources des outils, réactions, résistances, géologie, Bone, fracture, relief, contrôleur, proxies, audio et saleté comparées à la baseline Git : **aucune modification**. La suppression locale préexistante de la ligne de physique explicite dans `project.godot` reste conservée, hors commits ; le moteur utilise toujours sa valeur par défaut **60 Hz**, vérifiée par les régressions.

[Protection par composant](evidence/p4v2-component-contact.json) · [spectacle OFF](evidence/p4v2-legacy-visual.json) · [dust/cleanup](evidence/p4v2-feedback-visual.json) · [matériaux](evidence/p4v2-material-visual.json) · [interfaces V1.2](evidence/p4v2-interface-visual.json).

Reproduction complète (Godot 4.7.2 console) :

```powershell
& tests/check_p4v2.ps1 -GodotBin '<chemin Godot 4.7.2 console>' -Graphical
```

`-SkipRegression` rejoue seulement V2 et ses 24 scénarios graphiques. Les sorties brutes vont dans `work/test-logs/` ; les preuves finales sélectionnées sont versionnées dans `docs/dev/evidence/`.

## Performance V2

**Godot 4.7.2, Compatibility, RTX 5080 / Ryzen 7 9800X3D, 1920×1080, cap 240 FPS / physique 60 Hz.** Six scénarios × ON/OFF × 1×/3× = **24**, six secondes chacun, préparation/readbacks exclus. Chisel Clay plat, Chisel Stone plat, cavité profonde au cap, cap sur plat, Chisel au bord d'une cavité, Blower sur 48 fragments initialement endormis. Les fixtures de stress conservent les plafonds Bone. Blower utilise une cavité qui débouche sur le bord ; une petite zone centrale ne permettrait pas de mesurer honnêtement l'éjection.

| Mesure sur les 12 cas de chaque mode | OFF | ON |
|---|---:|---:|
| FPS moyens, plage | 239,81–239,89 | **239,83–240,14** |
| Minimum sur une seconde | 238,87 | **239,67** |
| Pire P95 frame | 4,438 ms | **5,581 ms** |
| Frame maximale | 11,150 ms | **11,555 ms** |
| Simulation : pire P95 / maximum | 5 / 47 µs | **1 434 / 2 072 µs** |
| MultiMesh : pire P95 / maximum | 8 / 143 µs | **69 / 193 µs** |
| Fragments actifs max | 0 terrain-aware | **48** |
| Sondes max par tick / frame | 0 / 0 | **480 / 480** |

Tous les cas V2 dépassent 60 FPS ; aucune frame V2 mesurée ne dépasse 16,67 ms. Le léger résultat >240 sur certains intervalles vient des frontières de mesure entre tick et rendu, pas d'un changement du cap. Les trois cas Chisel effectuent chacun **27 impacts en six secondes**, sans changer 4,5 Hz. Blower réveille depuis 48 endormis et éjecte **37 fragments à chaque zoom** ; CPU du jet mesuré séparément du tick de gravité.

Le maximum de sondes/frame Blower a été rejoué après exclusion de ses 90 ticks préparatoires de mise au repos. La physique est identique entre les deux séries ; seules les quatre mesures Blower actualisées alimentent la synthèse. Les 20 autres cas sont conservés. Les refus/recyclages sous saturation sont consignés dans les JSON, sans les masquer par un pool plus grand. **121 assertions du harnais V2**, dont cinq de capture/debug, passent ; les quatre cas Blower répétés ne sont pas comptés deux fois.

[Synthèse des 24 cas](evidence/p4v2-performance-summary.json) · [série brute](evidence/p4v2-benchmark.json) · [Blower, mesures corrigées](evidence/p4v2-blower-benchmark.json).

La suite historique ajoute **60 scénarios**, tous verts, avec V2 ON :

| Série | Cas | FPS moyens | Pire P95 | Frame maximale |
|---|---:|---:|---:|---:|
| Brush, dont quatre gestes de 30 s | 12 | 222,60–229,94 | 13,322 ms | 17,886 ms |
| P4 | 28 | 200,80–240,00 | 13,334 ms | **207,738 ms** |
| Verticalité A/C | 20 | 213,66–239,87 | 13,936 ms | 20,111 ms |

Les frames isolées au-dessus de 16,67 ms restent visibles dans les preuves. La pointe **207,738 ms** concerne le premier cas Soil/Brush 1×, **sans fragment terrain-aware actif** ; CPU d'édition max 13,17 ms, proxy max 0,126 ms. Elle n'est pas retirée de la série. **Non reproduite sur huit rejeux ciblés** (deux fois ON/OFF à 1×/3×) : 208,86–224,97 FPS, pire P95 **14,166 ms**, max **18,729 ms**, zéro fragment dur, simulation inactive max **42 µs**. Aucune cause certaine attribuée ; ce rejeu ne garantit pas l'absence de toute future pointe système/rendu. [Sonde Soil reproductible](../../tests/run_p4v2_soil_probe.gd) · [huit résultats](evidence/p4v2-soil-probe.json).

[Brush](evidence/p4v2-brush-regression.json) · [P4](evidence/p4v2-p4-regression.json) · [verticalité et GPU](evidence/p4v2-verticality-regression.json). Le minimum sur une seconde des vingt cas de verticalité est **193,84 FPS**. Les empreintes de fin de geste Brush correspondent avec/sans proxy.

## Limites et décision humaine

- Collision par hauteur sous le centre, dessous orienté ; pas de contact volumique contre toutes les faces, ni collision entre fragments. Les arêtes étroites peuvent être traversées latéralement ; remonter un relief plus haut utilise une projection verticale simplifiée.
- Le glissement possède une durée maximale, puis s'amortit : ce n'est pas un modèle physique de friction statique.
- Pool plein : émission partiellement refusée ou endormi recyclé ; la quantité P4 par plaque est conservée en amont de cette limite. Le spectacle sous spam intense reste à juger humainement.
- Souffle pondéré dans le plan de travail, sans occlusion aérodynamique des parois.
- Quelques fragments peuvent se superposer ou couvrir brièvement un détail. Leur impact sur Bone/curseur appartient au test humain. Le shader Dust reste inchangé ; son watchpoint de lecture des arêtes demeure différé P6/P7.
- Les performances et captures ne valident pas le plaisir. **STOP après livraison ; aucun merge, P5, fusion avec les miettes persistantes ou nouveau chantier poussière.**

## Checklist humaine exacte — dix minutes

Lancer **F5**, conserver les outils P4, masquer F1 pour juger le ressenti. Utiliser F3/F1 pour choisir le mode puis **R** à chaque comparaison, et répéter aux zooms **1× / 3×**.

1. **A — CHISEL.** Physics OFF → R → casser Clay/Sandstone. Physics ON → R → même zone. « Les morceaux physiques rendent-ils clairement le Chisel plus satisfaisant ? »
2. **B — CAVITY, test principal.** Créer un trou profond, puis casser au bord. « Est-ce que je vois naturellement le morceau tomber plus bas dans le trou ? »
3. **C — BLOWER.** Laisser quelques chunks se poser, puis souffler rapidement pendant leur maintien. « Est-ce que le Blower donne vraiment l’impression de chasser des morceaux physiques hors de la fouille ? »
4. **D — DEPTH.** Regarder des fragments tomber à des profondeurs différentes. « Est-ce que ça renforce ma perception de verticalité ? »
5. **E — CLUTTER.** « Est-ce que ces morceaux gênent la lecture du Bone / curseur ? » Cible : **NON**. Vérifier aussi que la poussière ne paraît pas plus gênante.
6. **F — VERDICT, après dix minutes.** « Physics ON est-il clairement plus fun, ou juste plus compliqué ? » **KEEP** seulement si clairement plus fun ; **SIMPLIFY** si une partie suffit ; **DROP** si le gain ne justifie pas la complexité. La suite sera décidée séparément.
