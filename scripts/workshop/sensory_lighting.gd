extends RefCounted
## Warm directional workshop rig, safe in Godot 4.7 Compatibility.
## Apply after inherited preparation _ready / look changes. Reuses the three
## existing lights; no extra shadow caster, screen copy, fog or postprocess.

static func setup(preparation: Node3D) -> void:
 # Multisampling keeps the thin tools, book edges and real block silhouette crisp.
 preparation.get_viewport().msaa_3d = Viewport.MSAA_4X
 var world := preparation.get_node_or_null("TableEnvironment/WorldEnvironment") as WorldEnvironment
 var key := preparation.get_node_or_null("TableEnvironment/Light") as DirectionalLight3D
 if world == null or key == null:
  return
 var environment := world.environment.duplicate() as Environment
 environment.background_color = Color(0.105, 0.082, 0.060)
 environment.ambient_light_color = Color(0.81, 0.86, 0.92)
 environment.ambient_light_energy = 0.29
 world.environment = environment
 # Warm light travels across the material ridges. The neutral skylight keeps
 # sediment, clay, cream bone and brown dirt distinct in the shadowed faces.
 key.rotation_degrees = Vector3(-48.0, -138.0, 0.0)
 key.light_color = Color(1.0, 0.94, 0.84)
 key.light_energy = 0.63
 # Keep the existing exposed-cell shadow system and its bias unchanged.
 var lamp := preparation.get("task_light") as SpotLight3D
 if lamp != null:
  lamp.position = Vector3(-0.35, 0.80, -0.29)
  lamp.look_at(Vector3(0.0, 0.045, 0.0), Vector3.UP)
  lamp.light_color = Color(1.0, 0.93, 0.81)
  lamp.light_energy = 0.44
  lamp.spot_range = 1.9
  lamp.spot_angle = 64.0
  lamp.spot_angle_attenuation = 0.45
  lamp.spot_attenuation = 0.7
 var bounce := preparation.get("bench_bounce") as OmniLight3D
 if bounce != null:
  bounce.position = Vector3(0.15, 0.20, 0.62)
  bounce.light_color = Color(0.91, 0.94, 1.0)
  bounce.light_energy = 0.16
  bounce.omni_range = 1.2
  bounce.omni_attenuation = 2.0
  bounce.shadow_enabled = false
