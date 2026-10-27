# Musée — musique et ambiance

## Intention et livraison

La galerie accueille une musique instrumentale contemplative et un fond de salle
indépendant. La composition a été demandée comme une miniature de piano feutré,
cordes de chambre chaleureuses et longues respirations, sans percussion
insistante ni arpège mécanique. Une seule prise originale de 90 s a été générée
avec ElevenLabs Music v2, sans référence d’artiste ou d’œuvre. Le traitement
local en tire une boucle de 84 s. Le fond de 48 s est une synthèse originale
déterministe : air de salle et petits mouvements du bois, sans foule, voix ou
pas d’avatar imaginaires.

L’atelier et les sons d’outils appréciés ne sont pas modifiés.

## Architecture et intégration

`scripts/audio/museum_audio.gd` est un consommateur audio natif du prototype.
Il possède seulement deux voix réservées : musique stéréo non diégétique et
ambiance diffuse 3D. Les deux ressources Vorbis sont décodées en flux; aucune
synthèse n’est exécutée pendant le jeu. Les noms d’événements sont
`event:/Music/Museum/Contemplation` et
`event:/Ambience/Museum/GoldenRoom`.

API de la scène :

```gdscript
var museum_audio = preload("res://scripts/audio/museum_audio.gd").new()
add_child(museum_audio)
museum_audio.setup(self)
museum_audio.set_mode(0) # 0 musique + ambiance, 1 ambiance seule, 2 silence
```

`cycle_mode()`, `get_mode_label()` et le signal `mode_changed` servent au HUD.
Les choix sont conservés dans `user://museum_audio.cfg`; `--qa` ou
`persist=false` désactive cette lecture/écriture pendant les tests.

Avant le retour à l’atelier : `await museum_audio.fade_out(0.65)`, puis
transfert existant. En cas d’échec : `museum_audio.resume_after_cancel()`.
Pour le sens atelier → musée, les helpers statiques
`fade_workshop_for_handoff(tree, seconds)` et
`restore_workshop_after_cancel(tree, token)` fondent/restaurent uniquement le
gain du bus Atelier; ils conservent son mute et n’altèrent jamais le Master.
La restauration est attendue avec `await` avant de réactiver le bouton de
réessai, pour éviter deux fondus concurrents et un gain de retour intermédiaire.
Le bouton Retour de la galerie reste désactivé jusqu’à l’installation audio;
un signal précoce est également ignoré sans verrouiller le transfert.

Le transfert reste celui des deux processus / renderers validés. L’audio
n’introduit pas un nouveau système de chargement. L’ancien processus peut
s’éteindre après le fondu, pendant que la nouvelle galerie commence doucement.

## Mix, silence et confort

`Museum Music` et `Museum Room` alimentent `Museum`, puis `Master`.
Aucun gain, mute ou effet Master existant n’est changé. Les bus déjà présents
conservent leurs valeurs. Gains de voix nominaux : musique −11 dB, ambiance
−14 dB. La crête du mix d’audition encodé est −16,1 dBFS.

Les changements de mode fondent les niveaux, sans relancer la composition.
Une scène désactivée suspend ses sources; sa reprise revient progressivement.
La pause sur perte de focus est **désactivée par défaut** : Alt-Tab ne coupe pas
la musique. L’option explicite `pause_on_focus_loss=true` permet un fondu court
suivi d’une pause, puis une reprise au même emplacement.

Budget : deux voix, un flux stéréo et un mono; 2 020 080 octets de ressources
runtime (~1,93 Mio). Les résonances sont préparées dans les sources; aucun
réseau de réverbération ou compresseur temps réel n’est ajouté au musée.
La source MP3 conservée représente environ 2,08 Mio supplémentaires hors
import de ressources.

Le morceau vise une sensation non pulsée. La couture est un chevauchement
musical long et progressif; les changements d’interface sont des fondus de
volume. Aucun découpage rythmique adaptatif ni tempo exact inféré du fichier
généré n’est revendiqué.

## Provenance et reproduction

Voir `assets/audio/museum/README.md`, `source/generation.json` et
`manifest.json`. La prise a coûté 1 350 crédits selon le résultat du connecteur
(USD 0,135). Aucune seconde génération n’a été lancée.

```powershell
python tools/audio/build_museum_audio.py
python tools/audio/check_museum_audio.py
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/run_museum_audio.gd
godot --headless --path . --script res://tests/run_museum_audio_integration.gd -- --qa --exhibit-store=res://work/audio/museum/integration-empty
```

Le traitement local est reproductible à partir du MP3 original préservé;
la composition générative elle-même n’est pas annoncée comme reproductible.

## Vérifications et écoute

- 23 contrôles Godot réussis : deux voix et setup idempotent, import Vorbis
  et durées, routage, trois modes, fondus, stabilité des horloges, focus optionnel,
  suspension de scène, aller/retour de transfert et préservation du Master.
- 46 contrôles d’intégration réussis dans les deux vraies scènes, galerie
  d’étude puis galerie de préparations avec stockage QA isolé : hook et trois
  libellés, sélection HUD → mode, absence de relance ou de bus dupliqués,
  suspension/reprise, sortie à −80 dB et libération des deux lecteurs.
  Ils couvrent aussi le retour pendant le chargement et deux échecs de transfert
  via le vrai handler atelier, avec réentrée pendant la restauration.
  Les trois erreurs de création de dossier du journal sont provoquées par la
  fixture QA : un sous-dossier d’un fichier, empêchant tout lancement natif.
- Décodage des **Ogg réellement livrés** : 84,00 s stéréo et 48,00 s mono,
  crêtes −5,14 / −14,25 dBFS, composante continue inférieure à 0,00001,
  raccords dans l’amplitude normale des différences entre échantillons.
- Audition complète disponible localement : `work/audio/museum/museum-audition.mp3`.
- Couture isolée : `work/audio/museum/museum-loop-seam.wav`.
- Résultats : `work/audio/museum/signal-checks.json`,
  `work/audio/museum/runtime-tests.json` et `integration-tests.json`.

Les tests headless vérifient les ressources, commandes et enveloppes; les lecteurs
n’y démarrent pas le matériel audio. Le passage réel entre processus/renderers a ensuite été vérifié par les vrais
handlers : atelier → musée en 4,37 s, retour en 7,61 s. Le confort audible
des transitions reste à juger humainement.

Ces fichiers sont des auditions hors jeu. Le blocage connu d’export
`AudioEffectRecord.get_recording()` rencontré à la passe atelier n’a pas été
réessayé. Aucun enregistrement mixeur natif ni profil DSP n’est revendiqué.
Les mesures ne remplacent pas l’écoute humaine de la composition, de la
couture harmonique et du confort prolongé dans la galerie.
