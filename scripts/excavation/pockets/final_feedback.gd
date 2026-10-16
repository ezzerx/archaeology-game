extends "res://scripts/preparation/tactile/cleaning_feedback.gd"
const GRAIN_CAP:=176
var grain_interval:=0.0
var grain_bursts:=0
var contact_bursts:=0
var grain_pool:MultiMesh
var grain_view:MultiMeshInstance3D
var grains:Array[Dictionary]=[]
var floor_cursor:=0
var last_floor_samples:=0
func setup(target:ExcavationBlock,input:ToolController) -> void:
 super.setup(target,input)
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var vertices:=[Vector3(-.55,0,-.4),Vector3(.4,.04,-.55),Vector3(.58,0,.3),Vector3(-.36,-.04,.5),Vector3(.08,.38,.03),Vector3(-.08,-.30,-.04)]
 for n in range(4):
  var m:=(n+1)%4
  for i in [4,m,n,5,n,m]:st.add_vertex(vertices[i])
 st.generate_normals()
 grain_pool=MultiMesh.new()
 grain_pool.transform_format=MultiMesh.TRANSFORM_3D
 grain_pool.use_colors=true
 grain_pool.mesh=st.commit()
 grain_pool.instance_count=GRAIN_CAP
 grain_pool.visible_instance_count=0
 grain_view=MultiMeshInstance3D.new()
 grain_view.multimesh=grain_pool
 var mat:=StandardMaterial3D.new()
 mat.vertex_color_use_as_albedo=true;mat.roughness=1;mat.metallic_specular=0
 grain_view.material_override=mat
 grain_view.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(grain_view)
func on_action(event:Dictionary) -> void:
 super.on_action(event)
 if not event.get("pocket_flow",false):return
 sweep_remaining=.12
 if grain_interval>0 or not particles_enabled:return
 grain_interval=.055;grain_bursts+=1
 audio.play_family(&"air",.45)
 _release_grains(event.grain_sources,event.direction,3,false)
 _dust(event.point,Color(.43,.31,.18),1,.004,Vector3(event.direction.x,0,event.direction.y)*.10)
func contact_release(sources:Array[Vector3]) -> void:
 if not particles_enabled:return
 contact_bursts+=1
 _release_grains(sources,Vector2(-1,-1).normalized(),1,true)
func _release_grains(sources:Array[Vector3],direction:Vector2,count:int,contact:bool) -> void:
 for source in sources:
  for n in range(count):
   if grains.size()>=GRAIN_CAP:return
   var size_roll:=rng.randf()
   var width:=rng.randf_range(.00075,.00125) if size_roll<.60 else (rng.randf_range(.0014,.0021) if size_roll<.92 else rng.randf_range(.0025,.0033))
   var origin:=point_world(Vector2(source.x,source.z))
   origin.y=block.base_height+source.y*block.working_map.excavatable_depth+.0015
   var rolling:=not contact and n==0
   var lifetime:=rng.randf_range(.28,.46) if rolling else rng.randf_range(.35,.56)
   var velocity:=Vector3(direction.x,0,direction.y)*rng.randf_range(.055,.10)
   velocity+=Vector3(rng.randf_range(-.012,.012),rng.randf_range(.025,.045) if rolling else rng.randf_range(.075,.115),rng.randf_range(-.012,.012))
   if contact:velocity*=.55
   grains.append({"position":origin,"velocity":velocity,"life":lifetime,"rotation":rng.randf_range(-PI,PI),
    "shape":Vector3(width,width*.65,width*.8),"floor":origin.y-.006,"rolling":rolling,
    "color":Color(.18,.12,.055).lerp(Color(.34,.245,.135),rng.randf())})
func _process(delta:float) -> void:
 grain_interval=maxf(0,grain_interval-delta)
 super._process(delta)
 if grain_pool==null:return
 last_floor_samples=0
 for i in range(grains.size()-1,-1,-1):
  var grain:Dictionary=grains[i]
  grain.life-=delta
  if grain.life<=0:grains.remove_at(i);continue
  grain.velocity.y-=delta*.65
  grain.position+=grain.velocity*delta
  if grain.rolling and last_floor_samples<12 and (i+floor_cursor)%3==0:
   var uv:=SurfaceMapping.local_to_uv(grain.position,block.surface_size)
   if uv.x<0 or uv.x>1 or uv.y<0 or uv.y>1:grains.remove_at(i);continue
   var actual:float=block.relief.height_at(uv)+grain.shape.x*.35
   last_floor_samples+=1
   if actual-grain.position.y>.005:grains.remove_at(i);continue
   grain.floor=actual
  if grain.position.y<grain.floor:
   grain.position.y=grain.floor
   grain.velocity*=Vector3(.84,-.18,.84)
 floor_cursor+=1
 for i in range(grains.size()):
  var grain:Dictionary=grains[i]
  var fade:=minf(1,grain.life/.09)
  var basis:=Basis(Vector3(.3,1,.2).normalized(),grain.rotation+grain.life*8).scaled(grain.shape*fade)
  grain_pool.set_instance_transform(i,Transform3D(basis,grain.position))
  grain_pool.set_instance_color(i,grain.color)
 grain_pool.visible_instance_count=grains.size()
func reset() -> void:
 super.reset()
 grains.clear();grain_interval=0;grain_bursts=0;contact_bursts=0
 if grain_pool!=null:grain_pool.visible_instance_count=0
