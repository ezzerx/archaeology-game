extends "res://scripts/p6a37/modeled_skeleton.gd"
var lamp_control: Node3D
func _ready() -> void:
	super._ready()
	lamp_control = preload("res://scripts/p6a38/orientable_lamp.gd").new()
	lamp_control.name = "OrientableLamp"
	add_child(lamp_control)
	lamp_control.setup(self)
	get_window().title = "ArchaeologyGame — P6A3.8 Lampe orientable"
	panel.get_child(0).get_child(0).text = "P6A3.8 / LAMPE ORIENTABLE"
func set_hero_look(enabled: bool) -> void:
	super.set_hero_look(enabled)
	if lamp_control != null: lamp_control.refresh_availability()
func toggle_readability() -> void:
	super.toggle_readability()
	if lamp_control != null: lamp_control.register_blockers()
