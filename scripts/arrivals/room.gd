extends RefCounted
const Shapes=preload("res://scripts/experiments/exhibition/gallery_room.gd")
const Props=preload("res://scripts/experiments/exhibition/gallery_environment_assets.gd")
const Furniture=preload("res://scripts/experiments/exhibition/gallery_furniture.gd")
static func material(color:String,metal:=0.) -> StandardMaterial3D:
 var m:=StandardMaterial3D.new();m.albedo_color=Color(color);m.roughness=.8;m.metallic=metal;return m
static func block(parent:Node3D,size:Vector3,pos:Vector3,mat:Material,radius:=.01) -> MeshInstance3D:
 return Shapes.soft_box(parent,size,pos,mat,radius)
static func install(scene:Node3D) -> void:
 var room:=Node3D.new();room.name="ReceivingRoom";scene.add_child(room)
 var plaster:=Shapes.masonry(Shapes.PLASTER,Color(.90,.87,.80),false,2.1)
 var green:=material("#344b3d");var trim:=material("#50634e");var wood:=material("#735033")
 var stone:=Shapes.masonry(Shapes.LIMESTONE,Color(.84,.82,.75),false,1.5)
 block(room,Vector3(8,.12,8),Vector3(0,-.09,-.5),material("#5f6256"))
 for z in range(10):
  for x in range(11):
   var tint:=Color(.80,.79,.72) if (x+z)%2==0 else Color(.72,.73,.68)
   if x==1 or x==9:tint=Color(.43,.52,.46)
   block(room,Vector3(.695,.045,.695),Vector3((x-5)*.7,-.025,(z-5)*.7),Shapes.masonry(Shapes.LIMESTONE,tint,true,1.6),.005)
 # Wall segments leave real openings for the window and the connecting arch.
 block(room,Vector3(1.15,3.7,.22),Vector3(-3.025,1.85,-1.9),plaster)
 block(room,Vector3(2.5,3.7,.22),Vector3(-.35,1.85,-1.9),plaster)
 block(room,Vector3(1.0,3.7,.22),Vector3(3.1,1.85,-1.9),plaster)
 block(room,Vector3(1.0,.96,.22),Vector3(-2.1,.48,-1.9),plaster)
 block(room,Vector3(1.0,.50,.22),Vector3(-2.1,3.45,-1.9),plaster)
 # Cream arch made with a rounded profile above the passage.
 var center:=Vector3(1.75,2.08,-1.9)
 for side in [-1,1]:
  block(room,Vector3(.23,2.08,.45),Vector3(1.75+side*.91,1.04,-1.8),stone,.018)
  block(room,Vector3(.32,.10,.52),Vector3(1.75+side*.91,2.02,-1.8),stone,.018)
 for i in range(24):
  var a:float=PI*(i+.5)/24
  var voussoir:=block(room,Vector3(.145,.23,.45),center+Vector3(cos(a)*.91,sin(a)*.91,0),stone,.008)
  voussoir.rotation.z=a-PI/2
 # Fill above the arched passage with wedge strips, no solid wall across its opening.
 for i in range(32):
  var x:float=-.8+(i+.5)*1.6/32
  var bottom:float=2.08+sqrt(maxf(0,.8*.8-x*x))
  block(room,Vector3(.052,3.7-bottom,.22),Vector3(1.75+x,(3.7+bottom)/2,-1.9),plaster,.001)
 block(room,Vector3(2,.15,.35),Vector3(1.75,3.58,-1.85),stone,.02)
 # Wainscot and cornice articulate the wall without filling window/door openings.
 for x in [-3.25,-2.65,-2.05,-1.45,-.85,-.25,.35,3.15]:
  block(room,Vector3(.58,.87,.065),Vector3(x,.45,-1.745),green)
  block(room,Vector3(.47,.62,.035),Vector3(x,.44,-1.70),trim,.012)
  block(room,Vector3(.405,.555,.035),Vector3(x,.44,-1.675),green,.01)
 for y in [.055,.90,.96]:
  block(room,Vector3(4.5,.065,.15),Vector3(-1.45,y,-1.70),wood)
  block(room,Vector3(.85,.065,.15),Vector3(3.15,y,-1.70),wood)
 block(room,Vector3(7.3,.16,.32),Vector3(0,3.52,-1.72),stone,.018)
 # Deeper room visible through arch; books, not undiscovered specimens.
 block(room,Vector3(2.2,3.2,.18),Vector3(1.75,1.6,-3.5),plaster)
 block(room,Vector3(.18,3.2,1.5),Vector3(2.85,1.6,-2.8),plaster)
 block(room,Vector3(1.45,.10,.5),Vector3(1.75,.9,-3.15),wood)
 Props.prop(room,Props.BOOKS,"PassageBooks",Vector3(1.60,.95,-3.12),.40,Color(.82,.85,.83),-12)
 # Window source, genuine opening and softly lit garden beyond.
 Props.prop(room,Props.WINDOW,"ReceivingWindow",Vector3(-2.1,.94,-1.62),2.0,Color(.85,.87,.85))
 var sky:=MeshInstance3D.new();var quad:=QuadMesh.new();quad.size=Vector2(2.6,3.4);sky.mesh=quad;sky.position=Vector3(-2.1,1.8,-3.0)
 var sky_mat:=ShaderMaterial.new();sky_mat.shader=preload("res://shaders/experiments/gallery_window.gdshader");sky.material_override=sky_mat;sky.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;room.add_child(sky)
 var garden=material("#789365")
 for i in range(9):
  var leaf:=MeshInstance3D.new();var sphere:=SphereMesh.new();sphere.radius=.24; sphere.height=.55;sphere.radial_segments=12;sphere.rings=8;leaf.mesh=sphere;leaf.material_override=garden
  leaf.position=Vector3(-2.85+float(i%3)*.55,.80+float(i/3)*.45,-2.55);room.add_child(leaf)
 Props.prop(room,Props.FERN,"WindowFern",Vector3(-2.75,.02,-.65),1.15,Color(.69,.76,.69),18)
 # Background credenza and field books.
 block(room,Vector3(1.2,.65,.43),Vector3(-.55,.325,-1.35),wood,.018)
 block(room,Vector3(1.28,.055,.50),Vector3(-.55,.68,-1.32),wood,.012)
 Props.prop(room,Props.BOOKS,"FieldBooks",Vector3(-.80,.71,-1.32),.42,Color(.90,.92,.87),-9)
 var drawing:=Node3D.new();drawing.name="FieldMap";room.add_child(drawing);drawing.position=Vector3(-.45,1.92,-1.65)
 block(drawing,Vector3(.82,.62,.04),Vector3.ZERO,wood,.008)
 block(drawing,Vector3(.75,.55,.012),Vector3(0,0,.026),material("#c8b88f"),.002)
 for i in range(6):
  var line:=block(drawing,Vector3(.59,.008,.004),Vector3(0,-.16+i*.065,.036),material("#847858"),.001)
  line.rotation.z=.07*sin(i*2.)
 for x in [-1.10,.60,2.8]:
  var lamp:Node3D=Furniture.LAMP.instantiate();room.add_child(lamp);lamp.scale=Vector3.ONE*.40;lamp.position=Vector3(x,2.65,-1.49);lamp.rotation_degrees.y=-90;Furniture._materials(lamp,Color(.80,.81,.76),.3)
  var bulb_pos:=lamp.to_global(Vector3(.31,.020,0))
  preload("res://scripts/experiments/exhibition/gallery_lighting.gd").emitter(room,bulb_pos,.06)
  var light:=OmniLight3D.new();room.add_child(light);light.position=bulb_pos+Vector3(0,-.05,.06);light.light_color=Color("#ffda9a");light.light_energy=.6;light.omni_range=1.25
 var table=load("res://assets/arrivals/models/reception_counter.glb").instantiate();table.name="ReceptionCounter";room.add_child(table);table.position=Vector3(0,0,.35);Furniture._materials(table,Color(.80,.83,.83),.35)
 # Register on the edge, deliberately away from crate picking surfaces.
 block(room,Vector3(.28,.022,.20),Vector3(-1.15,.867,.78),material("#493b2a"),.005)
 block(room,Vector3(.26,.008,.18),Vector3(-1.15,.882,.78),material("#e0d2ad"),.003)
static func lighting(scene:Node3D) -> void:
 preload("res://scripts/experiments/exhibition/gallery_lighting.gd").install(scene)
 var env:Environment=scene.get_node("GalleryLighting").environment
 env.tonemap_exposure=1.7 if RenderingServer.get_current_rendering_method()=="forward_plus" else .9
 env.ssil_intensity=.25
 scene.get_node("WindowDaylight").rotation_degrees=Vector3(-44,-48,0)
 scene.get_node("WindowDaylight").light_energy=1.05
 for n in scene.get_children():
  if str(n.name).begins_with("SpecimenLight"):n.queue_free()
