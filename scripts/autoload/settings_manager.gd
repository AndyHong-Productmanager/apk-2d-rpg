extends Node

const DEFAULT_SETTINGS := {
	"music_volume": 0.8,
	"sfx_volume": 0.8,
	"text_speed": "normal",
}

var music_volume := 0.8
var sfx_volume := 0.8
var text_speed := "normal"


func reset_settings() -> void:
	apply_snapshot(DEFAULT_SETTINGS)


func snapshot() -> Dictionary:
	return {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"text_speed": text_speed,
	}


func apply_snapshot(data: Dictionary) -> void:
	music_volume = float(data.get("music_volume", DEFAULT_SETTINGS.music_volume))
	sfx_volume = float(data.get("sfx_volume", DEFAULT_SETTINGS.sfx_volume))
	text_speed = String(data.get("text_speed", DEFAULT_SETTINGS.text_speed))
