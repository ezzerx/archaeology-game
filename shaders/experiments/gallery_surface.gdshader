shader_type spatial;
// Godot 4.7 spatial, Forward+ target; also valid in Compatibility.
// Zero texture reads. Microrelief is lighting only, with bounded surface gradients.
render_mode diffuse_burley;
uniform vec4 tint : source_color = vec4(.3,.15,.07,1.0);
uniform int kind : hint_enum("Walnut", "Mineral", "Brass", "Paper or fabric") = 0;
uniform float scale : hint_range(.1, 8.0, .1) = 1.0;
uniform int grain_axis : hint_enum("Vertical Y", "Horizontal X", "Depth Z") = 0;
uniform float grain_strength : hint_range(0.0, .6, .01) = .34;
uniform float grain_relief : hint_range(0.0, .002, .0001) = .0003;
uniform float wood_roughness : hint_range(.25, .85, .01) = .39;
uniform float brass_roughness : hint_range(.2, .65, .01) = .32;
varying vec3 p;
float gallery_hash(vec2 a) { return fract(sin(dot(a,vec2(127.1,311.7)))*43758.5453); }
float gallery_noise(vec2 a) {
 vec2 i=floor(a),f=fract(a);f=f*f*(3.0-2.0*f);
 return mix(mix(gallery_hash(i),gallery_hash(i+vec2(1,0)),f.x),
  mix(gallery_hash(i+vec2(0,1)),gallery_hash(i+vec2(1)),f.x),f.y);
}
void vertex() { p=VERTEX; } // Model coordinates anchor grain to the furniture.
vec3 gallery_normal(vec3 view_pos,vec3 normal,float height) {
 vec3 dx=dFdx(view_pos),dy=dFdy(view_pos);
 vec3 rx=cross(dy,normal),ry=cross(normal,dx);
 float det=dot(dx,rx);
 vec3 gradient=(dFdx(height)*rx+dFdy(height)*ry)*sign(det)/max(abs(det),.00000001);
 gradient*=min(1.0,.28/max(length(gradient),.00001));
 return normalize(normal-gradient);
}
void fragment() {
 vec3 q=p*scale;
 vec2 field=q.xy+q.z*vec2(.67,.29);
 float mottling=gallery_noise(field*35.0);
 float height=0.0;
 vec3 c=tint.rgb;
 if(kind==0) {
  vec2 wood=grain_axis==0 ? vec2(q.x+q.z*.67,q.y) :
   (grain_axis==1 ? vec2(q.z+q.y*.67,q.x) : vec2(q.x+q.y*.67,q.z));
  float broad=gallery_noise(wood*vec2(5.0,1.4));
  float warp=(broad-.5)*.032;
  float growth=gallery_noise(vec2((wood.x+warp)*80.0,wood.y*3.0));
  float fibres=gallery_noise(vec2((wood.x+warp)*430.0,wood.y*24.0));
  fibres=mix(.5,fibres,1.0-smoothstep(.3,1.0,fwidth(wood.x*430.0)));
  float grain=growth*.50+fibres*.30+broad*.20;
  c*=1.0+(grain-.5)*grain_strength;
  float polish=gallery_noise(wood*vec2(8.0,11.0));
  ROUGHNESS=clamp(wood_roughness+(polish-.5)*.15,.25,.85);
  height=(grain-.5)*grain_relief;
  SPECULAR=.42;
  CLEARCOAT=.22;
  CLEARCOAT_ROUGHNESS=.32;
 } else if(kind==1) {
  c*=.97+mottling*.055;
  ROUGHNESS=.88+(mottling-.5)*.10;
  height=(mottling-.5)*.00020;
  SPECULAR=.28;
 } else if(kind==2) {
  float brushed=gallery_noise(field*vec2(680.0,16.0));
  brushed=mix(.5,brushed,1.0-smoothstep(.35,1.0,fwidth(field.x*680.0)));
  c*=.94+mottling*.06;
  METALLIC=.84;
  ROUGHNESS=clamp(brass_roughness+(brushed-.5)*.10,.2,.65);
  height=(brushed-.5)*.000015;
  SPECULAR=.5;
 } else {
  c*=.96+mottling*.065;
  ROUGHNESS=.92;
  height=(mottling-.5)*.00010;
  SPECULAR=.20;
 }
 ALBEDO=c;
 NORMAL=gallery_normal(VERTEX,NORMAL,height); // fragment built-ins use view space.
}
