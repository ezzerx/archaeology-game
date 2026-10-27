# Museum audio

Two streamed runtime events accompany the fixed natural-history gallery.

- `museum_contemplation.ogg`: 84-second stereo music loop prepared from one
  90-second instrumental generation by ElevenLabs Music v2.
- `museum_room.ogg`: 48-second mono original deterministic room-air synthesis,
  with a few soft timber-settling details. No borrowed recording.

The music prompt asks for a warm contemplative felt-piano/chamber-string
miniature, generous space and asymmetrical phrasing. No artist, existing work,
recording or reference melody was supplied. The generated source is retained
unchanged at `source/museum_original.mp3`; the full prompt, generation ID, model
and parameters are in `source/generation.json`. The source directory is excluded
from Godot resource import by `.gdignore`. No additional generation is performed
by the local processing script.

Source generation:
[ElevenLabs flow](https://elevenlabs.io/app/flows/z6gzp7Rr13t3CIPTk3QG)
— generation `H1SzIeW1xMyOEFs8GI10`, 19 October 2026.
The connected service reported 1,350 credits / USD 0.135 for this one take.

Rebuild runtime assets and audition: `python tools/audio/build_museum_audio.py`.
Requires Python standard library and FFmpeg. This reproduces the processing
from the preserved source; it does not claim deterministic regeneration of the
ElevenLabs composition.

Music treatment: 35 Hz high-pass, 14.5 kHz low-pass, six-second raised-cosine
overlap of tail and head, DC removal, peak −5 dBFS, stereo Vorbis q5.
Room treatment: 320 ms overlap, DC removal, peak −14 dBFS, mono Vorbis q5.
`manifest.json` records PCM metrics, runtime file hashes, and source hash.

Auditions remain local in `work/audio/museum/`: nominal game mix
`museum-audition.mp3`, PCM `museum-audition.wav`, and
`museum-loop-seam.wav` (12 seconds either side of the music seam).
They are audio-design auditions, not captures of gameplay.
