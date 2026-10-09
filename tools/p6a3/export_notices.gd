extends SceneTree
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size()==1)
	var text := "ArchaeologyGame P6A3 — Windows playtest\n\nGodot Engine\n"+Engine.get_license_text()
	text += "\n\nThird-party notices bundled with Godot:\n"
	for component in Engine.get_copyright_info(): text += JSON.stringify(component,"\t")+"\n"
	text += JSON.stringify(Engine.get_license_info(),"\t")
	text += "\n\nUI uses installed Windows system fonts through SystemFont; no font files are redistributed.\n"
	text += "Selected material sources: ChatGPT ImageGen v02, reviewed by Antoine/orchestrator. Runtime derivations and original procedural static mesh authoring: ArchaeologyGame P6A2.\n"
	text += "P6A3 tool/lamp models: Tripo Studio Max paid-plan outputs, cleaned and adapted in Blender. Provenance: art/source/p6a3/meshes/tripo/provenance.json. Commercial-use policy: https://www.tripo3d.ai/help/privacy-policy/how-to-use-tripo-models-commercially\n"
	text += "P6A3 Foley: three ElevenLabs test candidates supplied by Antoine/orchestrator; original IDs and processing recorded in art/source/p6a3/audio/README.md and assets/p6a3/audio/processing.json.\n"
	FileAccess.open(args[0].path_join("LICENCES.txt"),FileAccess.WRITE).store_string(text)
	quit()
