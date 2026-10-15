extends WorkingSurface
var pocket: Node
func constrain_removal(index: int, next: float, tool_id: StringName) -> float:
 if is_instance_valid(pocket): return pocket.constrain(index,next,tool_id)
 return next
func apply_impact(point: Vector2, tool: ToolDefinition) -> int:
 var changed := super.apply_impact(point,tool)
 if is_instance_valid(pocket) and pocket.BOUNDS.grow(ceili(tool.radius)).has_point(Vector2i(point)): pocket.observe_opening()
 return changed
func apply_continuous(from: Vector2, to: Vector2, tool: ToolDefinition, delta: float) -> int:
 var changed := super.apply_continuous(from,to,tool,delta)
 if is_instance_valid(pocket) and tool.id == &"air_blower" and delta > 0:
  changed += pocket.blow(from,to,tool,delta)
 return changed
