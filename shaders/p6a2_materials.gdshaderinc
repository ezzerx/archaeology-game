// P6A2 data plates are non-repeating, full-core, linear textures. No displacement.
uniform sampler2D hero_soil : filter_linear_mipmap, repeat_disable;
uniform sampler2D hero_clay : filter_linear_mipmap, repeat_disable;
uniform sampler2D hero_stone : filter_linear_mipmap, repeat_disable;
uniform sampler2D hero_bone : filter_linear_mipmap, repeat_disable;
// Existing P6A painted source used once across the block, as value detail.
// Deliberately sampled as data; final palette is set separately in linear color.
uniform sampler2D hero_painted : filter_linear_mipmap, repeat_disable;

float hero_painted_value(vec2 uv, int layer, bool bone) {
 int id = bone ? 3 : layer;
 vec2 tile = vec2(float(id % 2), float(id / 2));
 vec3 source = texture(hero_painted, tile*.5+vec2(.015)+uv*.47).rgb;
 float mean_value = bone ? .87 : (layer==0 ? .31 : (layer==1 ? .41 : .64));
 return clamp(dot(source,vec3(.299,.587,.114))/mean_value,.55,1.5);
}

vec3 hero_bone_normal(vec2 uv) {
 vec2 step_uv=1.0/map_size;
 float left=texture(working_map,uv-vec2(step_uv.x,0)).r;
 float right=texture(working_map,uv+vec2(step_uv.x,0)).r;
 float back=texture(working_map,uv-vec2(0,step_uv.y)).r;
 float front=texture(working_map,uv+vec2(0,step_uv.y)).r;
 vec2 slope=vec2(right-left,front-back)*excavatable_height/(2.0*step_uv*surface_size);
 return normalize(vec3(-slope.x,1.0,-slope.y));
}

vec4 hero_plate(vec2 uv, int layer, bool bone) {
 if (bone) { return texture(hero_bone, uv); }
 if (layer == 0) { return texture(hero_soil, uv); }
 if (layer == 1) { return texture(hero_clay, uv); }
 return texture(hero_stone, uv);
}

vec3 hero_bump_normal(vec3 p, vec3 n, float h) {
 vec3 sx = dFdx(p), sy = dFdy(p);
 vec3 r1 = cross(sy,n), r2 = cross(n,sx);
 float det = dot(sx,r1);
 vec3 gradient = sign(det)*(dFdx(h)*r1+dFdy(h)*r2);
 // Bound material-boundary derivatives: no dark rims from a discontinuous
 // Soil/Clay/Bone data lookup, and at most ~11 degrees of cosmetic tilt.
 gradient /= max(abs(det),1e-12);
 gradient *= min(1.0,.20/max(length(gradient),1e-6));
 return normalize(n-gradient);
}

float hero_cavity(vec2 uv, float h) {
 // Only occlusion from the actual working heightfield, no invented cracks.
 vec2 offset = vec2(7.0)/map_size;
 float nearby = texture(working_map,uv+vec2(offset.x,0)).r
  + texture(working_map,uv-vec2(offset.x,0)).r
  + texture(working_map,uv+vec2(0,offset.y)).r
  + texture(working_map,uv-vec2(0,offset.y)).r;
 return clamp((nearby*.25-h)*8.0,0.0,.27);
}
