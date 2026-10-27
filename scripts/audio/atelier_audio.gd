extends MaterialAudio
## Native prototype audio event backend. Gameplay keeps named material events.
## Original authored PCM/ADPCM assets are loaded once; no synthesis in play.
## FMOD/Wwise remains a production integration decision, not a dependency here.

const ROOT := "res://assets/audio/atelier/"
const MIX_BUS := &"Atelier"
const TOOL_BUS := &"Atelier Tools"
const ROOM_BUS := &"Atelier Room"
const MAX_IMPACTS := 6
const MAX_ALERTS := 2
const LOOP_FAMILIES := [&"brush_soil", &"brush_clay", &"air", &"abrasive_tip"]
# Explicit family voice limits, priority and overflow policy. Reserved alert pool
# cannot be stolen by impacts. Under an exceptional burst drop newest (no clicks).
const EVENTS := {
	&"chisel_clay": {"limit": 3, "priority": 1, "gain": 0.0},
	&"chisel_stone": {"limit": 3, "priority": 1, "gain": -0.5},
	&"precision_pick": {"limit": 3, "priority": 1, "gain": 2.0},
	&"bone_revealed": {"limit": 2, "priority": 0, "gain": -1.0},
	&"direct_bone_hit": {"limit": 2, "priority": 0, "gain": -1.0},
}
var spatial_voices: Array[AudioStreamPlayer3D] = []
var loop_voices: Dictionary = {}
var voice_remaining: Array[float] = []
var voice_family: Array[StringName] = []
var last_variant: Dictionary = {}
var room_voice: AudioStreamPlayer3D
var air_level := 0.0
var air_target := 0.0
var air_starts := 0
var abrasion_level := 0.0
var abrasion_target := 0.0
var room_level := 0.0
var room_enabled := true
var _air_fresh := 0.0
var _abrasion_fresh := 0.0
var _running_loops: Dictionary = {}
var _feedback: MaterialFeedback
var _input: ToolController
var _contact := Vector3.ZERO
var _occlusion := 0.0
var _occlusion_target := 0.0
var _occlusion_timer := 0.0
var _filter: AudioEffectLowPassFilter
var dropped_events := 0
var peak_voices := 0

func setup(settings: ReactionProfile) -> void:
	profile = settings
	rng.seed = settings.seed + 51
	_setup_buses()
	for family in LOOP_FAMILIES:
		var stream := load(ROOT + String(family) + "_loop.wav") as AudioStreamWAV
		assert(stream != null, "Missing atelier texture: " + String(family))
		samples[family] = [stream, stream, stream, stream]
		var voice := _voice(TOOL_BUS)
		voice.stream = stream
		loop_voices[family] = voice
	for family in [&"chisel_clay", &"chisel_stone", &"precision_pick"]:
		var variants: Array[AudioStreamWAV] = []
		for variant in range(1, 7):
			var stream := load(ROOT + "%s_%02d.wav" % [family, variant]) as AudioStreamWAV
			assert(stream != null, "Missing atelier impact")
			variants.append(stream)
		samples[family] = variants
	# Keep the two accepted protected/damaging contact cues exactly distinct.
	for family in [&"bone_revealed", &"direct_bone_hit"]:
		var variants: Array[AudioStreamWAV] = []
		for variant in range(4):
			variants.append(MaterialAudio.synthesize(family, variant))
		samples[family] = variants
	for i in range(MAX_IMPACTS + MAX_ALERTS):
		spatial_voices.append(_voice(TOOL_BUS))
		voice_remaining.append(0.0)
		voice_family.append(&"")
	room_voice = _voice(ROOM_BUS)
	room_voice.stream = load(ROOT + "workshop_room.ogg")
	room_voice.panning_strength = 0.15
	_feedback = get_parent() as MaterialFeedback
	if _feedback != null:
		_input = _feedback.controller
		_contact = _feedback.block.global_position
		# Observe authoritative events before normal MaterialFeedback consumes them.
		_feedback.block.working_map.material_action.connect(_observe_action)
		_feedback.block.working_map.air_jet_applied.connect(_observe_air)
	room_voice.global_position = _contact + Vector3(0.0, 0.35, -0.7)
	if DisplayServer.get_name() != "headless":
		room_voice.play()

func _setup_buses() -> void:
	# Never alter Master volume, mute, effects, or any pre-existing user bus values.
	if AudioServer.get_bus_index(MIX_BUS) < 0:
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, MIX_BUS)
		AudioServer.set_bus_send(index, &"Master")
		var compressor := AudioEffectCompressor.new()
		compressor.threshold = -6.0
		compressor.ratio = 10.0
		compressor.attack_us = 500.0
		compressor.release_ms = 80.0
		compressor.gain = 0.0
		AudioServer.add_bus_effect(index, compressor)
	if AudioServer.get_bus_index(TOOL_BUS) < 0:
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, TOOL_BUS)
		AudioServer.set_bus_send(index, MIX_BUS)
		var lowpass := AudioEffectLowPassFilter.new()
		lowpass.cutoff_hz = 18000.0
		AudioServer.add_bus_effect(index, lowpass)
		var reverb := AudioEffectReverb.new()
		reverb.room_size = 0.28
		reverb.damping = 0.72
		reverb.predelay_msec = 18.0
		reverb.wet = 0.07
		reverb.dry = 1.0
		AudioServer.add_bus_effect(index, reverb)
	if AudioServer.get_bus_index(ROOM_BUS) < 0:
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, ROOM_BUS)
		AudioServer.set_bus_send(index, MIX_BUS)
	var tools_index := AudioServer.get_bus_index(TOOL_BUS)
	for i in range(AudioServer.get_bus_effect_count(tools_index)):
		var effect := AudioServer.get_bus_effect(tools_index, i)
		if effect is AudioEffectLowPassFilter:
			_filter = effect
			break

func _voice(bus_name: StringName) -> AudioStreamPlayer3D:
	var voice := AudioStreamPlayer3D.new()
	voice.bus = bus_name
	voice.volume_db = -80.0
	voice.max_polyphony = 1
	voice.max_db = 0.0
	voice.unit_size = 1.8
	voice.max_distance = 16.0
	voice.panning_strength = 0.65
	voice.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	voice.attenuation_filter_cutoff_hz = 18000.0
	add_child(voice)
	return voice

func _observe_action(event: Dictionary) -> void:
	_contact = _feedback.point_world(event.point)
	if event.get("abrasion", false):
		update_abrasion(event.get("flow_volume", 0.0))

func _observe_air(_from: Vector2, to: Vector2, _radius: float, _falloff: float, _delta: float, _direction: Vector2) -> void:
	_contact = _feedback.point_world(to)
	# A held air tool still breathes when no grains remain. Never infer new work.
	update_air(0.48)

func _process(delta: float) -> void:
	if profile == null:
		return
	for family in cooldown:
		cooldown[family] = maxf(0.0, cooldown[family] - delta)
	for i in range(voice_remaining.size()):
		voice_remaining[i] = maxf(0.0, voice_remaining[i] - delta)
	_brush_fresh = maxf(0.0, _brush_fresh - delta)
	_air_fresh = maxf(0.0, _air_fresh - delta)
	_abrasion_fresh = maxf(0.0, _abrasion_fresh - delta)
	if _brush_fresh == 0.0: brush_target = 0.0
	if _air_fresh == 0.0: air_target = 0.0
	if _abrasion_fresh == 0.0: abrasion_target = 0.0
	# The real controller owns focus/session cancellation. Read it, never change it.
	if _input != null:
		if not _input._held or not _input._focused or not _input.hit.get("inside", false):
			brush_target = 0.0
			air_target = 0.0
			abrasion_target = 0.0
		elif _input.hit.has("world"):
			_contact = _input.hit.world
	brush_level = _smooth(brush_level, brush_target, delta, 0.045, 0.12)
	brush_clay_mix = _smooth(brush_clay_mix, _brush_clay_target, delta, 0.10, 0.10)
	air_level = _smooth(air_level, air_target, delta, 0.065, 0.16)
	abrasion_level = _smooth(abrasion_level, abrasion_target, delta, 0.035, 0.09)
	_set_loop(&"brush_soil", brush_level * sqrt(1.0 - brush_clay_mix), -1.0, 0.94 + 0.12 * brush_level)
	_set_loop(&"brush_clay", brush_level * sqrt(brush_clay_mix), -1.0, 0.96 + 0.10 * brush_level)
	_set_loop(&"air", air_level, -0.5, 0.98 + 0.025 * air_level)
	_set_loop(&"abrasive_tip", abrasion_level, -2.0, 0.97 + 0.08 * abrasion_level)
	# The room gently steps back while hands work; no compressor pumping.
	var activity := maxf(brush_level, maxf(air_level, abrasion_level))
	var room_target := (0.5 - activity * 0.12) if room_enabled else 0.0
	room_level = _smooth(room_level, room_target, delta, 1.4, 0.45)
	room_voice.volume_db = maxf(-80.0, profile.audio_volume_db - 6.0 + linear_to_db(maxf(room_level, 0.00001)))
	_occlusion = _smooth(_occlusion, _occlusion_target, delta, 0.08, 0.12)
	if _filter != null:
		_filter.cutoff_hz = lerpf(18000.0, 1100.0, _occlusion)
	var active := 1 if room_level > 0.001 else 0
	for remaining in voice_remaining:
		if remaining > 0.0: active += 1
	active += _running_loops.size()
	peak_voices = maxi(peak_voices, active)

func _physics_process(delta: float) -> void:
	_occlusion_timer -= delta
	if _input == null or _occlusion_timer > 0.0:
		return
	_occlusion_timer = 0.125 # At most one ray every eight physics ticks.
	if not is_instance_valid(_input.camera):
		return
	var origin := _input.camera.global_position
	var toward := origin - _contact
	if toward.length_squared() < 0.000001:
		return
	# Stop just before the surface: the specimen itself must not occlude contact.
	var endpoint := _contact + toward.normalized() * 0.025
	var query := PhysicsRayQueryParameters3D.create(origin, endpoint, 1)
	query.collide_with_areas = false
	_occlusion_target = 1.0 if not _input.camera.get_world_3d().direct_space_state.intersect_ray(query).is_empty() else 0.0

static func _smooth(value: float, target: float, delta: float, attack: float, release: float) -> float:
	return lerpf(value, target, 1.0 - exp(-delta / (attack if target > value else release)))

func _set_loop(family: StringName, level: float, gain_db: float, pitch: float) -> void:
	var voice: AudioStreamPlayer3D = loop_voices[family]
	voice.global_position = _contact
	voice.volume_db = maxf(-80.0, profile.audio_volume_db + gain_db + linear_to_db(maxf(level, 0.00001)))
	voice.pitch_scale = pitch
	var release_ready := brush_target <= 0.0 if family in [&"brush_soil", &"brush_clay"] else true
	if level < 0.0001 and release_ready and _running_loops.has(family):
		voice.stop()
		_running_loops.erase(family)

func _start_loop(family: StringName) -> void:
	if _running_loops.has(family):
		return
	var voice: AudioStreamPlayer3D = loop_voices[family]
	voice.global_position = _contact
	voice.volume_db = -80.0
	if DisplayServer.get_name() != "headless":
		voice.play(rng.randf() * 0.9)
	_running_loops[family] = true

func update_brush(speed: float, work: float, clay := false) -> void:
	brush_target = (0.015 + 0.85 * clampf(speed / 650.0, 0.0, 1.0)) \
		* (0.55 + 0.45 * clampf(sqrt(maxf(work, 0.0) / 12.0), 0.0, 1.0)) if work > 0.0 else 0.0
	_brush_clay_target = 1.0 if clay else 0.0
	_brush_fresh = 0.08 # Covers the existing dry-brush 55 ms refresh interval.
	last_family = &"brush_clay" if clay else &"brush_soil"
	if brush_target > 0.0:
		if not _running_loops.has(&"brush_soil") and not _running_loops.has(&"brush_clay"):
			brush_starts += 1
			played += 1
		_start_loop(&"brush_soil")
		_start_loop(&"brush_clay")

func update_air(intensity: float) -> void:
	air_target = clampf(intensity, 0.25, 0.85)
	_air_fresh = 0.09
	if not _running_loops.has(&"air"):
		air_starts += 1
		played += 1
	_start_loop(&"air")
	last_family = &"air"

func update_abrasion(work: float) -> void:
	if work <= 0.0:
		return
	abrasion_target = 0.28 + 0.28 * clampf(sqrt(work / 5.0), 0.0, 1.0)
	_abrasion_fresh = 0.08
	if not _running_loops.has(&"abrasive_tip"):
		played += 1
	_start_loop(&"abrasive_tip")
	last_family = &"abrasive_tip"

func play_family(family: StringName, intensity := 1.0, discrete := false) -> void:
	if family == &"air":
		update_air(intensity)
		return
	if not EVENTS.has(family):
		return
	# A delayed simulation may catch up several hits in one frame. The gesture
	# still happens unchanged; do not stack identical audible transients.
	if cooldown.get(family, 0.0) > 0.0:
		return
	cooldown[family] = 0.025 if discrete else 0.095
	var config: Dictionary = EVENTS[family]
	var family_count := 0
	for i in range(voice_family.size()):
		if voice_family[i] == family and voice_remaining[i] > 0.0:
			family_count += 1
	var first := MAX_IMPACTS if config.priority == 0 else 0
	var last := MAX_IMPACTS + MAX_ALERTS if config.priority == 0 else MAX_IMPACTS
	var slot := -1
	if family_count < config.limit:
		for i in range(first, last):
			if voice_remaining[i] <= 0.0:
				slot = i
				break
	if slot < 0:
		dropped_events += 1
		return
	var variants: Array = samples[family]
	# Uniform choice from all alternatives, with no immediate repeated sample.
	var variant := rng.randi_range(0, variants.size() - 2)
	var previous: int = last_variant.get(family, -1)
	if previous >= 0 and variant >= previous:
		variant += 1
	elif previous < 0:
		variant = rng.randi_range(0, variants.size() - 1)
	last_variant[family] = variant
	var voice := spatial_voices[slot]
	voice.stream = variants[variant]
	voice.global_position = _contact
	voice.pitch_scale = rng.randf_range(0.965, 1.035)
	voice.volume_db = profile.audio_volume_db + float(config.gain) \
		+ linear_to_db(clampf(intensity, 0.2, 1.0)) + rng.randf_range(-0.55, 0.55)
	voice_remaining[slot] = voice.stream.get_length() / voice.pitch_scale + 0.025
	voice_family[slot] = family
	if DisplayServer.get_name() != "headless":
		voice.play()
	played += 1
	last_family = family

func set_tools_volume_db(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(TOOL_BUS), clampf(value, -60.0, 0.0))

func set_ambience_volume_db(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(ROOM_BUS), clampf(value, -60.0, 0.0))

func set_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MIX_BUS), muted)

func reset() -> void:
	# Input/surface resets release existing loops smoothly; room never restarts.
	# Hard teardown is handled separately so selecting tools does not click.
	brush_target = 0.0
	air_target = 0.0
	abrasion_target = 0.0
	_brush_fresh = 0.0
	_air_fresh = 0.0
	_abrasion_fresh = 0.0
	_brush_clay_target = 0.0
	brush_starts = 0
	air_starts = 0
	played = 0
	last_family = &""
	cooldown.clear()
	last_variant.clear()
	if profile != null:
		rng.seed = profile.seed + 51

func _exit_tree() -> void:
	for voice in spatial_voices:
		voice.stop()
	for voice: AudioStreamPlayer3D in loop_voices.values():
		voice.stop()
	if is_instance_valid(room_voice):
		room_voice.stop()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_PAUSED, NOTIFICATION_DISABLED]:
		# Collection hides a retained preparation by disabling its subtree.
		# Clear tool tails so they cannot resume later, pause the room in place.
		for voice in spatial_voices:
			voice.stop()
		voice_remaining.fill(0.0)
		for voice: AudioStreamPlayer3D in loop_voices.values():
			voice.stop()
		_running_loops.clear()
		brush_level = 0.0
		air_level = 0.0
		abrasion_level = 0.0
		reset()
		if is_instance_valid(room_voice):
			room_voice.stream_paused = true
	elif what in [NOTIFICATION_UNPAUSED, NOTIFICATION_ENABLED]:
		if is_instance_valid(room_voice):
			room_level = 0.0
			room_voice.volume_db = -80.0
			room_voice.stream_paused = false
