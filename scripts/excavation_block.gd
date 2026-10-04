class_name ExcavationBlock
extends Node3D

signal debris_ejected(world_position: Vector3, direction: Vector3, amount: float, material_type: StringName)

@export var surface_size := Vector2(1.1, 0.7)
@export_range(0.01, 0.5) var thickness := 0.12
@export_range(0.001, 0.1) var base_height := 0.018
@export var map_resolution := Vector2i(1024, 640)
@export var reactions: ReactionProfile = preload("res://config/material_reactions.tres")
@export var material_definitions: Array[MaterialDefinition] = [
	preload("res://config/loose_soil.tres"), preload("res://config/compact_clay.tres"),
	preload("res://config/sandstone.tres")]

var working_map: WorkingSurface
var relief: ReliefSurface
var texture: ImageTexture
var layer_texture: ImageTexture
var residue_texture: ImageTexture
var fossil_texture: ImageTexture
var fracture_texture: ImageTexture
var last_fracture_upload_usec := 0
var fracture_upload_count := 0
var material: ShaderMaterial
var skirt_material: ShaderMaterial
var last_upload_usec := 0
var upload_count := 0
var last_residue_upload_usec := 0
var residue_upload_count := 0
var debug_view := 0

@onready var surface: MeshInstance3D = $SurfaceMesh
@onready var body: StaticBody3D = $Body

func _on_debris_ejected(point: Vector2, direction: Vector2, amount: float, layer: int) -> void:
	var uv := (point + Vector2.ONE * 0.5) / Vector2(map_resolution)
	var position_world := to_global(Vector3((uv.x - 0.5) * surface_size.x,
		relief.height_at(uv) + 0.005, (uv.y - 0.5) * surface_size.y))
	var direction_world := (global_basis * Vector3(direction.x * surface_size.x / map_resolution.x,
		0, direction.y * surface_size.y / map_resolution.y)).normalized()
	debris_ejected.emit(position_world, direction_world, amount, material_definitions[layer].id)

func _ready() -> void:
	assert(surface_size.x > 0.0 and surface_size.y > 0.0 and thickness > base_height)
	var strata := Stratigraphy.new(map_resolution, material_definitions)
	working_map = WorkingSurface.new(map_resolution, strata, FossilField.new(map_resolution), reactions)
	working_map.loose_debris.ejected.connect(_on_debris_ejected)
	relief = ReliefSurface.new(working_map.image, surface_size, map_resolution, base_height, thickness)
	texture = ImageTexture.create_from_image(working_map.image)
	layer_texture = ImageTexture.create_from_image(strata.boundaries)
	residue_texture = ImageTexture.create_from_image(working_map.residue.image)
	fossil_texture = ImageTexture.create_from_image(working_map.fossil.field.image)
	fracture_texture = ImageTexture.create_from_image(working_map.fracture.image)
	working_map.fracture.dirty = false
	working_map.dirty = false
	working_map.residue.dirty = false
	material = surface.material_override.duplicate() as ShaderMaterial
	material.set_shader_parameter("working_map", texture)
	material.set_shader_parameter("layer_boundaries", layer_texture)
	material.set_shader_parameter("residue_map", residue_texture)
	material.set_shader_parameter("fossil_map", fossil_texture)
	material.set_shader_parameter("fracture_map", fracture_texture)
	material.set_shader_parameter("fracture_sizes", Vector2(reactions.patch_size(1), reactions.patch_size(2)))
	material.set_shader_parameter("fracture_seed", float(posmod(reactions.seed, 97)) / 97.0)
	material.set_shader_parameter("bone_exposure_epsilon", FossilField.EXPOSURE_EPSILON)
	material.set_shader_parameter("map_size", Vector2(map_resolution))
	material.set_shader_parameter("surface_size", surface_size)
	material.set_shader_parameter("base_height", base_height)
	material.set_shader_parameter("excavatable_height", thickness - base_height)
	for i in range(3):
		material.set_shader_parameter(["soil_color", "clay_color", "sandstone_color"][i], material_definitions[i].debug_color)
	surface.material_override = material
	var plane := surface.mesh as PlaneMesh
	plane.size = surface_size
	plane.subdivide_width = map_resolution.x - 1
	plane.subdivide_depth = map_resolution.y - 1
	surface.position = Vector3.ZERO
	surface.custom_aabb = AABB(Vector3(-surface_size.x * 0.5, 0, -surface_size.y * 0.5), Vector3(surface_size.x, thickness, surface_size.y))
	var skirt := MeshInstance3D.new()
	skirt.name = "ReliefSides"
	skirt.mesh = relief.create_skirt()
	skirt.custom_aabb = surface.custom_aabb
	skirt_material = material.duplicate() as ShaderMaterial
	skirt_material.set_shader_parameter("is_skirt", true)
	skirt.material_override = skirt_material
	add_child(skirt)
	($Sides.mesh as BoxMesh).size = Vector3(surface_size.x, base_height, surface_size.y)
	$Sides.position.y = base_height * 0.5
	# Keep the solid base's bottom and walls. The heightfield itself is its top
	# cap at minimum depth; a second coplanar cap would flicker through the floor.
	var base_arrays := ($Sides.mesh as BoxMesh).get_mesh_arrays()
	var base_normals: PackedVector3Array = base_arrays[Mesh.ARRAY_NORMAL]
	var base_indices: PackedInt32Array = base_arrays[Mesh.ARRAY_INDEX]
	var open_top_indices := PackedInt32Array()
	for i in range(0, base_indices.size(), 3):
		if base_normals[base_indices[i]].y < 0.5:
			open_top_indices.append_array(base_indices.slice(i, i + 3))
	base_arrays[Mesh.ARRAY_INDEX] = open_top_indices
	var base_mesh := ArrayMesh.new()
	base_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, base_arrays)
	$Sides.mesh = base_mesh
	($Body/CollisionShape3D.shape as BoxShape3D).size = Vector3(surface_size.x, thickness, surface_size.y)
	$Body/CollisionShape3D.position.y = thickness * 0.5

func pick(screen: Vector2, camera: Camera3D) -> Dictionary:
	var result := {"screen": screen, "inside": false}
	if not get_viewport().get_visible_rect().has_point(screen):
		return result
	var inverse := global_transform.affine_inverse()
	var hit := relief.ray_hit(inverse * camera.project_ray_origin(screen),
		inverse.basis * camera.project_ray_normal(screen), camera.far)
	if hit.is_empty():
		return result
	var uv := SurfaceMapping.local_to_uv(hit.local, surface_size).clamp(Vector2.ZERO, Vector2.ONE)
	var height := clampf((hit.local.y - base_height) / (thickness - base_height), 0.0, 1.0)
	result.merge(hit)
	result.merge({"inside": true, "world": to_global(hit.local), "uv": uv,
		"normal": (inverse.basis.transposed() * hit.local_normal).normalized(),
		"map": SurfaceMapping.uv_to_map(uv, map_resolution),
		"cell": SurfaceMapping.uv_to_cell(uv, map_resolution),
		"height": height, "depth": thickness - hit.local.y,
		"material": working_map.strata.material_at(uv, height)}, true)
	var cell: Vector2i = result.cell
	var index := cell.y * map_resolution.x + cell.x
	var component := working_map.fossil.field.component_ids[index]
	result.merge({"bone": component != 0, "bone_component": component,
		"bone_ceiling": working_map.fossil.field.ceilings[index],
		"bone_exposed": working_map.fossil.exposed[index] != 0,
		"cell_height": working_map.value_at(cell)})
	return result

func show_cursor(hit: Dictionary, radius: float, color := Color(0.95, 0.8, 0.2)) -> void:
	material.set_shader_parameter("cursor_visible", hit.inside)
	material.set_shader_parameter("cursor_radius", radius)
	material.set_shader_parameter("cursor_color", color)
	if hit.inside:
		material.set_shader_parameter("cursor_uv", hit.uv)

func set_debug_view(view: int) -> void:
	debug_view = posmod(view, 4)
	material.set_shader_parameter("debug_view", debug_view)
	skirt_material.set_shader_parameter("debug_view", debug_view)

func flush_texture() -> void:
	last_upload_usec = 0
	last_residue_upload_usec = 0
	last_fracture_upload_usec = 0
	if working_map.dirty:
		var start := Time.get_ticks_usec()
		texture.update(working_map.image)
		last_upload_usec = Time.get_ticks_usec() - start
		upload_count += 1
		working_map.dirty = false
	if working_map.residue.dirty:
		var start := Time.get_ticks_usec()
		residue_texture.update(working_map.residue.image)
		last_residue_upload_usec = Time.get_ticks_usec() - start
		residue_upload_count += 1
		working_map.residue.dirty = false
	if working_map.fracture.dirty:
		var start := Time.get_ticks_usec()
		fracture_texture.update(working_map.fracture.image)
		last_fracture_upload_usec = Time.get_ticks_usec() - start
		fracture_upload_count += 1
		working_map.fracture.dirty = false
