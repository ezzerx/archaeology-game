class_name TerrainDebris
extends RefCounted
## Read-only relief consumer. Fixed slots, no per-impact Nodes/meshes/colliders.
signal debris_ejected(position_local: Vector3, direction_local: Vector3, layer: int)
enum State { AIRBORNE, CONTACT, SLEEPING }
const ROTATION_AXIS := Vector3(0.3, 1, 0.2) / 1.063014581273465
const SUBSTEPS := 2

class Fragment extends RefCounted:
	var active := false
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

	func support_height() -> float:
		# Bottom of the rendered oriented box, not half its unrotated thickness.
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
var recycled_count := 0
var ejected_count := 0

func _init(terrain: ReliefSurface, settings: DebrisPhysicsProfile = preload("res://config/debris_physics_profile.tres")) -> void:
	relief = terrain
	map_size = relief.image.get_size()
	profile = settings
	for i in range(clampi(profile.fragment_cap, 1, 48)):
		fragments.append(Fragment.new())

func spawn(at: Vector3, velocity: Vector3, size: Vector3, layer: int, rotation: float) -> int:
	if layer not in [1, 2] or not _inside(at): return -1
	var slot := -1
	var oldest := -1.0
	for i in range(fragments.size()):
		var fragment := fragments[i]
		if not fragment.active:
			slot = i
			break
		# Never remove an airborne piece to make room. Reuse oldest resting FX.
		if fragment.state == State.SLEEPING and fragment.age > oldest:
			oldest = fragment.age
			slot = i
	if slot < 0:
		skipped_count += 1
		return -1
	var f := fragments[slot]
	if f.active:
		recycled_count += 1
		sleeping_count -= 1
	else: active_count += 1
	f.active = true
	f.position = at
	f.velocity = velocity
	f.size = size
	f.material = layer
	f.rotation = rotation
	f.angular_velocity = 4.0
	f.age = 0.0
	f.contacts = 0
	_wake(f)
	emitted_count += 1
	return slot

func _inside(at: Vector3) -> bool:
	return absf(at.x) <= relief.dimensions.x * 0.5 and absf(at.z) <= relief.dimensions.y * 0.5

func _height(at: Vector3) -> float:
	last_samples += 1
	return relief.height_at(SurfaceMapping.local_to_uv(at, relief.dimensions))

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
	f.active = false
	active_count -= 1

func advance(delta: float) -> void:
	var started := Time.get_ticks_usec()
	last_samples = 0
	sleeping_count = 0
	for f in fragments:
		if not f.active: continue
		f.age += delta
		if f.state == State.SLEEPING:
			# Excavation under a settled chunk must remove its support immediately.
			var floor_y := _height(f.position) + f.support_height() + profile.contact_skin
			if absf(f.position.y - floor_y) > profile.contact_skin * 2.0:
				_wake(f)
			else:
				f.sleeping_time += delta
				if f.sleeping_time >= profile.sleep_hold + profile.fade_duration:
					_release(f)
				else: sleeping_count += 1
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
		debris_ejected.emit(f.position, f.velocity.normalized(), f.material)
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
	var lateral := Vector2(f.velocity.x, f.velocity.z) * exp(-profile.friction[f.material - 1] * delta)
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
	if f.state == State.CONTACT and lateral.length() < profile.sleep_speed and absf(f.angular_velocity) < profile.sleep_angular_speed:
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
		if f.state == State.SLEEPING: sleeping_count -= 1
		_wake(f)
		var lateral := Vector3(f.velocity.x, 0, f.velocity.z) + jet * profile.blower_fragment_impulse * weight * delta
		lateral = lateral.limit_length(profile.blower_speed_limit)
		f.velocity.x = lateral.x
		f.velocity.z = lateral.z
		f.velocity.y = minf(profile.blower_lift_limit, f.velocity.y + profile.blower_fragment_lift * weight * delta)
		f.angular_velocity = maxf(f.angular_velocity, weight * 4.0)
		affected += 1
	last_blower_usec = Time.get_ticks_usec() - started
	return affected

func visibility_scale(f: Fragment) -> float:
	if f.state != State.SLEEPING: return 1.0
	return 1.0 - clampf((f.sleeping_time - profile.sleep_hold) / profile.fade_duration, 0.0, 1.0)

func reset() -> void:
	for f in fragments: f.active = false
	active_count = 0
	sleeping_count = 0
	last_samples = 0
	last_step_usec = 0
	last_blower_usec = 0
	emitted_count = 0
	skipped_count = 0
	recycled_count = 0
	ejected_count = 0
