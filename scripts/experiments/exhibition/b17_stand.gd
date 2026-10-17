extends RefCounted
## Adapter for the original Tripo stand. Source GLB remains untouched.
const MODEL=preload("res://assets/museum/models/b17_stand.glb")
const SOURCE_WIDTH:=.9798583984375
const SOURCE_DEPTH:=.4542846083641052
# Central cloth surface measured on the source mesh: y = intercept - slope * z.
const BED_INTERCEPT:=.25350
const BED_SLOPE:=.5589
const WIDTH:=3.05
const DEPTH:=2.18
const ANGLE:=19.0
const USABLE_EXTENT:=Vector2(2.56,1.40)

static func install(parent:Node3D,center:Vector3) -> Node3D:
 var stand:Node3D=MODEL.instantiate()
 stand.name="B17TripoStand"
 var scale_z:=DEPTH/SOURCE_DEPTH
 var scale_y:=tan(deg_to_rad(ANGLE))*scale_z/BED_SLOPE
 stand.scale=Vector3(WIDTH/SOURCE_WIDTH,scale_y,scale_z)
 stand.position=Vector3(center.x,center.y-BED_INTERCEPT*scale_y-.006,center.z)
 parent.add_child(stand)
 for mesh:MeshInstance3D in stand.find_children("*","MeshInstance3D",true,false):
  for surface in range(mesh.mesh.get_surface_count()):
   var material:=mesh.get_active_material(surface).duplicate() as StandardMaterial3D
   # The source orange varnish is subdued to sit beside the warm ivory and room wood.
   material.albedo_color=Color(.66,.70,.73)
   material.normal_scale=.40
   material.roughness=.88;material.metallic_specular=.38
   material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
   mesh.set_surface_override_material(surface,material)
  mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 stand.set_meta("source_original","res://assets/museum/source/tripo-studio/b17/museum_b17_stand_pilot.glb")
 stand.set_meta("bed_extent",USABLE_EXTENT)
 stand.set_meta("bed_angle_degrees",ANGLE)
 stand.set_meta("plinth_height",stand.position.y)
 return stand
