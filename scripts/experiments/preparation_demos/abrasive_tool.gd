extends RefCounted
## Authored lathe profiles: smooth normals, bevels, retaining rings and worn enamel.
static func attach(pose:ToolProxyPose) -> void:
 var ceramic:=_material(Color(.48,.43,.33),0,.06)
 var steel:=_material(Color(.25,.25,.22),.65,.1)
 var brass:=_material(Color(.35,.255,.13),.55,.3)
 var enamel:=_material(Color(.075,.17,.15),.08,.35)
 var dark:=_material(Color(.12,.105,.075),.2,.12)
 _part(pose,[[0.0,0.0],[.002,.0012],[.008,.0019],[.013,.0017]],ceramic,true)
 _part(pose,[[.010,.0012],[.018,.0012],[.022,.0028],[.025,.0028]],steel)
 _part(pose,[[.020,.0028],[.022,.0036],[.030,.0036],[.032,.0032]],brass)
 for n in range(3):
  var y:=.022+n*.0024
  _part(pose,[[y,.00365],[y+.00035,.0039],[y+.0008,.0039],[y+.0011,.00365]],dark)
 _part(pose,[[.030,.0032],[.034,.0042],[.041,.0047],[.062,.0053],[.079,.0048],[.084,.0037]],enamel)
 _part(pose,[[.032,.0041],[.033,.0045],[.035,.0045],[.036,.0043]],brass)
 _part(pose,[[.081,.0046],[.083,.0048],[.087,.0043],[.089,.0030],[.0895,0]],brass)
 # Fine grip rings interrupt the long silhouette without a repetitive corrugated hose.
 for y in [.044,.048,.052]:
  _part(pose,[[y,.00485],[y+.0005,.00505],[y+.001,.0049]],enamel)
 pose.finish()
static func _material(color:Color,metal:float,wear:float) -> ShaderMaterial:
 var mat:=ShaderMaterial.new();mat.shader=preload("res://shaders/experiments/abrasive_tool.gdshader")
 mat.set_shader_parameter("base_color",color);mat.set_shader_parameter("metal",metal);mat.set_shader_parameter("wear",wear)
 return mat
static func _part(pose:ToolProxyPose,profile:Array,material:Material,tip:=false) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rings:=48
 for j in range(profile.size()-1):
  var y0:float=profile[j][0];var r0:float=profile[j][1]
  var y1:float=profile[j+1][0];var r1:float=profile[j+1][1]
  var slope:=(r0-r1)/maxf(y1-y0,.000001)
  for k in range(rings):
   for corner in [[k,y0,r0],[k+1,y1,r1],[k,y1,r1],[k,y0,r0],[k+1,y0,r0],[k+1,y1,r1]]:
    var theta:float=TAU*corner[0]/rings
    st.set_normal(Vector3(cos(theta),slope,sin(theta)).normalized())
    var point:=Vector3(cos(theta)*corner[2],corner[1],sin(theta)*corner[2])
    st.add_vertex(point)
    if not tip:pose._body_vertices.append(point)
 var node:=MeshInstance3D.new();node.mesh=st.commit();node.material_override=material
 node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 (pose.tip if tip else pose.body).add_child(node)
