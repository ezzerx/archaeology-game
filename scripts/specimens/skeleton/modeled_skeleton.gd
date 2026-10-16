extends "res://scripts/specimens/sculpted_base/hero_skull.gd"
func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A3.7 Squelette modelé"
	panel.get_child(0).get_child(0).text = "P6A3.7 / SQUELETTE MODELÉ"
	for button: Button in panel.find_children("*","Button",true,false):
		if button.text == "Zone pilote dégagée, os sales · réinitialise": button.text = "Squelette dégagé, os sales · réinitialise"
	_button("Squelette préparé au Pick · réinitialise",panel.get_child(0),prepare_native_skeleton_review)
	if OS.get_cmdline_user_args().has("--inspect-skeleton"):
		inspection.select_part(0)
		inspection.toggle()
func _create_mesh_view() -> Node3D:
	return preload("res://scripts/specimens/skeleton/production_mesh_view.gd").new()
func _create_inspection() -> CanvasLayer:
	return preload("res://scripts/specimens/skeleton/asset_inspection.gd").new()
func prepare_review_patch() -> void:
	# Explicit staged inspection cut, announced reset; not recorded gameplay.
	controller.cancel_stroke()
	select_fixture(1)
	var surface := block.working_map
	var exposed := PackedInt32Array()
	for y in range(174,562):
		for x in range(164,838):
			var i := y*surface.size.x+x
			var roof := surface.structural_ceilings[i]
			surface._heights[i] = roof if roof > 0 else .22
			if roof > 0: exposed.append(i)
	surface.image.set_data(surface.size.x,surface.size.y,false,Image.FORMAT_RF,surface._heights.to_byte_array())
	surface.dirty = true
	surface.fossil.expose_cells(exposed)
	block.flush_texture()
	session.flush()
	controller.select_tool(0)
	controller.refresh_view()
var native_review_impacts := 0
func prepare_native_skeleton_review() -> void:
	# Real unchanged Bone-safe Pick impacts, limited to authored bone neighborhoods.
	controller.cancel_stroke()
	select_fixture(1)
	var field: FossilField = block.working_map.fossil.field
	native_review_impacts = 0
	for y in range(176,558,6):
		for x in range(168,838,6):
			var nearby := false
			for offset in [Vector2i.ZERO,Vector2i(-3,0),Vector2i(3,0),Vector2i(0,-3),Vector2i(0,3)]:
				if field.component_ids[(y+offset.y)*1024+x+offset.x] != 0: nearby = true
			if not nearby: continue
			for n in range(4):
				block.working_map.apply_impact(Vector2(x,y),controller.tools[3])
				native_review_impacts += 1
	# Finish residual thin margins with real centered Pick contacts. No height or
	# exposure staging: the unchanged tool kernel remains the only authority.
	for i in range(field.component_ids.size()):
		if field.component_ids[i] == 0 or block.working_map.fossil.exposed[i] != 0: continue
		@warning_ignore("integer_division")
		var point := Vector2(i%1024,i/1024)
		for n in range(4):
			if block.working_map.fossil.exposed[i] != 0: break
			block.working_map.apply_impact(point,controller.tools[3])
			native_review_impacts += 1
	block.flush_texture()
	session.flush()
	controller.select_tool(0)
	controller.refresh_view()
