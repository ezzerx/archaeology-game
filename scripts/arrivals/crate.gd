extends Node3D
## Mechanical parts have independent transforms; source meshes are immutable.
const Room=preload("res://scripts/experiments/exhibition/gallery_room.gd")
const Furniture=preload("res://scripts/experiments/exhibition/gallery_furniture.gd")
const TITLES=["Dépôt continental","Sédiments marins","Matrice minérale"]
const NOTES=["Matrice compacte","Sédiment meuble","Dépôts adhérents"]
const LOTS=["014","027","068"]
var index:=0
var unlocked:=false
var opening:=0.0
var lid:Node3D
var latch:Node3D
var covered:Node3D
var label:Label3D
var motion:Tween
func build(kind:int) -> void:
 index=kind
 name="Crate%d"%index
 var body=load("res://assets/arrivals/models/crate_body.glb").instantiate();add_child(body)
 Furniture._materials(body,Color(.86,.88,.88),.4)
 lid=Node3D.new();lid.name="LidHinge";add_child(lid);lid.position=Vector3(0,.267,-.315)
 var lid_mesh=load("res://assets/arrivals/models/crate_lid.glb").instantiate();lid.add_child(lid_mesh)
 lid_mesh.position=Vector3(0,0,.315)
 Furniture._materials(lid_mesh,Color(.86,.88,.88),.4)
 var brass:=StandardMaterial3D.new();brass.albedo_color=Color("#aa8750");brass.metallic=.7;brass.roughness=.38
 var dark:=StandardMaterial3D.new();dark.albedo_color=Color("#263e36");dark.roughness=.75
 for x in [-.27,.27]:
  Room.soft_box(self,Vector3(.065,.045,.012),Vector3(x,.244,-.321),brass,.003)
  Room.soft_box(lid,Vector3(.065,.012,.045),Vector3(x,.012,.025),brass,.003)
 Room.soft_box(self,Vector3(.049,.071,.011),Vector3(-.13,.215,.316),brass,.004)
 Room.soft_box(lid,Vector3(.045,.025,.015),Vector3(-.13,.002,.636),brass,.003)
 latch=Node3D.new();latch.name="LatchPivot";add_child(latch);latch.position=Vector3(-.13,.243,.331)
 Room.soft_box(latch,Vector3(.026,.064,.014),Vector3(0,-.03,.006),brass,.005)
 Room.soft_box(latch,Vector3(.014,.032,.017),Vector3(0,-.027,.012),dark,.003)
 for y in [.191,.24]:
  var sphere:=SphereMesh.new();sphere.radius=.004;sphere.height=.008;sphere.radial_segments=12;sphere.rings=6
  var rivet:=MeshInstance3D.new();rivet.mesh=sphere;rivet.material_override=brass;rivet.position=Vector3(-.13,y,.326);add_child(rivet)
 _hit(self,Vector3(.90,.265,.62),Vector3(0,.132,0),"body")
 _hit(lid,Vector3(.916,.05,.636),Vector3(0,.025,.315),"lid")
 _hit(self,Vector3(.085,.095,.04),Vector3(-.13,.225,.346),"latch")
 var paper:=StandardMaterial3D.new();paper.albedo_color=Color("#dacfb2");paper.roughness=.96
 Room.soft_box(self,Vector3(.28,.108,.004),Vector3(.15,.14,.318),paper,.001)
 label=Label3D.new();label.text="LOT "+LOTS[index]+"\n"+TITLES[index]+"\n"+NOTES[index]
 label.font_size=48;label.pixel_size=.00045;label.outline_size=0;label.modulate=Color("#3d392b")
 label.position=Vector3(.15,.14,.322);label.shaded=true;label.double_sided=false;add_child(label)
 covered=load("res://assets/arrivals/covered_blocks/block_%d.scn"%index).instantiate()
 covered.name="CoveredPreparation";add_child(covered)
 var extent:Vector2=covered.get_meta("display_extent")
 var fit:=minf(.72/extent.x,.43/extent.y)
 covered.scale=Vector3.ONE*fit
 covered.position=Vector3(0,.070,0)-Vector3(covered.get_meta("display_center"))*fit
 covered.visible=false
 var pad:=StandardMaterial3D.new();pad.albedo_color=Color("#bfb59d");pad.roughness=1
 for x in [-.37,.37]:
  for z in [-.23,.23]:Room.soft_box(self,Vector3(.07,.09,.065),Vector3(x,.095,z),pad,.014)
func _hit(parent:Node3D,size:Vector3,pos:Vector3,part:String) -> void:
 var body:=StaticBody3D.new();parent.add_child(body);body.position=pos
 body.set_meta("crate",index);body.set_meta("part",part);body.collision_layer=8;body.collision_mask=0
 var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=size;shape.shape=box;body.add_child(shape)
func release_latch() -> void:
 if unlocked:return
 unlocked=true
 if motion!=null:motion.kill()
 motion=create_tween();motion.tween_property(latch,"rotation:x",deg_to_rad(125),.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
func set_opening(value:float) -> void:
 if not unlocked:return
 opening=clampf(value,0,1)
 lid.rotation.x=-deg_to_rad(108)*opening
 covered.visible=opening>.10
func open_fully() -> void:
 if not unlocked:return
 if motion!=null:motion.kill()
 motion=create_tween();motion.tween_method(set_opening,opening,1.0,.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
func reset() -> void:
 if motion!=null:motion.kill()
 unlocked=false;opening=0;lid.rotation=Vector3.ZERO;latch.rotation=Vector3.ZERO;covered.hide()
