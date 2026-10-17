extends "res://scripts/experiments/preparation_demos/demo_feedback.gd"
## Local, brief, warm-grey sediment trails from actually removed cells.
func on_action(event:Dictionary) -> void:
 if not event.get("pocket_flow",false):
  super.on_action(event);return
 # Keep normal tool feedback, replacing only the brown pocket emission.
 var base:=event.duplicate();base.pocket_flow=false
 super.on_action(base)
 sweep_remaining=.12
 if grain_interval>0 or not particles_enabled:return
 grain_interval=.055;grain_bursts+=1
 audio.play_family(&"air",.45)
 var sources:Array=event.grain_sources
 _release_grains(sources,event.direction,3,false)
 if sources.is_empty():return
 var source:Vector3=sources[sources.size()/2]
 var first:=particles[3].size()
 _dust(Vector2(source.x,source.z),Color(.53,.49,.37),1,.0026,Vector3(event.direction.x,0,event.direction.y)*.11)
 for i in range(first,particles[3].size()):
  particles[3][i].amount=.10;particles[3][i].life=.22;particles[3][i].duration=.22

func _release_grains(sources:Array[Vector3],direction:Vector2,count:int,contact:bool) -> void:
 var first:=grains.size()
 super._release_grains(sources,direction,count,contact)
 for i in range(first,grains.size()):
  grains[i].color=Color(.29,.27,.21).lerp(Color(.63,.57,.43),rng.randf())
