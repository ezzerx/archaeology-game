# Rapport P4 — FINAL FEEL

**2026-10-04 · `prototype/p4-game-feel` · Godot 4.7.2 / Compatibility.**

Code vérifié : **`8394ee9eed8b5dd2b15fb901b5a7c6c7d77ee484`**. [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) **brouillon, non mergée**. Composition prête pour retest humain. **P4-V et P5 restent bloqués.** Source de vérité : [P4_FINAL_FEEL_TARGET](P4_FINAL_FEEL_TARGET.md).

## Composition issue du test A/B

Les worktrees identifient les références : **A `42ec46d`**, **B `c25b44f`**, version récente **E `f527139`**. Les préférences sont humaines ; les résultats ci-dessous vérifient l’implémentation, sans déclarer le plaisir validé.

| Origine | Ce qui est repris |
|---|---|
| P4-A | Taille/proportions des éclats Chisel, nombre lié aux cellules cassées, impulsion ascendante ; ancien angle des outils. |
| P4-B | Petits morceaux visibles qui suivent le jet et quittent la zone, largeur des miettes dures rendue comparable ; transport et hook de sortie conservés. |
| Version récente | Soil/Brush, poussière par matériau, ivoire Bone, Pick micro-Chisel, budget persistant, outils à pointe exacte, fracture, condition et caméra. |
| Nouvelle décision | Un petit son Bone à la première détection par reset ; un gros son sur hit direct réellement dommageable ; autres reveals = matière travaillée. |

Grammaire joueur inchangée : **matière attachée / saleté**. Soil → Brush ; matrice dure → Chisel ; détails proches de Bone → Pick ; mess → Brush/Blower.

## Chisel : spectacle indépendant de la saleté

| Paramètre visuel | Avant, E | FINAL FEEL |
|---|---:|---:|
| Émission | ≤3 éclats par impact | 1–5 par plaque cassée, `ceil(cells / 10)`, puis plafond du pool |
| Largeur nominale | 1,2–2,4 mm | **3–6 mm**, comme A |
| Hauteur / largeur Clay | 18 % | **24 %**, comme A |
| Hauteur / largeur Stone | 32 % | **70 %**, comme A |
| Profondeur / largeur | 75 % | **100 %**, comme A |
| Vitesse ascendante | 0,025–0,05 m/s | **0,035–0,10 m/s**, comme A |
| Vitesse radiale sortante | 0,09–0,14 m/s | Conservée |
| Durée | 0,51–0,69 s | Conservée |
| Pools | 4 × 48 | Conservés, 192 FX maximum |

Les éclats partent du **dessus estimé de la plaque arrachée** : hauteur du nouveau fond + `volume retiré / cellules × profondeur du bloc`. Un départ au fond cachait les morceaux dans les parois. Cette correction concerne uniquement le consommateur visuel ; marks → cracks → chunks, cadence, puissance, résistances et retrait restent exacts.

Les gros éclats expirent sans devenir du mess persistant. La sonde ordinaire atteint dix éclats sur un impact ; le benchmark de casse dense émet 182 FX durs Clay/Stone et 117 Stone en six secondes, avec respect des pools. Les captures réelles montrent leur contribution aux pixels à 1× comme à 3×.

## Blower et quantité persistante

**Quantités inchangées** : deux miettes par zone 24×24 texels, toutes matières partagées ; rétention ≤8 %, capacité 0,02 par miette ; excédent vers fine dust. Maximum 2 322 miettes au repos. Le budget libéré par nettoyage peut être réutilisé.

Seule la présentation Clay/Sandstone grandit : largeur maximale **1,4 → 4,5 mm**, hauteur **14 → 32 %**, échelle proportionnelle à la racine de la quantité. Écaille irrégulière conservée. B utilisait 4,5 mm nominalement, jusqu’à 6,75 mm et sans le plafond récent : cette accumulation ne revient pas. **Soil reste à 1,4 mm / 14 %**, même représentation, dust et audio qu’en E.

Le souffle conserve le transport B : jet lié au déplacement, 150 texels/s avec les réglages actuels, soulèvement visuel de 4–7 mm, sortie à la frontière et `debris_ejected`. La poussière part des cellules réellement nettoyées, reprend leur teinte locale et dérive dans son pool. Zéro changement de hauteur ou de condition.

Sonde graphique : **43 paquets** décollent dans le premier geste, **144 sorties** cohérentes sur le balayage complet. Benchmark : jusqu’à **129 paquets en vol + 48 bouffées** simultanés. Après **60 s simulées / 270 impacts sans cleanup**, les zones conservent **29 miettes Clay / 27 grès**, puis **zéro après Blower**, comme E. Le besoin réel de nettoyer reste à juger humainement.

## Bone audio, Pick et outils

- **Première détection du spécimen** : petit tik et signal Bone, une fois par reset, aucun dégât. Le nouveau champ `bone_first_contact` sépare cette transition des nouvelles cellules exposées.
- **Chisel direct sur Bone exposé avec baisse réelle de condition** : gros clack. Dégât historique inchangé, −3 points par impact, borné à zéro ; pas de faux signal de dommage supplémentaire une fois à zéro.
- **Autres impacts** : son Clay/Sandstone travaillé, même si des cellules Bone supplémentaires apparaissent. Si le retrait mélange les deux, le volume dominant choisit le timbre. Exposition et compteurs continuent à progresser.

Les **28 WAV historiques sont identiques à l’octet**. Brush continu, Pick et timbres validés conservés. Sonde audio : dans chaque cycle, 11 reveals purs Clay et 86 Stone supplémentaires gardent leur son de matière ; un seul tik Bone ; même résultat après reset.

**Pick inchangé** : six micro-impacts/s, clic ou maintien immobile, rayon 3, puissance 0,24, efficacités 0,30/1,00/1,50. Petit retrait efficace, sans plaques ni gros FX, interface initiale et plafond osseux, zéro dégât provisoire P4. Volume Chisel/Pick ≈17,80 dans le test d’une seconde.

**Angle A/B restauré** : Euler `(0.5, 0, -0.62)` pour les quatre outils, indépendant des normales. Pointe exacte ; manche rigide déplacé en hauteur seulement si nécessaire ; silhouettes récentes conservées. Dans la cavité synthétique quasi verticale de 10 cm, dégagement maximal **84,90 mm hors recul** et 93,97 mm avec recul : le connecteur s’allonge. Cette limite de placeholder reste à regarder en jeu. Sur le plat, aucun soulèvement au repos.

## Validation

**1 395 checks fonctionnels + 90 contrôles graphiques : zéro échec**, puis 28 scénarios de performance et oracle GPU. Les anciennes attentes « trois éclats de 2,4 mm maximum », « miettes dures de 1,4 mm » et « clearance ≤37 mm avec l’angle E » sont remplacées explicitement par la cible A/B.

- Fonctionnel : P0 45, P1 52, P2 97, P3 85, zoom 160 ; P4 core 61, pan 43, audio 33, dirt 27, budget 18, Pick 39, feedback 25, proxy 710.
- Graphique : accumulation/nettoyage 16, composition A/B 28, identité matière 46. Lecture de pixels avec/sans FX ; déplacement et sortie des paquets ; rendu Soil inchangé.
- Proxies : 35 contacts × quatre outils, 161 280 sommets et 107 520 points intérieurs ; pointe à moins de 1 µm, angle stable, manche rigide, dégagement et géométrie gameplay vérifiés.
- **4 432 rayons zoom, 387 pan, 225 roundtrips fracture**. Oracle GPU **194 955 pixels**, maps exactes ; erreur height ≤0,004825, matériau corrigé ≤0,010882, tolérances historiques inchangées.
- Condition : sonde attentive identique, 1 004 impacts → 49,87 % du crâne à 100 % ; dix hits directs →70 %. Cette sonde reconnaît parfaitement les centres exposés ; elle ne remplace pas le test humain.

Commande de reproduction :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

La première exécution graphique est restée en attente de capture et a été interrompue. Le benchmark relancé avec fenêtre à l’écran, puis les contrôles graphiques/GPU, ont tous terminé. Le lanceur place désormais explicitement les fenêtres ; ce premier run partiel est exclu des mesures ci-dessous. Les quatre cas denses ont été mesurés séparément avec le même code de production (`-- --dense-only`).

## Performance

RTX 5080 / Ryzen 7 9800X3D, 1080p Compatibility ; 28 scénarios de six secondes, input physique 60 Hz, FX et mixer actifs, bus muet. Fixtures/captures hors timing. **Cap 240 FPS / physique 60 Hz** inchangés.

| Scénario | FPS 1× / 3× | P95 1× / 3×, ms |
|---|---:|---:|
| Brush / Soil | 106,95 / 96,56 | 18,148 / 19,249 |
| Chisel / Clay | 239,86 / 239,87 | 4,294 / 4,289 |
| Chisel / Sandstone | 239,86 / 239,87 | 4,306 / 4,303 |
| Chisel dense / Clay | 239,80 / 239,83 | 4,303 / 4,298 |
| Chisel dense / Sandstone | 239,83 / 239,86 | 4,302 / 4,316 |
| Chisel près de Bone | 239,55 / 239,74 | 4,337 / 4,292 |
| Blower cleanup | 239,97 / 239,93 | 4,774 / 4,762 |
| Bloc sale au repos | 239,87 / 239,87 | 4,263 / 4,265 |
| Pick / Bone | 239,77 / 239,83 | 4,294 / 4,291 |
| Pick / Clay | 239,69 / 239,68 | 4,307 / 4,304 |
| Pick / Sandstone | 239,83 / 239,75 | 4,304 / 4,331 |
| Proxy / cavité profonde | 233,47 / 234,48 | 8,984 / 8,909 |
| Proxy / Bone | 232,62 / 233,75 | 9,647 / 9,596 |
| Dusty Bone | 239,87 / 239,87 | 4,286 / 4,286 |

**96,56–239,97 FPS**, P95 maximal **19,249 ms**, frame maximale **29,850 ms**. Casse dense et cleanup restent proches de 240 FPS ; la moyenne dépasse 60 dans tous les cas. Le coût de pose Brush/Soil monte à **3,60–3,97 ms en moyenne**, contre 0,89–1,10 ms avec l’angle plus vertical E ; Soil passe de 169–190 à 97–107 FPS. Le budget moyen est tenu, sans garantie que chaque frame reste sous 16,67 ms. Aucun réglage de gameplay Soil modifié.

## Preuves et limites

[Validation](evidence/p4-feel-validation.json) · [28 benchmarks](evidence/p4-feel-benchmark.json) · [composition rendue](evidence/p4-feel-composition-visual.json) · [dust/cleanup](evidence/p4-feel-feedback-visual.json) · [matières](evidence/p4-feel-material-visual.json) · [GPU](evidence/p4-feel-gpu.json) · [condition](evidence/p4-feel-condition.json).

- Chisel : [Clay 1×](evidence/p4-feel-clay-1x-flight.png) / [3×](evidence/p4-feel-clay-3x-flight.png), [Stone 1×](evidence/p4-feel-stone-1x-flight.png) / [3×](evidence/p4-feel-stone-3x-flight.png).
- Blower 1× : [avant](evidence/p4-feel-blower-1x-before.png) → [vol visible](evidence/p4-feel-blower-1x-travel.png) → [propre](evidence/p4-feel-blower-1x-clean.png). 3× : [avant](evidence/p4-feel-blower-3x-before.png) → [décollage](evidence/p4-feel-blower-3x-airborne.png) → [trajet](evidence/p4-feel-blower-3x-travel.png) → [propre](evidence/p4-feel-blower-3x-clean.png).
- Après une minute simulée : [Clay 1×](evidence/p4-feel-clay-60s-dirty-1x.png) / [3×](evidence/p4-feel-clay-60s-dirty-3x.png), [Stone](evidence/p4-feel-stone-60s-dirty-3x.png) ; après nettoyage [Clay](evidence/p4-feel-clay-60s-clean-3x.png) / [Stone](evidence/p4-feel-stone-60s-clean-3x.png).
- Angle fixe : [Brush en cavité](evidence/p4-feel-deep-proxy-0.png), [Chisel au bord](evidence/p4-feel-deep-edge-proxy-1.png), [Pick près de Bone](evidence/p4-feel-bone-proxy-3.png). Ivoire préservé : [Bone sale 1×](evidence/p4-feel-bone-dirty-1x.png) / [3×](evidence/p4-feel-bone-dirty-3x.png).

Ce sont des visuels placeholders. Le départ des éclats est une estimation moyenne de plaque ; pas de fragments géométriques reconstruits ni collision sur le relief mobile. Les miettes suivent le transport simplifié B ; pas de gravité terrain, glissement dans les cavités ou table salissable. Pigment approximé par le matériau local, sans nouvelle map. **P4-V, macro-stratigraphie, variations de profondeur, Forceps, P5, art pass et tuning final exclus.** La modification locale préexistante de `project.godot` est préservée et exclue des commits.

## Retest humain — exactement sept points

Ouvrir `project.godot` dans Godot 4.7.2, **F5**, masquer **F1**, réglages par défaut. Outils **1/2/3/4**, nouveau clic après changement ; Pick par clic ou maintien immobile.

1. **CHISEL** — « Est-il revenu au niveau de satisfaction de P4-A ? » Voir et ressentir que la matière casse réellement.
2. **PERSISTENT CLUTTER** — Après environ une minute de Chisel : « La scène reste-t-elle lisible ? »
3. **BLOWER** — Nettoyer : « Est-ce aussi satisfaisant que P4-B ? » Voir clairement des éléments quitter la scène.
4. **AUDIO** — Travailler le grès autour d’un os : son Sandstone la majorité du temps ; premier Bone = petit tik unique ; erreur directe sur Bone exposé = gros DING et perte de condition.
5. **PICK** — Finir les contours d’un os : rapide, précis, sûr, sans grosses plaques.
6. **TOOL ANGLE** — Vérifier la stabilité visuelle des quatre outils, y compris près des parois.
7. **LONG PLAY** — Jouer 10–15 minutes : « Est-ce que casser ET nettoyer sont tous les deux satisfaisants ? »

**STOP après livraison. PR #5 BROUILLON, NON MERGÉE. La prochaine décision dépend du test humain ; aucune autorisation de P4-V ou P5.**
