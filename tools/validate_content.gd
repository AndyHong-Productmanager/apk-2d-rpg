extends SceneTree

const REQUIRED_FILES: Array[String] = [
	"res://DESIGN.md",
	"res://ASSET_LEDGER.md",
	"res://docs/reference-study.md",
]

func _initialize() -> void:
	var failures: Array[String] = []

	if OS.get_environment("GODOT_EXPECT_CONTENT_FAIL") == "1":
		failures.append("EXPECTED_CONTENT_FAIL: missing content marker requested by test harness")

	for path in REQUIRED_FILES:
		if not FileAccess.file_exists(path):
			failures.append("missing content: %s" % path)

	if failures.is_empty():
		print("content validation passed")
		print("CONTENT_VALIDATION_OK")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
		print(failure)
	quit(1)
