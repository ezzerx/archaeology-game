extends "res://scripts/specimens/mesh_base/production_mesh_view.gd"
## The complete display mesh never casts. Only committed, exposed Bone cells
## contribute to this shadow-only roof; no hidden source geometry can leak.
var shadow_caster: MeshInstance3D
var shadows_enabled := true
var shadow_dirty := true
var pilot_cells := PackedInt32Array()
var caster_cells := PackedInt32Array()
var roof_vertices := PackedVector3Array()
var cell_slots := PackedInt32Array()
var last_shadow_build_usec := 0
var max_shadow_build_usec := 0
var shadow_rebuild_count := 0
const ROOF_INSET_M := .00035

func _source_scene() -> PackedScene:
	return preload("res://assets/p6a35/b17_production_patch.glb")
func _bone_shader() -> Shader:
	return preload("res://shaders/p6a35_aesthetic_bone.gdshader")

func setup(target: ExcavationBlock) -> void:
	super.setup(target)
	shadow_caster = MeshInstance3D.new()
	shadow_caster.name = "ExposedBoneShadowsOnly"
	shadow_caster.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	var opaque := StandardMaterial3D.new()
	opaque.cull_mode = BaseMaterial3D.CULL_DISABLED
	shadow_caster.material_override = opaque
	add_child(shadow_caster)
	var field: FossilField = block.working_map.fossil.field
	for i in range(field.replacement.size()):
		if field.replacement[i] != 0: pilot_cells.append(i)
	_cache_roofs()
	block.working_map.fossil.bone_component_exposure_changed.connect(_exposure_changed)
	block.working_map.surface_reset.connect(_clear_shadow)
	sync_state()

func _exposure_changed(_component: int, _count: int, _total: int) -> void:
	shadow_dirty = true

func _clear_shadow() -> void:
	# Clear synchronously, including a reset before the next render frame.
	shadow_caster.mesh = null
	caster_cells.clear()
	shadow_dirty = true

func sync_state() -> void:
	super.sync_state()
	if shadow_caster == null: return
	if shadow_dirty: rebuild_shadows()
	shadow_caster.visible = enabled and shadows_enabled and block.debug_view == 0

func rebuild_shadows() -> void:
	var began := Time.get_ticks_usec()
	var s: WorkingSurface = block.working_map
	var field: FossilField = s.fossil.field
	caster_cells.clear()
	for i in pilot_cells:
		if s.fossil.exposed[i] != 0 and s._heights[i] <= field.ceilings[i]+FossilField.EXPOSURE_EPSILON:
			caster_cells.append(i)
	shadow_caster.mesh = null
	if not caster_cells.is_empty():
		var indices := PackedInt32Array()
		indices.resize(caster_cells.size()*6)
		for n in range(caster_cells.size()):
			var v := cell_slots[caster_cells[n]]*4
			var j := n*6
			indices[j] = v
			indices[j+1] = v+1
			indices[j+2] = v+2
			indices[j+3] = v
			indices[j+4] = v+2
			indices[j+5] = v+3
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = roof_vertices
		arrays[Mesh.ARRAY_INDEX] = indices
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		shadow_caster.mesh = mesh
	shadow_dirty = false
	last_shadow_build_usec = Time.get_ticks_usec()-began
	max_shadow_build_usec = maxi(max_shadow_build_usec,last_shadow_build_usec)
	shadow_rebuild_count += 1

func _cache_roofs() -> void:
	# Immutable coordinates are built once at loading; live updates only rebuild
	# the index list. Unreferenced vertices produce no casting triangles.
	var field: FossilField = block.working_map.fossil.field
	cell_slots.resize(field.replacement.size())
	cell_slots.fill(-1)
	roof_vertices.resize(pilot_cells.size()*4)
	var step := block.surface_size/Vector2(field.size)
	for n in range(pilot_cells.size()):
		var i := pilot_cells[n]
		cell_slots[i] = n
		@warning_ignore("integer_division")
		var p := Vector2(i%field.size.x,i/field.size.x)*step-block.surface_size*.5
		var h := block.base_height+field.ceilings[i]*(block.thickness-block.base_height)-ROOF_INSET_M
		roof_vertices[n*4] = Vector3(p.x,h,p.y)
		roof_vertices[n*4+1] = Vector3(p.x+step.x,h,p.y)
		roof_vertices[n*4+2] = Vector3(p.x+step.x,h,p.y+step.y)
		roof_vertices[n*4+3] = Vector3(p.x,h,p.y+step.y)
