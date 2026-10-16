extends "res://scripts/preparation/readability/mastery_ui.gd"
var distinction: RefCounted
var distinction_label: Label
var archive_distinction: Label
var collection_label: Label

func setup(state: PreparationSession, input: ToolController, reset_action: Callable) -> void:
	super.setup(state,input,reset_action)
	var column := preparation_card.get_child(0)
	distinction_label = _label(column,"✦ Préparation intégrale\n100 / 100",14)
	distinction_label.add_theme_color_override("font_color",OCHRE)
	column.move_child(distinction_label,fine_label.get_index()+1)
	collection_label = _label(column,"Collection · distinction acquise",12)
	collection_label.add_theme_color_override("font_color",MUTED)
	column.move_child(collection_label,distinction_label.get_index()+1)
	archive_distinction = _label(card.get_child(0),"✦ Préparation intégrale",22)
	archive_distinction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	archive_distinction.add_theme_color_override("font_color",OCHRE)
	card.get_child(0).move_child(archive_distinction,card_star.get_index()+1)
	refresh()

func refresh() -> void:
	super.refresh()
	if distinction_label == null: return
	distinction_label.visible = distinction != null and distinction.earned
	collection_label.visible = distinction != null and distinction.has_collection_distinction()
	archive_distinction.visible = session.archive_snapshot.get("integral_preparation",false)
	if archive_distinction.visible and distinction != null:
		archive_distinction.text = "✦ Préparation intégrale" + ("\nDistinction enregistrée" if distinction.save_error == OK else "\nEnregistrement indisponible")
