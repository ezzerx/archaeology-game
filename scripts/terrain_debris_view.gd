class_name TerrainDebrisView
extends MultiMeshInstance3D
## One fixed pool; the P4-V1 hard mesh and face colors are shared unchanged.
var simulation: TerrainDebris
var block: ExcavationBlock
var colors: Array
var last_update_usec := 0

func setup(target: ExcavationBlock, state: TerrainDebris, mesh: Mesh, palette: Array) -> void:
	block = target
	simulation = state
	colors = palette
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = mesh
	multimesh.instance_count = simulation.fragments.size()
	multimesh.visible_instance_count = 0
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.78
	material_override = material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func sync() -> void:
	var started := Time.get_ticks_usec()
	# Local coordinates stay valid if the block is translated/rotated in a scene.
	global_transform = block.global_transform
	var slot := 0
	for f in simulation.fragments:
		if not f.active: continue
		var fade := simulation.visibility_scale(f)
		var basis := Basis(TerrainDebris.ROTATION_AXIS, f.rotation).scaled(f.size * fade)
		var position_local := f.position
		# Shrink toward the contact, so the fade never leaves a floating speck.
		if f.state == TerrainDebris.State.SLEEPING: position_local.y -= f.support_height() * (1.0 - fade)
		multimesh.set_instance_transform(slot, Transform3D(basis, position_local))
		multimesh.set_instance_color(slot, colors[f.material])
		slot += 1
	multimesh.visible_instance_count = slot
	last_update_usec = Time.get_ticks_usec() - started
