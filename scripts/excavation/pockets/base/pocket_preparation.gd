extends "res://scripts/excavation/block/rough/rough_preparation.gd"
var pocket: Node
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/excavation/pockets/base/pocket_profile.gd").new(block.working_map,block.footprint,block.rim)
func _create_feedback() -> MaterialFeedback:
 if sensory_enabled and readability_enabled: return preload("res://scripts/excavation/pockets/base/pocket_feedback.gd").new()
 return super._create_feedback()
func _create_pocket() -> Node:
 return preload("res://scripts/excavation/pockets/base/friable_pocket.gd").new()
func _ready() -> void:
 super._ready()
 pocket = _create_pocket()
 add_child(pocket)
 pocket.setup(block,profile.layout)
 block.working_map.pocket = pocket
 pocket.opened.connect(func(): session.notice.emit("Des grains sous la croûte — essayez un court balayage au souffleur (3)"))
 pocket.emptied.connect(func(): session.notice.emit("Poche évacuée — reprenez la préparation autour du fossile"))
 var done := {}
 for shader in [mesh_surface_shader,baseline_surface_shader,readability_shader,original_hero_shader,witness_shader,soil_shader,hero_shader]:
  if shader==null or done.has(shader): continue
  done[shader]=true
  shader.code = _hook(shader.code,"void vertex() {",'#include "res://shaders/p6a47_pocket.gdshaderinc"\nvoid vertex() {')
  shader.code = _hook(shader.code,"ALBEDO = mix(color, cursor_color.rgb, marker);", """
if (!is_skirt && !exposed_bone && debug_view==0) {
 color=friable_color(color,UV,texelFetch(working_map,cell,0).r);
}
ALBEDO = mix(color, cursor_color.rgb, marker);
""")
 _bind_pocket()
 _uniform_light()
 get_window().title = "ArchaeologyGame — B-17 · Poche friable"
 panel.get_child(0).get_child(0).text = "B-17 / POCHE FRIABLE"
 var layer := CanvasLayer.new()
 layer.layer = 6
 add_child(layer)
 var card := PanelContainer.new()
 card.position = Vector2(610,14)
 layer.add_child(card)
 var style = preload("res://scripts/workshop/playtest_preparation_ui.gd")
 card.add_theme_stylebox_override("panel",style.paper_style(style.PAPER,12))
 var label := Label.new()
 label.text = "B-17 · Une poche sous l’argile\nOuvrez la croûte mouchetée au Chisel (2), puis soufflez les grains (3). · R : recommencer"
 label.add_theme_color_override("font_color",style.INK)
 label.add_theme_font_override("font",session_ui.body_font)
 label.add_theme_font_size_override("font_size",17)
 card.add_child(label)
 controller.ui_blockers.append(card)
func _bind_pocket() -> void:
 if not is_instance_valid(pocket): return
 for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("friable_field",pocket.texture)
func _uniform_light() -> void:
 if not ready_for_look: return
 task_light.light_energy = .28
 task_light.spot_angle = 70
 task_light.spot_angle_attenuation = .15
 task_light.spot_attenuation = .5
 bench_bounce.light_energy = .10
 if hero_enabled and task_light_enabled: $TableEnvironment/Light.light_energy = .65
func set_hero_look(enabled: bool) -> void:
 super.set_hero_look(enabled)
 _uniform_light()
 _bind_pocket()
func reload() -> void:
 super.reload()
 if is_instance_valid(pocket): pocket.configure()
