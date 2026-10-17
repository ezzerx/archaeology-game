extends RefCounted
## Small patinated museum plaque on the stand's front ledge; editable text.
static func _material(color:String,metallic:float=0.0) -> StandardMaterial3D:
 var material:=StandardMaterial3D.new()
 material.albedo_color=Color(color);material.roughness=.92
 material.metallic=metallic;material.metallic_specular=.16
 return material

static func _box(parent:Node3D,size:Vector3,position:Vector3,material:Material) -> MeshInstance3D:
 var mesh:=BoxMesh.new();mesh.size=size
 var instance:=MeshInstance3D.new();instance.mesh=mesh;instance.material_override=material
 instance.position=position;parent.add_child(instance);return instance

static func _text(parent:Node3D,text:String,position:Vector3,size:float,font:Font,color:String) -> void:
 var label:=Label3D.new()
 label.text=text;label.font=font;label.font_size=96;label.pixel_size=size/96.
 label.position=position;label.modulate=Color(color);label.outline_size=0
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
 label.shaded=true;label.double_sided=false;label.no_depth_test=false
 label.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 parent.add_child(label)

static func install(parent:Node3D,index:int,position:Vector3,serif:Font,sans:Font) -> Node3D:
 var label:=Node3D.new();label.name="Cartel"+str(index)
 label.position=position;label.rotation_degrees.x=-55;parent.add_child(label)
 var holder:=_material("#352d22",.50)
 var stock:=_material("#776445",.55)
 var brass:=_material("#796b48",.6)
 for x in [-.22,.22]:
  _box(label,Vector3(.03,.17,.075),Vector3(x,0,-.045),holder)
 _box(label,Vector3(.76,.23,.014),Vector3.ZERO,holder)
 _box(label,Vector3(.732,.202,.003),Vector3(0,0,.009),stock)
 for x in [-.345,.345]:
  var pin:=MeshInstance3D.new();var mesh:=CylinderMesh.new()
  mesh.top_radius=.006;mesh.bottom_radius=.006;mesh.height=.004;mesh.radial_segments=12
  pin.mesh=mesh;pin.material_override=brass;pin.position=Vector3(x,-.080,.014)
  pin.rotation_degrees.x=90;label.add_child(pin)
 var code:="B–17" if index==0 else "M–08"
 var title:="Petit théropode" if index==0 else "Ammonite côtelée"
 var origin:="Ravin des Ocres" if index==0 else "Bassin des Aulnes"
 _text(label,code,Vector3(-.303,.068,.012),.030,sans,"#28251d")
 _text(label,title,Vector3(-.303,.005,.012),.050,serif,"#171b16")
 _text(label,origin,Vector3(-.303,-.066,.012),.026,sans,"#28251d")
 return label
