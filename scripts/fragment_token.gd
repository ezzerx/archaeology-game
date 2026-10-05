class_name FragmentToken
extends Control
## Functional tray silhouette, drawn only when its state changes.
var fragment_id := 0
var occupied := false:
	set(value):
		if occupied == value: return
		occupied = value
		queue_redraw()

func _draw() -> void:
	draw_style_box(_style(), Rect2(Vector2.ZERO, size))
	if not occupied: return
	var ends: Vector4 = RecoverableFragmentField.ENDS[fragment_id]
	var angle := Vector2(ends.z - ends.x, ends.w - ends.y).angle()
	var center := size * 0.5
	var direction := Vector2.from_angle(angle) * 20
	draw_line(center - direction, center + direction, Color(0.94, 0.87, 0.72), 12, true)
	draw_circle(center - direction, 6, Color(0.94, 0.87, 0.72), true, -1, true)
	draw_circle(center + direction, 6, Color(0.94, 0.87, 0.72), true, -1, true)

func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.15, 0.16)
	style.border_color = Color(0.43, 0.48, 0.48)
	style.set_border_width_all(1)
	return style
