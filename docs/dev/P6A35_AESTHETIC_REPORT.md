# P6A3.5 — Ivoire et relief : candidat esthétique

Livraison locale du 2026-10-14 après GO explicite d’Antoine. Sept pièces du pilote
précédent retravaillées ; la qualité esthétique reste à juger humainement.

## Lancer et comparer

`Launch-P6A35-Aesthetic-Pilot.ps1`, Godot 4.7.2 stable. Le démarrage reste recouvert.

- **H** : panneau de revue ; « Zone pilote dégagée, os sales · réinitialise »
  prépare la coupe contrôlée du crâne et des côtes avec du vrai Film à nettoyer.
  Ce bouton réinitialise la préparation ; ce n’est pas une session enregistrée.
- Dans ce panneau, **Ombres des os dégagés : actives / désactivées** compare
  uniquement leur projection, sans reset ni modification de préparation.
- **F5** : inspection du même asset propre, hors matrice ; glisser pour tourner,
  molette pour rapprocher. Échap / F5 ferme l’inspection.
- **F6** : mesh / relief du même champ dérivé, sans reset. Ce témoin reprend
  l’emprise de la nouvelle anatomie ; ce n’est pas l’ancien B-17 exact.
- **F7** : profil tactile / historique, comparatif existant conservé.

Référence P6A3.4 conservée avec son propre lanceur. Ancien Bone complet exact :
`Launch-P6A33-Tactile-Preparation.ps1`. Pas de migration générale du projet.

## Modèle et matière

Master Blender local paramétrique versionné, sans nouvelle génération distante :
`art/source/p6a35/b17-production-patch.blend` et
`tools/p6a35/build_production_patch.py`.

Crâne : arcade plus épaisse et transitions continues, rebord orbital modelé,
mandibule évasée à l’arrière, six petites dents effilées, petit foramen nasal
réellement percé. Côtes : tête articulaire élargie, col plus fin, lame légèrement
bombée et extrémité amincie. Les raccords passent sous les vertèbres conservées.

La famille d’albedo ivoire chaude P6A2 est conservée. L’occlusion courte portée
est calculée depuis les vraies surfaces Blender et exportée en couleurs de
sommets ; elle nuance les creux sans fissures décoratives qui imiteraient des
dégâts. Roughness et spéculaire sont légèrement ajustés. L’inspection hors
matrice dispose aussi d’ombres propres dans son monde 3D isolé.

Sept pièces fermées, **28 798 triangles** ; GLB 831 084 octets.
Asset : `assets/p6a35/b17_production_patch.glb`.
SHA-256 : `5cbd3edf6ec45e23c2aed308eef3bf68c34aa8ce6fad4df401bb23b717f427b1`.
Manifeste et champ : `production-manifest.json` et `mesh_patch_data.res` dans
le même dossier. Import sans LOD automatique ni compression de positions, pour
conserver l’accord entre triangles affichés et plafonds de fouille.
Reconstruction complète vérifiée avec `tools/p6a35/Build-Aesthetic-Pilot.ps1 -Graphical`.
Le helper s’arrête sur une erreur Blender, import, packing ou test.

## Ombres sans spoiler

Le modèle complet affiché garde **cast shadow désactivé**. Un second maillage,
uniquement soumis à la passe d’ombres, contient deux triangles par cellule Bone
du pilote réellement exposée, avec la même règle de plafond que la fouille.
Aucun triangle n’est soumis pour une cellule enterrée ou une autre région.

Chaque petit toit est situé 0,35 mm sous son plafond pour limiter l’auto-ombrage.
Les coordonnées immuables sont préparées au chargement ; seuls les indices des
cellules dégagées sont reconstruits après un changement d’exposition. Les
sommets non référencés ne produisent aucun triangle. Aucun travail répété au
repos. Le reset efface le caster immédiatement, avant le prochain rendu.
F6 / F7 / debug masquent également cette projection avec le mesh.

Cette projection reste une approximation sur la grille de fouille, pas une
copie des sous-faces complexes du modèle. Elle restaure l’ancrage visuel sans
activer l’ombre de sa silhouette complète. À 3×, certains bords de grille restent
visibles ; aucune refonte géologique n’a été faite.

## Vérifications et preuves

Godot 4.7.2 officiel, renderer Compatibility, RTX 5080. **284 contrôles, zéro
échec** : P5 128, tactile P6A3.3 40, P6A3.4 fonctionnel 26 et graphique 21,
P6A3.5 fonctionnel 38 et graphique 31. Détails JSON et captures natives dans
`docs/dev/evidence/p6a35/` ; registre de collection QA isolé sous `work/`.

- Projection indépendante des tableaux de rendu sur les **11 403 cellules**
  du modèle : zéro manque ; erreur maximale de plafond environ **0,540 µm**.
  11 285 cellules gagnantes du pilote ; 118 occlusions par vertèbres conservées.
  Aucun ancien crâne ou ancienne côte de secours dans les pièces remplacées.
- **185 rayons caméra réels**, écart maximal contact/picking environ **0,262 mm**,
  inférieur à la tolérance de grille. Régions anatomiques hors pilote inchangées.
- Matrice intacte : **tout le viewport pixel-identique** ombres on/off et mesh/relief.
  Révélation partielle : caster contrôlé indépendamment, aucun indice vers une
  cellule enterrée ; projection visible avant révélation du reste du crâne.
- Comparatif propre à 3× : **19 489 pixels** assombris de plus de 0,025 en
  luminance par les ombres, zéro éclairci au-delà de ce seuil. L’état complet
  reste identique pendant ces comparaisons.
- Vrais F5/F6/F7, bouton d’ombres, inspection, premier contact protégé,
  dégâts localisés, courts allers-retours Brush, archive/distinction et reset
  passent. Brush et dégâts P6A3.3 validés humainement ne sont pas retunés.
- Pilote précédent : ses 47 contrôles passent. Captures de référence : écarts
  résiduels infimes sur certains gros plans (au plus un pixel >0,03 de somme RGB
  dans les vues crâne contrôlées), détails dans `previous-pilot-pixel-deltas.json`.
  Les captures anciennes restent des preuves historiques.

Budget à 1×, coupe de revue : 73 → 76 draw calls ; +28 798 triangles visibles et
+22 570 triangles d’ombres, soit +51 368 primitives. Textures résidentes observées
177 520 462 octets dans les deux états. Médiane de 20 intervalles 4,165 ms off/on
au cap 240 FPS ; fréquence physique 60 Hz. Reconstruction complète du caster
mesurée à 3,064 ms dans cette capture, aucune reconstruction au repos. Mesures
courtes, pas une preuve de fluidité d’une session entière.

## Limites et retest humain

Le crâne reste une interprétation stylisée et aplatie du B-17 de préparation,
pas une anatomie scientifique complète à 360°. Les pièces hors matrice permettent
une revue de volume ; elles ne valident pas encore le futur catalogue ou un
squelette monté. La nouvelle emprise peut modifier localement le temps de
révélation, sans changer les règles ou presets d’outils.

À juger : ancrage des os dans la terre, ombres sous mâchoire/dans l’orbite,
volume et lisibilité des côtes à 1× / 3×, ivoire et rendu sale/propre. Vérifier
également que la découverte reste intacte en fouillant normalement. Brush et
dégâts sont déjà acceptés, leur nouveau retuning n’est pas demandé. La gate
et la prochaine action autorisée sont exclusivement dans `docs/brain/status.md`.


## Retour humain du 2026-10-14

Antoine : « ça passe mieux avec les ombres ». Amélioration de l’ancrage accueillie
positivement. Il demande si ce candidat représente la qualité artistique finale ;
ce retour ne vaut pas approbation finale du modèle ou de toute la phase.

Évaluation de l’agent : le crâne conserve une construction paramétrique trop
tubulaire et une anatomie trop simplifiée pour servir de référence artistique
finale. La passe a amélioré ombres, volume et matière du prototype ; le prochain
cap de qualité demande un travail de forme plus profond, pas seulement davantage
de textures. Cette évaluation est une recommandation, pas un nouveau GO humain.
