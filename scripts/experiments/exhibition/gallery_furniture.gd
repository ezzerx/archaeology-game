extends RefCounted
## Imported props stay separate from architecture and player preparation resources.
const CABINET=preload("res://assets/museum/models/cabinet.glb")
const LAMP=preload("res://assets/museum/models/wall_lamp.glb")

static func _materials(model:Node3D,tint:Color,normal_strength:float) -> void:
 for mesh:MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
  for surface in range(mesh.mesh.get_surface_count()):
   var material:=mesh.get_active_material(surface).duplicate() as StandardMaterial3D
   material.albedo_color=tint;material.normal_scale=normal_strength
   material.roughness=.88;material.metallic_specular=.38
   material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
   mesh.set_surface_override_material(surface,material)

static func install(parent:Node3D) -> void:
 var cabinet:Node3D=CABINET.instantiate();cabinet.name="MuseumCabinet"
 cabinet.scale=Vector3.ONE*(2.65/.98028564453125)
 cabinet.position=Vector3(.10,.01,-1.61);parent.add_child(cabinet)
 _materials(cabinet,Color(.66,.70,.73),.40)
 for i in range(2):
  var lamp:Node3D=LAMP.instantiate();lamp.name="WallLamp"+str(i)
  lamp.scale=Vector3.ONE*.53;lamp.rotation_degrees.y=-90
  # Source back plate is on -X. The rear of the plate touches the wall after rotation.
  lamp.position=Vector3(-1.35 if i==0 else 1.35,2.80,-1.81+.49*.53)
  parent.add_child(lamp);_materials(lamp,Color(.85,.85,.80),.35)
  var bulb_pos:Vector3=lamp.to_global(Vector3(.31,.020,0))
  var bulb:=preload("res://scripts/experiments/exhibition/gallery_lighting.gd").emitter(parent,bulb_pos,.100)
  bulb.name="WallLampBulb"+str(i)
  var pool:=SpotLight3D.new();parent.add_child(pool)
  pool.name="WallLampPool"+str(i)
  pool.position=bulb_pos+Vector3(0,-.035,.035)
  pool.look_at(pool.position+Vector3(0,-1,-.14))
  pool.light_color=Color("#ffe1ad");pool.light_energy=.72
  pool.spot_angle=64;pool.spot_range=2.8;pool.spot_attenuation=1.1;pool.light_size=.10
  pool.shadow_enabled=true;pool.shadow_bias=.025;pool.shadow_normal_bias=.12

 # Warm miniature lights inside the cabinet stay separate from the source mesh.
 for y in [2.24,1.81]:
  var light:=SpotLight3D.new();parent.add_child(light);light.name="CabinetDownlight"+str(y)
  light.position=Vector3(.10,y,-1.40);light.look_at(Vector3(.10,y-.5,-1.69))
  light.light_color=Color("#ffdda6");light.light_energy=.30
  light.spot_range=1.2;light.spot_angle=63;light.spot_attenuation=1.2
