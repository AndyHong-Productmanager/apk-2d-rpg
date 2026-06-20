# New Ilhwa Asset Overhaul Draft

status: approved
pending_action: write .omo/plans/new-ilhwa-asset-overhaul.md
approval_received: 2026-06-20
created: 2026-06-20
mode: ulw-plan

## User Request

The user rejected the current assets as amateur placeholder work and wants a real, high-quality 2D RPG asset direction. The plan must inspect the screenshots, research strong references, and create an executable asset-production plan that fits the game's story.

## Classification

Architecture-scale planning.

Facts:
- The request spans art direction, source/reference research, asset intake, story fit, UI/gameplay screenshots, and future production workflow.
- Current art touches multiple surfaces: world, characters, enemies, icons, title, dialogue, combat, inventory, and asset licensing.
- The user explicitly asked for a plan and signaled high quality expectations.

## Grounded Findings

### Story and Required Art Identity

- `STORY_BIBLE.md:5-9` defines the real fantasy: 2038 New Ilhwa, CIVIC MIND, memory suppression, Relay couriers, and grounded human agency inside a machine-run city.
- `STORY_BIBLE.md:13-19` requires a dense Pacific megacity over subway, port, semiconductor repair districts, rooftop rails, decommissioned transit tunnels, memory shards, and municipal robots.
- `STORY_BIBLE.md:44-105` gives three visually distinct playable rigs:
  - Mira: kinetic courier, rail batons, phase slide, fast route identity.
  - Jun: signal weaver, spool projector, Kite drone, consent/medical-bot history.
  - Sera: anchor mender, rescue maul, brace shield, disaster-response exosuit.
- `STORY_BIBLE.md:138-173` defines enemies and bosses that need robot/AGI silhouettes, not fantasy monsters:
  - Custodian Sweeper, Lane Sentinel, Patch Spider, Archive Mote, Debt Runner, Plated Bailiff, Null Scribe, Route Hound.
  - Vigilant Matron as converted hospital logistics rig.
  - Glass Bailiff IX as mobile courtroom/adjudicator platform.
- `STORY_BIBLE.md:198-210` defines Chapter 1 locations to cover in the art pass: Switchyard 12, Neon Repair Market, Service Rail East, Sealed Clinic, Rainline Underpass, Archive Convoy Wreck, Debt Gate, Hall of Records, Switchyard Return.

### Current Asset Problem

- `docs/asset-candidate-board.md:3-8` already says the previous mixed preview was rejected and that Diamond is fantasy-biased.
- `docs/asset-candidate-board.md:11` correctly states the core rule: one coherent art family first, no random CC0 mixing.
- `scripts/ui/app_shell.gd:11-20` and `scripts/ui/app_shell.gd:44-50` hardcode the current UI/world textures to `assets/diamond/runtime`.
- Current committed runtime asset inventory is only 14 Diamond PNGs:
  - `player_male.png`, `player_female.png`, `enemy_boar.png`, `tile_grass.png`, `tile_props.png`
  - 3 skill icons, 5 item/equipment icons, and `fx_fire.png`
- Screenshots inspected:
  - `docs/screenshots/assets-preview.png`: coherent pack board but fantasy/forest/boar, not New Ilhwa.
  - `docs/screenshots/title.png`: repeated grass grid and placeholder title/menu, no original key scene.
  - `docs/screenshots/exploration.png`: sparse market on generic grass-grid floor; no megacity or repair district identity.
  - `docs/screenshots/combat.png`: readable telegraph geometry, but enemy/arena art is mostly abstract over a fantasy tile repeat.
  - `docs/screenshots/boss.png`: boss fight is rings/lanes plus tiny boar-like sprites, not a hospital logistics rig.
  - `docs/screenshots/dialogue.png`: text panel works, but scene storytelling is thin.
  - `docs/screenshots/inventory.png`: icon set is fantasy consumables/equipment and the tab layout has awkward wrapping.

### Existing Constraints

- `DESIGN.md:3-9` says the project is reference-board-first, external media must only be linked, and no reference screenshots/sprites/logos may be copied, traced, recolored, or imported.
- `DESIGN.md:13-30` fixes mobile portrait constraints: 1080x1920 baseline, center 60 percent protected play lane, top HUD, bottom thumb zones.
- `DESIGN.md:74-80` requires combat telegraphs to remain readable over dense floors.
- `DESIGN.md:82-101` requires inventory, map, and upgrade readability via fixed grids/lanes.
- `DESIGN.md:103-108` and `ASSET_LEDGER.md:5-27` require ledgered assets, source URLs, license proof, commercial/APK/public-repo redistribution, modification permissions, and no unsafe preview media.
- `ASSET_LEDGER.md:21-27` prefers CC0/Kenney first, but the current quality target justifies a custom/original production pass plus license-verified candidates.
- `ASSET_LEDGER.md:53-63` blocks NC, ND, share-alike, unclear paid, preview-image, ripped, traced, franchise-derived, or AI-recreated sources.

## External Reference Research

References are visual/UX study only. Do not copy their art, UI compositions, logos, character designs, or screenshots into the repo.

1. CrossCode official press kit
   - Source: https://www.radicalfishgames.com/presskit/sheet.php?p=crosscode
   - Relevant facts: 16-bit action RPG, distant-future/sci-fi story, detailed animation, fast combat, puzzles, equipment, skill trees.
   - Extracted rules: readable silhouettes during dense action; combat effects can be bright if actors stay separated by value; RPG systems need compact, visual upgrade/inventory surfaces.

2. UNSIGHTED Steam page
   - Source: https://store.steampowered.com/app/1062110/UNSIGHTED/
   - Relevant facts: ruined city, Automatons, top-down action RPG, exploration, rich combat, crafting/upgrades, timed parry identity.
   - Extracted rules: robot identity must be readable through silhouettes and combat roles; city exploration needs routes/shortcuts, not just tile decoration.

3. Hyper Light Drifter official page
   - Source: https://www.heartmachine.com/hyper-light-drifter
   - Relevant facts: action adventure RPG, hand-animated characters/background elements, rare HUD, branching secrets.
   - Extracted rules: sparse HUD and strong focal silhouettes feel premium; every animation should sell intent, not just movement.

4. Eastward official page
   - Source: https://eastwardgame.com/
   - Relevant facts: vibrant cities, small-town life, dense character/world storytelling, combat/puzzles.
   - Extracted rules: prop density should tell the place's social function; NPC clusters and environmental objects carry story.

5. SIGNALIS Steam page
   - Source: https://store.steampowered.com/app/1262350/SIGNALIS/
   - Relevant facts: dystopian future, surveillance/propaganda, android workers/civil servants, identity and memory themes, retrotech mood.
   - Extracted rules: memory/AGI themes need visual language beyond neon: signage, warning labels, institutional panels, cold lighting, propaganda, corrupted record motifs.

6. Guardian Tales official and Google Play pages
   - Sources: https://guardiantales.com/ and https://play.google.com/store/apps/details?id=com.kakaogames.gdts
   - Relevant facts: mobile pixel adventure RPG, puzzle/action, large readable character roster, high download count.
   - Extracted rules: portrait mobile RPG needs exaggerated readable actors, thumb-safe combat controls, and instantly legible skills.

7. Kenney RPG Urban Pack / Top-down Shooter
   - Sources: https://kenney.nl/assets/rpg-urban-pack and https://kenney.nl/assets/top-down-shooter
   - Relevant facts: CC0, 16x16 urban/top-down packs; Kenney support says asset-page game assets are CC0 and commercial use is allowed.
   - Extracted role: license-safe blockout and emergency fallback, not the final premium look by itself.

8. LimeZu Modern Interiors / Modern Exteriors
   - Sources: https://limezu.itch.io/moderninteriors and https://limezu.itch.io/modernexteriors
   - Relevant facts: modern top-down interiors/exteriors, hospitals/control rooms/city props, cars/trucks, Godot support/autotiles on exteriors, license permits commercial use but restricts redistribution and requires credit.
   - Extracted role: strong candidate/reference for modern city density, but paid/license terms mean no automatic public-repo source import.

9. Dotmancer Diamond
   - Source: https://dotmancer.itch.io/diamond-top-down-pixel-art
   - Relevant facts: cohesive 32x32 top-down starter kit, Godot example, fantasy/forest/boar content, CC0 asset license.
   - Extracted role: useful learning scaffold; reject as final art direction for New Ilhwa.

## Decisions and Defaults

- Default art direction: original "New Ilhwa retrotech municipal pixel art" rather than fantasy, generic cyberpunk, or random free-asset collage.
- Retire Diamond from final presentation. Keep it only as temporary scaffold until replacement assets are wired and verified.
- Production style target: crisp pixel art with a 16x16 tile grid and 32x32 to 64x64 actor readability, dark civic infrastructure base, teal/cyan signal accents, amber hazard markings, red lethal telegraphs, purple memory/static corruption.
- Asset creation strategy: build a small original vertical-slice kit first, then expand. Use external references for rules and mood only.
- Source-asset strategy: if a licensed pack is used, use it as either blockout or explicitly ledgered derivative runtime files only. Do not commit paid source archives. If license cannot prove public-repo redistribution, block it.
- Test strategy default: tests-after plus visual QA. Every production asset task should update/verify asset ledger, run the Godot asset audit, capture screenshots with `tools/capture_ui_states.gd`, and compare before/after screenshots for story fit and readability.
- No human QA dependency in the execution plan. The worker will capture artifacts under `.omo/evidence/`.

## Planned Approach Awaiting Approval

Write one executable plan at `.omo/plans/new-ilhwa-asset-overhaul.md` with these waves:

1. Define art bible and style board
   - Visual pillars, palette, tile scale, actor scale, silhouette language, prohibited motifs, reference-derived rules.
   - Deliverable: `docs/art-direction-new-ilhwa.md`.

2. Build asset manifest and naming map
   - Map story/content IDs to required runtime assets.
   - Deliverable: `docs/asset-production-manifest.md` and updated asset ledger plan entries.

3. Produce first vertical-slice environment set
   - Switchyard 12, Neon Repair Market, Service Rail East, Sealed Clinic.
   - Replace grass grid with industrial floor/rail/market/clinic tiles.

4. Produce actor/enemy silhouette set
   - Three rigs, core NPC silhouettes, eight enemies, Vigilant Matron, Glass Bailiff IX placeholder silhouette.
   - Prioritize gameplay readability before animation volume.

5. Produce UI icon and effect language
   - Battery gels, memory shards, repair scrip, baton capacitors, drone rotors, brace plates, archive keys, rig skills, telegraph effects.

6. Wire assets through Godot surface
   - Replace hardcoded Diamond texture paths with a story-named asset registry.
   - Keep fallback behavior until every screenshot route passes.

7. Capture and verify all screens
   - Regenerate title, intro, exploration, dialogue, combat, boss, inventory, settings, credits, victory, landscape combat.
   - Evidence includes screenshots and audit outputs.

8. Review, iterate, and remove rejected preview artifacts
   - Retire `docs/screenshots/assets-preview.png` if the plan fully rejects Diamond.
   - Keep license proof and credits consistent.

## Scope In

- Asset direction plan.
- Original game-specific asset bible.
- Asset/source licensing workflow.
- Runtime asset replacement plan.
- Godot screenshot/manual QA plan.
- Story-to-asset mapping for Chapter 1 vertical slice.

## Scope Out

- Buying paid packs.
- Importing reference screenshots.
- Copying/tracing/recoloring existing games' art.
- Full Chapter 1 content expansion beyond assets and visual wiring.
- Audio.
- Marketing art beyond title/key-scene direction.

## Open Ambiguities Resolved By Default

- Paid versus free: default to original/project-owned production assets; paid packs are optional candidates only after explicit license proof.
- Pixel resolution: default to 16x16 tiles with 32x32/64x64 actor readability because the existing pipeline and mobile layout support that scale.
- Test strategy: default to tests-after plus visual QA because this is primarily visual/game-surface work, but code wiring still needs Godot audit and route checks.
- Asset technology: default to PNG spritesheets and Godot Control/CanvasItem integration because the current project already uses PNG runtime assets and screenshot capture tooling.

## Approval Gate

Approval received to write `.omo/plans/new-ilhwa-asset-overhaul.md` using the approach above.

Approval confirms:
- Diamond is rejected as the final art direction.
- The final plan should target an original, story-specific New Ilhwa asset set.
- Tests-after plus screenshot visual QA is acceptable.
- Paid packs remain candidates only, not automatic purchases/imports.
