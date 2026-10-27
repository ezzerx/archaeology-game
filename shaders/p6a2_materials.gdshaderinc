// Shared spatial-material functions; Godot 4.7 Compatibility / Mobile / Forward+.
// Authored albedo sources; derivatives add a bounded lighting-only microrelief.
// No screen/depth texture, displacement, new map samples or logical state reads.
uniform sampler2D hero_soil : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_clay : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_stone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_bone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool hero_fragmented_soil = true;
uniform float hero_texture_scale : hint_range(0.08, 0.5, 0.01) = 0.24;
uniform float hero_clay_saturation : hint_range(0.0, 1.0, 0.01) = 0.65;
uniform float hero_soil_relief : hint_range(0.0, 0.003, 0.0001) = 0.0011;
uniform float hero_clay_relief : hint_range(0.0, 0.003, 0.0001) = 0.0008;
uniform float hero_stone_relief : hint_range(0.0, 0.003, 0.0001) = 0.0007;
uniform float hero_bone_relief : hint_range(0.0, 0.001, 0.00001) = 0.00022;
uniform float hero_detail_slope_limit : hint_range(0.0, 0.7, 0.01) = 0.38;

vec3 hero_source(sampler2D source, vec2 p) {
 // Two albedo samples break periodic alignment without inventing broad grain.
 vec3 a=texture(source,p).rgb;
 vec3 b=texture(source,vec2(-p.y,p.x)*.91+vec2(.37,.61)).rgb;
 return mix(a,b,.25+.30*dust_noise(p*.71+vec2(3.2,8.6)));
}
vec3 hero_projection(sampler2D source,vec3 p,vec3 n) {
 // True surface position includes excavated walls. Two samples on planar faces,
 // at most six at a triplanar corner; no top-down stretching through the cut.
 vec3 w=pow(abs(n),vec3(6.0));w/=max(dot(w,vec3(1.0)),.00001);
 vec3 c=vec3(0.0);
 if(w.y>.005) { c+=hero_source(source,p.xz)*w.y; }
 if(w.x>.005) { c+=hero_source(source,p.zy)*w.x; }
 if(w.z>.005) { c+=hero_source(source,p.xy)*w.z; }
 return c;
}
vec3 hero_albedo(vec3 position,vec3 normal,int material_id) {
 vec3 p=position/hero_texture_scale;
 if(material_id==0) { return hero_projection(hero_soil,p,normal)*.68; }
 if(material_id==1) {
  vec3 c=hero_projection(hero_clay,p,normal);
  // Mineral terracotta retains its identity without the saturated orange cast.
  return mix(vec3(dot(c,vec3(.2126,.7152,.0722))),c,hero_clay_saturation)*.58;
 }
 if(material_id==2) {
  vec3 c=hero_projection(hero_stone,p,normal);
  return mix(c,vec3(dot(c,vec3(.2126,.7152,.0722))),.32)*.56;
 }
 vec3 c=hero_projection(hero_bone,p,normal);
 return mix(c,vec3(dot(c,vec3(.2126,.7152,.0722))),.20)*vec3(.55,.58,.65);
}
float hero_relief_scale(int material_id) {
 return material_id==0 ? hero_soil_relief : (material_id==1 ? hero_clay_relief : (material_id==2 ? hero_stone_relief : hero_bone_relief));
}
float hero_detail_height(vec3 albedo,int material_id) {
 // Reuse the sampled, mip-filtered authored grain before Film/residue/cursor.
 // The values are physical metres; this NEVER writes vertex or working height.
 float grain=clamp(dot(albedo,vec3(.2126,.7152,.0722))*2.5,0.0,1.0);
 return (grain-.5)*hero_relief_scale(material_id);
}
float hero_detail_roughness(float height,int material_id) {
 float dry=material_id==0 ? .97 : (material_id==1 ? .86 : (material_id==2 ? .92 : .65));
 float grain=height/max(hero_relief_scale(material_id),.000001);
 return clamp(dry-grain*.12,.55,.99);
}
vec3 hero_detail_normal(vec3 view_position,vec3 normal,float height) {
 // In Godot fragment(), VERTEX and NORMAL are view-space. This surface-gradient
 // method needs no tangent attribute and follows both top faces and cut walls.
 vec3 dx=dFdx(view_position),dy=dFdy(view_position);
 vec3 rx=cross(dy,normal),ry=cross(normal,dx);
 float det=dot(dx,rx);
 vec3 gradient=(dFdx(height)*rx+dFdy(height)*ry)*sign(det)/max(abs(det),.00000001);
 gradient*=min(1.0,hero_detail_slope_limit/max(length(gradient),.00001));
 return normalize(normal-gradient);
}
vec3 hero_bone_normal(vec2 uv) {
 vec2 step_uv=1.0/map_size;
 float left=texture(working_map,uv-vec2(step_uv.x,0)).r;
 float right=texture(working_map,uv+vec2(step_uv.x,0)).r;
 float back=texture(working_map,uv-vec2(0,step_uv.y)).r;
 float front=texture(working_map,uv+vec2(0,step_uv.y)).r;
 vec2 slope=vec2(right-left,front-back)*excavatable_height/(2.0*step_uv*surface_size);
 return normalize(vec3(-slope.x,1.0,-slope.y));
}
float hero_cavity(vec2 uv, float h) {
 vec2 offset=vec2(7.0)/map_size;
 float nearby=texture(working_map,uv+vec2(offset.x,0)).r
  +texture(working_map,uv-vec2(offset.x,0)).r
  +texture(working_map,uv+vec2(0,offset.y)).r
  +texture(working_map,uv-vec2(0,offset.y)).r;
 return clamp((nearby*.25-h)*8.0,0.0,.27);
}
