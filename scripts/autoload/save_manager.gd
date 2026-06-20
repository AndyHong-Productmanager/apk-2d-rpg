extends Node

const SAVE_PATH := "user://todo6_shell_save.json"
const CORRUPT_PATH := "user://todo6_shell_save.corrupt"
const SCHEMA_VERSION := 1


func build_payload(app_snapshot: Dictionary, settings_snapshot: Dictionary) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"app": app_snapshot,
		"settings": settings_snapshot,
	}


func default_payload() -> Dictionary:
	return build_payload({
		"route": "title",
		"previous_route": "",
		"has_seen_intro": false,
		"gameplay_ticks": 0,
		"continue_count": 0,
	}, {
		"music_volume": 0.8,
		"sfx_volume": 0.8,
		"text_speed": "normal",
	})


func write_payload(payload: Dictionary) -> Dictionary:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": FileAccess.get_open_error()}
	file.store_string(JSON.stringify(payload, "\t"))
	return {"ok": true, "path": SAVE_PATH}


func read_payload() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"ok": false, "error": "missing", "data": {}}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": FileAccess.get_open_error(), "data": {}}

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {"ok": false, "error": "corrupt", "data": {}}

	var data: Dictionary = json.data
	if int(data.get("schema_version", 0)) != SCHEMA_VERSION:
		return {"ok": false, "error": "schema", "data": data}

	return {"ok": true, "error": "", "data": data}


func read_or_recover() -> Dictionary:
	var result := read_payload()
	if result.ok:
		result["recovered"] = false
		return result

	if result.error == "corrupt" or result.error == "schema":
		_quarantine_bad_save()

	var payload := default_payload()
	var write_result := write_payload(payload)
	return {
		"ok": bool(write_result.ok),
		"error": "" if bool(write_result.ok) else write_result.error,
		"data": payload,
		"recovered": true,
	}


func remove_qa_saves() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if FileAccess.file_exists(CORRUPT_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CORRUPT_PATH))


func _quarantine_bad_save() -> void:
	if FileAccess.file_exists(CORRUPT_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CORRUPT_PATH))
	DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH), ProjectSettings.globalize_path(CORRUPT_PATH))
