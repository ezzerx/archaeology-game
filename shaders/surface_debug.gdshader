shader_type spatial;
render_mode cull_disabled, diffuse_burley;

uniform sampler2D working_map : filter_linear, repeat_disable;
uniform sampler2D layer_boundaries : filter_linear, repeat_disable;
uniform sampler2D residue_map : filter_linear, repeat_disable;
uniform sampler2D bone_film_map : filter_nearest, repeat_disable;
uniform sampler2D fossil_map : filter_nearest, repeat_disable;
uniform vec2 fragment_visible = vec2(1.0);
uniform int highlighted_fragment = -1;
uniform sampler2D fracture_map : filter_nearest, repeat_disable;
uniform vec2 fracture_sizes = vec2(9.0, 5.0);
uniform float fracture_seed = 0.0;
uniform float bone_exposure_epsilon = 0.0000152587890625;
uniform float surface_layer_epsilon = 0.000001;
uniform vec4 bone_color : source_color = vec4(0.94, 0.87, 0.72, 1.0);
uniform vec2 map_size = vec2(1024.0, 640.0);
uniform vec2 surface_size = vec2(1.1, 0.7);
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
varying vec2 surface_layer_delta;
varying vec3 surface_up;

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
	// PlaneMesh accumulates float32 X/Z increments. Reconstruct from UV like
	// the CPU grid: micrometer drift otherwise moves grazing occlusion edges.
	if (!is_skirt) { VERTEX.xz = (UV - vec2(0.5)) * surface_size; }
	float height = textureLod(working_map, UV, 0.0).r;
	surface_height = height * (is_skirt ? VERTEX.y : 1.0);
	// Subtract at the same grid vertices BEFORE raster interpolation. Comparing
	// triangle height with bilinear fragment limits made a clean floor flicker
	// between materials even when its RF values exactly matched the interface.
	surface_layer_delta = vec2(surface_height) - textureLod(layer_boundaries, UV, 0.0).rg;
	surface_up = normalize((MODELVIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	VERTEX.y = base_height + surface_height * excavatable_height;
}

void fragment() {
	// Derivatives of the real displaced geometry: lighting follows the cavity.
	vec3 relief_normal = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	if (relief_normal.z < 0.0) { relief_normal = -relief_normal; }
	NORMAL = relief_normal;
	int layer = surface_layer_delta.r > surface_layer_epsilon ? 0 : (surface_layer_delta.g > surface_layer_epsilon ? 1 : 2);
	vec3 color = layer == 0 ? soil_color.rgb : (layer == 1 ? clay_color.rgb : sandstone_color.rgb);
	// Discrete exposure agrees with CPU cell accounting. Geometry/picking retain
	// P1's interpolated heightfield; no coplanar second bone mesh or dynamic mask.
	ivec2 cell = clamp(ivec2(UV * map_size), ivec2(0), ivec2(map_size) - ivec2(1));
	vec2 bone = texelFetch(fossil_map, cell, 0).rg;
	bool exposed_bone = !is_skirt && bone.g > 0.5 && texelFetch(working_map, cell, 0).r <= bone.r + bone_exposure_epsilon;
	int fragment_id = int(round(bone.g)) - 5;
	if (fragment_id >= 0 && fragment_id < 2 && fragment_visible[fragment_id] < 0.5) { exposed_bone = false; }
	if (exposed_bone) { color = bone_color.rgb; }
	float dust_cover = 0.0;
	float film_cover = 0.0;
	// Persistent dirt is shaded only; geometry, debug views and picking stay exact.
	if (debug_view == 0 && !is_skirt) {
		if (exposed_bone) {
			vec4 film = texelFetch(bone_film_map, cell / 4, 0);
			int mask = int(round(film.g * 255.0)) | (int(round(film.b * 255.0)) << 8);
			int bit_index = (cell.y % 4) * 4 + cell.x % 4;
			float amount = ((mask & (1 << bit_index)) != 0) ? film.r : 0.0;
			float patch = dust_noise(vec2(cell) / 5.0) * 0.65 + dust_noise(vec2(cell) / 1.4) * 0.35;
			film_cover = amount * (0.20 + 0.64 * smoothstep(0.28, 0.72, patch));
			color = mix(color, bone_color.rgb * vec3(0.32, 0.25, 0.19), film_cover);
		}
		float residue = texture(residue_map, UV).r;
		if (!exposed_bone && layer > 0) {
			bool clay = layer == 1;
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
		// Local substrate is the deliberate source approximation: no extra map.
		vec3 dust_low = layer == 0 ? vec3(0.29, 0.145, 0.063) :
			(layer == 1 ? vec3(0.42, 0.20, 0.105) : vec3(0.56, 0.46, 0.31));
		vec3 dust_high = layer == 0 ? vec3(0.60, 0.40, 0.21) :
			(layer == 1 ? vec3(0.73, 0.46, 0.28) : vec3(0.86, 0.76, 0.58));
		if (exposed_bone) {
			// Locked rule: dust may obscure detail, never material identity.
			// Ivory remains dominant even at saturated residue; never stone grey.
			dust_cover *= 0.26; // <= 0.2392, leaving at least 76% original ivory.
			dust_low = bone_color.rgb * vec3(0.80, 0.78, 0.72);
			dust_high = bone_color.rgb * vec3(0.98, 0.96, 0.91);
		}
		vec3 dust_color = mix(dust_low, dust_high, broad * 0.65 + medium * 0.35);
		color = mix(color, dust_color, dust_cover);
		// A small face-value separation makes existing hard plate walls readable.
		// No AO texture taps, new geometry, cast shadows or change to Bone/Soil.
		if (!exposed_bone && layer > 0) {
			float upright = clamp(abs(dot(relief_normal, normalize(surface_up))), 0.0, 1.0);
			color *= mix(0.76, 1.0, upright);
		}
	}
	float distance_texels = length((UV - cursor_uv) * map_size);
	float ring = 1.0 - smoothstep(0.7, 1.6, abs(distance_texels - cursor_radius));
	float centre = 1.0 - smoothstep(0.7, 1.8, distance_texels);
	float marker = cursor_visible && !is_skirt ? max(ring * (debug_view == 0 ? 0.32 : 1.0), centre) : 0.0;
	if (exposed_bone && fragment_id >= 0 && fragment_id == highlighted_fragment && debug_view == 0) {
		color = mix(color, vec3(0.38, 0.84, 0.73), 0.35);
	}
	// Keep height in midtones: Compatibility's low-end color conversion otherwise
	// crushes near-zero values, which also obscures differences in this debug view.
	if (debug_view == 1) { color = vec3(0.25 + 0.75 * surface_height); }
	if (debug_view == 3) { color = relief_normal * 0.5 + 0.5; }
	ALBEDO = mix(color, cursor_color.rgb, marker);
	ROUGHNESS = mix(exposed_bone ? 0.43 : 0.85, exposed_bone ? 0.65 : 1.0, dust_cover);
	ROUGHNESS = mix(ROUGHNESS, 0.92, film_cover);
	SPECULAR = mix(exposed_bone ? 0.38 : 0.15, exposed_bone ? 0.28 : 0.06, dust_cover);
	SPECULAR *= 1.0 - film_cover * 0.65;
	if (debug_view != 0) {
		SPECULAR = 0.0;
		EMISSION = ALBEDO;
		ALBEDO = vec3(0.0);
	} else {
		EMISSION = vec3(0.15, 0.1, 0.01) * marker;
	}
}
