extends ToolProxyPose
## Keep authored UVs/PBR and a continuous rigid silhouette at the real contact.
## Static probes reuse the existing surface-only clearance query (12 maximum).


func attach(scene: PackedScene) -> void:
	var source := scene.instantiate()
	for original: MeshInstance3D in source.find_children("*", "MeshInstance3D", true, false):
		var mesh := original.duplicate() as MeshInstance3D
		var is_tip := original.name.begins_with("Tip")
		(tip if is_tip else body).add_child(mesh)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if not is_tip:
			for surface in range(mesh.mesh.get_surface_count()):
				var arrays := mesh.mesh.surface_get_arrays(surface)
				for index in arrays[Mesh.ARRAY_INDEX]:
					_body_vertices.append(mesh.transform * arrays[Mesh.ARRAY_VERTEX][index])
	source.free()
	finish()
