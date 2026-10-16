extends "res://scripts/preparation/readability/cleaning_feedback.gd"
## More readable bounded puffs, only after actual Film removal.
func on_action(event: Dictionary) -> void:
	var previous := particles[3].size()
	var previous_puffs := film_puffs
	super.on_action(event)
	if film_puffs == previous_puffs: return
	var point: Vector2 = event.bone_film_point
	_dust(point,Color(.76,.57,.33),2,.005)
	for i in range(previous,particles[3].size()):
		var particle: Dictionary = particles[3][i]
		particle.color = Color(.76,.57,.33)
		particle.shape = Vector3.ONE * rng.randf_range(.0045,.007)
		particle.amount = .58
		particle.duration = .38
		particle.life = .38
		particle.velocity = Vector3(rng.randf_range(-.012,.012),.020,rng.randf_range(-.012,.012))
	# Existing brush texture follows actual work; no new sound assets/pass.
	audio.update_brush(event.movement,event.bone_film_cleared,true)
