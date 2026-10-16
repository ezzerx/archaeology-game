extends "res://tests/run_p6a40_natural_block.gd"
func _pilot_scene() -> PackedScene:return preload("res://scenes/preparation/pocket_preparation.tscn")
func _output_directory() -> String:return "res://work/test-logs/p6a49/"
func _collection_store() -> String:return "res://work/test-logs/p6a49/collection-test.json"
func _suite_name() -> String:return "P6A4.9"
func native_impact(point:Vector2,tool:=1) -> void:
 main.controller.cancel_stroke();main.controller.select_tool(tool)
 main.controller._focused=true;main.controller._pointer_inside=true
 main.block.flush_texture()
 main.controller._screen=at(point);main.controller._held=true
 main.controller._physics_process(1.0/60)
 main.controller.cancel_stroke()
func dig_entry() -> int:
 for n in range(8):
  native_impact(main.pocket.layout.centre)
  if main.pocket.is_open:return n+1
 return 8
func open_band() -> int:
 var impacts:=0
 var centre:Vector2=main.pocket.layout.centre
 for y in [-15,15]:
  for x in [-44,-22,0,22,44]:
   var p:=centre+Vector2(x,y)
   var i:=int(p.y)*1024+int(p.x)
   for n in range(6):
    if main.block.working_map._heights[i]<=main.pocket.roofs[i]+.0001:break
    native_impact(p);impacts+=1
 return impacts
func sweep(a:Vector2,b:Vector2,seconds:float) -> void:
 var previous:=a
 main.controller.select_tool(2)
 for n in range(roundi(seconds*60)):
  var p:=a.lerp(b,float(n+1)/roundi(seconds*60))
  main.block.working_map.apply_continuous(previous,p,main.controller.tools[2],1.0/60)
  previous=p
func native_sweep(a:Vector2,b:Vector2,seconds:float) -> void:
 main.controller.select_tool(2)
 main.controller._focused=true;main.controller._pointer_inside=true
 var press:=InputEventMouseButton.new()
 press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=at(a)
 root.push_input(press,true)
 var frames:=roundi(seconds*60)
 for n in range(frames):
  main.block.flush_texture()
  var motion:=InputEventMouseMotion.new()
  motion.position=at(a.lerp(b,float(n+1)/frames));motion.button_mask=MOUSE_BUTTON_MASK_LEFT
  root.push_input(motion,true)
  main.controller._physics_process(1.0/60)
  await process_frame
 var release:=InputEventMouseButton.new()
 release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=main.controller._screen
 root.push_input(release,true)
func variant_checks() -> void:
 main.select_pocket_variant(0)
 var s:WorkingSurface=main.block.working_map
 var actor:Node=main.pocket
 var reference=preload("res://scenes/preparation/base/rough_block.tscn").instantiate()
 root.add_child(reference)
 reference.display.persist=false;reference.controller.set_physics_process(false)
 reference.reset_specimen()
 check(s._heights==reference.block.working_map._heights and s.strata.packed_limits==reference.block.working_map.strata.packed_limits,"buried inclusion starts with byte-identical natural-block heights and geological interfaces")
 reference.queue_free()
 await process_frame
 var initial:=state()
 var results:=[]
 var roof_hashes:=[]
 for variant in range(5):
  main.select_pocket_variant(variant)
  if not actor.layout.present:
   var sealed:=state()
   sweep(Vector2(490,390),Vector2(550,390),.5)
   check(actor.cells.is_empty() and actor.initial_volume==0 and state()==sealed,"absent trial has no granular volume or air excavation")
   check(actor.layout.seed_value==49304 and not actor.is_open,"absence is a seeded result chosen at preparation creation")
   results.append({"variant":variant,"seed":actor.layout.seed_value,"present":false})
   continue
  var centre:Vector2=actor.layout.centre
  var ci:=int(centre.y)*1024+int(centre.x)
  check(state()==initial and not actor.is_open,"changing buried layout leaves the intact block identical: "+str(variant))
  var minimum_cover:=INF;var maximum_cover:=0.0;var minimum_thickness:=INF;var maximum_thickness:=0.0
  var grain_hints:=0;var unsafe:=0;var bone_cells:=0
  for i:int in actor.cells:
   var cover:float=(s._heights[i]-actor.roofs[i])*s.excavatable_depth*1000
   var thickness:float=(actor.roofs[i]-actor.floors[i])*s.excavatable_depth*1000
   minimum_cover=minf(minimum_cover,cover);maximum_cover=maxf(maximum_cover,cover)
   minimum_thickness=minf(minimum_thickness,thickness);maximum_thickness=maxf(maximum_thickness,thickness)
   if s._heights[i]<=actor.roofs[i]+.036:grain_hints+=1
   if s.structural_ceilings[i]>0:
    bone_cells+=1
    if actor.floors[i]<s.structural_ceilings[i]+.011:unsafe+=1
  check(grain_hints==0 and minimum_cover>13 and maximum_cover<27,"entire inclusion is genuinely hidden under a bounded mid-depth cover: "+str(variant))
  check(maximum_cover-minimum_cover>5 and maximum_thickness-minimum_thickness>8,"inclined roof and variable thickness create a depth-varying volume: "+str(variant))
  check(unsafe==0 and bone_cells>=400,"buried lens contributes to fossil preparation with opaque Bone cover: "+str(variant))
  var cover_copy:=s.structural_ceilings.duplicate()
  var maximum_cell:=actor.layout.cells[0] as int
  for i:int in actor.layout.cells:
   if cover_copy[i]>cover_copy[maximum_cell]:maximum_cell=i
  var floor_copy:PackedFloat32Array=actor.floors.duplicate()
  var roof_copy:PackedFloat32Array=actor.roofs.duplicate()
  s.structural_ceilings.fill(0)
  s.structural_ceilings[maximum_cell]=cover_copy[maximum_cell]
  actor.configure()
  check(actor.floors==floor_copy and actor.roofs==roof_copy,"volume never traces the pattern of buried Bone anatomy: "+str(variant))
  s.structural_ceilings=cover_copy
  actor.configure()
  var no_air:=s._heights.duplicate()
  sweep(centre-Vector2(60,0),centre+Vector2(60,0),.5)
  check(s._heights==no_air,"air never reveals the buried inclusion through its solid overburden: "+str(variant))
  var before_impacts:int=main.controller.total_impacts
  var hits:=dig_entry()
  check(hits>=2 and hits<=5 and actor.is_open,"normal native Chisel work discovers mid-depth grains in a few impacts: "+str(variant))
  check(main.controller.total_impacts-before_impacts==hits,"discovery keeps one native impact per cadence step: "+str(variant))
  var after_discovery:float=actor.remaining_volume()/actor.initial_volume
  check(after_discovery>.95 and s.fossil.exposed_cells==0,"discovery exposes grains without auto-emptying the lens or revealing Bone: "+str(variant))
  var remote:=centre+Vector2(48,0)
  var ri:=int(remote.y)*1024+int(remote.x)
  var remote_height:float=s._heights[ri]
  var prior:=s._heights.duplicate()
  var old_center:float=s._heights[ci]
  await native_sweep(centre-Vector2(12,0),centre+Vector2(15,2),.5)
  var fraction:float=1.0-actor.remaining_volume()/actor.initial_volume
  var centre_drop:float=old_center-s._heights[ci]
  var max_drop:=0.0
  for i:int in actor.cells:max_drop=maxf(max_drop,prior[i]-s._heights[i])
  check(max_drop>.035 and fraction>.05,"first short native air gesture makes a visible local depth change: "+str(variant))
  check(s._heights[ri]==remote_height and remote_height>actor.roofs[ri]+.038,"an adjacent thick roof stays solid instead of vanishing with the pocket: "+str(variant))
  var outside:=0;var increased:=0
  for i in range(prior.size()):
   if s._heights[i]>prior[i]:increased+=1
   if s._heights[i]!=prior[i] and actor.roofs[i]<=0:outside+=1
  check(outside==0 and increased==0,"air removes only actual granular columns and never refills terrain: "+str(variant))
  var released:=state()
  for n in range(4):main.controller._physics_process(1.0/60)
  check(state()==released and not main.controller._held,"mouse release stops flow and any roof consequence: "+str(variant))
  # A second controlled route opens the cover before evacuation. Do not drive
  # Chisel blindly across already-empty, near-Bone columns in the pacing oracle.
  main.reset_specimen()
  var band_impacts:=open_band()
  var air_start:=s._heights.duplicate()
  var condition_before:float=s.fossil.condition
  var accessible:=0.0
  var accessible_cells:=PackedInt32Array()
  for i:int in actor.cells:
   if s._heights[i]<=actor.roofs[i]+.038:
    accessible+=maxf(0,minf(s._heights[i],actor.roofs[i])-actor.floors[i])
    accessible_cells.append(i)
  for pass_id in range(3):
   var a:=centre+Vector2(-61,-10 if pass_id!=1 else 12)
   var b:=centre+Vector2(61,-10 if pass_id!=1 else 12)
   sweep(a if pass_id%2==0 else b,b if pass_id%2==0 else a,.65)
  var emptied:float=1.0-actor.remaining_volume()/actor.initial_volume
  var still_accessible:=0.0
  for i:int in accessible_cells:still_accessible+=maxf(0,minf(s._heights[i],actor.roofs[i])-actor.floors[i])
  var accessible_fraction:=1.0-still_accessible/accessible
  check(accessible_fraction>.80,"short sweeps rapidly evacuate the grains reached by ordinary excavation: "+str(variant))
  check(absf(actor.remaining_cache-actor.remaining_volume())<.001,"cached volume matches actual RF after deep excavation: "+str(variant))
  var floor_violations:=0
  for i:int in actor.cells:
   if s._heights[i]<minf(air_start[i],actor.floors[i])-.00001:floor_violations+=1
  check(floor_violations==0 and s.fossil.condition==condition_before,"flow stops at the irregular compact floor and never damages Bone: "+str(variant))
  var hash_before:=digest(actor.roofs.to_byte_array())
  roof_hashes.append(hash_before)
  main.reset_specimen()
  check(state()==initial and digest(actor.roofs.to_byte_array())==hash_before and main.profile.variant==variant,"R preserves the chosen lens and restores its exact cover: "+str(variant))
  results.append({"variant":variant,"seed":actor.layout.seed_value,"present":true,"angle":actor.layout.angle,"axes":str(actor.layout.axes),"cover_mm":[minimum_cover,maximum_cover],"thickness_mm":[minimum_thickness,maximum_thickness],"bone_cells":bone_cells,"opening_impacts":hits,"first_half_second_removed":fraction,"maximum_local_drop_mm":max_drop*102,"centre_drop_mm":centre_drop*102,"band_impacts":band_impacts,"removed_after_three_sweeps":emptied,"accessible_grains_removed":accessible_fraction,"cells":actor.cells.size()})
 check(roof_hashes.size()==4 and roof_hashes[0]!=roof_hashes[1] and roof_hashes[1]!=roof_hashes[2] and roof_hashes[2]!=roof_hashes[3],"four admitted seeds produce different placement, shape, angle and depth")
 main.select_pocket_variant(0)
 var uploads:int=actor.uploads
 var idle:=state()
 for n in range(12):await process_frame
 check(state()==idle and actor.uploads==uploads and actor.ticks==0,"hidden inclusion has no idle computation, excavation or atlas upload")
 check(main.controller.tools[1].radius==26 and main.controller.tools[1].power==.84 and main.controller.tools[2].power==0 and main.controller.tools[2].effectiveness==Vector3.ZERO,"validated tools and zero global air excavation stay unchanged")
 # Dispatch a real UI click: a new trial must be reachable and cannot excavate.
 main.panel.show()
 await settle(3)
 var button_rect:Rect2=main.variant_button.get_global_rect()
 check(button_rect.position.y>0 and button_rect.end.y<root.content_scale_size.y,"alternate trial button remains reachable inside the native playtest panel")
 var press:=InputEventMouseButton.new()
 press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=button_rect.get_center()
 root.push_input(press,true)
 await process_frame
 var release:=InputEventMouseButton.new()
 release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=press.position
 root.push_input(release,true)
 check(main.profile.variant==1 and state()==initial and not main.controller._held,"actual trial button chooses a different buried lens and cleanly restarts without a tool stroke")
 main.panel.hide()
 main.reset_specimen()
 check(main.profile.variant==1 and state()==initial,"ordinary reset keeps the trial chosen through the actual UI")
 main.select_pocket_variant(0)
 evidence["seeded_variants"]=results
func pilot_checks() -> void:
 if mode=="motion":
  await finishing_motion()
  return
 if mode!="design":await super.pilot_checks()
 await variant_checks()
 await finishing_checks()
func bind_field(texture:Texture2D) -> void:
 for mat in [main.block.material,main.block.skirt_material]:mat.set_shader_parameter("friable_field",texture)
func finishing_checks() -> void:
 main.select_pocket_variant(0)
 var actor:Node=main.pocket
 var s:WorkingSurface=main.block.working_map
 var profile:RefCounted=main.profile
 var admitted:=0;var absent:=0;var unsafe:=0;var trimmed:=0
 for seed_value in range(49400,49432):
  var layout=profile.recipe.build(s,profile.limits[1],seed_value)
  if not layout.present:absent+=1;continue
  admitted+=1
  for slot in range(layout.cells.size()):
   var i:int=layout.cells[slot]
   if layout.floors[i]<s.structural_ceilings[i]+profile.recipe.safe_cover or s._heights[i]-layout.roofs[i]<.036:unsafe+=1
   if absf(layout.floors[i]-(profile.limits[1][i*2]-layout.cover[slot]-layout.depth[slot]))>.000001:trimmed+=1
 check(admitted>0 and absent>0 and unsafe==0 and trimmed==0,"32 independent seeds admit whole safe volumes or absence without anatomy-shaped trimming")
 evidence["seed_audit"]={"tested":32,"admitted":admitted,"absent":absent,"unsafe":unsafe,"trimmed":trimmed}
 var recipe:FriablePocketRecipe=profile.recipe.duplicate()
 recipe.occurrence_probability=1;recipe.max_attempts=3;recipe.safe_cover=1
 var rejected=recipe.build(s,profile.limits[1],49301)
 check(not rejected.present and rejected.cells.is_empty() and rejected.attempts==3,"unsafe envelope exhausts a bounded admission budget then yields absence")
 var repeat=profile.recipe.build(s,profile.limits[1],actor.layout.seed_value)
 check(repeat.cells==actor.layout.cells and repeat.roofs==actor.layout.roofs and repeat.floors==actor.layout.floors,"seed regeneration is byte-identical, independent of cached layouts")
 check(actor.cells.size()==actor.layout.cells.size(),"runtime retains the admitted whole shape without a secondary Bone trim")
 var banner_found:=false;var banner_hidden:=false
 for label:Label in main.find_children("*","Label",true,false):
  if label.text.begins_with("B-17 · Une découverte"):
   banner_found=true;banner_hidden=not label.is_visible_in_tree()
 check(banner_found and banner_hidden,"permanent instruction banner is removed from the play surface")
 check(main.introduction_count==1,"first-discovery hint appears once across resets and different preparations")
 var releases:int=actor.contact_releases
 native_impact(Vector2(200,200))
 check(actor.contact_releases==releases,"ordinary solid work away from the pocket never emits grain contact feedback")
 main.reset_specimen()
 var centre:Vector2=actor.layout.centre
 dig_entry()
 check(actor.contact_releases>0 and main.feedback.contact_bursts>0,"actual contact releases a small granular response through native Chisel input")
 check(main.introduction_count==1,"contextual tutorial does not repeat after replaying an already discovered pocket")
 var mat:StandardMaterial3D=main.feedback.grain_view.material_override
 check(mat.roughness==1 and mat.metallic_specular==0 and not mat.emission_enabled and main.feedback.grain_view.cast_shadow==0,"granular FX are matte, non-emissive and cannot cast hidden Bone shadows")
 var ci:=int(centre.y)*s.size.x+int(centre.x)
 var roof:float=actor.roofs[ci];var floor:float=actor.floors[ci]
 var old:=floor+.005
 check(actor.flow_height(ci,old,.23,1.0/60)==floor,"a real near-finished free column clears its last submillimetric tail")
 check(actor.flow_height(ci,old,.001,1.0/60)>floor and actor.flow_height(ci,floor,.5,1.0/60)==floor,"weak jet rim cannot auto-finish a distant column or cut compact floor")
 open_band()
 sweep(centre-Vector2(60,0),centre+Vector2(60,0),.3)
 main.feedback._process(1.0/60)
 check(main.feedback.grains.size()>0 and main.feedback.grains.size()<=176 and main.feedback.last_floor_samples<=12,"real flow uses the bounded granular pool and floor sampling budget")
 var sizes:=PackedInt32Array([0,0,0])
 for g:Dictionary in main.feedback.grains:
  sizes[0 if g.shape.x<.0013 else (1 if g.shape.x<.0022 else 2)]+=1
 check(sizes.count(0)==0,"visible flow contains fine grains, medium pieces and occasional coarse aggregates")
 main.reset_specimen()
 check(main.feedback.grains.is_empty() and main.feedback.grain_pool.visible_instance_count==0 and actor.contact_releases==0 and actor.tail_finishes==0,"reset immediately clears every new feedback pool and local finish state")
 evidence["grain_sizes_sample"]=Array(sizes)
func compare_previous_material() -> void:
 var codes:Dictionary={}
 for shader in [main.mesh_surface_shader,main.baseline_surface_shader,main.readability_shader,main.original_hero_shader,main.witness_shader,main.soil_shader,main.hero_shader]:
  if shader==null or codes.has(shader):continue
  codes[shader]=shader.code
  shader.code=shader.code.replace('res://shaders/p6a49_pocket.gdshaderinc','res://shaders/p6a47_pocket.gdshaderinc').replace(main.FRIABLE_FINISH_HOOK,'color=friable_color(color,UV,texelFetch(working_map,cell,0).r);')
 await skull_picture("finish-0-previous-material-same-terrain")
 for shader in codes:shader.code=codes[shader]
 await settle(4)
func pilot_visual() -> void:
 check(DisplayServer.get_name()!="headless","finishing proof uses native Godot rendering")
 main.select_pocket_variant(0)
 main.feedback.proxies_enabled=false
 for proxy in main.feedback.proxies:proxy.hide()
 main.feedback.set_physics_process(false)
 main.camera.set_process(true)
 await zoom_to(1)
 main.camera.set_process(false)
 var intact:=await skull_picture("finish-intact-overview")
 var zero:=Image.create(1024,640,false,Image.FORMAT_RGBAF)
 zero.fill(Color(0,0,0,0))
 var empty_field:=ImageTexture.create_from_image(zero)
 bind_field(empty_field)
 var no_field:=await frame_image()
 check(digest(intact.get_data())==digest(no_field.get_data()),"intact buried field has no visible clue compared with an absent pocket")
 bind_field(main.pocket.texture)
 main.mesh_view.model.hide()
 var no_source:=await frame_image()
 check(digest(intact.get_data())==digest(no_source.get_data()),"initial buried lens reveals neither source pixels nor Bone shadow")
 main.mesh_view.model.show()
 for variant in range(5):
  main.select_pocket_variant(variant)
  if not main.pocket.layout.present:
   main.camera.set_process(true);await zoom_to(1);main.camera.set_process(false)
   await skull_picture("finish-%d-no-pocket"%variant)
   continue
  var centre:Vector2=main.pocket.layout.centre
  main.camera.set_process(true)
  await zoom_to(2.7,centre)
  main.camera.set_process(false)
  var covered:=await skull_picture("finish-%d-covered"%variant)
  bind_field(empty_field)
  var covered_off:=await frame_image()
  check(digest(covered.get_data())==digest(covered_off.get_data()),"covered seeded lens has no shader hint: "+str(variant))
  bind_field(main.pocket.texture)
  native_impact(centre)
  await skull_picture("finish-%d-first-contact"%variant)
  check(not main.pocket.is_open,"first contact retains a true clay skin before open grains: "+str(variant))
  dig_entry()
  await create_timer(.65).timeout
  await skull_picture("finish-%d-discovered"%variant)
  main.feedback.proxies_enabled=true
  await native_sweep(centre-Vector2(12,0),centre+Vector2(15,2),.5)
  await settle(2);await RenderingServer.frame_post_draw
  var tool_picture:=root.get_texture().get_image()
  var name:="finish-%d-native-blower.png"%variant
  check(tool_picture.save_png(out+name)==OK,"capture "+name)
  evidence.captures.append(name)
  main.feedback.proxies_enabled=false
  for proxy in main.feedback.proxies:proxy.hide()
  await create_timer(.8).timeout
  var partial:=await skull_picture("finish-%d-local-cavity"%variant)
  main.mesh_view.model.hide()
  var without_source:=await frame_image()
  check(digest(partial.get_data())==digest(without_source.get_data()),"partial seeded cavity keeps source Bone fully occluded: "+str(variant))
  main.mesh_view.model.show()
  main.reset_specimen();open_band()
  main.camera.set_process(true);await zoom_to(3,centre);main.camera.set_process(false)
  await create_timer(.8).timeout
  await skull_picture("finish-%d-open-band"%variant)
  if variant==0:await compare_previous_material()
  for pass_id in range(3):sweep(centre+Vector2(-61,-10 if pass_id!=1 else 12),centre+Vector2(61,-10 if pass_id!=1 else 12),.65)
  await create_timer(.8).timeout
  await skull_picture("finish-%d-deep-cavity"%variant)
 main.select_pocket_variant(0)
 await super.pilot_visual()

func finishing_motion() -> void:
 check(DisplayServer.get_name()!="headless","motion proof uses native rendering")
 main.select_pocket_variant(0)
 var centre:Vector2=main.pocket.layout.centre
 open_band()
 main.feedback.proxies_enabled=true
 main.feedback.set_physics_process(false)
 main.camera.set_process(true);await zoom_to(3,centre);main.camera.set_process(false)
 await create_timer(.8).timeout
 await native_sweep(centre+Vector2(-38,0),centre+Vector2(-8,0),.16)
 await settle(1);await RenderingServer.frame_post_draw
 main.feedback.set_process(false)
 var flowing:=root.get_texture().get_image()
 var name:="finish-0-grains-in-motion.png"
 check(flowing.save_png(out+name)==OK,"capture "+name)
 evidence.captures.append(name)
 var particles:int=main.feedback.grains.size()
 check(particles>20 and particles<=176 and main.feedback.last_floor_samples<=12,"native moving jet shows a bounded real grain group")
 main.feedback.grain_view.hide()
 var hidden:=await frame_image()
 var pixels:=0
 var a:=flowing.get_data();var b:=hidden.get_data()
 for i in range(0,a.size(),4):
  if abs(a[i]-b[i])+abs(a[i+1]-b[i+1])+abs(a[i+2]-b[i+2])>6:pixels+=1
 check(pixels>50,"separate matte grain group makes a visible native pixel contribution")
 main.feedback.grain_view.show()
 var rolling:=0
 for grain:Dictionary in main.feedback.grains:
  if grain.rolling:rolling+=1
 check(rolling>0 and rolling<particles,"real jet combines short rolling grains and airborne aggregates")
 evidence["motion"]={"grains":particles,"rolling":rolling,"visible_pixels":pixels,"floor_samples_last_frame":main.feedback.last_floor_samples}
 main.feedback.set_process(true)
 await create_timer(.8).timeout
 check(main.feedback.grains.is_empty(),"released jet leaves no persistent floating grain particles")
