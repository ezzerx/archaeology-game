extends SceneTree
const Audio = preload("res://scripts/audio/atelier_audio.gd")
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func run() -> void:
	var master_volume := AudioServer.get_bus_volume_db(0)
	var master_mute := AudioServer.is_bus_mute(0)
	var sound := Audio.new()
	root.add_child(sound)
	sound.setup(ReactionProfile.new())
	sound.set_process(false)
	sound.set_physics_process(false)
	check(AudioServer.get_bus_volume_db(0) == master_volume and AudioServer.is_bus_mute(0) == master_mute, "setup preserves user Master")
	check(sound.spatial_voices.size() == 8 and sound.loop_voices.size() == 4, "bounded eight one-shots + four loops + one room")
	for family in Audio.LOOP_FAMILIES:
		var sample: AudioStreamWAV = sound.samples[family][0]
		check(sample.format == AudioStreamWAV.FORMAT_16_BITS and sample.loop_mode == AudioStreamWAV.LOOP_FORWARD, "seamless PCM loop import: " + String(family))
		check(sample.get_length() >= 4.0 and sample.get_length() <= 6.01, "finite loop duration: " + String(family))
	for family in [&"chisel_clay", &"chisel_stone", &"precision_pick"]:
		check(sound.samples[family].size() == 6, "six alternatives: " + String(family))
		for stream: AudioStreamWAV in sound.samples[family]:
			check(stream.format == AudioStreamWAV.FORMAT_IMA_ADPCM and stream.get_length() > 0.1 and stream.get_length() < 0.4, "short ADPCM impact loaded")
	check(sound.room_voice.stream is AudioStreamOggVorbis and sound.room_voice.stream.loop, "streamed Vorbis room loops")
	# Accepted scientific cues remain byte-identical, so the new timbre cannot
	# accidentally turn safe first contact into the damage alarm.
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/p4-validated-audio.json"))
	for family in ["bone_revealed", "direct_bone_hit"]:
		for variant in range(4):
			var hash := HashingContext.new()
			hash.start(HashingContext.HASH_SHA256)
			hash.update(sound.samples[StringName(family)][variant].data)
			check(hash.finish().hex_encode() == fixture[family][variant], "accepted contact cue retained")
	for i in range(180):
		sound.update_brush(400.0, 4.0, i > 90)
		sound._process(1.0 / 60.0)
	check(sound.brush_starts == 1 and sound.brush_clay_mix > 0.95, "brush crossfades material without repeated starts")
	sound._process(0.1)
	check(sound.brush_target == 0.0 and sound.brush_level > 0.0, "brush soft release")
	sound._process(2.0)
	check(not sound._running_loops.has(&"brush_soil") and not sound._running_loops.has(&"brush_clay"), "idle brush voices retire")
	for i in range(180):
		sound.update_air(0.55)
		sound._process(1.0 / 60.0)
	check(sound.air_starts == 1 and sound.air_level > 0.5, "held blower stays one continuous stream")
	sound._process(0.12)
	check(sound.air_target == 0.0 and sound.air_level > 0.0, "blower envelope releases")
	sound._process(2.0)
	check(not sound._running_loops.has(&"air"), "air voice retires")
	sound.update_abrasion(2.0)
	sound._process(0.016)
	check(sound.abrasion_level > 0.0 and sound.last_family == &"abrasive_tip", "real-work abrasive family exists")
	sound._process(2.0)
	var previous := -1
	var never_repeated := true
	for i in range(36):
		sound.play_family(&"chisel_stone", 1.0, true)
		var variant: int = sound.last_variant[&"chisel_stone"]
		never_repeated = never_repeated and variant != previous
		previous = variant
		sound._process(1.0 / 4.5)
	check(never_repeated, "no adjacent identical chisel sample across 36 native-cadence hits")
	# Force a worst-case event burst while preserving the reserved alarm pool.
	for i in range(20):
		sound.cooldown.clear()
		sound.play_family(&"chisel_stone", 1.0, true)
		sound.cooldown.clear()
		sound.play_family(&"precision_pick", 1.0, true)
	sound.play_family(&"direct_bone_hit", 1.0, true)
	check(sound.last_family == &"direct_bone_hit" and sound.dropped_events > 0, "saturated cosmetic pool cannot steal damage cue")
	check(sound.voice_remaining.filter(func(v: float) -> bool: return v > 0).size() <= 8, "burst voice cap")
	var room_before: AudioStream = sound.room_voice.stream
	sound.reset()
	sound._process(2.0)
	check(sound.room_voice.stream == room_before and sound.brush_target == 0.0 and sound.air_target == 0.0, "tool reset keeps ambience source and releases textures")
	sound.set_tools_volume_db(-7.0)
	sound.set_ambience_volume_db(-12.0)
	sound.set_muted(true)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index(Audio.MIX_BUS)), "atelier mute routes all new sound")
	check(AudioServer.get_bus_volume_db(0) == master_volume and AudioServer.is_bus_mute(0) == master_mute, "mix changes never alter Master")
	# A replacement preparation shares bus preferences; setup must not reset them.
	var second := Audio.new()
	root.add_child(second)
	second.setup(ReactionProfile.new())
	check(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(Audio.TOOL_BUS)) == -7.0 \
		and AudioServer.get_bus_volume_db(AudioServer.get_bus_index(Audio.ROOM_BUS)) == -12.0 \
		and AudioServer.is_bus_mute(AudioServer.get_bus_index(Audio.MIX_BUS)), "new preparation retains mix and mute")
	sound.update_air(0.6)
	sound.process_mode = Node.PROCESS_MODE_DISABLED
	check(sound._running_loops.is_empty() and not sound.room_voice.can_process() and (not sound.room_voice.playing or sound.room_voice.stream_paused), "disabled preparation silences all sources")
	sound.process_mode = Node.PROCESS_MODE_INHERIT
	check(not sound.room_voice.stream_paused and sound.room_level == 0.0, "resume fades room without stale tools")
	second.queue_free()
	sound.queue_free()
	await process_frame
	print("ATELIER AUDIO: ", checks, " checks, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
