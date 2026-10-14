extends Node
signal loosened
signal detached(reason: String)
var block: ExcavationBlock
var layout: RefCounted
var surface: WorkingSurface
var image: Image
var texture: ImageTexture
var targets := {}
var strikes: Array[Vector2] = []
var released := false
var piece: MeshInstance3D
var flight: Tween
var uploads := 0
var release_count := 0
var released_cells := 0
var release_usec := 0
var initial_volume := 0.0
var release_reason := ""
func setup(target: ExcavationBlock, shape: RefCounted) -> void:
 block = target
 surface = block.working_map
 layout = shape
 image = Image.create(1024,640,false,Image.FORMAT_RG8)
 texture = ImageTexture.create_from_image(image)
 surface.surface_reset.connect(reset)
 configure()
func configure() -> void:
 reset()
 targets.clear()
 initial_volume = 0.0
 for i in layout.cells:
  var upper: float = surface.strata.packed_limits[i*2]
  var floor := upper-.12
  if surface.structural_ceilings[i] > 0: floor = maxf(floor,surface.structural_ceilings[i]+.01)
  assert(floor < upper,"Plate must have positive thickness above Bone")
  targets[i] = floor
  initial_volume += upper-floor
 _draw_cracks()
func reset() -> void:
 if flight != null: flight.kill()
 if is_instance_valid(piece): piece.free()
 piece = null
 strikes.clear()
 released = false
 release_count = 0
 released_cells = 0
 release_reason = ""
 if image != null:
  image.fill(Color(0,0,0,1))
  texture.update(image)
  uploads += 1
func _draw_cracks() -> void:
 image.fill(Color(0,0,0,1))
 for i: int in layout.distances:
  @warning_ignore("integer_division")
  var p := Vector2(i%1024,i/1024)
  var opening := 0.0
  for strike in strikes: opening = maxf(opening,1.0-smoothstep(8,23,p.distance_to(strike)))
  var d: float = layout.distances[i]
  var width := .9+.16*sin(p.x*.17+p.y*.23)
  var mark := maxf(1.0-smoothstep(.3,width+ .35,d),(1.0-smoothstep(1.0,3.8,d))*opening)
  image.set_pixel(int(p.x),int(p.y),Color(mark,opening,0,1))
 texture.update(image)
 uploads += 1
func accepts_contact(point: Vector2, tool: ToolDefinition) -> bool:
 if released or tool.id != &"precision_pick" or tool.power <= 0 or not layout.BOUNDS.has_point(Vector2i(point)): return false
 var i := int(round(point.y))*1024+int(round(point.x))
 if not targets.has(i): return false
 var h: float = surface._heights[i]
 var upper: float = surface.strata.packed_limits[i*2]
 # Eligibility is sampled BEFORE native work: buried Soil cannot activate a joint.
 return h <= upper+Stratigraphy.SURFACE_EPSILON and h > targets[i]+.006 and layout.crack_distance(point) <= 5.5
func after_impact(point: Vector2, tool: ToolDefinition, contact: bool) -> int:
 if released or tool.power <= 0 or not layout.BOUNDS.has_point(Vector2i(point)): return 0
 if contact:
  var distinct := true
  for strike in strikes:
   if strike.distance_to(point) < 24: distinct = false
  if distinct:
   strikes.append(point)
   _draw_cracks()
   loosened.emit()
  var span := 0.0
  for a in strikes:
   for b in strikes: span = maxf(span,a.distance_to(b))
  if strikes.size() >= 3 and span >= 50: return _release(tool,"joint")
 # Normal excavation remains viable: an already eroded plate loses its support.
 var remaining := 0.0
 for i: int in targets:
  remaining += maxf(0.0,minf(surface._heights[i],surface.strata.packed_limits[i*2])-targets[i])
 if remaining < initial_volume*.45 and remaining > .001: return _release(tool,"erosion")
 return 0
func _release(tool: ToolDefinition, reason: String) -> int:
 if released: return 0
 var started := Time.get_ticks_usec()
 released = true
 release_reason = reason
 release_count += 1
 # Capture remaining real matrix BEFORE removing it. No intact replacement prop.
 _make_piece()
 var removed := Vector3.ZERO
 var changed := 0
 for i: int in targets:
  var old: float = surface._heights[i]
  var next: float = minf(old,targets[i])
  if next >= old: continue
  var upper: float = surface.strata.packed_limits[i*2]
  removed.x += maxf(old-upper,0.0)
  removed.z += minf(old,upper)-next
  surface._heights[i] = next
  changed += 1
 surface.last_removed += removed
 surface.image.set_data(1024,640,false,Image.FORMAT_RF,surface._heights.to_byte_array())
 surface.dirty = true
 # Residual native stress cannot redraw false cracks on the new exposed floor.
 for key: Vector3i in surface.fracture.stress.keys():
  if key.z == 2:
   var p := Vector2(key.x-1,key.y-1)*surface.fracture.profile.patch_size(2)
   if layout.BOUNDS.grow(12).has_point(Vector2i(p)): surface.fracture._record_stress(key,0.0)
 image.fill(Color(0,0,0,1))
 texture.update(image)
 uploads += 1
 block.flush_texture()
 released_cells = changed
 var event := {"tool":tool.id,"point":layout.CENTRE,"removed":removed,"changed":changed,"marks":0,
  "chunks":[{"layer":2,"point":layout.CENTRE,"cells":changed,"volume":removed.z}],
  "micro_detached":0,"bone_film_cleared":0.0,"residue_cleared":0.0,"loose_cleared":0.0,
  "bone_film_point":Vector2(-1,-1),"cleared_dust":[],"direction":Vector2.ONE,"bone_revealed":false,
  "bone_first_contact":false,"bone_protected_contact":false,"bone_damage":0.0,"direct_bone_hit":false,"movement":0.0,
  "slab_detached":true}
 surface.last_action = event
 surface.material_action.emit(event)
 release_usec = Time.get_ticks_usec()-started
 detached.emit(reason)
 return changed
func _make_piece() -> void:
 var st := SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var center := Vector3((layout.CENTRE.x/1024-.5)*1.1,.08,(layout.CENTRE.y/640-.5)*.7)
 var vertex_count := 0
 var corners := [Vector2(-1.5,-1.5),Vector2(1.5,-1.5),Vector2(1.5,1.5),Vector2(-1.5,1.5)]
 for y in range(168,264,3):
  for x in range(441,597,3):
   var i := y*1024+x
   if not targets.has(i) or surface._heights[i] <= targets[i]+.003: continue
   var top: float = block.base_height+surface._heights[i]*surface.excavatable_depth
   var bottom: float = block.base_height+targets[i]*surface.excavatable_depth
   var v: Array[Vector3] = []
   for height: float in [top,bottom]:
    for offset: Vector2 in corners:
     var p := Vector2(x,y)+offset
     v.append(Vector3((p.x/1024-.5)*1.1,height,(p.y/640-.5)*.7)-center)
   var dirt := 1.0 if surface._heights[i] > surface.strata.packed_limits[i*2]+.001 else 0.0
   st.set_color(Color(dirt,0,0,1))
   for k in [0,2,1,0,3,2,4,5,6,4,6,7]:
    st.set_uv(Vector2(v[k].x+center.x,v[k].z+center.z)/.24)
    st.set_uv2(Vector2((v[k].x+center.x)/1.1,(v[k].z+center.z)/.7)+Vector2.ONE*.5)
    st.add_vertex(v[k]); vertex_count += 1
   # Only actual outer/hole faces; internal coincident voxel sides are omitted.
   for n in range(4):
    var offset: Vector2i = [Vector2i(0,-3),Vector2i(3,0),Vector2i(0,3),Vector2i(-3,0)][n]
    var j := (y+offset.y)*1024+x+offset.x
    if targets.has(j) and surface._heights[j] > targets[j]+.003: continue
    var m := (n+1)%4
    st.set_color(Color(dirt,1,0,1))
    for k in [n,m,m+4,n,m+4,n+4]:
     st.set_uv(Vector2(v[k].x+center.x,v[k].y+center.y)/.24)
     st.set_uv2(Vector2.ZERO)
     st.add_vertex(v[k]); vertex_count += 1
 if vertex_count == 0: return
 st.generate_normals()
 piece = MeshInstance3D.new()
 piece.name = "DetachedSandstone"
 piece.mesh = st.commit()
 var mat := ShaderMaterial.new()
 mat.shader = preload("res://shaders/p6a43_detached_stone.gdshader")
 mat.set_shader_parameter("stone",block.material.get_shader_parameter("hero_stone"))
 mat.set_shader_parameter("soil",block.material.get_shader_parameter("hero_soil"))
 mat.set_shader_parameter("cracks",ImageTexture.create_from_image(image.duplicate()))
 piece.material_override = mat
 piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 block.add_child(piece)
 piece.position = center
 var end_rotation := Vector3(.12,.28,.18)
 var basis := Basis.from_euler(end_rotation)
 var min_y := INF
 for p: Vector3 in piece.mesh.get_faces(): min_y = minf(min_y,(basis*p).y)
 var landing := Vector3(.47,.002-min_y,.44)
 flight = create_tween()
 flight.set_parallel(true)
 flight.tween_property(piece,"position",center+Vector3(.10,.075,.10),.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 flight.tween_property(piece,"rotation",end_rotation*.35,.18)
 flight.chain().tween_property(piece,"position",landing,.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
 flight.parallel().tween_property(piece,"rotation",end_rotation,.40)
