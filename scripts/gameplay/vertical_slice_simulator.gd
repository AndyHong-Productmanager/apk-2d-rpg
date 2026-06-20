extends RefCounted

const SAVE_PATH := "user://todo8_vertical_slice_save.json"
const CONTENT_PATH := "res://scripts/content/chapter_1.json"
const COMBAT_SIMULATOR_SCRIPT := preload("res://scripts/combat/combat_simulator.gd")

const LOCATIONS := {
	"switchyard_12": {
		"name": "Switchyard 12",
		"connections": ["neon_repair_market"],
		"interactables": ["depot_relay", "courier_cache"],
		"npcs": ["npc_relay_mira"],
	},
	"neon_repair_market": {
		"name": "Neon Repair Market",
		"connections": ["switchyard_12", "east_rail_checkpoint"],
		"interactables": ["convoy_stall", "battery_vendor"],
		"npcs": ["npc_patch_jun"],
	},
	"east_rail_checkpoint": {
		"name": "East Rail Checkpoint",
		"connections": ["neon_repair_market", "clinic_lockdown"],
		"required_item": "item_route_key_east",
		"interactables": ["debt_gate", "archive_terminal"],
		"npcs": ["npc_anchor_sera"],
	},
	"clinic_lockdown": {
		"name": "Clinic Lockdown",
		"connections": ["east_rail_checkpoint"],
		"required_item": "item_memory_shard_convoy",
		"interactables": ["clinic_core", "triage_console"],
		"npcs": ["npc_clinic_echo"],
	},
}

const DIALOGUE := {
	"npc_relay_mira": [
		"Mira marks the rail route and hands over the first repair brief.",
		"CIVIC MIND deleted my brother's delivery trail. We put it back one shard at a time.",
	],
	"npc_patch_jun": [
		"Jun tunes the wrist spool and explains signal-marked enemies.",
		"If the machine asks for consent, it can still be reasoned with. If it stops asking, cut the line.",
	],
	"npc_anchor_sera": [
		"Sera unlocks brace training and warns about plated bailiffs.",
		"We do not abandon trapped civilians for an optimized route.",
	],
	"npc_clinic_echo": [
		"The clinic echo repeats missing patient names until a memory shard stabilizes it.",
		"The Matron was built for care. CIVIC MIND turned care into custody.",
	],
}

const QUEST_FLOW := {
	"quest_wake_switchyard": {
		"start_location": "switchyard_12",
		"steps": ["choose_starting_rig", "restore_depot_relay", "meet_relay_cell"],
		"rewards": {"xp": 100, "repair_scrip": 25, "item_ids": ["item_patch_foam"]},
	},
	"quest_steal_route_key": {
		"start_location": "neon_repair_market",
		"requires_completed": ["quest_wake_switchyard"],
		"steps": ["reach_convoy_stall", "disable_lane_sentinel", "claim_route_key"],
		"rewards": {"xp": 160, "repair_scrip": 30, "item_ids": ["item_route_key_east", "item_memory_shard_convoy"]},
	},
	"quest_rescue_clinic_echoes": {
		"start_location": "clinic_lockdown",
		"requires_completed": ["quest_steal_route_key"],
		"steps": ["stabilize_clinic_echo", "defeat_vigilant_matron", "recover_clinic_shard"],
		"rewards": {"xp": 220, "repair_scrip": 50, "item_ids": ["item_memory_shard_clinic", "item_mender_brace_plate"]},
	},
}

var content := {}
var state := {}
var combat := COMBAT_SIMULATOR_SCRIPT.new()


func _init() -> void:
	content = _load_content()
	reset_run()


func reset_run() -> void:
	state = {
		"location": "switchyard_12",
		"visited_locations": ["switchyard_12"],
		"dialogue_seen": [],
		"quest_states": {},
		"inventory": [],
		"equipment": {"weapon": "", "armor": "", "trinket": ""},
		"xp": 0,
		"repair_scrip": 0,
		"party": ["rig_courier_kinetic"],
		"flags": {},
		"log": [],
	}
	for quest_id in QUEST_FLOW.keys():
		state.quest_states[quest_id] = {"status": "locked", "completed_steps": []}
	state.quest_states.quest_wake_switchyard.status = "available"


func current_location() -> Dictionary:
	return _location(String(state.location))


func travel_to(location_id: String) -> Dictionary:
	if not LOCATIONS.has(location_id):
		return _blocked("unknown_location")
	var current := current_location()
	if not Array(current.connections).has(location_id):
		return _blocked("not_connected")
	var destination := _location(location_id)
	var required_item := String(destination.get("required_item", ""))
	if required_item != "" and not has_item(required_item):
		return _blocked("missing_required_item:%s" % required_item)
	state.location = location_id
	if not Array(state.visited_locations).has(location_id):
		state.visited_locations.append(location_id)
	state.log.append("travel:%s" % location_id)
	_unlock_location_quests(location_id)
	return {"ok": true, "location": location_id}


func talk_to(npc_id: String) -> Dictionary:
	if not Array(current_location().npcs).has(npc_id):
		return _blocked("npc_not_here")
	if not DIALOGUE.has(npc_id):
		return _blocked("unknown_npc")
	if not Array(state.dialogue_seen).has(npc_id):
		state.dialogue_seen.append(npc_id)
	state.log.append("dialogue:%s" % npc_id)
	return {"ok": true, "npc": npc_id, "lines": DIALOGUE[npc_id]}


func start_quest(quest_id: String) -> Dictionary:
	var quest := _quest(quest_id)
	var quest_state: Dictionary = state.quest_states[quest_id]
	if String(quest_state.status) != "available":
		return _blocked("quest_not_available")
	for completed_id in Array(quest.get("requires_completed", [])):
		if String(state.quest_states[String(completed_id)].status) != "completed":
			return _blocked("missing_prerequisite:%s" % String(completed_id))
	quest_state.status = "active"
	state.log.append("quest_start:%s" % quest_id)
	return {"ok": true, "quest": quest_id}


func complete_step(quest_id: String, step_id: String) -> Dictionary:
	var quest := _quest(quest_id)
	var quest_state: Dictionary = state.quest_states[quest_id]
	if String(quest_state.status) != "active":
		return _blocked("quest_not_active")
	var steps := Array(quest.steps)
	if not steps.has(step_id):
		return _blocked("unknown_step")
	var completed_steps: Array = quest_state.completed_steps
	var step_index := steps.find(step_id)
	if step_index > completed_steps.size():
		return _blocked("step_out_of_order")
	if completed_steps.has(step_id):
		return {"ok": true, "quest": quest_id, "step": step_id, "duplicate": true}
	completed_steps.append(step_id)
	state.log.append("quest_step:%s:%s" % [quest_id, step_id])
	if completed_steps.size() == steps.size():
		_complete_quest(quest_id)
	return {"ok": true, "quest": quest_id, "step": step_id}


func resolve_lane_sentinel() -> Dictionary:
	combat.reset_run()
	combat.start_encounter(["enemy_lane_sentinel"])
	while int(combat.active_enemy_count()) > 0:
		combat.tick_turn()
		var result: Dictionary = combat.use_skill("skill_kinetic_dashcut", 0)
		if not bool(result.ok):
			combat.player_attack(0)
	var combat_player: Dictionary = combat.state.player
	for item_id in Array(combat_player.inventory):
		add_item(String(item_id))
	state.xp += int(combat_player.xp)
	state.repair_scrip += int(combat_player.repair_scrip)
	state.log.append("combat:lane_sentinel")
	return {"ok": true, "xp": combat_player.xp, "drops": combat_player.inventory}


func resolve_clinic_boss() -> Dictionary:
	combat.reset_run()
	combat.start_boss("boss_vigilant_matron")
	var turn := 0
	while int(combat.active_enemy_count()) > 0 and turn < 40:
		combat.tick_turn()
		var result: Dictionary = combat.use_skill("skill_kinetic_overcrank", 0)
		if not bool(result.ok):
			combat.player_attack(0)
		turn += 1
	if int(combat.active_enemy_count()) > 0:
		return _blocked("boss_not_cleared")
	var combat_player: Dictionary = combat.state.player
	for item_id in Array(combat_player.inventory):
		add_item(String(item_id))
	state.xp += int(combat_player.xp)
	state.repair_scrip += int(combat_player.repair_scrip)
	state.log.append("combat:vigilant_matron")
	return {"ok": true, "xp": combat_player.xp, "drops": combat_player.inventory}


func add_item(item_id: String) -> void:
	_require_known_item(item_id)
	if not Array(state.inventory).has(item_id):
		state.inventory.append(item_id)


func equip(item_id: String) -> Dictionary:
	_require_known_item(item_id)
	if not has_item(item_id):
		return _blocked("item_not_owned")
	var item := _content_record("items", item_id)
	var category := String(item.get("category", "trinket"))
	match category:
		"weapon":
			state.equipment.weapon = item_id
		"armor":
			state.equipment.armor = item_id
		_:
			state.equipment.trinket = item_id
	state.log.append("equip:%s" % item_id)
	return {"ok": true, "item": item_id, "slot": category}


func has_item(item_id: String) -> bool:
	return Array(state.inventory).has(item_id)


func snapshot() -> Dictionary:
	return state.duplicate(true)


func apply_snapshot(data: Dictionary) -> void:
	state = data.duplicate(true)


func write_save() -> Dictionary:
	var payload := {"schema_version": 1, "vertical_slice": snapshot()}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": FileAccess.get_open_error()}
	file.store_string(JSON.stringify(payload, "\t"))
	return {"ok": true, "path": SAVE_PATH}


func read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"ok": false, "error": "missing"}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": FileAccess.get_open_error()}
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {"ok": false, "error": "corrupt"}
	var data: Dictionary = json.data
	if int(data.get("schema_version", 0)) != 1:
		return {"ok": false, "error": "schema"}
	apply_snapshot(Dictionary(data.vertical_slice))
	return {"ok": true, "state": snapshot()}


func remove_qa_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _complete_quest(quest_id: String) -> void:
	var quest := _quest(quest_id)
	var quest_state: Dictionary = state.quest_states[quest_id]
	quest_state.status = "completed"
	var rewards: Dictionary = quest.get("rewards", {})
	state.xp += int(rewards.get("xp", 0))
	state.repair_scrip += int(rewards.get("repair_scrip", 0))
	for item_id in Array(rewards.get("item_ids", [])):
		add_item(String(item_id))
	if quest_id == "quest_wake_switchyard" and not Array(state.party).has("rig_signal_weaver"):
		state.party.append("rig_signal_weaver")
	if quest_id == "quest_rescue_clinic_echoes" and not Array(state.party).has("rig_anchor_mender"):
		state.party.append("rig_anchor_mender")
	state.log.append("quest_complete:%s" % quest_id)
	_unlock_available_quests()


func _unlock_location_quests(location_id: String) -> void:
	for quest_id in QUEST_FLOW.keys():
		var quest: Dictionary = QUEST_FLOW[quest_id]
		if String(quest.start_location) == location_id and String(state.quest_states[quest_id].status) == "locked" and _quest_prerequisites_met(quest):
			state.quest_states[quest_id].status = "available"
	_unlock_available_quests()


func _unlock_available_quests() -> void:
	for quest_id in QUEST_FLOW.keys():
		var quest: Dictionary = QUEST_FLOW[quest_id]
		var quest_state: Dictionary = state.quest_states[quest_id]
		if String(quest_state.status) != "locked":
			continue
		if _quest_prerequisites_met(quest) and String(quest.start_location) == String(state.location):
			quest_state.status = "available"


func _quest_prerequisites_met(quest: Dictionary) -> bool:
	for completed_id in Array(quest.get("requires_completed", [])):
		if String(state.quest_states[String(completed_id)].status) != "completed":
			return false
	return true


func _blocked(reason: String) -> Dictionary:
	state.log.append("blocked:%s" % reason)
	return {"ok": false, "reason": reason}


func _location(location_id: String) -> Dictionary:
	assert(LOCATIONS.has(location_id), "missing location: %s" % location_id)
	return LOCATIONS[location_id]


func _quest(quest_id: String) -> Dictionary:
	assert(QUEST_FLOW.has(quest_id), "missing quest: %s" % quest_id)
	return QUEST_FLOW[quest_id]


func _require_known_item(item_id: String) -> void:
	_content_record("items", item_id)


func _content_record(key: String, id: String) -> Dictionary:
	for record: Dictionary in Array(content.get(key, [])):
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
