extends ExcavationBlock
## Refine exposed pilot-Bone contact against its display triangles. Matrix and
## unrelated anatomy keep the historical ray picker; no physics collider added.
var bone_query: TriangleMesh
func _create_fossil_field() -> FossilField:
	return preload("res://scripts/p6a36/mesh_fossil_field.gd").new(map_resolution)

func _ready() -> void:
	super._ready()
	var source: Node3D = _contact_source_scene().instantiate()
	add_child(source)
	var faces := PackedVector3Array()
	for mesh: MeshInstance3D in source.find_children("*","MeshInstance3D",true,false):
		var transform: Transform3D = global_transform.affine_inverse()*mesh.global_transform
		for surface_id in range(mesh.mesh.get_surface_count()):
			var arrays := mesh.mesh.surface_get_arrays(surface_id)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			for index in arrays[Mesh.ARRAY_INDEX]: faces.append((transform*vertices[index])*1000.0)
	bone_query = TriangleMesh.new()
	bone_query.create_from_faces(faces)
	source.free()

func pick(screen: Vector2, camera: Camera3D) -> Dictionary:
	var native := super.pick(screen,camera)
	if bone_query == null or not native.inside or not native.bone_exposed: return native
	var field: FossilField = working_map.fossil.field
	if field.replacement[native.cell.y*map_resolution.x+native.cell.x] == 0: return native
	var inverse := global_transform.affine_inverse()
	var origin: Vector3 = inverse*camera.project_ray_origin(screen)
	var direction: Vector3 = inverse.basis*camera.project_ray_normal(screen)
	var actual := bone_query.intersect_ray(origin*1000.0,direction)
	if actual.is_empty(): return native
	var local: Vector3 = actual.position*.001
	if local.distance_to(native.local) > .005: return native
	var uv := SurfaceMapping.local_to_uv(local,surface_size).clamp(Vector2.ZERO,Vector2.ONE)
	var cell := SurfaceMapping.uv_to_cell(uv,map_resolution)
	var index := cell.y*map_resolution.x+cell.x
	if field.replacement[index] == 0 or working_map.fossil.exposed[index] == 0: return native
	if working_map._heights[index] > field.ceilings[index]+FossilField.EXPOSURE_EPSILON: return native
	var height := (local.y-base_height)/(thickness-base_height)
	native.merge({"local":local,"world":to_global(local),"uv":uv,
		"map":SurfaceMapping.uv_to_map(uv,map_resolution),"cell":cell,
		"local_normal":actual.normal,"normal":(inverse.basis.transposed()*actual.normal).normalized(),
		"height":height,"depth":thickness-local.y,"mesh_contact_refined":true,
		"material":working_map.strata.surface_material_at(uv,height),"bone_component":field.component_ids[index],
		"bone_ceiling":field.ceilings[index],"cell_height":working_map._heights[index]},true)
	return native

func _contact_source_scene() -> PackedScene:
	return preload("res://assets/p6a36/b17_production_patch.glb")
