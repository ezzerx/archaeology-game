extends PreparationUI
## Presentation only. Base PreparationUI still owns P5 signals, snapshots/actions.
const INK := Color("463c2c")
const MUTED := Color("7b6c54")
const PAPER := Color("f2e6ce")
const GREEN := Color("54684e")
const OCHRE := Color("997035")
var heading_font: SystemFont
var body_font: SystemFont

func _init() -> void:
	heading_font = SystemFont.new()
	heading_font.font_names = PackedStringArray(["Georgia","Times New Roman"])
	body_font = SystemFont.new()
	body_font.font_names = PackedStringArray(["Segoe UI","Arial"])

static func paper_style(color: Color = PAPER, margin := 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("bdaa83")
	style.set_border_width_all(1)
	style.border_width_top = 3
	style.set_corner_radius_all(3)
	style.set_content_margin_all(margin)
	style.shadow_color = Color(0.12,.075,.03,.25)
	style.shadow_size = 7
	style.shadow_offset = Vector2(2,4)
	return style

func _panel(parent: Node, dimensions: Vector2) -> PanelContainer:
	var result := super._panel(parent,dimensions)
	result.add_theme_stylebox_override("panel",paper_style())
	return result

func _label(parent: Node, text: String, font_size := 18) -> Label:
	var label := super._label(parent,text,font_size)
	label.add_theme_color_override("font_color",INK)
	label.add_theme_font_override("font",body_font)
	return label

func _button(parent: Node, text: String, action: Callable, font_size := 18) -> Button:
	var button := super._button(parent,text,action,font_size)
	style_button(button)
	return button

func style_button(button: Button) -> void:
	button.add_theme_font_override("font",body_font)
	button.add_theme_color_override("font_color",INK)
	button.add_theme_color_override("font_hover_color",INK)
	button.add_theme_color_override("font_pressed_color",PAPER)
	for pair in [["normal",Color("e6d7b8")],["hover",Color("f9efd9")],["pressed",GREEN],["focus",Color("f9efd9")]]:
		var style := paper_style(pair[1],10)
		style.border_width_top = 1
		style.shadow_size = 0
		button.add_theme_stylebox_override(pair[0],style)

func _bar(parent: Node) -> ProgressBar:
	var bar := super._bar(parent)
	bar.custom_minimum_size.y = 7
	var background := paper_style(Color("d4c5a7"),0)
	background.shadow_size = 0
	background.set_border_width_all(0)
	var fill := background.duplicate() as StyleBoxFlat
	fill.bg_color = GREEN
	bar.add_theme_stylebox_override("background",background)
	bar.add_theme_stylebox_override("fill",fill)
	return bar

func _metric(parent: Node, title: String) -> Label:
	return super._metric(parent,"Reveal" if title == "Reveal skeleton" else "Clean")

func setup(state: PreparationSession, input: ToolController, reset_action: Callable) -> void:
	super.setup(state,input,reset_action)
	preparation_card.custom_minimum_size.x = 236
	preparation_card.position = Vector2(14,132)
	var column := preparation_card.get_child(0) as VBoxContainer
	column.add_theme_constant_override("separation",12)
	var title := column.get_child(0) as Label
	title.text = "Specimen B–17"
	title.add_theme_font_override("font",heading_font)
	title.add_theme_font_size_override("font_size",25)
	var overline := _label(column,"NATURAL HISTORY\nPREPARATION RECORD",11)
	overline.add_theme_color_override("font_color",MUTED)
	column.move_child(overline,0)
	var rule := HSeparator.new()
	column.add_child(rule)
	column.move_child(rule,2)
	var line := StyleBoxLine.new()
	line.color = Color("b9a680")
	rule.add_theme_stylebox_override("separator",line)
	state_label.add_theme_font_size_override("font_size",15)
	coverage_label.add_theme_font_size_override("font_size",14)
	closure_label.add_theme_font_size_override("font_size",14)
	fine_label.add_theme_font_size_override("font_size",14)
	condition_label.add_theme_font_size_override("font_size",16)
	card_title.text = "Specimen archived"
	card_title.add_theme_font_override("font",heading_font)
	card_title.add_theme_font_size_override("font_size",34)
	card_subtitle.text = "Museum records updated."
	card_subtitle.add_theme_font_size_override("font_size",19)
	var stamp := _label(card.get_child(0),"NATURAL HISTORY  /  COLLECTIONS",13)
	stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stamp.add_theme_color_override("font_color",MUTED)
	card.get_child(0).move_child(stamp,0)
	modal.color = Color(.12,.085,.04,.55)
	notice_label.add_theme_color_override("font_color",PAPER)
	notice_label.add_theme_color_override("font_outline_color",INK)
	notice_label.add_theme_constant_override("outline_size",4)
	refresh()

func refresh() -> void:
	super.refresh()
	# Only palette changes; latched milestones and visibility stay in the base UI.
	state_label.modulate = Color.WHITE
	state_label.add_theme_color_override("font_color",GREEN if session.preparation_complete else MUTED)
	closure_label.modulate = Color.WHITE
	closure_label.add_theme_color_override("font_color",GREEN)
	fine_label.modulate = Color.WHITE
	fine_label.add_theme_color_override("font_color",OCHRE)
	card_title.modulate = Color.WHITE
	card_title.add_theme_color_override("font_color",GREEN)
	card_star.modulate = Color.WHITE
	card_star.add_theme_color_override("font_color",OCHRE)

func _shine_star() -> void:
	super._shine_star()
	quality_tween.kill()
	fine_label.modulate = Color(1.1,1.05,.95)
	quality_tween = create_tween()
	quality_tween.tween_property(fine_label,"modulate",Color.WHITE,.75)
