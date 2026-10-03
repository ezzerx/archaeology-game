# Rapport P4 — Simplification finale après test humain

**2026-10-03 · `prototype/p4-game-feel` · Godot 4.7.2 stable / Compatibility.**

Code vérifié : **`f62fccfb3f6d1572e42f8ad3a3ec98b9691a3e14`**. Les commits suivants ne portent que documentation et preuves. [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) **en brouillon, non mergée**. Nouveau test humain attendu ; **P5 interdit**.

## Résultat de la passe

Le core validé reste intact : Chisel fun, marks → cracks → chunks, Clay/Sandstone, profondeur, condition plus juste, sons de découverte/hit direct, Brush audio, zoom, pan et picking. Cette passe simplifie la lecture : **matière attachée / saleté**, avec quatre rôles évidents.

| Besoin | Outil |
|---|---|
| Soil | Brush |
| Matrice dure en volume | Chisel |
| Détails attachés près de Bone | Precision Pick |
| Saleté, poussière et minuscules miettes | Brush local / Blower large |

Les anciens états internes restent utiles, mais Loose Debris n’est plus un concept à apprendre. F1 et le rappel d’outils suivent cette grammaire. Les écailles déjà réduites restent ≤1,4 × 0,196 mm, deux par zone 24×24 texels ; elles se nettoient comme le reste de la saleté.

## Bone et couleur de poussière

**Règle verrouillée : “Dust may obscure detail, never material identity.”**

La poussière sur Bone couvre au maximum **23,92 %** du mélange et garde une teinte ivoire terni. Au moins **76,08 %** de l’ivoire original demeure ; roughness/specular restent distincts de la pierre même à saturation. Aucune conséquence sur l’exposition ou Bone Condition.

Poussière contextuelle : **Soil brun terreux ; Clay ocre/rouge brun atténué ; Sandstone beige/crème chaud ; Bone ivoire sali**. Le matériau actuellement sous le dépôt sert d’approximation locale, sans map supplémentaire ou historique de pigment. Les amas persistants restent visibles à 1×/3×. Le Blower conserve son soulèvement depuis les cellules réellement nettoyées et reprend leur teinte locale.

## Outils et éclats

Orientation fixe, indépendante des normales et de la profondeur. Pointe réelle au hit ; manche gardant la même direction à l’écran. Silhouettes resserrées. Le contrôle local soulève uniquement le corps, rigidement en Y ; les quatre premiers millimètres de la pointe raccordent ce déplacement au contact. Recul vertical du corps, sans rotation ni déplacement du picking.

Aucun lift au repos sur le plat. Les contacts ordinaires demandent peu ou pas de dégagement ; le cas synthétique extrême d’une cavité quasi verticale de 10 cm atteint **36,32 mm hors recul**. Il reste explicitement dans le retest visuel. Topologie/cache locaux conservés, aucune simulation physique supplémentaire.

Éclats Chisel : **trois maximum par impact par défaut**, **1,2–2,4 mm**, aplatis. Départ à ≥4 mm du centre, vitesse sortante 0,09–0,14 m/s ; au-delà de 12 mm après 100 ms dans le test. Durée **0,51–0,69 s**, pools inchangés à 192 FX maximum. **Fracture et retrait structurel inchangés.**

## Precision Pick : micro-Chisel sûr

**Clic court ou LMB maintenu, même immobile.** Cadence existante du contrôleur, six impacts par seconde. L’ancien SCRAPE, la vitesse minimale et le retrait lent limité à 0,004 par passage sont supprimés.

| Paramètre | Nouvelle valeur |
|---|---:|
| Mode / cadence | IMPACT / 6 Hz |
| Rayon / falloff | 3 texels / 1,5 |
| Puissance par impact | 0,24 |
| Efficacités Soil / Clay / Sandstone | 0,30 / 1,00 / 1,50 |
| Poussière / nettoyage | 1,25 / 0 |
| Dégât Bone | 0, provisoire P4 |

Retrait direct sur un disque minuscule, sans stress ni grosses cellules/chunks. Chaque coup respecte l’interface de départ et le plafond osseux, sans marge. **Un clic central : 0,08 Clay / 0,045 Sandstone**, soit **8,16 / 4,59 mm** si la couche disponible le permet. La petite surface rend le Pick mauvais en volume : test d’environ une seconde, Chisel **17,80 fois** supérieur, malgré le retrait rapide au centre. Crâne et côtes peuvent être finis jusqu’au plafond sans dommage.

Petit recul, son discret à chaque impact utile. Les sons historiques, la règle Chisel, les résistances et les ressources Brush/Chisel/Blower n’ont pas changé. Seul le Pick a été retuné.

## Tests vérifiés

**1 376 checks fonctionnels + 62 contrôles graphiques, zéro échec**, plus benchmark et oracle GPU. Les attentes obsolètes « Pick immobile inactif », « grattage à profondeur limitée », « outil suivant le plan tangent » et « gros éclat durant 1–2 s » ont été remplacées explicitement par les décisions de cette passe ; les régressions historiques restent vertes.

- Pick : cadence réelle immobile, trois clics courts, Clay/grès immédiats, petit footprint, absence de plaque, couche initiale, plafonds crâne/côtes, découverte distincte du hit, zéro dégât et reset.
- Proxies : 35 positions × quatre outils, **161 280 sommets et 107 520 points intérieurs de face**, plat/pente/cavité/os/fracture. Pointe à moins de 1 µm du hit, sommets dégagés à 2 µm près, faces à 0,1 mm près. Manche rigide, angle/mesh identiques quand seule la normale change. Aucune modification du gameplay.
- Chunks : taille, budget, vitesse radiale, dégagement du centre, extinction sans perte de saleté persistante.
- Mess : Brush/Blower nettoient les miettes ; Pick retire les vrais restes attachés ; sources et quantités du dust lift-off conservées.
- Graphique : 16 contrôles accumulation/persistance/nettoyage, **46 contrôles de matière à 1×/3×**. Shader de production rendu, puis copie temporaire sans éclairage pour lire roughness/specular/couverture. Aucun mode de test ajouté au jeu.
- **28 WAV historiques identiques à l’octet** à `c25b44f` ; Brush continu et sons osseux conservés.
- **4 432 rayons zoom, 387 pan, 225 roundtrips fracture** ; oracle GPU **194 955 pixels**, cartes byte exactes, erreur height maximale 0,004825 < 0,01 et matériau corrigé 0,010882 < 0,02. Tolérances P3 inchangées.

Sonde Chisel attentive identique : **1 004 impacts**, 4 105 cellules osseuses, **49,87 % du crâne à 100 %** ; dix hits directs → 70 %. Cette sonde reconnaît parfaitement les centres exposés ; ce n’est pas une preuve de confort humain.

Commande complète :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

## Performance

RTX 5080 / Ryzen 7 9800X3D, 1920×1080, Compatibility. **24 scénarios de six secondes**, FX/mixer actifs, bus muet, fixtures et captures hors timing. **Cap 240 FPS / physique 60 Hz** conservés.

| Scénario | FPS 1× / 3× | P95 1× / 3×, ms |
|---|---:|---:|
| Brush / Soil | 190,25 / 169,27 | 12,322 / 13,365 |
| Chisel / Clay | 239,87 / 239,87 | 4,309 / 4,300 |
| Chisel / Sandstone | 239,87 / 239,87 | 4,306 / 4,327 |
| Chisel près de Bone | 239,87 / 239,87 | 4,329 / 4,299 |
| Blower cleanup | 240,01 / 239,91 | 4,763 / 4,812 |
| Bloc sale au repos | 239,87 / 239,87 | 4,271 / 4,273 |
| Pick / Bone | 239,87 / 239,87 | 4,355 / 4,295 |
| Pick / Clay | 239,87 / 239,87 | 4,303 / 4,305 |
| Pick / Sandstone | 239,87 / 239,87 | 4,335 / 4,380 |
| Proxy / cavité profonde | 238,37 / 238,27 | 6,316 / 6,439 |
| Proxy / Bone | 239,23 / 239,38 | 4,398 / 4,404 |
| Dusty Bone | 239,87 / 239,87 | 4,313 / 4,317 |

**169,27–240,01 FPS**, P95 maximal **13,365 ms**, frame maximale **20,944 ms**. Budget d’interaction ≥60 FPS tenu sur cette machine ; la mesure sur une fenêtre finie peut légèrement dépasser 240. Le coût moyen de pose Brush/Soil passe à environ **0,89–1,10 ms**, contre 3,2–3,3 ms à la passe précédente.

Pick : 36 impacts sur chaque run de six secondes, condition 100 %, aucun stress/chunk. Bloc saturé au repos : 2 322 miettes et aucun upload height. Blower : géométrie exacte. Sessions de 60 secondes simulées de Chisel : 29 miettes Clay / 27 Sandstone, puis zéro après souffle. Elles ne prédisent pas la cadence de nettoyage humaine.

## Preuves et limites

[Validation](evidence/p4-final-validation.json) · [benchmark](evidence/p4-final-benchmark.json) · [rendu/cleanup](evidence/p4-final-feedback-visual.json) · [matières](evidence/p4-final-material-visual.json) · [oracle GPU](evidence/p4-final-gpu.json) · [condition](evidence/p4-final-condition.json).

Captures du renderer :

- Bone 1× [propre](evidence/p4-final-bone-clean-1x.png) / [saturé](evidence/p4-final-bone-dirty-1x.png) ; 3× [propre](evidence/p4-final-bone-clean-3x.png) / [saturé](evidence/p4-final-bone-dirty-3x.png).
- Poussière [Soil](evidence/p4-final-soil-dirty-3x.png) / [Clay](evidence/p4-final-clay-dirty-3x.png) / [Sandstone](evidence/p4-final-stone-dirty-3x.png).
- Blower [sale](evidence/p4-final-dust-before-3x.png) → [soulèvement](evidence/p4-final-dust-lift-3x.png) → [dérive](evidence/p4-final-dust-drift-3x.png) → [propre](evidence/p4-final-dust-clean-3x.png).
- Proxies [Brush en cavité](evidence/p4-final-deep-proxy-0.png), [Chisel sur paroi](evidence/p4-final-deep-edge-proxy-1.png), [Pick sur Bone](evidence/p4-final-bone-proxy-3.png) ; éclats [Clay](evidence/p4-final-clay-chip.png) / [Sandstone](evidence/p4-final-stone-chip.png).

Proxies/FX restent placeholders, saleté agrégée et saturée, pigment approximé par substrat courant. La silhouette en cavité extrême, l’identité instantanée et le plaisir restent à valider humainement. DA P6 et tuning P7 non commencés. La modification locale préexistante de `project.godot` reste préservée et **exclue des commits** ; runtime mesuré à 60 Hz.

## Retest humain — exactement huit points

Ouvrir `project.godot` dans Godot 4.7.2, **F5**, masquer les panneaux **F1**, garder les réglages par défaut. Outils **1/2/3/4**, nouveau clic après changement ; Pick fonctionne en clic ou maintien immobile.

1. **CHISEL** — Le Chisel doit rester aussi fun.
2. **BONE + DUST** — Salir un os avec Clay/Sandstone dust. « Est-ce que je vois immédiatement que c’est toujours un os ? » Réponse cible : **oui**.
3. **TOOL VISUAL** — Creuser pente/cavity/os. L’outil ne traverse pas, ne change pas constamment d’orientation et ne cache pas le point travaillé.
4. **CHUNKS** — Chiseler Clay/Sandstone. « Est-ce que les éclats donnent du feedback sans bloquer ma vue ? »
5. **PICK** — Trouver les petits restes structurels proches d’un os. Le Pick doit les enlever rapidement, être précis et safe, sans demander 10 secondes par morceau.
6. **CLEANUP** — Brush/Blower. Ne pas devoir se demander « Est-ce loose debris ou dust ? » ; penser simplement « c’est sale → je nettoie ».
7. **FULL LOOP** — **Brush → Chisel → Precision Pick → Blower**. « Est-ce que les quatre outils ont maintenant chacun une raison évidente d’exister ? »
8. **10–15 MINUTES** — Jouer librement. « Est-ce que j’ai envie de continuer à nettoyer/révéler alors que personne ne m’y oblige ? »

**STOP après livraison. PR #5 BROUILLON, NON MERGÉE. Aucun P5 sans nouvelle autorisation explicite.**
