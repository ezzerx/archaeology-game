shader_type spatial;
render_mode cull_disabled, diffuse_burley;

uniform sampler2D working_map : filter_linear, repeat_disable;
uniform sampler2D layer_boundaries : filter_linear, repeat_disable;
uniform sampler2D residue_map : filter_linear, repeat_disable;
uniform vec2 map_size = vec2(1024.0, 640.0);
uniform float base_height = 0.018;
uniform float excavatable_height = 0.102;
uniform bool is_skirt = false;
uniform int debug_view = 0;
uniform vec4 soil_color : source_color = vec4(0.36, 0.20, 0.105, 1.0);
uniform vec4 clay_color : source_color = vec4(0.58, 0.29, 0.15, 1.0);
uniform vec4 sandstone_color : source_color = vec4(0.78, 0.65, 0.43, 1.0);
uniform vec2 cursor_uv = vec2(0.5);
uniform float cursor_radius = 40.0;
uniform bool cursor_visible = false;
uniform vec4 cursor_color : source_color = vec4(0.95, 0.8, 0.2, 1.0);
varying float surface_height;

void vertex() {
	float height = textureLod(working_map, UV, 0.0).r;
	surface_height = height * (is_skirt ? VERTEX.y : 1.0);
	VERTEX.y = base_height + surface_height * excavatable_height;
}

void fragment() {
	// Derivatives of the real displaced geometry: lighting follows the cavity.
	vec3 relief_normal = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	if (relief_normal.z < 0.0) { relief_normal = -relief_normal; }
	NORMAL = relief_normal;
	vec2 limits = texture(layer_boundaries, UV).rg;
	vec3 color = surface_height > limits.r ? soil_color.rgb : (surface_height > limits.g ? clay_color.rgb : sandstone_color.rgb);
	// Flat grey debug overlay only. Never affects height, normals or picking.
	if (debug_view == 0 && !is_skirt) {
		float residue = texture(residue_map, UV).r;
		color = mix(color, vec3(0.64, 0.66, 0.69), residue * 0.8);
	}
	float distance_texels = length((UV - cursor_uv) * map_size);
	float ring = 1.0 - smoothstep(0.7, 1.6, abs(distance_texels - cursor_radius));
	float centre = 1.0 - smoothstep(0.7, 1.8, distance_texels);
	float marker = cursor_visible && !is_skirt ? max(ring, centre) : 0.0;
	// Keep height in midtones: Compatibility's low-end color conversion otherwise
	// crushes near-zero values, which also obscures differences in this debug view.
	if (debug_view == 1) { color = vec3(0.25 + 0.75 * surface_height); }
	if (debug_view == 3) { color = relief_normal * 0.5 + 0.5; }
	ALBEDO = mix(color, cursor_color.rgb, marker);
	ROUGHNESS = 1.0;
	SPECULAR = 0.15;
	if (debug_view != 0) {
		SPECULAR = 0.0;
		EMISSION = ALBEDO;
		ALBEDO = vec3(0.0);
	} else {
		EMISSION = vec3(0.15, 0.1, 0.01) * marker;
	}
}
