class_name P6AMaterialPresets
extends RefCounted
## Explicit lab fixtures, never used by the ordinary P5 scene.
## Sculpt the real RF map, clamp to canonical Bone ceilings, then notify FossilState.
const NAMES := ["00 · Intact B-17", "01 · Worked Soil", "02 · Soil → Clay contact",
	"03 · Fresh Clay", "04 · Sandstone", "05 · Fracture / cavity",
	"06 · Dirty Bone Film", "07 · Partly cleaned Bone", "08 · Clean Bone", "09 · Material study"]
const NOTES := ["Closed incoming block. Brush to begin.", "Shallow brushed Soil; no invented persistent Soil dust.",
	"Brown Clay skin on the outer shelf; fresh orange cut at the centre. Toggle Patina.",
	"Fresh Clay floor with a narrow contact shelf. Chisel / Pick remain active.",
	"Sandstone floor, Clay walls and Soil rim. Optional second contact patina.",
	"Real Chisel impacts, fracture stress and debris in a layered cavity.",
	"Newly exposed Bone, original P4 spot mask and density. Compare film palette.",
	"Same Bone geometry; native Brush strokes clean the left side and a central strip.",
	"Same Bone geometry; all exposed Bone cleaned with the native film Brush API.",
	"Mixed cavity: Soil rim, contact skin, fresh Clay, Sandstone and three Bone cleaning states."]

static func apply(main: Node3D, preset: int) -> void:
	main.reset_specimen()
	var s: WorkingSurface = main.block.working_map
	if preset == 0: return
	var exposed := PackedInt32Array()
	for y in range(s.size.y):
		for x in range(s.size.x):
			var i := y * s.size.x + x
			var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(s.size)
			# Fixed shallow irregularity makes walls representative without random seeds.
			var q := (uv - Vector2(0.50, 0.53)) / Vector2(0.435, 0.405)
			var r := q.length() + 0.025 * sin(q.x * 17.0 + q.y * 8.0) + 0.017 * sin(q.y * 23.0)
			var soil := s.strata.packed_limits[i * 2]
			var stone := s.strata.packed_limits[i * 2 + 1]
			var height := 1.0
			if preset == 1:
				height = lerpf(0.87, 1.0, smoothstep(0.65, 0.98, r))
			elif preset in [2, 3]:
				height = lerpf(soil, 1.0, smoothstep(0.89, 0.98, r))
				var depth := 0.06 if preset == 2 else 0.115
				if r < 0.69: height = soil - depth * (1.0 - smoothstep(0.60, 0.69, r))
			else:
				height = lerpf(soil, 1.0, smoothstep(0.91, 0.98, r))
				if r < 0.83: height = lerpf(soil - 0.075, soil, smoothstep(0.77, 0.83, r))
				if r < 0.68: height = lerpf(stone - 0.008, soil - 0.075, smoothstep(0.62, 0.68, r))
				if preset >= 5 and r < 0.58:
					var floor_height := 0.155 + 0.011 * sin(x * 0.013) * sin(y * 0.017)
					height = lerpf(floor_height, stone - 0.008, smoothstep(0.51, 0.58, r))
			var ceiling := s.structural_ceilings[i]
			# Bone presets share EXACT geometry, including the matrix immediately around it.
			if preset >= 6:
				var bone_basin := ((uv - Vector2(0.48, 0.56)) / Vector2(0.35, 0.34)).length()
				if bone_basin < 1.0:
					height = minf(height, lerpf(0.14, height, smoothstep(0.88, 1.0, bone_basin)))
			height = maxf(height, ceiling)
			s._heights[i] = height
			if ceiling > 0.0 and height <= ceiling + FossilField.EXPOSURE_EPSILON: exposed.append(i)
	s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true
	s.fossil.expose_cells(exposed)
	if preset == 5:
		# Actual gameplay impact path, stress/debris/film emissions included.
		for p in [Vector2(706, 172), Vector2(716, 179), Vector2(724, 184), Vector2(730, 190)]:
			for n in range(3): s.apply_impact(p, main.controller.tools[1])
	if preset in [7, 9]:
		var brush: ToolDefinition = main.controller.tools[0]
		for y in range(170, 395, 16): s.bone_film.clean(Vector2(160, y), Vector2(330, y), brush, 2.0)
		s.bone_film.clean(Vector2(450, 210), Vector2(620, 370), brush, 0.42)
	if preset == 8:
		for y in range(0, s.size.y + 1, 20):
			s.bone_film.clean(Vector2(0, y), Vector2(s.size.x, y), main.controller.tools[0], 2.0)
	main.block.flush_texture()
	main.session.flush()
	main.controller.cancel_stroke()
	main.controller.refresh_view()
