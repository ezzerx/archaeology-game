extends "res://scripts/preparation/tactile/preparation_ui.gd"
func refresh() -> void:
 super.refresh()
 var values:=session.snapshot()
 state_label.text="Prêt pour la collection" if session.preparation_complete else values.classification
 condition_label.text="État · %d / 100"%roundi(values.condition)
 closure_label.text="Vous pouvez archiver ou poursuivre la finition."
 coverage_label.text="Une partie importante reste enfouie."
 fine_label.text="Préparation soignée" if session.fine_preparation else "Finition facultative · 95 %"
 archive_button.text="Ajouter à la collection"
 keep_button.text="Poursuivre la finition"
 card_title.text="Une nouvelle pièce pour le musée"
 card_subtitle.text="Votre préparation rejoint la collection."
 card_condition.text="État de la pièce · %d / 100"%roundi(session.archive_snapshot.get("condition",100))
 card_star.text="Préparation soignée"
 another_button.text="Voir ma collection"
 if archive_distinction!=null and archive_distinction.visible:archive_distinction.text="Préparation intégrale · 100 / 100"
func setup(state:PreparationSession,input:ToolController,reset_action:Callable) -> void:
 super.setup(state,input,reset_action)
 for label:Label in preparation_card.find_children("*","Label",true,false):
  if label.text=="Reveal":label.text="Dégagement"
  if label.text=="Clean":label.text="Nettoyage"
  if label.text.begins_with("NATURAL HISTORY"):label.text="MUSÉUM · ATELIER DE PRÉPARATION"
 for label:Label in card.find_children("*","Label",true,false):
  if label.text.begins_with("NATURAL HISTORY"):label.text="MUSÉUM · COLLECTIONS"
