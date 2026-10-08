extends "res://scripts/p6a/hero_patch.gd"
## P6A2 geometry/materials/task light/session are inherited unchanged.
var sensory_enabled := true
var sensory_button: Button
var lamp_art: Node3D
var old_lamp: MeshInstance3D

func _create_feedback() -> MaterialFeedback:
	return preload("res://scripts/p6a3/sensory_feedback.gd").new() if sensory_enabled else MaterialFeedback.new()

func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A3 Tool Feel"
	panel.get_child(0).get_child(0).text = "P6A3 / TOOL FEEL · F12 comparison"
	sensory_button=_button("F12 · Outils/feedback P6A2",panel.get_child(0),toggle_sensory)
	old_lamp = desk_art.find_child("task_lamp",true,false)
	lamp_art = preload("res://assets/p6a3/models/lamp.glb").instantiate()
	lamp_art.name = "TripoPreparationLamp"
	add_child(lamp_art)
	# Static art placement only. The accepted SpotLight transform/settings stay exact.
	lamp_art.position = Vector3(-.675, .0, -.30)
	for mesh: MeshInstance3D in lamp_art.find_children("*","MeshInstance3D",true,false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	old_lamp.hide()

func set_hero_look(enabled: bool) -> void:
	super.set_hero_look(enabled)
	if lamp_art != null:
		lamp_art.visible = enabled and sensory_enabled
		old_lamp.visible = enabled and not sensory_enabled

func _export_smoke() -> void:
	var art_ok := lamp_art != null and feedback.proxies.size() == 4
	for proxy:Node3D in feedback.proxies:
		art_ok = art_ok and proxy.find_children("*","MeshInstance3D",true,false).size()==1
	print("P6A3 PACKED ART ","PASS" if art_ok else "FAIL")
	if not art_ok:
		get_tree().quit(1)
		return
	await super._export_smoke()

func toggle_sensory() -> void:
	controller.cancel_stroke()
	var tint:=feedback.colors.duplicate()
	var crumb_tint:=feedback.loose_view.colors.duplicate()
	feedback.free() # Disconnects only presentation consumers; native state survives.
	sensory_enabled=not sensory_enabled
	if lamp_art != null:
		lamp_art.visible = hero_enabled and sensory_enabled
		old_lamp.visible = hero_enabled and not sensory_enabled
	feedback=_create_feedback()
	feedback.name="MaterialFeedback"
	add_child(feedback)
	feedback.setup(block,controller)
	feedback.colors=tint
	feedback.loose_view.colors=crumb_tint
	sensory_button.text="F12 · Outils/feedback P6A2" if sensory_enabled else "F12 · Outils/feedback P6A3"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F12:
		toggle_sensory()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)
