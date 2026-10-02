class_name MaterialAudio
extends Node
## Original procedural placeholder sounds, generated once. No external assets.
const FAMILIES := [&"brush_soil", &"brush_clay", &"chisel_clay", &"chisel_stone", &"bone_revealed", &"direct_bone_hit", &"air"]
const SAMPLE_RATE := 22050
var samples: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var cooldown: Dictionary = {}
var rng := RandomNumberGenerator.new()
var profile: ReactionProfile
var played := 0
var last_family: StringName
var brush_voices: Array[AudioStreamPlayer] = []
var brush_level := 0.0
var brush_target := 0.0
var brush_clay_mix := 0.0
var _brush_clay_target := 0.0
var _brush_fresh := 0.0
var brush_starts := 0
var _brush_running := false

func setup(settings: ReactionProfile) -> void:
	profile = settings
	rng.seed = settings.seed + 51
	for family in FAMILIES:
		var variants: Array[AudioStreamWAV] = []
		for variant in range(4):
			variants.append(synthesize(family, variant))
		samples[family] = variants
	for i in range(8):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)
	for i in range(2):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		brush_voices.append(voice)

static func synthesize_brush(family: StringName, variant: int) -> AudioStreamWAV:
	var random := RandomNumberGenerator.new()
	random.seed = 1631 + variant * 17 + (71 if family == &"brush_clay" else 0)
	var count := SAMPLE_RATE * 2
	var blend_count := SAMPLE_RATE / 10
	var wave := PackedFloat32Array()
	var low := 0.0
	var slow := 0.0
	for i in range(count + blend_count):
		var noise := random.randf_range(-1, 1)
		low = lerpf(low, noise, 0.13 if family == &"brush_soil" else 0.22)
		slow = lerpf(slow, noise, 0.012)
		wave.append((low - slow) * 0.85 + noise * 0.025)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		# Overlap the tail into the head: a continuous noise texture at the seam,
		# with no repeated attack or silence between short grains.
		var value := lerpf(wave[count + i], wave[i], float(i) / blend_count) if i < blend_count else wave[i]
		data.encode_s16(i * 2, roundi(value * 32767))
	var result := AudioStreamWAV.new()
	result.format = AudioStreamWAV.FORMAT_16_BITS
	result.mix_rate = SAMPLE_RATE
	result.data = data
	result.loop_mode = AudioStreamWAV.LOOP_FORWARD
	result.loop_begin = 0
	result.loop_end = count
	return result

static func synthesize(family: StringName, variant: int) -> AudioStreamWAV:
	if family in [&"brush_soil", &"brush_clay"]:
		return synthesize_brush(family, variant)
	var random := RandomNumberGenerator.new()
	random.seed = 800 + FAMILIES.find(family) * 17 + variant
	var duration := 0.18 if family in [&"brush_soil", &"brush_clay", &"air"] else 0.24
	var count := int(duration * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(count * 2)
	var filtered := 0.0
	var previous := 0.0
	for i in range(count):
		var t := float(i) / SAMPLE_RATE
		var noise := random.randf_range(-1, 1)
		filtered = lerpf(filtered, noise, 0.13 if family != &"air" else 0.045)
		var attack := minf(t / 0.003, 1.0)
		var signal_value := 0.0
		var variation := 1.0 + variant * 0.019
		match family:
			&"brush_soil": signal_value = (0.7 * filtered + 0.17 * noise) * sin(PI * t / duration) * 0.7
			&"brush_clay": signal_value = (noise - previous) * (0.25 + 0.12 * sin(t * 640)) * exp(-t * 17)
			&"chisel_clay": signal_value = (0.42 * sin(TAU * 240 * variation * t) + 0.65 * filtered) * exp(-t * 32) + noise * 0.18 * exp(-absf(t - 0.04) * 90)
			&"chisel_stone": signal_value = (0.23 * sin(TAU * 1420 * variation * t) + 0.16 * sin(TAU * 2213 * variation * t) + noise * 0.35) * exp(-t * 36) + noise * 0.16 * exp(-absf(t - 0.065) * 120)
			&"bone_revealed": signal_value = (0.25 * sin(TAU * 3900 * variation * t) + 0.09 * sin(TAU * 5800 * variation * t)) * exp(-t * 65)
			&"direct_bone_hit": signal_value = (0.55 * sin(TAU * 1850 * variation * t) + 0.16 * sin(TAU * 2770 * variation * t) + 0.2 * noise * exp(-t * 80)) * exp(-t * 26)
			&"air": signal_value = (filtered * 1.5 + noise * 0.05) * sin(PI * t / duration)
		previous = noise
		var pcm := roundi(clampf(signal_value * attack * minf((duration - t) / 0.012, 1.0), -0.95, 0.95) * 32767.0)
		data.encode_s16(i * 2, pcm)
	var result := AudioStreamWAV.new()
	result.format = AudioStreamWAV.FORMAT_16_BITS
	result.mix_rate = SAMPLE_RATE
	result.data = data
	return result

func _process(delta: float) -> void:
	for family in cooldown:
		cooldown[family] = maxf(0.0, cooldown[family] - delta)
	_brush_fresh = maxf(0.0, _brush_fresh - delta)
	if _brush_fresh == 0.0: brush_target = 0.0
	brush_level = lerpf(brush_level, brush_target, 1.0 - exp(-delta / (0.08 if brush_target > brush_level else 0.16)))
	brush_clay_mix = lerpf(brush_clay_mix, _brush_clay_target, 1.0 - exp(-delta * 8.0))
	for i in range(brush_voices.size()):
		var level := brush_level * (brush_clay_mix if i == 1 else 1.0 - brush_clay_mix)
		brush_voices[i].volume_db = maxf(-80.0, profile.audio_volume_db + linear_to_db(maxf(level, 0.00001)))
		brush_voices[i].pitch_scale = 0.9 + brush_level * 0.2

func update_brush(speed: float, work: float, clay := false) -> void:
	# Work is a real removed/cleaned amount; movement is map texels per second.
	# A stationary working brush stays almost silent, a dry idle one releases.
	brush_target = (0.015 + 0.85 * clampf(speed / 650.0, 0.0, 1.0)) \
		* (0.55 + 0.45 * clampf(sqrt(maxf(work, 0.0) / 12.0), 0.0, 1.0)) if work > 0.0 else 0.0
	_brush_clay_target = 1.0 if clay else 0.0
	_brush_fresh = 0.05
	last_family = &"brush_clay" if clay else &"brush_soil"
	if not _brush_running and brush_target > 0:
		for i in range(2):
			brush_voices[i].stream = samples[&"brush_soil" if i == 0 else &"brush_clay"][0]
			brush_voices[i].volume_db = -80
			if DisplayServer.get_name() != "headless": brush_voices[i].play()
		_brush_running = true
		brush_starts += 1
		played += 1

func play_family(family: StringName, intensity := 1.0, discrete := false) -> void:
	if not discrete and cooldown.get(family, 0.0) > 0.0:
		return
	cooldown[family] = 0.095
	var voice := voices[played % voices.size()]
	voice.stream = samples[family][rng.randi_range(0, 3)]
	voice.pitch_scale = rng.randf_range(1.0 - profile.pitch_variation, 1.0 + profile.pitch_variation)
	voice.volume_db = profile.audio_volume_db + linear_to_db(clampf(intensity, 0.2, 1.0)) + rng.randf_range(-1.0, 1.0)
	# Headless numerical suites have no audio mixer to retire playbacks at exit.
	if DisplayServer.get_name() != "headless": voice.play()
	played += 1
	last_family = family

func reset() -> void:
	for voice in brush_voices:
		voice.stop()
		voice.stream = null
	brush_level = 0.0
	brush_target = 0.0
	brush_clay_mix = 0.0
	_brush_clay_target = 0.0
	_brush_fresh = 0.0
	_brush_running = false
	brush_starts = 0
	for voice in voices:
		voice.stop()
		voice.stream = null
	cooldown.clear()
	played = 0
	last_family = &""
	if profile != null: rng.seed = profile.seed + 51

func _exit_tree() -> void:
	reset()
