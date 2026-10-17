extends ToolController
## One finishing slot, with explicit cycling and remembered return.
var finishing_variant := 0
var finishing_modal: Control

func has_finishing_family() -> bool:
 return tools.size() > 4 and tools[4].id == &"abrasive_tip"

func select_tool(index: int) -> bool:
 var previous := finishing_variant
 if has_finishing_family() and index in [0, 4]: finishing_variant = index
 if super.select_tool(index): return true
 finishing_variant = previous
 return false

func select_finishing() -> void:
 if not _focused or (is_instance_valid(finishing_modal) and finishing_modal.visible): return
 var next := finishing_variant
 if selected_index in [0, 4]: next = 4 if selected_index == 0 else 0
 select_tool(next)

func _unhandled_input(event: InputEvent) -> void:
 if has_finishing_family():
  if is_instance_valid(finishing_modal) and finishing_modal.visible:
   cancel_stroke()
   return
  if event is InputEventKey and event.physical_keycode in [KEY_1, KEY_KP_1, KEY_5, KEY_KP_5]:
   if event.pressed and not event.echo and event.physical_keycode in [KEY_1, KEY_KP_1]:
    select_finishing()
   get_viewport().set_input_as_handled()
   return
 super._unhandled_input(event)
