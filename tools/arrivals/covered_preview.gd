extends RefCounted
## Fixed, fully buried previews need neither excavation-density grids nor bones.
static func optimize(frozen:Node3D) -> Dictionary:
 var surface:=frozen.get_node("SurfaceMesh") as MeshInstance3D
 var original:=surface.mesh as PlaneMesh
 assert(original!=null)
 var plane:=PlaneMesh.new()
 plane.size=original.size;plane.center_offset=original.center_offset;plane.orientation=original.orientation
 plane.subdivide_width=255;plane.subdivide_depth=159
 surface.mesh=plane
 var removed:=0
 for mesh in frozen.get_children():
  if str(mesh.name).begins_with("ProductionBone"):
   mesh.free();removed+=1
 frozen.set_meta("arrival_preview_grid",Vector2i(256,160))
 return {"surface_triangles":256*160*2,"buried_bone_meshes_removed":removed,"original_maps_preserved":true}
