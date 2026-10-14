extends "res://scripts/p6a33/cleaning_feedback.gd"
func _update_proxy_pose(selected: int) -> void:
 if selected != 3 or not controller.lever_drag or not is_instance_valid(controller.slab):
  super._update_proxy_pose(selected)
  return
 # The tip stays in its joint while the handle follows the short lever gesture.
 var slab: Node = controller.slab
 var progress: float = slab.visual_progress
 var edge: float = clampf((slab.lever_anchor.y-175)/90,0,1)
 var proxy: Node3D = proxies[selected]
 proxy.global_position = controller.lever_hit.world+Vector3.UP*edge*progress*.004
 proxy.global_basis = Basis.from_euler(Vector3(.5+.34*progress,0,-.62))
 proxy.scale = Vector3.ONE
 proxy_poses[selected].fit(proxy,block)
