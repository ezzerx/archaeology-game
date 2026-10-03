# Rapport P4 — Game Feel / Material Reactions

**2026-10-03 · troisième passe corrective · `prototype/p4-game-feel` · Godot 4.7.2 stable / Compatibility.**

Code validé : `dbdc2170a23053f1970c48f0b1f69016d4afadf0` ; les commits suivants ne portent que la documentation et les preuves.

[PR #5](https://github.com/ezzerx/archaeology-game/pull/5) **en brouillon, non mergée**. P4 attend le nouveau test humain ; **P5 interdit**. Le [brief initial](P4_BRIEF.md) est complété par les autorisations correctives consignées dans [l’architecture](P4_MATERIAL_REACTION_DECISION.md).

## Retour humain et périmètre

Le Chisel reste très fun. Fracture Clay/Sandstone, Brush audio, sons de découverte/hit direct, Bone Condition, zoom, pan RMB, Home et picking sont à préserver. La réduction des gros débris et le concept Precision Pick sont conservés.

Cette passe traite cinq problèmes : proxy qui traverse le relief, poussière trop proche d’un bruit de shader au dézoom, Blower qui semble effacer, Pick trop discret dans le grès, confusion entre restes attachés et miettes. **Seuls les paramètres du Pick sont retunés.** Aucun changement des ressources Brush/Chisel/Blower, résistances, fracture, audio ou caméra.

## Contact des outils

**Diagnostic confirmé :** la pointe était placée au hit, mais le corps gardait une rotation quasi fixe. Le recul pouvait aussi déplacer le proxy entier. Orienter seulement selon la normale ne suffit pas : dans une cavité concave, le manche peut atteindre la paroi opposée.

**Nouvelle pose :** repère continu construit depuis la normale du hit, redressement progressif en profondeur, inclinaison minimale pour garder la pointe visible. La pointe réelle du mesh et le pivot restent au hit ; les extrémités sont effilées vers ce contact. Le recul du Chisel agit depuis ce pivot, sans déplacer le contact.

Une protection locale ajuste uniquement le mesh visuel : sommets du côté positif du plan de contact, dégagement du relief, contrôles dans les faces pour éviter une traversée entre leurs sommets. Marge de 0,1 mm et réserve de 0,9 mm seulement sur une face en conflit ; pointe protégée. Les sommets partagés restent liés. Le proxy peut se déformer dans une cavité extrême ; aucune donnée de fouille n’en dépend.

Topologie fixe, au plus **2 592 sommets rendus** pour le Brush. Échantillons du relief local réutilisés, faces déjà dégagées exclues, pose inchangée conservée exactement. Aucun scan global, collider ou changement de picking. Les contrôles utilisent les vrais tableaux de sommets : `Mesh.get_faces()` quantifie sa représentation dérivée et ne convient pas à cette précision.

## Saleté et souffle

| Catégorie | Comportement actuel |
|---|---|
| **Structural** | Heightfield attaché ; plaques, crêtes et petits restes répondent au Chisel/Pick selon leur matière. |
| **Transient Chunks** | Éclats Clay/Stone de 3–6 mm, durée **1,275–1,725 s**, envol/rebond visuels. Expiration sans effet sur la vraie saleté. |
| **Loose Debris** | Écailles asymétriques à six côtés, **≤1,4 mm** de large et **≤0,196 mm** de haut. Deux miettes maximum par zone 24×24 texels, toutes matières confondues ; au plus 2 322 sur le bloc. |
| **Fine Dust** | Trace persistante principale : amas irréguliers, taches intermédiaires et speckles, teinte beige/grise et rugosité. La couverture augmente avec l’accumulation ; visible à 1×/3×, sans expiration. |

Carte de poussière **R8 256×160** et accumulation float CPU conservées. Aucun node de poussière supplémentaire. La rétention des miettes reste plafonnée à 8 % et 0,02 par miette ; l’excédent alimente Fine Dust. Nettoyage/reset libèrent le budget local. Aucune simulation des miettes au repos.

**Blower : sale → soulèvement → dérive dans le jet → propre.** Le nettoyage produit au plus **16 packets temporaires `{point, amount}`**, dont chaque source est une cellule réellement nettoyée. Leur somme correspond à la quantité retirée, y compris quand le curseur lui-même est sur une zone propre. Pas de nuage générique au curseur.

Ces packets alimentent le pool AirDust existant : **48 bouffées maximum**, toujours 192 FX au total. Départ au relief source, soulèvement, vitesse horizontale 0,13–0,19 m/s dans le jet, dispersion, expansion et extinction après 0,55–0,9 s. La surface visuelle dépend de la quantité retirée, avec plafonds de taille/opacité et omission des émissions lorsque le pool est plein. Les FX ne détiennent aucune quantité gameplay.

Les miettes restent poussées puis éjectées ; hook monde `debris_ejected` conservé. Zéro retrait structurel et zéro dégât au nettoyage. Aucune table salissable.

**Diagnostic des blocs orange :** une plaque orange persistante après expiration des éclats appartient à la Clay structurelle. Une miette détachée est maintenant une petite écaille, nettoyable au Brush/Blower ; le Pick travaille le substrat attaché et ne nettoie pas la miette. F1 affiche STRUCTURAL/BONE au vrai hit, plus les miettes et FX proches. Ces compteurs de voisinage permettent de lever l’ambiguïté sans changer le picking ni créer d’UI joueur finale.

## Precision Pick : avant / après

| Paramètre | Deuxième passe | Troisième passe |
|---|---:|---:|
| Puissance | 0,16 | **0,22** |
| Efficacité Soil / Clay / Sandstone | 0,30 / 0,60 / 0,45 | **0,30 / 0,75 / 1,00** |
| Vitesse de référence | 100 texels/s | **40 texels/s** |
| Rayon / falloff | 3 texels / 1,5 | inchangés |
| Retrait maximal par texel/passage | 0,004 | inchangé |
| Génération poussière / nettoyage | 1,25 / 0 | inchangés |
| Dégât osseux | 0 | inchangé, provisoire P4 |

Les petits mouvements lents à 3× étaient fortement atténués par la vitesse de référence de 100 texels/s. La puissance augmente de 37,5 %, et les efficacités/référence sont adaptées à la finition. Aucune multiplication brute par dix.

Avec les résistances historiques, débit central nominal : **Clay 0,055 profondeur/s**, **Sandstone 0,0275**, donc grès deux fois plus lent. Le test de **0,4 s à 30 texels/s** mesure **0,01650 / 0,00825** de profondeur, soit **1,68 / 0,84 mm**. Avec les anciens paramètres, le calcul donne environ 0,39 / 0,11 mm pour ce même geste idéal. Le grès réagit donc rapidement tout en restant plus résistant.

**[4] Pick = LMB maintenu + mouvement**, aucun forage immobile, pas de stress ni plaques de Chisel. Rayon minuscule, limite de passage, arrêt à la couche initiale et bone ceiling conservés. Les tests de volume gardent le Chisel nettement supérieur. Rôles : **Chisel volume/fracture → Pick restes attachés → Brush miettes → Blower poussière/nettoyage large**.

## Vérifications

**1 093 checks fonctionnels, zéro échec** : P0 45, P1 52, P2 97, P3 85, zoom 160, P4 61, pan 43, audio 18, saleté 27, budget débris 16, Pick 38, nouveau feedback 25, proxy 426. Cas et tolérances historiques conservés.

- Proxies : **35 contacts × quatre outils** sur plat, pente, cavité profonde, os et fracture. Pointe réelle/pivot à moins de 1 µm du hit ; sommets hors plan/relief à 2 µm près ; **161 280 sommets et 107 520 points intérieurs de face** contrôlés, tolérance intérieure 0,1 mm. Pose fixe exactement stable ; géométrie, plafonds et condition inchangés.
- Dust/Blower : persistance, accumulation/reset exacts, sources réellement nettoyées, somme des quantités, déplacement dans le jet avant expiration, absence de modification de hauteur/condition et pool borné. Les miettes répondent au Brush/Blower et les gros éclats expirent.
- Pick : Clay/grès perceptibles, résistance relative, volume inférieur au Chisel, zéro forage immobile, interfaces et limites de passage, finition de vrais restes sur crâne/côtes au plafond osseux, zéro dégât.
- **28 WAV historiques identiques à l’octet** à la référence `c25b44f` ; boucle Brush et sémantique découverte/hit direct préservées.
- Picking : **4 432 rayons zoom**, **387 rayons pan**, **225 roundtrips de fracture** ; oracle GPU P3 sur **194 955 pixels**, tolérances historiques conservées et cartes CPU/GPU exactes.
- **16 contrôles graphiques** complémentaires : accumulation réellement rendue à 1×/3×, persistance au-delà des FX, nettoyage visible à géométrie/condition identiques, sessions de Chisel et dimensions des miettes. Sur la région contrôlée, le dépôt léger affecte environ 56 % des points sondés, le dépôt dense environ 75 %. Ces différences de pixels ne valent pas validation humaine du rendu.

La sonde Chisel attentive reste identique : **1 004 impacts**, 4 105 cellules exposées, **49,87 % du crâne à 100 %** ; dix hits directs → 70 %. Elle suppose une reconnaissance parfaite des centres visibles et ne remplace pas un test humain.

Commande complète reproductible :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

## Performances et preuves

RTX 5080 / Ryzen 7 9800X3D, 1920×1080, Compatibility, **cap 240 FPS / physique 60 Hz**. **22 scénarios** de six secondes à 1×/3×, FX actifs, mixer réel avec bus muet. Préparation, warmup et captures exclus du timing.

| Scénario | FPS 1× / 3× | Frame P95 1× / 3×, ms |
|---|---:|---:|
| Brush / Soil | 122,91 / 133,69 | 14,039 / 13,041 |
| Chisel / Clay | 239,87 / 239,87 | 4,307 / 4,314 |
| Chisel / Sandstone | 239,87 / 239,87 | 4,304 / 4,307 |
| Chisel près de l’os | 239,87 / 239,87 | 4,312 / 4,295 |
| Blower massif | 239,98 / 239,91 | 4,783 / 4,757 |
| Bloc sale au repos | 239,87 / 239,87 | 4,269 / 4,269 |
| Pick / os | 239,85 / 239,85 | 4,892 / 4,879 |
| Pick / Clay | 239,84 / 239,85 | 4,877 / 4,883 |
| Pick / Sandstone | 239,85 / 239,84 | 4,908 / 4,919 |
| Proxy Brush / cavité | 238,47 / 238,36 | 7,205 / 7,368 |
| Proxy Brush / relief osseux | 239,57 / 239,58 | 5,385 / 5,256 |

**122,91–239,98 FPS**, P95 maximal **14,039 ms**, frame maximale **17,927 ms**, zéro échec graphique. Le contrôle visuel augmente le coût du Brush continu par rapport à la deuxième passe ; l’objectif de confort ≥60 FPS est tenu sur cette machine. Coût moyen de pose pendant Brush/Soil : environ 3,2–3,3 ms ; au repos, pose conservée. Aucun scan full-map par frame.

Bloc entièrement sali au repos : **2 322 miettes**, zéro édition/upload height. Blower massif : zéro upload height. Pick : condition 100 %, zéro fracture. Deux sessions contrôlées de **270 impacts = 60 secondes simulées** sans nettoyage gardent **29 miettes Clay / 27 Sandstone**, puis zéro après souffle. Elles démarrent sur une couche pré-exposée ; elles ne mesurent pas la cadence humaine.

Preuves : [benchmark](evidence/p4-fix3-benchmark.json), [rendu poussière](evidence/p4-fix3-feedback-visual.json), [oracle GPU](evidence/p4-fix3-gpu.json). Logs détaillés locaux dans `work/test-logs/`. Les preuves des passes précédentes restent versionnées.

Captures du vrai renderer :

- Dust 1× : [sale](evidence/p4-fix3-dust-before-1x.png) → [soulèvement](evidence/p4-fix3-dust-lift-1x.png) → [propre](evidence/p4-fix3-dust-clean-1x.png).
- Dust 3× : [sale](evidence/p4-fix3-dust-before-3x.png) → [soulèvement](evidence/p4-fix3-dust-lift-3x.png) → [dérive](evidence/p4-fix3-dust-drift-3x.png) → [propre](evidence/p4-fix3-dust-clean-3x.png).
- Chisel, 60 s simulées : Clay [1×](evidence/p4-fix3-clay-60s-dirty-1x.png) / [3×](evidence/p4-fix3-clay-60s-dirty-3x.png), Sandstone [1×](evidence/p4-fix3-stone-60s-dirty-1x.png) / [3×](evidence/p4-fix3-stone-60s-dirty-3x.png).
- Contact : [Brush en cavité](evidence/p4-fix3-deep-proxy-0.png), [Pick sur os](evidence/p4-fix3-bone-proxy-3.png), [Chisel en pente](evidence/p4-fix3-slope-proxy-1.png).

## Limites

Proxies, poussière et sons restent des placeholders. Le contrôle des faces repose sur des sondes locales ; le retest doit encore juger les silhouettes et transitions de pose dans les reliefs irréguliers. Quantités visuelles saturées, poussière à résolution réduite, transport des miettes sans collisions fines. Le débit et la sécurité du Pick restent des choix P4, pas le tuning P7. Les mesures ne constituent ni un verdict de plaisir ni une garantie sur un autre GPU.

La modification locale préexistante de `project.godot` (suppression de la valeur explicite 60 Hz, égale au défaut Godot) est préservée et **exclue des commits**. Runtime mesuré : 60 Hz.

## Retest humain — 10 à 15 minutes

Ouvrir `project.godot` dans Godot 4.7.2, **F5**, masquer les panneaux avec **F1**, garder les réglages par défaut. Outils **1/2/3/4**, nouveau clic après changement ; Pick = maintenir LMB et bouger.

1. **TOOL CLIPPING** — Creuser pentes/cavités, passer les quatre outils sur parois, os et bords fracturés. Pointe au contact, corps dégagé, pas de flottement/jitter visible.
2. **DUST GENERATION** — Creuser Clay/Sandstone **30–60 s**. La zone doit sembler sale même à **1×**, sans piles de cubes.
3. **BLOWER** — Souffler : voir la poussière se lever et partir dans le jet. « Ça souffle ou ça efface ? » Réponse cible : **ça souffle**.
4. **PICK CLAY** — Finir les détails attachés autour d’un os avec de petits mouvements.
5. **PICK SANDSTONE** — Retrait perceptible rapidement, plus lent que Clay, sans devenir un outil de volume ; condition intacte.
6. **LOOSE DEBRIS** — Distinguer immédiatement matière attachée et miette détachée. Brush/Blower déplacent ou retirent les miettes ; F1 peut aider au diagnostic.
7. **FULL LOOP** — **Chisel → Pick → Brush → Blower** : chaque outil remplit-il maintenant un rôle évident ?

**STOP après livraison. PR #5 reste BROUILLON, NON MERGÉE. Aucun P5 sans nouvelle autorisation explicite.**
