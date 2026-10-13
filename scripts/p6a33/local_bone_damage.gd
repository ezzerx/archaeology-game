extends RefCounted
## Cosmetic map of committed damage contacts. Global Condition remains authoritative.
var fossil: FossilState
var image: Image
var texture: ImageTexture
var marks: Array[Dictionary] = []

func setup(state: FossilState) -> void:
	fossil = state
	image = Image.create(state.field.size.x, state.field.size.y, false, Image.FORMAT_L8)
	image.fill(Color.BLACK)
	texture = ImageTexture.create_from_image(image)
	state.bone_damaged_at.connect(record)
	state.specimen_reset.connect(reset)

func reset() -> void:
	marks.clear()
	image.fill(Color.BLACK)
	texture.update(image)

func record(cell: Vector2i, component: int, damage: float) -> void:
	if damage <= 0.0: return
	var mark: Dictionary = {}
	for existing in marks:
		if existing.component == component and Vector2(existing.cell).distance_to(Vector2(cell)) < 9.0:
			mark = existing
			break
	if mark.is_empty():
		mark = {"cell":cell, "component":component, "damage":0.0}
		marks.append(mark)
	mark.damage += damage
	var random := RandomNumberGenerator.new()
	random.seed = mark.cell.y * fossil.field.size.x + mark.cell.x + 719
	var angle := random.randf_range(-PI, PI)
	var severity := clampf(mark.damage / 14.0, 0.0, 1.0)
	var length := lerpf(6.0, 19.0, severity)
	var origin := Vector2(mark.cell)
	for branch in range(3):
		var direction := Vector2.from_angle(angle + branch * 2.1 + random.randf_range(-.45,.45))
		var previous := origin
		for step in range(1,5):
			var next := origin + direction * length * step / 4.0 + direction.orthogonal() * random.randf_range(-1.6,1.6)
			_draw_segment(previous, next, component, lerpf(.35,.95,severity))
			previous = next
	texture.update(image)

func _draw_segment(a: Vector2, b: Vector2, component: int, strength: float) -> void:
	var low := Vector2i((a.min(b)-Vector2.ONE*2).floor()).max(Vector2i.ZERO)
	var high := Vector2i((a.max(b)+Vector2.ONE*2).ceil()).min(fossil.field.size-Vector2i.ONE)
	for y in range(low.y,high.y+1):
		for x in range(low.x,high.x+1):
			var index := y*fossil.field.size.x+x
			if fossil.exposed[index] == 0 or fossil.field.component_ids[index] != component: continue
			var point := Vector2(x,y)
			var distance := point.distance_to(Geometry2D.get_closest_point_to_segment(point,a,b))
			var value := strength * (1.0-smoothstep(.35,1.3,distance))
			if value > image.get_pixel(x,y).r: image.set_pixel(x,y,Color(value,value,value))
