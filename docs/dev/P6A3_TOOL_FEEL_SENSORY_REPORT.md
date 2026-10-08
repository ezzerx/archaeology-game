# P6A3 — Tool Feel & Sensory Pass

Livraison du 8 octobre 2026. Ce rapport décrit la réalisation et les preuves ;
le [statut canonique](../brain/status.md) définit le gate humain.
La qualité sensorielle reste à juger en jouant.

## Architecture et périmètre

`scenes/p6a3_tool_feel.tscn` hérite du Hero P6A2 accepté. Assemblage mince dans
`scripts/p6a3/tool_feel.gd`, consommateur de présentation dans `sensory_feedback.gd`.
Les seules extensions partagées sont des factories de feedback/audio et la pose
visuelle. Le défaut P5/P6A2 reste inchangé. Aucun moteur de fouille dupliqué.

Géométrie B P6A1.6, Soil fragmentée, Clay v02, Sandstone, jacket, caméra, picking,
plafonds Bone, Condition, protection du premier contact, Film, débris persistants,
Exposure/Cleanliness et règles P5 sont conservés. Physique **60 Hz**, cap **240 FPS**.
F12 compare art/lampe/motions/VFX/audio sur le même état de fouille, sans reset.

La branche a été synchronisée sur `73f0e31` avant ce travail. Les notes locales
précédentes ont été préservées ; les modifications utilisateur de `project.godot`,
de l'import Plaster et les UID antérieurs hors mission ne sont pas incluses.

## Outils et Tripo Studio

- Godot **4.7.2.stable.official.ed1daf0bf** :
  `%USERPROFILE%/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`.
- Blender **5.2.2 LTS**, portable/headless :
  `%LOCALAPPDATA%/Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe`.
- Microsoft Playwright MCP **0.0.83**, extension officielle **0.4.0**, Node **24.18.0**,
  Chrome **154.0.8037.98**. Tripo Codex **0.2.3** / CLI **0.5.1** reste installé.
- L'API avait 0 crédit ; la livraison utilise **Studio Max**, autorisé explicitement
  par Antoine. Solde affiché **25 070 → 24 675**, soit **395 crédits dépensés**.

Les quatre JPEG individuels approuvés, 1254², ont été utilisés en **image-to-3D
H3.1**, géométrie + textures/PBR. Aucun remplacement text-to-3D, aucune texture 8K,
aucune génération par parties, aucun appel Meshy. Lampe existante récupérée dans
l'historique d'Antoine, donc aucune nouvelle génération de lampe.

| Asset | Projet Studio | High : triangles | Smart Mesh P1.0 : cible → résultat | Runtime final |
| --- | --- | ---: | ---: | ---: |
| Brush | `351d5df0-8edc-4d30-b1f4-87b6d7dfb7aa` | 1 871 676 | 12 000 → 10 897 | 10 897 |
| Chisel | `7c8a9054-c6b5-432c-8e30-081859ae9515` | 1 933 666 | 8 000 → 7 235 | 5 585 |
| Pick | `f3a891dd-cd83-4b6d-8d11-470f052888f8` | 1 937 847 | 7 000 → 9 226 | 9 226 |
| Blower | `52391ae6-ac8b-47cf-b09d-3aaba4168b74` | 1 987 658 | 15 000 → 14 472 | 14 472 |
| Lampe | `f32be606-c368-40ad-9de7-92d58af179b9` | 1 940 580 | 20 000 → 19 324 | 19 324 |

Coût observé : **4 × 55 génération + 5 × 35 retopo Triangle**. Les cibles ne sont
pas des comptes exacts ; Pick reste dans son budget indicatif de 5–10k.
Les tâches payantes ont été soumises entre 16:21 et 16:49 UTC, en entrelaçant les
exports/nettoyages. Ce créneau inclut les contrôles et n'est pas une mesure pure
de latence serveur. Aucun retry payant aveugle ou doublon constaté.

[Provenance, empreintes et paramètres](../../art/source/p6a3/meshes/tripo/provenance.json).
Les dix GLB sources sont conservés. Le master Blower est le GLB officiel du viewer,
compressé `EXT_meshopt_compression` : import Blender vérifié à **1 987 658 triangles**.
Les liens temporaires du convertisseur ne sont pas des références durables.
La [politique commerciale Tripo](https://www.tripo3d.ai/help/privacy-policy/how-to-use-tripo-models-commercially)
prévoit usage commercial/modification/distribution des sorties d'un plan payant ;
les droits sur les images d'entrée restent distincts. Aucun secret ni lien signé
n'est versionné.

## Workflow accéléré et reproductible

`tools/p6a3/prepare_studio_upload.py` prépare l'upload mémoire du JPEG approuvé.
Cette voie évite le refus Chrome `DOM.setFileInputFiles` rencontré avec un chemin
local. Un onglet Codex distinct évite que l'inspection d'Antoine change la cible.
Avant chaque opération payante : UUID du modèle, options, cible et prix visibles
vérifiés ; après soumission, lecture du statut/solde, jamais de double clic spéculatif.
Les actions utilisent les contrôles DOM Studio via Playwright.

L'export vérifie le fichier réel et son en-tête GLB, sans attendre exclusivement
l'événement `download` que l'extension ne transmet pas toujours. Si Chrome ne
matérialise pas un export, seule son URL officielle déjà observée dans la réponse
Studio est récupérée, puis validée. Pour un lien expiré : renouveler la lecture ;
ne pas relancer de génération. Les sources deviennent immédiatement locales.

**Limite honnête :** la génération/retopo est désormais praticable, mais les menus
Studio, historiques et exports restent moins fiables qu'une API. Certains clics
et exports ont encore demandé un diagnostic. Ce n'est pas une promesse de pipeline
sans intervention ; Blender et Godot en aval sont entièrement scriptables.

## Nettoyage Blender et budgets

`tools/p6a3/build_runtime_assets.py -- <brush|chisel|pick|blower|lamp>` exécuté par
Blender régénère les cinq `.blend` éditables et les GLB runtime. Unités mètres,
Blender Z-up → Godot Y-up, transformations appliquées, UV/normales/PBR conservés,
pivots de contact, aucune collision ni lumière importée. Les tools restent des
meshes rigides continus : pas de jointure artificielle tip/manche.

Les faces avant/arrière/profil/dessus ont été rendues puis inspectées ; les vues
1×/3× dans Godot contrôlent la silhouette utile. **Antoine a repéré une double lame
sur le Chisel Tripo.** Le nettoyage retire la branche miroir, recentre et amincit
la lame restante, ferme les coupes et recalcule les normales. Les UV conservés
restent ceux de la branche source ; le master défectueux est conservé comme preuve.
Le Chisel corrigé a une seule lame de face comme de profil.

Textures runtime : **un jeu PBR 1024² par asset**, trois images (albédo, normale,
metal/roughness), donc 15 images. Sources 2048² conservées dans les GLB. Aucun bake
supplémentaire high→low nécessaire : Smart Mesh a fourni les textures transférées.
Le script conserve ce transfert, réduit la résolution, et exporte les matériaux.
Cinq GLB runtime : environ **25,8 MiB**, **59 504 triangles** tous assets réunis ;
un seul outil est visible. Lampe + outil le plus dense : **33 796 triangles**.
Godot extrait aussi les quinze PNG incorporés vers le dossier modèles pour leur
import : copies runtime versionnées avec leurs `.import`, environ 23,5 MiB
supplémentaires sur disque, sans quinze textures GPU supplémentaires.
Budget texture théorique avec mipmaps : environ 10–20 MiB en BC1/BC5/BC7 selon
canaux, jusqu'à 80 MiB en RGBA8 non compressé. Ce ne sont pas des mesures VRAM.

## Lampe

Métal patiné, articulations laiton, abat-jour crème : le modèle existant Studio
remplace le placeholder uniquement dans P6A3. Sa base et son abat-jour sont réduits,
son bras inférieur allongé dans Blender pour rapprocher l'ouverture de la source
lumineuse sans masquer une grande partie du bloc. Les UV de ce bras sombre sont
étirés ; cette adaptation reste visible dans le `.blend` et le script.

La SpotLight garde **exactement** sa position `(-0.45, 0.80, -0.30)`, orientation,
puissance, couleur, portée et ombres P6A2. Aucune nouvelle lumière ; art de lampe
sans collision ni ombre projetée, comme le placeholder. Carnet et pot existants
conservés. Le cadrage interactif n'est pas changé. La capture « overview » est
une vue documentaire plus large, clairement séparée du 1× jouable.

## Mouvements par outil

`scripts/p6a3/sensory_feedback.gd` consomme les événements natifs et le hit validé
du contrôleur. Aucun délai ou wind-up n'est ajouté aux entrées.

| Outil | Présentation ajoutée |
| --- | --- |
| Brush | Petite pression et balayage angulaire continu autour du contact réel |
| Chisel | Recul court de 6 mm maximum, retour en 140 ms et petite rotation ; déclenché au tick de l'impact natif |
| Precision Pick | Jab/recul plus fin de 1,8 mm maximum et rotation réduite |
| Air Blower | Vibration légère et contraction visuelle de 2,5 % pendant l'activation |

Les outils rigides restent référencés au vrai hit ; au maximum 12 sondes de
surface redressent Brush/Chisel/Pick dans les cavités. Blower reste au-dessus de
la surface avec sa buse visible. Aucune anatomie cachée ne sert au placement. Les animations ne changent ni picking,
ni puissance, ni cadence. Hors bloc, sous l'UI ou après perte de focus, le contact
cosmétique s'arrête. Une frappe sans retrait fait encore bouger l'outil, sans
inventer une fracture structurelle.

## Réactivité et VFX

Deux petits meshes de shards fermés de 12 triangles remplacent les cubes des
particules transitoires : Clay aplatie, Sandstone plus anguleuse. Rotation,
proportions, vitesse et durée varient avec une graine locale, sans toucher à la
graine ou au système de fracture gameplay. Le bruit visuel reste borné : pools
de **160 grains/éclats Clay, 128 shards Sandstone, 128 poussières**, soit 416 maximum.
Les débris persistants, leurs collisions simplifiées et leur nettoyage restent P4.

| Interaction | Réponse |
| --- | --- |
| Brush → Soil | Grains de 0,8–2,6 mm + poussière fine, cadence cosmétique limitée ; pilotés par le Soil réellement retiré même quand le hit post-édition est déjà Clay |
| Brush → Clay | Petit frottement/puff terracotta même sans événement de retrait ; **aucun retrait Clay**, aucune poussière ajoutée aux données gameplay |
| Chisel → Clay | Majorité de petits éclats plats, quelques flocons plus larges, directions divergentes et bref puff |
| Chisel → Sandstone | Shards plus anguleux, grain brun minéral et poussière sèche |
| Pick → matrice | Au plus trois petits éclats par impact et poussière localisée |
| Pick près de Bone visible | Un éclat fin et un puff réduit ; seuls les pixels Bone déjà exposés sont consultés, jamais l'anatomie cachée |
| Blower | Soulèvement natif conservé, complété par quelques poussières entraînées par le jet quand il nettoie effectivement du mess |
| Brush → Bone Film | Fines poussières sales uniquement quand le film est réellement retiré ; masque, vitesse de nettoyage et Condition inchangés |

La poussière reçoit la task light acceptée, avec albédo atténué et spéculaire nul
pour éviter les nuages lumineux. Le volume des paquets soufflés est réduit
visuellement ; la quantité de poussière gameplay retirée ne change pas. Les éclats durent environ 0,25–0,72 s,
avec un rebond visuel borné et une réduction finale ; aucune particule n'écrit de
donnée de fouille ou ne possède de collider.

## Audio et provenance

Les trois MP3 ont été téléchargés depuis les liens du
[manifest source](../../art/source/p6a3/audio/README.md), validés par ffprobe et
décodage intégral ffmpeg, puis **commités avant dérivés** dans `6168a54`.
Les originaux restent byte-identiques, stéréo 44,1 kHz : 1 s Brush, 1 s Clay,
2 s Sandstone. SHA256 dans le manifest.

`tools/p6a3/prepare_foley.py` régénère les neuf WAV sous `assets/p6a3/audio/` :
mono PCM16 44,1 kHz, passe-haut léger 75 Hz, trims, fondus courts et niveau crête.
`processing.json` donne chaque plage source, durée et empreinte.

- Brush Soil : région utile 0,16–0,77 s avec raccord de 55 ms ; boucle finale
  0,555 s à −10 dBFS crête. Niveau piloté par le travail et le mouvement natifs.
- Chisel Clay : quatre extraits courts d'une même prise, environ 0,27–0,305 s,
  crête −6 dBFS ; pas quatre enregistrements indépendants.
- Chisel Sandstone : quatre extraits d'environ 0,235–0,27 s, crête −7 dBFS ; le
  bruit tardif vers 1,5 s n'est pas inclus dans les impacts.
- Choix de variante, pitch ±4 % et petite variation de niveau via le système
  existant. Huit voix one-shot ; deux voix continues Brush. Mix global P4 conservé.
- Brush sur Clay, Pick, Blower et cues Bone gardent les sons synthétiques
  provisoires. Les trois sources ElevenLabs restent des **candidats de test**,
  à juger en jeu avec le mouvement et les effets, pas une validation production.

## Tests et performances

**66 contrôles P6A3, 128 régressions P5, 0 échec.** Les huit trajectoires passent
par le ToolController natif à 60 Hz : comparaison des empreintes heightfield,
strata, Bone, plafonds, exposition, Film, fracture, poussière, Condition et session.
Même état final P6A2/P6A3 sur chaque cas. Vérifications supplémentaires : Brush
n'excave pas Clay, Film nettoyé sans dommage, picking valide, focus/UI, reset,
meshes importés avec UV/textures, budgets, absence de collider/lumière parasite.

1920×1080, Compatibility/OpenGL, RTX 5080, Ryzen 7 9800X3D, cap 240 FPS.
20 cas : deux resets et huit interactions, avant/après, caméras identiques,
120 ticks mesurés par cas après échauffement. Timings GPU fournis par Godot.

| Cas | Frame P95 avant → après, ms | GPU moyen avant → après, ms | Édition CPU P95, ms | Présentation CPU P95, ms | Draw calls P95 avant → après | Pic particules |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| reset-1x | 4.21 → 4.21 | 2.17 → 2.17 | 0.00 | 0.019 | 105 → 71 | 0 |
| reset-3x | 4.21 → 4.21 | 1.06 → 1.07 | 0.00 | 0.020 | 75 → 45 | 0 |
| brush-soil | 8.68 → 8.74 | 2.32 → 2.33 | 4.49 | 0.129 | 105 → 75 | 28 |
| brush-clay | 7.95 → 7.98 | 1.11 → 1.12 | 3.75 | 0.067 | 75 → 47 | 14 |
| chisel-clay | 4.60 → 4.68 | 1.02 → 1.03 | 4.92 | 0.185 | 57 → 55 | 70 |
| chisel-sandstone | 6.54 → 6.58 | 1.04 → 1.04 | 3.88 | 0.140 | 56 → 54 | 69 |
| pick-matrix | 4.56 → 4.56 | 1.02 → 1.03 | 1.41 | 0.088 | 53 → 51 | 22 |
| pick-near-bone | 6.55 → 6.56 | 1.05 → 1.03 | 0.64 | 0.067 | 56 → 54 | 8 |
| blower-debris | 7.05 → 7.06 | 1.04 → 1.04 | 0.47 | 0.120 | 52 → 49 | 54 |
| bone-film | 10.20 → 10.22 | 1.12 → 1.13 | 3.71 | 0.071 | 81 → 53 | 7 |

Le rendu reste environ à 4,17 ms en moyenne sous le cap. **Ce n'est pas une garantie
240 FPS constants** : les ticks d'édition font déjà monter le P95 du témoin, en
particulier Brush/Film. L'écart P95 observé est au plus 0,09 ms dans ces parcours ;
GPU moyen ajouté environ 0–0,02 ms. Le coût CPU du contact cosmétique est séparé
dans le JSON (P95 ≤ 0,025 ms). Les draw calls baissent grâce au mesh unique par
outil et au matériau unique de lampe. Pas d'optimisation prématurée du moteur.

Le compteur texture Godot total du banc vaut **108,3 MiB**. Le banc garde les
ressources des deux versions chargées pour F12 ; il ne mesure pas un delta VRAM
pur entre exécutables séparés. Les pools sont bornés à 416 particules, pics
observés ≤ 70 ici. Les budgets ne remplacent pas un test sur un PC plus modeste.

[Mesures brutes](evidence/p6a3-sensory/benchmark.json) ·
[Tests P6A3](evidence/p6a3-sensory/tests.json) ·
[Régression P5](evidence/p6a3-sensory/p5-regression.json).

## Captures et vidéo

24 captures Godot réelles, mêmes fixtures/caméras pour les huit comparaisons.
20 renders Blender documentent les faces cachées. Aucune retouche de rendu ;
JPEG documentaire et compression vidéo uniquement.

- [Vidéo avant/après, 52 s avec son](evidence/p6a3-sensory/feedback-comparison.mp4) :
  première moitié P6A2, seconde P6A3 ; huit interactions dans chaque moitié,
  60 images/s, dérivé 720p de l'enregistrement Godot 1080p.
- Chisel Clay : [avant](evidence/p6a3-sensory/before-chisel-clay.jpg) /
  [après](evidence/p6a3-sensory/after-chisel-clay.jpg).
- Chisel corrigé : [face](evidence/p6a3-sensory/chisel-front.jpg) /
  [profil](evidence/p6a3-sensory/chisel-side.jpg) /
  [arrière](evidence/p6a3-sensory/chisel-back.jpg).
- [Brush 3×](evidence/p6a3-sensory/brush-3x.jpg),
  [Pick près de Bone](evidence/p6a3-sensory/after-pick-near-bone.jpg),
  [Blower](evidence/p6a3-sensory/after-blower-debris.jpg).
- Lampe, même vue documentaire : [avant](evidence/p6a3-sensory/lamp-before-overview.jpg) /
  [après](evidence/p6a3-sensory/lamp-after-overview.jpg).
- [Vrai cadrage jouable 1×](evidence/p6a3-sensory/workbench-1x.jpg).

La capture vidéo fixe le temps d'enregistrement à 60 images/s ; son coût
MJPEG/encodage n'est pas utilisé comme mesure de performance du jeu.

## Retest humain

```powershell
.\Launch-P6A3-Tool-Feel.ps1
```

Ou ouvrir `builds/P6A3-Playtest/ArchaeologyGame.exe`. ZIP autonome :
`builds/ArchaeologyGame-P6A3-Playtest-Windows.zip`, généré par
`tools/p6a3/Export-Playtest.ps1`, hors Git. Aucun Godot requis pour le ZIP. Exécutable et ZIP décompressé vérifiés :
`P6A3 PACKED ART PASS`, outils natifs/reset PASS, sortie 0.
[Empreintes du package](evidence/p6a3-sensory/package.json).

1. 1/2/3/4 : Brush, Chisel, Blower, Pick ; clic gauche habituel.
2. R : recommencer ; molette 1×–3× ; clic droit pan ; Home vue d'ensemble.
3. Alt+Entrée : plein écran ; Échap : retour fenêtre.
4. F12 : comparer les anciens/nouveaux outils, lampe, mouvements, VFX et sons,
   **sans reset ni changement de lumière**.
5. Tester Brush→Soil puis Brush→Clay ; ce second contact doit être visible sans
   creuser. H/F9 donnent accès rapidement à la matrice nue et aux fixtures.
6. Comparer Chisel→Clay et Chisel→Sandstone : éclats, poussière, son, synchronisation.
7. Pick dans la matrice puis près de Bone ; Blower sur un vrai tas ; Brush sur Film.
8. Juger les quatre silhouettes en 1×/3×, notamment la lame unique du Chisel,
   la buse du Blower et la lampe dans la vue de travail.

## Limites et jugement proposé

- Les marques gravées/ammonites issues de Tripo ne sont pas parfaitement fidèles ;
  pas de nouveau logo canonisé. Les soies du Brush restent une masse texturée,
  sans simulation de poils individuels.
- Chisel réparé localement : la mauvaise version reste dans Studio et dans les
  masters. **Le runtime et le `.blend` corrigés sont ceux à examiner.**
- Lamp : proportions du bras adaptées au cadrage, UV étirés sur cette portion ;
  pas de câblage animé. Une petite projection de l'abat-jour sur la périphérie
  haute reste visible ; aucun collider ne bloque le picking.
- Clearance des outils = 12 sondes de surface, pas une simulation de main ni une
  collision physique exhaustive ; vérifier les excavations extrêmes au retest.
- Pick, Blower, Brush→Clay et signaux Bone gardent un audio provisoire. Les trois
  Foley fournis restent des candidats ; variantes = découpes d'une même prise.
- Le rendu/matériau et l'emprise de la matrice restent P6A2. Aucun gain de cadence
  d'excavation n'est revendiqué ; le ressenti de lenteur n'est pas retuné ici.

Recommandation : **soumettre cette passe au HUMAN GAME-FEEL VERDICT**. Le saut
technique et visuel est vérifiable ; « satisfaisant à jouer » ne peut pas être
canonisé par les tests. Les éventuelles corrections doivent partir du jeu réel.
