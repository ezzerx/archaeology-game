extends "res://tools/p6a3/export_notices.gd"

func _initialize() -> void:
	super._initialize()
	var path := OS.get_cmdline_user_args()[0].path_join("LICENCES.txt")
	var text := FileAccess.get_file_as_string(path)
	text = text.replace("ArchaeologyGame P6A3 — Windows playtest", "ArchaeologyGame P6A3.1 — Web playtest")
	text = text.replace("UI uses installed Windows system fonts through SystemFont; no font files are redistributed.", "UI uses SystemFont or engine fallback fonts; no Windows font files are redistributed.")
	text += "\nP6A3.1 retains the original P4/P5/P6A2 runtime audio. Historical ElevenLabs test sources may remain bundled; Claude is selected for the future sound-production pass, not invoked in this build.\n"
	FileAccess.open(path, FileAccess.WRITE).store_string(text)
