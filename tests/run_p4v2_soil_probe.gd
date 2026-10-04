extends "res://tests/run_p4_benchmark.gd"
## Focused replay of the isolated Soil/1x frame outlier in the full P4 suite.
var simulation_us: Array[float] = []
var active_peak := 0

func on_frame() -> void:
	super.on_frame()
	if measuring:
		simulation_us.append(block.working_map.loose_debris.physics.last_step_usec)
		active_peak = maxi(active_peak, block.working_map.loose_debris.physics.active_count)

func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_mute(0, true)
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for i in range(90): await physics_frame
	for zoom in [1.0, 3.0]:
		for repeat in range(2):
			for enabled in [true, false]:
				main.feedback.crumb_physics_enabled = enabled
				simulation_us.clear()
				active_peak = 0
				await scenario("soil", zoom)
				var key := "soil_%dx" % int(zoom)
				var data: Dictionary = report[key]
				data.simulation_us = stats(simulation_us)
				data.active_fragments = active_peak
				data.physics_on = enabled
				check(data.frame_ms.p95 < 16.67 and data.render_fps >= 60, "Soil replay sustained frame budget")
				check(active_peak == 0, "Soil does not spawn hard fragments in either mode")
				report["%s_%s_%d" % [key, "on" if enabled else "off", repeat]] = data
				report.erase(key)
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v2-soil-probe.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V2 SOIL PROBE: %d failures" % failures)
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
