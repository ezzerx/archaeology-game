class_name TerrainDebris
extends RefCounted
## Motion kernel for persistent LooseDebris crumbs, not transient Chisel chunks.
## Read-only relief, fixed slots. Ownership/amount/spawn budgets live in LooseDebris.
signal debris_ejected(source: Vector3i, position_local: Vector3, direction_local: Vector3)
enum State { AIRBORNE, CONTACT, SLEEPING }
const ROTATION_AXIS := Vector3(0.3, 1, 0.2) / 1.063014581273465
const SUBSTEPS := 2

class Fragment extends RefCounted:
	var active := false
	var source := Vector3i.ZERO
	var position := Vector3.ZERO
	var velocity := Vector3.ZERO
	var rotation := 0.0
	var angular_velocity := 4.0
	var size := Vector3.ONE
	var material := 1
	var age := 0.0
	var state := State.AIRBORNE
	var quiet_time := 0.0
	var contact_time := 0.0
	var sleeping_time := 0.0
	var contacts := 0
	var blown_recently := 0.0

	func support_height() -> float:
		# Conservative oriented envelope of the flake, not its unrotated thickness.
		var basis := Basis(ROTATION_AXIS, rotation)
		return (absf(basis.x.y) * size.x + absf(basis.y.y) * size.y + absf(basis.z.y) * size.z) * 0.5

var relief: ReliefSurface
var map_size: Vector2i
var profile: DebrisPhysicsProfile
var fragments: Array[Fragment] = []
var active_count := 0
var sleeping_count := 0
var last_samples := 0
var last_step_usec := 0
var last_blower_usec := 0
var emitted_count := 0
var skipped_count := 0
var ejected_count := 0
var _vertex_heights: Dictionary = {} # Tick-local, invalidated before any support query.

func _init(terrain: ReliefSurface, settings: DebrisPhysicsProfile = preload("res://config/debris_physics_profile.tres"), capacity := 128) -> void:
	relief = terrain
	map_size = relief.image.get_size()
	profile = settings
	for i in range(clampi(capacity, 1, 512)):
		fragments.append(Fragment.new())

func spawn(at: Vector3, velocity: Vector3, size: Vector3, layer: int, rotation: float, source := Vector3i.ZERO) -> int:
	if layer not in [1, 2] or not _inside(at): return -1
	var slot := -1
	for i in range(fragments.size()):
		var fragment := fragments[i]
		if not fragment.active:
			slot = i
			break
	if slot < 0:
		skipped_count += 1
		return -1
	var f := fragments[slot]
	active_count += 1
	f.active = true
	f.source = source
	f.position = at
	f.velocity = velocity
	f.size = size
	f.material = layer
	f.rotation = rotation
	f.angular_velocity = 4.0
	f.age = 0.0
	f.contacts = 0
	f.blown_recently = 0.0
	_wake(f)
	emitted_count += 1
	return slot

func _inside(at: Vector3) -> bool:
	return absf(at.x) <= relief.dimensions.x * 0.5 and absf(at.z) <= relief.dimensions.y * 0.5

func _height(at: Vector3) -> float:
	last_samples += 1
	# Same three vertices/triangle and float32 vertex Y as ReliefSurface.height_at.
	# Nearby contacts share vertex reads; no stale cache after excavation next tick.
	var uv := SurfaceMapping.local_to_uv(at, relief.dimensions).clamp(Vector2.ZERO, Vector2.ONE)
	var point := uv * Vector2(relief.cells)
	var cell := Vector2i(point.floor()).min(relief.cells - Vector2i.ONE)
	var fraction := point - Vector2(cell)
	var b := _vertex_height(cell + Vector2i.RIGHT)
	var c := _vertex_height(cell + Vector2i.DOWN)
	if fraction.x + fraction.y <= 1.0:
		var a := _vertex_height(cell)
		return a + (b - a) * fraction.x + (c - a) * fraction.y
	var d := _vertex_height(cell + Vector2i.ONE)
	return d + (c - d) * (1.0 - fraction.x) + (b - d) * (1.0 - fraction.y)

func _vertex_height(cell: Vector2i) -> float:
	if not _vertex_heights.has(cell): _vertex_heights[cell] = relief.vertex_at(cell).y
	return _vertex_heights[cell]

func _gradient(at: Vector3) -> Vector2:
	var distance := profile.slope_sample_distance
	var left := maxf(-relief.dimensions.x * 0.5, at.x - distance)
	var right := minf(relief.dimensions.x * 0.5, at.x + distance)
	var back := maxf(-relief.dimensions.y * 0.5, at.z - distance)
	var front := minf(relief.dimensions.y * 0.5, at.z + distance)
	return Vector2(
		(_height(Vector3(right, at.y, at.z)) - _height(Vector3(left, at.y, at.z))) / maxf(right - left, 0.000001),
		(_height(Vector3(at.x, at.y, front)) - _height(Vector3(at.x, at.y, back))) / maxf(front - back, 0.000001))

func _wake(f: Fragment) -> void:
	f.state = State.AIRBORNE
	f.quiet_time = 0.0
	f.contact_time = 0.0
	f.sleeping_time = 0.0

func _release(f: Fragment) -> void:
	if not f.active: return
	f.active = false
	active_count -= 1
	if f.state == State.SLEEPING: sleeping_count = maxi(0, sleeping_count - 1)

func remove(slot: int) -> void:
	_release(fragments[slot])

func advance(delta: float) -> void:
	var started := Time.get_ticks_usec()
	last_samples = 0
	_vertex_heights.clear()
	if active_count == 0:
		last_step_usec = Time.get_ticks_usec() - started
		return
	for f in fragments:
		if not f.active: continue
		f.age += delta
		f.blown_recently = maxf(0, f.blown_recently - delta)
		if f.state == State.SLEEPING:
			# Excavation under a settled crumb must remove its support immediately.
			var floor_y := _height(f.position) + f.support_height() + profile.contact_skin
			if absf(f.position.y - floor_y) > profile.contact_skin * 2.0:
				sleeping_count -= 1
				_wake(f)
			else:
				f.sleeping_time += delta
				# Persistent dirt: no expiry, fade or oldest-sleeper recycling.
				continue
		for step in range(SUBSTEPS):
			_step(f, delta / SUBSTEPS)
			if not f.active or f.state == State.SLEEPING: break
		if f.active and f.state == State.SLEEPING: sleeping_count += 1
	last_step_usec = Time.get_ticks_usec() - started

func _step(f: Fragment, delta: float) -> void:
	var previous := f.position
	f.velocity.y -= profile.gravity * delta
	f.position += f.velocity * delta
	f.rotation += f.angular_velocity * delta
	if not _inside(f.position):
		# Intersect the boundary once, then release before notifying observers.
		var movement := f.position - previous
		var fraction := 1.0
		for axis in [0, 2]:
			var bound := relief.dimensions.x * 0.5 if axis == 0 else relief.dimensions.y * 0.5
			if movement[axis] > 0: fraction = minf(fraction, (bound - previous[axis]) / movement[axis])
			elif movement[axis] < 0: fraction = minf(fraction, (-bound - previous[axis]) / movement[axis])
		f.position = previous + movement * fraction
		_release(f)
		ejected_count += 1
		debris_ejected.emit(f.source, f.position, f.velocity.normalized())
		return
	var floor_y := _height(f.position) + f.support_height() + profile.contact_skin
	# floor_y already includes the skin. An extra tolerance here would swallow
	# small positive 60 Hz Blower lifts and pin a resting piece to its floor.
	if f.position.y > floor_y:
		f.state = State.AIRBORNE
		f.quiet_time = 0.0
		return
	f.position.y = floor_y
	var impact_speed := maxf(0.0, -f.velocity.y)
	var bounce := impact_speed * profile.restitution[f.material - 1]
	if f.state == State.AIRBORNE: f.contacts += 1
	f.velocity.y = bounce if bounce >= profile.bounce_min_speed else 0.0
	f.state = State.AIRBORNE if f.velocity.y > 0 else State.CONTACT
	var lateral := Vector2(f.velocity.x, f.velocity.z) * exp(-(profile.blown_drag if f.blown_recently > 0 else profile.friction[f.material - 1]) * delta)
	f.angular_velocity *= exp(-profile.angular_damping * delta)
	f.contact_time += delta
	if f.state == State.CONTACT and f.contact_time < profile.slide_duration:
		var gradient := _gradient(f.position)
		if gradient.length() > profile.slide_threshold:
			# Project gravity downhill. Never add an uphill component or energy.
			var downhill := -gradient * profile.slide_acceleration / (1.0 + gradient.length_squared())
			var extra := downhill * delta
			if lateral.length() < profile.slide_speed_limit:
				lateral = (lateral + extra).limit_length(profile.slide_speed_limit)
	f.velocity.x = lateral.x
	f.velocity.z = lateral.y
	if f.blown_recently <= 0 and f.state == State.CONTACT and lateral.length() < profile.sleep_speed and absf(f.angular_velocity) < profile.sleep_angular_speed:
		f.quiet_time += delta
		if f.quiet_time >= profile.sleep_delay:
			f.state = State.SLEEPING
			f.velocity = Vector3.ZERO
			f.angular_velocity = 0.0
	else: f.quiet_time = 0.0

func blow(from: Vector2, to: Vector2, radius: float, falloff: float, delta: float, direction: Vector2) -> int:
	var started := Time.get_ticks_usec()
	var affected := 0
	if radius <= 0 or delta <= 0 or direction.is_zero_approx(): return 0
	var segment := to - from
	var inv_length := 1.0 / segment.length_squared() if not segment.is_zero_approx() else 0.0
	# Same map-space direction as LooseDebris, converted to this local block.
	var jet := Vector3(direction.x * relief.dimensions.x / map_size.x, 0,
		direction.y * relief.dimensions.y / map_size.y).normalized()
	for f in fragments:
		if not f.active: continue
		var point := SurfaceMapping.local_to_uv(f.position, relief.dimensions) * Vector2(map_size) - Vector2.ONE * 0.5
		var t := clampf((point - from).dot(segment) * inv_length, 0, 1)
		var weight := WorkingSurface.weight(point.distance_to(from + segment * t) / radius, falloff)
		if weight <= 0: continue
		var pop := f.state != State.AIRBORNE and f.blown_recently <= 0
		if f.state == State.SLEEPING:
			sleeping_count -= 1
			_wake(f)
		if pop:
			f.velocity.y = maxf(f.velocity.y, profile.crumb_blower_pop * weight)
			f.state = State.AIRBORNE
		f.blown_recently = profile.blown_duration
		var lateral := Vector3(f.velocity.x, 0, f.velocity.z) + jet * profile.crumb_blower_acceleration * weight * delta
		lateral = lateral.limit_length(profile.crumb_blower_speed_limit)
		f.velocity.x = lateral.x
		f.velocity.z = lateral.z
		f.angular_velocity = maxf(f.angular_velocity, weight * 4.0)
		affected += 1
	last_blower_usec = Time.get_ticks_usec() - started
	return affected

func reset() -> void:
	for f in fragments: f.active = false
	active_count = 0
	sleeping_count = 0
	last_samples = 0
	last_step_usec = 0
	last_blower_usec = 0
	emitted_count = 0
	skipped_count = 0
	ejected_count = 0
