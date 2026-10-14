shader_type spatial;
render_mode cull_back;
uniform sampler2D hero_soil : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_clay : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_stone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cracks : filter_linear, repeat_disable;
uniform vec4 soil_color : source_color = vec4(.265,.175,.10,1.0);
uniform vec3 rock_origin = vec3(0.0);
uniform vec2 map_size = vec2(1024.0,640.0);
uniform float excavatable_height = .102;
varying vec3 rock_position;
varying vec3 rock_normal;
float grain_hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float dust_noise(vec2 p) {
 vec2 c=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(grain_hash(c),grain_hash(c+vec2(1,0)),f.x),mix(grain_hash(c+vec2(0,1)),grain_hash(c+vec2(1)),f.x),f.y);
}
vec3 hero_source(sampler2D source, vec2 p) {
 // Both samples are authored color at ~24 cm. The gentle blend only breaks
 // periodic alignment; it does not synthesize material grain or broad color.
 vec3 a=texture(source,p).rgb;
 vec3 b=texture(source,vec2(-p.y,p.x)*.91+vec2(.37,.61)).rgb;
 return mix(a,b,.25+.30*dust_noise(p*.71+vec2(3.2,8.6)));
}
vec3 hero_projection(sampler2D source,vec3 p,vec3 n) {
 // Real surface position, including excavated walls. No displacement. Avoid
 // stretching a top-down image into vertical stripes on a deep cut.
 vec3 w=pow(abs(n),vec3(6.0));w/=max(dot(w,vec3(1.0)),.00001);
 vec3 c=vec3(0.0);
 if(w.y>.005) { c+=hero_source(source,p.xz)*w.y; }
 if(w.x>.005) { c+=hero_source(source,p.zy)*w.x; }
 if(w.z>.005) { c+=hero_source(source,p.xy)*w.z; }
 return c;
}
vec3 hero_albedo(vec3 position,vec3 normal,int material_id) {
 vec3 p=position/.24;
 if(material_id==0) { return hero_projection(hero_soil,p,normal)*.68; }
 if(material_id==1) { return hero_projection(hero_clay,p,normal)*.58; }
 if(material_id==2) {
  vec3 c=hero_projection(hero_stone,p,normal);
  return mix(c,vec3(dot(c,vec3(.2126,.7152,.0722))),.32)*.56;
 }
 return hero_projection(hero_stone,p,normal);
}

#include "res://shaders/p6a15_contact_deposits.gdshaderinc"
void vertex() {
 rock_position=VERTEX+rock_origin;
 rock_normal=NORMAL;
}
void fragment() {
 vec2 uv=rock_position.xz/vec2(1.1,.7)+vec2(.5);
 vec3 n=normalize(rock_normal);
 vec3 stone=hero_albedo(rock_position,n,2);
 vec3 clay=hero_albedo(rock_position,n,1);
 vec3 soil=hero_albedo(rock_position,n,0);
 vec2 material_masks=COLOR.rg;
 if (COLOR.b>.5) {
  material_masks=vec2(UV2.x>.000001 ? 1.0 : 0.0,UV2.x<=.000001 && UV2.y>.000001 ? 1.0 : 0.0);
 }
 vec3 color=mix(mix(stone,clay,material_masks.g),soil,material_masks.r);
 int layer=material_masks.g>.5 ? 1 : 2;
 float contact=soil_lab_patina ? soil_contact_deposit(uv,UV2,layer)*(1.0-COLOR.r)*(1.0-COLOR.b) : 0.0;
 color=mix(color,soil_color.rgb*vec3(.80,.85,.88),contact);
 vec2 joint=texture(cracks,uv).rg;
 float intact_plate=smoothstep(-.055,-.025,UV2.y);
 color*=1.0-joint.r*intact_plate*(.52+.18*joint.g)*(1.0-COLOR.b)*(1.0-COLOR.r)*(1.0-COLOR.g);
 ALBEDO=color;
 ROUGHNESS=1.0;
}
