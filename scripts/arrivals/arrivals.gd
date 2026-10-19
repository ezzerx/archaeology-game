extends Node3D
const Crate=preload("res://scripts/arrivals/crate.gd")
const Room=preload("res://scripts/arrivals/room.gd")
const Store=preload("res://scripts/collection/exhibit_store.gd")
const Handoff=preload("res://scripts/collection/exhibit_handoff.gd")
var crates:Array[Node3D]=[]
var camera:Camera3D
var selected:=-1
var focus:=Vector3(0,1.18,-.15)
var target_focus:=Vector3(0,1.18,-.15)
var view_size:=3.15
var target_size:=3.15
var heading:Label
var instruction:Label
var back:Button
var start_button:Button
var gallery_button:Button
var ready_for_input:=false
var transferring:=false
var dragging_lid:=false
var drag_distance:=0.
var press_opening:=0.
var drag_origin:=Vector2.ZERO
var pointer:=Vector2.ZERO
var hint_row:HBoxContainer
func _ready() -> void:
 get_window().title="ArchaeologyGame — Arrivages"
 get_window().content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
 get_viewport().msaa_3d=Viewport.MSAA_4X;get_viewport().use_taa=false
 Room.install(self);Room.lighting(self)
 for i in range(3):
  var crate=Crate.new();add_child(crate);crate.build(i);crates.append(crate)
  crate.position=Vector3([0.,-.91,.91][i],.85,[.45,.25,.25][i])
  if i>0:crate.scale=Vector3.ONE*.83;crate.rotation_degrees.y=5 if i==1 else -5
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.near=.04;camera.far=30;add_child(camera);camera.current=true
 _camera();_ui();_refresh()
 await get_tree().physics_frame
 ready_for_input=true;Handoff.ready(Store.configured_directory())
func _ui() -> void:
 var canvas:=CanvasLayer.new();add_child(canvas)
 var ui:=Control.new();canvas.add_child(ui);ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var top:=Label.new();ui.add_child(top);top.position=Vector2(35,25);top.text="LE MUSÉE  /  RÉCEPTION";top.add_theme_font_size_override("font_size",19);top.add_theme_color_override("font_color",Color("#f0e3c9"));top.add_theme_color_override("font_shadow_color",Color(.1,.1,.08,.8));top.add_theme_constant_override("shadow_offset_y",2)
 var panel:=PanelContainer.new();ui.add_child(panel);panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);panel.offset_top=-134
 var style:=StyleBoxFlat.new();style.bg_color=Color(.06,.095,.075,.95);style.content_margin_left=38;style.content_margin_right=38;style.content_margin_top=18;style.content_margin_bottom=18;panel.add_theme_stylebox_override("panel",style)
 var row:=HBoxContainer.new();row.add_theme_constant_override("separation",24);panel.add_child(row)
 var text:=VBoxContainer.new();text.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(text)
 heading=Label.new();text.add_child(heading);heading.add_theme_font_size_override("font_size",30);heading.add_theme_color_override("font_color",Color("#eee0bf"))
 instruction=Label.new();text.add_child(instruction);instruction.add_theme_font_size_override("font_size",18);instruction.add_theme_color_override("font_color",Color("#c7c8b6"));instruction.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 hint_row=HBoxContainer.new();hint_row.add_theme_constant_override("separation",10);row.add_child(hint_row)
 back=_button(hint_row,"Autres colis");back.pressed.connect(func():select(-1))
 start_button=_button(hint_row,"Préparer ce bloc");start_button.pressed.connect(_start)
 gallery_button=_button(hint_row,"Voir le musée");gallery_button.pressed.connect(_gallery)
func _button(parent:Node,text:String) -> Button:
 var b:=Button.new();parent.add_child(b);b.text=text;b.focus_mode=Control.FOCUS_NONE;b.size_flags_vertical=Control.SIZE_SHRINK_CENTER;b.custom_minimum_size=Vector2(190,50);b.add_theme_font_size_override("font_size",19)
 var style:=StyleBoxFlat.new();style.bg_color=Color("#324a3a");style.border_color=Color("#9d8b5e");style.set_border_width_all(1);style.set_corner_radius_all(4);style.content_margin_left=18;style.content_margin_right=18;b.add_theme_stylebox_override("normal",style)
 var hover:=style.duplicate();hover.bg_color=Color("#4b6247");b.add_theme_stylebox_override("hover",hover);b.add_theme_stylebox_override("pressed",hover);b.add_theme_color_override("font_color",Color("#eee0bf"));return b
func _process(delta:float) -> void:
 if selected>=0:
  var opened:float=crates[selected].opening
  target_size=lerpf(1.25,1.65,opened)
  target_focus=crates[selected].position+Vector3(0,.25+.07*opened,.02)
 var a:=1-exp(-delta*7)
 focus=focus.lerp(target_focus,a);view_size=lerpf(view_size,target_size,a);_camera()
 if selected>=0 and not transferring:
  var was_disabled:=start_button.disabled
  start_button.disabled=crates[selected].opening<.92
  if was_disabled!=start_button.disabled:_refresh()
func _camera() -> void:
 if camera==null:return
 var aspect:=get_viewport().get_visible_rect().size.aspect()
 camera.size=view_size*maxf(1.,1.60/aspect)
 camera.position=focus+Vector3(.28,3.2,5.6) if selected<0 else focus+Vector3(.10,4.3,5.0)
 camera.look_at(focus)
func select(index:int) -> void:
 if transferring:return
 dragging_lid=false
 selected=clampi(index,-1,2)
 if selected<0:target_focus=Vector3(0,1.18,-.15);target_size=3.15
 else:target_focus=crates[selected].position+Vector3(0,.25,.02);target_size=1.25
 _refresh()
func _refresh() -> void:
 back.visible=selected>=0;start_button.visible=selected>=0;gallery_button.visible=selected<0
 heading.text="Les nouveaux arrivages" if selected<0 else "Lot "+Crate.LOTS[selected]+" · "+Crate.TITLES[selected]
 instruction.text="Choisissez un colis pour consulter sa provenance."
 if selected>=0:
  var crate=crates[selected]
  instruction.text="Cliquez sur le loquet pour le libérer.  [E]" if not crate.unlocked else "Soulevez le couvercle en glissant vers le haut.  [E]"
  if crate.opening>=.92:instruction.text="Le bloc est encore couvert. Sa préparation révélera ce qu’il contient."
  start_button.disabled=crate.opening<.92
func hit(point:Vector2) -> Dictionary:
 var origin:=camera.project_ray_origin(point)
 var query:=PhysicsRayQueryParameters3D.create(origin,origin+camera.project_ray_normal(point)*30,8)
 return get_world_3d().direct_space_state.intersect_ray(query)
func _unhandled_input(event:InputEvent) -> void:
 if not ready_for_input or transferring:return
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE:select(-1)
  elif event.keycode in [KEY_1,KEY_2,KEY_3]:select(int(event.keycode)-KEY_1)
  elif event.keycode==KEY_E and selected>=0:
   if not crates[selected].unlocked:crates[selected].release_latch()
   else:crates[selected].open_fully()
   _refresh()
  elif event.keycode==KEY_ENTER and event.alt_pressed:get_window().mode=Window.MODE_WINDOWED if get_window().mode!=Window.MODE_WINDOWED else Window.MODE_FULLSCREEN
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  pointer=event.position
  if not event.pressed:
   if dragging_lid:
    dragging_lid=false
    if drag_distance<5:crates[selected].open_fully()
    _refresh()
   return
  var found:=hit(event.position)
  if found.is_empty():return
  var object:Node=found.collider
  var i:int=object.get_meta("crate",-1)
  if i<0:return
  if selected!=i:select(i);return
  if focus.distance_to(target_focus)>.03:return
  var part:String=object.get_meta("part","")
  if part=="latch" and not crates[i].unlocked:crates[i].release_latch();_refresh()
  elif part=="lid" and crates[i].unlocked:
   if crates[i].motion!=null:crates[i].motion.kill()
   dragging_lid=true;drag_distance=0;drag_origin=event.position;press_opening=crates[i].opening
 if event is InputEventMouseMotion and dragging_lid:
  drag_distance=maxf(drag_distance,event.position.distance_to(drag_origin))
  crates[selected].set_opening(press_opening+(drag_origin.y-event.position.y)/220.)
  _refresh()
func _notification(what:int) -> void:
 if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_MOUSE_EXIT]:dragging_lid=false
func _start() -> void:
 if transferring or selected<0 or crates[selected].opening<.92:return
 transferring=true;dragging_lid=false;start_button.disabled=true;back.disabled=true
 instruction.text="Installation du bloc à l’atelier…"
 if not await Handoff.transfer_to(get_tree(),"workshop",Store.configured_directory(),selected,true):_failed()
func _gallery() -> void:
 if transferring:return
 transferring=true;gallery_button.disabled=true;instruction.text="Ouverture du musée…"
 if not await Handoff.transfer_to(get_tree(),"gallery",Store.configured_directory(),-1,true):_failed()
func _failed() -> void:
 transferring=false;back.disabled=false;gallery_button.disabled=false;_refresh();instruction.text="Le passage n’a pas pu s’ouvrir. Vous pouvez réessayer."
