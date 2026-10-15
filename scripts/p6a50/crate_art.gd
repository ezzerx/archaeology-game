extends Control
## Native illustrated specimen crate; no fossil silhouette in an unopened parcel.
var code:="M–08"
var compact:=true
var empty:=false
var lettering:=SystemFont.new()
func _ready() -> void:
 lettering.font_names=PackedStringArray(["Georgia"])
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)
func _draw() -> void:
 if size.x<1:return
 draw_set_transform(Vector2.ZERO,0,size/Vector2(700,270))
 draw_rect(Rect2(0,0,700,270),Color("3c3025"))
 for i in range(35):
  var y:=float(i*9)
  draw_line(Vector2(0,y),Vector2(700,y+7),Color(1,.83,.56,.025),1)
 if empty:
  draw_rect(Rect2(58,30,584,200),Color("433a2d"))
  draw_rect(Rect2(58,30,584,200),Color("79654a"),false,2)
  draw_line(Vector2(320,130),Vector2(380,130),Color("9e8964"),2)
  draw_line(Vector2(350,100),Vector2(350,160),Color("9e8964"),2)
  return
 var x:=126.0 if compact else 70.0
 var w:=448.0 if compact else 560.0
 draw_rect(Rect2(x+12,54,w,196),Color(0,0,0,.25))
 draw_colored_polygon(PackedVector2Array([Vector2(x,208),Vector2(x+w,208),Vector2(x+w+22,232),Vector2(x+22,232)]),Color("684831"))
 draw_colored_polygon(PackedVector2Array([Vector2(x+w,34),Vector2(x+w+22,56),Vector2(x+w+22,232),Vector2(x+w,208)]),Color("715036"))
 for plank in range(5):
  var y:=34.0+plank*35
  draw_rect(Rect2(x,y,w,33),Color("a0784c").lightened(.035*sin(plank*7.0)))
  for line in range(5):
   var yy:=y+5+line*5
   draw_polyline(PackedVector2Array([Vector2(x+8,yy),Vector2(x+w*.27,yy-1),Vector2(x+w*.53,yy+2),Vector2(x+w-8,yy)]),Color(.25,.15,.07,.14),1)
 for xx in [x+38,x+w-56]:
  draw_rect(Rect2(xx,25,21,192),Color("c39b69"))
  for y in [38,198]:draw_circle(Vector2(xx+10,y),3,Color("463d2c"))
 draw_line(Vector2(x+w*.51,31),Vector2(x+w*.51,210),Color("d2b98a"),3)
 var tag:=Rect2(x+w*.49-68,83,147,84)
 draw_rect(Rect2(tag.position+Vector2(3,4),tag.size),Color(0,0,0,.2))
 draw_rect(tag,Color("eee1c3"))
 draw_circle(tag.position+Vector2(73,8),3,Color("6b5740"))
 draw_string(lettering,tag.position+Vector2(18,53),code,HORIZONTAL_ALIGNMENT_LEFT,-1,34,Color("473c2b"))
