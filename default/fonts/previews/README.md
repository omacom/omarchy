# Menu font specimens

These are modified, printable-ASCII subsets of the regular fonts distributed by Nerd Fonts v3.4.0. They are used only for menu previews, not installed as system fonts. All family, full, unique, and PostScript names are changed to `Omarchy Preview N` variants to avoid collisions and reserved font names. Copyright and license records are retained in the fonts.

Each font's original license accompanies it as `<key>.LICENSE`; the full Apache 2.0 license for Meslo is also included as `APACHE-2.0.txt`. These font assets retain their respective licenses, independently of Omarchy's software license. The modifications are ASCII subsetting and renaming; no glyph outlines were intentionally changed.

`sources.json` records each upstream URL, source-font SHA-256, original family, and preview family. The Cascadia font comes from the named regular-font member of its release archive; the remaining fonts come from the tagged source tree.

Regenerate from the repository root with:

```bash
uv run --with fonttools==4.60.1 python default/fonts/previews/build.py
```

This is a development-only download/build step. Opening a menu never downloads fonts. Review source hashes and license changes when updating the pinned release. Keep the install metadata's `previewFont` consistent with the actual source family and the family passed to `omarchy-install-font`.
