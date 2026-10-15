extends "res://scripts/p6a47/pocket_surface.gd"
func apply_impact(point:Vector2,tool:ToolDefinition) -> int:
 var samples:Array[Vector3]=pocket.capture_contact(point,tool) if is_instance_valid(pocket) else []
 var changed:=super.apply_impact(point,tool)
 if changed>0 and is_instance_valid(pocket):pocket.after_contact(samples)
 return changed
