extends "res://scripts/p6a43/fractured_slab.gd"
var mesh_points: Array[Vector2i] = []
var mesh_quads: Array[Dictionary] = []
var point_owner := PackedInt32Array()
var mesh_cache_builds := 0
var cached_positions := PackedVector3Array()
var cached_normals := PackedVector3Array()
var cached_colors := PackedColorArray()
var cached_deltas := PackedVector2Array()
var cached_heights := PackedFloat32Array()
var cached_upper := PackedFloat32Array()
var cached_lower := PackedFloat32Array()
var cached_floor := PackedFloat32Array()
func _plate_roof_at(i: int) -> float:
 # Partial burial is real Clay. Only an already exposed Stone joint earns work.
 return surface.strata.packed_limits[i*2+1]
func configure() -> void:
 super.configure()
 if mesh_quads.is_empty(): _cache_geometry()
 _cache_attributes()
func _cache_geometry() -> void:
 var lookup := {}
 var offsets := [Vector2i.ZERO,Vector2i(2,0),Vector2i(2,2),Vector2i(0,2)]
 for y in range(142,290,2):
  for x in range(416,622,2):
   var center := Vector2i(x+1,y+1)
   var i := center.y*1024+center.x
   if not targets.has(i): continue
   var corners := PackedInt32Array()
   for offset: Vector2i in offsets:
    var p := Vector2i(x,y)+offset
    if not lookup.has(p):
     lookup[p] = mesh_points.size()
     mesh_points.append(p)
     point_owner.append(i)
    corners.append(lookup[p])
   mesh_quads.append({"cell":i,"corners":corners,"grid":Vector2i(x,y)})
 mesh_cache_builds += 1
func sample_grid(data: PackedFloat32Array, p: Vector2i, stride := 1, channel := 0) -> float:
 var sum := 0.0
 for offset: Vector2i in [Vector2i(-1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i.ZERO]:
  var i := (p.y+offset.y)*1024+p.x+offset.x
  sum += data[i*stride+channel]
 return sum*.25
func floor_grid(p: Vector2i, owner: int) -> float:
 var sum := 0.0
 var count := 0
 for offset: Vector2i in [Vector2i(-1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i.ZERO]:
  var i := (p.y+offset.y)*1024+p.x+offset.x
  if targets.has(i):
   sum += targets[i]
   count += 1
 return sum/count if count > 0 else float(targets[owner])
func _cache_attributes() -> void:
 var positions := PackedVector3Array()
 var normals := PackedVector3Array()
 var colors := PackedColorArray()
 var deltas := PackedVector2Array()
 var count := mesh_points.size()
 positions.resize(count*2)
 normals.resize(count*2)
 colors.resize(count*2)
 deltas.resize(count*2)
 var center := Vector3((layout.CENTRE.x/1024-.5)*1.1,.08,(layout.CENTRE.y/640-.5)*.7)
 cached_heights.resize(count)
 cached_upper.resize(count)
 cached_lower.resize(count)
 cached_floor.resize(count)
 var heights: PackedFloat32Array = surface._heights
 var layers: PackedFloat32Array = surface.strata.packed_limits
 for n in range(count):
  var p := mesh_points[n]
  var bottom := floor_grid(p,point_owner[n])
  var h := maxf(bottom,sample_grid(heights,p))
  var upper := sample_grid(layers,p,2,0)
  var lower := sample_grid(layers,p,2,1)
  cached_heights[n] = h
  cached_upper[n] = upper
  cached_lower[n] = lower
  cached_floor[n] = bottom
  var x := (float(p.x)/1024-.5)*1.1-center.x
  var z := (float(p.y)/640-.5)*.7-center.z
  positions[n] = Vector3(x,block.base_height+h*surface.excavatable_depth-center.y,z)
  positions[n+count] = Vector3(x,block.base_height+bottom*surface.excavatable_depth-center.y,z)
  var dx := (sample_grid(heights,p+Vector2i(1,0))-sample_grid(heights,p-Vector2i(1,0)))*surface.excavatable_depth/(2*1.1/1024)
  var dz := (sample_grid(heights,p+Vector2i(0,1))-sample_grid(heights,p-Vector2i(0,1)))*surface.excavatable_depth/(2*.7/640)
  normals[n] = Vector3(-dx,1,-dz).normalized()
  normals[n+count] = Vector3.DOWN
  colors[n] = Color(1 if h > upper+.000001 else 0,1 if h <= upper+.000001 and h > lower+.000001 else 0,0,1)
  colors[n+count] = Color(0,0,1,1)
  deltas[n] = Vector2(h-upper,h-lower)
  deltas[n+count] = Vector2(bottom-upper,bottom-lower)
 cached_positions = positions
 cached_normals = normals
 cached_colors = colors
 cached_deltas = deltas
func _make_piece() -> void:
 var positions := cached_positions.duplicate()
 var normals := cached_normals.duplicate()
 var colors := cached_colors.duplicate()
 var deltas := cached_deltas.duplicate()
 var indices := PackedInt32Array()
 var count := mesh_points.size()
 var center := Vector3((layout.CENTRE.x/1024-.5)*1.1,.08,(layout.CENTRE.y/640-.5)*.7)
 var heights: PackedFloat32Array = surface._heights
 for n in range(count):
  var p := mesh_points[n]
  var h := maxf(cached_floor[n],sample_grid(heights,p))
  if h == cached_heights[n]: continue
  positions[n].y = block.base_height+h*surface.excavatable_depth-center.y
  var upper: float = cached_upper[n]
  var lower: float = cached_lower[n]
  colors[n] = Color(1 if h > upper+.000001 else 0,1 if h <= upper+.000001 and h > lower+.000001 else 0,0,1)
  deltas[n] = Vector2(h-upper,h-lower)
  var dx := (sample_grid(heights,p+Vector2i(1,0))-sample_grid(heights,p-Vector2i(1,0)))*surface.excavatable_depth/(2*1.1/1024)
  var dz := (sample_grid(heights,p+Vector2i(0,1))-sample_grid(heights,p-Vector2i(0,1)))*surface.excavatable_depth/(2*.7/640)
  normals[n] = Vector3(-dx,1,-dz).normalized()
 var active := {}
 var used_vertices := PackedByteArray()
 used_vertices.resize(count)
 for q in mesh_quads:
  if heights[q.cell] > targets[q.cell]+.003: active[q.grid] = true
 for q in mesh_quads:
  if not active.has(q.grid): continue
  var c: PackedInt32Array = q.corners
  for v in c: used_vertices[v] = 1
  for k in [0,1,2,0,2,3]: indices.append(c[k])
  for k in [0,2,1,0,3,2]: indices.append(c[k]+count)
  for n in range(4):
   var offset: Vector2i = [Vector2i(0,-2),Vector2i(2,0),Vector2i(0,2),Vector2i(-2,0)][n]
   if active.has(q.grid+offset): continue
   var a: int = c[n]
   var b: int = c[(n+1)%4]
   var edge := positions[b]-positions[a]
   var normal := Vector3(edge.z,0,-edge.x).normalized()
   var start := positions.size()
   for v in [a,b,b+count,a+count]:
    positions.append(positions[v])
    normals.append(normal)
    colors.append(Color(0,0,1,1))
    deltas.append(deltas[v])
   for k in [0,2,1,0,3,2]: indices.append(start+k)
 if indices.is_empty(): return
 var arrays := []
 arrays.resize(Mesh.ARRAY_MAX)
 arrays[Mesh.ARRAY_VERTEX] = positions
 arrays[Mesh.ARRAY_NORMAL] = normals
 arrays[Mesh.ARRAY_COLOR] = colors
 arrays[Mesh.ARRAY_TEX_UV2] = deltas
 arrays[Mesh.ARRAY_INDEX] = indices
 piece = MeshInstance3D.new()
 piece.name = "NaturalDetachedSandstone"
 piece.mesh = ArrayMesh.new()
 piece.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
 var mat := ShaderMaterial.new()
 mat.shader = preload("res://shaders/p6a44_detached_stone.gdshader")
 mat.set_shader_parameter("hero_stone",preload("res://assets/p6a2/textures/sandstone/p6a2_sandstone_albedo_v02.png"))
 mat.set_shader_parameter("hero_clay",preload("res://assets/p6a2/textures/clay/p6a2_clay_albedo_v02.png"))
 mat.set_shader_parameter("hero_soil",preload("res://assets/p6a2/textures/soil/p6a2_soil_albedo_v02.png"))
 mat.set_shader_parameter("rock_origin",center)
 mat.set_shader_parameter("soil_color",block.material.get_shader_parameter("soil_color"))
 mat.set_shader_parameter("cracks",ImageTexture.create_from_image(image.duplicate()))
 mat.set_shader_parameter("soil_lab_patina",block.material.get_shader_parameter("soil_lab_patina"))
 piece.material_override = mat
 piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 block.add_child(piece)
 piece.position = center
 var end_rotation := Vector3(.12,.28,.18)
 var basis := Basis.from_euler(end_rotation)
 var min_y := INF
 for n in range(count):
  if used_vertices[n] == 0: continue
  min_y = minf(min_y,minf((basis*positions[n]).y,(basis*positions[n+count]).y))
 var landing := Vector3(.47,.002-min_y,.44)
 flight = create_tween().set_parallel(true)
 flight.tween_property(piece,"position",center+Vector3(.10,.075,.10),.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 flight.tween_property(piece,"rotation",end_rotation*.35,.18)
 flight.chain().tween_property(piece,"position",landing,.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
 flight.parallel().tween_property(piece,"rotation",end_rotation,.40)
