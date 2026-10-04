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

## Deuxième test humain et finition P4 — 2026-10-03

Antoine confirme Chisel/fracture, profondeur, lisibilité, condition moins punitive et zoom/pan. Sons découverte/hit direct jugés parfaits, Brush audio suffisant pour P4. La boucle suscite encore environ 15 minutes de jeu supplémentaires. Préserver ces acquis.

La correction autorisée sépare **Transient Chunks / Loose Debris / Fine Dust**. Les gros éclats expirent en 1–2 secondes ; les miettes persistantes sont plafonnées localement (deux par 24×24 texels, toutes matières partagées, taille ≤1,6 mm). Au plus 8 % du retrait nourrit les miettes, l’excédent retourne à Fine Dust. Le nettoyage libère le budget. Ce choix vise un Blower périodique satisfaisant sans timer ni retuning de ses paramètres.

**Exception explicite au périmètre initial : quatrième outil Precision Pick [4].** LMB maintenu + mouvement, rayon 3 texels, retrait structurel lent et local de Clay/Sandstone, sans fracture de plaques. Un passage respecte l’interface initiale, une profondeur maximale et le bone ceiling. Zéro dégât **provisoire P4** pour pouvoir finir les restes attachés ; aucune protection supplémentaire du Chisel et aucun bonus Brush. Les paramètres du nouvel outil sont des valeurs de départ, pas le tuning P7.

Vérifié : 642 checks, 28 WAV historiques identiques à l’octet, oracle GPU conservé ; 14 scénarios à 222–240 FPS sur la machine de référence, y compris bloc entièrement sali au repos et Pick autour des os. Les sessions de 60 secondes simulées de Chisel gardent 29/27 miettes dans leurs zones ; ce résultat technique ne valide pas à lui seul la cadence humaine du nettoyage.

Prochaine action : huit points de retest dans [P4_REPORT](../dev/P4_REPORT.md). **STOP après livraison, PR #5 en brouillon, aucun merge ni P5 sans nouvelle autorisation explicite.**

## Troisième test humain et corrections ciblées P4 — 2026-10-03

Le Chisel reste très fun ; fracture, audio Brush/osseux, condition, picking et caméra restent validés. Antoine autorise uniquement cinq corrections : contact du proxy, lisibilité Fine Dust, soulèvement directionnel de la poussière nettoyée, réglage du Pick et distinction attaché/détaché/transitoire. La réduction du budget de miettes est conservée.

Choix livrés : pointe réelle au hit, repère continu de normale, protection du mesh visuel contre le relief ; amas de poussière stables dans le shader R8 ; packets temporaires issus de cellules effectivement nettoyées, transformés en bouffées dans le pool AirDust existant. Écailles détachées ≤1,4 × 0,196 mm, deux par zone locale, F1 avec compteurs de voisinage. Aucun changement de géométrie gameplay par les proxies/FX.

Pick seul retuné : puissance 0,16 → 0,22 ; efficacités Clay 0,60 → 0,75 / Sandstone 0,45 → 1,00 ; vitesse de référence 100 → 40 texels/s. Rayon, limite par passage, interfaces et plafond osseux conservés. Clay deux fois plus rapide que grès au débit central nominal ; zéro dégât reste provisoire P4.

Leçons vérifiées : une normale ne suffit pas contre une paroi opposée concave ; contrôler aussi l’intérieur des faces. `Mesh.get_faces()` quantifie son maillage dérivé : les tests précis doivent lire `surface_get_arrays`. Réutiliser sommets/échantillons locaux et borner la topologie pour éviter que le contrôle visuel dépasse le budget. Le billboard MultiMesh doit conserver explicitement l’échelle des instances.

Vérifié : **1 093 checks fonctionnels**, 16 contrôles graphiques, oracle GPU conservé, 28 WAV historiques identiques ; **22 scénarios à 123–240 FPS**, P95 maximal 14,039 ms. Les captures montrent la saleté/son nettoyage, sans valider subjectivement « ça souffle ». Sept points de retest dans [P4_REPORT](../dev/P4_REPORT.md). **STOP après livraison ; PR #5 brouillon, aucun merge ni P5.**

## Simplification finale P4 après nouveau test humain — 2026-10-03

Décisions explicites d’Antoine : le joueur ne distingue que **matière attachée / saleté**. Soil → Brush, matrice dure en volume → Chisel, détails près de Bone → Precision Pick, mess → Brush/Blower. La distinction Loose Debris/Fine Dust reste interne ; les petites écailles sont une composante de la saleté.

Règle verrouillée : **Dust may obscure detail, never material identity.** Bone conserve son ivoire et sa réponse lumineuse même poussiéreux. Dépôts colorés selon le matériau local, sans map supplémentaire. Orientation visuelle fixe des outils, pointe ancrée, dégagement vertical du corps ; éclats plus petits/rares, rapidement éjectés hors du centre. Le suivi de normale de la troisième passe est abandonné conformément au retour humain.

Le Pick devient un **micro-Chisel sûr** : clic/maintien immobile, 6 Hz, rayon 3, puissance 0,24, efficacités 0,30/1,00/1,50. Retrait direct sans grosses fractures, arrêt de couche et plafond osseux intact ; zéro dégât provisoire P4. Le faible débit en volume vient de la surface minuscule, plus d’un grattage lent obligatoire. Le mode SCRAPE est retiré. Chisel, Brush, Blower, résistances, fracture, audio et caméra sont préservés.

Vérifié au code `f62fccf` : **1 376 checks fonctionnels + 62 contrôles graphiques**, oracle GPU et 28 WAV historiques exacts ; **24 scénarios à 169–240 FPS**, P95 maximal 13,365 ms sur la machine de référence. Point de vigilance réel : dégagement de corps jusqu’à 36,32 mm dans la cavité synthétique quasi verticale. Les tests ne remplacent pas le verdict humain sur la silhouette ou le plaisir.

Leçons : conserver l’identité du matériau sous les effets de saleté ; séparer la petite aire d’un outil de son efficacité locale ; un manche rigide à orientation fixe et une pointe raccordée permettent le dégagement sans suivre les micronormales. Les bornes visuelles doivent être examinées sur les cas extrêmes, pas seulement sur le plat.

Prochaine action : les **huit points exacts** de [P4_REPORT](../dev/P4_REPORT.md#retest-humain--exactement-huit-points), dont la boucle Brush → Chisel → Pick → Blower et 10–15 minutes libres. **STOP après livraison. PR #5 en brouillon, aucun merge ni P5.**

## P4 FINAL FEEL — composition issue du test A/B, 2026-10-04

Antoine choisit le spectacle Chisel A (`42ec46d`), le cleanup Blower B (`c25b44f`), Soil/Pick récents et l’ancien angle fixe. La réduction du nombre et de la taille des éclats avait diminué le plaisir : le problème à traiter était l’accumulation persistante. Décision confirmée : **séparer puissance du spectacle transitoire et quantité de saleté durable**. La cible canonique est [P4_FINAL_FEEL_TARGET](../dev/P4_FINAL_FEEL_TARGET.md).

Implémentation : éclats 3–6 mm, 1–5 par plaque réelle, expiration courte dans les pools existants ; naissance au dessus estimé de la plaque enlevée. Miettes dures jusqu’à 4,5 mm pour rendre le souffle visible, sans augmenter la rétention 8 %, le plafond de deux dépôts/zone ou leur capacité. Soil, Pick micro-Chisel, fracture, condition et caméra restent inchangés. Angle A/B fixe `(0.5, 0, -0.62)`, pointe précise et dégagement du corps conservés.

Nouvelle règle audio : **un petit tik Bone à la première détection du spécimen par reset ; un gros clack uniquement sur hit direct qui diminue la condition ; tous les autres reveals gardent le son de matière**. `bone_revealed` reste le compteur d’exposition supplémentaire ; `bone_first_contact` et la perte réelle transportée dans l’événement gouvernent seulement le feedback. Aucun changement de dommage ou protection supplémentaire.

Leçons vérifiées : des fragments créés après le retrait peuvent disparaître dans les parois si on les fait naître au nouveau fond ; utiliser le volume/cellules pour estimer le dessus retiré rend leur projection visible, sans physique terrain. Restaurer un angle plus oblique augmente le coût du dégagement local et la longueur du raccord de pointe dans une cavité extrême ; documenter ces compromis, sans refaire tourner le manche selon la normale.

Code `8394ee9` : **1 395 checks fonctionnels + 90 contrôles graphiques**, oracle GPU et 28 WAV historiques exacts ; **28 scénarios à 96,56–239,97 FPS**, P95 maximal 19,249 ms. Les valeurs persistantes restent 29/27 miettes après une minute simulée de Chisel, zéro après Blower. Ces preuves ne valident pas le plaisir humain.

Prochaine action : les **sept points exacts** de [P4_REPORT](../dev/P4_REPORT.md#retest-humain--exactement-sept-points). **STOP, PR #5 brouillon, aucun merge. P4-V (macro-stratigraphie / profondeur variable / vraie physique de débris) reste une proposition bloquée jusqu’au test humain et à une nouvelle autorisation ; P5 interdit.**

## Bugfix ciblé P4 FINAL FEEL — 2026-10-04

Antoine juge le reste du Final Feel plutôt bon et autorise uniquement Brush FPS et protection du premier contact direct Bone. La découverte adjacente garde le son matériau et ne consomme jamais la protection. `first_direct_contact_consumed`, indépendant de `first_contact`, se réarme au reset : premier Chisel direct tik/100, deuxième DING/97. Pick/Brush/Blower restent sûrs et ne consomment rien. **Correction ultérieure canonique : la consommation à la révélation centrale de ce bugfix est abandonnée par le dernier lock ci-dessous ; seul un centre déjà visible avant le coup est éligible.** L’interprétation précédente « tik à la première découverte » est également remplacée.

Leçon mesurée : la stabilité de topologie ne rend pas gratuit un mesh reconstruit à chaque pose. Ancien Brush : jusqu’à 1 498 lectures terrain/pose, tableaux/normales et meshes répétés ; le coût croît avec la densité. Nouveau Tip/Body statique : ≤12 sondes, ≤48 lectures, zéro reconstruction, angle A/B conservé. Geste identique de 30 s à 1×/3× : 144/154 → 233/236 FPS, proxy P95 8,6/8,4 ms → 32 µs. La chute humaine <10 FPS n’a pas été reproduite ; le surcoût du proxy est isolé, les autres états gameplay correspondent.

Priorité confirmée : fluidité, angle stable, point exact lisible, puis anti-clipping raisonnable ; petites intersections rares acceptées. Régression CPU par nombre de lectures/meshes statiques et benchmark proxy on/off, au-delà des FPS absolus. [Rapport et trois points de retest](../dev/P4_REPORT.md#retest-humain--exactement-trois-points). STOP ; PR #5 brouillon, aucun merge, P4-V ou P5.

## Dernier lock P4 FINAL FEEL — 2026-10-04

Valeurs validées par le test humain, persistées dans les ressources (rayon / puissance / falloff) : **Brush 40 / 0.70 / 1.25 ; Chisel 22 / 0.64 / 2.25 ; Blower 60 / 0 / 1.00 ; Pick 7 / 0.24 / 1.50**. **P4 human-validated baseline — tuning final deferred to P7.** Cadences, efficacités, résidu, dégâts, résistances et seuils de fracture inchangés. Les anciens rayons 12/3 des entrées historiques ne sont plus les baselines courantes.

Règle confirmée : **premier Chisel sur un centre Bone déjà exposé AVANT cet impact** uniquement. Capturer cet état avant toute mutation. Révélation cachée, centrale ou adjacente : matériau, zéro dégât, protection disponible, aucun événement protégé. Clic suivant sur l’os désormais visible : petit tik/100, protection consommée ; suivant : DING/97. Reset réarme ; Pick/Brush/Blower ne consomment jamais. Ne jamais déduire le contact de l’exposition après coup ou de la découverte du spécimen.

Leçon : une protection destinée au premier geste volontaire sur une cible visible doit utiliser son état **avant** l’action, sinon la révélation peut dépenser la protection à l’insu du joueur. Aucun changement de spectacle, transport, Dust, proxies, caméra ou debug. Résultats et preuves du lock : [P4_REPORT](../dev/P4_REPORT.md). STOP après push ; PR #5 brouillon, P4 prêt pour décision de fermeture, aucun merge ni P4-V/P5 autorisé.

## Dernier micro-fix P4 — protection par composant, 2026-10-04

Antoine remplace la protection globale des passes précédentes par **une protection indépendante par composant anatomique**. B-17 : **Skull / Spine / Ribs / Hind Limb**, quatre maximum par reset. Toutes les côtes partagent RIBS, toutes les vertèbres partagent SPINE ; aucune protection par cellule, os individuel ou nouvelle zone. `direct_contact_consumed` est un tableau de cinq octets indexés par `Component`, NONE inutilisé. Reset remet les quatre états à READY.

Précondition inchangée : le centre doit être **déjà exposé avant l’impact** et l’outil dommageable. Première frappe du composant : tik et zéro dégât ; suivantes sur ce composant : DING/−3. **Bone Condition reste globale** : Skull → Skull → Ribs → Ribs = 100 → 97 → 97 → 94. Révélation centrale/adjacente, Pick, Brush et Blower ne consomment jamais. Seul ajout debug : READY/USED dans les lignes F1 existantes. Cette règle est une **baseline P4 réévaluable en P7**.

Code `0c549f5` : **1 517 contrôles fonctionnels + 90 graphiques**, zéro échec ; 72 nouveaux vérifient aussi une autre côte, une autre vertèbre, reset et outils sûrs. Sanity de quatre scénarios à **239,86–239,87 FPS**, P95 maximal 4,325 ms. Baselines outils, ressources et tout le reste du feel inchangés. **P4 Final Feel ready for human closure / P4-V authorization.** STOP après push ; PR #5 brouillon, aucun merge ni P4-V/P5 sans nouvelle autorisation.

## P4 validé et fondation de verticalité avancée à P4-V1 — 2026-10-04

Antoine confirme la validation humaine et le merge P4 Final Feel (`7ae0fec3c004d207c99f4713111a240f8d5f2e9a`), puis autorise uniquement **P4-V1 Verticality**, [brief](../dev/P4V_BRIEF.md), PR #6 brouillon. La fondation de macro-verticalité déterministe est avancée car elle modifie le core gameplay. **Génération par seed, multiples blocs et systèmes de sites restent post-core.** P4-V2 debris physics exige un test humain V1 puis une autorisation séparée ; P5 reste bloqué.

Choix implémenté : profil pur en UV, pente Soil, lentille large Clay indépendante et enfouissement incliné/warpé commun à B-17. Résoudre les overlaps dans l’authoring P4 puis translater le gagnant conserve les IDs même si un clamp devenait actif. Cartes statiques construites une fois, aucun calcul vertical par tick ; reset exact. La silhouette de 32 290 cellules et les totaux de composants restent inchangés. Bone passe de 65,79–77,85 à 55,35–85,34 mm de profondeur. Les outils, fracture, sons, protections et budgets P4 restent verrouillés.

Leçons vérifiées : tester les anciennes fixtures avec la matière réellement sous le point, plutôt qu’une hauteur fixe supposée « Clay » ; comparer la silhouette à un oracle figé avant la modification ; contrôler la composante ajoutée du champ pour sa douceur, sans confondre les bords anatomiques avec du bruit. Le `PlaneMesh` natif accumule des pas float32 : aligner X/Z depuis UV dans le shader évite sa dérive par rapport à la grille CPU, surtout sur les rayons rasants. Les intermédiaires de l’intersection Möller–Trumbore passent en scalaires float64, avec les mêmes tolérances, pour tenir le budget de 5 µm. L’oracle indépendant utilise une équation de plan et des barycentriques float64, afin de ne pas recopier cet algorithme ni introduire sa propre erreur de tangence.

Validation finale : 1 604 contrôles fonctionnels, 90 visuels, neuf empreintes reproductibles et 60 scénarios de performance, zéro échec dans les phases finales. V1 : P95 maximal 12,757 ms, minimum sur une seconde 210,54 FPS ; pointe isolée de 18,728 ms documentée. Le harnais graphique conserve l’horloge de son maintien synthétique face aux notifications Windows ; le comportement de focus du jeu et ses cadences restent inchangés.

Formules, mesures, limites de rasterisation et checklist humaine dans [P4V_REPORT](../dev/P4V_REPORT.md). Aucun intérêt humain de V1 n’est inféré de l’automatisation. **STOP après livraison : attendre Antoine, ne pas merger ni lancer P4-V2.**

## P4-V1.1 — verticalité sensible à l'effort, 2026-10-04

**Antoine valide humainement le principe de verticalité V1**, mais certaines colonnes Sandstone rendent la fouille trop longue. Correction autorisée uniquement sur la distribution des couches, depuis `122e9b1cf6dfacad721f9af240ef30592de8491c`. Garder les profondeurs Bone et les paramètres P4 ; remplacer une partie de Stone par Clay avec un champ large en UV, sans masque de squelette ni correction par cellule.

Règle confirmée : **“Verticality / generation must be effort-aware, not depth-only.”** Une future seed devra respecter des budgets de travail pondérés par la matière et des quantiles/maxima sur toute la population Bone, en plus des contraintes géométriques. Clay coûte 3/1 =3 par mm ; Stone 8/1,5 =5,333… : une profondeur identique ne représente pas un effort identique. L'oracle debug/test compte uniquement la matrice au-dessus du plafond Bone et ne prédit pas le temps réel.

Implémentation : nappe Clay à épaules douces, gradient et deux lobes larges. Soil et tous les plafonds/IDs/totaux Bone restent exacts à trois résolutions ; amplitude 29,99 mm conservée. Sur 32 290 cellules, Stone médiane/P95/max : **23,28/31,48/36,94 →11,59/17,12/21,49 mm**. Effort médiane/P95/max : **174,18/207,47/231,88 →147,28/175,70/199,65**. 90,11 % des cellules conservent 5–18 mm de Stone. Les budgets sont provisoires P4-V, tuning final P7.

Leçon validée : les seules fixtures A/B/C ne détectent pas les colonnes extrêmes ailleurs sur le fossile. Figer la référence avant correction et contrôler la population entière évite ce biais. Les anciens contrastes Clay/Stone des fixtures sont actualisés pour refléter la redistribution ; les seuils géométriques et matériaux restent inchangés. Outils, résistances, fracture, protection, audio, caméra et rendu ne sont pas retunés.

Preuves, résultats de régression et performances : [P4V_REPORT, section V1.1](../dev/P4V_REPORT.md#v11--vérification-et-performance). La livraison demandait les cinq questions V1.1 ; le retour humain et le prochain protocole sont actualisés ci-dessous. PR #6 brouillon, aucun P4-V2, procgen ou P5.

## P4-V1.2 — interfaces et lecture des morceaux, 2026-10-04

**Antoine juge la base verticale V1.1 meilleure et conserve cette direction.** Seul un cleanup visuel est autorisé : grille orange Clay/Sandstone et séparation des blocs/éclats/miettes. Aucune nouvelle passe de géologie, retuning outil, modification Bone ou physique de débris.

Cause vérifiée : une hauteur interpolée sur triangles comparée à une limite bilinéaire peut afficher une fausse matière, même quand les deux cartes sont identiques. Calculer leur différence aux mêmes sommets puis interpoler la différence supprime l'artefact ; le picking doit utiliser les mêmes triangles. Tolérance commune de présentation `1e-6` normalisée, sans toucher les seuils de travail par cellule. Les cartes V1.1 gardent leurs empreintes exactes ; les cinq fixtures GPU n'ont plus de couleur parasite, y compris avec une pellicule Clay réelle de 0,051 mm.

Lisibilité : légère différence de valeur entre dessus/parois dures et couleurs de faces précalculées dans les meshes de morceaux existants. Pas de silhouette, trajectoire, quantité ou durée nouvelle. Le contraste augmente dans les fixtures, mais le jugement de profondeur/plaisir appartient au test humain.

Leçon de validation : figer l'état de simulation et attendre des frames complètes après un échange de mesh/shader avant lecture GPU ; une capture trop précoce peut confondre absence temporaire et contraste. [Preuves et trois questions V1.2](../dev/P4V_REPORT.md). **STOP après push, PR #6 DRAFT ; aucun merge, P4-V2, procgen ou P5.**
