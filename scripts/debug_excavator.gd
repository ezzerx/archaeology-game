class_name DebugExcavator
extends Resource
## Legacy P0/P1 regression fixture only; the playable scene uses ToolDefinition.

@export_range(1.0, 128.0, 1.0) var radius := 40.0:
	set(value): radius = clampf(value, 1.0, 128.0)
@export_range(0.05, 5.0, 0.05) var strength := 0.8:
	set(value): strength = clampf(value, 0.05, 5.0)
@export_range(0.25, 8.0, 0.25) var falloff := 1.5:
	set(value): falloff = clampf(value, 0.25, 8.0)
