# Menu font specimens

These are modified, printable-ASCII subsets of regular Nerd Fonts (the original six are from v3.4.0). They are used only for menu previews, not installed as system fonts. All family, full, unique, and PostScript names are changed to private `Omarchy Preview` variants to avoid collisions and reserved font names. Copyright and license records are retained in the fonts.

Each font's original license accompanies it as `<key>.LICENSE`; the full Apache 2.0 license for Meslo is also included as `APACHE-2.0.txt`. These font assets retain their respective licenses, independently of Omarchy's software license. The modifications are ASCII subsetting and renaming; no glyph outlines were intentionally changed.

`sources.json` configures each upstream font/license URL or archive member and records the source-font SHA-256, original family, and preview family. The Cascadia font comes from the named regular-font member of its release archive; the remaining original fonts come from the tagged source tree.

Regenerate from the repository root with:

```bash
uv run --with fonttools==4.60.1 python default/fonts/previews/build.py
# Or rebuild just one specimen:
uv run --with fonttools==4.60.1 python default/fonts/previews/build.py rebuild fira
```

To add a font, use the generator's `add` command; see [`agents/skills/font-previews.md`](../../../agents/skills/font-previews.md) for source selection, local-file inputs, menu wiring, licenses, and verification. Existing keys are protected against accidental replacement.

This is a development-only download/build step. Opening a menu never downloads fonts. Rebuilds verify source hashes; review hashes and license changes when updating a pinned release. Keep the install metadata's `previewFont` consistent with the actual source family and the family passed to `omarchy-install-font`. The existing menu test enforces preview coverage in pull-request CI. The separately bundled Apache license is retained as-is during rebuilds.
