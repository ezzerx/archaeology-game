class_name NaturalMatrixFixtures
extends RefCounted
## Controlled review fixtures. No alternate tool logic; not a generation system.
const PATH_FROM := Vector2(180, 225)
const PATH_TO := Vector2(815, 285)
const BONE_REGION := Rect2i(222, 208, 106, 87)

static func apply(main: Node3D, fixture: int) -> void:
	var s: WorkingSurface = main.block.working_map
	if fixture == 2:
		# 72 regular Chisel impacts across basin/shoulder/ridge. Same work A/B.
		for n in range(72):
			s.apply_impact(PATH_FROM.lerp(PATH_TO, float(n) / 71), main.controller.tools[1])
	elif fixture == 3:
		# Native Bone-safe Pick raster, no manual exposure or Bone mesh staging.
		for y in range(BONE_REGION.position.y, BONE_REGION.end.y, 7):
			for x in range(BONE_REGION.position.x, BONE_REGION.end.x, 7):
				for n in range(4): s.apply_impact(Vector2(x, y), main.controller.tools[3])
	elif fixture == 4:
		# A diagnostic open cut through both real interfaces, never new geology.
		for y in range(s.size.y):
			for x in range(s.size.x):
				var i := y * s.size.x + x
				var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(s.size)
				var r := ((uv - Vector2(0.80, 0.30)) / Vector2(0.17, 0.16)).length()
				if r >= 1.0: continue
				var cut := lerpf(0.36, s._heights[i], smoothstep(0.55, 1.0, r))
				s._heights[i] = maxf(minf(s._heights[i], cut), s.structural_ceilings[i])
		var exposed := PackedInt32Array()
		for i in range(s._heights.size()):
			if s.structural_ceilings[i] > 0 and s._heights[i] <= s.structural_ceilings[i] + FossilField.EXPOSURE_EPSILON: exposed.append(i)
		s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
		s.dirty = true
		s.fossil.expose_cells(exposed)
	main.block.flush_texture()
	main.session.flush()
	main.controller.cancel_stroke()
	main.controller.refresh_view()
