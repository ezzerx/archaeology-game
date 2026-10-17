extends RefCounted
## Small dimensional courtyard behind the real opening; no generated image or new asset.
static func install(g:Node3D,parent:Node3D) -> void:
 var root:=Node3D.new();root.name="WindowCourtyard";parent.add_child(root)
 var sky:=QuadMesh.new();sky.size=Vector2(12,8)
 var backdrop:=MeshInstance3D.new();backdrop.mesh=sky;backdrop.position=Vector3(-4.48,0,-9)
 var sky_mat:=ShaderMaterial.new();sky_mat.shader=preload("res://shaders/experiments/gallery_window.gdshader")
 backdrop.material_override=sky_mat;backdrop.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(backdrop)
 var wall_mat:=StandardMaterial3D.new();wall_mat.albedo_color=Color("#adba99");wall_mat.roughness=.95
 g.box(root,Vector3(9,.75,.32),Vector3(-4.5,-.45,-4.9),wall_mat)
 var stone:=StandardMaterial3D.new();stone.albedo_color=Color("#d2c5a2");stone.roughness=.95
 g.box(root,Vector3(9,.12,.48),Vector3(-4.5,-.03,-4.9),stone)
 var rng:=RandomNumberGenerator.new();rng.seed=510617
 for tree in range(4):
  var origin:=Vector3(-7.0+tree*1.6,-.65,-3.5-rng.randf_range(0,.35))
  var trunk:=StandardMaterial3D.new();trunk.albedo_color=Color("#746953");trunk.roughness=.95
  g.cylinder(root,.045,1.2,origin+Vector3(0,.5,0),trunk)
  for k in range(40):
   var sphere:=SphereMesh.new();sphere.radius=rng.randf_range(.13,.29);sphere.height=sphere.radius*1.9
   sphere.radial_segments=16;sphere.rings=10
   var mesh:=MeshInstance3D.new();mesh.mesh=sphere
   mesh.position=origin+Vector3(rng.randf_range(-.7,.7),rng.randf_range(.9,1.9),rng.randf_range(-.45,.45))
   var leaf:=StandardMaterial3D.new();leaf.albedo_color=Color("#73925a").lerp(Color("#bfc47a"),rng.randf())
   leaf.roughness=.95;mesh.material_override=leaf;root.add_child(mesh)
 # Subtle glazing: one continuous pane behind the open mullions, with local reflection.
 var glass:=StandardMaterial3D.new();glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 glass.albedo_color=Color(.74,.87,.87,.025);glass.roughness=.12;glass.metallic_specular=.55
 glass.cull_mode=BaseMaterial3D.CULL_DISABLED
 var pane:=MeshInstance3D.new();pane.name="WindowGlass"
 var plane:=QuadMesh.new();plane.size=Vector2(1.20,2.08);pane.mesh=plane
 pane.position=Vector3(-4.48,2.27,-2.39);pane.material_override=glass
 pane.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(pane)


 for mesh:MeshInstance3D in root.find_children("*","MeshInstance3D",true,false):
  mesh.layers=2
 var daylight:=OmniLight3D.new();daylight.name="CourtyardDaylight";root.add_child(daylight)
 daylight.position=Vector3(-4.5,3.5,-4.0);daylight.light_color=Color("#e1eeec")
 daylight.light_energy=1.8;daylight.omni_range=8.;daylight.light_cull_mask=2
