# P6A3 audio source candidates — pre-production manifest

Status: **test candidates for in-game P6A3 evaluation, not final audio**.

Human direction:
- target realistic, satisfying, tactile Foley;
- “ASMR” is **not** the literal style target;
- sounds must represent the physical action/material correctly and remain pleasant over repeated gameplay.

## Candidate A — Brush on Soil

Provider/model: ElevenLabs Sound Effects v2  
Generation ID: `QPuCrki4OAea61nRDemH`  
Flow ID: `Qe77oBdo7EaMcGYa3YGy`  
Observed duration: ~1 s

Prompt:

> Realistic close-recorded Foley of a soft natural-bristle fossil preparation brush sweeping loose dry soil from compact clay. Fine dirt grains and tiny crumbs shifting under the bristles, light dry friction, natural and satisfying, short and clean. No music, voice, ambience, exaggerated whoosh, cinematic impact or heavy reverb.

Human verdict: promising enough for real in-game testing.

## Candidate B — Chisel on Clay

Provider/model: ElevenLabs Sound Effects v2  
Generation ID: `Quck9U93MWiSTqM3Bhoy`  
Flow ID: `jRLDUwFaS2sqxNgoT0ro`  
Observed duration: ~1 s

Prompt:

> Realistic Foley of one precise paleontology chisel strike into compact dry terracotta clay. Short dense earthen knock, small brittle crack, a few tiny clay chips and powder falling immediately after impact. Natural, controlled and satisfying. No music, voice, ambience, metallic ring, huge rock break or cinematic boom.

Human verdict: promising enough for real in-game testing.

## Candidate C — Chisel on Sandstone, corrected

Provider/model: ElevenLabs Sound Effects v2  
Generation ID: `Lm2AZSFpp1rNU0ntpWwj`  
Flow ID: `Zy8fcjiR712MLwwMHVGx`  
Observed duration: ~2 s

Prompt:

> Realistic Foley of one precise paleontology chisel strike into compact sandstone. The sound is dominated by dry stone: a short mineral crack, gritty fracture, tiny angular rock chips and dust falling. Only a very faint dull steel contact at the start, with no ringing. Absolutely no metallic rattling, no coins, no metal container resonance, no clatter. Short, controlled, satisfying game SFX.

Reason for correction: the earlier candidate sounded like metal pieces rattling inside a metal container rather than a tool breaking sandstone.

Human status: candidate to test in game.

## Integration policy

- Preserve original downloaded source files when materialized.
- Runtime variants may be trimmed/normalized for gameplay.
- Chisel/Pick interactions should normally be short one-shots.
- Brush/Blower may later use short layered/loopable textures where appropriate.
- Use variation/randomization rather than one identical sample repeated indefinitely.
- Final audio direction is judged in context with animation and VFX, not in isolation.

## Transfer sources for P6A3 kickoff

The three user-confirmed MP3 files are available for Codex/Astra to download and place in the repository at kickoff.

| Interaction | Source transfer URL | Expected repo filename |
| --- | --- | --- |
| Brush → Soil | https://at.adobe.com/LzARPDV356QENcWv | `art/source/p6a3/audio/raw/brush_soil_test_v01.mp3` |
| Chisel → Clay | https://at.adobe.com/Tg65GioG7dbxIhcu | `art/source/p6a3/audio/raw/chisel_clay_test_v01.mp3` |
| Chisel → Sandstone | https://at.adobe.com/v0uHdvKgvzoHW4HV | `art/source/p6a3/audio/raw/chisel_sandstone_test_v01.mp3` |

User-confirmed original mapping:
- `content.mp3` = Brush → Soil
- `content (1).mp3` = Chisel → Clay
- `content (2).mp3` = Chisel → Sandstone

At P6A3 kickoff, Codex should:
1. download the three files from the transfer URLs above;
2. verify they are valid MP3 audio;
3. rename them to the expected repo filenames;
4. preserve them as raw/source test audio;
5. commit them before integrating runtime derivatives.

Do not treat these transfer URLs as permanent production storage. The repository copies become authoritative once materialized.

## Sources materialized — 2026-10-08

The three original transfers are preserved byte-for-byte under `raw/`. All identify
as MP3, stereo, 44,100 Hz with ffprobe; full ffmpeg decoding completed without errors.
No trimming, normalization or re-encoding was applied to these source files.

| Source | Duration | Bytes | SHA256 |
| --- | ---: | ---: | --- |
| `raw/brush_soil_test_v01.mp3` | 1.000 s | 34306 | `af94e9f6c1f54341819d409c037dec5b27d2302566df17343e5080c85bb6c7b6` |
| `raw/chisel_clay_test_v01.mp3` | 1.000 s | 34306 | `41a79bf2aebaf706cf51ee1aa17fcf3b54b0cf1975adb5f8f835cf22ff502e95` |
| `raw/chisel_sandstone_test_v01.mp3` | 2.000 s | 50188 | `dbb81322c0dbce1f6ca8796e758fa6b5e29965d986c7bf81c00967d25c959c00` |

These remain test candidates for the combined in-game human game-feel review.
