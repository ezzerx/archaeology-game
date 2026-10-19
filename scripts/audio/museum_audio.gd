extends Node
## Two named native-prototype events, no gameplay playback or source paths.
## Long-form room + music stream from Vorbis. Workshop sounds stay untouched.
signal mode_changed(value: int)

enum Mode { MUSIC_AND_AMBIENCE, AMBIENCE_ONLY, SILENT }
const LABELS := ["Musique + ambiance", "Ambiance seule", "Son coupé"]
const MUSIC_EVENT := &"event:/Music/Museum/Contemplation"
const ROOM_EVENT := &"event:/Ambience/Museum/GoldenRoom"
const MUSIC_PATH := "res://assets/audio/museum/museum_contemplation.ogg"
const ROOM_PATH := "res://assets/audio/museum/museum_room.ogg"
const MIX_BUS := &"Museum"
const MUSIC_BUS := &"Museum Music"
const ROOM_BUS := &"Museum Room"
const MUSIC_DB := -11.0
const ROOM_DB := -14.0
const SETTINGS_PATH := "user://museum_audio.cfg"
static var session_mode := Mode.MUSIC_AND_AMBIENCE

var music_voice: AudioStreamPlayer
var room_voice: AudioStreamPlayer3D
var mode: int = Mode.MUSIC_AND_AMBIENCE
var persist := true
var pause_on_focus_loss := false # Opt-in; Alt-Tab does not silence the gallery by default.
var music_level := 0.0
var room_level := 0.0
var scene_level := 0.0
var focus_level := 1.0
var playback_starts := 0
var _scene_active := true
var _focused := true
var _fade_time := 1.4
var _configured := false
var _scene: Node3D
var _paused_by_tree := false

func setup(scene: Node3D) -> void:
	if _configured:
		return
	_configured = true
	_scene = scene
	if "--qa" in OS.get_cmdline_user_args():
		persist = false
	_setup_buses()
	mode = session_mode
	if persist:
		var settings := ConfigFile.new()
		if settings.load(SETTINGS_PATH) == OK:
			mode = clampi(int(settings.get_value("museum", "mode", mode)), 0, 2)
	music_voice = AudioStreamPlayer.new()
	music_voice.name = "MuseumContemplation"
	music_voice.bus = MUSIC_BUS
	music_voice.max_polyphony = 1 # One reserved music voice; never stolen.
	music_voice.volume_db = -80.0
	music_voice.stream = load(MUSIC_PATH)
	add_child(music_voice)
	room_voice = AudioStreamPlayer3D.new()
	room_voice.name = "MuseumGoldenRoom"
	room_voice.bus = ROOM_BUS
	room_voice.max_polyphony = 1 # One diffuse room voice; never stolen.
	room_voice.volume_db = -80.0
	room_voice.max_db = 0.0
	room_voice.unit_size = 12.0
	room_voice.max_distance = 40.0
	room_voice.panning_strength = 0.2
	room_voice.attenuation_filter_cutoff_hz = 15000.0
	room_voice.stream = load(ROOM_PATH)
	add_child(room_voice)
	room_voice.global_position = scene.to_global(Vector3(0.0, 2.3, -1.0))
	assert(music_voice.stream != null and room_voice.stream != null, "Museum audio resources missing")
	# Both start muted and sample clocks remain stable across mode transitions.
	if DisplayServer.get_name() != "headless":
		music_voice.play()
		room_voice.play()
	playback_starts = 2
	var window := get_window()
	window.focus_entered.connect(_focus_entered)
	window.focus_exited.connect(_focus_exited)
	set_mode(mode, false)

func _setup_buses() -> void:
	# Create only our own routes, and retain any existing user bus/mute settings.
	for pair in [[MIX_BUS, &"Master"], [MUSIC_BUS, MIX_BUS], [ROOM_BUS, MIX_BUS]]:
		if AudioServer.get_bus_index(pair[0]) >= 0:
			continue
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, pair[0])
		AudioServer.set_bus_send(index, pair[1])
	# No realtime reverb: a natural stereo room tail is already in the music.
	# Conservative asset levels + gain keep two-voice peaks far below full scale.

func set_mode(value: int, save := true) -> void:
	mode = clampi(value, 0, 2)
	session_mode = mode
	if persist and save:
		var settings := ConfigFile.new()
		settings.set_value("museum", "mode", mode)
		settings.save(SETTINGS_PATH)
	mode_changed.emit(mode)

func cycle_mode() -> void:
	set_mode((mode + 1) % 3)

func get_mode_label() -> String:
	return LABELS[mode]

func _process(delta: float) -> void:
	if not _configured or _paused_by_tree:
		return
	var music_target := 1.0 if mode == Mode.MUSIC_AND_AMBIENCE else 0.0
	var room_target := 0.0 if mode == Mode.SILENT else 1.0
	music_level = _smooth(music_level, music_target, delta, 0.15)
	room_level = _smooth(room_level, room_target, delta, 0.10)
	scene_level = _smooth(scene_level, 1.0 if _scene_active else 0.0, delta, _fade_time / 6.0)
	focus_level = _smooth(focus_level, 1.0 if _focused else 0.0, delta, 0.06)
	var gate := scene_level * focus_level
	_set_gain(music_voice, MUSIC_DB, music_level * gate)
	_set_gain(room_voice, ROOM_DB, room_level * gate)
	# Pause the clocks only after the envelope is inaudible. Resume at the same
	# musical point, without replaying an intro on every UI selection/focus return.
	var suspend := gate < 0.0001 or mode == Mode.SILENT and music_level < 0.0001 and room_level < 0.0001
	music_voice.stream_paused = suspend
	room_voice.stream_paused = suspend

static func _smooth(current: float, target: float, delta: float, seconds: float) -> float:
	return lerpf(current, target, 1.0 - exp(-delta / maxf(seconds, 0.005)))

func _set_gain(voice: Node, base_db: float, level: float) -> void:
	voice.set(&"volume_db", maxf(-80.0, base_db + linear_to_db(maxf(level, 0.00001))))

func fade_out(seconds := 0.65) -> void:
	_fade_time = clampf(seconds, 0.05, 3.0)
	_scene_active = false
	if is_inside_tree():
		await get_tree().create_timer(_fade_time, true, false, true).timeout
	if is_instance_valid(music_voice):
		music_voice.volume_db = -80.0
		room_voice.volume_db = -80.0
		music_voice.stream_paused = true
		room_voice.stream_paused = true
	scene_level = 0.0

func resume_after_cancel() -> void:
	_scene_active = true
	_fade_time = 1.0

func _focus_entered() -> void:
	_focused = true

func _focus_exited() -> void:
	if pause_on_focus_loss:
		_focused = false

func _notification(what: int) -> void:
	if not _configured:
		return
	if what in [NOTIFICATION_DISABLED, NOTIFICATION_PAUSED]:
		_paused_by_tree = true
		music_voice.stream_paused = true
		room_voice.stream_paused = true
	elif what in [NOTIFICATION_ENABLED, NOTIFICATION_UNPAUSED]:
		_paused_by_tree = false
		scene_level = 0.0
		music_voice.volume_db = -80.0
		room_voice.volume_db = -80.0

func _exit_tree() -> void:
	if is_instance_valid(music_voice):
		music_voice.stop()
	if is_instance_valid(room_voice):
		room_voice.stop()

static func fade_workshop_for_handoff(tree: SceneTree, seconds := 0.65) -> Dictionary:
	# Optional bridge hook: fade only Atelier, never Master or its mute flag.
	# Caller retains this token to restore the exact gain on a failed handoff.
	var index := AudioServer.get_bus_index(&"Atelier")
	if index < 0:
		return {}
	var token := {"volume_db": AudioServer.get_bus_volume_db(index)}
	var tween := tree.create_tween()
	tween.tween_method(func(value: float): AudioServer.set_bus_volume_db(index, value), float(token.volume_db), -80.0, seconds)
	await tween.finished
	return token

static func restore_workshop_after_cancel(tree: SceneTree, token: Dictionary) -> void:
	var index := AudioServer.get_bus_index(&"Atelier")
	if index < 0 or token.is_empty():
		return
	var tween := tree.create_tween()
	tween.tween_method(func(value: float): AudioServer.set_bus_volume_db(index, value), AudioServer.get_bus_volume_db(index), float(token.volume_db), 0.65)
	# Keep retry controls locked until the exact previous gain is restored.
	await tween.finished
