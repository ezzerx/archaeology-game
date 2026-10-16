extends ColorRect
signal confirmed
var ok_button:Button
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 color=Color(.05,.035,.02,.68)
 mouse_filter=Control.MOUSE_FILTER_STOP
 var style=preload("res://scripts/workshop/playtest_preparation_ui.gd")
 var card:=PanelContainer.new();add_child(card)
 card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 card.position=Vector2(620,430);card.size=Vector2(680,210)
 card.add_theme_stylebox_override("panel",style.paper_style(style.PAPER,18))
 var box:=VBoxContainer.new();box.add_theme_constant_override("separation",16);card.add_child(box)
 var title:=Label.new();title.text="Changer de préparation ?";title.add_theme_font_size_override("font_size",26)
 title.add_theme_color_override("font_color",style.INK);box.add_child(title)
 var text:=Label.new();text.text="Le travail de cet essai sera recommencé.\nLa collection habituelle reste intacte."
 text.add_theme_font_size_override("font_size",20);text.add_theme_color_override("font_color",style.INK);box.add_child(text)
 var row:=HBoxContainer.new();row.add_theme_constant_override("separation",12);box.add_child(row)
 var cancel:=Button.new();cancel.text="Continuer mon travail";cancel.custom_minimum_size=Vector2(300,44);row.add_child(cancel);cancel.pressed.connect(hide)
 ok_button=Button.new();ok_button.text="Changer et recommencer";ok_button.custom_minimum_size=Vector2(300,44);row.add_child(ok_button)
 ok_button.pressed.connect(func():hide();confirmed.emit())
 for button in [cancel,ok_button]:button.focus_mode=Control.FOCUS_NONE;button.add_theme_font_size_override("font_size",18)
 hide()
func popup_centered(_size:Vector2i) -> void:show()
func get_ok_button() -> Button:return ok_button
