extends "res://scripts/p6a41/rough_preparation.gd"
const CARD = preload("res://scripts/p6a/playtest_preparation_ui.gd")
const PROFILES = preload("res://scripts/p6a42/three_profiles.gd")
var block_choice: OptionButton
var block_hint: Label
var switch_dialog: ConfirmationDialog
var requested_block := -1
var trial_worked := false
var wired_ui: PreparationUI
func _create_profile() -> SoilFoundationProfile:
 return PROFILES.new(block.working_map,block.footprint,block.rim)
func _ready() -> void:
 super._ready()
 var tray := PanelContainer.new()
 tray.add_theme_stylebox_override("panel",CARD.paper_style(CARD.PAPER,10))
 var layer := CanvasLayer.new()
 layer.layer = 6
 add_child(layer)
 layer.add_child(tray)
 tray.position = Vector2(620,14)
 tray.custom_minimum_size.x = 680
 var box := VBoxContainer.new()
 tray.add_child(box)
 var row := HBoxContainer.new()
 box.add_child(row)
 var caption := Label.new()
 caption.add_theme_color_override("font_color",CARD.INK)
 caption.add_theme_font_override("font",session_ui.body_font)
 caption.text = "B-17 · Choisir une préparation  "
 row.add_child(caption)
 block_choice = OptionButton.new()
 for title in PROFILES.NAMES: block_choice.add_item(title)
 session_ui.style_button(block_choice)
 block_choice.focus_mode = Control.FOCUS_NONE
 block_choice.item_selected.connect(request_block)
 row.add_child(block_choice)
 block_hint = Label.new()
 block_hint.add_theme_color_override("font_color",CARD.MUTED)
 block_hint.add_theme_font_override("font",session_ui.body_font)
 block_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 block_hint.custom_minimum_size.x = 680
 block_hint.add_theme_font_size_override("font_size",16)
 box.add_child(block_hint)
 controller.ui_blockers.append(tray)
 switch_dialog = ConfirmationDialog.new()
 switch_dialog.title = "Changer de préparation ?"
 switch_dialog.dialog_text = "Le bloc choisi commencera une nouvelle préparation.\nLa fouille en cours sera recommencée."
 switch_dialog.ok_button_text = "Ouvrir ce bloc"
 switch_dialog.cancel_button_text = "Continuer la fouille"
 add_child(switch_dialog)
 switch_dialog.confirmed.connect(_confirm_block)
 switch_dialog.canceled.connect(_cancel_block)
 # The existing archive flow advances through the three trials; R repeats one.
 _wire_archive()
 block.working_map.tool_applied.connect(_worked)
 block.working_map.surface_reset.connect(_trial_reset)
 _update_trial()
func _worked() -> void:
 trial_worked = true
func _trial_reset() -> void:
 trial_worked = false
func request_block(index: int) -> void:
 block_choice.select(profile.selected)
 if index == profile.selected: return
 requested_block = clampi(index,0,2)
 controller.cancel_stroke()
 if trial_worked and not session.archived:
  switch_dialog.popup_centered(Vector2i(500,180))
 else: _confirm_block()
func _cancel_block() -> void:
 requested_block = -1
func _confirm_block() -> void:
 if requested_block < 0: return
 open_block(requested_block)
 requested_block = -1
func open_block(index: int) -> void:
 controller.cancel_stroke()
 profile.selected = clampi(index,0,2)
 reset_specimen()
 _update_trial()
func next_block() -> void:
 open_block((profile.selected+1)%3)
func reload() -> void:
 super.reload()
 if block_choice != null: _update_trial()
func _update_trial() -> void:
 block_choice.select(profile.selected)
 block_hint.text = PROFILES.NOTES[profile.selected]+"  ·  R : recommencer"
 get_window().title = "ArchaeologyGame — B-17 · "+PROFILES.NAMES[profile.selected]
 panel.get_child(0).get_child(0).text = "B-17 / TROIS PRÉPARATIONS"
 # Historical debug cuts remain available, but the player selector is separate.
 note.text = PROFILES.NOTES[profile.selected]

func _wire_archive() -> void:
 wired_ui = session_ui
 for connection in session_ui.another_button.pressed.get_connections():
  session_ui.another_button.pressed.disconnect(connection.callable)
 session_ui.another_button.pressed.connect(next_block)
 session_ui.another_button.text = "Préparer le bloc suivant"
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(session_ui) and session_ui != wired_ui: _wire_archive()
