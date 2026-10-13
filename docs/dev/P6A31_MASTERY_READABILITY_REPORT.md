# P6A3.1 — Mastery & Bone Readability

Date: 2026-10-13. **Candidate for Antoine's human review; not final art approval.**
Authorization: explicit request to merge PR #9 and start P6A3.1. Baseline is merge
`32a85ba9` containing P6A3 head `b91ff24`.

## Play

Godot 4.7.2 stable: `scenes/p6a31_mastery_readability.tscn`.
Windows editor launch: `Launch-P6A31-Mastery.ps1 -GodotBin <4.7.2 console binary>`.
F7 switches P6A3/P6A3.1 readability without resetting the specimen. F12 retains
P6A2/P6A3 authored-tool comparison. H opens the comparison panel.

The native main scene and historical P6A3 candidate remain unchanged. No automatic
promotion of this new candidate to the project main scene or merge is implied.

## Changes

- At internal >=99%, player-facing Reveal/Clean resolve to 100 only with the
  current hidden-cluster coverage guard satisfied. Below that, percentages still
  floor; 84.99 and 94.99 never advertise the 85/95 milestones. The live bars and
  archive summary use the same display rule. Raw session/archive metrics and
  latched Museum Standard/Fine Preparation rules remain exact and unchanged.
- Chisel circle uses 55% of its prior visual radius; actual P6A3 Chisel remains
  Radius 26 / Power .84 / Falloff 2.25. Other tool markers keep their radius.
- A small Condition gauge consumes the existing global 0–100 value while keeping
  Excellent/Good/Fair/Damaged. Its tint follows the same canonical tier cutoffs.
- Fixed irregular surface seams become visible progressively as actual global
  Condition decreases. This is cosmetic wear on exposed Bone, not local hit
  damage, missing Bone geometry, or a second damage state. Hidden Bone never
  receives a visible overlay; reset restores undamaged presentation.
- Weak residual Film uses a nonlinear opacity curve, keeping the original patch
  pattern and exact dirty-cell mask. Exactly clean stays exactly clean. No Film
  amounts, removal speed, cleanliness denominator, or original material identity
  are changed.
- Fine localized dust follows a real Brush Film-removal event, including stationary
  strokes and edge cleaning. Native Film exposes one strongest-removal cell as
  presentation metadata; an event forwards it. No-op cleaning resets the metadata
  and emits no removal puff. Emission is throttled, uses the existing bounded pool,
  and does not add persistent residue or affect Condition.

## Browser delivery

Owner-private link (Sites deployment succeeded):
https://archeology-private-playtest.toitou2.chatgpt.site
Site `appgprj_6ace1afd5f2c81919e82f40e93b3ef32`, static source
`09e5627ad2a7cda314dbc33c4ef4955501601a8d`, deployment
`appgdep_6ace22914988819186e7fd862be1e94b`.

The private page requires the owner’s ChatGPT sign-in; game assets remain behind
that access boundary. No public sharing is enabled.

Actual Godot 4.7.2 Web export, single-threaded Compatibility/WebGL2, no GDExtension.
`tools/p6a31/export_web.py` stages runtime files and selects this scene without
editing project.godot. Requires official matching `web_nothreads_release.zip` and
`version.txt`, then packages the export through `package_web.py`.

The WebAssembly and PCK are transported as compressed <=8 MiB parts for static
hosting. The loader reconstructs the exact original bytes and checks SHA-256
before returning them to the engine. This changes asset transport, not gameplay.
Initial compressed download is about 55 MB. No game installation is required;
Chrome/Edge with WebGL2 on desktop and a mouse are recommended. Browser data can
cache local display preferences. Source/licence notices are included.

Site is owner-private, requested explicitly by Antoine. Source helpers described
by the Sites skill are absent in this executor; equivalent source synchronization
uses Git with credentials supplied through hidden stdin and environment-only
headers, followed by an archive of the exact pushed static content. No credentials
are stored in files or printed.

## Validation

- Official Godot `4.7.2.stable.official.ed1daf0bf`, Linux.
- P5 regression: **128 checks, zero failures**.
- P6A3.1: **127 checks, zero failures**, including original P6A3 native trajectories
  with byte-identical gameplay states in eight cases, 99% boundary/coverage checks,
  raw snapshots/archive, compare/reset, actual removal source, no-op dust, gauge,
  native Condition and unchanged Chisel effect radius.
- Native graphical comparison: original six captures / **8 checks, zero failures**.
  **Targeted true 94%-cleanliness comparison: 5 checks, zero failures**,
  with before/after screenshots preserving exact Film/geometry. Evidence is under
  `docs/dev/evidence/p6a31/`. Browser startup and actual game rendering were
  observed in Chromium/Mesa; software-GPU automation can time out during capture.
  Work-PC input/audio/feel and browser performance still need human review. Software rendering measurements do not establish RTX 5080
  performance, work-PC performance, or human audio/feel approval.

## Human retest

1. Pursue displayed 100/100; check real missing anatomy still blocks full completion.
2. Near 94% Cleanliness, locate dirty patches visually and clean them with Brush.
3. Brush stationary/at the edge of dirty Bone: see a fine removal puff; repeat on
   clean Bone: no false cleaning puff.
4. Check the smaller Chisel marker feels precise with its original work radius.
5. Hit exposed Bone repeatedly: first protected contact stays protected; subsequent
   damage lowers the gauge and progressively shows wear. Brush/Pick stay safe.
6. Archive/Keep Cleaning/reset, focus loss, zoom and pan still behave as before.
7. F7 compare without reset, then give separate readability/visual/feel feedback.

## Sound decision

Antoine selects Claude instead of ElevenLabs for the dedicated sound pass, after
his own positive tests. **No sounds are generated or replaced in P6A3.1.** Historical
ElevenLabs provenance remains truthful; current original runtime audio is retained.

Deferred: B-17 true 3D fossil mesh, sound/music production, interactive lamp,
jacket/footprint, Clay breakup, Sandstone tuning, new tools, museum/meta, P6B/P7.

## Browser verification limit

Chromium/Mesa produced the actual rendered game. Subsequent software-GPU
automation also encountered `CONTEXT_LOST_WEBGL` and blank captures, without
failed asset requests or JavaScript exceptions. This is a failed interaction
verification, not a passed Web playtest. Cause is not established; a GPU watchdog
during slow software rendering is being checked. The private link is a candidate
for testing on Antoine’s hardware, not a claim of stable browser performance.

The Web shell now handles lost GPU contexts with an explicit reload screen.
This prevents silent blank playtests; it does not claim to cure the GPU failure.

## Human work-PC trial

Antoine accessed the Web game and exited after trial because of excessive lag
on his small work laptop. No frame-time capture or hardware characterization
was supplied. This confirms that this setup is unsuitable for judging the
preparation feel. Human readability/feel approval remains pending a native
test on his home PC. No automatic optimization scope is inferred.

## Review capture pack and native Windows delivery

Antoine requests annotated screenshots while away and one larger home playtest.
Actual engine-controlled capture pack: 6 additional checks, zero failures,
showing the unchanged Chisel effect radius and guarded displayed 100/100.
Screenshots use controlled native QA states, not a claim of a full recorded play.

Lightweight private review: `/review.html` on the playtest Site.
Private portable Windows download: `/native.html` on the same Site.
Official Godot 4.7.2 Windows x64 template; export completed, ZIP CRC and PE x64
header verified. **Windows executable launch is not verified in Linux**; retest
on the home PC. SHA-256/package manifest retained with Site source.
ZIP: `ArchaeologyGame-P6A31-Windows.zip` (82,954,555 bytes).
Reproduce natively: `tools/p6a31/Export-Playtest.ps1` with matching engine/templates.

Review-page image loading and mobile-width layout, plus actual browser native-ZIP
download and ZIP CRC, were verified successfully in Chromium without starting 3D.
