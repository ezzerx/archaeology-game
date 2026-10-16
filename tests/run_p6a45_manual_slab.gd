extends "res://tests/run_p6a40_natural_block.gd"
var pre_release_heights := PackedFloat32Array()
var pre_release_exposure := PackedByteArray()
func _pilot_scene() -> PackedScene:
 return preload("res://scenes/p6a45_manual_slab.tscn")
func _output_directory() -> String:
 return "res://work/test-logs/p6a45/"
func _collection_store() -> String:
 return "res://work/test-logs/p6a45/collection-test.json"
func _suite_name() -> String:
 return "P6A4.5"
func brush_joint(p: Vector2) -> void:
 for n in range(4):
  main.block.working_map.apply_continuous(p+Vector2(-12 if n%2==0 else 12,0),p+Vector2(12 if n%2==0 else -12,0),main.controller.tools[0],.12)
func track_commit(event: Dictionary) -> void:
 if event.get("slab_detached",false): return
 pre_release_heights = main.block.working_map._heights.duplicate()
 pre_release_exposure = main.block.working_map.fossil.exposed.duplicate()
func native_click(p: Vector2) -> void:
 main.controller.cancel_stroke()
 main.controller.select_tool(3)
 main.controller._focused = true
 main.controller._pointer_inside = true
 main.controller._screen = at(p)
 main.controller._held = true
 main.controller._physics_process(1.0/60)
 main.controller.cancel_stroke()
func release_pointer() -> void:
 var event := InputEventMouseButton.new()
 event.button_index = MOUSE_BUTTON_LEFT
 event.pressed = false
 event.position = main.controller._screen
 root.push_input(event,true)
func press_lever(p: Vector2) -> void:
 release_pointer()
 main.controller.cancel_stroke()
 main.controller.select_tool(3)
 main.controller._focused = true
 main.controller._pointer_inside = true
 var event := InputEventMouseButton.new()
 event.button_index = MOUSE_BUTTON_LEFT
 event.pressed = true
 event.position = at(p)
 root.push_input(event,true)
func drag_lever(amount: float) -> void:
 var motion := InputEventMouseMotion.new()
 motion.position = main.controller.lever_start+Vector2(0,root.get_visible_rect().size.y*.04*amount)
 motion.button_mask = MOUSE_BUTTON_MASK_LEFT
 main.controller._input(motion)
 main.controller._physics_process(1.0/60)
func manual_extract(p: Vector2) -> void:
 pre_release_heights = main.block.working_map._heights.duplicate()
 pre_release_exposure = main.block.working_map.fossil.exposed.duplicate()
 press_lever(p)
 drag_lever(1.05)
 release_pointer()
func make_mobile() -> void:
 main.reset_specimen()
 for p in [Vector2(475,202),Vector2(536,202),Vector2(525,240)]: brush_joint(p)
 for p in [Vector2(475,202),Vector2(536,202),Vector2(525,240)]: native_click(p)
func pilot_checks() -> void:
 await super.pilot_checks()
 make_mobile()
 check(main.slab.mobile and not main.slab.released,"joint work reaches mobile state without removing plate")
 var untouched := state()
 var count_before: int = main.controller.total_impacts
 press_lever(Vector2(525,240))
 check(main.controller.lever_drag,"real mouse press captures a lever only on a freed joint")
 for n in range(30): main.controller._physics_process(1.0/60)
 check(state() == untouched and not main.slab.released and main.controller.total_impacts == count_before,"holding still neither extracts nor repeats native Pick impacts")
 drag_lever(.55)
 check(main.slab.dragging and main.slab.lever_progress > .5 and state() == untouched,"partial lever changes presentation only, not heights or Bone")
 main.slab._process(.1)
 main.feedback._update_proxy_pose(3)
 var expected_tip: Vector3 = main.controller.lever_hit.world+Vector3.UP*clampf((main.slab.lever_anchor.y-175)/90,0,1)*main.slab.visual_progress*.004
 check(main.feedback.proxies[3].global_position.distance_to(expected_tip) < .000001,"lever Pick tip remains anchored to the lifting joint")
 drag_lever(-.3)
 check(main.slab.lever_progress == 0 and not main.slab.released,"reverse gesture never extracts")
 drag_lever(.55)
 var release := InputEventMouseButton.new()
 release.button_index = MOUSE_BUTTON_LEFT
 release.pressed = false
 release.position = main.controller._screen
 root.push_input(release,true)
 await settle(15)
 check(not main.controller.lever_drag and not main.slab.dragging and main.slab.visual_progress == 0 and state() == untouched,"early release rests the plate and keeps the exact preparation")
 for cause in ["tool", "focus", "exit", "zoom", "reset", "UI", "resize", "session"]:
  make_mobile()
  var stable := state()
  press_lever(Vector2(525,240))
  check(main.controller.lever_drag,"cancellation scenario starts with a genuinely captured mouse gesture: "+cause)
  drag_lever(.5)
  match cause:
   "tool": main.controller.select_tool(1)
   "focus": main.controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
   "exit": main.controller._notification(Node.NOTIFICATION_WM_MOUSE_EXIT)
   "zoom": main.camera.reset_view()
   "reset": main.reset_specimen()
   "UI":
    var blocker := Control.new()
    blocker.position = main.controller._screen-Vector2.ONE*30
    blocker.size = Vector2.ONE*60
    main.add_child(blocker)
    main.controller.ui_blockers.append(blocker)
    main.controller._physics_process(1.0/60)
    main.controller.ui_blockers.erase(blocker)
    blocker.free()
   "resize": main.controller._update_pointer_position()
   "session":
    main.session.archived = true
    main.controller._physics_process(1.0/60)
    main.session.archived = false
  check(not main.controller.lever_drag and not main.slab.released,"lever cancels safely on "+cause)
  if cause != "reset": check(state() == stable,"cancel preserves exact preparation: "+cause)
 make_mobile()
 check(not main.slab.can_lever(Vector2(480,170),main.controller.tools[3]),"unexposed Clay does not provide a grip")
 check(not main.slab.can_lever(Vector2(525,240),main.controller.tools[1]),"Chisel cannot perform the Pick lever")
 manual_extract(Vector2(525,240))
 check(main.slab.release_reason == "manual_joint","dispatched viewport mouse events complete a manual joint extraction")
 var committed := state()
 var committed_count: int = main.slab.release_count
 drag_lever(2)
 check(state() == committed and main.slab.release_count == committed_count,"successful extraction commits once and cannot repeat")
 main.reset_specimen()
 var slab: Node = main.slab
 var s: WorkingSurface = main.block.working_map
 var joints := [Vector2(475,202),Vector2(536,202),Vector2(525,240)]
 var initial := state()
 var reference := WorkingSurface.new(s.size,Stratigraphy.new(s.size,main.block.material_definitions),s.fossil.field)
 var baseline: RefCounted = preload("res://scripts/p6a41/rough_profile.gd").new(reference,main.block.footprint,main.block.rim)
 var outside_heights := 0
 var changed_heights := 0
 var wrong_soil := 0
 for i in range(s._heights.size()):
  if s._heights[i] != baseline.fragmented_top[i]:
   changed_heights += 1
   @warning_ignore("integer_division")
   if not slab.layout.BOUNDS.has_point(Vector2i(i%1024,i/1024)): outside_heights += 1
  if main.block.footprint.mask[i] != 0 and absf((main.profile.fragmented_top[i]-main.profile.substrates[1][i])-(baseline.fragmented_top[i]-baseline.substrates[1][i])) > .000001: wrong_soil += 1
 check(outside_heights == 0 and changed_heights > 10000 and wrong_soil == 0,"natural relief is local and keeps the exact accepted loose Soil quantity")
 check(main.profile.covered_cells > 3000 and main.profile.exposed_cells > 4000 and main.profile.groove_cells > 500,"real partial Clay burial and relief grooves coexist with readable Stone")
 var changed_layers := 0
 var wrong_layers := 0
 var unsafe := 0
 for i in range(s._heights.size()):
  if s.strata.packed_limits[i*2] != baseline.limits[1][i*2] or s.strata.packed_limits[i*2+1] != baseline.limits[1][i*2+1]:
   changed_layers += 1
   @warning_ignore("integer_division")
   if not slab.layout.BOUNDS.has_point(Vector2i(i%1024,i/1024)): wrong_layers += 1
  if slab.targets.has(i) and s.fossil.field.component_ids[i] != 0 and slab.targets[i] <= s.structural_ceilings[i]: unsafe += 1
 check(changed_layers > 10000 and wrong_layers == 0,"real sandstone bed changes only the authored plate and short geological transition")
 check(unsafe == 0 and s.fossil.exposed_cells == 0,"plate floor never cuts through Bone and initial matrix remains buried")
 for index in range(4):
  var expected: ToolDefinition = load(["res://config/soft_brush.tres","res://config/chisel.tres","res://config/air_blower.tres","res://config/precision_pick.tres"][index])
  if index == 1:
   # Accepted runtime playtest overrides, not the older P4 resource defaults.
   expected = expected.duplicate()
   expected.radius = 26.0
   expected.power = .84
  var tool: ToolDefinition = main.controller.tools[index]
  check(tool.radius == expected.radius and tool.power == expected.power and tool.cadence == expected.cadence and tool.effectiveness == expected.effectiveness and tool.falloff == expected.falloff,"accepted tool settings preserved: "+str(index))
 var dirt_point := Vector2(-1,-1)
 for i: int in slab.layout.distances:
  if slab.targets.has(i) and s._heights[i] > s.strata.packed_limits[i*2]+.002:
   @warning_ignore("integer_division")
   dirt_point = Vector2(i%1024,i/1024)
   break
 check(dirt_point.x > 0,"authored fissure has an actually Soil-covered witness")
 check(not slab.accepts_contact(dirt_point,main.controller.tools[3]),"Soil-covered crack cannot accept a joint strike")
 s.apply_impact(dirt_point,main.controller.tools[3])
 check(slab.strikes.is_empty(),"an impact revealing a previously covered joint earns no premature credit")
 main.reset_specimen()
 var covered_point := Vector2(-1,-1)
 for i: int in slab.layout.distances:
  if slab.targets.has(i) and s.strata.packed_limits[i*2]-s.strata.packed_limits[i*2+1] > .012 and slab.layout.distances[i] < 1:
   @warning_ignore("integer_division")
   covered_point = Vector2(i%1024,i/1024)
   break
 check(covered_point.x > 0,"witness joint is actually under more than 1 mm of Clay")
 var covered_index := int(covered_point.y)*1024+int(covered_point.x)
 var smooth_clay_top: float = baseline.limits[1][covered_index*2]+(slab.layout.relief_mm(covered_point)+slab.layout.cover_mm(covered_point))/(s.excavatable_depth*1000.0)
 check(absf(s.strata.packed_limits[covered_index*2]-smooth_clay_top) < .000001,"real Clay fills the hidden groove instead of imprinting its outline on the covering surface")
 brush_joint(covered_point)
 check(not slab.accepts_contact(covered_point,main.controller.tools[3]),"Brush cannot activate a joint still covered in structural Clay")
 native_click(covered_point)
 check(slab.strikes.is_empty(),"native Pick removing Clay gives no premature Stone-joint credit")
 native_click(covered_point)
 check(slab.strikes.size() == 1,"freshly exposed Stone joint accepts the next real impact")
 main.reset_specimen()
 for p: Vector2 in joints: brush_joint(p)
 var zero: ToolDefinition = main.controller.tools[3].duplicate()
 zero.power = 0
 var before := state()
 s.apply_impact(joints[0],zero)
 check(state() == before and slab.strikes.is_empty(),"zero-power tool does not weaken or remove a plate")
 s.apply_impact(Vector2(500,192),main.controller.tools[3])
 check(slab.strikes.is_empty(),"Pick away from every authored fissure remains ordinary excavation")
 main.reset_specimen()
 for p: Vector2 in joints: brush_joint(p)
 s.apply_impact(joints[0],main.controller.tools[3])
 for n in range(5): s.apply_impact(joints[0],main.controller.tools[3])
 check(slab.strikes.size() == 1 and not slab.released,"hammering the same opened point cannot farm the joint bonus")
 var outcomes := []
 for order in [[0,1,2],[2,0,1],[1,2,0]]:
  main.reset_specimen()
  for p: Vector2 in joints: brush_joint(p)
  s.material_action.connect(track_commit)
  for n in range(3):
   native_click(joints[order[n]])
   check(not slab.released and slab.mobile == (n == 2),"distributed real Pick impacts loosen without automatic removal: "+str(order)+" / "+str(n))
  s.material_action.disconnect(track_commit)
  manual_extract(joints[order[2]])
  check(slab.release_count == 1 and slab.released_cells > 9000,"one bounded plate release removes a consequential real volume")
  var outside := 0
  var increased := 0
  var count := 0
  for i in range(s._heights.size()):
   if s._heights[i] == pre_release_heights[i]: continue
   count += 1
   if not slab.targets.has(i): outside += 1
   if s._heights[i] > pre_release_heights[i]: increased += 1
  check(outside == 0 and increased == 0 and count == slab.released_cells,"bonus commit removes only remaining plate cells and never fills terrain")
  var actual_volume := 0.0
  for i in range(s._heights.size()): actual_volume += pre_release_heights[i]-s._heights[i]
  var removed: Vector3 = s.last_action.removed
  check(removed.y > 0 and absf(removed.x+removed.y+removed.z-actual_volume) < .001,"carried Clay/Soil and Stone account for exactly the real removed volume")
  var arrays: Array = slab.piece.mesh.surface_get_arrays(0)
  var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
  var mesh_normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
  var mesh_indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
  var wrong_winding := 0
  for n in range(0,mesh_indices.size(),3):
   var a: int = mesh_indices[n]
   var b: int = mesh_indices[n+1]
   var c: int = mesh_indices[n+2]
   var cross := (vertices[b]-vertices[a]).cross(vertices[c]-vertices[a])
   if cross.dot(mesh_normals[a]+mesh_normals[b]+mesh_normals[c]) > .00000001: wrong_winding += 1
  check(wrong_winding == 0,"clockwise closed-mesh faces agree with outward normals while shadows remain enabled")
  var error := 0.0
  for n in range(slab.mesh_points.size()):
   var h: float = maxf(slab.cached_floor[n],slab.sample_grid(pre_release_heights,slab.mesh_points[n]))
   error = maxf(error,absf(vertices[n].y+ .08-(main.block.base_height+h*s.excavatable_depth)))
  check(error < .0000001,"continuous detached top follows the real filtered relief, including native impact holes")
  check(s.fossil.exposed == pre_release_exposure and s.fossil.condition == 100,"release itself neither reveals buried Bone nor damages the fossil")
  check(is_instance_valid(slab.piece) and slab.piece.mesh.get_faces().size() > 3000 and slab.piece.find_children("*","CollisionObject3D",true,false).is_empty(),"actual remaining matrix produces a bounded non-pickable detached piece")
  var cached_builds: int = slab.mesh_cache_builds
  var uploads: int = slab.uploads
  for n in range(10): main.block.flush_texture()
  check(cached_builds == slab.mesh_cache_builds and uploads == slab.uploads and slab.image.get_data().count(0) == slab.image.get_data().size(),"released joint clears its texture and performs no idle uploads")
  outcomes.append({"order":order,"removed_cells":count,"release_usec":slab.release_usec,"triangles":slab.piece.mesh.get_faces().size()/3})
  await create_timer(.65).timeout
  var on_bench := true
  for v: Vector3 in slab.piece.mesh.get_faces():
   var p: Vector3 = slab.piece.transform*v
   if main.block.footprint.contains_uv(Vector2(p.x/1.1,p.z/.7)+Vector2.ONE*.5): on_bench = false
  check(on_bench,"detached stone lands entirely outside the excavation domain")
  main.reset_specimen()
  check(state() == initial and slab.strikes.is_empty() and not is_instance_valid(slab.piece) and not slab.released,"reset restores geology/cracks and immediately frees the old piece")
 main.reset_specimen()
 for p: Vector2 in joints: brush_joint(p)
 for p: Vector2 in joints: s.apply_impact(p,main.controller.tools[1])
 check(slab.strikes.is_empty() and not slab.released,"three broad Chisel hits do not receive precision-joint credit")
 var brute_impacts := 3
 for n in range(8):
  for y in range(185,251,18):
   for x in range(455,585,18):
    if slab.mobile: break
    s.apply_impact(Vector2(x,y),main.controller.tools[1])
    brute_impacts += 1
 check(slab.mobile and not slab.released,"normal Chisel erosion loosens unsupported matrix without auto-removal")
 var eroded_grip := Vector2(-1,-1)
 for i: int in slab.targets:
  @warning_ignore("integer_division")
  var p := Vector2(i%1024,i/1024)
  if slab.can_lever(p,main.controller.tools[3]): eroded_grip = p; break
 check(eroded_grip.x > 0,"eroded remaining matrix offers an actual exposed grip")
 manual_extract(eroded_grip)
 check(slab.released and slab.release_reason == "manual_erosion","eroded matrix also requires a conscious final lever gesture")
 await create_timer(.65).timeout
 var lowest := INF
 var landed_arrays: Array = slab.piece.mesh.surface_get_arrays(0)
 var landed_vertices: PackedVector3Array = landed_arrays[Mesh.ARRAY_VERTEX]
 for i: int in landed_arrays[Mesh.ARRAY_INDEX]: lowest = minf(lowest,(slab.piece.transform*landed_vertices[i]).y)
 check(absf(lowest-.002) < .000001,"an eroded piece lands using only its remaining rendered volume")
 evidence["natural_art"] = {"covered_cells":main.profile.covered_cells,"exposed_stone_cells":main.profile.exposed_cells,"groove_cells":main.profile.groove_cells,"outline_points":slab.layout.POLYGON.size(),"mesh_cache_builds":slab.mesh_cache_builds}
 evidence["slab"] = {"plate_cells":slab.targets.size(),"changed_geology_cells":changed_layers,"distributed_pick_impacts":3,"brute_chisel_impacts":brute_impacts,"outcomes":outcomes}
 main.reset_specimen()
func light_samples(picture: Image) -> Dictionary:
 var samples := []
 for z in [-.24,0.0,.24]:
  for x in [-.42,0.0,.42]: samples.append(plate_sample(picture,x,z))
 var minimum: float = samples.min()
 var maximum: float = samples.max()
 return {"samples":samples,"range_relative":(maximum-minimum)/maximum,"centre":samples[4]}
func uniform_light_visual() -> void:
 main.feedback.proxies_enabled = false
 for proxy in main.feedback.proxies: proxy.hide()
 main.feedback.set_physics_process(false)
 main.reset_specimen()
 await zoom_to(1)
 main.block.hide()
 var plate := MeshInstance3D.new()
 var mesh := PlaneMesh.new()
 mesh.size = Vector2(1.1,.7)
 plate.mesh = mesh
 plate.position.y = .121
 var material := StandardMaterial3D.new()
 material.albedo_color = Color(.15,.15,.15)
 material.roughness = 1
 plate.material_override = material
 main.add_child(plate)
 var key: DirectionalLight3D = main.get_node("TableEnvironment/Light")
 var next := await skull_picture("neutral-uniform")
 main.task_light.light_energy = 1.2
 main.task_light.spot_angle = 50
 main.task_light.spot_angle_attenuation = 1.3
 main.task_light.spot_attenuation = 1.1
 main.bench_bounce.light_energy = .3
 key.light_energy = .2
 var previous := await skull_picture("neutral-previous")
 var a := light_samples(next)
 var b := light_samples(previous)
 evidence["illumination"] = {"new":a,"previous":b,"x":[-.42,0,.42],"z":[-.24,0,.24],"patch_pixels":25}
 check(a.range_relative < .12 and a.range_relative < b.range_relative*.5,"centre/corners brightness range is below 12 percent and at least halved")
 check(a.centre < b.centre and a.samples.min() >= b.samples.min()*.8,"centre hotspot reduced without crushing the darker extremities")
 main._uniform_light()
 plate.free()
 main.block.show()
 main.prepare_native_skeleton_review()
 P5Fixture.clean(main.block.working_map)
 var shadowed := await skull_picture("prepared-uniform")
 main.mesh_view.shadows_enabled = false
 var without_shadow := await frame_image()
 var darker := 0
 for y in range(130,630):
  for x in range(200,1180):
   if without_shadow.get_pixel(x,y).get_luminance()-shadowed.get_pixel(x,y).get_luminance() > .025: darker += 1
 check(darker > 200,"uniform lighting retains visible shadows from actually exposed bones")
 evidence["bone_shadow_pixels"] = darker
 main.mesh_view.shadows_enabled = true
 main.reset_specimen()
func pilot_visual() -> void:
 check(DisplayServer.get_name() != "headless","native renderer required")
 await uniform_light_visual()
 main.feedback.set_physics_process(false)
 main.feedback.proxies_enabled = false
 main.reset_specimen()
 await zoom_to(1)
 var intact := await skull_picture("slab-intact-overview")
 main.mesh_view.model.hide()
 var no_source := await frame_image()
 check(intact.get_data() == no_source.get_data(),"cracked matrix never reveals any fully buried source pixel")
 main.mesh_view.model.show()
 for p: Vector2 in [Vector2(475,202),Vector2(536,202),Vector2(525,240)]: brush_joint(p)
 await zoom_to(2,Vector2(520,216))
 var hidden_joint := Vector2(-1,-1)
 var s: WorkingSurface = main.block.working_map
 for i: int in main.slab.layout.distances:
  if not main.slab.targets.has(i) or main.slab.layout.distances[i] > 1: continue
  var covered := true
  for off in [-2050,-2048,-2046,-2,0,2,2046,2048,2050]:
   if s.strata.packed_limits[(i+off)*2]-s.strata.packed_limits[(i+off)*2+1] < .012: covered = false
  if covered:
   @warning_ignore("integer_division")
   hidden_joint = Vector2(i%1024,i/1024)
   break
 check(hidden_joint.x > 0,"native witness has a joint still buried under real Clay")
 brush_joint(hidden_joint)
 var cracks := await skull_picture("slab-joints-close")
 main.block.material.set_shader_parameter("slab_cracks",ImageTexture.create_from_image(Image.create(1024,640,false,Image.FORMAT_RG8)))
 var without := await frame_image()
 var covered_center := Vector2i(at(hidden_joint)*Vector2(root.size)/Vector2(root.content_scale_size))
 var covered_box := Rect2i(covered_center-Vector2i(2,2),Vector2i(4,4))
 check(cracks.get_region(covered_box).get_data() == without.get_region(covered_box).get_data(),"a joint buried under Clay is pixel-identical when the entire crack atlas is removed")
 check(cracks.get_data() != without.get_data(),"fissure shading is visibly present on actual exposed sandstone")
 main.block.material.set_shader_parameter("slab_cracks",main.slab.texture)
 native_click(Vector2(475,202))
 await skull_picture("slab-first-joint")
 native_click(Vector2(536,202))
 await skull_picture("slab-second-joint")
 native_click(Vector2(525,240))
 check(main.slab.mobile and not main.slab.released,"ready plate remains in the block until manual extraction")
 await skull_picture("plate-ready")
 press_lever(Vector2(525,240))
 drag_lever(.65)
 await settle(8)
 await skull_picture("plate-lever-preview")
 main.feedback.proxies_enabled = true
 main.controller.hit.inside = true
 main.feedback.proxies[3].show()
 main.feedback._update_proxy_pose(3)
 await skull_picture("plate-lever-with-pick")
 main.feedback.proxies[3].hide()
 main.feedback.proxies_enabled = false
 # Freeze only the idle ready wobble for an exact on/off source comparison.
 main.feedback.hide()
 for mat in [main.block.material,main.block.skirt_material]: mat.set_shader_parameter("lever_ready",false)
 var preview_on := await frame_image()
 main.mesh_view.model.hide()
 var preview_off := await frame_image()
 check(preview_on.get_data() == preview_off.get_data() and main.mesh_view.shadow_caster.mesh == null,"partial manual lift reveals no buried source pixel or Bone shadow caster")
 main.mesh_view.model.show()
 main.feedback.show()
 main.slab._set_preview()
 drag_lever(1.05)
 main.controller.cancel_stroke()
 check(main.slab.released,"native controller triggers graphical release")
 check(main.slab.piece.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_ON,"only the actually detached visible matrix piece adds its own shadow")
 main.slab.flight.pause()
 main.slab.flight.custom_step(.13)
 await skull_picture("slab-lifting")
 main.slab.flight.play()
 await create_timer(.7).timeout
 await zoom_to(1)
 var after := await skull_picture("slab-landed-overview")
 main.mesh_view.model.hide()
 var hidden := await frame_image()
 for p in [Vector2(235,243),Vector2(480,307),Vector2(441,360),Vector2(628,383)]:
  var i: int = main.block.working_map.fossil.field.index_at_map(p)
  var centre := Vector2i(at(p)*Vector2(root.size)/Vector2(root.content_scale_size))
  var box := Rect2i(centre-Vector2i(10,10),Vector2i(20,20))
  check(main.block.working_map.fossil.exposed[i] == 0 and after.get_region(box).get_data() == hidden.get_region(box).get_data(),"detachment keeps buried component pixel-identical: "+str(p))
 main.mesh_view.model.show()
 main.reset_specimen()
 check(not is_instance_valid(main.slab.piece) and main.mesh_view.shadow_caster.mesh == null,"reset removes detached piece and all source casting geometry")
 await skull_picture("slab-reset")
 await zoom_to(2,Vector2(520,216))
 var transform: Transform3D = main.camera.global_transform
 var view_size: float = main.camera.size
 await skull_picture("natural-matrix-close")
 main.queue_free()
 await process_frame
 main = preload("res://scenes/p6a44_natural_slab.tscn").instantiate()
 root.add_child(main)
 main.display.persist = false
 main.controller.set_physics_process(false)
 main.feedback.proxies_enabled = false
 main.feedback.set_physics_process(false)
 main.camera.set_process(false)
 # Display preferences load during ready; pin the same native window afterward.
 root.mode = Window.MODE_WINDOWED
 root.size = Vector2i(1280,720)
 await settle(5)
 main.camera.global_transform = transform
 main.camera.size = view_size
 var previous := await skull_picture("previous-plate-same-view")
 check(previous.get_size() == Vector2i(1280,720) and main.camera.size == view_size and main.camera.global_transform == transform,"old/new plate comparison preserves native image dimensions, camera pose and scale")
