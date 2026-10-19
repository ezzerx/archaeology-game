extends RefCounted
## Dimensioned surfaces, softened profiles and texture scale around the Tripo modules.
const EnvironmentAssets=preload("res://scripts/experiments/exhibition/gallery_environment_assets.gd")
const LIMESTONE=preload("res://assets/museum/materials/limestone.png")
const PLASTER=preload("res://assets/museum/materials/plaster.png")
static var mesh_cache:Dictionary={}
static func masonry(texture:Texture2D,tint:Color,horizontal:bool,meters:float) -> ShaderMaterial:
 var m:=ShaderMaterial.new();m.shader=preload("res://shaders/experiments/gallery_masonry.gdshader")
 m.set_shader_parameter("surface_texture",texture);m.set_shader_parameter("tint",tint)
 m.set_shader_parameter("horizontal",horizontal);m.set_shader_parameter("meters",meters)
 return m
static func soft_box(parent:Node3D,size:Vector3,pos:Vector3,mat:Material,radius:float=.015) -> MeshInstance3D:
 var key:=str(size)+":"+str(radius)
 if not mesh_cache.has(key):
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  var half:=size*.5;var inner:=half-Vector3.ONE*radius
  for face in range(6):
   var axis:=face/2;var sign_value:float=1 if face%2==0 else -1
   var normal:=Vector3.ZERO;normal[axis]=sign_value
   var u:=Vector3.ZERO;u[(axis+1)%3]=1
   var v:=normal.cross(u)
   var hu:float=half[(axis+1)%3];var hv:float=half[(axis+2)%3]
   var us:Array[float]=[];var vs:Array[float]=[]
   for j in range(4):
    us.append(-hu+radius*float(j)/3.);vs.append(-hv+radius*float(j)/3.)
   for j in range(4):
    us.append(hu-radius+radius*float(j)/3.);vs.append(hv-radius+radius*float(j)/3.)
   for y in range(7):
    for x in range(7):
     for corner in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(1,0)]:
      var p:Vector3=normal*half[axis]+u*us[x+corner.x]+v*vs[y+corner.y]
      var c:=p.clamp(-inner,inner);var n:Vector3=(p-c).normalized()
      st.set_normal(n);st.set_uv(Vector2(us[x+corner.x]/(2*hu)+.5,vs[y+corner.y]/(2*hv)+.5))
      st.add_vertex(c+n*radius)
  mesh_cache[key]=st.commit()
 var node:=MeshInstance3D.new();node.mesh=mesh_cache[key];node.material_override=mat;node.position=pos;parent.add_child(node)
 return node
static func install(g:Node3D) -> void:
 var room:=preload("res://assets/museum/polish/architecture.scn").instantiate()
 room.name="GalleryArchitecture";g.add_child(room)
 preload("res://scripts/experiments/exhibition/gallery_garden.gd").install(g,room)
 EnvironmentAssets.install(g)
