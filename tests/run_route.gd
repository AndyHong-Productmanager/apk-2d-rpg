extends SceneTree

const TITLE_SCENE := preload("res://scenes/title.tscn")
const VERTICAL_SLICE_SCRIPT := preload("res://scripts/gameplay/vertical_slice_simulator.gd")


func _initialize() -> void:
	var args := Array(OS.get_cmdline_user_args())
	if args.has("--route"):
		match _arg_value(args, "--route"):
			"app_shell":
				await _run_app_shell_route()
				return
			"vertical_slice":
				_run_vertical_slice_route()
				return
			"invalid_quest_transition":
				_run_invalid_quest_transition()
				return

	print("route test scaffold: no routes are implemented in Wave 1 Todo 3")
	quit(0)


func _run_app_shell_route() -> void:
	var shell: Node = TITLE_SCENE.instantiate()
	root.add_child(shell)
	await process_frame
	var app_state: Node = root.get_node("AppState")

	shell.call("start_new_run")
	assert(String(shell.call("current_route")) == "intro")
	shell.call("finish_intro")
	assert(String(shell.call("current_route")) == "gameplay")
	shell.call("pause_game")
	assert(String(shell.call("current_route")) == "paused")
	assert(bool(shell.call("save_game")))

	var before_ticks := int(app_state.get("gameplay_ticks"))
	app_state.call("reset_shell")
	assert(String(shell.call("current_route")) == "title")
	assert(bool(shell.call("continue_from_save")))
	assert(String(shell.call("current_route")) == "gameplay")
	assert(int(app_state.get("gameplay_ticks")) == before_ticks)
	assert(int(app_state.get("continue_count")) == 1)

	shell.call("open_settings")
	assert(String(shell.call("current_route")) == "settings")
	shell.call("return_to_title")
	shell.call("open_credits")
	assert(String(shell.call("current_route")) == "credits")

	print("SHELL_ROUTE_OK title intro gameplay paused settings credits")
	print("SAVE_ROUNDTRIP_OK route=gameplay ticks=%d continue_count=%d" % [
		int(app_state.get("gameplay_ticks")),
		int(app_state.get("continue_count")),
	])
	quit(0)


func _run_vertical_slice_route() -> void:
	var sim = VERTICAL_SLICE_SCRIPT.new()
	sim.remove_qa_save()

	_assert_ok(sim.start_quest("quest_wake_switchyard"))
	_assert_ok(sim.talk_to("npc_relay_mira"))
	_assert_ok(sim.complete_step("quest_wake_switchyard", "choose_starting_rig"))
	_assert_ok(sim.complete_step("quest_wake_switchyard", "restore_depot_relay"))
	_assert_ok(sim.complete_step("quest_wake_switchyard", "meet_relay_cell"))
	assert(String(sim.state.quest_states.quest_wake_switchyard.status) == "completed")
	assert(sim.has_item("item_patch_foam"))
	assert(Array(sim.state.party).has("rig_signal_weaver"))

	_assert_ok(sim.travel_to("neon_repair_market"))
	_assert_ok(sim.talk_to("npc_patch_jun"))
	_assert_ok(sim.start_quest("quest_steal_route_key"))
	_assert_ok(sim.complete_step("quest_steal_route_key", "reach_convoy_stall"))
	_assert_ok(sim.resolve_lane_sentinel())
	_assert_ok(sim.complete_step("quest_steal_route_key", "disable_lane_sentinel"))
	_assert_ok(sim.complete_step("quest_steal_route_key", "claim_route_key"))
	assert(String(sim.state.quest_states.quest_steal_route_key.status) == "completed")
	assert(sim.has_item("item_route_key_east"))
	assert(sim.has_item("item_memory_shard_convoy"))

	_assert_ok(sim.travel_to("east_rail_checkpoint"))
	_assert_ok(sim.talk_to("npc_anchor_sera"))
	_assert_ok(sim.travel_to("clinic_lockdown"))
	_assert_ok(sim.talk_to("npc_clinic_echo"))
	_assert_ok(sim.start_quest("quest_rescue_clinic_echoes"))
	_assert_ok(sim.complete_step("quest_rescue_clinic_echoes", "stabilize_clinic_echo"))
	_assert_ok(sim.resolve_clinic_boss())
	_assert_ok(sim.complete_step("quest_rescue_clinic_echoes", "defeat_vigilant_matron"))
	_assert_ok(sim.complete_step("quest_rescue_clinic_echoes", "recover_clinic_shard"))
	assert(String(sim.state.quest_states.quest_rescue_clinic_echoes.status) == "completed")
	assert(sim.has_item("item_memory_shard_clinic"))
	assert(sim.has_item("item_mender_brace_plate"))
	assert(Array(sim.state.party).has("rig_anchor_mender"))
	_assert_ok(sim.equip("item_mender_brace_plate"))

	_assert_ok(sim.write_save())
	var loaded = VERTICAL_SLICE_SCRIPT.new()
	_assert_ok(loaded.read_save())
	assert(loaded.has_item("item_route_key_east"))
	assert(loaded.has_item("item_memory_shard_clinic"))
	assert(String(loaded.state.quest_states.quest_rescue_clinic_echoes.status) == "completed")
	assert(String(loaded.state.equipment.trinket) == "item_mender_brace_plate")

	print("QUEST_REWARD_OK xp=%d scrip=%d items=%d" % [
		int(sim.state.xp),
		int(sim.state.repair_scrip),
		Array(sim.state.inventory).size(),
	])
	print("INVENTORY_PERSIST_OK items=%d final_equipment=%s" % [
		Array(loaded.state.inventory).size(),
		String(loaded.state.equipment.trinket),
	])
	print("VERTICAL_SLICE_COMPLETE locations=%d dialogue=%d party=%d" % [
		Array(sim.state.visited_locations).size(),
		Array(sim.state.dialogue_seen).size(),
		Array(sim.state.party).size(),
	])
	quit(0)


func _run_invalid_quest_transition() -> void:
	var sim = VERTICAL_SLICE_SCRIPT.new()
	sim.remove_qa_save()

	_assert_ok(sim.travel_to("neon_repair_market"))
	var locked_travel: Dictionary = sim.travel_to("east_rail_checkpoint")
	assert(not bool(locked_travel.ok))
	assert(String(locked_travel.reason).begins_with("missing_required_item"))

	var locked_quest: Dictionary = sim.start_quest("quest_steal_route_key")
	assert(not bool(locked_quest.ok))
	assert(String(locked_quest.reason) == "quest_not_available")

	_assert_ok(sim.start_quest("quest_wake_switchyard"))
	var out_of_order: Dictionary = sim.complete_step("quest_wake_switchyard", "meet_relay_cell")
	assert(not bool(out_of_order.ok))
	assert(String(out_of_order.reason) == "step_out_of_order")

	print("INVALID_QUEST_TRANSITION_BLOCKED_OK travel=%s quest=%s step=%s" % [
		String(locked_travel.reason),
		String(locked_quest.reason),
		String(out_of_order.reason),
	])
	quit(0)


func _assert_ok(result: Dictionary) -> void:
	assert(bool(result.ok), "route action failed: %s" % JSON.stringify(result))


func _arg_value(args: Array, flag: String) -> String:
	var index := args.find(flag)
	if index == -1 or index + 1 >= args.size():
		return ""
	return String(args[index + 1])
