# New Ilhwa Asset Overhaul

## TL;DR
> Summary:      Replace the fantasy Diamond presentation with a story-specific New Ilhwa 2038 asset direction and runtime surface. The work creates an accepted art bible, a provenance-safe asset manifest, original vertical-slice sprites/tiles/icons, portable QA, and regenerated screenshots that visibly sell CIVIC MIND, Relay couriers, memory shards, municipal robots, and repair-district city spaces.
> Deliverables:
> - `docs/art-direction-new-ilhwa.md`
> - `docs/asset-production-manifest.md`
> - Updated `docs/asset-candidate-board.md`, `ASSET_LEDGER.md`, `CREDITS.md`, `docs/asset-pipeline.md`, and `docs/visual-qa.md`
> - Original runtime assets under `assets/new_ilhwa/runtime/` with proof under `assets/licenses/`
> - Story-named runtime asset registry replacing captured Diamond usage
> - Regenerated screenshots under `docs/screenshots/` plus before/after evidence under `.omo/evidence/new-ilhwa-asset-overhaul/`
> Effort:       XL
> Risk:         High - visual quality, asset provenance, and runtime screenshot fidelity must all pass without copying reference media.

## Scope
### Must have
- Reject Diamond as final art direction and update the candidate board to supersede the old "pick a paid pack after Diamond rejection" instruction.
- Preserve Diamond only as archived/license-tracked legacy scaffold. It must not appear in final captured runtime states or final visual QA claims.
- Create a project-owned New Ilhwa art bible before runtime asset production. Allowed final asset methods:
  - Hand-authored pixel art created for this project.
  - Procedural/project-authored pixel assets created from original shapes/palettes/scripts in this repo.
  - License-verified third-party assets only when ledger proof explicitly allows commercial APK use, public repo redistribution, and modification.
- Do not use AI-generated final runtime art unless a separate user-approved provenance policy is added first. Do not trace, recolor, or recreate protected/reference game art.
- Create a self-authored asset ledger/proof model covering creator, creation method, source working file, project ownership/license, redistribution permission, and proof path.
- Produce production art for Switchyard 12, Neon Repair Market, Service Rail East, and Sealed Clinic. The remaining Chapter 1 nodes get manifest-approved placeholders only in this pass.
- Produce visually distinct silhouettes for Mira, Jun, Sera, the core visible NPCs (`npc_relay_mira`, `npc_patch_jun`, `npc_anchor_sera`, `npc_clinic_echo`), eight enemy types, and Vigilant Matron.
- Treat Glass Bailiff IX as manifest-only for this pass unless a separate `final-boss` capture state is added and verified.
- Define technical specs: 16x16 tile basis, 128x128 actor frame sheets for current renderer compatibility, 4-direction frame layout where animated, intentional transparent padding, max 2048x2048 sheet size, max 256 sampled colors unless ledgered exception.
- Make QA portable through `GODOT_BIN`; the old hardcoded Linux path must not be the only path.
- Archive current screenshots before capture, regenerate title/intro/exploration/dialogue/combat/boss/victory/inventory/settings/credits/combat-landscape, then archive after screenshots and logs.
- Final screenshots must show New Ilhwa civic/retrotech motifs and must not show fantasy grass, boar enemies, broadsword/buckler fantasy icons, or Diamond runtime art.

### Must NOT have (guardrails, anti-slop, scope boundaries)
- No external reference screenshots, logos, sprites, videos, store capsules, or press-kit art committed or imported.
- No copying, tracing, recoloring, or "close enough" derivation from CrossCode, UNSIGHTED, Hyper Light Drifter, Eastward, SIGNALIS, Guardian Tales, LimeZu, Kenney, or Dotmancer.
- No unledgered runtime asset files.
- No paid source archive committed to Git unless its license explicitly permits public redistribution.
- No weakening/removing existing tests or audit rules to make assets pass.
- No full Chapter 1 expansion beyond the four production-art locations in this pass.
- No audio work.
- No final claim based only on grep, file existence, or subagent summary. Final proof requires screenshots plus command markers.

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: tests-after + Godot headless scripts + static asset/reference checks.
- QA policy: every todo has agent-executed scenarios and stores evidence in `.omo/evidence/new-ilhwa-asset-overhaul/`.
- Evidence: `.omo/evidence/new-ilhwa-asset-overhaul/task-<N>-<slug>.<ext>`.
- Required final pass markers:
  - `CONTENT_VALIDATION_OK`
  - `SHELL_ROUTE_OK`
  - `VERTICAL_SLICE_COMPLETE`
  - `COMBAT_LOOP_OK`
  - `BOSS_CLEAR_OK`
  - `SETTINGS_PERSIST_OK`
  - `VISUAL_CAPTURE_OK`
  - `ASSET_AUDIT_OK`
  - `FULL_QA_OK`
- Required final static assertions:
  - `scripts/ui/app_shell.gd` captured-state registry does not use `res://assets/diamond/runtime`.
  - `docs/screenshots/assets-preview.png` is retired or replaced by a New Ilhwa-only board.
  - `CREDITS.md` no longer describes Diamond as runtime art for final screenshots.
  - `docs/visual-qa.md` references the new after screenshots and evidence paths.
- Portable command convention:
  - Windows Git Bash: `GODOT_BIN="/c/path/to/Godot_v4.x.exe" bash tools/run_full_qa.sh`
  - Unix-like shell: `GODOT_BIN="/path/to/godot" bash tools/run_full_qa.sh`
  - If `GODOT_BIN` is unset or missing, the QA runner must fail with an actionable `GODOT_BIN_MISSING` style message instead of using a stale path silently.

## Execution strategy
### Parallel execution waves
> Target 5-8 todos per wave. < 3 per wave (except the final) = under-splitting.
Wave 1 (no deps): 1, 2, 3, 4, 5, 6
Wave 2 (after 1-6): 7, 8, 9, 10, 11, 12
Wave 3 (after 7-12): 13, 14
Critical path: 1 -> 2 -> 3 -> 4 -> 5 -> 7/8/9/10 -> 11 -> 12 -> 13 -> 14

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| 1 | None | 11, 13, 14 | 2, 3, 4, 5, 6 |
| 2 | None | 3, 4, 7, 8, 9, 10, 12 | 1, 5, 6 |
| 3 | 2 | 4, 7, 8, 9, 10, 12 | 1, 5, 6 |
| 4 | 2, 3 | 7, 8, 9, 10, 11, 12 | 5, 6 |
| 5 | None | 7, 8, 9, 10, 12 | 1, 2, 3, 6 |
| 6 | None | 12, 13 | 1, 2, 3, 4, 5 |
| 7 | 1, 2, 3, 4, 5 | 11, 12, 13 | 8, 9, 10 |
| 8 | 1, 2, 3, 4, 5 | 11, 12, 13 | 7, 9, 10 |
| 9 | 1, 2, 3, 4, 5 | 11, 12, 13 | 7, 8, 10 |
| 10 | 1, 2, 3, 4, 5 | 11, 12, 13 | 7, 8, 9 |
| 11 | 1, 4, 7, 8, 9, 10 | 12, 13 | None |
| 12 | 2, 3, 4, 5, 6, 11 | 13, 14 | None |
| 13 | 1, 11, 12 | 14 | None |
| 14 | 13 | Final verification | None |

## Todos
> Implementation + Test = ONE todo. Never separate.

- [ ] 1. Make QA portable and evidence-safe
  What to do / Must NOT do:
  Update `tools/run_full_qa.sh` and `docs/asset-pipeline.md` so all Godot commands use explicit `GODOT_BIN`, fail fast when missing, and write/copy logs to `.omo/evidence/new-ilhwa-asset-overhaul/`. Preserve all existing QA markers. Do not delete existing route, gameplay, capture, or audit checks.
  Parallelization: Can parallel Y | Wave 1 | Blocks 11, 13, 14
  References (executor has NO interview context - be exhaustive): `tools/run_full_qa.sh:1-55`, `tools/capture_ui_states.gd:3-18`, `tools/capture_ui_states.gd:46-82`, `tools/audit_assets.gd:63-88`, `docs/asset-pipeline.md:58-69`, `project.godot:20-28`
  Acceptance criteria (agent-executable): Run `GODOT_BIN="$GODOT_BIN" bash tools/run_full_qa.sh > .omo/evidence/new-ilhwa-asset-overhaul/task-1-full-qa.log 2>&1` and verify the log includes `FULL_QA_OK`, or if Godot is unavailable verify the runner fails with a clear `GODOT_BIN` missing message and no stale `/home/ubuntuhong/...` path is used.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` with `GODOT_BIN="$GODOT_BIN" bash tools/run_full_qa.sh`; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-1-full-qa.log`. Static fallback: `git grep -n "/home/ubuntuhong/dev/.local-tools/bin/godot" -- tools docs` must return no stale default command.
  Commit: Y | chore(qa): make Godot asset QA portable | Files `tools/run_full_qa.sh`, `docs/asset-pipeline.md`

- [ ] 2. Record approval and retire the old direction gate
  What to do / Must NOT do:
  Update `docs/asset-candidate-board.md` to state the approved direction: Diamond is rejected as final art and the replacement direction is original New Ilhwa retrotech municipal pixel art. Replace the old instruction to pick a paid pack after Diamond rejection. Update `ASSET_LEDGER.md` and `CREDITS.md` to mark Diamond as legacy/scaffold-only until removed from final captured runtime. Do not remove license proof for files still present.
  Parallelization: Can parallel Y | Wave 1 | Blocks 3, 4, 7, 8, 9, 10, 12
  References (executor has NO interview context - be exhaustive): `docs/asset-candidate-board.md:3-38`, `ASSET_LEDGER.md:21-27`, `ASSET_LEDGER.md:31-51`, `CREDITS.md:1-20`, `.omo/drafts/new-ilhwa-asset-overhaul.md`
  Acceptance criteria (agent-executable): `git grep -n "Start with .*Diamond\\|select a more modern/cyberpunk paid pack before making a new preview\\|Andy should approve" -- docs/asset-candidate-board.md` returns no stale final-direction gate; `git grep -n "legacy scaffold\\|not final runtime" -- docs/asset-candidate-board.md ASSET_LEDGER.md CREDITS.md` finds the new decision.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` static grep commands above; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-2-direction-gate.log`.
  Commit: Y | docs(assets): approve New Ilhwa art direction | Files `docs/asset-candidate-board.md`, `ASSET_LEDGER.md`, `CREDITS.md`

- [ ] 3. Create the New Ilhwa art bible
  What to do / Must NOT do:
  Add `docs/art-direction-new-ilhwa.md` with visual pillars, palette, tile/actor/effect specs, silhouette rules, screen-specific quality bars, reference-derived rules with access dates, and prohibited motifs. Include measurable checks: no fantasy grass, no boar enemy, no broadsword/buckler fantasy icons, civic/retrotech motifs visible in title/exploration/combat/boss/inventory, readable actors at 1080x1920 and 1920x1080. Do not embed or download external reference images.
  Parallelization: Can parallel Y | Wave 1 | Blocks 4, 7, 8, 9, 10, 12
  References (executor has NO interview context - be exhaustive): `STORY_BIBLE.md:5-19`, `STORY_BIBLE.md:44-105`, `STORY_BIBLE.md:138-173`, `STORY_BIBLE.md:198-210`, `DESIGN.md:3-30`, `DESIGN.md:53-80`, `docs/reference-study.md:1-169`
  Acceptance criteria (agent-executable): `test -s docs/art-direction-new-ilhwa.md` and `git grep -n "New Ilhwa\\|CIVIC MIND\\|memory shard\\|municipal robot\\|no fantasy grass\\|no boar" -- docs/art-direction-new-ilhwa.md` finds each required concept.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` with `test` and `git grep`; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-3-art-bible.log`.
  Commit: Y | docs(art): define New Ilhwa visual bible | Files `docs/art-direction-new-ilhwa.md`

- [ ] 4. Create the asset production manifest and provenance model
  What to do / Must NOT do:
  Add `docs/asset-production-manifest.md` mapping content/story IDs to runtime assets, MVP status, final status, frame specs, source/provenance proof, and QA screens. Include self-authored asset ledger fields and explicitly list production-art locations (Switchyard 12, Neon Repair Market, Service Rail East, Sealed Clinic) versus manifest-only locations (Rainline Underpass, Archive Convoy Wreck, Debt Gate, Hall of Records, Switchyard Return). Enumerate exact actor/NPC/enemy/boss IDs. Do not leave "core NPC" or "enemy set" as vague labels.
  Parallelization: Can parallel Y | Wave 1 | Blocks 7, 8, 9, 10, 11, 12
  References (executor has NO interview context - be exhaustive): `scripts/content/chapter_1.json:1-10`, `scripts/content/chapter_1.json:425-522`, `scripts/gameplay/vertical_slice_simulator.gd:5-91`, `STORY_BIBLE.md:154-179`, `STORY_BIBLE.md:181-210`, `ASSET_LEDGER.md:5-27`, `ASSET_LEDGER.md:65-73`
  Acceptance criteria (agent-executable): `git grep -n "rig_courier_kinetic\\|rig_signal_weaver\\|rig_anchor_mender\\|npc_relay_mira\\|npc_patch_jun\\|npc_anchor_sera\\|npc_clinic_echo\\|enemy_custodian_sweeper\\|enemy_lane_sentinel\\|enemy_patch_spider\\|enemy_archive_mote\\|enemy_debt_runner\\|enemy_plated_bailiff\\|enemy_null_scribe\\|enemy_route_hound\\|boss_vigilant_matron\\|boss_glass_bailiff_ix" -- docs/asset-production-manifest.md` finds all IDs.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` with manifest ID grep plus `GODOT_BIN="$GODOT_BIN" "$GODOT_BIN" --headless --path . --script res://tools/validate_content.gd`; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-4-manifest.log`.
  Commit: Y | docs(assets): map story IDs to production art | Files `docs/asset-production-manifest.md`, `ASSET_LEDGER.md`

- [ ] 5. Introduce a story-named runtime asset registry
  What to do / Must NOT do:
  Replace the two hardcoded Diamond `RUNTIME_ASSETS` dictionaries in `scripts/ui/app_shell.gd` with one story-named registry/API. Keys must match manifest concepts and content IDs where practical, such as `rig_courier_kinetic`, `rig_signal_weaver`, `rig_anchor_mender`, `enemy_lane_sentinel`, `boss_vigilant_matron`, `tile_switchyard_floor`, `icon_memory_shard`, `fx_signal_static`. Diamond fallback may exist only as an unreachable dev fallback and must not be selected in final captured states. Do not use `as any`, suppress diagnostics, or bypass missing asset errors silently.
  Parallelization: Can parallel Y | Wave 1 | Blocks 7, 8, 9, 10, 12
  References (executor has NO interview context - be exhaustive): `scripts/ui/app_shell.gd:11-20`, `scripts/ui/app_shell.gd:33-60`, `scripts/ui/app_shell.gd:85-90`, `scripts/ui/app_shell.gd:249-263`, `scripts/ui/app_shell.gd:671-700`, `scripts/content/chapter_1.json:425-522`
  Acceptance criteria (agent-executable): `git grep -n "res://assets/diamond/runtime" -- scripts/ui/app_shell.gd` returns no captured-state usage; `GODOT_BIN="$GODOT_BIN" "$GODOT_BIN" --headless --path . --script res://tests/run_route.gd -- --route app_shell` prints `SHELL_ROUTE_OK`.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` with static grep and app shell route; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-5-asset-registry.log`.
  Commit: Y | refactor(ui): centralize runtime asset registry | Files `scripts/ui/app_shell.gd`, optional `scripts/ui/asset_registry.gd`

- [ ] 6. Add static final-art guard checks
  What to do / Must NOT do:
  Add a lightweight verification script or shell check that fails if final captured runtime uses forbidden Diamond paths, fantasy markers, or rejected preview references. It should check `scripts/ui/app_shell.gd`, `docs/visual-qa.md`, `CREDITS.md`, `docs/asset-candidate-board.md`, and final screenshot inventory. Do not make the check so broad that legitimate `assets/licenses/diamond-top-down-pixel-art-LICENSE.txt` or historical ledger notes fail.
  Parallelization: Can parallel Y | Wave 1 | Blocks 12, 13
  References (executor has NO interview context - be exhaustive): `tools/run_full_qa.sh:21-55`, `tools/audit_assets.gd:188-217`, `docs/asset-candidate-board.md:3-38`, `CREDITS.md:1-20`, `docs/visual-qa.md:1-20`, `scripts/ui/app_shell.gd:523-524`
  Acceptance criteria (agent-executable): New check prints `NEW_ILHWA_ART_GUARD_OK` on passing state and fails when run against a temporary fixture containing a forbidden final `res://assets/diamond/runtime/tile_grass.png` reference.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` with the new guard script and its negative fixture; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-6-art-guard.log`.
  Commit: Y | test(assets): guard final art direction | Files `tools/*`, optional docs update

- [ ] 7. Produce and wire the New Ilhwa environment tiles
  What to do / Must NOT do:
  Create original runtime environment sheets under `assets/new_ilhwa/runtime/` for Switchyard 12, Neon Repair Market, Service Rail East, and Sealed Clinic. Replace grass-grid world rendering with civic/retrotech floor, rails, stalls, repair props, clinic panels, signage, archive/memory motifs, and readable combat lanes. Preserve portrait protected lane rules. Do not introduce high-res painterly or photoreal assets.
  Parallelization: Can parallel Y | Wave 2 | Blocks 11, 12, 13
  References (executor has NO interview context - be exhaustive): `STORY_BIBLE.md:13-19`, `STORY_BIBLE.md:198-210`, `DESIGN.md:13-30`, `DESIGN.md:74-80`, `docs/art-direction-new-ilhwa.md`, `docs/asset-production-manifest.md`, `scripts/ui/app_shell.gd:85-130`
  Acceptance criteria (agent-executable): `GODOT_BIN="$GODOT_BIN" "$GODOT_BIN" --headless --path . --script res://tools/audit_assets.gd` prints `ASSET_AUDIT_OK`; `GODOT_BIN="$GODOT_BIN" "$GODOT_BIN" --headless --path . --script res://tools/capture_ui_states.gd` prints `VISUAL_CAPTURE_OK`; screenshots `exploration.png`, `combat.png`, and `boss.png` contain no grass-grid floor or Diamond tile usage by static registry check.
  QA scenarios (name the exact tool + invocation): Godot asset audit and capture commands above; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-7-environments.log` plus copied screenshots under `.omo/evidence/new-ilhwa-asset-overhaul/task-7-after/`.
  Commit: Y | feat(assets): add New Ilhwa environment tiles | Files `assets/new_ilhwa/runtime/*`, `assets/licenses/*`, `ASSET_LEDGER.md`, `scripts/ui/app_shell.gd`

- [ ] 8. Produce and wire playable rig and NPC silhouettes
  What to do / Must NOT do:
  Create original actor sheets for Mira, Jun, Sera, and visible NPCs. Minimum: all actors have readable static/idle silhouettes; Mira gets the primary 4-direction playable movement sheet if only one full animation set fits this pass; Jun and Sera may be high-quality static/limited-animation silhouettes if clearly recorded in the manifest. Actor frames must align with the current 128x128 renderer or the renderer must be updated with tests. Do not reuse fantasy male/female Diamond sprites.
  Parallelization: Can parallel Y | Wave 2 | Blocks 11, 12, 13
  References (executor has NO interview context - be exhaustive): `STORY_BIBLE.md:44-105`, `scripts/content/chapter_1.json:20-170`, `scripts/gameplay/vertical_slice_simulator.gd:42-71`, `scripts/ui/app_shell.gd:151-170`, `scripts/ui/app_shell.gd:249-256`, `docs/asset-production-manifest.md`
  Acceptance criteria (agent-executable): `git grep -n "player_male\\|player_female" -- scripts/ui/app_shell.gd docs/visual-qa.md CREDITS.md` returns no final runtime usage; capture shows three distinct Relay silhouettes in title/intro/exploration/dialogue.
  QA scenarios (name the exact tool + invocation): Godot capture plus static grep; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-8-actors.log` and screenshot copies.
  Commit: Y | feat(assets): add Relay rig silhouettes | Files `assets/new_ilhwa/runtime/*`, `assets/licenses/*`, `ASSET_LEDGER.md`, `scripts/ui/app_shell.gd`, `docs/asset-production-manifest.md`

- [ ] 9. Produce and wire enemy and boss silhouettes
  What to do / Must NOT do:
  Create original silhouettes for the eight enemy types and production boss art for Vigilant Matron. Use role-first silhouettes: sweeper cone unit, rail sentinel turret, repair spider, archive mote drone, debt runner human scavenger, plated bailiff heavy, null scribe archive caster, route hound pursuit unit. Vigilant Matron must read as a converted hospital logistics rig with stretcher rails, triage lasers, repair pods, and a control node. Glass Bailiff IX remains manifest-only unless capture tooling is expanded. Do not use boar sprites.
  Parallelization: Can parallel Y | Wave 2 | Blocks 11, 12, 13
  References (executor has NO interview context - be exhaustive): `STORY_BIBLE.md:136-173`, `scripts/content/chapter_1.json:425-552`, `scripts/combat/combat_simulator.gd:6-13`, `scripts/ui/app_shell.gd:171-191`, `scripts/ui/app_shell.gd:399-419`, `tools/capture_ui_states.gd:7-18`, `docs/asset-production-manifest.md`
  Acceptance criteria (agent-executable): `git grep -n "enemy_boar" -- scripts/ui/app_shell.gd docs/visual-qa.md CREDITS.md` returns no final runtime usage; `GODOT_BIN="$GODOT_BIN" "$GODOT_BIN" --headless --path . --script res://tests/run_gameplay_scenario.gd -- --scenario combat_loop --scenario boss_clear` prints `COMBAT_LOOP_OK` and `BOSS_CLEAR_OK`; combat/boss screenshots show robot/AGI silhouettes.
  QA scenarios (name the exact tool + invocation): Godot gameplay scenario and capture; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-9-enemies-boss.log` and screenshot copies.
  Commit: Y | feat(assets): add municipal enemy silhouettes | Files `assets/new_ilhwa/runtime/*`, `assets/licenses/*`, `ASSET_LEDGER.md`, `scripts/ui/app_shell.gd`

- [ ] 10. Produce and wire UI icons, effects, and inventory readability
  What to do / Must NOT do:
  Replace fantasy icons with story-specific item/skill/effect icons: memory shard, repair scrip, battery gel, patch foam, thermal vent, signal needle, baton capacitor, drone rotor, brace plate, archive key, Dashcut, Tether Pulse, Brace Shield, and signal/static effects. Fix the inventory tab wrapping issue while preserving fixed-grid mobile layout. Do not leave broadsword, buckler, sack, potion, or generic fire as final captured icons.
  Parallelization: Can parallel Y | Wave 2 | Blocks 11, 12, 13
  References (executor has NO interview context - be exhaustive): `STORY_BIBLE.md:107-134`, `STORY_BIBLE.md:175-179`, `DESIGN.md:68-87`, `scripts/ui/app_shell.gd:11-20`, `scripts/ui/app_shell.gd:464-470`, `scripts/ui/app_shell.gd:632-638`, `docs/screenshots/inventory.png`, `docs/art-direction-new-ilhwa.md`
  Acceptance criteria (agent-executable): `git grep -n "icon_broadsword\\|icon_buckler\\|icon_hp_potion\\|icon_mp_potion\\|icon_sack\\|fx_fire" -- scripts/ui/app_shell.gd docs/visual-qa.md CREDITS.md` returns no final runtime usage; inventory screenshot has no wrapped `Consumables` tab and no fantasy item icon set.
  QA scenarios (name the exact tool + invocation): Godot capture plus static grep; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-10-icons-inventory.log` and `inventory.png`.
  Commit: Y | feat(assets): add New Ilhwa icons and effects | Files `assets/new_ilhwa/runtime/*`, `assets/licenses/*`, `ASSET_LEDGER.md`, `scripts/ui/app_shell.gd`

- [ ] 11. Regenerate runtime screenshots with before/after evidence
  What to do / Must NOT do:
  Before overwriting screenshots, copy existing `docs/screenshots/*.png` into `.omo/evidence/new-ilhwa-asset-overhaul/before/`. Run the capture tool, then copy regenerated screenshots and capture logs into `.omo/evidence/new-ilhwa-asset-overhaul/after/`. Confirm title, intro, exploration, dialogue, combat, boss, victory, inventory, settings, credits, and combat-landscape all exist and are non-empty. Do not rely on screenshots without archiving before/after evidence.
  Parallelization: Can parallel N | Wave 2 | Blocks 12, 13
  References (executor has NO interview context - be exhaustive): `tools/capture_ui_states.gd:3-18`, `tools/capture_ui_states.gd:46-82`, `docs/screenshots/title.png`, `docs/screenshots/exploration.png`, `docs/screenshots/combat.png`, `docs/screenshots/boss.png`, `docs/screenshots/inventory.png`
  Acceptance criteria (agent-executable): `GODOT_BIN="$GODOT_BIN" "$GODOT_BIN" --headless --path . --script res://tools/capture_ui_states.gd > .omo/evidence/new-ilhwa-asset-overhaul/task-11-capture.log 2>&1` prints `VISUAL_CAPTURE_OK`; `find .omo/evidence/new-ilhwa-asset-overhaul/before .omo/evidence/new-ilhwa-asset-overhaul/after -name '*.png' | wc -l` is at least 22.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` copy/capture/check sequence; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-11-capture.log`, `before/`, `after/`.
  Commit: Y | test(visual): capture New Ilhwa runtime screens | Files `docs/screenshots/*.png`, `.omo/evidence/new-ilhwa-asset-overhaul/*` if evidence is committed by project convention; otherwise evidence remains untracked.

- [ ] 12. Retire Diamond preview and clean stale visual docs
  What to do / Must NOT do:
  Delete or replace `docs/screenshots/assets-preview.png` with a New Ilhwa-only board after replacement screenshots pass. Update `docs/visual-qa.md`, `CREDITS.md`, `ASSET_LEDGER.md`, and `docs/asset-candidate-board.md` so they no longer describe Diamond as final runtime art. Handle `docs/screenshots/reference-combat.png` by replacing it with New Ilhwa combat reference or explicitly marking it historical. Do not remove the Dotmancer license proof while any Diamond files remain in the repo.
  Parallelization: Can parallel N | Wave 2 | Blocks 13, 14
  References (executor has NO interview context - be exhaustive): `docs/asset-candidate-board.md:3-38`, `CREDITS.md:1-20`, `ASSET_LEDGER.md:31-51`, `docs/visual-qa.md:1-20`, `docs/screenshots/assets-preview.png`, `docs/screenshots/reference-combat.png`, `assets/licenses/diamond-top-down-pixel-art-LICENSE.txt`
  Acceptance criteria (agent-executable): `git grep -n "Diamond sprites\\|Diamond tile assets\\|task-9-screenshot-contact-sheet-diamond\\|assets-preview.png" -- docs CREDITS.md ASSET_LEDGER.md` finds no stale final-runtime claim; if Diamond files remain, `test -s assets/licenses/diamond-top-down-pixel-art-LICENSE.txt` still passes.
  QA scenarios (name the exact tool + invocation): Static grep plus visual file existence checks; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-12-doc-cleanup.log`.
  Commit: Y | docs(visual): retire Diamond preview artifacts | Files `docs/visual-qa.md`, `docs/asset-candidate-board.md`, `CREDITS.md`, `ASSET_LEDGER.md`, `docs/screenshots/*`

- [ ] 13. Run full New Ilhwa QA and fix every failure
  What to do / Must NOT do:
  Run the full QA runner with `GODOT_BIN`, the new art guard, asset audit, route tests, gameplay tests, screenshot capture, and static final-art assertions. Fix every failure in the owning task area. Do not weaken tests or visual checks. If a command cannot run because Godot is not installed, resolve the local Godot dependency rather than declaring visual work done.
  Parallelization: Can parallel N | Wave 3 | Blocks 14
  References (executor has NO interview context - be exhaustive): `tools/run_full_qa.sh:45-55`, `tools/validate_content.gd:3-22`, `tests/run_route.gd:25-122`, `tests/run_gameplay_scenario.gd:20-191`, `tools/audit_assets.gd:80-88`, `tools/capture_ui_states.gd:72-82`, `tools/*art*guard*`
  Acceptance criteria (agent-executable): `GODOT_BIN="$GODOT_BIN" bash tools/run_full_qa.sh > .omo/evidence/new-ilhwa-asset-overhaul/task-13-full-qa.log 2>&1` prints `FULL_QA_OK`; the log also contains every required pass marker listed in Verification strategy.
  QA scenarios (name the exact tool + invocation): Full QA runner and pass-marker grep; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-13-full-qa.log`.
  Commit: Y | test(qa): verify New Ilhwa asset overhaul | Files only as needed for fixes from failed QA

- [ ] 14. Final self-review and scope fidelity audit
  What to do / Must NOT do:
  Re-read this plan, the diff, generated docs, manifest, asset registry, screenshots, and QA logs. Confirm every must-have is met, every must-not-have is respected, all evidence paths exist, and no unrelated user changes were reverted. Produce a concise final evidence ledger in `.omo/evidence/new-ilhwa-asset-overhaul/final-summary.md`. Do not declare completion while any plan checkbox is incomplete or any final QA marker is missing.
  Parallelization: Can parallel N | Wave 3 | Blocks final verification
  References (executor has NO interview context - be exhaustive): `.omo/plans/new-ilhwa-asset-overhaul.md`, `.omo/drafts/new-ilhwa-asset-overhaul.md`, `.omo/evidence/new-ilhwa-asset-overhaul/`, `git status --short`, all changed files
  Acceptance criteria (agent-executable): `test -s .omo/evidence/new-ilhwa-asset-overhaul/final-summary.md`; final summary lists each todo, evidence path, pass/fail state, and any remaining risk. `git status --short` contains only intentional changes.
  QA scenarios (name the exact tool + invocation): `mcp__git_bash.run` with final summary checks and `git status --short`; Evidence `.omo/evidence/new-ilhwa-asset-overhaul/task-14-final-review.log`.
  Commit: Y | docs(plan): record New Ilhwa asset evidence | Files `.omo/evidence/new-ilhwa-asset-overhaul/final-summary.md`

## Final verification wave (after ALL todos)
> Runs in parallel. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [ ] F1. Plan compliance audit
  Verify every todo acceptance criterion has evidence and no scope item is skipped.
- [ ] F2. Code quality review
  Review GDScript/runtime changes for maintainability, no duplicate asset maps, no silent missing texture failures, no unrelated refactors.
- [ ] F3. Real manual QA
  Inspect the regenerated screenshots in `.omo/evidence/new-ilhwa-asset-overhaul/after/` and `docs/screenshots/` for New Ilhwa story fit, readability, no clipping, mobile touch safety, no fantasy/Diamond motifs.
- [ ] F4. Scope fidelity
  Confirm the work only changes planning/docs/assets/runtime wiring needed for this asset overhaul and leaves unrelated gameplay expansion out.

## Commit strategy
- Use atomic Conventional Commits.
- Suggested commit sequence:
  1. `chore(qa): make Godot asset QA portable`
  2. `docs(assets): approve New Ilhwa art direction`
  3. `docs(art): define New Ilhwa visual bible`
  4. `docs(assets): map story IDs to production art`
  5. `refactor(ui): centralize runtime asset registry`
  6. `test(assets): guard final art direction`
  7. `feat(assets): add New Ilhwa environment tiles`
  8. `feat(assets): add Relay rig silhouettes`
  9. `feat(assets): add municipal enemy silhouettes`
  10. `feat(assets): add New Ilhwa icons and effects`
  11. `test(visual): capture New Ilhwa runtime screens`
  12. `docs(visual): retire Diamond preview artifacts`
  13. `test(qa): verify New Ilhwa asset overhaul`
- Final commit footer when committing plan-driven work: `Plan: .omo/plans/new-ilhwa-asset-overhaul.md`

## Success criteria
- The final runtime screenshots no longer look like a fantasy grass-grid prototype.
- Title/exploration/combat/boss/inventory screens visibly communicate New Ilhwa, CIVIC MIND, Relay couriers, municipal robots, memory shards, repair districts, service rails, and the Sealed Clinic.
- Actors/enemies remain readable in 1080x1920 portrait and 1920x1080 landscape captures.
- The asset registry does not select `res://assets/diamond/runtime` for final captured states.
- `docs/screenshots/assets-preview.png` is retired/replaced and stale Diamond visual QA claims are gone.
- All imported/generated runtime assets are ledgered, licensed/provenanced, and pass `ASSET_AUDIT_OK`.
- `tools/run_full_qa.sh` is portable and the final log contains `FULL_QA_OK`.
- No external reference media is copied, traced, recolored, or committed.
