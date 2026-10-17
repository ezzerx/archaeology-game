extends "res://scripts/experiments/preparation_demos/demo_suite.gd"
const Store=preload("res://scripts/collection/exhibit_store.gd")
const Handoff=preload("res://scripts/collection/exhibit_handoff.gd")
var exhibit_store:RefCounted
var saved:=false

func _ready() -> void:
 exhibit_store=Store.new(Store.configured_directory())
 compact_selected=2
 await super._ready()
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
