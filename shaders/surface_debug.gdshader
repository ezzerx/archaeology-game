shader_type spatial;
render_mode cull_disabled, diffuse_burley;

uniform sampler2D working_map : filter_linear, repeat_disable;
uniform sampler2D layer_boundaries : filter_linear, repeat_disable;
uniform sampler2D residue_map : filter_linear, repeat_disable;
uniform sampler2D fossil_map : filter_nearest, repeat_disable;
uniform sampler2D fracture_map : filter_nearest, repeat_disable;
uniform vec2 fracture_sizes = vec2(9.0, 5.0);
uniform float fracture_seed = 0.0;
uniform float bone_exposure_epsilon = 0.0000152587890625;
uniform vec4 bone_color : source_color = vec4(0.94, 0.87, 0.72, 1.0);
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

float grain_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float dust_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(grain_hash(cell), grain_hash(cell + vec2(1.0, 0.0)), f.x),
		mix(grain_hash(cell + vec2(0.0, 1.0)), grain_hash(cell + vec2(1.0)), f.x), f.y);
}

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
	// Discrete exposure agrees with CPU cell accounting. Geometry/picking retain
	// P1's interpolated heightfield; no coplanar second bone mesh or dynamic mask.
	ivec2 cell = clamp(ivec2(UV * map_size), ivec2(0), ivec2(map_size) - ivec2(1));
	vec2 bone = texelFetch(fossil_map, cell, 0).rg;
	bool exposed_bone = !is_skirt && bone.g > 0.5 && texelFetch(working_map, cell, 0).r <= bone.r + bone_exposure_epsilon;
	if (exposed_bone) { color = bone_color.rgb; }
	float dust_cover = 0.0;
	// Persistent dirt is shaded only; geometry, debug views and picking stay exact.
	if (debug_view == 0 && !is_skirt) {
		float residue = texture(residue_map, UV).r;
		if (!exposed_bone && surface_height <= limits.r) {
			bool clay = surface_height > limits.g;
			vec2 p = vec2(cell);
			vec2 warped = vec2(p.x + 0.25 * p.y + 3.0 * abs(mod(p.y / 7.0 + fracture_seed, 2.0) - 1.0),
				p.y + 2.0 * abs(mod(p.x / 11.0 + fracture_seed, 2.0) - 1.0));
			vec2 partition = warped / (clay ? fracture_sizes.x : fracture_sizes.y);
			ivec2 tile = ivec2(floor(partition)) + ivec2(1);
			vec2 stress = texelFetch(fracture_map, tile, 0).rg;
			float tension = clay ? stress.r : stress.g;
			vec2 edge = min(fract(partition), 1.0 - fract(partition));
			float crack = 1.0 - smoothstep(0.03, 0.11, min(edge.x, edge.y));
			color *= 1.0 - tension * (0.15 + 0.62 * crack);
		}
		// Centimetre-scale deposits survive overview zoom. Warped, broken edges
		// expand with accumulation; smaller speckles belong to those same patches.
		vec2 p = UV * map_size;
		vec2 warp = vec2(dust_noise(p / 31.0), dust_noise(p / 29.0 + vec2(17.0))) * 9.0;
		vec2 q = p + warp;
		float broad = dust_noise(q / 23.0);
		float medium = dust_noise(q / 6.0 + vec2(9.0));
		float fine = dust_noise(q / 1.7);
		float accumulation = pow(residue, 0.55);
		float patch = broad * 0.62 + medium * 0.30 + fine * 0.08;
		float islands = smoothstep(0.64 - accumulation * 0.38, 0.79 - accumulation * 0.38, patch);
		float speckles = smoothstep(0.51, 0.74, medium * 0.6 + fine * 0.4) * smoothstep(0.35, 0.62, broad);
		dust_cover = clamp((islands * 0.88 + speckles * 0.30) * accumulation, 0.0, 0.92);
		vec3 dust_color = mix(vec3(0.34, 0.305, 0.235), vec3(0.67, 0.62, 0.50), broad * 0.65 + medium * 0.35);
		color = mix(color, dust_color, dust_cover);
	}
	float distance_texels = length((UV - cursor_uv) * map_size);
	float ring = 1.0 - smoothstep(0.7, 1.6, abs(distance_texels - cursor_radius));
	float centre = 1.0 - smoothstep(0.7, 1.8, distance_texels);
	float marker = cursor_visible && !is_skirt ? max(ring * (debug_view == 0 ? 0.32 : 1.0), centre) : 0.0;
	// Keep height in midtones: Compatibility's low-end color conversion otherwise
	// crushes near-zero values, which also obscures differences in this debug view.
	if (debug_view == 1) { color = vec3(0.25 + 0.75 * surface_height); }
	if (debug_view == 3) { color = relief_normal * 0.5 + 0.5; }
	ALBEDO = mix(color, cursor_color.rgb, marker);
	ROUGHNESS = mix(exposed_bone ? 0.43 : 0.85, 1.0, dust_cover);
	SPECULAR = mix(exposed_bone ? 0.38 : 0.15, 0.06, dust_cover);
	if (debug_view != 0) {
		SPECULAR = 0.0;
		EMISSION = ALBEDO;
		ALBEDO = vec3(0.0);
	} else {
		EMISSION = vec3(0.15, 0.1, 0.01) * marker;
	}
}
