class_name MaterialAudio
extends Node
## Original procedural placeholder sounds, generated once. No external assets.
const FAMILIES := [&"brush_soil", &"brush_clay", &"chisel_clay", &"chisel_stone", &"bone", &"air"]
const SAMPLE_RATE := 22050
var samples: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var cooldown: Dictionary = {}
var rng := RandomNumberGenerator.new()
var profile: ReactionProfile
var played := 0
var last_family: StringName

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

static func synthesize(family: StringName, variant: int) -> AudioStreamWAV:
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
			&"bone": signal_value = (0.55 * sin(TAU * 2850 * variation * t) + 0.16 * sin(TAU * 4270 * variation * t)) * exp(-t * 26)
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
	for voice in voices:
		voice.stop()
		voice.stream = null
	cooldown.clear()
	played = 0
	last_family = &""
	if profile != null: rng.seed = profile.seed + 51

func _exit_tree() -> void:
	reset()
