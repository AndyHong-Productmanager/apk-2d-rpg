extends SceneTree

const SAVE_MANAGER_SCRIPT := preload("res://scripts/autoload/save_manager.gd")
const SETTINGS_MANAGER_SCRIPT := preload("res://scripts/autoload/settings_manager.gd")
const COMBAT_SIMULATOR_SCRIPT := preload("res://scripts/combat/combat_simulator.gd")


func _initialize() -> void:
	var args := Array(OS.get_cmdline_user_args())
	if args.has("--scenario"):
		for scenario in _arg_values(args, "--scenario"):
			_run_scenario(scenario)
		quit(0)
		return

	print("gameplay scenario scaffold: no gameplay systems are implemented in Wave 1 Todo 3")
	quit(0)


func _run_scenario(scenario: String) -> void:
	match scenario:
		"corrupt_save":
			_run_corrupt_save()
		"combat_loop":
			_run_combat_loop()
		"boss_clear":
			_run_boss_clear()
		"low_energy_guard":
			_run_low_energy_guard()
		"settings_persist":
			_run_settings_persist()
		_:
			_fail("unknown scenario: %s" % scenario)


func _run_corrupt_save() -> void:
	var save_manager: Node = SAVE_MANAGER_SCRIPT.new()
	var file := FileAccess.open(save_manager.get("SAVE_PATH"), FileAccess.WRITE)
	_require(file != null, "save file opens")
	file.store_string("{not valid json")
	file.close()

	var result: Dictionary = save_manager.call("read_or_recover")
	_require(bool(result.ok), "corrupt save recovers")
	_require(bool(result.recovered), "result marks recovered")
	_require(FileAccess.file_exists(save_manager.get("CORRUPT_PATH")), "corrupt save quarantined")
	_require(FileAccess.file_exists(save_manager.get("SAVE_PATH")), "replacement save exists")
	_require(String(result.data.app.route) == "title", "default route restored")

	print("CORRUPT_SAVE_RECOVERY_OK recovered=true route=title")
	save_manager.free()


func _run_combat_loop() -> void:
	var combat := COMBAT_SIMULATOR_SCRIPT.new()
	var counts: Dictionary = combat.call("content_counts")
	_require(int(counts.enemies) == 8, "chapter has eight enemy types")
	_require(int(counts.bosses) == 2, "chapter has two bosses")
	_require(int(counts.items) >= 8, "chapter has item drops")

	combat.call("start_encounter", [
		"enemy_custodian_sweeper",
		"enemy_patch_spider",
		"enemy_null_scribe",
		"enemy_plated_bailiff",
	])
	var start_integrity := int(combat.state.player.integrity)
	var start_energy := int(combat.state.player.energy)

	var tell: Dictionary = combat.call("telegraph", 0)
	_require(bool(tell.ok) and String(tell.telegraph) == "amber cone sweep", "enemy telegraph is exposed")
	var guard_result: Dictionary = combat.call("guard", true)
	_require(bool(guard_result.ok), "perfect guard activates")
	var parry_result: Dictionary = combat.call("enemy_attack", 0)
	_require(bool(parry_result.parried), "perfect guard parries")

	var dash_result: Dictionary = combat.call("dash", 0)
	_require(bool(dash_result.ok), "dash spends stamina")
	var skill_result: Dictionary = combat.call("use_skill", "skill_kinetic_dashcut", 0)
	_require(bool(skill_result.ok), "dashcut spends energy and applies damage")
	var cooldown_result: Dictionary = combat.call("use_skill", "skill_kinetic_dashcut", 0)
	_require(not bool(cooldown_result.ok) and String(cooldown_result.reason) == "cooldown", "cooldown blocks repeated skill")

	_clear_active_enemies(combat, 40)
	var player: Dictionary = combat.state.player
	_require(int(combat.call("active_enemy_count")) == 0, "encounter cleared")
	_require(int(player.integrity) < start_integrity, "player took real damage")
	_require(int(player.energy) != start_energy, "energy mutated")
	_require(int(player.xp) >= 100, "xp awarded")
	_require(Array(player.inventory).has("item_clean_circuit"), "enemy item drop awarded")
	_require(Array(player.inventory).has("item_plated_shell_fragment"), "heavy enemy item drop awarded")

	print("COMBAT_LOOP_OK enemies=8 bosses=2 xp=%d drops=%d level=%d" % [
		int(player.xp),
		Array(player.inventory).size(),
		int(player.level),
	])


func _run_boss_clear() -> void:
	var combat := COMBAT_SIMULATOR_SCRIPT.new()
	_clear_boss(combat, "boss_vigilant_matron")
	combat.call("rest_at_hub")
	_clear_boss(combat, "boss_glass_bailiff_ix")

	var player: Dictionary = combat.state.player
	_require(int(player.level) >= 3, "boss xp levels player")
	_require(Array(player.inventory).has("item_memory_shard_clinic"), "first boss story reward awarded")
	_require(Array(player.inventory).has("item_mender_brace_plate"), "first boss gear reward awarded")
	_require(Array(player.inventory).has("item_memory_shard_testimony"), "final boss story reward awarded")
	_require(Array(player.inventory).has("item_bailiff_core"), "final boss core reward awarded")

	print("BOSS_CLEAR_OK bosses=2 xp=%d level=%d repair_scrip=%d drops=%d" % [
		int(player.xp),
		int(player.level),
		int(player.repair_scrip),
		Array(player.inventory).size(),
	])


func _run_low_energy_guard() -> void:
	var combat := COMBAT_SIMULATOR_SCRIPT.new()
	combat.call("start_encounter", ["enemy_lane_sentinel"])
	combat.call("set_player_energy", 4)
	var before_energy := int(combat.state.player.energy)
	var guard_result: Dictionary = combat.call("guard", true)
	_require(not bool(guard_result.ok), "guard is blocked below energy cost")
	_require(String(guard_result.reason) == "low_energy", "guard failure reason is low energy")
	_require(int(combat.state.player.energy) == before_energy, "failed guard does not spend energy")
	combat.call("dash", 0)
	_require(int(combat.state.player.energy) >= 0, "dash clamps energy at zero")
	combat.call("enemy_attack", 0)
	_require(int(combat.state.player.energy) >= 0, "enemy attack cannot make energy negative")

	print("LOW_ENERGY_GUARD_BLOCKED_OK energy=%d" % int(combat.state.player.energy))
	print("NO_NEGATIVE_ENERGY_OK energy=%d" % int(combat.state.player.energy))


func _run_settings_persist() -> void:
	var save_manager: Node = SAVE_MANAGER_SCRIPT.new()
	var settings_manager: Node = SETTINGS_MANAGER_SCRIPT.new()
	save_manager.call("remove_qa_saves")

	var target_settings := {
		"master_volume": 0.42,
		"music_volume": 0.25,
		"sfx_volume": 0.9,
		"text_speed": "fast",
		"readable_text": true,
		"reduced_motion": true,
	}
	settings_manager.call("apply_snapshot", target_settings)
	var saved_settings: Dictionary = settings_manager.call("snapshot")
	_require(_settings_match(saved_settings, target_settings), "settings snapshot captures audio readability accessibility")

	var payload: Dictionary = save_manager.call("build_payload", {
		"route": "settings",
		"previous_route": "title",
		"has_seen_intro": true,
		"gameplay_ticks": 11,
		"continue_count": 2,
	}, saved_settings)
	var write_result: Dictionary = save_manager.call("write_payload", payload)
	_require(bool(write_result.ok), "settings payload writes")

	settings_manager.call("reset_settings")
	_require(not _settings_match(settings_manager.call("snapshot"), target_settings), "reset proves settings need restore")

	var read_result: Dictionary = save_manager.call("read_or_recover")
	_require(bool(read_result.ok), "settings payload reads")
	_require(not bool(read_result.recovered), "settings payload is not recovered")
	var loaded_payload: Dictionary = read_result.data
	settings_manager.call("apply_snapshot", loaded_payload.get("settings", {}))
	var loaded_settings: Dictionary = settings_manager.call("snapshot")
	_require(_settings_match(loaded_settings, target_settings), "settings persist across save load")

	var clamped_settings := {
		"master_volume": 2.0,
		"music_volume": -0.5,
		"sfx_volume": 0.5,
		"text_speed": "unreadable",
		"readable_text": false,
		"reduced_motion": true,
	}
	settings_manager.call("apply_snapshot", clamped_settings)
	var sanitized: Dictionary = settings_manager.call("snapshot")
	_require(is_equal_approx(float(sanitized.master_volume), 1.0), "master volume clamps high")
	_require(is_equal_approx(float(sanitized.music_volume), 0.0), "music volume clamps low")
	_require(String(sanitized.text_speed) == "normal", "invalid text speed falls back")

	print("SETTINGS_PERSIST_OK master=0.42 music=0.25 sfx=0.90 text=fast readable=true reduced_motion=true")
	save_manager.call("remove_qa_saves")
	settings_manager.free()
	save_manager.free()


func _clear_boss(combat: RefCounted, boss_id: String) -> void:
	combat.call("start_boss", boss_id)
	_clear_active_enemies(combat, 60)
	_require(int(combat.call("active_enemy_count")) == 0, "%s defeated" % boss_id)


func _clear_active_enemies(combat: RefCounted, turn_limit: int) -> void:
	var turn := 0
	while int(combat.call("active_enemy_count")) > 0 and turn < turn_limit:
		var target := _first_active_enemy_index(combat)
		combat.call("tick_turn")
		if turn % 3 == 0:
			combat.call("telegraph", target)
			combat.call("guard", turn % 6 == 0)
			combat.call("enemy_attack", target)
		if _try_skill(combat, "skill_kinetic_overcrank", target):
			pass
		elif _try_skill(combat, "skill_kinetic_dashcut", target):
			pass
		elif _try_skill(combat, "skill_signal_tether", target):
			pass
		else:
			combat.call("dash", target)
			combat.call("player_attack", target)
		turn += 1
	_require(turn < turn_limit, "combat cleared before turn limit")


func _try_skill(combat: RefCounted, skill_id: String, target: int) -> bool:
	var result: Dictionary = combat.call("use_skill", skill_id, target)
	return bool(result.ok)


func _first_active_enemy_index(combat: RefCounted) -> int:
	var enemies: Array = combat.state.enemies
	for index in enemies.size():
		if not bool(enemies[index].defeated):
			return index
	_fail("no active enemy")
	return -1


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _settings_match(actual: Dictionary, expected: Dictionary) -> bool:
	return (
		is_equal_approx(float(actual.get("master_volume", -1.0)), float(expected.master_volume))
		and is_equal_approx(float(actual.get("music_volume", -1.0)), float(expected.music_volume))
		and is_equal_approx(float(actual.get("sfx_volume", -1.0)), float(expected.sfx_volume))
		and String(actual.get("text_speed", "")) == String(expected.text_speed)
		and bool(actual.get("readable_text", false)) == bool(expected.readable_text)
		and bool(actual.get("reduced_motion", false)) == bool(expected.reduced_motion)
	)


func _fail(message: String) -> void:
	push_error(message)
	print("SCENARIO_FAIL %s" % message)
	quit(1)


func _arg_values(args: Array, flag: String) -> Array[String]:
	var values: Array[String] = []
	for index in args.size():
		if String(args[index]) == flag and index + 1 < args.size():
			values.append(String(args[index + 1]))
	return values
