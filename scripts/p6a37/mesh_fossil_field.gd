extends FossilField
## Full source-authored B-17; no native bone fallback in this isolated candidate.
var patch: Resource
var replacement := PackedByteArray()
var native_occlusion_cells := 0
func _init(resolution := Vector2i(1024,640)) -> void:
	super(resolution)
	patch = load("res://assets/p6a37/mesh_patch_data.res")
	assert(size == patch.size)
	ceilings = patch.ceilings.duplicate()
	component_ids = patch.components.duplicate()
	replacement.resize(component_ids.size())
	component_totals.fill(0)
	total_cells = 0
	highest_ceiling = 0.0
	image = Image.create(size.x,size.y,false,Image.FORMAT_RGF)
	for i in range(component_ids.size()):
		var component := component_ids[i]
		if component == 0: continue
		replacement[i] = 1
		component_totals[component] += 1
		total_cells += 1
		highest_ceiling = maxf(highest_ceiling,ceilings[i])
		@warning_ignore("integer_division")
		image.set_pixel(i%size.x,i/size.x,Color(ceilings[i],component,0,1))
