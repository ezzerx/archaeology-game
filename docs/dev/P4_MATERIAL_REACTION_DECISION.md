# Décision P4 — Réactions locales de matière

2026-10-02. Source de vérité : [P4_BRIEF](P4_BRIEF.md). P4 uniquement.

## Architecture retenue

Le heightfield RF reste l'autorité géométrique. `MaterialFracture` ajoute une partition angulaire déterministe et un stress local par cellule de fracture et matériau. Un cisaillement et des ondes triangulaires seedées déforment une grille sans laisser de trous. Les cellules d'argile sont plus larges que celles de grès. Chaque impact augmente le stress des seules cellules touchées ; le seuil déclenche un retrait de profondeur discret, sans falloff circulaire sur le morceau détaché.

Les alternatives Voronoi et masques aléatoires par impact demanderaient davantage de calcul ou rendraient les fissures moins persistantes. Aucun voxel, moteur de destruction ou rigid body n'est nécessaire.

Le footprint découpe les morceaux au rayon de l'outil. Chaque texel s'arrête au bas de **sa couche au début de l'impact**, puis au plafond osseux. Aucun surplus ne traverse une autre couche ; un impact puissant peut casser immédiatement. La terre reste retirée continûment. Les petites puissances créent d'abord des marques, puis une rupture.

## État et rendu

Le stress est un dictionnaire sparse, sans travail au repos. Un petit atlas RG8 (argile/grès), dimensionné à la résolution et aux tailles de cellules, transmet les marques au shader. Il n'est uploadé que lorsqu'un impact le modifie. Aucun masque mutable 1024×640 supplémentaire. Le shader emploie la même partition pour dessiner des fissures angulaires ; aucun déplacement visuel supplémentaire ne fausse le picking.

Le noyau historique `apply_segment` reste disponible pour les tests P0–P3 et les fixtures. La scène jouable active explicitement le profil P4 ; les tests P4 couvriront ce chemin. Les événements de matière sont produits après la modification réelle, puis consommés par les proxies, les particules et l'audio. Ceux-ci ne modifient jamais la simulation.

## Condition osseuse

Règle P3 conservée : centre déjà exposé avant l'impact = une pénalité ; premier contact caché protégé. Pas de marge de sécurité, bonus Brush, arrêt automatique ni immunité ajoutés. L'évaluation après implémentation, les limites et les preuves sont consignées dans [P4_REPORT](P4_REPORT.md).

## Paramètres

`config/material_reactions.tres` porte seed, taille des cellules, seuils, profondeur des morceaux, limites des particules, recul et variations audio. Ce sont des valeurs de prototype, pas le tuning final P7.

## Effets sans autorité gameplay

`MaterialFeedback` reçoit les événements validés de `WorkingSurface`. Les trois proxies suivent le hit DDA, sans collider ; leur animation ne déclenche jamais de coup. Quatre MultiMesh bornent les particules à 192. Les éléments sont visuels, s'éteignent rapidement et ne sont pas consultés pour la condition ou les hauteurs. F2 masque ces proxies et débris pour conserver un oracle de surface pur.

`MaterialAudio` synthétise une fois six familles × quatre WAV originaux. Huit voix suffisent ; les actions continues sont limitées à un grain sonore par 95 ms, tandis que le Chisel suit les événements d'impact. Aucun plugin audio ou téléchargement d'asset nécessaire.

API utilisées : [MultiMesh](https://docs.godotengine.org/en/stable/classes/class_multimesh.html) et [AudioStreamWAV](https://docs.godotengine.org/en/stable/classes/class_audiostreamwav.html), documentation officielle Godot ; fonctionnement vérifié dans le binaire 4.7.2 local.
