# Tripo Studio — profils Image → 3D

UI observée sur la capture fournie par Antoine le 2026-10-13. L'abonnement
Tripo Max Studio et ses coûts ne sont pas ceux de l'API. Les libellés ci-dessous
sont ceux de Studio ; ne pas les traduire en paramètres CLI sans vérification.

## Profil B-17 — squelette fossile partiel, source pour Blender

| Option Studio | Réglage conseillé | But |
|---|---|---|
| Mode | Modèle HD | Source détaillée pour le pilote |
| AI Modèle | H3.1 – Qualité Optimale | Priorité au détail géométrique |
| Qualité de maillage Ultra | Activée | Préserver os fins et cavités |
| Complétion IA et amélioration 3D | Désactivée | Limiter les ajouts au spécimen partiel |
| Texture | Activée | Conserver une source texturée inspectable |
| Texture Quality | 4K, si disponible après désactivation de l'option 8K | Source utile sans texture 8K ; 2K convient si 4K reste inaccessible |
| Texture 8K | Désactivée | Inutile pour ce premier pilote ; conserver l'essai pour un besoin réel |
| Supprimer l'éclairage | Activé | Limiter ombres et lumière déjà peintes dans l'albedo |
| PBR | Activé | Base de matériaux pour Blender/Godot |
| Topologie | Triangle | Prop statique, réduction ultérieure dans Blender |
| Nombre de polygones | 200 000 | Budget source, pas budget runtime Godot |
| Générer par parties | Désactivé | Inspecter la génération complète avant séparation manuelle |
| Générer des multi-vues | Ne pas lancer pour le premier essai | Garder la pose de la référence sans ajouter des vues inventées |
| Confidentialité | Privé si proposé | Le libellé observé « Partage uniquement » ne prouve pas un accès owner-only |
| Export | GLB avec textures ; ZIP si plusieurs fichiers | Remettre l'original pour inspection et travail Blender |

Sur la capture, 8K est activé (« Essai ×1 »), le nombre de polygones est
2 000 000 et le bouton de génération affiche 65 barré puis 0. Ce sont les
valeurs observées avant les changements conseillés, pas un devis confirmé
pour le profil ci-dessus. Antoine effectue la génération dans son Studio ;
l'agent n'a pas lancé ni payé de génération.

## Ajuster les prochaines itérations

Ce profil est spécifique aux os fins et au fossile partiel. Ne pas réutiliser
automatiquement 200k/Ultra/4K pour chaque prop. Avant chaque génération :
identifier l'usage, le cadrage en jeu, les détails géométriques critiques,
la pose à conserver, puis proposer le profil adapté et l'export attendu.
Séparer explicitement budget source Tripo et budget runtime Blender/Godot.

- Côtes fusionnées, dents absentes, orbite bouchée : inspecter la géométrie,
  corriger la référence ou le mesh ; une texture 8K ne répare pas ces défauts.
- Pose différente, membres ajoutés : conserver Complétion IA désactivée,
  reprendre une référence plus ciblée ; ne pas changer l'autorité Bone du jeu
  pour faire rentrer un résultat arbitraire.
- Fond/plaque généré : nettoyer dans Blender si les os sont récupérables,
  sinon isoler davantage la référence. Ne pas conserver une plaque dans l'asset.
- Texture trop marquée par l'éclairage : garder Supprimer l'éclairage activé,
  inspecter l'albedo sous un éclairage neutre avant intégration.
- Os perdus après optimisation : garder le GLB source intact et réduire moins
  agressivement la partie concernée dans Blender.

Le modèle actuel de préparation est un probe technique calculé depuis le champ
B-17 natif ; il n'est pas le résultat de ces réglages Studio. Aucun réglage
ci-dessus ne garantit à lui seul la fidélité anatomique ou le bon masquage en jeu.
