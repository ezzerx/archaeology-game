class_name ExcavationBlock
extends Node3D

@export var surface_size := Vector2(1.1, 0.7)
@export_range(0.01, 0.5) var thickness := 0.12
@export var map_resolution := Vector2i(1024, 640)

var working_map: WorkingSurface
var texture: ImageTexture
var material: ShaderMaterial

@onready var surface: MeshInstance3D = $SurfaceMesh
@onready var body: StaticBody3D = $Body

func _ready() -> void:
	assert(surface_size.x > 0.0 and surface_size.y > 0.0)
	working_map = WorkingSurface.new(map_resolution)
	texture = ImageTexture.create_from_image(working_map.image)
	working_map.dirty = false
	material = surface.material_override.duplicate() as ShaderMaterial
	material.set_shader_parameter("working_map", texture)
	material.set_shader_parameter("map_size", Vector2(map_resolution))
	surface.material_override = material
	(surface.mesh as PlaneMesh).size = surface_size
	surface.position.y = thickness + 0.0001
	var dimensions := Vector3(surface_size.x, thickness, surface_size.y)
	($Sides.mesh as BoxMesh).size = dimensions
	$Sides.position.y = thickness * 0.5
	($Body/CollisionShape3D.shape as BoxShape3D).size = dimensions
	$Body/CollisionShape3D.position.y = thickness * 0.5

func pick(screen: Vector2, camera: Camera3D) -> Dictionary:
	# Call from the physics tick only. Collision layer 1 belongs to the block.
	var result := {"screen": screen, "inside": false}
	if not get_viewport().get_visible_rect().has_point(screen):
		return result
	var origin := camera.project_ray_origin(screen)
	var query := PhysicsRayQueryParameters3D.create(origin,
		origin + camera.project_ray_normal(screen) * camera.far, 1)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or hit.collider != body:
		return result
	var local_point := to_local(hit.position)
	var normal: Vector3 = global_transform.basis.transposed() * hit.normal
	var uv := SurfaceMapping.local_to_uv(local_point, surface_size)
	result.merge({"world": hit.position, "local": local_point, "uv": uv,
		"map": SurfaceMapping.uv_to_map(uv, map_resolution),
		"cell": SurfaceMapping.uv_to_cell(uv, map_resolution)})
	# Reject side faces: clamping a side hit would paint an unrelated edge texel.
	result.inside = normal.normalized().dot(Vector3.UP) > 0.99 and SurfaceMapping.contains_uv(uv)
	return result

func show_cursor(hit: Dictionary, radius: float) -> void:
	material.set_shader_parameter("cursor_visible", hit.inside)
	material.set_shader_parameter("cursor_radius", radius)
	if hit.inside:
		material.set_shader_parameter("cursor_uv", hit.uv)

func flush_texture() -> void:
	if working_map.dirty:
		texture.update(working_map.image)
		working_map.dirty = false
