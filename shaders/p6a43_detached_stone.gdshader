shader_type spatial;
render_mode cull_disabled;
uniform sampler2D stone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cracks : filter_linear, repeat_disable;
void fragment() {
 vec3 c=texture(stone,UV).rgb;
 c=mix(c,vec3(dot(c,vec3(.2126,.7152,.0722))),.32)*.56;
 ALBEDO=mix(c,texture(soil,UV).rgb*.68,COLOR.r);
 ALBEDO*=1.0-texture(cracks,UV2).r*.66*(1.0-COLOR.g);
 ROUGHNESS=1.0;
}
