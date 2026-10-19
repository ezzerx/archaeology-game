shader_type spatial;
// Opaque distant garden/sky backdrop. Zero texture samples, no animation jitter.
render_mode unshaded, cull_disabled;
uniform vec4 sky_high : source_color = vec4(.63,.72,.71,1.0);
uniform vec4 sky_low : source_color = vec4(.98,.83,.54,1.0);
uniform vec4 leaf_dark : source_color = vec4(.24,.34,.14,1.0);
uniform vec4 leaf_light : source_color = vec4(.72,.68,.30,1.0);
uniform float foliage_amount : hint_range(0.0,1.0,.01) = .52;
uniform float daylight_value : hint_range(.5,2.5,.05) = 1.45;
float garden_hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float garden_noise(vec2 p) {
 vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(garden_hash(i),garden_hash(i+vec2(1,0)),f.x),mix(garden_hash(i+vec2(0,1)),garden_hash(i+vec2(1)),f.x),f.y);
}
void fragment() {
 vec3 sky=mix(sky_high.rgb,sky_low.rgb,smoothstep(.03,.72,UV.y));
 float tree= garden_noise(UV*vec2(22,14))*.62
  + garden_noise(UV*vec2(49,34)+vec2(5.3,2.1))*.28
  + garden_noise(UV*vec2(105,71))*.10;
 float canopy=smoothstep(.43,.62,tree+UV.y*.17)*foliage_amount;
 vec3 leaves=mix(leaf_dark.rgb,leaf_light.rgb,smoothstep(.35,.7,tree));
 ALBEDO=mix(sky,leaves,canopy)*daylight_value;
}
