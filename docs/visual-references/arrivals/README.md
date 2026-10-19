# Arrivages — pack de production Tripo

La [planche de scène](00-arrivals-approved.png) est validée par Antoine le
19 octobre 2026 pour la version test de #27. Les références ci-dessous sont
des déclinaisons pour la production, pas des captures du jeu.

| Ordre | Image à importer seule | Export demandé | Contrôle avant export |
|---|---|---|---|
| 1 | [Corps de caisse](01-crate-body.png) | `arrivals_crate_body_v01.glb` | Intérieur réellement creux, fond fermé, quatre parois, aucune pièce flottante ni couvercle inventé |
| 2 | [Couvercle](02-crate-lid.png) | `arrivals_crate_lid_v01.glb` | Plaque mince et solide, dessous fermé, aucune seconde caisse |
| 3 | [Comptoir](03-reception-counter.png) | `arrivals_counter_v01.glb` | Plateau plat et vide, pieds reliés, dos et dessous cohérents |

Commencer par le corps et examiner son intérieur dans Studio avant de produire
la suite. Chaque objet fait l'objet d'une génération séparée. Ne pas envoyer
la planche de scène entière, ni combiner ces trois objets comme des multi-vues.

## Réglages recommandés avant chaque génération

Libellés repris des captures Studio déjà fournies par Antoine. Vérifier chaque
colonne au lieu de supposer que Studio conserve le bon budget. Les paramètres
réellement choisis et le résultat restent à confirmer dans les exports.

| Réglage | 01 Corps | 02 Couvercle | 03 Comptoir |
|---|---|---|---|
| Mode | Modèle HD | Modèle HD | Modèle HD |
| AI Modèle | H3.1 – Qualité Optimale | H3.1 – Qualité Optimale | H3.1 – Qualité Optimale |
| Qualité de maillage Ultra | Activée | Activée | Activée |
| Complétion IA et amélioration 3D | Désactivée | Désactivée | Désactivée |
| Texture | Activée | Activée | Activée |
| Qualité de la texture | 4K | 4K | 4K |
| Supprimer l'éclairage | Activé | Activé | Activé |
| PBR | Activé | Activé | Activé |
| Topologie | Triangle | Triangle | Triangle |
| Nombre de polygones | **100 000** | **50 000** | **150 000** |
| Générer par parties | Désactivé | Désactivé | Désactivé |
| Texture 8K | Désactivée | Désactivée | Désactivée |
| Générer des multi-vues | Ne pas lancer | Ne pas lancer | Ne pas lancer |
| Export | GLB avec textures | GLB avec textures | GLB avec textures |

Une génération par objet pour l'inspection initiale. Le coût applicable est
celui affiché dans Studio ; les prix et crédits API ne décrivent pas l'abonnement
Studio. Aucun crédit Tripo n'a été dépensé par l'agent pour ce pack d'images.

Différences entre objets : seul le nombre de polygones change. Le corps réserve
du détail aux arêtes, renforts et poignée ; le couvercle simple demande moins de
géométrie ; le comptoir est un grand meuble avec panneaux et moulures.
Ces budgets visent des sources détaillées et ne sont pas des budgets runtime
ni des mesures de qualité. L'optimisation sera réalisée sur copie après revue.

## Contraintes d'assemblage

- Corps et couvercle sont volontairement séparés. Garder **Générer par parties
  désactivé** : chaque référence représente déjà une seule pièce utile.
- Gabarits indicatifs : corps 90 × 62 × 27 cm, couvercle 91 × 63 × 4 cm ; comptoir
  240 × 100 × 85 cm. Ajuster autour des vrais blocs ; ne pas présumer que Tripo
  reproduit les dimensions, l'épaisseur ou la correspondance des deux pièces.
- La caisse générée n'a ni loquet ni charnière animable. Ils seront fabriqués
  séparément dans Blender pour conserver des pivots et dégagements précis.
- Les étiquettes seront composées dans Godot : refuser le texte ou les logos
  inventés. Les calages et le vrai bloc sont ajoutés après l'import.
- Examiner les faces cachées et supprimer le socle/fond gris si le générateur
  l'a transformé en géométrie. Contrôler normales, UV et ombres peintes.
- Conserver les GLB originaux. Depuis le travail, joindre les exports au chat ;
  un fichier présent uniquement sur le PC personnel n'est pas accessible ici.

## Réutiliser avant de générer

Fenêtre, appliques, livres, fougère et vitrine existent déjà dans le dépôt.
Architecture, lumière, étiquettes et mécanique seront assemblées localement.
Le présent pack couvre les trois nouveaux assets principaux ; une éventuelle
nouvelle référence sera préparée si l'adaptation du pilote n'est pas satisfaisante.

## Provenance

Images générées avec Imagegen à partir de la planche retenue. Les images ne
constituent pas encore des assets 3D ni une validation du rendu natif.
Source, date et empreintes : [provenance.json](provenance.json).
