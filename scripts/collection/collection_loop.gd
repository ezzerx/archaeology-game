extends Node
const Catalog=preload("res://scripts/collection/catalog.gd")
var store:RefCounted
var hub:CanvasLayer
var preparation:Node3D
var busy:=false
var saved_archive:=false
var captured_photo:Image
var canvas_states:Array=[]
var confirmation:CanvasLayer
var confirm_button:Button
var cancel_button:Button
var loading:Label
var display_manager:Node
var pocket_introduction_seen:=false
func _ready() -> void:
 display_manager=preload("res://scripts/workshop/playtest_display.gd").new();add_child(display_manager);display_manager.setup(null);display_manager.set_process_input(false)
 var storage:="user://collection/records.json"
 var legacy:="user://preparation_distinctions.json"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--collection-store="):storage=arg.trim_prefix("--collection-store=")
  if arg.begins_with("--distinction-store="):legacy=arg.trim_prefix("--distinction-store=")
 store=preload("res://scripts/collection/collection_store.gd").new(storage,legacy)
 hub=preload("res://scripts/collection/collection_hub.gd").new();add_child(hub);hub.setup(store)
 hub.specimen_chosen.connect(choose_specimen)
 hub.resume_requested.connect(resume)
 loading=hub.label(hub.root_control,"",28,true,Color("f2e6ce"))
 loading.position=Vector2(620,985);loading.size=Vector2(1100,60)
 get_window().title="ArchaeologyGame — Atelier des collections"
func choose_specimen(id:String) -> void:
 if busy or not id in Catalog.IDS:return
 if preparation!=null and not preparation.session.archived:
  if preparation.specimen_id==id:resume();return
  confirm_change("Ouvrir une autre caisse ?","La préparation en cours sera laissée de côté.
Seules les pièces ajoutées à la collection sont enregistrées.",func():open_specimen(id))
  return
 if preparation!=null and preparation.session.archived and not saved_archive:
  hub.banner.text="L’enregistrement n’est pas terminé. Retournez à l’établi pour réessayer."
  hub.resume_button.show();return
 open_specimen(id)
func confirm_change(title:String,message:String,action:Callable) -> void:
 if confirmation!=null:return
 confirmation=CanvasLayer.new();confirmation.layer=30;add_child(confirmation)
 var bg:=ColorRect.new();confirmation.add_child(bg);bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.color=Color(0,0,0,.7)
 var center:=CenterContainer.new();bg.add_child(center);center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var paper:=PanelContainer.new();center.add_child(paper);paper.custom_minimum_size=Vector2(720,0);paper.add_theme_stylebox_override("panel",preload("res://scripts/workshop/playtest_preparation_ui.gd").paper_style())
 var col:=VBoxContainer.new();paper.add_child(col);col.add_theme_constant_override("separation",24)
 hub.label(col,title,35,true)
 hub.label(col,message,23)
 confirm_button=hub.button(col,"Ouvrir la nouvelle caisse",func():close_confirmation();action.call())
 cancel_button=hub.button(col,"Garder ma préparation",close_confirmation)
func close_confirmation() -> void:
 if confirmation==null:return
 confirmation.queue_free();confirmation=null
func open_specimen(id:String) -> void:
 if busy:return
 busy=true
 hub.root_control.show();hub.show_page("depot")
 hub.banner.text="Installation de la caisse "+Catalog.entry(id).code+" à l’établi…"
 for btn:Button in hub.item_buttons.values():btn.disabled=true
 loading.text="Préparation de l’établi…"
 await get_tree().process_frame
 await get_tree().process_frame
 if preparation!=null:
  pocket_introduction_seen=pocket_introduction_seen or preparation.introduction_seen
  display_manager.windowed_size=preparation.display.windowed_size
  display_manager.windowed_position=preparation.display.windowed_position
  remove_child(preparation);preparation.free();preparation=null
 canvas_states.clear();captured_photo=null;saved_archive=false
 var scene:=load("res://scenes/specimen_preparation.tscn") as PackedScene
 preparation=scene.instantiate()
 preparation.specimen_id=id
 preparation.get_node("ExcavationBlock").specimen_id=id
 add_child(preparation)
 preparation.display.windowed_size=display_manager.windowed_size
 preparation.display.windowed_position=display_manager.windowed_position
 preparation.introduction_seen=pocket_introduction_seen
 var trial:int=int(store.records.get(id,{}).get("attempts",0))%5
 if trial>0:preparation.select_pocket_variant(trial)
 preparation.collection_requested.connect(func():show_hub("gallery"))
 preparation.restart_requested.connect(_request_restart)
 preparation.session.archive_created.connect(_archive)
 for connection in preparation.session_ui.another_button.pressed.get_connections():preparation.session_ui.another_button.pressed.disconnect(connection.callable)
 preparation.session_ui.another_button.pressed.connect(_after_archive)
 hub.current_id=id;hub.current_archived=false
 hub.root_control.hide();loading.text="";busy=false
 preparation.session.notice.emit(""+Catalog.entry(id).code+" · Chisel pour dégrossir, Pick près du fossile, Brush pour finir")
func _request_restart() -> void:
 if busy:return
 show_hub("depot")
 confirm_change("Recommencer cette préparation ?","Le bloc en cours sera remplacé par un nouvel exemplaire.
Votre collection reste conservée.",func():open_specimen(preparation.specimen_id))
func _pause_preparation() -> void:
 if preparation==null:return
 preparation.controller.cancel_stroke()
 preparation.process_mode=Node.PROCESS_MODE_DISABLED
 if canvas_states.is_empty():
  for canvas:CanvasLayer in preparation.find_children("*","CanvasLayer",true,false):
   canvas_states.append([canvas,canvas.visible]);canvas.hide()
func resume() -> void:
 if busy or preparation==null or confirmation!=null:return
 for pair in canvas_states:
  if is_instance_valid(pair[0]):pair[0].visible=pair[1]
 canvas_states.clear()
 preparation.process_mode=Node.PROCESS_MODE_INHERIT
 preparation.controller.cancel_stroke()
 hub.root_control.hide()
func show_hub(page:="gallery",message:="") -> void:
 if busy:return
 _pause_preparation()
 hub.current_archived=preparation!=null and preparation.session.archived
 hub.show_page(page,message)
 hub.resume_button.visible=preparation!=null and (not preparation.session.archived or not saved_archive)
func _after_archive() -> void:
 if busy:return
 if not saved_archive:
  _archive(preparation.session.archive_snapshot);return
 var other:String="B17" if preparation.specimen_id=="M08" else "M08"
 var message:String="La pièce rejoint votre collection. La caisse "+Catalog.entry(other).code+" vous attend."
 if store.records.size()==2:message="Les deux pièces sont réunies. Chaque préparation garde votre travail et vos distinctions."
 show_hub("gallery",message)
func _archive(_snapshot:Dictionary) -> void:
 if busy or preparation==null:return
 busy=true
 var ui=preparation.session_ui
 ui.another_button.disabled=true;ui.another_button.text="Enregistrement de votre préparation…"
 preparation.controller.cancel_stroke();preparation.controller.set_physics_process(false)
 if captured_photo==null:captured_photo=await _photograph()
 var result:Dictionary=store.archive(preparation.specimen_id,preparation.session.archive_snapshot,captured_photo)
 saved_archive=result.ok
 ui.another_button.disabled=false
 if saved_archive:
  ui.another_button.text="Voir ma collection"
  ui.card_subtitle.text="Votre préparation est enregistrée." if result.improved else "Votre pièce précédente, mieux préservée, reste exposée."
 else:
  ui.another_button.text="Réessayer l’enregistrement"
  ui.card_subtitle.text="Enregistrement impossible ("+error_string(result.error)+").
Votre préparation reste ouverte."
 busy=false
func _photograph() -> Image:
 var saved_camera:Transform3D=preparation.camera.global_transform
 var saved_size:float=preparation.camera.size
 var target:float=preparation.camera.target_zoom
 preparation.camera.reset_view();preparation.camera.set_process(false)
 var field:FossilField=preparation.block.working_map.fossil.field
 var low:=Vector3(INF,INF,INF);var high:=Vector3(-INF,-INF,-INF)
 for i in range(field.component_ids.size()):
  if field.component_ids[i]==0:continue
  @warning_ignore("integer_division")
  var uv:Vector2=(Vector2(i%field.size.x,i/field.size.x)+Vector2(.5,.5))/Vector2(field.size)
  var p:Vector2=(uv-Vector2(.5,.5))*preparation.block.surface_size
  var point:=Vector3(p.x,.018+field.ceilings[i]*.102,p.y)
  low=low.min(point);high=high.max(point)
 var centre:Vector3=(low+high)*.5
 preparation.camera.global_position+=preparation.block.to_global(centre)-preparation.block.to_global(Vector3(0,preparation.block.thickness,0))
 var viewport_size:Vector2=get_viewport().get_visible_rect().size
 preparation.camera.size=maxf((high.z-low.z)*1.4,(high.x-low.x)*viewport_size.y/viewport_size.x*1.4)+.03
 var canvases:Array=[]
 for canvas:CanvasLayer in preparation.find_children("*","CanvasLayer",true,false):
  canvases.append([canvas,canvas.visible]);canvas.hide()
 preparation.block.show_cursor({"inside":false},1)
 var proxies:Array=[]
 var proxy_enabled:bool=preparation.feedback.proxies_enabled
 preparation.feedback.proxies_enabled=false
 for proxy in preparation.feedback.proxies:
  proxies.append([proxy,proxy.visible]);proxy.hide()
 # Let the final brush/debris gesture settle; capture the real matrix and damage.
 for frame in range(55):await get_tree().process_frame
 await RenderingServer.frame_post_draw
 var image:=get_viewport().get_texture().get_image()
 var rect:=Rect2();var first:=true
 for i in range(field.component_ids.size()):
  if field.component_ids[i]==0:continue
  @warning_ignore("integer_division")
  var uv:Vector2=(Vector2(i%field.size.x,i/field.size.x)+Vector2(.5,.5))/Vector2(field.size)
  var p:Vector2=(uv-Vector2(.5,.5))*preparation.block.surface_size
  var screen:Vector2=preparation.camera.unproject_position(preparation.block.to_global(Vector3(p.x,.018+field.ceilings[i]*.102,p.y)))
  if first:rect=Rect2(screen,Vector2.ONE);first=false
  else:rect=rect.expand(screen)
 var render_scale:Vector2=Vector2(image.get_size())/get_viewport().get_visible_rect().size
 rect=Rect2(rect.position*render_scale,rect.size*render_scale)
 rect=rect.grow(32).intersection(Rect2(Vector2.ZERO,Vector2(image.get_size())))
 var cropped:=image.get_region(Rect2i(rect))
 if cropped.get_width()>1400:cropped.resize(1400,roundi(1400.0*cropped.get_height()/cropped.get_width()),Image.INTERPOLATE_LANCZOS)
 for pair in canvases:pair[0].visible=pair[1]
 for pair in proxies:pair[0].visible=pair[1]
 preparation.feedback.proxies_enabled=proxy_enabled
 preparation.camera.global_transform=saved_camera;preparation.camera.size=saved_size;preparation.camera.target_zoom=target;preparation.camera.set_process(true)
 return cropped
func _input(event:InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and event.physical_keycode==KEY_ENTER and hub.root_control.visible:
  if preparation!=null:preparation.display.toggle_fullscreen()
  else:display_manager.toggle_fullscreen()
  get_viewport().set_input_as_handled();return
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_ESCAPE:
  if confirmation!=null:close_confirmation()
  elif hub.root_control.visible:resume()
  else:show_hub("gallery")
  get_viewport().set_input_as_handled()
