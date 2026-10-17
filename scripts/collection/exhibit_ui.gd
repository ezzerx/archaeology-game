extends "res://scripts/experiments/preparation_demos/demo_ui.gd"
var archive_state:="waiting"
func refresh() -> void:
 super.refresh()
 archive_button.text="Conserver cette préparation"
 closure_label.text="Conservez ce bloc tel qu’il est, ou poursuivez la finition."
 card_title.text="Votre travail rejoint le musée"
 match archive_state:
  "saving":
   card_subtitle.text="Conservation du relief, de la matière et de la finition…"
   another_button.text="Enregistrement…";another_button.disabled=true
  "saved":
   card_subtitle.text="Ce bloc précis est enregistré. Vous pourrez le retrouver après relance."
   another_button.text="Voir au musée";another_button.disabled=false
  "failed":
   card_subtitle.text="Enregistrement impossible. Votre bloc reste ouvert."
   another_button.text="Réessayer l’enregistrement";another_button.disabled=false
  _:
   card_subtitle.text="Le musée gardera votre préparation, avec ses traces de travail."
