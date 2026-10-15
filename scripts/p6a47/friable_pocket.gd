extends Node
## A bounded granular inclusion in the actual RF matrix. No hidden fossil reads
## drive its appearance, flow or shape. Bone is consulted only for the cover guard.
signal opened
signal emptied
const CENTRE := Vector2(496,305)
const BOUNDS := Rect2i(401,248,192,117)
const STEP := 1.0/60.0
var layout: RefCounted
var block: ExcavationBlock
var surface: WorkingSurface
var cells := PackedInt32Array()
var roofs := PackedFloat32Array()
var floors := PackedFloat32Array()
var image: Image
var texture: ImageTexture
var cover_floor := 0.0
var initial_volume := 0.0
var blown_volume := 0.0
var remaining_cache := 0.0
var is_open := false
var is_empty := false
var ticks := 0
var flow_usec := 0
var accumulator := 0.0
var uploads := 0
func setup(target: ExcavationBlock, shape: RefCounted) -> void:
 layout = shape
 block = target
 surface = block.working_map
 image = Image.create(surface.size.x,surface.size.y,false,Image.FORMAT_RGBAF)
 texture = ImageTexture.create_from_image(image)
 surface.surface_reset.connect(clear)
 configure()
func clear() -> void:
 is_open = false
 is_empty = false
 blown_volume = 0
 ticks = 0
 accumulator = 0
 flow_usec = 0
func configure() -> void:
 clear()
 cells.clear()
 roofs.resize(surface._heights.size()); roofs.fill(0)
 floors.resize(roofs.size()); floors.fill(0)
 image.fill(Color(0,0,0,0))
 initial_volume = 0
 # A single conservative cover bound prevents any Bone-shaped imprint in the
 # cavity floor. Its roughness and silhouette are independent of Bone anatomy.
 cover_floor = 0
 for i: int in layout.cells: cover_floor=maxf(cover_floor,surface.structural_ceilings[i])
 cover_floor += .018
 for slot in range(layout.cells.size()):
  var i: int = layout.cells[slot]
  var x: int = i%surface.size.x
  var y: int = i/surface.size.x
  var n: float = layout.noise_values[slot]
  var weight: float = layout.weights[slot]
  var roof := roof_at(i,weight,n)
  var floor := floor_at(i,roof,weight,n)
  if floor >= roof-.012: continue
  cells.append(i)
  roofs[i] = roof
  floors[i] = floor
  initial_volume += roof-floor
  image.set_pixel(x,y,Color(roof,floor,weight,1))
 remaining_cache = initial_volume
 texture.update(image)
 uploads += 1
func contact_bounds() -> Rect2i:
 return BOUNDS
func roof_at(i: int, _weight: float, _noise: float) -> float:
 return surface.strata.packed_limits[i*2]-.015
func floor_at(i: int, roof: float, weight: float, noise: float) -> float:
 var x: int = i%surface.size.x
 var y: int = i/surface.size.x
 var depth := .045+.17*weight+.027*noise+.018*sin(x*.09+y*.07)
 return maxf(roof-depth,cover_floor+.012+.012*sin(x*.09+y*.07)+.014*(noise+.5))
func constrain(i: int, next: float, tool: StringName) -> float:
 if roofs.is_empty() or roofs[i] <= 0: return next
 var old: float = surface._heights[i]
 if old <= floors[i]+.00001: return next
 # First real cut opens the thin crust. A later solid-tool cut can scoop grains;
 # Brush cannot grind this inclusion away. No mutation, refill or false exposure.
 if old > roofs[i]+.0001:
  return minf(old,maxf(next,surface.strata.packed_limits[i*2] if tool == &"soft_brush" else roofs[i]))
 if tool == &"soft_brush": return old
 return maxf(next,maxf(floors[i],old-.018))
func observe_opening() -> void:
 remaining_cache = remaining_volume()
 if is_open: return
 var count := 0
 for i in cells:
  if surface._heights[i] <= roofs[i]+.0001: count += 1
 if count >= 12:
  is_open = true
  opened.emit()
func remaining_volume() -> float:
 var remaining := 0.0
 for i in cells: remaining += maxf(0,minf(surface._heights[i],roofs[i])-floors[i])
 return remaining
func _undercut(i: int) -> bool:
 for offset in [-3072,-3,3,3072]:
  var j: int = i+offset
  if roofs[j]>0 and surface._heights[j] < roofs[j]-.020: return true
 return false
func flow_height(i: int, old: float, weight: float, delta: float) -> float:
 return maxf(floors[i],minf(old,roofs[i])-.60*delta*weight)
func blow(from: Vector2, to: Vector2, tool: ToolDefinition, delta: float) -> int:
 if not is_open: return 0
 var low := Vector2i((from.min(to)-Vector2.ONE*tool.radius).floor()).max(contact_bounds().position)
 var high := Vector2i((from.max(to)+Vector2.ONE*tool.radius).ceil()).min(contact_bounds().end-Vector2i.ONE)
 if low.x>high.x or low.y>high.y: return 0
 accumulator += minf(delta,.125)
 var iterations := mini(8,floori((accumulator+.0000001)/STEP))
 if iterations == 0: return 0
 accumulator -= iterations*STEP
 var started := Time.get_ticks_usec()
 var changed := 0
 var removed_soil := 0.0
 var removed_clay := 0.0
 var removed_stone := 0.0
 var samples: Array[Vector3] = []
 var center := Vector2.ZERO
 var total := 0.0
 var segment := to-from
 var length_squared := segment.length_squared()
 var inverse := 1.0/length_squared if length_squared>0 else 0.0
 var radius_squared := tool.radius*tool.radius
 for step in range(iterations):
  var eligible := PackedInt32Array()
  var weights := PackedFloat32Array()
  # Eligibility is frozen for this substep: the front never races through an
  # entire roof in iteration order. Unsupported crust crumbles only in the jet.
  for y in range(low.y,high.y+1):
   for x in range(low.x,high.x+1):
    var i := y*surface.size.x+x
    if roofs[i]<=0: continue
    var old: float = surface._heights[i]
    if old<=floors[i]+.00001: continue
    var p := Vector2(x,y)
    var t := clampf((p-from).dot(segment)*inverse,0,1)
    var d := p.distance_squared_to(from+segment*t)
    if d>=radius_squared: continue
    if old>roofs[i]+.0001 and not _undercut(i): continue
    # Thick remaining overburden is solid, never collapses from air.
    if old>roofs[i]+.038: continue
    eligible.append(i)
    weights.append(WorkingSurface.weight(sqrt(d)/tool.radius,.60))
  var sample_stride := maxi(1,eligible.size()/12 as int)
  for n in range(eligible.size()):
   var i := eligible[n]
   var old: float = surface._heights[i]
   var next := flow_height(i,old,weights[n],STEP)
   surface._heights[i] = next
   next = surface._heights[i] # Account from committed float32, not a proposed height.
   var volume := old-next
   if volume<=0: continue
   remaining_cache -= maxf(0,minf(old,roofs[i])-next)
   # Fracture stress belongs to the removed crust/grains. Do not stamp its
   # coarse rectangular marks onto the new compact floor.
   if next<=floors[i]+.00001 and not surface.fracture.stress.is_empty():
    var point := Vector2(i%surface.size.x,i/surface.size.x as int)
    for layer in [1,2]:
     var tile: Vector2i = surface.fracture.partition(point,layer)
     var key := Vector3i(tile.x,tile.y,layer)
     if surface.fracture.stress.has(key):surface.fracture._record_stress(key,0.0)
   var upper: float = surface.strata.packed_limits[i*2]
   var lower: float = surface.strata.packed_limits[i*2+1]
   removed_soil += maxf(0,old-maxf(next,upper))
   removed_clay += maxf(0,minf(old,upper)-maxf(next,lower))
   removed_stone += maxf(0,minf(old,lower)-next)
   var p := Vector2(i%surface.size.x,i/surface.size.x as int)
   center += p*volume
   total += volume
   if n%sample_stride==0 and samples.size()<12: samples.append(Vector3(p.x,old,p.y))
   changed += 1
  ticks += 1
 if changed == 0: return 0
 blown_volume += total
 surface.image.set_data(surface.size.x,surface.size.y,false,Image.FORMAT_RF,surface._heights.to_byte_array())
 surface.dirty = true
 surface.update_fragments(Rect2i(low,high-low+Vector2i.ONE))
 var removed := Vector3(removed_soil,removed_clay,removed_stone)
 surface.last_removed += removed
 var event := {"tool":tool.id,"point":center/total,"removed":removed,"changed":changed,"marks":0,"chunks":[],
  "micro_detached":0,"bone_film_cleared":0.0,"residue_cleared":0.0,"loose_cleared":0.0,
  "bone_film_point":Vector2(-1,-1),"cleared_dust":[],"direction":surface.loose_debris.jet,
  "bone_revealed":false,"bone_first_contact":false,"bone_protected_contact":false,
  "bone_damage":0.0,"direct_bone_hit":false,"movement":from.distance_to(to)/delta,
  "pocket_flow":true,"grain_sources":samples,"flow_volume":total}
 surface.last_action = event
 surface.material_action.emit(event)
 if not is_empty and remaining_cache<initial_volume*.08:
  is_empty = true
  emptied.emit()
 flow_usec = Time.get_ticks_usec()-started
 return changed
