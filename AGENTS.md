# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — P4 Final Feel validé humainement et mergé**, baseline `7ae0fec3c004d207c99f4713111a240f8d5f2e9a`. **Base verticale V1.1 jugée meilleure par Antoine ; micro-passe P4-V1.2 Visual Cleanup** sur `prototype/p4v-verticality`, PR #6 en brouillon. Lire d’abord `docs/dev/P4V_BRIEF.md` (section V1.2 prioritaire), `docs/dev/P4V_REPORT.md` et le statut du Brain. Les acquis P4 restent définis par `docs/dev/P4_FINAL_FEEL_TARGET.md`, `docs/dev/P4_REPORT.md` et `docs/dev/P4_MATERIAL_REACTION_DECISION.md`. **Ne pas merger la PR #6, lancer P4-V2 Debris Physics ou commencer P5 sans nouvelle autorisation explicite d’Antoine.**

**Base V1.1 conservée** : un seul profil statique en UV (`BlockVerticalityProfile`), Clay redistribuée par nappe/gradient et deux lobes doux, sans masque Bone. Soil et plafonds Bone V1 exacts (55,35–85,34 mm). Silhouette/IDs/totaux P4 exacts. Budgets Sandstone sur tout le fossile : P95 ≤18–20 mm, maximum ≤22 mm. Oracle relatif F1/tests : Clay au-dessus de Bone ×3 + Sandstone ×5,333… ; aucune prédiction de temps. **Verticality / generation must be effort-aware, not depth-only.** A `(250,230)` Skull, B `(510,307)` Spine, C `(646,441)` Hind Limb à 1024×640. Aucune seed/procgen, aucune physique de débris ; aucun retuning outil.

**V1.2** : interfaces visuelles et matériau du curseur interpolés sur les mêmes triangles que le relief ; delta hauteur/limite calculé aux sommets, tolérance numérique normalisée `1e-6` (0,102 µm). Cartes géologiques et retrait par cellule inchangés. Valeur des faces renforcée sur les parois dures, éclats et miettes avec meshes statiques ; silhouettes, trajectoires, quantités et durées conservées. Trois questions humaines du rapport : grille orange absente, blocs/profondeur mieux lisibles, agrément préservé. **STOP après livraison pour ce test.**

Composition : Chisel spectacle A (`42ec46d`) avec éclats transitoires 3–6 mm, 1–5 par plaque cassée, pools bornés, expiration 0,51–0,69 s ; Blower B (`c25b44f`) avec miettes dures visibles et vol directionnel hors du bloc. Quantité persistante récente conservée : deux miettes par zone 24×24, rétention 8 %, capacité 0,02. Mécaniques Soil et Pick préservées. Angle ancien fixe `(0.5, 0, -0.62)`, pointe exacte et corps soulevé localement. **Bone : une protection par composant (Skull / Spine / Ribs / Hind Limb), quatre maximum pour B-17 par reset ; Bone Condition globale.** Premier Chisel direct sur un centre du composant DÉJÀ EXPOSÉ AVANT le coup = petit tik, zéro dégât, protection de ce composant consommée ; suivants sur ce même composant = DING/−3. Toutes les côtes partagent RIBS, toutes les vertèbres SPINE. Révélation même centrale et Pick/Brush/Blower ne consomment rien. `direct_contact_consumed` est un tableau indexé par Component, NONE inutilisé ; reset réarme les quatre, F1 affiche READY/USED. Baseline P4 réévaluable en P7. Exposure inchangée. Proxies statiques Tip/Body, au plus douze sondes terrain, aucune reconstruction de mesh en jeu.

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
