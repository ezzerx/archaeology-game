class_name WorkingSurface
extends RefCounted
## Normalized surface height: 1 = intact top; 0 = non-excavatable floor.
## Optional strata: omitted by the P0 kernel tests to isolate footprint behaviour.

var image: Image
var size: Vector2i
var dirty := true
var strata: Stratigraphy
var residue: SurfaceResidue
var fossil: FossilState
var bone_film: BoneSurfaceFilm
var fragments: FragmentState
var structural_ceilings := PackedFloat32Array()
var highest_structural_ceiling := -1.0
var bone_display_image: Image
signal tool_applied
signal material_action(event: Dictionary)
## Feedback-only jet, including clean terrain. It never changes the action/state.
signal air_jet_applied(from: Vector2, to: Vector2, radius: float, falloff: float, delta: float, direction: Vector2)
signal surface_reset
var fracture: MaterialFracture
var loose_debris: LooseDebris
var excavatable_depth := 0.102 # Metres; set from the actual production block.
var last_micro_probes := 0
var last_micro_cells := 0
var last_removed := Vector3.ZERO
var last_action: Dictionary = {}
var last_residue_edit_usec := 0
var last_edit_usec := 0 # Surface work, excluding synchronous feedback consumers.
var changed_residue_cells := 0
var _heights := PackedFloat32Array()

func _init(resolution := Vector2i(1024, 640), stratigraphy: Stratigraphy = null,
		fossil_field: FossilField = null, reactions: ReactionProfile = null) -> void:
	assert(resolution.x > 0 and resolution.y > 0)
	size = resolution
	strata = stratigraphy
	image = Image.create(size.x, size.y, false, Image.FORMAT_RF)
	residue = SurfaceResidue.new(size)
	bone_film = BoneSurfaceFilm.new(size)
	if reactions != null:
		assert(strata != null)
		fracture = MaterialFracture.new(size, reactions)
		loose_debris = LooseDebris.new(size)
	if fossil_field != null:
		assert(fossil_field.size == size)
		fossil = FossilState.new(fossil_field)
		fossil.bone_cell_exposed.connect(bone_film.expose)
		structural_ceilings = fossil_field.ceilings
		highest_structural_ceiling = fossil_field.highest_ceiling
		bone_display_image = fossil_field.image
	reset()

func enable_fragments(field: RecoverableFragmentField) -> void:
	assert(fossil != null and field.size == size)
	fragments = FragmentState.new(field)
	fragments.cell_exposed.connect(bone_film.expose)
	fragments.fragment_recovered.connect(_release_fragment_ceiling)
	bone_display_image = fossil.field.image.duplicate()
	structural_ceilings = fossil.field.ceilings.duplicate()
	for id in range(field.COUNT):
		for index in field.cells[id]:
			assert(fossil.field.component_ids[index] == 0)
			structural_ceilings[index] = field.ceilings[index]
			highest_structural_ceiling = maxf(highest_structural_ceiling, field.ceilings[index])
			@warning_ignore("integer_division")
			bone_display_image.set_pixel(index % size.x, index / size.x, Color(field.ceilings[index], 5 + id, 0, 1))

func _release_fragment_ceiling(id: int, _count: int) -> void:
	# Recovering removes the independent object, not any terrain. Its substrate
	# retains the exact RF heights and can be worked normally afterwards.
	for index in fragments.field.cells[id]: structural_ceilings[index] = 0.0

func update_fragments(region: Rect2i) -> void:
	if fragments != null: fragments.update_region(_heights, region)

func reset() -> void:
	_heights.resize(size.x * size.y)
	_heights.fill(1.0)
	image.fill(Color(1.0, 0.0, 0.0, 1.0))
	residue.reset()
	bone_film.reset()
	if fragments != null:
		for id in range(fragments.field.COUNT):
			for index in fragments.field.cells[id]: structural_ceilings[index] = fragments.field.ceilings[index]
		fragments.reset()
	if fracture != null:
		fracture.reset()
	if loose_debris != null: loose_debris.reset()
	last_removed = Vector3.ZERO
	last_action = {}
	if fossil != null:
		fossil.reset()
	last_residue_edit_usec = 0
	changed_residue_cells = 0
	dirty = true
	surface_reset.emit()

func value_at(cell: Vector2i) -> float:
	return image.get_pixelv(cell.clamp(Vector2i.ZERO, size - Vector2i.ONE)).r

static func weight(distance_ratio: float, falloff: float) -> float:
	var t := clampf(distance_ratio, 0.0, 1.0)
	var smooth_weight := 1.0 - t * t * (3.0 - 2.0 * t)
	return pow(smooth_weight, maxf(falloff, 0.01))

func apply_segment(from: Vector2, to: Vector2, radius: float, strength: float,
		falloff: float, delta: float, effectiveness := Vector3.ONE,
		residue_generation := 0.0, stop_at_initial_layer := false, brush_cleanup := false) -> int:
	if radius <= 0.0 or strength <= 0.0 or delta <= 0.0:
		return 0
	# Sweep a capsule: the entire segment is covered, including fast movements.
	# Each texel is modified at most once per tick, independent of sample overlap.
	var low := Vector2i((from.min(to) - Vector2.ONE * radius).floor()).max(Vector2i.ZERO)
	var high := Vector2i((from.max(to) + Vector2.ONE * radius).ceil()).min(size - Vector2i.ONE)
	var segment := to - from
	var length_squared := segment.length_squared()
	var radius_squared := radius * radius
	var strip_half_width := radius * sqrt(length_squared) / absf(segment.y) if absf(segment.y) > 0.0001 else 0.0
	var inverse_length := 1.0 / length_squared if length_squared > 0.0 else 0.0
	var inverse_radius := 1.0 / radius
	var base_work := strength * delta
	var exponent := maxf(falloff, 0.01)
	var resistance := Vector3.ONE
	var limits := PackedFloat32Array()
	if strata != null:
		resistance = Vector3(strata.materials[0].resistance, strata.materials[1].resistance, strata.materials[2].resistance)
		limits = strata.packed_limits
	# Cost in tool work per depth. Zero effectiveness is an impassable layer.
	resistance /= effectiveness.max(Vector3.ONE * 0.00000001)
	var changed := 0
	var has_fossil := fossil != null
	var bone_ceilings := structural_ceilings
	# Above this immutable bound no cell can contact bone: skip its packed reads.
	var bone_limit := highest_structural_ceiling + 2.0 * FossilField.EXPOSURE_EPSILON if has_fossil else -1.0
	var newly_exposed := PackedInt32Array()
	var micro_seen := {}
	if loose_debris != null: loose_debris.begin_deposition()
	for y in range(low.y, high.y + 1):
		var row_low := low.x
		var row_high := high.x
		if strip_half_width > 0.0:
			# Intersect the bounding box with the infinite capsule strip per row.
			# This avoids scanning most of the map during long diagonal sweeps.
			var line_x := from.x + (y - from.y) * segment.x / segment.y
			row_low = maxi(row_low, ceili(line_x - strip_half_width))
			row_high = mini(row_high, floori(line_x + strip_half_width))
		for x in range(row_low, row_high + 1):
			var index := y * size.x + x
			var old_value := _heights[index]
			if old_value <= 0.0:
				continue
			var dx := x - from.x
			var dy := y - from.y
			var t := clampf((dx * segment.x + dy * segment.y) * inverse_length, 0.0, 1.0)
			dx -= segment.x * t
			dy -= segment.y * t
			var distance_squared := dx * dx + dy * dy
			if distance_squared >= radius_squared:
				continue
			var ratio := sqrt(distance_squared) * inverse_radius
			var work := base_work * pow(maxf(0.0, 1.0 - ratio * ratio * (3.0 - 2.0 * ratio)), exponent)
			var next_value := old_value
			if strata == null:
				next_value = maxf(0.0, old_value - work * effectiveness.x)
			else:
				# Inline the same piecewise work integration as Stratigraphy.remove_work.
				# Packed reads avoid per-texel Image calls and Resource dispatch.
				var upper := limits[index * 2]
				var lower := limits[index * 2 + 1]
				if brush_cleanup and loose_debris != null and old_value <= upper:
					var layer := 1 if old_value > lower else 2
					var remaining := old_value - MicroRemnant.bottom(self, index, layer)
					if remaining > Stratigraphy.SURFACE_EPSILON and remaining <= loose_debris.profile.micro_depth_m / excavatable_depth + Stratigraphy.SURFACE_EPSILON \
							and work >= base_work * loose_debris.profile.micro_min_weight and not micro_seen.has(index) \
							and last_micro_probes < loose_debris.profile.micro_probe_budget:
						last_micro_probes += 1
						var island := MicroRemnant.inspect(self, Vector2i(x, y), layer, micro_seen)
						var volume := 0.0
						var center := Vector2.ZERO
						for member in island:
							volume += _heights[member] - MicroRemnant.bottom(self, member, layer)
							center += Vector2(member % size.x, member / size.x as int)
						if not island.is_empty() and loose_debris.detach_at(center / island.size(), volume, layer):
							for member in island:
								_heights[member] = MicroRemnant.bottom(self, member, layer)
								if has_fossil and bone_ceilings[member] > 0 and _heights[member] <= bone_ceilings[member] + FossilField.EXPOSURE_EPSILON and fossil.exposed[member] == 0:
									newly_exposed.append(member)
							last_removed[layer] += volume
							last_micro_cells += island.size()
							changed += island.size()
					continue # All non-eligible attached hard material is untouched.

				if next_value > upper and effectiveness.x > 0.0:
					var removed := minf(next_value - upper, work / resistance.x)
					next_value -= removed
					work -= removed * resistance.x
				if work > 0.0 and next_value <= upper and next_value > lower and effectiveness.y > 0.0:
					var removed := minf(next_value - lower, work / resistance.y)
					next_value -= removed
					work -= removed * resistance.y
				if next_value <= lower and effectiveness.z > 0.0:
					next_value = maxf(0.0, next_value - maxf(work, 0.0) / resistance.z)
				if stop_at_initial_layer:
					var initial_floor := upper if old_value > upper else (lower if old_value > lower else 0.0)
					next_value = maxf(next_value, initial_floor)
			if next_value < old_value:
				if next_value <= bone_limit and bone_ceilings[index] > 0.0:
					# Discard remaining work at bone. Ineffective strokes do not
					# inspect fossil state, and clamped cells produce no dirty upload.
					next_value = maxf(next_value, bone_ceilings[index])
					if next_value >= old_value:
						continue
					# Decide from the stored float32, not the pre-rounding calculation.
					_heights[index] = next_value
					if _heights[index] <= bone_ceilings[index] + FossilField.EXPOSURE_EPSILON and fossil.exposed[index] == 0:
						newly_exposed.append(index)
				_heights[index] = next_value
				var layer := Stratigraphy.index_at(old_value, Vector2(limits[index * 2], limits[index * 2 + 1])) if strata != null else 0
				last_removed[layer] += old_value - _heights[index]
				var fine_dust := (old_value - next_value) * residue_generation if layer > 0 else 0.0
				if loose_debris != null and layer > 0:
					fine_dust += loose_debris.deposit_removed(x, y, old_value - _heights[index], layer)
				if fine_dust > 0.0:
					residue.deposit_removed(x, y, fine_dust)
				changed += 1
	if loose_debris != null: loose_debris.end_deposition()
	if changed > 0:
		# Image is the synchronized RF staging buffer, also used by CPU picking.
		image.set_data(size.x, size.y, false, Image.FORMAT_RF, _heights.to_byte_array())
	dirty = dirty or changed > 0
	if not newly_exposed.is_empty():
		fossil.expose_cells(newly_exposed)
	if changed > 0: update_fragments(Rect2i(low - Vector2i.ONE * 2, high - low + Vector2i.ONE * 5))
	return changed

func apply_continuous(from: Vector2, to: Vector2, tool: ToolDefinition, delta: float) -> int:
	return _apply_tool(from, to, tool, delta)

func apply_impact(point: Vector2, tool: ToolDefinition) -> int:
	# Impacts deliberately have no previous point and cannot form a capsule.
	# Calls outside the map never clamp into a valid edge-cell damage decision.
	if point.x < -0.5 or point.y < -0.5 or point.x >= size.x - 0.5 or point.y >= size.y - 0.5:
		last_action = {}
		return 0
	# Only Bone visible BEFORE this impact is a direct-contact candidate.
	# Snapshot before fracture, exposure signals, cleanup or any other mutation.
	var was_exposed_before_impact := fossil != null and fossil.exposed[fossil.field.index_at_map(point)] != 0
	return _apply_tool(point, point, tool, 1.0, was_exposed_before_impact)

func _apply_tool(from: Vector2, to: Vector2, tool: ToolDefinition, amount: float, was_exposed_before_impact := false) -> int:
	var edit_started := Time.get_ticks_usec()
	last_edit_usec = 0
	last_micro_probes = 0
	last_micro_cells = 0
	last_residue_edit_usec = 0
	changed_residue_cells = 0
	last_removed = Vector3.ZERO
	last_action = {}
	if amount <= 0.0 or tool.id == &"forceps" or tool.interaction_mode == ToolDefinition.InteractionMode.RECOVERY:
		return 0
	tool_applied.emit()
	residue.last_cleared = 0.0
	residue.cleared_packets = []
	bone_film.clean(from, to, tool, amount) # Before revelation: newly exposed film survives this stroke.
	if loose_debris != null: loose_debris.clean(from, to, tool, amount)
	var changed := 0
	var exposed_before := fossil.exposed_cells if fossil != null else 0
	var discovered_before := fossil.first_contact if fossil != null else false
	var can_damage := was_exposed_before_impact and fossil != null and tool.interaction_mode == ToolDefinition.InteractionMode.IMPACT \
		and tool.power > 0.0 and tool.bone_damage > 0.0
	var center_index := fossil.field.index_at_map(to) if can_damage else -1
	# Pick shares the impact clock, but removes only its tiny footprint directly.
	# No broad fracture cells, motion gate, or weak per-pass scraping limit.
	var is_pick := tool.id == &"precision_pick"
	var is_fracture := fracture != null and tool.interaction_mode == ToolDefinition.InteractionMode.IMPACT and not is_pick
	if is_fracture:
		changed = fracture.apply(self, to, tool)
	elif tool.effectiveness != Vector3.ZERO:
		changed = apply_segment(from, to, tool.radius, tool.power, tool.falloff,
			amount, tool.effectiveness,
			tool.residue_generation, is_pick, tool.id == &"soft_brush")
	if tool.residue_clear > 0.0 or (changed > 0 and (tool.residue_generation > 0.0 or loose_debris != null)):
		var start := Time.get_ticks_usec()
		changed_residue_cells = residue.apply_segment(from, to, tool.radius, tool.falloff, tool.residue_clear * amount, tool.id == &"air_blower")
		last_residue_edit_usec = Time.get_ticks_usec() - start
	var marks := fracture.last_marks if is_fracture else 0
	var bone_revealed := fossil != null and fossil.exposed_cells > exposed_before
	# Exposure remains per-cell; the discovery cue belongs to the specimen once.
	var bone_first_contact := fossil != null and fossil.first_contact and not discovered_before
	# Never infer contact from post-impact exposure, even at the exact centre.
	var direct_bone_hit := can_damage
	var bone_protected_contact := false
	var bone_damage := 0.0
	if direct_bone_hit:
		var condition_before := fossil.condition
		bone_protected_contact = fossil.contact_at(center_index, tool.bone_damage, was_exposed_before_impact)
		bone_damage = condition_before - fossil.condition
	var loose_cleared := loose_debris.last_cleared if loose_debris != null else 0.0
	if changed > 0 or marks > 0 or changed_residue_cells > 0 or residue.last_cleared > 0 or loose_cleared > 0 or bone_film.last_cleared > 0 or bone_revealed or direct_bone_hit:
		last_action = {"tool": tool.id, "point": to, "removed": last_removed,
			"changed": changed, "marks": marks, "chunks": fracture.last_chunks.duplicate(true) if is_fracture else [],
			"micro_detached": last_micro_cells, "bone_film_cleared": bone_film.last_cleared, "residue_cleared": residue.last_cleared, "loose_cleared": loose_cleared,
			"cleared_dust": residue.cleared_packets.duplicate(true),
			"direction": loose_debris.jet if loose_debris != null else Vector2(-1, -1).normalized(), "bone_revealed": bone_revealed,
			"bone_first_contact": bone_first_contact,
			"bone_protected_contact": bone_protected_contact,
			"bone_damage": bone_damage,
			"direct_bone_hit": direct_bone_hit, "movement": from.distance_to(to) / maxf(amount, 0.0001)}
		last_edit_usec = Time.get_ticks_usec() - edit_started
		material_action.emit(last_action)
	else:
		last_edit_usec = Time.get_ticks_usec() - edit_started
	if tool.id == &"air_blower":
		air_jet_applied.emit(from, to, tool.radius, tool.falloff, amount,
			loose_debris.jet if loose_debris != null else Vector2(-1, -1).normalized())
	return changed
