extends "res://scripts/excavation/block/natural/natural_block.gd"
var rim: RefCounted
var render_image: Image
var render_builds := 0
func _ready() -> void:
	super._ready()
	rim = preload("res://scripts/excavation/block/rough/rough_rim.gd").new(footprint,surface_size)
	natural_wall.mesh = rim.mesh
	# Facets can protrude by up to 18 mm below the unchanged top domain.
	natural_wall.custom_aabb = surface.custom_aabb.grow(.02)
func enforce_void() -> void:
	super.enforce_void()
	if rim == null or rim.caps.is_empty(): return
	var changed := false
	for i in rim.caps:
		if working_map._heights[i] > rim.caps[i]:
			working_map._heights[i] = rim.caps[i]
			changed = true
	if changed:
		working_map.image.set_data(map_resolution.x,map_resolution.y,false,Image.FORMAT_RF,working_map._heights.to_byte_array())
		working_map.dirty = true
		flush_texture()
func _height_image_for_rendering() -> Image:
	if rim == null: return super._height_image_for_rendering()
	# Irregular clamp-to-edge guard for linear vertex sampling. WorkingSurface
	# keeps zero material outside; only this hidden one-texel guard is extended.
	var heights := working_map._heights.duplicate()
	for i in rim.padding: heights[i] = heights[rim.padding[i]]
	if render_image == null: render_image = Image.create(map_resolution.x,map_resolution.y,false,Image.FORMAT_RF)
	render_image.set_data(map_resolution.x,map_resolution.y,false,Image.FORMAT_RF,heights.to_byte_array())
	relief.image = render_image
	render_builds += 1
	return render_image

func pick(screen: Vector2, camera: Camera3D) -> Dictionary:
	# Delayed ticks can repick between impacts before the normal end-of-tick
	# upload. Keep geometry current here as the canonical height image was.
	if working_map.dirty: flush_texture()
	return super.pick(screen,camera)
