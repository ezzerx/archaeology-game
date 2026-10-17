uniform int preparation_demo = 0;
uniform sampler2D demo_geology : filter_nearest, repeat_disable;
uniform sampler2D demo_crust : filter_nearest, repeat_disable;
float demo_hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float demo_noise(vec2 p) {
 vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(demo_hash(i),demo_hash(i+vec2(1,0)),f.x),mix(demo_hash(i+vec2(0,1)),demo_hash(i+vec2(1,1)),f.x),f.y);
}
vec3 demo_material(vec3 original,vec2 uv,float h,bool skirt) {
 if(preparation_demo==0)return original;
 vec2 p=uv*vec2(1024.0,640.0);
 float grain=demo_hash(floor(p*1.4));
 float cloud=demo_noise(p*.026);
 float fine=demo_noise(p*.22);
 vec4 field=texture(demo_geology,uv);
 float freed=field.r>0.0 ? (1.0-smoothstep(field.r+.001,field.r+.014,h))*step(field.g+.002,h):0.0;
 float lamina=sin(p.y*.21+p.x*.034+demo_noise(p*.018)*9.0+h*95.0)*.5+.5;
 vec3 marl=mix(vec3(.22,.205,.155),vec3(.49,.45,.33),cloud*.55+fine*.30);
 marl*=.86+grain*.22+lamina*.06;
 vec3 sand=mix(vec3(.31,.255,.16),vec3(.57,.48,.32),fine*.55+grain*.45);
 vec3 result=mix(marl,sand,freed*.88);
 if(preparation_demo==2)result=mix(result,vec3(.41,.30,.20)*(0.65+cloud*.35+grain*.18),.52);
 // Contact dirt and mineral pores remain in the same lit material; no unlit overlay.
 float consolidated=(field.r>0.0?1.0-field.b:1.0);
 if(preparation_demo==1){
  vec3 sediment=mix(vec3(.34,.315,.245),vec3(.56,.51,.395),fine*.55+grain*.45);
  // Loose bed, firm marl and exposed base share a mineral palette but read differently.
  result=mix(marl*vec3(.97,1.0,1.04),sediment,freed*.92);
  result*=1.0-consolidated*.10;
 }
 float original_luma=dot(original,vec3(.21,.72,.07));
 result*=clamp(original_luma/.34,.62,1.24);
 vec2 crust=texture(demo_crust,uv).rg;
 if(!skirt && crust.g>0.0 && h<=crust.g+.002 && h>crust.r+.0001){
  float pit=smoothstep(.72,.94,grain)*smoothstep(.32,.68,fine);
  float freshly_cut=smoothstep(.002,.009,crust.g-h);
  float bloom=demo_noise(p*.13);
  vec3 rind=mix(vec3(.255,.243,.208),vec3(.43,.408,.347),bloom*.65+fine*.35);
  vec3 interior=mix(vec3(.365,.335,.275),vec3(.50,.46,.38),fine*.6+cloud*.4);
  vec3 mineral=mix(rind,interior,freshly_cut*.78);
  mineral*=1.0-pit*mix(.24,.10,freshly_cut);
  vec2 step_uv=vec2(3.0/1024.0,3.0/640.0);
  float nearby=(texture(working_map,uv+vec2(step_uv.x,0)).r+texture(working_map,uv-vec2(step_uv.x,0)).r+
                texture(working_map,uv+vec2(0,step_uv.y)).r+texture(working_map,uv-vec2(0,step_uv.y)).r)*.25;
  mineral*=clamp(1.0-max(0.0,nearby-h)*6.0,.72,1.0);
  result=mix(result,mineral,1.0-smoothstep(crust.g,crust.g+.002,h));
 }
 return result;
}

vec3 demo_grain_normal(vec3 normal,vec2 uv,float h,vec3 axis_x,vec3 axis_z){
 vec4 field=texture(demo_geology,uv);
 vec2 crust=texture(demo_crust,uv).rg;
 float loose=field.r>0.0 ? (1.0-smoothstep(field.r+.001,field.r+.014,h))*step(field.g+.002,h):0.0;
 float coat=(crust.g>0.0 && h<=crust.g+.002 && h>crust.r+.0001)?1.0:0.0;
 vec2 p=uv*vec2(1024,640)*.7;
 float a=demo_noise(p);
 vec2 slope=vec2(demo_noise(p+vec2(.4,0))-a,demo_noise(p+vec2(0,.4))-a);
 // Smooth the actual current mineral height, including the local abrasion.
 // Only visible coating or freed marine grains use this shading; sealed cover is unchanged.
 if(coat>0.0 || (preparation_demo==1 && loose>.01)){
  vec2 texel=vec2(1.0/1024.0,1.0/640.0);
  float dx=texture(working_map,uv+vec2(texel.x*2.0,0)).r-texture(working_map,uv-vec2(texel.x*2.0,0)).r;
  float dz=texture(working_map,uv+vec2(0,texel.y*2.0)).r-texture(working_map,uv-vec2(0,texel.y*2.0)).r;
  vec3 up=normalize(cross(axis_z,axis_x));
  vec3 sculpted=normalize(up-axis_x*clamp(dx*25.5,-2.0,2.0)-axis_z*clamp(dz*25.5,-2.0,2.0));
  normal=normalize(mix(normal,sculpted,(coat>0.0?.88:.62*loose)*smoothstep(.4,.8,dot(normal,up))));
 }
 return normalize(normal+(axis_x*slope.x+axis_z*slope.y)*(.45*loose+.50*coat*(1.0-smoothstep(.002,.012,crust.g-h)*.65)));
}
