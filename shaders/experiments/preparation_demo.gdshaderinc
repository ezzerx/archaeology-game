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
 if(preparation_demo==1)result=mix(result,result*vec3(.75,.86,.94),consolidated*.52);
 float original_luma=dot(original,vec3(.21,.72,.07));
 result*=clamp(original_luma/.34,.62,1.24);
 vec2 crust=texture(demo_crust,uv).rg;
 if(!skirt && crust.g>0.0 && h<=crust.g+.002 && h>crust.r+.0001){
  float pit=smoothstep(.70,.90,grain)*smoothstep(.3,.7,fine);
  vec3 mineral=mix(vec3(.235,.225,.20),vec3(.43,.415,.37),cloud*.4+fine*.6);
  mineral*=1.0-pit*.25;
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
 return normalize(normal+(axis_x*slope.x+axis_z*slope.y)*(.45*loose+.30*coat));
}
