uniform sampler2D local_damage_map : filter_linear, repeat_disable;
float local_bone_wear(vec2 cell) {
 return texture(local_damage_map, (cell + vec2(.5)) / vec2(textureSize(local_damage_map,0))).r;
}
