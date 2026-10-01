shader_type spatial;
render_mode unshaded;

uniform sampler2D working_map : filter_linear, repeat_disable;
uniform vec2 map_size = vec2(1024.0, 640.0);
uniform vec2 cursor_uv = vec2(0.5);
uniform float cursor_radius = 40.0;
uniform bool cursor_visible = false;

void fragment() {
	float value = texture(working_map, UV).r;
	vec3 grey = mix(vec3(0.12), vec3(0.65), value);
	float distance_texels = length((UV - cursor_uv) * map_size);
	float ring = 1.0 - smoothstep(0.8, 1.8, abs(distance_texels - cursor_radius));
	ALBEDO = mix(grey, vec3(0.95, 0.82, 0.28), cursor_visible ? ring : 0.0);
}
