// P6A-1 appearance only. All geometric/mask authorities remain in surface_debug.
uniform sampler2D lab_atlas : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform bool lab_patina = true;
uniform bool lab_stone_patina = false;
uniform bool lab_film_palette = true;
uniform bool lab_detail = true;

vec3 lab_tex(vec2 p, int material_id) {
	// Mirror inside an inset quadrant; no cross-material bleed and no wrap seam.
	// Mirroring is a spike compromise; authored seamless tiles are the production option.
	vec2 q = 1.0 - abs(mod(p, 2.0) - 1.0);
	vec2 tile = vec2(float(material_id % 2), float(material_id / 2));
	return texture(lab_atlas, tile * 0.5 + vec2(0.015) + q * 0.47).rgb;
}

vec3 lab_material(vec2 uv, float height, vec2 layer_delta, int layer, bool bone,
		vec3 normal, vec3 up, out float roughness, out float bump) {
	int id = bone ? 3 : layer;
	vec2 p = uv * surface_size * 4.0;
	float broad = dust_noise(p * 3.1 + vec2(3.4, 9.1));
	float grain = dust_noise(p * 90.0);
	vec3 base = id == 0 ? vec3(0.32, 0.205, 0.12) : (id == 1 ? vec3(0.64, 0.305, 0.135) :
		(id == 2 ? vec3(0.61, 0.49, 0.32) : vec3(0.73, 0.73, 0.67)));
	float detail_value = grain;
	if (LAB_APPROACH == 1) {
		float streak = dust_noise(vec2(p.x * 12.0 + broad, p.y * 38.0));
		float variation = (broad - 0.5) * 0.16 + (streak - 0.5) * 0.07 + (grain - 0.5) * 0.075;
		base *= 1.0 + variation * (bone ? 0.25 : 1.0);
		detail_value = grain * 0.75 + streak * 0.25;
	} else {
		vec3 painted = lab_tex(p, id);
		if (LAB_APPROACH == 3) {
			// Additional side projection avoids stretching down deep cavity walls.
			float wall = 1.0 - smoothstep(0.30, 0.88, abs(dot(normal, normalize(up))));
			vec3 side = lab_tex(vec2(p.x + p.y * 0.35, height * excavatable_height * 4.0), id);
			painted = mix(painted, side, wall * 0.80);
			painted *= 1.0 + (broad - 0.5) * (bone ? 0.035 : 0.22);
		}
		// Compress contrast into a painted palette instead of importing photo-like grit.
		vec3 tinted = painted * (id == 0 ? vec3(0.73, 0.81, 0.90) :
			(id == 1 ? vec3(0.80, 0.89, 0.94) : (id == 2 ? vec3(0.75, 0.78, 0.84) : vec3(0.80, 0.84, 0.89))));
		base = mix(base, tinted, bone ? 0.75 : 0.68);
		detail_value = dot(painted, vec3(0.299, 0.587, 0.114));
	}
	roughness = bone ? 0.40 : (layer == 0 ? 0.97 : (layer == 1 ? 0.87 : 0.91));
	roughness = clamp(roughness + (detail_value - 0.5) * (bone ? 0.025 : 0.08), 0.0, 1.0);
	// Cosmetic shader distance band in mm; never a layer or excavation stop.
	if (!bone && layer == 1 && lab_patina) {
		float cut_mm = max(0.0, -layer_delta.r) * excavatable_height * 1000.0;
		float skin = (1.0 - smoothstep(0.20, 2.4, cut_mm)) * (0.65 + 0.22 * broad);
		base = mix(base, base * vec3(0.59, 0.65, 0.73), skin);
		roughness = mix(roughness, 0.97, skin);
	}
	if (!bone && layer == 2 && lab_stone_patina) {
		float cut_mm = max(0.0, -layer_delta.g) * excavatable_height * 1000.0;
		float skin = (1.0 - smoothstep(0.15, 1.4, cut_mm)) * 0.35;
		base = mix(base, base * vec3(0.76, 0.67, 0.56), skin);
	}
	// Sub-mm shading relief. Neither VERTEX, depth, silhouette nor pick is changed.
	bump = detail_value * (bone ? 0.000025 : (layer == 0 ? 0.00042 : 0.00018));
	return base;
}

vec3 lab_bone_normal(vec2 uv) {
	// A centred normal on the SAME heightfield softens Bone's visible triangle
	// facets. No normal map, offset vertex, dilation of the Bone mask or extra mesh.
	vec2 step_uv = 1.0 / map_size;
	float left = texture(working_map, uv - vec2(step_uv.x, 0.0)).r;
	float right = texture(working_map, uv + vec2(step_uv.x, 0.0)).r;
	float back = texture(working_map, uv - vec2(0.0, step_uv.y)).r;
	float front = texture(working_map, uv + vec2(0.0, step_uv.y)).r;
	vec2 slope = vec2(right - left, front - back) * excavatable_height / (2.0 * step_uv * surface_size);
	return normalize(vec3(-slope.x, 1.0, -slope.y));
}

vec3 lab_normal(vec3 position_view, vec3 n, float bump) {
	// Screen derivatives build a surface gradient on the real displaced triangles.
	vec3 dx = dFdx(position_view);
	vec3 dy = dFdy(position_view);
	vec3 r1 = cross(dy, n);
	vec3 r2 = cross(n, dx);
	float determinant = dot(dx, r1);
	vec3 gradient = (r1 * dFdx(bump) + r2 * dFdy(bump)) / max(abs(determinant), 1e-10) * sign(determinant);
	return normalize(n - clamp(gradient, vec3(-0.32), vec3(0.32)));
}
