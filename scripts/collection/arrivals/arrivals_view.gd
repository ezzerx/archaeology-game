extends Control
# Native viewport keeps arrivals lighting and cameras out of the preparation world.
signal specimen_chosen(id:String)
signal collection_requested
signal resume_requested
const Catalog=preload("res://scripts/collection/catalog.gd")
var stage:Node3D
var viewport:SubViewport
var selected:="M08"
var current_id:=""
var current_archived:=false
var blocked:=false
var item_buttons:Dictionary={}
var description:Label
var rhythm:Label
var banner:Label
var resume_button:Button
var collection_button:Button
var viewport_container:SubViewportContainer
var store:RefCounted
func text_label(text:String,at:Vector2,font_size:int,tint:=Color("eee0c3")) -> Label:
 var label:=Label.new();add_child(label);label.text=text;label.position=at
 label.add_theme_font_size_override("font_size",font_size);label.add_theme_color_override("font_color",tint)
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 return label
func make_button(text:String,at:Vector2,dimensions:Vector2,callback:Callable,primary:=false) -> Button:
 var button:=Button.new();add_child(button);button.text=text;button.position=at;button.size=dimensions;button.focus_mode=Control.FOCUS_ALL
 button.add_theme_font_size_override("font_size",24)
 var normal:=StyleBoxFlat.new();normal.bg_color=Color("cab789") if primary else Color("302c23")
 normal.content_margin_left=24;normal.content_margin_right=24
 normal.border_width_bottom=2;normal.border_color=Color("88774f")
 var hover:=normal.duplicate();hover.bg_color=normal.bg_color.lightened(.12)
 var focus:=StyleBoxFlat.new();focus.bg_color=Color.TRANSPARENT;focus.set_border_width_all(2);focus.border_color=Color("eee0c3")
 button.add_theme_stylebox_override("normal",normal);button.add_theme_stylebox_override("hover",hover)
 button.add_theme_stylebox_override("pressed",normal);button.add_theme_stylebox_override("focus",focus)
 button.add_theme_color_override("font_color",Color("302b21") if primary else Color("e1d1b0"))
 button.add_theme_color_override("font_hover_color",Color("302b21") if primary else Color("fff0d0"))
 button.pressed.connect(callback)
 return button
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 viewport_container=SubViewportContainer.new();add_child(viewport_container)
 viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 viewport_container.stretch=true;viewport_container.mouse_filter=Control.MOUSE_FILTER_IGNORE
 viewport=SubViewport.new();viewport_container.add_child(viewport)
 viewport.own_world_3d=true;viewport.handle_input_locally=false;viewport.gui_disable_input=true
 stage=preload("res://scripts/collection/arrivals/arrivals_stage.gd").new();viewport.add_child(stage)
 text_label("MUSÉUM D’HISTOIRE NATURELLE  /  RÉCEPTION",Vector2(80,48),18,Color("c4b392"))
 var title:=text_label("Les arrivages de l’atelier",Vector2(77,80),46)
 var serif:=SystemFont.new();serif.font_names=PackedStringArray(["Georgia"]);title.add_theme_font_override("font",serif)
 collection_button=make_button("Ma collection  →",Vector2(1530,70),Vector2(310,56),func():collection_requested.emit())
 resume_button=make_button("Reprendre ma préparation",Vector2(1440,145),Vector2(400,56),func():resume_requested.emit())
 description=text_label("",Vector2(80,887),27)
 rhythm=text_label("",Vector2(80,933),21,Color("cdbb96"))
 text_label("Cliquez sur une caisse · ← → pour choisir · Entrée pour ouvrir",Vector2(80,1008),18,Color("cdbb96"))
 banner=text_label("",Vector2(80,190),19,Color("ead5aa"));banner.size=Vector2(1250,70);banner.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 for id:String in Catalog.IDS:
  item_buttons[id]=make_button("",Vector2(1390,940),Vector2(450,66),func():specimen_chosen.emit(id),true)
 visibility_changed.connect(_visibility_changed)
 resized.connect(_resize_stage)
 select_crate(selected)
 _visibility_changed()
func configure(data:RefCounted,active_id:String,archived:bool) -> void:
 store=data;current_id=active_id;current_archived=archived;blocked=false
 resume_button.visible=not current_id.is_empty() and not current_archived
 for button:Button in item_buttons.values():button.disabled=false
 select_crate(selected)
func select_crate(id:String) -> void:
 selected=id;stage.select_crate(id)
 var data:=Catalog.entry(id)
 description.text="Caisse "+data.code+"  ·  "+data.provenance
 rhythm.text=data.rhythm
 if current_id==id and not current_archived:rhythm.text="Votre préparation en cours vous attend à l’établi."
 elif store!=null and store.records.has(id):rhythm.text="Un nouvel exemplaire · votre pièce conservée reste dans la collection."
 var had_focus:=false
 for button:Button in item_buttons.values():had_focus=had_focus or button.has_focus()
 for key:String in item_buttons:
  var button:Button=item_buttons[key]
  button.visible=key==id
  button.text="Reprendre ma préparation  →" if current_id==key and not current_archived else "Ouvrir la caisse "+Catalog.entry(key).code+"  →"
 if had_focus:item_buttons[id].grab_focus()
func _resize_stage() -> void:stage.resize_camera(size)
func _visibility_changed() -> void:
 var active:=is_visible_in_tree()
 viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
 stage.process_mode=Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
 set_process_input(active);set_process_unhandled_input(active)
 if active:_resize_stage.call_deferred()
func _input(event:InputEvent) -> void:
 if blocked or not is_visible_in_tree():return
 if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed:
  if event.physical_keycode==KEY_TAB:
   var targets:Array[Button]=[collection_button]
   if resume_button.visible:targets.append(resume_button)
   targets.append(item_buttons[selected])
   var index:int=targets.find(get_viewport().gui_get_focus_owner())
   index=(targets.size()-1 if event.shift_pressed else 0) if index<0 else posmod(index+(-1 if event.shift_pressed else 1),targets.size())
   targets[index].grab_focus();get_viewport().set_input_as_handled()
  elif event.physical_keycode in [KEY_LEFT,KEY_RIGHT]:
   select_crate("B17" if selected=="M08" else "M08");get_viewport().set_input_as_handled()
func _unhandled_input(event:InputEvent) -> void:
 if blocked or not is_visible_in_tree() or item_buttons[selected].disabled:return
 if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and event.physical_keycode in [KEY_ENTER,KEY_KP_ENTER]:
  specimen_chosen.emit(selected);get_viewport().set_input_as_handled()
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  var local:Vector2=get_global_transform_with_canvas().affine_inverse()*event.position
  var id:String=stage.crate_at(local*Vector2(viewport.size)/size)
  if not id.is_empty():select_crate(id);get_viewport().set_input_as_handled()
