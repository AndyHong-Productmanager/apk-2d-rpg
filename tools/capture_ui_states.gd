extends SceneTree

const TITLE_SCENE := preload("res://scenes/title.tscn")
const OUTPUT_DIR := "res://docs/screenshots"
const PORTRAIT_SIZE := Vector2i(1080, 1920)
const LANDSCAPE_SIZE := Vector2i(1920, 1080)
const STATES := [
	"title",
	"intro",
	"exploration",
	"dialogue",
	"combat",
	"boss",
	"victory",
	"inventory",
	"settings",
	"credits",
	"combat-landscape",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_dir := ProjectSettings.globalize_path(OUTPUT_DIR)
	var dir_error := DirAccess.make_dir_recursive_absolute(output_dir)
	if dir_error != OK:
		push_error("could not create screenshot directory: %s" % output_dir)
		quit(1)
		return

	var viewport := SubViewport.new()
	viewport.name = "Todo9CaptureViewport"
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var shell: Control = TITLE_SCENE.instantiate()
	viewport.add_child(shell)
	await process_frame
	await process_frame

	for state_name in STATES:
		var size := LANDSCAPE_SIZE if state_name == "combat-landscape" else PORTRAIT_SIZE
		viewport.size = size
		shell.size = Vector2(size)
		shell.set_anchors_preset(Control.PRESET_FULL_RECT)
		shell.call("show_capture_state", state_name)
		await process_frame
		await process_frame
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await process_frame

		var image := viewport.get_texture().get_image()
		var path := "%s/%s.png" % [OUTPUT_DIR, state_name]
		var save_error := image.save_png(path)
		if save_error != OK:
			push_error("failed to save %s" % path)
			quit(1)
			return
		var bytes := FileAccess.get_file_as_bytes(path)
		if bytes.is_empty():
			push_error("empty screenshot: %s" % path)
			quit(1)
			return
		print("CAPTURED %s %dx%d bytes=%d" % [path, image.get_width(), image.get_height(), bytes.size()])
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	for state_name in STATES:
		var path := "%s/%s.png" % [OUTPUT_DIR, state_name]
		var bytes := FileAccess.get_file_as_bytes(path)
		if bytes.is_empty():
			push_error("missing or empty required screenshot: %s" % path)
			quit(1)
			return

	root.remove_child(viewport)
	viewport.queue_free()
	print("VISUAL_CAPTURE_OK states=%d output=%s" % [STATES.size(), output_dir])
	quit(0)
