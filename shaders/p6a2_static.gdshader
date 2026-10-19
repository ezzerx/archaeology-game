shader_type spatial;
// Godot 4.7 Compatibility / Mobile / Forward+. Opaque; no screen/depth reads.
// Plaster: three authored texture samples. Wood/linen: zero texture samples.
// VERTEX is model space in vertex(), view space in fragment(); COLOR is vertex AO.
render_mode diffuse_burley;

uniform int kind : hint_enum("Plaster", "Walnut", "Linen") = 0;
uniform sampler2D plaster_source : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float plaster_scale : hint_range(0.05, 0.5, 0.01) = 0.24;
uniform float plaster_relief : hint_range(0.0, 0.004, 0.0001) = 0.0012;
uniform vec4 wood_dark : source_color = vec4(0.125, 0.094, 0.069, 1.0);
uniform vec4 wood_light : source_color = vec4(0.255, 0.182, 0.125, 1.0);
uniform float plank_width : hint_range(0.08, 0.4, 0.01) = 0.185;
uniform float wood_relief : hint_range(0.0, 0.002, 0.0001) = 0.00018;
uniform float wood_roughness : hint_range(0.35, 0.95, 0.01) = 0.71;
uniform vec4 linen_color : source_color = vec4(0.35, 0.27, 0.16, 1.0);
uniform float thread_spacing : hint_range(0.0005, 0.004, 0.0001) = 0.0015;
uniform float linen_relief : hint_range(0.0, 0.001, 0.00001) = 0.00018;
varying vec3 local_pos;

void vertex() { local_pos = VERTEX; }
float grain_hash_static(vec2 p) {
 return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float grain_noise_static(vec2 p) {
 vec2 i = floor(p), f = fract(p);
 f = f * f * (3.0 - 2.0 * f);
 return mix(mix(grain_hash_static(i), grain_hash_static(i + vec2(1, 0)), f.x),
  mix(grain_hash_static(i + vec2(0, 1)), grain_hash_static(i + vec2(1)), f.x), f.y);
}
vec3 tactile_normal(vec3 view_position, vec3 normal, float height) {
 vec3 dx = dFdx(view_position), dy = dFdy(view_position);
 vec3 rx = cross(dy, normal), ry = cross(normal, dx);
 float det = dot(dx, rx);
 vec3 gradient = (dFdx(height) * rx + dFdy(height) * ry) * sign(det) / max(abs(det), 0.00000001);
 // Cap at a grazing angle: subpixel seams cannot turn into glittering facets.
 gradient *= min(1.0, 0.65 / max(length(gradient), 0.00001));
 return normalize(normal - gradient);
}
void fragment() {
 vec3 p = local_pos;
 float height = 0.0;
 if (kind == 0) {
  vec3 normal_local = normalize(cross(dFdx(p), dFdy(p)));
  vec3 weights = pow(abs(normal_local), vec3(5.0));
  weights /= max(dot(weights, vec3(1.0)), 0.0001);
  vec3 source = texture(plaster_source, p.yz / plaster_scale).rgb * weights.x
   + texture(plaster_source, p.xz / plaster_scale).rgb * weights.y
   + texture(plaster_source, p.xy / plaster_scale).rgb * weights.z;
  float chalk = dot(source, vec3(0.2126, 0.7152, 0.0722));
  ALBEDO = source * COLOR.rgb * 1.5;
  height = chalk * plaster_relief;
  ROUGHNESS = mix(0.99, 0.88, chalk);
  SPECULAR = 0.16;
 } else if (kind == 1) {
  float board = floor((p.x + 1.0) / plank_width);
  float seed = grain_hash_static(vec2(board, 8.0));
  vec2 grain_uv = vec2(p.x, p.z + seed * 3.0);
  float slow = grain_noise_static(grain_uv * vec2(5.0, 1.2));
  float warp = sin(p.z * 4.0 + seed * 9.0) * 0.007 + (slow - 0.5) * 0.018;
  // Aperiodic longitudinal fibres avoid striped veneer at overview distance.
  float growth = grain_noise_static(vec2((p.x + warp) * 90.0, p.z * 3.0));
  float fibres = grain_noise_static(vec2((p.x + warp) * 430.0, p.z * 25.0));
  float resolved = 1.0 - smoothstep(0.4, 1.2, fwidth(p.x * 430.0));
  fibres = mix(0.5, fibres, resolved);
  float tone = clamp(0.46 + slow * 0.18 + growth * 0.13 + fibres * 0.08, 0.0, 1.0);
  float board_x = fract((p.x + 1.0) / plank_width);
  float edge = min(board_x, 1.0 - board_x) * plank_width;
  float seam = smoothstep(0.00035, 0.0016, edge);
  float worn = grain_noise_static(grain_uv * vec2(9.0, 13.0));
  ALBEDO = mix(wood_dark.rgb, wood_light.rgb, tone);
  ALBEDO *= (0.95 + seed * 0.08) * mix(0.47, 1.0, seam);
  height = (growth * 0.30 + fibres * 0.30 + seam * 0.40) * wood_relief;
  ROUGHNESS = clamp(wood_roughness + (worn - 0.5) * 0.18 + (1.0 - seam) * 0.22, 0.35, 0.95);
  SPECULAR = 0.23;
 } else {
  vec2 thread = p.xz / thread_spacing;
  vec2 resolution = vec2(1.0) - smoothstep(vec2(0.22), vec2(0.85), fwidth(thread));
  vec2 weave = cos(thread * TAU) * resolution;
  float strand = (weave.x + weave.y) * 0.25 + 0.5;
  float fleck = grain_noise_static(p.xz * 130.0);
  ALBEDO = linen_color.rgb * (0.84 + strand * 0.21 + fleck * 0.12);
  height = strand * linen_relief;
  ROUGHNESS = 0.98;
  SPECULAR = 0.10;
 }
 NORMAL = tactile_normal(VERTEX, NORMAL, height);
}
