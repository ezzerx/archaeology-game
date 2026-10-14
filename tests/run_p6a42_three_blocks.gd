extends "res://tests/run_p6a40_natural_block.gd"
func _pilot_scene() -> PackedScene:
 return preload("res://scenes/p6a42_three_blocks.tscn")
func _output_directory() -> String:
 return "res://work/test-logs/p6a42/"
func _collection_store() -> String:
 return "res://work/test-logs/p6a42/collection-test.json"
func _suite_name() -> String:
 return "P6A4.2"
func pilot_checks() -> void:
 await super.pilot_checks()
 var s: WorkingSurface = main.block.working_map
 var source := s.fossil.field.image.get_data()
 var reports := []
 for trial in range(3):
  main.open_block(trial)
  var initial := s.image.get_data()
  var layers := s.strata.boundaries.get_data()
  var baseline := 0.0
  var cost := 0.0
  var minimum_gap := INF
  var wrong := 0
  var soil_mm := 0.0
  var stone_bone := 0
  var surface_stone := 0
  for i in range(s._heights.size()):
   if main.block.footprint.mask[i] == 0:
    if s._heights[i] != 0: wrong += 1
    continue
   var now := Vector2(s.strata.packed_limits[i*2],s.strata.packed_limits[i*2+1])
   if now.y > now.x or now.y <= 0: wrong += 1
   soil_mm = maxf(soil_mm,(s._heights[i]-now.x)*102.0)
   if is_equal_approx(now.x,now.y): surface_stone += 1
   if s.fossil.field.component_ids[i] == 0: continue
   var roof := s.fossil.field.ceilings[i]
   minimum_gap = minf(minimum_gap,s._heights[i]-roof)
   var old := Vector2(main.profile.reference_limits[i*2],main.profile.reference_limits[i*2+1])
   baseline += s.strata.hard_work_to_bone(old,roof,102,main.controller.tools[1])
   cost += s.strata.hard_work_to_bone(now,roof,102,main.controller.tools[1])
   if now.y > roof: stone_bone += 1
  check(wrong == 0 and soil_mm <= 2.0,"ordered geology, thin Soil and empty natural corners: "+str(trial))
  check(minimum_gap > .02 and s.fossil.exposed_cells == 0,"all Bone starts buried by at least 2 mm without a Bone-driven surface: "+str(trial))
  check(cost/baseline <= 1.0,"structural effort to Bone is bounded by accepted reference: "+str(trial))
  check(s.fossil.field.image.get_data() == source,"unchanged source/ceilings for trial "+str(trial))
  check(main.matrix_edges.edges.count(255) == 0 and main.mesh_view.shadow_caster.mesh == null,"fresh block has no buried outline/caster: "+str(trial))
  # Genuine Pick impacts from intact initial condition, no staged cuts or exposure.
  var started := Time.get_ticks_usec()
  var impacts := 0
  for y in range(176,558,6):
   for x in range(168,838,6):
    var nearby := false
    for offset in [Vector2i.ZERO,Vector2i(-3,0),Vector2i(3,0),Vector2i(0,-3),Vector2i(0,3)]:
     if s.fossil.field.component_ids[(y+offset.y)*1024+x+offset.x] != 0: nearby = true
    if not nearby: continue
    for n in range(4):
     s.apply_impact(Vector2(x,y),main.controller.tools[3])
     impacts += 1
  for i in range(s.fossil.field.component_ids.size()):
   if s.fossil.field.component_ids[i] == 0: continue
   @warning_ignore("integer_division")
   var p := Vector2(i%1024,i/1024)
   for n in range(20):
    if s.fossil.exposed[i] != 0: break
    s.apply_impact(p,main.controller.tools[3])
    impacts += 1
  check(s.fossil.exposure_percent() == 100 and s.fossil.condition == 100,"native safe Pick fully reveals trial "+str(trial))
  # Genuine moving Brush sweeps; no direct clean fixture.
  for y in range(176,574,16):
   for n in range(4):
    var a := Vector2(155 if n%2==0 else 850,y)
    var b := Vector2(850 if n%2==0 else 155,y)
    s.apply_continuous(a,b,main.controller.tools[0],.12)
  main.block.flush_texture()
  main.session.flush()
  check(s.bone_film.cleanliness_percent() == 100 and main.session.preparation_complete and main.distinction.earned,"native moving Brush reaches guarded 100/100 and distinction: "+str(trial))
  check(main.session.archive(),"archive remains available: "+str(trial))
  main.session_ui.another_button.pressed.emit()
  check(main.profile.selected == (trial+1)%3 and s.fossil.exposed_cells == 0 and not main.session.archived,"archive next-block button advances and resets exactly once: "+str(trial))
  main.open_block(trial)
  check(s.image.get_data() == initial and s.strata.boundaries.get_data() == layers,"reset restores byte-identical deterministic geology: "+str(trial))
  reports.append({"trial":trial,"hard_work_ratio":cost/baseline,"minimum_burial_mm":minimum_gap*102,"stone_bone_cells":stone_bone,"surface_stone_cells":surface_stone,"pick_impacts":impacts,"test_cpu_seconds":(Time.get_ticks_usec()-started)/1000000.0})
 check(reports[0].stone_bone_cells < reports[1].stone_bone_cells and reports[1].surface_stone_cells > 1000 and reports[2].surface_stone_cells > 1000,"three preparations have different accessible geological distributions")
 main.open_block(0)
 s.apply_impact(Vector2(260,230),main.controller.tools[3])
 var before := state()
 main.request_block(1)
 check(main.switch_dialog.visible and main.profile.selected == 0 and state() == before,"changing a worked block waits for explicit reset confirmation")
 main.switch_dialog.hide()
 main._cancel_block()
 check(state() == before and main.profile.selected == 0,"cancel preserves the whole preparation")
 main.request_block(1)
 main.switch_dialog.hide()
 main._confirm_block()
 check(main.profile.selected == 1 and not main.trial_worked,"confirm opens the requested fresh geology")
 var before_soil := s.strata.boundaries.get_data()
 var before_soil_top := s.image.get_data()
 main.toggle_soil()
 check(s.strata.boundaries.get_data() == before_soil and s.image.get_data() != before_soil_top,"historical Soil comparison changes only overburden on the selected new geology")
 main.toggle_soil()
 check(is_instance_valid(main.block_choice) and s.image.get_data() == before_soil_top,"return from Soil comparison restores the exact trial and retains the selector")
 var builds: int = main.block.render_builds
 for n in range(10): main.block.flush_texture()
 check(builds == main.block.render_builds,"new cached profiles add no idle height rebuilds")
 evidence["three_trials"] = reports
 main.open_block(0)
func pilot_visual() -> void:
 check(DisplayServer.get_name() != "headless","real native renderer required")
 var images := []
 for trial in range(3):
  main.open_block(trial)
  await settle(6)
  var intact := await skull_picture("trial-"+str(trial+1)+"-intact")
  images.append(digest(intact.get_data()))
  main.mesh_view.model.hide()
  var absent := await frame_image()
  check(intact.get_data() == absent.get_data(),"intact matrix identical without Bone source in trial "+str(trial))
  main.mesh_view.model.show()
  # Leave an actually played opening while other anatomy remains buried.
  for n in range(40):
   main.block.working_map.apply_impact(Vector2(235,243),main.controller.tools[3])
   if main.block.working_map.fossil.exposed_cells >= 100: break
  check(main.block.working_map.fossil.exposed_cells > 0 and main.block.working_map.fossil.exposed_cells < 1000,"native opening actually exposes a bounded piece of Bone: "+str(trial))
  main.block.flush_texture()
  await settle(6)
  var caster_wrong := 0
  for i in main.mesh_view.caster_cells:
   if main.block.working_map.fossil.exposed[i] == 0: caster_wrong += 1
  check(main.mesh_view.caster_cells.size() > 0 and caster_wrong == 0,"partial caster contains only committed exposed cells: "+str(trial))
  var partial := await skull_picture("trial-"+str(trial+1)+"-opening")
  main.mesh_view.model.hide()
  var hidden := await frame_image()
  for p in [Vector2(480,307),Vector2(441,360),Vector2(628,383)]:
   var i: int = main.block.working_map.fossil.field.index_at_map(p)
   var centre := Vector2i(at(p)*Vector2(root.size)/Vector2(root.content_scale_size))
   var box := Rect2i(centre-Vector2i(10,10),Vector2i(20,20))
   check(main.block.working_map.fossil.exposed[i] == 0 and partial.get_region(box).get_data() == hidden.get_region(box).get_data(),"opening never reveals another buried component: "+str(trial)+" / "+str(p))
  main.mesh_view.model.show()
 check(images[0] != images[1] and images[1] != images[2] and images[0] != images[2],"all three initial block surfaces are visually distinct")
 main.open_block(0)
