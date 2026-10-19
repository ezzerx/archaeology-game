extends "res://scripts/experiments/preparation_demos/demo_suite.gd"
const Store=preload("res://scripts/collection/exhibit_store.gd")
const Handoff=preload("res://scripts/collection/exhibit_handoff.gd")
var exhibit_store:RefCounted
var saved:=false
var arrivals_return:Control
var arrivals_button:Button

func _ready() -> void:
 exhibit_store=Store.new(Store.configured_directory())
 compact_selected=2
 await super._ready()
 if "--arrivals-loop" in OS.get_cmdline_user_args():_arrivals_navigation()
 Handoff.ready(exhibit_store.directory)

func _make_preparation() -> Node3D:
 var value:=super._make_preparation()
 value.set_script(preload("res://scripts/collection/exhibit_preparation.gd"))
 return value

func open_demo(index:int,compact:int=-1) -> void:
 if busy:return
 await super.open_demo(index,compact)
 saved=false
 if "--qa" in OS.get_cmdline_user_args():preparation.display.persist=false
 preparation.session.archive_created.connect(_save_exhibit)
 for connection in preparation.session_ui.another_button.pressed.get_connections():
  preparation.session_ui.another_button.pressed.disconnect(connection.callable)
 preparation.session_ui.another_button.pressed.connect(_after_archive)
 if is_instance_valid(arrivals_button):
  compact_bar.hide();preparation.controller.ui_blockers.append(arrivals_button);preparation.controller.ui_blockers.append(arrivals_return)
 get_window().title="ArchaeologyGame — Préparer pour le musée"

func choose(index:int,restart:=false,compact:int=-1) -> void:
 if busy:return
 if is_instance_valid(preparation) and preparation.session.archived and not saved:
  preparation.session.notice.emit("Conservez ce bloc avant de changer de préparation.");return
 super.choose(index,restart,compact)

func _save_exhibit(_snapshot:Dictionary) -> void:
 if busy:return
 busy=true;preparation.controller.cancel_stroke()
 preparation.session_ui.archive_state="saving";preparation.session_ui.refresh()
 await get_tree().process_frame
 await get_tree().process_frame
 var result:Dictionary=exhibit_store.archive(preparation)
 saved=result.ok
 preparation.session_ui.archive_state="saved" if saved else "failed"
 preparation.session_ui.refresh()
 busy=false

func _after_archive() -> void:
 if busy:return
 if not saved:
  _save_exhibit(preparation.session.archive_snapshot);return
 busy=true;preparation.session_ui.another_button.disabled=true
 preparation.session_ui.card_subtitle.text="Installation de votre bloc dans la galerie…"
 var ok:bool=await Handoff.transfer(get_tree(),true,exhibit_store.directory,0 if preparation.specimen_id=="B17" else 1)
 if not ok:
  busy=false;preparation.session_ui.refresh()
  preparation.session_ui.card_subtitle.text="La galerie n’a pas pu s’ouvrir. Votre bloc est enregistré ; réessayez."

func _initial_demo() -> int:
 if "--arrivals-loop" in OS.get_cmdline_user_args():
  for arg in OS.get_cmdline_user_args():
   if arg.begins_with("--arrival-kind="):return clampi(int(arg.trim_prefix("--arrival-kind=")),0,2)
 return 0

func _arrivals_navigation() -> void:
 buttons[0].get_parent().hide();compact_bar.hide()
 var canvas:=CanvasLayer.new();canvas.layer=25;add_child(canvas)
 arrivals_button=Button.new();canvas.add_child(arrivals_button);arrivals_button.text="Retour aux arrivages";arrivals_button.position=Vector2(1460,18);arrivals_button.custom_minimum_size=Vector2(300,46);arrivals_button.focus_mode=Control.FOCUS_NONE
 arrivals_button.add_theme_font_size_override("font_size",20)
 arrivals_return=preload("res://scripts/experiments/preparation_demos/demo_confirmation.gd").new();canvas.add_child(arrivals_return)
 var labels:=arrivals_return.find_children("*","Label",true,false)
 labels[0].text="Retourner aux arrivages ?";labels[1].text="Cette préparation non conservée sera recommencée.\nLes pièces déjà exposées restent enregistrées."
 arrivals_return.ok_button.text="Quitter cette préparation"
 arrivals_button.pressed.connect(_request_arrivals)
 arrivals_return.confirmed.connect(_return_arrivals)
 preparation.controller.ui_blockers.append(arrivals_button);preparation.controller.ui_blockers.append(arrivals_return)

func _request_arrivals() -> void:
 if busy:return
 preparation.controller.cancel_stroke()
 if preparation.session.archived and not saved:
  preparation.session.notice.emit("Conservez ce bloc avant de quitter l’atelier.");return
 if saved:_return_arrivals()
 else:arrivals_return.show()

func _return_arrivals() -> void:
 if busy:return
 busy=true;preparation.controller.cancel_stroke();arrivals_button.disabled=true
 preparation.controller.set_process_unhandled_input(false)
 arrivals_return.show();arrivals_return.ok_button.disabled=true
 if not await Handoff.transfer_to(get_tree(),"arrivals",exhibit_store.directory,-1,true):
  busy=false;arrivals_button.disabled=false;arrivals_return.hide();arrivals_return.ok_button.disabled=false
  preparation.controller.set_process_unhandled_input(true)
  preparation.session.notice.emit("Les arrivages n’ont pas pu s’ouvrir. Votre bloc reste ici.")
