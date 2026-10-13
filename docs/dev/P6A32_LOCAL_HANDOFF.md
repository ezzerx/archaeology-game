# Reprise locale — 2026-10-13

Antoine est rentré et reprend avec son agent local. Le travail cloud est poussé
sur `prototype/p6a32-fossil-mesh`, PR #11 DRAFT, empilée sur #10. Cette branche
contient P6A3.1 et le premier pilote du crâne Tripo. `main` contient le merge #9,
pas ces deux candidats. Le workspace cloud est propre.

## Récupérer et lancer

Lire `AGENTS.md`, puis `docs/brain/status.md` et le rapport
`docs/dev/P6A32_TRIPO_SKULL_PILOT_REPORT.md`.
Vérifier les changements locaux avant de changer de branche ; conserver le
travail local existant. Fetch la branche distante et la mettre à jour sans
écraser des commits locaux.

Avec Godot **4.7.2 stable**, lancer `Launch-P6A32-Fossil-Mesh.ps1` (paramètre
`-GodotBin` si nécessaire), ou directement
`res://scenes/p6a32_fossil_mesh.tscn`. Le main_scene du projet reste le prototype
historique : lancer cette scène explicitement pour tester la nouvelle version.

Version portable déjà exportée :
https://archeology-private-playtest.toitou2.chatgpt.site/native.html
Le ZIP n'est pas versionné dans Git ; le code, les assets et les scripts d'export
le sont. Décompresser et conserver l'EXE et le PCK ensemble.

## Ce qu'il faut juger

- F6 : crâne Tripo / os actuels, sans reset, à zoom 1× et 3×.
- Bords pendant la révélation, raccords, flottement, trous et contact des outils.
- Film / Brush / poussière, Condition, puis Archive / Keep Cleaning / reset.
- P6A3.1 : 100 % affichés sous garde-fous, cercle Chisel, fin du nettoyage.
- Lancement Windows et fluidité sur le PC de référence, pas validés dans le cloud.

Le crâne est un pilote visiblement grossier, pas le squelette final. Les autres
os gardent le rendu actuel ; fallback Bone dans les zones non couvertes.
Source GLB Tripo originale, master Blender et profil Studio sont conservés.
Préserver les données Bone, les règles P4/P5 et le picking pendant la revue.
Pas de migration mesh-authored Bone implicite, ni de merge automatique.

Preuves : 142 contrôles fonctionnels, 17 graphiques, 3 de budget logiciel et
10 smoke checks du PCK exporté passent. Matrice intacte : zéro pixel changé
avec le mesh on/off. Ces résultats ne constituent pas une validation humaine.

Captures commentées :
https://archeology-private-playtest.toitou2.chatgpt.site/review.html#crane
Options Tripo : `docs/dev/TRIPO_STUDIO_IMAGE_TO_3D_SETTINGS.md`.
Les sons restent ceux d'avant ; Claude est prévu pour une passe dédiée future.
