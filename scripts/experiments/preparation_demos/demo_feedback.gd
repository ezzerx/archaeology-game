extends "res://scripts/excavation/pockets/final_feedback.gd"
var abrasion_interval:=0.0
func _create_proxies() -> void:
 super._create_proxies()
 var proxy:=Node3D.new();proxy.name="AbrasiveTip";add_child(proxy);proxies.append(proxy)
 var pose:=ToolProxyPose.new();proxy_poses.append(pose);pose.setup(proxy)
 preload("res://scripts/experiments/preparation_demos/abrasive_tool.gd").attach(pose)
 proxy.hide()
func on_action(event:Dictionary) -> void:
 super.on_action(event)
 if event.get("abrasion",false) and abrasion_interval<=0:
  abrasion_interval=.06
  _dust(event.point,Color(.53,.46,.32),3,.003)
  chips_left=2;gentle_contact=true;_emit(2,event.point,2)
func _process(delta:float) -> void:
 abrasion_interval=maxf(0,abrasion_interval-delta)
 super._process(delta)
func _update_proxy_pose(selected:int) -> void:
 super._update_proxy_pose(selected)
 if selected==4 and controller._held:
  proxies[selected].global_basis=ToolProxyPose.fixed_basis(selected)*Basis.from_euler(Vector3(0,sin(motion_time*85)*.035,0))
