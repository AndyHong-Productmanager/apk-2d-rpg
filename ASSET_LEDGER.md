# Asset Ledger

Wave 0 uses a commercial-safe, repository-safe asset strategy: prefer CC0 assets with direct source pages, keep license proof beside every imported asset, and block any asset whose APK or public repository redistribution terms are not explicit.

## Required Ledger Fields

Every asset imported into the Godot project must have a row with these fields before the file is committed:

| field | required value |
| --- | --- |
| source URL | Permanent page for the asset, not a search page, collection page, image preview, or marketplace home page. |
| author | Public creator name shown on the source page or bundled license file. |
| license | Exact license name and version from the source page or bundled license file. |
| commercial-use status | Explicit yes/no statement for use in a commercial game. |
| APK redistribution status | Explicit yes/no statement for bundling modified or unmodified asset files inside the Android APK. |
| public repo redistribution status | Explicit yes/no statement for committing the asset or derived project-ready files to this public repository. |
| modification permission | Explicit yes/no statement for resizing, recoloring, slicing, format conversion, compression, or animation edits. |
| required attribution text | Exact credit line required by the license, or an optional credit line for CC0 assets. |
| original paid/download files allowed to be committed | Yes only when the license permits public redistribution of the original downloaded package; otherwise commit only derived runtime files and license proof. |

## Approved Intake Strategy

1. Start with Kenney CC0 2D assets because Kenney states its asset-page game assets are CC0, usable in commercial projects, and attribution is not required.
2. Use OpenGameArt only when the individual asset page, not just a collection, shows a compatible license and file list.
3. Use paid itch.io packs only after saving the license file or page snapshot that proves APK redistribution, public repo redistribution, modification, attribution, and paid source commit rules.
4. Keep downloaded archives out of Git unless the row below says original downloaded files may be committed.
5. Do not use preview images, screenshots, thumbnails, store logos, or marketing art as game assets unless the same page explicitly licenses that exact file.

## Candidate Ledger

| asset role | source URL | author | license | commercial-use status | APK redistribution status | public repo redistribution status | modification permission | required attribution text | original paid/download files allowed to be committed | intake decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Primary urban RPG tiles, props, vehicles, and four-direction characters | https://kenney.nl/assets/rpg-urban-pack and https://kenney-assets.itch.io/rpg-urban-kit | Kenney | Creative Commons CC0 1.0 Universal | Yes, source page states commercial projects are allowed. | Yes, CC0 permits bundling modified or unmodified runtime assets in the APK. | Yes for project-ready extracted CC0 files and the license proof. Prefer not to commit the zip archive. | Yes, CC0 permits edits. | Optional: `Assets by Kenney (kenney.nl), CC0.` Do not use the Kenney logo. | Yes for CC0 content if needed; no for convenience bundles or purchase artifacts unless their license file expressly allows public mirror distribution. | Approved first choice. |
| Compact overworld/town fallback tiles | https://kenney.nl/assets/tiny-town | Kenney | Creative Commons CC0 | Yes, covered by Kenney asset-page CC0 policy. | Yes, CC0 permits APK bundling. | Yes for project-ready extracted CC0 files and the license proof. Prefer not to commit the zip archive. | Yes, CC0 permits edits. | Optional: `Assets by Kenney (kenney.nl), CC0.` Do not use the Kenney logo. | Yes for CC0 content if needed; no for all-in-one bundle archives or purchase artifacts unless license proof allows public mirror distribution. | Approved fallback if the urban pack does not cover a needed map area. |
| Top-down combat or prototype props | https://www.kenney.nl/assets/top-down-shooter | Kenney | Creative Commons CC0 | Yes, covered by Kenney asset-page CC0 policy. | Yes, CC0 permits APK bundling. | Yes for project-ready extracted CC0 files and the license proof. Prefer not to commit the zip archive. | Yes, CC0 permits edits. | Optional: `Assets by Kenney (kenney.nl), CC0.` Do not use the Kenney logo. | Yes for CC0 content if needed; no for all-in-one bundle archives or purchase artifacts unless license proof allows public mirror distribution. | Approved only if visual style remains coherent with the selected base pack. |
| Dungeon floor and wall tiles | https://opengameart.org/content/top-down-dungeon-pack | Screaming Brain Studios | CC0 | Yes, source page states commercial and non-commercial projects are allowed. | Yes, source page and CC0 allow redistribution in the APK. | Yes for downloaded CC0 files and license proof. | Yes, CC0 permits edits. | Optional: `Top Down Dungeon Pack by Screaming Brain Studios, CC0.` | Yes, because the source page publishes the downloadable asset under CC0. | Approved secondary source after recording page snapshot and license proof. |
| Simple top-down tileset construction templates | https://opengameart.org/content/top-down-simple-tile-sets | yd | CC0 | Yes, CC0 permits commercial use. | Yes, CC0 permits APK bundling. | Yes for downloaded CC0 files and license proof. | Yes, CC0 permits edits. | Optional: `Top-down simple tile-sets by yd, CC0.` | Yes, because the source page lists the files under CC0. | Approved for prototyping or internal tile editing. |
| Top-down adventure character, NPC, tiles, and chiptune pack | https://opengameart.org/content/top-down-adventure-assets | ansimuz | CC0 | Yes, source page states personal and commercial projects are allowed. | Yes, source page states the file can be redistributed. | Yes, source page states the file can be redistributed. | Yes, source page states assets can be modified. | Optional: `Top Down Adventure Assets by Ansimuz, CC0.` | Yes, because the source page states the file can be redistributed. | Approved only if the mixed art/audio style is accepted for the game direction. |
| RPG UI status and item icons | https://opengameart.org/content/rpg-ui-icons | OwlishMedia | CC0 | Yes, CC0 permits commercial use. | Yes, CC0 permits APK bundling. | Yes for downloaded CC0 files and license proof. | Yes, CC0 permits edits. | Optional: `RPG UI Icons by OwlishMedia, CC0.` | Yes, because the source page lists the download under CC0. | Approved for UI prototyping and icon placeholders. |
| 16x16 overworld tiles | https://opengameart.org/content/16x16-puny-world-tileset | Shade | CC0 | Yes, source page states commercial use is allowed. | Yes, CC0 permits APK bundling. | Yes for downloaded CC0 files and license proof. | Yes, source page states modification is allowed. | Optional: `16x16 Puny World Tileset by Shade, CC0.` | Yes, because the source page lists the file under CC0. | Approved fallback if scale and palette match the final art direction. |

## Allowed Licenses

| license | allowed for closed commercial APK | allowed in public repository | attribution requirement | notes |
| --- | --- | --- | --- | --- |
| CC0 1.0 Universal / Public Domain dedication | Yes. | Yes, when the exact asset file is published under CC0. | None required; optional credit recommended. | Preferred license for Wave 0. |
| Public Domain with explicit creator statement | Yes. | Yes, when the statement permits redistribution. | None unless the source text requests courtesy credit. | Save a page snapshot or bundled text file. |
| CC-BY 4.0 / OGA-BY | Yes, if attribution is complete and no extra restriction conflicts with APK distribution. | Yes, if the asset file and derivatives may be redistributed. | Required. | Use only when the attribution burden is accepted in CREDITS.md. |
| Paid royalty-free license | Yes only when the paid license explicitly allows commercial game use and APK redistribution. | Only when the paid license explicitly allows public redistribution of the source files. | Follow the license text. | Default decision is to keep original paid files out of Git and commit only runtime derivatives if permitted. |

## Prohibited Or Blocked Licenses

| license or source condition | default decision | reason |
| --- | --- | --- |
| GPL, LGPL, or code-style copyleft applied to art assets | Block for a closed APK unless legal/product explicitly accepts the obligations. | Copyleft obligations can conflict with closed commercial distribution. |
| CC-BY-SA or OGA-BY-SA | Block for a closed APK unless share-alike obligations are explicitly accepted. | Share-alike terms can affect derivative art distribution. |
| NC, non-commercial, educational-use, personal-use, or fan-use terms | Block. | Commercial APK use is not allowed. |
| ND or no-derivatives terms | Block. | Runtime preparation usually requires resizing, slicing, compression, or palette edits. |
| Marketplace preview images, screenshots, thumbnails, logos, or mockups | Block as source assets unless that exact file is licensed for reuse. | Preview media can include third-party work or rights-reserved branding. |
| Ripped, traced, AI-recreated, trademarked, or franchise-derived art | Block. | Provenance and third-party rights are not commercially safe. |
| Paid pack without a license file or page snapshot proving redistribution terms | Block. | Purchase access alone does not prove public repository rights. |

## Intake Checklist

For each imported asset:

1. Save the source URL, author, license, and access date in this ledger.
2. Save the source page snapshot or bundled license text under the asset's future license-proof location.
3. Record whether commercial use, APK redistribution, public repo redistribution, modification, attribution, and paid source commit are allowed.
4. Commit only project-ready runtime files, metadata needed by Godot, and license proof.
5. Add or update the exact credit text in CREDITS.md before shipping any build that contains the asset.
