extends Node
const TITLES:=["01 · Terre compacte","02 · Sédiments marins","03 · Concrétions"]
const NOTES:=["SUIVRE UNE FORME  ·  Ouvrez la matrice, puis suivez ce qui apparaît.",
 "LIBÉRER LES GRAINS  ·  Ouvrez au Chisel, soufflez les zones friables. Les îlots solides se travaillent au Pick.",
 "DÉGAGER LES DÉTAILS  ·  Ouvrez puis soufflez. [1] alterne Brush / pointe abrasive : érodez les dépôts, brossez les détails."]
var preparation:Node3D
var selected:=-1
var compact_selected:=0
var pending_compact:=0
var compact_bar:HBoxContainer
var compact_buttons:Array[Button]=[]
var busy:=false
var buttons:Array[Button]=[]
var hint:Label
var confirmation:Control
var pending:=-1
var loading:Label
func _ready() -> void:
 var layer:=CanvasLayer.new();layer.layer=18;add_child(layer)
 var bar:=HBoxContainer.new();bar.position=Vector2(470,16);bar.add_theme_constant_override("separation",8);layer.add_child(bar)
 var style=preload("res://scripts/workshop/playtest_preparation_ui.gd")
 for i in range(3):
  var button:=Button.new();button.text=TITLES[i];button.focus_mode=Control.FOCUS_NONE;button.custom_minimum_size=Vector2(245,42)
  button.add_theme_font_size_override("font_size",18)
  button.add_theme_color_override("font_color",style.INK)
  button.add_theme_stylebox_override("normal",style.paper_style(style.PAPER,8))
  button.pressed.connect(choose.bind(i));bar.add_child(button);buttons.append(button)
 var reset:=Button.new();reset.text="Recommencer";reset.focus_mode=Control.FOCUS_NONE;reset.custom_minimum_size=Vector2(155,42);bar.add_child(reset)
 reset.pressed.connect(func():choose(selected,true))
 _compact_selector(layer,style)
 hint=Label.new();hint.position=Vector2(360,962);hint.size=Vector2(1200,30);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 hint.add_theme_font_size_override("font_size",18);hint.add_theme_color_override("font_color",Color(.91,.83,.66))
 hint.add_theme_color_override("font_shadow_color",Color(0,0,0,.9));hint.add_theme_constant_override("shadow_offset_y",2);layer.add_child(hint)
 loading=Label.new();loading.text="Préparation du bloc…";loading.position=Vector2(800,500);loading.add_theme_font_size_override("font_size",30);layer.add_child(loading)
 confirmation=preload("res://scripts/experiments/preparation_demos/demo_confirmation.gd").new()
 layer.add_child(confirmation)
 confirmation.confirmed.connect(func():open_demo(pending,pending_compact))
 await open_demo(0)
func choose(index:int,restart:=false,compact:int=-1) -> void:
 var choice:=compact_selected if compact<0 else posmod(compact,3)
 if busy or (index==selected and not restart and choice==compact_selected):return
 pending=index;pending_compact=choice
 if is_instance_valid(preparation) and not preparation.session.archived:
  preparation.controller.cancel_stroke();confirmation.popup_centered(Vector2i(540,160))
 else:open_demo(index,choice)
func open_demo(index:int,compact:int=-1) -> void:
 if busy:return
 busy=true;loading.show()
 if compact>=0:compact_selected=posmod(compact,3)
 for button in compact_buttons:button.disabled=true
 for button in buttons:button.disabled=true
 if is_instance_valid(preparation):
  remove_child(preparation);preparation.queue_free()
 await get_tree().process_frame
 preparation=load("res://scenes/experiments/demo_preparation.tscn").instantiate()
 preparation.compact_variant=compact_selected
 preparation.demo_kind=index;preparation.specimen_id="B17" if index==0 else "M08"
 var block=preparation.get_node("ExcavationBlock");block.demo_kind=index;block.specimen_id=preparation.specimen_id
 add_child(preparation)
 selected=index
 preparation.restart_requested.connect(func():choose(selected,true))
 preparation.collection_requested.connect(func():choose((selected+1)%3))
 preparation.controller.ui_blockers.append(confirmation)
 preparation.controller.finishing_modal=confirmation
 for button in buttons:preparation.controller.ui_blockers.append(button)
 preparation.controller.ui_blockers.append(buttons[0].get_parent().get_child(3))
 for button in compact_buttons:preparation.controller.ui_blockers.append(button)
 compact_bar.visible=index==0
 for i in range(compact_buttons.size()):
  compact_buttons[i].disabled=false;compact_buttons[i].modulate=Color(1,.83,.55) if i==compact_selected else Color.WHITE
 hint.text=NOTES[index]
 for i in range(buttons.size()):
  buttons[i].disabled=false;buttons[i].modulate=Color(1,.83,.55) if i==index else Color.WHITE
 loading.hide();busy=false

func _compact_selector(layer:CanvasLayer,style:Script) -> void:
 compact_bar=HBoxContainer.new();compact_bar.position=Vector2(470,66)
 compact_bar.add_theme_constant_override("separation",8);layer.add_child(compact_bar)
 var names:=["A · Grande ouverture","B · Poches dispersées","C · Veine profonde"]
 for i in range(names.size()):
  var button:=Button.new();button.text=names[i];button.focus_mode=Control.FOCUS_NONE
  button.custom_minimum_size=Vector2(245,36);button.add_theme_font_size_override("font_size",16)
  button.add_theme_color_override("font_color",style.INK)
  button.add_theme_stylebox_override("normal",style.paper_style(style.PAPER,6))
  button.pressed.connect(choose.bind(0,false,i));compact_bar.add_child(button);compact_buttons.append(button)
