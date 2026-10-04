> Archive : restauration 4,5 mm validée humainement dans la demande de clôture. Les budgets et mesures ci-dessous précèdent cette passe. Rapport courant : [P4V2_REPORT](P4V2_REPORT.md).

# P4-V2 — Look P4-V1 restauré, physique conservée

2026-10-04 · `prototype/p4v2-debris-physics` · [PR #7](https://github.com/ezzerx/archaeology-game/pull/7) **DRAFT, aucun merge**. Correction et tests : **`a58fe1a`**. Baseline visuelle validée : `ce014d0c2dd311ed2fbac0f37e0001be707a74a7`. [Brief courant](P4V2_BRIEF.md).

## Décision humaine et restauration

Antoine rejette les micro-débris de `8f703ae` : trop petits, discrets et peu intéressants à nettoyer. La cible confirmée est **MÊMES DÉBRIS QU’AVANT, AVEC UN PEU DE PHYSIQUE**. Le passage de 4,5 à 2,2 mm était un redesign indésirable, pas une nécessité physique. Le précédent [rapport à 2,2 mm](P4V2_CRUMBS_MICRO_REPORT.md) et ses preuves sont conservés comme historique rejeté.

- **Largeur maximale Clay/Sandstone : 4,5 mm**, directement reprise de P4-V1, en ON et OFF. Épaisseur **32 % /1,44 mm max**, profondeur **75 % /3,375 mm max**, taille selon racine de la quantité : formules historiques conservées.
- Même mesh asymétrique, mêmes couleurs, contraste des faces et matériau. Soil reste **1,4 mm**. Aucun nouveau modèle de débris, matériau ou éclairage.
- Même rétention **8 %**, capacité **0,02**, **deux miettes par zone de naissance 24×24 texels**, stride 8. Aucun filtrage ou baisse de quantité supplémentaire.
- Le **cap global V2 128** reste une limite de charge : après saturation, surplus vers Dust, jamais éviction. Il est la seule différence dans `config/debris_profile.tres` par rapport à la baseline P4-V1 ; tous ses paramètres visuels et locaux sont restaurés/exacts.
- Gros éclats transitoires Chisel **inchangés**, déjà revenus au spectacle P4-V1 : 3–6 mm, 1–5 par plaque, 0,51–0,69 s. Outils, verticalité, Bone, Dust, audio et proxies inchangés.

## Physique conservée comme comportement

Aucune modification de `TerrainDebris`, `LooseDebris` ou des paramètres de mouvement dans cette passe. La taille restaurée alimente simplement le rendu et son enveloppe de contact existante. Un seul noyau, 128 slots préalloués, MultiMesh fixe, aucun Node par miette.

Petit kick initial **0,035 m/s latéral /0,025 vertical**, gravité **0,65 m/s²**, restitution Clay/Stone **0,12/0,22**, amortissement, relief courant, glissement court puis sommeil **sans fade ni expiration**. Creuser le support réveille la miette. Brush retire progressivement à sa position actuelle ; Blower réveille et déplace sa quantité entière (impulsion/lift **5,0/1,8 par seconde**, caps **0,80/0,22 m/s**). Éjection unique avec quantité restante réelle et budget libéré. Aucun changement des ressources outils.

F3 conserve l'A/B **Crumb Physics OFF/ON** sur la même échelle P4-V1. R vide tout et garde le mode. F1 affiche compte, mouvement, sommeil, sondes et CPU.

Limites conservées : support par heightfield sous le centre et enveloppe orientée ; pas de collision volumique latérale/entre miettes ni d'occlusion du jet par les parois. Le budget local reste attaché à la naissance. La physique peut déplacer/regrouper les saletés et modifier le nettoyage futur ; aucune promesse de disposition pixel-identique ON/OFF.

## Vérification du look et de la quantité

Huit captures réelles : Clay/Sandstone ×1×/3× ×OFF/ON. Trois zones fracturées par le vrai Chisel, puis trois secondes de simulation pour laisser disparaître les gros éclats. Chaque comparaison fige les positions/quantités et réduit **seulement les transforms de rendu** à 2,2/4,5 pour mesurer la perte de présence de la miniaturisation. Ce n'est pas une comparaison de deux trajectoires différentes.

**32 contrôles verts** : couverture visible multipliée par **3,67 à 4,10** à quantité/position identiques. Chaque fixture conserve **20 miettes**, avec quantité exactement identique ON/OFF (Clay **0,314929**, Stone **0,125100** unités normalisées). Cela vérifie la présence sans artificiellement augmenter la densité. Le ressenti reste à valider par Antoine.

[Clay restaurée à 3×](evidence/p4v2-look-clay-3x-on-restored.png) · [référence micro à mêmes positions](evidence/p4v2-look-clay-3x-on-micro-reference.png) · [Sandstone restaurée à 1×](evidence/p4v2-look-stone-1x-on-restored.png) · [mesures visuelles](evidence/p4v2-look-visual.json).

## Tests et impact performance

- **1 782 contrôles fonctionnels uniques** : 1 691 historiques +91 V2. Rejeux interprocessus identiques, mêmes neuf empreintes géologiques. Aucun seuil structurel/Bone/outils relâché.
- **28 contrôles GPU Final Feel +38 contraste/interfaces** verts. Le seuil de présence historique **>3 mm** est rétabli ; la fixture élargie pour compenser les micro-débris est retirée. Le test de contraste P4-V1 sur une seule fracture passe à ses seuils d'origine.
- **8 contrôles GPU physiques** : dimensions pleines exactement 4,5×1,44 mm, XYZ rendu = XYZ physique, chute en cavité, sommeil 30 s, réveil Blower et Brush au point déplacé. Chute de **67,64 mm**, dessous à **25,15 mm** sur le fond de 25 mm. Sommeil 100 s sur plat toujours vérifié.
- Les 36 scénarios dédiés sont rejoués : 0/32/64/128 miettes, cavité, Blower au cap, Brush, Chisel Clay/Stone, ON/OFF et 1×/3×. Les 60 benchmarks historiques complets du passage précédent ne sont pas rejoués : les outils et leurs chemins CPU restent inchangés ; les cas directement affectés sont couverts par ce profiling et les visuels ci-dessus.

**36 scénarios /202 assertions verts**, minimum sur une seconde **238,70 FPS**. Aucun dépassement de 16,67 ms dans les frames de ce profiling. Le budget de performance reste respecté avec l'échelle restaurée.

| Mesure, mêmes 36 cas | Ancienne passe 2,2 mm | Look restauré 4,5 mm |
|---|---:|---:|
| FPS moyens | 239,80–239,87 | **239,78–239,87** |
| Pire P95 frame | 6,342 ms | **6,556 ms** |
| Frame maximale | 11,839 ms | **12,202 ms** |
| Noyau physique ON, pire P95 /max | 1 072 /4 137 µs | **1 016 /4 248 µs** |
| MultiMesh, pire P95 /max, tous modes | 210 /763 µs | **209 /706 µs** |
| Sondes max/tick, miettes max | 1 280 /128 | **1 280 /128** |

Le P95 maximal varie de **+0,214 ms** entre ces passages locaux ; il ne faut pas attribuer causalement cette différence à la taille seule. Aucun nouveau mesh, slot ou système physique. Blower éjecte toujours **128/128** avec **2,56 unités** conservées dans chaque cas de cap ; Brush nettoie les 128. La présence restaurée ne nécessite donc pas de relâcher le budget ni les seuils.

Machine : Godot **4.7.2 Compatibility**, RTX 5080 / Ryzen 7 9800X3D, 1920×1080, cap **240 FPS**, physique **60 Hz**. Éditeur et autre instance utilisateur laissés ouverts ; mesures locales, non isolées. Les captures sont séparées du chronométrage. Les coûts de noyau n'incluent pas tout le bookkeeping ; les FPS complets l'incluent.

[Tests fonctionnels](evidence/p4v2-look-tests.json) · [journal](evidence/p4v2-look-functional.txt) · [benchmark](evidence/p4v2-look-benchmark.json) · [comparaison de performance](evidence/p4v2-look-performance.json).

Reproduction : `tests/check_p4v2.ps1 -GodotBin '<Godot 4.7.2 console>' -Graphical`. `-SkipRegression` limite à V2 et ses captures. La modification locale préexistante de `project.godot` reste intacte, hors commits.

## Retest humain — quatre questions

Relancer le prototype. **F3 OFF → R → zone**, puis **ON → R → même zone**, à 1× et 3× ; masquer F1 pour juger le ressenti. Cible **OUI** aux quatre questions.

1. **VISIBILITÉ** : « Est-ce que les petits débris sont revenus à une présence visuelle satisfaisante ? »
2. **IDENTITÉ** : « Est-ce que ça ressemble à nouveau aux débris persistants que je voulais nettoyer ? »
3. **PHYSIQUE** : « Est-ce qu’ils ont juste ce qu’il faut de mouvement pour être plus naturels ? »
4. **BLOWER** : « Est-ce que le blower les chasse mieux tout en les laissant bien visibles avant nettoyage ? »

**STOP pour ce retest. PR #7 DRAFT, aucun merge ni P5. Aucune validation humaine de cette restauration n'est encore acquise.**
