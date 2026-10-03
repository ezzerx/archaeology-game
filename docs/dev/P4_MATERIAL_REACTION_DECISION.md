# Décision P4 — Matière attachée et saleté

2026-10-03. Passe finale de simplification autorisée après test humain. Elle remplace le Pick SCRAPE, les proxies orientés par la normale et la classification joueur des débris. [Brief initial](P4_BRIEF.md), [résultats et retest](P4_REPORT.md). PR #5 reste en brouillon ; aucun merge ni P5.

## Grammaire joueur

| Ce que le joueur voit | Outil évident |
|---|---|
| Soil attaché | Brush |
| Clay / Sandstone en volume | Chisel |
| Petits restes attachés autour de Bone | Precision Pick |
| Saleté : poussière et minuscules miettes | Brush local / Blower large |

Deux états visibles : **matière attachée / saleté**. Aucun choix Loose Debris / Transient Chunks. Le rappel d’outils et F1 emploient « attached material » et « mess » ; les noms techniques internes ne créent aucune règle joueur supplémentaire.

## Socle préservé

Fracture Chisel, profondeur, condition plus juste, sons de découverte/hit direct, Brush audio et caméra sont validés humainement. Ressources Brush/Chisel/Blower, résistances, partition, stress, seuils, profondeur des fractures, audio, contrôleur d’entrée et picking inchangés.

Heightfield RF autoritaire, picking DDA sur ses triangles, fracture locale seedée et sparse, atlas RG8 de 242×133. Premier contact osseux sûr, puis −3 points par impact Chisel dont le centre était déjà exposé, une pénalité maximum par impact. Aucun auto-stop, marge osseuse ou bonus Brush.

## Bone et poussière par matière

> Dust may obscure detail, never material identity.

Sur Bone, couverture **≤0,2392** : au moins **76,08 %** de l’ivoire original reste dans le mélange. La poussière osseuse est elle-même un ivoire terni, jamais une teinte pierre. Roughness Bone **0,43–0,483**, specular **0,356–0,38** ; matrice roughness **0,85–0,988**, specular **0,067–0,15**. Ces bornes décrivent les propriétés du shader, pas la luminosité des pixels soumis aux ombres.

Carte R8 256×160 et accumulation float CPU conservées, aucune nouvelle map. Le **matériau actuellement sous le dépôt** fournit l’approximation locale de source : Soil brun terreux, Clay ocre/rouge brun atténué, Sandstone beige/crème chaud, Bone ivoire sali. Choix de lisibilité, sans historique du transport des pigments entre couches.

Amas larges, taches intermédiaires et speckles stables ; couverture croissante avec l’accumulation, sans expiration au repos. Géométrie et vues F2 inchangées. Les bouffées Blower reprennent la teinte locale au point réellement nettoyé.

## Orientation fixe des outils

Normale et profondeur ne contrôlent plus l’orientation. Base constante relative à la caméra fixe : Euler **(0,10 ; 0 ; −0,20 rad)**, Blower **−0,18 rad** sur Z. Le manche reste du même côté du curseur. Silhouettes Brush/Chisel/Blower resserrées pour dégager la vue et entrer dans les cavités.

Pointe réelle et pivot exactement au hit. `ToolProxyPose` calcule un **déplacement vertical minimal du corps** depuis les sommets et des sondes intérieures de chaque face proche du relief. Manche rigide : même translation de tous ses sommets, aucun changement d’angle ou déplacement horizontal. Les quatre premiers millimètres de la pointe raccordent ce déplacement à zéro au contact. Recul par translation verticale du corps : Chisel 12 mm maximum, Pick 2 mm, sans déplacer le hit.

Aucun soulèvement au repos sur le plat. Marge locale 0,1 mm plus réserve 0,4 mm seulement en présence d’un obstacle. Le cas synthétique extrême d’une cavité quasi verticale profonde de 10 cm demande **36,32 mm** de dégagement hors recul ; sa lecture reste à juger en jeu. Aucun plafond arbitraire qui laisserait le mesh traverser la paroi.

Topologie fixe, au plus 2 592 sommets rendus pour Brush ; sommets uniques et relief local mémorisés pendant la pose, faces dégagées exclues. Contact/height/recul inchangés = pose réutilisée. Aucun collider ou scan global. Les tests inspectent `surface_get_arrays` ; `Mesh.get_faces()` quantifie son maillage dérivé.

## Éclats discrets

Événements de fracture inchangés. Le consommateur visuel émet **au plus trois éclats par impact aux paramètres par défaut**, un par événement retenu. Largeur **1,2–2,4 mm**, hauteur **18 % Clay / 32 % Sandstone**, profondeur 75 % de la largeur. Départ à ≥4 mm du centre, vitesse radiale sortante **0,09–0,14 m/s**, extinction **0,51–0,69 s**. Aucun gros cube posé sur le marqueur.

Quatre pools MultiMesh de 48 instances, **192 FX maximum**, sans rigid body. Envol, rebond et expiration n’ont aucune autorité sur la structure ou la saleté persistante.

## Mess : un seul geste de nettoyage

Deux états internes restent utiles pour leur faible coût : poussière dominante R8 + fractions CPU ; `LooseDebris` en minuscules écailles irrégulières **≤1,4 × 0,196 × 1,05 mm**, deux par zone 24×24 texels, toutes matières confondues. Au plus 2 322 miettes, aucune simulation au repos. Rétention ≤8 %, capacité 0,02 ; excédent vers la poussière. Le nettoyage libère le budget.

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

Petit recul et son Pick discret à l’impact ; nouveaux contacts pouvant jouer la découverte, jamais le hit direct. **Zéro dégât est provisoire P4 pour tester la finition, pas le tuning P7.** Règles Chisel intactes.

## Audio, caméra et limites

28 WAV historiques protégés par SHA-256 de référence `c25b44f`. La huitième famille Pick garde ses samples ; seul son déclenchement suit les impacts. Boucles Brush, découverte et hit direct inchangés.

Caméra orthographique 84°, zoom 1–3× au curseur, RMB pan borné, Home vue initiale et R reset conservés. Changement d’outil, focus/resize annulent le geste ; nouveau clic requis. Debug Shift/Ctrl/Alt+molette et F6/F7 conservés. Cap 240 FPS, physique 60 Hz.

Visuels placeholders, quantités agrégées et saturées, sans collisions fines ou historique de pigment. Les contrôles de géométrie, pixels et débit ne valident pas le plaisir ou la reconnaissance humaine instantanée. **Prochain gate : les huit points du rapport ; aucun merge ni P5 automatique.**
