extends Node
## Correct material interpolation only beside committed, exposed Bone cells.
var block: ExcavationBlock
var texture: ImageTexture
var image: Image
var edges := PackedByteArray()
var pending := {}
var neighbors := {}
var uploads := 0
func setup(target: ExcavationBlock) -> void:
	block = target
	var field: FossilField = block.working_map.fossil.field
	edges.resize(field.component_ids.size())
	image = Image.create(field.size.x,field.size.y,false,Image.FORMAT_R8)
	texture = ImageTexture.create_from_image(image)
	for y in range(1,field.size.y-1):
		for x in range(1,field.size.x-1):
			var i := y*field.size.x+x
			if field.component_ids[i] == 0: continue
			var adjacent := PackedInt32Array()
			for offset in [-field.size.x-1,-field.size.x,-field.size.x+1,-1,1,field.size.x-1,field.size.x,field.size.x+1]:
				if field.component_ids[i+offset] == 0: adjacent.append(i+offset)
			if not adjacent.is_empty(): neighbors[i] = adjacent
	block.working_map.fossil.bone_cell_exposed.connect(_expose)
	block.working_map.surface_reset.connect(_reset)
func _expose(cell: Vector2i, _component: int) -> void:
	var i := cell.y*block.map_resolution.x+cell.x
	for adjacent in neighbors.get(i,[]): pending[adjacent] = true
func _reset() -> void:
	pending.clear();edges.fill(0);image.fill(Color(0,0,0,1));texture.update(image)
func sync() -> void:
	if pending.is_empty(): return
	for i in pending: edges[i] = 255
	pending.clear()
	image.set_data(block.map_resolution.x,block.map_resolution.y,false,Image.FORMAT_R8,edges)
	texture.update(image)
	uploads += 1
func _process(_delta: float) -> void:
	sync()
