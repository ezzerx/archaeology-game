extends SceneTree
## Native, unlit palette comparison: run Compatibility first, then Forward+.
## --reference=<palette JSON> compares the renderer against the authored colors.
## --palette-include=<path> is useful for before/after investigation.
var output:="res://work/issue28/colors/"
var reference:=""
var include_path:="res://shaders/experiments/preparation_demo.gdshaderinc"
var failures:Array[String]=[]
var checks:=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func field(value:Color) -> ImageTexture:
 var img:=Image.create(2,2,false,Image.FORMAT_RGBAF);img.fill(value)
 return ImageTexture.create_from_image(img)
func run() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--reference="):reference=arg.trim_prefix("--reference=")
  if arg.begins_with("--palette-include="):include_path=arg.trim_prefix("--palette-include=")
  if arg.begins_with("--color-output="):output=arg.trim_prefix("--color-output=").trim_suffix("/")+"/"
 DirAccess.make_dir_recursive_absolute(output)
 root.size=Vector2i(512,256);root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
 root.msaa_3d=Viewport.MSAA_DISABLED;root.use_taa=false
 var world:=Node3D.new();root.add_child(world)
 var environment:=WorldEnvironment.new();world.add_child(environment);environment.environment=Environment.new()
 environment.environment.background_mode=Environment.BG_COLOR
 environment.environment.background_color=Color.BLACK
 environment.environment.tonemap_mode=Environment.TONE_MAPPER_LINEAR
 var camera:=Camera3D.new();world.add_child(camera)
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=2.;camera.position=Vector3(0,0,5)
 var shader:=Shader.new()
 shader.code='shader_type spatial;\nrender_mode unshaded;\nuniform sampler2D working_map;\nuniform vec4 palette_original : source_color=vec4(.34,.34,.34,1.);\nuniform float height=.5;\nuniform bool palette_skirt=false;\n#include "'+include_path+'"\nvoid fragment(){ALBEDO=demo_material(palette_original.rgb,UV,height,palette_skirt);}'
 var cases:Array[Dictionary]=[
  {"name":"compact passthrough","kind":0,"height":.5,"original":Color(.25,.42,.56)},
  {"name":"marine marl","kind":1,"height":.85},
  {"name":"marine loose","kind":1,"height":.65},
  {"name":"marine deep","kind":1,"height":.35},
  {"name":"marine dark contact","kind":1,"height":.65,"original":Color(.08,.07,.05)},
  {"name":"concretion matrix","kind":2,"height":.85},
  {"name":"concretion rind","kind":2,"height":.705,"crust":true},
  {"name":"concretion cut","kind":2,"height":.698,"crust":true}
 ]
 for i in range(cases.size()):
  var c:Dictionary=cases[i]
  var m:=ShaderMaterial.new();m.shader=shader
  m.set_shader_parameter("preparation_demo",c.kind);m.set_shader_parameter("height",c.height)
  m.set_shader_parameter("palette_original",c.get("original",Color(.34,.34,.34)))
  m.set_shader_parameter("demo_geology",field(Color(.7,.4,.8,0)))
  m.set_shader_parameter("demo_deep_geology",field(Color(.38,.2,.6,0)))
  m.set_shader_parameter("demo_crust",field(Color(.6,.71,0,0) if c.get("crust",false) else Color(0,0,0,0)))
  m.set_shader_parameter("working_map",field(Color(c.height,0,0,0)))
  var patch:=MeshInstance3D.new();patch.mesh=QuadMesh.new();patch.material_override=m
  patch.position=Vector3(float(i%4)-1.5,.5-float(i/4),0);world.add_child(patch)
 for n in range(20):await process_frame
 await RenderingServer.frame_post_draw
 var picture:=root.get_texture().get_image()
 var renderer:=RenderingServer.get_current_rendering_method()
 picture.save_png(output+renderer+".png")
 var means:Array=[]
 for i in range(cases.size()):
  var total:=Vector3.ZERO
  for y in range(16,112):
   for x in range(16,112):
    var color:=picture.get_pixel((i%4)*128+x,(i/4)*128+y)
    total+=Vector3(color.r,color.g,color.b)
  total/=96.*96.
  means.append([total.x,total.y,total.z])
  check(total.length()>.02,"nonempty patch: "+cases[i].name)
 var differences:Array=[]
 if not reference.is_empty():
  var baseline=JSON.parse_string(FileAccess.get_file_as_string(reference))
  check(baseline is Dictionary and baseline.get("means",[]).size()==cases.size(),"reference palette available")
  if failures.is_empty():
   for i in range(cases.size()):
    var delta:=0.
    for channel in range(3):delta=maxf(delta,absf(means[i][channel]-baseline.means[i][channel]))
    differences.append(delta)
    check(delta<.012,"color continuity: "+cases[i].name)
 var report:={"renderer":renderer,"checks":checks,"failures":failures,"means":means,"max_channel_difference":differences}
 FileAccess.open(output+renderer+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("EXHIBIT COLORS ",JSON.stringify(report))
 world.queue_free();await process_frame;await process_frame
 quit(0 if failures.is_empty() else 1)
