extends "res://scripts/excavation/pockets/final_surface.gd"
var demo_kind:=0
var grain_roofs:=PackedFloat32Array()
var grain_floors:=PackedFloat32Array()
var crust_caps:=PackedFloat32Array()
var grains_removed:=0.0
var crust_removed:=0.0
var demo_ready:=false
var radial_weights:=PackedFloat32Array()
func configure_demo(roofs:PackedFloat32Array,floors:PackedFloat32Array,caps:PackedFloat32Array) -> void:
 grain_roofs=roofs;grain_floors=floors;crust_caps=caps.duplicate()
 grains_removed=0;crust_removed=0;demo_ready=true
 if radial_weights.is_empty():
  radial_weights.resize(4097)
  for i in range(4097):radial_weights[i]=weight(sqrt(float(i)/4096),.65)
func can_detach_micro_remnant(i:int) -> bool:
 return not demo_ready or demo_kind!=2 or crust_caps[i]<=0
func constrain_removal(i:int,next:float,tool_id:StringName) -> float:
 if demo_kind==0 or not demo_ready:return super.constrain_removal(i,next,tool_id)
 var old:=_heights[i]
 if crust_caps[i]>0:next=maxf(next,crust_caps[i])
 if grain_roofs[i]>0 and old>grain_floors[i]:
  # A tool opens the cover. Once grains are freed, air is efficient and impacts nibble.
  if old>grain_roofs[i]+.0001:next=maxf(next,grain_roofs[i])
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
 # An explicit immutable snapshot freezes roof eligibility for the complete stroke.
 # Single traversal + a radial lookup avoid per-texel calls, vectors and pow().
 var previous_heights:=_heights.duplicate()
 var sample_stride:=maxi(1,floori(radius_squared*.23))
 var rate:=.27 if abrasion else .72
 var work:=rate*minf(delta,.05)
 for y in range(low.y,high.y+1):
  var dy:float=y-from.y
  for x in range(low.x,high.x+1):
   var dx:float=x-from.x
   var t:=clampf((dx*segment.x+dy*segment.y)*inverse_length,0,1)
   var px:=dx-segment.x*t;var py:=dy-segment.y*t
   var distance_squared:=px*px+py*py
   if distance_squared>=radius_squared:continue
   var i:=y*size.x+x
   var old:=previous_heights[i]
   var cap:=crust_caps[i]
   var floor_height:=structural_ceilings[i]
   if abrasion:
    if cap<=0 or old>cap+.001:continue
   else:
    var roof:=grain_roofs[i]
    if roof<=0 or old<=grain_floors[i]:continue
    if old>roof+.0001:
     if old>roof+.022:continue
     var unsupported:=false
     for offset in [-size.x*3,-3,3,size.x*3]:
      var j:int=i+offset
      if j>=0 and j<grain_roofs.size() and abs(j%size.x-x)<=3 and grain_roofs[j]>0 and previous_heights[j]<grain_roofs[j]-.018:
       unsupported=true;break
     if not unsupported:continue
    floor_height=maxf(grain_floors[i],maxf(floor_height,cap))
   var influence:=radial_weights[mini(4096,int(distance_squared*lookup_scale))]
   var next:=maxf(floor_height,old-work*influence)
   if next-floor_height<.002 and influence>.25:next=floor_height
   if next>=old:continue
   _heights[i]=next
   if abrasion:crust_caps[i]=next if next>structural_ceilings[i]+.00001 else 0.0
   volume+=old-next;changed+=1
   if sources.size()<8 and (changed%sample_stride==0 or (abrasion and changed==1)):sources.append(Vector3(x,old,y))
   if structural_ceilings[i]>0 and next<=structural_ceilings[i]+FossilField.EXPOSURE_EPSILON and fossil.exposed[i]==0:newly_exposed.append(i)
 if changed==0:return 0
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
