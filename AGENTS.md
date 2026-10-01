# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — P4 implémenté, en attente du test humain** sur `prototype/p4-game-feel`. P0/P1/P2/P3 sont validés et mergés. `docs/dev/P4_BRIEF.md` est la source de vérité ; consulter `docs/dev/P4_REPORT.md` et `docs/dev/P4_MATERIAL_REACTION_DECISION.md`. **Ne pas merger P4 ni commencer P5 sans nouvelle autorisation explicite d’Antoine.** P4 ajoute la fracture locale, les outils visibles, les débris et l'audio placeholder. Aucune marge de sécurité osseuse ni bonus Brush près des os n'est ajouté. La sonde automatique de condition ne vaut pas validation humaine de l'équité. Molette = zoom 1–3× ; Shift/Ctrl/Alt + molette règlent puissance/falloff/rayon en debug. Cap 240 FPS, physique 60 Hz. La présence d’une roadmap ne lance pas ses étapes.

## Invariants de conception

- Fouille strictement du dessus / tabletop, sans monde ouvert ni personnage contrôlable.
- Priorité à la sensation de fouille avant le volume de contenu et les systèmes secondaires.
- Musée en galerie horizontale ; squelettes visuellement incomplets tant que des pièces manquent.
- DA non verrouillée avant une comparaison sur le prototype jouable.
- Godot envisagé ; vérifier la version avant de la choisir.
- Nom ArchaeologyGame temporaire et modifiable.

## Documentation et mémoire

Répondre en français et conserver une documentation concise, actionnable, en UTF-8. Distinguer décisions confirmées, propositions et résultats réellement vérifiés. Après un changement durable, actualiser le statut et les décisions du Brain du dépôt, sans dupliquer l’état du projet dans le Brain global. Ne pas stocker de secrets ou importer la mémoire personnelle dans GitHub.
