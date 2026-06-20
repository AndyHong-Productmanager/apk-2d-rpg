extends Control

const INK := Color("#151820")
const PAPER := Color("#F2F0E6")
const PANEL := Color("#202633")
const HEALTH := Color("#D94444")
const ENERGY := Color("#35A7D8")
const SUCCESS := Color("#56B870")
const WARNING := Color("#E5A137")
const STATUS := Color("#8E56C5")
const RUNTIME_ASSETS := {
	"ui_skill_bash": "res://assets/diamond/runtime/ui_skill_bash.png",
	"ui_skill_whirlwind": "res://assets/diamond/runtime/ui_skill_whirlwind.png",
	"ui_skill_shield_block": "res://assets/diamond/runtime/ui_skill_shield_block.png",
	"icon_hp_potion": "res://assets/diamond/runtime/icon_hp_potion.png",
	"icon_mp_potion": "res://assets/diamond/runtime/icon_mp_potion.png",
	"icon_sack": "res://assets/diamond/runtime/icon_sack.png",
	"icon_broadsword": "res://assets/diamond/runtime/icon_broadsword.png",
	"icon_buckler": "res://assets/diamond/runtime/icon_buckler.png",
	"fx_fire": "res://assets/diamond/runtime/fx_fire.png",
}

@export var initial_route := "title"

var _app_state: Node
var _save_manager: Node
var _settings_manager: Node
var _content: Control
var _capture_state := ""
var _runtime_textures := {}


class VisualSurface:
	extends Control

	const INK := Color("#151820")
	const PAPER := Color("#F2F0E6")
	const PANEL := Color("#202633")
	const HEALTH := Color("#D94444")
	const ENERGY := Color("#35A7D8")
	const SUCCESS := Color("#56B870")
	const WARNING := Color("#E5A137")
	const STATUS := Color("#8E56C5")
	const RUNTIME_ASSETS := {
		"player_male": "res://assets/diamond/runtime/player_male.png",
		"player_female": "res://assets/diamond/runtime/player_female.png",
		"enemy_boar": "res://assets/diamond/runtime/enemy_boar.png",
		"fx_fire": "res://assets/diamond/runtime/fx_fire.png",
		"tile_grass": "res://assets/diamond/runtime/tile_grass.png",
		"tile_props": "res://assets/diamond/runtime/tile_props.png",
	}

	var state_name := "title"
	var _textures := {}

	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_load_runtime_textures()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		var screen := get_rect().size
		if screen.x <= 0.0 or screen.y <= 0.0:
			return
		_draw_world(screen)
		match state_name:
			"title":
				_draw_title_world(screen)
			"intro":
				_draw_intro_world(screen)
			"exploration", "dialogue", "inventory", "settings", "credits", "victory":
				_draw_exploration_world(screen)
			"combat", "combat-landscape":
				_draw_combat_world(screen, false)
			"boss":
				_draw_combat_world(screen, true)
			_:
				_draw_exploration_world(screen)

	func _draw_world(screen: Vector2) -> void:
		draw_rect(Rect2(Vector2.ZERO, screen), INK)
		var tile := 96.0 if screen.y >= screen.x else 88.0
		_draw_grass_tiles(screen, tile)
		var floor_a := INK.lerp(PANEL, 0.52)
		var floor_b := INK.lerp(PANEL, 0.70)
		for y in range(-1, int(ceil(screen.y / tile)) + 1):
			for x in range(-1, int(ceil(screen.x / tile)) + 1):
				var color := floor_a if (x + y) % 2 == 0 else floor_b
				draw_rect(Rect2(Vector2(x * tile, y * tile), Vector2(tile - 2.0, tile - 2.0)), color, false, 1.0)
		for x in range(0, int(screen.x), int(tile * 2.0)):
			draw_rect(Rect2(Vector2(x + tile * 0.42, 0.0), Vector2(8.0, screen.y)), WARNING.darkened(0.58))
		var rail_y := screen.y * (0.28 if screen.y >= screen.x else 0.22)
		draw_rect(Rect2(Vector2(0.0, rail_y), Vector2(screen.x, 20.0)), PANEL.lightened(0.10))
		draw_rect(Rect2(Vector2(0.0, rail_y + 44.0), Vector2(screen.x, 16.0)), PANEL.darkened(0.10))

	func _draw_title_world(screen: Vector2) -> void:
		_draw_exploration_world(screen)
		var arch := Rect2(Vector2(screen.x * 0.13, screen.y * 0.17), Vector2(screen.x * 0.74, screen.y * 0.31))
		draw_rect(arch, PANEL.darkened(0.08))
		draw_rect(arch.grow(-10.0), INK.lerp(PANEL, 0.82))
		for i in range(5):
			var gem := Vector2(arch.position.x + 105.0 + float(i) * 155.0, arch.position.y + 78.0 + float(i % 2) * 36.0)
			_draw_diamond(gem, 34.0, ENERGY.lerp(PAPER, 0.22))
		_draw_actor(Vector2(screen.x * 0.47, screen.y * 0.55), 1.32, SUCCESS, true)
		_draw_companion(Vector2(screen.x * 0.57, screen.y * 0.57), 1.08, STATUS)

	func _draw_intro_world(screen: Vector2) -> void:
		_draw_exploration_world(screen)
		var gate := Rect2(Vector2(screen.x * 0.18, screen.y * 0.20), Vector2(screen.x * 0.64, screen.y * 0.32))
		draw_rect(gate, PANEL.darkened(0.12))
		draw_rect(gate.grow(-14.0), INK.lerp(ENERGY, 0.18))
		_draw_diamond(gate.get_center(), min(screen.x, screen.y) * 0.055, WARNING)
		_draw_actor(Vector2(screen.x * 0.40, screen.y * 0.61), 1.22, SUCCESS, true)
		_draw_companion(Vector2(screen.x * 0.61, screen.y * 0.60), 1.06, ENERGY)

	func _draw_exploration_world(screen: Vector2) -> void:
		var lane_w := screen.x * 0.60
		var lane_x := (screen.x - lane_w) * 0.5
		draw_rect(Rect2(Vector2(lane_x, screen.y * 0.15), Vector2(lane_w, screen.y * 0.66)), PANEL.darkened(0.15), false, 6.0)
		_draw_vendor(Vector2(screen.x * 0.30, screen.y * 0.36), WARNING)
		_draw_terminal(Vector2(screen.x * 0.68, screen.y * 0.33))
		_draw_crates(Vector2(screen.x * 0.23, screen.y * 0.64), screen.x >= screen.y)
		_draw_diamond(Vector2(screen.x * 0.76, screen.y * 0.58), 28.0, ENERGY)
		_draw_actor(Vector2(screen.x * 0.50, screen.y * 0.58), 1.28, SUCCESS, true)
		_draw_companion(Vector2(screen.x * 0.61, screen.y * 0.48), 0.96, STATUS)

	func _draw_combat_world(screen: Vector2, boss: bool) -> void:
		var center := Vector2(screen.x * 0.50, screen.y * (0.49 if screen.y >= screen.x else 0.55))
		var radius: float = min(screen.x, screen.y) * (0.34 if boss else 0.28)
		draw_circle(center, radius, PANEL.darkened(0.12))
		draw_arc(center, radius, 0.0, TAU, 96, WARNING, 8.0)
		draw_arc(center, radius * 0.70, 0.0, TAU, 96, STATUS.darkened(0.15), 4.0)
		_draw_actor(center + Vector2(-radius * 0.38, radius * 0.38), 1.22, SUCCESS, true)
		if boss:
			_draw_boss(center + Vector2(radius * 0.14, -radius * 0.10), radius * 0.38)
			_draw_ring(center + Vector2(radius * 0.15, radius * 0.03), radius * 0.54, HEALTH)
			_draw_lane(center + Vector2(-radius * 0.72, -radius * 0.42), center + Vector2(radius * 0.78, radius * 0.36), HEALTH)
		else:
			_draw_enemy(center + Vector2(radius * 0.24, -radius * 0.18), 1.12, HEALTH)
			_draw_enemy(center + Vector2(radius * 0.50, radius * 0.20), 0.92, STATUS)
			_draw_ring(center + Vector2(radius * 0.32, -radius * 0.12), radius * 0.30, WARNING)
			_draw_lane(center + Vector2(-radius * 0.15, radius * 0.58), center + Vector2(radius * 0.65, -radius * 0.28), HEALTH)
			draw_arc(center + Vector2(-radius * 0.30, radius * 0.25), radius * 0.20, -0.6, 1.1, 24, ENERGY, 10.0)

	func _draw_actor(pos: Vector2, scale: float, accent: Color, player: bool) -> void:
		if _draw_character_sprite("player_male", pos, scale, 0, 0):
			if player:
				_draw_diamond(pos + Vector2(0.0, -36.0 * scale), 10.0 * scale, ENERGY)
			return
		var px := 28.0 * scale
		draw_circle(pos + Vector2(0.0, -px * 1.50), px * 0.54, PAPER if player else accent.lightened(0.25))
		draw_rect(Rect2(pos + Vector2(-px * 0.62, -px * 1.0), Vector2(px * 1.24, px * 1.72)), accent)
		draw_rect(Rect2(pos + Vector2(-px * 0.36, px * 0.72), Vector2(px * 0.26, px * 0.82)), PANEL.darkened(0.25))
		draw_rect(Rect2(pos + Vector2(px * 0.10, px * 0.72), Vector2(px * 0.26, px * 0.82)), PANEL.darkened(0.25))
		draw_rect(Rect2(pos + Vector2(-px * 1.0, -px * 0.82), Vector2(px * 0.38, px * 1.10)), accent.darkened(0.20))
		draw_rect(Rect2(pos + Vector2(px * 0.62, -px * 0.82), Vector2(px * 0.38, px * 1.10)), accent.darkened(0.20))
		if player:
			_draw_diamond(pos + Vector2(0.0, -px * 0.32), px * 0.28, ENERGY)

	func _draw_companion(pos: Vector2, scale: float, accent: Color) -> void:
		if _draw_character_sprite("player_female", pos, scale, 0, 0):
			return
		_draw_actor(pos, scale, accent, false)

	func _draw_enemy(pos: Vector2, scale: float, accent: Color) -> void:
		if _draw_character_sprite("enemy_boar", pos, scale, 1, 0):
			return
		var px := 34.0 * scale
		draw_circle(pos + Vector2(0.0, -px * 0.8), px * 0.70, accent.darkened(0.12))
		draw_rect(Rect2(pos + Vector2(-px * 0.80, -px * 0.4), Vector2(px * 1.60, px * 1.35)), accent)
		draw_rect(Rect2(pos + Vector2(-px * 0.34, -px * 0.96), Vector2(px * 0.22, px * 0.26)), PAPER)
		draw_rect(Rect2(pos + Vector2(px * 0.12, -px * 0.96), Vector2(px * 0.22, px * 0.26)), PAPER)
		draw_rect(Rect2(pos + Vector2(-px * 1.10, px * 0.0), Vector2(px * 0.30, px * 0.92)), accent.darkened(0.28))
		draw_rect(Rect2(pos + Vector2(px * 0.80, px * 0.0), Vector2(px * 0.30, px * 0.92)), accent.darkened(0.28))

	func _draw_boss(pos: Vector2, radius: float) -> void:
		draw_circle(pos, radius, STATUS.darkened(0.18))
		_draw_character_sprite("enemy_boar", pos + Vector2(0.0, -radius * 0.08), radius / 170.0, 1, 0)
		_draw_character_sprite("enemy_boar", pos + Vector2(-radius * 0.55, radius * 0.18), radius / 250.0, 0, 0)
		_draw_character_sprite("enemy_boar", pos + Vector2(radius * 0.55, radius * 0.18), radius / 250.0, 3, 0)
		draw_circle(pos + Vector2(0.0, -radius * 0.44), radius * 0.62, PANEL.lightened(0.08))
		for i in range(8):
			var angle := float(i) * TAU / 8.0
			var arm := Vector2(cos(angle), sin(angle))
			_draw_lane(pos + arm * radius * 0.58, pos + arm * radius * 1.15, STATUS)
		_draw_diamond(pos + Vector2(0.0, -radius * 0.52), radius * 0.28, WARNING)

	func _draw_vendor(pos: Vector2, accent: Color) -> void:
		draw_rect(Rect2(pos + Vector2(-58.0, -38.0), Vector2(116.0, 76.0)), PANEL.lightened(0.08))
		draw_rect(Rect2(pos + Vector2(-72.0, -62.0), Vector2(144.0, 28.0)), accent)
		for i in range(3):
			draw_circle(pos + Vector2(-35.0 + float(i) * 35.0, 2.0), 12.0, PAPER)
		_draw_props_region(Rect2(224.0, 94.0, 78.0, 58.0), Rect2(pos + Vector2(-42.0, 32.0), Vector2(84.0, 62.0)))

	func _draw_terminal(pos: Vector2) -> void:
		draw_rect(Rect2(pos + Vector2(-46.0, -68.0), Vector2(92.0, 136.0)), PANEL.lightened(0.08))
		draw_rect(Rect2(pos + Vector2(-30.0, -48.0), Vector2(60.0, 44.0)), ENERGY.darkened(0.10))
		draw_rect(Rect2(pos + Vector2(-22.0, 22.0), Vector2(44.0, 10.0)), PAPER.darkened(0.15))
		draw_circle(pos + Vector2(0.0, 52.0), 9.0, SUCCESS)

	func _draw_crates(pos: Vector2, wide: bool) -> void:
		var count := 4 if wide else 3
		for i in range(count):
			var offset := Vector2(float(i % 2) * 64.0, float(i / 2) * 54.0)
			draw_rect(Rect2(pos + offset, Vector2(54.0, 46.0)), WARNING.darkened(0.18))
			draw_rect(Rect2(pos + offset + Vector2(8.0, 8.0), Vector2(38.0, 30.0)), PANEL.darkened(0.12), false, 3.0)
		_draw_props_region(Rect2(300.0, 164.0, 72.0, 54.0), Rect2(pos + Vector2(134.0, 24.0), Vector2(96.0, 72.0)))

	func _draw_diamond(pos: Vector2, radius: float, color: Color) -> void:
		var points := PackedVector2Array([
			pos + Vector2(0.0, -radius),
			pos + Vector2(radius * 0.78, 0.0),
			pos + Vector2(0.0, radius),
			pos + Vector2(-radius * 0.78, 0.0),
		])
		draw_colored_polygon(points, color)
		draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), PAPER, 3.0)

	func _draw_ring(pos: Vector2, radius: float, color: Color) -> void:
		draw_arc(pos, radius, 0.0, TAU, 96, color, 10.0)
		draw_circle(pos, radius * 0.10, color.lightened(0.12))

	func _draw_lane(a: Vector2, b: Vector2, color: Color) -> void:
		draw_line(a, b, color, 18.0)
		draw_line(a, b, PAPER.darkened(0.15), 4.0)

	func _load_runtime_textures() -> void:
		for key in RUNTIME_ASSETS.keys():
			var image := Image.new()
			if image.load(String(RUNTIME_ASSETS[key])) == OK:
				_textures[key] = ImageTexture.create_from_image(image)

	func _draw_grass_tiles(screen: Vector2, tile: float) -> void:
		var texture: Texture2D = _textures.get("tile_grass")
		if texture == null:
			return
		var source := Rect2(Vector2(64.0, 0.0), Vector2(64.0, 64.0))
		for y in range(-1, int(ceil(screen.y / tile)) + 1):
			for x in range(-1, int(ceil(screen.x / tile)) + 1):
				var rect := Rect2(Vector2(x * tile, y * tile), Vector2(tile, tile))
				draw_texture_rect_region(texture, rect, source, Color(0.72, 0.92, 0.76, 0.84))

	func _draw_character_sprite(asset_key: String, foot_pos: Vector2, scale: float, col: int, row: int) -> bool:
		var texture: Texture2D = _textures.get(asset_key)
		if texture == null:
			return false
		var frame := Vector2(128.0, 128.0)
		var dest_size := Vector2(128.0, 128.0) * scale
		var dest := Rect2(foot_pos - Vector2(dest_size.x * 0.5, dest_size.y * 0.88), dest_size)
		var source := Rect2(Vector2(float(col) * frame.x, float(row) * frame.y), frame)
		draw_texture_rect_region(texture, dest, source)
		return true

	func _draw_props_region(source: Rect2, dest: Rect2) -> void:
		var texture: Texture2D = _textures.get("tile_props")
		if texture == null:
			return
		draw_texture_rect_region(texture, dest, source)


func _ready() -> void:
	_app_state = get_node("/root/AppState")
	_save_manager = get_node("/root/SaveManager")
	_settings_manager = get_node("/root/SettingsManager")
	_app_state.route_changed.connect(_render)
	_load_runtime_textures()
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


func show_capture_state(state_name: String) -> void:
	_capture_state = state_name
	_render_visual(state_name)


func _build_frame() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_content = Control.new()
	_content.name = "Content"
	_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_content)


func _render(route: String) -> void:
	if _capture_state != "":
		return
	match route:
		"title":
			_render_visual("title")
		"intro":
			_render_visual("intro")
		"gameplay":
			_render_visual("exploration")
		"paused":
			_render_visual("inventory")
		"settings":
			_render_visual("settings")
		"credits":
			_render_visual("credits")
		_:
			_render_visual("title")


func _render_visual(state_name: String) -> void:
	_clear_content()
	var screen := get_viewport_rect().size
	_content.position = Vector2.ZERO
	_content.size = screen
	var surface := VisualSurface.new()
	surface.name = "VisualSurface_%s" % state_name
	surface.state_name = state_name
	surface.position = Vector2.ZERO
	surface.size = screen
	_content.add_child(surface)
	_add_state_ui(state_name)
	surface.queue_redraw()


func _clear_content() -> void:
	for child in _content.get_children():
		_content.remove_child(child)
		child.free()


func _add_state_ui(state_name: String) -> void:
	var screen := get_viewport_rect().size
	var landscape := screen.x > screen.y
	match state_name:
		"title":
			_add_title_ui(screen)
		"intro":
			_add_top_hud(screen, "DEPOT RELAY", "SIGNAL LOST", false)
			_add_dialogue_panel(screen, "Mira", "The relay woke before the district did. Pick a rig, keep the center lane clear, and follow the blue beacons.")
			_add_touch_controls(screen, false)
		"exploration":
			_add_top_hud(screen, "MARKET OUTER RING", "Find the route key", false)
			_add_touch_controls(screen, false)
			_add_objective_chip(screen, "Talk", "Relay Mira", ENERGY)
		"dialogue":
			_add_top_hud(screen, "NEON REPAIR MARKET", "Patch Jun", false)
			_add_touch_controls(screen, false)
			_add_dialogue_panel(screen, "Patch Jun", "The convoy stall has a sentinel. Break posture first, then claim the east route key.")
		"combat":
			_add_top_hud(screen, "LANE SENTINEL", "Guard the rail sweep", true)
			_add_enemy_strip(screen, "Lane Sentinel", 0.62, false)
			_add_touch_controls(screen, true)
		"boss":
			_add_top_hud(screen, "VIGILANT MATRON", "Phase 2: clinic lockdown", true)
			_add_enemy_strip(screen, "Vigilant Matron", 0.46, true)
			_add_touch_controls(screen, true)
		"victory":
			_add_top_hud(screen, "CLINIC LOCKDOWN", "Echoes stabilized", false)
			_add_victory_panel(screen)
		"inventory":
			_add_top_hud(screen, "INVENTORY", "Gear tab", false)
			_add_inventory_panel(screen)
		"settings":
			_add_top_hud(screen, "SETTINGS", "Readable touch controls", false)
			_add_settings_panel(screen)
		"credits":
			_add_top_hud(screen, "CREDITS", "Asset proof retained", false)
			_add_credits_panel(screen)
		"combat-landscape":
			_add_top_hud(screen, "LANE SENTINEL", "Landscape combat capture", true)
			_add_enemy_strip(screen, "Lane Sentinel", 0.62, false)
			_add_touch_controls(screen, true)
			_add_landscape_prompt(screen)
		_:
			_add_top_hud(screen, "APK 2D RPG", "Ready", false)
	if not landscape and state_name not in ["title", "inventory", "settings", "credits", "victory"]:
		_add_bottom_safe_shadow(screen)


func _add_title_ui(screen: Vector2) -> void:
	_add_label("APK 2D RPG", Vector2(screen.x * 0.11, screen.y * 0.10), Vector2(screen.x * 0.78, 96.0), 64, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("Signal rigs against a corrupted city grid", Vector2(screen.x * 0.15, screen.y * 0.16), Vector2(screen.x * 0.70, 56.0), 30, PAPER.darkened(0.10), HORIZONTAL_ALIGNMENT_CENTER)
	var x := screen.x * 0.58
	var y := screen.y * 0.64
	_add_menu_button("New Run", Vector2(x, y), start_new_run)
	_add_menu_button("Continue", Vector2(x, y + 108.0), continue_from_save)
	_add_menu_button("Settings", Vector2(x, y + 216.0), open_settings)
	_add_menu_button("Credits", Vector2(x, y + 324.0), open_credits)


func _add_top_hud(screen: Vector2, location: String, objective: String, combat: bool) -> void:
	var hud := _add_panel("HUD", Vector2(24.0, 24.0), Vector2(screen.x - 48.0, 132.0), PANEL, PAPER.darkened(0.45))
	_add_label(location, hud.position + Vector2(24.0, 14.0), Vector2(screen.x * 0.50, 38.0), 27, PAPER, HORIZONTAL_ALIGNMENT_LEFT)
	_add_label(objective, hud.position + Vector2(screen.x * 0.52, 18.0), Vector2(screen.x * 0.40, 34.0), 23, PAPER.darkened(0.10), HORIZONTAL_ALIGNMENT_RIGHT)
	_add_bar(hud.position + Vector2(24.0, 72.0), Vector2(screen.x * 0.25, 22.0), HEALTH, 0.78)
	_add_bar(hud.position + Vector2(screen.x * 0.30, 72.0), Vector2(screen.x * 0.22, 22.0), ENERGY, 0.64)
	_add_bar(hud.position + Vector2(screen.x * 0.55, 72.0), Vector2(screen.x * 0.18, 22.0), SUCCESS, 0.52)
	if combat:
		_add_label("TELEGRAPH", hud.position + Vector2(screen.x * 0.77, 66.0), Vector2(screen.x * 0.18, 34.0), 20, WARNING, HORIZONTAL_ALIGNMENT_RIGHT)


func _add_enemy_strip(screen: Vector2, enemy_name: String, fill: float, boss: bool) -> void:
	var width := screen.x * (0.60 if screen.x > screen.y else 0.70)
	var pos := Vector2((screen.x - width) * 0.5, 180.0)
	_add_label(enemy_name, pos, Vector2(width, 34.0), 24 if not boss else 30, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	_add_bar(pos + Vector2(0.0, 42.0), Vector2(width, 24.0), HEALTH if not boss else STATUS, fill)
	_add_bar(pos + Vector2(width * 0.18, 76.0), Vector2(width * 0.64, 16.0), WARNING, 0.38 if not boss else 0.72)


func _add_touch_controls(screen: Vector2, combat: bool) -> void:
	var bottom := screen.y - 236.0
	var stick := _add_panel("MoveZone", Vector2(44.0, bottom), Vector2(196.0, 196.0), PANEL.darkened(0.02), ENERGY.darkened(0.15))
	var center := stick.position + stick.size * 0.5
	_add_round_button("Move", center - Vector2(54.0, 54.0), 108.0, ENERGY.darkened(0.25), PAPER)
	var labels := ["Dodge", "Guard", "Skill 1", "Skill 2", "Skill 3"] if combat else ["Map", "Talk", "Dodge"]
	var icons := ["", "ui_skill_shield_block", "ui_skill_bash", "ui_skill_whirlwind", "fx_fire"] if combat else ["icon_sack", "", ""]
	var start_x := screen.x - 112.0 * float(min(labels.size(), 3)) - 44.0
	for i in range(labels.size()):
		var row := int(i / 3)
		var col := i % 3
		var pos := Vector2(start_x + float(col) * 112.0, bottom + float(row) * 104.0)
		_add_round_button(labels[i], pos, 96.0, PANEL.lightened(0.08), PAPER, icons[i])


func _add_dialogue_panel(screen: Vector2, speaker: String, body: String) -> void:
	var height := 260.0
	var panel := _add_panel("Dialogue", Vector2(32.0, screen.y - height - 28.0), Vector2(screen.x - 64.0, height), PANEL, ENERGY.darkened(0.15))
	_add_label(speaker, panel.position + Vector2(24.0, 20.0), Vector2(panel.size.x - 48.0, 36.0), 30, ENERGY, HORIZONTAL_ALIGNMENT_LEFT)
	_add_label(body, panel.position + Vector2(24.0, 76.0), Vector2(panel.size.x - 48.0, 116.0), 29, PAPER, HORIZONTAL_ALIGNMENT_LEFT)
	_add_label("NEXT", panel.position + Vector2(panel.size.x - 154.0, panel.size.y - 66.0), Vector2(120.0, 44.0), 24, WARNING, HORIZONTAL_ALIGNMENT_RIGHT)


func _add_inventory_panel(screen: Vector2) -> void:
	var panel := _add_panel("InventoryPanel", Vector2(38.0, 188.0), Vector2(screen.x - 76.0, screen.y - 238.0), PANEL, PAPER.darkened(0.45))
	var tabs := ["Gear", "Consumables", "Shards", "Quest", "Archive"]
	for i in range(tabs.size()):
		var tab_color := ENERGY if i == 0 else PANEL.lightened(0.16)
		_add_chip(tabs[i], panel.position + Vector2(24.0 + float(i) * 184.0, 28.0), Vector2(164.0, 64.0), tab_color)
	var grid_origin := panel.position + Vector2(28.0, 128.0)
	var cell := Vector2(148.0, 148.0)
	var names := ["Brace", "Key", "Foam", "Shard", "Gel", "Needle", "Boot", "Core", "Plate", "Scrip"]
	for i in range(20):
		var col := i % 5
		var row := int(i / 5)
		var pos := grid_origin + Vector2(float(col) * (cell.x + 16.0), float(row) * (cell.y + 18.0))
		_add_item_cell(pos, cell, names[i % names.size()], i)
	var detail_x := grid_origin.x + 5.0 * (cell.x + 16.0) + 22.0
	if detail_x + 260.0 < panel.position.x + panel.size.x:
		_add_panel("ItemDetail", Vector2(detail_x, grid_origin.y), Vector2(260.0, 420.0), PANEL.lightened(0.08), WARNING.darkened(0.15))
		_add_label("Mender Brace Plate", Vector2(detail_x + 20.0, grid_origin.y + 20.0), Vector2(220.0, 70.0), 25, PAPER, HORIZONTAL_ALIGNMENT_LEFT)
		_add_label("+14 guard on brace\nRarity: clinic relic\nEquip", Vector2(detail_x + 20.0, grid_origin.y + 114.0), Vector2(220.0, 180.0), 22, PAPER.darkened(0.05), HORIZONTAL_ALIGNMENT_LEFT)


func _add_settings_panel(screen: Vector2) -> void:
	var panel := _add_panel("SettingsPanel", Vector2(72.0, 228.0), Vector2(screen.x - 144.0, screen.y - 340.0), PANEL, STATUS.darkened(0.15))
	var rows := [
		["Music", 0.72, ENERGY],
		["SFX", 0.58, WARNING],
		["Text Speed", 0.84, SUCCESS],
		["Contrast", 0.66, PAPER],
	]
	for i in range(rows.size()):
		var y := panel.position.y + 74.0 + float(i) * 142.0
		_add_label(String(rows[i][0]), Vector2(panel.position.x + 38.0, y), Vector2(260.0, 42.0), 28, PAPER, HORIZONTAL_ALIGNMENT_LEFT)
		_add_bar(Vector2(panel.position.x + 330.0, y + 10.0), Vector2(panel.size.x - 420.0, 24.0), rows[i][2], float(rows[i][1]))
		_add_round_button("-", Vector2(panel.position.x + panel.size.x - 224.0, y - 22.0), 88.0, PANEL.lightened(0.10), PAPER)
		_add_round_button("+", Vector2(panel.position.x + panel.size.x - 118.0, y - 22.0), 88.0, PANEL.lightened(0.10), PAPER)
	_add_chip("Back", panel.position + Vector2(38.0, panel.size.y - 118.0), Vector2(180.0, 80.0), ENERGY)


func _add_credits_panel(screen: Vector2) -> void:
	var panel := _add_panel("CreditsPanel", Vector2(70.0, 210.0), Vector2(screen.x - 140.0, screen.y - 300.0), PANEL, SUCCESS.darkened(0.15))
	_add_label("Credits", panel.position + Vector2(34.0, 28.0), Vector2(panel.size.x - 68.0, 54.0), 38, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	var lines := [
		"Design direction: diamond pixel RPG reference board",
		"Runtime screens: Diamond sprites, tiles, skill icons, and live Godot UI",
		"Asset archive: kept outside repo unless licensed derivatives are selected",
		"QA target: portrait-first playable shell with landscape combat capture",
		"Thanks to the operators who keep evidence with every acceptance run",
	]
	for i in range(lines.size()):
		_add_label(lines[i], panel.position + Vector2(46.0, 118.0 + float(i) * 82.0), Vector2(panel.size.x - 92.0, 56.0), 25, PAPER.darkened(0.04), HORIZONTAL_ALIGNMENT_LEFT)


func _add_victory_panel(screen: Vector2) -> void:
	var panel := _add_panel("VictoryPanel", Vector2(screen.x * 0.13, screen.y * 0.28), Vector2(screen.x * 0.74, screen.y * 0.42), PANEL, SUCCESS.darkened(0.12))
	_add_label("VICTORY", panel.position + Vector2(24.0, 34.0), Vector2(panel.size.x - 48.0, 62.0), 54, SUCCESS, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("Vigilant Matron defeated", panel.position + Vector2(24.0, 112.0), Vector2(panel.size.x - 48.0, 44.0), 28, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	var rewards := ["Memory Shard", "Mender Brace Plate", "+120 XP", "+80 Scrip"]
	for i in range(rewards.size()):
		var pos := panel.position + Vector2(54.0 + float(i % 2) * (panel.size.x * 0.46), 198.0 + float(i / 2) * 124.0)
		_add_chip(rewards[i], pos, Vector2(panel.size.x * 0.38, 84.0), WARNING if i < 2 else ENERGY)


func _add_objective_chip(screen: Vector2, action: String, target: String, color: Color) -> void:
	_add_chip("%s  %s" % [action, target], Vector2(screen.x * 0.34, screen.y * 0.72), Vector2(screen.x * 0.32, 76.0), color)


func _add_landscape_prompt(screen: Vector2) -> void:
	_add_chip("Landscape viewport 1920 x 1080", Vector2(screen.x * 0.37, screen.y - 126.0), Vector2(screen.x * 0.26, 70.0), ENERGY)


func _add_bottom_safe_shadow(screen: Vector2) -> void:
	var shade := ColorRect.new()
	shade.name = "BottomThumbShade"
	shade.color = INK.lerp(PANEL, 0.35)
	shade.position = Vector2(0.0, screen.y - 286.0)
	shade.size = Vector2(screen.x, 286.0)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(shade)
	_content.move_child(shade, 1)


func _add_panel(name: String, pos: Vector2, size: Vector2, bg: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.name = name
	panel.position = pos
	panel.size = size
	panel.add_theme_stylebox_override("panel", _style_box(bg, border, 8, 2))
	_content.add_child(panel)
	return panel


func _add_label(text: String, pos: Vector2, size: Vector2, font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = size
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	_content.add_child(label)
	return label


func _add_menu_button(text: String, pos: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(360.0, 88.0)
	button.custom_minimum_size = button.size
	button.add_theme_font_size_override("font_size", 28)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_stylebox_override("normal", _style_box(PAPER, ENERGY.darkened(0.20), 8, 2))
	button.add_theme_stylebox_override("hover", _style_box(PAPER.lightened(0.03), WARNING, 8, 2))
	button.add_theme_stylebox_override("pressed", _style_box(PAPER.darkened(0.08), SUCCESS, 8, 2))
	button.pressed.connect(callback)
	_content.add_child(button)
	return button


func _add_round_button(text: String, pos: Vector2, size: float, bg: Color, fg: Color, icon_key := "") -> Button:
	var button := Button.new()
	button.text = "" if icon_key != "" else text
	button.position = pos
	button.size = Vector2(size, size)
	button.custom_minimum_size = button.size
	button.add_theme_font_size_override("font_size", 18 if text.length() > 5 else 24)
	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", PAPER)
	button.add_theme_stylebox_override("normal", _style_box(bg, fg.darkened(0.25), 8, 2))
	button.add_theme_stylebox_override("hover", _style_box(bg.lightened(0.08), ENERGY, 8, 2))
	button.add_theme_stylebox_override("pressed", _style_box(bg.darkened(0.12), WARNING, 8, 2))
	_content.add_child(button)
	if icon_key != "":
		_add_icon_to_button(button, icon_key, Vector2(size * 0.62, size * 0.62))
	return button


func _add_chip(text: String, pos: Vector2, size: Vector2, color: Color) -> Panel:
	var chip := _add_panel("Chip_%s" % text.replace(" ", "_"), pos, size, color.darkened(0.16), color.lightened(0.10))
	_add_label(text, pos + Vector2(12.0, 4.0), size - Vector2(24.0, 8.0), 22, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	return chip


func _add_item_cell(pos: Vector2, size: Vector2, text: String, index: int) -> void:
	var color: Color = [ENERGY, SUCCESS, WARNING, STATUS][index % 4]
	_add_panel("Item_%d" % index, pos, size, PANEL.lightened(0.06), color.darkened(0.10))
	var icon_rect := ColorRect.new()
	icon_rect.position = pos + Vector2(36.0, 22.0)
	icon_rect.size = Vector2(76.0, 58.0)
	icon_rect.color = color
	_content.add_child(icon_rect)
	var icon_keys := ["icon_broadsword", "icon_buckler", "icon_hp_potion", "icon_mp_potion", "icon_sack"]
	_add_texture_icon(icon_keys[index % icon_keys.size()], pos + Vector2(30.0, 16.0), Vector2(88.0, 72.0))
	_add_label(text, pos + Vector2(10.0, 88.0), Vector2(size.x - 20.0, 34.0), 19, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("x%d" % (index % 5 + 1), pos + Vector2(12.0, 116.0), Vector2(size.x - 24.0, 26.0), 17, PAPER.darkened(0.10), HORIZONTAL_ALIGNMENT_RIGHT)


func _add_bar(pos: Vector2, size: Vector2, color: Color, fill: float) -> void:
	var base := ColorRect.new()
	base.position = pos
	base.size = size
	base.color = INK.lerp(PANEL, 0.60)
	_content.add_child(base)
	var filled := ColorRect.new()
	filled.position = pos
	filled.size = Vector2(size.x * clampf(fill, 0.0, 1.0), size.y)
	filled.color = color
	_content.add_child(filled)


func _style_box(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style


func _load_runtime_textures() -> void:
	for key in RUNTIME_ASSETS.keys():
		var image := Image.new()
		if image.load(String(RUNTIME_ASSETS[key])) == OK:
			_runtime_textures[key] = ImageTexture.create_from_image(image)


func _add_texture_icon(texture_key: String, pos: Vector2, size: Vector2) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.position = pos
	texture_rect.size = size
	texture_rect.texture = _runtime_textures.get(texture_key)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(texture_rect)
	return texture_rect


func _add_icon_to_button(button: Button, texture_key: String, size: Vector2) -> void:
	var texture_rect := TextureRect.new()
	texture_rect.position = (button.size - size) * 0.5
	texture_rect.size = size
	texture_rect.texture = _runtime_textures.get(texture_key)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(texture_rect)
