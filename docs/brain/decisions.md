# Décisions initiales

Source : décisions confirmées par Antoine au 2026-09-30 et au 2026-10-01.

## Décisions produit

| Décision | Conséquence |
|---|---|
| Tabletop fixe, sans avatar | La fouille est le centre du jeu |
| DA 2.5D stylisée, orthographique presque verticale | Relief, lumière et profondeur prioritaires |
| Pixel art non retenu pour V0.1 | Liberté de creusement et contours |
| Trois outils | Soft Brush, Chisel, Air Blower |
| Matières cœur | Loose Soil, Compact Clay, Sandstone |
| Specimen B-17 | Petit théropode fictif / indéterminé |
| Premier contact os protégé | La découverte ne punit pas instantanément |
| Bone Condition sans Game Over | Tension légère |
| Musée scrollable, non navigable | Méta-progression future |
| Godot 4.7.2 stable Standard | Stack prototype |

## Gates validées

### P0
Validé par Antoine. Merge :
`244aba3652a03aac908b1aabe1651c3b9edb1315`.

### P1
Validé par Antoine. Merge :
`960642c3fc6972bdb257c96abd43b90c148e632d`.

Décisions techniques principales :

- height RF 1024×640 ;
- grille GPU dense ;
- picking DDA sur la même topologie que le rendu ;
- stratigraphie statique irrégulière ;
- Hard Rock omis.

### P2
Validé par Antoine : les outils fonctionnent comme voulu pour le prototype.

Merge :
`9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.

Décisions P2 :

- ToolDefinition minimal ;
- Brush continu ;
- Chisel impacts discrets à 4,5 Hz ;
- Blower sans excavation structurelle ;
- résidu debug léger 256×160 R8 ;
- aucun système fossile ou polish final en P2.

## Décision FPS — 2026-10-01

Pendant P2, Godot utilisait la RTX 5080 à 100% lorsque le rendu était non plafonné.

Décision d'Antoine :

- **runtime interactif normal plafonné à 240 FPS à partir de P3** ;
- benchmarks autorisés à override le plafond ;
- ne pas lancer de chantier d'optimisation GPU supplémentaire tant que le comportement à 240 FPS n'est pas retesté ;
- si nécessaire, réduire encore le cap après test humain.

## Scope P3

P3 est autorisé.

Il doit couvrir :

- fossile caché ;
- exposition progressive ;
- bone ceiling ;
- Bone detected ;
- protection premier contact ;
- condition 100→0 ;
- dégâts Chisel uniquement sur os déjà exposé ;
- Brush/Blower sûrs ;
- exposition globale/composants.

P3 ne doit pas couvrir classification, fragments, objectifs, final audio/VFX ou musée.

Référence : [P3_BRIEF](../dev/P3_BRIEF.md).

## Choix techniques P3 implémentés

- Un champ statique aligné à la hauteur P1 porte plafond et ID de composant ; l'occupation dérive de l'ID. Même géométrie/picking, aucune texture dynamique supplémentaire.
- Quatre composants fixes de B-17 : Skull, Spine / Vertebrae, Ribs, Hind Limb. Pas de génération aléatoire ou d'asset externe.
- Exposition structurelle par cellule, epsilon binaire `1/65536` et comparaison sur les float32 réellement stockés pour accorder CPU et GPU.
- Dégât décidé sur le centre **avant** l'impact : révélation protégée puis −3 points par impact direct sur os déjà exposé. Résidu et condition indépendants.
- Événements émis après synchronisation ; compteur de composant regroupé par opération. Premier contact réarmé seulement par reset.
- Cap Godot `application/run/max_fps=240`, physique 60 Hz. Aucun changement de densité du mesh. Lectures osseuses évitées tant que le retrait reste au-dessus du plus haut plafond.

Décision complète : [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md). Résultats et limites mesurés : [P3_REPORT](../dev/P3_REPORT.md). **Aucune validation humaine P3 ou autorisation P4 n'est inférée des tests automatiques.**

## Retour humain P3 et suite — 2026-10-01

Antoine confirme : « Ok tout fonctionne et le GPU ne surchauffe plus. » Le fonctionnement P3 est validé humainement et le cap 240 FPS est conservé. Il souhaite cadrer quelques modifications design avec l'orchestrateur avant une nouvelle passe ; leur contenu reste à définir. Ce retour n'autorise ni le merge de la PR #4 ni P4/P5.

## Passe corrective P3 : zoom seul — 2026-10-01

Le cadrage actuel de [P3_DESIGN_FIXES](../dev/P3_DESIGN_FIXES.md) et la confirmation explicite d'Antoine remplacent la proposition initiale de marge osseuse : **zoom joueur seulement**. La marge de 2 mm et le bonus Brush près des os ne sont pas livrés ; les outils et la condition retrouvent leur logique P3 initiale.

Zoom orthographique 1×–3× au curseur, orientation 84° fixe ; réglages debug sur F6/F7 et modificateurs ; Home restaure le cadrage et R restaure aussi le spécimen. Le zoom et le picking attendent un retest humain ; PR #4 non mergée et P4/P5 bloqués.

Bone Condition reste une preuve technique, avec premier contact protégé et dégâts sur os déjà exposé. Son équilibrage n'est pas final ; conserver 100 % lors d'une fouille attentive n'est pas encore un critère P3. P4 réévaluera l'évitement des dégâts après les réactions de matière et le Chisel prévus. La lisibilité Bone/Clay reste différée à P4/P6.

Règle réutilisable : ne pas ajouter dans une phase antérieure un contournement pour un problème qu'une phase déjà prévue doit remodeler, sauf s'il empêche de valider la phase courante.

## Future product pillars confirmed — 2026-10-01

These directions are now confirmed as intended future features, but their detailed design is deliberately deferred until the core excavation loop and visual pipeline are validated.

### Variable excavation blocks

The finished game must not repeat identical layer depths and stratigraphy across every block.

Future blocks should use controlled, seed-based / authored variability so the player reads the material rather than memorizing fixed depths.

Confirmed future variation may include:

- variable layer thicknesses;
- irregular interfaces;
- local pockets / lenses;
- variable fossil depth / position / orientation where compatible;
- difficulty bands.

Implementation is deferred until after the V0.1 core gate.

### Equipment progression

Long-term progression should include tool unlocks / specialization in addition to fossil collection.

Prefer functional choices (precision, width, stiffness, power/risk, nozzle control, preservation tools) over simple percentage upgrades.

Detailed progression economy / tree / currency remains open for a dedicated brainstorm.

### Expertise / site progression

Long-term progression should also unlock more demanding excavation sites / matrices.

Possible framing includes museum prestige, expertise, reputation, funding or another diegetic system.

Detailed design is deferred.

Reference: [FUTURE_SYSTEMS.md](../FUTURE_SYSTEMS.md).

## Visual-production timing clarified — 2026-10-01

Canonical roadmap numbering remains:

**P0 → P1 → P2 → P3 → P4 → P5 → P6 Art Pass → P7 Tuning**

There is **no separate ART0 phase**.

Decision:

- advance gameplay with placeholder/greybox visuals using a Pareto 80/20 approach;
- P4 adds only the sensory visuals/audio needed to validate game feel;
- P5 completes the gameplay loop and functional UI without requiring final DA;
- P6 is the dedicated DA milestone once visual production has greater leverage than adding another gameplay system;
- inside P6, first run a **P6A Visual Direction / Production Spike**, then a **P6B V0.1 Art Pass**;
- P7 tunes the completed, art-passed slice.

DA remains a core product risk and must not be treated as optional polish, but expensive production art is intentionally deferred until the gameplay foundation is mature.

Reference: [ROADMAP.md](../ROADMAP.md) and [ART_DIRECTION.md](../ART_DIRECTION.md).

## Validation humaine du zoom et ergonomie debug — 2026-10-02

Antoine valide humainement le zoom et autorise uniquement une petite passe debug : molette seule = zoom ; Shift+molette = puissance ; Ctrl+molette = falloff ; Alt+molette = rayon. F6/F7 restent en secours. Valeurs par défaut inchangées. Les réglages annulent le geste courant et ne déclenchent pas de zoom. 439 checks fonctionnels passent, dont 160 input/zoom. PR #4 non mergée ; aucune autorisation de merge ou P4 n’est inférée.

## Engine policy — Godot remains canonical — 2026-10-01

Decision by Antoine:

> Continue development on Godot. Do not perform a speculative Unity port or parallel implementation.

Rationale:

- Godot currently satisfies the technical needs of ArchaeologyGame;
- the existing P0–P3 architecture is progressing quickly and has not hit an engine-specific blocker;
- switching now would impose a certain rewrite cost for hypothetical benefits;
- Unity's larger ecosystem / artist tooling is acknowledged, but is not sufficient reason by itself to migrate.

A Unity switch should be reconsidered only if a **concrete, material engine limitation** appears, for example:

- a required visual/VFX result is significantly harder or impractical in Godot;
- the art/content pipeline is materially less efficient than a Unity equivalent;
- performance cannot meet target hardware after reasonable Godot optimization;
- console/platform requirements make Unity materially more practical;
- a critical production tool or middleware cannot be integrated reasonably in Godot.

The comparison standard is not “Unity has more features”, but:

> **Would Unity materially reduce risk, effort, or quality limitations for a problem we are actually facing?**

Until such a case exists, Godot 4.7.2 remains the canonical engine for the prototype and subsequent development.



## P3 final — 2026-10-02

P3 est validé humainement et mergé.

Merge PR #4 :

`10a12379ab1db629380ac9697e5597aeb16a373b`

Décisions finales :

- Specimen B-17 / bone ceiling / exposition / condition technique validés ;
- zoom orthographique 1×–3× au curseur validé ;
- aide et raccourcis debug validés ;
- cap 240 FPS conservé ;
- le hook de découverte fonctionne : une fois l'os perçu, Antoine veut continuer à le révéler.

Bone Condition n'est pas considérée équilibrée en P3.

Le problème observé vient potentiellement du comportement encore simplifié du Chisel et des matériaux. Il est donc explicitement reporté à P4, après introduction de fissures/chunks/débris.

Règle maintenue :

> Ne pas créer un workaround dans une phase antérieure pour un problème qu'une phase suivante est précisément censée remodeler.

## P4 autorisé — 2026-10-02

P4 = **Game Feel / Material Reactions**.

Objectif :

- faire sentir des matières différentes par leur comportement ;
- faire du Chisel un outil de frappe/fracture et non un effaceur de pixels ;
- introduire particles/debris/audio/tool presence en qualité prototype ;
- améliorer la lisibilité de la découverte ;
- réévaluer ensuite seulement l'évitement des dégâts osseux.

P4 reste un jalon gameplay/game feel, pas un Art Pass.

Référence : [P4_BRIEF](../dev/P4_BRIEF.md).

## Implémentation P4 et état de validation — 2026-10-02

- Partition angulaire seedée et stress sparse par matériau : Clay 9 texels / plaques, Sandstone 5 texels / fragments. Un impact ne traverse pas la couche initialement touchée ; plafond osseux toujours appliqué.
- Atlas dynamique de stress RG8 **64 372 octets** ; aucun masque mutable à la résolution du heightfield. Reset exact, aucun calcul de fracture au repos.
- Les effets consomment les actions réelles : proxies sans collider, quatre pools MultiMesh limités à 192 particules, six familles audio originales × quatre variantes. F2 masque les effets pour conserver des vues de données et un oracle GPU sans occlusion.
- La sonde attentive conserve 100 % de condition avec 49,87 % du crâne révélé. Cette preuve technique ne valide ni la lisibilité humaine ni le plaisir ; aucune protection nouvelle n'a été nécessaire pour cette sonde et aucune n'est ajoutée.
- Un pic isolé au premier effet a motivé une préchauffe invisible du matériau instancié au démarrage. Le passage final reste sous 11,6 ms par frame mesurée ; ne pas généraliser cette mesure à tous les pilotes.
- P4 reste à valider humainement. PR non mergée ; P5/P6/P7 non commencés.

Références : [P4_REPORT](../dev/P4_REPORT.md), [P4_MATERIAL_REACTION_DECISION](../dev/P4_MATERIAL_REACTION_DECISION.md).

## Retour humain et passe corrective P4 — 2026-10-02

Antoine confirme une fouille devenue addictive : environ 15 minutes supplémentaires malgré l'intention d'arrêter, Chisel très fun. Préserver marks → cracks → chunks et les réglages existants ; aucun tuning final avant P7.

Décisions confirmées : Fine Dust et Loose Debris persistants séparés ; miettes déjà détachées nettoyables sans toucher au grès structurel ; souffle directionnel avec événement de sortie pour un futur atelier ; Brush audio continu ; découverte osseuse distincte du hit direct ; pan RMB à angle fixe et Home complet. Aucun quatrième outil, marge osseuse, table salissable ou P5.

Implémentation vérifiée : carte de poussière R8 conservée, bins sparse 8×8 et MultiMesh, paquets de miettes regroupés localement pour éviter un objet par tick. 585 checks passent, oracle GPU et budget graphique conservés. La masse des paquets est une quantité visuelle normalisée ; la physique fine reste une limite explicite.

Le premier retour positif ne valide pas encore les corrections : attendre le nouveau test humain du rapport. PR #5 reste en brouillon et non mergée.
