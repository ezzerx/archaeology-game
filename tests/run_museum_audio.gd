extends SceneTree
const MuseumAudio = preload("res://scripts/audio/museum_audio.gd")
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error(label)

func advance(audio: Node, seconds: float) -> void:
	for i in range(roundi(seconds * 60.0)):
		audio._process(1.0 / 60.0)

func run() -> void:
	var master := {"volume": AudioServer.get_bus_volume_db(0), "mute": AudioServer.is_bus_mute(0)}
	var scene := Node3D.new()
	root.add_child(scene)
	var audio := MuseumAudio.new()
	audio.persist = false
	scene.add_child(audio)
	audio.setup(scene)
	audio.set_process(false)
	check(audio.get_child_count() == 2 and audio.playback_starts == 2, "exactly two bounded voices")
	var count := AudioServer.bus_count
	audio.setup(scene)
	check(audio.get_child_count() == 2 and AudioServer.bus_count == count, "setup is idempotent")
	check(audio.music_voice.stream is AudioStreamOggVorbis and audio.room_voice.stream is AudioStreamOggVorbis, "both long assets stream as Vorbis")
	check(audio.music_voice.stream.loop and audio.room_voice.stream.loop, "both imports loop")
	check(absf(audio.music_voice.stream.get_length() - 84.0) < 0.1 and absf(audio.room_voice.stream.get_length() - 48.0) < 0.1, "authored loop periods retained")
	check(audio.music_voice.bus == MuseumAudio.MUSIC_BUS and audio.room_voice.bus == MuseumAudio.ROOM_BUS, "independent music/room routing")
	check(audio.music_voice.max_polyphony == 1 and audio.room_voice.max_polyphony == 1, "one reserved voice per event")
	check(AudioServer.get_bus_send(AudioServer.get_bus_index(MuseumAudio.MIX_BUS)) == &"Master", "museum mix reaches Master")
	audio.set_mode(0)
	advance(audio, 2.5)
	check(audio.music_level > 0.99 and audio.room_level > 0.99 and audio.scene_level > 0.99, "entry fades into full scene")
	audio.set_mode(1)
	audio._process(1.0 / 60.0)
	check(audio.music_level > 0.0 and audio.music_level < 1.0, "music choice releases without hard cut")
	advance(audio, 2.0)
	check(audio.music_voice.volume_db < -70.0 and audio.room_voice.volume_db > -30.0, "ambience-only mode keeps room")
	audio.set_mode(2)
	advance(audio, 2.0)
	check(audio.music_voice.volume_db <= -79.0 and audio.room_voice.volume_db <= -79.0, "silent mode becomes inaudible")
	audio.set_mode(0)
	advance(audio, 2.0)
	check(audio.playback_starts == 2 and audio.music_level > 0.99, "mode change resumes existing music clock")
	audio._focus_exited()
	advance(audio, 1.0)
	check(audio.focus_level > 0.99, "Alt-Tab does not silence by default")
	audio.pause_on_focus_loss = true
	audio._focus_exited()
	advance(audio, 1.0)
	check(audio.focus_level < 0.0001, "optional focus policy fades before pause")
	audio._focus_entered()
	advance(audio, 1.0)
	check(audio.focus_level > 0.99 and audio.playback_starts == 2, "focus resumes without repeating intro")
	await audio.fade_out(0.05)
	check(audio.scene_level == 0.0 and audio.music_voice.volume_db == -80.0 and audio.room_voice.volume_db == -80.0, "scene exit reaches silence before process handoff")
	audio.resume_after_cancel()
	advance(audio, 2.0)
	check(audio.scene_level > 0.99, "failed handoff restores museum gently")
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	check(audio._paused_by_tree, "retained disabled scene suspends its audio")
	scene.process_mode = Node.PROCESS_MODE_INHERIT
	check(not audio._paused_by_tree and audio.scene_level == 0.0, "retained scene resumes with a new fade")
	# A temporary Atelier route isolates bridge tests from actual workshop scenes.
	var index := AudioServer.get_bus_index(&"Atelier")
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, &"Atelier")
	AudioServer.set_bus_volume_db(index, -7.5)
	AudioServer.set_bus_mute(index, true)
	var token := await MuseumAudio.fade_workshop_for_handoff(self, 0.05)
	check(AudioServer.get_bus_volume_db(index) == -80.0 and AudioServer.is_bus_mute(index), "workshop handoff respects its mute flag")
	MuseumAudio.restore_workshop_after_cancel(self, token)
	await create_timer(0.8).timeout
	check(is_equal_approx(AudioServer.get_bus_volume_db(index), -7.5) and AudioServer.is_bus_mute(index), "failed handoff restores exact workshop gain and mute")
	check(AudioServer.get_bus_volume_db(0) == master.volume and AudioServer.is_bus_mute(0) == master.mute, "all changes preserve Master")
	DirAccess.make_dir_recursive_absolute("res://work/audio/museum")
	FileAccess.open("res://work/audio/museum/runtime-tests.json", FileAccess.WRITE).store_string(
		JSON.stringify({"checks": checks, "failures": failures}, "  "))
	scene.queue_free()
	await process_frame
	print("MUSEUM AUDIO: ", checks, " checks, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
