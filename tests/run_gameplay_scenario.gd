extends SceneTree

const SAVE_MANAGER_SCRIPT := preload("res://scripts/autoload/save_manager.gd")


func _initialize() -> void:
	var args := Array(OS.get_cmdline_user_args())
	if args.has("--scenario") and _arg_value(args, "--scenario") == "corrupt_save":
		_run_corrupt_save()
		return

	print("gameplay scenario scaffold: no gameplay systems are implemented in Wave 1 Todo 3")
	quit(0)


func _run_corrupt_save() -> void:
	var save_manager: Node = SAVE_MANAGER_SCRIPT.new()
	var file := FileAccess.open(save_manager.get("SAVE_PATH"), FileAccess.WRITE)
	assert(file != null)
	file.store_string("{not valid json")
	file.close()

	var result: Dictionary = save_manager.call("read_or_recover")
	assert(bool(result.ok))
	assert(bool(result.recovered))
	assert(FileAccess.file_exists(save_manager.get("CORRUPT_PATH")))
	assert(FileAccess.file_exists(save_manager.get("SAVE_PATH")))
	assert(String(result.data.app.route) == "title")

	print("CORRUPT_SAVE_RECOVERY_OK recovered=true route=title")
	quit(0)


func _arg_value(args: Array, flag: String) -> String:
	var index := args.find(flag)
	if index == -1 or index + 1 >= args.size():
		return ""
	return String(args[index + 1])
