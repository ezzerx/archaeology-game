class_name P6AMaterialVariants
extends RefCounted
## Lab-only adapters around the untouched P5 shader. Fail loudly if a hook moves.
## Vertex displacement, layer/exposure masks, film coverage, dust and cracks stay P5.
const BASE = preload("res://shaders/surface_debug.gdshader")
const ATLAS = preload("res://assets/p6a/material-atlas.png")
const NAMES := ["P5 · Reference", "A · Procedural", "B · Painted textures", "C · Hybrid materials"]
var shaders: Array[Shader] = [BASE]

func _init() -> void:
	for approach in range(1, 4):
		var code := BASE.code
		code = hook(code, "void vertex() {", "const int LAB_APPROACH = %d;\n" % approach
			+ '#include "res://shaders/p6a_materials.gdshaderinc"\nvoid vertex() {')
		code = hook(code, "float dust_cover = 0.0;", "float lab_roughness = 0.85;\n"
			+ "float lab_bump = 0.0;\n"
			+ "if (debug_view == 0) { color = lab_material(UV, surface_height, surface_layer_delta, layer, exposed_bone, relief_normal, surface_up, lab_roughness, lab_bump); }\n"
			+ "float dust_cover = 0.0;")
		code = hook(code, "color = mix(color, bone_color.rgb * vec3(0.32, 0.25, 0.19), film_cover);",
			"color = mix(color, lab_film_palette ? vec3(0.19, 0.135, 0.105) : bone_color.rgb * vec3(0.32, 0.25, 0.19), film_cover);")
		code = hook(code, "if (debug_view != 0) {", "if (debug_view == 0) {\n"
			+ "ROUGHNESS = mix(mix(lab_roughness, exposed_bone ? 0.65 : 1.0, dust_cover), lab_film_palette ? 0.96 : 0.92, film_cover);\n"
			+ "vec3 lab_n = exposed_bone ? normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(lab_bone_normal(UV), 0.0)).xyz) : relief_normal;\n"
			+ "NORMAL = lab_n;\n"
			+ "if (lab_detail) { NORMAL = lab_normal(VERTEX, lab_n, lab_bump * (1.0 - dust_cover) * (1.0 - film_cover)); }\n"
			+ "}\nif (debug_view != 0) {")
		var shader := Shader.new()
		shader.code = code
		shaders.append(shader)

static func hook(code: String, anchor: String, replacement: String) -> String:
	assert(code.count(anchor) == 1, "P6A adapter needs review: " + anchor)
	return code.replace(anchor, replacement)

func apply(block: ExcavationBlock, candidate: int, patina: bool, stone_patina: bool,
		film_palette: bool, detail: bool) -> void:
	# Reuse the exact material objects: controller and texture uploads keep their refs.
	for material in [block.material, block.skirt_material]:
		material.shader = shaders[candidate]
		if candidate == 0: continue
		material.set_shader_parameter("lab_atlas", ATLAS)
		material.set_shader_parameter("lab_patina", patina)
		material.set_shader_parameter("lab_stone_patina", stone_patina)
		material.set_shader_parameter("lab_film_palette", film_palette)
		material.set_shader_parameter("lab_detail", detail)
