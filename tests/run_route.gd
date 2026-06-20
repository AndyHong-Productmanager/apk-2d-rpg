extends SceneTree

const TITLE_SCENE := preload("res://scenes/title.tscn")


func _initialize() -> void:
	var args := Array(OS.get_cmdline_user_args())
	if args.has("--route") and _arg_value(args, "--route") == "app_shell":
		await _run_app_shell_route()
		return

	print("route test scaffold: no routes are implemented in Wave 1 Todo 3")
	quit(0)


func _run_app_shell_route() -> void:
	var shell: Node = TITLE_SCENE.instantiate()
	root.add_child(shell)
	await process_frame
	var app_state: Node = root.get_node("AppState")

	shell.call("start_new_run")
	assert(String(shell.call("current_route")) == "intro")
	shell.call("finish_intro")
	assert(String(shell.call("current_route")) == "gameplay")
	shell.call("pause_game")
	assert(String(shell.call("current_route")) == "paused")
	assert(bool(shell.call("save_game")))

	var before_ticks := int(app_state.get("gameplay_ticks"))
	app_state.call("reset_shell")
	assert(String(shell.call("current_route")) == "title")
	assert(bool(shell.call("continue_from_save")))
	assert(String(shell.call("current_route")) == "gameplay")
	assert(int(app_state.get("gameplay_ticks")) == before_ticks)
	assert(int(app_state.get("continue_count")) == 1)

	shell.call("open_settings")
	assert(String(shell.call("current_route")) == "settings")
	shell.call("return_to_title")
	shell.call("open_credits")
	assert(String(shell.call("current_route")) == "credits")

	print("SHELL_ROUTE_OK title intro gameplay paused settings credits")
	print("SAVE_ROUNDTRIP_OK route=gameplay ticks=%d continue_count=%d" % [
		int(app_state.get("gameplay_ticks")),
		int(app_state.get("continue_count")),
	])
	quit(0)


func _arg_value(args: Array, flag: String) -> String:
	var index := args.find(flag)
	if index == -1 or index + 1 >= args.size():
		return ""
	return String(args[index + 1])
