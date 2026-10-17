extends RefCounted
## A frozen render, deliberately containing no preparation scripts or simulation.
var copies:Dictionary={}

func capture(preparation:Node3D) -> Node3D:
 preparation.controller.cancel_stroke()
 preparation.block.flush_texture()
 preparation._sync_visuals()
 preparation.mesh_view.sync_state()
 var root:=Node3D.new();root.name="PreparedBlock"
 var bounds:=Rect2(preparation.block.footprint.outline[0],Vector2.ZERO)
 for point in preparation.block.footprint.outline:bounds=bounds.expand(point)
 root.set_meta("display_extent",bounds.size*preparation.block.surface_size+Vector2(.012,.012))
 var center:Vector2=(bounds.get_center()-Vector2(.5,.5))*preparation.block.surface_size
 root.set_meta("display_center",Vector3(center.x,0,center.y))
 root.set_meta("snapshot_version",1)
 # Preserve local vertex coordinates: bone/strata shaders address their maps in block space.
 _copy_visible(preparation.block,root,root,preparation.block.global_transform.affine_inverse())
 if not preparation.block.is_ancestor_of(preparation.mesh_view):
  _copy_visible(preparation.mesh_view,root,root,preparation.block.global_transform.affine_inverse())
 return root

func _copy_visible(source:Node,container:Node3D,owner_node:Node3D,from_world:Transform3D) -> void:
 if source is Node3D and not source.is_visible_in_tree():return
 if source is MeshInstance3D and source.mesh!=null:
  var result:=MeshInstance3D.new()
  result.name=source.name
  result.mesh=_resource(source.mesh)
  result.transform=from_world*source.global_transform
  result.cast_shadow=source.cast_shadow
  result.custom_aabb=source.custom_aabb
  result.extra_cull_margin=source.extra_cull_margin
  result.material_override=_resource(source.material_override)
  for i in range(source.mesh.get_surface_count()):
   result.set_surface_override_material(i,_resource(source.get_surface_override_material(i)))
  container.add_child(result);result.owner=owner_node
 for child in source.get_children():_copy_visible(child,container,owner_node,from_world)

func _resource(source:Resource) -> Resource:
 if source==null:return null
 var key:=source.get_instance_id()
 if copies.has(key):return copies[key]
 # Imported textures are immutable assets; dynamic maps must own independent pixels.
 if source is CompressedTexture2D:return source
 if source is ImageTexture:
  var texture:=ImageTexture.create_from_image(source.get_image())
  copies[key]=texture;return texture
 if source is ShaderMaterial:
  var material:=ShaderMaterial.new();copies[key]=material
  material.shader=source.shader.duplicate()
  for uniform in source.shader.get_shader_uniform_list():
   var value=source.get_shader_parameter(uniform.name)
   if value==null:continue
   material.set_shader_parameter(uniform.name,_resource(value) if value is Resource else value)
  material.set_shader_parameter("cursor_visible",false)
  return material
 var result:=source.duplicate(true);copies[key]=result
 return result

static func valid_scene(scene:PackedScene) -> bool:
 if scene==null:return false
 var state:=scene.get_state()
 if state.get_node_count()<2 or state.get_node_count()>100:return false
 for i in range(state.get_node_count()):
  if state.get_node_type(i) not in [&"Node3D",&"MeshInstance3D"]:return false
  for j in range(state.get_node_property_count(i)):
   if state.get_node_property_name(i,j)==&"script":return false
 return true
