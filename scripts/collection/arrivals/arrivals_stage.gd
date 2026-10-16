extends Node3D
# Separate world for sealed arrivals. No fossil asset is instantiated here.
const Catalog = preload("res://scripts/collection/catalog.gd")
var camera: Camera3D
var crates: Dictionary = {}
var selected := "M08"
var wood_shader: Shader
var paper: StandardMaterial3D
var canvas: StandardMaterial3D

func solid(color: Color, roughness := .9) -> StandardMaterial3D:
 var material := StandardMaterial3D.new()
 material.albedo_color = color
 material.roughness = roughness
 return material

func timber(tint: Color, seed_value: float) -> ShaderMaterial:
 var material := ShaderMaterial.new()
 material.shader = wood_shader
 material.set_shader_parameter("tint", tint)
 material.set_shader_parameter("seed_value", seed_value)
 return material

func box(parent: Node3D, size: Vector3, at: Vector3, material: Material) -> MeshInstance3D:
 var node := MeshInstance3D.new()
 var mesh := BoxMesh.new()
 mesh.size = size
 node.mesh = mesh
 node.material_override = material
 parent.add_child(node)
 node.position = at
 return node

func inscription(parent: Node3D, text: String, at: Vector3, size: int, tint := Color("463b2c")) -> Label3D:
 var label := Label3D.new()
 label.text = text
 label.font_size = size
 label.pixel_size = .0019
 label.modulate = tint
 label.outline_size = 0
 label.shaded = true
 label.double_sided = false
 parent.add_child(label)
 label.position = at
 label.rotation_degrees.x = -90
 return label

func crate(id: String, at: Vector3, width: float, depth: float, angle: float, shade: Color) -> void:
 var node := Node3D.new()
 node.name = "Crate" + id
 add_child(node)
 node.position = at
 node.rotation_degrees.y = angle
 crates[id] = node
 var height := .39
 var model:Node3D=load("res://assets/arrivals/"+id.to_lower()+"_crate.glb").instantiate()
 node.add_child(model)
 var index:=0
 for part:MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
  for surface in range(part.mesh.get_surface_count()):
   var material:Material=part.mesh.surface_get_material(surface)
   if material!=null and material.resource_name.begins_with("wood"):
    part.set_surface_override_material(surface,timber(shade.lightened((index%5)*.012),float(index)))
   else:
    part.set_surface_override_material(surface,solid(Color("252923") if material==null or material.resource_name!="interior" else Color("241c14"),.82))
  index+=1
 # Opaque lid and provenance card: never load a fossil model for an unknown crate.
 var card := Node3D.new()
 node.add_child(card)
 card.position = Vector3(-width*.06,height+.005,.05)
 card.rotation_degrees.y = -5
 box(card,Vector3(.62,.006,.40),Vector3.ZERO,paper)
 inscription(card,"MUSÉUM  ·  RÉCEPTION",Vector3(0,.008,-.13),15)
 inscription(card,Catalog.entry(id).code,Vector3(0,.009,-.015),52)
 inscription(card,"DÉPÔT MARIN" if id=="M08" else "DÉPÔT CONTINENTAL",Vector3(0,.008,.11),16)
 var body := StaticBody3D.new()
 body.set_meta("specimen_id",id)
 node.add_child(body)
 var shape := CollisionShape3D.new()
 var volume := BoxShape3D.new()
 volume.size = Vector3(width,.43,depth)
 shape.shape = volume
 body.add_child(shape)
 shape.position.y = .215

func _ready() -> void:
 wood_shader = Shader.new()
 wood_shader.code = """shader_type spatial;
uniform vec4 tint : source_color;
uniform float seed_value;
varying vec3 p;
varying vec3 n;
float hash(vec2 q){return fract(sin(dot(q,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 q){vec2 i=floor(q),f=fract(q);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){p=VERTEX;n=NORMAL;}
void fragment(){
 vec2 q=abs(n.y)>.5?p.xz:(abs(n.x)>.5?p.zy:p.xy);
 q+=vec2(seed_value*.37,seed_value*.23);
 float broad=noise(q*vec2(3.0,22.0));
 float warp=noise(q*vec2(3.0,5.0))*.025;
 float grain=noise(vec2(q.x*9.0,(q.y+warp)*380.0));
 float pores=noise(q*vec2(65.0,1700.0));
 ALBEDO=tint.rgb*(.87+broad*.14+(grain-.5)*.15+(pores-.5)*.07);
 ROUGHNESS=.92;
}"""
 paper=solid(Color("c8b99a"))
 canvas=solid(Color("494b40"))
 var environment_node := WorldEnvironment.new()
 var environment := Environment.new()
 environment.background_mode = Environment.BG_COLOR
 environment.background_color = Color("241d17")
 environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 environment.ambient_light_color = Color("dcc6a3")
 environment.ambient_light_energy = .30
 environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
 environment_node.environment = environment
 add_child(environment_node)
 var key := DirectionalLight3D.new()
 add_child(key)
 key.rotation_degrees = Vector3(-65,-25,0)
 key.light_color = Color("fff0d7")
 key.light_energy = .68
 key.shadow_enabled = true
 key.directional_shadow_max_distance = 10
 key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
 key.shadow_bias = .12
 key.shadow_normal_bias = 1.2
 camera=Camera3D.new()
 add_child(camera)
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=3.65
 camera.far=12
 camera.position=Vector3(0,4.6,4.0)
 camera.look_at(Vector3(0,.05,0))
 camera.current=true
 # Same warm wood family as the excavation bench, with real edges and board seams.
 for n in range(15):
  box(self,Vector3(6.6,.13,.48),Vector3(0,-.11,-3.63+n*.49),timber(Color("533d2a"),float(n)))
 box(self,Vector3(6.7,.23,.10),Vector3(0,-.16,2.27),timber(Color("443021"),2.0))
 make_cloth()
 # A receipt and a closed register establish the workbench scale.

 crate("M08",Vector3(-1.25,0,-.18),1.45,1.10,-6,Color("766a52"))
 crate("B17",Vector3(.95,0,-.13),2.0,1.30,4,Color("6a5944"))
 box(self,Vector3(.78,.008,.40),Vector3(-1.73,-.026,1.22),paper)
 inscription(self,"SERVICE DES COLLECTIONS",Vector3(-1.73,-.018,1.13),17)
 inscription(self,"Lot du jour   /   02 caisses",Vector3(-1.73,-.018,1.27),18)
 # Closed register is a contextual prop; collection redesign remains issue 28.
 var register := Node3D.new()
 add_child(register)
 register.position=Vector3(2.45,-.015,1.10)
 register.rotation_degrees.y=-12
 box(register,Vector3(.55,.055,.76),Vector3.ZERO,solid(Color("263c32")))
 box(register,Vector3(.49,.035,.70),Vector3(.015,.017,0),solid(Color("c9b994")))
 box(register,Vector3(.55,.012,.76),Vector3(0,.040,0),solid(Color("2e4639")))
 inscription(register,"MUSÉUM",Vector3(0,.05,0),17,Color("b8a16b"))


func select_crate(id:String) -> void:
 selected=id
 for key:String in crates:
  for child in crates[key].get_children():
   if child.name=="SelectionMarker":child.free()
 var marker:=box(crates[id],Vector3(.20,.004,.025),Vector3(0,.403,.21),solid(Color("bd9a54")))
 marker.name="SelectionMarker"

func crate_at(screen:Vector2) -> String:
 var origin:=camera.project_ray_origin(screen)
 var query:=PhysicsRayQueryParameters3D.create(origin,origin+camera.project_ray_normal(screen)*20)
 var hit:=get_world_3d().direct_space_state.intersect_ray(query)
 return str(hit.collider.get_meta("specimen_id")) if not hit.is_empty() and hit.collider.has_meta("specimen_id") else ""

func resize_camera(dimensions:Vector2) -> void:
 if camera!=null:camera.size=maxf(3.65,6.0*dimensions.y/maxf(dimensions.x,1.0))

func make_cloth() -> MeshInstance3D:
 var surface:=SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for z in range(16):
  for x in range(36):
   for offset:Vector2i in [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,1),Vector2i(0,1)]:
    var u:float=float(x+offset.x)/36.0;var v:float=float(z+offset.y)/16.0
    var height:float=-.020+sin(u*47.0+v*6.0)*.008+sin(v*41.0+u*12.0)*.004
    surface.set_uv(Vector2(u,v))
    surface.add_vertex(Vector3((u-.5)*4.8,height,(v-.5)*2.05-.08))
 surface.generate_normals()
 var cloth:=MeshInstance3D.new();cloth.mesh=surface.commit();cloth.material_override=canvas;add_child(cloth)
 return cloth
