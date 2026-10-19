# Passe sonore atelier — notes de réalisation

## Intention

Son intime, minéral et feutré. Les outils restent au premier plan : frottement
organique du Brush, poids bref du Chisel puis petits éclats, tic précis du Pick,
souffle continu et soyeux du Blower. La pointe abrasive reçoit enfin une texture
de grain fin lorsque les concrétions sont réellement travaillées. Un fond d’air
d’atelier discret remplit les pauses, sans musique.

## Raccordement et périmètre

Le consommateur `sensory_feedback.gd::_create_audio()` instancie
`scripts/audio/atelier_audio.gd`, sous-classe de `MaterialAudio`.
Les trois préparations héritent de ce consommateur. Les événements existants
`play_family` / `update_brush` conservent leur rôle, cadence, quantité de matière
et sens scientifique. Un observateur du signal `material_action` fixe le point
3D et écoute `abrasion`; `air_jet_applied` permet au souffle de continuer sur
terrain déjà propre. Ces observateurs ne modifient aucune surface.

Le backend natif est le choix du prototype existant, derrière les noms
d’événements. Aucune intégration FMOD/Wwise n’est introduite ou revendiquée.
Les chemins d’assets sont confinés au backend audio, jamais au contrôleur outil.
L’implémentation historique et les 28 empreintes P4 restent intactes; les deux
signaux Bone (contact protégé / dommage) restent rigoureusement inchangés.

## Mix et budget

| Élément | Politique |
|---|---|
| Voix spatiales d’impacts | 6, limite 3 par famille; surplus ignoré sans couper une voix |
| Voix Bone réservées | 2, priorité supérieure; jamais prises par Chisel/Pick |
| Textures continues | 4 voix maximum; Brush utilise 2 couches pour fondre les matières |
| Ambiance | 1 voix Vorbis en boucle, pause/reprise avec la préparation |
| Limite totale du backend | 13 voix; allocation fixe au setup, aucune création par geste |
| Variations | 6 fichiers par matière d’impact, pas de répétition immédiate |
| Occlusion | 1 rayon toutes les 125 ms; arrêt avant la surface, filtre lissé |
| Réverbération | petite pièce, prédélai 18 ms, wet 7 % |
| Compression de sécurité | bus Atelier, seuil −6 dB, ratio 10:1, aucun gain automatique |

`Atelier Tools` et `Atelier Room` alimentent `Atelier`, puis `Master`.
Les préférences des bus existants et le Master ne sont jamais réinitialisés.
API : `set_tools_volume_db`, `set_ambience_volume_db`, `set_muted`.
Le HUD fournit le choix complet / outils seuls / muet dans cette passe.

Les boucles ont une attaque et un relâchement lissés et cessent lorsque
l’enveloppe est inaudible. Les changements d’outil laissent s’éteindre leur
courte queue. Un `PROCESS_MODE_DISABLED` hérité (retour collection) arrête
les outils et suspend l’ambiance; la reprise ramène le fond progressivement.
La destruction de la préparation retire toutes ses voix.

Sources : 23 assets, environ 2,30 Mio avant imports. Impacts courts en IMA ADPCM,
textures continues PCM mono, longue ambiance Vorbis. La génération s’effectue
hors jeu; seuls les deux signaux scientifiques legacy sont synthétisés au setup.
Aucune mesure sur machine modeste ni certification de budget DSP n’est revendiquée.

## Provenance et reproduction

Tout le contenu de `assets/audio/atelier/` est une synthèse originale déterministe,
sans enregistrement emprunté, service externe ni génération payante.
Voir `assets/audio/atelier/README.md` et `manifest.json`.

```powershell
python tools/audio/build_atelier_audio.py
python tools/audio/check_atelier_audio.py
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/run_atelier_audio.gd
godot --headless --path . --script res://tests/run_atelier_audio_routing.gd
```

Le nom `godot` désigne ici l’exécutable canonique Godot 4.7.2.

## Éléments de vérification

- 22 maîtres PCM + décodage de l’ambiance Vorbis : aucun échec de signal
  (crête, énergie, composante continue, raccord de boucle, attaque, silence aux
  extrémités des impacts).
- 56 contrôles backend : import ADPCM/PCM/Vorbis, boucles et relâchement,
  absence de répétition immédiate, polyphonie saturée, priorité Bone,
  empreintes scientifiques, mix/mute conservés et suspension/reprise.
- 22 contrôles de routage sur les trois préparations : vrais gestes de Brush,
  Chisel, Pick, souffle sur surface intacte et abrasion. L’accès aux concrétions
  se fait par les outils existants; aucun tableau de terrain n’est réécrit.
- Écoute locale : `work/audio/atelier-audition.wav`, 24 s, ordre et temps dans
  `work/audio/atelier-audition.txt`. Montage de sons original hors jeu; ce fichier
  n’est pas présenté comme une capture de partie.
- Mesures détaillées locales : `work/audio/signal-checks.json`, `runtime-tests.log`,
  `routing.json`. Ces contrôles ne constituent pas la validation humaine du timbre.

Un essai humain au casque et sur enceintes reste nécessaire pour juger le poids
des impacts, le confort d’un brossage prolongé et le niveau du fond d’atelier.


### Limite de la capture mixeur

L’essai natif Windows a parcouru les sons et la pause/reprise, puis est resté
bloqué à `AudioEffectRecord.get_recording()` après l’arrêt de l’enregistrement.
L’essai avec le driver Dummy n’a pas donné de fichier exploitable non plus.
Les processus de test ont été arrêtés; aucun résultat de crête du mixeur ou
enregistrement de gameplay n’est revendiqué. Le harnais temporaire défaillant
n’est pas livré comme test. Le log local est `work/audio/native-mixer.log`.
L’écoute de 24 s reste une audition hors jeu des sources, au gain nominal.

Le backend utilise les paramètres documentés des
[lecteurs 3D Godot](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html)
et du [compresseur de bus](https://docs.godotengine.org/en/stable/classes/class_audioeffectcompressor.html).
