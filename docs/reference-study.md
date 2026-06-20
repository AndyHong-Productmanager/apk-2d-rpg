# APK 2D RPG Reference Study

Wave 0 Todo 1 output for the original APK 2D RPG. This study uses official, Steam, and press kit pages as visual references only. No screenshots, preview images, logos, sprites, text passages, or page assets are stored in this repository.

## Source Table

| Reference | Source | Access | Useful screens | Extracted Rule | Applied to this game |
| --- | --- | --- | --- | --- | --- |
| CrossCode | https://www.radicalfishgames.com/presskit/sheet.php?p=crosscode | Official press kit | Combat, puzzles, equipment, upgrade tree | Fast HUD and effect layers can be dense when enemy, projectile, and player silhouettes remain separated by value and outline. | Keep the player centered in combat, reserve bright color for threats and skill feedback, and make puzzle objects readable at one glance. |
| Hyper Light Drifter | https://www.heartmachine.com/hyper-light-drifter | Official page | Exploration, combat, title, upgrade fantasy | Minimal words, high-contrast silhouettes, and sparse HUD create a premium action feel. | Use quiet exploration UI, reveal danger through animation and color, and keep title menus spare with one strong focal image. |
| UNSIGHTED | https://store.steampowered.com/app/1062110/UNSIGHTED/ | Steam page | Combat, map, upgrade chips, exploration | Top-down action needs readable route options, short telegraph windows, and build choices that fit one screen. | Boss and elite attacks use colored ground telegraph shapes, inventory chips fit into a compact portrait grid, and map doors mark locked, optional, and main paths. |
| Children of Morta | https://playdigious.com/press/sheet.php?p=children_of_morta and https://store.steampowered.com/app/330020/Children_of_Morta/ | Mobile press kit and Steam page | Character select, combat, family upgrades, mobile UI | Distinct playable characters need unique combat silhouettes, upgrade lanes, and readable mobile controls. | The three playable rigs must have different attack arcs, movement tells, portrait cards, and upgrade rows. |
| Sea of Stars | https://sabotagestudio.com/presskits/sea-of-stars/ | Official press kit | Dialogue, turn prompts, map traversal, title | Rich pixel scenes support dense UI only when text boxes and prompts use strong panels and consistent margins. | Dialogue uses a bottom panel with speaker portrait, short lines, and no overlap with interactables or mobile controls. |
| Eastward | https://eastwardgame.com/ | Official page | Dialogue, town exploration, duo puzzles, cooking/reward UI | Dense towns feel alive through layered props, NPC clustering, and clear interaction markers. | Exploration maps use dense set dressing around safe zones but keep combat lanes clear and mark talk/search/use points with one icon language. |
| Cassette Beasts | https://www.cassettebeasts.com/presskit/ | Official press kit | Companion, inventory, creature roster, battle choice UI | Collection-heavy RPGs need sorting, compact cards, and relationship/status information without covering the field. | Inventory and roster screens use tabs, rarity/status chips, and short item verbs rather than long descriptions in the first layer. |
| TUNIC | https://tunicgame.com/ and https://finji.co/games/tunic/ | Official pages | Title, map/manual, exploration, item discovery | Mystery can be guided with spatial landmarks instead of tutorial text. | Map screens show landmarks and route symbols; early title and intro avoid lore dumps and teach through item placement. |
| Moonlighter | https://store.steampowered.com/app/606150/Moonlighter/ | Steam page | Inventory, shop/reward loop, dungeon combat | Loot games benefit from strict inventory slots, value cues, and immediate post-run reward review. | Backpack is a fixed grid with stack/value markers, quick compare, and a result screen after dungeon or boss rewards. |
| Guardian Tales | https://guardiantales.com/ and https://play.google.com/store/apps/details?id=com.kakaogames.gdts | Official and mobile store pages | Mobile portrait HUD, stage map, puzzle/combat, touch controls | Mobile action RPGs need thumb-safe controls, large buttons, and HUD that avoids the center play lane. | Portrait layout reserves bottom corners for movement/skills, top strip for resources/objectives, and the middle 60 percent for play. |

## Screenshot Capture Method

- Source pages were opened only as reference material from official, Steam, or press kit locations.
- No remote images were downloaded into the repository.
- If later visual boards are needed, store only original game screenshots from our Godot runtime under `docs/screenshots/`; external reference art remains linked, not copied.
- Any manual screenshot used for private comparison must stay outside committed game assets and must not be traced, recolored, or imported.

## Visual Rules

### HUD

Rule:
- Keep persistent HUD to the top safe strip and bottom touch zones.
- Use three priority levels: survival resources, current objective, and temporary combat prompts.
- Resource bars must be distinguishable by shape as well as color.
- Cooldowns use radial or shrinking fill states with numeric text only for long timers.

Applied:
- Portrait gameplay uses HP/energy/status at top left, objective/map hint at top right, virtual stick bottom left, and three skill buttons plus dodge/guard bottom right.
- Landscape capture keeps the same hierarchy but widens the objective strip instead of adding more widgets.

### dialogue

Rule:
- Use a stable bottom panel, speaker portrait/name, and two to three short text lines.
- Important verbs should appear as button prompts, not paragraph text.
- Dialogue must never cover the player, active enemy telegraph, or required interaction marker.

Applied:
- Story scenes place dialogue in a bottom panel with 16 px internal padding at 1080x1920.
- NPC bark text is one-line overhead only outside combat.
- Long lore is split into pages with a visible continue affordance.

### Combat telegraph

Rule:
- Every enemy attack with meaningful damage needs a telegraph before the hit frame.
- Telegraph language must be consistent: red or amber for damage, cyan for interactable or defensive timing, purple for status or corruption.
- Ground markers should be simple circles, cones, lanes, or rings and must outlive the anticipation animation long enough to react.

Applied:
- Standard enemies use 250-450 ms attack warnings; bosses use 550-900 ms warnings plus animation wind-up.
- The telegraph fades after impact but does not hide under particles.
- If the arena is visually dense, attack zones get a dark outline or dimmed floor mask.

### Inventory

Rule:
- Inventory must be scannable as categories first, items second, details third.
- Use fixed slots, rarity/status chips, stack counts, and clear equip/consume/drop verbs.
- Avoid full-screen text walls on mobile.

Applied:
- Inventory uses tabs for Gear, Consumables, Shards, Quest, and Archive.
- Item cards show icon, name, count, rarity, and one primary stat.
- Details open in a side or bottom panel; destructive actions require a confirm state.

### Title

Rule:
- Title screens should establish genre and tone in the first viewport.
- Main actions need predictable order: Continue, New Game, Settings, Credits, Quit where platform allows.
- Avoid a marketing layout; the title is the playable entry point.

Applied:
- Title art shows the original city/runner conflict, not borrowed key art.
- Continue is disabled only when no save exists and includes a clear inactive state.
- Android builds replace Quit with Back/Exit behavior consistent with the platform.

### Map

Rule:
- Maps must distinguish current room, objective route, optional route, locked route, and fast-travel/save nodes.
- Icons need shape differences, not only color differences.
- The active objective should be visible without panning when the player opens the map.

Applied:
- The first chapter map uses nodes connected by corridors rather than a full noisy minimap.
- Main quest markers use diamond icons, side quests use circles, locked gates use bars, and save rooms use a square beacon.

### Upgrade UI

Rule:
- Upgrade screens need readable dependencies, cost, preview, and confirmation.
- Character identity should remain visible while browsing upgrades.
- Show locked choices early, but never make the tree look larger than actual content.

Applied:
- Each rig has three upgrade lanes: core attack, defense/mobility, and utility.
- Nodes show cost, current rank, next-rank effect, and locked prerequisite.
- Shared account upgrades are visually separated from rig-specific skills.

### Visual Density

Rule:
- Exploration may be dense at the edges; combat lanes must be sparse enough to read movement and attacks.
- Important sprites need value contrast against floor tiles.
- Particles should confirm hits, not bury the actors.

Applied:
- Safe hubs can use 70-85 percent prop density around walls and stalls.
- Combat rooms keep the central movement lane below 35 percent prop coverage.
- Boss arenas reserve at least one full dodge lane in portrait view.

### Mobile Portrait Constraints

Rule:
- The center play lane is protected space.
- Touch targets should be large, separated, and reachable by thumbs.
- Critical text must fit without scaling by viewport width.

Applied:
- Baseline is 1080x1920 portrait.
- Primary touch targets are at least 88x88 px with 16 px minimum spacing.
- Text panels use fixed readable sizes, wrapping, and page breaks instead of tiny type.
- The camera favors vertical anticipation: enemies and objectives are framed above the player when possible.

## Gameplay/UI Takeaways

1. Combat readability wins over decorative detail. CrossCode, Hyper Light Drifter, UNSIGHTED, and Children of Morta all rely on clean silhouettes during fights.
2. Dialogue and world detail should carry character. Eastward and Sea of Stars show that dense scenes need stable text containers and consistent interaction prompts.
3. Upgrade and inventory systems must be compact. CrossCode, UNSIGHTED, Cassette Beasts, Moonlighter, and Children of Morta all point toward categorized, preview-first UI.
4. Mobile needs its own layout. Guardian Tales and the Children of Morta mobile press kit make portrait controls a first-class design constraint, not a late overlay.
5. The title and map should teach tone and direction before the player reads a tutorial. Hyper Light Drifter and TUNIC support sparse, symbolic guidance.

## Original Application Rules

These are the binding rules for the original APK 2D RPG:

- HUD: One persistent top strip and two bottom thumb zones; no permanent widgets in the center 60 percent of the play area.
- dialogue: Bottom panel, speaker portrait, short lines, clear continue marker, and no overlap with combat or required interaction markers.
- Combat telegraph: All heavy attacks have visible anticipation, colored ground shape, and readable impact timing.
- Inventory: Five tabs, fixed grid, concise item cards, and a separate details panel for equip/consume/compare actions.
- Title: Original key scene, save-aware menu state, and no borrowed logos, layouts, or art.
- Map: Node-and-corridor structure for chapter one with distinct icon shapes for main, optional, locked, and save routes.
- Upgrade UI: Three lanes per playable rig, visible costs, rank preview, and prerequisite state.
- Visual density: Dense hubs, sparse combat center, readable actor value contrast, and particles capped during high-risk attacks.
- Mobile portrait: 1080x1920 baseline, 88x88 px minimum touch targets, protected center lane, and objective information in the top strip.

## Prohibited Copying/Asset Use

- Do not import reference screenshots, logos, sprites, store capsules, videos, UI images, or press kit art into game scenes.
- Do not trace or recolor reference art to create production assets.
- Do not crawl restricted pages or ignore robots directives.
- Do not use preview media as game assets unless a separate asset license explicitly grants redistribution and modification rights.
- Do not copy game-specific names, lore, character designs, UI icon shapes, or layout compositions closely enough to imply derivation.
- Use these references only to derive abstract screen rules, density targets, hierarchy, and mobile constraints.

## Acceptance Checklist

- [x] 8-12 accessible references included.
- [x] Required references included: CrossCode, Hyper Light Drifter, UNSIGHTED, Children of Morta, Sea of Stars, Eastward, Cassette Beasts.
- [x] Extra top-down/mobile RPG references included: TUNIC, Moonlighter, Guardian Tales.
- [x] Source URLs recorded.
- [x] HUD, dialogue, combat telegraph, inventory, title, map, upgrade UI, visual density, and mobile portrait constraints covered.
- [x] Applied rules for the original game recorded.
- [x] External media is linked only and not stored.
- [x] Prohibited copying and asset-use guardrails recorded.
