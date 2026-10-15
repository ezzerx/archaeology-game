extends "res://scripts/p6a37/production_block.gd"
var footprint: RefCounted
var natural_wall: MeshInstance3D
var matrix_edges: Node
func _ready() -> void:
	super._ready()
	footprint = _create_footprint()
	relief.surface_domain = footprint.contains_uv
	var loose := working_map.loose_debris
	loose.physics = preload("res://scripts/p6a40/natural_debris.gd").new(relief,loose.physics.profile,loose.profile.matrix_crumb_cap)
	loose.physics.debris_ejected.connect(loose._on_physical_exit)
	for child in get_children():
		if child is MeshInstance3D and child != surface: child.hide()
	natural_wall = MeshInstance3D.new()
	natural_wall.name = "NaturalMatrixWalls"
	natural_wall.mesh = footprint.wall_mesh(surface_size)
	natural_wall.material_override = skirt_material
	natural_wall.custom_aabb = surface.custom_aabb
	add_child(natural_wall)
func enforce_void() -> void:
	var changed := false
	for i in footprint.outside:
		if working_map._heights[i] != 0:
			working_map._heights[i] = 0.0
			changed = true
	if changed:
		working_map.image.set_data(map_resolution.x,map_resolution.y,false,Image.FORMAT_RF,working_map._heights.to_byte_array())
		working_map.dirty = true
		flush_texture()

func pick(screen: Vector2, camera: Camera3D) -> Dictionary:
	var hit := super.pick(screen,camera)
	if not hit.inside or matrix_edges == null or hit.bone: return hit
	var i: int = hit.cell.y*map_resolution.x+hit.cell.x
	if matrix_edges.edges[i] == 0 and not matrix_edges.pending.has(i): return hit
	var limits := Vector2(working_map.strata.packed_limits[i*2],working_map.strata.packed_limits[i*2+1])
	var layer := Stratigraphy.index_at(working_map._heights[i]-Stratigraphy.SURFACE_EPSILON,limits)
	hit.material = working_map.strata.materials[layer]
	return hit

func _create_footprint() -> RefCounted:
	return preload("res://scripts/p6a40/footprint.gd").new(map_resolution)
