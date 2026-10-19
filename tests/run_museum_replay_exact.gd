extends "res://tests/run_issue33_demos.gd"
## Differential replay: immutable pre-optimization surface, identical controlled camera.
## Historical references stay untouched; wall-clock zoom is deliberately not an oracle.
const ORACLE_REV := "99fa7fe"
const SURFACE_PATH := "scripts/experiments/preparation_demos/demo_surface.gd"
const SCRATCH := "res://work/museum-polish/replay-exact/"
const CURRENT = preload("res://scripts/experiments/preparation_demos/demo_surface.gd")

class ProbeBlock extends "res://scripts/experiments/preparation_demos/demo_block.gd":
 var replay_surface: Script
 func _create_working_surface(stratigraphy: Stratigraphy) -> WorkingSurface:
  var value = replay_surface.new(map_resolution, stratigraphy, _create_fossil_field(), reactions)
  value.demo_kind = demo_kind
  return value

class ProbeSuite extends "res://scripts/experiments/preparation_demos/demo_suite.gd":
 var replay_surface: Script
 func _make_preparation() -> Node3D:
  var value: Node3D = super._make_preparation()
  var block = value.get_node("ExcavationBlock")
  block.set_script(ProbeBlock)
  block.replay_surface = replay_surface
  return value

var records: Array = []
var oracle: Script
var source_metadata: Dictionary

func prepare_oracle() -> bool:
 var output: Array = []
 var code := OS.execute("git", PackedStringArray(["show", ORACLE_REV + ":" + SURFACE_PATH]), output, true)
 if code != 0 or output.is_empty():return false
 var source: String = output[0].replace("\r\n", "\n")
 DirAccess.make_dir_recursive_absolute(SCRATCH)
 var path := SCRATCH + "oracle_99fa7fe.gd"
 FileAccess.open(path, FileAccess.WRITE).store_string(source)
 oracle = load(path)
 source_metadata = {"oracle_revision": ORACLE_REV, "oracle_path": SURFACE_PATH,
  "oracle_sha256_lf": digest(source.to_utf8_buffer()),
  "current_sha256_lf": digest(FileAccess.get_file_as_string("res://" + SURFACE_PATH).replace("\r\n", "\n").to_utf8_buffer())}
 return oracle != null

func controlled_zoom(delta: float) -> int:
 main.camera.set_process(false)
 main.camera.reset_view();main.camera._focused = true
 main.camera.request_zoom(log(2.0) / log(main.camera.wheel_step), at(Vector2(500,340)))
 var ticks := 0
 while absf(main.camera.size - main.camera._base_size / 2.0) >= 0.0000001 and ticks < 1000:
  main.camera._process(delta)
  ticks += 1
 check(ticks < 1000, "controlled zoom converges")
 return ticks

func route(surface: Script, kind: int, zoom_delta: float, name: String) -> Dictionary:
 suite = ProbeSuite.new();suite.replay_surface = surface
 root.add_child(suite)
 while suite.busy:await process_frame
 if kind > 0:await suite.open_demo(kind)
 main = suite.preparation;main.display.persist = false
 var c = main.controller;c.set_physics_process(false);c.set_process(false)
 main.feedback.set_physics_process(false);main.feedback.set_process(false)
 main.camera.set_process(false)
 await settle(4)
 var zoom_ticks := controlled_zoom(zoom_delta)
 await settle(4)
 c._focused = true;c._pointer_inside = true
 var start := state()
 var camera := {"transform_bytes": var_to_bytes(main.camera.global_transform).hex_encode(),
  "transform": str(main.camera.global_transform), "size": main.camera.size,
  "viewport": str(root.get_visible_rect()), "window": str(root.size), "ticks": zoom_ticks,
  "delta": zoom_delta}
 var s = main.block.working_map
 var events: Array = []
 s.material_action.connect(func(event):events.append(event.duplicate(true)))
 var stages: Array = []
 for tool in [1,2,3,0,4]:
  if tool >= c.tools.size():continue
  events.clear()
  c.select_tool(tool);c._focused = true;c._pointer_inside = true
  c._held = true;c.impact_clock.reset();c._previous_valid = false
  var totals := 0
  var inputs := PackedVector2Array();var changed := PackedInt32Array()
  var a := Vector2(410,300);var b := Vector2(585,395)
  if tool == 4:
   a = Vector2(563,403) if kind == 1 else Vector2(530,350)
   b = Vector2(601,430) if kind == 1 else Vector2(570,367)
  for tick in range(120):
   var fraction: float = .5-.5*cos(float(tick)/119*TAU*2)
   c._screen = at(a.lerp(b,fraction))
   var pick: Dictionary = main.block.pick(c._screen, main.camera)
   inputs.append(pick.get("map", Vector2(INF, INF)))
   c._physics_process(1.0/60)
   main.session.flush();totals += c.changed_texels;changed.append(c.changed_texels)
   var original: Vector2 = c._screen
   for frame in range(3):
    c._screen = original+Vector2(frame+1,0);c.call("_process",1.0/240)
   c._screen = original
  c.cancel_stroke();main.block.flush_texture();main.session.flush()
  var snapshot := state()
  snapshot.caps = digest(s.crust_caps.to_byte_array())
  snapshot.grains = s.grains_removed;snapshot.crust = s.crust_removed;snapshot.impacts = c.total_impacts
  snapshot.height_array = digest(s._heights.to_byte_array())
  snapshot.last_action = digest(var_to_bytes(s.last_action))
  stages.append({"tool": tool, "state": snapshot, "changed": totals,
   "changed_ticks": digest(changed.to_byte_array()), "picked_map": digest(inputs.to_byte_array()),
   "first_pick": str(inputs[0]), "events": digest(var_to_bytes(events))})
 main.reset_specimen();await settle(3)
 check(state() == start, name + " resets exactly")
 var result := {"name": name, "kind": kind, "camera": camera, "initial": start, "stages": stages}
 suite.queue_free();await process_frame;await process_frame
 print("REPLAY_CASE ", name, " first_height=", stages[0].state.height, " camera=", camera.transform)
 return result

func compare(a: Dictionary, b: Dictionary) -> void:
 check(a.initial == b.initial, "same initial maps kind %d" % a.kind)
 check(a.camera == b.camera, "same camera bytes kind %d" % a.kind)
 for index in range(a.stages.size()):
  var before: Dictionary = a.stages[index];var after: Dictionary = b.stages[index]
  check(before.picked_map == after.picked_map, "same input bytes kind %d tool %d" % [a.kind,before.tool])
  check(before.state == after.state, "exact state and volumes kind %d tool %d" % [a.kind,before.tool])
  check(before.changed == after.changed and before.changed_ticks == after.changed_ticks,
   "exact removal per tick kind %d tool %d" % [a.kind,before.tool])
  check(before.events == after.events, "exact ordered events kind %d tool %d" % [a.kind,before.tool])

func run() -> void:
 out = SCRATCH
 if not prepare_oracle():
  push_error("Immutable 99fa7fe Git oracle unavailable");quit(2);return
 AudioServer.set_bus_mute(0,true)
 root.mode = Window.MODE_WINDOWED;root.size = Vector2i(1280,720)
 await process_frame;await process_frame
 var count := 1 if "--compact-only" in OS.get_cmdline_user_args() else 3
 for kind in range(count):
  var before := await route(oracle,kind,1.0/240,"oracle-fixed240-kind%d" % kind)
  var after := await route(CURRENT,kind,1.0/240,"current-fixed240-kind%d" % kind)
  compare(before,after);records.append(before);records.append(after)
 # Same immutable gameplay, only camera interpolation schedule varies.
 var schedule := await route(oracle,0,1.0/60,"oracle-fixed60-kind0")
 records.append(schedule)
 var old: Dictionary = records[0]
 var probe := {"same_initial": old.initial == schedule.initial,
  "same_camera_bytes": old.camera.transform_bytes == schedule.camera.transform_bytes,
  "same_first_picked_inputs": old.stages[0].picked_map == schedule.stages[0].picked_map,
  "same_chisel_height": old.stages[0].state.height == schedule.stages[0].state.height,
  "same_chisel_changed": old.stages[0].changed == schedule.stages[0].changed}
 check(probe.same_initial, "cadence probe starts from identical maps")
 var result := {"checks": checks, "failures": failures, "source": source_metadata,
  "engine": Engine.get_version_info(), "headless": DisplayServer.get_name() == "headless",
  "controlled_zoom": "manual PrecisionZoom._process; physics 60 Hz; 3 visual refreshes per tick; no gameplay quantization",
  "historical_fixture_edited": false, "cadence_probe": probe, "records": records}
 FileAccess.open(SCRATCH+"result.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("CAMERA_CADENCE_PROBE ",probe)
 print("MUSEUM_REPLAY_EXACT ",checks," checks ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
