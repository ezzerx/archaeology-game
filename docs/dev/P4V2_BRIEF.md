# P4 — Micro-passe finale de clôture

2026-10-05 · `prototype/p4v2-debris-physics` · PR #7 **DRAFT**. Entrée : `1aadaa3f35d2d73963dccc2a14a6055840644046`.

Le cœur P4 est apprécié. Cette autorisation porte uniquement sur trois irritants : micro-restes structurels ressemblant à du mess, miettes Matrix camouflées qui conservent le cap, poussière Soil persistante sans intérêt suffisant. **STOP après livraison ; aucun merge ni P5.**

## Contrat courant

- **Soil : aucun mess persistant**, ni grains ni Fine Dust. Retrait, audio Brush, relief et couleur conservés. Suppression du dépôt au niveau matériau, aucun hack shader. **Soil persistent dust deferred to P6/P7 redesign.** Fine Dust Clay/Sandstone conservée.
- **Micro-restes** : Brush peut détacher un îlot hard très fin et minuscule, en le convertissant explicitement en miette. Inspection locale bornée, déterministe, sans flood-fill global. Épaisseur ≤1,5 mm, composante 8-connectée ≤4 cellules dans une fenêtre 5×5 ; voisin épais/connectivité étendue rejetés. Maximum64 inspections par action. Pas d’érosion générale Clay/Sandstone par Brush ; Pick garde les vrais morceaux attachés.
- **Blower** : exposition suffisante au jet → EJECTING → court vol visuel puis disparition. Poids minimal0,25 et accumulation0,075 seconde pondérée, oubli après0,15 s sans influence. Le seuil libère immédiatement le cap logique, la source locale et le slot physique. FX0,35 s, direction du jet, petit lift ; pool visuel séparé et borné. **Matrix crumbs can be removed by cleanup commitment, not only literal block-edge crossing.**
- **Fréquence inchangée** : Clay3 / Stone4 par zone24×24, Matrix256, même look4,5 mm, rétention8 % et capacité0,02 pour l’excavation habituelle. Un micro-îlot détaché conserve sa quantité entière sous forme de miette, sans gros chunk ni réaction Chisel.
- **Bone Film absolument inchangé** : teinte sombre validée, Brush seul, pas de nettoyage Blower/Pick. Exposure ≠ Cleanliness ≠ Condition.
- **Pick inchangé** :11 /0,44 /1,75,6 Hz, dégâts0, efficacités intactes. Tuning final différé P7.

## Validation

Fixtures voisines plaque attachée/micro-îlot, plafonds Bone et zéro dégât, Soil20 s sans génération Matrix/Dust, préservation de Dust hard existante, éjection locale depuis un cap plein y compris sur Soil, FX temporaire, pas de double événement et nouvelles miettes Chisel admises immédiatement.

Benchmark1×/3× : Brush Soil long,256 miettes endormies, évacuation locale massive, Brush micro-restes, Brush film. FPS, P95/max frame, CPU débris et édition/upload résidu. Retest humain du feel, de la lisibilité des outils et de la boucle complète. [Rapport courant](P4V2_REPORT.md).
