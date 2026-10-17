extends "res://scripts/collection/specimen_preparation.gd"
@export var demo_kind:=0
var compact_variant:=0
var material_hint:Label
var finishing_button:Button
func _create_mastery_ui() -> PreparationUI:
 var ui=preload("res://scripts/experiments/preparation_demos/demo_ui.gd").new()
 ui.distinction=distinction
 return ui
func _create_profile() -> SoilFoundationProfile:
 if demo_kind==2:return preload("res://scripts/experiments/preparation_demos/concretion_profile.gd").new(block.working_map,block.footprint,block.rim)
 if demo_kind==0:return preload("res://scripts/experiments/preparation_demos/compact_profile.gd").new(block.working_map,block.footprint,block.rim,compact_variant)
 return preload("res://scripts/experiments/preparation_demos/demo_profile.gd").new(block.working_map,block.footprint,block.rim,demo_kind)
func _create_feedback() -> MaterialFeedback:return preload("res://scripts/experiments/preparation_demos/demo_feedback.gd").new()
func _ready() -> void:
 if demo_kind==2:
  var tool:=ToolDefinition.new();tool.id=&"abrasive_tip";tool.display_name="Pointe abrasive";tool.radius=18;tool.power=0;tool.effectiveness=Vector3.ZERO;tool.bone_damage=0
  $ToolController.tools.append(tool)
 super._ready()
 # A separate namespace even when launched without QA switches. No real collection write.
 distinction.storage_path="user://preparation_demos/distinctions.json"
 DirAccess.make_dir_recursive_absolute("user://preparation_demos")
 if "--qa" in OS.get_cmdline_user_args():
  for argument in OS.get_cmdline_user_args():
   if argument.begins_with("--distinction-store="):distinction.storage_path=argument.trim_prefix("--distinction-store=")
 distinction.records.clear()
 collection_button.hide()
 if is_instance_valid(variant_button):variant_button.hide()
 for mat in [block.material,block.skirt_material]:
  var shader:=Shader.new()
  shader.code=mat.shader.code.replace("void vertex() {",'#include "res://shaders/experiments/preparation_demo.gdshaderinc"\nvoid vertex() {')
  shader.code=shader.code.replace("ALBEDO = mix(color, cursor_color.rgb, marker);", """if (!exposed_bone && debug_view==0) {
 float demo_h=texelFetch(working_map,cell,0).r;
 color=demo_material(color,UV,demo_h,is_skirt);
 if(preparation_demo>0 && !is_skirt){
  vec3 demo_x=normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(1,0,0,0)).xyz);
  vec3 demo_z=normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(0,0,1,0)).xyz);
  NORMAL=demo_grain_normal(NORMAL,UV,demo_h,demo_x,demo_z);
  ROUGHNESS=max(ROUGHNESS,.93);SPECULAR=min(SPECULAR,.12);
 }
}
ALBEDO = mix(color, cursor_color.rgb, marker);""")
  mat.shader=shader
  mat.set_shader_parameter("preparation_demo",demo_kind)
  mat.set_shader_parameter("demo_geology",profile.geology)
  mat.set_shader_parameter("demo_crust",profile.crust)
 material_hint=Label.new();material_hint.position=Vector2(560,923);material_hint.size=Vector2(800,28)
 material_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 material_hint.add_theme_font_override("font",session_ui.body_font)
 material_hint.add_theme_font_size_override("font_size",20)
 material_hint.add_theme_color_override("font_color",Color(.94,.87,.72))
 material_hint.add_theme_color_override("font_shadow_color",Color(0,0,0,.9));material_hint.add_theme_constant_override("shadow_offset_y",2)
 session_ui.root_control.add_child(material_hint)
 # Keep discovery notices below the selector instead of underneath its buttons.
 session_ui.notice_label.position.y=116 if demo_kind==0 else 78
 if demo_kind>0:
  feedback.colors[0]=Color(.41,.34,.22);feedback.colors[1]=Color(.37,.34,.25);feedback.colors[2]=Color(.48,.42,.30)
 if demo_kind==2:_setup_finishing_toolbar()
 $Debug/Help.text=("1 Brush ↔ Pointe abrasive" if demo_kind==2 else "1 Brush")+"   2 Chisel   3 Souffleur   4 Pick"+"     Molette · zoom     Clic droit · déplacer     Home · vue"
 get_window().title="ArchaeologyGame — Trois préparations"
 session_ui.archive_button.text="Terminer cet essai"
 session_ui.refresh()
func _input(event:InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_H,KEY_C]:
  get_viewport().set_input_as_handled();return
 super._input(event)

func _process(delta:float) -> void:
 super._process(delta)
 if material_hint==null:return
 material_hint.text=""
 if demo_kind==0 or not controller.hit.get("inside",false):return
 var surface=block.working_map
 var point:Vector2=controller.hit.map
 var cell:=Vector2i(point.round()).clamp(Vector2i.ZERO,surface.size-Vector2i.ONE)
 var i:int=cell.y*surface.size.x+cell.x
 var height:float=surface._heights[i]
 # A cue describes the actual visible surface only; no look-ahead into buried anatomy.
 if surface.crust_caps[i]>0 and height<=surface.crust_caps[i]+.001:
  material_hint.text="Concrétion adhérente  ·  Pointe abrasive · famille [1]"
 elif surface.fossil.exposed[i]!=0:
  if surface.bone_film.value_at((Vector2(cell)+Vector2.ONE*.5)/Vector2(surface.size))>0:
   material_hint.text="Poussière sur la pièce  ·  Brush [1]"
 elif surface.grain_roofs[i]>0 and height<=surface.grain_roofs[i]+.001 and height>surface.grain_floors[i]+.002:
  material_hint.text="Grains libérés  ·  Souffleur [3]"
 elif height>surface.strata.packed_limits[i*2]+.0001:
  material_hint.text="Terre de surface  ·  Brush [1]"
 elif surface.grain_roofs[i]>0 and height>surface.grain_roofs[i]+.001:
  material_hint.text="Croûte compacte  ·  Chisel [2] / Pick [4]"
 else:material_hint.text="Matrice consolidée  ·  Chisel [2] / Pick [4]"

func _setup_finishing_toolbar() -> void:
 var redundant:=toolbar.get_child(4)
 toolbar.remove_child(redundant);redundant.queue_free()
 finishing_button=toolbar.get_child(0)
 for connection in finishing_button.pressed.get_connections():
  finishing_button.pressed.disconnect(connection.callable)
 finishing_button.pressed.connect(controller.select_finishing)
 finishing_button.custom_minimum_size=Vector2(292,58)
 finishing_button.add_theme_font_size_override("font_size",16)
 finishing_button.tooltip_text="1 : rappeler la finition · nouvel appui : changer de variante"
 toolbar.offset_left=-422;toolbar.offset_right=422;toolbar.offset_top=-84
 _update_toolbar(controller.selected_index)

func _update_toolbar(index:int) -> void:
 super._update_toolbar(index)
 if not is_instance_valid(finishing_button):return
 var abrasive:bool=controller.finishing_variant==4
 finishing_button.text="[1] "+("Pointe abrasive\n↔ Brush" if abrasive else "Brush\n↔ Pointe abrasive")
 finishing_button.set_pressed_no_signal(index in [0,4])
