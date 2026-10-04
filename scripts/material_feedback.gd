class_name MaterialFeedback
extends Node3D
## Visual/audio consumer only. Bounded MultiMesh pools; no physical colliders.
var block: ExcavationBlock
var controller: ToolController
var profile: ReactionProfile
var audio: MaterialAudio
var loose_view: LooseDebrisView
var crumb_physics_enabled: bool:
	get: return block.working_map.loose_debris.physics_enabled
	set(value): block.working_map.loose_debris.physics_enabled = value
var airflow := Vector3(-0.07, 0.02, -0.06)
var proxies: Array[Node3D] = []
var proxy_poses: Array[ToolProxyPose] = []
var pools: Array[MultiMesh] = []
var particles: Array[Array] = [[], [], [], []]
var rng := RandomNumberGenerator.new()
var recoil_remaining := 0.0
var sweep_remaining := 0.0
var bone_remaining := 0.0
var bone_ring: MeshInstance3D
var action_count := 0
var emitted := PackedInt32Array([0, 0, 0, 0])
var particles_enabled := true
var last_proxy_usec := 0
var proxies_enabled := true # Diagnostic A/B switch; does not disable other feedback.
var last_action_usec := 0
var last_particles_usec := 0
var _warmup_frames := 2
var colors := [Color(0.48, 0.30, 0.14), Color(0.57, 0.27, 0.12), Color(0.76, 0.62, 0.39), Color(0.72, 0.67, 0.53)]

func setup(target: ExcavationBlock, input: ToolController) -> void:
	block = target
	controller = input
	profile = block.reactions
	rng.seed = profile.seed
	audio = MaterialAudio.new()
	audio.name = "MaterialAudio"
	add_child(audio)
	audio.setup(profile)
	_create_proxies()
	_create_particles()
	loose_view = LooseDebrisView.new()
	loose_view.name = "PersistentLooseDebris"
	add_child(loose_view)
	loose_view.setup(block)
	bone_ring = MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.013
	ring.outer_radius = 0.015
	ring.rings = 16
	ring.ring_segments = 6
	bone_ring.mesh = ring
	bone_ring.material_override = _material(Color(0.98, 0.93, 0.78))
	bone_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bone_ring.hide()
	add_child(bone_ring)
	block.working_map.material_action.connect(on_action)
	block.working_map.air_jet_applied.connect(on_air_jet)
	block.working_map.surface_reset.connect(reset)
	controller.tool_selected.connect(func(_index: int): recoil_remaining = 0.0)

func _material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.78
	return result

func _part(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.subdivide_width = 1
	mesh.subdivide_height = 4
	mesh.subdivide_depth = 1
	part.mesh = mesh
	part.position = at
	part.material_override = _material(color)
	part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(part)
	proxy_poses.back().register_part(part, 0.017 if proxies.size() == 1 else 0.004)

func _create_proxies() -> void:
	var wood := Color(0.30, 0.17, 0.07)
	var metal := Color(0.36, 0.40, 0.41)
	for i in range(4):
		var proxy := Node3D.new()
		proxy.name = ["BrushProxy", "ChiselProxy", "BlowerProxy", "PrecisionPickProxy"][i]
		add_child(proxy)
		proxies.append(proxy)
		proxy_poses.append(ToolProxyPose.new())
		proxy_poses.back().setup(proxy)
		# Tip at origin; the handle extends away from the precise contact marker.
		if i == 0:
			_part(proxy, Vector3(0.009, 0.055, 0.008), Vector3(0, 0.059, 0), wood)
			_part(proxy, Vector3(0.014, 0.015, 0.006), Vector3(0, 0.024, 0), metal)
			for bristle in range(7):
				_part(proxy, Vector3(0.0017, 0.017, 0.004), Vector3((bristle - 3) * 0.0018, 0.009, 0), Color(0.76, 0.63, 0.38))
		elif i == 1:
			_part(proxy, Vector3(0.007, 0.035, 0.004), Vector3(0, 0.0175, 0), Color(0.28, 0.34, 0.38))
			_part(proxy, Vector3(0.010, 0.04, 0.008), Vector3(0, 0.055, 0), wood)
		elif i == 2:
			_part(proxy, Vector3(0.008, 0.046, 0.008), Vector3(0, 0.023, 0), metal)
			_part(proxy, Vector3(0.016, 0.028, 0.012), Vector3(0, 0.060, 0), Color(0.14, 0.26, 0.24))
		else:
			_part(proxy, Vector3(0.0015, 0.013, 0.0015), Vector3(0, 0.0065, 0), Color(0.72, 0.76, 0.77))
			_part(proxy, Vector3(0.003, 0.025, 0.003), Vector3(0, 0.0255, 0), metal)
			_part(proxy, Vector3(0.007, 0.032, 0.007), Vector3(0, 0.054, 0), Color(0.27, 0.36, 0.25))
		proxy_poses.back().finish()
		proxy.hide()

func _create_particles() -> void:
	for family in range(4):
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.use_colors = true
		var chip := BoxMesh.new()
		chip.size = Vector3.ONE
		multi.mesh = QuadMesh.new() if family == 3 else chip
		if family in [1, 2]: multi.mesh = DebrisVisualMesh.with_face_contrast(chip)
		multi.instance_count = profile.particles_per_family
		# Draw a sub-pixel instance below the opaque block for two startup frames.
		# This compiles the instanced material before the first real interaction.
		multi.set_instance_transform(0, Transform3D(Basis().scaled(Vector3.ONE * 0.00001), Vector3.ZERO))
		multi.set_instance_color(0, colors[family])
		multi.visible_instance_count = 1
		var node := MultiMeshInstance3D.new()
		node.name = ["SoilGrains", "ClayChips", "StoneFragments", "AirDust"][family]
		node.multimesh = multi
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var mat := _material(Color.WHITE)
		mat.vertex_color_use_as_albedo = true
		if family == 3:
			var gradient := Gradient.new()
			gradient.offsets = PackedFloat32Array([0, 0.3, 1])
			gradient.colors = PackedColorArray([Color(1, 1, 1, 0.7), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0)])
			var texture := GradientTexture2D.new()
			texture.gradient = gradient
			texture.fill = GradientTexture2D.FILL_RADIAL
			texture.fill_from = Vector2(0.5, 0.5)
			texture.fill_to = Vector2(1.0, 0.5)
			mat.albedo_texture = texture
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
			mat.billboard_keep_scale = true
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = mat
		add_child(node)
		pools.append(multi)

func point_world(point: Vector2) -> Vector3:
	var uv := (point + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
	return block.to_global(Vector3((uv.x - 0.5) * block.surface_size.x,
		block.relief.height_at(uv) + 0.001, (uv.y - 0.5) * block.surface_size.y))

func _emit(family: int, point: Vector2, count: int, impact := Vector2(INF, INF), detached_depth := 0.0) -> void:
	if not particles_enabled or profile.particle_amount <= 0:
		return
	var origin := point_world(point)
	var center := point_world(impact if impact.is_finite() else point)
	var debris := block.working_map.loose_debris.profile
	for i in range(mini(ceili(count * profile.particle_amount), 16)):
		if particles[family].size() >= profile.particles_per_family: break
		var scale_value := rng.randf_range(0.001, 0.0025) if family in [0, 3] else rng.randf_range(debris.chunk_width.x, debris.chunk_width.y)
		# P4-A plate/shard proportions for hard material; recent Soil unchanged.
		var shape := Vector3(scale_value, scale_value * 0.32, scale_value * 0.75)
		if family in [1, 2]: shape = Vector3(scale_value, scale_value * (0.24 if family == 1 else 0.7), scale_value)
		var velocity := Vector3(rng.randf_range(-0.04, 0.04), rng.randf_range(0.035, 0.10), rng.randf_range(-0.04, 0.04))
		var spawn := origin
		if family in [1, 2]:
			var away := Vector3(origin.x - center.x, 0, origin.z - center.z)
			if away.length_squared() < 0.000001:
				var angle := rng.randf_range(-PI, PI)
				away = Vector3(cos(angle), 0, sin(angle))
			away = away.normalized()
			# Substantial P4-A break-off pieces, still clearing the contact centre.
			var distance := maxf(Vector2(origin.x - center.x, origin.z - center.z).length(), 0.004)
			spawn = Vector3(center.x, origin.y, center.z) + away * distance
			# The event arrives after excavation: launch from the removed plate's
			# top, not its new floor where outward pieces would vanish into walls.
			# Static source estimate only; no moving-terrain physics or sampling.
			spawn.y += detached_depth * (block.relief.top_height - block.relief.floor_height)
			velocity = away * rng.randf_range(0.09, 0.14) + Vector3.UP * rng.randf_range(0.035, 0.10)
		if family == 3: velocity += airflow
		var lifetime := block.working_map.loose_debris.profile.chunk_lifetime * rng.randf_range(0.85, 1.15) \
			if family in [1, 2] else profile.particle_lifetime * rng.randf_range(0.65, 1.2)
		particles[family].append({"position": spawn, "velocity": velocity, "life": lifetime,
			"shape": shape, "rotation": rng.randf_range(-PI, PI), "floor": origin.y, "impact": center})
		emitted[family] += 1

func on_air_jet(_from: Vector2, _to: Vector2, _radius: float, _falloff: float, _delta: float, _direction: Vector2) -> void:
	if block.working_map.loose_debris.last_blown > 0:
		sweep_remaining = 0.12
		# Existing dirt events already play this sound. Clean terrain needs it too.
		if block.working_map.last_action.is_empty(): audio.play_family(&"air", 0.25)

func debris_debug() -> String:
	var state := block.working_map.loose_debris
	return ("Crumb Physics: %s [F3] | Soil grains: %d / %d | Matrix crumbs: %d / %d\n" % [
		"ON" if crumb_physics_enabled else "OFF", state.count_for(0), state.profile.soil_grain_cap,
		state.count_for(1), state.profile.matrix_crumb_cap]
		+ "Clay: %d | Sandstone: %d | Moving matrix: %d | Sleeping: %d | Fine Dust: separate\n" % [
		state.layer_counts[1], state.layer_counts[2], state.physics.active_count - state.physics.sleeping_count, state.physics.sleeping_count]
		+ "Terrain samples: %d (tick %d) | CPU: %d us | MultiMesh: %d us\n" % [
		state.samples_last_frame, state.physics.last_samples, state.physics.last_step_usec, loose_view.last_update_usec])

func _lift_dust(packets: Array, direction: Vector2) -> void:
	if not particles_enabled or profile.particle_amount <= 0: return
	for packet in packets:
		if particles[3].size() >= profile.particles_per_family: break
		var amount: float = packet.amount
		if amount <= 0: continue
		var point: Vector2 = packet.point
		var origin := point_world(point)
		var side := Vector3(-direction.y, 0, direction.x)
		var velocity := Vector3(direction.x, 0, direction.y) * rng.randf_range(0.13, 0.19) \
			+ side * rng.randf_range(-0.018, 0.018) + Vector3.UP * rng.randf_range(0.018, 0.035)
		var width := clampf(sqrt(amount) * 0.014, 0.001, 0.025)
		var lifetime := rng.randf_range(0.55, 0.9)
		particles[3].append({"position": origin, "velocity": velocity, "life": lifetime, "duration": lifetime,
			"shape": Vector3.ONE * width, "rotation": 0.0, "floor": origin.y,
			"source": point, "amount": amount, "dust": true, "color": dust_color_at(point)})
		emitted[3] += 1

func dust_color_at(point: Vector2) -> Color:
	# Match the shader's local-material approximation, including dirty ivory.
	var surface := block.working_map
	var cell := Vector2i(point.round()).clamp(Vector2i.ZERO, surface.size - Vector2i.ONE)
	var index := cell.y * surface.size.x + cell.x
	if surface.fossil != null and surface.fossil.exposed[index] != 0:
		return Color(0.87, 0.79, 0.63)
	var layer := Stratigraphy.index_at(surface.value_at(cell), Vector2(surface.strata.packed_limits[index * 2], surface.strata.packed_limits[index * 2 + 1]))
	return [Color(0.48, 0.30, 0.14), Color(0.62, 0.36, 0.20), Color(0.76, 0.65, 0.47)][layer]

func on_action(event: Dictionary) -> void:
	var action_started := Time.get_ticks_usec()
	action_count += 1
	var removed: Vector3 = event.removed
	var point: Vector2 = event.point
	var loose_cleared: float = event.get("loose_cleared", 0.0)
	var protected_contact: bool = event.get("bone_protected_contact", false)
	var damaging_hit: bool = event.direct_bone_hit and event.get("bone_damage", 0.0) > 0.0
	if event.tool == &"chisel":
		recoil_remaining = 0.14
		var layer := 1
		if removed.y + removed.z > 0:
			# Mixed footprints sound like the material actually removed most, not
			# whichever fracture patch happened to be iterated first.
			layer = 2 if removed.z > removed.y else 1
		elif block.working_map.value_at(Vector2i(point.round())) <= block.working_map.strata.sample_limits((point + Vector2.ONE * 0.5) / Vector2(block.map_resolution)).y: layer = 2
		if not protected_contact and not damaging_hit and (not event.direct_bone_hit or removed.length_squared() > 0 or event.marks > 0):
			audio.play_family(&"chisel_clay" if layer == 1 else &"chisel_stone", 0.72 if event.chunks.is_empty() else 1.0, true)
		var debris := block.working_map.loose_debris.profile
		for chunk in event.chunks:
			_emit(chunk.layer, chunk.point, clampi(ceili(float(chunk.cells) / debris.chunk_cells_per_particle), 1, debris.chunk_particles_per_patch),
				point, chunk.volume / chunk.cells)
	elif event.tool == &"soft_brush":
		sweep_remaining = 0.12
		if removed.x + removed.y + event.residue_cleared + loose_cleared > 0:
			audio.update_brush(event.movement, removed.x + removed.y + event.residue_cleared + loose_cleared,
				removed.y > removed.x)
			if removed.y > removed.x: _emit(0, point, 1)
	elif event.tool == &"precision_pick" and removed.length_squared() > 0:
		recoil_remaining = 0.14
		audio.play_family(&"precision_pick", 0.3, true)
	elif event.tool == &"air_blower" and event.residue_cleared + loose_cleared > 0:
		sweep_remaining = 0.12
		var direction: Vector2 = event.get("direction", Vector2(-1, -1).normalized())
		airflow = Vector3(direction.x * 0.14, 0.02, direction.y * 0.14)
		audio.play_family(&"air", clampf(event.residue_cleared + loose_cleared, 0.25, 0.8))
		_lift_dust(event.get("cleared_dust", []), direction)
	if removed.x > 0: _emit(0, point, clampi(ceili(removed.x / 8.0), 1, 5))
	if protected_contact or damaging_hit:
		# A damaging centre hit wins if that same impact also reveals nearby cells.
		audio.play_family(&"direct_bone_hit" if damaging_hit else &"bone_revealed",
			1.0 if damaging_hit else 0.42, damaging_hit)
		bone_ring.position = point_world(point)
		bone_remaining = 0.55
	last_action_usec = Time.get_ticks_usec() - action_started

func _process(delta: float) -> void:
	if controller == null: return
	# Data views must show only the authoritative surface, unobstructed by FX.
	visible = block.debug_view == 0
	recoil_remaining = maxf(0.0, recoil_remaining - delta)
	sweep_remaining = maxf(0.0, sweep_remaining - delta)
	bone_remaining = maxf(0.0, bone_remaining - delta)
	bone_ring.visible = bone_remaining > 0
	bone_ring.scale = Vector3.ONE * (1.0 + (0.55 - bone_remaining) * 0.7)
	var proxy_started := Time.get_ticks_usec()
	for i in range(proxies.size()):
		var proxy := proxies[i]
		proxy.visible = proxies_enabled and controller.hit.inside and i == controller.selected_index
		if not proxy.visible: continue
		proxy.global_position = controller.hit.world
		# Camera orientation is fixed: the handle always goes to the same screen
		# side. Neither micronormals, depth nor recoil rotate this frame.
		proxy.global_basis = ToolProxyPose.fixed_basis(i)
		var recoil := sin(recoil_remaining / 0.14 * PI) * (profile.recoil if i == 1 else 0.002 if i == 3 else 0.0)
		proxy_poses[i].fit(proxy, block, recoil)
	last_proxy_usec = Time.get_ticks_usec() - proxy_started
	var particles_started := Time.get_ticks_usec()
	for family in range(4):
		var active: Array = particles[family]
		for i in range(active.size() - 1, -1, -1):
			var particle: Dictionary = active[i]
			particle.life -= delta
			if particle.life <= 0:
				active.remove_at(i)
				continue
			if particle.get("dust", false):
				particle.velocity *= exp(-delta * 0.55)
			else:
				particle.velocity.y -= delta * (0.18 if family in [0, 3] else 0.65)
			particle.position += particle.velocity * delta
			# One inexpensive visual bounce against the original impact height.
			if particle.position.y < particle.floor:
				particle.position.y = particle.floor
				particle.velocity *= Vector3(0.65, -0.28, 0.65)
		for i in range(active.size()):
			var particle: Dictionary = active[i]
			var fade := minf(1.0, particle.life / 0.15)
			var dust: bool = particle.get("dust", false)
			var expansion: float = 1.0 + (1.0 - particle.life / particle.duration) * 1.6 if dust else fade
			var basis := Basis(Vector3(0.3, 1, 0.2).normalized(), particle.rotation + particle.life * 4).scaled(particle.shape * expansion)
			pools[family].set_instance_transform(i, Transform3D(basis, particle.position))
			var color: Color = particle.get("color", colors[family])
			if dust: color.a = fade * clampf(sqrt(particle.amount) * 1.5, 0.08, 0.8)
			pools[family].set_instance_color(i, color)
		pools[family].visible_instance_count = maxi(active.size(), 1 if _warmup_frames > 0 else 0)
	_warmup_frames = maxi(0, _warmup_frames - 1)
	last_particles_usec = Time.get_ticks_usec() - particles_started

func contact_debug(hit: Dictionary) -> String:
	return "\nContact: %s | Mess: Brush / Blower" % ["BONE" if hit.bone_exposed else "ATTACHED MATERIAL"]

func reset() -> void:
	if loose_view != null: loose_view._process(0)
	for family in range(4):
		particles[family].clear()
		pools[family].visible_instance_count = 0
	for proxy in proxies: proxy.hide()
	audio.reset()
	rng.seed = profile.seed
	airflow = Vector3(-0.07, 0.02, -0.06)
	recoil_remaining = 0
	sweep_remaining = 0
	bone_remaining = 0
	bone_ring.hide()
	_warmup_frames = 0
	action_count = 0
	emitted.fill(0)
