extends Node

const DEFAULT_SETTINGS := {
	"master_volume": 0.8,
	"music_volume": 0.8,
	"sfx_volume": 0.8,
	"text_speed": "normal",
	"readable_text": false,
	"reduced_motion": false,
}
const TEXT_SPEED_OPTIONS := ["slow", "normal", "fast", "instant"]

var master_volume := 0.8
var music_volume := 0.8
var sfx_volume := 0.8
var text_speed := "normal"
var readable_text := false
var reduced_motion := false


func reset_settings() -> void:
	apply_snapshot(DEFAULT_SETTINGS)


func snapshot() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"text_speed": text_speed,
		"readable_text": readable_text,
		"reduced_motion": reduced_motion,
	}


func apply_snapshot(data: Dictionary) -> void:
	master_volume = _volume_from(data, "master_volume")
	music_volume = _volume_from(data, "music_volume")
	sfx_volume = _volume_from(data, "sfx_volume")
	text_speed = _text_speed_from(data)
	readable_text = bool(data.get("readable_text", DEFAULT_SETTINGS.readable_text))
	reduced_motion = bool(data.get("reduced_motion", DEFAULT_SETTINGS.reduced_motion))


func _volume_from(data: Dictionary, key: String) -> float:
	var value := float(data.get(key, DEFAULT_SETTINGS[key]))
	return min(max(value, 0.0), 1.0)


func _text_speed_from(data: Dictionary) -> String:
	var value := String(data.get("text_speed", DEFAULT_SETTINGS.text_speed))
	if TEXT_SPEED_OPTIONS.has(value):
		return value
	return String(DEFAULT_SETTINGS.text_speed)
