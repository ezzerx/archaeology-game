extends RefCounted
## Imported props stay separate from architecture and player preparation resources.
const CABINET=preload("res://assets/museum/models/cabinet.glb")
const LAMP=preload("res://assets/museum/models/wall_lamp.glb")

static func _materials(model:Node3D,tint:Color,normal_strength:float) -> void:
 for mesh:MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
  for surface in range(mesh.mesh.get_surface_count()):
   var material:=mesh.get_active_material(surface).duplicate() as StandardMaterial3D
   material.albedo_color=tint;material.normal_scale=normal_strength
   mesh.set_surface_override_material(surface,material)

static func install(parent:Node3D) -> void:
 var cabinet:Node3D=CABINET.instantiate();cabinet.name="MuseumCabinet"
 cabinet.scale=Vector3.ONE*(2.65/.98028564453125)
 cabinet.position=Vector3(.10,.01,-1.61);parent.add_child(cabinet)
 _materials(cabinet,Color(.52,.60,.67),.65)
 for i in range(2):
  var lamp:Node3D=LAMP.instantiate();lamp.name="WallLamp"+str(i)
  lamp.scale=Vector3.ONE*.53;lamp.rotation_degrees.y=-90
  # Source back plate is on -X. The rear of the plate touches the wall after rotation.
  lamp.position=Vector3(-1.35 if i==0 else 1.35,2.80,-1.81+.49*.53)
  parent.add_child(lamp);_materials(lamp,Color(.72,.77,.80),.45)
  var pool:=SpotLight3D.new();parent.add_child(pool)
  pool.name="WallLampPool"+str(i)
  pool.position=lamp.position+Vector3(0,.03,.18)
  pool.look_at(pool.position+Vector3(0,-1,-.14))
  pool.light_color=Color("#ffe1ad");pool.light_energy=.11
  pool.spot_angle=64;pool.spot_range=2.8;pool.spot_attenuation=1.3
  pool.shadow_enabled=true;pool.shadow_bias=.025;pool.shadow_normal_bias=.12
