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
 var root:=Node3D.new();root.name="GalleryArchitecture";g.add_child(root)
 var plaster:=masonry(PLASTER,Color(.86,.83,.76),false,2.3)
 var stone:=masonry(LIMESTONE,Color(.88,.85,.78),false,1.9)
 var wood:Material=g._material(Color("#755036"))
 var wood_trim:Material=g._material(Color("#805c3f"))
 var grout:Material=g._material(Color("#686052"),1)
 g.box(root,Vector3(13,.14,9),Vector3(0,-.11,0),grout)
 # Thin joints and rounded stone arrises replace the prominent grid.
 for z in range(12):
  for x in range(15):
   var edge:bool=x==1 or x==13 or z==1 or z==10
   var tint:=Color(.40,.51,.48) if edge else Color(.80,.79,.75)
   tint*=.97+float(posmod(x*11+z*7,7))*.009
   var floor_mat:=masonry(LIMESTONE,tint,true,1.8)
   soft_box(root,Vector3(.854,.048,.744),Vector3((x-7)*.86,-.024,(z-5.5)*.75),floor_mat,.006)
 # The wall sits behind the source modules and cannot intersect their recesses.
 # Segments leave an actual opening behind the imported arched frame.
 g.box(root,Vector3(1.40,4.8,.24),Vector3(-5.80,2.4,-2.66),plaster)
 g.box(root,Vector3(10.36,4.8,.24),Vector3(1.32,2.4,-2.66),plaster)
 g.box(root,Vector3(1.24,1.15,.24),Vector3(-4.48,.575,-2.66),plaster)
 g.box(root,Vector3(1.24,1.40,.24),Vector3(-4.48,4.10,-2.66),plaster)
 # Solid jamb returns close the parallax gap between the opening and the back wall.
 for side in [-1.,1.]:
  soft_box(root,Vector3(.18,2.22,.60),Vector3(-4.48+side*.71,2.20,-2.24),plaster,.008)
 _window_spandrels(root,plaster)
 preload("res://scripts/experiments/exhibition/gallery_garden.gd").install(g,root)
 # Wainscot echoes the imported niche profile, with softened rather than box-sharp edges.
 for i in range(19):
  var x:float=-5.85+i*.65
  if (x > -3.65 and x < -1.45) or (x>1.50 and x<3.70):continue
  soft_box(root,Vector3(.646,1.03,.15),Vector3(x,.515,-2.36),wood,.015)
  soft_box(root,Vector3(.53,.77,.04),Vector3(x,.49,-2.265),wood_trim,.012)
  soft_box(root,Vector3(.45,.67,.045),Vector3(x,.49,-2.245),wood,.012)
 for y in [.07,1.03,1.09]:
  soft_box(root,Vector3(12.4,.075,.24),Vector3(0,y,-2.29),wood_trim,.018)
 # Bring the connecting wall forward to the furniture back plane. Keeping the
 # entire wall behind the niches made the pilasters read as detached deep boxes.
 soft_box(root,Vector3(2.46,2.22,.58),Vector3(0,2.20,-2.24),plaster,.012)
 soft_box(root,Vector3(2.24,2.22,.58),Vector3(4.98,2.20,-2.24),plaster,.012)
 # Flush upper masonry ties the source modules into the architecture.
 soft_box(root,Vector3(9.84,.46,.75),Vector3(1.28,3.52,-2.175),plaster,.012)
 soft_box(root,Vector3(1.8,.46,.75),Vector3(-4.55,3.52,-2.175),plaster,.012)
 for x in [-5.67,-3.65,-1.35,1.35,3.74,5.68]:
  soft_box(root,Vector3(.24,2.22,.73),Vector3(x,2.20,-2.175),plaster,.018)
  soft_box(root,Vector3(.26,1.09,.73),Vector3(x,.545,-2.175),wood,.016)
  soft_box(root,Vector3(.30,.075,.79),Vector3(x,1.09,-2.15),wood_trim,.016)
  soft_box(root,Vector3(.30,.075,.79),Vector3(x,.06,-2.15),wood_trim,.016)

 soft_box(root,Vector3(12.4,.15,.30),Vector3(0,3.77,-1.90),stone,.027)
 soft_box(root,Vector3(12.4,.055,.36),Vector3(0,3.88,-1.87),plaster,.016)
 var title:Label3D=g.lettering(root,"Traces du vivant",Vector3(.1,3.51,-1.78),.14,Color("#6b5d40"))
 title.shaded=true
 EnvironmentAssets.install(g)
static func _window_spandrels(parent:Node3D,mat:Material) -> void:
 # Fill only the upper corners outside the arch so sky never leaks above its frame.
 for side in [-1.,1.]:
  var points:=PackedVector2Array([Vector2(0,3.40),Vector2(side*.62,3.40),Vector2(side*.62,2.69)])
  for i in range(1,25):
   var a:=float(i)/24.*PI*.5
   points.append(Vector2(side*cos(a)*.62,2.69+sin(a)*.62))
  var indices:=Geometry2D.triangulate_polygon(points)
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for i in range(0,indices.size(),3):
   for j in [2,1,0]:
    var point:=points[indices[i+j]]
    st.set_normal(Vector3.BACK);st.set_uv(point);st.add_vertex(Vector3(point.x-4.48,point.y,-1.94))
  var mesh:=MeshInstance3D.new();mesh.mesh=st.commit();mesh.material_override=mat;parent.add_child(mesh)
