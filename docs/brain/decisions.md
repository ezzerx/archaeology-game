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

Le Pick devient un **micro-Chisel sûr** : clic/maintien immobile, 6 Hz, rayon 3, puissance 0,24, efficacités 0,30/ 1,00/ 1,50. Retrait direct sans grosses fractures, arrêt de couche et plafond osseux intact ; zéro dégât provisoire P4. Le faible débit en volume vient de la surface minuscule, plus d’un grattage lent obligatoire. Le mode SCRAPE est retiré. Chisel, Brush, Blower, résistances, fracture, audio et caméra sont préservés.

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

Règle confirmée : **“Verticality / generation must be effort-aware, not depth-only.”** Une future seed devra respecter des budgets de travail pondérés par la matière et des quantiles/maxima sur toute la population Bone, en plus des contraintes géométriques. Clay coûte 3/1 =3 par mm ; Stone 8/ 1,5 =5,333… : une profondeur identique ne représente pas un effort identique. L'oracle debug/test compte uniquement la matrice au-dessus du plafond Bone et ne prédit pas le temps réel.

Implémentation : nappe Clay à épaules douces, gradient et deux lobes larges. Soil et tous les plafonds/IDs/totaux Bone restent exacts à trois résolutions ; amplitude 29,99 mm conservée. Sur 32 290 cellules, Stone médiane/P95/max : **23,28/31,48/36,94 →11,59/17,12/21,49 mm**. Effort médiane/P95/max : **174,18/207,47/231,88 →147,28/175,70/199,65**. 90,11 % des cellules conservent 5–18 mm de Stone. Les budgets sont provisoires P4-V, tuning final P7.

Leçon validée : les seules fixtures A/B/C ne détectent pas les colonnes extrêmes ailleurs sur le fossile. Figer la référence avant correction et contrôler la population entière évite ce biais. Les anciens contrastes Clay/Stone des fixtures sont actualisés pour refléter la redistribution ; les seuils géométriques et matériaux restent inchangés. Outils, résistances, fracture, protection, audio, caméra et rendu ne sont pas retunés.

Preuves, résultats de régression et performances : [P4V_REPORT, section V1.1](../dev/P4V_REPORT.md#v11--vérification-et-performance). La livraison demandait les cinq questions V1.1 ; le retour humain et le prochain protocole sont actualisés ci-dessous. PR #6 brouillon, aucun P4-V2, procgen ou P5.

## P4-V1.2 — interfaces et lecture des morceaux, 2026-10-04

**Antoine juge la base verticale V1.1 meilleure et conserve cette direction.** Seul un cleanup visuel est autorisé : grille orange Clay/Sandstone et séparation des blocs/éclats/miettes. Aucune nouvelle passe de géologie, retuning outil, modification Bone ou physique de débris.

Cause vérifiée : une hauteur interpolée sur triangles comparée à une limite bilinéaire peut afficher une fausse matière, même quand les deux cartes sont identiques. Calculer leur différence aux mêmes sommets puis interpoler la différence supprime l'artefact ; le picking doit utiliser les mêmes triangles. Tolérance commune de présentation `1e-6` normalisée, sans toucher les seuils de travail par cellule. Les cartes V1.1 gardent leurs empreintes exactes ; les cinq fixtures GPU n'ont plus de couleur parasite, y compris avec une pellicule Clay réelle de 0,051 mm.

Lisibilité : légère différence de valeur entre dessus/parois dures et couleurs de faces précalculées dans les meshes de morceaux existants. Pas de silhouette, trajectoire, quantité ou durée nouvelle. Le contraste augmente dans les fixtures, mais le jugement de profondeur/plaisir appartient au test humain.

Leçon de validation : figer l'état de simulation et attendre des frames complètes après un échange de mesh/shader avant lecture GPU ; une capture trop précoce peut confondre absence temporaire et contraste. [Preuves et trois questions V1.2](../dev/P4V_REPORT.md). **STOP après push, PR #6 DRAFT ; aucun merge, P4-V2, procgen ou P5.**

## P4-V1 validation humaine et merge — 2026-10-04

Antoine valide **P4-V1 Verticality** après la passe V1.2. La macro-stratigraphie déterministe, la redistribution sensible à l'effort et le cleanup des interfaces sont conservés comme nouvelle baseline. PR #6 mergée dans `main` au commit `756cd4338285e52b7d751bc0f0e1694b7792c882`.

Watchpoint différé : avant Blower, la poussière peut encore réduire la lisibilité des arêtes et des blocs ; après nettoyage, les bords sombres et la perception de profondeur sont plus nets. Ce point est **non bloquant** pour P4-V1 et doit être repris lors du polish visuel / P6-P7, en surveillant la relation poussière ↔ lecture du relief.

La verticalité actuelle est jugée suffisante pour avancer. Pas de nouvelle itération géologique avant nécessité observée. Le prochain spike possible est **P4-V2 terrain-aware debris physics** ; la génération procédurale reste future/post-core.

## P4-V2 — spike secondaire borné, 2026-10-04

Autorisation explicite d'Antoine : implémenter et mesurer les éclats Clay/Sandstone terrain-aware, livrer la PR #7 **DRAFT**, puis **STOP pour KEEP / SIMPLIFY / DROP**. P4/V1 sont la baseline ; aucun P5 ni merge automatique. Un DROP est une conclusion valide si le gain de plaisir est insuffisant.

Choix expérimental livré dans `38cc404` : 48 enregistrements préalloués, un MultiMesh, échantillonnage local du relief courant et dessous orienté. Pas de RigidBody ou de collision mesh. L'ancien chemin des éclats demeure en OFF ; les mêmes paramètres de spawn alimentent un seul des deux chemins. À saturation, seul un endormi peut être recyclé ; sinon nouvelle émission refusée. Fragments indépendants de la saleté persistante, du RF, des protections Bone et des outils verrouillés.

Leçon vérifiée : l'événement de nettoyage existant ne suffit pas pour souffler un morceau posé sur terrain propre. Un signal de jet indépendant transporte la capsule et la durée réelle sans créer d'action matière fictive. Le contact ne doit pas appliquer sa marge deux fois : cela absorbait les petites impulsions positives à 60 Hz. Le test de décollage utilise donc la cadence réelle, en plus des impulsions isolées.

Leçon de validation : comparer quinze états intermédiaires ON/OFF, ainsi que le résultat final, évite qu'une saturation de Bone Condition ou du terrain masque une divergence. La fixture cavité doit vérifier la hauteur finale relativement au plan de naissance. Le rendu, la performance et l'intérêt humain restent trois preuves différentes. Paramètres, limites et checklist : [P4V2_REPORT](../dev/P4V2_REPORT.md). Aucun KEEP acquis.


## P4-V2 — SIMPLIFY et cible persistent crumbs, 2026-10-04

**Décision humaine confirmée : SIMPLIFY** sur `d8224ec`. Il y avait un malentendu de vocabulaire : Antoine désignait les petites saletés persistantes, pas les gros éclats de casse. Règle canonique : **“Debris physics target = persistent crumbs, not transient Chisel chunks.”** La nouvelle autorisation couvre le correctif, ses tests/perfs, la documentation et le push de la PR #7 **DRAFT**, puis STOP. Aucun merge/P5.

Choix implémenté dans **`03803e5`** : restaurer le chemin des gros éclats P4-V1 à l'identique et réutiliser le seul noyau de mouvement pour `LooseDebris`. La quantité et l'occupation restent attachées à la clé de naissance ; la position physique actuelle est commune au rendu et au nettoyage. Deux miettes/24×24, 8 % retenus, capacité 0,02, cap global 128. Une miette partie de sa source garde sa place jusqu'au nettoyage ; les destinations ne sont pas rebucketées. Saturation = refus + surplus Dust, jamais recyclage visible. Dimensions communes ON/OFF 2,2 mm maximum pour la matrice ; aucun gros cube persistant. **Le sommeil n'est plus une condition d'expiration.**

Blower réveille et transporte la miette complète ; Brush garde un retrait progressif simple au point actuel. Sortie unique avec quantité restante réelle, état et budget libérés avant émission. Deux paramètres dédiés au système de miettes (5,0 / 1,8 par seconde) donnent une réponse légère, sans toucher la ressource outil. Ces paramètres physiques restent expérimentaux, non validés humainement.

Leçons vérifiées : ne pas utiliser le bucket de naissance comme position de nettoyage après transport ; tester le vrai renderer pour les transforms MultiMesh (le backend headless renvoie des données factices) ; séparer mesure de performance et attente d'une capture GPU, sauvegarder les scénarios achevés. L'oracle ON/OFF doit comparer la structure, la fracture et Bone, **pas imposer des miettes identiques alors que leur mouvement/nettoyage est précisément la variable étudiée**. La conservation de leur quantité est contrôlée séparément jusqu'à l'éjection, y compris après nettoyage partiel.

Résultats et checklist canoniques : [P4V2_REPORT](../dev/P4V2_REPORT.md). La technique prouve la chute, la persistance, l'autorité de position et les budgets ; elle ne prouve pas le fun. **Attendre le nouvel A/B humain KEEP / SIMPLIFY / DROP.**

## P4-V2 — Restaurer le look, ne modifier que le mouvement, 2026-10-04

Antoine rejette explicitement les micro-débris de `8f703ae` : taille/présence insuffisantes. **MÊMES DÉBRIS QU’AVANT, AVEC UN PEU DE PHYSIQUE.** La physique ne préautorise aucun redesign visuel ni raréfaction. Reprendre directement la baseline persistante P4-V1 : 4,5 mm max, forme, couleurs, contraste, proportions et règles locales de quantité historiques. Le cap global 128 et les mouvements V2 restent ; aucune modification des outils, de la verticalité, de Bone ou du spectacle Chisel.

Leçon confirmée : séparer l'identité visuelle déjà appréciée d'une expérimentation de comportement. La réduction 4,5 →2,2 mm retirait environ trois quarts de la couverture pixel sur les captures de contrôle, malgré la même quantité. Restaurer aussi les attentes visuelles historiques, au lieu d'adapter les fixtures pour accepter cette perte. Les captures figées vérifient désormais la présence à quantité/position identiques ; elles ne remplacent pas le retest humain.

Rapport et quatre questions : [P4V2_REPORT](../dev/P4V2_REPORT.md). **PR #7 DRAFT, STOP après push pour validation humaine ; aucun merge/P5.**

## P4 — Autorisation de clôture et Soil visible, 2026-10-04

Antoine valide la restauration Matrix 4,5 mm avec physique et le spectacle Chisel P4-V1. La clôture autorise explicitement budgets distincts Soil/Matrix, cap Matrix>128, Blower sans lévitation et nouveau film adhérent sur Bone, avant retest final. Le retour Soil impose deux feedbacks lisibles : Dust diffuse conservée **et** grains bruns plats individuels1,8–2,5 mm.

Livraison : Soil 128, Matrix 256, admission locale par matériau, Fine Dust sans slot. Le diamètre Soil1,8–2,2 mm n'est plus proportionnel à sa quantité minuscule. Pas de multiplicateur Sandstone : 38crumbs/20 impacts, rendement par volume supérieur à Clay après séparation des budgets. Le Blower donne un pop au sol, puis une poussée horizontale ; friction faible temporaire, aucune recharge verticale en vol. Banc ouvert :80/80 sortent en1 s.

**Exposure ≠ Cleanliness ≠ Condition.** Le film apparaît au signal central de première exposition et seul Brush le retire, avec continuité audio. Une carte compacte peut partager une quantité tout en gardant un masque fin des cellules sales : une nouvelle cellule exposée ne resalit pas les anciennes propres. Les cellules nouvellement révélées dans un groupe déjà partiellement nettoyé partagent la quantité restante ; aucune recharge des voisines.

Leçon vérifiée de performance : profiler Soil au cap en parallèle de Matrix en mouvement, pas seulement le noyau de débris isolé. Le stress initial échoue ; refus Soil rapides, marquage par groupe de déposition et cache de sommets limité au tick réduisent le coût sans changer les quantités ni les hauteurs canoniques. Preuves exactes dans [P4V2_REPORT](../dev/P4V2_REPORT.md).

**PR #7 DRAFT, pas de merge/P5 automatique ; STOP après push pour les tests humains Soil/Matrix/Blower/Bone Film et 10–15 min de jeu.** Le test technique ne valide pas le plaisir.

## Precision Pick — addendum humain confirmé, 2026-10-04

Nouveau test humain positif : **11 / 0,44 / 1,75** remplace **7 / 0,24 / 1,50** dans la ressource native. Cadence6 Hz, dégâts Bone 0, efficacités0,30/ 1,00/ 1,50 inchangées. Finition structurelle rapide après Chisel ; faible capacité de déblaiement due au petit footprint, pas à un impact local péniblement faible. Aucun stress de fracture ni gros chunks Chisel. Brush prépare le film adhérent, Blower chasse le mess libre. **P4 human-validated baseline — final fine tuning still deferred to P7.** Les anciennes entrées de décision conservent leur valeur historique, pas une baseline concurrente.


## P4 — Dernière clôture : simplification et évacuation, 2026-10-04

**Décision produit confirmée : “Soil particles removed for now; Soil uses dust-only feedback.”** Les grains apportent peu de lisibilité et dégradent la sensation de fluidité pendant Brush. Cette décision remplace l’addendum précédent : retirer génération persistante/transitoire, budget, hop et pool GPU Soil ; conserver Dust et son nettoyage. Les index matériau restent stables, la case0 des tableaux communs est inutilisée pour les débris.

Les petits débris persistants sont uniquement Clay/Sandstone, même look4,5 mm et physique légère. Le manque de présence hors cap se corrige par **3/4 places locales Clay/Stone**, contre2/2, sans toucher le retrait structurel ni agrandir les morceaux. Mesure à volume retiré exact :45→66 et38→65, refus cap0. La fréquence est un paramètre de débris, pas un retuning des outils.

Le Blower doit **libérer le budget par une vraie sortie**, pas seulement dégager la zone locale. La traînée réduite dure2 s après contact (0,2 s⁻¹) pour conserver l’élan hors du rayon du jet ; gravité et absence de lift répété conservées. Le state est retiré uniquement au franchissement du bord ou au nettoyage Brush. Tester départ d’un cap plein, sortie unique, nouvelles frappes puis remplissage détecte mieux les blocages qu’un compteur de mouvement seul.

Le **gameplay Bone Film est validé humainement**. Seule sa teinte change : brun terreux plus sombre, patches ivoire encore visibles, distinction Sandstone à retester. Brush seul retire le film ; pas d’autorité sur Exposure, Condition ou protections. Boucle canonique : excavation→chunks ; aftermath→Matrix crumbs + Dust ; découverte→film ; préparation→Brush film→Pick matrice attachée→Bone propre.

Pick **11 / 0,44 / 1,75**,6 Hz, dégâts0, efficacités intactes reste la baseline humaine. **P4 human-validated baseline — final fine tuning still deferred to P7.** [Preuves et retest final](../dev/P4V2_REPORT.md). **PR #7 DRAFT, STOP, aucun merge ni P5.**


## P4 — Micro-passe finale : lisibilité et nettoyage, 2026-10-05

**Retour humain : le cœur P4 est apprécié, le Bone Film actuel (gameplay et couleur) est validé.** Trois irritants seulement restent autorisés, sans nouvelle feature ni P5.

**Soil persistent dust deferred to P6/P7 redesign.** Après suppression des grains, supprimer également le dépôt persistant SurfaceResidue Soil : pas assez de valeur gameplay/feel pour fermer P4. La décision remplace « Soil dust-only ». Le retrait, l’audio, la couleur et le relief restent ; la Dust hard n’est pas supprimée.

**Micro structural remnant→detached Matrix crumb** : un reste fin et presque détaché ne doit pas obliger à deviner Pick quand il ressemble à une saleté. Helper local5×5,8-connexité,≤4 cellules,≤1,5 mm au-dessus de l’interface ou du plafond Bone, sans voisin épais/prolongement ;64 inspections maximum/action. Toute quantité convertie appartient réellement à une miette, sans grosse fracture, réaction Chisel ni dégât. Si l’admission échoue, ne pas effacer la structure. Le Brush historique pouvait encore éroder Clay à0,06 d’efficacité : cette valeur est corrigée à0 pour que l’exception reste une conversion explicite, pas du déblaiement général. Pick conserve les vrais morceaux attachés.

**Matrix crumbs can be removed by cleanup commitment, not only literal block-edge crossing.** Abandon de l’exigence de vraie sortie au bord : un souffle significatif évacue le mess dès son engagement. Poids≥0,25, dose0,075 seconde pondérée, oubli0,15 s ; un effleurement d’une frame ne suffit pas. Au seuil, libérer les budgets avant notification, lancer un FX0,35 s borné (0,65 m/s horizontal,0,08 m/s vertical, rétrécissement final). Un FX n’est jamais une unité Matrix logique. Cette règle vaut également pour Matrix déplacée/camouflée sur Soil et pour F3 OFF.

Fréquence3/4 et cap256 conservés, sans nouveau retuning. Bone Film, Pick11/0,44/1,75, autres baselines numériques et géologie restent verrouillés. Le test de reprise immédiate Chisel pendant les FX est plus pertinent que la seule distance parcourue par les débris. [Preuves, limites et retest](../dev/P4V2_REPORT.md). **STOP après push, PR #7 DRAFT, aucun merge.**


## Baseline narrative musée et P6 contact patina — 2026-10-04

Antoine canonise comme **base narrative actuelle tant qu'une meilleure piste n'émerge pas** : le joueur travaille dans les coulisses d'un musée d'histoire naturelle comme préparateur / restaurateur de spécimens. Le musée confie blocs et fragments, l'atelier est le lieu de gameplay, puis les pièces préparées rejoignent réserves, collection ou exposition. Aucun avatar contrôlable n'est ajouté.

Mise en scène retenue comme direction : **façade du musée au menu principal → atelier intérieur pendant le gameplay → galerie/collection comme destination du travail**. Le musée devient donc à la fois contexte narratif, employeur diégétique et méta-progression.

Le naming définitif reste ouvert. **Bone by Bone** est un candidat haut de shortlist, sans validation comme titre final.

P6 reçoit aussi une idée DA canonisée : **layer contact patina**. La frontière Soil → Clay doit pouvoir montrer une fine peau de Clay salie/brunie par son contact avec le Soil ; dès qu'on la creuse, la Clay intérieure apparaît plus franche/orangée. Une version plus légère Clay → Sandstone est à tester en P6A. Cette patine est visuelle uniquement : elle ne change ni épaisseur structurelle, ni résistance, ni picking.


## P4 clôturé humainement — 2026-10-05

Antoine valide la clôture de **P4 Game Feel**. PR #7 mergée dans `main` au commit `bae4ee64268dd6270afb9f0011c316c45c57d251`. La boucle d'excavation/préparation contient désormais les éléments essentiels ; la recherche des derniers 20 % est volontairement différée afin de bénéficier du contexte de P5/P6.

Baselines principales conservées : Brush **40 / 0,70 / 1,25** ; Chisel **22 / 0,64 / 2,25**, 4,5 Hz ; Blower **60 / 0 / 1,0**, clear 2,5 ; Precision Pick **11 / 0,44 / 1,75**, 6 Hz, Bone safe. Chisel bulk, Pick finition structurelle, Brush préparation/nettoyage, Blower évacuation du mess.

La préparation Bone est canonique : **Exposure ≠ Cleanliness ≠ Condition**. Un Bone révélé porte un film adhérent nettoyable au Brush ; les vrais restes structurels restent au Pick ; la Condition et les protections par composant sont indépendantes.

Déférés sans bloquer P4 : Soil trop provisoire pour le final, débris encore perfectibles, ambiguïtés visuelles Pick/Brush sur certains micro-restes, Bone dirt parfois trop proche du Sandstone, dust vs lecture des arêtes. Pour P6, tester d'abord **la couleur seule** du Bone Film avant de modifier son pattern/densité, car les taches actuelles sont appréciées.

Si ces sujets restent importants après P5/P6, ouvrir une **phase future dédiée de polish excavation/gameplay, nom à définir**, et non `P4.2`. P5 devient la prochaine phase canonique.


## Macro game design — caisses et musée vivant — 2026-10-05

Antoine canonise deux piliers pour le jeu complet, à concevoir/prototyper **après la V0.1** sans les tirer dans P5.

**1. Specimen crates / intake queue.** Le prochain travail est choisi via des caisses physiques reçues par le musée. L'étiquette donne origine géologique/site, période estimée, matrice, difficulté, notes de provenance et éventuel caractère rare/exceptionnel sans révéler précisément le contenu. Une courte phase satisfaisante d'ouverture de caisse doit relier la sélection à la préparation. Les caisses spéciales peuvent créer un fort sentiment d'anticipation (« il faut que j'ouvre celle-là »), mais la rareté ne doit pas devenir une lootbox payante ni rendre la progression principale injuste.

**2. Musée comme mémoire physique du travail.** La galerie doit donner envie d'être complétée parce qu'elle matérialise réellement les préparations du joueur, dans l'esprit du plaisir de donation/complétion du musée d'Animal Crossing. Les pièces apparaissent dans les expositions, les manques restent visibles et la progression se lit dans le lieu avant de se lire dans des chiffres. Une galerie partiellement remplie au départ est une piste forte pour faire sentir que le musée existait avant le joueur et créer des objectifs déjà entamés.

Boucle macro cible : **crate queue → anticipation/opening → preparation → archive → visible museum update → next crate**.


## Directions à approfondir — caisses, silhouettes de blocs et refonte Soil — 2026-10-05

Antoine conserve trois **directions préférées à tester**, sans les considérer encore comme implémentations finales :

1. **Identité visuelle des caisses** : la forme exacte des caisses n'est pas prioritaire, mais leur traitement visuel peut signaler provenance, rareté ou caractère exceptionnel (marquages, scellés, étiquettes, renforts, usure, handling tags) et renforcer l'anticipation avant ouverture.
2. **Silhouette du bloc préparé** : tester des masses/jackets plus variés qu'un rectangle parfait (compact, allongé, cassé/asymétrique, etc.) tout en conservant d'abord une surface de préparation lisible. La variation doit enrichir l'identité du spécimen, pas ajouter de friction gratuite.
3. **Refonte Soil — hypothèse privilégiée** : remplacer à terme le Soil épais par une couche plutôt fine de terre/saleté meuble posée sur la matrice. Le Brush enlève le surplus pour révéler Clay/Sandstone ; une patine de contact sale reste visible sur la surface, puis l'excavation révèle la couleur fraîche de la matrice. Boucle cible : **surface dirt → contact patina → fresh structural matrix**. Si Soil devient mince, la verticalité doit être portée par la matrice et l'enfouissement, pas par une grosse épaisseur de terre.

Ces points appartiennent au futur macro/polish design et ne rouvrent pas P4/P5.


## Specimen Intake screen baseline — 2026-10-05

Antoine valide comme **base à tester** la variante A du futur écran d'arrivage : vue fixe/semi-fixe de la salle de réception du musée avec plusieurs caisses visibles et sélectionnables directement. Elle emprunte deux éléments aux variantes alternatives :

- focus visuel/cinématique subtil sur la caisse sélectionnée ;
- fiche scientifique / clipboard concise pour les informations de provenance, période, matrice probable, difficulté et notes du conservateur.

Aucun avatar contrôlable ni déplacement 3D pour aller toucher les caisses. La salle doit rester un hub de choix court, lisible et diégétique, puis mener à une phase d'ouverture de caisse et enfin à la préparation.

## P5 — Retour humain1 et correction autorisée, 2026-10-05

**Verdict confirmé : P5 non validé.** L'ambiguïté mission/qualité100 % empêche d'interpréter le premier Keep Cleaning comme une envie libre de poursuivre. Antoine autorise une correction ciblée : hiérarchie requise/optionnelle, marges UI, fragments naturellement voisins du spécimen, plateau physique, préparation fine95/95 et archive satisfaisante. **Préférence produit confirmée : l'archive doit être une conclusion courte, claire et émotionnellement positive du travail pour le musée, pas un rapport administratif/PDF.** Aucun P6 ni retuning P4.

Choix livrés, à retester humainement : demande de gauche seule autorité d'archive ; dossier explicitement optionnel ; étoiles persistantes95/95 avec éclat/notice uniques et aucun effet sur Condition/mission ; découverte d'un fragment à10 % d'exposition réelle. Les fragments sont près de la mâchoire et du bassin sans changer les totaux anatomiques. Le plateau est un objet3D fixe ; la cible est son fond intérieur, pas son rectangle écran. Home retrouve le bureau quand le zoom sort le plateau du cadre ; cette friction éventuelle doit être évaluée au retest.

L'archive conserve les valeurs finales, affiche identité/demande accomplie/fragments/Condition/qualité optionnelle et remercie brièvement le joueur, avec une confirmation douce. Les écarts détaillés restent F1. Un parcours sans étoile reste une réussite complète de la demande. Le protocole laisse **choisir librement** Archive ou Keep Cleaning ; aucune consigne de continuer avant de relever le choix.

Leçons vérifiées : les sous-lignes d'un objectif terminé doivent porter le même statut visuel que sa coche ; les contrôles de layout doivent inclure l'état Keep Cleaning où le bouton Archive apparaît, sinon celui-ci peut masquer le compteur du plateau. Attendre la fin du bref fondu pour la capture finale d'archive, sans l'exclure du benchmark. L'oracle entièrement révélé/nettoyé atteint100 % ; la cause des98–99 % de la session humaine reste non localisée faute de snapshot de ce terrain. Rapport et retest : [P5_CORRECTION_REPORT](../dev/P5_CORRECTION_REPORT.md).


## P5 simplification — remove fragment objective and reduce UI — 2026-10-05

Antoine rejects the growing P5 objective/dossier complexity. The core P5 goal is simplified to **Prepare the specimen = reveal >=90% of the skeleton + clean >=90% of revealed Bone**.

The two loose fragments, Forceps objective, physical tray, component stars and detailed component checklist are removed from the P5 player-facing validation flow. They were exploratory mechanics, not part of Antoine's original core vision, and may only return later if Macro Game Design gives them a clear role.

P5 UI should be minimal and functional: one preparation goal, two progress values/bars, established four-tool toolbar, clear completion state, Archive / Keep Cleaning. Classification may remain a subtle discovery signal but not a competing checklist. Condition is not another completion requirement.

P5's art is intentionally greybox. **P5 must be clear, not beautiful; P6 owns the real visual/UI language.**

P5 is complete when one preparation session can be understood, completed and archived from start to finish without explanation. Full skeleton extraction vs in-matrix vs mounted/hybrid museum destination remains a Macro Game Design decision.


## P5 compact HUD + 85/95 mastery ladder — 2026-10-05

Antoine keeps P5 minimal but restores one global optional mastery reward.

- Required completion = **global Exposure >=85% AND global Cleanliness >=85%**.
- Optional mastery = **global Exposure >=95% AND global Cleanliness >=95%** -> one persistent **★ Fine Preparation** reward with a brief subtle glint/sound.
- Exact 100% is never required.
- No per-component stars/checklists in the player-facing P5 UI.
- Primary HUD = one compact top-left / left-margin card with specimen name + Reveal + Clean + state. No permanent right-side dossier.
- Four-tool toolbar remains bottom.
- Classification is transient/non-blocking; Condition and detailed component data stay out of the primary HUD.

Rationale: preserve a clear 0→85 required phase, a meaningful 85→95 optional mastery phase, and 95→100 personal completion, while keeping the fossil/work surface visually dominant.


## P5 — Livraison du parcours simplifié85/95, 2026-10-05

La direction humaine85/95 est implémentée sur PR #8 (`19b8ec4`) : une seule carte de préparation, quatre outils, aucun fragment/Forceps/plateau dans le jeu normal. À85/85, completion persistante et archive permise ; la fouille n'est pas interrompue. À95/95, une seule étoile globale persistante et une confirmation discrète ; Condition indépendante, aucun bonus100%. Archive ne montre que la clôture positive, l'étoile si acquise et le bouton suivant. Les détails demeurent F1.

Choix technique vérifié : ne pas supprimer les modules de l'expérience fragments, mais ne les initialiser que dans un test explicite ; aucune touche normale ne les active. Les anciens tests de seuils/composants/mission sont remplacés par ceux du parcours actif, tandis que plafonds/READY/retour/dépôt restent couverts séparément. Les snapshots de fin/archivage et le reset sont conservés. Un Keep Cleaning sans clic est possible : lire aussi les actions supplémentaires, pas seulement le booléen de choix.

Leçon vérifiée : un panneau dimensionné par texte avec retour à la ligne doit pouvoir rétrécir après calcul de sa taille minimale ; sinon il laisse une grande zone vide malgré un contenu compact. La capture et le contrôle de rectangle ont détecté et corrigé ce défaut.

[Rapport et preuves](../dev/P5_SIMPLIFICATION_REPORT.md) :2 017 contrôles fonctionnels,59 graphiques,22 scénarios/90 contrôles perf, oracle GPU194 955 pixels ; zéro échec. **Cela ne valide pas P5 humainement.** Attendre les six réponses du retest libre ; aucun merge ni P6.

## Crate opening — tactile modular grammar — 2026-10-05

Antoine valide la direction d'une **ouverture tactile directe** et variée des caisses. Le joueur agit avec la souris sur les éléments physiques plutôt que d'appuyer sur un bouton abstrait : tirer une sangle pour la retirer, ouvrir des loquets, insérer un pied-de-biche dans la jointure puis tirer la souris vers le bas pour faire levier, soulever le couvercle, retirer éventuellement une protection intérieure.

La variation est modulaire : toutes les caisses ne possèdent pas les mêmes attaches. Certaines ont sangles + loquets, d'autres nécessitent le pied-de-biche, d'autres sont plus simples. Ne pas empiler tous les gestes à chaque fois : viser généralement **2–3 interactions courtes**, avec des affordances visuelles évidentes et sans fail-state punitif.

La caisse révèle toujours un **bloc/jacket fermé et non préparé**. L'ouverture de caisse répond à « quel chantier ai-je reçu ? » ; le reveal des os reste réservé au cœur de gameplay de préparation.


## Macro design question — specimen destination after preparation — 2026-10-05

Antoine confirme que la transition **préparation → musée** doit être traitée sérieusement pendant le futur Macro Game Design. Les modèles à comparer sont : spécimen conservé **in matrix**, os/éléments extractibles, contribution progressive à un squelette monté, ou approche hybride selon le type de fossile.

Une courte étape de **conservation / finition / mounting** reste une piste forte pour relier le travail du laboratoire à l'exposition (consolidant, dernier nettoyage, support, étiquette), mais elle ne doit pas devenir une seconde phase de 10–15 minutes après chaque préparation. Cible : geste final court, satisfaisant et cérémoniel.

L'ancienne expérience des deux fragments extractibles dans P5, désormais dormante, reste un test de mécanique Forceps, pas une décision sur le modèle final d'extraction des pièces principales.


## P5 final simplified target — 85/95, coverage guard, qualitative Condition — 2026-10-05

Antoine validates the next P5 design baseline:

- Required preparation = **Exposure >=85% + Cleanliness >=85% + coverage guard**.
- Coverage guard is invisible unless it blocks completion; it prevents archive while an obvious major contiguous anatomical region remains substantially buried.
- Optional mastery = **Exposure >=95% + Cleanliness >=95% => one global ★ Fine Preparation**.
- Exact100% is personal only.
- Condition is shown as a qualitative care state, independent from completion:
  - 95–100 Excellent
  - 85–94 Good
  - 70–84 Fair
  - <70 Damaged
- Condition does not gate archive in P5 and does not invalidate Fine Preparation.
- Primary HUD remains one compact card with museum standard, Reveal, Clean and qualitative Condition; no permanent right dossier.
- Fragments/Forceps/tray and per-component stars remain outside the P5 player flow.

Design intent: answer four questions with minimal UI — What do I do? Can I stop? Why might I continue? Why should I be careful?

## Livraison couverture et soin — 2026-10-05

La cible humaine est implémentée :85/85 global plus garde anatomique, Condition qualitative indépendante, étoile globale95/95 inchangée. Choix prototype **65 % minimum sur chacun des quatre composants**, centralisé dans PreparationRules ; les captures comparées50/60/65/70 montrent que50 laisse tout le bas de patte couvert. Ce choix demande encore validation humaine : quatre compteurs ne constituent pas une analyse de chaque sous-os ou amas contigu.

La garde est invalidée uniquement par exposition, puis évaluée dans le regroupement existant ; film et dégâts seuls ne la recalculent pas. Une baisse de Condition notifie une seule fois le palier atteint, sans rafale si plusieurs seuils sont franchis. Une découverte simultanée ne remplace pas immédiatement cette notice. Reset réarme les notifications ; nettoyer ne restaure pas Condition et n'annule pas Fine Preparation.

[Rapport courant](../dev/P5_COVERAGE_CARE_REPORT.md) :2 055 contrôles fonctionnels,77 graphiques,104 contrôles perf/26 scénarios, zéro échec. Les vérifications techniques ne valent pas validation produit. Retest libre en neuf questions, PR #8 DRAFT ; aucun merge/P6.

## P5 coverage guard — hidden connected mass — 2026-10-05

Antoine approves replacing the coarse **65% minimum per anatomical component** readiness guard with a more perceptual hidden-mass test.

Archive readiness remains:
- Exposure global >=85%
- Cleanliness global >=85%
- no major contiguous hidden Bone cluster above the centralized prototype threshold

Initial target to test: largest remaining connected hidden Bone cluster around **2–3% of total main skeleton cells**. Exact threshold must be calibrated on B-17 fixtures and documented.

Reason: a component can satisfy65% exposure while still leaving a visually obvious lower-limb section buried. The new guard should answer the perceptual question: **does a major piece of the skeleton still visibly remain undiscovered?**

No new HUD metric; only a contextual "Major section still covered" message when blocked. P4 gameplay and P5 UI remain otherwise unchanged.


## Garde exacte des amas cachés — implémentation Human test5 — 2026-10-05

La règle prototype retenue est `plus grand amas caché < ceil(total Bone principal ×0,02)`, soit strictement moins de646 cellules pour B-17. Connexité8 immédiate, aucun pont ni dilatation. La topologie réelle sépare naturellement le pied (1 328 cellules) du bas de jambe (1 983), tous deux détectables sans relier les os.2 % a été préféré à3 % : la limite3 % laisserait encore près de73 % du pied caché. Ce choix technique reste à valider humainement.

La liste des cellules cachées suit les signaux de première exposition ; le parcours en largeur est regroupé par action, différé jusqu’à85 % et mis en cache. Aucun recalcul pour film, Condition ou caméra. Les régions séparées ne sont jamais additionnées : plusieurs petits restes ne forment pas artificiellement une grande pièce manquante. La méthode ne garantit pas une silhouette complète si plusieurs petits os séparés restent enfouis ; aucune extension de gameplay pour masquer cette limite.

[Rapport courant](../dev/P5_HIDDEN_CLUSTER_REPORT.md).85/85 global,95/95 facultatif et Condition qualitative restent inchangés. Aucun merge ni P6 avant verdict humain.


## P5 human closure — advance to P6 — 2026-10-05

Antoine explicitly closes P5 as **sufficiently validated to advance**.

What P5 proved:
- one fossil-preparation session can be understood and completed end-to-end;
- the compact HUD communicates the core job clearly enough;
- museum standard at85/85 gives a clear stopping point;
- optional95/95 Fine Preparation provides a lightweight reason to continue;
- qualitative Condition gives the player a reason to work carefully without becoming another completion bar;
- Archive / Keep Cleaning establishes a complete session ending.

Known limitations are accepted and deferred rather than blocking P6:
- Cleanliness is measured over currently exposed Bone, so revealing new dirty Bone can lower the displayed cleanliness percentage; this is logical but may need better communication/presentation later.
- The hidden-cluster coverage guard is still not a perfect proxy for human visual completeness; some visibly missing anatomy can still remain while archive is allowed. Do not spend more P5 time tailoring B-17-specific completion logic.
- Final in-matrix vs extraction vs mounted-skeleton/hybrid destination remains a Macro Game Design question.
- P5 UI is intentionally greybox; visual quality is now P6's responsibility.

Fragments/Forceps remain dormant historical experiments, not part of the active P5 player loop.

Decision: stop P5 iteration here, merge PR #8, then open **P6A — Visual Direction / Production Spike**.


## Documentation authority and P6A Soil sequencing — 2026-10-06

Two durable project-management decisions:

### Documentation authority
- `docs/brain/status.md` is the **single source of truth for live phase, gate, active branch/PR and next authorized action**.
- `AGENTS.md` stays short: routing + durable invariants only.
- README / GAMEPLAY_LOOP / ROADMAP / HANDOFF must not duplicate live authorization language.
- Historical dev reports do not authorize work.
- Superseded P4-V2 intermediate reports are archived under `docs/dev/archive/p4v2/` with compatibility stubs at their old paths.
- Documentation roles are defined in `docs/DOCUMENTATION_POLICY.md`.

### P6A ordering
P6A2 Hero Lookdev is prepared but **must not execute before the Soil Foundation Spike**.

Reason:
the current thick structural Soil is explicitly provisional, while the preferred art/gameplay direction is thin loose overburden over Clay/Sandstone with a dirty contact patina. Building production lookdev around the thick Soil first would create avoidable rework.

Sequence:
> P6A-1 Material Lab ✅ → P6A1.5 Soil Foundation Spike → P6A2 Hero Lookdev → human visual gate → P6B

The Soil spike decides only the basic Soil role/grammar needed for art. It is not final Soil polish.

## Contact patina — correction de cible, 2026-10-06

Antoine précise que la patine doit être **le matériau d’origine + des dépôts irréguliers**, et non une nouvelle couleur uniformément plus sombre. Clay reste clairement orange ; les taches ont une couverture cassée, des bords imparfaits et une opacité variable. Même principe, plus subtil, pour Sandstone. L’analogie visuelle avec Bone Film n’autorise aucun couplage de gameplay.

Pour le Soil Foundation Spike, le choix technique est d’isoler les nouvelles conditions initiales et cette patine dans une scène de comparaison, en conservant le noyau d’excavation P4/P5. Le profil à 0–2 mm reste une **hypothèse testée**, pas une décision de gameplay validée. Détails et limites dans [P6A15_SOIL_REPORT](../dev/P6A15_SOIL_REPORT.md).


## P6A1.5 human verdict — thin Soil baseline accepted — 2026-10-06

Antoine human-tested the Soil Foundation candidate and prefers the **thin irregular overburden** direction to the former thick structural Soil.

Durable direction:
- Soil is a **thin, partial, loose surface covering**, not a multi-centimeter structural layer.
- It follows the underlying matrix relief instead of creating an independent flat ceiling.
- Brush removes this superficial dirt quickly; Clay/Sandstone becomes the real structural excavation.
- Exact thickness/coverage values from the spike remain tuning values, not final production constants.

The corrected contact patina is also preferred:
- keep the original Clay/Sandstone identity;
- add irregular dirty deposits/stains with broken coverage;
- never replace the material with one uniformly darker band.
The spike visuals are still placeholder/ugly; this decision concerns semantics and readability, not final art quality.

P6A2 remains delayed because the Soil test exposed a new structural issue: once the thin Soil is removed, the underlying Clay/Sandstone top is still too planar.

## P6A1.6 — natural matrix geometry direction — 2026-10-06

Antoine explicitly authorizes a focused geometry spike before Hero Lookdev.

Problem:
> thin Soil now follows the matrix correctly, but the matrix itself still reads as a broad horizontal plane.

Target:
- give the **underlying Clay/Sandstone surface** natural deterministic macro relief before excavation begins;
- use broad undulations, shallow bowls/cavities, ridges, local shelves/steps and imperfect transitions rather than a flat slab;
- make the initial block feel like a believable fossil-bearing matrix, not a rectangle filled with horizontal layers;
- Soil must conform to this richer substrate;
- preserve gameplay readability, Bone ceilings, picking, tool grammar, effort-aware work budgets and deterministic QA.

This spike is about **internal matrix topography**, not the future outer block/jacket silhouette system. Prepared-block silhouette variation remains a separate later direction.

Sequence becomes:
> P6A-1 Material Lab ✅ → P6A1.5 Soil Foundation ✅ human direction chosen → **P6A1.6 Natural Geometry Spike** → P6A2 Hero Lookdev → human visual gate → P6B.

## P6A1.6 — séparation géologie / validation Bone (2026-10-06)

Choix technique du spike, sans validation du candidat visuel : les macroformes sont des fonctions UV déterministes centralisées, calculées une fois, indépendantes du fossile. Bone sert à vérifier les plafonds et les budgets de travail après construction, jamais à sculpter/clamp le relief initial. Les fixtures pré-creusées sont séparées de cette génération et les outils restent natifs. Voir [rapport et limites](../dev/P6A16_NATURAL_GEOMETRY_REPORT.md).

Leçon de mesure vérifiée : l’encodage de hauteur GPU par couleurs proches du noir peut produire une fausse divergence sous Compatibility. Encoder dans les tons moyens et comparer aussi à un oracle de triangles natifs avant de conclure à un défaut du picking.

## P6A1.6 — retour humain : structure minérale, pas ondulations (2026-10-06)

Antoine ne valide pas le premier B : les plis doux restent trop proches d’un plan continu sous la caméra actuelle. Direction confirmée pour la correction : masses/plaques irrégulières imbriquées, plateaux, marches adoucies et poches ouvertes, portés par le vrai heightfield. Ne pas compenser par du bruit, de la texture ou de la lumière ; préserver l’indépendance du fossile. Le [B corrigé](../dev/P6A16_STRUCTURED_MATRIX_REPORT.md) applique cette direction mais attend son propre verdict humain.


## P6A1.6 — retour humain : affleurements, pas puzzle (2026-10-06)

Le B polygonal améliore la lecture des niveaux mais n’est pas approuvé comme fondation : Antoine voit une surface découpée en plaques. Direction confirmée : substrat continu relativement calme, quelques masses minérales émergentes de tailles différentes, épaulements imbriqués et poches ouvertes. Préférer des contours courbes irréguliers, des fronts localisés qui se fondent ailleurs dans la surface, et une variation méso légère sur les dessus. Éviter les anneaux abrupts complets, les tranchées de largeur constante et la mosaïque de poids visuel uniforme. Le vrai heightfield doit porter cette lecture sans patine ; outils et Bone restent verrouillés. La [correction par affleurements](../dev/P6A16_OUTCROPS_REPORT.md) est une proposition technique, pas une validation de cette géométrie.


## P6A1.6 — test de grammaire de surface macro + méso (2026-10-06)

Antoine recadre la dernière correction : le matériau doit pouvoir évoquer de petites unités minérales excavables **avant** les coups Chisel, par la vraie géométrie. Il autorise un test associant des masses réellement positives par rapport à A, des poches et une structure méso de petits replats/ressauts/creux irréguliers. Les macroformes seules ne suffisent pas ; éviter membrane, puzzle fermé, grille Minecraft et bruit uniforme. Cette autorisation de test **ne valide pas** une grammaire voxel finale. Conserver A, Soil, lumière, caméra, outils, Bone, picking et discipline de budgets ; adapter la distribution géométrique si nécessaire, jamais les outils. [Implémentation et preuves du test](../dev/P6A16_SURFACE_GRAMMAR_REPORT.md).


## P6A1 — clôture suffisante pour avancer (2026-10-07)

Antoine a revu le dernier test de grammaire de surface et clôt P6A1 comme **suffisamment validé pour avancer vers P6A2**. Le B macro + méso actuel est la fondation de travail Hero Lookdev pour maintenant ; cette décision n'approuve pas une géométrie finale parfaite. Conserver les preuves historiques et leurs verdicts contemporains.

**Clay surface breakup grammar** est différé : une amélioration ciblée ultérieure pourra rapprocher la surface Clay intacte du langage minéral de petites cassures visible après excavation. Ce n'est pas un blocage P6A2. Soil mince P6A1.5 et patine par dépôts restent acceptés ; P4/P5 restent gelés.

## Production P6A2 — chaîne minimale et autorité (2026-10-07)

Stack retenue : Godot 4.7.2 pour gameplay/rendu/assemblage ; Blender 5.2.2 LTS pour géométrie statique, UV et export GLB ; références canoniques versionnées ; images ChatGPT sélectionnées par Antoine/orchestrateur puis consommées dans le dépôt. Aucun besoin de reproduire ImageGen localement. Meshy/Tripo non requis, Krita/Photoshop seulement sur besoin concret de nettoyage, audio ultérieur.

La chaîne GLB est vérifiée par une sonde non-production : un mètre par unité, Blender Z-up/+Y avant → Godot Y-up/−Z avant, rotation/échelle appliquées, sources DCC exclues de l'import runtime et sorties GLB explicites versionnées. Blender reste hors Git. Voir [rapport de preflight](../dev/P6A2_PREFLIGHT_REPORT.md) pour conventions et preuves.

Le cœur dynamique Godot garde l'autorité exclusive : heightfield/couches, plafonds Bone, outils, picking, film, fracture et progression. Les assets Blender sont des supports statiques sans autorité de fouille. Les expériences visuelles doivent rester dans une petite scène Hero Patch isolée partageant les systèmes existants avant toute promotion en production. La réussite technique du preflight n'est ni une validation artistique ni un GO implicite de développement.

## P6A2 — GO pour un Hero Patch limité (2026-10-07)

Après preflight READY, Antoine autorise explicitement un seul Hero Patch réel et jouable héritant du lab P6A1.6 B : matières, première coque plâtrée statique Blender, lumière et établi limité. Les visuels restent locaux à cette scène avant revue ; la comparaison au témoin conserve fouille et caméra. Le GO n’autorise ni la grammaire Clay différée, ni du tuning gameplay, ni une généralisation artistique. Une livraison testée doit revenir au verdict visuel humain ; aucune acceptation de direction ou transition P6B n’est implicite. [Rapport de la proposition](../dev/P6A2_HERO_LOOKDEV_REPORT.md).

## P6A2 — rejet artistique et correction ciblée (2026-10-07)

Antoine valide la chaîne technique, l’isolation et la performance du Hero `a9d47b6`, mais rejette son look. Le jacket doit se lire comme le contenant physique irrégulier d’un unique bloc de préparation, pas un cadre clair indépendant. L’atlas Material Lab, déjà jugé pauvre, est exclu de la fondation visuelle P6A2 : demander de nouvelles sources ImageGen précises à Antoine/orchestrateur avant finalisation matière. La lumière doit venir d’une véritable lampe locale (Spot/Omni), pas seulement d’un directionnel réchauffé. Ces trois priorités précèdent tout accessoire/polish secondaire. Architecture, géométrie B et gameplay restent conservés ; aucune validation de direction artistique n’est implicite.

## P6A2 — verdict après test réel : Soil puis présentation playtest (2026-10-07)

Antoine accepte Clay pour maintenant, veut conserver la lampe locale comme amélioration majeure et juge Sandstone acceptable malgré une valeur encore un peu sombre. Ces éléments ne doivent pas devenir les sujets d’une nouvelle refonte pendant la correction Soil.

Soil reste dans le jeu pour sa variété de lecture et de gameplay. Sa lecture de grandes taches sombres/camouflage est rejetée : viser une couche de terre superficielle, meuble, granulaire, naturelle et compatible avec Clay. C’est la première priorité, devant l’intégration jacket/bloc. Une forme intérieure excavable moins rectangulaire reste une piste future, pas une décision d’architecture acquise.

La préparation d’un playtest entre amis doit ensuite améliorer le confort grand écran/plein écran, la présentation des objectifs et de fin de session, et ajouter une lampe visible avec quelques accessoires discrets. La simulation reste à 60 Hz ; le confort de rendu n’autorise pas à changer le gameplay. Ce retour demande une proposition de mission, sans validation implicite de toute la direction Hero ni lancement de P6B.

## P6A2 — GO Soil et présentation playtest, critères humains précisés (2026-10-07)

Antoine autorise l’implémentation du brief Soil & Playtest Presentation. Le Soil doit changer de **morphologie**, pas seulement devenir moins sombre : dépôts fragmentés, amas de tailles variées, bords cassés, grain v02 et Clay clairement visible entre eux. Examiner les tailles/distributions des amas continus en plus de la couverture. Le critère reste le plaisir d’enlever une vraie couche de terre meuble. Soil mince, retrait rapide au Brush, Clay v02 et patine séparée restent conservés.

L’UI reçoit un véritable restyle papier/musée crème et chaud, avec Reveal / Clean / Condition lisibles, appliqué aussi à Archive / Keep Cleaning et au bilan. Informations et règles P5 inchangées. Plein écran, lampe visible, deux ou trois accessoires maximum et export Windows portable sont dans ce GO ; jacket/emprise intérieure restent exclus. La livraison doit s’arrêter pour revue humaine, sans P6B ni merge implicites.


## P6A2 Playtest — Soil enfin positif, nouveaux axes de polish (2026-10-07)

Après test réel de `P6A2 Soil & Playtest Presentation`, Antoine juge que c’est la **première version où Soil ne rend pas le jeu plus laid mais ajoute au contraire un petit charme**. La direction fragmentée/terre meuble est donc acceptée comme baseline actuelle, sans être considérée parfaite ou finale.

Éléments conservés pour maintenant :
- Clay v02 : bonne direction actuelle ;
- task light locale : amélioration majeure confirmée ;
- Sandstone : acceptable mais assez sombre, non prioritaire.

Nouveaux besoins de qualité perçue à garder pour les passes suivantes :
- les modèles visuels des outils actuels sont trop pauvres et doivent être remplacés par des modèles cohérents avec l’univers Archeo ;
- l’audio est un levier de satisfaction majeur : viser des **Foley satisfaisants, tactiles, crédibles et propres**. Le terme « ASMR » utilisé initialement décrivait le niveau de satisfaction recherché, pas une esthétique sonore littérale ;
- ajouter des réponses matérielles non destructives lorsque pertinent : par exemple Brush sur Clay peut produire un petit puff/poussière colorée cohérente même si l’outil n’excave pas la Clay. Le but est la **réactivité matière / game feel / juice**, sans modifier la règle d’outil ;
- le rythme global paraît encore un peu lent. Priorité à P7 fine tuning avant toute extension de l’arsenal. Si le tuning ne suffit pas, explorer plus tard un outil plus efficace que le Chisel avec vraies contreparties (risque, précision, contrôle, etc.), ce qui repositionnerait le Chisel comme outil intermédiaire.

Aucun de ces points n’autorise une modification automatique de gameplay pendant P6A.


## P6A3 pre-production — Tripo primary pipeline and audio target (2026-10-08)

After a bounded Meshy vs Tripo bake-off on a preparation lamp and Chisel, Antoine concludes that both generators can reach comparable visual quality when used well. The deciding factor for Archeo is **agent workflow compatibility**, not a claimed universal quality winner.

Decision:
- **Tripo is the primary 3D generation pipeline for Astra/Codex** because the official Tripo 3D Codex plugin is already authenticated, agent-friendly and lowest-friction for project-integrated generation.
- Meshy remains a fallback / second opinion for difficult assets, not the default production path.
- Preferred tool-asset pipeline: **approved ImageGen reference → Tripo image-to-3D → source/high asset retained → Smart Mesh / retopo as appropriate → Blender 5.2.2 cleanup and bake → Godot 4.7.2**.
- Raw multi-million-face generations are source masters, never runtime assets. Runtime topology is chosen by visual need after cleanup and in-engine comparison.

Antoine approved the P6A3 tool family art direction and the four individual ImageGen references now versioned under `art/source/p6a3/tool-concepts/`.

Audio correction:
- Do **not** target literal “ASMR sound”.
- Target **realistic, satisfying tactile Foley**: credible material response, clean short transients, restrained proximity/detail and pleasant repetition.
- ElevenLabs remains useful as a source generator, but generated sounds are test material rather than automatically final production SFX.
- Current in-game candidates to test first: Brush→Soil, Chisel→Clay and the corrected stone-dominant Chisel→Sandstone. Final judgement happens synchronized with tool animation/VFX in game.

## P6A3 — GO Tool Feel & Sensory, autorité inchangée (2026-10-08)

Antoine autorise les quatre modèles depuis leurs références ImageGen approuvées,
via Tripo puis nettoyage/optimisation Blender, ainsi qu'un remplacement visuel
statique de la lampe. La task light P6A2 reste la référence ; seul l'alignement
physique du modèle peut être adapté. Les masters générés sont des sources, jamais
des meshes runtime bruts.

Les motions, les réactions matière et le Foley doivent répondre immédiatement aux
inputs sans retuning de la fouille. Un Brush sur Clay peut recevoir une réponse
cosmétique sans devenir excavateur de Clay. Soil, Bone/plafonds/Condition, outils,
P5, géométrie B, jacket/emprise et cadence 60 Hz/240 FPS restent conservés. Le
rythme global est réservé au tuning P7. La réussite technique ne valide pas le
ressenti ; la livraison P6A3 complète doit revenir au HUMAN GAME-FEEL VERDICT.

## P6A3 — voie Studio autorisée et contrôle des faces cachées (2026-10-08)

Antoine autorise la reprise complète P6A3 via Playwright et les crédits Studio,
puis livraison/revue humaine. Le solde Studio et le solde API sont distincts :
un connecteur API authentifié n'implique pas l'accès aux crédits de l'abonnement
Studio. Le pipeline artistique reste image approuvée → Tripo → retopo → Blender
→ Godot ; Meshy demeure un fallback, sans bake-off supplémentaire.

Une génération vue de face ne valide pas un outil : Antoine a identifié une
seconde lame du Chisel depuis un autre angle. Examiner face, dos, profil et
vue de jeu avant intégration ; conserver les sources et la correction Blender
reproductible. Un master généré ne devient jamais directement le runtime.

## P6A3 — priorité playtest, retour humain correctif (2026-10-08)

Antoine demande une présentation des outils fixe à l'écran, sans déplacement
libre dans la matière, avec de courtes animations sur input. Les Foley P6A3 sont
rejetés pour le playtest immédiat : restaurer l'audio précédent, sans retuning
ni génération. Conserver les assets/VFX utiles et les règles P4/P5 ; pas de
nouvelle direction, de bake-off, de travail matériaux/jacket ou de P6B/P7.

Clarification humaine : « fixe » signifie angle constant en suivant la souris,
pas ancrage dans un coin d'écran. Supprime l'interprétation précédente.
La capture fournie autorise explicitement le réglage Chisel 26 / 0.84 / 2.25
dans le playtest P6A3 ; aucun autre tuning n'est demandé.

Précision suivante : reprendre la pose de présentation P6A2 elle-même en gardant
les nouveaux modèles ; ne pas substituer un nouvel angle caméra ou une taille
écran constante. Les petites animations input restent souhaitées.


## P6A3 — friend playtest: mastery hook and next sequence (2026-10-08)

Informal friend playtest, sample **n=3**. All three engaged through archive-or-beyond.
One player reached **99% and kept pushing specifically because they wanted 100%**;
the other two archived before max completion. This is directional qualitative
evidence that Archeo's preparation loop now carries the intended "one more bit"
pull and that optional mastery can motivate behavior. Do not overgeneralize from
the small sample.

Durable follow-up direction:
- displayed **100% must be attainable**. For the next focused pass, allow a
  relevant internal value of >=99% to resolve to 100% when existing completion
  guards are satisfied, rather than strand a visually complete specimen at 99%;
- preserve completion/hidden-cluster guards so display rounding never hides a
  genuinely missing region;
- **Perfect Preparation** is a preferred future mastery label for displayed
  full preparation plus excellent care; exact achievement/meta wiring remains
  deferred;
- Chisel feedback: reduce only the **visual crosshair circle**, not its actual
  excavation radius;
- Bone Condition: retain Excellent / Good / Fair / Damaged but make state more
  explicit with a readable gauge/presentation; progressively reflect real damage
  on the Bone material/geometry visually without creating a second gameplay state;
- Bone cleanliness readability: at 94% Cleanliness the Bone can already read
  fully clean, so dirty-vs-clean Film contrast must remain actionable near 100%;
- Brush cleaning Bone Film should emit a small, localized dust/removal response
  tied to real Film removal.

Sequencing agreed:
1. P6A3.1 — playtest feedback / mastery readability quick pass;
2. dedicated Sound Design & Music phase;
3. dedicated Interactive Task Light spike;
4. another playtest.

Audio direction is **satisfying tactile Foley**, not literal ASMR. The sound
phase must be treated as a real quality pillar and include restrained preparation
music. The task-light spike should test player-controlled light direction as a
possible relief-reading mechanic because fixed one-sided lighting can hide some
cavities. Neither phase is auto-authorized by documentation alone.


## 2026-10-09 — Fossil mesh visual priority / Material Column evaluation

Antoine demande que l'amélioration du **squelette/fossile B-17 en véritable mesh
3D** fasse partie des changements à traiter rapidement. Intention acceptée comme
nouvelle **priorité artistique à prototyper**, pas comme autorisation d'écraser
les systèmes Bone actuels. La source actuelle est un champ anatomique partiel
2.5D défini dans `fossil_field.gd`, avec ceilings, exposure, Condition et Film.
Un asset 3D extérieur posé par-dessus ne serait pas suffisant : il doit rester
strictement synchronisé avec les zones Bone révélées, la géométrie excavée et la
caméra/picking. Un prototype visuel limité, avec gate humain avant généralisation,
est proposé dans `docs/dev/P6A3_FOSSIL_MESH_DIRECTION.md`. Il se placerait
préférentiellement après P6A3.1 et avant les phases Sound/Light si GO.

Un brief externe « Material Column » propose 5–6 slots géologiques verticaux
par case avec identités de matériau variables. Après audit du code : faisable,
mais **réarchitecture majeure** du noyau travail/fracture, lookup GPU, tool
effectiveness, débris, rendering et validation. Préserver la hauteur unique par
case est la bonne intuition ; néanmoins ni le nombre N ni l'architecture exacte
ne sont choisis. **Aucun GO d'implémentation.** Explorer d'abord une variabilité
contrôlée sur des blocs authored avec les trois rôles actuels, puis envisager la
généralisation au début de la phase post-core Block Variability Prototype,
après P7. Voir `docs/dev/MATERIAL_COLUMN_FEASIBILITY_REVIEW.md`.


## Marketing M1 — self-publishing baseline and public hook readiness (2026-10-09)

Antoine prefers **self-publishing as the current operating assumption**, using
AI-assisted art/development and the production tools already proven. A publisher
is an option to compare later when a more representative vertical slice,
production budget and public demand evidence exist; PR agency is not a current
purchase commitment.

New milestone **Marketing M1 — First Public Hook Ready** is defined independently
from P0–P7: a 15–30s genuine-gameplay clip should be attractive, understandable
and satisfying to new viewers without explanatory narration.

This is NOT equivalent to public-demo or Steam-launch readiness and carries
no authorization to publish or begin marketing spend. First friend playtest
(n=3) showed a promising mastery hook, but is not market validation. A small
cold-viewer check and explicit human acceptance are needed for M1.

Ref: `docs/marketing/M1_FIRST_PUBLIC_HOOK_READY.md`.


## 2026-10-13 — Merge P6A3, GO P6A3.1, browser playtest and Claude sound

Antoine explicitly requests merging the latest P6A branch into main and starting
P6A3.1. PR #9 is merged with its exact head `b91ff24`; merge commit `32a85ba9`.
This is phase advancement authorization, not final artistic approval of every
P6A3 detail. P6A3.1 stays an isolated candidate for human review.

A private browser link is the requested work-PC playtest route, with no local
game installation. The actual Godot 4.7.2 Web export must be used; native
performance and audio feel still require representative hardware/human review.

Claude replaces ElevenLabs as Antoine’s selected source-production solution for
the dedicated sound phase after his own positive tests. No Claude tool is
invoked or message sent by this delivery. Existing native audio remains intact
during P6A3.1; generated sounds are not automatically production-approved.


## 2026-10-13 — Work-laptop Web playtest unsuitable

Antoine tried the private Web build, then exited because it lagged too much
on his small work laptop. The exact hardware/performance cause is not measured.
This is an unsuitable playtest setup, not a P6A3.1 feel verdict. Use native
testing on the home reference PC for the human gate; screenshots/video can
support visual discussion while away. No automatic Web optimization phase.


## 2026-10-13 — GO B-17 mesh before combined home test

Antoine wants larger progress before returning home, with refinement afterward.
He explicitly identifies skeleton visual improvement as next and offers his
Tripo Max Studio session for ImageGen → Tripo → Blender → Godot. Proceed with
a bounded real mesh pilot on top of P6A3.1 without waiting for its separate
feel verdict. Preserve native exposure/Film/Condition and progressive occlusion;
combine human review in the evening. No merge or Sound/Light GO is inferred.

## 2026-10-13 — Manual Tripo Studio handoff after shared-browser failure

Antoine chose to generate the B-17 reference in his own Tripo Studio and return
its textured GLB. Firecrawl browser credit exhaustion is the access blocker,
not evidence about his Tripo Max credits. No Tripo generation was performed by
the agent. Continue independent Bone-field binding preparation; inspect and
fit the returned asset before graphical/gameplay acceptance or playtest export.
The offline native-field mesh is a technical probe and must not be presented
as the requested Tripo skeleton or as validated production artwork.

## 2026-10-13 — Préparation tactile après le test natif

Antoine préfère le style du squelette précédent pour sa cohérence avec le thème.
L’essai de comparaison Tripo est non concluant : F6/F7 étaient interceptés par
le tuning debug et modifiaient le vrai rayon. Le style précédent redevient la
présentation initiale du candidat ; le crâne Tripo reste conservé pour comparaison.
Le dessin paramétrique de futurs os est une piste viable à évaluer, pas un GO
pour produire de nouveaux spécimens ou remplacer l’architecture Bone.

Direction autorisée pour la correction P6A3.3 :

- Brush : quelques petits allers-retours, retrait rapide et clairement visible ;
  aucun besoin de frottement prolongé sans raison perceptible ;
- dégâts : marques locales liées aux impacts réellement dommageables et orientées
  de façon variée ; Condition globale reste l’unique autorité de dégâts ;
- 100/100 : distinction de collection suffisante pour maintenant, indépendante de
  l’état de conservation, sans mode séparé ni récompense économique ;
- binds : comparaisons réservées sans interception par le tuning debug.

Le registre local de distinctions à l’archivage est le support minimal en
attendant la collection ; il n’ouvre pas le chantier musée/meta. Rapport :
`docs/dev/P6A33_TACTILE_PREPARATION_REPORT.md`. Le candidat reste soumis au retest humain.


## 2026-10-13 — Validation humaine ciblée P6A3.3

Antoine juge « parfaits » le Brush sur la saleté de l’os et les dégâts localisés.
Conserver ces interactions et leurs réglages. Cette validation est ciblée :
elle ne vaut ni validation du crâne Tripo hybride, ni confirmation de la
persistance de la distinction, ni autorisation de merge/phase suivante.

Le comparatif Tripo contient volontairement du Bone historique dans les zones
non remplacées. Une préférence artistique issue de ce test ne doit pas être
présentée comme la comparaison de deux crânes intégralement autonomes. Le style
précédent reste la référence jouable choisie ; tout nouvel asset/protocole reste
à convenir. Voir l’addendum humain du rapport P6A3.3.


## 2026-10-14 — GO essai de production 3D borné

Antoine choisit l’essai proposé : un crâne et quelques côtes stylisés, un
remplacement complet des pièces testées et une inspection du même asset hors
matrice pour évaluer son potentiel de collection. Le GO couvre la projection
mesh → champ Bone dans cette scène isolée ; aucune migration générale du noyau
ou production du catalogue n’est autorisée implicitement.

La fabrication locale paramétrique Blender produit de vrais meshes fermés,
distincts du relief raster précédent. Les formes réutilisent la direction
ivoire chaude et la matière acceptée, sans nouvelle génération Tripo. L’asset
source garde sept pièces, regroupées en une surface pour le rendu de fouille.
Les sources et le pipeline sont conservés dans le rapport P6A3.4.

La faisabilité technique vérifiée ne vaut pas validation artistique. L’anatomie
aplatie reste simplifiée et la projection à hauteur unique limite les usages
possibles. Verdict humain à recueillir avant de choisir le pipeline de production.
Le Brush sur os et les dégâts localisés validés restent inchangés.


## 2026-10-14 — GO passe esthétique P6A3.5

Antoine autorise une passe esthétique sur le crâne et les côtes du pilote :
conserver le style ivoire chaud et retrouver ombres/relief, sans révéler les
os enterrés. Préserver les interactions Brush et dégâts localisés validées.
Le retour positif sur la proximité du style ne canonise pas encore le catalogue.

Le candidat livré conserve le caster complet désactivé et projette les ombres
depuis les seules cellules dégagées ; matrice intacte pixel-identique vérifiée.
La réussite technique ne vaut pas acceptation esthétique humaine. Preuves et
limites dans `docs/dev/P6A35_AESTHETIC_REPORT.md`.


## 2026-10-14 — GO crâne de référence artistique P6A3.6

Antoine autorise le vrai travail de modelage pour voir un candidat représentatif
de la qualité artistique de production. L’objectif est de valider cette qualité
avant extension du catalogue, avec ivoire chaud et ombres exposées conservés.
Le pilote paramétrique en tubes ne constitue pas cette référence.

Le candidat livré utilise des cages anatomiques et des volumes creux, avec
comparaison directe des deux GLB et étude sans texture dans Godot. Le concept
ImageGen est une intention, pas une preuve de qualité du runtime. Le contact
des os réellement dégagés est affiné sur leurs triangles dans cette scène
isolée ; règles et presets restent conservés. Le verdict artistique reste humain.


## 2026-10-14 — Référence artistique du crâne acceptée

Antoine valide positivement le nouveau crâne P6A3.6 : plus joli, avec des détails
supplémentaires et des dents qui donnent davantage d’intérêt à la précision
pendant la fouille. Conserver ce modèle comme référence artistique pour cadrer
les prochains assets. Le détail anatomique a ici une valeur visuelle et tactile
confirmée ; ne pas réduire cette richesse à de la décoration de texture.

Ce retour ne déclenche pas automatiquement la production du catalogue ou une
phase suivante. Brush et dégâts localisés restent conservés tels que validés.


## 2026-10-14 — GO modelage du squelette B-17 après validation du crâne

Antoine autorise explicitement l’application du niveau artistique accepté aux
côtes et au reste du squelette, même style et interactions validées conservés.
Le périmètre couvre le B-17 actuel ; il ne déclenche pas un catalogue multi-spécimens.

Conserver le crâne accepté exactement et reprendre les autres pièces en volumes
anatomiques : articulations, lames, creux, phalanges et griffes. Le candidat P6A3.7
remplace entièrement le relief Bone dans sa scène isolée, sans changer les quatre
composantes canoniques ni leurs règles. La réussite technique et la référence du
crâne ne valent pas validation humaine automatique des nouvelles régions.


## 2026-10-14 — Squelette modelé et méthode artistique acceptés

Antoine valide le B-17 P6A3.7 et souhaite employer cette approche pour les futurs
squelettes et reliques de la collection. La référence devient le modelage local
Blender de vrais volumes anatomiques/structurels, aidé par script, export GLB,
champ de fouille dérivé des surfaces et contrôle dans Godot en fouille/hors matrice.
Le détail doit servir la beauté et l’intérêt de la précision, tout en restant lisible.

Préserver le langage chaleureux et les interactions ; adapter la matière aux
objets futurs. Cette décision retient une direction de production, sans autoriser
implicitement la fabrication immédiate du catalogue ou une nouvelle phase.


## 2026-10-14 — Publication main autorisée, son différé

Antoine demande explicitement la mise à jour de GitHub et la publication de la
dernière version jouable validée sur main. Consolider le lancement par défaut
sur B-17 modelé, puis intégrer les PR empilées ; préserver les scènes historiques.
Le Sound Design est différé faute de crédits Claude disponibles actuellement.

Lampe orientable, silhouette naturelle du bloc et variété matériaux/outils sont
remis en discussion pour la rejouabilité. Cette demande de cadrage n’autorise
pas leur implémentation immédiate ni une architecture de strates N-slots.


## 2026-10-14 — Version validée publiée sur main

Publication demandée par Antoine réalisée via les PR #10 puis #11 ; B-17 modelé
est désormais le lancement normal du projet. Les PR fusionnées ne constituent
plus des gates actives. Garder sources, scènes et preuves historiques, et conserver
le répertoire de données utilisateur existant. Le Sound Design reste différé.

Pour la discussion de rejouabilité, distinguer lecture/interaction (lampe),
identité du bloc (silhouette) et variété des décisions de fouille (spécimen,
géologie, placement et effort). Tester d’abord un petit lot de blocs façonnés
avec les rôles matériaux existants avant une migration de strates ou une
multiplication des outils. C’est une recommandation, pas un GO d’implémentation.


## 2026-10-14 — GO essai de lampe orientable

Antoine autorise explicitement l’essai, avec ambiance chaude, interactions
validées et secret des os enterrés conservés. La source se déplace autour du
bloc pour changer le sens des ombres ; l’objet et ses réglages acceptés sont réutilisés.
Mode de manipulation explicite, retour simple aux outils, capture sans excavation.

La référence main reste inchangée. Le candidat P6A3.8 est isolé et sa validation
humaine doit porter sur l’aide à lire le relief et le confort de manipulation.
La protection des os enterrés reste indépendante de l’orientation de lumière :
masque d’exposition réel et caster des seules cellules dégagées. Vérifier à la
fois pixels et indices, car les ombres d’os déjà dégagés sur de la matrice couverte
sont légitimes et ne constituent pas une révélation d’os encore enterrés.


## 2026-10-14 — Lampe mobile mise de côté après essai humain

Antoine juge le déplacement de lampe trop gadget actuellement : bénéfice de
jeu insuffisant, geste peu intuitif et objet qui glisse autour de la table peu
convaincant. Ne pas intégrer cet essai ; privilégier une bonne lumière fixe,
chaude et centrée. Cela ne remet pas en cause le B-17 modelé ou les interactions
acceptées. Aucun redesign supplémentaire de lampe n’est déclenché.

Le signalement de restes orange autour des os doit distinguer matrice attachée,
miettes libres et défaut de rendu. Ne pas masquer cosmétiquement un matériau
encore présent, ni modifier la Brush validée sur la seule base d’une capture.


## 2026-10-14 — Recentrage fixe et clarification des restes orange

Antoine demande une lampe fixe centrée, afin de mieux répartir la lumière sur le
bloc plutôt que de l’éclairer depuis la gauche. La demande ne rétablit pas le
mode de manipulation mobile rejeté.

Il confirme que l’argile orange se retire bien ; c’est son contour qui épouse
artificiellement les os qui pose problème. Le diagnostic de retrait au Pick
répondait à une autre question et ne constitue pas une validation artistique.
Conserver ce retour sans modifier les outils acceptés. Les formes naturelles
extérieures sont proposées comme suite, sans GO implicite sur tout le chantier.


## 2026-10-14 — GO premier bloc naturel, contour et lampe

Antoine autorise un premier bloc aux formes naturelles, B-17 et interactions
validées conservés, ainsi que la correction du contour orange si un fix est
identifié. Il signale que le modèle de lampe centré masque le dessus du bloc.
La source chaude centrée reste la référence ; la géométrie décorative est retirée
du champ de fouille dans le candidat, sans réintroduire de manipulation.

Pour une silhouette de bloc, partager le domaine entre rendu, matière initiale,
picking et évacuation des miettes ; ne pas produire seulement une découpe visuelle
qui conserve des coins invisibles jouables. Ne pas façonner le contour d’après
les os cachés. Le défaut de liseré reproduit vient de l’interpolation d’une hauteur
Bone dans la matière voisine ; corriger l’identité locale réelle sans supprimer
la matrice ni déplacer les plafonds. Le rapport P6A40 garde les preuves et limites.
Cette livraison ne vaut pas validation humaine du nouveau bloc ou du correctif.


## 2026-10-14 — Retour humain sur les bords du premier bloc naturel

Antoine préfère nettement la silhouette irrégulière, mais les flancs et l’arête
restent trop propres, comme découpés à la disqueuse. Conserver l’irrégularité
extérieure comme direction ; rechercher des cassures et volumes de roche brute
sur les bords. Ce retour ne valide pas toute la phase et ne déclenche pas seul
une nouvelle implémentation. Le rapport P6A40 conserve le détail de la proposition.


## 2026-10-14 — GO passe des bords bruts

Antoine autorise la passe proposée : volumes cassés de tailles variées, pans
inclinés et arête ébréchée avec portions préservées, matière des flancs plus lisible.
Conserver la silhouette supérieure appréciée, B-17 et les interactions validées.

Pour un domaine de hauteur irrégulier, le vide logique ne doit pas être moyenné
comme un échantillon de roche à hauteur zéro sur le bord. Un guard de rendu hors
domaine peut porter l’échantillon voisin, à condition de rester hors matière
jouable et d’être partagé avec le picker. Garder la mise à jour immédiate des
contacts après édition. Le rapport P6A41 conserve preuves et limites ; aucune
validation artistique de cette nouvelle passe n’est déduite des contrôles.


## 2026-10-14 — Bords bruts appréciés comme base de travail

Antoine juge la passe P6A41 « déjà sympa pour le moment » et demande la suite.
Conserver cette référence pour avancer, sans prolonger spontanément le polissage
des bords. La prochaine étape doit être proposée puis choisie ; ce retour ne
vaut pas GO pour la variabilité, un catalogue ou une fusion.


## 2026-10-14 — GO essai de trois géologies B-17

Antoine autorise les trois préparations proposées avec B-17, outils et interactions
validés conservés. La variation doit porter sur la manière de fouiller, sans être
une simple augmentation de durée. Tester d’abord des profils façonnés avec les
matériaux actuels ; conserver les plafonds et la source du même spécimen pour
isoler la géologie. Le rapport P6A42 garde budgets, parcours et limites ; le
verdict humain décidera si les accès changent réellement les choix du joueur.


## 2026-10-14 — Géologies variées, stratégie inchangée : essai non concluant

Retour humain P6A42 : les trois profils restent essentiellement une variation
visuelle. Le Chisel est utilisé en masse, puis le Pick et la Brush près des os.
Changer la distribution de Clay/Sandstone ne suffit donc pas à prouver la
rejouabilité. Le coût structurel inférieur à la référence garantit un budget,
mais ne démontre pas de diversité d’actions. Discuter des comportements de
matériaux et des choix qu’ils créent avant d’étendre les profils ou les outils.
Conserver le tactile et l’art appréciés ; le nouveau gameplay exige un GO dédié.


## 2026-10-14 — GO plaque de grès fracturée

Antoine autorise un essai borné : garder le feeling des outils, proposer des
fissures lisibles et un détachement satisfaisant. Le candidat repart des bords
bruts avec un comportement local de joint ; les trois géologies restent une
expérience non concluante pour la rejouabilité.

L’impact natif doit conserver cadence, contact préalable et décisions Bone.
Le retrait de plaque vient ensuite, limité à la matrice réellement restante et
à ses plafonds. La pièce animée ne remplace pas la matière attachée : elle vient
de la matière retirée et quitte le domaine jouable. Le Chisel reste une voie
possible. Le rapport P6A43 garde seuils, preuves, coût ponctuel et limites ;
le verdict humain sur le nouveau geste reste nécessaire.


## 2026-10-14 — Plaque : incitation réussie, direction de composition variable

Antoine juge la plaque imparfaite, mais elle donne une raison d’utiliser autre
chose que le Chisel. Retenir ce signal positif sur la variation des gestes,
sans assimiler le spike à une mécanique équilibrée ou visuellement finale.
L’intégration artistique reste à améliorer.

La direction souhaitée est un mélange de situations locales, avec des plaques
réparties de manière variable et d’autres comportements complémentaires dans
les blocs. La variété doit donc porter sur les gestes et choix, en plus de la
géologie visible. Les règles de placement et la palette de situations restent
à concevoir ; la gate du statut canonique détermine la prochaine action.


## 2026-10-14 — GO intégration naturelle de la plaque

Antoine autorise la proposition : contour moins découpé, fissures liées au relief
et enfouissement partiel. Conserver le geste encourageant, les outils et B-17.
Une couverture Clay doit être une vraie interface, pas un recoloriage ; elle
remplit les fissures cachées au lieu d’en imprimer le contour. Le crédit de joint
vient d’un grès réellement visible avant l’impact.

Le morceau détaché doit conserver la matrice restante, son relief et ses couches,
avec des normales/faces cohérentes et ses ombres. Le rapport P6A44 garde les preuves,
coûts et limites. Cette passe ne constitue pas le GO d’une autre mécanique ou d’un
générateur de blocs ; la revue artistique reste la prochaine étape.


## 2026-10-14 — Revue de la plaque et limite de l’éclairage centré

Antoine juge l’intégration de la plaque un peu meilleure mais encore peu naturelle,
avec des fissures trop lisses, et remet en question son retrait automatique. Ne pas
transformer l’intérêt déjà reconnu de varier les outils en validation de ce retrait
ou de l’art final. Une extraction active reste à discuter.

Le centre trop lumineux est un nouveau défaut signalé sur captures. L’équilibre
mesuré entre points symétriques gauche/droite ne prouve pas l’uniformité entre le
centre et les bords. Conserver cette distinction dans les prochaines revues de
lumière. Le rapport P6A44 détaille le diagnostic et les propositions ; la gate du
statut canonique conserve seule la prochaine action autorisée.


## 2026-10-14 — GO lumière uniforme, fractures brutes et levier manuel

Antoine autorise une passe ciblée sur les trois problèmes du retour P6A44 :
éclairage plus uniforme, fissures plus brutes et retrait manuel au Pick par un
petit geste de levier. Garder les outils, B-17, la chaleur, le relief et les os
enterrés protégés. Le travail sur les joints doit rendre la plaque mobile ; le
joueur décide ensuite de la décoller. Relâcher avant la fin doit être réversible.

Le candidat P6A45 conserve les scènes témoins et les réglages des quatre outils.
Le rapport dédié garde la distinction entre prévisualisation attachée, retrait de
vraie matière et dépose assistée, ainsi que les preuves centre/bords. La validation
artistique et tactile reste humaine ; aucun GO de généralisation ou de merge.


## 2026-10-14 — Levier préféré ; plaque à penser comme un volume enfoui

Antoine préfère le retrait manuel au Pick. Conserver cette direction sans assimiler
la préférence à une validation artistique de la plaque. Il relève encore une
frontière grès/argile trop nette, souhaite une influence visible sur l’argile et une
rupture autour de la plaque quand elle est prête à sortir. L’idée d’un « iceberg »
désigne un volume enfoui irrégulier avec une empreinte correspondante après retrait.
Le rapport P6A45 conserve captures, diagnostic et proposition ; la gate du statut
canonique conserve seule la prochaine action autorisée.


## 2026-10-14 — GO essai de roche enchâssée pour décider du système

Antoine autorise l’essai de la proposition plaque–argile–empreinte après avoir
préféré le levier manuel. Garder ce geste, rendre la transition plus morcelée,
faire progresser une rupture autour de la plaque et donner au volume enfoui une
forme irrégulière dont dérivent ensemble le morceau et le creux.

Le but de l’essai est de décider humainement si ce système est à retenir dans le
jeu. Ce GO ne constitue donc pas la validation définitive, la généralisation à
d’autres blocs ou le merge. Le rapport P6A46 garde les preuves, le modèle de volume
et ses limites ; les autres interactions validées et les os enterrés restent
protégés. La gate du statut canonique conserve seule la prochaine action.


## 2026-10-15 — Rejouabilité : utilité de la plaque encore incertaine

Antoine doute de la nouvelle fonctionnalité de plaque et demande d’autres idées
pour la rejouabilité. Conserver l’expérimentation sans la considérer comme une
fonctionnalité de production retenue ; la préférence antérieure pour le levier
portait sur le mode de retrait. Reprendre le signal P6A42 : varier les deux
matériaux visuellement n’avait pas suffi à varier la stratégie. Le rapport P6A46
conserve ce retour et les hypothèses proposées, sans les canoniser comme choix
humains. La gate du statut conserve seule la prochaine action autorisée.


## 2026-10-15 — GO poche friable : premier essai cohérent de game design

Antoine sélectionne la poche friable pour un essai et demande de concevoir une
proposition convaincante dès la première livraison, plutôt que plusieurs retours
sur une intégration minimale. Isoler une situation courte : ouvrir une croûte,
évacuer les grains au souffleur, puis poursuivre la préparation du squelette.
Le choix réutilise les outils existants et vise un vrai changement de geste,
sans rallonger le bloc. Ce GO ne valide pas encore le plaisir, l’art final ou la
généralisation ; la plaque précédente conserve son verdict incertain.
Les preuves de l’essai sont dans le rapport P6A47 ; la gate demeure dans le statut.


## 2026-10-15 — Retour positif sur la poche ; variation et profondeur souhaitées

Antoine trouve la poche friable sympa, avec un potentiel conditionné à une bonne
intégration. Il souhaite des découvertes à des endroits variables, qui puissent
se prolonger dans le bloc plutôt que rester uniquement en surface, et une
présence aléatoire entre blocs. Retenir cette direction pour le design de
rejouabilité, sans transformer ce signal en validation artistique finale,
fréquence imposée ou génération déjà approuvée. Le rapport P6A47 conserve le
retour et la proposition de suite ; le statut conserve seul la gate.


## 2026-10-15 — GO poche à mi-profondeur

Antoine autorise l’essai de poche enfouie proposé après le retour positif P6A47.
L’objectif est de la découvrir pendant la fouille et d’explorer un volume dans
l’épaisseur, avec quelques implantations contrôlées avant une éventuelle
répartition variable. Préserver les outils, le soufflage court et les os couverts.
Ce GO n’autorise pas implicitement la génération globale, l’art final ou le merge.
Le rapport P6A48 conserve les preuves et les limites de la représentation actuelle ;
le statut conserve seul la prochaine action.


## 2026-10-15 — Dynamique de poche enfouie validée ; viser une dernière finition

Antoine valide explicitement la nouvelle dynamique apportée par la poche à
mi-profondeur. Il veut une passe finale de game design, de rendu et d’apparition
pour arrêter l’itération sur cette fonctionnalité et avancer vers d’autres
missions. Retenir le comportement comme direction sélectionnée, sans assimiler
ce verdict à l’approbation de l’art final ou de la distribution des rencontres.
Le dernier addendum P6A48 conserve une proposition bornée et ses critères de
clôture ; ces suggestions ne sont pas encore des décisions humaines.


## 2026-10-15 — GO finition bornée des poches et revue interne

Antoine sélectionne la passe de découverte progressive, grain mat, souffle court
avec une fin lisible et zéro/une poche variable par préparation. Il demande une
revue attentive et des corrections internes avant livraison. La dynamique P6A48
reste validée ; ce GO ne vaut pas approbation de l’art final ou merge. La recette
sépare génération géologique et admission Bone : rejeter entier un volume unsafe
évite de révéler l’anatomie par le fond. Les preuves et limites de cette finition
sont dans le rapport P6A49 ; le statut conserve seul la prochaine action.

## 2026-10-15 — Poche friable validée pour avancer

Antoine valide P6A49 comme référence actuelle. Réserver les éventuels raffinements
aux interactions avec d’autres systèmes, plutôt que prolonger la finition de
cette fonctionnalité isolée. Cette décision clôt la revue humaine de la passe ;
elle ne sélectionne pas encore le prochain chantier et ne demande pas de merge.
Le rapport P6A49 conserve le verdict et les preuves ; le statut conserve la gate.

## 2026-10-16 — GO deuxième spécimen et petite collection persistante

Après validation de la poche friable, Antoine autorise la mission proposée :
un deuxième fossile distinct, deux places de collection et une transition entre
préparations. Priorité à un premier essai amusant et soigné, avec revue et
itérations internes. Le prototype retient M–08, une ammonite stylisée, face à
B–17 ; cela n'est pas encore une validation humaine de son art ou de la boucle.
Conserver les outils et interactions acquis ; différer l'économie, le musée
complet et le Sound Design. Le rapport P6A50 conserve les choix candidats et les
preuves ; seul le statut porte la prochaine action autorisée.


## 2026-10-16 — Workflow par issues et retour sur la présentation de la collection

Antoine demande explicitement un plan découpé en issues GitHub, traitées une par
une : issue terminée → PR → validation → merge → nettoyage des branches. Les
missions suivantes repartent de main ; arrêter l'empilement de branches de
prototypes. La méthode durable est dans `docs/DEVELOPMENT_WORKFLOW.md`.

Antoine apprécie l'ammonite mais rejette l'esthétique des écrans de caisses et de
collection, trop proche d'un jeu navigateur. Ne pas confondre ce retour positif
sur l'asset avec une validation globale de la boucle ou une permission de merge.
La continuité visuelle avec l'atelier guide les propositions ; desserte et registre
restent des options à valider, sans modification des interactions acquises.


## 2026-10-16 — Consolidation approuvée avec interfaces provisoires

Antoine répond « Yes je valide ! » à la proposition explicite de fusionner #24
comme base jouable avec les écrans provisoires, avant leur refonte dans les
issues dédiées. Cet accord autorise la fusion et le nettoyage des branches.
Il ne valide pas artistiquement les écrans et ne déclenche pas automatiquement
l'implémentation des issues suivantes. Le prototype divergent de lampe orientable
est conservé sous le tag `archive/p6a38-orientable-lamp-2026-10-16` avant retrait.


## 2026-10-16 — GO issue 26, conservation stricte du gameplay

Antoine autorise le nettoyage du code et des anciens prototypes avec vérifications
complètes et PR à valider. Nommer les composants réutilisés par responsabilité,
retirer seulement les expériences séparables et leurs tests propres, conserver
les régressions utiles et les sources d'assets. Les déplacements gardent les UID
et le comportement ; une ancienne génération peut encore être une dépendance.
Les preuves et limites de cette migration sont dans le rapport de l'issue 26.
Cette autorisation ne porte ni sur le merge ni sur la refonte des écrans.


## 2026-10-16 — Caisses abandonnées, priorité au cadrage avant réalisation

Antoine rejette le concept de caisses actuel, insuffisant artistiquement, et le
reporte à une passe dédiée future. Ce verdict remplace l’acceptation provisoire
de la disposition. Fermer #30 sans fusion, garder une archive récupérable, retirer
la branche active. Main conserve B–17 et l’ammonite avec le gameplay validé.

Avant de poursuivre, mener un brainstorm global. Pour chaque étape, prendre le
temps de définir ce qu’elle doit être dans le jeu avant de la développer. Une
composition fonctionnelle ou des tests verts ne remplacent pas une vision validée.
Les arrivages et la collection visuelle sont différés ; leur forme reste ouverte.


## 2026-10-16 — Découverte prioritaire, collection comme continuité

Antoine privilégie la surprise de découvrir, avec la collection qui donne envie
de continuer. Il demande de définir ensemble la session idéale, sans développement.
Cette orientation ne tranche pas encore les indices initiaux, la distribution du
contenu, les doublons ou la forme de la collection.


## 2026-10-16 — Indices larges et diversité réelle de préparation

Antoine souhaite des indices de provenance sans connaître précisément le contenu.
Il évoque de futures étiquettes et symboles sur des caisses ; le rendu abandonné
reste rejeté. La rejouabilité doit dépasser le schéma argile/grès/poche : explorer
des matières et approches différentes, éventuellement des outils distincts,
cohérents avec les provenances. Préserver le plaisir de découverte et le soin de
préparation. Les exemples marin/Égypte sont des pistes, pas des recettes ni un GO.


## 2026-10-16 — Trois recettes à éprouver avant extension du contenu

Après description des parcours, Antoine autorise trois démos soignées : compact,
granulaire, encroûté. Les construire au niveau visuel du bloc de référence,
prendre des captures et itérer après revue interne. Le nouveau geste doit
modifier la manière de préparer, sans simplement allonger le travail.

B–17 et M–08 servent de témoins. La pointe abrasive est un outil expérimental
pour les dépôts localisés ; les quatre outils validés restent la référence.
Une enveloppe granulaire peut découvrir réellement le fossile, à condition de
respecter l'accès par une ouverture et les collisions. La couverture intacte
ne doit porter aucune empreinte de l'anatomie ni des concrétions enfouies.
Ces essais ne valident pas une génération globale ou une extension du catalogue.
Leur qualité technique et la revue des captures ne remplacent pas le verdict
humain sur l'intérêt des trois approches.

## 2026-10-16 — Trois préparations validées, finition à cadrer par mécanique

Antoine valide l'intérêt ludique de l'essai #33. La préparation marine centrée
sur le souffle et la pointe abrasive des concrétions apportent une variation
appréciée. Les poches doivent mieux équilibrer le grès du bloc compact ; les
creux de l'ammonite doivent offrir un relief sensible au Pick. Ces réserves
définissent des sujets de finition, pas un rejet des nouvelles approches.

Il propose de regrouper les outils par familles avec variantes sur appuis
répétés, par exemple Brush/abrasif sur 1. L'idée vise une utilisation plus
ludique et une place pour de futurs gestes spécialisés ; elle ne valide ni une
nouvelle alternative précise au Chisel, ni un changement automatique d'outil.

La validation explicite de l'essai permet de clore sa PR conformément au
workflow installé. Définir et valider la vision de chaque prochaine mission
avant création d'issues exécutables et développement. Garder les démos séparées
de la collection réelle ; leur acceptation ne valide pas encore un générateur
de recettes, un catalogue supplémentaire ou une finition artistique définitive.

## 2026-10-16 — GO relief de l'ammonite, puis finition ciblée des mécaniques

Antoine approuve la mission de relief de M–08 : découvrir les bosses au souffle,
suivre les creux au Pick et révéler les détails sous les concrétions. Réaliser
cette mission avant les passes ciblées sur les mécaniques, chacune avec sa vision
et sa validation. L'accord ne déclenche pas toutes les finitions en parallèle.

Orientation durable : étendre la rejouabilité par des nouveautés de game design
qui diversifient réellement les gestes et situations, puis bien les exécuter.
Continuer à explorer des idées utiles au plaisir de préparation ; la seule
quantité de matériaux ou de pièces n'est pas le moteur recherché.

## 2026-10-17 — Précision M–08 : relief entre petites côtes, spirale compacte

Antoine préfère le sillon resserré de la version antérieure à #35. Les « petites
vagues » désignent les côtes transversales de la coquille, pas les grands tours.
Restaurer la spirale validée et donner du volume aux creux entre côtes pour que
le Pick les suive réellement. Cette précision remplace l'interprétation élargie
de la première proposition ; poursuivre la correction dans la même PR #36.

## 2026-10-17 — Relief corrigé de M–08 retenu

Antoine accepte le résultat corrigé 75555a0 : « Ok c'est sympa comme ça ! ».
La spirale compacte avec petites côtes sculptées devient la référence pour M–08.
Clore #35 selon le workflow ; cadrer la prochaine finition avant développement.

## 2026-10-17 — GO terre compacte, trois dispositions

Antoine autorise une grande poche avec une petite, plusieurs poches modestes,
puis une veine plus profonde avec une seconde rencontre. Argile dominante,
bancs de grès discontinus, poches remplaçant de la matière compacte pour créer
des accélérations et des choix de poursuite. Garder rendu et feeling des outils.
Captures, revue et itérations avant PR ; l'accord porte sur l'essai #37, pas
sur un générateur global ou les familles d'outils.

## 2026-10-17 — Terre compacte validée, C comme référence de rythme

Antoine valide le mélange des trois dispositions #37 : les variations de
hauteur des matières, les bancs de grès locaux et les poches créent un rythme
plus intéressant que l'ancienne disposition en couches. Elles nourrissent
l'envie de découvrir ce qui se trouve plus loin et dans le prochain bloc.

C · Veine profonde est sa préférée, pour la sensation « sur quoi est-ce que
je vais tomber ». Retenir cette composition comme référence de rythme et
d'incertitude pour la suite, en gardant les trois essais comparables.
La surprise recherchée porte aussi sur la géologie pendant la fouille,
en complément de l'identité du spécimen à découvrir.

Ce verdict valide l'essai livré, pas encore un générateur de production ni
une fréquence universelle de poches. Cadrer séparément les prochaines
finitions avant développement, selon le workflow installé.

## 2026-10-17 — GO finition des concrétions et famille sur 1

Antoine approuve trois rencontres : dépôt mince, amas entre plusieurs côtes et
traînée suivant une courbure. L'abrasion doit montrer un retrait local et rapide,
révéler le relief sous une poussière encore brossable, avec des dépôts visuellement
minéraux et une majorité de coquille libre. Captures et itérations avant PR.

La touche 1 regroupe Brush/pointe abrasive : retour à la dernière variante
depuis un autre outil, alternance sur nouvel appui dans la famille, Brush par
défaut. Un emplacement affiche clairement la variante et l'alternative.
Le GO conserve outils et interactions validés ; aucune nouvelle pénalité,
recette globale, collection ou passe sonore n'est incluse.

## 2026-10-17 — Concrétions et famille de finition validées

Après essai de la passe #39 livrée dans la PR #40, Antoine confirme :
« Ok j'ai testé c'est cool ! » Le commit jouable est a750318.
Ce retour valide globalement les trois rencontres et la famille Brush/pointe
sur 1 telles que livrées ; aucune correction supplémentaire n'est demandée.
Conserver cette référence pour les prochaines préparations. La génération
de production et les futures mécaniques nécessitent leur propre vision
approuvée avant développement.

## 2026-10-17 — Cadrage marin, puis fluidité des outils

Antoine demande une proposition concrète de finition des sédiments marins,
avec le gameplay axé sur le Blower. Il souhaite ensuite une passe dédiée à
la fluidité : sensation de retard ou de mouvement peu fluide malgré 240 FPS
affichés. Ne pas confondre débit d'images, fréquence d'écran et réactivité.
Ces demandes fixent les sujets à cadrer, sans approuver une implémentation.

Une inspection du code donne une piste à vérifier en exécution : le point visé
et le cercle sont actualisés dans ToolController._physics_process à 60 Hz ;
le modèle animé à chaque image réutilise controller.hit.world. Ce constat
ne mesure ni la latence totale ni la fréquence effective de l'écran.

## 2026-10-17 — GO finition des sédiments marins
Antoine approuve la vision fenêtre → nappe → relief, avec le Blower central,
les gestes et outils validés conservés, et une revue native par captures avec
itérations avant PR. La passe fluidité vient après cette mission, séparément.

## 2026-10-17 — Blower marin validé, préparation à prolonger par du travail dur
Antoine valide le feeling du souffle et la réaction de matière de #41, mais
termine trop vite (environ 30 secondes selon son essai). Le Blower doit donner
un aperçu rapide de la découverte, puis laisser davantage de matrice dure sur
l'ammonite et autour, à préparer au Chisel/Pick. Conserver la réaction rapide
du sédiment ; ajouter du travail de précision plutôt que ralentir le souffle.
Correction dans la même PR #42 avant validation globale ou fusion.

## 2026-10-17 — Structure marine acceptée, durée encore trop courte
Après essai de la correction 9fb752f, Antoine confirme que le mélange avec
les bancs durs correspond à son intention. Il termine toutefois la préparation
en 1 min 30 à 2 min et la juge encore trop rapide. Conserver le feeling et
la structure acceptés ; définir la durée et le parcours avant de choisir le
prochain levier. Ce retour ne fixe pas de durée cible et ne valide pas une
nouvelle mécanique, un ralentissement des outils ou la fusion de la PR #42.

## 2026-10-17 — Durée cible des petits spécimens
Antoine confirme 5–7 minutes comme durée adaptée à un petit spécimen de type
ammonite. D'autres spécimens pourront demander des préparations plus longues ;
aucune durée n'est encore fixée pour ceux-ci. C'est une cible de conception
à évaluer en essai humain, sans minuterie imposée. La confirmation porte sur
la durée ; les leviers de progression en profondeur et les rencontres
supplémentaires proposés restent à cadrer.

## 2026-10-17 — GO parcours marin suivant
Antoine autorise le prochain test selon les modifications proposées : découverte
rapide, progression en profondeur et zones de travail distinctes, avec une courte
rencontre de concrétions utilisant la famille de finition validée. Cible humaine
5–7 minutes pour cette petite ammonite ; conserver outils et réactions validés.
La correction reste dans #41 / PR #42, avec captures et contrôles avant essai.

## 2026-10-17 — Retour positif sur le parcours marin en profondeur
Antoine décrit le nouvel essai comme sympa et une base fun, tout en évoquant
quelques améliorations possibles sans les préciser. Retenir ce retour sur le
plaisir du parcours actuel, sans inventer de défaut à corriger ni de durée
humaine mesurée. La cible de 5–7 minutes reste distincte de ce verdict.

## 2026-10-17 — Clôture marine et GO fluidité
Antoine autorise la fusion de #42 et le nettoyage de sa branche, puis la passe
fluidité. Comparer avant/après sur terre compacte, sédiments marins et concrétions,
en conservant le feeling validé. Objectif : suivi précis, contact réactif et
mouvements réguliers ; mesures techniques et verdict humain restent distincts.

## 2026-10-17 — Fluidité acceptée et prochain cap à cadrer
Antoine valide le suivi d'outils de #43 / PR #44, nettement plus fluide après essai,
et autorise fusion puis nettoyage. Des baisses de FPS persistent lorsqu'il souffle
beaucoup de particules ; elles ne remettent pas en cause cette acceptation.
Les traiter séparément dans #50 sans attribuer leur cause aux seuls effets avant profilage.

Antoine souhaite explorer une première exposition et une boucle arrivages,
préparation, collection. Séparer le cadrage #45, arrivages #27, collection #28,
UI #46, décor de bureau en assets 3D #47, sons avec Claude la semaine prochaine #48
et musique #49. Approfondir chaque vision avant développement ; ces tickets
n'autorisent pas une implémentation immédiate. Le rendu des anciennes caisses
reste rejeté. La découverte est prioritaire, la collection donne envie de continuer.

## 2026-10-17 — Vision d'exposition acceptée pour essais
Antoine valide provisoirement une petite galerie 3D, sans avatar, avec vues composées,
déplacement horizontal et inspection rapprochée. B–17 et ammonite restent dans leur
matrice, sur des supports adaptés ; le résultat réel de préparation doit, à terme,
être conservé avec matière restante, nettoyage, dégâts et distinctions.
Privilégier des emplacements conçus et une boucle arrivage → préparation → exposition
→ nouvel arrivage. L'extraction et le squelette monté ne font pas partie du premier cap.
Commencer les essais puis ajuster ; cet accord ne vaut pas validation artistique finale.
L'essai visuel borné #51 précède la conservation 3D réelle et le raccordement de la boucle.


## 2026-10-17 — Navigation appréciée, art du musée à reconcevoir
Antoine apprécie la caméra et les transitions entre pièces de #51, mais juge
le rendu actuel impropre à la production. Concevoir une vraie scène de musée
d'histoire naturelle : architecture, ambiance, environnement et supports pour
les préparations. Repartir des concepts initiaux et de l'esprit accueillant
d'Animal Crossing ; établir des références visuelles avant la production
d'assets 3D avec Tripo. Cette appréciation partielle ne valide pas le décor.
Les nouveaux concepts restent des propositions tant qu'Antoine n'en a pas choisi
la direction ; la conservation des vrais blocs reste souhaitée.

## 2026-10-17 — Seconde direction de musée retenue, continuité atelier obligatoire
Antoine préfère le second concept, plus stylisé, et demande que ses graphismes
collent à ceux de la préparation. Retenir son architecture et son ambiance tout
en prenant le rendu validé du jeu comme référence pour les matières, les os et
le niveau de détail. Adapter le décor aux vrais blocs. La sélection du concept
ne valide ni le décor natif actuel ni une fusion de #52.

## 2026-10-17 — Réglages explicites avant chaque génération Tripo
Antoine demande de mémoriser les réglages et de lui donner, pour chaque nouvelle
génération, une fiche adaptée à l'asset : référence, modèle, géométrie, textures,
budget de polygones et export. Ne pas se fier à la persistance des options Studio.
Première fiche recommandée pour le présentoir B–17 :
[réglages Studio](../visual-references/museum/furniture/TRIPO_STUDIO_SETTINGS.md).
Antoine prévoit un lancement manuel ; aucun modèle n'est encore reçu ni validé.

## 2026-10-17 — Qualité du pilote avant réduction du maillage
Antoine remet en question le faible budget proposé pour B–17 et veut préserver
la qualité artistique. Distinguer la source de génération de la version destinée
au jeu : comparer dans Godot avant réduction. Fiche Studio révisée vers une source
plus détaillée ; ces nouveaux réglages restent une recommandation non éprouvée.

## 2026-10-17 — Conservation des exports Tripo
Présentoir B–17 fourni par Antoine. Original copié sans retouche dans un dossier
local stable hors worktree et dans assets/museum/source/ pour versionnage ;
emplacements, provenance et empreinte dans assets/museum/source/README.md.
Les futurs dépôts peuvent être signalés par leur nom dans le chat. Leur archivage
Git reste explicite ; le dossier local seul ne garantit pas une sauvegarde distante.

## 2026-10-17 — Présentoir B–17 retenu, scène à poursuivre
Antoine apprécie le rendu du pilote B–17 mais rejette le cartel frontal « Petit
théropode ». Conserver le rendu du meuble comme référence, refaire le cartel et
poursuivre l'application de cette qualité au reste de la scène. Cette appréciation
ne valide pas la salle entière ni la fusion de #52.

## 2026-10-17 — Mobilier apprécié, environnement à refaire
Antoine trouve les assets Tripo sympathiques, mais rejette encore le sol, les
murs et le décor de fond. Préparer des références de production pour remplacer
ces éléments ; cette appréciation ne vaut pas validation de la salle entière.
