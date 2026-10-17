extends RefCounted
## Dimensioned architectural modules surrounding the four imported furniture assets.
static func install(g:Node3D) -> void:
 var m:Dictionary=g.materials
 g.box(g,Vector3(11,.15,8),Vector3(0,-.12,0),g._material(Color("#5a574d"),1))
 # Limestone field, with a restrained green border around the display bay.
 for z in range(11):
  for x in range(16):
   var tint:=Color("#888275") if x not in [1,14] and z not in [1,9] else Color("#485349")
   tint*=.94+float(posmod(x*11+z*7,9))*.012
   var material:ShaderMaterial=g._material(tint,1)
   g.box(g,Vector3(.645,.035,.645),Vector3((x-7.5)*.65,-.025,(z-5)*.65),material)
 g.box(g,Vector3(12,5,.24),Vector3(0,2.45,-2.36),m.wall)
 g.box(g,Vector3(9.6,1.0,.14),Vector3(0,.5,-2.17),m.wood)
 for i in range(16):
  var x:float=-4.5+i*.6
  g.box(g,Vector3(.53,.78,.035),Vector3(x,.48,-2.08),m.trim)
  g.box(g,Vector3(.45,.67,.04),Vector3(x,.48,-2.06),m.wood)
 for y in [.08,.97,1.04]:
  g.box(g,Vector3(9.6,.055,.22),Vector3(0,y,-2.08),m.trim)
 # Arched recesses replace the large flat noticeboards.
 for x in [-2.65,2.65]:
  _niche(g,x,1.13,2.43,.69,-2.215)
  for y in [1.18,1.77]:
   g.box(g,Vector3(1.25,.045,.24),Vector3(x,y,-2.07),m.wood)
  var label:Label3D=g.lettering(g,"TERRES ANCIENNES" if x<0 else "MONDES MARINS",Vector3(x,2.58,-2.17),.080,Color("#b7ad8f"),g.sans)
  label.shaded=true
  g._wall_drawing(Vector3(x,2.16,-2.16),x>0).scale=Vector3.ONE*.38
 # Three masonry piers articulate the bay rather than a continuous flat wall.
 for x in [-3.58,3.58]:
  g.box(g,Vector3(.23,3.50,.29),Vector3(x,1.75,-2.08),m.wall)
  g.box(g,Vector3(.36,.12,.37),Vector3(x,2.79,-2.04),m.stone)
  g.box(g,Vector3(.31,.07,.34),Vector3(x,2.88,-2.04),m.stone)
  g.box(g,Vector3(.37,.12,.37),Vector3(x,1.03,-2.04),m.trim)
 g.box(g,Vector3(9.6,.09,.29),Vector3(0,3.62,-2.13),m.stone)
 g.box(g,Vector3(9.6,.04,.34),Vector3(0,3.68,-2.09),m.wall)
 var title:Label3D=g.lettering(g,"Traces du vivant",Vector3(.1,3.04,-2.16),.16,Color("#504b3d"))
 title.shaded=true

static func _niche(g:Node3D,x:float,bottom:float,spring:float,r:float,z:float) -> void:
 var points:=PackedVector2Array([Vector2(-r,bottom),Vector2(r,bottom),Vector2(r,spring)])
 for i in range(1,49):
  var a:=PI*float(i)/48.
  points.append(Vector2(cos(a)*r,spring+sin(a)*r))
 var mesh:=SurfaceTool.new();mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 var indices:=Geometry2D.triangulate_polygon(points)
 for i in range(0,indices.size(),3):
  for j in [2,1,0]:
   var p:=points[indices[i+j]];mesh.set_normal(Vector3(0,0,1));mesh.add_vertex(Vector3(x+p.x,p.y,z))
 var node:=MeshInstance3D.new();node.mesh=mesh.commit();node.material_override=g.materials.teal;g.add_child(node)
 # Rounded arch profile with real depth: inner reveal, face and outer return.
 var ring:=SurfaceTool.new();ring.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(48):
  var a:=PI*float(i)/48.;var b:=PI*float(i+1)/48.
  for profile in range(3):
   var radii:Vector2
   var depths:Vector2
   if profile==0:radii=Vector2(r,r+.025);depths=Vector2(z+.005,z+.15)
   elif profile==1:radii=Vector2(r+.025,r+.145);depths=Vector2(z+.15,z+.15)
   else:radii=Vector2(r+.145,r+.17);depths=Vector2(z+.15,z+.005)
   var vertices:=[Vector3(x+cos(a)*radii.x,spring+sin(a)*radii.x,depths.x),Vector3(x+cos(b)*radii.x,spring+sin(b)*radii.x,depths.x),Vector3(x+cos(b)*radii.y,spring+sin(b)*radii.y,depths.y),Vector3(x+cos(a)*radii.y,spring+sin(a)*radii.y,depths.y)]
   for index in [0,1,2,0,2,3]:ring.add_vertex(vertices[index])
 ring.generate_normals()
 var rim:=MeshInstance3D.new();rim.mesh=ring.commit();rim.material_override=g.materials.stone;g.add_child(rim)
 for side in [-1,1]:
  g.box(g,Vector3(.15,spring-bottom,.15),Vector3(x+side*(r+.085),(spring+bottom)*.5,z+.075),g.materials.stone)
