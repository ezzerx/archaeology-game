extends "res://scripts/p6a44/natural_slab.gd"
signal ready_to_lift
var mobile := false
var dragging := false
var lever_progress := 0.0
var visual_progress := 0.0
var lever_anchor := Vector2.ZERO
var readiness_reason := ""
var lever_texture: ImageTexture
func configure() -> void:
 super.configure()
 var plate := Image.create(1024,640,false,Image.FORMAT_RGF)
 for i: int in targets:
  @warning_ignore("integer_division")
  plate.set_pixel(i%1024,i/1024,Color(1,targets[i],0,1))
 lever_texture = ImageTexture.create_from_image(plate)
 bind_preview()
func reset() -> void:
 super.reset()
 mobile = false
 dragging = false
 lever_progress = 0
 visual_progress = 0
 readiness_reason = ""
 _set_preview()
func bind_preview() -> void:
 for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("lever_plate",lever_texture)
 _set_preview()
func _set_preview() -> void:
 if block == null: return
 for mat in [block.material,block.skirt_material]:
  mat.set_shader_parameter("lever_amount",visual_progress)
  mat.set_shader_parameter("lever_ready",mobile and not released)
func _process(delta: float) -> void:
 if is_equal_approx(visual_progress,lever_progress): return
 visual_progress = move_toward(visual_progress,lever_progress,delta*8)
 _set_preview()
func _draw_cracks() -> void:
 image.fill(Color(0,0,0,1))
 for i: int in layout.distances:
  @warning_ignore("integer_division")
  var p := Vector2(i%1024,i/1024)
  var opening := 0.0
  for strike in strikes: opening = maxf(opening,1.0-smoothstep(8,23,p.distance_to(strike)))
  var d: float = layout.distances[i]
  var width: float = layout.width_at(p)
  var mark := maxf((1.0-smoothstep(.15,width,d))*(.64+.26*sin(p.x*.71-p.y*.47)*sin(p.x*.71-p.y*.47)),(1.0-smoothstep(.6,width+1.6,d))*opening)
  image.set_pixel(int(p.x),int(p.y),Color(mark,opening,0,1))
 texture.update(image)
 uploads += 1
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
  if strikes.size() >= 3 and span >= 50: _mark_mobile("joint")
 # Broad excavation still works normally; it never launches a fragment by itself.
 if not mobile:
  var remaining := 0.0
  for i: int in targets: remaining += maxf(0.0,minf(surface._heights[i],_plate_roof_at(i))-targets[i])
  if remaining < initial_volume*.45 and remaining > .001: _mark_mobile("erosion")
 return 0
func _mark_mobile(reason: String) -> void:
 if mobile: return
 mobile = true
 readiness_reason = reason
 _set_preview()
 ready_to_lift.emit()
func can_lever(point: Vector2, tool: ToolDefinition) -> bool:
 if not mobile or released or tool.id != &"precision_pick" or tool.power <= 0: return false
 var p := Vector2i(point.round())
 if not layout.BOUNDS.has_point(p): return false
 var i := p.y*1024+p.x
 if not targets.has(i) or surface._heights[i] <= targets[i]+.003: return false
 # Only an already exposed joint/edge gives purchase. No grip through Clay/Soil.
 if surface._heights[i] > _plate_roof_at(i)+Stratigraphy.SURFACE_EPSILON: return false
 if layout.border_distance(point) <= 14: return true
 for strike in strikes:
  if strike.distance_to(point) <= 16: return true
 return readiness_reason == "erosion" and layout.crack_distance(point) <= 6
func begin_lever(point: Vector2, tool: ToolDefinition) -> bool:
 if not can_lever(point,tool): return false
 dragging = true
 lever_progress = 0
 lever_anchor = point
 return true
func cancel_lever() -> void:
 dragging = false
 lever_progress = 0
func move_lever(progress: float, tool: ToolDefinition) -> int:
 if not dragging or not mobile or released or tool.id != &"precision_pick" or tool.power <= 0: return 0
 lever_progress = clampf(progress,0,1)
 if lever_progress < 1: return 0
 dragging = false
 mobile = false
 lever_progress = 0
 visual_progress = 0
 _set_preview()
 # This is a separate manual action, not an extension of the last native impact.
 surface.last_removed = Vector3.ZERO
 surface.tool_applied.emit()
 return _release(tool,"manual_"+readiness_reason)
