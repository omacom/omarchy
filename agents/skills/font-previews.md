# Font Installation Options and Previews

Read this before adding or changing a font installation option in `default/omarchy/omarchy-menu.jsonc` or its bundled preview in `default/fonts/previews/`. For branded icon glyphs, use [`icon-font.md`](icon-font.md) instead.

## Create the specimen

1. Choose a packaged Nerd Font and identify the exact static, regular-weight TrueType family passed to `omarchy-install-font`. Use the same variant for the preview: Nerd Font and Nerd Font Mono are not interchangeable.
2. Find pinned upstream HTTPS URLs for the full font and its license. Check that the license permits modification and redistribution; keep any required additional license files (Meslo also needs `APACHE-2.0.txt`). Prefer a release tag, not a moving branch.
3. From the repository root, run the generator with a key matching the menu option's final ID component:

```bash
uv run --with fonttools==4.60.1 python default/fonts/previews/build.py add example-mono \
  --font-url https://example.org/releases/v1.2/ExampleMonoNerdFont-Regular.ttf \
  --license-url https://example.org/releases/v1.2/OFL.txt
```

The URLs above are placeholders. If the source font and license are already downloaded, add `--font /path/to/full-font.ttf --license /path/to/LICENSE`; still supply the real upstream URLs so another contributor can rebuild the preview. New additions accept direct files, not release archives; extract an archive's regular face locally and use a pinned direct upstream file URL for future rebuilds.

The generator creates `<key>.ttf`, `<key>.LICENSE`, and a `sources.json` record, then prints the menu's `previewFont` and `previewFontFile` fields. It retains printable ASCII and shaping rules, preserves copyright/license name records, and gives the specimen a private `Omarchy Preview <key>` family. Never install specimens into fontconfig: their distinct family names keep incomplete fonts from shadowing the full installed font. Existing preview families stay unchanged when adding another font.

## Wire the menu

Add the font under `install.style.font` in `default/omarchy/omarchy-menu.jsonc`. Set `previewFont` and `previewFontFile` to the generated metadata, and use the exact same full family as the third argument to `omarchy-install-font`:

```jsonc
"install.style.font.example-mono": {"icon":"","label":"Example Mono","previewFont":"ExampleMono Nerd Font","previewFontFile":"default/fonts/previews/example-mono.ttf","action":"omarchy-install-font 'Example Mono' ttf-example-mono-nerd 'ExampleMono Nerd Font'"},
```

Use the actual generated family, package and display name, not these placeholders. Follow the existing menu's quoting convention. Follow [`../../docs/i18n.md`](../../docs/i18n.md) for any new translatable labels; font names remain unchanged. Update the available-font list in `manual/38-fonts.md` when appropriate.

## Verify and commit

Run the existing menu checks and read their saved output:

```bash
bash test/shell.d/menu-test.sh >/tmp/opencode/menu-test.log 2>&1
```

This test runs in existing pull-request CI through `./test/all`. It checks all font-install options for offline assets, matching install/source families, provenance, private font names, size, and licenses without downloading upstream fonts. It does not judge whether the font looks right or whether the license permits redistribution.

Verify the new option in the running menu before installation, following [`visual-verification.md`](visual-verification.md). Confirm the specimen renders rather than “Preview unavailable”, its regular face is correct, and its sample is not clipped. Then install/select the full font in a disposable VM and compare it. Commit the menu, generated specimen, license, and manifest together; previews must work offline on a fresh checkout.

## Rebuild or update

```bash
uv run --with fonttools==4.60.1 python default/fonts/previews/build.py rebuild example-mono
# Omit keys (or run without arguments) to rebuild every specimen.
```

`sources.json` is the source configuration as well as the provenance record. It supports direct font/license URLs and named members of existing release archives. Rebuilds verify each full source font's SHA-256 before writing its preview. To update a font, review the new upstream font, license, URLs and hash, then update that record and rebuild only its key. Keep `previewFamily` stable, and review license changes and generated diffs. The separately bundled Apache license is not downloaded by the generator.
