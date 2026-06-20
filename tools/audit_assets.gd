extends SceneTree

const REQUIRED_DOCS: Array[String] = [
	"res://ASSET_LEDGER.md",
	"res://CREDITS.md",
	"res://docs/license-audit.md",
]

const ASSET_ROOT := "res://assets"
const LICENSE_ROOT := "res://assets/licenses"
const MAX_TEXTURE_SIZE := 2048
const TILE_UNIT := 16
const MAX_UNIQUE_COLORS := 256

const RUNTIME_EXTENSIONS: Array[String] = [
	"png",
	"jpg",
	"jpeg",
	"webp",
	"svg",
	"ogg",
	"wav",
	"mp3",
	"ttf",
	"otf",
]

const TEXTURE_EXTENSIONS: Array[String] = [
	"png",
	"jpg",
	"jpeg",
	"webp",
]

const BLOCKED_SOURCE_PATTERNS: Array[String] = [
	"preview",
	"thumbnail",
	"screenshot",
	"mockup",
	"logo",
	"watermark",
	"ripped",
	"traced",
	"fanart",
	"fan_art",
	"franchise",
	"trademark",
	"ai-recreated",
	"ai_recreated",
	"noncommercial",
	"non-commercial",
	"personal-use",
	"personal_use",
	"educational-use",
	"fan-use",
	"no-derivatives",
	"share-alike",
	"cc-by-sa",
	"gpl",
	"lgpl",
]

func _initialize() -> void:
	var failures: Array[String] = []
	var ledger_text := _read_text("res://ASSET_LEDGER.md", failures)
	var fixtures := _parse_fixtures()

	_check_required_docs(failures)
	_check_license_root(failures)

	for asset_path in _collect_runtime_assets(ASSET_ROOT):
		_audit_asset(asset_path, ledger_text, failures)

	for extra_asset in _parse_extra_assets():
		_audit_asset(_to_resource_path(extra_asset), ledger_text, failures)

	for fixture in fixtures:
		_apply_fixture(fixture, ledger_text, failures)

	if failures.is_empty():
		print("ASSET_AUDIT_OK")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
		print(failure)
	quit(1)

func _check_required_docs(failures: Array[String]) -> void:
	for path in REQUIRED_DOCS:
		if not FileAccess.file_exists(path):
			failures.append("ASSET_DOC_MISSING: %s" % path)

func _check_license_root(failures: Array[String]) -> void:
	if not DirAccess.dir_exists_absolute(LICENSE_ROOT):
		failures.append("ASSET_LICENSE_ROOT_MISSING: %s" % LICENSE_ROOT)

func _read_text(path: String, failures: Array[String]) -> String:
	if not FileAccess.file_exists(path):
		failures.append("ASSET_DOC_MISSING: %s" % path)
		return ""

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures.append("ASSET_DOC_UNREADABLE: %s" % path)
		return ""

	return file.get_as_text()

func _parse_extra_assets() -> Array[String]:
	var assets: Array[String] = []
	var args := OS.get_cmdline_user_args()
	var index := 0

	while index < args.size():
		if args[index] == "--extra-asset":
			if index + 1 >= args.size():
				print("EXTRA_ASSET_ARGUMENT_MISSING")
				quit(1)
				return assets
			assets.append(args[index + 1])
			index += 2
			continue
		index += 1

	return assets

func _parse_fixtures() -> Array[String]:
	var fixtures: Array[String] = []
	var args := OS.get_cmdline_user_args()
	var index := 0

	while index < args.size():
		if args[index] == "--fixture":
			if index + 1 >= args.size():
				print("AUDIT_FIXTURE_ARGUMENT_MISSING")
				quit(1)
				return fixtures
			fixtures.append(args[index + 1])
			index += 2
			continue
		index += 1

	return fixtures

func _apply_fixture(fixture: String, ledger_text: String, failures: Array[String]) -> void:
	match fixture:
		"missing_audio_license":
			var fixture_asset := "res://assets/audio/fixture_missing_audio_license.ogg"
			var fixture_ledger := "%s\n%s\n" % [ledger_text, _to_ledger_path(fixture_asset)]
			var before := failures.size()
			_audit_asset(fixture_asset, fixture_ledger, failures)
			if failures.size() > before:
				failures.append("AUDIO_LICENSE_FIXTURE_REJECTED")
		_:
			failures.append("UNKNOWN_AUDIT_FIXTURE: %s" % fixture)

func _collect_runtime_assets(root_path: String) -> Array[String]:
	var paths: Array[String] = []
	if not DirAccess.dir_exists_absolute(root_path):
		return paths

	_collect_runtime_assets_recursive(root_path, paths)
	return paths

func _collect_runtime_assets_recursive(root_path: String, paths: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue

		var child_path := "%s/%s" % [root_path, entry]
		if dir.current_is_dir():
			_collect_runtime_assets_recursive(child_path, paths)
		elif _is_runtime_asset(child_path):
			paths.append(child_path)

		entry = dir.get_next()
	dir.list_dir_end()

func _audit_asset(asset_path: String, ledger_text: String, failures: Array[String]) -> void:
	if _is_license_proof_path(asset_path) or asset_path.ends_with("/.gitkeep"):
		return

	var normalized_path := _to_ledger_path(asset_path)
	if _has_blocked_pattern(normalized_path):
		failures.append("BLOCKED_SOURCE_PATTERN: %s" % normalized_path)

	if not _ledger_mentions_asset(normalized_path, ledger_text):
		failures.append("UNREGISTERED_ASSET_DETECTED: %s" % normalized_path)
		return

	_check_license_proof(normalized_path, ledger_text, failures)

	if _is_texture(asset_path):
		_check_texture_rules(asset_path, normalized_path, failures)

func _check_license_proof(normalized_path: String, ledger_text: String, failures: Array[String]) -> void:
	var asset_id := _asset_id_from_path(normalized_path)
	var expected_md := "%s/%s.md" % [LICENSE_ROOT, asset_id]
	var expected_txt := "%s/%s.txt" % [LICENSE_ROOT, asset_id]

	if FileAccess.file_exists(expected_md) or FileAccess.file_exists(expected_txt):
		return
	if ledger_text.contains("assets/licenses/%s.md" % asset_id) or ledger_text.contains("assets/licenses/%s.txt" % asset_id):
		return
	if _ledger_row_has_existing_license_proof(normalized_path, ledger_text):
		return

	failures.append("ASSET_LICENSE_PROOF_MISSING: %s" % normalized_path)

func _ledger_row_has_existing_license_proof(normalized_path: String, ledger_text: String) -> bool:
	for raw_line in ledger_text.split("\n"):
		var line := raw_line.strip_edges()
		if not line.begins_with("|") or not line.contains(normalized_path):
			continue
		if _row_references_existing_license_proof(line):
			return true
	return false

func _row_references_existing_license_proof(line: String) -> bool:
	var marker := "assets/licenses/"
	var index := line.find(marker)
	while index != -1:
		var proof_end := _license_proof_end(line, index)
		if proof_end == -1:
			index = line.find(marker, index + marker.length())
			continue

		var proof_path := "res://%s" % line.substr(index, proof_end - index)
		if FileAccess.file_exists(proof_path):
			return true
		index = line.find(marker, proof_end)

	return false

func _license_proof_end(line: String, start: int) -> int:
	var end := -1
	for extension in [".md", ".txt"]:
		var candidate := line.find(extension, start)
		if candidate == -1:
			continue
		candidate += extension.length()
		if end == -1 or candidate < end:
			end = candidate
	return end

func _check_texture_rules(asset_path: String, normalized_path: String, failures: Array[String]) -> void:
	var image := Image.new()
	var error := image.load(asset_path)
	if error != OK:
		failures.append("TEXTURE_UNREADABLE: %s" % normalized_path)
		return

	if image.get_width() > MAX_TEXTURE_SIZE or image.get_height() > MAX_TEXTURE_SIZE:
		failures.append("OVERSIZED_TEXTURE_DETECTED: %s %dx%d" % [normalized_path, image.get_width(), image.get_height()])

	if image.get_width() % TILE_UNIT != 0 or image.get_height() % TILE_UNIT != 0:
		failures.append("SCALE_RULE_VIOLATION: %s %dx%d" % [normalized_path, image.get_width(), image.get_height()])

	if _unique_color_count(image) > MAX_UNIQUE_COLORS:
		failures.append("PALETTE_RULE_VIOLATION: %s" % normalized_path)

func _unique_color_count(image: Image) -> int:
	var colors := {}
	for y in image.get_height():
		for x in image.get_width():
			colors[image.get_pixel(x, y).to_html(true)] = true
			if colors.size() > MAX_UNIQUE_COLORS:
				return colors.size()
	return colors.size()

func _ledger_mentions_asset(normalized_path: String, ledger_text: String) -> bool:
	return ledger_text.contains(normalized_path) or ledger_text.contains("res://%s" % normalized_path)

func _has_blocked_pattern(normalized_path: String) -> bool:
	var lower_path := normalized_path.to_lower()
	for pattern in BLOCKED_SOURCE_PATTERNS:
		if lower_path.contains(pattern):
			return true
	return false

func _is_runtime_asset(path: String) -> bool:
	var extension := path.get_extension().to_lower()
	return RUNTIME_EXTENSIONS.has(extension)

func _is_texture(path: String) -> bool:
	var extension := path.get_extension().to_lower()
	return TEXTURE_EXTENSIONS.has(extension)

func _is_license_proof_path(path: String) -> bool:
	return path.begins_with(LICENSE_ROOT + "/")

func _to_resource_path(path: String) -> String:
	if path.begins_with("res://"):
		return path

	var project_root := ProjectSettings.globalize_path("res://")
	if path.begins_with(project_root):
		return "res://" + path.substr(project_root.length()).trim_prefix("/")

	return "res://" + path.trim_prefix("./")

func _to_ledger_path(path: String) -> String:
	return path.trim_prefix("res://").trim_prefix("./")

func _asset_id_from_path(normalized_path: String) -> String:
	var basename := normalized_path.get_file().get_basename().to_lower()
	return basename.replace(" ", "-")
