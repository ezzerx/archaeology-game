extends Node3D
## Isolated visual trial: two authored examples, no collection/storage access.
const Fixture=preload("res://scripts/experiments/exhibition/gallery_fixture.gd")
const B17Stand=preload("res://scripts/experiments/exhibition/b17_stand.gd")
const AmmoniteStand=preload("res://scripts/experiments/exhibition/ammonite_stand.gd")
const Furniture=preload("res://scripts/experiments/exhibition/gallery_furniture.gd")
const Room=preload("res://scripts/experiments/exhibition/gallery_room.gd")
const Cartel=preload("res://scripts/experiments/exhibition/gallery_cartel.gd")
const OVERVIEW_FOCUS=Vector3(0,1.72,-.25)
const OVERVIEW_SIZE=6.15
var _previous_rendering:Dictionary={}
var museum_audio:Node
var sound_mode:OptionButton
var camera:Camera3D
var selected:=-1
var focus:=OVERVIEW_FOCUS
var target_focus:=OVERVIEW_FOCUS
var view_size:=OVERVIEW_SIZE
var target_size:=OVERVIEW_SIZE
var angle:=Vector2.ZERO
var target_angle:=Vector2.ZERO
var orbit:=Vector3(1.0,4.5,7.6)
var dragging:=false
var dragged:=false
var press_point:=Vector2.ZERO
var examples:Array[Node3D]=[]
var centers:Array[Vector3]=[Vector3(-1.65,1.14,.06),Vector3(1.62,1.14,.06)]
var heading:Label
var subtitle:Label
var nav_buttons:Array[Button]=[]
var exhibition_note:Label
var fade:ColorRect
var fixtures_ready:=false
var materials:Dictionary={}
var serif:=SystemFont.new()
var sans:=SystemFont.new()
func _ready() -> void:
 get_window().title="ArchaeologyGame — Première exposition"
 # Render 3D at window resolution; keep the authored logical UI layout.
 _previous_rendering={"stretch":get_window().content_scale_mode,"msaa":get_viewport().msaa_3d,"taa":get_viewport().use_taa}
 get_window().content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
 get_viewport().msaa_3d=Viewport.MSAA_4X
 get_viewport().use_taa=false
 serif.font_names=PackedStringArray(["Georgia","Noto Serif"])
 sans.font_names=PackedStringArray(["Segoe UI","Noto Sans"])
 _materials();_environment();Room.install(self);Furniture.install(self);_displays();_ui()
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.near=.05;camera.far=40;add_child(camera);camera.current=true
 _update_camera()
 await get_tree().process_frame
 for id in ["B17","M08"]:
  var index:=examples.size()
  var fixture:=_build_exhibit(id);var pivot:=get_node("Mount"+str(index))
  examples.append(fixture)
  if fixture==null:continue
  pivot.add_child(fixture)
  var extent:Vector2=fixture.get_meta("display_extent")
  var usable:Vector2=pivot.get_meta("usable_extent",Vector2(1.84,1.54))
  var fit:=minf(usable.x/extent.x,usable.y/extent.y)
  if fixture.has_meta("snapshot_version"):fit*=.92 # Leave room for the real block thickness above the board.
  fixture.scale=Vector3.ONE*fit
  fixture.position=-Vector3(fixture.get_meta("display_center",Vector3.ZERO))*fit
  await get_tree().process_frame
 _install_audio()
 fixtures_ready=true
 var tween:=create_tween();tween.tween_property(fade,"modulate:a",0.0,.7)
 tween.tween_callback(fade.hide)
func _material(color:Color,kind:int=0) -> ShaderMaterial:
 var m:=ShaderMaterial.new();m.shader=preload("res://shaders/experiments/gallery_surface.gdshader")
 m.set_shader_parameter("tint",color);m.set_shader_parameter("kind",kind);return m
func _materials() -> void:
 materials.wood=_material(Color("#38261d"));materials.trim=_material(Color("#55402a"))
 materials.wall=_material(Color("#b6b2a8"),1);materials.stone=_material(Color("#aba899"),1)
 materials.teal=_material(Color("#263c32"),3);materials.dark=_material(Color("#15211e"),3)
 materials.brass=_material(Color("#a4824b"),2);materials.paper=_material(Color("#e5d7b8"),3)
 materials.floor=_material(Color("#3e3429"));materials.edge=_material(Color("#1f1713"))
func box(parent:Node3D,size:Vector3,pos:Vector3,mat:Material) -> MeshInstance3D:
 var n:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=size
 n.mesh=mesh;n.material_override=mat;n.position=pos;parent.add_child(n);return n
func cylinder(parent:Node3D,radius:float,height:float,pos:Vector3,mat:Material) -> MeshInstance3D:
 var n:=MeshInstance3D.new();var mesh:=CylinderMesh.new()
 mesh.top_radius=radius;mesh.bottom_radius=radius;mesh.height=height;mesh.radial_segments=24
 n.mesh=mesh;n.material_override=mat;n.position=pos;parent.add_child(n);return n
func lettering(parent:Node3D,words:String,pos:Vector3,size:float,color:Color,font:Font=null) -> Label3D:
 var t:=Label3D.new();t.text=words;t.font=font if font!=null else serif
 t.font_size=96;t.pixel_size=size/96.;t.position=pos;t.modulate=color
 t.outline_size=0;t.no_depth_test=false;t.shaded=false;t.double_sided=false
 parent.add_child(t);return t
func _environment() -> void:
 preload("res://scripts/experiments/exhibition/gallery_lighting.gd").install(self)

func _wall_drawing(pos:Vector3,marine:bool) -> MeshInstance3D:
 var line:=ImmediateMesh.new();line.surface_begin(Mesh.PRIMITIVE_LINES)
 for band in range(5 if not marine else 1):
  for i in range(180):
   var t:=float(i)/179.
   var a:Vector3
   var b:Vector3
   if marine:
    var theta:=t*TAU*2.4;var r:=.035+t*.33
    var next:=theta+.08
    a=Vector3(cos(theta)*r,sin(theta)*r,0);b=Vector3(cos(next)*(r+.002),sin(next)*(r+.002),0)
   else:
    var x:float=(t-.5)*2.65
    var y:float=.16*sin(t*5.0)+.030*sin(t*17+band*.4)-band*.075+.16
    a=Vector3(x,y,0);b=Vector3(x+.015,y+.002,0)
   line.surface_add_vertex(a);line.surface_add_vertex(b)
 line.surface_end()
 var n:=MeshInstance3D.new();n.mesh=line;n.position=pos;add_child(n)
 var mat:=StandardMaterial3D.new();mat.albedo_color=Color("#a09372");mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;n.material_override=mat
 return n
func _displays() -> void:
 for i in range(2):
  var center:=centers[i]
  var width:=B17Stand.WIDTH if i==0 else AmmoniteStand.WIDTH
  var depth:=B17Stand.DEPTH if i==0 else AmmoniteStand.DEPTH
  var mount:=Node3D.new();mount.name="Mount"+str(i);add_child(mount)
  mount.position=center;mount.rotation_degrees.x=19
  var stand:=B17Stand.install(self,center) if i==0 else AmmoniteStand.install(self,center)
  var plinth_height:float=stand.get_meta("plinth_height")
  Room.soft_box(self,Vector3(width-.13,plinth_height-.06,depth-.13),Vector3(center.x,(plinth_height+.06)*.5,center.z),_material(Color("#68482f")),.018)
  Room.soft_box(self,Vector3(width-.04,.06,depth-.04),Vector3(center.x,.03,center.z),materials.edge,.012)
  mount.set_meta("usable_extent",B17Stand.USABLE_EXTENT if i==0 else AmmoniteStand.USABLE_EXTENT)
  Cartel.install(self,i,Vector3(center.x,.925,1.04),serif,sans)
func _ui() -> void:
 var canvas:=CanvasLayer.new();add_child(canvas)
 var ui:=Control.new();canvas.add_child(ui);ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var shade:=ColorRect.new();ui.add_child(shade);shade.color=Color(.035,.045,.038,.88)
 shade.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);shade.offset_top=-118;shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 heading=Label.new();shade.add_child(heading);heading.position=Vector2(46,18);heading.add_theme_font_override("font",serif)
 heading.add_theme_font_size_override("font_size",29);heading.add_theme_color_override("font_color",Color("#eadbbb"))
 subtitle=Label.new();shade.add_child(subtitle);subtitle.position=Vector2(47,64);subtitle.add_theme_font_override("font",sans)
 subtitle.add_theme_font_size_override("font_size",17);subtitle.add_theme_color_override("font_color",Color("#b6b29e"))
 var row:=HBoxContainer.new();shade.add_child(row);row.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 row.offset_left=-660;row.offset_right=-35;row.offset_top=30;row.offset_bottom=80;row.add_theme_constant_override("separation",14)
 for i in range(3):
  var button:=Button.new();row.add_child(button)
  button.text=["Vue d’ensemble","B–17","Ammonite"][i];button.custom_minimum_size=Vector2(190,50)
  button.add_theme_font_override("font",sans);button.add_theme_font_size_override("font_size",19);button.focus_mode=Control.FOCUS_NONE
  var style:=StyleBoxFlat.new();style.bg_color=Color("#23352e");style.border_color=Color("#8b7952")
  style.set_border_width_all(1);style.set_corner_radius_all(3);style.content_margin_left=20;style.content_margin_right=20
  button.add_theme_stylebox_override("normal",style)
  var hover:=style.duplicate();hover.bg_color=Color("#384c3b");button.add_theme_stylebox_override("hover",hover)
  button.add_theme_stylebox_override("pressed",hover);button.add_theme_color_override("font_color",Color("#e6d5af"))
  button.pressed.connect(select.bind(i-1));nav_buttons.append(button)
 var note_back:=ColorRect.new();ui.add_child(note_back);note_back.position=Vector2(18,12);note_back.size=Vector2(460,42);note_back.color=Color(.055,.075,.06,.83);note_back.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var note:=Label.new();exhibition_note=note;ui.add_child(note);note.position=Vector2(30,22)
 note.text="ÉTUDE D’EXPOSITION · PRÉPARATIONS D’EXEMPLE";note.add_theme_font_override("font",sans)
 note.add_theme_font_size_override("font_size",15);note.modulate=Color("#d7c8aa")
 fade=ColorRect.new();ui.add_child(fade);fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);fade.color=Color("#17221d");fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 _captions()
func select(index:int) -> void:
 if not fixtures_ready:return
 selected=clampi(index,-1,1);target_angle=Vector2.ZERO
 target_focus=OVERVIEW_FOCUS if selected<0 else centers[selected]+Vector3(0,-.14,.12)
 target_size=OVERVIEW_SIZE if selected<0 else (3.2 if selected==0 else 2.65)
 _captions()
func _captions() -> void:
 heading.text="Traces du vivant" if selected<0 else ("Petit théropode · B–17" if selected==0 else "Ammonite côtelée · M–08")
 subtitle.text="Choisissez une pièce pour l’observer de près." if selected<0 else "Molette : rapprocher · Glisser : observer le relief · Échap : ensemble"
 for i in range(nav_buttons.size()):nav_buttons[i].modulate=Color.WHITE if i-1==selected else Color(.72,.76,.70)
func _process(delta:float) -> void:
 var a:=1.0-exp(-delta*7.)
 focus=focus.lerp(target_focus,a);view_size=lerpf(view_size,target_size,a);angle=angle.lerp(target_angle,a)
 orbit=orbit.lerp(Vector3(1.0,4.5,7.6) if selected<0 else Vector3(0,6.8,5.4),a)
 _update_camera()
func _update_camera() -> void:
 if camera==null:return
 var distance:=orbit
 distance=distance.rotated(Vector3.UP,angle.x).rotated(Vector3.RIGHT,angle.y)
 camera.position=focus+distance;camera.look_at(focus);camera.size=view_size
func _unhandled_input(event:InputEvent) -> void:
 if not fixtures_ready:return
 if event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_ESCAPE,KEY_HOME:select(-1)
   KEY_LEFT,KEY_A:select(0)
   KEY_RIGHT,KEY_D:select(1)
   KEY_ENTER:
    if event.alt_pressed:get_window().mode=Window.MODE_WINDOWED if get_window().mode!=Window.MODE_WINDOWED else Window.MODE_FULLSCREEN
 if event is InputEventMouseButton:
  if event.button_index==MOUSE_BUTTON_LEFT:
   if event.pressed:press_point=event.position;dragging=true;dragged=false
   else:
    dragging=false
    if not dragged:_click_piece(event.position)
  if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and selected>=0:
   target_size=clampf(target_size*(.90 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 1.11),1.6 if selected==0 else 1.3,4.)
 if event is InputEventMouseMotion and dragging:
  if event.position.distance_to(press_point)>6:dragged=true
  if selected>=0:
   target_angle.x=clampf(target_angle.x-event.relative.x*.002,-.16,.16)
   target_angle.y=clampf(target_angle.y-event.relative.y*.001,-.06,.06)
  else:target_focus.x=clampf(target_focus.x-event.relative.x*.004,-.65,.65)
func _click_piece(point:Vector2) -> void:
 for i in range(centers.size()):
  var size:=Vector2(3.,1.7) if i==0 else Vector2(2.,1.5)
  var c:=camera.unproject_position(centers[i])
  var w:=camera.unproject_position(centers[i]+Vector3(size.x*.5,0,0)).distance_to(c)
  if Rect2(c-Vector2(w,w*.65),Vector2(w*2,w*1.3)).has_point(point):select(i);return
func _notification(what:int) -> void:
 if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_MOUSE_EXIT]:dragging=false

func _exit_tree() -> void:
 if _previous_rendering.is_empty():return
 get_window().content_scale_mode=_previous_rendering.stretch
 get_viewport().msaa_3d=_previous_rendering.msaa
 get_viewport().use_taa=_previous_rendering.taa

func _build_exhibit(id:String) -> Node3D:
 return Fixture.build(id)

func _install_audio() -> void:
 museum_audio=preload("res://scripts/audio/museum_audio.gd").new()
 museum_audio.name="MuseumAudio";add_child(museum_audio);museum_audio.setup(self)
 sound_mode=OptionButton.new();exhibition_note.get_parent().add_child(sound_mode)
 sound_mode.name="MuseumSoundMode";sound_mode.position=Vector2(1250,18)
 sound_mode.custom_minimum_size=Vector2(350,46);sound_mode.focus_mode=Control.FOCUS_NONE
 for label in museum_audio.LABELS:sound_mode.add_item(label)
 sound_mode.select(museum_audio.mode)
 sound_mode.add_theme_stylebox_override("normal",nav_buttons[0].get_theme_stylebox("normal"))
 sound_mode.add_theme_font_override("font",sans);sound_mode.add_theme_font_size_override("font_size",19)
 sound_mode.add_theme_color_override("font_color",Color("#e6d5af"))
 sound_mode.item_selected.connect(func(index:int):museum_audio.set_mode(index))
