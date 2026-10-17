shader_type spatial;
render_mode diffuse_burley;
uniform sampler2D surface_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color=vec4(1.);
uniform float meters=1.6;
uniform bool horizontal=false;
uniform float roughness_value=.88;
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
vec2 mirror_uv(vec2 uv){return abs(fract(uv*.5)*2.-1.);}
void fragment(){
 vec2 q=(horizontal?world.xz:world.xy)/meters;
 vec3 a=texture(surface_texture,mirror_uv(q)).rgb;
 vec3 b=texture(surface_texture,mirror_uv(vec2(q.y,-q.x)*.71+vec2(.28,.63))).rgb;
 vec3 stone=mix(a,b,.26);
 // Small-scale material relief in view space works without generated tangent UVs.
 float h=dot(stone,vec3(.2126,.7152,.0722))*.0015;
 vec3 dpdx=dFdx(VERTEX),dpdy=dFdy(VERTEX);
 vec3 rx=cross(dpdy,NORMAL),ry=cross(NORMAL,dpdx);
 float det=dot(dpdx,rx);
 vec3 gradient=sign(det)*(dFdx(h)*rx+dFdy(h)*ry);
 if(abs(det)>0.000000001){NORMAL=normalize(abs(det)*NORMAL-gradient);}
 ALBEDO=stone*tint.rgb;
 ROUGHNESS=clamp(roughness_value+(stone.r-.5)*.16,.65,1.);
 SPECULAR=.28;
}
