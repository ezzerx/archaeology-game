extends RefCounted
## Display-only authored examples. No player archive, session or tool controller.
const Catalog=preload("res://scripts/collection/catalog.gd")
const Field=preload("res://scripts/collection/specimen_field.gd")
const Outline=preload("res://scripts/excavation/block/natural/footprint.gd")
const GRID=Vector2i(256,160)
static func build(id:String) -> Node3D:
 var root:=Node3D.new();root.name="Example_"+id
 var field=Field.new(Vector2i(1024,640),id)
 var marine:=id=="M08"
 var bone:=Catalog.entry(id).model as String
 var model:Node3D=load(bone).instantiate();root.add_child(model)
 var bounds:=AABB();var first:=true
 for mesh:MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
  var transform:=mesh.transform;var parent:Node3D=mesh.get_parent()
  while parent!=root:
   transform=parent.transform*transform;parent=parent.get_parent()
  var b:AABB=transform*mesh.get_aabb()
  bounds=b if first else bounds.merge(b);first=false
 var center:=Vector2(bounds.get_center().x,bounds.get_center().z)
 var extent:=Vector2(bounds.size.x,bounds.size.z)+Vector2(.09,.08)
 var origin:=center/Vector2(1.1,.7)+Vector2(.5,.5)
 var span:=extent/Vector2(1.1,.7)
 var points:=PackedVector2Array()
 for point:Vector2 in Outline.POINTS:points.append((point-Vector2(.5,.5))*span+origin)
 var ivory:=ShaderMaterial.new();ivory.shader=preload("res://shaders/p6a36_hero_bone.gdshader")
 ivory.set_shader_parameter("inspection",true)
 ivory.set_shader_parameter("hero_bone",preload("res://assets/p6a2/textures/bone/p6a2_bone_albedo_v02.png"))
 for mesh:MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
  mesh.material_override=ivory;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 var vertices:=PackedVector3Array();var uvs:=PackedVector2Array();var colors:=PackedColorArray();var indices:=PackedInt32Array()
 # Irregular geological surface, deterministic across launches.
 var relief:=FastNoiseLite.new();relief.seed=5108 if marine else 5117
 relief.frequency=.075;relief.fractal_octaves=3
 var valid:=PackedByteArray();valid.resize(GRID.x*GRID.y)
 for y in range(GRID.y+1):
  for x in range(GRID.x+1):
   var uv:=(Vector2(x,y)/Vector2(GRID)-Vector2(.5,.5))*span+origin
   var q:=(uv-origin)/(span*.5)
   var radius:=pow(absf(q.x),4)+pow(absf(q.y),4)
   var rim:=smoothstep(.45,.97,radius)
   var ripple:=relief.get_noise_2d(x,y)*.003+relief.get_noise_2d(x*3.,y*3.)*.0006
   var h:=.026+ripple+rim*.024
   var cell:=Vector2i(uv*Vector2(field.size)).clamp(Vector2i.ZERO,field.size-Vector2i.ONE)
   var i:int=cell.y*field.size.x+cell.x
   if field.component_ids[i]!=0:h=minf(h,.018+field.ceilings[i]*.102-.009)
   vertices.append(Vector3((uv.x-.5)*1.1,h,(uv.y-.5)*.7))
   uvs.append(uv);colors.append(Color(rim,.90+.10*relief.get_noise_2d(x*.5,y*.5),0,1))
 for y in range(GRID.y):
  for x in range(GRID.x):
   var uv:=((Vector2(x,y)+Vector2.ONE*.5)/Vector2(GRID)-Vector2(.5,.5))*span+origin
   if not Geometry2D.is_point_in_polygon(uv,points):continue
   valid[y*GRID.x+x]=1
   var a:=y*(GRID.x+1)+x;var b:=a+1;var c:=a+GRID.x+1;var d:=c+1
   indices.append_array(PackedInt32Array([a,b,c,b,d,c]))
 for y in range(GRID.y):
  for x in range(GRID.x):
   if valid[y*GRID.x+x]==0:continue
   var a:=y*(GRID.x+1)+x
   for side in range(4):
    var nx:=x+([0,1,0,-1][side] as int);var ny:=y+([-1,0,1,0][side] as int)
    if nx>=0 and ny>=0 and nx<GRID.x and ny<GRID.y and valid[ny*GRID.x+nx]!=0:continue
    var ends:Array=[[a+1,a],[a+GRID.x+2,a+1],[a+GRID.x+1,a+GRID.x+2],[a,a+GRID.x+1]][side]
    var offset:=vertices.size()
    for idx:int in ends:
     var top:=vertices[idx];var bottom:=Vector3(top.x,.001,top.z)
     vertices.append(top);vertices.append(bottom);uvs.append(uvs[idx]);uvs.append(uvs[idx]+Vector2(.03,.03))
     colors.append(Color(.3,.65,0,1));colors.append(Color(.2,.45,0,1))
    indices.append_array(PackedInt32Array([offset,offset+2,offset+1,offset+2,offset+3,offset+1]))
 var arrays:=[];arrays.resize(Mesh.ARRAY_MAX)
 arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs;arrays[Mesh.ARRAY_COLOR]=colors;arrays[Mesh.ARRAY_INDEX]=indices
 var raw:=ArrayMesh.new();raw.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
 var st:=SurfaceTool.new();st.create_from(raw,0);st.generate_normals()
 var matrix:=MeshInstance3D.new();matrix.name="PreparedMatrix";matrix.mesh=st.commit()
 var mat:=ShaderMaterial.new();mat.shader=preload("res://shaders/experiments/gallery_matrix.gdshader")
 mat.set_shader_parameter("sandstone",preload("res://assets/p6a2/textures/sandstone/p6a2_sandstone_albedo_v02.png"))
 mat.set_shader_parameter("clay",preload("res://assets/p6a2/textures/clay/p6a2_clay_albedo_v02.png"))
 mat.set_shader_parameter("marine",marine)
 matrix.material_override=mat;root.add_child(matrix)
 model.position-=Vector3(center.x,0,center.y)
 matrix.position-=Vector3(center.x,0,center.y)
 root.set_meta("display_extent",extent)
 root.set_meta("example_only",true)
 return root
