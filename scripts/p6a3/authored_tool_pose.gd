extends ToolProxyPose
## Keep authored UVs/PBR and a continuous rigid silhouette at the real contact.
## Static probes reuse the existing surface-only clearance query (12 maximum).
var air_tool := false

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

func fit(proxy: Node3D, target: ExcavationBlock, recoil := 0.0) -> void:
	super.fit(proxy, target, 0.0)
	if air_tool:
		# A blower works above the surface: keep the nozzle/pear legible rather
		# than standing it vertically and hiding the jet behind the bulb.
		body.position = Vector3.ZERO
		body_lift = _clearance + .006
		proxy.global_position += target.global_basis.y * body_lift
		return
	# The old proxy separates tip/body vertically. Authored art stays one object:
	# stand the tool more upright in deep cavities, preserving contact at the tip.
	# Query only the excavated surface; never hidden Bone or picking state.
	var upright := clampf(_clearance / .014, 0.0, 1.0)
	proxy.global_basis = proxy.global_basis.slerp(Basis.IDENTITY, upright)
	body.position = Vector3.ZERO
	proxy.global_position += target.global_basis.y * maxf(recoil, 0.0)
	body_lift = maxf(recoil, 0.0)
