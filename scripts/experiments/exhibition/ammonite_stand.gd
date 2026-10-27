extends RefCounted
## Source cloth sampled at x=0, +/-0.28: y = .46096 - .5705*z.
const MODEL=preload("res://assets/museum/models/ammonite_stand.glb")
const WIDTH:=2.10
const DEPTH:=2.16
const USABLE_EXTENT:=Vector2(1.68,1.49)
static func install(parent:Node3D,center:Vector3) -> Node3D:
 var stand:Node3D=MODEL.instantiate();stand.name="AmmoniteTripoStand"
 var scale_z:=DEPTH/.7266235947608948
 var scale_y:=tan(deg_to_rad(19.0))*scale_z/.5705
 stand.scale=Vector3(WIDTH/.980804443359375,scale_y,scale_z)
 stand.position=Vector3(center.x,center.y-.46096*scale_y-.006,center.z)
 parent.add_child(stand)
 for mesh:MeshInstance3D in stand.find_children("*","MeshInstance3D",true,false):
  for surface in range(mesh.mesh.get_surface_count()):
   var material:=mesh.get_active_material(surface).duplicate() as StandardMaterial3D
   material.albedo_color=Color(.72,.74,.75);material.normal_scale=.40
   material.roughness=1.0;material.metallic_specular=.43
   material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
   mesh.set_surface_override_material(surface,material)
 stand.set_meta("plinth_height",stand.position.y)
 return stand
