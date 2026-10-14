shader_type spatial;
render_mode diffuse_burley;
uniform sampler2D working_map : filter_linear, repeat_disable;
uniform sampler2D fossil_map : filter_nearest, repeat_disable;
uniform sampler2D bone_film_map : filter_nearest, repeat_disable;
uniform sampler2D residue_map : filter_linear, repeat_disable;
uniform sampler2D production_coverage : filter_nearest, repeat_disable;
uniform vec2 map_size = vec2(1024.0,640.0);
uniform vec2 surface_size = vec2(1.1,.7);
uniform float excavatable_height = .102;
uniform bool shown = true;
uniform bool inspection = false;
uniform vec2 cursor_uv = vec2(-1.0);
uniform float cursor_radius = 1.0;
uniform bool cursor_visible = false;
uniform vec4 cursor_color : source_color = vec4(.96,.9,.73,1.0);
varying vec3 bone_position;
varying vec3 bone_normal;
varying float bone_occlusion;
float grain_hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float dust_noise(vec2 p) {
 vec2 c=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(grain_hash(c),grain_hash(c+vec2(1,0)),f.x),mix(grain_hash(c+vec2(0,1)),grain_hash(c+vec2(1)),f.x),f.y);
}
#include "res://shaders/p6a2_materials.gdshaderinc"
#include "res://shaders/p6a31_readability.gdshaderinc"
#include "res://shaders/p6a33_local_damage.gdshaderinc"
void vertex() { bone_position=VERTEX; bone_normal=NORMAL; bone_occlusion=COLOR.r; }
void fragment() {
 if (!shown) { discard; }
 vec2 uv=bone_position.xz/surface_size+vec2(.5);
 ivec2 cell=clamp(ivec2(uv*map_size),ivec2(0),ivec2(map_size)-ivec2(1));
 float cover=0.0;
 vec3 albedo=hero_albedo(bone_position,normalize(bone_normal),3);
 // Short-range baked occlusion preserves warm ivory in broad lit faces.
 albedo *= mix(vec3(.64,.60,.53),vec3(1.0),bone_occlusion);
 float cavity=inspection ? 0.0 : hero_cavity(uv,(bone_position.y-.018)/excavatable_height);
 albedo *= 1.0-cavity*.45;
 if (!inspection) {
  vec2 bone=texelFetch(fossil_map,cell,0).rg;
  if (texelFetch(production_coverage,cell,0).r < .5 || bone.g < .5 || texelFetch(working_map,cell,0).r > bone.r+.0000152587890625) { discard; }
  vec4 film=texelFetch(bone_film_map,cell/4,0);
  int mask=int(round(film.g*255.0)) | (int(round(film.b*255.0))<<8);
  int bit_index=(cell.y%4)*4+cell.x%4;
  float amount=(mask&(1<<bit_index))!=0 ? film.r : 0.0;
  float patch=dust_noise(vec2(cell)/5.0)*.65+dust_noise(vec2(cell)/1.4)*.35;
  cover=pow(clamp(amount/.85,0.0,1.0),.65)*.85*(.20+.64*smoothstep(.28,.72,patch));
  albedo=mix(albedo,vec3(.46,.405,.31)*vec3(.48,.37,.24),cover);
  albedo*=1.0-local_bone_wear(vec2(cell))*.60;
  float residue=texture(residue_map,uv).r;
  albedo=mix(albedo,vec3(.35,.30,.22),clamp(residue*.2392,0.0,.2392));
  float distance_texels=length((uv-cursor_uv)*map_size);
  float ring=1.0-smoothstep(.7,1.6,abs(distance_texels-cursor_radius*mastery_cursor_scale));
  float centre=1.0-smoothstep(.7,1.8,distance_texels);
  float marker=cursor_visible ? max(ring*.32,centre) : 0.0;
  albedo=mix(albedo,cursor_color.rgb,marker);
 }
 ALBEDO=albedo;
 ROUGHNESS=mix(.67,.97,cover);
 SPECULAR=.28*(1.0-cover*.65);
}
