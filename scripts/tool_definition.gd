class_name ToolDefinition
extends Resource
## P2 tuning only. Power = work/second for strokes, work/impact for the chisel.
## Effectiveness vector order follows the three fixed P1 layers: Soil, Clay, Stone.

enum InteractionMode { CONTINUOUS, IMPACT }

@export var id: StringName
@export var display_name: String
@export var interaction_mode := InteractionMode.CONTINUOUS
@export_range(1.0, 128.0, 1.0) var radius := 40.0:
	set(value): radius = clampf(value, 1.0, 128.0)
@export_range(0.0, 5.0, 0.01) var power := 0.8:
	set(value): power = clampf(value, 0.0, 5.0)
@export_range(0.25, 8.0, 0.25) var falloff := 1.5:
	set(value): falloff = clampf(value, 0.25, 8.0)
@export_range(0.1, 20.0, 0.1) var cadence := 4.5:
	set(value): cadence = clampf(value, 0.1, 20.0)
@export var effectiveness := Vector3.ONE:
	set(value): effectiveness = value.clamp(Vector3.ZERO, Vector3.ONE * 8.0)
## Residue units per normalized depth actually removed; not work attempted.
@export_range(0.0, 20.0, 0.1) var residue_generation := 0.0:
	set(value): residue_generation = clampf(value, 0.0, 20.0)
## Residue units/second (continuous) or units/impact, before radial falloff.
@export_range(0.0, 10.0, 0.1) var residue_clear := 0.0:
	set(value): residue_clear = clampf(value, 0.0, 10.0)
## Percentage points per direct impact on a centre cell exposed BEFORE the hit.
@export_range(0.0, 100.0, 0.1) var bone_damage := 0.0:
	set(value): bone_damage = clampf(value, 0.0, 100.0)

func effectiveness_for(material_id: StringName) -> float:
	match material_id:
		&"loose_soil": return effectiveness.x
		&"compact_clay": return effectiveness.y
		&"sandstone": return effectiveness.z
	return 0.0

func structural_rate(material: MaterialDefinition) -> float:
	var rate := power * effectiveness_for(material.id) / material.resistance
	return rate * cadence if interaction_mode == InteractionMode.IMPACT else rate

func mode_name() -> String:
	return "IMPACTS" if interaction_mode == InteractionMode.IMPACT else "CONTINUOUS"
