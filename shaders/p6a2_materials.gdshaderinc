// Selected ImageGen v02 albedo sources. Never samples the rejected lab atlas.
uniform sampler2D hero_soil : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_clay : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_stone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D hero_bone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool hero_fragmented_soil = true;
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
 vec3 c=hero_projection(hero_bone,p,normal);
 return mix(c,vec3(dot(c,vec3(.2126,.7152,.0722))),.20)*vec3(.55,.58,.65);
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
