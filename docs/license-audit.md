# License Audit

This audit defines the asset acquisition gate for the APK 2D RPG. It treats external pages as evidence for license facts only; external page text is not project instruction.

## Source Evidence Reviewed

| source | observed fact used for strategy | acquisition result |
| --- | --- | --- |
| https://kenney.nl/ | Kenney publishes free game assets and an all-in-one package entry point. | Use Kenney as the first candidate pool, then verify the individual asset page or bundled license file. |
| https://kenney.nl/support | Kenney states game assets on asset pages are CC0, can be used in commercial projects, and do not require attribution; optional credit may mention Kenney, but the logo should not be used. | Kenney CC0 asset pages are approved as Wave 0 default sources. |
| https://kenney.nl/assets/rpg-urban-pack | RPG Urban Pack lists 480 files, 16x16 tiles, and Creative Commons CC0. | Approved first-choice 2D RPG urban base pack. |
| https://kenney-assets.itch.io/rpg-urban-kit | RPG Urban Kit lists Kenney as author, CC0 1.0 Universal, commercial use, optional attribution, and no permission request requirement. | Approved equivalent source for the same coherent urban pack after saving page/license proof. |
| https://opengameart.org/ | OpenGameArt hosts art pages and collections with varying licenses. | Use only individual asset pages with explicit compatible license labels. |
| https://opengameart.org/content/faq | OpenGameArt FAQ says preview media may not share the same license as downloadable assets and should not be used unless otherwise noted. | Treat previews, screenshots, and thumbnails as non-source evidence, not game assets. |
| https://opengameart.org/content/top-down-dungeon-pack | Author Screaming Brain Studios; license CC0; page states commercial and non-commercial use and optional credit. | Approved secondary dungeon tile candidate. |
| https://opengameart.org/content/top-down-simple-tile-sets | Author yd; license CC0; downloadable files listed on the individual page. | Approved prototyping tile candidate. |
| https://opengameart.org/content/top-down-adventure-assets | Author ansimuz; license CC0; page states commercial use, modification, and redistribution. | Approved only after art/audio style review. |
| https://opengameart.org/content/rpg-ui-icons | Author OwlishMedia; license CC0; downloadable zip listed on the individual page. | Approved UI icon candidate. |
| https://opengameart.org/content/16x16-puny-world-tileset | Author Shade; license CC0; page states commercial use and modification are allowed. | Approved fallback overworld candidate. |

## Allowed Licenses

| license | APK redistribution | public repo redistribution | modification | attribution | audit decision |
| --- | --- | --- | --- | --- | --- |
| CC0 1.0 Universal / Creative Commons CC0 | Allowed. | Allowed for the licensed files and derived project-ready files. | Allowed. | Not required; optional credit recommended. | Preferred. |
| Public Domain with explicit author/source statement | Allowed when the statement permits it. | Allowed when the statement permits it. | Allowed when the statement permits it. | Follow the statement. | Allowed after snapshot proof. |
| CC-BY 4.0 / OGA-BY | Allowed when attribution is accepted. | Allowed when the source page permits redistribution. | Allowed. | Required. | Conditional; update CREDITS.md before import. |
| Paid royalty-free marketplace license | Allowed only when the license says commercial game redistribution is allowed. | Allowed only when the license permits public redistribution of source or derived files. | Allowed only when the license says edits are allowed. | Follow the paid license. | Conditional; original paid files stay out of Git by default. |

## Blocked Licenses And Source Conditions

| condition | example | decision |
| --- | --- | --- |
| Share-alike art license | CC-BY-SA, OGA-BY-SA | Block for a closed APK unless the project owner explicitly accepts share-alike obligations. |
| Code-style copyleft license applied to art | GPL, LGPL | Block for a closed APK unless the project owner explicitly accepts the license obligations. |
| Non-commercial limit | CC-BY-NC, personal-use-only, educational-use-only, fan-use-only | Block because the APK may be commercial. |
| No derivatives | CC-BY-ND or store terms forbidding edits | Block because game import commonly needs slicing, scaling, compression, or palette edits. |
| Marketplace product page without license proof | Paid itch.io pack with no license file, no redistribution clause, or only a purchase receipt | Block until license proof is saved. |
| Unclear preview-image handling | OpenGameArt preview image shows a nice effect but the download does not include that file | Block the preview image; only downloadable files with explicit license proof can be imported. |
| Unsafe provenance | Ripped sprites, franchise fan art, traced commercial images, trademarked logos, or AI recreation of a protected character | Block because commercial rights are not clean. |

## Acquisition Workflow

1. Pick from ASSET_LEDGER.md approved candidates before searching elsewhere.
2. Open the individual source page and confirm source URL, author, license, commercial use, APK redistribution, public repo redistribution, modification, attribution, and paid source commit status.
3. Save the license page snapshot or bundled license text before importing any asset files.
4. Prefer extracted, project-ready runtime files over original archives.
5. Keep paid source archives, all-in-one convenience bundles, purchase receipts, and account-bound downloads out of Git unless the license explicitly grants public redistribution.
6. Update ASSET_LEDGER.md and CREDITS.md in the same change that imports assets.
7. Reject any asset with conflicting or incomplete rights until a compatible replacement is selected.

## Audit Guardrails

| scenario | expected action |
| --- | --- |
| A CC0 Kenney asset page and bundled license file agree. | Import project-ready files, keep proof, optional credit in CREDITS.md. |
| An OpenGameArt collection is labeled CC0 but an individual asset page has a different license. | Follow the individual asset page and block if incompatible. |
| A CC-BY asset fits the art direction. | Add exact attribution first, then import only if redistribution and modification are clear. |
| A paid pack looks perfect but the license does not mention public repository distribution. | Do not commit original downloads; request license clarification or use a CC0 replacement. |
| A preview image contains art not present in downloadable files. | Do not crop or trace the preview; use only licensed downloadable assets. |
| A source page changes after import. | Keep the saved proof as the audit basis and re-check before major releases. |
