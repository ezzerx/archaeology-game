extends RefCounted
## Gallery-only lighting. The preparation renderer and project settings stay intact.
static func install(g:Node3D) -> void:
 var forward:=RenderingServer.get_current_rendering_method()=="forward_plus"
 if forward:
  RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
  RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
  g.get_viewport().use_taa=true
  RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM,true,.5,2,20.,40.)
  RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM,true,.5,2,20.,40.)
 var world:=WorldEnvironment.new();world.name="GalleryLighting";g.add_child(world)
 var env:=Environment.new();world.environment=env
 env.background_mode=Environment.BG_COLOR;env.background_color=Color("#263334")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color("#c5d4d3");env.ambient_light_energy=.38
 env.reflected_light_source=Environment.REFLECTION_SOURCE_SKY
 var sky:=Sky.new();var sky_mat:=ProceduralSkyMaterial.new()
 sky_mat.sky_top_color=Color("#9abac8");sky_mat.sky_horizon_color=Color("#dfd5bd")
 sky_mat.ground_bottom_color=Color("#403322");sky_mat.ground_horizon_color=Color("#a09072")
 sky_mat.sky_energy_multiplier=.45;sky_mat.ground_energy_multiplier=.35
 sky.sky_material=sky_mat;env.sky=sky
 env.tonemap_mode=Environment.TONE_MAPPER_AGX if forward else Environment.TONE_MAPPER_FILMIC
 env.tonemap_exposure=2.1 if forward else .9
 env.ssao_enabled=true;env.ssao_radius=.24;env.ssao_intensity=1.1
 env.ssao_power=1.35;env.ssao_detail=.6;env.ssao_light_affect=.35
 env.ssil_enabled=forward;env.ssil_radius=1.7;env.ssil_intensity=.40
 env.glow_enabled=true;env.glow_intensity=.22
 env.glow_hdr_threshold=1.4;env.glow_bloom=0.
 var key:=DirectionalLight3D.new();key.name="WindowDaylight";g.add_child(key)
 key.rotation_degrees=Vector3(-38,-56,0);key.light_color=Color("#fff0da")
 key.light_energy=1.2;key.light_angular_distance=3.5;key.shadow_enabled=true
 key.directional_shadow_max_distance=18;key.shadow_bias=.025;key.shadow_normal_bias=.35
 var fill:=DirectionalLight3D.new();fill.name="RoomBounce";g.add_child(fill)
 fill.rotation_degrees=Vector3(-55,125,0);fill.light_color=Color("#d6dfdd");fill.light_energy=.22
 # Broad exhibition beams preserve the readable specimen relief during inspection.
 for x in [-1.65,1.62]:
  var light:=SpotLight3D.new();light.name="SpecimenLight"+str(x);g.add_child(light)
  light.position=Vector3(x-.5,3.65,1.45);light.look_at(Vector3(x,1.,0))
  light.light_color=Color("#ffe3b7");light.light_energy=.48
  light.spot_range=5.;light.spot_angle=43;light.spot_attenuation=.75
  light.shadow_enabled=true;light.light_size=.20
  light.shadow_bias=.025;light.shadow_normal_bias=.12
 var probe:=ReflectionProbe.new();probe.name="GalleryReflection";g.add_child(probe)
 probe.position=Vector3(0,1.8,-.5);probe.size=Vector3(13,6,9)
 probe.box_projection=true;probe.interior=true;probe.intensity=.55
 probe.max_distance=18;probe.update_mode=ReflectionProbe.UPDATE_ONCE
static func emitter(parent:Node3D,pos:Vector3,radius:float) -> MeshInstance3D:
 var sphere:=SphereMesh.new();sphere.radius=radius;sphere.height=radius*.5
 sphere.radial_segments=24;sphere.rings=12
 var m:=StandardMaterial3D.new();m.albedo_color=Color("#fff0c9")
 m.emission_enabled=true;m.emission=Color("#ffca79");m.emission_energy_multiplier=3.5
 m.roughness=.55
 var bulb:=MeshInstance3D.new();bulb.mesh=sphere;bulb.material_override=m
 bulb.position=pos;bulb.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(bulb)
 return bulb
