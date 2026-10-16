extends CanvasLayer
signal specimen_chosen(id:String)
signal resume_requested
const Catalog=preload("res://scripts/collection/catalog.gd")
const Style=preload("res://scripts/workshop/playtest_preparation_ui.gd")
var arrivals:Control
var gallery_root:Control
var gallery_resume:Button
var gallery_banner:Label
var root_control:Control
var store:RefCounted
var body:HBoxContainer
var title:Label
var subtitle:Label
var count_label:Label
var banner:Label
var resume_button:Button
var mode:="depot"
var current_id:=""
var current_archived:=false
var item_buttons:Dictionary={}
var photos:Dictionary={}
var style=Style.new()
var depot_button:Button
var gallery_button:Button
var viewer:Control
var view_close:Button
func label(parent:Node,text:String,font_size:int,heading:=false,color:=Color("463c2c")) -> Label:
 var out:=Label.new();out.text=text
 out.add_theme_font_override("font",style.heading_font if heading else style.body_font)
 out.add_theme_font_size_override("font_size",font_size)
 out.add_theme_color_override("font_color",color)
 out.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(out);return out
func button(parent:Node,text:String,action:Callable) -> Button:
 var out:=Button.new();out.text=text;out.focus_mode=Control.FOCUS_NONE
 style.style_button(out);out.add_theme_font_size_override("font_size",22)
 out.custom_minimum_size.y=52;out.pressed.connect(action);parent.add_child(out);return out
func setup(data:RefCounted) -> void:
 store=data;layer=20;add_child(style)
 root_control=Control.new();add_child(root_control)
 root_control.mouse_filter=Control.MOUSE_FILTER_IGNORE
 root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 gallery_root=Control.new();root_control.add_child(gallery_root)
 gallery_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var background:=ColorRect.new();gallery_root.add_child(background)
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 background.color=Color("342c23")
 var shader:=Shader.new()
 shader.code="shader_type canvas_item; void fragment(){vec2 p=UV;float grain=fract(sin(dot(FRAGCOORD.xy,vec2(12.9898,78.233)))*43758.5453);vec3 c=mix(vec3(.12,.105,.085),vec3(.25,.205,.15),1.0-distance(p,vec2(.5,.25))*.85);COLOR=vec4(c+(grain-.5)*.017,1.0);}"
 var mat:=ShaderMaterial.new();mat.shader=shader;background.material=mat
 var overline:=label(gallery_root,"MUSÉUM D’HISTOIRE NATURELLE     /     ATELIER DES COLLECTIONS",17,false,Color("cdbb96"))
 overline.position=Vector2(164,48)
 title=label(gallery_root,"Les arrivages",55,true,Style.PAPER);title.position=Vector2(160,82)
 subtitle=label(gallery_root,"Chaque caisse est une découverte à préparer.",23,false,Color("cdbb96"));subtitle.position=Vector2(164,158)
 count_label=label(gallery_root,"",22,false,Style.PAPER);count_label.position=Vector2(1480,62)
 var navigation:=HBoxContainer.new();gallery_root.add_child(navigation);navigation.position=Vector2(164,212);navigation.add_theme_constant_override("separation",12)
 depot_button=button(navigation,"Les arrivages",func():show_page("depot"))
 gallery_button=button(navigation,"Ma collection",func():show_page("gallery"))
 resume_button=button(gallery_root,"Retour à l’établi",func():resume_requested.emit())
 resume_button.position=Vector2(1505,212);resume_button.custom_minimum_size.x=250
 body=HBoxContainer.new();gallery_root.add_child(body);body.position=Vector2(164,294);body.size=Vector2(1592,628);body.add_theme_constant_override("separation",32)
 banner=label(gallery_root,"",23,false,Style.PAPER);banner.position=Vector2(164,947);banner.size=Vector2(1592,88);banner.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 gallery_resume=resume_button;gallery_banner=banner
 arrivals=preload("res://scripts/collection/arrivals/arrivals_view.gd").new();root_control.add_child(arrivals)
 arrivals.specimen_chosen.connect(func(id:String):specimen_chosen.emit(id))
 arrivals.collection_requested.connect(func():show_page("gallery"))
 arrivals.resume_requested.connect(func():resume_requested.emit())
 show_page("depot")
func show_page(page:String,message:="") -> void:
 mode=page;root_control.show()
 gallery_root.visible=page=="gallery";arrivals.visible=page=="depot"
 resume_button=arrivals.resume_button if page=="depot" else gallery_resume
 banner=arrivals.banner if page=="depot" else gallery_banner
 title.text="Les arrivages" if page=="depot" else "Votre collection"
 subtitle.text="Une provenance, quelques indices… à vous de faire apparaître le reste." if page=="depot" else "Les pièces que vous avez préparées, telles que vous les avez laissées."
 count_label.text="%d / 2 pièces conservées"%store.records.size()
 depot_button.disabled=page=="depot";gallery_button.disabled=page=="gallery"
 resume_button.visible=not current_id.is_empty() and not current_archived
 for child in body.get_children():body.remove_child(child);child.queue_free()
 item_buttons.clear();photos.clear()
 if page=="gallery":
  for id:String in Catalog.IDS:_item(id)
 else:
  arrivals.configure(store,current_id,current_archived)
  item_buttons=arrivals.item_buttons.duplicate()
 banner.text=message
 if banner.text.is_empty():
  if page=="depot":banner.text=""
  elif store.records.size()==2:banner.text="Deux découvertes réunies. Vous pouvez reprendre un exemplaire pour améliorer votre préparation."
  else:banner.text="Les emplacements vides attendent vos prochaines découvertes."
 if store.load_failed:banner.text="La collection enregistrée est illisible. Le fichier est préservé ; l’archivage est momentanément indisponible."
 elif store.recovered:banner.text="Collection récupérée depuis sa sauvegarde de secours."
func _item(id:String) -> void:
 var data:=Catalog.entry(id)
 var record:Dictionary=store.records.get(id,{})
 var paper:=PanelContainer.new();body.add_child(paper)
 paper.custom_minimum_size=Vector2(780,620);paper.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 paper.add_theme_stylebox_override("panel",Style.paper_style(Style.PAPER,28))
 var col:=VBoxContainer.new();paper.add_child(col);col.add_theme_constant_override("separation",14)
 label(col,"DÉPÔT MARIN  /  M–08" if id=="M08" else "DÉPÔT CONTINENTAL  /  B–17",15,false,Style.MUTED)
 var heading:String="Caisse "+data.code if mode=="depot" else (data.name if not record.is_empty() else "Une place à remplir")
 label(col,heading,35,true)
 if mode=="gallery" and not record.is_empty():
  var image:Image=Image.load_from_file(store.photo_path(record)) if FileAccess.file_exists(store.photo_path(record)) else null
  if image!=null and not image.is_empty():
   var frame:=TextureRect.new();frame.texture=ImageTexture.create_from_image(image);frame.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;frame.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
   frame.custom_minimum_size=Vector2(700,270);col.add_child(frame);photos[id]=frame
   frame.tooltip_text="Regarder votre préparation en détail"
   frame.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
   frame.mouse_filter=Control.MOUSE_FILTER_STOP
   frame.gui_input.connect(func(event:InputEvent):
    if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
     examine(id);frame.accept_event())
  else:
   var missing:=label(col,"Photographie indisponible
Le relevé de préparation est conservé.",23,false,Style.MUTED);missing.custom_minimum_size.y=270
 else:
  var art=preload("res://scripts/collection/crate_art.gd").new();art.code=data.code;art.compact=id=="M08";art.empty=mode=="gallery";art.custom_minimum_size=Vector2(700,270);col.add_child(art)
 var details:String=data.provenance
 if mode=="gallery" and not record.is_empty():
  var s:Dictionary=record.snapshot
  details="État %d / 100   ·   Dégagé %d %%   ·   Nettoyé %d %%"%[roundi(s.condition),preload("res://scripts/preparation/readability/mastery_ui.gd").display_percent(s.exposure,true),preload("res://scripts/preparation/readability/mastery_ui.gd").display_percent(s.cleanliness,true)]
 label(col,details,20,false,Style.MUTED)
 var note:String=data.note if mode=="depot" else ("Le meilleur état est conservé lors de vos prochains essais." if not record.is_empty() else "Préparez ce spécimen pour lui donner une place ici.")
 if store.badge(id):note="✦ Préparation intégrale obtenue · 100 / 100"+("
Distinction de votre ancienne préparation conservée." if record.is_empty() else "")
 var description:=label(col,note,21,false,Style.GREEN if store.badge(id) else Style.INK);description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;description.custom_minimum_size.y=64;description.size_flags_vertical=Control.SIZE_EXPAND_FILL
 var action:String="Ouvrir la caisse "+data.code if record.is_empty() else "Préparer un nouvel exemplaire"
 if current_id==id and not current_archived:action="Reprendre ma préparation"
 item_buttons[id]=button(col,action,func():specimen_chosen.emit(id))

func examine(id:String) -> void:
 if viewer!=null or not store.records.has(id):return
 var record:Dictionary=store.records[id]
 if not FileAccess.file_exists(store.photo_path(record)):return
 var image:=Image.load_from_file(store.photo_path(record))
 if image==null or image.is_empty():return
 var overlay:=ColorRect.new();viewer=overlay;root_control.add_child(overlay)
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);overlay.color=Color(.07,.055,.035,1)
 var data:=Catalog.entry(id)
 var name_label:=label(overlay,data.name,47,true,Style.PAPER);name_label.position=Vector2(130,70)
 var details_label:=label(overlay,"Votre préparation conservée · "+data.code,22,false,Color("cdbb96"));details_label.position=Vector2(132,137)
 var frame:=TextureRect.new();overlay.add_child(frame)
 frame.texture=ImageTexture.create_from_image(image);frame.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;frame.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 frame.position=Vector2(130,210);frame.size=Vector2(1300,750)
 var column:=VBoxContainer.new();overlay.add_child(column);column.position=Vector2(1480,300);column.size=Vector2(310,600);column.add_theme_constant_override("separation",22)
 label(column,"Relevé de préparation",27,true,Style.PAPER)
 var values:Dictionary=record.snapshot
 label(column,"État     %d / 100"%roundi(values.condition),24,false,Style.PAPER)
 label(column,"Dégagé     %d %%"%preload("res://scripts/preparation/readability/mastery_ui.gd").display_percent(values.exposure,true),24,false,Style.PAPER)
 label(column,"Nettoyé     %d %%"%preload("res://scripts/preparation/readability/mastery_ui.gd").display_percent(values.cleanliness,true),24,false,Style.PAPER)
 if store.badge(id):
  var distinction:=label(column,"✦ Préparation intégrale
Distinction obtenue",23,false,Color("d1b37b"));distinction.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var caption:=label(column,"La photographie garde la matrice, les traces et l’état de votre pièce.",21,false,Color("cdbb96"));caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 view_close=button(overlay,"Retour à la collection · Échap",close_viewer);view_close.position=Vector2(1410,80);view_close.custom_minimum_size.x=380
func close_viewer() -> void:
 if viewer==null:return
 viewer.queue_free();viewer=null
func _input(event:InputEvent) -> void:
 if viewer!=null and event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE:
  close_viewer();get_viewport().set_input_as_handled()
