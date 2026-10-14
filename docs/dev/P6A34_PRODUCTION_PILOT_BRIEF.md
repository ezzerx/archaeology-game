# P6A3.4 — Essai de production 3D soigné

GO explicite Antoine, 2026-10-14, après discussion du pipeline de production.

Livrer un crâne et trois paires de côtes en vrais meshes fermés, stylisés dans
la famille ivoire chaude du squelette préféré. Fabrication paramétrique locale
Blender, masters et générateur conservés. Aucun appel payant Tripo nécessaire.

Le modèle définit son emprise et son plafond Bone pour la zone bornée du pilote.
Remplacer complètement le Skull et les trois paires de côtes sélectionnées ;
aucun ancien Bone de secours à l’intérieur de ces pièces. Les autres éléments
B-17 restent historiques. Réutiliser l’excavation, le Film, Condition, les dégâts
localisés et le profil Brush P6A3.3 validés. Préserver la géologie et les presets.

F6 compare la présentation mesh et le relief du même état de fouille dérivé,
sans reset. F5 ouvre une inspection du même asset hors matrice, pour juger le
potentiel de collection ; il s’agit d’un outil de revue, pas du musée final.
Les références historiques restent accessibles via leurs scènes/lanceurs.

Vérifications : source GLB/master/générateur, maillage fermé, budget <=40k triangles,
champ dérivé vérifié par projection indépendante des triangles importés,
préservation des régions hors pilote, occultation sous matrice intacte,
révélation partielle, contact/picking, Film/Brush/Condition/reset/archive,
comparaisons sans mutation et inspection sans effet sur la préparation.
Contrôler les captures natives sur Godot 4.7.2 et la RTX 5080. Mesurer le coût
sans prétendre qu’un benchmark constitue une validation du ressenti.

Livrer le candidat jouable, son lanceur, les preuves et un rapport franc sur
les limites. Aucun merge, production de catalogue, extraction gameplay ou
réarchitecture géologique générale automatique.
