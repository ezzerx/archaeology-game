extends SceneTree
## Ordinary scene/settings, no FPS or VSync override. Automated 2-minute observation.
## Does not replace Antoine's F5 playtest or per-process GPU observation.

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var samples: Array[Dictionary] = []
	for second in range(125):
		await create_timer(1.0).timeout
		if second < 5: continue
		samples.append({"second": second - 4, "fps": Engine.get_frames_per_second(),
			"cap": Engine.max_fps, "physics_hz": Engine.physics_ticks_per_second})
	var report := {"godot": Engine.get_version_info().string, "samples": samples,
		"viewport": str(root.get_texture().get_size()), "vsync_mode": DisplayServer.window_get_vsync_mode(),
		"note": "Ordinary project settings, automatic idle observation; no fabricated user playtest."}
	var output := FileAccess.open("res://work/test-logs/p3-runtime.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "\t"))
	output.close()
	print("P3 RUNTIME: ", samples.size(), " seconds, cap=", Engine.max_fps, " physics=", Engine.physics_ticks_per_second)
	quit(0 if Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60 else 1)
