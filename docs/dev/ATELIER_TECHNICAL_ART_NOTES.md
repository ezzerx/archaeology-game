# Atelier — notes de Technical Art

## Intention et périmètre
La préparation devient un établi de muséum habité : toile de protection cousue,
plateau émaillé contenant les outils réels, carnet illustré et crayon, livres
vert musée à dorure, petit pot inventorié et lampe visible. Le bloc conserve la
place principale et la caméra reste identique. Le dessin du carnet est une
planche de référence explicitement nommée ; il ne révèle pas le spécimen enterré.

Les trois images fournies par Antoine guident la palette, les matières et le soin
des objets. Cette passe ne prétend pas reproduire leur photoréalisme ; elle
apporte une mise en scène cohérente au vrai jeu Compatibility existant.

Aucun nouvel éclairage, collision, animation, particule, contrôle ou traitement
par frame dans ce module. Le bloc, ses empreintes, ses outils interactifs et ses
résultats restent indépendants. La lampe décorative ne projette pas d'ombre sur
la préparation. Les lumières et shaders partagés appartiennent à la passe
Godot Shader Developer.

## Spécification de production

| Catégorie | Budget attribué | Réalisation |
| --- | --- | --- |
| Ensemble du décor | 45 000 triangles, 16 surfaces opaques | 42 322 triangles, 14 surfaces |
| Textures nouvelles | 1 atlas 1024 × 1024, mipmaps, BC7 PC | Atlas SVG avec lettres en contours, import haute qualité VRAM |
| Outils et lampe | Réutiliser les textures et silhouettes existantes | GLB source inchangés, premier LOD cuit dans le décor |
| Petites pièces | Métal, papier, bois, céramique et feuilles regroupés par matière | Aucun objet individuel ajouté à la boucle runtime |
| Particules / transparence | 0 / 0 | Géométrie opaque uniquement |
| Éclairage ajouté | 0 nouvelle lumière ou source lumineuse projetant des ombres | Lampe d'apparence seulement |

Le budget est vérifié par le script de cuisson, qui échoue avant sauvegarde si
l'ensemble est incomplet ou dépasse 45 000 triangles / 16 surfaces. Les 14
surfaces impliquent 14 passes de couleur avant les passes d'ombres éventuelles.
Les matériaux source réutilisés restent sous le budget mémoire déjà chargé pour
les outils interactifs ; seul l'atlas de papeterie est nouveau.

Toute géométrie passe par `ImporterMesh.generate_lods(25, 60, [])` hors ligne.
Les petites surfaces plates ne bénéficient pas d'une réduction supplémentaire ;
les batches de pièces courbes comportent de 1 à 5 LOD automatiques. Aucun nouveau
hero mesh n'est produit et le bloc dynamique conserve sa propre géométrie.
Le point de départ des outils/lampe décoratifs est lui-même le premier LOD des
sources détaillées. L'export runtime n'utilise pas `ImporterMesh`.

## Fichiers et intégration
- `scripts/workshop/polish/atelier_set_dressing.gd` : module runtime.
- `assets/workshop/polish/atelier_still_life.scn` : scène statique B–17 cuite.
- `assets/workshop/polish/atelier_marine.scn` : variante de proportions M–08 cuite.
- `scripts/workshop/polish/atelier_geometry.gd` : source géométrique reproductible.
- `scripts/workshop/polish/bake_atelier.gd` : cuisson, vérification budget, LOD.
- `assets/workshop/polish/field_notes.svg` : atlas final importé, contours vectoriels.
- `scripts/workshop/polish/source/field_notes.svg.in` : mise en page éditable.
- `scripts/workshop/polish/outline_atlas.py` : conversion du texte en contours.

Après le `_ready()` hérité de la préparation :

```gdscript
var atelier = preload("res://scripts/workshop/polish/atelier_set_dressing.gd").new()
add_child(atelier)
atelier.setup(self)
```

Le module masque `desk_art`, remplacé par le nouvel ensemble.
Pour M–08, il sélectionne un décor adapté : accessoires à 75 % uniformes,
toile ajustée séparément à 0,675 × 0,585 m et centre déplacé de (0,022 ; 0,014 m)
selon les proportions de son empreinte. La caméra reste à 0,70 et B–17 garde son
décor initial. Une seule des variantes est instanciée : le budget de rendu ne double pas.
`set_enabled(false)` restaure sa visibilité initiale pour la comparaison.
Le parent de mission gère l'intégration partagée et le raccord au témoin visuel.

Cuisson géométrique :

```powershell
& $Godot --headless --path . --script res://scripts/workshop/polish/bake_atelier.gd
& $Godot --headless --path . --script res://scripts/workshop/polish/bake_atelier.gd -- --marine
```

Pour modifier les textes : éditer le `.svg.in`, exécuter `outline_atlas.py --font
C:/Windows/Fonts/georgia.ttf` avec `fontTools`, importer le SVG puis recuire.
La police n'est pas redistribuée : seuls les contours de la papeterie dessinée
sont conservés. L'outillage Python ne sert pas au runtime.

L'atlas monde conserve sa résolution source de 1024 px, mipmaps activées et
compression haute qualité PC ; une future cible mobile devra recevoir son
override ASTC. Aucun nouveau shader spécifique à la plateforme n'est ajouté.

## Vérification effectuée
- Import Godot 4.7.2 sans erreur sur les sources et ressources finales.
- Cuisson hors ligne réussie : 42 322 triangles / 14 batches, scène d'environ 1 Mo.
- Deux captures réelles dans la préparation B–17 avec renderer Compatibility,
  RTX 5080 et vue inchangée à 1440 × 810 : correction des papiers/émail trop clairs,
  typographie SVG réellement visible, lampe entièrement dans le cadre, toile
  resserrée gris chanvre. Dernière capture : `work/sensory/atelier-art-review.png`.
- Les accessoires restent périphériques ; aucun accessoire ne recouvre le bloc
  dans cette vue. Aucun réglage de zoom, caméra ou gameplay n'a été modifié.

Le parent de mission fournit les captures finales des trois préparations, les
régressions et les mesures de performance intégrées. Cette revue visuelle
technique ne constitue pas l'acceptation artistique d'Antoine. Pas de profilage
sur mobile, de sign-off matériel ni de promesse de qualité AAA équivalente aux
références photographiques.


### Vérification complémentaire des formats M–08
La première capture intégrée montrait une toile disproportionnée et des
accessoires hors cadre pour les deux M–08. La variante ci-dessus corrige ce
point sans modifier le bloc ou les contrôles. Captures moteur inspectées :
`work/sensory/atelier-marine-1.png` et `work/sensory/atelier-marine-2.png`.
Les livres, notes et vrais outils sont entièrement visibles autour du bloc,
avec bois périphérique et aucune occlusion de la surface de travail.
Les assertions de cadrage `.70` et de sélection de la variante passent dans
les deux préparations ; comparaison flottante avec `is_equal_approx`.
