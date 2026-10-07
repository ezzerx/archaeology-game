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
