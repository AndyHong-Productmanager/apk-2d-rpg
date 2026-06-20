extends Control

const INK := Color("#151820")
const PAPER := Color("#F2F0E6")
const PANEL := Color("#202633")
const ENERGY := Color("#35A7D8")
const SUCCESS := Color("#56B870")
const WARNING := Color("#E5A137")
const STATUS := Color("#8E56C5")

@export var initial_route := "title"

var _app_state: Node
var _save_manager: Node
var _settings_manager: Node
var _content: VBoxContainer


func _ready() -> void:
	_app_state = get_node("/root/AppState")
	_save_manager = get_node("/root/SaveManager")
	_settings_manager = get_node("/root/SettingsManager")
	_app_state.route_changed.connect(_render)
	_build_frame()
	_app_state.go_to(initial_route)


func start_new_run() -> void:
	_app_state.start_new_run()


func finish_intro() -> void:
	_app_state.finish_intro()


func pause_game() -> void:
	_app_state.pause_game()


func resume_game() -> void:
	_app_state.resume_game()


func open_settings() -> void:
	_app_state.go_to("settings")


func open_credits() -> void:
	_app_state.go_to("credits")


func return_to_title() -> void:
	_app_state.go_to("title")


func save_game() -> bool:
	var payload: Dictionary = _save_manager.build_payload(_app_state.snapshot(), _settings_manager.snapshot())
	return bool(_save_manager.write_payload(payload).ok)


func continue_from_save() -> bool:
	var result: Dictionary = _save_manager.read_or_recover()
	if not bool(result.ok):
		return false
	var data: Dictionary = result.data
	_settings_manager.apply_snapshot(data.get("settings", {}))
	_app_state.apply_snapshot(data.get("app", {}))
	_app_state.continue_count += 1
	_app_state.go_to("gameplay")
	return true


func current_route() -> String:
	return String(_app_state.route)


func _build_frame() -> void:
	anchors_preset = Control.PRESET_FULL_RECT

	var background := ColorRect.new()
	background.name = "PaperBackground"
	background.color = INK
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.name = "SafeMargin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)

	_content = VBoxContainer.new()
	_content.name = "Content"
	_content.alignment = BoxContainer.ALIGNMENT_CENTER
	_content.add_theme_constant_override("separation", 24)
	margin.add_child(_content)


func _render(route: String) -> void:
	for child in _content.get_children():
		child.queue_free()

	match route:
		"title":
			_render_title()
		"intro":
			_render_intro()
		"gameplay":
			_render_gameplay()
		"paused":
			_render_pause()
		"settings":
			_render_settings()
		"credits":
			_render_credits()
		_:
			_render_title()


func _render_title() -> void:
	_add_heading("APK 2D RPG", ENERGY)
	_add_body("Shell route: title menu")
	_add_button("New Run", start_new_run)
	_add_button("Continue", continue_from_save)
	_add_button("Settings", open_settings)
	_add_button("Credits", open_credits)


func _render_intro() -> void:
	_add_heading("Intro", WARNING)
	_add_body("A quiet boot scene establishes the run before control begins.")
	_add_button("Begin", finish_intro)


func _render_gameplay() -> void:
	_add_heading("Gameplay Shell", SUCCESS)
	_add_body("Gameplay placeholder with no combat systems or imported assets.")
	_add_body("Ticks: %d" % int(_app_state.gameplay_ticks))
	_add_button("Save", save_game)
	_add_button("Pause", pause_game)


func _render_pause() -> void:
	_add_heading("Paused", PANEL)
	_add_body("Menu route reachable from gameplay.")
	_add_button("Continue", resume_game)
	_add_button("Save", save_game)
	_add_button("Title", return_to_title)


func _render_settings() -> void:
	_add_heading("Settings", STATUS)
	_add_body("Music %.0f%% / SFX %.0f%% / Text %s" % [
		float(_settings_manager.music_volume) * 100.0,
		float(_settings_manager.sfx_volume) * 100.0,
		String(_settings_manager.text_speed),
	])
	_add_button("Back", return_to_title)


func _render_credits() -> void:
	_add_heading("Credits", SUCCESS)
	_add_body("Credits route placeholder. Final credits remain in CREDITS.md.")
	_add_button("Back", return_to_title)


func _add_heading(text: String, accent: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", PAPER)
	label.add_theme_font_size_override("font_size", 56)
	_content.add_child(label)

	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(256, 8)
	rule.color = accent
	_content.add_child(rule)


func _add_body(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", PAPER)
	label.add_theme_font_size_override("font_size", 28)
	_content.add_child(label)


func _add_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(360, 88)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_font_size_override("font_size", 28)
	button.pressed.connect(callback)
	_content.add_child(button)
