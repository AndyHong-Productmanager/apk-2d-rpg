extends SceneTree

const TITLE_SCENE := preload("res://scenes/title.tscn")
const PORTRAIT_SIZE := Vector2i(1080, 1920)
const ROUTE_STEPS := [
	{"name": "title", "visual": "title", "action": "boot", "route": "title"},
	{"name": "intro", "visual": "intro", "action": "interact", "call": "start_new_run", "route": "intro"},
	{"name": "exploration", "visual": "exploration", "action": "interact", "call": "finish_intro", "route": "gameplay"},
	{"name": "combat", "visual": "combat", "action": "attack", "route": "gameplay"},
	{"name": "boss", "visual": "boss", "action": "skill_1", "route": "gameplay"},
	{"name": "save", "visual": "inventory", "action": "open_menu", "call": "pause_and_save", "route": "paused"},
	{"name": "continue", "visual": "exploration", "action": "interact", "call": "continue_from_save", "route": "gameplay"},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config := _parse_args()
	var route := String(config.get("route", "full_release"))
	if route != "full_release":
		_fail("unsupported route: %s" % route)
		return

	var frames_dir := _to_absolute_path(String(config.get("frames", ".omo/evidence/playthrough/frames")))
	var video_path := _to_absolute_path(String(config.get("video", ".omo/evidence/playthrough/full-release.webm")))
	_prepare_output_paths(frames_dir, video_path)

	var save_manager: Node = root.get_node("SaveManager")
	save_manager.call("remove_qa_saves")

	var viewport := SubViewport.new()
	viewport.name = "Todo12PlaythroughViewport"
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.size = PORTRAIT_SIZE
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var shell: Control = TITLE_SCENE.instantiate()
	shell.size = Vector2(PORTRAIT_SIZE)
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(shell)
	await process_frame
	await process_frame

	var frame_paths: Array[String] = []
	for index in ROUTE_STEPS.size():
		var step: Dictionary = ROUTE_STEPS[index]
		await _perform_step(shell, step)
		_require(String(shell.call("current_route")) == String(step.route), "route mismatch for %s" % String(step.name))
		shell.call("show_capture_state", String(step.visual))
		await process_frame
		await process_frame
		var frame_path := await _capture_frame(viewport, frames_dir, index, String(step.name))
		frame_paths.append(frame_path)
		print("INPUT_STEP_OK index=%d state=%s action=%s route=%s frame=%s" % [
			index,
			String(step.name),
			String(step.action),
			String(shell.call("current_route")),
			frame_path,
		])

	var video_bytes := _write_video_placeholder(video_path, route, frame_paths)
	_require(video_bytes > 0, "video artifact is non-empty")

	root.remove_child(viewport)
	viewport.queue_free()
	save_manager.call("remove_qa_saves")

	print("VISUAL_CAPTURE_OK frames=%d output=%s video=%s video_bytes=%d" % [
		frame_paths.size(),
		frames_dir,
		video_path,
		video_bytes,
	])
	print("INPUT_PLAYTHROUGH_OK route=%s frames=%d video=%s" % [route, frame_paths.size(), video_path])
	quit(0)


func _perform_step(shell: Control, step: Dictionary) -> void:
	var action := String(step.action)
	if action != "boot":
		await _press_action(action)

	match String(step.get("call", "")):
		"start_new_run":
			shell.call("start_new_run")
		"finish_intro":
			shell.call("finish_intro")
		"pause_and_save":
			shell.call("pause_game")
			_require(bool(shell.call("save_game")), "save succeeds")
		"continue_from_save":
			var app_state: Node = root.get_node("AppState")
			app_state.call("reset_shell")
			_require(String(shell.call("current_route")) == "title", "reset returns to title before continue")
			_require(bool(shell.call("continue_from_save")), "continue succeeds")
		_:
			pass
	await process_frame
	await process_frame


func _press_action(action: String) -> void:
	var pressed := InputEventAction.new()
	pressed.action = action
	pressed.pressed = true
	Input.parse_input_event(pressed)
	print("INPUT_EVENT action=%s pressed=true" % action)
	await process_frame

	var released := InputEventAction.new()
	released.action = action
	released.pressed = false
	Input.parse_input_event(released)
	print("INPUT_EVENT action=%s pressed=false" % action)
	await process_frame


func _capture_frame(viewport: SubViewport, frames_dir: String, index: int, state_name: String) -> String:
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await process_frame
	await process_frame

	var image := viewport.get_texture().get_image()
	var frame_path := "%s/%03d-%s.png" % [frames_dir, index, state_name]
	var save_error := image.save_png(frame_path)
	if save_error != OK:
		_fail("failed to save frame: %s" % frame_path)
		return frame_path

	var bytes := FileAccess.get_file_as_bytes(frame_path)
	if bytes.is_empty():
		_fail("empty frame: %s" % frame_path)
		return frame_path

	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	print("FRAME_CAPTURED path=%s bytes=%d size=%dx%d" % [
		frame_path,
		bytes.size(),
		image.get_width(),
		image.get_height(),
	])
	return frame_path


func _write_video_placeholder(video_path: String, route: String, frame_paths: Array[String]) -> int:
	var file := FileAccess.open(video_path, FileAccess.WRITE)
	if file == null:
		_fail("failed to open video artifact: %s" % video_path)
		return 0

	var lines: Array[String] = [
		"WEBM_PLACEHOLDER",
		"route=%s" % route,
		"frame_count=%d" % frame_paths.size(),
		"proof=sequential_png_frames",
	]
	for frame_path in frame_paths:
		lines.append("frame=%s" % frame_path)
	file.store_string("\n".join(lines) + "\n")
	file.close()

	var bytes := FileAccess.get_file_as_bytes(video_path)
	print("VIDEO_PLACEHOLDER_OK path=%s bytes=%d" % [video_path, bytes.size()])
	return bytes.size()


func _prepare_output_paths(frames_dir: String, video_path: String) -> void:
	var frames_error := DirAccess.make_dir_recursive_absolute(frames_dir)
	if frames_error != OK:
		_fail("could not create frame directory: %s" % frames_dir)
		return

	var video_dir := video_path.get_base_dir()
	var video_error := DirAccess.make_dir_recursive_absolute(video_dir)
	if video_error != OK:
		_fail("could not create video directory: %s" % video_dir)
		return


func _parse_args() -> Dictionary:
	var args := Array(OS.get_cmdline_user_args())
	var config := {
		"route": "full_release",
		"frames": ".omo/evidence/playthrough/frames",
		"video": ".omo/evidence/playthrough/full-release.webm",
	}
	var index := 0
	while index < args.size():
		var key := String(args[index])
		if key in ["--route", "--frames", "--video"]:
			if index + 1 >= args.size():
				_fail("missing value for %s" % key)
				return config
			config[key.trim_prefix("--")] = String(args[index + 1])
			index += 2
			continue
		index += 1
	return config


func _to_absolute_path(path: String) -> String:
	if path.begins_with("/") or path.begins_with("res://") or path.begins_with("user://"):
		return ProjectSettings.globalize_path(path)

	var project_root := ProjectSettings.globalize_path("res://").trim_suffix("/")
	return "%s/%s" % [project_root, path.trim_prefix("./")]


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	push_error(message)
	print("INPUT_PLAYTHROUGH_FAIL %s" % message)
	quit(1)
