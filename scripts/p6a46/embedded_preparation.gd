extends "res://scripts/p6a45/manual_preparation.gd"
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/p6a46/embedded_profile.gd").new(block.working_map,block.footprint,block.rim)
func _create_slab() -> Node:
 return preload("res://scripts/p6a46/embedded_slab.gd").new()
func _ready() -> void:
 super._ready()
 var done := {}
 for shader in [mesh_surface_shader,baseline_surface_shader,readability_shader,original_hero_shader,witness_shader,soil_shader,hero_shader]:
  if shader == null or done.has(shader): continue
  done[shader] = true
  shader.code = _hook(shader.code,"void vertex() {","uniform sampler2D slab_break : filter_linear, repeat_disable;\nuniform sampler2D slab_clay_folds : filter_linear, repeat_disable;\nvoid vertex() {")
  shader.code = _hook(shader.code,"ALBEDO = mix(color, cursor_color.rgb, marker);", """
if (!is_skirt && !exposed_bone && debug_view == 0) {
 vec2 seam = texture(slab_break,UV).rg;
 float current = texelFetch(working_map,cell,0).r;
 float remaining_lip = smoothstep(seam.g-.009,seam.g-.003,current);
 color *= 1.0-seam.r*.34*remaining_lip;
 vec2 fold = texture(slab_clay_folds,UV).rg;
 if (layer == 1) { color *= 1.0-fold.r*.22*smoothstep(fold.g-.009,fold.g-.003,current); }
}
ALBEDO = mix(color, cursor_color.rgb, marker);
""")
 for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("slab_clay_folds",profile.folds_texture)
 slab.bind_preview()
 _label_trial()
func _label_trial() -> void:
 get_window().title = "ArchaeologyGame — B-17 · Roche enchâssée"
 panel.get_child(0).get_child(0).text = "B-17 / VOLUME ENFOUI"

func set_hero_look(enabled: bool) -> void:
 super.set_hero_look(enabled)
 if profile != null and profile.get("folds_texture") != null:
  for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("slab_clay_folds",profile.folds_texture)
