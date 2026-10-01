class_name MaterialDefinition
extends Resource
## P1 only: no final-tool, fossil, audio or particle data.

@export var id: StringName
@export var display_name: String
@export_range(0.1, 50.0, 0.1) var resistance := 1.0:
	set(value): resistance = maxf(value, 0.1)
@export var debug_color := Color.WHITE
