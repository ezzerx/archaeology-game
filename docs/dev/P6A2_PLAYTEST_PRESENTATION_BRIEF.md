# P6A2 Soil & Playtest Presentation — brief

**Date :** 2026-10-07. Périmètre issu du test humain de `d535c31`, précisé par le GO d’Antoine. La gate et l’autorisation courante sont exclusivement dans [status.md](../brain/status.md).

Précisions humaines intégrées : Soil doit changer de morphologie, pas seulement s’éclaircir (amas fragmentés de tailles variées, bords cassés, interstices Clay, grain de la source v02). Mesurer aussi taille/distribution des composantes continues. UI : vrai restyle papier/musée, crème/chaud, hiérarchie soignée et Reveal / Clean / Condition immédiatement lisibles, décliné jusqu’au bilan et Archive / Keep Cleaning. L’exemple UI papier mentionné n’est pas matérialisé dans les références locales trouvées ; la direction textuelle explicite sert de référence, sans prétendre reproduire cette image.

## Objectif

Rendre le Hero Patch présentable et confortable pour un premier playtest entre amis. La réussite dépend d’abord d’un Soil qui apporte une matière crédible et un geste de brossage satisfaisant, puis d’une présentation claire qui ne demande pas d’accompagnement développeur.

Conserver `scenes/p6a2_hero_patch.tscn` et son architecture isolée. Garder Clay, la lampe locale et Sandstone comme références de travail actuelles ; préserver les témoins et captures historiques. Aucun nouveau système de fouille.

## 1. Soil — travail prioritaire

**Diagnostiquer avant de corriger.** Le profil `soil_foundation_profile.gd`, repris par `natural_matrix_profile.gd`, construit la vraie couverture mince. `p6a15_contact_deposits.gdshaderinc` ajoute séparément des dépôts visuels sur le substrat. Comparer couverture seule, patine seule et combinaison, aux mêmes caméra, relief et lumière : la contribution exacte au camouflage reste à vérifier visuellement.

**Cible matière :** terre meuble et granulaire, brun chaud compatible avec Clay, grain lisible à 3× et masse cohérente à 1×. Réduire les grands aplats sombres et les contours de taches qui dominent le matériau. Travailler la taille des dépôts, leur bordure, les variations locales et le contraste, sans remplacer le camouflage par du bruit uniforme.

Partir de la source Soil ImageGen v02 sélectionnée et de son échelle réelle. Ne pas réutiliser l’atlas rejeté. Une nouvelle source n’est à demander que si un manque précis est démontré.

La direction P6A1.5 reste : mince, partielle, irrégulière, suivant le substrat et retirée rapidement au Brush. Les éventuelles modifications de répartition concernent seulement la couverture Soil locale au Hero, jamais le relief Clay/Sandstone ni la géologie B. Garder un effort de nettoyage comparable et documenter toute variation de quantité ; aucun retuning d’outil/résistance pour la compenser. Ne pas peindre du Soil excavable là où la simulation n’en contient pas. Aucun lien de génération avec la position du fossile.

Patine : conserver le principe accepté de dépôts sur le matériau d’origine. Si elle contribue au défaut, limiter la correction à sa lecture de salissure ; ne pas refaire l’albedo Clay validé ni ajouter une bande sombre uniforme.

**Livrable central :** comparaison avant/après contrôlée à 1× et 3×, départ intact → brossage partiel → substrat dégagé, plus un trajet de Brush identique. Un décor plus agréable ne compense pas un Soil toujours perçu comme camouflage.

## 2. Confort plein écran / grand écran

Prévoir un mode fenêtré confortable et un plein écran sans bordure réversible, adapté à la résolution native, avec préférence mémorisée. Proposition : Alt+Entrée pour la bascule, puisque F11 sert actuellement au diagnostic de lumière.

Adapter l’échelle UI et le cadrage aux dimensions de fenêtre sans changer zoom/pan, précision du pointeur ou aire excavable. Vérifier le passage fenêtre/plein écran, l’Alt-Tab, les bords et le picking à 1×/3×. Aucune action d’outil ne doit rester enclenchée après perte de focus.

Physique 60 Hz et cap 240 FPS conservés. Mesurer le coût aux résolutions réellement testées ; ne pas extrapoler une fluidité 4K depuis le 1080p.

## 3. Objectifs et fin de session

Polir la présentation locale au Hero, en réutilisant `PreparationSession` et les règles P5 : hiérarchie typographique, carte d’objectif compacte, états/progrès lisibles et écran de bilan cohérent avec l’ambiance de préparation. Conserver Exposure, Cleanliness et Condition comme concepts distincts.

Rendre le palier atteint et le choix Archive / Keep Cleaning compréhensibles. Garder 85/85, le garde-fou des zones cachées, 95/95 optionnel et les transitions existantes. Ne pas inventer score, récompenses, objectifs ou méta-jeu. Les contrôles de diagnostic restent accessibles mais masqués dans la présentation destinée aux amis.

## 4. Lampe visible et établi discret

Ajouter une seule lampe de bureau dont la tête et la direction rendent crédible la source locale déjà validée. Garder son rendu lumineux comme référence ; aucun nouveau chantier d’éclairage.

Ajouter au maximum deux ou trois accessoires statiques utiles à l’ambiance, hors zone de fouille et sans masquer l’UI. Le spécimen domine. Réutiliser Blender → GLB → Godot ; compter les triangles et draw calls ajoutés. Aucun nouvel outil DCC nécessaire par défaut.

## Ordre et limites

Commencer par le diagnostic et le candidat Soil. Préparer ensuite le confort d’affichage, l’UI et la lampe, sans multiplier les variantes artistiques. La revue finale doit isoler le verdict Soil de l’attrait du décor.

Hors périmètre : nouvelle forme excavable du bloc, correction jacket, Clay surface breakup grammar, retuning Clay/Sandstone, anatomie, plafonds Bone, Bone Film, outils/résistances, progression P5, destruction jacket, atelier complet, musée/intake, audio, P6B. Une future correction jacket/emprise intérieure mérite un brief séparé après Soil, car elle touche potentiellement l’autorité de fouille.

## Livraison et validation proposées

- Hero jouable avec lanceur conservé ; petit export Windows portable lançable par double-clic, sans Godot installé ni terminal requis côté ami. Pas de menu complet ou d’installeur.
- Captures comparables : Soil initial/partiellement brossé/dégagé à 1×/3×, vue d’ensemble avec lampe, objectif en cours, palier musée, choix de poursuite et bilan archivé.
- Tests ciblés : quatre outils et Bone Film, début → fin de session, transitions P5 inchangées, physique 60 Hz, pointer/picking et UI après changements de fenêtre/résolution. Préciser ce qui a réellement été testé en 1080p, 1440p, 4K et ratios différents selon le matériel disponible.
- Mesures avant/après aux mêmes résolution et état : frame P95, GPU si disponible, CPU édition, draw calls, triangles/textures ajoutés ; un reset, Brush, Chisel/débris et nettoyage Bone suffisent pour le périmètre, sauf anomalie.
- Rapport court avec changements, limites, captures, performances et procédure de playtest non technique. L’acceptation visuelle appartient à Antoine ; aucune promotion de phase automatique.

**Critères de revue humaine :** Soil ressemble-t-il à de la terre plutôt qu’à un camouflage ? Son retrait révèle-t-il naturellement le Clay conservé ? L’objectif et la fin se comprennent-ils sans explication ? Le plein écran est-il confortable ? La lampe et les accessoires donnent-ils vie au poste sans voler l’attention au fossile ?
