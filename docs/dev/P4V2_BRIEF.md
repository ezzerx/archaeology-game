# P4 — Dernière passe de clôture

2026-10-04 · `prototype/p4v2-debris-physics` · PR #7 **DRAFT**. Entrée : `491934e1dae46c6c980a325e2d73f4aaee58cac6`.

Le retour humain valide le look/physique des Matrix crumbs, le spectacle Chisel, le gameplay Bone Film et le Pick 11 / 0,44 / 1,75. Cette passe simplifie les débris et corrige leur fréquence, leur évacuation et la teinte du film. **STOP après livraison pour retest humain, aucun merge ni P5.**

## Contrat courant

- **Soil particles removed for now; Soil uses dust-only feedback.** Plus de grains persistants, de particules transitoires Soil, de budget Soil, de hop ou de pool GPU associé. Fine Dust et nettoyage Brush/Blower conservés. Cette décision remplace l’addendum demandant des grains Soil visibles.
- **Matrix uniquement Clay/Sandstone** : look 4,5 mm max conservé, physique légère, persistance, nettoyage au point physique courant. Cap global256. Fréquence augmentée par quotas locaux24×24 : **Clay3, Sandstone4**, contre2/2. Rétention8 %, capacité0,02, aucun grossissement ni disparition automatique. Surplus en Dust.
- **Blower** : garder le pop unique au sol et la poussée horizontale ; prolonger l’élan hors du rayon du jet pour franchir le vrai bord. Une sortie retire le state, décrémente le compteur et libère les slots. Vérifier un cap plein, balayage prolongé, nouvelles frappes Chisel puis remplissage du budget.
- **Bone Film** : brun terreux plus sombre, distinct du Sandstone ; conserver des zones ivoire et les mêmes patches. Brush seul retire le film ; Blower/Pick ne le retirent pas. Aucune modification de Condition, Exposure ou protection.
- **F1** : Matrix/cap, Clay crumbs, Sandstone crumbs, Moving, Sleeping ; Fine Dust séparée, film sous curseur. Aucun compteur Soil.

## Invariants et boucle humaine

Pick **11 / 0,44 / 1,75**,6 Hz, dégâts Bone0, efficacités0,30/1,00/1,50 inchangées. **P4 human-validated baseline — final fine tuning still deferred to P7.** Aucune fracture ni gros chunks Chisel donnés au Pick. Autres outils, géologie V1.1, cleanup V1.2, plafonds/protections Bone, caméra, audio et spectacle transitoire dur conservés.

Excavation structurelle → chunks transitoires → Clay/Sandstone crumbs persistantes + Fine Dust → découverte Bone sale → Brush film → Pick matrice encore attachée → Bone propre.

**Exposure ≠ Cleanliness ≠ Condition.** Le film reste RGBA8 compact160 KiB avec masque fin ; une nouvelle cellule révélée ne resalit pas les voisines nettoyées.

## Validation demandée

Régressions P0–P4/P4-V, comparaison de rendement à quantité excavée identique, Soil sans grains ni compétition de budget, balayage Blower avec compteur avant/après et vraie réapparition, captures Bone sale/Blower/Brush/propre à1×/3×.

Benchmark1080p des gestes Brush Soil, Chisel Clay, Chisel Sandstone, Blower à beaucoup de miettes, Brush film : FPS moyens, P95/max frame et occupation Matrix. Cible soutenue≥60 FPS, P95<16,67 ms ; publier les pointes isolées. [Rapport et checklist](P4V2_REPORT.md).
