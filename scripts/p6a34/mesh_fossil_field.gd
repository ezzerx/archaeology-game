extends FossilField
## Only this pilot uses mesh-authored Skull and three rib pairs.
var patch: Resource
var replacement := PackedByteArray()
var native_occlusion_cells := 0

func _init(resolution := Vector2i(1024,640)) -> void:
	super(resolution)
	patch = load("res://assets/p6a34/mesh_patch_data.res")
	assert(size == patch.size,"Pilot bake uses the canonical resolution")
	replacement.resize(component_ids.size())
	for i in range(component_ids.size()):
		var previous := component_ids[i]
		var selected: bool = previous == Component.SKULL or (previous == Component.RIBS and patch.old_rib_selection[i] != 0)
		if selected:
			component_ids[i] = 0
			ceilings[i] = 0.0
		if patch.components[i] != 0:
			if previous != 0 and not selected:
				# Native vertebrae may physically sit above a rib joint. Keep their
				# exact authority; this is occlusion by another bone, not old rib fallback.
				assert(ceilings[i] >= patch.ceilings[i],"New mesh must not overtop unrelated anatomy")
				native_occlusion_cells += 1
				continue
			component_ids[i] = patch.components[i]
			ceilings[i] = patch.ceilings[i]
			replacement[i] = 1
	component_totals.fill(0)
	total_cells = 0
	highest_ceiling = 0.0
	image = Image.create(size.x,size.y,false,Image.FORMAT_RGF)
	for i in range(component_ids.size()):
		var component := component_ids[i]
		if component == 0: continue
		component_totals[component] += 1
		total_cells += 1
		highest_ceiling = maxf(highest_ceiling,ceilings[i])
		@warning_ignore("integer_division")
		image.set_pixel(i%size.x,i/size.x,Color(ceilings[i],component,0,1))
