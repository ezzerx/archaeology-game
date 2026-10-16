uniform sampler2D friable_field : filter_nearest, repeat_disable;
float pocket_hash(vec2 p) {return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
vec4 pocket_grain(vec2 p) {
 vec2 base=floor(p);vec2 f=fract(p);float nearest=4.0;float second=4.0;vec2 closest=vec2(0.0);float id=0.0;
 for(int y=-1;y<=1;y++){for(int x=-1;x<=1;x++){
  vec2 cell=base+vec2(float(x),float(y));
  vec2 site=vec2(pocket_hash(cell),pocket_hash(cell+vec2(17.0,43.0)))*.9+.05;
  vec2 d=vec2(float(x),float(y))+site-f;float r=dot(d,d);
  if(r<nearest){second=nearest;nearest=r;closest=d;id=pocket_hash(cell+vec2(9.0,61.0));}
  else{second=min(second,r);}
 }}return vec4(second-nearest,closest,id);
}
vec4 friable_grain(vec2 point) {
 vec4 medium=pocket_grain(point/1.65+vec2(sin(point.y*.17),cos(point.x*.15))*.18);
 vec4 coarse=pocket_grain(point/3.6);
 float clump=step(.82,coarse.w)*smoothstep(.035,.16,coarse.x);
 vec4 fine=pocket_grain(point/.72);
 vec4 mixed=mix(medium,fine,step(.70,medium.w)*.65);
 return mix(mixed,coarse,clump);
}
float friable_loose(vec4 field,float height) {
 return field.a*(1.0-smoothstep(field.r+.0003,field.r+.004,height))*smoothstep(field.g+.00002,field.g+.006,height);
}
vec3 friable_color(vec3 original,vec2 uv,float height) {
 vec4 field=texture(friable_field,uv);
 if(field.a<.5 || height<field.g+.00002 || height>field.r+.022){return original;}
 vec4 grain=friable_grain(uv*map_size);
 float seam=smoothstep(.012,.065,grain.x);
 vec3 sand=mix(vec3(.265,.185,.095),vec3(.405,.295,.16),grain.w);
 sand*=.83+.17*seam+.17*(grain.y*.65+grain.z*.35);
 float inclusions=step(.78,grain.w)*smoothstep(.025,.12,grain.x);
 float skin=1.0-smoothstep(field.r+.006,field.r+.022,height);
 // Fragmented inclusions in the real last skin, never a full boundary outline.
 vec3 crust=mix(original,vec3(.30,.21,.115),skin*field.b*inclusions*.42);
 float border=smoothstep(.015,.17,field.b);
 return mix(crust,sand,friable_loose(field,height)*border);
}
vec3 friable_normal(vec3 normal,vec2 uv,float height,vec3 axis_x,vec3 axis_z) {
 vec4 field=texture(friable_field,uv);
 if(field.a<.5 || height>field.r+.004 || height<field.g+.00002){return normal;}
 vec4 grain=friable_grain(uv*map_size);
 float amount=friable_loose(field,height)*smoothstep(.015,.17,field.b)*.26;
 return normalize(normal+(axis_x*grain.y+axis_z*grain.z)*amount);
}
