# Statut canonique

- Date : **2026-10-02**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — zoom P3 validé humainement ; ergonomie debug vérifiée ; non mergé**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`.
- Branche de livraison P3 : `prototype/p3-fossil` ; [PR #4](https://github.com/ezzerx/archaeology-game/pull/4) en brouillon vers `main`, non mergée.
- Merge P0 : `244aba3652a03aac908b1aabe1651c3b9edb1315`.
- Merge P1 : `960642c3fc6972bdb257c96abd43b90c148e632d`.
- Merge P2 : `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## P0 — Validé ✅

Fondation interaction validée : mapping souris, surface, strokes, reset/debug.

## P1 — Validé ✅

Relief excavable 3D, stratigraphie, résistances et picking précis sur le relief.

## P2 — Validé ✅

Antoine confirme le 2026-10-01 que les trois outils fonctionnent comme voulu pour le prototype.

Livré et validé :

- Soft Brush continu ;
- Chisel discret à 4,5 Hz ;
- Air Blower sans retrait structurel ;
- ToolDefinition data-driven ;
- résidu debug R8 256×160 ;
- changement 1/2/3 et toolbar ;
- reset/input robustes ;
- **194 checks P0/P1/P2, 0 échec** ;
- ~60 FPS sur les benchmarks graphiques 1080p plafonnés à 60.

PR #3 mergée vers `main` le 2026-10-01 au commit `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.

Rapport : [P2_REPORT.md](../dev/P2_REPORT.md).

## Décision runtime FPS

Lors du test humain P2, le runtime Godot non plafonné a poussé la RTX 5080 à 100% GPU.

Décision explicite d'Antoine :

> **Capper les runs interactifs normaux à 240 FPS à partir de P3.**

Les scripts de benchmark peuvent temporairement désactiver/modifier ce plafond pour mesurer la marge.

Aucune autre optimisation GPU n'est demandée pour l'instant. Après son test P3 le 2026-10-01, Antoine confirme que le GPU ne surchauffe plus ; le cap reste à 240 FPS.

## Watchpoints techniques

- grille relief dense (~1,31 M triangles) ;
- upload height RF complet à chaque tick dirty ;
- residue R8 séparé mais léger ;
- stress synthétique extrême hors budget ;
- collider physique enveloppe uniquement ;
- valeurs d'efficacité/résistance encore de prototype.

Aucun de ces points ne bloque P3.

## P3 — Zoom validé ; ergonomie debug vérifiée

Livré dans le périmètre confirmé par Antoine le 2026-10-01 :

- Specimen B-17 fixe, initialement caché, **32 290 cellules** et quatre composants ;
- champ fossile RGF statique, clamp au sommet osseux et relief émergent ;
- zoom orthographique **1×–3×** ancré au curseur, orientation **84°** fixe ;
- molette seule = zoom ; Shift+molette = puissance, Ctrl+molette = falloff, Alt+molette = rayon ; F6/F7 en secours ;
- Home rétablit la vue ; R restaure également le spécimen ; resize/focus robustes ;
- logique osseuse P3 initiale conservée : premier contact protégé, `Bone detected` une fois par reset, Chisel **−3 points par impact direct sur centre déjà exposé** ;
- Brush/Blower sûrs, efficacités P2 inchangées, résidu indépendant ;
- exposition globale/composants, signaux découplés et reset exact ;
- cap officiel **240 FPS**, physique **60 Hz** ;
- **439 checks P0/P1/P2/P3, zéro échec** après ergonomie debug ; benchmarks graphiques de la passe zoom précédente validés ;
- sept scénarios P3 autour de **240 FPS**, rendu/picking comparés sur **194 955 pixels** à 1×/2×/3×.

Résultats automatisés et checklist : [P3_REPORT](../dev/P3_REPORT.md). Architecture : [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md). Source de vérité corrective : [P3_DESIGN_FIXES](../dev/P3_DESIGN_FIXES.md), prioritaire sur le [brief initial](../dev/P3_BRIEF.md).

Retour humain initial d'Antoine : « Ok tout fonctionne et le GPU ne surchauffe plus. » Ce retour valide le fonctionnement initial et le confort GPU ; Antoine valide également le zoom le 2026-10-02.

## Clarification design — 2026-10-01

La revue produit confirme l'envie de continuer à révéler le fossile et le besoin de zoom. Antoine confirme ensuite **« Zoom seul comme le design fix l'indique »**. La marge de 2 mm et le bonus Brush près des os sont retirés de la passe ; le code de retrait et les tests osseux historiques retrouvent leur version P3 initiale.

**L'équilibrage de Bone Condition n'est pas final. Une excavation à 100 % de condition n'est pas un critère d'acceptation P3.** P4 devra réévaluer l'évitement des dégâts après l'introduction des réactions de matière prévues : fissures, morceaux d'argile, détachement de blocs de grès, interaction du Chisel et débris. Aucune solution n'est canonisée à l'avance. La lisibilité Bone/Clay reste principalement un sujet P4/P6.

Règle de conception : ne pas ajouter un contournement dans une phase antérieure pour un problème qu'une phase déjà prévue doit remodeler, sauf s'il bloque la validation de la phase courante.

**Zoom validé humainement le 2026-10-02 ; ergonomie debug validée humainement ; aide permanente des raccourcis ajoutée en bas et vérifiée visuellement. STOP à P3. PR #4 conservée en brouillon ; aucun merge ni P4/P5 sans nouvelle autorisation explicite d'Antoine.**

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → **P3 Fossile** → P4 Game feel → P5 UI/progression → P6 Art pass (spike puis application) → P7 Tuning → V0.1.

La [roadmap](../ROADMAP.md) fixe les gates suivants. Les [systèmes futurs confirmés](../FUTURE_SYSTEMS.md) restent différés après V0.1 ; leur documentation n'autorise aucune implémentation dans P3.
