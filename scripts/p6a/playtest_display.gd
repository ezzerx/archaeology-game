extends Node
## Native-resolution 3D + scalable canvas, isolated to the Hero scene.
const SETTINGS := "user://p6a2_display.cfg"
var windowed_size := Vector2i(1600,900)
var windowed_position := Vector2i.ZERO
var fullscreen_button: Button
var controller: ToolController
var persist := true

func setup(input: ToolController) -> void:
	controller = input
	persist = not "--qa" in OS.get_cmdline_user_args()
	var window := get_window()
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.content_scale_size = Vector2i(1920,1080)
	# Keep a stable 16:9 working view on other aspect ratios; no cropped tools.
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	window.min_size = Vector2i(960,540)
	if not persist: return
	var settings := ConfigFile.new()
	settings.load(SETTINGS)
	var available := DisplayServer.screen_get_usable_rect(window.current_screen)
	windowed_size = settings.get_value("display","window_size",Vector2i(1600,900))
	windowed_size = windowed_size.clamp(Vector2i(960,540),available.size)
	window.size = windowed_size
	window.position = available.position+(available.size-windowed_size)/2
	if settings.get_value("display","fullscreen",false): set_fullscreen(true)

func set_fullscreen(enabled: bool) -> void:
	var window := get_window()
	controller.cancel_stroke()
	if enabled:
		windowed_size = window.size
		windowed_position = window.position
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		window.size = windowed_size
		window.position = windowed_position
	if fullscreen_button: fullscreen_button.text = "Window · Alt+Enter" if enabled else "Fullscreen · Alt+Enter"
	if persist:
		var settings := ConfigFile.new()
		settings.set_value("display","fullscreen",enabled)
		settings.set_value("display","window_size",windowed_size)
		settings.save(SETTINGS)

func toggle_fullscreen() -> void:
	set_fullscreen(get_window().mode != Window.MODE_FULLSCREEN)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.alt_pressed and event.physical_keycode == KEY_ENTER:
			toggle_fullscreen()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_ESCAPE and get_window().mode == Window.MODE_FULLSCREEN:
			set_fullscreen(false)
			get_viewport().set_input_as_handled()
