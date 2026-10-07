# P6A2 correction — demande de sources ImageGen

Demande du 7 octobre 2026, après rejet humain du look `a9d47b6`.
**Suite :** set sélectionné reçu dans le commit externe `5a3d340` et intégration
autorisée par Antoine. Les fichiers fournis sont des **miroirs JPEG 1254²**,
pas les PNG 2048² demandés. Voir `art/source/p6a2/images/README.md` pour les
dimensions, la sélection, les limites et les SHA des originaux hors dépôt.
La demande ci-dessous reste la spécification historique, pas un constat de livraison.
**Cinq images distinctes et cohérentes, une par matière ; aucun nouvel atlas.**
Le Material Lab rejeté ne doit pas être donné comme référence à ImageGen.

## Consigne commune à joindre à chacun des cinq prompts

Créer une source de couleur diffuse pour un jeu stylisé 2.5D de préparation
paléontologique chaleureux. Aspect travaillé à la main, minéral tactile,
retenu ; ni photo hyperréaliste, ni cartoon exagéré, ni pixel art.

**PNG RGB sRGB, 2048 × 2048 pixels, carré de matière de 24 × 24 cm**, plein cadre,
vue orthographique perpendiculaire. Une seule matière. Raccordable sans couture
sur X et Y, sans motif distinctif central ni répétition périodique évidente.
Les valeurs doivent rester homogènes à grande échelle, avec variations locales
irrégulières non orientées. Pas de grille ni de planche de quatre échantillons.

Rôle : **source d’albedo peinte**, pas photographie éclairée, pas normal map,
pas height map, pas set PBR prétendument calibré. Montrer la couleur intrinsèque,
les inclusions et pores par de faibles différences de couleur ; ne pas dessiner
leur lumière. **Aucun éclairage cuit, aucune ombre portée ou occlusion cuite,
aucun reflet, aucun hotspot, aucun gradient lumineux, aucune vignette**, même si
les références en comportent. Le relief et la lampe seront rendus dans Godot.
Pas de cadre, texte, outil, fossile entier, anatomie, lampe ou décor.

Joindre `02-material-closeup.jpg` comme référence principale de langage et
séparation des matières, puis `01-gameplay-target.jpg`. **Ne pas recopier leur
composition, géométrie, poussière de scène ou lumière dorée dans la texture.**

## Cinq variantes à générer

| Fichier sous `art/source/p6a2/images/` | Palette diffuse indicative (pas lumière) | Détail voulu à l’échelle 24 cm | Interdits spécifiques |
|---|---|---|---|
| `p6a2_clay_albedo_source_v02.png` | Terracotta orange naturel, brun rouge discret ; points de départ sRGB `#985932`, `#B5683B`, `#C78049` | Terre compacte, grains 0.3–1 mm, rares marques minérales 1–3 mm, plages chromatiques douces 10–35 mm | Marbre, volutes peintes, grosses craquelures/plaques, lave, mousse, gros cailloux, taches noires « camouflage » |
| `p6a2_sandstone_albedo_source_v02.png` | Brun minéral sombre et désaturé, `#51483B`, `#6B5B46`, `#857055`, nettement sous Clay en luminosité et sous Bone | Grain angulaire serré 0.5–2 mm, inclusions 2–6 mm, quelques fines discontinuités minérales ; aspect compact capable de fracture | Roche blanche/calcaire, granite noir et blanc, strates répétées, faux blocs éclairés, grands trous/canyons, couleur orange Clay |
| `p6a2_soil_albedo_source_v02.png` | Terre brun chaud sombre, `#3E2B1C`, `#59402A`, `#745536` | Fine couverture meuble, grains/agrégats 0.4–2 mm, quelques fragments jusqu’à 3 mm ; dispersion irrégulière | Galets, pavage, terre de plusieurs centimètres d’épaisseur représentée en coupe, racines, feuilles, herbe, gros morceaux de roche |
| `p6a2_bone_albedo_source_v02.png` | Vieil ivoire ocré, `#B7A57F`, `#C5B38E`, `#D2C29D` ; plus chaud que le plâtre, pas blanc | Surface osseuse fossilisée propre, pores subtils 0.15–0.7 mm, très rares inclusions minérales <1 mm, fines stries non régulières | Silhouette/anatomie d’os, crâne, dents, chair, vernis, porcelaine, blanc pur, saleté/Film/pattern de nettoyage cuits |
| `p6a2_plaster_albedo_source_v02.png` | Plâtre craie gris chaud, `#AAA79D`, `#BCB7AB`, `#D3D0C5` ; moins jaune que Bone | Plâtre mat crayeux, grains 0.2–1 mm, irrégularités d’enduit 3–12 mm, rares fibres courtes discrètes | Ivoire/pore d’os, marbre, tuiles/pierres séparées, rebord dessiné, fissures larges ombrées, tissage intégral uniforme |

Chaque ligne reprend **toutes** les exigences communes : 2048², 24 cm, seamless
XY, source albedo sRGB, pas de lumière/ombre cuite. Aucune sixième image sale
pour Bone : son Film reste exclusivement le masque dynamique natif. La toile
localisée du jacket peut rester un matériau temporaire indépendant.

## Livraison et intégration attendues

Antoine/orchestrateur génère les cinq sources dans ChatGPT, sélectionne le set
cohérent et fournit les PNG originaux avec leurs prompts. Ne pas fournir une
capture d’écran ou un montage JPEG. Si ImageGen ne produit pas réellement
2048²/seamless, signaler les dimensions et les raccords observés ; ne pas affirmer
que la demande a été satisfaite par simple upscale.

Originaux sélectionnés conservés aux chemins ci-dessus avec provenance,
dimensions, SHA256 et validation humaine de sélection. Runtime dérivé :
`assets/p6a2/textures/<material>/p6a2_<material>_albedo_v02.png`.
La résolution runtime (probablement 1024²) sera décidée après inspection à 3×,
sans supprimer les sources 2048². Import couleur sRGB + mipmaps ; aucun masque
de gameplay généré par ImageGen. Les sources ne sont pas automatiquement
interprétées comme hauteur physique. Roughness et éventuels détails de normale
seront des réglages locaux modestes, pas un substitut à de mauvaises sources.

Contrôles avant intégration finale : matière correcte, Bone/plâtre séparés,
absence de lumière cuite, détail à la bonne échelle, raccords 2×2, comparaison
directe avec 02 puis 01 et observation à 1×/3× dans le vrai bloc. Une image non
conforme est signalée, pas silencieusement promue en matériau final.

Au moment de cette demande, le volet matière attendait ces sources ; coque et
lampe pouvaient avancer avec des aplats temporaires. Le set reçu est documenté
dans le dossier cité en tête ; la gate courante reste dans `docs/brain/status.md`.
