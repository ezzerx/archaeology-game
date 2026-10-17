extends RefCounted
## Museum-only interpretation of frozen v1 renders. Never edits the archive/maps.
const DUST_ANCHOR="vec3 dust_color = mix(dust_low, dust_high, broad * 0.65 + medium * 0.35);"
const BONE_ANCHOR="if (texelFetch(production_coverage,cell,0).r < .5 || bone.g < .5 || texelFetch(working_map,cell,0).r > bone.r+.0000152587890625) { discard; }"
const BONE_BORDER="""if (texelFetch(production_coverage,cell,0).r >= .5 && bone.g >= .5) {
   // Keep the preparation's exact burial rule for every mapped Bone cell.
   if (texelFetch(working_map,cell,0).r > bone.r+.0000152587890625) { discard; }
  } else {
   // The rasterized footprint samples cell centres, not the actual mesh edge.
   // At its fringe, retain only geometry physically above the remaining matrix.
   // This also works inside the spiral; it never disables burial globally.
   if (.018+texture(working_map,uv).r*excavatable_height > bone_position.y) { discard; }
  }"""
const DUST_COLOR="""
vec3 exhibit_srgb_to_linear(vec3 c) {
 return mix(c/12.92,pow((c+vec3(.055))/1.055,vec3(2.4)),step(vec3(.04045),c));
}
"""
static func apply(block:Node3D) -> void:
 if block==null or block.get_meta("exhibit_display_fixed",false):return
 _remove_duplicate_copies(block)
 var done:Dictionary={}
 for mesh:MeshInstance3D in block.find_children("*","MeshInstance3D",true,false):
  var mat:=mesh.material_override as ShaderMaterial
  if mat==null or done.has(mat):continue
  done[mat]=true
  var code:=mat.shader.code
  var updated:=code
  if code.contains('varying vec3 bone_position;'):
   assert(code.count(BONE_ANCHOR)==1,"Review the archived bone shader's burial contract")
   updated=code.replace(BONE_ANCHOR,BONE_BORDER)
  elif code.contains(DUST_ANCHOR):
   updated=code.replace("void fragment() {",DUST_COLOR+"\nvoid fragment() {")
   # Exposed fallback Bone uses source_color uniforms, already decoded.
   updated=updated.replace(DUST_ANCHOR,DUST_ANCHOR+"\nif (!OUTPUT_IS_SRGB && !exposed_bone) { dust_color=exhibit_srgb_to_linear(dust_color); }")
  if updated!=code:
   var shader:=Shader.new();shader.code=updated;mat.shader=shader
 block.set_meta("exhibit_display_fixed",true)

static func _remove_duplicate_copies(block:Node3D) -> void:
 # Early v1 captures traversed both the block and its Bone child a second time.
 # Match exact resources/transforms/settings; distinct overlapping objects remain.
 var unique:Array[MeshInstance3D]=[]
 for mesh:MeshInstance3D in block.find_children("*","MeshInstance3D",true,false):
  var duplicate:=false
  for other in unique:
   if mesh.mesh!=other.mesh or mesh.transform!=other.transform or mesh.get_parent()!=other.get_parent():continue
   if mesh.material_override!=other.material_override or mesh.cast_shadow!=other.cast_shadow:continue
   var same:=true
   for surface in range(mesh.mesh.get_surface_count()):
    if mesh.get_surface_override_material(surface)!=other.get_surface_override_material(surface):same=false;break
   if same:duplicate=true;break
  if duplicate:mesh.free()
  else:unique.append(mesh)
