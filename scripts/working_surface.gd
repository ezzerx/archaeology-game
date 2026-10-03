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
signal material_action(event: Dictionary)
signal surface_reset
var fracture: MaterialFracture
var loose_debris: LooseDebris
var last_removed := Vector3.ZERO
var last_action: Dictionary = {}
var last_residue_edit_usec := 0
var changed_residue_cells := 0
var _heights := PackedFloat32Array()

func _init(resolution := Vector2i(1024, 640), stratigraphy: Stratigraphy = null,
		fossil_field: FossilField = null, reactions: ReactionProfile = null) -> void:
	assert(resolution.x > 0 and resolution.y > 0)
	size = resolution
	strata = stratigraphy
	image = Image.create(size.x, size.y, false, Image.FORMAT_RF)
	residue = SurfaceResidue.new(size)
	if reactions != null:
		assert(strata != null)
		fracture = MaterialFracture.new(size, reactions)
		loose_debris = LooseDebris.new(size)
	if fossil_field != null:
		assert(fossil_field.size == size)
		fossil = FossilState.new(fossil_field)
	reset()

func reset() -> void:
	_heights.resize(size.x * size.y)
	_heights.fill(1.0)
	image.fill(Color(1.0, 0.0, 0.0, 1.0))
	residue.reset()
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
		residue_generation := 0.0) -> int:
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
	var bone_ceilings := fossil.field.ceilings if has_fossil else PackedFloat32Array()
	# Above this immutable bound no cell can contact bone: skip its packed reads.
	var bone_limit := fossil.field.highest_ceiling + 2.0 * FossilField.EXPOSURE_EPSILON if has_fossil else -1.0
	var newly_exposed := PackedInt32Array()
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
				var fine_dust := (old_value - next_value) * residue_generation
				if loose_debris != null:
					fine_dust += loose_debris.deposit_removed(x, y, old_value - _heights[index], layer)
				if fine_dust > 0.0:
					residue.deposit_removed(x, y, fine_dust)
				changed += 1
	if changed > 0:
		# Image is the synchronized RF staging buffer, also used by CPU picking.
		image.set_data(size.x, size.y, false, Image.FORMAT_RF, _heights.to_byte_array())
	dirty = dirty or changed > 0
	if not newly_exposed.is_empty():
		fossil.expose_cells(newly_exposed)
	return changed

func apply_continuous(from: Vector2, to: Vector2, tool: ToolDefinition, delta: float) -> int:
	return _apply_tool(from, to, tool, delta)

func apply_impact(point: Vector2, tool: ToolDefinition) -> int:
	# Impacts deliberately have no previous point and cannot form a capsule.
	# Snapshot the centre BEFORE removal: the impact revealing it is always safe.
	# Calls outside the map never clamp into a valid edge-cell damage decision.
	if point.x < -0.5 or point.y < -0.5 or point.x >= size.x - 0.5 or point.y >= size.y - 0.5:
		last_action = {}
		return 0
	if fossil != null and tool.interaction_mode == ToolDefinition.InteractionMode.IMPACT and tool.power > 0.0:
		fossil.damage_at(fossil.field.index_at_map(point), tool.bone_damage)
	return _apply_tool(point, point, tool, 1.0)

func _apply_tool(from: Vector2, to: Vector2, tool: ToolDefinition, amount: float) -> int:
	last_residue_edit_usec = 0
	changed_residue_cells = 0
	last_removed = Vector3.ZERO
	last_action = {}
	if amount <= 0.0:
		return 0
	residue.last_cleared = 0.0
	if loose_debris != null: loose_debris.clean(from, to, tool, amount)
	var changed := 0
	var exposed_before := fossil.exposed_cells if fossil != null else 0
	var direct_bone_hit := fossil != null and tool.interaction_mode == ToolDefinition.InteractionMode.IMPACT \
		and tool.power > 0.0 and tool.bone_damage > 0.0 and fossil.exposed[fossil.field.index_at_map(to)] != 0
	var is_fracture := fracture != null and tool.interaction_mode == ToolDefinition.InteractionMode.IMPACT
	if is_fracture:
		changed = fracture.apply(self, to, tool)
	elif tool.effectiveness != Vector3.ZERO:
		changed = apply_segment(from, to, tool.radius, tool.power, tool.falloff,
			amount, tool.effectiveness, tool.residue_generation)
	if tool.residue_clear > 0.0 or (changed > 0 and (tool.residue_generation > 0.0 or loose_debris != null)):
		var start := Time.get_ticks_usec()
		changed_residue_cells = residue.apply_segment(from, to, tool.radius, tool.falloff, tool.residue_clear * amount)
		last_residue_edit_usec = Time.get_ticks_usec() - start
	var marks := fracture.last_marks if is_fracture else 0
	var bone_revealed := fossil != null and fossil.exposed_cells > exposed_before
	var loose_cleared := loose_debris.last_cleared if loose_debris != null else 0.0
	if changed > 0 or marks > 0 or changed_residue_cells > 0 or loose_cleared > 0 or bone_revealed or direct_bone_hit:
		last_action = {"tool": tool.id, "point": to, "removed": last_removed,
			"changed": changed, "marks": marks, "chunks": fracture.last_chunks.duplicate(true) if is_fracture else [],
			"residue_cleared": residue.last_cleared, "loose_cleared": loose_cleared,
			"direction": loose_debris.jet if loose_debris != null else Vector2(-1, -1).normalized(), "bone_revealed": bone_revealed,
			"direct_bone_hit": direct_bone_hit, "movement": from.distance_to(to) / maxf(amount, 0.0001)}
		material_action.emit(last_action)
	return changed
