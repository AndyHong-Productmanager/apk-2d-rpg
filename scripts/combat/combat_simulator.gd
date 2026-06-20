extends RefCounted

const CONTENT_PATH := "res://scripts/content/chapter_1.json"

const ENEMY_COMBAT := {
	"enemy_custodian_sweeper": {"integrity": 48, "attack": 13, "posture": 18, "xp": 20, "repair_scrip": 8, "drops": ["item_clean_circuit"], "telegraph": "amber cone sweep"},
	"enemy_lane_sentinel": {"integrity": 62, "attack": 18, "posture": 26, "xp": 28, "repair_scrip": 12, "drops": ["item_battery_gel"], "telegraph": "red rail line"},
	"enemy_patch_spider": {"integrity": 42, "attack": 9, "posture": 14, "xp": 18, "repair_scrip": 9, "drops": ["item_patch_foam"], "telegraph": "cyan repair beam"},
	"enemy_archive_mote": {"integrity": 44, "attack": 15, "posture": 16, "xp": 24, "repair_scrip": 10, "drops": ["item_archive_keybit"], "telegraph": "purple siphon ring"},
	"enemy_debt_runner": {"integrity": 54, "attack": 17, "posture": 20, "xp": 26, "repair_scrip": 14, "drops": ["item_scrip_bundle_small"], "telegraph": "smoke dash line"},
	"enemy_plated_bailiff": {"integrity": 92, "attack": 24, "posture": 36, "xp": 42, "repair_scrip": 22, "drops": ["item_plated_shell_fragment"], "telegraph": "red grab circle"},
	"enemy_null_scribe": {"integrity": 58, "attack": 20, "posture": 22, "xp": 34, "repair_scrip": 16, "drops": ["item_signal_needle"], "telegraph": "purple text block"},
	"enemy_route_hound": {"integrity": 64, "attack": 21, "posture": 24, "xp": 32, "repair_scrip": 18, "drops": ["item_courier_boot_servos"], "telegraph": "red pounce lane"},
}

const BOSS_COMBAT := {
	"boss_vigilant_matron": {"integrity": 190, "attack": 28, "posture": 55, "xp": 120, "repair_scrip": 80, "drops": ["item_patch_foam", "item_battery_gel"]},
	"boss_glass_bailiff_ix": {"integrity": 250, "attack": 34, "posture": 70, "xp": 180, "repair_scrip": 120, "drops": ["item_false_testimony_core", "item_scrip_bundle_large"]},
}

const SKILLS := {
	"skill_kinetic_dashcut": {"energy": 18, "stamina": 8, "cooldown": 2, "damage": 42, "posture": 14, "status": "guard_broken"},
	"skill_signal_tether": {"energy": 16, "stamina": 0, "cooldown": 2, "damage": 30, "posture": 8, "status": "signal_mark"},
	"skill_anchor_brace": {"energy": 12, "stamina": 0, "cooldown": 3, "damage": 18, "posture": 18, "status": "braced"},
	"skill_kinetic_overcrank": {"energy": 28, "stamina": 14, "cooldown": 3, "damage": 58, "posture": 24, "status": "overheated"},
}

var content := {}
var state := {}


func _init() -> void:
	content = _load_content()
	reset_run()


func reset_run() -> void:
	state = {
		"player": {
			"integrity": 124,
			"max_integrity": 124,
			"energy": 96,
			"max_energy": 96,
			"stamina": 74,
			"max_stamina": 74,
			"guard": 30,
			"xp": 0,
			"level": 1,
			"repair_scrip": 0,
			"inventory": [],
			"statuses": {},
			"cooldowns": {},
		},
		"enemies": [],
		"log": [],
	}


func content_counts() -> Dictionary:
	return {
		"enemies": _content_array("enemies").size(),
		"bosses": _content_array("bosses").size(),
		"items": _content_array("items").size(),
		"skills": _content_array("skills").size(),
	}


func start_encounter(enemy_ids: Array) -> void:
	state.enemies = []
	for enemy_id in enemy_ids:
		state.enemies.append(_build_enemy(String(enemy_id), false))
	state.log.append("encounter:%s" % ",".join(enemy_ids))


func start_boss(boss_id: String) -> void:
	state.enemies = [_build_enemy(boss_id, true)]
	state.log.append("boss:%s" % boss_id)


func active_enemy_count() -> int:
	var count := 0
	for enemy: Dictionary in state.enemies:
		if not bool(enemy.defeated):
			count += 1
	return count


func rest_at_hub() -> void:
	var player: Dictionary = state.player
	player.energy = player.max_energy
	player.stamina = player.max_stamina
	player.statuses.clear()
	state.log.append("rest")


func set_player_energy(amount: int) -> void:
	state.player.energy = clampi(amount, 0, int(state.player.max_energy))


func telegraph(enemy_index: int) -> Dictionary:
	var enemy := _enemy_at(enemy_index)
	if bool(enemy.defeated):
		return {"ok": false, "reason": "defeated"}
	enemy.telegraph_ready = true
	_set_enemy(enemy_index, enemy)
	state.log.append("telegraph:%s:%s" % [enemy.id, enemy.telegraph])
	return {"ok": true, "telegraph": enemy.telegraph}


func guard(perfect_timing: bool) -> Dictionary:
	var player: Dictionary = state.player
	if int(player.energy) < 10:
		state.log.append("guard_blocked:low_energy")
		return {"ok": false, "reason": "low_energy", "energy": player.energy}
	player.energy = maxi(0, int(player.energy) - 10)
	player.statuses["guard_active"] = {"perfect": perfect_timing, "turns": 1}
	state.log.append("guard:%s" % ("perfect" if perfect_timing else "normal"))
	return {"ok": true, "energy": player.energy}


func dash(enemy_index: int) -> Dictionary:
	var player: Dictionary = state.player
	if int(player.stamina) < 12:
		return {"ok": false, "reason": "low_stamina"}
	player.stamina -= 12
	player.energy = maxi(0, int(player.energy) - 4)
	player.statuses["kinetic_charge"] = {"turns": 2}
	state.log.append("dash:%s" % _enemy_at(enemy_index).id)
	return {"ok": true, "stamina": player.stamina, "energy": player.energy}


func player_attack(enemy_index: int) -> Dictionary:
	var enemy := _enemy_at(enemy_index)
	if bool(enemy.defeated):
		return {"ok": false, "reason": "defeated"}

	var player: Dictionary = state.player
	var damage := 22
	if player.statuses.has("kinetic_charge"):
		damage += 14
		player.statuses.erase("kinetic_charge")
	if String(enemy.weakness) == "kinetic":
		damage += 8
	_apply_enemy_damage(enemy_index, damage, 8, "")
	player.energy = mini(int(player.max_energy), int(player.energy) + 6)
	player.stamina = mini(int(player.max_stamina), int(player.stamina) + 4)
	state.log.append("attack:%s:%d" % [enemy.id, damage])
	return {"ok": true, "damage": damage}


func use_skill(skill_id: String, enemy_index: int) -> Dictionary:
	if not SKILLS.has(skill_id):
		return {"ok": false, "reason": "unknown_skill"}
	var skill: Dictionary = SKILLS[skill_id]
	var player: Dictionary = state.player
	var cooldowns: Dictionary = player.cooldowns
	if int(cooldowns.get(skill_id, 0)) > 0:
		return {"ok": false, "reason": "cooldown"}
	if int(player.energy) < int(skill.energy):
		return {"ok": false, "reason": "low_energy"}
	if int(player.stamina) < int(skill.stamina):
		return {"ok": false, "reason": "low_stamina"}

	player.energy -= int(skill.energy)
	player.stamina -= int(skill.stamina)
	cooldowns[skill_id] = int(skill.cooldown)
	_apply_enemy_damage(enemy_index, int(skill.damage), int(skill.posture), String(skill.status))
	if skill_id == "skill_anchor_brace":
		player.integrity = mini(int(player.max_integrity), int(player.integrity) + 14)
	state.log.append("skill:%s:%s" % [skill_id, _enemy_at(enemy_index).id])
	return {"ok": true, "energy": player.energy, "stamina": player.stamina}


func enemy_attack(enemy_index: int) -> Dictionary:
	var enemy := _enemy_at(enemy_index)
	if bool(enemy.defeated):
		return {"ok": false, "reason": "defeated"}

	var player: Dictionary = state.player
	var incoming := int(enemy.attack)
	if enemy.statuses.has("signal_mark"):
		incoming = maxi(1, incoming - 6)

	var damage := incoming
	var parried := false
	if player.statuses.has("guard_active"):
		var guard_state: Dictionary = player.statuses.guard_active
		if bool(guard_state.perfect):
			damage = maxi(0, incoming - int(player.guard))
			parried = true
			_apply_enemy_damage(enemy_index, 0, 14, "parried")
			player.energy = mini(int(player.max_energy), int(player.energy) + 5)
		else:
			damage = ceili(float(incoming) * 0.35)
		player.statuses.erase("guard_active")

	player.integrity = maxi(0, int(player.integrity) - damage)
	enemy.telegraph_ready = false
	_set_enemy(enemy_index, enemy)
	state.log.append("enemy_attack:%s:%d" % [enemy.id, damage])
	return {"ok": true, "damage": damage, "parried": parried}


func tick_turn() -> void:
	var cooldowns: Dictionary = state.player.cooldowns
	for skill_id in cooldowns.keys():
		cooldowns[skill_id] = maxi(0, int(cooldowns[skill_id]) - 1)
	for status_id in state.player.statuses.keys():
		var status: Dictionary = state.player.statuses[status_id]
		if status.has("turns"):
			status.turns = int(status.turns) - 1
			if int(status.turns) <= 0:
				state.player.statuses.erase(status_id)


func _apply_enemy_damage(enemy_index: int, damage: int, posture_damage: int, status_id: String) -> void:
	var enemy := _enemy_at(enemy_index)
	if bool(enemy.defeated):
		return
	enemy.integrity = maxi(0, int(enemy.integrity) - damage)
	enemy.posture = maxi(0, int(enemy.posture) - posture_damage)
	if status_id != "":
		enemy.statuses[status_id] = true
	if int(enemy.posture) == 0:
		enemy.statuses["guard_broken"] = true
	if bool(enemy.boss):
		_update_boss_phase(enemy)
	if int(enemy.integrity) == 0:
		_defeat_enemy(enemy)
	_set_enemy(enemy_index, enemy)


func _defeat_enemy(enemy: Dictionary) -> void:
	if bool(enemy.defeated):
		return
	enemy.defeated = true
	var player: Dictionary = state.player
	player.xp += int(enemy.xp)
	if int(player.xp) >= 260:
		player.level = 3
	elif int(player.xp) >= 100:
		player.level = 2
	player.repair_scrip += int(enemy.repair_scrip)
	for item_id in enemy.drops:
		player.inventory.append(item_id)
	state.log.append("defeat:%s" % enemy.id)


func _update_boss_phase(enemy: Dictionary) -> void:
	var ratio := float(enemy.integrity) / float(enemy.max_integrity)
	var next_phase := 0
	if ratio <= 0.34:
		next_phase = 2
	elif ratio <= 0.67:
		next_phase = 1
	if next_phase > int(enemy.phase_index):
		enemy.phase_index = next_phase
		enemy.statuses["phase_%d" % next_phase] = true
		state.log.append("boss_phase:%s:%d" % [enemy.id, next_phase])


func _build_enemy(id: String, boss: bool) -> Dictionary:
	var content_record := _content_record("bosses" if boss else "enemies", id)
	var combat: Dictionary = BOSS_COMBAT[id] if boss else ENEMY_COMBAT[id]
	var drops: Array = Array(combat.drops).duplicate()
	if boss:
		drops.append_array(Array(content_record.get("reward_item_ids", [])))
	return {
		"id": id,
		"name": String(content_record.name),
		"boss": boss,
		"integrity": int(combat.integrity),
		"max_integrity": int(combat.integrity),
		"attack": int(combat.attack),
		"posture": int(combat.posture),
		"max_posture": int(combat.posture),
		"xp": int(combat.xp),
		"repair_scrip": int(combat.repair_scrip),
		"drops": drops,
		"telegraph": String(combat.get("telegraph", content_record.get("telegraph", "boss tell"))),
		"weakness": String(content_record.get("weakness", "kinetic")),
		"statuses": {},
		"phase_index": 0,
		"telegraph_ready": false,
		"defeated": false,
	}


func _enemy_at(index: int) -> Dictionary:
	assert(index >= 0 and index < state.enemies.size())
	return state.enemies[index]


func _set_enemy(index: int, enemy: Dictionary) -> void:
	state.enemies[index] = enemy


func _content_array(key: String) -> Array:
	return Array(content.get(key, []))


func _content_record(key: String, id: String) -> Dictionary:
	for record: Dictionary in _content_array(key):
		if String(record.get("id", "")) == id:
			return record
	assert(false, "missing content record: %s/%s" % [key, id])
	return {}


func _load_content() -> Dictionary:
	var file := FileAccess.open(CONTENT_PATH, FileAccess.READ)
	assert(file != null)
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	assert(error == OK)
	assert(typeof(json.data) == TYPE_DICTIONARY)
	return json.data
