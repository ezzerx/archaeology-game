extends WorkingSurface
var slab: Node
func apply_impact(point: Vector2, tool: ToolDefinition) -> int:
 var contact: bool = is_instance_valid(slab) and slab.accepts_contact(point,tool)
 var changed := super.apply_impact(point,tool)
 if is_instance_valid(slab): changed += slab.after_impact(point,tool,contact)
 return changed
