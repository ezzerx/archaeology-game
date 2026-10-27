shader_type spatial;
// Forward+ museum stone. Two mip-filtered authored samples; no screen reads.
render_mode diffuse_burley;
uniform sampler2D surface_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color=vec4(1.0);
uniform float meters : hint_range(.2, 5.0, .1) = 1.6;
uniform bool horizontal=false;
uniform float roughness_value : hint_range(.35, 1.0, .01) = .88;
uniform float relief_height : hint_range(0.0, .005, .0001) = .0015;
uniform float floor_polish : hint_range(0.0, .5, .01) = .42;
varying vec3 world;
varying vec3 world_normal;
void vertex() {
 world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 world_normal=MODEL_NORMAL_MATRIX*NORMAL;
}
vec2 mirror_uv(vec2 uv) { return abs(fract(uv*.5)*2.0-1.0); }
void fragment() {
 // Project wall returns in their own plane; avoid stretching the jamb textures.
 vec2 vertical=abs(world_normal.x)>abs(world_normal.z) ? world.zy : world.xy;
 vec2 q=(horizontal ? world.xz : vertical)/meters;
 vec3 a=texture(surface_texture,mirror_uv(q)).rgb;
 vec3 b=texture(surface_texture,mirror_uv(vec2(q.y,-q.x)*.71+vec2(.28,.63))).rgb;
 vec3 stone=mix(a,b,.26);
 float h=dot(stone,vec3(.2126,.7152,.0722))*relief_height;
 vec3 dpdx=dFdx(VERTEX),dpdy=dFdy(VERTEX);
 vec3 rx=cross(dpdy,NORMAL),ry=cross(NORMAL,dpdx);
 float det=dot(dpdx,rx);
 vec3 gradient=(dFdx(h)*rx+dFdy(h)*ry)*sign(det)/max(abs(det),.00000001);
 gradient*=min(1.0,.30/max(length(gradient),.00001));
 NORMAL=normalize(NORMAL-gradient);
 ALBEDO=stone*tint.rgb;
 ROUGHNESS=clamp(roughness_value-(horizontal?floor_polish:0.0)+(stone.r-.5)*.12,.40,1.0);
 SPECULAR=.32;
 CLEARCOAT=horizontal?.14:0.0;
 CLEARCOAT_ROUGHNESS=.35;
}
