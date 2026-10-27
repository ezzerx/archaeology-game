# Musée — lumière et matières

## Cible

Le cabinet d'histoire naturelle fourni par Antoine le 19 octobre 2026 guide
cette passe : soleil latéral chaud, niches éclairées, pierre ivoire,
noyer riche, laiton mesuré, livres et végétation. La référence définit
l'ambiance ; les préparations du joueur gardent leurs matières et leur état.

## Mise en œuvre

- Soleil directionnel entrant de l'ouverture gauche vers l'avant droit,
  avec ombres filtrées. L'ancien éclairage uniforme de façade est remplacé
  par une distinction entre lumière extérieure et éclairages de mobilier.
- Un soleil ombré, deux clés rasantes ombrées sur les présentoirs et deux
  clés ombrées en haut des niches. Les neuf autres sources locales restent
  sans ombres, limitées en portée. Leur position suit les modules définis
  avec le Technical Artist. Les réglages ont été mesurés sur de vraies archives,
  pas seulement sur les deux spécimens d’étude.
- Réponse AgX, remplissage neutre, éclat d'ampoule modéré. Le noyer reste brun,
  la pierre garde ses demi-teintes et les fossiles restent identifiables.
- SSIL désactivé. SSAO limité aux contacts ; aucune SDFGI, volumétrie,
  réflexion écran ni nouveau post-traitement de flou.
- Une sonde de réflexion locale, mise à jour une fois, fournit le reflet
  de la salle au laiton et aux surfaces finies.

## Matières

`gallery_surface.gdshader` conserve les quatre familles et leurs paramètres
`tint`, `kind`, `scale`. Le nouveau `grain_axis` indique la direction
des fibres : 0 vertical Y, 1 horizontal X, 2 profondeur Z.

Le bois utilise un grain irrégulier non périodique, une rugosité légèrement
variable, une couche de finition satinée et un relief de normale borné. Le laiton reçoit un brossage subtil,
avec métallique 0,84 et rugosité par défaut 0,32. Pierre, papier et tissu
restent mats. Ces matières procédurales ajoutent **zéro lecture de texture**.

`gallery_masonry.gdshader` conserve deux lectures filtrées des textures de
pierre/enduit existantes. Les retours de mur utilisent leur propre plan de
projection. Le sol reçoit une finition plus satinée, sans effet miroir.
Le relief dérivé reste borné et ne déplace jamais la géométrie.

`gallery_window.gdshader` produit un fond opaque de ciel doré et feuillage
lointain doux, sans animation, texture écran ou transparence. Le jardin
géométrique du Technical Artist reste distinct.

## Intégration et invariants

Fichiers de cette responsabilité :

- `scripts/experiments/exhibition/gallery_lighting.gd`
- `shaders/experiments/gallery_surface.gdshader`
- `shaders/experiments/gallery_masonry.gdshader`
- `shaders/experiments/gallery_window.gdshader`

Les shaders de fossiles, cartes d'archive, masques d'enfouissement, hauteurs,
Film, Condition et logique de préparation ne sont pas modifiés dans cette
passe musée. Les spécimens d'étude et les vraies archives restent distincts.

Cible : Godot 4.7.2, Forward+, plafond 240 FPS / physique 60 Hz.
MSAA 4× de la galerie est conservé. La mesure finale doit inclure la nouvelle
géométrie et les sources pratiques ; une réduction du nombre d'ombres n'est
pas à elle seule une preuve de gain GPU.

## Vérification

La capture de référence locale est
`work/museum-polish/before/01-gallery.png`.
Les vues après intégration, les itérations et mesures natives sont centralisées
dans le rapport musée et le dossier `work/museum-polish/`.
Les shaders ont été compilés et rendus par Godot 4.7.2 Forward+ sur RTX 5080.
Aucune validation artistique humaine n’est déduite des tests.

### Première itération lumière

Godot 4.7.2 Forward+ / RTX 5080 a compilé et rendu les six vues natives
`light-first/`, sortie 0. Leur revue a révélé un remplissage insuffisant :
correction du niveau, puis orientation de la lumière de retour vers les
façades. `light-adjusted.png` est une étape intermédiaire antérieure à
la nouvelle architecture et à la dernière orientation du remplissage.

Le processus de capture intermédiaire a signalé des ressources encore
référencées à la fermeture (7 textures, 8 instances, 4 ressources), sans erreur
de shader. Ce point est transmis à l'orchestration pour les contrôles de
fermeture de la scène finale.


## Itérations et mesure sur archives réelles

La revue de `iteration-1/01-gallery.png` a révélé des alcôves ternes et des
appliques sans effet lisible. Les sources étaient trop faibles au regard de
leur portée, et les niches éclairées trop verticalement. `light-pools-2.png`
vérifie la correction locale sans hausse de l’exposition générale.

`light-key-4.png` vérifie ensuite des clés rasantes : côtes, relief de coquille
et contact entre blocs et supports deviennent plus lisibles. Le remplissage
neutre a été réduit pour conserver ce contraste. Le soleil entrant de la
fenêtre a été réorienté vers les supports. Les ampoules visibles et la seconde
version des accessoires sont réalisées par le Technical Artist.

Une comparaison dans un même processus natif a utilisé la **copie QA des vraies
archives** `work/museum-polish/player-copy`, à 1920 × 1080, VSync et cap désactivés
pour 300 images mesurées par configuration, après stabilisation. Aucun fichier
d’archive n’a été réécrit. Résultats :

| Ombres | GPU P50 ensemble | GPU P50 B–17 proche | Image P50 ensemble | Image P50 B–17 |
| --- | ---: | ---: | ---: | ---: |
| Soleil seul | 3,983 ms | 4,536 ms | 4,372 ms | 4,882 ms |
| Soleil + 2 présentoirs | 4,406 ms | 5,080 ms | 4,822 ms | 5,454 ms |
| Soleil + 2 présentoirs + 2 niches | 4,443 ms | 5,111 ms | 4,835 ms | 5,499 ms |

La configuration finale conserve les quatre sources locales ombrées : leur
surcoût mesuré de 0,46–0,58 ms par rapport au soleil seul apporte les contacts
et la séparation des objets. Les deux niches ajoutent seulement environ
0,03 ms par rapport aux deux présentoirs. Les traces et captures sont sous
`work/museum-polish/shadow-compare/`, notamment `metrics.json`,
`four-local-overview.png`, `exhibit-only-b17.png` et `sun-only-b17.png`.

Le plafond de 240 FPS est conservé ; **ces archives denses ne tiennent pas
240 FPS à 1080p** dans cette mesure. Le P95 GPU de la configuration retenue est
4,749 ms en ensemble et 5,357 ms près de B–17. Les nouvelles images finales
après les dernières corrections du décor relèvent du rapport central.

Budget shaders : surface 0 lecture de texture, pierre 2 lectures, fond de
fenêtre 0 lecture ; aucune lecture écran, aucune boucle dynamique, aucun
`discard`, aucun changement des matériaux des préparations archivées. La
finition n’ajoute pas de géométrie animée, SDFGI, SSIL ou volumétrie.

## Revue finale

La revue des trois captures `final-real/01-overview.png`, `04-b17-close.png`
et `05-ammonite-close.png` confirme le gain de profondeur et la lisibilité
des fossiles. Un reflet trop large et blanc sur le cadre M–08 a conduit à
réduire seulement la composante spéculaire des deux clés d’exposition à 0,55.
L’éclairage diffus et les matériaux archivés sont conservés. La capture finale
de cette finition, du tapis et des gravures est centralisée par l’orchestration.

L’inspection en lecture seule de l’archive B–17 confirme une texture d’argile
terracotta d’origine avec `source_color`, `debug_view=0` et `preparation_demo=0`.
Aucun double décodage de cet albédo n’a été constaté ; son apparence plus claire
et rosée sous les clés et AgX ne justifie pas de recolorer la préparation.

La scène reste une version stylisée améliorée : la fenêtre est graphique,
les grands murs assez réguliers et les très gros plans exposent la grille du
terrain archivé. Ces limites ne sont pas masquées par un flou ni une modification
des données de préparation. L’approbation finale demeure celle d’Antoine.

### Reflet du présentoir M–08

L’inspection de la dernière capture rapprochée a révélé que la bande blanche
persistait après réduction spéculaire des clés. Le GLB source a été lu sans
modification : l’albédo ne contient pas de bande blanche ; le canal vert de
sa texture de rugosité donne environ 0,314 sur le bois (médiane des pixels
identifiés comme bois). Le facteur 0,54 de l’adaptateur abaissait cette
rugosité à environ 0,17. B–17 utilise une texture différente, environ 0,506,
soit environ 0,27 avec son facteur existant.

La seule correction finale est `material.roughness=1.0` dans
`scripts/experiments/exhibition/ammonite_stand.gd`. Elle conserve la texture
de rugosité M–08 et sa variation, avec un bois proche de 0,31 au lieu de 0,17 ;
B–17, lumière, GLB source et matériaux du fossile restent inchangés.
Cette multiplication est décrite dans la
[documentation Godot BaseMaterial3D](https://docs.godotengine.org/en/stable/classes/class_basematerial3d.html#class-basematerial3d-property-roughness-texture).
Le contrôle final est visuel, pris en charge par l’orchestration ; aucun
nouveau coût shader ni branche de navigation n’est ajouté.
