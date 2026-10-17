extends "res://scripts/excavation/pockets/final_surface.gd"
var demo_kind:=0
var grain_roofs:=PackedFloat32Array()
var grain_floors:=PackedFloat32Array()
var crust_caps:=PackedFloat32Array()
var grains_removed:=0.0
var crust_removed:=0.0
var demo_ready:=false
var marine_grain_ease:=PackedFloat32Array()
var deep_grain_roofs:=PackedFloat32Array()
var deep_grain_floors:=PackedFloat32Array()
var radial_weights:=PackedFloat32Array()
func configure_demo(roofs:PackedFloat32Array,floors:PackedFloat32Array,caps:PackedFloat32Array) -> void:
 grain_roofs=roofs;grain_floors=floors;crust_caps=caps.duplicate()
 grains_removed=0;crust_removed=0;demo_ready=true
 if radial_weights.is_empty():
  radial_weights.resize(4097)
  for i in range(4097):radial_weights[i]=weight(sqrt(float(i)/4096),.65)
func can_detach_micro_remnant(i:int) -> bool:
 return not demo_ready or demo_kind==0 or crust_caps[i]<=0
func constrain_removal(i:int,next:float,tool_id:StringName) -> float:
 if demo_kind==0 or not demo_ready:return super.constrain_removal(i,next,tool_id)
 var old:=_heights[i]
 if crust_caps[i]>0:next=maxf(next,crust_caps[i])
 var roof:=grain_roofs[i];var floor_height:=grain_floors[i]
 if not deep_grain_roofs.is_empty() and deep_grain_roofs[i]>0 and old<=floor_height+.0001:
  roof=deep_grain_roofs[i];floor_height=deep_grain_floors[i]
 if roof>0 and old>floor_height:
  # A tool opens the cover. Once grains are freed, air is efficient and impacts nibble.
  if old>roof+.0001:next=maxf(next,roof)
  elif tool_id==&"soft_brush":next=maxf(next,old)
  else:next=maxf(next,old-.024)
 return minf(old,next)
func apply_continuous(from:Vector2,to:Vector2,tool:ToolDefinition,delta:float) -> int:
 if not demo_ready or demo_kind==0:return super.apply_continuous(from,to,tool,delta)
 if tool.id==&"abrasive_tip":return _work_material(from,to,tool,delta,true)
 var changed:=super.apply_continuous(from,to,tool,delta)
 if tool.id==&"air_blower":changed+=_work_material(from,to,tool,delta,false)
 return changed
func _work_material(from:Vector2,to:Vector2,tool:ToolDefinition,delta:float,abrasion:bool) -> int:
 if delta<=0 or tool.radius<=0:return 0
 var started:=Time.get_ticks_usec()
 var low:=Vector2i((from.min(to)-Vector2.ONE*tool.radius).floor()).max(Vector2i.ZERO)
 var high:=Vector2i((from.max(to)+Vector2.ONE*tool.radius).ceil()).min(size-Vector2i.ONE)
 var segment:=to-from
 var length_squared:=segment.length_squared()
 var inverse_length:=1.0/length_squared if length_squared>0 else 0.0
 var radius_squared:=tool.radius*tool.radius
 var lookup_scale:=4096.0/radius_squared
 var changed:=0
 var volume:=0.0
 var newly_exposed:=PackedInt32Array()
 var sources:Array[Vector3]=[]
 var was_discovered:=fossil.first_contact
 # Explicit snapshot: packed-array assignments share mutable storage. Neighbor
 # eligibility must stay frozen for the whole stroke (no same-tick cascade).
 var previous_heights:=_heights.duplicate()
 var next_heights:=_heights
 var caps:=crust_caps
 var ceilings:=structural_ceilings
 var roofs:=grain_roofs;var floors:=grain_floors
 var lower_roofs:=deep_grain_roofs;var lower_floors:=deep_grain_floors
 var weights:=radial_weights;var ease:=marine_grain_ease
 var exposed:=fossil.exposed
 var width:=size.x;var count:=previous_heights.size()
 var offsets:PackedInt32Array=PackedInt32Array([-width*3,-3,3,width*3])
 var has_lower:=not lower_roofs.is_empty()
 var marine:=demo_kind==1
 var varying_ease:=marine and not ease.is_empty()
 var lip:=.028 if marine else .022
 var sx:=segment.x;var sy:=segment.y
 var sample_stride:=maxi(1,floori(radius_squared*.23))
 var rate:=.27 if abrasion else .72
 var work:=rate*minf(delta,.05)
 for y in range(low.y,high.y+1):
  var dy:float=y-from.y
  var row:=y*width
  for x in range(low.x,high.x+1):
   var i:=row+x
   var old:=previous_heights[i]
   var cap:=caps[i]
   var floor_height:=ceilings[i]
   var roof:=0.0;var bed_floor:=0.0;var deep_layer:=false
   # Already finished cells need neither distance math nor neighborhood queries.
   if abrasion:
    if cap<=0 or old>cap+.001 or old<=floor_height:continue
   else:
    roof=roofs[i];bed_floor=floors[i]
    deep_layer=has_lower and lower_roofs[i]>0 and old<=bed_floor+.0001
    if deep_layer:roof=lower_roofs[i];bed_floor=lower_floors[i]
    if roof<=0 or old<=bed_floor:continue
    floor_height=maxf(bed_floor,maxf(floor_height,cap))
    if old<=floor_height or old>roof+lip:continue
   var dx:float=x-from.x
   var t:=clampf((dx*sx+dy*sy)*inverse_length,0,1)
   var px:=dx-sx*t;var py:=dy-sy*t
   var distance_squared:=px*px+py*py
   if distance_squared>=radius_squared:continue
   if not abrasion and old>roof+.0001:
    var unsupported:=false
    for offset in offsets:
     var j:int=i+offset
     if j<0 or j>=count or abs(j%width-x)>3:continue
     var neighbor_roof:float=lower_roofs[j] if deep_layer else roofs[j]
     if neighbor_roof>0 and previous_heights[j]<neighbor_roof-.018:
      unsupported=true;break
    if not unsupported:continue
   var influence:=weights[mini(4096,int(distance_squared*lookup_scale))]
   if varying_ease:influence*=ease[i]
   var next:=maxf(floor_height,old-work*influence)
   if next-floor_height<.002 and influence>.25:next=floor_height
   if next>=old:continue
   next_heights[i]=next
   if abrasion:caps[i]=next if next>ceilings[i]+.00001 else 0.0
   volume+=old-next;changed+=1
   if sources.size()<8 and (changed%sample_stride==0 or ((abrasion or marine) and changed==1)):sources.append(Vector3(x,old,y))
   if ceilings[i]>0 and next<=ceilings[i]+FossilField.EXPOSURE_EPSILON and exposed[i]==0:newly_exposed.append(i)
 if changed==0:return 0
 _heights=next_heights
 if abrasion:crust_caps=caps
 tool_applied.emit()
 image.set_data(size.x,size.y,false,Image.FORMAT_RF,_heights.to_byte_array());dirty=true
 fossil.expose_cells(newly_exposed)
 update_fragments(Rect2i(low,high-low+Vector2i.ONE))
 if abrasion:crust_removed+=volume
 else:grains_removed+=volume
 last_removed=Vector3(0,0,volume) if abrasion else Vector3(volume,0,0)
 last_action={"tool":tool.id,"point":to,"removed":last_removed,"changed":changed,"marks":0,"chunks":[],"micro_detached":0,
  "bone_film_cleared":0.0,"residue_cleared":0.0,"loose_cleared":0.0,"bone_film_point":to,"cleared_dust":[],
  "direction":loose_debris.jet,"bone_revealed":not newly_exposed.is_empty(),"bone_first_contact":not was_discovered and fossil.first_contact,
  "bone_protected_contact":false,"bone_damage":0.0,"direct_bone_hit":false,"movement":from.distance_to(to)/delta,
  "pocket_flow":not abrasion,"abrasion":abrasion,"grain_sources":sources,"flow_volume":volume}
 last_edit_usec=Time.get_ticks_usec()-started
 material_action.emit(last_action)
 return changed
