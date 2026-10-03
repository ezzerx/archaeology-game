# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — simplification finale P4 livrée, retest humain attendu** sur `prototype/p4-game-feel`, PR #5 en brouillon. Chisel/fracture, profondeur, condition plus juste, sons osseux, Brush audio, zoom/pan/picking sont validés humainement : préserver ces acquis et les réglages des trois outils historiques. P0/P1/P2/P3 sont validés et mergés. Lire `docs/dev/P4_BRIEF.md`, puis `docs/dev/P4_REPORT.md` et `docs/dev/P4_MATERIAL_REACTION_DECISION.md`. **Ne pas merger P4 ni commencer P5 sans nouvelle autorisation explicite d’Antoine.** Grammaire joueur : **matière attachée / saleté**. Soil → Brush ; matrice dure → Chisel ; détails près de Bone → Pick ; mess → Brush/Blower. Règle verrouillée : **Dust may obscure detail, never material identity** ; Bone garde son ivoire et sa réponse lumineuse. Dust par matériau local, sans nouvelle map ; soulèvement directionnel conservé. Proxies à orientation fixe, pointe au hit, corps soulevé localement ; éclats petits, rares, éjectés hors du centre. **[4] Precision Pick = micro-Chisel** : clic ou maintien immobile, 6 Hz, rayon 3, puissance 0,24, efficacités 0,30/1,00/1,50, interface et plafond osseux respectés, zéro dégât provisoire P4. Aucun bonus Brush, marge osseuse ou auto-stop Chisel. RMB pan borné à angle fixe ; Home restaure zoom/pan, R aussi le spécimen. Molette zoom 1–3× ; Shift/Ctrl/Alt puissance/falloff/rayon en debug, F6/F7 en secours. Cap 240 FPS, physique 60 Hz. Tuning final P7 ; la roadmap ne lance pas ses étapes.

## Invariants de conception

- Fouille strictement du dessus / tabletop, sans monde ouvert ni personnage contrôlable.
- Priorité à la sensation de fouille avant le volume de contenu et les systèmes secondaires.
- Musée en galerie horizontale ; squelettes visuellement incomplets tant que des pièces manquent.
- DA non verrouillée avant une comparaison sur le prototype jouable.
- Godot envisagé ; vérifier la version avant de la choisir.
- Nom ArchaeologyGame temporaire et modifiable.

## Documentation et mémoire

Répondre en français et conserver une documentation concise, actionnable, en UTF-8. Distinguer décisions confirmées, propositions et résultats réellement vérifiés. Après un changement durable, actualiser le statut et les décisions du Brain du dépôt, sans dupliquer l’état du projet dans le Brain global. Ne pas stocker de secrets ou importer la mémoire personnelle dans GitHub.
