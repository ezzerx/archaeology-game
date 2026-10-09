class_name SoilFoundationProfile
extends RefCounted
## Lab-only initial conditions. The excavation kernel, tools and Bone stay P5.
## Static caches are built once; a reset copies them, never regenerates geology.
const MAX_SOIL_MM := 2.0
var limits: Array[PackedFloat32Array] = []
var substrates: Array[PackedFloat32Array] = []
var thin_tops: Array[PackedFloat32Array] = []
var build_count := 0
var build_usec := 0
var size: Vector2i

func _init(surface: WorkingSurface, fixture_count := 2) -> void:
	var started := Time.get_ticks_usec()
	size = surface.size
	var broad := FastNoiseLite.new()
	broad.seed = 61715
	broad.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	broad.frequency = 1.0
	broad.fractal_type = FastNoiseLite.FRACTAL_NONE
	var medium := FastNoiseLite.new()
	medium.seed = 1726
	medium.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	medium.frequency = 1.0
	medium.fractal_type = FastNoiseLite.FRACTAL_NONE
	for fixture in range(fixture_count):
		var layer_data := surface.strata.packed_limits.duplicate()
		var substrate := PackedFloat32Array()
		var top := PackedFloat32Array()
		substrate.resize(size.x * size.y)
		top.resize(substrate.size())
		for y in range(size.y):
			for x in range(size.x):
				var i := y * size.x + x
				var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(size)
				var upper := layer_data[i * 2]
				if fixture == 1:
					# Explicit pre-cut witness in an empty corner, shared by A and B.
					# Remove Clay here, without moving Stone or any Bone ceiling.
					var r := ((uv - Vector2(0.94, 0.12)) / Vector2(0.20, 0.25)).length()
					upper = lerpf(upper, layer_data[i * 2 + 1], 1.0 - smoothstep(0.60, 1.0, r))
					layer_data[i * 2] = upper
				substrate[i] = upper
				# Noise varies dirt coverage only. It never defines the geology/Bone.
				var b := broad.get_noise_2dv(uv * Vector2(6.6, 4.2))
				var m := medium.get_noise_2dv(uv * Vector2(25.3, 16.1))
				var coverage := smoothstep(-0.10, 0.22, b + 0.28 * m)
				var thickness_mm := MAX_SOIL_MM * coverage * (0.55 + 0.45 * clampf(0.5 + m, 0.0, 1.0))
				top[i] = upper + thickness_mm / (surface.excavatable_depth * 1000.0)
		limits.append(layer_data)
		substrates.append(substrate)
		thin_tops.append(top)
	build_count += 1
	build_usec = Time.get_ticks_usec() - started

func apply(block: ExcavationBlock, candidate: int, fixture: int, cleared: bool) -> void:
	var s := block.working_map
	s.strata.packed_limits = limits[fixture].duplicate()
	s.strata.boundaries.set_data(size.x, size.y, false, Image.FORMAT_RGF, s.strata.packed_limits.to_byte_array())
	block.layer_texture.update(s.strata.boundaries)
	if cleared:
		s._heights = substrates[fixture].duplicate()
	elif candidate == 1:
		s._heights = thin_tops[fixture].duplicate()
	# A keeps WorkingSurface.reset's original, perfectly flat 1.0 top.
	s.image.set_data(size.x, size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true
	block.flush_texture()
