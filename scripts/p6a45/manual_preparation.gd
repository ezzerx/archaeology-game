extends "res://scripts/p6a44/natural_preparation.gd"
func _create_feedback() -> MaterialFeedback:
 if sensory_enabled and readability_enabled:
  return preload("res://scripts/p6a45/lever_feedback.gd").new()
 return super._create_feedback()
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/p6a45/rough_profile.gd").new(block.working_map,block.footprint,block.rim)
func _create_slab() -> Node:
 return preload("res://scripts/p6a45/manual_slab.gd").new()
func _ready() -> void:
 super._ready()
 controller.slab = slab
 slab.ready_to_lift.connect(_lift_notice)
 var done := {}
 for shader in [mesh_surface_shader,baseline_surface_shader,readability_shader,original_hero_shader,witness_shader,soil_shader,hero_shader]:
  if shader == null or done.has(shader): continue
  done[shader] = true
  shader.code = _hook(shader.code,"void vertex() {", """
uniform sampler2D lever_plate : filter_nearest, repeat_disable;
uniform float lever_amount = 0.0;
uniform bool lever_ready = false;
void vertex() {
""")
  shader.code = _hook(shader.code,"VERTEX.y = base_height + surface_height * excavatable_height;", """
VERTEX.y = base_height + surface_height * excavatable_height;
// Positive-only movement of existing matrix: never removes cover or moves Bone.
vec2 plate = textureLod(lever_plate,UV,0.0).rg;
if (!is_skirt && plate.r>.5 && height>plate.g+.003) {
 float edge = clamp((UV.y*map_size.y-175.0)/90.0,0.0,1.0);
 float play = lever_ready ? .13+.09*sin(TIME*4.0) : 0.0;
 VERTEX.y += edge*(lever_amount*.004+play*.003);
}
""")
 slab.bind_preview()
 _label_trial()
 for label: Label in find_children("*","Label",true,false):
  if label.text.begins_with("B-17 · Grès dans"):
   label.text = "B-17 · Plaque à soulever
Ouvrez les joints au Pick, puis maintenez et tirez vers vous. · R : recommencer"
 _uniform_light()
func _label_trial() -> void:
 get_window().title = "ArchaeologyGame — B-17 · Levier au Pick"
 panel.get_child(0).get_child(0).text = "B-17 / LEVIER MANUEL"
func _uniform_light() -> void:
 if not ready_for_look: return
 task_light.light_energy = .28
 task_light.spot_angle = 70
 task_light.spot_angle_attenuation = .15
 task_light.spot_attenuation = .5
 bench_bounce.light_energy = .10
 if hero_enabled and task_light_enabled:
  $TableEnvironment/Light.light_energy = .65
func set_hero_look(enabled: bool) -> void:
 super.set_hero_look(enabled)
 _uniform_light()
 if is_instance_valid(slab): slab.bind_preview()
func _lift_notice() -> void:
 session.notice.emit("La plaque prend du jeu — maintenez le Pick sur un joint ouvert et tirez vers vous")
