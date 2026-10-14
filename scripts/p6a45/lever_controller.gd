extends ToolController
## Opt-in only for this candidate; ordinary tool cadence and definitions stay native.
var slab: Node
var lever_drag := false
var lever_start := Vector2.ZERO
var lever_hit := {}
func cancel_stroke() -> void:
 if is_instance_valid(slab): slab.cancel_lever()
 lever_drag = false
 super.cancel_stroke()
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
  var target := _pick_current()
  if target.inside and is_instance_valid(slab) and slab.can_lever(target.map,config):
   cancel_stroke()
   slab.begin_lever(target.map,config)
   lever_drag = true
   lever_start = _screen
   lever_hit = target.duplicate()
   get_viewport().set_input_as_handled()
   return
 super._unhandled_input(event)
func _physics_process(delta: float) -> void:
 # Captured levering consumes this gesture without native repeated impacts.
 if lever_drag: _held = false
 super._physics_process(delta)
 if not lever_drag: return
 if not hit.inside or not _focused or not _pointer_inside or config.id != &"precision_pick":
  cancel_stroke()
  return
 var distance := maxf(24,get_viewport().get_visible_rect().size.y*.04)
 var progress := (_screen-lever_start).y/distance
 var changed: int = slab.move_lever(progress,config)
 if changed > 0:
  changed_texels = changed
  lever_drag = false
  _held = false
  impact_clock.reset()
