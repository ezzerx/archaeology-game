# Décision P4 — Final Feel, spectacle transitoire et nettoyage

2026-10-04. Composition autorisée après A/B humain : [P4_FINAL_FEEL_TARGET](P4_FINAL_FEEL_TARGET.md) prévaut sur les anciennes attentes de réduction du spectacle. Références vérifiées dans les worktrees : **A `42ec46d`**, **B `c25b44f`**, version récente **E `f527139`**. [Résultats et retest](P4_REPORT.md). PR #5 reste en brouillon ; aucun merge, P4-V ou P5.

## Grammaire joueur

| Ce que le joueur voit | Outil évident |
|---|---|
| Soil attaché | Brush |
| Clay / Sandstone en volume | Chisel |
| Petits restes attachés autour de Bone | Precision Pick |
| Saleté : poussière et minuscules miettes | Brush local / Blower large |

Deux états visibles : **matière attachée / saleté**. Aucun choix Loose Debris / Transient Chunks. Le rappel d’outils et F1 emploient « attached material » et « mess » ; les noms techniques internes ne créent aucune règle joueur supplémentaire.

## Socle préservé

Fracture Chisel, profondeur, condition plus juste, timbres découverte/hit direct, Brush audio et caméra sont validés humainement. Ressources Brush/Chisel/Blower/Pick, résistances, partition, stress, seuils, profondeur des fractures, samples audio, contrôleur d’entrée et picking inchangés. Seul le routage des signaux Bone change selon la nouvelle règle humaine.

Heightfield RF autoritaire, picking DDA sur ses triangles, fracture locale seedée et sparse, atlas RG8 de 242×133. Premier contact osseux sûr, puis −3 points par impact Chisel dont le centre était déjà exposé, une pénalité maximum par impact. Aucun auto-stop, marge osseuse ou bonus Brush.

## Bone et poussière par matière

> Dust may obscure detail, never material identity.

Sur Bone, couverture **≤0,2392** : au moins **76,08 %** de l’ivoire original reste dans le mélange. La poussière osseuse est elle-même un ivoire terni, jamais une teinte pierre. Roughness Bone **0,43–0,483**, specular **0,356–0,38** ; matrice roughness **0,85–0,988**, specular **0,067–0,15**. Ces bornes décrivent les propriétés du shader, pas la luminosité des pixels soumis aux ombres.

Carte R8 256×160 et accumulation float CPU conservées, aucune nouvelle map. Le **matériau actuellement sous le dépôt** fournit l’approximation locale de source : Soil brun terreux, Clay ocre/rouge brun atténué, Sandstone beige/crème chaud, Bone ivoire sali. Choix de lisibilité, sans historique du transport des pigments entre couches.

Amas larges, taches intermédiaires et speckles stables ; couverture croissante avec l’accumulation, sans expiration au repos. Géométrie et vues F2 inchangées. Les bouffées Blower reprennent la teinte locale au point réellement nettoyé.

## Orientation fixe des outils

Normale et profondeur ne contrôlent pas l’orientation. Base ancienne A/B restaurée pour les quatre outils : Euler **(0,50 ; 0 ; −0,62 rad)**, constante relative à la caméra fixe. Elle remplace l’angle plus vertical E `(0,10 ; 0 ; −0,20)`, Blower `−0,18`. Silhouettes récentes resserrées et pointe précise conservées. Priorité humaine : stabilité, zone de travail visible, puis anti-clipping raisonnable.

Pointe réelle et pivot exactement au hit. Depuis le bugfix ciblé, `ToolRoot` contient un `Tip` statique (les quatre premiers millimètres) et un `Body` statique. La silhouette est découpée une seule fois au démarrage. Au plus **douze sondes de hauteur** déterminent une translation verticale du corps ; aucune reconstruction de mesh, normale ou scan surfacique pendant le jeu. Contact et hauteur inchangés = dégagement réutilisé ; le recul ne relance pas les sondes. Chisel 12 mm, Pick 2 mm, sans déplacer la pointe.

Aucun soulèvement au repos sur le plat. Marge locale 0,1 mm plus réserve 0,4 mm seulement en présence d’un obstacle, déplacement borné à la profondeur du bloc plus recul. Priorité explicite : **fluidité > angle stable > point lisible > anti-clipping**. De petites intersections rares, ou une séparation pointe/corps dans une cavité extrême, sont acceptées ; la contrainte ancienne de dégagement de toutes les faces est retirée.

Les tests vérifient les ressources et tableaux de sommets/normales inchangés, le nombre réel de lectures terrain et le coût CPU, y compris lorsque la densité du relief double. Mesures avant/après et diagnostic dans [P4_REPORT](P4_REPORT.md).

## Spectacle Chisel transitoire, repris de A

Événements de fracture inchangés. Le consommateur visuel reprend A : **1–5 éclats par plaque réellement cassée**, `clamp(ceil(cells / 10), 1, 5)`, puis saturation du pool. Largeur **3–6 mm**, hauteur **24 % Clay / 70 % Sandstone**, profondeur 100 % de la largeur. Les anciennes bornes E — trois éclats par impact, 1,2–2,4 mm, hauteur 18/32 %, profondeur 75 % — sont explicitement abandonnées.

Départ à ≥4 mm du centre, vitesse radiale sortante **0,09–0,14 m/s** conservée, vitesse ascendante A **0,035–0,10 m/s**, durée récente **0,51–0,69 s**. Le point de naissance est relevé de `chunk.volume / chunk.cells × profondeur du bloc` : l’événement arrive après le retrait, donc un départ au nouveau fond cachait les fragments dans les parois. Cette estimation statique remet les morceaux au niveau de la plaque arrachée. Le plan de rebond simple reste celui de la source ; aucun échantillonnage de terrain sous les morceaux en vol.

Quatre pools MultiMesh de 48 instances, **192 FX maximum**, sans rigid body. Envol, rebond et expiration n’ont aucune autorité sur la structure ou la saleté persistante.

## Mess : un seul geste de nettoyage

Deux états internes restent utiles pour leur faible coût : poussière dominante R8 + fractions CPU ; `LooseDebris` en écailles irrégulières. **Quantités E inchangées** : deux par zone 24×24 texels, toutes matières confondues ; au plus 2 322 miettes ; rétention ≤8 %, capacité 0,02 ; excédent vers la poussière. Aucune simulation au repos. Le nettoyage libère le budget. Les gros morceaux transitoires ne deviennent jamais des dépôts.

Pour retrouver le vol visible B, les miettes **Clay/Sandstone** ont une échelle nominale maximale **4,5 × 1,44 × 3,375 mm**, au lieu de 1,4 × 0,196 × 1,05 mm ; la quantité fait varier leur taille via la racine carrée. Elles sont posées à mi-hauteur +0,1 mm au-dessus du substrat. On reprend la largeur B de 4,5 mm et la hauteur 32 %, avec le plafond récent : B permettait jusqu’à 6,75 mm et beaucoup plus de dépôts. **Soil reste strictement à la représentation récente**, au plus 1,4 × 0,196 × 1,05 mm, offset 0,18 mm.

Brush nettoie poussière et miettes localement, Blower largement. Les miettes sont plates, sans silhouette de brique. La matière attachée reste une hauteur modifiable au Pick ; aucune conversion en saleté nettoyable près de Bone.

Souffle conservé : au plus **16 packets `{point, amount}`** issus de cellules effectivement nettoyées, somme égale à `last_cleared`. Aucun nuage générique au curseur propre. Pool AirDust existant : départ au relief source, soulèvement, jet **0,13–0,19 m/s**, expansion, extinction **0,55–0,9 s** ; quantité retirée règle taille/opacité, avec saturation du pool. Le billboard conserve l’échelle des instances.

Les miettes soufflées s’agrègent en paquets, avancent à 60 Hz et sortent à la frontière. Hook `debris_ejected(world_position, direction, amount, material_type)` conservé. Zéro retrait de hauteur, dégât ou table salissable. Reset exact des états et FX.

## Precision Pick = micro-Chisel sûr pour P4

**LMB maintenu : six petits impacts par seconde, même immobile. Clic court : impact immédiat.** Réutilisation d’`ImpactClock` et du chemin IMPACT du contrôleur. Suppression de SCRAPE, de la vitesse minimale et du plafond lent par passage.

| Paramètre | Valeur P4 |
|---|---:|
| Rayon | 3 texels, contre 12 pour Chisel |
| Puissance par impact | 0,24 |
| Cadence / falloff | 6 Hz / 1,5 |
| Efficacités Soil / Clay / Sandstone | 0,30 / 1,00 / 1,50 |
| Génération poussière / nettoyage | 1,25 / 0 |
| Dégât Bone | 0 |

Disque minuscule, au plus 25 centres de texels modifiés dans le test centré. Micro-retrait direct, sans cellules de fracture Chisel, stress ou gros éclat. Chaque impact s’arrête à l’interface du matériau initial et au plafond osseux, sans marge. Aucun pont entre deux positions d’impact.

Un clic central retire **0,08 Clay / 0,045 Sandstone** de hauteur normalisée, soit **8,16 / 4,59 mm**, si la couche disponible le permet. L’efficacité locale est forte ; le volume reste faible grâce au rayon. Le test d’une seconde mesure un rapport de volume Chisel/Pick **17,80**. Géométrie, exposition, dépôt et événements restent synchronisés dans le noyau commun.

Petit recul et son Pick discret à l’impact ; le Pick ne déclenche ni tik protégé ni dommage et ne consomme jamais la protection Chisel. **Zéro dégât est provisoire P4 pour tester la finition, pas le tuning P7.**

## Audio, caméra et limites

28 WAV historiques protégés par SHA-256 de référence `c25b44f`. Famille Pick et boucles Brush conservées. Nouvelle sémantique Bone :

- `bone_revealed` garde sa signification d’exposition supplémentaire ; le décompte des cellules/composants reste inchangé.
- `bone_first_contact` et `FossilState.first_contact` indiquent seulement la découverte/UI. Même la première révélation adjacente garde le son du matériau travaillé.
- `first_direct_contact_consumed`, distinct et remis à faux au reset, protège une fois le centre d’un impact Chisel susceptible de faire des dégâts. Premier contact direct : `bone_protected_contact = true`, petit tik, zéro dégât. Pick/Brush/Blower ne consomment rien.
- Un centre Bone caché atteint par cet impact peut consommer la protection sans dégât. Des cellules révélées ailleurs dans le footprint ne le peuvent pas. Une fois la protection consommée, un nouveau centre précédemment caché reste sans dommage sur sa révélation, conformément à la règle historique.
- `bone_damage` transporte la baisse réelle de condition déjà calculée par la règle existante. **Gros clack + signal visuel** seulement si hit direct et perte >0 ; à condition zéro, aucun faux signal de dommage supplémentaire.
- Autres impacts : Clay/Sandstone travaillé, y compris lors de toute exposition adjacente. Si les deux sont retirés, le volume dominant choisit le son. Le contact direct protégé et un hit dommageable ont priorité sur ce son de matière.

Le sample historique `bone_revealed` est le petit tik de contact protégé ; aucun WAV modifié. Aucune marge, auto-stop ni retuning des outils ; les dégâts ultérieurs restent −3 points, bornés à zéro.

Caméra orthographique 84°, zoom 1–3× au curseur, RMB pan borné, Home vue initiale et R reset conservés. Changement d’outil, focus/resize annulent le geste ; nouveau clic requis. Debug Shift/Ctrl/Alt+molette et F6/F7 conservés. Cap 240 FPS, physique 60 Hz.

Visuels placeholders, quantités agrégées et saturées, sans collisions fines ou historique de pigment. Les contrôles de géométrie, pixels et débit ne valident pas le plaisir ou la reconnaissance humaine instantanée. **Prochain gate : les trois points du bugfix dans le rapport. STOP ; aucun merge, P4-V ou P5 automatique.** Macro-stratigraphie, profondeur fossile variable et vraie gravité des débris dans les cavités restent hors périmètre.
