# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — P4 FINAL FEEL composée, retest humain attendu** sur `prototype/p4-game-feel`, PR #5 en brouillon. Lire en priorité `docs/dev/P4_FINAL_FEEL_TARGET.md` (source de vérité de la composition A/B), puis `docs/dev/P4_REPORT.md` et `docs/dev/P4_MATERIAL_REACTION_DECISION.md`. P0/P1/P2/P3 sont validés et mergés. **Ne pas merger P4, lancer P4-V Verticality / Debris Physics ni commencer P5 sans nouvelle autorisation explicite d’Antoine.**

Composition : Chisel spectacle A (`42ec46d`) avec éclats transitoires 3–6 mm, 1–5 par plaque cassée, pools bornés, expiration 0,51–0,69 s ; Blower B (`c25b44f`) avec miettes dures visibles et vol directionnel hors du bloc. Quantité persistante récente conservée : deux miettes par zone 24×24, rétention 8 %, capacité 0,02. Soil et Pick récents préservés. Angle ancien fixe `(0.5, 0, -0.62)`, pointe exacte et corps soulevé localement. **Audio Bone : petit tik uniquement à la première découverte du spécimen par reset ; gros clack uniquement sur hit Chisel direct avec perte réelle de condition ; autres révélations = son du matériau travaillé.** Exposure et Bone Condition inchangées.

Grammaire joueur : **matière attachée / saleté**. Soil → Brush ; matrice dure → Chisel ; détails près de Bone → Pick ; mess → Brush/Blower. **Dust may obscure detail, never material identity** : Bone garde son ivoire et sa réponse lumineuse. Dust par matériau local, sans nouvelle map ; soulèvement directionnel conservé. **[4] Precision Pick = micro-Chisel** : clic ou maintien immobile, 6 Hz, rayon 3, puissance 0,24, efficacités 0,30/1,00/1,50, interface et plafond osseux respectés, zéro dégât provisoire P4. Fracture, réglages historiques, sons générés, Brush et caméra à préserver ; aucun bonus Brush, marge osseuse ou auto-stop Chisel. RMB pan borné à angle fixe ; Home restaure zoom/pan, R aussi le spécimen. Molette zoom 1–3× ; Shift/Ctrl/Alt puissance/falloff/rayon en debug, F6/F7 en secours. Cap 240 FPS, physique 60 Hz. Tuning final P7 ; la roadmap ne lance pas ses étapes.

## Invariants de conception

- Fouille strictement du dessus / tabletop, sans monde ouvert ni personnage contrôlable.
- Priorité à la sensation de fouille avant le volume de contenu et les systèmes secondaires.
- Musée en galerie horizontale ; squelettes visuellement incomplets tant que des pièces manquent.
- DA non verrouillée avant une comparaison sur le prototype jouable.
- Godot envisagé ; vérifier la version avant de la choisir.
- Nom ArchaeologyGame temporaire et modifiable.

## Documentation et mémoire

Répondre en français et conserver une documentation concise, actionnable, en UTF-8. Distinguer décisions confirmées, propositions et résultats réellement vérifiés. Après un changement durable, actualiser le statut et les décisions du Brain du dépôt, sans dupliquer l’état du projet dans le Brain global. Ne pas stocker de secrets ou importer la mémoire personnelle dans GitHub.
