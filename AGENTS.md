# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — micro-fix P4 FINAL FEEL par composant, prêt pour décision de fermeture** sur `prototype/p4-game-feel`, PR #5 en brouillon. Lire en priorité `docs/dev/P4_FINAL_FEEL_TARGET.md` (source de vérité de la composition A/B et de la protection par composant), puis `docs/dev/P4_REPORT.md` et `docs/dev/P4_MATERIAL_REACTION_DECISION.md`. P0/P1/P2/P3 sont validés et mergés. **Ne pas merger P4, lancer P4-V Verticality / Debris Physics ni commencer P5 sans nouvelle autorisation explicite d’Antoine.**

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
