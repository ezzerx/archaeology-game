extends "res://scripts/p6a41/rough_preparation.gd"
var slab: Node
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/p6a43/slab_profile.gd").new(block.working_map,block.footprint,block.rim)
func _ready() -> void:
 super._ready()
 slab = preload("res://scripts/p6a43/fractured_slab.gd").new()
 add_child(slab)
 slab.setup(block,profile.layout)
 block.working_map.slab = slab
 slab.loosened.connect(_joint_notice)
 slab.detached.connect(_detachment_notice)
 var done := {}
 for shader in [mesh_surface_shader,baseline_surface_shader,readability_shader,original_hero_shader,witness_shader,soil_shader,hero_shader]:
  if shader == null or done.has(shader): continue
  done[shader] = true
  shader.code = _hook(shader.code,"void vertex() {","uniform sampler2D slab_cracks : filter_linear, repeat_disable;\nvoid vertex() {")
  shader.code = _hook(shader.code,"ALBEDO = mix(color, cursor_color.rgb, marker);","""
if (!is_skirt && !exposed_bone && layer == 2 && debug_view == 0) {
 float h = texelFetch(working_map,cell,0).r;
 float roof = texelFetch(layer_boundaries,cell,0).r;
 vec2 joint = texture(slab_cracks,UV).rg;
 float intact_plate = smoothstep(roof-.055,roof-.025,h);
 color *= 1.0-joint.r*intact_plate*(.72+.16*joint.g);
}
ALBEDO = mix(color, cursor_color.rgb, marker);
""")
 for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("slab_cracks",slab.texture)
 _label_trial()
 var layer := CanvasLayer.new()
 layer.layer = 6
 add_child(layer)
 var card := PanelContainer.new()
 card.position = Vector2(620,14)
 layer.add_child(card)
 var style = preload("res://scripts/p6a/playtest_preparation_ui.gd")
 card.add_theme_stylebox_override("panel",style.paper_style(style.PAPER,12))
 var label := Label.new()
 label.text = "B-17 · Grès fracturé\nLe Pick peut ouvrir les joints et libérer la plaque. · R : recommencer"
 label.add_theme_color_override("font_color",style.INK)
 label.add_theme_font_override("font",session_ui.body_font)
 card.add_child(label)
 controller.ui_blockers.append(card)
func _label_trial() -> void:
 get_window().title = "ArchaeologyGame — B-17 · Grès fracturé"
 panel.get_child(0).get_child(0).text = "B-17 / PLAQUE FRACTURÉE"
func _joint_notice() -> void:
 if slab.strikes.size() == 1: session.notice.emit("Le joint s’ouvre — poursuivez sur une autre fissure")
func _detachment_notice(_reason: String) -> void:
 session.notice.emit("Plaque détachée")
func reload() -> void:
 super.reload()
 if is_instance_valid(slab): slab.configure()
func set_hero_look(enabled: bool) -> void:
 super.set_hero_look(enabled)
 if is_instance_valid(slab):
  for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("slab_cracks",slab.texture)
