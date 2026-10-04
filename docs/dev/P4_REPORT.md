# Rapport P4 — FINAL FEEL, bugfix ciblé

**2026-10-04 · `prototype/p4-game-feel` · Godot 4.7.2 / Compatibility.**

Code vérifié : **`59f7e2184076094741aa8191488288fc84d4e99e`**. [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) **brouillon, non mergée**. Deux corrections autorisées : coût du proxy Brush et protection du premier contact direct Bone. Le reste du Final Feel est jugé plutôt bon par Antoine. **P4-V et P5 restent bloqués.** Source de vérité : [P4_FINAL_FEEL_TARGET](P4_FINAL_FEEL_TARGET.md).

## Brush : diagnostic mesuré avant correction

Le signalement humain est une chute **sous 10 FPS** pendant Brush → Soil → mouvement continu. Cette chute précise n’a **pas été reproduite** dans le benchmark autonome ; le surcoût du proxy est en revanche isolé quantitativement. La référence avant correction est `70349ab`, avec seulement des compteurs temporels et un interrupteur de diagnostic pour masquer/désactiver les proxies sans couper les autres effets.

Même scène 1080p, RTX 5080 / Ryzen 7 9800X3D, réglages de jeu inchangés, cap 240 FPS / physique 60 Hz. Pour chaque zoom : Brush immobile six secondes, mouvement de 30 secondes partant de Soil intact, mouvement six secondes dans une zone déjà creusée. Chaque geste est rejoué avec et sans proxy, soit douze cas avant et douze après. Rendu, audio et effets actifs ; bus muet. Préparation, reset et captures exclus du chronométrage.

**Cause vérifiée : le solveur de dégagement du proxy reconstruisait ses meshes pendant le jeu.** Un changement de contact ou d’upload invalidait la pose ; les neuf pièces Brush déclenchaient scans rectangulaires du relief, duplication des positions, sondes de faces, normales et `clear_surfaces/add_surface_from_arrays`. En zone creusée, couper seulement le proxy faisait passer **120,32 → 236,11 FPS à 1×**, et **125,54 → 235,97 FPS à 3×**. Les uploads et effets étaient beaucoup plus petits.

Sonde CPU isolée avant fix, 120 poses en zone creusée : jusqu’à **1 498 lectures de sommets terrain par pose**, **729 notifications de modification de mesh**, P95 du fit **10 823 µs**. Doubler la densité linéaire du relief portait ces lectures à **5 495**, P95 **15 333 µs**. Le coût dépendait donc de la géométrie/du relief, malgré le cache. Cela établit la régression du proxy, sans attribuer artificiellement les <10 FPS non reproduits à un autre facteur non mesuré.

## Proxy après simplification

`ToolRoot` garde la base exacte **`Basis.from_euler(Vector3(0.5, 0, -0.62))`**. Deux enfants : **Tip**, pointe réelle au hit, et **Body**, manche/corps statiques. La silhouette existante est séparée une seule fois à quatre millimètres du contact lors de l’initialisation.

En jeu : au plus **douze sondes de hauteur** réparties sur trois sections du corps ; un simple déplacement vertical, aucun recalcul des sommets/normales, aucune reconstruction de surface, aucun scan de zone ni duplication de vertex arrays. Dégagement réutilisé si contact/height inchangés ; le recul déplace Body et ne relance pas les sondes. Zéro soulèvement au repos sur le plat ; pointe et angle inchangés même avec une normale presque horizontale.

La sonde CPU après fix relève **48 lectures de sommets maximum**, même avec densité doublée, **zéro modification de mesh**, P95 **37 µs** en zone creusée. Les tableaux de sommets/normales et ressources restent identiques sur tous les contacts. La cavité synthétique extrême demande jusqu’à **83,14 mm de déplacement, recul compris**. De rares petites intersections ou une séparation pointe/corps dans ce cas extrême sont acceptées par la priorité humaine : fluidité, angle stable, contact lisible, puis anti-clipping. Aucun retour au suivi des normales.

## Performance avant / après

Proxy actif dans les deux colonnes. Temps de frame en ms, coût proxy au P95 en µs.

| Scénario | FPS avant → après | P95 frame avant → après | Frame max avant → après | Proxy P95 avant → après |
|---|---:|---:|---:|---:|
| Immobile 1× | 146,27 → 231,69 | 13,178 → 12,502 | 25,128 → 17,486 | 5 515 → 33 |
| Immobile 3× | 156,63 → 237,75 | 12,378 → 12,058 | 20,008 → 13,908 | 5 309 → 31 |
| Soil en mouvement 30 s, 1× | 143,57 → **232,59** | 17,860 → **12,537** | 30,367 → **18,205** | 8 616 → **32** |
| Soil en mouvement 30 s, 3× | 154,03 → **235,60** | 17,027 → **12,265** | 34,910 → **17,400** | 8 432 → **32** |
| Zone creusée 1× | 120,32 → 236,76 | 19,817 → 12,162 | 34,417 → 15,668 | 9 574 → 32 |
| Zone creusée 3× | 125,54 → 237,08 | 17,562 → 12,080 | 35,789 → 14,696 | 9 132 → 32 |

Après fix, proxy actif/désactivé : **232,59 / 233,10 FPS à 1×**, **235,60 / 236,66 à 3×** sur les gestes de 30 s, moins de 0,5 % d’écart. Les six comparaisons restent à moins de 1 % ; les empreintes finales height, residue et débris, les cellules modifiées, exposure et condition correspondent avant/après et avec/sans proxy. Le Brush n’a pas été retuné.

Détail CPU du geste de 30 s à 1×, **moyenne / P95**, en µs. ToolController inclut WorkingSurface et le consommateur synchrone : ces lignes ne s’additionnent pas. Proxy/particules/débris sont mesurés par frame rendue, édition/uploads par tick physique.

| Mesure | Avant | Après |
|---|---:|---:|
| ToolController `edit_usec` | 8 188,7 / 9 185 | 7 897,1 / 8 445 |
| WorkingSurface seul | 8 161,4 / 9 152 | 7 871,7 / 8 412 |
| RF height upload | 131,7 / 156 | 123,0 / 139 |
| Residue upload | 10,0 / 20 | 7,6 / 10 |
| Total `upload_usec` | 141,7 / 172 | 130,6 / 148 |
| `proxy_usec` | 1 918,9 / 8 616 | 15,4 / 32 |
| Feedback synchrone de l’action | 22,2 / 31 | 20,8 / 28 |
| Particules | 55,1 / 80 | 53,7 / 72 |
| Rendu des débris persistants | 45,4 / 127 | 27,8 / 111 |

Les JSON contiennent aussi les maxima et toutes ces mesures à 3×. Les moyennes dépassent largement 60 FPS et tous les P95 après correction sont sous 16,67 ms ; quelques frames isolées atteignent 18,205 ms. Le test autonome ne remplace pas le retest humain de 30–60 s dans les conditions du signalement.

## Bone : découverte et premier contact direct distincts

Cause : `FossilState.first_contact` suivait la **première exposition**, et le chemin de dommage pénalisait immédiatement tout centre déjà exposé. Une révélation adjacente pouvait ainsi jouer le tik de découverte, puis laisser le premier vrai coup direct faire −3 points.

`first_contact` reste la découverte/UI, avec les mêmes cellules exposées et compteurs. Le nouvel état **`first_direct_contact_consumed`**, initialement faux, est indépendant et réarmé au reset. Seul le centre exact d’un impact d’outil dommageable et de puissance positive peut le consommer. Actuellement, seul Chisel remplit cette condition.

| Action | Protection / condition | Son |
|---|---|---|
| Révélation adjacente, même première | Protection disponible ; 100 | Matériau travaillé |
| Premier Chisel direct sur Bone exposé | `bone_protected_contact = true`, dégâts 0 ; 100 ; protection consommée | Petit tik |
| Deuxième Chisel au même point | Protection fausse, dégâts historiques 3 ; 97 | Gros DING |
| Reset | Protection réarmée ; 100 | État audio réinitialisé |
| Pick, Brush, Blower avant Chisel | Aucun dégât, aucune consommation | Audio propre à leur travail |

Un impact qui révèle Bone **au centre** peut être le contact protégé : tik, zéro dégât et protection consommée. Une révélation seulement ailleurs dans le footprint ne le peut jamais. Après consommation, une nouvelle cellule précédemment cachée reste sans dommage sur l’impact qui la découvre, comme avant ; seuls les centres déjà exposés prennent les dégâts ultérieurs. À condition zéro, aucun faux son de dommage. Les **28 WAV historiques restent identiques**.

Tests : séquence A–F du signalement, centre caché atteint dans le même impact, reset, Pick révélant l’os avant Chisel, Brush/Blower, dommage réel borné à zéro, entrée réelle souris/focus/changement d’outil. Deux cycles de révélations adjacentes : **11 Clay et 86 Stone supplémentaires**, aucun son Bone, aucune consommation de protection.

## Acquis Final Feel conservés

- **Chisel A `42ec46d`** : marks → cracks → chunks, éclats 3–6 mm, 1–5 par plaque cassée, départ au dessus estimé du morceau, durée 0,51–0,69 s, pools 4 × 48 ; aucune modification de fracture, cadence, puissance ou résistances.
- **Blower B `c25b44f`** : miettes dures visibles jusqu’à 4,5 mm, vol directionnel et sortie de frontière ; hook `debris_ejected`. Zéro retrait structurel ou dommage.
- **Quantités persistantes** : deux miettes par zone 24×24, rétention 8 %, capacité 0,02 ; Soil à 1,4 mm / 14 %. Dust locale, ivoire Bone, effets de souffle inchangés.
- **Pick** : six micro-impacts/s, rayon 3, puissance 0,24, efficacités 0,30/1,00/1,50, interface et plafond osseux, zéro dégât provisoire P4. Rapport de volume Chisel/Pick toujours 17,80.
- **Caméra/input** : zoom 1–3×, RMB pan borné, Home et R, touches/debug, picking exact ; 240 FPS / physique 60 Hz.

## Validation et preuves

**1 430 checks fonctionnels + 90 contrôles graphiques, zéro échec**, puis six cas CPU de pose, douze comparaisons Brush après correction et 28 scénarios graphiques généraux. Ces derniers donnent **234,21–240,00 FPS**, P95 maximal **12,291 ms**, frame maximale **16,883 ms**. Le test d’entrée P3 est explicitement adapté au premier contact direct protégé, puis vérifie la pénalité habituelle au clic suivant.

Oracle GPU **194 955 pixels**, height ≤0,004825, matériau corrigé ≤0,010882, mêmes tolérances et maps exactes ; **4 432 rayons zoom, 387 pan, 225 roundtrips fracture**. Sonde attentive inchangée : 1 004 impacts → 49,87 % du crâne, condition 100 ; la protection ayant déjà été consommée par un centre découvert pendant cette sonde, dix hits sur os visible →70.

Chisel/Blower : pixels d’éclats réels aux deux zooms, 43 paquets au premier souffle et 144 sorties ; après une minute simulée de Chisel, 29/27 miettes Clay/grès, zéro après nettoyage. Soil golden, Pick et identité des matières passent. Configuration des outils, fracture, transport, audio généré, shaders et caméra identiques au commit de référence.

Les anciennes assertions de dégagement de toutes les faces du proxy sont remplacées par les exigences explicitement demandées : pointe exacte, base stable, meshes statiques, zéro effet gameplay, nombre borné de sondes et comparaison CPU/graphique. La régression ne repose donc pas seulement sur un seuil FPS fragile en headless.

[Brush avant](evidence/p4-bugfix-brush-before.json) · [Brush après](evidence/p4-bugfix-brush-after.json) · [coût proxy avant](evidence/p4-bugfix-proxy-cost-before.json) · [coût proxy après](evidence/p4-bugfix-proxy-cost-after.json) · [validation du bugfix](evidence/p4-bugfix-validation.json).

[28 scénarios](evidence/p4-bugfix-benchmark.json) · [composition rendue](evidence/p4-bugfix-composition-visual.json) · [dust/cleanup](evidence/p4-bugfix-feedback-visual.json) · [matières](evidence/p4-bugfix-material-visual.json) · [GPU](evidence/p4-bugfix-gpu.json) · [condition](evidence/p4-bugfix-condition.json). Proxies inspectés : [Brush en cavité](evidence/p4-bugfix-deep-brush.png), [Chisel au bord](evidence/p4-bugfix-deep-edge-chisel.png), [Pick/Bone](evidence/p4-bugfix-bone-pick.png).

Reproduction complète :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

Les preuves A/B de la composition précédente restent archivées sous `evidence/p4-feel-*`. Les preuves actuelles du bugfix utilisent `p4-bugfix-*`. La modification locale préexistante de `project.godot` est préservée et exclue des commits. Aucun merge, P4-V, physique des débris, verticalité ou P5.

## Retest humain — exactement trois points

Ouvrir `project.godot` dans Godot 4.7.2, **F5**, masquer **F1**, réglages par défaut.

1. **BRUSH PERF** — Reset, puis Brush sur Soil pendant **30–60 s** : aucune chute massive, jeu fluide, sensation Soil inchangée.
2. **BONE PROTECTION** — Révéler un os en cassant la matrice autour. Premier hit Chisel direct : **petit tik, condition 100**. Deuxième au même endroit : **gros DING, perte de condition**.
3. **QUICK SANITY** — Chisel + Blower + Pick pendant quelques minutes : vérifier que les autres sensations sont conservées.

**STOP après correction. PR #5 BROUILLON, NON MERGÉE. P4-V et P5 restent interdits sans nouvelle autorisation explicite.**
