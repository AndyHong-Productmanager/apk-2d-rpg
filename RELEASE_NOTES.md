# v0.1.0

Initial public APK release for **APK 2D RPG**, a Lazycodex-built Godot 4.7 2D action RPG vertical slice.

## Included

- Android debug APK: `apk-2d-rpg-debug.apk`
- Title, intro, exploration, dialogue, combat, boss, inventory, settings, credits, and victory screens
- 2038 AGI robot-era story bible and Chapter 1 content model
- Full QA script and input-driven playthrough capture
- Visual QA screenshots attached to this release
- HTML5 export for browser smoke QA

## Verification

- Full QA passed through `tools/run_full_qa.sh`
- APK package: `com.lazycodex.apk2drpg`
- APK signatures: v2 true, v3 true
- APK alignment: verification successful
- targetSdk: `36`

## Notes

This is a debug-signed APK for public testing. Play Store production release still requires a release keystore, store listing, privacy review, and real device matrix QA.
