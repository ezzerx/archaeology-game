extends MaterialAudio
## Only P6A3 replaces the three approved Foley families. Other cues stay provisional.

func setup(settings: ReactionProfile) -> void:
	super.setup(settings)
	var loop := load("res://assets/p6a3/audio/brush_soil_loop.wav").duplicate() as AudioStreamWAV
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_begin = 0
	loop.loop_end = loop.data.size() / 2
	samples[&"brush_soil"] = [loop,loop,loop,loop]
	for family in [&"chisel_clay", &"chisel_stone"]:
		var variants: Array[AudioStreamWAV] = []
		for i in range(1,5):
			variants.append(load("res://assets/p6a3/audio/%s_%02d.wav" % [family,i]))
		samples[family] = variants
