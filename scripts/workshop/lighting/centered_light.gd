extends "res://scripts/specimens/skeleton/modeled_skeleton.gd"
## Fixed rear-centre lamp; no manipulation mode or preparation changes.
func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — B-17 · Lumière centrée"
	panel.get_child(0).get_child(0).text = "B-17 / LUMIÈRE FIXE CENTRÉE"
	lamp_art.position = Vector3(0.0,0.0,-.49)
	lamp_art.rotation.y = -PI*.5
	# Preserve the existing shade-to-source offset after turning the fixture.
	task_light.position = Vector3(0.0,.80,-.265)
	task_light.look_at(Vector3(0.0,.04,0.0),Vector3.UP)
	bench_bounce.position.x = 0.0

func set_hero_look(enabled: bool) -> void:
	super.set_hero_look(enabled)
	if ready_for_look and enabled and task_light_enabled:
		# Weak fill shares the central axis instead of retaining a left bias.
		$TableEnvironment/Light.rotation_degrees = Vector3(-52,180,0)
