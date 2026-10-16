extends "res://scripts/p6a41/rough_profile.gd"
## Three authored initial conditions. Tool resources and Bone field are read-only.
const NAMES := ["01 · Découverte", "02 · Banc oblique", "03 · Îlots"]
const NOTES := ["Matrice plus légère : ouvrir une zone, puis suivre les premiers os.",
 "Un banc de grès traverse l’argile : choisir son accès et adapter le dégagement.",
 "Des îlots de grès séparés : alterner ouvertures et finitions autour des détails."]
var selected := 0
var variants: Array[Dictionary] = []
var reference_limits: PackedFloat32Array
var reference_top: PackedFloat32Array
var shape: RefCounted
var edge: RefCounted
func _init(surface: WorkingSurface, footprint_shape: RefCounted, rim: RefCounted) -> void:
 super(surface,footprint_shape,rim)
 shape = footprint_shape
 edge = rim
 reference_limits = limits[1].duplicate()
 reference_top = fragmented_top.duplicate()
 for variant in range(3):
  var layers := reference_limits.duplicate()
  var substrate := substrates[1].duplicate()
  var top := reference_top.duplicate()
  var alternate_top := thin_tops[1].duplicate()
  for y in range(size.y):
   for x in range(size.x):
    var i := y*size.x+x
    if shape.mask[i] == 0: continue
    var uv := (Vector2(x,y)+Vector2.ONE*.5)/Vector2(size)
    var upper: float = reference_limits[i*2]-.025
    var lower: float = reference_limits[i*2+1]
    if variant == 0:
     upper -= .010
     lower = maxf(.08,lower-.15)
    elif variant == 1:
     # One folded diagonal bed pinches the Clay out at its broad centre.
     var across := uv.x-.70*uv.y-.24-.025*sin(uv.y*TAU)-.012*sin(uv.y*23.0+uv.x*7.0)-.006*sin(uv.y*53.0)
     var width := .050+.009*sin(uv.y*19.0+.6)
     var bank := 1.0-smoothstep(width,width+.095,absf(across))
     lower = lerpf(maxf(.08,lower-.19),upper,bank)
    else:
     # Broad geological lenses, never masks or offsets around Bone anatomy.
     var islands := 0.0
     for form: Vector4 in [Vector4(.30,.33,.095,.10),Vector4(.54,.57,.10,.085),Vector4(.73,.74,.08,.10)]:
      var warped := uv+Vector2(.008*sin(uv.y*35.0),.009*sin(uv.x*27.0))
      var q := (warped-Vector2(form.x,form.y))/Vector2(form.z,form.w)
      islands = maxf(islands,1.0-smoothstep(.65,1.25,q.length()))
     lower = lerpf(maxf(.08,lower-.18),upper,islands)
    layers[i*2] = upper
    layers[i*2+1] = minf(upper,lower)
    var dirt: float = maxf(0.0,reference_top[i]-substrates[1][i])
    substrate[i] = upper
    top[i] = upper+dirt
    alternate_top[i] = upper+maxf(0.0,thin_tops[1][i]-substrates[1][i])
  substrate = edge.capped(substrate)
  top = edge.capped(top)
  alternate_top = edge.capped(alternate_top)
  variants.append({"limits":layers,"substrate":substrate,"top":top,"alternate_top":alternate_top})
func apply(block: ExcavationBlock, _candidate: int, _fixture: int, cleared: bool) -> void:
 var s := block.working_map
 var data: Dictionary = variants[selected]
 s.strata.packed_limits = data.limits.duplicate()
 s.strata.boundaries.set_data(size.x,size.y,false,Image.FORMAT_RGF,s.strata.packed_limits.to_byte_array())
 block.layer_texture.update(s.strata.boundaries)
 s._heights = data.substrate.duplicate() if cleared else (data.top.duplicate() if fragmented else data.alternate_top.duplicate())
 s.image.set_data(size.x,size.y,false,Image.FORMAT_RF,s._heights.to_byte_array())
 s.dirty = true
 block.flush_texture()
