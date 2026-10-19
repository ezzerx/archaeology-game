extends SceneTree
## Exact differential test against an unchanged Git oracle, plus bounded CPU timings.
## Oracles are reconstructed from immutable Git source in work/, never swapped into production.
const CURRENT = preload("res://scripts/experiments/preparation_demos/demo_surface.gd")
var checks := 0
var failures: Array[String] = []
var report := {}
var resolution := Vector2i(1024, 640)

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error(label)

func fixture(script: Script, field: FossilField, label: String, kind: int):
	var s = script.new(resolution, null, field)
	s.demo_kind = kind
	s.loose_debris = LooseDebris.new(resolution)
	var n := resolution.x * resolution.y
	var roofs := PackedFloat32Array(); roofs.resize(n); roofs.fill(0.62)
	var floors := PackedFloat32Array(); floors.resize(n); floors.fill(0.18)
	var caps := PackedFloat32Array(); caps.resize(n)
	s.deep_grain_roofs.resize(n); s.deep_grain_floors.resize(n)
	s.marine_grain_ease.resize(n)
	for i in range(n):
		var bone: float = field.ceilings[i]
		var seed_value := (i * 17 + floori(float(i) / resolution.x) * 13) % 97
		s.marine_grain_ease[i] = 0.75 + seed_value / 194.0
		if seed_value < 28:
			s.deep_grain_roofs[i] = 0.32
			s.deep_grain_floors[i] = 0.05
			floors[i] = 0.36
		if bone > 0 and seed_value < 40:
			caps[i] = bone + 0.035
		var old := 0.50
		match label:
			"sealed": old = 0.68
			"deep": old = 0.30
			"lip": old = 0.64 if seed_value > 8 else 0.58
			"mixed":
				old = [0.64, 0.62005, 0.58, floors[i] + 0.00005, floors[i], bone + 0.02, 0.80][seed_value % 7]
			"abrasion": old = caps[i] + (0.002 if seed_value % 3 == 0 else 0.0) if caps[i] > 0 else 0.50
		s._heights[i] = old
	s.configure_demo(roofs, floors, caps)
	s.image.set_data(resolution.x, resolution.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	return s

func snapshot_equal(a, b) -> bool:
	return a._heights.to_byte_array() == b._heights.to_byte_array() \
		and a.image.get_data() == b.image.get_data() \
		and a.crust_caps.to_byte_array() == b.crust_caps.to_byte_array() \
		and a.fossil.exposed == b.fossil.exposed \
		and a.fossil.component_exposed == b.fossil.component_exposed \
		and a.fossil.first_contact == b.fossil.first_contact \
		and a.fossil.condition == b.fossil.condition \
		and a.bone_film.image.get_data() == b.bone_film.image.get_data() \
		and a.grains_removed == b.grains_removed and a.crust_removed == b.crust_removed \
		and var_to_bytes(a.last_action) == var_to_bytes(b.last_action)

func observe(s) -> Array:
	var events: Array = []
	s.tool_applied.connect(func(): events.append(["tool"]))
	s.fossil.bone_first_contact.connect(func(cell, component): events.append(["first", cell, component]))
	s.fossil.bone_cell_exposed.connect(func(cell, component): events.append(["cell", cell, component]))
	s.fossil.bone_component_exposure_changed.connect(func(component, count, total): events.append(["exposure", component, count, total]))
	s.material_action.connect(func(event): events.append(["material", event.duplicate(true)]))
	return events

func stats(values: Array) -> Dictionary:
	var ordered := values.duplicate(); ordered.sort()
	var total := 0.0
	for value in values: total += value
	return {"n": values.size(), "mean_us": total / values.size(), "p50_us": ordered[ordered.size() / 2],
		"p95_us": ordered[mini(ordered.size() - 1, floori(ordered.size() * 0.95))]}

func prepare_oracles(oracle_path: String, bound_path: String) -> bool:
	var output: Array = []
	var code := OS.execute("git", PackedStringArray(["show", "99fa7fe:scripts/experiments/preparation_demos/demo_surface.gd"]), output, true)
	if code != 0 or output.is_empty():
		push_error("The unchanged 99fa7fe Git oracle is required for the differential test.")
		return false
	var original: String = output[0]
	original = original.replace("\r\n", "\n")
	# Reconstruct the intermediate conservative row-bound witness in isolation.
	var bound := original.replace(" for y in range(low.y,high.y+1):",
		" var minimum_x:=minf(from.x,to.x);var maximum_x:=maxf(from.x,to.x)\n var minimum_y:=minf(from.y,to.y);var maximum_y:=maxf(from.y,to.y)\n for y in range(low.y,high.y+1):")
	bound = bound.replace("  for x in range(low.x,high.x+1):",
		"  var edge_distance:=maxf(0.0,maxf(minimum_y-y,y-maximum_y))\n  var reach:=sqrt(maxf(0.0,radius_squared-edge_distance*edge_distance))\n  var row_low:=maxi(low.x,floori(minimum_x-reach))\n  var row_high:=mini(high.x,ceili(maximum_x+reach))\n  for x in range(row_low,row_high+1):")
	DirAccess.make_dir_recursive_absolute("res://work/museum-polish/blower")
	FileAccess.open(oracle_path, FileAccess.WRITE).store_string(original)
	FileAccess.open(bound_path, FileAccess.WRITE).store_string(bound)
	return true

func run() -> void:
	var oracle_path := "res://work/museum-polish/blower/oracle_99fa7fe.gd"
	var bound_path := "res://work/museum-polish/blower/row_bound_witness.gd"
	var suffix := "candidate"
	var quick := "--quick" in OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--label="): suffix = arg.trim_prefix("--label=")
	if not prepare_oracles(oracle_path, bound_path):
		quit(2); return
	var scripts: Array = [load(oracle_path), load(bound_path), CURRENT]
	var field := FossilField.new(resolution)
	var blower: ToolDefinition = preload("res://config/air_blower.tres")
	var abrasive := ToolDefinition.new(); abrasive.id = &"abrasive_tip"; abrasive.radius = 18
	var cases: Array = []
	var paths := [
		[Vector2(510, 320), Vector2(510, 320)],
		[Vector2(510.25, 320.125), Vector2(512.25, 320.89)],
		[Vector2(590, 370), Vector2(460, 260)],
		[Vector2(0, 0), Vector2(2.5, 0.5)],
		[Vector2(1023, 639), Vector2(1019, 637)],
		[Vector2(-80, -90), Vector2(-70, -60)],
		[Vector2(1040, 650), Vector2(1000, 630)],
		[Vector2(450, 300), Vector2(450, 360)],
		[Vector2(450, 360), Vector2(550, 360)],
		[Vector2(0, 630), Vector2(1023, 5)]
	]
	for kind in ([1] if quick else [1, 2]):
		for label in (["open"] if quick else ["sealed", "open", "deep", "lip", "mixed", "abrasion"]):
			var surfaces: Array = []
			var observations: Array = []
			var timings: Array = [[], [], []]
			for script in scripts:
				var s = fixture(script, field, label, kind)
				surfaces.append(s); observations.append(observe(s))
			var tool := abrasive if label == "abrasion" else blower
			var active_counts: Array = [0, 0, 0]
			for step in range(100 if quick else 70):
				var path: Array = paths[step % paths.size()] if step < 20 and not quick else [Vector2(510, 320), Vector2(510, 320)]
				if step >= 45:
					var a := Vector2(490 + 40 * sin(step * 0.06), 325 + 20 * cos(step * 0.07))
					path = [a, a + Vector2(1.25, -0.75)]
				var counts: Array = [0, 0, 0]
				for position in range(3):
					var version := (position + step) % 3 # Rotate order to reduce warm-cache bias.
					var started := Time.get_ticks_usec()
					counts[version] = surfaces[version]._work_material(path[0], path[1], tool, 1.0 / 60.0, label == "abrasion")
					timings[version].append(Time.get_ticks_usec() - started)
					if counts[version] > 0: active_counts[version] += 1
				for version in [1, 2]:
					check(counts[0] == counts[version] and snapshot_equal(surfaces[0], surfaces[version])
						and var_to_bytes(observations[0]) == var_to_bytes(observations[version]),
						"%d/%s step %d witness %d exact state and ordered events" % [kind, label, step, version])
				for events in observations: events.clear()
			cases.append({"kind": kind, "case": label, "oracle": stats(timings[0]), "row_bound": stats(timings[1]),
				"candidate": stats(timings[2]), "active_ticks": active_counts,
				"grains": surfaces[0].grains_removed, "crust": surfaces[0].crust_removed})
			print("BLOWER CASE ", kind, "/", label, " ", JSON.stringify(cases.back()))
	report = {"engine": Engine.get_version_info().string, "label": suffix,
		"oracle_sha256": FileAccess.get_sha256(oracle_path), "candidate_sha256": FileAccess.get_sha256("res://scripts/experiments/preparation_demos/demo_surface.gd"),
		"checks": checks, "failures": failures, "resolution": str(resolution), "cases": cases}
	DirAccess.make_dir_recursive_absolute("res://work/museum-polish/blower")
	FileAccess.open("res://work/museum-polish/blower/" + suffix + ".json", FileAccess.WRITE).store_string(JSON.stringify(report, "  "))
	print("BLOWER EXACT: ", checks, " checks, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
