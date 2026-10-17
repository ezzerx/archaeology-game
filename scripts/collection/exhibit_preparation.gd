extends "res://scripts/experiments/preparation_demos/demo_preparation.gd"
func _create_mastery_ui() -> PreparationUI:
 var ui=preload("res://scripts/collection/exhibit_ui.gd").new()
 ui.distinction=distinction
 return ui
