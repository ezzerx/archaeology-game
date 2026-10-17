shader_type spatial;
render_mode diffuse_burley;
uniform vec4 tint : source_color = vec4(.3,.15,.07,1);
uniform int kind = 0;
uniform float scale = 1.0;
varying vec3 p;
float hash(vec3 a){return fract(sin(dot(a,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 a){vec3 i=floor(a),f=fract(a);f=f*f*(3.-2.*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){p=VERTEX;}
void fragment(){
 vec3 q=p*scale;
 float n=noise(q*35.);
 float grain=noise(vec3(q.x*3.,q.y*4.,q.z*150.));
 float streak=sin(q.z*180.+noise(q*4.)*10.)*.5+.5;
 vec3 c=tint.rgb;
 if(kind==0){c*=.83+.12*grain+.025*streak;ROUGHNESS=.48;}
 else if(kind==1){c*=.96+.025*n+.025*noise(q*4.);ROUGHNESS=.96;}
 else if(kind==2){c*=.83+.16*n;METALLIC=.72;ROUGHNESS=.38;}
 else{c*=.89+.14*n;ROUGHNESS=.82;}
 ALBEDO=c;SPECULAR=.25;
}
