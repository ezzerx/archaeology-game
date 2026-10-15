extends "res://scripts/p6a47/pocket_preparation.gd"
var variant_button:Button
func _create_profile() -> SoilFoundationProfile:
 return preload("res://scripts/p6a48/buried_profile.gd").new(block.working_map,block.footprint,block.rim)
func _create_pocket() -> Node:
 return preload("res://scripts/p6a48/buried_pocket.gd").new()
func _ready() -> void:
 super._ready()
 get_window().title="ArchaeologyGame — B-17 · Poche enfouie"
 panel.get_child(0).get_child(0).text="B-17 / POCHE ENFOUIE"
 for label:Label in find_children("*","Label",true,false):
  if label.text.begins_with("B-17 · Une poche sous"):
   label.text="B-17 · Une découverte dans l’argile\nFouillez normalement. Quand des grains apparaissent, essayez le souffleur (3). · R : recommencer · H : autres essais"
 variant_button=Button.new()
 variant_button.focus_mode=Control.FOCUS_NONE
 session_ui.style_button(variant_button)
 variant_button.tooltip_text="Recommence le spécimen avec un autre emplacement et une autre profondeur de poche."
 panel.get_child(0).add_child(variant_button)
 panel.get_child(0).move_child(variant_button,1)
 variant_button.pressed.connect(func():select_pocket_variant(profile.variant+1))
 _variant_label()
func _variant_label() -> void:
 if is_instance_valid(variant_button):variant_button.text="Autre essai · recommencer (%d/3)" % (profile.variant+1)
func select_pocket_variant(index:int) -> void:
 profile.set_variant(index)
 reset_specimen()
 _variant_label()
func reload() -> void:
 # Binding precedes the inherited reset; configure then uses the selected lens.
 if is_instance_valid(pocket):pocket.layout=profile.layout
 super.reload()
 _variant_label()
