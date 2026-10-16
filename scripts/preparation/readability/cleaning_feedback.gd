extends "res://scripts/tools/feedback/sensory_feedback.gd"
## Dust follows the committed native Film-removal event, even at the Brush edge.
var film_dust_interval := 0.0
var film_puffs := 0
var last_film_point := Vector2(-1, -1)

func on_action(event: Dictionary) -> void:
	super.on_action(event)
	if event.tool != &"soft_brush" or event.get("bone_film_cleared", 0.0) <= 0.0: return
	if film_dust_interval > 0.0 or not particles_enabled: return
	var point: Vector2 = event.get("bone_film_point", Vector2(-1, -1))
	if point.x < 0.0: return
	var previous := particles[3].size()
	_dust(point, Color(.64, .48, .30), 2, .003)
	# Fine local release rather than the broad dry-Clay contact puff.
	var origin := point_world(point)
	for i in range(previous, particles[3].size()):
		particles[3][i].position = origin + Vector3(rng.randf_range(-.001, .001), .001, rng.randf_range(-.001, .001))
		particles[3][i].amount = .15
		particles[3][i].duration = .32
		particles[3][i].life = .32
	if particles[3].size() > previous:
		film_puffs += 1
		last_film_point = point
		film_dust_interval = .065

func _physics_process(delta: float) -> void:
	film_dust_interval = maxf(0.0, film_dust_interval - delta)
	super._physics_process(delta)

func _pointer_film_dust(_point: Vector2) -> void:
	# Native removal is observed in on_action, independently of pointer movement.
	pass

func reset() -> void:
	super.reset()
	film_dust_interval = 0.0
	film_puffs = 0
	last_film_point = Vector2(-1, -1)
