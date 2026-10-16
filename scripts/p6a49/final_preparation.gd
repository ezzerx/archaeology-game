extends "res://scripts/p6a48/buried_preparation.gd"
const FRIABLE_FINISH_HOOK:="""
float friable_height=texelFetch(working_map,cell,0).r;
color=friable_color(color,UV,friable_height);
vec3 friable_x=normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(1.0,0.0,0.0,0.0)).xyz);
vec3 friable_z=normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(0.0,0.0,1.0,0.0)).xyz);
NORMAL=friable_normal(NORMAL,UV,friable_height,friable_x,friable_z);
float loose_grains=friable_loose(texture(friable_field,UV),friable_height);
ROUGHNESS=mix(ROUGHNESS,1.0,loose_grains);
SPECULAR=mix(SPECULAR,.05,loose_grains);
"""
var introduction_seen:=false
var introduction_count:=0
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/p6a49/final_profile.gd").new(block.working_map,block.footprint,block.rim)
func _create_pocket() -> Node:return preload("res://scripts/p6a49/final_pocket.gd").new()
func _create_feedback() -> MaterialFeedback:
 if sensory_enabled and readability_enabled:return preload("res://scripts/p6a49/final_feedback.gd").new()
 return super._create_feedback()
func _ready() -> void:
 super._ready()
 get_window().title="ArchaeologyGame — B-17 · Poches friables"
 panel.get_child(0).get_child(0).text="B-17 / FINITION DES POCHES"
 for label:Label in find_children("*","Label",true,false):
  if label.text.begins_with("B-17 · Une découverte"):
   label.get_parent().hide()
 for signal_name in ["opened","emptied"]:
  for connection in pocket.get_signal_connection_list(signal_name):pocket.disconnect(signal_name,connection.callable)
 pocket.opened.connect(_first_discovery)
 pocket.contact_grains.connect(_contact_grains)
 var done:={}
 for shader in [mesh_surface_shader,baseline_surface_shader,readability_shader,original_hero_shader,witness_shader,soil_shader,hero_shader]:
  if shader==null or done.has(shader):continue
  done[shader]=true
  shader.code=shader.code.replace('res://shaders/p6a47_pocket.gdshaderinc','res://shaders/p6a49_pocket.gdshaderinc')
  shader.code=_hook(shader.code,'color=friable_color(color,UV,texelFetch(working_map,cell,0).r);',FRIABLE_FINISH_HOOK)
 $Debug/Help.text+="     H · essais"
 _variant_label()
func _first_discovery() -> void:
 if introduction_seen:return
 introduction_seen=true;introduction_count+=1
 session.notice.emit("Des grains se libèrent — essayez le souffleur (3)")
func _contact_grains(sources:Array[Vector3]) -> void:
 if feedback.has_method("contact_release"):feedback.contact_release(sources)
func _variant_label() -> void:
 if is_instance_valid(variant_button):variant_button.text="Nouvelle préparation · recommencer (%d/5)"%(profile.variant+1)
