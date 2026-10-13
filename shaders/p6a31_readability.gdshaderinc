// Cosmetic consumers only: no geometry, exposure, picking or Film-state edits.
uniform float mastery_condition = 100.0;
uniform float mastery_cursor_scale = 1.0;

float mastery_film(float amount) {
	// Preserve exact clean zero; amplify weak real Film, without a dirty floor.
	return pow(clamp(amount / .85, 0.0, 1.0), .40) * .85;
}

float mastery_wear(vec2 cell, float condition) {
	float loss = clamp((100.0 - condition) / 40.0, 0.0, 1.0);
	// Fixed irregular seams, progressively disclosed by the global Condition.
	// Decorative wear across exposed Bone; no invented local damage authority.
	vec2 q = vec2(cell.x + dust_noise(cell / 9.0) * 6.0, cell.y);
	float ridge = abs(fract((q.x + q.y * .43) / 18.0) - .5);
	float crack = 1.0 - smoothstep(.018, .07, ridge);
	float location = dust_noise(cell / 13.0 + vec2(19.0, 7.0));
	float admission = smoothstep(.0, .12, loss - location * .85);
	return crack * admission * min(loss * 2.0, 1.0);
}
