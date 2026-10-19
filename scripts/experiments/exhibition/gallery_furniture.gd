extends RefCounted
## Original static cabinet, lighting fixtures, bench and rug; no light nodes.
static func install(parent:Node3D) -> void:
 var furniture:=preload("res://assets/museum/polish/furniture.scn").instantiate()
 furniture.name="MuseumFurniture";parent.add_child(furniture)
 var glass:=StandardMaterial3D.new()
 glass.albedo_color=Color(.77,.82,.72,.045)
 glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 glass.roughness=.18;glass.metallic_specular=.48
 glass.cull_mode=BaseMaterial3D.CULL_BACK
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for x in [-.555,.555]:
  var mesh:=QuadMesh.new();mesh.size=Vector2(.91,1.87)
  st.append_from(mesh,0,Transform3D(Basis.IDENTITY,Vector3(x,2.09,-1.435)))
 var pane:=MeshInstance3D.new();pane.mesh=st.commit();pane.material_override=glass
 pane.name="CabinetGlazing";pane.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 furniture.add_child(pane)
