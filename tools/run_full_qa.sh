#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/home/ubuntuhong/dev/.local-tools/bin/godot}"
XVFB_SCREEN="${XVFB_SCREEN:--screen 0 1080x1920x24}"
TMP_DIR="$(mktemp -d)"

cleanup() {
	rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

run_godot() {
	local script_path="$1"
	shift
	xvfb-run -a -s "${XVFB_SCREEN}" "${GODOT_BIN}" --path "${PROJECT_ROOT}" --script "${script_path}" -- "$@"
}

run_step() {
	local label="$1"
	local marker="$2"
	shift 2
	local output_path="${TMP_DIR}/${label}.log"

	echo "== ${label} =="
	if ! "$@" > "${output_path}" 2>&1; then
		cat "${output_path}"
		echo "QA_STEP_FAIL label=${label}"
		exit 1
	fi

	cat "${output_path}"
	if ! rg -q "${marker}" "${output_path}"; then
		echo "QA_STEP_FAIL label=${label} missing_marker=${marker}"
		exit 1
	fi
	echo "QA_STEP_OK label=${label} marker=${marker}"
}

cd "${PROJECT_ROOT}"
mkdir -p .omo/evidence

run_step "content_validation" "CONTENT_VALIDATION_OK" run_godot "res://tools/validate_content.gd"
run_step "app_shell_route" "SHELL_ROUTE_OK" run_godot "res://tests/run_route.gd" --route app_shell
run_step "corrupt_save_recovery" "CORRUPT_SAVE_RECOVERY_OK" run_godot "res://tests/run_gameplay_scenario.gd" --scenario corrupt_save
run_step "combat_loop" "COMBAT_LOOP_OK" run_godot "res://tests/run_gameplay_scenario.gd" --scenario combat_loop
run_step "boss_clear" "BOSS_CLEAR_OK" run_godot "res://tests/run_gameplay_scenario.gd" --scenario boss_clear
run_step "vertical_slice" "VERTICAL_SLICE_COMPLETE" run_godot "res://tests/run_route.gd" --route vertical_slice
run_step "visual_capture" "VISUAL_CAPTURE_OK" run_godot "res://tools/capture_ui_states.gd"
run_step "asset_audit" "ASSET_AUDIT_OK" run_godot "res://tools/audit_assets.gd"
run_step "settings_persist" "SETTINGS_PERSIST_OK" run_godot "res://tests/run_gameplay_scenario.gd" --scenario settings_persist

echo "FULL_QA_OK project=${PROJECT_ROOT}"
