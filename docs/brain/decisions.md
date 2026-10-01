# Décisions initiales

Source : décisions confirmées par Antoine au 2026-09-30 et au 2026-10-01.

| Décision | Raison / conséquence |
|---|---|
| Canoniser avant de développer | Conserver une référence claire et portable |
| ArchaeologyGame comme working title neutre | Ne pas figer le nom commercial |
| Dépôt GitHub privé | Conserver la conception dans le compte d’Antoine |
| Tabletop fixe, sans personnage ni monde ouvert | Concentrer l’expérience sur la fouille |
| Game feel prioritaire | Tester le geste avant le volume de contenu |
| Musée horizontal avec squelettes incomplets | Méta-progression tangible |
| Prototype v0.1 focalisé | Un écran, un bloc, un fossile, trois outils |
| **DA v0.1 : 2.5D stylisée, tabletop, orthographique presque verticale** | Prioriser relief et révélation libre |
| Pixel art non retenu pour le prototype | Éviter les contraintes de grille sur la fouille |
| Références | Assemble with Care, A Little to the Left, Potion Craft, Strange Horticulture — inspiration seulement |
| Specimen B-17 | Petit théropode fictif / indéterminé |
| Outils v0.1 | Soft Brush, Chisel, Air Blower |
| Matières cœur | Loose Soil, Compact Clay, Sandstone |
| Poussière / résidu | Le vrai game feel poussière est P4 ; P2 peut utiliser un état minimal debug-only si nécessaire au Blower |
| Premier contact os protégé | P3 : signaler sans pénaliser |
| Bone Condition sans Game Over | Tension légère |
| Deux fragments récupérables | Collection visible |
| Keep Cleaning | KPI comportemental central |
| Godot 4.7.2 stable Standard | Stack prototype validée localement |
| Brain canonique dans le dépôt | Reprise portable |

## Spécification de référence

[PROTOTYPE_V0_1_SPEC.md](../PROTOTYPE_V0_1_SPEC.md) prévaut pour le produit.

## Verdict P0

**Validé par Antoine le 2026-10-01.**  
PR #1 mergée : `244aba3652a03aac908b1aabe1651c3b9edb1315`.

## Décisions techniques P1

| Décision | Raison / limite |
|---|---|
| Grille dense GPU + height RF 1024×640 | Cavités précises sans reconstruction mesh par geste |
| Picking DDA sur triangles identiques au rendu | Alignement souris/relief exact |
| Tolérance relative ray/triangle | Adaptée aux triangles millimétriques |
| Deux frontières statiques ondulées | Bloc test déterministe sans génération procédurale |
| Retrait intégré par couche | Ne pas sauter une couche résistante |
| Base sans cap supérieur doublé | Évite le z-fighting au fond |
| PackedFloat32Array + Image staging | Hot loop plus efficace |
| Hard Rock omis | Non nécessaire à la preuve P1 |

### Verdict P1

**Validé par Antoine le 2026-10-01 : « j'ai testé tout fonctionne ».**

PR #2 mergée vers `main` :
`960642c3fc6972bdb257c96abd43b90c148e632d`.

P2 est autorisé.

## Review technique après P1

Architecture jugée solide pour le prototype.

Watchpoints :

- 1,31 M triangles : précision excellente, coût production à réévaluer plus tard ;
- upload RF complet : ne pas multiplier les maps sans mesure ;
- stress coin-à-coin hors budget : non bloquant pour usage naturel ;
- collider physique approximatif : acceptable tant que seuls les outils utilisent le picking exact ;
- résistances 1/3/8 : ne pas les considérer comme tuning final.

## Décision de scope P2

P2 doit construire les **outils**, pas le fossile ni le polish complet.

- Soft Brush : interaction continue, large et douce, très efficace sur Loose Soil, presque inefficace sur Clay, inefficace sur Sandstone.
- Chisel : impacts discrets cadencés, efficace sur Clay, utile sur Sandstone, non destiné au nettoyage fin.
- Air Blower : ne retire pratiquement pas de matière structurelle.

Pour rendre le Blower testable sans empiéter sur P4, P2 peut créer un **résidu scalaire minimal / debug-only** généré par certaines excavations et supprimé par le Blower. Ce résidu n'est pas le système final de poussière : pas de particules, audio, turbulence ni art pass.

P3 (fossile) reste interdit jusqu'à validation humaine de P2.

## Points encore ouverts

- tuning final des outils ;
- coût des très grandes empreintes après ajout des trois modes ;
- stratégie d'upload si un état de résidu runtime est ajouté ;
- assets, sons et FX de production ;
- tuning du fossile et du musée plus tard.
