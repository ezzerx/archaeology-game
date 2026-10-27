extends Node3D
## Source builder for the atelier still-life. Run bake_atelier.gd to rebuild.
## Noninteractive peripheral props, metre units, shared material batches.
var batches: Dictionary = {}
var materials: Dictionary = {}
var triangle_count := 0
var lod_counts: Dictionary = {}

func build(marine := false) -> void:
 name = "AtelierStillLife"
 _material("enamel", Color(.34,.35,.30), .57, .05)
 _material("green", Color(.038,.095,.076), .63)
 _material("brass", Color(.28,.18,.085), .49, .52)
 _material("steel", Color(.32,.36,.35), .32, .8)
 _material("wood", Color(.20,.085,.031), .61)
 _material("paper", Color(.36,.31,.22), .98)
 _material("ink", Color(.09,.065,.035), .98)
 _material("clay", Color(.28,.10,.041), .96)
 _material("leaf", Color(.075,.145,.045), .81)
 _material("canvas", Color(.38,.30,.18), .98)
 var cloth := preload("res://materials/p6a2/canvas.tres").duplicate()
 cloth.set_shader_parameter("linen_color",Color(.245,.225,.185))
 cloth.set_shader_parameter("thread_spacing",.00085)
 cloth.set_shader_parameter("linen_relief",.00008)
 materials["canvas"] = cloth
 var art := StandardMaterial3D.new()
 art.albedo_texture = preload("res://assets/workshop/polish/field_notes.svg")
 art.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
 art.albedo_color = Color(.49,.47,.42)
 art.roughness = .98
 materials["art"] = art
 # Broad soft support frames the irregular block. No raised rim intersects it.
 _mat(Vector2(.90/1.13,.78/.71) if marine else Vector2.ONE)
 _notebook(Vector3(.653,.016,.105), -.13)
 _books(Vector3(.676,.014,-.245), .09)
 _tray(Vector3(-.657,.012,.105), -.06)
 # The visible lamp is removed by explicit art direction; task illumination stays separate.
 _sample_jar(Vector3(.676,0,.324), .035, .086)
 _brush_pot(Vector3(-.673,0,-.257))
 _plant(Vector3(.745,0,-.447))
 _ruler(Vector3(-.13,.007,.393))
 _tag(Vector3(.406,.009,.375),-.11)
 _flush()

func _material(key: String, color: Color, roughness: float, metal := 0.0) -> void:
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.roughness = roughness
 mat.metallic = metal
 mat.vertex_color_use_as_albedo = true
 materials[key] = mat

func _append(key: String, mesh: Mesh, transform: Transform3D, tint := Color.WHITE) -> void:
 if not batches.has(key):
  var st := SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  batches[key] = st
 var st: SurfaceTool = batches[key]
 var arrays := mesh.surface_get_arrays(0)
 var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
 var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
 var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
 var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
 var normal_basis := transform.basis.inverse().transposed()
 var total := indices.size() if not indices.is_empty() else vertices.size()
 for n in range(total):
  var i: int = indices[n] if not indices.is_empty() else n
  st.set_normal((normal_basis*normals[i]).normalized())
  st.set_uv(uv[i] if not uv.is_empty() else Vector2.ZERO)
  st.set_color(tint)
  st.add_vertex(transform*vertices[i])

func _pose(position: Vector3, angle := 0.0) -> Transform3D:
 return Transform3D(Basis(Vector3.UP,angle),position)

func _box(key: String, position: Vector3, size: Vector3, angle := 0.0, bevel := .0015, tint := Color.WHITE) -> void:
 # Bevelled box built from four eight-point rings; softened silhouettes catch light.
 var rings: Array[PackedVector3Array] = []
 var b := minf(bevel,minf(size.y*.35,minf(size.x,size.z)*.15))
 for level in range(4):
  var inset := b if level in [0,3] else 0.0
  var y: float = [-size.y*.5,-size.y*.5+b,size.y*.5-b,size.y*.5][level]
  var x := size.x*.5-inset
  var z := size.z*.5-inset
  var c := maxf(b*.6,.00001)
  rings.append(PackedVector3Array([Vector3(-x+c,y,-z),Vector3(x-c,y,-z),Vector3(x,y,-z+c),Vector3(x,y,z-c),Vector3(x-c,y,z),Vector3(-x+c,y,z),Vector3(-x,y,z-c),Vector3(-x,y,-z+c)]))
 var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for r in range(3):
  for j in range(8):
   var k := (j+1)%8
   _quad(st,rings[r][j],rings[r][k],rings[r+1][k],rings[r+1][j])
 for j in range(1,7):
  _triangle(st,rings[3][0],rings[3][j+1],rings[3][j])
  _triangle(st,rings[0][0],rings[0][j],rings[0][j+1])
 _append(key,st.commit(),_pose(position,angle),tint)

func _triangle(st: SurfaceTool, a: Vector3,b: Vector3,c: Vector3, uv_a := Vector2.ZERO, uv_b := Vector2.RIGHT, uv_c := Vector2.ONE) -> void:
 var normal := (b-a).cross(c-a).normalized()
 st.set_normal(normal)
 st.set_uv(uv_a); st.add_vertex(a)
 st.set_uv(uv_c); st.add_vertex(c)
 st.set_uv(uv_b); st.add_vertex(b)

func _quad(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> void:
 _triangle(st,a,b,c,Vector2(0,0),Vector2(1,0),Vector2(1,1))
 _triangle(st,a,c,d,Vector2(0,0),Vector2(1,1),Vector2(0,1))

func _lathe(key: String, position: Vector3, profile: Array, segments := 24, angle := 0.0) -> void:
 var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for r in range(profile.size()-1):
  var p: Vector2 = profile[r]; var q: Vector2 = profile[r+1]
  for j in range(segments):
   var a := TAU*float(j)/segments; var b := TAU*float(j+1)/segments
   _quad(st,Vector3(cos(a)*p.x,p.y,sin(a)*p.x),Vector3(cos(b)*p.x,p.y,sin(b)*p.x),Vector3(cos(b)*q.x,q.y,sin(b)*q.x),Vector3(cos(a)*q.x,q.y,sin(a)*q.x))
 _append(key,st.commit(),_pose(position,angle))

func _rod(key: String, a: Vector3,b: Vector3, radius: float, end_radius := -1.0, segments := 10) -> void:
 var mesh := CylinderMesh.new()
 mesh.top_radius = radius if end_radius<0 else end_radius
 mesh.bottom_radius = radius
 mesh.height = a.distance_to(b)
 mesh.radial_segments = segments
 mesh.rings = 1
 var axis := (b-a).normalized()
 var x := Vector3.RIGHT.cross(axis).normalized()
 if x.length_squared()<.01: x = Vector3.FORWARD.cross(axis).normalized()
 var z := x.cross(axis).normalized()
 _append(key,mesh,Transform3D(Basis(x,axis,z),a.lerp(b,.5)))

func _mat(scale_xz := Vector2.ONE) -> void:
 # Gentle irregular textile edge, stitched hem and corner folds under the block.
 var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var cloth_scale := Vector3(scale_xz.x,1,scale_xz.y)
 var nx := 48; var nz := 32
 for z in range(nz):
  for x in range(nx):
   _quad(st,_cloth_vertex(x,z,nx,nz),_cloth_vertex(x,z+1,nx,nz),_cloth_vertex(x+1,z+1,nx,nz),_cloth_vertex(x+1,z,nx,nz))
 _append("canvas",st.commit(),Transform3D(Basis.from_scale(cloth_scale),Vector3.ZERO))
 for x in range(86):
  var px := -.53+x*.0125
  for z in [-.33,.33]:
   _rod("paper",Vector3(px,.006,z)*cloth_scale,Vector3(px+.0055,.006,z)*cloth_scale,.0005,-1,5)
 for z in range(49):
  var pz := -.304+z*.0125
  for x in [-.545,.545]:
   _rod("paper",Vector3(x,.006,pz)*cloth_scale,Vector3(x,.006,pz+.0055)*cloth_scale,.0005,-1,5)

func _cloth_vertex(x: int,z: int,nx: int,nz: int) -> Vector3:
 var u := float(x)/nx; var v := float(z)/nz
 var edge := pow(absf(u-.5)*2,12)+pow(absf(v-.5)*2,12)
 return Vector3((u-.5)*1.13+.002*sin(v*25),.003+edge*(.0015+.001*sin(u*35+v*14)),(v-.5)*.71+.002*sin(u*21))

func _art(position: Vector3,size: Vector2,angle: float,tile: int) -> void:
 var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var uv0 := Vector2(float(tile%2)*.5,float(tile/2)*.5)
 var a := Vector3(-size.x*.5,0,-size.y*.5); var b := Vector3(-size.x*.5,0,size.y*.5)
 var c := Vector3(size.x*.5,0,size.y*.5); var d := Vector3(size.x*.5,0,-size.y*.5)
 _triangle(st,a,b,c,uv0,uv0+Vector2(0,.5),uv0+Vector2(.5,.5))
 _triangle(st,a,c,d,uv0,uv0+Vector2(.5,.5),uv0+Vector2(.5,0))
 _append("art",st.commit(),_pose(position,angle))

func _notebook(origin: Vector3,angle: float) -> void:
 var pose := _pose(origin,angle)
 _box("green",origin,Vector3(.193,.011,.233),angle,.002)
 _box("paper",origin+Vector3(0,.01,0),Vector3(.184,.012,.221),angle,.001)
 # Leaves and binding give the notebook volume from the fixed oblique camera.
 for n in range(4):
  _box("ink",origin+Vector3(0,.006+n*.0023,.109),Vector3(.177,.00035,.0006),angle,0)
 _art(origin+Vector3(0,.017,0),Vector2(.18,.216),angle,0)
 _rod("brass",pose*Vector3(-.05,.025,.12),pose*Vector3(.072,.025,-.118),.0025)
 _rod("ink",pose*Vector3(.072,.025,-.118),pose*Vector3(.078,.025,-.131),.0022,0)

func _books(origin: Vector3,angle: float) -> void:
 for n in range(2):
  var p := origin+Vector3(-.008*n,.019*n,0)
  var a := angle+.08*n
  _box("green" if n==1 else "wood",p,Vector3(.163,.008,.207),a,.002)
  _box("paper",p+Vector3(0,.009,0),Vector3(.152,.014,.193),a,.001)
  _box("green" if n==1 else "wood",p+Vector3(0,.018,0),Vector3(.163,.005,.207),a,.001)
  _box("green" if n==1 else "wood",p+Vector3(-.079,.009,0),Vector3(.008,.025,.207),a,.002)
 _art(origin+Vector3(-.008,.041,0),Vector2(.145,.186),angle+.08,1)

func _tray(origin: Vector3,angle: float) -> void:
 var pose := _pose(origin,angle)
 _box("enamel",origin,Vector3(.174,.012,.323),angle,.004)
 _box("green",origin+Vector3(0,.007,0),Vector3(.156,.003,.302),angle,.002)
 for x in [-.082,.082]:
  _box("enamel",pose*Vector3(x,.014,0),Vector3(.009,.026,.314),angle,.003)
 for z in [-.155,.155]:
  _box("enamel",pose*Vector3(0,.014,z),Vector3(.169,.026,.009),angle,.003)
 # Tool roll supports: textured straps beneath three distinct silhouettes.
 for z in [-.079,.071]:
  _box("canvas",pose*Vector3(0,.014,z),Vector3(.149,.009,.028),angle,.002)
 for n in range(3):
  var tool: String = ["brush","chisel","pick"][n]
  var tool_pose := pose * Transform3D(Basis(Vector3.RIGHT,PI*.5).scaled(Vector3.ONE*1.65),Vector3(-.051+n*.049,.026,-.091))
  _asset(tool,tool_pose)

func _asset(asset: String, transform: Transform3D) -> void:
 var source: Node3D = load("res://assets/p6a3/models/"+asset+".glb").instantiate()
 for instance: MeshInstance3D in source.find_children("*","MeshInstance3D",true,false):
  for surface in range(instance.mesh.get_surface_count()):
   var key := asset+str(surface)
   materials[key] = instance.mesh.surface_get_material(surface)
   var mesh := ArrayMesh.new()
   var arrays := instance.mesh.surface_get_arrays(surface)
   var optimized := ImporterMesh.new()
   optimized.add_surface(Mesh.PRIMITIVE_TRIANGLES,arrays)
   optimized.generate_lods(25,60,[])
   if optimized.get_surface_lod_count(0)>0:
    arrays[Mesh.ARRAY_INDEX] = optimized.get_surface_lod_indices(0,0)
   mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
   _append(key,mesh,transform*instance.transform)
 source.free()
func _sample_jar(origin: Vector3,radius: float,height: float) -> void:
 # Opaque amber ceramic avoids layered transparency on the preparation renderer.
 _lathe("clay",origin,[Vector2(0,0),Vector2(radius*.84,0),Vector2(radius,.006),Vector2(radius,height*.65),Vector2(radius*.72,height*.78),Vector2(radius*.72,height*.91)],28)
 _lathe("brass",origin,[Vector2(radius*.78,height*.87),Vector2(radius*.82,height*.9),Vector2(radius*.82,height),Vector2(0,height)],28)
 for i in range(14):
  var a := TAU*i/14
  _rod("ink",origin+Vector3(cos(a)*radius*.825,height*.91,sin(a)*radius*.825),origin+Vector3(cos(a)*radius*.825,height*.985,sin(a)*radius*.825),.0005,-1,5)
 # Paper inventory tag is readable from above, as on the reference specimens.
 _tag(origin+Vector3(-radius*.15,height+.001,0),.14,.5)

func _brush_pot(origin: Vector3) -> void:
 _lathe("enamel",origin,[Vector2(0,0),Vector2(.032,0),Vector2(.037,.007),Vector2(.041,.071),Vector2(.04,.079),Vector2(.034,.079),Vector2(.033,.020),Vector2(0,.020)],28)
 _lathe("green",origin,[Vector2(.0405,.071),Vector2(.0412,.073),Vector2(.0412,.077),Vector2(.039,.080)],28)
 for n in range(5):
  var x := -.018+n*.009
  var end := origin+Vector3(x*1.7,.135+.011*(n%3),.009*sin(n*2))
  var base := origin+Vector3(x,.025,0)
  _rod("wood",base,end,.0025,.003,9)
  var tip := end+(end-base).normalized()*.016
  _rod("brass",end,tip,.0038,-1,9)
  var finish := tip+(end-base).normalized()*.029
  _rod("paper",tip,finish,.005,.002,10)

func _plant(origin: Vector3) -> void:
 _lathe("clay",origin,[Vector2(0,0),Vector2(.034,0),Vector2(.049,.062),Vector2(.052,.064),Vector2(.052,.074),Vector2(.043,.074),Vector2(.043,.059)],28)
 _lathe("ink",origin,[Vector2(0,.060),Vector2(.043,.060)],24)
 for stem in range(7):
  var a := TAU*stem/7
  var end := origin+Vector3(cos(a)*.10,.11+float(stem%3)*.018,sin(a)*.095)
  var base := origin+Vector3(0,.06,0)
  _rod("leaf",base,end,.0015,.0007,6)
  for n in range(1,7):
   var t := float(n)/7
   var center := base.lerp(end,t)
   for side in [-1,1]:
    var lateral: Vector3 = Vector3(-sin(a),.12,cos(a))*side
    var tip: Vector3 = center+lateral*(.025*(1-t)+.011)+Vector3(cos(a),.15,sin(a))*.015
    var cross_axis := Vector3(cos(a),0,sin(a))*.006
    var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
    _triangle(st,center,tip+cross_axis,tip+Vector3(0,.003,0))
    _triangle(st,center,tip+Vector3(0,.003,0),tip-cross_axis)
    _triangle(st,center,tip+Vector3(0,.003,0),tip+cross_axis)
    _triangle(st,center,tip-cross_axis,tip+Vector3(0,.003,0))
    _append("leaf",st.commit(),Transform3D.IDENTITY,Color(.75+.05*n,.83+.02*n,.63+.04*n))

func _ruler(origin: Vector3) -> void:
 _box("wood",origin,Vector3(.316,.006,.031),.02,.001)
 for n in range(61):
  var x := origin.x-.147+n*.0049
  _box("ink",Vector3(x,origin.y+.0035,origin.z-.007),Vector3(.0007,.0002,.014 if n%10==0 else (.010 if n%5==0 else .006)),.02,0)
 for x in [-.136,.136]:
  _lathe("brass",origin+Vector3(x,.0036,0),[Vector2(0,0),Vector2(.002,0),Vector2(.002,.0004),Vector2(0,.0004)],10)

func _tag(origin: Vector3,angle: float,scale_value := 1.0) -> void:
 _box("paper",origin,Vector3(.123,.0015,.055)*scale_value,angle,.0003)
 _art(origin+Vector3(0,.001,0),Vector2(.119,.052)*scale_value,angle,2)

func _flush() -> void:
 for key: String in batches:
  var st: SurfaceTool = batches[key]
  st.index()
  var mesh := st.commit()
  var source := ImporterMesh.new()
  source.add_surface(Mesh.PRIMITIVE_TRIANGLES,mesh.surface_get_arrays(0),[],{},materials[key],key)
  source.generate_lods(25,60,[])
  var instance := MeshInstance3D.new()
  instance.name = "Atelier_"+key
  instance.mesh = source.get_mesh()
  instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if key.begins_with("lamp") else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
  add_child(instance)
  instance.owner = self
  triangle_count += mesh.surface_get_array_index_len(0)/3
  lod_counts[key] = source.get_surface_lod_count(0)
