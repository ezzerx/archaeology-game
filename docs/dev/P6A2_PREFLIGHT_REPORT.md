# P6A2 — Hero Lookdev preflight

2026-10-07. **Verdict : READY.** Chaîne essentielle exécutée, pas supposée. Ce rapport documente le preflight ; la gate courante reste dans [status.md](../brain/status.md). Aucune art pass P6A2 réalisée.

## Décision humaine et synchronisation

Antoine clôt P6A1 comme **suffisamment validé pour avancer**. Le B macro + méso de `26f3552` est la fondation P6A2 pour maintenant, pas une géométrie finale parfaite. **Clay surface breakup grammar** est différé : rapprocher ultérieurement la surface Clay intacte du langage de petites cassures minérales après excavation. Ce n’est ni un blocage ni une tâche de ce preflight. Soil mince et patine par dépôts restent acceptés ; P4/P5 restent gelés. Les rapports historiques P6A1.6 n’ont pas été réécrits.

Avant le travail : inspection Git, fetch origin, avance rapide de `26f3552` vers `370ba6355a4a03d48e6faa5ae6aa60988aa2cb88`. Aucun reset/rebase/force-push. La modification utilisateur préexistante de `project.godot` (retrait de la déclaration explicite 60 Hz, valeur par défaut toujours 60) et `tests/export_p6a_evidence.gd.uid` non suivi sont préservés et exclus du commit.

## Six références locales vérifiées

Toutes sont versionnées sous `docs/visual-references/p6a2/`, décodées dans Godot **et inspectées visuellement directement par l’agent**. Aucun remplacement ni régénération. Dimensions et SHA256 complets dans [results.json](evidence/p6a2-preflight/results.json).

| Fichier | Pixels | Rôle exact |
|---|---:|---|
| `00-style-north-star.jpg` | 1024×576 | chaleur, émotion, illustration artisanale, monde du laboratoire ; pas composition gameplay |
| `01-gameplay-target.jpg` | 1024×576 | cible gameplay principale : qualité du bloc, séparation des matières, jacket, profondeur, lisibilité |
| `02-material-closeup.jpg` | 1024×768 | matière tactile, Soil, Clay orange, Sandstone compact, Bone sale/propre, rugosité et détail ; pas caméra macro |
| `03-closed-block.jpg` | 768×432 | identité du bloc fermé, silhouette et langage plâtre/support ; pas intake |
| `04-progression-states.jpg` | 768×432 | continuité intact → révélation → Bone sale → préparation ; pas UI 2×2 |
| `05-workbench-target.jpg` | 640×360 | support de cadrage limité, table/lampe/accessoires discrets ; pas atelier complet |

Hiérarchie conservée : **gameplay/mécaniques > 01 > 02 > 00 > supports > ancien board**. Les images montrent bien la séparation orange/pierre sombre/ivoire, les rebords plâtrés et la lumière chaude recherchés. Elles ne sont pas des plans d’anatomie ou de géométrie à copier. Ces JPEG durables conviennent à la référence, pas à l’extraction automatique de textures finales. Le texte d’accès initial de `P6A2_VISUAL_TARGETS.md` précède leur matérialisation ; le pack local est maintenant effectivement disponible.

## Outils réellement vérifiés

| Outil | Version CLI exacte | Exécutable |
|---|---|---|
| Godot | `4.7.2.stable.official.ed1daf0bf` | `C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe` |
| Blender | `5.2.2 LTS`, hash `d13f752e3b9c`, build 2026-09-15 | `C:\Users\antoi\AppData\Local\Programs\ArchaeologyGameTools\blender-5.2.2-windows-x64\blender.exe` |

Blender absent des chemins usuels/PATH au début. ZIP x64 de la [distribution officielle](https://download.blender.org/release/Blender5.2/blender-5.2.2-windows-x64.zip), extrait dans `%LOCALAPPDATA%\Programs\ArchaeologyGameTools`. SHA256 comparé au [manifeste officiel](https://download.blender.org/release/Blender5.2/blender-5.2.2.sha256) : `3849d17a682cba006075aaa3f3597ecb5c9c30ec31035b2e092c53e40679b535`.

[Relevé technique compact](evidence/p6a2-preflight/toolchain.json) : versions, chemins, provenance et empreintes vérifiées.

Portable, aucun MSI, UAC, droit administrateur, installation système ou changement global de PATH. ZIP, manifeste et binaires restent hors Git. Les commandes ont requis la permission d’exécution/réseau de l’environnement Codex, pas une intervention physique d’Antoine. TLS vérifié normalement ; aucun contournement de certificat. Blender lancé avec `--background --factory-startup`, version exacte imposée par le helper ; aucune version substituée.

`tools/preflight/Export-Probe.ps1` retrouve le chemin utilisateur conventionnel, ou accepte `BLENDER_BIN` / `-BlenderBin`. Godot est déjà présent ; son chemin actuel dans Downloads reste utilisable via `-GodotBin` des lanceurs existants. Ne pas supposer qu’il existe sur un autre PC.

ChatGPT ImageGen : workflow autorisé et préparé **sans génération locale exigée**. Une prochaine étape doit décrire le besoin exact (matière, échelle, canaux, raccords, rôle), Antoine/orchestrateur génère dans ChatGPT puis sélectionne l’asset à fournir. Aucun nouveau service/outil IA installé.

## Preuve Blender → GLB → Godot : PASS

Sonde **PREFLIGHT ONLY / NON-PRODUCTION** : quatre boîtes asymétriquement disposées, 48 triangles, aucune collision, aucun script embarqué. Corps à deux matériaux (dessus doré, reste gris), trois repères rouge/vert/bleu. Ce n’est pas un jacket ni un candidat visuel.

- Génération : `tools/preflight/create_probe.py`, Blender en arrière-plan.
- Source sauvegardée : `art/source/preflight/pipeline_probe.blend` (~102 Ko). `art/source/.gdignore` empêche son import Blender implicite par Godot.
- Export **depuis le .blend rouvert dans un autre processus** : `tools/preflight/export_static.py`.
- Sortie : `assets/preflight/pipeline_probe.glb` (8 420 octets), avec métadonnées `.glb.import` versionnées. Cache importé `.godot/imported/` ignoré.
- Scène dédiée : `scenes/preflight/pipeline_probe.tscn` ; ouvrable et jouable par F6 ou CLI. Son éclairage/caméra sont uniquement des dispositifs de contrôle, pas du lookdev.
- Contrôles : `tests/run_p6a2_preflight.gd`, **31 contrôles / zéro échec**, trois captures, import et exécution sans erreur script/shader/import.
- Export répété, y compris après réouverture : GLB octet-identique SHA256 `d13a6df29c02fff51f600553ddc57dfe09e7f7853c694e9b4138804750c86d33`. On ne promet pas que les métadonnées internes du `.blend` soient octet-identiques.

### Conventions mesurées

Blender **Metric, scale_length=1**, une unité = un mètre ; Godot une unité = un mètre, import root_scale=1. Blender **+Z haut, +Y avant** devient Godot **+Y haut, −Z avant**, +X reste +X. Export glTF `export_yup=true`, sans deuxième rotation compensatoire.

Corps Blender XYZ **0,2×0,1×0,05 m** → sommets Godot XYZ **0,2×0,05×0,1 m**. Origine du groupe Blender `(0,3;0,2;0)` et centre local `(0;0;0,025)` → centre Godot `(0,3;0,025;−0,2)`. Les trois marqueurs vérifient indépendamment le signe de chaque axe. Rotation/échelle appliquées au mesh, translations locales intentionnelles conservées. Normales de tous les sommets unitaires et sortantes, slots `probe_neutral` / `probe_top` et roughness 0,8 / 0,25 conservés.

Un premier contrôle fondé sur l’AABB a observé **0,05001 m** au lieu de 0,05 : la marge de culling de la surface plane dorée n’est pas la dimension des sommets. Le contrôle final mesure les sommets réels, sans relâcher leur égalité. Un typage du script de test a aussi été corrigé avant le run final ; aucun fichier gameplay concerné.

Export : GLB 2.0, meshes/normales/UV/matériaux, modifiers appliqués (`export_apply`), sans animations/caméras/lumières. Matériaux Principled simples ; les réseaux Blender arbitraires ne sont pas garantis exportables. Triangulation par l’exporteur. Pas de compression Draco requise. Godot : import PackedScene standard, tangentes générées, matériaux intégrés ; les futurs overrides lookdev seront des ressources Godot isolées, pas des modifications du cache généré.

Noms sans suffixes de collision (`-col`, etc.), `snake_case` pour fichiers/meshes/matériaux ; origine et dimensions documentées par asset. Appliquer rotation/échelle avant export, éviter échelles négatives ; garder les transformations d’assemblage dans Godot. Le nom de probe est explicitement non-production.

### Rejouer depuis la racine

```powershell
# Régénère uniquement la sonde, sauvegarde puis rouvre le .blend et exporte.
.\tools\preflight\Export-Probe.ps1
$godot = 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path . --editor --quit
& $godot --path . --script tests/run_p6a2_preflight.gd
```

Pour exporter un `.blend` édité sans le régénérer :

```powershell
$blender = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe'
& $blender --background --factory-startup art/source/preflight/pipeline_probe.blend --python-exit-code 1 --python tools/preflight/export_static.py -- --output assets/preflight/pipeline_probe.glb
```

Logs/captures temporaires : `work/test-logs/p6a2-preflight/`. Preuves compactes versionnées : [résultats](evidence/p6a2-preflight/results.json), [sonde](evidence/p6a2-preflight/probe.jpg), [coexistence B](evidence/p6a2-preflight/baseline-B-with-static-probe.jpg), [P5](evidence/p6a2-preflight/baseline-P5.jpg). Captures inspectées, 1920×1080 Compatibility OpenGL 3.3 / RTX 5080 / NVIDIA 610.88. Ce smoke test ne remplace ni les régressions gameplay déjà livrées ni une future validation artistique/performance du Hero Patch.

## Baseline exacte et isolation recommandée

**Départ P6A2 : `scenes/p6a16_natural_matrix_lab.tscn`, candidat B (`select_candidate(1)`), fixture 0, Soil mince et patine actifs.** Attention : le lab historique démarre toujours en **A** ; choisir B explicitement, ne pas prendre son défaut pour la fondation acceptée.

Géométrie : `scripts/p6a/natural_matrix_profile.gd` du commit `26f3552`, macro + méso réels indépendants du fossile, couches/cache du `soil_foundation_profile.gd`. `natural_matrix_lab.gd` étend `soil_foundation_lab.gd`, lui-même `prototype_main.gd`. La scène normale P5 `scenes/prototype_main.tscn` conserve son démarrage historique ; aucune promotion automatique de B en production.

**Recommandation après GO : créer une petite scène héritée `scenes/p6a2_hero_patch.tscn` à partir du lab**, avec un mince script d’assemblage sélectionnant B et des ressources visuelles locales à cette scène. Ce fichier n’est pas créé par le preflight. Garder le lab comme témoin de comparaison. Aucun framework supplémentaire ni duplication du moteur de fouille.

| Autorité partagée inchangée | Sources exactes |
|---|---|
| Hauteurs RF, couches, édition, résistances | `scripts/working_surface.gd`, `scripts/stratigraphy.gd`, `config/loose_soil.tres`, `compact_clay.tres`, `sandstone.tres` |
| Maillage dynamique, uploads et reconstruction de surface | `scripts/excavation_block.gd`, `scripts/relief_surface.gd`, déplacement de `shaders/surface_debug.gdshader` |
| Bone, plafonds, exposition, Condition, Film | `scripts/fossil_field.gd`, `fossil_state.gd`, `bone_surface_film.gd` |
| Outils, fracture/débris, picking, caméra | `scripts/tool_controller.gd`, `tool_definition.gd`, `material_fracture.gd`, `loose_debris.gd`, `relief_surface.gd`, `precision_zoom.gd`, ressources `config/` |
| Progression et archive | `scripts/preparation_session.gd`, `preparation_rules.gd`, `preparation_ui.gd` |
| Sémantique patine | adaptateur `soil_foundation_lab.gd` et `shaders/p6a15_contact_deposits.gdshaderinc` |

Le probe est instancié comme **frère statique** hors du rectangle d’excavation, sans collision. Les hashes hauteurs/interfaces/plafonds Bone sont identiques avant/après. P5 et le B actif ouvrent avec leurs quatre outils et session natives ; cap 240 FPS / physique 60 Hz confirmé. Aucun shader, script ou paramètre de production retouché.

Visuellement sûr à expérimenter après GO : albedo/roughness et variation de surface sans déplacement autoritaire, ressources shader locales conservant vertex/masks d’excavation, éclairages locaux, static jacket/props hors zone de travail. Ne pas occlure les cibles ou laisser une silhouette statique prétendre être excavable. Blender n’écrit jamais hauteurs, plafonds, picking, exposition/film, fracture logique ou progression. Préserver le motif/densité Bone Film : commencer par couleur/propriétés uniquement. Vérifier lisibilité et précision avant de promouvoir une ressource hors scène isolée.

## Périmètre préparé pour la mission Hero Lookdev

1. **Matières** : Clay, Sandstone, Soil, Bone et plâtre ; séparation, couleurs/roughness, détail tactile méso/micro ; Soil mince et dépôts irréguliers conservés.
2. **Jacket statique** : première coque plâtrée irrégulière, rebords imparfaits autour du cœur dynamique, sans pouvoir d’édition ou de picking.
3. **Lumière** : chaleur de lampe, profondeur des creux lisible, aucun rendu excessivement sombre.
4. **Cadrage limité** : assez de table/support pour juger le patch ; fossile dominant, pas d’atelier complet.
5. **Boucle de comparaison** : captures cadrées de manière contrôlée face aux rôles 01/02/00, états intact, brossé, excavé, Bone sale/propre, zooms actuels. Nommer les écarts visuels puis itérer ; gameplay prime. Mesurer le coût du vrai patch une fois créé.

`docs/dev/P6A2_HERO_LOOKDEV_BRIEF.md` **absent** lors de l’audit. Aucun blocage de préparation : cette mission, le guide canonique, les décisions humaines et le périmètre ci-dessus suffisent. Le futur GO devra porter sur cette mission limitée, pas sur tout P6.

Non-objectifs : atelier complet, musée, crate/intake, plusieurs jackets/blocs, génération de spécimens, anatomie, nouveau terrain, Clay surface breakup grammar, tuning P4/P7, progression P5, film redessiné, audio, UI finale, P6B. **Même les cinq axes permis ci-dessus n’ont pas été implémentés dans le preflight.**

## Convention images/textures pour la suite

- Références approuvées : `docs/visual-references/p6a2/` ; cibles de lecture, pas matériaux runtime.
- Sources sélectionnées ImageGen/photos/peintures : futur `art/source/p6a2/images/`, original intact et nom `p6a2_<material>_<role>_vNN.<ext>`. Sources Blender : futur `art/source/p6a2/meshes/`. `art/source/.gdignore` isole les sources DCC du runtime.
- Textures traitées réellement utilisées : futur `assets/p6a2/textures/<material>/`, suffixes `_albedo`, `_roughness`, `_normal`, `_mask` ; PNG pour données/alpha, aucune compression JPEG de masks/normales. GLB statiques : futur `assets/p6a2/static/`. Matériaux Godot : futur `materials/p6a2/`.
- Chaque asset sélectionné doit avoir une note de provenance voisine : auteur/outil/version/date, prompt ou référence de génération quand disponible, sélection humaine, licence/origine, SHA256 source, transformations/crop/tiling/canaux, échelle physique, sortie et scène utilisatrice. Ne pas versionner tous les essais rejetés.
- Albedo traité comme couleur sRGB ; roughness/masks comme données linéaires, normal tangent OpenGL (+Y). Pas de lumière/ombres cuites involontaires dans l’albedo. Import Godot contrôlé pour repeat/filter/mipmaps adaptés aux UV/zoom ; `.import` versionné, `.godot/` non versionné. Vérifier les canaux réellement consommés et l’absence de double conversion couleur ; un source-image généré n’est pas directement un set PBR.
- Ne créer ces dossiers/contenus qu’au premier asset utile. Aucune bibliothèque factice, nouvelle texture ou génération réalisée ici.

## Outils optionnels, risques et clôture

Meshy/Tripo restent des accélérateurs éventuels de bases **statiques**, jamais une dépendance ou une autorité de gameplay. Krita/Photoshop attendent un besoin concret de nettoyage/paintover. Audio et outils associés attendent une phase ultérieure. Aucun outil optionnel installé.

**Aucun blocage technique restant identifié.** La preuve couvre un GLB simple, pas les futurs matériaux complexes, UV de jacket ou leur qualité/performance. Ces points se vérifient pendant le lookdev. La géométrie reste provisoire par décision humaine ; l’amélioration Clay différée n’est pas un prérequis. Le chemin Godot devra être reconfiguré si l’installation est déplacée. Ces limites ne bloquent pas le lancement de la mission limitée.

**READY** pour soumettre la suite à Antoine. P6A2 Hero Lookdev attend son **GO explicite** ; aucun merge de PR #9 et aucune implémentation Hero Patch automatique.
