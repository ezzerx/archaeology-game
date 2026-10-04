# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — P4 Final Feel/P4-V1 mergés ; look Matrix 4,5 mm et physique persistante validés humainement**. Baseline d’entrée de dernière clôture `491934e1dae46c6c980a325e2d73f4aaee58cac6`. **Dernière passe de clôture P4 livrée**, branche `prototype/p4v2-debris-physics`, **PR #7 DRAFT**. Lire `docs/dev/P4V2_BRIEF.md`, `docs/dev/P4V2_REPORT.md` et le statut du Brain. **STOP pour retest humain final ; aucun merge ni P5 sans nouvelle autorisation.**

**Débris** : garder le look Matrix P4-V1, 4,5 mm max, mêmes mesh/couleurs/proportions/quantité selon accumulation. Physique sur petites miettes persistantes seulement ; chunks Chisel 3–6 mm, 1–5 par plaque, 0,51–0,69 s, inchangés. Cap Matrix **256**, Fine Dust hors cap. Places de naissance par zone 24×24 : **Clay 3 / Sandstone 4** ; rétention 8 %, capacité 0,02, surplus Dust, aucune éviction. Soil : **Fine Dust uniquement**, aucun grain persistant/transitoire, budget ou pool GPU Soil. Un MultiMesh 256, noyau physique 256, deux sous-pas à 60 Hz, gravité 0,65, restitution 0,12/ 0,22, friction 14/9, sommeil sans expiration. Blower : **pop 0,055 m/s au sol une fois, accélération horizontale 12 m/s², vitesse max 1,6 m/s**, traînée 0,2 pendant 2 s ; aucun lift répété en vol. Position XYZ autoritaire pour rendu/nettoyage/sortie, quantité réelle et libération du budget. Cache de sommets strictement local au tick, résultat exact du relief canonique. F3 physique Matrix ON/OFF, R conserve le mode et vide les états ; F1 compte Matrix/Clay/Stone/mouvement/sommeil/film/coûts, sans compteur Soil.

**Bone Surface Dirt Film** : nouvelle couche adhérente autorisée par la clôture, distincte de Fine Dust. Signal central de première exposition → film 0,85. Carte RGBA8 au quart par axe (160 KiB), quantité par groupe 4×4 et masque 16bits des cellules fines sales ; cellules déjà propres jamais resalies par une nouvelle voisine. Seul Soft Brush retire le film (`bone_film_clear=1,0/s`, autres outils0), ~1 s au centre ; audio Brush actif sur film seul, zéro nouvelle émission Matrix. Blower enlève Dust/débris mais laisse le film. Ivoire identifiable, patches brun terreux sombre distincts du Sandstone et rugosité. **Exposure ≠ Cleanliness ≠ Condition** : aucune autorité film sur relief, plafonds, protection ou dégâts. Reset réarme le film. Toute validation de cette clôture reste humaine.

**Base V1.1 conservée** : un seul profil statique en UV (`BlockVerticalityProfile`), Clay redistribuée par nappe/gradient et deux lobes doux, sans masque Bone. Soil et plafonds Bone V1 exacts (55,35–85,34 mm). Silhouette/IDs/totaux P4 exacts. Budgets Sandstone sur tout le fossile : P95 ≤18–20 mm, maximum ≤22 mm. Oracle relatif F1/tests : Clay au-dessus de Bone ×3 + Sandstone ×5,333… ; aucune prédiction de temps. **Verticality / generation must be effort-aware, not depth-only.** A `(250,230)` Skull, B `(510,307)` Spine, C `(646,441)` Hind Limb à 1024×640. Aucune seed/procgen ni retuning outil.

**V1.2 validée** : interfaces visuelles et matériau du curseur interpolés sur les mêmes triangles que le relief ; delta hauteur/limite calculé aux sommets, tolérance numérique normalisée `1e-6` (0,102 µm). Cartes géologiques et retrait par cellule inchangés. Valeur des faces renforcée sur les parois dures, éclats et miettes avec meshes statiques. Retour humain : grille orange absente, blocs/profondeur mieux lisibles, agrément préservé. Ces acquis restent verrouillés dans V2.

Référence P4 : Chisel spectacle A (`42ec46d`) avec éclats transitoires 3–6 mm, 1–5 par plaque cassée, pools bornés, expiration 0,51–0,69 s **dans les deux modes**. Le principe Blower B (`c25b44f`) de chasse directionnelle de petites saletés reste la cible ; ON utilise maintenant la position physique persistante et OFF son vol 2D historique. Fréquence persistante finale : trois miettes Clay / quatre Sandstone par zone 24×24, rétention 8 %, capacité 0,02. Mécaniques Soil et Pick préservées. Angle ancien fixe `(0.5, 0, -0.62)`, pointe exacte et corps soulevé localement. **Bone : une protection par composant (Skull / Spine / Ribs / Hind Limb), quatre maximum pour B-17 par reset ; Bone Condition globale.** Premier Chisel direct sur un centre du composant DÉJÀ EXPOSÉ AVANT le coup = petit tik, zéro dégât, protection de ce composant consommée ; suivants sur ce même composant = DING/−3. Toutes les côtes partagent RIBS, toutes les vertèbres SPINE. Révélation même centrale et Pick/Brush/Blower ne consomment rien. `direct_contact_consumed` est un tableau indexé par Component, NONE inutilisé ; reset réarme les quatre, F1 affiche READY/USED. Baseline P4 réévaluable en P7. Exposure inchangée. Proxies statiques Tip/Body, au plus douze sondes terrain, aucune reconstruction de mesh en jeu.

Baselines ressources humaines (rayon / puissance / falloff) : **Brush 40 / 0.70 / 1.25 ; Chisel 22 / 0.64 / 2.25 ; Blower 60 / 0 / 1.00 ; Pick 11 / 0.44 / 1.75**. Blower `residue_clear = 2.5`. **P4 human-validated baseline — tuning final deferred to P7.** Cadences, efficacités, génération de résidus, dégâts, résistances et seuils de fracture préservés.

Grammaire joueur : **matière attachée / saleté**. Soil → Brush ; matrice dure → Chisel ; détails près de Bone → Pick ; mess → Brush/Blower. **Dust may obscure detail, never material identity** : Bone garde son ivoire et sa réponse lumineuse. Dust par matériau local, sans nouvelle map ; soulèvement directionnel conservé. **[4] Precision Pick = micro-Chisel** : clic ou maintien immobile, 6 Hz, rayon 11, puissance 0,44, falloff 1,75, efficacités 0,30/ 1,00/ 1,50, interface et plafond osseux respectés, zéro dégât provisoire P4. Sons générés, Brush, proxies, fracture et caméra à préserver ; aucun bonus Brush, marge osseuse ou auto-stop Chisel. RMB pan borné à angle fixe ; Home restaure zoom/pan, R aussi le spécimen. Molette zoom 1–3× ; Shift/Ctrl/Alt puissance/falloff/rayon en debug, F6/F7 en secours. Cap 240 FPS, physique 60 Hz. Tuning final P7 ; la roadmap ne lance pas ses étapes.

## Invariants de conception

- Fouille strictement du dessus / tabletop, sans monde ouvert ni personnage contrôlable.
- Priorité à la sensation de fouille avant le volume de contenu et les systèmes secondaires.
- Musée en galerie horizontale ; squelettes visuellement incomplets tant que des pièces manquent.
- DA non verrouillée avant une comparaison sur le prototype jouable.
- Godot envisagé ; vérifier la version avant de la choisir.
- Nom ArchaeologyGame temporaire et modifiable.

## Documentation et mémoire

Répondre en français et conserver une documentation concise, actionnable, en UTF-8. Distinguer décisions confirmées, propositions et résultats réellement vérifiés. Après un changement durable, actualiser le statut et les décisions du Brain du dépôt, sans dupliquer l’état du projet dans le Brain global. Ne pas stocker de secrets ou importer la mémoire personnelle dans GitHub.
