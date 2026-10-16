extends "res://scripts/p6a43/slab_preparation.gd"
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/p6a44/natural_profile.gd").new(block.working_map,block.footprint,block.rim)
func _create_slab() -> Node:
 return preload("res://scripts/p6a44/natural_slab.gd").new()
func _ready() -> void:
 super._ready()
 var done := {}
 for shader in [mesh_surface_shader,baseline_surface_shader,readability_shader,original_hero_shader,witness_shader,soil_shader,hero_shader]:
  if shader == null or done.has(shader): continue
  done[shader] = true
  shader.code = _hook(shader.code,"float roof = texelFetch(layer_boundaries,cell,0).r;","float roof = texelFetch(layer_boundaries,cell,0).g;")
  shader.code = _hook(shader.code,"color *= 1.0-joint.r*intact_plate*(.72+.16*joint.g);","color *= 1.0-joint.r*intact_plate*(.52+.18*joint.g);")
 _label_trial()
 for label: Label in find_children("*","Label",true,false):
  if label.text.begins_with("B-17 · Grès fracturé"): label.text = "B-17 · Grès dans sa matrice\nOuvrez les joints visibles au Pick. · R : recommencer"
func _label_trial() -> void:
 get_window().title = "ArchaeologyGame — B-17 · Plaque naturelle"
 panel.get_child(0).get_child(0).text = "B-17 / PLAQUE INTÉGRÉE"
