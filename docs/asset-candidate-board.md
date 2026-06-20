# Asset Candidate Board

Status: asset direction reset. The previous mixed free-asset preview was rejected and must not be used as final art direction.

Current preview artifact: `docs/screenshots/assets-preview.png`

Current tested pack: `Diamond - Top Down Pixel Art Pack` from itch.io. This is a coherent 32x32 RPG pack, but it is fantasy-biased. Andy should approve only if this style is acceptable as the base style after cyberpunk recolor/reskin work.

## Decision Rule

Use one coherent art family first, then add only compatible packs. Do not mix random CC0 packs into a final-looking screenshot.

## Recommended Shortlist

| rank | pack | why it is here | risk | link |
| --- | --- | --- | --- | --- |
| 1 | Diamond - Top Down Pixel Art Pack | 32x32 top-down RPG starter with animated player characters, animated monsters, UI, icons, tiles, and a Godot example project. Best fit for a coherent vertical slice. | Fantasy-biased, not cyberpunk; would need recolor/setting adaptation. | https://dotmancer.itch.io/diamond-top-down-pixel-art |
| 2 | Pixel Art Top Down - Basic | Cohesive 32x32 top-down base by Cainos. Good for prototype-to-polish consistency. | Basic/free pack may not include enough human character variety alone. | https://cainos.itch.io/pixel-art-top-down-basic |
| 3 | Modern Interiors / Modern Exteriors by LimeZu | Strong modern human-scale tiles, interiors, props, and city-like spaces. Good for 2038 AGI city if paired with a matching character pack. | Paid packs; license and redistribution must be checked before commit. | https://limezu.itch.io/ |
| 4 | RPG Top Down Character Pack by HammerStrike | 32x32 top-down character pack with more human/game-character look. | Paid; must verify license and pair with matching tiles/monsters. | https://hammerstrike.itch.io/rpg-top-down-character-pack |
| 5 | Rogue Noir / Cyberpunk Assetpack | Dark cyberpunk direction closer to the 2038 AGI setting. | Need license check and style compatibility with top-down gameplay. | https://itch.io/game-assets/tag-cyberpunk |
| 6 | Mega Pack Top Down Monsters | Large top-down enemy roster for real combat variety. | Paid; likely needs style adaptation to chosen base pack. | https://itch.io/game-assets/tag-monsters/tag-top-down |

## Current Recommendation

Start with `Diamond - Top Down Pixel Art Pack` for the vertical slice if Andy wants a cohesive free path.

If Andy wants a more modern/cyberpunk/human look, use a paid direction:

1. `LimeZu` for modern city/interior tiles.
2. `HammerStrike RPG Top Down Character Pack` or another 32x32 character pack for humans.
3. A matching monster/robot pack only after the character/tile style is approved.

## Approval Gate

Do not continue Todo 8 or import final gameplay art until Andy approves one of these directions.

After approval, import selected runtime assets from the chosen pack only. If Diamond is rejected, delete `docs/screenshots/assets-preview.png` and select a more modern/cyberpunk paid pack before making a new preview.
