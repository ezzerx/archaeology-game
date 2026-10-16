shader_type spatial;
uniform vec4 base_color : source_color = vec4(.12,.23,.21,1.0);
uniform float metal=0.0;
uniform float wear=.25;
varying vec3 local_point;
float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 p){vec3 i=floor(p);vec3 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){local_point=VERTEX;}
void fragment(){
 float mottling=noise(local_point*900.0);
 float speckle=hash(floor(local_point*14500.0));
 float scuff=smoothstep(.63,.8,noise(local_point*vec3(3000,240,3000)));
 ALBEDO=base_color.rgb*(.78+mottling*.30+speckle*.12);
 ALBEDO=mix(ALBEDO,vec3(.37,.28,.16),scuff*wear);
 ROUGHNESS=mix(.78,.43,metal)+mottling*.10;
 METALLIC=metal;SPECULAR=.28;
}
