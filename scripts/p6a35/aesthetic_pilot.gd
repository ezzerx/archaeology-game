extends "res://scripts/p6a34/production_pilot.gd"
var shadows_button: Button
func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A3.5 Ivoire et relief"
	panel.get_child(0).get_child(0).text = "P6A3.5 / IVOIRE ET RELIEF"
	shadows_button = _button("Ombres des os dégagés : actives",panel.get_child(0),_toggle_shadows)
func _create_mesh_view() -> Node3D:
	return preload("res://scripts/p6a35/production_mesh_view.gd").new()
func _create_inspection() -> CanvasLayer:
	return preload("res://scripts/p6a35/asset_inspection.gd").new()
func _toggle_shadows() -> void:
	mesh_view.shadows_enabled = not mesh_view.shadows_enabled
	mesh_view.sync_state()
	shadows_button.text = "Ombres des os dégagés : actives" if mesh_view.shadows_enabled else "Ombres des os dégagés : désactivées"
