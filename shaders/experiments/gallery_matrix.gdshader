shader_type spatial;
render_mode diffuse_burley;
uniform sampler2D sandstone : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D clay : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool marine = false;
varying vec3 p;
varying vec4 col;
void vertex(){p=VERTEX;col=COLOR;}
void fragment(){
 vec3 stone=texture(sandstone,UV*3.2).rgb;
 vec3 earth=texture(clay,UV*3.2).rgb;
 vec3 c=mix(stone*vec3(.32,.36,.34),earth*.30,col.r*(marine?.12:.55));
 if(marine)c*=vec3(.88,.91,.88);
 ALBEDO=c*(.80+.20*col.g);ROUGHNESS=.94;SPECULAR=.12;
}
