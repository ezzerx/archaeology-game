# Environnement du musée — références à produire

Le 17 octobre 2026, Antoine apprécie le mobilier Tripo mais rejette encore le sol,
les murs et le décor de fond. Ce pack prépare leur remplacement en gardant les
meubles et les préparations comme références de rendu.
Direction commune : [concept retenu](../02-gallery-stylized.png).
État et autorisation : [statut canonique](../../../brain/status.md).

## Ce qui doit changer dans la scène
Le sol doit ressembler à de grandes dalles de calcaire adoucies, avec des joints
fins et une bordure verte discrète. Les murs doivent avoir un enduit calme,
des reliefs de pierre et des boiseries aux profils arrondis. Les niches ont une
vraie profondeur. Une fenêtre donne une raison à la lumière naturelle ; les
appliques apportent des touches chaudes sans blanchir tout le mur.

Garder le décor en second plan : quelques livres, un échantillon minéral et une
plante suffisent à habiter cette première travée. Ces accessoires ne deviennent
pas de nouvelles pièces acquises par le joueur. B–17 et M–08 restent dominants.

## Images pour Tripo
Une image par génération ; ne pas envoyer une planche réunissant plusieurs objets.

| Image | Usage | Budget source recommandé | Export proposé |
|---|---|---:|---|
| [01 — Niche murale](01-niche-murale.png) | Premier pilote : niche creuse, pierre, deux étagères et soubassement bois | 200 000 | museum_wall_niche_v01.glb |
| [02 — Fenêtre cintrée](02-fenetre-cintree.png) | Encadrement et croisillons ; verre et extérieur ajoutés séparément | 150 000 | museum_arched_window_v01.glb |
| [03 — Fougère en pot](03-fougere-en-pot.png) | Une touche végétale près de la fenêtre | 200 000 | museum_potted_fern_v01.glb |
| [04 — Livres](04-livres-naturaliste.png) | Une pile compacte pour étagère/vitrine | 100 000 | museum_field_books_v01.glb |
| [05 — Échantillon minéral](05-echantillon-calcite.png) | Petit décor géologique de fond, inspiré de la calcite | 100 000 | museum_mineral_sample_v01.glb |

Les budgets privilégient une source détaillée. Ils ne garantissent pas la qualité
et ne constituent pas le budget final du jeu. Les proportions, ouvertures et
surfaces invisibles sur l’image devront être examinées dans le GLB.

Les [réglages complets par objet](TRIPO_STUDIO_SETTINGS.md) sont prêts.
Commencer par la niche : elle permet de juger la nouvelle architecture avant
de multiplier les modules. Les accessoires sont indépendants de son assemblage.

## Matières pour le sol et les murs — sans génération Tripo
- [06 — Calcaire](06-calcaire-matiere.png) : nuances minérales et grain pour les dalles.
- [07 — Enduit](07-enduit-matiere.png) : enduit à la chaux fin et légèrement nuancé.

Ce sont des références de matière et bases couleur candidates. Elles ne sont
pas des matériaux PBR complets ni des textures dont les raccords sont validés.
Elles mesurent réellement 1254 × 1254 pixels. Il faudra contrôler répétition,
échelle, raccords et relief dans le moteur avant de les utiliser en production.

Créer les grandes surfaces et leurs UV avec des dimensions contrôlées. Les joints,
bordures, angles et raccords aux meubles appartiennent à la géométrie de scène.
Reprendre les profils de boiserie du module niche pour les pans droits. Éviter
de demander une salle entière, le sol ou un assemblage de murs à une génération
Tripo unique : ces éléments doivent s’adapter précisément à notre caméra.

## Revue des images
- Niche : profondeur et profils lisibles, deux étagères plus un appui bas, socle
  bois cohérent avec la vitrine ; le cadre est intégré à un seul module.
- Fenêtre : première version rejetée car les ouvertures ressemblaient à des
  panneaux pleins. La version retenue montre six ouvertures sur fond gris.
  Vérifier dans Studio puis dans le GLB que ces espaces sont réellement vides.
- Plante : folioles volontairement larges, plusieurs frondes distinctes ; surveiller
  la fusion des feuilles au centre et les faces arrière dans le résultat 3D.
- Livres : trois volumes distingués, aucun titre inventé à supprimer.
- Minéral : silhouette compacte et variations ivoire/miel ; accessoire décoratif,
  pas une référence scientifique de cristallographie.

Les références d’objets sont isolées. La niche contient un canal alpha ; les
autres images sélectionnées ont un fond gris opaque. Contrôler le détourage
proposé par Studio, en particulier les trous de la fenêtre et les feuilles.

## Ordre d’intégration proposé
1. Niche pilote et module droit assorti ; proportions et joints des murs.
2. Sol/enduit, lumière naturelle, ombres et contraste avec les meubles existants.
3. Fenêtre et quelques accessoires, avec silhouettes dégagées autour des blocs.
4. Captures natives ensemble/inspection et revue humaine.

Cette passe produit les références, pas leur intégration. La scène jouable n’a
pas été modifiée et aucun appel payant Tripo n’a été lancé.

## Fichiers et provenance
Images générées avec **Imagegen intégré**, puis revues ; une correction de fenêtre.
[Prompts exacts](prompts.json) · [dimensions et empreintes](manifest.json).

Copie pratique du pack :
C:/Users/antoi/Documents/ArchaeologyGame-Assets/Tripo/museum/references-environnement/

Déposer les nouveaux GLB dans :
C:/Users/antoi/Documents/ArchaeologyGame-Assets/Tripo/museum/

Les originaux seront conservés avant retouche ou optimisation.
