# Design System

This project is reference-board-first. No gameplay screens, production UI screens, or runtime assets should be implemented before the design board and asset ledger are accepted.

## Source Inputs

- `docs/reference-study.md` defines the abstract screen rules, density targets, hierarchy, and mobile constraints.
- `ASSET_LEDGER.md` defines asset intake rules. Use approved CC0-first sources, save license proof before import, and do not commit unlicensed preview media.
- External reference media is linked only. Do not copy, trace, recolor, or import reference screenshots, logos, sprites, store capsules, videos, or press kit art.

## Baseline

- Target orientation: portrait.
- Design viewport: 1080 x 1920.
- Protected play lane: center 60 percent of the screen.
- Primary touch target: at least 88 x 88 px.
- Touch spacing: at least 16 px.
- Dialogue internal padding at baseline: 16 px.
- Rendering intent: crisp 2D pixels with nearest filtering by default.

## Layout Rules

- Persistent HUD belongs in the top safe strip and bottom thumb zones.
- Bottom left is reserved for movement.
- Bottom right is reserved for dodge, guard, and three skill actions.
- The center play lane must stay free of permanent widgets.
- Top left carries survival resources.
- Top right carries objective, route, or map hints.
- Dialogue uses a stable bottom panel with speaker identity and two to three short lines.
- Inventory, map, and upgrade surfaces must use fixed grids or lanes instead of text-heavy layouts.

## Tokens

### Spacing

| token | value | use |
| --- | ---: | --- |
| `space_1` | 4 px | hairline offsets |
| `space_2` | 8 px | compact groups |
| `space_3` | 16 px | panel padding and touch separation |
| `space_4` | 24 px | section gaps |
| `space_5` | 32 px | major panel gutters |

### Shape

| token | value | use |
| --- | ---: | --- |
| `radius_panel` | 8 px | framed UI panels |
| `radius_chip` | 4 px | item state and rarity chips |
| `stroke_hairline` | 1 px | low-priority separators |
| `stroke_focus` | 2 px | focus, selected, and danger outlines |

### Color Roles

| role | value | use |
| --- | --- | --- |
| `ink` | `#151820` | primary text and dark silhouettes |
| `paper` | `#F2F0E6` | light text or panel foreground |
| `panel` | `#202633` | dialogue and menu panels |
| `health` | `#D94444` | HP and lethal damage |
| `energy` | `#35A7D8` | stamina, timing, and defensive prompts |
| `warning` | `#E5A137` | heavy attack anticipation |
| `status` | `#8E56C5` | corruption, poison, or abnormal status |
| `success` | `#56B870` | recover, save, or accepted action |

## Screen-Specific Rules

### HUD

- Use three priorities: survival resources, current objective, temporary combat prompts.
- Resource bars must differ by shape as well as color.
- Cooldowns use radial or shrinking fill states; numeric text is for long timers only.

### Combat Telegraphs

- Heavy attacks require an anticipation marker before the hit frame.
- Damage uses red or amber circles, cones, lanes, or rings.
- Defensive or timing windows use cyan.
- Status or corruption uses purple.
- Markers must remain readable over particles and dense floors.

### Inventory

- Categories come first, items second, details third.
- Tabs are Gear, Consumables, Shards, Quest, and Archive.
- Item cards show icon, name, count, rarity, and one primary stat.
- Destructive actions require a confirm state.

### Map

- Chapter maps use nodes and corridors.
- Main objectives use diamonds.
- Optional routes use circles.
- Locked gates use bars.
- Save or fast-travel nodes use square beacons.

### Upgrade UI

- Each playable rig has three lanes: attack, defense or mobility, and utility.
- Nodes show cost, rank, preview, and prerequisite state.
- Shared account upgrades are visually separated from rig-specific skills.

## Asset Rules

- Approved assets must be recorded in `ASSET_LEDGER.md` before import.
- Save source URL, author, license, commercial use, APK redistribution, public repository redistribution, modification permission, attribution, and original source commit status.
- Prefer Kenney CC0 sources for first implementation.
- Block non-commercial, no-derivatives, share-alike, unclear paid, copied, traced, or franchise-derived assets.

## Current Scaffold Boundary

- This scaffold may contain a boot scene, autoload folders, export placeholders, and validation or capture tool skeletons.
- It must not contain gameplay systems, production UI screens, imported art, copied reference material, or unrecorded assets.
