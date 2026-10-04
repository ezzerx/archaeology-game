# P4 — Passe de clôture : aftermath et préparation Bone

2026-10-04 · `prototype/p4v2-debris-physics` · PR #7 **DRAFT**.

## Autorisation et acquis humains

Antoine valide P4 Final Feel, P4-V1, le look Matrix restauré à 4,5 mm, sa physique persistante et le spectacle Chisel transitoire. La nouvelle demande autorise les derniers correctifs ci-dessous, puis impose **STOP pour validation humaine finale**, sans merge ni P5.

## Contrat de cette passe

- Soil : Fine Dust inchangée **et** petits grains terreux distincts, plats et irréguliers. Taille nominale variable 1,8–2,2 mm ; léger hop visuel, sommeil rapide, nettoyage Brush et transport Blower. Cap dédié **128**, comparaison profilée avec 192. Aucun slot TerrainDebris.
- Matrix : Clay/Sandstone conservent exactement leur look validé, maximum 4,5 mm. Cap physique **256**, indépendant de Soil ; deux places de naissance par zone 24×24 **et par matériau**. Rétention 8 %, capacité 0,02, surplus Fine Dust, aucune éviction.
- Blower : un petit pop au premier contact avec une miette au sol, puis poussée horizontale continue. Pas de lift répété en vol. Mesurer un balayage ouvert d'une seconde, éjection cible ≥70 %, quantités exactes.
- Bone Surface Dirt Film : dépôt adhérent automatique à la première exposition. Ivoire chaud identifiable, patches beige/brun, moins brillant. **Brush seul** le retire progressivement, environ une seconde au centre ; Blower laisse le film. La boucle audio Brush continue même sur film seul. Aucun crumb Matrix créé par ce nettoyage.
- F1 : Soil/cap, Matrix/cap, Clay, Sandstone, Matrix en mouvement/en sommeil, Fine Dust séparée, pourcentage de film sous le curseur et coût d'upload.

## Invariants

**Addendum humain Pick confirmé** : `radius=11.0`, `power=0.44`, `falloff=1.75`, cadence 6 Hz, dégâts0, efficacités0,30/ 1,00/ 1,50 inchangées. Remplace7/ 0,24/ 1,50 ; finition structurelle rapide autour de Bone, précision assurée par le petit footprint, aucune fracture Chisel ni gros chunks. Autres baselines intactes. Nouveau champ outil : `bone_film_clear=1.0` pour Soft Brush, zéro ailleurs. Chisel transitoire, Dust, verticalité, génération, plafonds Bone, exposition, protections par composant, séquence Condition 100/97/97/94, Pick et proxies conservés. F3 compare uniquement la physique Matrix ; reset vide les deux budgets et le film.

**Exposure ≠ Cleanliness ≠ Condition.** Une nouvelle cellule révélée ne resalit jamais une cellule déjà nettoyée, même dans le même texel compact de film.

## Boucle finale

Excavation structurelle → gros éclats transitoires → miettes persistantes physiques + Fine Dust.

Découverte Bone → film adhérent → Brush pour le film → Pick pour la matrice encore attachée → Bone propre. Brush/Blower enlèvent les saletés détachées ; le Blower laisse la préparation adhérente au Brush.

## Livraison et validation

Tests fonctionnels historiques et de clôture, captures Soil et Bone dirty/blown/brushed/clean à 1×/3×, cap Matrix 128/192/256 + Soil plein, cas sommeil/mouvement/cavité/Blower/Brush, comparaison Soil 128/192 et coût film. Cible soutenue ≥60 FPS, P95 <16,67 ms ; publier aussi les frames isolées hors budget.

[Rapport, preuves et checklist humaine](P4V2_REPORT.md). Commits atomiques et push, PR #7 reste DRAFT. P4 ne devient DONE qu'après le verdict humain demandé.
