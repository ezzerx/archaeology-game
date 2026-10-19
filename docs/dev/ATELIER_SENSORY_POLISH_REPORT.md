# Atelier — passe visuelle et sonore

## Mandat du 19 octobre 2026
Antoine demande une amélioration de la version existante par Technical Artist,
Godot Shader Developer et Game Audio Engineer, sur une branche séparée avec
PR draft et sans merge. Ses trois images fixent la direction : laboratoire
chaleureux de musée d’histoire naturelle, bois/laiton/toile, matière minérale
crédible, lumière de préparation et sons tactiles. Le niveau « AAA » exprime
une attente de finition et d’envie de jouer, pas une promesse de photoréalisme.

Base : `origin/main` 04a8406. Branche : `codex/atelier-sensory-polish`.
Livraison runtime : `0bc84f3`. PR draft [#55](https://github.com/ezzerx/archaeology-game/pull/55), non fusionnée.
La PR arrivages #54 est indépendante et n’est pas intégrée à cette passe.
La demande explicite autorise cette nouvelle mission ; les anciens arrêts
historiques ne sont pas interprétés comme un refus de cette demande.

## Périmètre
- Atelier réel et ses trois préparations : terre compacte, sédiments marins,
  concrétions ; aucun nouveau système de jeu.
- Matières et éclairage, détails périphériques qui laissent le bloc lisible.
- Son des outils et ambiance discrète, sans modification de leur cadence.
- Géométrie excavable, cartes et masques d’exposition, film, Condition,
  paramètres outils, progression et archivage conservés.
- Captures natives comparables ; contrôles déterministes et tests existants.

## Équipe et livraison
- Technical Artist : mise en scène et accessoires ; notes techniques dédiées.
- Godot Shader Developer : matières / lumière ; notes techniques dédiées.
- Game Audio Engineer : son et mix ; notes techniques dédiées.
- Orchestration : intégration, captures, non-régression et PR.

Lancement local : `Launch-Atelier-Polish.cmd` (Godot 4.7.2).
La validation artistique, le plaisir sonore et les performances perçues restent
à juger par Antoine dans la version jouable. Tests verts ≠ validation humaine.

## Preuves
Les captures `before-*` sont prises depuis la base inchangée, même fenêtre,
caméra et trajectoires de gestes que les captures `after-*`.
Le parcours de capture utilise les vrais outils sans fixture de révélation.
Les contrôles automatisés n’écrivent pas dans les sauvegardes du joueur.

Résultats et limites de la version intégrée figurent ci-dessous.

Le système d’approbation automatique a refusé la création d’une issue supplémentaire. La mission conserve le périmètre expressément demandé : branche séparée et PR draft, sans création d’issue et sans fusion.


## Résultat livré
L’atelier reçoit une toile cousue, un plateau avec les modèles d’outils existants,
un carnet illustré, des livres de muséum, un pot inventorié et une lampe. Une
variante adaptée à l’empreinte M–08 garde les accessoires dans son cadrage,
sans changer la caméra. Deux ensembles statiques de 42 322 triangles, 14 surfaces
par instance, réutilisent les textures des outils et un nouvel atlas de papeterie.

Les matières reçoivent un relief normal et une rugosité issus du grain déjà
échantillonné. L’argile perd son orange excessif ; le bois devient un noyer plus
sobre. Les trois lumières existantes sont rééquilibrées, avec ombres obliques
chaudes et remplissage neutre. Anticrénelage MSAA 4× activé. Aucune carte de
hauteur, visibilité des os ou propriété mécanique n’est modifiée.

La banque originale compte 23 sons : impacts argile/grès et Pick variés,
frottements de brosse, souffle continu, abrasion et fond discret de pièce.
Les alertes Bone historiques sont conservées. Les bus permettent le choix
« outils + ambiance », « outils seuls » ou « coupé » ; le Master reste intact.
La préparation suspendue arrête ses outils et met l’ambiance en pause.

## Revue et limites
Les captures ont conduit à deux corrections avant livraison : papier et métal
initialement trop clairs, puis toile trop grande pour le cadrage M–08. Les
captures finales sont des images natives du jeu, sans retouche. Le terrain,
la géométrie en gradins des coupes, les interfaces existantes et les écrans
collection/musée ne sont pas refondus. La proximité des références est une
direction de finition, pas une équivalence photoréaliste acquise.

L’audition `work/audio/atelier-audition.wav` est un montage hors jeu de 24 s.
L’enregistrement du mixeur natif a bloqué à la récupération du flux ; aucun
enregistrement de partie ni mesure de crête du mix final n’est revendiqué.
Les sources, enveloppes, importeurs, polyphonie et vrais événements sont testés.
Le timbre, le confort à long terme et le niveau d’ambiance attendent une écoute
humaine, idéalement au casque puis sur enceintes.

Les oracles d’images tolèrent un seul niveau de couleur sur 255 : les résolutions
MSAA diffèrent parfois d’un arrondi selon les lots dessinés. Le curseur et les
VFX transitoires sont exclus de l’oracle d’archivage, puisqu’ils ne doivent pas
être enregistrés dans la collection. Les cartes de gameplay sont comparées
par leurs empreintes exactes, sans tolérance.

## Essai humain proposé
1. Ouvrir `Launch-Atelier-Polish.cmd` et parcourir les trois préparations.
2. Observer l’ensemble, zoomer sur une coupe et vérifier la distinction des
   matières et des os sous la nouvelle lumière.
3. Comparer Brush, Chisel, Pick, souffle et pointe abrasive ; essayer les trois
   modes de son. Juger notamment un brossage prolongé et le relâchement du souffle.
4. Confirmer ou refuser la direction artistique et sonore sur la PR draft.
   Aucun merge n’est autorisé par les seuls tests ou par cette livraison.

## Reproduire les contrôles
Avec `$Godot` pointant vers Godot 4.7.2 et le dépôt comme répertoire courant :

```powershell
& $Godot --headless --editor --path . --import
& $Godot --headless --path . --script tests/run_runtime_resources.gd
& $Godot --headless --path . --script tests/run_atelier_audio.gd
& $Godot --headless --path . --script tests/run_atelier_audio_routing.gd
& $Godot --headless --path . --script tests/run_issue28_storage.gd
& $Godot --path . --rendering-method gl_compatibility --script tests/run_atelier_sensory.gd -- --qa --distinction-store=res://work/sensory/distinctions.json
& $Godot --path . --rendering-method gl_compatibility --script tests/run_issue43_fluidity_replay.gd -- --qa --label=after --reference=res://docs/dev/evidence/atelier-sensory/before-replay.json --distinction-store=res://work/sensory/distinctions.json
```

La référence `before-replay.json` a été capturée sur main 04a8406 avant les
modifications. L’ancienne fixture issue43 reste intacte ; elle a un hash de
hauteur différent dès cette base et n’est pas remplacée silencieusement.
Le paramètre `--reference` permet de choisir explicitement la comparaison.

## Captures comparables

| Préparation | Avant | Après |
| --- | --- | --- |
| Terre compacte B–17 | [Vue initiale](evidence/atelier-sensory/before-0-covered.png) | [Atelier final](evidence/atelier-sensory/after-0-covered.png) |
| Sédiments marins M–08 | [Vue initiale](evidence/atelier-sensory/before-1-covered.png) | [Atelier final](evidence/atelier-sensory/after-1-covered.png) |
| Concrétions M–08 | [Vue initiale](evidence/atelier-sensory/before-2-covered.png) | [Atelier final](evidence/atelier-sensory/after-2-covered.png) |

Les fichiers `before/after-*-working.png` du même dossier montrent les mêmes
trajectoires de gestes dans chaque préparation. L’audition originale de 24 s et
son minutage sont conservés à côté, explicitement étiquetés comme montage hors jeu.

## Résultats finaux
- Chargement : **325 ressources/scripts, 0 échec**.
- Son : **56 contrôles backend + 22 contrôles de routage, 0 échec** ;
  22 PCM et ambiance Vorbis contrôlés ; génération reproductible.
- Stockage des collections : **18 contrôles, 0 échec**.
- Rendu, masques et restitution sérialisée : **27 contrôles, 0 échec**
  sur les trois familles (tolérance de rendu 1/255 décrite ci-dessus).
- Replay : **38 contrôles, 0 échec** ; données et volumes retirés identiques
  au main capturé avant cette mission sur les 14 étapes outil/famille.
- RTX 5080 / Compatibility / 1440 × 810 / MSAA 4× : médiane au repos
  **4,166 ms** dans chaque préparation, P95 **4,20–4,21 ms**. Ces mesures
  prouvent ce parcours et cette résolution, pas un maintien garanti à 240 FPS
  sous toute excavation ou sur d’autres machines.

Détails reproductibles et résultats : `docs/dev/evidence/atelier-sensory/`.

Le parcours natif d’activité ajoute **20 contrôles, 0 échec** : suivi du curseur
et gestes Brush, Chisel, Pick, souffle, abrasion sur les trois familles.
Moyennes par segment **150,9–240,6 FPS** à 1440 × 810 ; des pointes de frame
subsistent (voir `active-runtime.json`), ces moyennes ne promettent donc pas une
latence constante. Le minimum concerne le souffle marin dense (P95 17,05 ms), un point de suivi à conserver sous #50 ; cette passe ne prétend pas le résoudre. Le log signale également une invalidation du périphérique
WASAPI pendant la fin du test ; il n’est pas utilisé comme preuve d’écoute.
