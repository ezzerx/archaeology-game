extends "res://scripts/p6a45/manual_slab.gd"
var break_image: Image
var break_texture: ImageTexture
var break_uploads := 0
var border_samples := {}
var border_base := {}
var border_depth := {}
var broken_cells := 0
func _plate_floor_at(i: int, upper: float) -> float:
 @warning_ignore("integer_division")
 var p := Vector2(i%1024,i/1024)
 var floor: float = upper-layout.thickness_mm(p)/(surface.excavatable_depth*1000.0)
 if surface.structural_ceilings[i] > 0: floor = maxf(floor,surface.structural_ceilings[i]+.01)
 return floor
func configure() -> void:
 super.configure()
 border_base.clear()
 border_depth.clear()
 broken_cells = 0
 if break_image == null:
  break_image = Image.create(1024,640,false,Image.FORMAT_RGF)
  break_texture = ImageTexture.create_from_image(break_image)
 if border_samples.is_empty():
  for y in range(layout.BOUNDS.position.y,layout.BOUNDS.end.y):
   for x in range(layout.BOUNDS.position.x,layout.BOUNDS.end.x):
    var p := Vector2(x,y)
    var distance: float = layout.border_distance(p)
    if distance <= 4.5: border_samples[y*1024+x] = distance
 for i: int in border_samples: border_base[i] = surface._heights[i]
 _draw_break()
 bind_preview()
func reset() -> void:
 super.reset()
 border_depth.clear()
 broken_cells = 0
 if break_image != null:
  break_image.fill(Color(0,0,0,1))
  break_texture.update(break_image)
  break_uploads += 1
func bind_preview() -> void:
 super.bind_preview()
 if break_texture != null:
  for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("slab_break",break_texture)
func _cache_attributes() -> void:
 super._cache_attributes()
 # The underside follows the same filtered rupture data as the cavity.
 var count := mesh_points.size()
 for n in range(count):
  var p := mesh_points[n]
  var owner: int = point_owner[n]
  var dx := (floor_grid(p+Vector2i(1,0),owner)-floor_grid(p-Vector2i(1,0),owner))*surface.excavatable_depth/(2*1.1/1024)
  var dz := (floor_grid(p+Vector2i(0,1),owner)-floor_grid(p-Vector2i(0,1),owner))*surface.excavatable_depth/(2*.7/640)
  cached_normals[n+count] = Vector3(dx,-1,dz).normalized()
func after_impact(point: Vector2, tool: ToolDefinition, contact: bool) -> int:
 var old_count := strikes.size()
 var was_mobile := mobile
 var changed := super.after_impact(point,tool,contact)
 if not released and (strikes.size() > old_count or mobile != was_mobile): changed += _extend_break(point,tool)
 return changed
func _extend_break(point: Vector2, tool: ToolDefinition) -> int:
 var removed := Vector3.ZERO
 # Accumulate in float64 before constructing Vector3, as for the main release.
 var soil := 0.0
 var clay := 0.0
 var stone := 0.0
 var changed := 0
 for i: int in border_samples:
  @warning_ignore("integer_division")
  var p := Vector2(i%1024,i/1024)
  var progress := 1.0 if mobile else 0.0
  if not mobile:
   for strike in strikes: progress = maxf(progress,(1.0-smoothstep(20,64,p.distance_to(strike)))*.72)
  var width := .55+.55*(.5+.5*sin(p.x*.43-p.y*.31))
  var d: float = border_samples[i]
  var depth := (0.55+.65*(.5+.5*sin(p.x*.23+p.y*.17)))*(1.0-smoothstep(.12,width+.75,d))*progress/(surface.excavatable_depth*1000.0)
  if depth <= float(border_depth.get(i,0.0))+.000001: continue
  border_depth[i] = depth
  var old: float = surface._heights[i]
  var target: float = float(border_base[i])-depth
  if surface.structural_ceilings[i] > 0: target = maxf(target,surface.structural_ceilings[i]+.01)
  var next := minf(old,target)
  if next >= old: continue
  var upper: float = surface.strata.packed_limits[i*2]
  var lower: float = surface.strata.packed_limits[i*2+1]
  soil += maxf(old-upper,0)-maxf(next-upper,0)
  clay += maxf(0,minf(old,upper)-maxf(next,lower))
  stone += maxf(0,minf(old,lower)-next)
  surface._heights[i] = next
  changed += 1
 broken_cells = border_depth.size()
 _draw_break()
 if changed == 0: return 0
 removed = Vector3(soil,clay,stone)
 surface.last_removed += removed
 surface.image.set_data(1024,640,false,Image.FORMAT_RF,surface._heights.to_byte_array())
 surface.dirty = true
 block.flush_texture()
 var event := {"tool":tool.id,"point":point,"removed":removed,"changed":changed,"marks":0,"chunks":[],
  "micro_detached":0,"bone_film_cleared":0.0,"residue_cleared":0.0,"loose_cleared":0.0,
  "bone_film_point":Vector2(-1,-1),"cleared_dust":[],"direction":Vector2.ONE,"bone_revealed":false,
  "bone_first_contact":false,"bone_protected_contact":false,"bone_damage":0.0,"direct_bone_hit":false,"movement":0.0,
  "slab_seam":true}
 surface.last_action = event
 surface.material_action.emit(event)
 return changed
func _draw_break() -> void:
 if break_image == null: return
 break_image.fill(Color(0,0,0,1))
 for i: int in border_depth:
  @warning_ignore("integer_division")
  var p := Vector2(i%1024,i/1024)
  var depth: float = border_depth[i]
  var ink := clampf(depth*surface.excavatable_depth*1000.0/.7,0,1)
  break_image.set_pixel(int(p.x),int(p.y),Color(ink,float(border_base[i])-depth,0,1))
 break_texture.update(break_image)
 break_uploads += 1

func _make_piece() -> void:
 super._make_piece()
 if not is_instance_valid(piece): return
 piece.material_override.shader = preload("res://shaders/p6a46_detached_rock.gdshader")
 piece.material_override.set_shader_parameter("slab_clay_folds",block.material.get_shader_parameter("slab_clay_folds"))
 piece.material_override.set_shader_parameter("slab_break",ImageTexture.create_from_image(break_image.duplicate()))
