extends "res://scripts/preparation/tactile/cleaning_feedback.gd"
var grain_interval := 0.0
var grain_bursts := 0
func _process(delta: float) -> void:
 grain_interval = maxf(0,grain_interval-delta)
 super._process(delta)
func on_action(event: Dictionary) -> void:
 super.on_action(event)
 if not event.get("pocket_flow",false): return
 sweep_remaining = .12
 if grain_interval>0 or not particles_enabled: return
 grain_interval = .055
 grain_bursts += 1
 audio.play_family(&"air",.45)
 var direction: Vector2 = event.direction
 var velocity := Vector3(direction.x,0,direction.y)
 for source: Vector3 in event.grain_sources:
  var origin := point_world(Vector2(source.x,source.z))
  origin.y = block.base_height+source.y*block.working_map.excavatable_depth+.002
  for n in range(3):
   if particles[1].size()>=160: break
   var width := rng.randf_range(.0011,.0028)
   particles[1].append({"position":origin+Vector3(rng.randf_range(-.002,.002),.001,rng.randf_range(-.002,.002)),
    "velocity":velocity*rng.randf_range(.12,.23)+Vector3(rng.randf_range(-.018,.018),rng.randf_range(.13,.20),rng.randf_range(-.018,.018)),
    "life":rng.randf_range(.38,.58),"shape":Vector3(width,width*.65,width*.8),
    "rotation":rng.randf_range(-PI,PI),"floor":origin.y-.006,"color":Color(.44,.30,.16).lerp(Color(.68,.52,.30),rng.randf())})
   emitted[1] += 1
 _dust(event.point,Color(.62,.43,.24),2,.006,velocity*.12)
func reset() -> void:
 super.reset()
 grain_interval = 0
 grain_bursts = 0
