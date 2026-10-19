extends SceneTree
## Read real surface events in each shipped preparation; never replace their maps.
var checks := 0
var failures: Array[String] = []
var suite: Node
var summary: Array[Dictionary] = []
const Audio = preload("res://scripts/audio/atelier_audio.gd")

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func run() -> void:
	AudioServer.set_bus_mute(0, true)
	suite = load("res://scenes/experiments/preparation_demos.tscn").instantiate()
	root.add_child(suite)
	while suite.busy:
		await process_frame
	for kind in range(3):
		if kind > 0:
			await suite.open_demo(kind)
		var prep = suite.preparation
		prep.display.persist = false
		prep.controller.set_physics_process(false)
		prep.controller.set_process(false)
		var sound = prep.feedback.audio
		sound.set_process(false)
		var surface = prep.block.working_map
		check(sound.get_script() == Audio, "new audio wired into preparation %d" % kind)
		var point := Vector2(500, 340)
		sound.reset()
		surface.apply_continuous(point, point + Vector2(8, 0), prep.controller.tools[0], 1.0 / 60.0)
		check(sound.brush_target > 0.0, "actual soil brush refreshes friction %d" % kind)
		sound.reset()
		surface.apply_continuous(point, point, prep.controller.tools[2], 1.0 / 60.0)
		check(sound.air_target > 0.0 and sound.air_starts == 1, "actual air on sealed terrain breathes once %d" % kind)
		sound.reset()
		surface.apply_impact(point, prep.controller.tools[1])
		check(sound.last_family in [&"chisel_clay", &"chisel_stone"], "actual fracture keeps material family %d" % kind)
		sound.reset()
		surface.apply_impact(point + Vector2(25, 0), prep.controller.tools[3])
		check(sound.last_family == &"precision_pick", "actual precision impact has its own tick %d" % kind)
		if kind > 0:
			var cell := -1
			for i in range(surface.crust_caps.size()):
				if surface.crust_caps[i] > 0.0:
					cell = i
					break
			check(cell >= 0, "preparation contains a concrete finishing encounter")
			if cell >= 0:
				point = Vector2(cell % 1024, floori(float(cell) / 1024))
				# Bounded actual safe Pick work opens access; abrasion stays impossible
				# until existing material rules allow it. No fixture is edited.
				for i in range(90):
					surface.apply_impact(point, prep.controller.tools[3])
				for i in range(40):
					surface.apply_continuous(point, point, prep.controller.tools[2], 0.05)
				sound.reset()
				var removed: int = surface.apply_continuous(point, point, prep.controller.tools[4], 0.05)
				check(removed > 0 and sound.abrasion_target > 0.0 and sound.last_family == &"abrasive_tip", "actual concretion work drives abrasion texture %d" % kind)
		summary.append({"preparation": kind, "audio_script": sound.get_script().resource_path,
			"room_voices": 1, "spatial_pool": sound.spatial_voices.size()})
		check(sound.get_child_count() == 13, "one fixed audio rig per preparation %d" % kind)
		prep.session.flush()
		await process_frame
		await process_frame
		print("ATELIER ROUTING preparation ", kind, " complete")
	FileAccess.open("res://work/audio/routing.json", FileAccess.WRITE).store_string(
		JSON.stringify({"checks": checks, "failures": failures, "preparations": summary}, "  "))
	suite.queue_free()
	await process_frame
	print("ATELIER ROUTING: ", checks, " checks, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
