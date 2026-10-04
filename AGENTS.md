# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — P4 Final Feel et P4-V1 Verticality validés humainement et mergés**. Baseline `main@ce014d0c2dd311ed2fbac0f37e0001be707a74a7`. Spike courant **P4-V2 Terrain-aware Debris Physics**, branche `prototype/p4v2-debris-physics`, **PR #7 DRAFT**. Lire d’abord `docs/dev/P4V2_BRIEF.md`, `docs/dev/P4V2_REPORT.md` et le statut du Brain. Les acquis P4/V1 restent définis par `docs/dev/P4_FINAL_FEEL_TARGET.md`, `docs/dev/P4_REPORT.md` et `docs/dev/P4V_REPORT.md`. **STOP après livraison pour le test humain KEEP / SIMPLIFY / DROP. Aucun merge, P5 ou fusion avec les miettes persistantes sans nouvelle autorisation.**

**V2 expérimentale** : `TerrainDebris` en lecture seule du relief, 48 slots préalloués Clay/Sandstone et un MultiMesh fixe. Deux sous-pas à 60 Hz, hauteur courante sous le morceau, support orienté, glissement court puis sommeil/fade. Gravité 0,65 ; restitution Clay/Stone 0,12/0,22 ; friction 14/9 s⁻¹. Blower impulse/lift 1,8/1,1 par seconde, poids/rayon/falloff existants ; signal de souffle distinct pour réveiller aussi sur terrain propre. Aucun changement de saleté, gameplay, Bone ou outils. Éjection unique via hook existant avec amount=0 (feedback sans quantité persistante). F3 choisit ON/OFF pour les nouveaux éclats, ON au lancement ; R vide les fragments et conserve le mode ; F1 expose les compteurs/coûts. OFF conserve les trajectoires et durées P4-V1. Aucun RigidBody, collider dynamique ou nœud par morceau. La poussière qui atténue les arêtes reste un watchpoint P6/P7.

**Base V1.1 conservée** : un seul profil statique en UV (`BlockVerticalityProfile`), Clay redistribuée par nappe/gradient et deux lobes doux, sans masque Bone. Soil et plafonds Bone V1 exacts (55,35–85,34 mm). Silhouette/IDs/totaux P4 exacts. Budgets Sandstone sur tout le fossile : P95 ≤18–20 mm, maximum ≤22 mm. Oracle relatif F1/tests : Clay au-dessus de Bone ×3 + Sandstone ×5,333… ; aucune prédiction de temps. **Verticality / generation must be effort-aware, not depth-only.** A `(250,230)` Skull, B `(510,307)` Spine, C `(646,441)` Hind Limb à 1024×640. Aucune seed/procgen ni retuning outil.

**V1.2 validée** : interfaces visuelles et matériau du curseur interpolés sur les mêmes triangles que le relief ; delta hauteur/limite calculé aux sommets, tolérance numérique normalisée `1e-6` (0,102 µm). Cartes géologiques et retrait par cellule inchangés. Valeur des faces renforcée sur les parois dures, éclats et miettes avec meshes statiques. Retour humain : grille orange absente, blocs/profondeur mieux lisibles, agrément préservé. Ces acquis restent verrouillés dans V2.

Référence P4 : Chisel spectacle A (`42ec46d`) avec éclats transitoires 3–6 mm, 1–5 par plaque cassée, pools bornés, expiration 0,51–0,69 s **en OFF** ; ON utilise le cycle V2 ci-dessus. Blower B (`c25b44f`) conserve ses miettes dures visibles et son vol directionnel hors du bloc. Quantité persistante récente conservée : deux miettes par zone 24×24, rétention 8 %, capacité 0,02. Mécaniques Soil et Pick préservées. Angle ancien fixe `(0.5, 0, -0.62)`, pointe exacte et corps soulevé localement. **Bone : une protection par composant (Skull / Spine / Ribs / Hind Limb), quatre maximum pour B-17 par reset ; Bone Condition globale.** Premier Chisel direct sur un centre du composant DÉJÀ EXPOSÉ AVANT le coup = petit tik, zéro dégât, protection de ce composant consommée ; suivants sur ce même composant = DING/−3. Toutes les côtes partagent RIBS, toutes les vertèbres SPINE. Révélation même centrale et Pick/Brush/Blower ne consomment rien. `direct_contact_consumed` est un tableau indexé par Component, NONE inutilisé ; reset réarme les quatre, F1 affiche READY/USED. Baseline P4 réévaluable en P7. Exposure inchangée. Proxies statiques Tip/Body, au plus douze sondes terrain, aucune reconstruction de mesh en jeu.

Baselines ressources humaines (rayon / puissance / falloff) : **Brush 40 / 0.70 / 1.25 ; Chisel 22 / 0.64 / 2.25 ; Blower 60 / 0 / 1.00 ; Pick 7 / 0.24 / 1.50**. Blower `residue_clear = 2.5`. **P4 human-validated baseline — tuning final deferred to P7.** Cadences, efficacités, génération de résidus, dégâts, résistances et seuils de fracture préservés.

Grammaire joueur : **matière attachée / saleté**. Soil → Brush ; matrice dure → Chisel ; détails près de Bone → Pick ; mess → Brush/Blower. **Dust may obscure detail, never material identity** : Bone garde son ivoire et sa réponse lumineuse. Dust par matériau local, sans nouvelle map ; soulèvement directionnel conservé. **[4] Precision Pick = micro-Chisel** : clic ou maintien immobile, 6 Hz, rayon 7, puissance 0,24, efficacités 0,30/1,00/1,50, interface et plafond osseux respectés, zéro dégât provisoire P4. Sons générés, Brush, proxies, fracture et caméra à préserver ; aucun bonus Brush, marge osseuse ou auto-stop Chisel. RMB pan borné à angle fixe ; Home restaure zoom/pan, R aussi le spécimen. Molette zoom 1–3× ; Shift/Ctrl/Alt puissance/falloff/rayon en debug, F6/F7 en secours. Cap 240 FPS, physique 60 Hz. Tuning final P7 ; la roadmap ne lance pas ses étapes.

## Invariants de conception

- Fouille strictement du dessus / tabletop, sans monde ouvert ni personnage contrôlable.
- Priorité à la sensation de fouille avant le volume de contenu et les systèmes secondaires.
- Musée en galerie horizontale ; squelettes visuellement incomplets tant que des pièces manquent.
- DA non verrouillée avant une comparaison sur le prototype jouable.
- Godot envisagé ; vérifier la version avant de la choisir.
- Nom ArchaeologyGame temporaire et modifiable.

## Documentation et mémoire

Répondre en français et conserver une documentation concise, actionnable, en UTF-8. Distinguer décisions confirmées, propositions et résultats réellement vérifiés. Après un changement durable, actualiser le statut et les décisions du Brain du dépôt, sans dupliquer l’état du projet dans le Brain global. Ne pas stocker de secrets ou importer la mémoire personnelle dans GitHub.
