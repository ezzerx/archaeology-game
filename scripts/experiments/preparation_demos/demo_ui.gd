extends "res://scripts/collection/specimen_ui.gd"
func refresh() -> void:
 super.refresh()
 if collection_label!=null:collection_label.hide()
 archive_button.text="Terminer cet essai"
 another_button.text="Recommencer cet essai"
 card_title.text="Préparation terminée"
 card_subtitle.text="Résultat de cet essai · collection habituelle préservée"
 state_label.text="Prêt à terminer" if session.preparation_complete else session.snapshot().classification
 closure_label.text="Terminez cet essai ou poursuivez la finition."
