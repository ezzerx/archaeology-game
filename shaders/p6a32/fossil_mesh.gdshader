shader_type spatial;
render_mode diffuse_burley, cull_disabled;
uniform sampler2D working_map : filter_linear, repeat_disable;
uniform sampler2D fossil_map : filter_nearest, repeat_disable;
uniform sampler2D bone_film_map : filter_nearest, repeat_disable;
uniform sampler2D residue_map : filter_linear, repeat_disable;
uniform sampler2D hero_bone : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D source_albedo : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D source_normal : hint_normal, filter_linear_mipmap, repeat_disable;
uniform bool use_source_albedo = false;
uniform bool use_source_normal = false;
uniform int component_filter = 0;
uniform vec2 cursor_uv = vec2(-1.0);
uniform float cursor_radius = 1.0;
uniform bool cursor_visible = false;
uniform vec4 cursor_color : source_color = vec4(.96,.9,.73,1.0);
uniform vec2 map_size = vec2(1024.0,640.0);
uniform vec2 surface_size = vec2(1.1,.7);
uniform float bone_exposure_epsilon = .0000152587890625;
uniform float b17_condition = 100.0;
uniform bool shown = true;
varying vec3 bone_position;
float grain_hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float dust_noise(vec2 p) {
 vec2 cell=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(grain_hash(cell),grain_hash(cell+vec2(1,0)),f.x),mix(grain_hash(cell+vec2(0,1)),grain_hash(cell+vec2(1)),f.x),f.y);
}
#include "res://shaders/p6a31_readability.gdshaderinc"
void vertex() { bone_position=VERTEX; }
void fragment() {
 vec2 uv=bone_position.xz/surface_size+vec2(.5);
 ivec2 cell=clamp(ivec2(uv*map_size),ivec2(0),ivec2(map_size)-ivec2(1));
 vec2 bone=texelFetch(fossil_map,cell,0).rg;
 // Exactly the real CPU/display exposure rule. Hidden bones never draw.
 if (!shown || bone.g<.5 || (component_filter>0 && int(round(bone.g))!=component_filter) || texelFetch(working_map,cell,0).r>bone.r+bone_exposure_epsilon) { discard; }
 vec4 film=texelFetch(bone_film_map,cell/4,0);
 int mask=int(round(film.g*255.0)) | (int(round(film.b*255.0))<<8);
 int bit_index=(cell.y%4)*4+cell.x%4;
 float amount=(mask&(1<<bit_index))!=0 ? film.r : 0.0;
 float patch=dust_noise(vec2(cell)/5.0)*.65+dust_noise(vec2(cell)/1.4)*.35;
 float cover=mastery_film(amount)*(.20+.64*smoothstep(.28,.72,patch));
 vec3 albedo=use_source_albedo ? texture(source_albedo,UV).rgb*vec3(.58,.62,.68) : texture(hero_bone,bone_position.xz/.24).rgb*vec3(.66,.69,.73);
 albedo=mix(albedo,vec3(.18,.135,.085),cover);
 albedo*=1.0-mastery_wear(vec2(cell),b17_condition)*.60;
 float residue=texture(residue_map,uv).r;
 albedo=mix(albedo,vec3(.75,.69,.55),clamp(residue*.2392,0.0,.2392));
 float distance_texels=length((uv-cursor_uv)*map_size);
 float ring=1.0-smoothstep(.7,1.6,abs(distance_texels-cursor_radius*mastery_cursor_scale));
 float centre=1.0-smoothstep(.7,1.8,distance_texels);
 float marker=cursor_visible ? max(ring*.32,centre) : 0.0;
 ALBEDO=mix(albedo,cursor_color.rgb,marker);
 if (use_source_normal) { NORMAL_MAP=texture(source_normal,UV).rgb; NORMAL_MAP_DEPTH=.15; }
 ROUGHNESS=mix(.70,.97,cover);
 SPECULAR=.25*(1.0-cover*.65);
}
