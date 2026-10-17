shader_type spatial;
render_mode unshaded,cull_disabled;
void fragment(){
 vec3 sky=mix(vec3(.34,.51,.57),vec3(.08,.30,.48),smoothstep(.1,.75,1.-UV.y));
 float cloud=exp(-pow((UV.y-.36)*27.,2.))*smoothstep(.2,.9,sin(UV.x*24.)*.3+.6);
 sky=mix(sky,vec3(.91,.88,.76),cloud*.42);
 ALBEDO=sky;
}
