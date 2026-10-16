extends "res://tests/run_p6a40_natural_block.gd"
func _pilot_scene() -> PackedScene:
 return preload("res://scenes/preparation/base/friable_pocket.tscn")
func _output_directory() -> String:
 return "res://work/test-logs/p6a47/"
func _collection_store() -> String:
 return "res://work/test-logs/p6a47/collection-test.json"
func _suite_name() -> String:
 return "P6A4.7"
func pocket_point(x: float,y: float) -> Vector2:
 return Vector2(x-30,y+104)
func native_impact(p: Vector2, tool:=1) -> void:
 main.controller.cancel_stroke()
 main.controller.select_tool(tool)
 main.controller._focused = true
 main.controller._pointer_inside = true
 main.controller._screen = at(p)
 main.controller._held = true
 main.controller._physics_process(1.0/60)
 main.controller.cancel_stroke()
func open_pocket() -> int:
 for n in range(4):
  native_impact(pocket_point(516,201))
  if main.pocket.is_open: return n+1
 return 4
func sweep(a: Vector2,b: Vector2,seconds: float) -> void:
 main.controller.select_tool(2)
 var previous := a
 for n in range(roundi(seconds*60)):
  var p := a.lerp(b,float(n+1)/roundi(seconds*60))
  main.block.working_map.apply_continuous(previous,p,main.controller.tools[2],1.0/60)
  previous = p
func native_sweep(a: Vector2,b: Vector2,seconds: float) -> void:
 main.controller.select_tool(2)
 main.controller._focused=true;main.controller._pointer_inside=true
 var press := InputEventMouseButton.new()
 press.button_index=MOUSE_BUTTON_LEFT
 press.pressed=true
 press.position=at(a)
 root.push_input(press,true)
 var frames := roundi(seconds*60)
 for n in range(frames):
  main.block.flush_texture()
  var motion := InputEventMouseMotion.new()
  motion.position=at(a.lerp(b,float(n+1)/frames))
  motion.button_mask=MOUSE_BUTTON_MASK_LEFT
  root.push_input(motion,true)
  main.controller._physics_process(1.0/60)
  await process_frame
 var release := InputEventMouseButton.new()
 release.button_index=MOUSE_BUTTON_LEFT
 release.pressed=false
 release.position=main.controller._screen
 root.push_input(release,true)
func pocket_checks() -> void:
 main.reset_specimen()
 var s: WorkingSurface = main.block.working_map
 var pocket: Node = main.pocket
 var start := s._heights.duplicate()
 var initial := state()
 var bone_cells := 0
 var max_bone := 0.0
 var max_bone_cell := -1
 for i: int in pocket.cells:
  if s.structural_ceilings[i]>0:bone_cells+=1
  if s.structural_ceilings[i]>max_bone:
   max_bone=s.structural_ceilings[i];max_bone_cell=i
 check(bone_cells>2000,"inclusion sits on the skeleton preparation path instead of being an unrelated side hole")
 var cover := s.structural_ceilings.duplicate()
 var actual_floor: PackedFloat32Array = pocket.floors.duplicate()
 s.structural_ceilings.fill(0)
 s.structural_ceilings[max_bone_cell]=max_bone
 pocket.configure()
 check(pocket.floors==actual_floor,"cavity relief never prints buried Bone anatomy through its remaining opaque cover")
 s.structural_ceilings=cover
 pocket.configure()
 var volume: float = pocket.initial_volume
 sweep(pocket_point(460,198),pocket_point(598,198),.8)
 check(state()==initial and not pocket.is_open,"air on the untouched crust cannot excavate solid matrix")
 check(main.controller.tools[2].power==0 and main.controller.tools[2].effectiveness==Vector3.ZERO,"Blower global solid-cutting power remains exactly zero")
 var count_before: int = main.controller.total_impacts
 var strikes := open_pocket()
 check(pocket.is_open and strikes<=3,"a few native Chisel impacts open a readable pocket without a secret point")
 check(main.controller.total_impacts-count_before==strikes,"opening consumes exactly the existing impact cadence")
 var opened_remaining: float = pocket.remaining_volume()/volume
 check(opened_remaining>.95 and s.fossil.exposed_cells==0,"opening retains the grains and never auto-removes the volume or exposes buried Bone")
 var untouched_remote := s._heights.duplicate()
 sweep(pocket_point(650,125),pocket_point(700,125),.2)
 check(s._heights==untouched_remote,"an opened pocket never gives air power on distant solid matrix")
 var previous := s._heights.duplicate()
 var result := s.apply_continuous(pocket_point(516,201),pocket_point(516,201),main.controller.tools[2],1.0/60)
 var actual := 0.0
 var outside := 0
 for i in range(previous.size()):
  actual += previous[i]-s._heights[i]
  if previous[i]!=s._heights[i] and pocket.roofs[i]<=0: outside+=1
 check(result>0 and actual>0 and outside==0,"first air tick removes real granular height only inside the inclusion")
 check(s.last_action.get("pocket_flow",false) and absf(actual-s.last_action.flow_volume)<.0001,"grain feedback reports actual committed volume, not cosmetic progress")
 var remote: int = 305*1024+560
 check(s._heights[remote]==previous[remote],"one air tick never opens the remote intact end of the crust")
 for pass_id in range(3):
  var a := pocket_point(470,195 if pass_id!=1 else 218)
  var b := pocket_point(587,195 if pass_id!=1 else 218)
  sweep(a if pass_id%2==0 else b,b if pass_id%2==0 else a,.70)
 var fraction: float = 1.0-pocket.remaining_volume()/volume
 check(fraction>.80,"three short sweeps evacuate over eighty percent of the authored pocket")
 var min_depth := INF
 var max_depth := 0.0
 var leaks := 0
 var increased := 0
 for i: int in pocket.cells:
  var depth: float = (pocket.roofs[i]-pocket.floors[i])*s.excavatable_depth*1000
  min_depth=minf(min_depth,depth);max_depth=maxf(max_depth,depth)
  if s.structural_ceilings[i]>0 and s._heights[i]<s.structural_ceilings[i]+.0119: leaks+=1
  if s._heights[i]>start[i]: increased+=1
 check(max_depth-min_depth>10 and leaks==0 and increased==0,"real irregular cavity retains a safe cover over Bone and never refills the terrain")
 check(s.fossil.exposed_cells==0 and s.fossil.condition==100,"pocket flow is never a Bone reveal or damage shortcut")
 var upload_count: int = pocket.uploads
 check(absf(pocket.remaining_cache-pocket.remaining_volume())<.001,"incremental volume tracking matches actual remaining height")
 var old_ticks: int = pocket.ticks
 var stable := state()
 for n in range(10):
  main.block.flush_texture()
  await process_frame
 check(state()==stable and pocket.ticks==old_ticks and pocket.uploads==upload_count,"idle pocket has no flow, state edit or atlas upload")
 # Native Brush remains a cleaning tool, not a second granular excavator.
 main.reset_specimen();open_pocket()
 var before_brush := s._heights.duplicate()
 for n in range(10): s.apply_continuous(pocket_point(500,200),pocket_point(535,200),main.controller.tools[0],.1)
 var cut_grains := 0
 for i: int in pocket.cells:
  if before_brush[i]<=pocket.roofs[i]+.0001 and s._heights[i]<before_brush[i]:cut_grains+=1
 check(cut_grains==0,"Brush cannot silently turn into bulk-grain cutting")
 # Air must still work through the real controller and stop when released/focus lost.
 main.controller.select_tool(2)
 main.controller._screen=at(pocket_point(516,201))
 main.controller._focused=true;main.controller._pointer_inside=true;main.controller._held=true
 main.controller._physics_process(1.0/60)
 check(s.last_action.get("pocket_flow",false),"normal held Blower input reaches actual pocket flow")
 main.controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
 var focus_state := state()
 for n in range(6): main.controller._physics_process(1.0/60)
 check(state()==focus_state and not main.controller._held,"focus loss stops air excavation immediately")
 main.controller._focused=true
 main.reset_specimen()
 check(state()==initial and not pocket.is_open and pocket.blown_volume==0 and main.feedback.grain_bursts==0,"R restores exact original preparation, pocket and feedback")
 # A completely exhausted granular column hands back the native Pick integration.
 open_pocket()
 for n in range(90): s.apply_continuous(pocket_point(516,201),pocket_point(516,201),main.controller.tools[2],1.0/60)
 var i: int = 305*1024+486
 check(absf(s._heights[i]-pocket.floors[i])<.00001,"stationary air stops on the real floor instead of eroding solid substrate")
 var tile := s.fracture.partition(pocket_point(516,201),1)
 check(not s.fracture.stress.has(Vector3i(tile.x,tile.y,1)),"evacuated grain column retains no ghost crust fracture on its compact floor")
 var floor_height: float = s._heights[i]
 s.apply_impact(pocket_point(516,201),main.controller.tools[3])
 check(s._heights[i]<floor_height,"native Pick can resume the underlying excavation after grain removal")
 # Temporal partition: the same stationary air duration has the same RF result.
 var timing_results := []
 for hz in [30,60,120]:
  main.reset_specimen();open_pocket()
  for n in range(hz):s.apply_continuous(pocket_point(516,201),pocket_point(516,201),main.controller.tools[2],1.0/hz)
  timing_results.append(digest(s._heights.to_byte_array()))
 check(timing_results[0]==timing_results[1] and timing_results[1]==timing_results[2],"fixed flow substeps make stationary excavation independent of caller frame partition")
 # Several real entry points, not a memorized joint or prescribed opening.
 for p in [pocket_point(480,190),pocket_point(560,195),pocket_point(532,225)]:
  main.reset_specimen()
  for n in range(3):native_impact(p)
  check(pocket.is_open,"ordinary Chisel contact opens the inclusion at "+str(p))
 main.reset_specimen();open_pocket()
 var before_native: float=pocket.remaining_volume()
 await native_sweep(pocket_point(500,200),pocket_point(550,200),.30)
 check(pocket.remaining_volume()<before_native and not main.controller._held,"real mouse drag and release evacuate grains and terminate the stroke")
 var after_native := state()
 main.reset_specimen();open_pocket()
 for n in range(5):sweep(pocket_point(465,195),pocket_point(590,215),.70)
 # Pick one genuinely covered Bone cell in the evacuated centre. The reward
 # still requires the canonical solid removal/exposure path, never air magic.
 var witness := -1
 for j: int in pocket.cells:
  if s.structural_ceilings[j]>0 and absf(s._heights[j]-pocket.floors[j])<.00001:
   if witness<0 or s._heights[j]-s.structural_ceilings[j]<s._heights[witness]-s.structural_ceilings[witness]:witness=j
 check(witness>=0 and s.fossil.exposed_cells==0,"evacuated pocket leads to covered Bone on the actual preparation path")
 var witness_point := Vector2(witness%1024,witness/1024 as int)
 for n in range(3):native_impact(witness_point,3)
 check(s.fossil.exposed[witness]!=0 and s.fossil.condition==100,"a short native Pick finish reveals real Bone without damage after the pocket")
 main.reset_specimen();open_pocket()
 await native_sweep(pocket_point(500,200),pocket_point(550,200),.30)
 after_native = state()
 for n in range(5):main.controller._physics_process(1.0/60)
 check(state()==after_native,"released air never continues excavation or delayed collapse")
 evidence["pocket_design"]={"opening_impacts":strikes,"remaining_after_opening":opened_remaining,"evacuated_after_2_1_seconds":fraction,"depth_mm":[min_depth,max_depth],"cells":pocket.cells.size(),"covered_bone_cells":bone_cells,"last_air_cpu_usec":pocket.flow_usec}
 main.reset_specimen()
func pilot_checks() -> void:
 if mode!="design": await super.pilot_checks()
 await pocket_checks()
func pilot_visual() -> void:
 check(DisplayServer.get_name()!="headless","pocket art uses the native graphical renderer")
 main.reset_specimen()
 main.feedback.proxies_enabled=false
 for proxy in main.feedback.proxies: proxy.hide()
 main.feedback.set_physics_process(false)
 main.camera.set_process(true)
 await zoom_to(2.7,pocket_point(526,201))
 main.camera.set_process(false)
 var intact := await skull_picture("pocket-intact")
 main.mesh_view.model.hide()
 var hidden := await frame_image()
 check(digest(intact.get_data())==digest(hidden.get_data()),"weathered crust contains no buried source pixels or shadow outline")
 main.mesh_view.model.show()
 open_pocket()
 await skull_picture("pocket-opened")
 sweep(pocket_point(490,198),pocket_point(546,202),.35)
 await skull_picture("pocket-first-burst")
 # A native mouse-driven sweep with the real tool visible, captured mid-flow.
 main.feedback.proxies_enabled=true
 await native_sweep(pocket_point(500,200),pocket_point(555,210),.25)
 await settle(2)
 await RenderingServer.frame_post_draw
 var tool_picture := root.get_texture().get_image()
 check(tool_picture.save_png(out+"pocket-native-blower.png")==OK,"capture actual Blower gesture with tool visible")
 evidence.captures.append("pocket-native-blower.png")
 main.feedback.proxies_enabled=false
 for proxy in main.feedback.proxies:proxy.hide()
 for pass_id in range(3):
  sweep(pocket_point(470,195 if pass_id!=1 else 218),pocket_point(587,195 if pass_id!=1 else 218),.70)
 await skull_picture("pocket-cavity-moving-grains")
 # Wait for cosmetic particles before the source-on/off occlusion oracle.
 await create_timer(.8).timeout
 var cavity := await skull_picture("pocket-cavity")
 main.mesh_view.model.hide()
 var empty_without_source := await frame_image()
 check(digest(cavity.get_data())==digest(empty_without_source.get_data()),"evacuated pocket still hides every buried Bone pixel and shadow")
 main.mesh_view.model.show()
 # Freeze actual particles to compare source visibility; they never imply Bone.
 for family in [1,2,3]:main.feedback.particles[family].clear()
 main.reset_specimen()
 await skull_picture("pocket-reset")
 await super.pilot_visual()
