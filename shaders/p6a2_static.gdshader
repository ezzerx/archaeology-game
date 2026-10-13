shader_type spatial;
render_mode diffuse_burley;
uniform int kind = 0; // plaster, wood, canvas
uniform sampler2D plaster_source : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
varying vec3 local_pos;
void vertex() { local_pos = VERTEX; }
float hash(vec3 p) { return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453); }
float noise(vec3 p) {
 vec3 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),
 mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1)),f.x),f.y),f.z);
}
void fragment() {
 vec3 p=local_pos;
 float broad=noise(p*26.0), fine=noise(p*750.0);
 if(kind==0) {
  vec3 weights=pow(abs(NORMAL),vec3(5.0));
  // Object-space triplanar color: static sides retain authored scale too.
  vec3 normal_local=normalize(cross(dFdx(p),dFdy(p)));
  weights=pow(abs(normal_local),vec3(5.0));weights/=max(dot(weights,vec3(1.0)),.0001);
  vec3 source=texture(plaster_source,p.yz/.24).rgb*weights.x
   +texture(plaster_source,p.xz/.24).rgb*weights.y
   +texture(plaster_source,p.xy/.24).rgb*weights.z;
  ALBEDO=source*COLOR.rgb*1.6;
  ROUGHNESS=.96;SPECULAR=.09;
 } else if(kind==1) {
  float wave=sin(p.x*85.0+noise(p*vec3(6,2,11))*7.0);
  float grain=noise(vec3(p.x*240.0+wave*2.0,p.y*2.0,p.z*9.0));
  float plank=floor((p.x+1.0)/.185);
  float seam=smoothstep(.003,.009,abs(fract((p.x+1.0)/.185)-.5));
  ALBEDO=mix(vec3(.13,.08,.05),vec3(.25,.16,.10),.42+.20*grain+.15*broad);
  ALBEDO*=.85+.18*hash(vec3(plank));
  ALBEDO*=.78+.22*seam;
  ROUGHNESS=.74+.12*grain;SPECULAR=.25;
 } else {
  float weave=sin(p.x*2800.0)*sin(p.z*2800.0);
  ALBEDO=vec3(.25,.175,.085)*(.9+.13*weave+.2*broad);
  ROUGHNESS=.98;SPECULAR=.1;
 }
}
