# Contexte du projet ArchaeologyGame

## Reprise

Lire `docs/brain/BRAIN.md`, `docs/brain/status.md` et les documents utiles à la demande. Le contexte propre à ce dépôt est canonique pour ce projet ; le Brain personnel ne conserve qu’un pointeur.

## Périmètre actuel

Le projet est en **préproduction — zoom P3 implémenté ; retest humain requis, PR #4 non mergée**. P0/P1/P2 sont validés et mergés. `docs/dev/P3_DESIGN_FIXES.md` est la source de vérité de cette passe ; consulter `docs/dev/P3_REPORT.md` et `docs/dev/P3_FOSSIL_DECISION.md` pour les résultats. **Ne pas merger P3 ni commencer P4/P5 sans nouvelle autorisation explicite d’Antoine.** La passe corrective porte seulement sur le zoom. L'évitement des dégâts osseux et l'équilibrage de condition sont différés à P4 ; conserver 100 % n'est pas un critère P3. La validation initiale ne vaut pas validation du zoom. La présence d’une roadmap ne lance pas ses étapes.

## Invariants de conception

- Fouille strictement du dessus / tabletop, sans monde ouvert ni personnage contrôlable.
- Priorité à la sensation de fouille avant le volume de contenu et les systèmes secondaires.
- Musée en galerie horizontale ; squelettes visuellement incomplets tant que des pièces manquent.
- DA non verrouillée avant une comparaison sur le prototype jouable.
- Godot envisagé ; vérifier la version avant de la choisir.
- Nom ArchaeologyGame temporaire et modifiable.

## Documentation et mémoire

Répondre en français et conserver une documentation concise, actionnable, en UTF-8. Distinguer décisions confirmées, propositions et résultats réellement vérifiés. Après un changement durable, actualiser le statut et les décisions du Brain du dépôt, sans dupliquer l’état du projet dans le Brain global. Ne pas stocker de secrets ou importer la mémoire personnelle dans GitHub.
