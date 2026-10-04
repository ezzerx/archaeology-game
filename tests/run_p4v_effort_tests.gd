extends SceneTree
## Full Bone population, frozen V1 reference, actual float32 maps and resources.

const BEFORE = preload("res://tests/fixtures/p4v1_profile.gd")
const P4 = preload("res://tests/fixtures/p4_fossil_field.gd")
const DEPTH_MM := 102.0
const ZONES := [Vector2i(250, 230), Vector2i(510, 307), Vector2i(646, 441)]
var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"),
	preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
var chisel: ToolDefinition = preload("res://config/chisel.tres")
var checks := 0
var failures := 0
var report := {"reference": "122e9b1cf6dfacad721f9af240ef30592de8491c",
	"percentiles": "Nearest rank (ceil(n*p)-1); median averages the two middle values when n is even.",
	"hard_work_index": "Clay ABOVE Bone in mm * resistance/effectiveness + Sandstone ABOVE Bone in mm * resistance/effectiveness; intact column, not excavation time."}

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("P4V EFFORT FAIL: " + message)

func digest(bytes: PackedByteArray) -> String:
	var hash_context := HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256)
	hash_context.update(bytes)
	return hash_context.finish().hex_encode()

func distribution(values: Array[float]) -> Dictionary:
	values.sort()
	var n := values.size()
	return {"min": values[0], "median": (values[(n - 1) / 2] + values[n / 2]) * 0.5,
		"P90": values[ceili(n * 0.90) - 1], "P95": values[ceili(n * 0.95) - 1], "max": values[-1]}

func measure(limits: PackedFloat32Array, bones: FossilField, strata: Stratigraphy) -> Dictionary:
	var stone: Array[float] = []
	var effort: Array[float] = []
	var depth: Array[float] = []
	var clay: Array[float] = []
	var soil: Array[float] = []
	var in_typical_band := 0
	var ordered := true
	for i in range(bones.size.x * bones.size.y):
		var upper := limits[i * 2]
		var lower := limits[i * 2 + 1]
		ordered = ordered and 1.0 > upper and upper > lower and lower > 0.0
		clay.append((upper - lower) * DEPTH_MM)
		soil.append((1.0 - upper) * DEPTH_MM)
		if bones.component_ids[i] == 0: continue
		var ceiling := bones.ceilings[i]
		var stone_mm := maxf(0.0, lower - ceiling) * DEPTH_MM
		stone.append(stone_mm)
		effort.append(strata.hard_work_to_bone(Vector2(upper, lower), ceiling, DEPTH_MM, chisel))
		depth.append((1.0 - ceiling) * DEPTH_MM)
		if stone_mm >= 5 and stone_mm <= 18: in_typical_band += 1
	var zones := []
	if bones.size == Vector2i(1024, 640):
		for point: Vector2i in ZONES:
			var i := point.y * bones.size.x + point.x
			var upper := limits[i * 2]
			var lower := limits[i * 2 + 1]
			var ceiling := bones.ceilings[i]
			zones.append({"cell": [point.x, point.y], "component": FossilField.COMPONENT_NAMES[bones.component_ids[i]],
				"soil_mm": (1 - upper) * DEPTH_MM, "clay_mm": (upper - lower) * DEPTH_MM,
				"clay_above_bone_mm": maxf(0.0, upper - maxf(lower, ceiling)) * DEPTH_MM,
				"sandstone_mm": maxf(0.0, lower - ceiling) * DEPTH_MM, "bone_mm": (1 - ceiling) * DEPTH_MM,
				"hard_work_index": strata.hard_work_to_bone(Vector2(upper, lower), ceiling, DEPTH_MM, chisel)})
	return {"bone_cells": stone.size(), "sandstone_mm": distribution(stone), "hard_work_index": distribution(effort),
		"bone_depth_mm": distribution(depth), "clay_whole_map_mm": distribution(clay), "soil_whole_map_mm": distribution(soil),
		"stone_5_to_18_mm_fraction": float(in_typical_band) / stone.size(), "interfaces_ordered": ordered, "zones": zones}

func test_resolution(size: Vector2i) -> void:
	var strata := Stratigraphy.new(size, definitions)
	var bones := FossilField.new(size)
	var authored := P4.new(size)
	var old_limits := PackedFloat32Array()
	old_limits.resize(size.x * size.y * 2)
	var old_bone := authored.ceilings.duplicate()
	var old_image: Image = authored.image.duplicate()
	var same_soil := true
	for y in range(size.y):
		for x in range(size.x):
			var i := y * size.x + x
			var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(size)
			var limits: Vector2 = BEFORE.layer_limits(uv)
			old_limits[i * 2] = limits.x
			old_limits[i * 2 + 1] = limits.y
			same_soil = same_soil and limits.x == strata.packed_limits[i * 2]
			if authored.component_ids[i] != 0:
				old_bone[i] = BEFORE.buried_ceiling(authored.ceilings[i], uv)
				old_image.set_pixel(x, y, Color(old_bone[i], authored.component_ids[i], 0.0, 1.0))
	check(same_soil, "Soil byte exact versus V1 at %s" % size)
	check(bones.ceilings == old_bone and bones.image.get_data() == old_image.get_data(), "all Bone heights byte exact versus V1 at %s" % size)
	check(bones.component_ids == authored.component_ids and bones.component_totals == authored.component_totals
		and bones.total_cells == authored.total_cells, "IDs / silhouette / component totals exact at %s" % size)
	var before := measure(old_limits, bones, strata)
	var after := measure(strata.packed_limits, bones, strata)
	check(before.interfaces_ordered and after.interfaces_ordered, "interfaces never cross over the entire block at %s" % size)
	check(after.sandstone_mm.P95 <= 18.0 and after.sandstone_mm.max <= 22.0, "whole-fossil Stone P95 <=18 mm and hard max <=22 mm at %s" % size)
	check(after.sandstone_mm.median >= 5.0 and after.sandstone_mm.median <= 18.0
		and after.stone_5_to_18_mm_fraction >= 0.80, "at least 80%% of Bone cells retain 5-18 mm Stone at %s" % size)
	check(after.hard_work_index.P95 <= before.hard_work_index.P95 * 0.90
		and after.hard_work_index.max <= before.hard_work_index.max * 0.90,
		"hard-work P95 and max fall by at least 10%% at %s" % size)
	check(after.hard_work_index.P95 <= 180 and after.hard_work_index.max <= 205,
		"absolute hard-work budgets prevent future outlier drift at %s" % size)
	check(after.hard_work_index.median <= before.hard_work_index.median * 0.90
		and after.hard_work_index.P90 - after.hard_work_index.min > 50,
		"typical effort decreases while paths remain meaningfully different at %s" % size)
	check(after.bone_depth_mm == before.bone_depth_mm and after.bone_depth_mm.max - after.bone_depth_mm.min > 29,
		"full Bone distribution and ~30 mm amplitude preserved at %s" % size)
	check(after.soil_whole_map_mm == before.soil_whole_map_mm and after.soil_whole_map_mm.min < 20
		and after.soil_whole_map_mm.max > 40, "Soil range preserved at %s" % size)
	check(after.clay_whole_map_mm.min < 15 and after.clay_whole_map_mm.max > 35,
		"broad Clay thickness variation survives redistribution at %s" % size)
	var entry := {"before": before, "after": after, "ids_sha256": digest(bones.component_ids),
		"before_layers_sha256": digest(old_limits.to_byte_array()), "after_layers_sha256": digest(strata.boundaries.get_data()),
		"before_fossil_sha256": digest(old_image.get_data()), "after_fossil_sha256": digest(bones.image.get_data()),
		"component_totals": Array(bones.component_totals)}
	report[str(size)] = entry
	if size == Vector2i(1024, 640):
		check(bones.total_cells == 32290 and entry.ids_sha256 == "9f36172b7b6924c288c089dd6736709f1bcec831adb8743b623bb3e759afca21"
			and entry.before_layers_sha256 == "48770854498bf447805741d929a540fed9d59ab86e3698efc9b0c2c1fd30f296"
			and entry.before_fossil_sha256 == "1f1b9622b3aecb19cefb3b6a3266469c5ac170cf7579a695219fdee57ad8d73e",
			"canonical population, layers and Bone map match the measured reference HEAD")
		check(absf(before.sandstone_mm.median - 23.2788413465) < 0.00001
			and absf(before.sandstone_mm.P95 - 31.4756718278) < 0.00001
			and absf(before.sandstone_mm.max - 36.9410766363) < 0.00001,
			"frozen before profile reproduces the original all-cell measurement")
		for zone in [0, 2]:
			check(after.zones[zone].sandstone_mm >= 10 and after.zones[zone].sandstone_mm <= 18,
				"A/C Stone sanity check: %s" % ZONES[zone])
		check(after.zones[1].sandstone_mm > 0 and after.zones[1].sandstone_mm < 10, "B retains a shorter Stone pass")
		print("P4V EFFORT DISTRIBUTION: ", JSON.stringify(entry))

func test_metric() -> void:
	var strata := Stratigraphy.new(Vector2i.ONE, definitions)
	check(definitions[1].resistance == 3.0 and definitions[2].resistance == 8.0
		and chisel.effectiveness.y == 1.0 and chisel.effectiveness.z == 1.5, "human-validated resistance / effectiveness unchanged")
	var limits := Vector2(0.8, 0.5)
	check(absf(strata.hard_work_to_bone(limits, 0.4, 100, chisel) - (30 * 3.0 + 10 * 8.0 / 1.5)) < 0.00001,
		"metric counts both hard layers above Bone")
	check(absf(strata.hard_work_to_bone(limits, 0.65, 100, chisel) - 15 * 3.0) < 0.00001,
		"Bone inside Clay excludes Clay below the ceiling and all Stone")
	check(strata.hard_work_to_bone(limits, 0.9, 100, chisel) == 0, "no hard layer above a higher ceiling")
	var tool := chisel.duplicate() as ToolDefinition
	tool.effectiveness = Vector3.ONE
	check(absf(strata.hard_work_to_bone(limits, 0.4, 100, tool) - 170.0) < 0.00001, "metric reads resource weights, not hardcoded values")
	tool.effectiveness = Vector3.ZERO
	check(is_inf(strata.hard_work_to_bone(limits, 0.65, 100, tool))
		and strata.hard_work_to_bone(limits, 0.9, 100, tool) == 0, "zero effectiveness only blocks material actually above Bone")
	report["weights"] = {"clay": definitions[1].resistance / chisel.effectiveness.y,
		"sandstone": definitions[2].resistance / chisel.effectiveness.z}

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	test_metric()
	for size in [Vector2i(1024, 640), Vector2i(512, 320), Vector2i(256, 160)]: test_resolution(size)
	report["checks"] = checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v-effort-tests.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V EFFORT TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
