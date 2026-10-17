shader_type spatial;
render_mode diffuse_burley;
uniform sampler2D surface_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color = vec4(1.);
uniform float meters = 1.6;
uniform bool horizontal = false;
uniform float roughness_value = .88;
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
vec2 mirror_uv(vec2 uv){return abs(fract(uv*.5)*2.-1.);}
void fragment(){
 vec2 q=(horizontal ? world.xz : world.xy)/meters;
 vec3 a=textureLod(surface_texture,mirror_uv(q),1.2).rgb;
 vec3 b=textureLod(surface_texture,mirror_uv(vec2(q.y,-q.x)*.71+vec2(.28,.63)),1.2).rgb;
 ALBEDO=mix(a,b,.26)*tint.rgb;
 ROUGHNESS=roughness_value;SPECULAR=.24;
}
