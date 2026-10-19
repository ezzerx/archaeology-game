extends RefCounted
## Museum-only Forward+ rig. Sun + four bounded local shadows; measured on real archives.
## No SSIL, SDFGI, volumetric fog or screen reflection. Preparation stays untouched.
static func install(g: Node3D) -> void:
 var forward := RenderingServer.get_current_rendering_method() == "forward_plus"
 if forward:
  RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
  RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
  RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, .5, 2, 20., 40.)
 var world := WorldEnvironment.new()
 world.name = "GalleryLighting"
 g.add_child(world)
 var env := Environment.new()
 world.environment = env
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color("#342b20")
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("#c7cbc5")
 env.ambient_light_energy = .24
 env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
 var sky := Sky.new()
 var sky_mat := ProceduralSkyMaterial.new()
 sky_mat.sky_top_color = Color("#afc1c5")
 sky_mat.sky_horizon_color = Color("#f2dfbb")
 sky_mat.ground_bottom_color = Color("#3b2c1e")
 sky_mat.ground_horizon_color = Color("#ac8e60")
 sky_mat.sky_energy_multiplier = .48
 sky_mat.ground_energy_multiplier = .32
 sky.sky_material = sky_mat
 env.sky = sky
 env.tonemap_mode = Environment.TONE_MAPPER_AGX if forward else Environment.TONE_MAPPER_FILMIC
 env.tonemap_exposure = 1.85 if forward else .9
 env.ssao_enabled = forward
 env.ssao_radius = .20
 env.ssao_intensity = 1.0
 env.ssao_power = 1.15
 env.ssao_detail = .5
 env.ssao_light_affect = .25
 env.ssil_enabled = false
 env.glow_enabled = forward
 env.glow_intensity = .15
 env.glow_hdr_threshold = 1.6
 env.glow_bloom = 0.
 var sun := DirectionalLight3D.new()
 sun.name = "WindowDaylight"
 g.add_child(sun)
 # Light travels from the real left window toward the room and right foreground.
 sun.rotation_degrees = Vector3(-23.0, -119.0, 0.0)
 sun.light_color = Color("#ffe8c7")
 sun.light_energy = 2.8
 sun.light_angular_distance = 1.35
 sun.shadow_enabled = true
 sun.directional_shadow_max_distance = 17.0
 sun.shadow_bias = .022
 sun.shadow_normal_bias = .22
 var fill := DirectionalLight3D.new()
 fill.name = "RoomBounce"
 g.add_child(fill)
 # Approximate light returning from the sunlit foreground onto the wall fronts.
 fill.rotation_degrees = Vector3(-48.0, 35.0, 0.0)
 fill.light_color = Color("#d5dfdc")
 fill.light_energy = .30
 fill.shadow_enabled = false
 # Raking exhibit keys reveal the existing fossil relief without changing materials.
 # Two local shadows cost about .5 ms on the dense real QA archives at 1080p.
 for x in [-1.65, 1.62]:
  var exhibit_key := _spot(g, "SpecimenLight" + str(x), Vector3(x-1.40,2.8,.90), Vector3(x,1.15,0.), 5.0, 5.0, 43.0, Color("#ffe5c1"))
  exhibit_key.light_specular = .55 # Keep the varnished frame highlights below a broad white stripe.
  exhibit_key.shadow_enabled = true
  exhibit_key.shadow_bias = .025
  exhibit_key.shadow_normal_bias = .25
  exhibit_key.light_size = .20
 # Practical fixtures match the authored architecture. Ranges end in the niche.
 # Only the upper niche keys cast shadows; shelf/cabinet fills stay unshadowed.
 for x in [-3.78, -1.40, 1.40, 3.78]:
  _spot(g, "WallLampPool" + str(x), Vector3(x,2.43,-1.43), Vector3(x,1.70,-2.02), 3.4, 2.5, 54.0, Color("#ffcc83"))
 for x in [-2.65, 2.65]:
  for y in [2.98,2.32]:
   var niche_key := _spot(g, "NicheDownlight" + str(x) + "_" + str(y), Vector3(x,y,-1.81), Vector3(x,y-.55,-2.42), 1.65, 1.65, 53.0, Color("#ffce8b"))
   niche_key.shadow_enabled = y > 2.5
   niche_key.shadow_bias = .025
   niche_key.shadow_normal_bias = .25
   niche_key.light_size = .08
 for y in [2.98, 2.38, 1.77]:
  _spot(g, "CabinetDownlight" + str(y), Vector3(0,y,-1.48), Vector3(0,y-.48,-2.05), 1.10, 1.40, 64.0, Color("#ffd39a"))
 var probe := ReflectionProbe.new()
 probe.name = "GalleryReflection"
 g.add_child(probe)
 probe.position = Vector3(0,1.8,-.5)
 probe.size = Vector3(13,6,9)
 probe.box_projection = true
 probe.interior = true
 probe.intensity = .60
 probe.max_distance = 18
 probe.update_mode = ReflectionProbe.UPDATE_ONCE

static func _spot(parent: Node3D, label: String, pos: Vector3, target: Vector3, energy: float, distance: float, angle: float, color: Color) -> SpotLight3D:
 var light := SpotLight3D.new()
 light.name = label
 parent.add_child(light)
 light.position = pos
 light.look_at(target)
 light.light_color = color
 light.light_energy = energy
 light.spot_range = distance
 light.spot_angle = angle
 light.spot_angle_attenuation = .7
 light.spot_attenuation = 1.0
 light.shadow_enabled = false
 return light

static func emitter(parent: Node3D, pos: Vector3, radius: float) -> MeshInstance3D:
 var sphere := SphereMesh.new()
 sphere.radius = radius
 sphere.height = radius*.5
 sphere.radial_segments = 20
 sphere.rings = 10
 var material := StandardMaterial3D.new()
 material.albedo_color = Color("#e8c78f")
 material.emission_enabled = true
 material.emission = Color("#ffcd83")
 material.emission_energy_multiplier = 1.8
 material.roughness = .65
 var bulb := MeshInstance3D.new()
 bulb.mesh = sphere
 bulb.material_override = material
 bulb.position = pos
 bulb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 parent.add_child(bulb)
 return bulb
