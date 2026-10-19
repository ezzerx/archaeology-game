extends "res://scripts/workshop/polish/atelier_geometry.gd"
## Original cabinet-of-natural-history modules. Offline geometry authoring only.
## Shared opaque batches and generated mesh LODs; no runtime modelling.
var frame := Transform3D.IDENTITY

func _append(key: String,mesh: Mesh,transform: Transform3D,tint := Color.WHITE) -> void:
 super._append(key,mesh,frame*transform,tint)

func make(category: String) -> void:
 name = category
 _palette()
 match category:
  "architecture": _architecture()
  "furniture": _furniture()
  "collections": _collections()
  "garden": _garden()
 _flush()

func _gallery_material(key: String,color: String,kind: int,axis := 0) -> void:
 var mat := ShaderMaterial.new()
 mat.shader=preload("res://shaders/experiments/gallery_surface.gdshader")
 mat.set_shader_parameter("tint",Color(color))
 mat.set_shader_parameter("kind",kind)
 mat.set_shader_parameter("grain_axis",axis)
 materials[key]=mat

func _palette() -> void:
 _gallery_material("walnut","#483021",0)
 _gallery_material("walnut_long","#4c3324",0,1)
 _gallery_material("polished_edge","#654932",0,1)
 _gallery_material("dark_wood","#271d17",0)
 _gallery_material("bottle_green","#253a30",3)
 _gallery_material("brass","#96733c",2)
 _gallery_material("paper","#b8a987",3)
 _gallery_material("leather_red","#552e21",3)
 _gallery_material("leather_green","#223a2b",3)
 _gallery_material("leather_brown","#59432c",3)
 _gallery_material("rope","#49231e",3)
 _material("leaf",Color("#365321"),.43)
 _material("leaf_light",Color("#66743a"),.46)
 for key in ["leaf","leaf_light"]:
  materials[key].cull_mode=BaseMaterial3D.CULL_DISABLED
  materials[key].clearcoat_enabled=true
  materials[key].clearcoat=.18
  materials[key].clearcoat_roughness=.33
 _material("stem",Color("#39402a"),.88)
 _material("quartz",Color("#c7bd9f"),.19)
 _material("smoky_quartz",Color("#645763"),.22)
 for key in ["quartz","smoky_quartz"]:
  materials[key].clearcoat_enabled=true;materials[key].clearcoat=.65
  materials[key].clearcoat_roughness=.16
  materials[key].metallic_specular=.65
 _material("fossil",Color("#a58b5c"),.60)
 _material("soil",Color("#30291b"),1.0)
 for key in ["plaster","stone","floor","floor_alt"]:
  var mat:=ShaderMaterial.new()
  mat.shader=preload("res://shaders/experiments/gallery_masonry.gdshader")
  mat.set_shader_parameter("surface_texture",preload("res://assets/museum/materials/plaster.png") if key=="plaster" else preload("res://assets/museum/materials/limestone.png"))
  mat.set_shader_parameter("tint",Color(.86,.79,.66) if key in ["plaster","stone"] else (Color(.67,.63,.54) if key=="floor" else Color(.76,.71,.62)))
  mat.set_shader_parameter("horizontal",key.begins_with("floor"))
  mat.set_shader_parameter("meters",2.1)
  mat.set_shader_parameter("roughness_value",.83 if key.begins_with("floor") else .94)
  materials[key]=mat
 var print_mat:=StandardMaterial3D.new()
 print_mat.albedo_texture=preload("res://assets/museum/polish/natural_history_engraved.png")
 print_mat.albedo_color=Color(.66,.61,.51)
 print_mat.roughness=.95
 print_mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
 materials["illustrations"]=print_mat
 var rug:=StandardMaterial3D.new()
 rug.albedo_texture=preload("res://assets/museum/polish/heritage_rug_woven.png")
 rug.albedo_color=Color(.84,.80,.72)
 rug.roughness=1.0
 rug.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
 materials["rug"]=rug
 var glow:=StandardMaterial3D.new()
 glow.albedo_color=Color("#ffe7b8")
 glow.emission_enabled=true;glow.emission=Color("#ffe1a0");glow.emission_energy_multiplier=1.2
 materials["bulb"]=glow

func _moulded_panel(pos: Vector3,width: float,height: float,depth := .06) -> void:
 _box("walnut",pos,Vector3(width,height,depth),0,.012)
 var face:=pos+Vector3(0,0,depth*.5+.016)
 _box("dark_wood",face,Vector3(width-.11,height-.12,.018),0,.004)
 _box("walnut",face+Vector3(0,0,.015),Vector3(width-.19,height-.20,.026),0,.012)
 for x in [-1,1]:
  _box("polished_edge",face+Vector3(x*(width-.12)*.5,0,.020),Vector3(.025,height-.08,.035),0,.007)
 for y in [-1,1]:
  _box("polished_edge",face+Vector3(0,y*(height-.12)*.5,.020),Vector3(width-.10,.025,.035),0,.007)

func _arch(key: String,center: Vector3,inner_radius: float,outer_radius: float,depth: float,segments := 64) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(segments):
  var a:=PI*float(i)/segments;var b:=PI*float(i+1)/segments
  for side in [-1.,1.]:
   var z:float=side*depth*.5
   var p:=Vector3(cos(a)*inner_radius,sin(a)*inner_radius,z)
   var q:=Vector3(cos(a)*outer_radius,sin(a)*outer_radius,z)
   var r:=Vector3(cos(b)*outer_radius,sin(b)*outer_radius,z)
   var s:=Vector3(cos(b)*inner_radius,sin(b)*inner_radius,z)
   if side>0:_quad(st,p,q,r,s)
   else:_quad(st,p,s,r,q)
  for radius in [inner_radius,outer_radius]:
   var p:=Vector3(cos(a)*radius,sin(a)*radius,-depth*.5)
   var q:=Vector3(cos(b)*radius,sin(b)*radius,-depth*.5)
   var r:=q+Vector3(0,0,depth);var s:=p+Vector3(0,0,depth)
   if radius==inner_radius:_quad(st,p,s,r,q)
   else:_quad(st,p,q,r,s)
 _append(key,st.commit(),_pose(center))

func _spandrel(x: float,spring: float,radius: float,width: float,top: float,z: float) -> void:
 for side in [-1.,1.]:
  var points:=PackedVector2Array([Vector2(0,top),Vector2(side*width*.5,top),Vector2(side*width*.5,spring),Vector2(side*radius,spring)])
  for n in range(1,49):
   var angle:=PI*.5*float(n)/48
   points.append(Vector2(side*cos(angle)*radius,spring+sin(angle)*radius))
  var indices:=Geometry2D.triangulate_polygon(points)
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for i in range(0,indices.size(),3):
   var a:=points[indices[i]];var b:=points[indices[i+1]];var c:=points[indices[i+2]]
   if (b-a).cross(c-a)>0:_triangle(st,Vector3(a.x,a.y,0),Vector3(b.x,b.y,0),Vector3(c.x,c.y,0))
   else:_triangle(st,Vector3(a.x,a.y,0),Vector3(c.x,c.y,0),Vector3(b.x,b.y,0))
  _append("plaster",st.commit(),_pose(Vector3(x,0,z)))

func _architecture() -> void:
 # Single batch per stone family: physical shallow joints without 180 draw calls.
 _box("dark_wood",Vector3(0,-.10,0),Vector3(13,.16,9),0,.01)
 for z in range(12):
  for x in range(17):
   var shift:=.375 if z%2 else 0.0
   _box("floor_alt" if (x+z*3)%5==0 else "floor",Vector3((x-8)*.76+shift,-.025,(z-5.5)*.75),Vector3(.752,.05,.742),0,.005)
 # Continuous back plane and real 70 cm deep openings at the front elevation.
 _box("plaster",Vector3(-5.95,2.12,-2.80),Vector3(.80,4.24,.18),0,.012)
 _box("plaster",Vector3(1.20,2.12,-2.80),Vector3(10.30,4.24,.18),0,.012)
 _box("plaster",Vector3(-4.75,.55,-2.80),Vector3(1.60,1.10,.18),0,.012)
 _box("plaster",Vector3(-4.75,3.79,-2.80),Vector3(1.60,.90,.18),0,.012)
 _box("plaster",Vector3(0,.55,-2.33),Vector3(12.7,1.10,.75),0,.015)
 _box("plaster",Vector3(0,3.745,-2.33),Vector3(12.7,.99,.75),0,.015)
 for data in [[-5.90,.90],[-3.73,.64],[-1.58,.62],[1.58,.62],[4.88,2.94]]:
  _box("plaster",Vector3(data[0],2.18,-2.33),Vector3(data[1],2.16,.75),0,.012)
 _box("plaster",Vector3(0,2.18,-2.64),Vector3(2.54,2.16,.18),0,.012)
 for x in [-2.65,2.65]:
  _spandrel(x,2.35,.76,1.52,3.34,-1.947)
  _box("bottle_green",Vector3(x,2.11,-2.67),Vector3(1.57,1.98,.055),0,.008)
  _arch("stone",Vector3(x,2.35,-1.92),.76,.95,.20)
  _arch("plaster",Vector3(x,2.35,-1.805),.80,.88,.045)
  for side in [-1,1]:
   _box("stone",Vector3(x+side*.855,1.73,-1.92),Vector3(.19,1.25,.20),0,.014)
   _box("plaster",Vector3(x+side*.855,2.345,-1.90),Vector3(.27,.085,.26),0,.017)
   _box("stone",Vector3(x+side*.855,2.285,-1.92),Vector3(.23,.045,.22),0,.012)
   _box("plaster",Vector3(x+side*.855,1.135,-1.91),Vector3(.27,.09,.27),0,.012)
  for shelf_y in [1.14,1.78,2.43]:
   _box("walnut_long",Vector3(x,shelf_y,-2.25),Vector3(1.54,.075,.73),0,.022)
   _box("polished_edge",Vector3(x,shelf_y-.038,-1.87),Vector3(1.61,.045,.065),0,.010)
  _moulded_panel(Vector3(x,.565,-1.92),1.72,1.05,.15)
 # Wainscot lower band, recessed walnut panels with small arrises.
 for i in range(18):
  var x:float=-6.0+i*.70
  if absf(absf(x)-2.65)<.85:continue
  _moulded_panel(Vector3(x,.54,-1.96),.69,1.02,.15)
 for y in [.065,.99,1.055]:
  _box("walnut_long",Vector3(0,y,-1.90),Vector3(12.6,.07,.23),0,.014)
 for y in [3.95,4.04,4.13]:
  _box("stone" if y==4.04 else "plaster",Vector3(0,y,-1.91),Vector3(12.6,.075,.24+(y-3.95)*.6),0,.020)
 # Window opening and timber tracery: warm courtyard is entirely behind it.
 var wx:=-4.75
 _spandrel(wx,2.54,.70,1.40,3.34,-1.947)
 _arch("stone",Vector3(wx,2.54,-1.92),.70,.86,.22)
 _arch("walnut",Vector3(wx,2.54,-2.06),.62,.70,.13)
 for side in [-1,1]:
  _box("stone",Vector3(wx+side*.78,1.82,-1.92),Vector3(.16,1.44,.23),0,.015)
  _box("walnut",Vector3(wx+side*.65,1.82,-2.06),Vector3(.09,1.44,.13),0,.009)
 _box("stone",Vector3(wx,1.08,-1.86),Vector3(1.81,.12,.55),0,.022)
 _box("walnut",Vector3(wx,2.10,-2.06),Vector3(.065,2.04,.14),0,.009)
 for y in [1.14,1.82,2.48]:
  _box("walnut_long",Vector3(wx,y,-2.055),Vector3(1.32,.065,.14),0,.008)

func _furniture() -> void:
 # Tall double-door cabinet: rails, backs and shelf spaces are independent solids.
 _box("dark_wood",Vector3(0,2.10,-2.17),Vector3(2.31,2.14,.08),0,.012)
 _box("walnut",Vector3(0,2.12,-2.115),Vector3(2.10,1.95,.02),0,.003)
 for x in range(8):
  _box("dark_wood",Vector3(-.92+x*.26,2.12,-2.099),Vector3(.007,1.95,.004),0,0)
 for x in [-1.16,1.16]:
  _box("walnut",Vector3(x,2.12,-1.84),Vector3(.12,2.18,.65),0,.021)
 for y in [1.10,1.80,2.42,3.03]:
  _box("walnut_long",Vector3(0,y,-1.84),Vector3(2.30,.065,.63),0,.016)
  _box("polished_edge",Vector3(0,y-.028,-1.50),Vector3(2.34,.04,.09),0,.01)
 # Cabinet crown uses a stepped profile and broad top lip, not a rounded box lid.
 for data in [[3.10,2.40,.09,.71],[3.18,2.51,.08,.78],[3.245,2.56,.045,.81],[1.04,2.48,.10,.77]]:
  _box("polished_edge",Vector3(0,data[0],-1.84),Vector3(data[1],data[2],data[3]),0,.018)
 for x in [-.555,.555]:
  for side in [-1,1]:
   _box("walnut",Vector3(x+side*.49,2.09,-1.48),Vector3(.065,1.99,.075),0,.009)
  for y in [1.12,3.065]:
   _box("walnut_long",Vector3(x,y,-1.48),Vector3(1.04,.07,.075),0,.009)
  _rod("brass",Vector3(x-signf(x)*.40,2.04,-1.43),Vector3(x-signf(x)*.40,2.04,-1.38),.018,-1,14)
  for y in [1.45,2.70]:
   _box("brass",Vector3(x+signf(x)*.505,y,-1.43),Vector3(.028,.095,.022),0,.004)
 for x in [-.62,.62]:
  _moulded_panel(Vector3(x,.56,-1.52),1.20,.88,.10)
  _rod("brass",Vector3(x-signf(x)*.46,.75,-1.44),Vector3(x-signf(x)*.46,.75,-1.40),.018,-1,12)
 _box("walnut_long",Vector3(0,.095,-1.84),Vector3(2.47,.14,.78),0,.018)
 _plinth_skirting(Vector3(-1.65,0,.06),Vector2(3.05,2.18),.3847)
 _plinth_skirting(Vector3(1.62,0,.06),Vector2(2.10,2.16),.3075)
 # Leather bench under the window, turned brass feet and stitched cushion grid.
 _bench(Vector3(-4.70,0,-1.30),2.06)
 # Wall lamps in the same positions as the shader developer's light sources.
 for x in [-3.78,-1.40,1.40,3.78]:_sconce(Vector3(x,2.75,-1.72))
 # An original woven ornamental rug gives the plinths a coherent floor territory.
 _box("rope",Vector3(-.2,.008,.45),Vector3(7.30,.014,3.66),0,.007)
 _floor_art("rug",Vector3(-.2,.017,.45),Vector2(7.26,3.62))
 for x in range(90):
  var px:=-3.80+x*.081
  for z in [-1.40,2.30]:_rod("paper",Vector3(px,.015,z),Vector3(px+.008,.013,z+.085),.004,-1,5)
 _barrier()
 # Artwork reads as physical printmaking, with layered wood/brass frames.
 _frame(Vector3(-3.78,1.90,-1.84),Vector2(.46,.84),0)
 _frame(Vector3(4.05,1.96,-1.84),Vector2(.70,.93),1)

func _plinth_skirting(center: Vector3,size: Vector2,height: float) -> void:
 # Thin cabinet-making veneer over the existing supports; no mounting changes.
 var mid_y:=(height+.06)*.5
 frame=_pose(center+Vector3(0,mid_y,(size.y-.13)*.5+.008))
 _low_panel(size.x-.17,height-.075)
 for side in [-1.,1.]:
  frame=_pose(center+Vector3(side*(size.x-.13)*.5,mid_y,0),side*PI*.5)
  _low_panel(size.y-.17,height-.075)
 frame=Transform3D.IDENTITY

func _low_panel(width: float,height: float) -> void:
 _box("walnut_long",Vector3.ZERO,Vector3(width,height,.016),0,.004)
 _box("dark_wood",Vector3(0,0,.012),Vector3(width-.075,height-.050,.008),0,.003)
 _box("walnut_long",Vector3(0,0,.019),Vector3(width-.12,height-.090,.010),0,.005)
 for y in [-1.,1.]:
  _box("polished_edge",Vector3(0,y*(height-.029)*.5,.020),Vector3(width-.020,.020,.026),0,.005)
 for x in [-1.,1.]:
  _box("polished_edge",Vector3(x*(width-.030)*.5,0,.020),Vector3(.020,height-.020,.026),0,.005)

func _bench(origin: Vector3,width: float) -> void:
 for x in [-width*.42,width*.42]:
  for z in [-.21,.21]:
   _lathe("walnut",origin+Vector3(x,0,z),[Vector2(.035,0),Vector2(.048,.045),Vector2(.035,.09),Vector2(.029,.30),Vector2(.048,.40),Vector2(.044,.46)],18)
 _box("walnut_long",origin+Vector3(0,.43,0),Vector3(width,.12,.60),0,.022)
 _box("leather_red",origin+Vector3(0,.525,0),Vector3(width-.07,.13,.57),0,.045)
 for x in range(12):
  var px:=-width*.45+x*width*.0818
  _rod("brass",origin+Vector3(px,.525,.286),origin+Vector3(px,.526,.292),.009,-1,8)
 for x in range(7):
  for z in [-.17,.0,.17]:
   _lathe("dark_wood",origin+Vector3(-width*.42+x*width*.14,.591,z),[Vector2(.010,0),Vector2(.009,.001),Vector2(0,.002)],10)

func _sconce(origin: Vector3) -> void:
 frame=_pose(origin)
 var p:=CylinderMesh.new();p.top_radius=.105;p.bottom_radius=.105;p.height=.035;p.radial_segments=28
 _append("brass",p,Transform3D(Basis(Vector3.RIGHT,PI*.5),Vector3.ZERO))
 _rod("brass",Vector3(0,0,.025),Vector3(0,.04,.15),.025,-1,16)
 _rod("brass",Vector3(0,.04,.15),Vector3(0,-.04,.25),.025,-1,16)
 _lathe("brass",Vector3(0,-.04,.25),[Vector2(.035,0),Vector2(.049,-.04),Vector2(.076,-.10),Vector2(.13,-.18),Vector2(.158,-.23),Vector2(.159,-.25),Vector2(.146,-.25),Vector2(.115,-.205),Vector2(.06,-.12)],32)
 _lathe("bulb",Vector3(0,-.293,.25),[Vector2(.145,0),Vector2(.149,.002),Vector2(.149,.005),Vector2(.140,.008)],32)
 var bulb:=SphereMesh.new();bulb.radius=.045;bulb.height=.064;bulb.radial_segments=24;bulb.rings=12
 _append("bulb",bulb,_pose(Vector3(0,-.329,.25)))
 frame=Transform3D.IDENTITY

func _barrier() -> void:
 var xs:=[-3.47,.14,3.02]
 for x in xs:
  _lathe("brass",Vector3(x,0,1.67),[Vector2(0,0),Vector2(.14,0),Vector2(.15,.035),Vector2(.125,.07),Vector2(.09,.09),Vector2(.055,.12),Vector2(.035,.19),Vector2(.028,.70),Vector2(.055,.75),Vector2(.055,.79),Vector2(.028,.82),Vector2(0,.84)],24)
 for segment in range(2):
  for strand in range(3):
   for i in range(48):
    var t0:=float(i)/48;var t1:=float(i+1)/48
    var a:=Vector3(lerpf(xs[segment],xs[segment+1],t0),.77-.19*sin(t0*PI),1.67)
    var b:=Vector3(lerpf(xs[segment],xs[segment+1],t1),.77-.19*sin(t1*PI),1.67)
    var ph0:=t0*TAU*12+strand*TAU/3;var ph1:=t1*TAU*12+strand*TAU/3
    a+=Vector3(0,cos(ph0),sin(ph0))*.009;b+=Vector3(0,cos(ph1),sin(ph1))*.009
    _rod("rope",a,b,.009,-1,6)

func _floor_art(key: String,pos: Vector3,size: Vector2) -> void:
 var plane:=PlaneMesh.new();plane.size=size
 _append(key,plane,_pose(pos))

func _frame(origin: Vector3,size: Vector2,tile: int) -> void:
 _box("dark_wood",origin,Vector3(size.x+.08,size.y+.08,.055),0,.012)
 _box("brass",origin+Vector3(0,0,.031),Vector3(size.x+.034,size.y+.034,.014),0,.004)
 _box("paper",origin+Vector3(0,0,.042),Vector3(size.x,size.y,.018),0,.003)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var uv:=Vector2(float(tile%2)*.5,float(tile/2)*.5)
 var a:=Vector3(-size.x*.46,-size.y*.46,0);var b:=Vector3(size.x*.46,-size.y*.46,0)
 var c:=Vector3(size.x*.46,size.y*.46,0);var d:=Vector3(-size.x*.46,size.y*.46,0)
 _triangle(st,a,b,c,uv+Vector2(0,.5),uv+Vector2(.5,.5),uv+Vector2(.5,0))
 _triangle(st,a,c,d,uv+Vector2(0,.5),uv+Vector2(.5,0),uv)
 _append("illustrations",st.commit(),_pose(origin+Vector3(0,0,.055)))

func _collections() -> void:
 _book_row(Vector3(-3.30,1.82,-2.12),5,.40)
 _book_row(Vector3(-3.29,2.47,-2.26),5,.39)
 _book_row(Vector3(2.09,2.47,-2.26),3,.28)
 _book_row(Vector3(-.94,1.14,-1.85),5,.46)
 _book_row(Vector3(.17,1.84,-1.86),5,.39)
 _book_stack(Vector3(-.58,1.84,-1.87),3)
 _book_stack(Vector3(-.47,3.28,-1.88),4)
 _book_stack(Vector3(2.80,1.82,-2.15),2)
 _book_stack(Vector3(.67,1.14,-1.86),2)
 _book_stack(Vector3(3.03,2.47,-2.17),2)
 _shell(Vector3(-2.28,2.48,-2.06),.245)
 _shell(Vector3(.62,1.26,-1.78),.20)
 _shell(Vector3(2.26,1.82,-2.10),.19)
 _mineral_cluster(Vector3(2.98,2.61,-2.16),.29,false)
 _mineral_cluster(Vector3(-2.26,1.82,-2.16),.28,true)
 _mineral_cluster(Vector3(.55,2.46,-1.85),.34,false)
 _mineral_cluster(Vector3(.18,3.28,-1.86),.23,true)
 _cabinet_skull(Vector3(-.58,2.48,-1.88))
 _frame(Vector3(.07,3.58,-1.77),Vector2(.44,.58),2)
 _armillary(Vector3(.78,3.28,-1.82))
 _magnifier(Vector3(3.00,1.82,-1.94),.11)
 _specimen_tag(Vector3(-2.30,2.475,-1.94),.24)
 _specimen_tag(Vector3(.50,2.465,-1.57),.20)
 _specimen_tag(Vector3(-.60,1.845,-1.57),.23)
 _plant_urn(Vector3(-3.95,0,-.84),.95,false)
 _plant_urn(Vector3(4.12,0,-.90),1.10,true)
 _small_ivy_pot(Vector3(-3.25,2.47,-1.98),.95)
 _ivy(Vector3(-3.28,2.72,-1.85),1.30)
 _small_ivy_pot(Vector3(2.14,2.47,-1.98),1.05)
 _ivy(Vector3(2.13,2.72,-1.85),1.30)
 _small_ivy_pot(Vector3(-.91,3.27,-1.76),.95)
 _ivy(Vector3(-.91,3.51,-1.66),.80)
 for p in [Vector3(-.78,1.145,-1.57),Vector3(.47,1.845,-1.57),Vector3(-.77,2.465,-1.57)]:_specimen_tag(p,.18)

func _cabinet_skull(origin: Vector3) -> void:
 # A separate catalogue replica uses the existing raw sculpt, with no prepared data.
 var source:Node3D=preload("res://assets/p6a32/b17_tripo_skull.glb").instantiate()
 var bounds:=AABB();var first:=true
 for instance:MeshInstance3D in source.find_children("*","MeshInstance3D",true,false):
  var xf:=_asset_transform(source,instance)
  var bb:AABB=xf*instance.mesh.get_aabb()
  bounds=bb if first else bounds.merge(bb);first=false
 var fit:=.64/maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z))
 var offset:=-bounds.get_center();offset.y=-bounds.position.y
 var placement:=Transform3D(Basis(Vector3.UP,-.22).scaled(Vector3.ONE*fit),origin+Vector3(0,.08,0))
 placement.origin+=placement.basis*offset
 for instance:MeshInstance3D in source.find_children("*","MeshInstance3D",true,false):
  for surface in range(instance.mesh.get_surface_count()):
   var arrays:=instance.mesh.surface_get_arrays(surface)
   var opt:=ImporterMesh.new();opt.add_surface(Mesh.PRIMITIVE_TRIANGLES,arrays);opt.generate_lods(25,60,[])
   if opt.get_surface_lod_count(0)>0:
    arrays[Mesh.ARRAY_INDEX]=opt.get_surface_lod_indices(0,opt.get_surface_lod_count(0)-1)
   for lod in range(opt.get_surface_lod_count(0)):
    var indices:=opt.get_surface_lod_indices(0,lod)
    if indices.size()/3>4200:continue
    arrays[Mesh.ARRAY_INDEX]=indices;break
   var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
   _append("fossil",mesh,placement*_asset_transform(source,instance))
 source.free()
 _box("dark_wood",origin+Vector3(0,.015,0),Vector3(.50,.03,.24),0,.009)
 for x in [-.16,.16]:_rod("brass",origin+Vector3(x,.03,0),origin+Vector3(x,.13,0),.010,-1,12)

func _asset_transform(root_node: Node3D,node: Node3D) -> Transform3D:
 var transform:=node.transform
 var parent_node:=node.get_parent()
 while parent_node!=root_node and parent_node is Node3D:
  transform=parent_node.transform*transform;parent_node=parent_node.get_parent()
 return transform

func _book_row(origin: Vector3,count: int,height: float) -> void:
 var offset:=0.0
 for i in range(count):
  var width:=.088+float((i*7)%5)*.015
  _book(origin+Vector3(offset,0,0),width,height*(.83+float((i*3)%5)*.055),.25,i)
  offset+=width+.014

func _book(origin: Vector3,width: float,height: float,depth: float,variant: int) -> void:
 var leather:String=["leather_green","leather_brown","leather_red"][variant%3]
 _box("paper",origin+Vector3(0,height*.5,0),Vector3(width-.013,height-.018,depth-.020),0,.005)
 for x in [-width*.5,width*.5]:
  _box(leather,origin+Vector3(x,height*.5,0),Vector3(.010,height,depth),0,.004)
 _box(leather,origin+Vector3(0,height*.5,depth*.5),Vector3(width+.008,height,.019),0,.006)
 for y in [.026,.066,height-.030,height-.070]:
  _box(leather,origin+Vector3(0,y,depth*.5+.014),Vector3(width+.012,.012,.010),0,.004)
 for y in [.033,.072,height-.023,height-.063]:
  _box("brass",origin+Vector3(0,y,depth*.5+.012),Vector3(width-.012,.006,.005),0,.001)
 for page in range(7):
  _box("paper",origin+Vector3(0,height*.5,-depth*.5+.010+page*.034),Vector3(width-.010,height-.020,.0012),0,0)
 _box("brass",origin+Vector3(0,height*.62,depth*.5+.012),Vector3(width*.66,.048,.002),0,.001)
 _box(leather,origin+Vector3(0,height*.62,depth*.5+.014),Vector3(width*.57,.037,.002),0,.001)
 for y in [.15,.168,.186]:
  if y<height-.06:_box("brass",origin+Vector3(0,y,depth*.5+.013),Vector3(width*.38,.002,.003),0,.0004)

func _book_stack(origin: Vector3,count: int) -> void:
 for i in range(count):
  frame=_pose(origin+Vector3(0,.055*i,0),.07*(i-1))
  _box("leather_red" if i%2 else "leather_green",Vector3(0,.008,0),Vector3(.43,.016,.29),0,.005)
  _box("paper",Vector3(0,.032,0),Vector3(.41,.036,.274),0,.004)
  _box("leather_red" if i%2 else "leather_green",Vector3(0,.055,0),Vector3(.43,.012,.29),0,.004)
  _box("leather_red" if i%2 else "leather_green",Vector3(0,.03,.14),Vector3(.43,.05,.016),0,.006)
  for x in [-.16,.16]:_box("brass",Vector3(x,.03,.150),Vector3(.008,.04,.005),0,.001)
 frame=Transform3D.IDENTITY

func _mineral_cluster(origin: Vector3,size: float,smoky: bool) -> void:
 _box("dark_wood",origin+Vector3(0,.012,0),Vector3(size*1.2,.025,size*.9),0,.01)
 # Irregular clusters grow from a rocky matrix; each prism has its own axis.
 var stone:=SphereMesh.new();stone.radius=size*.43;stone.height=size*.23;stone.radial_segments=13;stone.rings=5
 _append("fossil",stone,_pose(origin+Vector3(0,size*.10,0)),Color(.62,.60,.55))
 for i in range(19):
  var theta:=i*2.399
  var r:=size*.30*sqrt(float(i)/18.0)
  var height:=size*(1.01-.57*float(i)/18.0)*(1.0+.15*sin(i*5.1))
  var radius:=size*(.115-float(i%4)*.012)
  var center:=origin+Vector3(cos(theta)*r,.04,sin(theta)*r*.70)
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  var angle:=theta*.31
  var tip:=Vector3(radius*.14,height,radius*.05)
  for j in range(6):
   var a:=TAU*j/6+angle;var b:=TAU*(j+1)/6+angle
   var p:=Vector3(cos(a)*radius,0,sin(a)*radius)
   var q:=Vector3(cos(b)*radius,0,sin(b)*radius)
   var u:=Vector3(q.x,height*(.73+.035*sin(j*2.1)),q.z)
   var v:=Vector3(p.x,height*(.73+.035*sin((j-1)*2.1)),p.z)
   _quad(st,p,v,u,q);_triangle(st,v,tip,u)
  var tilt:=Basis.from_euler(Vector3(sin(theta)*.34,theta,cos(theta)*.29))
  var variation:=.82+.18*sin(float(i)*1.7)
  _append("smoky_quartz" if smoky else "quartz",st.commit(),Transform3D(tilt,center),Color(variation,variation*.98,variation*.92))

func _shell_point(angle: float,cross_angle: float,radius: float) -> Vector3:
 var r:=radius*.67*exp(.17*(angle-TAU*2.7))
 var tube:=r*.493*(1.0+.075*pow(.5+.5*cos(angle*37.0),5.0))
 var radial:=Vector3(cos(angle),sin(angle),0)
 return radial*(r+tube*cos(cross_angle))+Vector3(0,0,tube*.86*sin(cross_angle))

func _shell(origin: Vector3,radius: float) -> void:
 # Joined logarithmic whorls, true ribbed volume and an inset aperture.
 _box("dark_wood",origin+Vector3(0,.015,0),Vector3(radius*1.30,.03,radius*.80),0,.009)
 _rod("brass",origin+Vector3(0,.03,0),origin+Vector3(0,radius*.52,0),.013,-1,16)
 var center:=origin+Vector3(0,radius+.045,.020)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var steps:=288;var sides:=20
 for n in range(steps):
  var a:=TAU*2.7*float(n)/steps;var b:=TAU*2.7*float(n+1)/steps
  for j in range(sides):
   var u:=TAU*float(j)/sides;var v:=TAU*float(j+1)/sides
   _quad(st,_shell_point(a,u,radius),_shell_point(b,u,radius),_shell_point(b,v,radius),_shell_point(a,v,radius))
 st.index();st.generate_normals()
 _append("fossil",st.commit(),_pose(center,-.14))
 # The terminal cross section is recessed, so the shell reads as hollow at its mouth.
 var angle:=TAU*2.7;var r:=radius*.67
 var end:=center+Vector3(cos(angle),sin(angle),0)*r
 var cap:=CylinderMesh.new();cap.top_radius=r*.41;cap.bottom_radius=r*.41;cap.height=.007;cap.radial_segments=24
 var axis:=Vector3(-sin(angle),cos(angle),0)
 var cross_axis:=Vector3(0,0,1)
 _append("dark_wood",cap,Transform3D(Basis(cross_axis,axis,cross_axis.cross(axis)),end))

func _specimen_tag(origin: Vector3,width: float) -> void:
 _box("paper",origin+Vector3(0,.025,.015),Vector3(width,.052,.008),0,.002)
 for i in range(3):_box("dark_wood",origin+Vector3(-width*.08,.038-i*.012,.020),Vector3(width*(.65-.11*i),.002,.001),0,0)

func _torus(key: String,origin: Vector3,radius: float,thickness: float,rotation: Vector3) -> void:
 var mesh:=TorusMesh.new();mesh.inner_radius=radius-thickness;mesh.outer_radius=radius+thickness
 mesh.rings=40;mesh.ring_segments=8
 _append(key,mesh,Transform3D(Basis.from_euler(rotation),origin))

func _armillary(origin: Vector3) -> void:
 _lathe("brass",origin,[Vector2(0,0),Vector2(.12,0),Vector2(.13,.025),Vector2(.10,.05),Vector2(.045,.08),Vector2(.025,.16),Vector2(.05,.19)],24)
 var center:=origin+Vector3(0,.39,0)
 _torus("brass",center,.225,.009,Vector3(PI*.5,0,.3))
 _torus("brass",center,.202,.007,Vector3(.3,.2,.7))
 _torus("brass",center,.193,.007,Vector3(.8,.8,.1))
 _rod("brass",center+Vector3(-.09,-.24,0),center+Vector3(.09,.24,0),.008,-1,10)
 var sphere:=SphereMesh.new();sphere.radius=.045;sphere.height=.09;sphere.radial_segments=16;sphere.rings=8
 _append("brass",sphere,_pose(center))

func _magnifier(origin: Vector3,radius: float) -> void:
 _box("dark_wood",origin+Vector3(0,.015,0),Vector3(.18,.03,.11),0,.006)
 _rod("brass",origin+Vector3(0,.03,0),origin+Vector3(0,.17,0),.013,-1,12)
 _torus("brass",origin+Vector3(0,.25,0),radius,.009,Vector3(PI*.5,0,0))

func _leaf_point(base: Vector3,tip: Vector3,width: float,t: float,v: float,lobed: bool) -> Vector3:
 var direction:=(tip-base).normalized()
 var side:=direction.cross(Vector3.UP).normalized()
 if side.length_squared()<.01:side=Vector3.RIGHT
 var normal:=side.cross(direction).normalized()
 var silhouette:=pow(sin(PI*t),.67)
 if lobed:silhouette*=.80+.20*cos(t*PI*5.0)
 var center:=base.lerp(tip,t)+normal*sin(t*PI)*width*.47
 return center+side*(v*width*silhouette)+normal*(absf(v)*absf(v)*width*.26*sin(t*PI))

func _leaf(base: Vector3,tip: Vector3,width: float,key: String,lobed := false,detailed := true) -> void:
 # Smooth curved blade with rolled edges: no billboard, no triangular silhouette.
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rows:=8 if detailed else 6;var columns:=4 if detailed else 2
 for row in range(rows):
  var t:=float(row)/rows;var nt:=float(row+1)/rows
  for column in range(columns):
   var v:float=-1.0+2.0*float(column)/columns;var nv:float=-1.0+2.0*float(column+1)/columns
   _quad(st,_leaf_point(base,tip,width,t,v,lobed),_leaf_point(base,tip,width,t,nv,lobed),_leaf_point(base,tip,width,nt,nv,lobed),_leaf_point(base,tip,width,nt,v,lobed))
 st.index();st.generate_normals()
 _append(key,st.commit(),Transform3D.IDENTITY,Color(.85+.15*absf(sin(base.x*17+base.y)),.94,.78))
 # Raised central vein follows the leaf, catching one narrow highlight.
 if width>.045 and detailed:
  var previous:=base
  for step in range(1,4):
   var point:=_leaf_point(base,tip,width,float(step)/3,0,lobed)+Vector3(0,.0015,0)
   _rod("leaf_light",previous,point,.0017,-1,4);previous=point

func _plant_urn(origin: Vector3,size: float,fern: bool) -> void:
 frame=Transform3D(Basis.from_scale(Vector3.ONE*size),origin)
 _lathe("stone",Vector3.ZERO,[Vector2(0,0),Vector2(.18,0),Vector2(.20,.04),Vector2(.16,.08),Vector2(.11,.11),Vector2(.10,.18),Vector2(.20,.25),Vector2(.25,.40),Vector2(.24,.48),Vector2(.28,.50),Vector2(.28,.54),Vector2(.22,.54),Vector2(.21,.46)],40)
 _lathe("soil",Vector3.ZERO,[Vector2(0,.47),Vector2(.215,.47)],32)
 for i in range(16):
  var a:=TAU*i/16
  _rod("stone",Vector3(cos(a)*.13,.18,sin(a)*.13),Vector3(cos(a)*.235,.43,sin(a)*.235),.012,.018,8)
 if fern:
  for stem in range(17):
   var angle:=stem*2.399
   var a:=Vector3(0,.49,0);var end:=Vector3(cos(angle)*(.52+.15*sin(stem)),.91+float(stem%4)*.07,sin(angle)*.54)
   var previous:=a
   for step in range(1,13):
    var t:=float(step)/12
    var point:=a.lerp(end,t)+Vector3(0,sin(t*PI)*.28,0)
    _rod("stem",previous,point,.006*(1-t*.7),-1,6)
    for side in [-1,1]:
     var lateral:Vector3=Vector3(-sin(angle),.12,cos(angle))*side
     var leaf_tip:Vector3=point+lateral*(.19*(1-t)+.040)+Vector3(cos(angle),0,sin(angle))*.08
     _leaf(point,leaf_tip,.025*(1-t)+.008,"leaf_light" if (stem+step)%7==0 else "leaf")
    previous=point
 else:
  # Broad glossy laurel leaves distinguish this urn from the fine fern opposite.
  for stem in range(14):
   var angle:=stem*2.399;var reach:=.22+.12*float(stem%3)
   var end:=Vector3(cos(angle)*reach,.90+float(stem%4)*.12,sin(angle)*reach)
   var base:=Vector3(0,.49,0);var previous:=base
   for step in range(1,7):
    var t:=float(step)/6;var point:=base.lerp(end,t)+Vector3(0,sin(t*PI)*.15,0)
    _rod("stem",previous,point,.008*(1-t*.4),-1,7)
    if step>2:
     var lateral:=Vector3(cos(angle+.6*float(step%2)),.12,sin(angle+.6*float(step%2)))
     var leaf_end:=point+lateral*(.20+.055*float(step%3))-Vector3(0,.055,0)
     _leaf(point,leaf_end,.065+.012*float(step%3),"leaf_light" if (stem+step)%6==0 else "leaf")
    previous=point
 frame=Transform3D.IDENTITY

func _small_ivy_pot(origin: Vector3,size: float) -> void:
 frame=Transform3D(Basis.from_scale(Vector3.ONE*size),origin)
 _lathe("leather_brown",Vector3.ZERO,[Vector2(0,0),Vector2(.080,0),Vector2(.086,.025),Vector2(.116,.185),Vector2(.127,.192),Vector2(.129,.215),Vector2(.114,.225),Vector2(.107,.192)],28)
 _lathe("soil",Vector3.ZERO,[Vector2(0,.194),Vector2(.108,.194)],24)
 _lathe("brass",Vector3.ZERO,[Vector2(.128,.198),Vector2(.131,.201),Vector2(.131,.205),Vector2(.128,.208)],28)
 for i in range(13):
  var angle:=i*2.399;var base:=Vector3(0,.19,0)
  var stem_tip:=Vector3(cos(angle)*.06,.28+float(i%3)*.018,sin(angle)*.06)
  _rod("stem",base,stem_tip,.003,-1,5)
  _leaf(stem_tip,stem_tip+Vector3(cos(angle)*.17,.015,sin(angle)*.17),.063,"leaf_light" if i%4==0 else "leaf",true)
 frame=Transform3D.IDENTITY

func _ivy(origin: Vector3,length: float) -> void:
 for strand in range(5):
  var previous:=origin+Vector3(strand*.055,0,0)
  var drop:=length*(.75+.25*sin(strand*2.1+.4))
  for i in range(15):
   var t:=float(i+1)/15
   var point:=origin+Vector3(sin(t*8+strand)*.14+strand*.06,-drop*t,.07+sin(t*3)*.08)
   _rod("stem",previous,point,.006*(1-t*.6),-1,6)
   var side:=1.0 if i%2 else -1.0
   _leaf(point,point+Vector3(side*(.11+.025*sin(i*2)), -.09,.05),.067,"leaf_light" if (i+strand)%5==0 else "leaf",true)
   previous=point

func _garden() -> void:
 var sky:=QuadMesh.new();sky.size=Vector2(10,6)
 var sky_mat:=ShaderMaterial.new();sky_mat.shader=preload("res://shaders/experiments/gallery_window.gdshader")
 materials["sky"]=sky_mat
 _append("sky",sky,_pose(Vector3(-4.75,2.1,-6)))
 for n in range(5):
  var x:=-6.4+float(n)*.82
  var z:=-4.6-float(n%2)*.3
  _rod("walnut",Vector3(x,.4,z),Vector3(x+.16,2.8,z),.06,.035,10)
  for branch in range(5):
   var a:=Vector3(x+.1,1.0+branch*.31,z)
   var b:=a+Vector3((-.65 if branch%2 else .65),.45,-.02)
   _rod("walnut",a,b,.025,.009,7)
   for leaf in range(12):
    var t:=float(leaf)/12
    var p:=a.lerp(b,t)
    _leaf(p,p+Vector3(.14*(1 if leaf%2 else -1),.11,.04),.10,"leaf_light" if (leaf+n)%3==0 else "leaf",false,false)


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
   _quad(st,rings[r][j],rings[r+1][j],rings[r+1][k],rings[r][k])
 for j in range(1,7):
  _triangle(st,rings[3][0],rings[3][j+1],rings[3][j])
  _triangle(st,rings[0][0],rings[0][j],rings[0][j+1])
 _append(key,st.commit(),_pose(position,angle),tint)


func _lathe(key: String, position: Vector3, profile: Array, segments := 24, angle := 0.0) -> void:
 var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for r in range(profile.size()-1):
  var p: Vector2 = profile[r]; var q: Vector2 = profile[r+1]
  for j in range(segments):
   var a := TAU*float(j)/segments; var b := TAU*float(j+1)/segments
   _quad(st,Vector3(cos(a)*p.x,p.y,sin(a)*p.x),Vector3(cos(a)*q.x,q.y,sin(a)*q.x),Vector3(cos(b)*q.x,q.y,sin(b)*q.x),Vector3(cos(b)*p.x,p.y,sin(b)*p.x))
 _append(key,st.commit(),_pose(position,angle))




func _triangle(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv_a := Vector2.ZERO,uv_b := Vector2.RIGHT,uv_c := Vector2.ONE) -> void:
 var cross_product:=(b-a).cross(c-a)
 if cross_product.length_squared()<0.00000000000001:return
 st.set_normal(cross_product.normalized())
 st.set_uv(uv_a);st.add_vertex(a)
 st.set_uv(uv_c);st.add_vertex(c)
 st.set_uv(uv_b);st.add_vertex(b)
