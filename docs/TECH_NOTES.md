# Notes techniques

**Stack courant : Godot 4.7.2 stable Standard, GDScript, Compatibility/OpenGL.** Le noyau reste un heightfield RF 1024×640 avec relief GPU et picking CPU cohérent, enrichi par fossile, fracture, débris, verticalité, Bone Film et progression de session. Pour l'état live, lire uniquement [status](brain/status.md), puis le brief/report actif. Les sections ci-dessous sont surtout des notes techniques/historiques d'exploration.

Les sections exploratoires ci-dessous datent de la conception initiale. Leurs pistes 2D / pixel art sont historiques. Elles ne décrivent ni la phase active ni une autorisation de travail. La source de statut reste [status](brain/status.md).

## Pourquoi explorer Godot

Les textures dynamiques et shaders 2D fournissent des pistes pour représenter masks, couches et retrait de matière. L’API `ImageTexture` permet de mettre à jour une texture à partir d’une image ; les shaders `CanvasItem` concernent le rendu 2D. Ces capacités ne valident pas encore la performance ou le game feel de notre approche. Sources officielles consultées le 2026-09-30 : [ImageTexture](https://docs.godotengine.org/en/stable/classes/class_imagetexture.html), [CanvasItem shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html).

Vérifier la version stable officielle au démarrage du développement, tester la solution minimale puis consigner la version effectivement utilisée. Ne pas reprendre sans vérification une version annoncée dans un ancien brainstorming.

## Responsabilités proposées

| Module | Responsabilités | Limite |
|---|---|---|
| **Excavation Engine** | Material masks, outils, résistance / profondeur, destruction, fossil detection | Ne décide pas seul de la collection ni de la présentation du musée |
| **Game Feel** | Particules, poussière, éclats, camera feedback, animation des outils, audio triggers | Réagit aux interactions et découvertes, sans devenir la source de vérité des pièces |
| **Fossil System** | Spécimens, fragments, découvertes, identification et completion % | Distingue révélation, récupération et possession |
| **Museum** | Carousel / scroll, assemblage du fossile, missing parts, présentation de progression | Affiche les acquisitions réelles ; aucun avatar |
| **Content Pipeline** | Nouveau fossile, nouveau bloc, material maps, museum entry | Commencer par un contenu manuel minimal, outiller après validation |

Ce découpage sert à clarifier les responsabilités. Il n’impose ni classes, ni services, ni développement simultané de tous les modules.

## Représentation à explorer

Un bloc peut superposer des textures et masks par matériau. Une carte de résistance / profondeur conserve l’état résiduel local ; les visuels traduisent les états intact, abîmé, fissuré, presque cassé puis retiré. Le retrait découvre la couche suivante, jusqu’à l’os.

Une carte séparée peut décrire les zones fossiles et leurs fragments. Les interactions produisent des événements de contact, usure, rupture et première découverte pour les retours sensoriels. Les seuils et le stockage exact restent à choisir.

Comparer une grille invisible adaptée au pixel art à un mask plus continu pour la 2D illustrée. Choisir résolution, fréquence de mise à jour et méthode CPU / shader après mesure sur le petit prototype ; ne pas présupposer une destruction en voxels, une 3D ou un moteur physique complexe.

## Données minimales futures

- **Matériau** : identité, résistance / profondeur, états visuels, famille sonore, réactions.
- **Outil** : zone d’action, efficacité par matériau, précision, risque éventuel sur fossile.
- **Bloc** : couches, material maps, fossile caché et correspondance spatiale.
- **Spécimen / fragment** : identité connue, indices, partie de collection, état de révélation / récupération ; condition optionnelle.
- **Exposition** : liste de pièces attendues, acquisitions et placements visuels.

La jauge de dégagement du bloc et la complétion de collection sont indépendantes. Les identifiants devront permettre de relier chaque nouvelle acquisition à son emplacement de musée.

## Points à tester

| Risque | Expérience minimale |
|---|---|
| Effacement qui ressemble à une gomme | Ajouter résistance, états intermédiaires et réactions par matière |
| Pixel art dégradé par les masks | Comparer grille / bords adaptés et rendu illustré sur le même bloc |
| Mises à jour de texture trop coûteuses | Mesurer une seule surface avant d’augmenter la résolution |
| Particules qui masquent les os | Rejouer les premières révélations avec densité réduite |
| Dommages frustrants | Tester le contact / avertissement avant de figer une pénalité |
| Coût de contenu trop élevé | Créer un second bloc avant un pipeline ou un catalogue important |

## Versionnement

Le `.gitignore` exclut les caches Godot, imports générés, exports locaux et credentials d’export. Les sources futures (scènes, scripts, textures sources, fichiers `.uid` et métadonnées `.import` associées aux assets) doivent rester versionnables. `.gitattributes` normalise les fins de ligne en LF sans changer la configuration Git globale.

Les règles des presets d’export varient selon la version : la documentation officielle distingue Godot 3.x / 4.0 de 4.1 et ultérieur. Par prudence, `export_presets.cfg` est exclu tant que la version n’est pas choisie ; réexaminer ce choix pour versionner un preset sans secret si pertinent. Source : [Godot — Version control systems](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html), consultée le 2026-09-30. Base complémentaire : [Godot.gitignore de GitHub](https://github.com/github/gitignore/blob/main/Godot.gitignore), consultée le même jour.

Évaluer Git LFS avant l’introduction de gros assets ; aucun asset lourd ni configuration LFS n’est nécessaire à cette canonisation. La sauvegarde avancée, les exports Steam et les outils de production restent hors v0.1.
