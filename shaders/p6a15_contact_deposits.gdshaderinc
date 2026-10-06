// Visual-only contamination, independent of Bone Film and all gameplay masks.
uniform bool soil_lab_patina = true;

float soil_contact_deposit(vec2 uv, vec2 delta, int layer) {
	vec2 p = uv * map_size;
	vec2 warp = vec2(dust_noise(p / 71.0), dust_noise(p / 67.0 + vec2(13.0))) * 22.0;
	vec2 q = p + warp;
	float broad = dust_noise(q / 37.0);
	float medium = dust_noise(q / 9.0 + vec2(19.0));
	float fine = dust_noise(q / 2.3);
	float patch = broad * 0.60 + medium * 0.30 + fine * 0.10;
	// Exactly zero between islands. There is no uniform brown base tint.
	float islands = smoothstep(0.47, 0.66, patch);
	float broken = smoothstep(0.28, 0.48, medium * 0.72 + fine * 0.28);
	float cut_mm = max(0.0, -delta.r) * excavatable_height * 1000.0;
	if (layer == 2) { cut_mm = min(cut_mm, max(0.0, -delta.g) * excavatable_height * 1000.0); }
	float skin = 1.0 - smoothstep(0.10, 1.0, cut_mm);
	return islands * broken * (0.40 + 0.22 * fine) * skin * (layer == 1 ? 1.0 : 0.52);
}
