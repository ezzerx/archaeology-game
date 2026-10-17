extends RefCounted
## Source GLBs are immutable; the defective niche back is repaired in scene space.
const NICHE=preload("res://assets/museum/models/wall_niche.glb")
const WINDOW=preload("res://assets/museum/models/arched_window.glb")
const FERN=preload("res://assets/museum/models/potted_fern.glb")
const BOOKS=preload("res://assets/museum/models/field_books.glb")
const MINERAL=preload("res://assets/museum/models/mineral_sample.glb")
const Furniture=preload("res://scripts/experiments/exhibition/gallery_furniture.gd")
static func prop(parent:Node3D,packed:PackedScene,node_name:String,pos:Vector3,scale_value:float,tint:Color,turn:float=0.) -> Node3D:
 var n:Node3D=packed.instantiate();n.name=node_name;n.position=pos;n.scale=Vector3.ONE*scale_value;n.rotation_degrees.y=turn
 parent.add_child(n);Furniture._materials(n,tint,.45)
 return n
static func install(g:Node3D) -> void:
 var root:=Node3D.new();root.name="EnvironmentAssets";g.add_child(root)
 for i in range(2):
  var x:float=-2.55 if i==0 else 2.60
  var n:=prop(root,NICHE,"Niche"+str(i),Vector3(x,0,-2.10),3.36,Color(.85,.86,.83))
  # Source back plane is z=-.1099 with three large holes; the new face sits in
  # front of it, behind the shelves. Cover the entire back to avoid patch seams.
  var back:MeshInstance3D=g.box(n,Vector3(.435,.64,.012),Vector3(0,.588,-.101),g._material(Color("#304334"),3))
  back.name="ContinuousNicheBack"
  # Shallow warm pools separate the objects from the recessed green back.
  var light:=SpotLight3D.new();n.add_child(light);light.position=Vector3(0,.84,.045)
  light.look_at(light.global_position+Vector3(0,-1,-.35))
  light.spot_range=2.3;light.spot_angle=64;light.light_energy=.48;light.light_color=Color("#ffe2ae")
  light.spot_attenuation=1.2;light.light_size=.10
  # Recessed downlight sits within the niche, not across the arch face.
  var bulb:=preload("res://scripts/experiments/exhibition/gallery_lighting.gd").emitter(root,Vector3(x,2.80,-2.06),.055)
  bulb.name="NicheDownlight"+str(i)
 # Shelf tops measured in the original module; source assets have a bottom pivot.
 prop(root,MINERAL,"NicheMineral",Vector3(-2.69,2.074,-2.20),.42,Color(.69,.73,.78),-16)
 prop(root,BOOKS,"NicheBooks",Vector3(-2.42,1.545,-2.19),.46,Color(.90,.93,.96),-9)
 prop(root,BOOKS,"MarineBooks",Vector3(2.56,2.074,-2.19),.39,Color(.90,.93,.96),8)
 prop(root,MINERAL,"MarineMineral",Vector3(2.67,1.545,-2.20),.30,Color(.72,.79,.85),39)
 prop(root,FERN,"WindowFern",Vector3(-4.20,.01,-1.55),1.28,Color(.63,.71,.66),18)
 prop(root,WINDOW,"ArchedWindow",Vector3(-4.48,1.09,-2.11),2.25,Color(.85,.87,.85))
 # Decorative specimens inside the existing cabinet; no player collection data.
 prop(root,MINERAL,"CabinetMineral",Vector3(-.23,1.907,-1.57),.28,Color(.73,.78,.84),-24)
 prop(root,BOOKS,"CabinetBooks",Vector3(.34,1.461,-1.58),.32,Color(.90,.93,.96),12)
