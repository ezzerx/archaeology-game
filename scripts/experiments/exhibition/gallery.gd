extends Node3D
## Isolated visual trial: two authored examples, no collection/storage access.
const Fixture=preload("res://scripts/experiments/exhibition/gallery_fixture.gd")
const B17Stand=preload("res://scripts/experiments/exhibition/b17_stand.gd")
var camera:Camera3D
var selected:=-1
var focus:=Vector3(0,1.20,0)
var target_focus:=Vector3(0,1.20,0)
var view_size:=5.4
var target_size:=5.4
var angle:=Vector2.ZERO
var target_angle:=Vector2.ZERO
var orbit:=Vector3(1.0,5.4,7.3)
var dragging:=false
var dragged:=false
var press_point:=Vector2.ZERO
var examples:Array[Node3D]=[]
var centers:Array[Vector3]=[Vector3(-1.65,1.14,.06),Vector3(1.62,1.14,.06)]
var heading:Label
var subtitle:Label
var nav_buttons:Array[Button]=[]
var fade:ColorRect
var fixtures_ready:=false
var materials:Dictionary={}
var serif:=SystemFont.new()
var sans:=SystemFont.new()
func _ready() -> void:
 get_window().title="ArchaeologyGame — Première exposition"
 get_viewport().msaa_3d=Viewport.MSAA_4X
 serif.font_names=PackedStringArray(["Georgia","Noto Serif"])
 sans.font_names=PackedStringArray(["Segoe UI","Noto Sans"])
 _materials();_environment();_room();_displays();_ui()
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.near=.05;camera.far=40;add_child(camera);camera.current=true
 _update_camera()
 await get_tree().process_frame
 for id in ["B17","M08"]:
  var index:=examples.size()
  var fixture:=Fixture.build(id);var pivot:=get_node("Mount"+str(index))
  pivot.add_child(fixture)
  var extent:Vector2=fixture.get_meta("display_extent")
  var usable:Vector2=pivot.get_meta("usable_extent",Vector2(1.84,1.54))
  var fit:=minf(usable.x/extent.x,usable.y/extent.y)
  fixture.scale=Vector3.ONE*fit
  examples.append(fixture)
  await get_tree().process_frame
 fixtures_ready=true
 var tween:=create_tween();tween.tween_property(fade,"modulate:a",0.0,.7)
 tween.tween_callback(fade.hide)
func _material(color:Color,kind:int=0) -> ShaderMaterial:
 var m:=ShaderMaterial.new();m.shader=preload("res://shaders/experiments/gallery_surface.gdshader")
 m.set_shader_parameter("tint",color);m.set_shader_parameter("kind",kind);return m
func _materials() -> void:
 materials.wood=_material(Color("#38261d"));materials.trim=_material(Color("#55402a"))
 materials.wall=_material(Color("#b9ad94"),1);materials.stone=_material(Color("#b4a58a"),1)
 materials.teal=_material(Color("#223c39"),3);materials.dark=_material(Color("#15211e"),3)
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
 var world:=WorldEnvironment.new();var env:=Environment.new()
 env.background_mode=Environment.BG_COLOR;env.background_color=Color("#1b201e")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color("#d8d3bb");env.ambient_light_energy=.33
 env.tonemap_mode=Environment.TONE_MAPPER_FILMIC;world.environment=env;add_child(world)
 var key:=DirectionalLight3D.new();add_child(key);key.rotation_degrees=Vector3(-55,-26,0)
 key.light_color=Color("#ffe8c2");key.light_energy=.60;key.shadow_enabled=true
 key.directional_shadow_max_distance=16;key.shadow_bias=.05;key.shadow_normal_bias=.4
 var fill:=DirectionalLight3D.new();add_child(fill);fill.rotation_degrees=Vector3(-38,125,0)
 fill.light_color=Color("#c8dfdc");fill.light_energy=.20
 for x in [-1.65,1.62]:
  var light:=SpotLight3D.new();add_child(light);light.position=Vector3(x,3.6,.6)
  light.look_at(Vector3(x,1,0));light.light_color=Color("#ffe3b3");light.light_energy=.22
  light.spot_range=6;light.spot_angle=42;light.spot_attenuation=.6

func _room() -> void:
 box(self,Vector3(10,.15,6),Vector3(0,-.12,0),materials.edge)
 for z in range(19):
  for x in range(6):
   var mat:ShaderMaterial=materials.floor.duplicate();mat.set_shader_parameter("tint",Color("#3e3429")*(.88+float(posmod(x*11+z*7,9))*.025))
   var b:=box(self,Vector3(1.7,.035,.29),Vector3((x-2.5)*1.72+(.5 if z%2 else 0),-.025,(z-9)*.3),mat)
   b.rotation.y=.002*sin(x*9+z)
 box(self,Vector3(14,6,.18),Vector3(0,2.9,-1.35),materials.wall)
 box(self,Vector3(9.3,1.04,.13),Vector3(0,.51,-1.21),materials.wood)
 for x in range(15):
  var px:float=-4.35+x*.62
  box(self,Vector3(.56,.78,.04),Vector3(px,.5,-1.13),materials.trim)
  box(self,Vector3(.48,.68,.045),Vector3(px,.5,-1.10),materials.wood)
 for y in [.07,.98,1.06]:
  box(self,Vector3(9.4,.045,.18),Vector3(0,y,-1.13),materials.trim)
 box(self,Vector3(9.4,.018,.018),Vector3(0,1.095,-1.04),materials.brass)
 for x in [-3.85,3.85]:
  box(self,Vector3(.14,3.15,.16),Vector3(x,2.12,-1.14),materials.stone)
  box(self,Vector3(.28,.1,.23),Vector3(x,3.62,-1.10),materials.stone)
 for x in [-1.95,1.95]:
  box(self,Vector3(3.48,1.65,.06),Vector3(x,2.21,-1.205),materials.teal)
  for dx in [-1.75,1.75]:box(self,Vector3(.025,1.69,.065),Vector3(x+dx,2.21,-1.16),materials.brass)
  for y in [1.365,3.055]:box(self,Vector3(3.53,.025,.065),Vector3(x,y,-1.16),materials.brass)
 lettering(self,"Traces du vivant",Vector3(0,3.32,-1.10),.25,Color("#463d2e"))
 lettering(self,"TERRES ANCIENNES",Vector3(-1.95,2.87,-1.15),.12,Color("#d2c19c"),sans)
 lettering(self,"Un squelette, une histoire",Vector3(-1.95,2.64,-1.15),.16,Color("#eadbb7"))
 lettering(self,"MONDES MARINS",Vector3(1.95,2.87,-1.15),.12,Color("#d2c19c"),sans)
 lettering(self,"La mémoire des mers",Vector3(1.95,2.64,-1.15),.16,Color("#eadbb7"))
 _wall_drawing(Vector3(-1.95,2.00,-1.13),false)
 _wall_drawing(Vector3(1.95,2.00,-1.13),true)
 # A quiet side cabinet makes the gallery feel occupied before the player's work.
 for x in [-3.75,3.75]:
  box(self,Vector3(.52,.76,.63),Vector3(x,.38,-.20),materials.wood)
  box(self,Vector3(.59,.06,.70),Vector3(x,.79,-.20),materials.trim)
  for y in [.16,.37,.58]:
   box(self,Vector3(.44,.18,.025),Vector3(x,y,.13),materials.trim)
   box(self,Vector3(.1,.018,.035),Vector3(x,y,.155),materials.brass)
 for i in range(3):
  box(self,Vector3(.32,.035,.40),Vector3(-3.75,.84+i*.036,-.20),materials.paper).rotation.y=.08*i
func _wall_drawing(pos:Vector3,marine:bool) -> void:
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
func _displays() -> void:
 for i in range(2):
  var center:=centers[i]
  var width:=B17Stand.WIDTH if i==0 else 2.10
  var depth:=B17Stand.DEPTH if i==0 else 1.80
  var mount:=Node3D.new();mount.name="Mount"+str(i);add_child(mount)
  mount.position=center;mount.rotation_degrees.x=19
  if i==0:
   var stand:=B17Stand.install(self,center)
   var plinth_height:float=stand.get_meta("plinth_height")
   box(self,Vector3(width-.13,plinth_height-.06,depth-.13),Vector3(center.x,(plinth_height+.06)*.5,center.z),materials.dark)
   box(self,Vector3(width-.04,.06,depth-.04),Vector3(center.x,.03,center.z),materials.edge)
   mount.set_meta("usable_extent",B17Stand.USABLE_EXTENT)
  else:
   box(self,Vector3(width-.30,.77,depth-.34),Vector3(center.x,.44,.12),materials.wood)
   box(self,Vector3(width-.20,.10,depth-.24),Vector3(center.x,.105,.12),materials.edge)
   for offset in [-1,1]:
    var front:=box(self,Vector3((width-.48)*.5,.58,.025),Vector3(center.x+offset*(width-.35)*.25,.47,depth*.5-.04),materials.trim)
    box(front,Vector3((width-.61)*.5,.49,.02),Vector3(0,0,.02),materials.wood)
   box(mount,Vector3(width,.10,depth),Vector3(0,-.07,0),materials.trim)
   box(mount,Vector3(width-.10,.024,depth-.10),Vector3(0,-.008,0),materials.dark)
   for side in [-1,1]:
    box(mount,Vector3(.018,.025,depth-.08),Vector3(side*(width*.5-.035),.008,0),materials.brass)
    box(mount,Vector3(width-.06,.025,.018),Vector3(0,.008,side*(depth*.5-.035)),materials.brass)
  # Labels are mounted on a separate lip: they never overlap the specimen.
  var label_pivot:=Node3D.new();add_child(label_pivot)
  label_pivot.position=Vector3(center.x,.77,depth*.5+.16);label_pivot.rotation_degrees.x=-48
  box(label_pivot,Vector3(1.25,.28,.018),Vector3.ZERO,materials.brass)
  box(label_pivot,Vector3(1.21,.24,.020),Vector3(0,0,.012),materials.paper)
  var title:="Petit théropode" if i==0 else "Ammonite côtelée"
  lettering(label_pivot,title,Vector3(0,.040,.029),.073,Color("#3a3325"))
  lettering(label_pivot,"B–17 · RAVIN DES OCRES" if i==0 else "M–08 · BASSIN DES AULNES",Vector3(0,-.055,.030),.036,Color("#695f49"),sans)
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
 var note:=Label.new();ui.add_child(note);note.position=Vector2(30,22)
 note.text="ÉTUDE D’EXPOSITION · PRÉPARATIONS D’EXEMPLE";note.add_theme_font_override("font",sans)
 note.add_theme_font_size_override("font_size",15);note.modulate=Color("#d7c8aa")
 fade=ColorRect.new();ui.add_child(fade);fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);fade.color=Color("#17221d");fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 _captions()
func select(index:int) -> void:
 if not fixtures_ready:return
 selected=clampi(index,-1,1);target_angle=Vector2.ZERO
 target_focus=Vector3(0,1.20,0) if selected<0 else centers[selected]+Vector3(0,-.14,.12)
 target_size=5.4 if selected<0 else (3.2 if selected==0 else 2.65)
 _captions()
func _captions() -> void:
 heading.text="Traces du vivant" if selected<0 else ("Petit théropode · B–17" if selected==0 else "Ammonite côtelée · M–08")
 subtitle.text="Choisissez une pièce pour l’observer de près." if selected<0 else "Molette : rapprocher · Glisser : observer le relief · Échap : ensemble"
 for i in range(nav_buttons.size()):nav_buttons[i].modulate=Color.WHITE if i-1==selected else Color(.72,.76,.70)
func _process(delta:float) -> void:
 var a:=1.0-exp(-delta*7.)
 focus=focus.lerp(target_focus,a);view_size=lerpf(view_size,target_size,a);angle=angle.lerp(target_angle,a)
 orbit=orbit.lerp(Vector3(1.0,5.4,7.3) if selected<0 else Vector3(0,6.8,5.4),a)
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
