extends "res://scripts/specimens/shaded_base/aesthetic_pilot.gd"
func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A3.6 Crâne de référence artistique"
	panel.get_child(0).get_child(0).text = "P6A3.6 / CRÂNE DE RÉFÉRENCE"
	_button("Crâne préparé au Pick · réinitialise",panel.get_child(0),prepare_native_pick_review)
	if OS.get_cmdline_user_args().has("--inspect-skull"):
		inspection.select_part(1)
		inspection.toggle()
func _create_mesh_view() -> Node3D:
	return preload("res://scripts/specimens/sculpted_base/production_mesh_view.gd").new()
func _create_inspection() -> CanvasLayer:
	return preload("res://scripts/specimens/sculpted_base/asset_inspection.gd").new()

func prepare_native_pick_review() -> void:
	# Explicit deterministic native-tool fixture. No manual Bone exposure or
	# terrain staging: all cuts use the unchanged Bone-safe Pick kernel.
	controller.cancel_stroke()
	select_fixture(1)
	for y in range(174,288,6):
		for x in range(168,332,6):
			for n in range(4): block.working_map.apply_impact(Vector2(x,y),controller.tools[3])
	block.flush_texture()
	session.flush()
	controller.select_tool(0)
	controller.refresh_view()
