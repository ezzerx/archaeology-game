extends "res://scripts/workshop/lighting/centered_light.gd"
var matrix_edges: Node
var shape_ready := false
func _create_profile() -> SoilFoundationProfile:
	return preload("res://scripts/excavation/block/natural/natural_profile.gd").new(block.working_map,block.footprint)
func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — B-17 · Bloc naturel"
	panel.get_child(0).get_child(0).text = "B-17 / PREMIER BLOC NATUREL"
	matrix_edges = preload("res://scripts/excavation/block/natural/matrix_edges.gd").new()
	add_child(matrix_edges)
	matrix_edges.setup(block)
	block.matrix_edges = matrix_edges
	var done := {}
	for shader in [mesh_surface_shader,baseline_surface_shader,readability_shader,original_hero_shader,witness_shader,soil_shader,hero_shader]:
		if shader == null or done.has(shader): continue
		done[shader] = true
		var code: String = shader.code
		code = code.replace("void vertex() {","uniform sampler2D natural_footprint : filter_nearest, repeat_disable;\nuniform sampler2D exposed_matrix_edges : filter_nearest, repeat_disable;\nuniform bool correct_matrix_edges = true;\nvoid vertex() {\nfloat skirt_fraction = VERTEX.y;")
		code = code.replace("VERTEX.y = base_height + surface_height * excavatable_height;","VERTEX.y = base_height + surface_height * excavatable_height;\nif (is_skirt) { VERTEX.y -= base_height*(1.0-skirt_fraction); }")
		var split := code.find("void fragment() {")
		var vertex := code.substr(0,split)
		var fragment := code.substr(split).replace("surface_layer_delta","material_layer_delta")
		fragment = fragment.replace("void fragment() {","void fragment() {\nif (!is_skirt && texture(natural_footprint,UV).r < .5) { discard; }\nvec2 material_layer_delta = surface_layer_delta;")
		fragment = fragment.replace("if (exposed_bone) { color = bone_color.rgb; }","""
if (!is_skirt && !exposed_bone && correct_matrix_edges && texelFetch(exposed_matrix_edges,cell,0).r > .5) {
 material_layer_delta = vec2(texelFetch(working_map,cell,0).r)-texelFetch(layer_boundaries,cell,0).rg;
 layer = material_layer_delta.r > surface_layer_epsilon ? 0 : (material_layer_delta.g > surface_layer_epsilon ? 1 : 2);
 color = layer == 0 ? soil_color.rgb : (layer == 1 ? clay_color.rgb : sandstone_color.rgb);
}
if (exposed_bone) { color = bone_color.rgb; }
""")
		shader.code = vertex+fragment
	shape_ready = true
	set_hero_look(hero_enabled)
	block.enforce_void()
func set_hero_look(enabled: bool) -> void:
	super.set_hero_look(enabled)
	if jacket != null: jacket.hide()
	# The decorative fixture must never project over the work area at any zoom.
	if lamp_art != null: lamp_art.hide()
	if old_lamp != null: old_lamp.hide()
	if not shape_ready: return
	for mat in [block.material,block.skirt_material]:
		mat.set_shader_parameter("natural_footprint",block.footprint.texture)
		mat.set_shader_parameter("exposed_matrix_edges",matrix_edges.texture)
func toggle_sensory() -> void:
	super.toggle_sensory()
	if lamp_art != null: lamp_art.hide()
	if old_lamp != null: old_lamp.hide()
func reload() -> void:
	super.reload()
	if block != null and block.footprint != null: block.enforce_void()
func _process(delta: float) -> void:
	super._process(delta)
	if matrix_edges != null: matrix_edges.sync()
