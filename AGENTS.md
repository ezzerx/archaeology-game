# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — passe corrective P4 livrée, nouveau test humain attendu** sur `prototype/p4-game-feel`, PR #5 en brouillon. Le premier test humain est très positif : Chisel très fun, environ 15 minutes de jeu supplémentaires. Préserver la fracture actuelle. P0/P1/P2/P3 sont validés et mergés. Lire `docs/dev/P4_BRIEF.md`, puis les corrections dans `docs/dev/P4_REPORT.md` et `docs/dev/P4_MATERIAL_REACTION_DECISION.md`. **Ne pas merger P4 ni commencer P5 sans nouvelle autorisation explicite d’Antoine.** P4 distingue Fine Dust et Loose Debris persistants, souffle directionnel, Brush audio continu, découverte osseuse et hit direct. RMB drag = pan borné à angle fixe ; Home restaure zoom/pan, R restaure aussi le spécimen. Aucune marge osseuse ni bonus Brush ; ressources de tuning inchangées, réglage final P7. Molette = zoom 1–3× ; Shift/Ctrl/Alt règlent puissance/falloff/rayon en debug, F6/F7 en secours. Cap 240 FPS, physique 60 Hz. La roadmap ne lance pas ses étapes.

## Invariants de conception

- Fouille strictement du dessus / tabletop, sans monde ouvert ni personnage contrôlable.
- Priorité à la sensation de fouille avant le volume de contenu et les systèmes secondaires.
- Musée en galerie horizontale ; squelettes visuellement incomplets tant que des pièces manquent.
- DA non verrouillée avant une comparaison sur le prototype jouable.
- Godot envisagé ; vérifier la version avant de la choisir.
- Nom ArchaeologyGame temporaire et modifiable.

## Documentation et mémoire

Répondre en français et conserver une documentation concise, actionnable, en UTF-8. Distinguer décisions confirmées, propositions et résultats réellement vérifiés. Après un changement durable, actualiser le statut et les décisions du Brain du dépôt, sans dupliquer l’état du projet dans le Brain global. Ne pas stocker de secrets ou importer la mémoire personnelle dans GitHub.
