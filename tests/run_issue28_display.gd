extends SceneTree
const Store=preload("res://scripts/collection/exhibit_store.gd")
const Display=preload("res://scripts/collection/exhibit_display.gd")
var checks:=0
var failures:Array[String]=[]
var output:="res://work/issue28/display/"
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func frame() -> Image:
 for i in range(8):await process_frame
 await RenderingServer.frame_post_draw
 return root.get_texture().get_image()
func run() -> void:
 DirAccess.make_dir_recursive_absolute(output)
 root.size=Vector2i(800,500);root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
 root.msaa_3d=Viewport.MSAA_DISABLED;root.use_taa=false
 var store:=Store.new(Store.configured_directory())
 check(not store.manifest.attempts.is_empty(),"test archives available")
 var world:=Node3D.new();root.add_child(world)
 var environment:=WorldEnvironment.new();world.add_child(environment);environment.environment=Environment.new()
 environment.environment.background_mode=Environment.BG_COLOR;environment.environment.background_color=Color(.04,.06,.08)
 environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 environment.environment.ambient_light_color=Color.WHITE;environment.environment.ambient_light_energy=.7
 var camera:=Camera3D.new();world.add_child(camera)
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=.85
 camera.position=Vector3(0,2,0);camera.look_at(Vector3.ZERO,Vector3.FORWARD)
 var tested:Dictionary={}
 for record in store.manifest.attempts:
  var kind:=int(record.kind)
  if tested.has(kind):continue
  tested[kind]=true
  store.manifest.latest[record.specimen_id]=record
  var block:=store.load_block(record.specimen_id)
  check(block!=null,"archive loads "+str(kind))
  if block==null:continue
  var archive_path:String=store.directory.path_join(record.file)
  var file_hash:=FileAccess.get_sha256(archive_path)
  var bone:=block.get_node("ProductionBoneBatch") as MeshInstance3D
  var mat:=bone.material_override as ShaderMaterial
  var maps:Dictionary={}
  for name in ["working_map","fossil_map","production_coverage","bone_film_map","local_damage_map","residue_map"]:
   var texture:Texture2D=mat.get_shader_parameter(name)
   maps[name]=hash(texture.get_image().get_data())
  Display.apply(block)
  var count:=block.find_children("*","MeshInstance3D",true,false).size()
  check(count==4,"one matrix, wall, Bone and caster "+str(kind))
  var shader:=mat.shader
  Display.apply(block)
  check(mat.shader==shader and block.find_children("*","MeshInstance3D",true,false).size()==count,"display adaptation is idempotent "+str(kind))
  for name in maps:
   var texture:Texture2D=mat.get_shader_parameter(name)
   check(hash(texture.get_image().get_data())==maps[name],"display preserves "+name+" "+str(kind))
  check(mat.get_shader_parameter("inspection")!=true,"burial is not disabled "+str(kind))
  world.add_child(block)
  for mesh:MeshInstance3D in block.find_children("*","MeshInstance3D",true,false):mesh.hide()
  var empty:=await frame()
  var original:Texture2D=mat.get_shader_parameter("working_map")
  var buried:=original.get_image().duplicate() as Image;buried.fill(Color(1,0,0,0))
  mat.set_shader_parameter("working_map",ImageTexture.create_from_image(buried))
  bone.show()
  var hidden:=await frame()
  check(empty.get_data()==hidden.get_data(),"fully buried Bone has zero pixels, even with matrix hidden "+str(kind))
  var partial:=original.get_image().duplicate() as Image
  partial.blit_rect(buried,Rect2i(0,0,partial.get_width()/2,partial.get_height()),Vector2i.ZERO)
  mat.set_shader_parameter("working_map",ImageTexture.create_from_image(partial))
  var split:=await frame()
  split.save_png(output+"buried-left-"+str(kind)+".png")
  var left_changes:=0;var right_changes:=0
  for y in range(500):
   for x in range(800):
    if split.get_pixel(x,y)!=empty.get_pixel(x,y):
     if x<397:left_changes+=1
     elif x>403:right_changes+=1
  check(left_changes==0,"buried half has zero visible pixels "+str(kind))
  check(right_changes>500,"exposed half still renders "+str(kind))
  mat.set_shader_parameter("working_map",original)
  check(FileAccess.get_sha256(archive_path)==file_hash,"existing archive bytes untouched "+str(kind))
  block.free()
 check(tested.size()==3,"all three preparation families tested")
 var report:={"checks":checks,"failures":failures}
 FileAccess.open(output+"result.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("EXHIBIT DISPLAY ",JSON.stringify(report))
 world.queue_free();await process_frame;await process_frame;quit(0 if failures.is_empty() else 1)
