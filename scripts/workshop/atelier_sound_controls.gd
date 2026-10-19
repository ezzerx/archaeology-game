extends OptionButton
## One compact player-facing control. Never changes the Master bus.
func setup(preparation: Node3D) -> void:
 name="AtelierSound"
 add_item("Son : outils + ambiance")
 add_item("Son : outils seuls")
 add_item("Son : coupé")
 focus_mode=Control.FOCUS_NONE
 preparation.session_ui.style_button(self)
 add_theme_font_size_override("font_size",16)
 preparation.session_ui.root_control.add_child(self)
 position=Vector2(1640,66)
 size=Vector2(260,36)
 preparation.controller.ui_blockers.append(self)
 var mix:=AudioServer.get_bus_index("Atelier")
 var room:=AudioServer.get_bus_index("Atelier Room")
 select(2 if mix>=0 and AudioServer.is_bus_mute(mix) else (1 if room>=0 and AudioServer.is_bus_mute(room) else 0))
 item_selected.connect(_select_mode)
func _select_mode(index:int) -> void:
 var mix:=AudioServer.get_bus_index("Atelier")
 var room:=AudioServer.get_bus_index("Atelier Room")
 if mix>=0:AudioServer.set_bus_mute(mix,index==2)
 if room>=0:AudioServer.set_bus_mute(room,index==1)
