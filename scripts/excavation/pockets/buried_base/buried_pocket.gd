extends "res://scripts/excavation/pockets/base/friable_pocket.gd"
var cover_by_cell:=PackedFloat32Array()
func configure() -> void:
 cover_by_cell.resize(surface._heights.size())
 cover_by_cell.fill(0)
 for slot in range(layout.cells.size()):cover_by_cell[layout.cells[slot]]=layout.cover[slot]
 super.configure()
func contact_bounds() -> Rect2i:
 return layout.bounds
func roof_at(i:int,_weight:float,_noise:float) -> float:
 return surface.strata.packed_limits[i*2]-cover_by_cell[i]
func floor_at(i:int,roof:float,weight:float,noise:float) -> float:
 var x:int=i%surface.size.x
 var y:int=i/surface.size.x
 var thickness:=.035+.125*weight+.018*noise+.010*sin(x*.09+y*.07)
 return maxf(roof-thickness,cover_floor+.008+.007*sin(x*.09+y*.07)+.010*(noise+.5))
