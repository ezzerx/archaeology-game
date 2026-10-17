extends "res://scripts/excavation/pockets/final_feedback.gd"
var abrasion_interval:=0.0
var abrasion_age:=1.0
var abrasion_bursts:=0
func _create_proxies() -> void:
 super._create_proxies()
 var proxy:=Node3D.new();proxy.name="AbrasiveTip";add_child(proxy);proxies.append(proxy)
 var pose:=ToolProxyPose.new();proxy_poses.append(pose);pose.setup(proxy)
 preload("res://scripts/experiments/preparation_demos/abrasive_tool.gd").attach(pose)
 proxy.hide()
func on_action(event:Dictionary) -> void:
 super.on_action(event)
 if event.get("abrasion",false):
  abrasion_age=0.0
  if abrasion_interval>0 or not particles_enabled:return
  abrasion_interval=.055;abrasion_bursts+=1
  var sources:Array=event.get("grain_sources",[])
  var contact:Vector2=event.point
  if not sources.is_empty():
   var source:Vector3=sources[sources.size()/2]
   contact=Vector2(source.x,source.z)
  var first_dust:int=particles[3].size()
  _dust(contact,Color(.62,.57,.48),1,.0024)
  for i in range(first_dust,particles[3].size()):
   particles[3][i].amount=.16
   particles[3][i].life=.25;particles[3][i].duration=.25
  var saved:Color=colors[2]
  colors[2]=Color(.54,.49,.40)
  chips_left=3;gentle_contact=true;_emit(2,contact,3)
  colors[2]=saved
func _process(delta:float) -> void:
 abrasion_interval=maxf(0,abrasion_interval-delta);abrasion_age+=delta
 super._process(delta)
func _update_proxy_pose(selected:int) -> void:
 super._update_proxy_pose(selected)
 if selected==4 and controller._held and controller.hit.get("inside",false) and abrasion_age<.10:
  proxies[selected].global_basis=ToolProxyPose.fixed_basis(selected)*Basis.from_euler(Vector3(0,sin(motion_time*85)*.018,0))
func reset() -> void:
 super.reset()
 abrasion_interval=0;abrasion_age=1;abrasion_bursts=0
