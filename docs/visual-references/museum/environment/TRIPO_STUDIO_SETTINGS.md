# Tripo Studio — environnement du musée

Fiches recommandées le 17 octobre 2026, à partir des libellés de Studio fournis
par Antoine et de la méthode retenue pour les quatre premiers meubles.
Chaque colonne est une fiche complète. Les réglages réellement utilisés et la
qualité obtenue restent à vérifier dans les exports.

## Réglages avant chaque génération
| Réglage | 01 Niche | 02 Fenêtre | 03 Fougère | 04 Livres | 05 Minéral |
|---|---|---|---|---|---|
| Image | 01-niche-murale.png | 02-fenetre-cintree.png | 03-fougere-en-pot.png | 04-livres-naturaliste.png | 05-echantillon-calcite.png |
| Mode | Modèle HD | Modèle HD | Modèle HD | Modèle HD | Modèle HD |
| AI Modèle | H3.1 – Qualité Optimale | H3.1 – Qualité Optimale | H3.1 – Qualité Optimale | H3.1 – Qualité Optimale | H3.1 – Qualité Optimale |
| Qualité de maillage Ultra | Activée | Activée | Activée | Activée | Activée |
| Complétion IA et amélioration 3D | Désactivée | Désactivée | Désactivée | Désactivée | Désactivée |
| Texture | Activée | Activée | Activée | Activée | Activée |
| Qualité de la texture | 4K | 4K | 4K | 4K | 4K |
| Supprimer l’éclairage | Activé | Activé | Activé | Activé | Activé |
| PBR | Activé | Activé | Activé | Activé | Activé |
| Topologie | Triangle | Triangle | Triangle | Triangle | Triangle |
| Nombre de polygones | **200 000** | **150 000** | **200 000** | **100 000** | **100 000** |
| Générer par parties | Désactivé | Désactivé | Désactivé | Désactivé | Désactivé |
| Texture 8K | Désactivée | Désactivée | Désactivée | Désactivée | Désactivée |
| Générer des multi-vues | Ne pas lancer | Ne pas lancer | Ne pas lancer | Ne pas lancer | Ne pas lancer |
| Export | GLB avec textures | GLB avec textures | GLB avec textures | GLB avec textures | GLB avec textures |

Le seul changement par rapport aux fiches précédentes est le nombre de polygones
selon l’objet. Saisir le nombre indiqué plutôt que de reprendre aveuglément
la dernière valeur conservée par Studio. Une génération par objet suffit pour
l’inspection initiale ; le coût applicable est celui affiché par Studio.

## Premier fichier conseillé : la niche
Entrée : [01-niche-murale.png](01-niche-murale.png).
**200 000**, Ultra activé, H3.1 / Modèle HD, textures 4K, PBR et suppression
de l’éclairage activés, Triangle ; autres options selon la colonne 01.
Export : **museum_wall_niche_v01.glb**.

Contrôler la profondeur de la niche, les deux étagères, le grain du bois,
les bords du module et son dos. Sa taille sera ajustée dans le moteur.
Ne pas multiplier les générations pour les deux côtés de la salle : le premier
module peut être réutilisé après inspection et adaptation.

## Contrôles des autres exports
- **Fenêtre :** six trous réels, aucun panneau opaque ou faux paysage à la place
  du verre. L’encadrement ne doit pas devenir une porte. Export :
  museum_arched_window_v01.glb.
- **Fougère :** feuilles distinctes, branches reliées au pot, dos des frondes
  acceptable ; éviter un gros volume plein entre les feuilles. Export :
  museum_potted_fern_v01.glb.
- **Livres :** trois volumes lisibles, couverture et pages distinctes, aucun texte
  inventé sur les dos. Export : museum_field_books_v01.glb.
- **Minéral :** pointes reliées à une base stable, silhouette sans pointes flottantes,
  pierre sans effet lumineux peint. Export : museum_mineral_sample_v01.glb.

Conserver tous les originaux dans le dossier stable habituel :
C:/Users/antoi/Documents/ArchaeologyGame-Assets/Tripo/museum/

## Sol et enduit
**Ne pas envoyer les images 06 et 07 dans Tripo.** Elles servent à construire
les matières de nos surfaces contrôlées dans Godot ; raccords, UV et relief
seront traités à l’intégration.

Les références actuelles restent à valider dans le jeu. Aucun crédit Studio
ou API n’a été dépensé par l’agent dans cette préparation d’images.
