shader_type spatial;
render_mode unshaded, cull_disabled;
void fragment(){
 float sky=smoothstep(.20,.78,UV.y);
 vec3 colour=mix(vec3(.40,.49,.26),vec3(.48,.66,.72),sky);
 // Soft distant foliage, never high-contrast detail competing with the fossils.
 float tree=sin(UV.x*13.+.7)*.06+sin(UV.x*29.)*.025+.43;
 float leaf=1.-smoothstep(tree-.025,tree+.03,UV.y);
 colour=mix(colour,vec3(.42,.51,.29),leaf*.65);
 ALBEDO=colour;
}
