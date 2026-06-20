# Asset Import And Visual Normalization Pipeline

Wave 1 does not import external art yet. This pipeline defines the gate that every future asset import must pass before the files are committed to the repository or bundled into an APK.

## Source Of Truth

- `ASSET_LEDGER.md` records candidate sources, import decisions, and per-asset redistribution facts.
- `CREDITS.md` records required and optional credit text before any playable build includes the asset.
- `docs/license-audit.md` records blocked license classes and source conditions.
- `assets/licenses/` stores source page snapshots, bundled license files, or other proof for each imported asset.

An asset is not accepted unless the source URL, author, exact license, commercial use, APK redistribution, public repository redistribution, modification permission, attribution text, and source-file commit policy are all recorded.

## Repository Layout

```text
assets/
  licenses/
    <asset-id>.md
  <category>/
    <asset-id>.<runtime-extension>
```

Use lowercase kebab-case or snake_case filenames. Keep downloaded archives, purchase receipts, account-bound bundles, convenience zips, and source-store metadata out of Git unless the ledger explicitly says the original downloaded files may be publicly redistributed.

## Intake Steps

1. Choose an approved source from `ASSET_LEDGER.md` before searching for a replacement.
2. Save the source page snapshot or bundled license text under `assets/licenses/`.
3. Add a ledger row for the runtime asset path before committing the runtime file.
4. Add the exact required credit to `CREDITS.md` when the license requires attribution.
5. Convert assets into project-ready runtime files only after license proof is saved.
6. Run `tools/audit_assets.gd` and fix every reported blocker before staging the asset import.

## Blocked Source Patterns

Do not import files whose path, source proof, or ledger row indicates any of these conditions:

- preview image, thumbnail, screenshot, marketplace mockup, logo, watermark, or store branding
- ripped, traced, fan-art, franchise-derived, trademarked, or AI recreation source
- non-commercial, personal-use-only, educational-use-only, fan-use-only, no-derivatives, share-alike, GPL, or LGPL art terms
- paid pack without explicit APK redistribution, public repository redistribution, modification, and attribution terms

The audit script checks common blocked filename patterns so unsafe fixture files fail early. Human review still owns final source-page interpretation.

## Visual Normalization Rules

- Base tile scale is 16x16 pixels. Runtime tile and sprite sheets should have dimensions divisible by 16.
- Keep source art coherent with the accepted top-down pixel-art direction. Do not mix high-resolution painterly, photoreal, or UI-only styles into world tiles.
- Runtime texture dimensions must stay at or below 2048x2048 unless a specific ledger note explains the exception.
- Prefer indexed or limited palettes for tiles and sprites. The audit script warns through a failure when a texture exceeds 256 unique sampled colors.
- Keep transparent padding intentional. Crop excess transparent borders before committing runtime sheets.
- Preserve source files only when the license explicitly permits public repository redistribution.

## Audit Command

Run the passing check from the repository root:

```bash
/home/ubuntuhong/dev/.local-tools/bin/godot --headless --path /home/ubuntuhong/dev/apk-2d-rpg --script res://tools/audit_assets.gd
```

Run a negative fixture check when changing the audit script:

```bash
/home/ubuntuhong/dev/.local-tools/bin/godot --headless --path /home/ubuntuhong/dev/apk-2d-rpg --script res://tools/audit_assets.gd -- --extra-asset .omo/evidence/asset-fixture/unregistered.png
```

The audit prints `ASSET_AUDIT_OK` only when required documentation exists and no asset rule fails. It prints `UNREGISTERED_ASSET_DETECTED` and exits non-zero when an extra fixture or future asset file is not represented by the ledger.
