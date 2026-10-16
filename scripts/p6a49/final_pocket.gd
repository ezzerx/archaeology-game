extends "res://scripts/p6a47/friable_pocket.gd"
signal contact_grains(sources:Array[Vector3])
var tail_finishes:=0
var contact_releases:=0
func clear() -> void:
 super.clear()
 tail_finishes=0;contact_releases=0
func contact_bounds() -> Rect2i:return layout.bounds
func roof_at(i:int,_weight:float,_noise:float) -> float:return layout.roofs[i]
func floor_at(i:int,_roof:float,_weight:float,_noise:float) -> float:return layout.floors[i]
func flow_height(i:int,old:float,weight:float,delta:float) -> float:
 var next:=super.flow_height(i,old,weight,delta)
 # A real jet can finish the last submillimetric free grains locally. It cannot
 # finish a sealed column, enlarge the footprint or cut the compact substrate.
 if old<=roofs[i]+.0001 and weight>.22 and next<old and next>floors[i] and next-floors[i]<.004:
  tail_finishes+=1
  return floors[i]
 return next
func _undercut(i:int) -> bool:
 var x:=i%surface.size.x
 for offset in [-surface.size.x*3,-3,3,surface.size.x*3]:
  var j:int=i+offset
  if j<0 or j>=roofs.size() or abs(j%surface.size.x-x)>3:continue
  if roofs[j]>0 and surface._heights[j]<roofs[j]-.020:return true
 return false
func capture_contact(point:Vector2,tool:ToolDefinition) -> Array[Vector3]:
 var samples:Array[Vector3]=[]
 if not layout.present or tool.power<=0 or not contact_bounds().grow(ceili(tool.radius)).has_point(Vector2i(point)):return samples
 var low:=Vector2i(point-Vector2.ONE*tool.radius).max(contact_bounds().position)
 var high:=Vector2i(point+Vector2.ONE*tool.radius).min(contact_bounds().end-Vector2i.ONE)
 for y in range(low.y,high.y+1,4):
  for x in range(low.x,high.x+1,4):
   var i:=y*surface.size.x+x
   if roofs[i]<=0 or Vector2(x,y).distance_squared_to(point)>tool.radius*tool.radius:continue
   var old:float=surface._heights[i]
   if old>floors[i]+.003:samples.append(Vector3(x,old,y))
 return samples
func after_contact(samples:Array[Vector3]) -> void:
 var released:Array[Vector3]=[]
 for sample in samples:
  var i:=int(sample.z)*surface.size.x+int(sample.x)
  var next:float=surface._heights[i]
  if next>=sample.y-.00001 or next>roofs[i]+.018 or surface.fossil.exposed[i]!=0:continue
  released.append(Vector3(sample.x,minf(sample.y,roofs[i]+.012),sample.z))
  if released.size()==6:break
 if not released.is_empty():
  contact_releases+=1
  contact_grains.emit(released)
