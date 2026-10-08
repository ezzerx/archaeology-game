extends MaterialFeedback
## Presentation consumer: no height, film, residue, fracture or session writes.
## The native event supplies removal; validated controller hit supplies dry contact.
const CAPACITY := [0,160,128,128]
var impact_age := 1.0
var motion_time := 0.0
var working_last_tick := false
var previous_contact := Vector2.ZERO
var contact_interval := 0.0
var observed_impacts := 0
var last_event_tick := -1
var chips_left := 0
var gentle_contact := false
var dry_contacts := 0
var motion_impacts := 0
var peak_particles := 0
var last_contact_usec := 0

func _create_proxies() -> void:
	for asset in ["brush", "chisel", "blower", "pick"]:
		var proxy := Node3D.new()
		proxy.name = asset.capitalize() + "AuthoredTool"
		add_child(proxy)
		proxies.append(proxy)
		var pose := preload("res://scripts/p6a3/authored_tool_pose.gd").new()
		proxy_poses.append(pose)
		pose.setup(proxy)
		pose.air_tool = asset == "blower"
		pose.attach(load("res://assets/p6a3/models/" + asset + ".glb"))
		proxy.hide()

func _create_audio() -> MaterialAudio:
	return MaterialAudio.new() # Human playtest rollback: original P4/P5 audio.

func setup(target: ExcavationBlock, input: ToolController) -> void:
	super.setup(target,input)
	process_physics_priority = 50 # Observe the native controller after its 60 Hz edit.
	controller.tool_selected.connect(_selected)

func _selected(_index: int) -> void:
	impact_age = 1.0
	working_last_tick = false
	contact_interval = 0.0
	audio.reset()

func _chip_mesh(stone: bool) -> ArrayMesh:
	# Two irregular closed convex shards, never the old unit cube.
	var v := [Vector3(-.5,-.3,-.4),Vector3(.42,-.34,-.48),Vector3(.5,-.2,.37),Vector3(-.36,-.25,.5),
		Vector3(-.39,.24,-.3),Vector3(.28,.39,-.27),Vector3(.34,.28,.22),Vector3(-.3,.32,.3)]
	if stone:
		v[5] = Vector3(.16,.64,-.17)
		v[2] = Vector3(.65,-.31,.22)
	var faces := [[0,2,1],[0,3,2],[4,5,6],[4,6,7],[0,1,5],[0,5,4],
		[1,2,6],[1,6,5],[2,3,7],[2,7,6],[3,0,4],[3,4,7]]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(faces.size()):
		var value := .82 + (i%4)*.06
		for index: int in faces[i]:
			surface.set_color(Color(value,value,value))
			surface.add_vertex(v[index])
	surface.generate_normals()
	return surface.commit()

func _create_particles() -> void:
	super._create_particles()
	for family in [1,2,3]:
		pools[family].instance_count = CAPACITY[family]
		if family != 3: pools[family].mesh = _chip_mesh(family == 2)
		pools[family].set_instance_transform(0,Transform3D(Basis().scaled(Vector3.ONE*.00001),Vector3.ZERO))
		pools[family].set_instance_color(0,colors[family])
		pools[family].visible_instance_count = 1
	# Dust receives the accepted task light, instead of an unlit grey overlay.
	var dust := get_node("AirDust") as MultiMeshInstance3D
	(dust.material_override as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	# Lit billboard normals can face the lamp directly: no specular hot spots
	# on airborne earth. Retain diffuse task-light response and soft transparency.
	(dust.material_override as StandardMaterial3D).metallic_specular = 0.0
	(dust.material_override as StandardMaterial3D).roughness = 1.0
	(dust.material_override as StandardMaterial3D).albedo_color = Color(.32,.32,.32)
	_warmup_frames = 2

func _lift_dust(packets: Array, direction: Vector2) -> void:
	var first := particles[3].size()
	super._lift_dust(packets,direction)
	# The native cleared-dust packets still decide whether a plume exists.
	# Only reduce its screen-space bulk/opacity for this presentation.
	for i in range(first,particles[3].size()):
		particles[3][i].shape *= .6
		particles[3][i].amount *= .3

func _emit(family: int, point: Vector2, count: int, impact := Vector2(INF,INF), detached_depth := 0.0) -> void:
	if not particles_enabled or profile.particle_amount <= 0: return
	var pool := 1 if family == 0 else family
	if pool == 3: return # Continuous dust has its own soft, material-colored emission.
	var origin := point_world(point)
	var center := point_world(impact if impact.is_finite() else point)
	var n := mini(count, 4 if family == 0 else mini(chips_left,6))
	for i in range(n):
		if particles[pool].size() >= CAPACITY[pool]: break
		var size := rng.randf_range(.0008,.0026) if family == 0 else rng.randf_range(.0015,.0055)
		if gentle_contact: size *= .55
		# Rare larger flakes anchor the fracture; most response is small grit.
		if family == 1 and i == 0 and n > 3 and not gentle_contact: size *= 1.5
		var angle := rng.randf_range(-PI,PI)
		var away := Vector3(cos(angle),0,sin(angle))
		if impact.is_finite():
			var outward := Vector3(origin.x-center.x,0,origin.z-center.z)
			if outward.length_squared()>.000001: away=(outward.normalized()+away*.5).normalized()
		var speed := rng.randf_range(.015,.055) if family == 0 else rng.randf_range(.045,.13)
		if gentle_contact: speed *= .5
		var duration := rng.randf_range(.25,.55) if family == 0 else rng.randf_range(.32,.72)
		var spawn := origin+away*rng.randf_range(.0005,.004)
		spawn.y += detached_depth*(block.relief.top_height-block.relief.floor_height)
		var color: Color = colors[family]*rng.randf_range(.92,1.16)
		color.a=1
		particles[pool].append({"position":spawn,"velocity":away*speed+Vector3.UP*speed*.7,
			"life":duration,"duration":duration,"floor":origin.y,"rotation":rng.randf_range(-PI,PI),
			"shape":Vector3(size,size*(.26 if family==1 else .6),size*rng.randf_range(.55,1.1)),"color":color})
		emitted[family]+=1
		if family!=0: chips_left-=1

func _dust(point: Vector2, color: Color, count: int, width := .004, direction := Vector3.ZERO) -> void:
	if not particles_enabled or profile.particle_amount<=0: return
	var origin := point_world(point)
	for i in range(count):
		if particles[3].size()>=CAPACITY[3]: break
		var duration:=rng.randf_range(.23,.5)
		var spread:=Vector3(rng.randf_range(-.007,.007),.001,rng.randf_range(-.007,.007))
		particles[3].append({"position":origin+spread,"velocity":spread*2.0+direction+Vector3.UP*.009,
			"life":duration,"duration":duration,"floor":origin.y,"rotation":rng.randf_range(-PI,PI),
			"shape":Vector3.ONE*width*rng.randf_range(.6,1.15),"color":color,"dust":true,"amount":.026})
		emitted[3]+=1

func on_action(event: Dictionary) -> void:
	var started:=Time.get_ticks_usec()
	last_event_tick=Engine.get_physics_frames()
	gentle_contact=event.get("direct_bone_hit",false) or event.get("bone_revealed",false) or event.get("bone_film_cleared",0.0)>0
	# Only already exposed Bone may soften nearby feedback. Hidden anatomy is ignored.
	var surface:=block.working_map
	for offset in [Vector2i.ZERO,Vector2i(-12,0),Vector2i(12,0),Vector2i(0,-12),Vector2i(0,12)]:
		var cell:Vector2i=(Vector2i(event.point)+offset).clamp(Vector2i.ZERO,surface.size-Vector2i.ONE)
		if surface.fossil.exposed[cell.y*surface.size.x+cell.x]!=0: gentle_contact=true
	chips_left=5 if gentle_contact else 22
	# Existing first-contact protection/damage cues stay driven by the native event.
	super.on_action(event)
	var removed:Vector3=event.removed
	if event.tool in [&"chisel",&"precision_pick"]:
		impact_age=0
		motion_impacts+=1
		var family:=2 if removed.z>removed.y else 1
		if event.tool==&"precision_pick":
			chips_left=3 if not gentle_contact else 1
			if removed.length_squared()>0: _emit(family,event.point,chips_left)
		if removed.length_squared()>0 or event.get("marks",0)>0:
			_dust(event.point,colors[family],1 if gentle_contact else 4,.0025 if gentle_contact else .007)
	last_action_usec=Time.get_ticks_usec()-started

func _physics_process(delta: float) -> void:
	var started:=Time.get_ticks_usec()
	last_contact_usec=0
	if controller==null: return
	contact_interval=maxf(0,contact_interval-delta)
	var active:bool=controller._held and controller.hit.get("inside",false) and controller._focused
	if not active:
		working_last_tick=false
		observed_impacts=controller.total_impacts
		return
	var hit:Dictionary=controller.hit
	var point:Vector2=hit.map
	var speed:=point.distance_to(previous_contact)/delta if working_last_tick else 80.0
	var bone:bool=hit.get("bone_exposed",false) # Never consult hidden Bone to telegraph it.
	var family:int=maxi(0,[&"loose_soil",&"compact_clay",&"sandstone"].find(hit.material.id))
	# Thin Soil can already be gone at the post-edit cursor. Its native removed
	# amount is the authority for this tick's grains, not the newly revealed Clay.
	var action:Dictionary=block.working_map.last_action
	if controller.config.id==&"soft_brush" and not action.is_empty() and action.removed.x>0: family=0
	gentle_contact=bone
	if controller.config.id==&"soft_brush" and contact_interval<=0 and (speed>8 or not working_last_tick):
		contact_interval=.055
		if not bone and family==0:
			_emit(0,point,3)
			_dust(point,colors[0],1,.003)
		elif bone:
			if block.working_map.bone_film.last_cleared>0: _dust(point,colors[0].lightened(.2),1,.002)
		else:
			# Dry contact is cosmetic: a tiny colored abrasion puff, no material removal.
			_dust(point,colors[family].lightened(.13),2,.0045)
			dry_contacts+=1
			audio.update_brush(speed,.035,true)
	if controller.config.id==&"air_blower" and contact_interval<=0:
		contact_interval=.07
		var has_mess:=not block.working_map.last_action.is_empty() or block.working_map.loose_debris.last_blown>0
		if has_mess: _dust(point,colors[family],2,.003,airflow*.6)
	if controller.total_impacts!=observed_impacts and last_event_tick!=Engine.get_physics_frames():
		# No removal (e.g. hard contact): the input still moves, with no fake fracture.
		impact_age=0
		motion_impacts+=1
		if not bone:
			_dust(point,colors[family],1,.002)
			audio.play_family(&"precision_pick",.22,true)
	observed_impacts=controller.total_impacts
	previous_contact=point
	working_last_tick=true
	last_contact_usec=Time.get_ticks_usec()-started

func _process(delta: float) -> void:
	motion_time+=delta
	impact_age+=delta
	super._process(delta)
	peak_particles=maxi(peak_particles,particles[1].size()+particles[2].size()+particles[3].size())

func _update_proxy_pose(selected: int) -> void:
	var proxy:=proxies[selected]
	var pressed:bool=controller._held and controller.hit.inside
	var rotation:=Vector3.ZERO
	var lift:=0.0
	if selected==0 and pressed:
		rotation=Vector3(.025*sin(motion_time*29),0,-.055+.055*sin(motion_time*22))
	elif selected in [1,3] and impact_age<.14:
		var envelope:=sin(PI*clampf(impact_age/.14,0,1))
		lift=envelope*(.006 if selected==1 else .0018)
		rotation.z=envelope*(.065 if selected==1 else .02)
	elif selected==2 and pressed:
		rotation.z=.012*sin(motion_time*35)
	# Follow the pointer, with a fixed presentation angle independent of terrain.
	# A foreground camera plane prevents the mesh entering the working matrix.
	var camera := controller.camera
	var anchor := camera.unproject_position(controller.hit.world)
	var depth := camera.near + .12
	# Measure scale on one fixed ray pair, avoiding pointer-dependent float jitter.
	var pixel_unit := camera.project_position(Vector2(0,1), depth).distance_to(camera.project_position(Vector2.ZERO,depth))
	var visual_scale := pixel_unit * 150.0 / .105
	proxy.global_position = camera.project_position(anchor,depth) + camera.global_basis.y * lift * visual_scale
	proxy.global_basis = camera.global_basis * Basis.from_euler(Vector3(.25,0,-.4)) * Basis.from_euler(rotation)
	proxy.scale = Vector3.ONE * visual_scale * (1.0-.025*(.5+.5*sin(motion_time*22)) if selected==2 and pressed else 1.0)
	proxy_poses[selected].body.position = Vector3.ZERO

func reset() -> void:
	super.reset()
	impact_age=1
	working_last_tick=false
	contact_interval=0
	observed_impacts=controller.total_impacts if controller else 0
	dry_contacts=0
	motion_impacts=0
	peak_particles=0
