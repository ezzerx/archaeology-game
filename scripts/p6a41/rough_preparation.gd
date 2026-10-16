extends "res://scripts/p6a40/natural_preparation.gd"
var rough_ready := false
var wall_shaders := {}
func _create_profile() -> SoilFoundationProfile:
	return preload("res://scripts/p6a41/rough_profile.gd").new(block.working_map,block.footprint,block.rim)
func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — B-17 · Bords bruts"
	panel.get_child(0).get_child(0).text = "B-17 / BORDS BRUTS"
	rough_ready = true
	set_hero_look(hero_enabled)
func set_hero_look(enabled: bool) -> void:
	super.set_hero_look(enabled)
	if not rough_ready: return
	var base: Shader = block.skirt_material.shader
	if not wall_shaders.has(base):
		var shader := Shader.new()
		var code := base.code
		code = _hook(code,"void vertex() {","varying vec3 cliff_normal;\nvarying vec3 cliff_position;\nvoid vertex() {")
		code = _hook(code,"surface_up = normalize((MODELVIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);","surface_up = normalize((MODELVIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);\ncliff_normal = normalize((MODELVIEW_MATRIX*vec4(NORMAL,0.0)).xyz);")
		code = _hook(code,"if (is_skirt) { VERTEX.y -= base_height*(1.0-skirt_fraction); }","if (is_skirt) { VERTEX.y -= base_height*(1.0-skirt_fraction); }\ncliff_position = VERTEX;")
		code = _hook(code,"vec3 relief_normal = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));","vec3 relief_normal = normalize(cliff_normal);")
		code = _hook(code,"ALBEDO = mix(color, cursor_color.rgb, marker);","color *= mix(.92,1.18,dust_noise(vec2(cliff_position.x+cliff_position.z*.7,cliff_position.y)*180.0));\nALBEDO = mix(color, cursor_color.rgb, marker);")
		shader.code = code
		wall_shaders[base] = shader
	block.skirt_material.shader = wall_shaders[base]
