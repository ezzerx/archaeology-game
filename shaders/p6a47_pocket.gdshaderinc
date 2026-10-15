uniform sampler2D friable_field : filter_nearest, repeat_disable;
float pocket_hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
vec3 pocket_grains(vec2 p) {
 vec2 base=floor(p); vec2 f=fract(p); float nearest=4.0; float second=4.0; vec2 closest=vec2(0.0); float identity=0.0;
 for(int y=-1;y<=1;y++) { for(int x=-1;x<=1;x++) {
  vec2 cell=base+vec2(float(x),float(y));
  vec2 site=vec2(pocket_hash(cell),pocket_hash(cell+vec2(17.0,43.0)))*.90+.05;
  vec2 d=vec2(float(x),float(y))+site-f;
  float r=dot(d,d);
  if(r<nearest) {second=nearest;nearest=r;closest=d;identity=pocket_hash(cell+vec2(9.0,61.0));}
  else {second=min(second,r);}
 }}
 float facet=clamp(closest.x*.8+closest.y*.35,-.4,.4);
 return vec3(second-nearest,facet,identity);
}
vec3 friable_color(vec3 original, vec2 uv, float height) {
 vec4 pocket=texture(friable_field,uv);
 if(pocket.a<.5 || height<pocket.g+.00002 || height>pocket.r+.036) { return original; }
 float loose=1.0-smoothstep(pocket.r+.0003,pocket.r+.004,height);
 vec2 point=uv*map_size;
 // Unequal angular grains with sparse larger chips, rather than round pebbles.
 vec3 grain=pocket_grains(point/1.55+vec2(sin(point.y*.19),cos(point.x*.17))*.22);
 float seam=smoothstep(.012,.07,grain.x);
 vec3 sand=mix(vec3(.225,.155,.087),vec3(.35,.26,.155),grain.z);
 sand*=.76+.24*seam+.30*grain.y;
 float chip=step(.91,pocket_hash(floor(point/3.7)));
 sand=mix(sand,vec3(.39,.31,.205),chip*.34);
 float pores=step(.76,grain.z)*(1.0-smoothstep(.03,.09,grain.x));
 float weather=pocket.b*(.44+.24*pores);
 vec3 crust=mix(original,vec3(.29,.19,.10),weather);
 crust*=1.0-.32*pores*pocket.b;
 return mix(crust,sand,loose);
}
