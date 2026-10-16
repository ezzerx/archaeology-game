extends "res://scripts/specimens/sculpted_base/asset_inspection.gd"
func _source_scene() -> PackedScene:
	return preload("res://assets/p6a37/b17_skeleton.glb")
func _previous_source_scene() -> PackedScene:
	return preload("res://assets/p6a36/b17_production_patch.glb")
func setup(pilot: Node3D) -> void:
	super.setup(pilot)
	var header: VBoxContainer = root_control.get_child(1)
	var row: HBoxContainer = header.get_child(2)
	var comparisons := HBoxContainer.new()
	header.add_child(comparisons)
	for button in [reference_button,shape_button]: button.reparent(comparisons)
	for item in [["Vertèbres / queue",3],["Bassin / patte",4]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(170,44)
		row.add_child(button)
		button.pressed.connect(select_part.bind(item[1]))
	reference_button.custom_minimum_size.x = 370
	reference_button.text = "Modèle : squelette complet"
	header.get_child(1).text = "Même modèle qu’en fouille · glisser pour tourner · molette pour rapprocher"
	select_part(0)
func select_part(which: int) -> void:
	if which >= 3 and using_previous:
		using_previous = false
		model.show()
		previous_model.hide()
	current_part = which
	var chosen: Node3D = previous_model if using_previous else model
	var selected: Array[MeshInstance3D] = previous_meshes if using_previous else meshes
	var bounds := AABB()
	var first := true
	for mesh in selected:
		mesh.visible = which == 0 or (which == 1 and "Skull" in mesh.name) or (which == 2 and "Rib" in mesh.name) or (which == 3 and "Vertebra" in mesh.name) or (which == 4 and not "Skull" in mesh.name and not "Rib" in mesh.name and not "Vertebra" in mesh.name)
		if not mesh.visible: continue
		var local := chosen.global_transform.affine_inverse()*mesh.global_transform
		var box: AABB = local*mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	chosen.position = -bounds.get_center()
	pivot.rotation = Vector3.ZERO
	camera.size = maxf(bounds.size.x*.95,bounds.size.z*1.4)+.055
	if reference_button != null:
		reference_button.disabled = which >= 3
		reference_button.text = "Référence : crâne + côtes P6A3.6" if using_previous else "Modèle : squelette complet"
func toggle_reference() -> void:
	super.toggle_reference()
	reference_button.text = "Référence : crâne + côtes P6A3.6" if using_previous else "Modèle : squelette complet"
