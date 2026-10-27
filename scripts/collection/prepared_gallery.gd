extends "res://scripts/experiments/exhibition/gallery.gd"
const Store=preload("res://scripts/collection/exhibit_store.gd")
const Handoff=preload("res://scripts/collection/exhibit_handoff.gd")
var exhibit_store:RefCounted
var return_button:Button
var transferring:=false

func _ready() -> void:
 exhibit_store=Store.new(Store.configured_directory())
 await super._ready()
 return_button.disabled=false
 exhibition_note.text="COLLECTION · VOS PRÉPARATIONS"
 for i in range(2):
  if examples[i]==null:
   nav_buttons[i+1].disabled=true;nav_buttons[i+1].text="À découvrir"
   var labels:=get_node("Cartel"+str(i)).find_children("*","Label3D",true,false)
   labels[0].text="COLLECTION";labels[1].text="À découvrir";labels[2].text="Votre prochaine préparation"
 for argument in OS.get_cmdline_user_args():
  if argument.begins_with("--exhibit-focus="):select(int(argument.trim_prefix("--exhibit-focus=")))
 _captions()
 Handoff.ready(exhibit_store.directory)

func _build_exhibit(id:String) -> Node3D:
 var block:Node3D=exhibit_store.load_block(id)
 preload("res://scripts/collection/exhibit_display.gd").apply(block)
 return block

func _ui() -> void:
 super._ui()
 return_button=Button.new();return_button.disabled=true;exhibition_note.get_parent().add_child(return_button)
 return_button.text="Retour à l’atelier";return_button.position=Vector2(1620,18)
 return_button.custom_minimum_size=Vector2(265,46);return_button.focus_mode=Control.FOCUS_NONE
 return_button.add_theme_stylebox_override("normal",nav_buttons[0].get_theme_stylebox("normal"))
 return_button.add_theme_font_override("font",sans);return_button.add_theme_font_size_override("font_size",19)
 return_button.pressed.connect(_return_to_workshop)

func select(index:int) -> void:
 if index>=0 and (index>=examples.size() or examples[index]==null):return
 super.select(index)

func _captions() -> void:
 super._captions()
 if exhibit_store==null:return
 if not exhibit_store.error_message.is_empty():
  subtitle.text=exhibit_store.error_message;return
 if selected<0:
  subtitle.text="Chaque pièce conserve le relief et les traces de votre travail."
  if exhibit_store.manifest.latest.is_empty():subtitle.text="La galerie attend votre première préparation. Rejoignez l’atelier."
 else:
  var record:Dictionary=exhibit_store.entry("B17" if selected==0 else "M08")
  if record.is_empty():return
  var values:Dictionary=record.snapshot
  subtitle.text="Dégagement %d %% · Nettoyage %d %% · État %d / 100"%[roundi(values.exposure),roundi(values.cleanliness),roundi(values.condition)]
  if record.get("integral",false):subtitle.text+=" · Préparation intégrale"
  subtitle.text+="   |   Molette : rapprocher · Glisser : relief"

func _return_to_workshop() -> void:
 if transferring or not fixtures_ready or not is_instance_valid(museum_audio):return
 transferring=true;return_button.disabled=true;return_button.text="Ouverture de l’atelier…"
 await museum_audio.fade_out(.65)
 if not await Handoff.transfer(get_tree(),false,exhibit_store.directory):
  museum_audio.resume_after_cancel()
  transferring=false;return_button.disabled=false;return_button.text="Réessayer l’atelier"
  subtitle.text="L’atelier n’a pas pu s’ouvrir. Vos préparations sont conservées."
