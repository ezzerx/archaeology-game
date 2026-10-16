extends "res://scripts/excavation/pockets/final_preparation.gd"
signal collection_requested
signal restart_requested
@export var specimen_id:="B17"
var collection_button:Button
func _create_display() -> Node:
 var value=preload("res://scripts/workshop/playtest_display.gd").new()
 value.load_preferences=false
 return value
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/collection/specimen_profile.gd").new(block.working_map,block.footprint,block.rim)
func _create_mesh_view() -> Node3D:
 return preload("res://scripts/collection/specimen_mesh.gd").new(specimen_id)
func _create_inspection() -> CanvasLayer:
 return preload("res://scripts/collection/specimen_inspection.gd").new()
func _create_mastery_ui() -> PreparationUI:
 var ui=preload("res://scripts/collection/specimen_ui.gd").new()
 ui.distinction=distinction
 return ui
func _ready() -> void:
 super._ready()
 get_window().title="ArchaeologyGame — Atelier des collections"
 panel.hide()
 $Debug/Help.text="1 Brush   2 Chisel   3 Souffleur   4 Pick     Molette · zoom     Clic droit · déplacer     Home · vue     C · collection"
 if specimen_id=="M08":
  camera.size=.70;camera.initialize_view()
 collection_button=Button.new()
 collection_button.text="Collection · C"
 collection_button.focus_mode=Control.FOCUS_NONE
 session_ui.style_button(collection_button)
 session_ui.root_control.add_child(collection_button)
 collection_button.position=Vector2(16,78)
 collection_button.custom_minimum_size=Vector2(236,40)
 controller.ui_blockers.append(collection_button)
 collection_button.pressed.connect(func():collection_requested.emit())
 for label:Label in session_ui.preparation_card.find_children("*","Label",true,false):
  if label.text.begins_with("Specimen B"):label.text="Spécimen "+preload("res://scripts/collection/catalog.gd").entry(specimen_id).code
 session_ui.refresh()
 controller.select_tool(1)
func _input(event:InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_C:
   collection_requested.emit();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_R:
   restart_requested.emit();get_viewport().set_input_as_handled();return
  if not "--qa" in OS.get_cmdline_user_args() and event.physical_keycode in [KEY_F5,KEY_H,KEY_F8,KEY_F9,KEY_F10,KEY_F11]:
   get_viewport().set_input_as_handled();return
 super._input(event)
