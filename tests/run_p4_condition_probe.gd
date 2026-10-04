extends SceneTree
## Upper-bound feasibility probe, NOT a claim of human fairness or game feel.
## Choices read exposed cells/visible height only, never hidden fossil ceilings.
var report := {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var definitions: Array[MaterialDefinition] = [load("res://config/loose_soil.tres"), load("res://config/compact_clay.tres"), load("res://config/sandstone.tres")]
	var size := Vector2i(1024, 640)
	var surface := WorkingSurface.new(size, Stratigraphy.new(size, definitions), FossilField.new(size), load("res://config/material_reactions.tres"))
	var chisel: ToolDefinition = load("res://config/chisel.tres")
	var brush: ToolDefinition = load("res://config/soft_brush.tres")
	var blower: ToolDefinition = load("res://config/air_blower.tres")
	# Brush the crown area through the normal continuous API (same defaults).
	for y in range(150, 261, 25):
		for i in range(3): surface.apply_continuous(Vector2(215, y), Vector2(360, y), brush, 0.25)
	var impacts := 0
	var progress: Array[Dictionary] = []
	for pass_index in range(9):
		var exposed_before := surface.fossil.exposed_cells
		for y in range(162, 258, 8):
			for x in range(230, 352, 8):
				var index := y * size.x + x
				# Stop/re-aim when centre is visibly exposed; no hidden-bone oracle.
				if surface.fossil.exposed[index] != 0 or surface._heights[index] <= 0: continue
				surface.apply_impact(Vector2(x, y), chisel)
				impacts += 1
		progress.append({"pass": pass_index + 1, "impacts": impacts, "new_bone_cells": surface.fossil.exposed_cells - exposed_before,
			"exposed_cells": surface.fossil.exposed_cells, "condition": surface.fossil.condition})
		if impacts >= 1000: break
	surface.apply_continuous(Vector2(215, 205), Vector2(360, 205), blower, 2)
	report["careful_visible_centres"] = {"impacts": impacts, "chisel_seconds_at_4_5_hz": impacts / chisel.cadence,
		"exposed_cells": surface.fossil.exposed_cells, "skull_exposure_percent": surface.fossil.exposure_percent(FossilField.Component.SKULL),
		"global_exposure_percent": surface.fossil.exposure_percent(), "condition": surface.fossil.condition, "passes": progress,
		"limitation": "Perfect centre recognition and immediate stop; feasibility only, not a human playtest."}
	var direct := Vector2.ZERO
	for i in range(surface.fossil.exposed.size()):
		if surface.fossil.exposed[i] != 0:
			direct = Vector2(i % size.x, i / size.x)
			break
	var before := surface.fossil.condition
	var protection_available := not surface.fossil.first_direct_contact_consumed
	surface.apply_impact(direct, chisel)
	var protected_condition := surface.fossil.condition
	var protected_event: bool = surface.last_action.bone_protected_contact
	for i in range(9): surface.apply_impact(direct, chisel)
	report["held_on_visible_bone"] = {"impacts": 10, "condition_before": before, "condition_after": surface.fossil.condition,
		"protection_available_before": protection_available, "first_hit_condition": protected_condition, "first_hit_protected": protected_event}
	FileAccess.open("res://work/test-logs/p4-condition.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 CONDITION ", JSON.stringify(report))
	quit(0 if surface.fossil.exposed_cells > 0 and before == 100 and protection_available
		and protected_event and protected_condition == 100 and surface.fossil.condition == 73 else 1)
