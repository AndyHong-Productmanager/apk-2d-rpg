extends Node

signal route_changed(route: String)

const ROUTE_TITLE := "title"
const ROUTE_INTRO := "intro"
const ROUTE_GAMEPLAY := "gameplay"
const ROUTE_PAUSED := "paused"
const ROUTE_SETTINGS := "settings"
const ROUTE_CREDITS := "credits"

var route := ROUTE_TITLE
var previous_route := ""
var has_seen_intro := false
var gameplay_ticks := 0
var continue_count := 0


func reset_shell() -> void:
	route = ROUTE_TITLE
	previous_route = ""
	has_seen_intro = false
	gameplay_ticks = 0
	continue_count = 0
	route_changed.emit(route)


func go_to(next_route: String) -> void:
	previous_route = route
	route = next_route
	route_changed.emit(route)


func start_new_run() -> void:
	reset_shell()
	go_to(ROUTE_INTRO)


func finish_intro() -> void:
	has_seen_intro = true
	go_to(ROUTE_GAMEPLAY)


func pause_game() -> void:
	if route == ROUTE_GAMEPLAY:
		go_to(ROUTE_PAUSED)


func resume_game() -> void:
	if route == ROUTE_PAUSED:
		go_to(ROUTE_GAMEPLAY)


func tick_gameplay() -> void:
	gameplay_ticks += 1


func snapshot() -> Dictionary:
	return {
		"route": ROUTE_GAMEPLAY if route == ROUTE_PAUSED else route,
		"previous_route": previous_route,
		"has_seen_intro": has_seen_intro,
		"gameplay_ticks": gameplay_ticks,
		"continue_count": continue_count,
	}


func apply_snapshot(data: Dictionary) -> void:
	previous_route = String(data.get("previous_route", ""))
	has_seen_intro = bool(data.get("has_seen_intro", false))
	gameplay_ticks = int(data.get("gameplay_ticks", 0))
	continue_count = int(data.get("continue_count", 0))
	go_to(String(data.get("route", ROUTE_TITLE)))
