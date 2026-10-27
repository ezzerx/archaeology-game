extends SceneTree
## Exercise the production gallery hook and HUD with isolated QA storage.
const MuseumAudio = preload("res://scripts/audio/museum_audio.gd")
var checks := 0
var failures: Array[String] = []


# Exercise the real workshop retry handler with a directory failure before any
# child process can launch. Only the heavyweight scene construction is omitted.
class RetryWorkshop:
	extends "res://scripts/collection/exhibit_workshop.gd"
	func _ready() -> void:
		pass

class RetryUi:
	extends RefCounted
	var another_button := Button.new()
	var card_subtitle := Label.new()
	func refresh() -> void:
		another_button.disabled = false

class RetryPreparation:
	extends Node3D
	var specimen_id := "B17"
	var session_ui := RetryUi.new()
	func _ready() -> void:
		add_child(session_ui.another_button)
		add_child(session_ui.card_subtitle)

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
	if "--qa" not in OS.get_cmdline_user_args() or not "--exhibit-store=res://work/audio/museum/integration-empty" in OS.get_cmdline_user_args():
		push_error("Use -- --qa --exhibit-store=res://work/audio/museum/integration-empty")
		quit(2)
		return
	var master := {"volume": AudioServer.get_bus_volume_db(0), "mute": AudioServer.is_bus_mute(0)}
	var route_count := 0
	for path in ["res://scenes/experiments/exhibition_study.tscn", "res://scenes/collection/prepared_gallery.tscn"]:
		var scene = load(path).instantiate()
		root.add_child(scene)
		if path.ends_with("prepared_gallery.tscn"):
			check(scene.return_button.disabled and scene.museum_audio == null, "return stays disabled before gallery audio setup")
			# A direct early signal also needs a guard, not only a disabled button.
			scene.return_button.pressed.emit()
			check(not scene.transferring and scene.return_button.disabled, "early return signal is harmless and does not lock the gallery")
		var started := Time.get_ticks_msec()
		while not scene.fixtures_ready:
			await process_frame
			if Time.get_ticks_msec() - started > 45000:
				push_error("Gallery did not finish its production setup: " + path)
				quit(1)
				return
		await process_frame
		if path.ends_with("prepared_gallery.tscn"):
			check(not scene.return_button.disabled and is_instance_valid(scene.museum_audio), "return becomes available after complete gallery setup")
		var audio = scene.museum_audio
		var control: OptionButton = scene.sound_mode
		check(audio.get_script() == MuseumAudio, path + ": production audio hook")
		check(not audio.persist, path + ": QA never alters player sound settings")
		check(audio.get_child_count() == 2 and audio.playback_starts == 2, path + ": exactly two voices")
		check(control.item_count == 3 and control.selected == audio.mode, path + ": HUD initial mode agrees")
		check(control.get_item_text(0) == MuseumAudio.LABELS[0] and control.get_item_text(1) == MuseumAudio.LABELS[1] and control.get_item_text(2) == MuseumAudio.LABELS[2], path + ": three legible mode labels")
		if route_count > 0:
			check(AudioServer.bus_count == route_count, "second gallery does not duplicate mix routes")
		route_count = AudioServer.bus_count
		audio.set_process(false)
		for mode in [0, 1, 2, 0]:
			control.select(mode)
			control.item_selected.emit(mode)
			advance(audio, 2.5)
			check(audio.mode == mode, path + ": HUD routes mode %d" % mode)
			if mode == 1:
				check(audio.music_voice.volume_db < -70.0 and audio.room_voice.volume_db > -30.0, path + ": ambience remains after music fades")
			elif mode == 2:
				check(audio.music_voice.volume_db == -80.0 and audio.room_voice.volume_db == -80.0, path + ": silent HUD choice")
		check(audio.playback_starts == 2, path + ": HUD changes never retrigger tracks")
		scene.process_mode = Node.PROCESS_MODE_DISABLED
		check(audio._paused_by_tree and not audio.room_voice.can_process(), path + ": retained scene suspension reaches audio")
		scene.process_mode = Node.PROCESS_MODE_INHERIT
		check(not audio._paused_by_tree and audio.scene_level == 0.0, path + ": retained scene resumes with fade")
		await audio.fade_out(0.05)
		check(audio.scene_level == 0.0 and audio.music_voice.volume_db == -80.0 and audio.room_voice.volume_db == -80.0, path + ": handoff endpoint silences both voices")
		var audio_ref: WeakRef = weakref(audio)
		var music_ref: WeakRef = weakref(audio.music_voice)
		var room_ref: WeakRef = weakref(audio.room_voice)
		scene.queue_free()
		await process_frame
		check(audio_ref.get_ref() == null and music_ref.get_ref() == null and room_ref.get_ref() == null, path + ": gallery exit frees every voice")
	await check_workshop_retry()
	check(AudioServer.get_bus_volume_db(0) == master.volume and AudioServer.is_bus_mute(0) == master.mute, "actual gallery integration preserves Master")
	DirAccess.make_dir_recursive_absolute("res://work/audio/museum")
	FileAccess.open("res://work/audio/museum/integration-tests.json", FileAccess.WRITE).store_string(JSON.stringify({"checks": checks, "failures": failures}, "  "))
	print("MUSEUM INTEGRATION: ", checks, " checks, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)


func check_workshop_retry() -> void:
	var blocker_path := "res://work/audio/museum/handoff-blocker.txt"
	FileAccess.open(blocker_path, FileAccess.WRITE).store_string("QA handoff cannot create a directory inside this file.")
	var blocked_path := blocker_path.path_join("child")
	print("EXPECT 3 directory errors below: one precondition and two deliberate failed handoffs; no child process launches.")
	var blocked := DirAccess.make_dir_recursive_absolute(blocked_path) != OK
	check(blocked, "retry fixture prevents native process handoff")
	if not blocked:
		return
	var index := AudioServer.get_bus_index(&"Atelier")
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, &"Atelier")
	AudioServer.set_bus_volume_db(index, -7.5)
	AudioServer.set_bus_mute(index, true)
	var workshop := RetryWorkshop.new()
	root.add_child(workshop)
	workshop.preparation = RetryPreparation.new()
	workshop.add_child(workshop.preparation)
	workshop.exhibit_store = load("res://scripts/collection/exhibit_store.gd").new(blocked_path)
	workshop.saved = true
	for attempt in range(2):
		workshop._after_archive()
		check(workshop.busy and workshop.preparation.session_ui.another_button.disabled, "attempt %d locks retry controls" % attempt)
		await create_timer(0.78).timeout
		check(workshop.busy and workshop.preparation.session_ui.another_button.disabled, "attempt %d remains locked during gain restoration" % attempt)
		# Simulate an immediate second click while the restoration is in flight.
		workshop._after_archive()
		check(workshop.busy, "attempt %d ignores reentry during restoration" % attempt)
		await create_timer(0.65).timeout
		check(not workshop.busy and not workshop.preparation.session_ui.another_button.disabled
			and is_equal_approx(AudioServer.get_bus_volume_db(index), -7.5) and AudioServer.is_bus_mute(index),
			"attempt %d restores the original gain/mute before unlocking" % attempt)
	workshop.queue_free()
	await process_frame
